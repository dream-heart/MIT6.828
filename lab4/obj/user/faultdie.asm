
obj/user/faultdie：     文件格式 elf32-i386


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
  800059:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  800060:	e8 19 01 00 00       	call   80017e <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 6b 0b 00 00       	call   800bd5 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 11 0b 00 00       	call   800b83 <sys_env_destroy>
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
  800081:	e8 a2 0d 00 00       	call   800e28 <set_pgfault_handler>
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
  800095:	83 ec 18             	sub    $0x18,%esp
  800098:	8b 45 08             	mov    0x8(%ebp),%eax
  80009b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80009e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000a5:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a8:	85 c0                	test   %eax,%eax
  8000aa:	7e 08                	jle    8000b4 <libmain+0x22>
		binaryname = argv[0];
  8000ac:	8b 0a                	mov    (%edx),%ecx
  8000ae:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 b4 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000c0:	e8 02 00 00 00       	call   8000c7 <exit>
}
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d4:	e8 aa 0a 00 00       	call   800b83 <sys_env_destroy>
}
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	53                   	push   %ebx
  8000df:	83 ec 14             	sub    $0x14,%esp
  8000e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e5:	8b 13                	mov    (%ebx),%edx
  8000e7:	8d 42 01             	lea    0x1(%edx),%eax
  8000ea:	89 03                	mov    %eax,(%ebx)
  8000ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f8:	75 19                	jne    800113 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000fa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800101:	00 
  800102:	8d 43 08             	lea    0x8(%ebx),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 39 0a 00 00       	call   800b46 <sys_cputs>
		b->idx = 0;
  80010d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800113:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800117:	83 c4 14             	add    $0x14,%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800126:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012d:	00 00 00 
	b.cnt = 0;
  800130:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800137:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800141:	8b 45 08             	mov    0x8(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	c7 04 24 db 00 80 00 	movl   $0x8000db,(%esp)
  800159:	e8 76 01 00 00       	call   8002d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016e:	89 04 24             	mov    %eax,(%esp)
  800171:	e8 d0 09 00 00       	call   800b46 <sys_cputs>

	return b.cnt;
}
  800176:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800184:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 87 ff ff ff       	call   80011d <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    
  800198:	66 90                	xchg   %ax,%ax
  80019a:	66 90                	xchg   %ax,%ax
  80019c:	66 90                	xchg   %ax,%ax
  80019e:	66 90                	xchg   %ax,%ax

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 c3                	mov    %eax,%ebx
  8001b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001cd:	39 d9                	cmp    %ebx,%ecx
  8001cf:	72 05                	jb     8001d6 <printnum+0x36>
  8001d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001d4:	77 69                	ja     80023f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001dd:	83 ee 01             	sub    $0x1,%esi
  8001e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001f0:	89 c3                	mov    %eax,%ebx
  8001f2:	89 d6                	mov    %edx,%esi
  8001f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800202:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	e8 ac 0c 00 00       	call   800ec0 <__udivdi3>
  800214:	89 d9                	mov    %ebx,%ecx
  800216:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	89 54 24 04          	mov    %edx,0x4(%esp)
  800225:	89 fa                	mov    %edi,%edx
  800227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022a:	e8 71 ff ff ff       	call   8001a0 <printnum>
  80022f:	eb 1b                	jmp    80024c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	8b 45 18             	mov    0x18(%ebp),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	ff d3                	call   *%ebx
  80023d:	eb 03                	jmp    800242 <printnum+0xa2>
  80023f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800242:	83 ee 01             	sub    $0x1,%esi
  800245:	85 f6                	test   %esi,%esi
  800247:	7f e8                	jg     800231 <printnum+0x91>
  800249:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800250:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800254:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800257:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80025a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800262:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026f:	e8 7c 0d 00 00       	call   800ff0 <__umoddi3>
  800274:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800278:	0f be 80 86 11 80 00 	movsbl 0x801186(%eax),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800285:	ff d0                	call   *%eax
}
  800287:	83 c4 3c             	add    $0x3c,%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800295:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 0a                	jae    8002aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	88 02                	mov    %al,(%edx)
}
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	e8 02 00 00 00       	call   8002d4 <vprintfmt>
	va_end(ap);
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 3c             	sub    $0x3c,%esp
  8002dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e6:	eb 11                	jmp    8002f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 48 04 00 00    	je     800738 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8002f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	83 c7 01             	add    $0x1,%edi
  8002fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800300:	83 f8 25             	cmp    $0x25,%eax
  800303:	75 e3                	jne    8002e8 <vprintfmt+0x14>
  800305:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800309:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800317:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800323:	eb 1f                	jmp    800344 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800328:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032c:	eb 16                	jmp    800344 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800331:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800335:	eb 0d                	jmp    800344 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800337:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 17             	movzbl (%edi),%edx
  80034d:	0f b6 c2             	movzbl %dl,%eax
  800350:	83 ea 23             	sub    $0x23,%edx
  800353:	80 fa 55             	cmp    $0x55,%dl
  800356:	0f 87 bf 03 00 00    	ja     80071b <vprintfmt+0x447>
  80035c:	0f b6 d2             	movzbl %dl,%edx
  80035f:	ff 24 95 40 12 80 00 	jmp    *0x801240(,%edx,4)
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800374:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800378:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80037b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80037e:	83 f9 09             	cmp    $0x9,%ecx
  800381:	77 3c                	ja     8003bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 40 04             	lea    0x4(%eax),%eax
  800396:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039c:	eb 27                	jmp    8003c5 <vprintfmt+0xf1>
  80039e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	0f 49 c2             	cmovns %edx,%eax
  8003ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b1:	eb 91                	jmp    800344 <vprintfmt+0x70>
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bd:	eb 85                	jmp    800344 <vprintfmt+0x70>
  8003bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	0f 89 75 ff ff ff    	jns    800344 <vprintfmt+0x70>
  8003cf:	e9 63 ff ff ff       	jmp    800337 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003da:	e9 65 ff ff ff       	jmp    800344 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8003e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 00 ff ff ff       	jmp    8002f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	99                   	cltd   
  800403:	31 d0                	xor    %edx,%eax
  800405:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 09             	cmp    $0x9,%eax
  80040a:	7f 0b                	jg     800417 <vprintfmt+0x143>
  80040c:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  800413:	85 d2                	test   %edx,%edx
  800415:	75 20                	jne    800437 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800417:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041b:	c7 44 24 08 9e 11 80 	movl   $0x80119e,0x8(%esp)
  800422:	00 
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 34 24             	mov    %esi,(%esp)
  80042a:	e8 7d fe ff ff       	call   8002ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800432:	e9 c2 fe ff ff       	jmp    8002f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800437:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80043b:	c7 44 24 08 a7 11 80 	movl   $0x8011a7,0x8(%esp)
  800442:	00 
  800443:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800447:	89 34 24             	mov    %esi,(%esp)
  80044a:	e8 5d fe ff ff       	call   8002ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800452:	e9 a2 fe ff ff       	jmp    8002f9 <vprintfmt+0x25>
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80045d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800460:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800467:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800469:	85 ff                	test   %edi,%edi
  80046b:	b8 97 11 80 00       	mov    $0x801197,%eax
  800470:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800473:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800477:	0f 84 92 00 00 00    	je     80050f <vprintfmt+0x23b>
  80047d:	85 c9                	test   %ecx,%ecx
  80047f:	0f 8e 98 00 00 00    	jle    80051d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	89 54 24 04          	mov    %edx,0x4(%esp)
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	e8 47 03 00 00       	call   8007d8 <strnlen>
  800491:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800499:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	eb 0f                	jmp    8004b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ef 01             	sub    $0x1,%edi
  8004b6:	85 ff                	test   %edi,%edi
  8004b8:	7f ed                	jg     8004a7 <vprintfmt+0x1d3>
  8004ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c0:	85 c9                	test   %ecx,%ecx
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	0f 49 c1             	cmovns %ecx,%eax
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d5:	89 cb                	mov    %ecx,%ebx
  8004d7:	eb 50                	jmp    800529 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dd:	74 1e                	je     8004fd <vprintfmt+0x229>
  8004df:	0f be d2             	movsbl %dl,%edx
  8004e2:	83 ea 20             	sub    $0x20,%edx
  8004e5:	83 fa 5e             	cmp    $0x5e,%edx
  8004e8:	76 13                	jbe    8004fd <vprintfmt+0x229>
					putch('?', putdat);
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f8:	ff 55 08             	call   *0x8(%ebp)
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8004fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800500:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	eb 1a                	jmp    800529 <vprintfmt+0x255>
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051b:	eb 0c                	jmp    800529 <vprintfmt+0x255>
  80051d:	89 75 08             	mov    %esi,0x8(%ebp)
  800520:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800523:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800526:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800530:	0f be c2             	movsbl %dl,%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	74 25                	je     80055c <vprintfmt+0x288>
  800537:	85 f6                	test   %esi,%esi
  800539:	78 9e                	js     8004d9 <vprintfmt+0x205>
  80053b:	83 ee 01             	sub    $0x1,%esi
  80053e:	79 99                	jns    8004d9 <vprintfmt+0x205>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800555:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	eb 08                	jmp    800564 <vprintfmt+0x290>
  80055c:	89 df                	mov    %ebx,%edi
  80055e:	8b 75 08             	mov    0x8(%ebp),%esi
  800561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800564:	85 ff                	test   %edi,%edi
  800566:	7f e2                	jg     80054a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056b:	e9 89 fd ff ff       	jmp    8002f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800570:	83 f9 01             	cmp    $0x1,%ecx
  800573:	7e 19                	jle    80058e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 50 04             	mov    0x4(%eax),%edx
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 08             	lea    0x8(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb 38                	jmp    8005c6 <vprintfmt+0x2f2>
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 1b                	je     8005ad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 c1                	mov    %eax,%ecx
  80059c:	c1 f9 1f             	sar    $0x1f,%ecx
  80059f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ab:	eb 19                	jmp    8005c6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b5:	89 c1                	mov    %eax,%ecx
  8005b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005cc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d5:	0f 89 04 01 00 00    	jns    8006df <vprintfmt+0x40b>
				putch('-', putdat);
  8005db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ee:	f7 da                	neg    %edx
  8005f0:	83 d1 00             	adc    $0x0,%ecx
  8005f3:	f7 d9                	neg    %ecx
  8005f5:	e9 e5 00 00 00       	jmp    8006df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7e 10                	jle    80060f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
  80060d:	eb 26                	jmp    800635 <vprintfmt+0x361>
	else if (lflag)
  80060f:	85 c9                	test   %ecx,%ecx
  800611:	74 12                	je     800625 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
  800623:	eb 10                	jmp    800635 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800635:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80063a:	e9 a0 00 00 00       	jmp    8006df <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80064a:	ff d6                	call   *%esi
			putch('X', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800657:	ff d6                	call   *%esi
			putch('X', putdat);
  800659:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800664:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800669:	e9 8b fc ff ff       	jmp    8002f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80066e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800672:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800679:	ff d6                	call   *%esi
			putch('x', putdat);
  80067b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800686:	ff d6                	call   *%esi
			num = (unsigned long long)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800698:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80069d:	eb 40                	jmp    8006df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7e 10                	jle    8006b4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ac:	8d 40 08             	lea    0x8(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b2:	eb 26                	jmp    8006da <vprintfmt+0x406>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	74 12                	je     8006ca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c8:	eb 10                	jmp    8006da <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006da:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8006f2:	89 14 24             	mov    %edx,(%esp)
  8006f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006f9:	89 da                	mov    %ebx,%edx
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	e8 9e fa ff ff       	call   8001a0 <printnum>
			break;
  800702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800705:	e9 ef fb ff ff       	jmp    8002f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	89 04 24             	mov    %eax,(%esp)
  800711:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800716:	e9 de fb ff ff       	jmp    8002f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800726:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	eb 03                	jmp    80072d <vprintfmt+0x459>
  80072a:	83 ef 01             	sub    $0x1,%edi
  80072d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800731:	75 f7                	jne    80072a <vprintfmt+0x456>
  800733:	e9 c1 fb ff ff       	jmp    8002f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800738:	83 c4 3c             	add    $0x3c,%esp
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5f                   	pop    %edi
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 28             	sub    $0x28,%esp
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800753:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075d:	85 c0                	test   %eax,%eax
  80075f:	74 30                	je     800791 <vsnprintf+0x51>
  800761:	85 d2                	test   %edx,%edx
  800763:	7e 2c                	jle    800791 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076c:	8b 45 10             	mov    0x10(%ebp),%eax
  80076f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800773:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077a:	c7 04 24 8f 02 80 00 	movl   $0x80028f,(%esp)
  800781:	e8 4e fb ff ff       	call   8002d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800786:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800789:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078f:	eb 05                	jmp    800796 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	89 04 24             	mov    %eax,(%esp)
  8007b9:	e8 82 ff ff ff       	call   800740 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strnlen+0x13>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1d>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f3                	jne    8007e8 <strnlen+0x10>
		n++;
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	89 c2                	mov    %eax,%edx
  800803:	83 c2 01             	add    $0x1,%edx
  800806:	83 c1 01             	add    $0x1,%ecx
  800809:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800810:	84 db                	test   %bl,%bl
  800812:	75 ef                	jne    800803 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800821:	89 1c 24             	mov    %ebx,(%esp)
  800824:	e8 97 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800830:	01 d8                	add    %ebx,%eax
  800832:	89 04 24             	mov    %eax,(%esp)
  800835:	e8 bd ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	5b                   	pop    %ebx
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	89 f3                	mov    %esi,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	89 f2                	mov    %esi,%edx
  800854:	eb 0f                	jmp    800865 <strncpy+0x23>
		*dst++ = *src;
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	0f b6 01             	movzbl (%ecx),%eax
  80085c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085f:	80 39 01             	cmpb   $0x1,(%ecx)
  800862:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	39 da                	cmp    %ebx,%edx
  800867:	75 ed                	jne    800856 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800869:	89 f0                	mov    %esi,%eax
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 75 08             	mov    0x8(%ebp),%esi
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80087d:	89 f0                	mov    %esi,%eax
  80087f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800883:	85 c9                	test   %ecx,%ecx
  800885:	75 0b                	jne    800892 <strlcpy+0x23>
  800887:	eb 1d                	jmp    8008a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 0b                	je     8008a1 <strlcpy+0x32>
  800896:	0f b6 0a             	movzbl (%edx),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	75 ec                	jne    800889 <strlcpy+0x1a>
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	eb 02                	jmp    8008a3 <strlcpy+0x34>
  8008a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a6:	29 f0                	sub    %esi,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strcmp+0x11>
		p++, q++;
  8008b7:	83 c1 01             	add    $0x1,%ecx
  8008ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 04                	je     8008c8 <strcmp+0x1c>
  8008c4:	3a 02                	cmp    (%edx),%al
  8008c6:	74 ef                	je     8008b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 c0             	movzbl %al,%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 c3                	mov    %eax,%ebx
  8008de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e1:	eb 06                	jmp    8008e9 <strncmp+0x17>
		n--, p++, q++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e9:	39 d8                	cmp    %ebx,%eax
  8008eb:	74 15                	je     800902 <strncmp+0x30>
  8008ed:	0f b6 08             	movzbl (%eax),%ecx
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	74 04                	je     8008f8 <strncmp+0x26>
  8008f4:	3a 0a                	cmp    (%edx),%cl
  8008f6:	74 eb                	je     8008e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	eb 05                	jmp    800907 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	eb 07                	jmp    80091d <strchr+0x13>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 0f                	je     800929 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	0f b6 10             	movzbl (%eax),%edx
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f2                	jne    800916 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800935:	eb 07                	jmp    80093e <strfind+0x13>
		if (*s == c)
  800937:	38 ca                	cmp    %cl,%dl
  800939:	74 0a                	je     800945 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093b:	83 c0 01             	add    $0x1,%eax
  80093e:	0f b6 10             	movzbl (%eax),%edx
  800941:	84 d2                	test   %dl,%dl
  800943:	75 f2                	jne    800937 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800953:	85 c9                	test   %ecx,%ecx
  800955:	74 36                	je     80098d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800957:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095d:	75 28                	jne    800987 <memset+0x40>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 23                	jne    800987 <memset+0x40>
		c &= 0xFF;
  800964:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800968:	89 d3                	mov    %edx,%ebx
  80096a:	c1 e3 08             	shl    $0x8,%ebx
  80096d:	89 d6                	mov    %edx,%esi
  80096f:	c1 e6 18             	shl    $0x18,%esi
  800972:	89 d0                	mov    %edx,%eax
  800974:	c1 e0 10             	shl    $0x10,%eax
  800977:	09 f0                	or     %esi,%eax
  800979:	09 c2                	or     %eax,%edx
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800982:	fc                   	cld    
  800983:	f3 ab                	rep stos %eax,%es:(%edi)
  800985:	eb 06                	jmp    80098d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 35                	jae    8009db <memmove+0x47>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2e                	jae    8009db <memmove+0x47>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ba:	75 13                	jne    8009cf <memmove+0x3b>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0e                	jne    8009cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 09                	jmp    8009d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d8:	fc                   	cld    
  8009d9:	eb 1d                	jmp    8009f8 <memmove+0x64>
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009df:	f6 c2 03             	test   $0x3,%dl
  8009e2:	75 0f                	jne    8009f3 <memmove+0x5f>
  8009e4:	f6 c1 03             	test   $0x3,%cl
  8009e7:	75 0a                	jne    8009f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f1:	eb 05                	jmp    8009f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f3:	89 c7                	mov    %eax,%edi
  8009f5:	fc                   	cld    
  8009f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f8:	5e                   	pop    %esi
  8009f9:	5f                   	pop    %edi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a02:	8b 45 10             	mov    0x10(%ebp),%eax
  800a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 79 ff ff ff       	call   800994 <memmove>
}
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 55 08             	mov    0x8(%ebp),%edx
  800a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a28:	89 d6                	mov    %edx,%esi
  800a2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2d:	eb 1a                	jmp    800a49 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2f:	0f b6 02             	movzbl (%edx),%eax
  800a32:	0f b6 19             	movzbl (%ecx),%ebx
  800a35:	38 d8                	cmp    %bl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 db             	movzbl %bl,%ebx
  800a3f:	29 d8                	sub    %ebx,%eax
  800a41:	eb 0f                	jmp    800a52 <memcmp+0x35>
		s1++, s2++;
  800a43:	83 c2 01             	add    $0x1,%edx
  800a46:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a49:	39 f2                	cmp    %esi,%edx
  800a4b:	75 e2                	jne    800a2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a64:	eb 07                	jmp    800a6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a66:	38 08                	cmp    %cl,(%eax)
  800a68:	74 07                	je     800a71 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	39 d0                	cmp    %edx,%eax
  800a6f:	72 f5                	jb     800a66 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	eb 03                	jmp    800a84 <strtol+0x11>
		s++;
  800a81:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a84:	0f b6 0a             	movzbl (%edx),%ecx
  800a87:	80 f9 09             	cmp    $0x9,%cl
  800a8a:	74 f5                	je     800a81 <strtol+0xe>
  800a8c:	80 f9 20             	cmp    $0x20,%cl
  800a8f:	74 f0                	je     800a81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a91:	80 f9 2b             	cmp    $0x2b,%cl
  800a94:	75 0a                	jne    800aa0 <strtol+0x2d>
		s++;
  800a96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9e:	eb 11                	jmp    800ab1 <strtol+0x3e>
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	80 f9 2d             	cmp    $0x2d,%cl
  800aa8:	75 07                	jne    800ab1 <strtol+0x3e>
		s++, neg = 1;
  800aaa:	8d 52 01             	lea    0x1(%edx),%edx
  800aad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ab6:	75 15                	jne    800acd <strtol+0x5a>
  800ab8:	80 3a 30             	cmpb   $0x30,(%edx)
  800abb:	75 10                	jne    800acd <strtol+0x5a>
  800abd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac1:	75 0a                	jne    800acd <strtol+0x5a>
		s += 2, base = 16;
  800ac3:	83 c2 02             	add    $0x2,%edx
  800ac6:	b8 10 00 00 00       	mov    $0x10,%eax
  800acb:	eb 10                	jmp    800add <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800acd:	85 c0                	test   %eax,%eax
  800acf:	75 0c                	jne    800add <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad6:	75 05                	jne    800add <strtol+0x6a>
		s++, base = 8;
  800ad8:	83 c2 01             	add    $0x1,%edx
  800adb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800add:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 0a             	movzbl (%edx),%ecx
  800ae8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800aeb:	89 f0                	mov    %esi,%eax
  800aed:	3c 09                	cmp    $0x9,%al
  800aef:	77 08                	ja     800af9 <strtol+0x86>
			dig = *s - '0';
  800af1:	0f be c9             	movsbl %cl,%ecx
  800af4:	83 e9 30             	sub    $0x30,%ecx
  800af7:	eb 20                	jmp    800b19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800af9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800afc:	89 f0                	mov    %esi,%eax
  800afe:	3c 19                	cmp    $0x19,%al
  800b00:	77 08                	ja     800b0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 57             	sub    $0x57,%ecx
  800b08:	eb 0f                	jmp    800b19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b0d:	89 f0                	mov    %esi,%eax
  800b0f:	3c 19                	cmp    $0x19,%al
  800b11:	77 16                	ja     800b29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b13:	0f be c9             	movsbl %cl,%ecx
  800b16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b1c:	7d 0f                	jge    800b2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b27:	eb bc                	jmp    800ae5 <strtol+0x72>
  800b29:	89 d8                	mov    %ebx,%eax
  800b2b:	eb 02                	jmp    800b2f <strtol+0xbc>
  800b2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b33:	74 05                	je     800b3a <strtol+0xc7>
		*endptr = (char *) s;
  800b35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b3a:	f7 d8                	neg    %eax
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	89 c6                	mov    %eax,%esi
  800b5d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b91:	b8 03 00 00 00       	mov    $0x3,%eax
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 cb                	mov    %ecx,%ebx
  800b9b:	89 cf                	mov    %ecx,%edi
  800b9d:	89 ce                	mov    %ecx,%esi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 28                	jle    800bcd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb0:	00 
  800bb1:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800bb8:	00 
  800bb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc0:	00 
  800bc1:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800bc8:	e8 90 02 00 00       	call   800e5d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcd:	83 c4 2c             	add    $0x2c,%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 02 00 00 00       	mov    $0x2,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_yield>:

void
sys_yield(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	be 00 00 00 00       	mov    $0x0,%esi
  800c21:	b8 04 00 00 00       	mov    $0x4,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2f:	89 f7                	mov    %esi,%edi
  800c31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 28                	jle    800c5f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c42:	00 
  800c43:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c52:	00 
  800c53:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800c5a:	e8 fe 01 00 00       	call   800e5d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5f:	83 c4 2c             	add    $0x2c,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	b8 05 00 00 00       	mov    $0x5,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c81:	8b 75 18             	mov    0x18(%ebp),%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 28                	jle    800cb2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c95:	00 
  800c96:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca5:	00 
  800ca6:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800cad:	e8 ab 01 00 00       	call   800e5d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb2:	83 c4 2c             	add    $0x2c,%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 28                	jle    800d05 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf8:	00 
  800cf9:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800d00:	e8 58 01 00 00       	call   800e5d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d05:	83 c4 2c             	add    $0x2c,%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 28                	jle    800d58 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d3b:	00 
  800d3c:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800d43:	00 
  800d44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4b:	00 
  800d4c:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800d53:	e8 05 01 00 00       	call   800e5d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d58:	83 c4 2c             	add    $0x2c,%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 28                	jle    800dab <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d87:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800d96:	00 
  800d97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9e:	00 
  800d9f:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800da6:	e8 b2 00 00 00       	call   800e5d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dab:	83 c4 2c             	add    $0x2c,%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	be 00 00 00 00       	mov    $0x0,%esi
  800dbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 cb                	mov    %ecx,%ebx
  800dee:	89 cf                	mov    %ecx,%edi
  800df0:	89 ce                	mov    %ecx,%esi
  800df2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df4:	85 c0                	test   %eax,%eax
  800df6:	7e 28                	jle    800e20 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e03:	00 
  800e04:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e13:	00 
  800e14:	c7 04 24 e5 13 80 00 	movl   $0x8013e5,(%esp)
  800e1b:	e8 3d 00 00 00       	call   800e5d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e20:	83 c4 2c             	add    $0x2c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e2e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e35:	75 1c                	jne    800e53 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800e37:	c7 44 24 08 f4 13 80 	movl   $0x8013f4,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  800e4e:	e8 0a 00 00 00       	call   800e5d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e65:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e68:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e6e:	e8 62 fd ff ff       	call   800bd5 <sys_getenvid>
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e81:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e89:	c7 04 24 28 14 80 00 	movl   $0x801428,(%esp)
  800e90:	e8 e9 f2 ff ff       	call   80017e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e99:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	e8 79 f2 ff ff       	call   80011d <vcprintf>
	cprintf("\n");
  800ea4:	c7 04 24 7a 11 80 00 	movl   $0x80117a,(%esp)
  800eab:	e8 ce f2 ff ff       	call   80017e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eb0:	cc                   	int3   
  800eb1:	eb fd                	jmp    800eb0 <_panic+0x53>
  800eb3:	66 90                	xchg   %ax,%ax
  800eb5:	66 90                	xchg   %ax,%ax
  800eb7:	66 90                	xchg   %ax,%ax
  800eb9:	66 90                	xchg   %ax,%ax
  800ebb:	66 90                	xchg   %ax,%ax
  800ebd:	66 90                	xchg   %ax,%ax
  800ebf:	90                   	nop

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
