
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  80004e:	e8 54 01 00 00       	call   8001a7 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 b7 0b 00 00       	call   800c14 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  800074:	e8 2e 01 00 00       	call   8001a7 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 0c 12 80 00 	movl   $0x80120c,(%esp)
  800094:	e8 0e 01 00 00       	call   8001a7 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000b2:	e8 2d 0b 00 00       	call   800be4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 85 0a 00 00       	call   800b87 <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 f2 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 96 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 89 09 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
	...

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
  8001e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	75 08                	jne    8001fc <printnum+0x2c>
  8001f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fa:	77 59                	ja     800255 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800207:	8b 45 10             	mov    0x10(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800212:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800216:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021d:	00 
  80021e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	e8 e0 0c 00 00       	call   800f10 <__udivdi3>
  800230:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800234:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023f:	89 fa                	mov    %edi,%edx
  800241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800244:	e8 87 ff ff ff       	call   8001d0 <printnum>
  800249:	eb 11                	jmp    80025c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024f:	89 34 24             	mov    %esi,(%esp)
  800252:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800255:	83 eb 01             	sub    $0x1,%ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f ef                	jg     80024b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800272:	00 
  800273:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	e8 bb 0d 00 00       	call   801040 <__umoddi3>
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	0f be 80 35 12 80 00 	movsbl 0x801235(%eax),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800296:	83 c4 3c             	add    $0x3c,%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e7:	73 0a                	jae    8002f3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ec:	88 0a                	mov    %cl,(%edx)
  8002ee:	83 c2 01             	add    $0x1,%edx
  8002f1:	89 10                	mov    %edx,(%eax)
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800302:	8b 45 10             	mov    0x10(%ebp),%eax
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	e8 02 00 00 00       	call   80031d <vprintfmt>
	va_end(ap);
}
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 4c             	sub    $0x4c,%esp
  800326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800329:	8b 75 10             	mov    0x10(%ebp),%esi
  80032c:	eb 12                	jmp    800340 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032e:	85 c0                	test   %eax,%eax
  800330:	0f 84 bf 03 00 00    	je     8006f5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800336:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800340:	0f b6 06             	movzbl (%esi),%eax
  800343:	83 c6 01             	add    $0x1,%esi
  800346:	83 f8 25             	cmp    $0x25,%eax
  800349:	75 e3                	jne    80032e <vprintfmt+0x11>
  80034b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80034f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800356:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80036a:	eb 2b                	jmp    800397 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 22                	jmp    800397 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 19                	jmp    800397 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 0d                	jmp    800397 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800390:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	0f b6 16             	movzbl (%esi),%edx
  80039a:	0f b6 c2             	movzbl %dl,%eax
  80039d:	8d 7e 01             	lea    0x1(%esi),%edi
  8003a0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003a3:	83 ea 23             	sub    $0x23,%edx
  8003a6:	80 fa 55             	cmp    $0x55,%dl
  8003a9:	0f 87 28 03 00 00    	ja     8006d7 <vprintfmt+0x3ba>
  8003af:	0f b6 d2             	movzbl %dl,%edx
  8003b2:	ff 24 95 00 13 80 00 	jmp    *0x801300(,%edx,4)
  8003b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003bc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003cb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003cf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 2f                	ja     800409 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003da:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 50 04             	lea    0x4(%eax),%edx
  8003e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 1a                	jmp    80040c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f9:	79 9c                	jns    800397 <vprintfmt+0x7a>
  8003fb:	eb 81                	jmp    80037e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800400:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800407:	eb 8e                	jmp    800397 <vprintfmt+0x7a>
  800409:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80040c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800410:	79 85                	jns    800397 <vprintfmt+0x7a>
  800412:	e9 73 ff ff ff       	jmp    80038a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800417:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041d:	e9 75 ff ff ff       	jmp    800397 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	89 04 24             	mov    %eax,(%esp)
  800434:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043a:	e9 01 ff ff ff       	jmp    800340 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 fa 1f             	sar    $0x1f,%edx
  80044f:	31 d0                	xor    %edx,%eax
  800451:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 f8 09             	cmp    $0x9,%eax
  800456:	7f 0b                	jg     800463 <vprintfmt+0x146>
  800458:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	75 23                	jne    800486 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 4d 12 80 	movl   $0x80124d,0x8(%esp)
  80046e:	00 
  80046f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800473:	8b 7d 08             	mov    0x8(%ebp),%edi
  800476:	89 3c 24             	mov    %edi,(%esp)
  800479:	e8 77 fe ff ff       	call   8002f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800481:	e9 ba fe ff ff       	jmp    800340 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800486:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048a:	c7 44 24 08 56 12 80 	movl   $0x801256,0x8(%esp)
  800491:	00 
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 7d 08             	mov    0x8(%ebp),%edi
  800499:	89 3c 24             	mov    %edi,(%esp)
  80049c:	e8 54 fe ff ff       	call   8002f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a4:	e9 97 fe ff ff       	jmp    800340 <vprintfmt+0x23>
  8004a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	ba 46 12 80 00       	mov    $0x801246,%edx
  8004c4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cb:	0f 8e 8c 00 00 00    	jle    80055d <vprintfmt+0x240>
  8004d1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004d5:	0f 84 82 00 00 00    	je     80055d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004df:	89 34 24             	mov    %esi,(%esp)
  8004e2:	e8 b1 02 00 00       	call   800798 <strnlen>
  8004e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ea:	29 c2                	sub    %eax,%edx
  8004ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004ef:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004f3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004f6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004f9:	89 de                	mov    %ebx,%esi
  8004fb:	89 d3                	mov    %edx,%ebx
  8004fd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	eb 0d                	jmp    80050e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800501:	89 74 24 04          	mov    %esi,0x4(%esp)
  800505:	89 3c 24             	mov    %edi,(%esp)
  800508:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	85 db                	test   %ebx,%ebx
  800510:	7f ef                	jg     800501 <vprintfmt+0x1e4>
  800512:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800515:	89 f3                	mov    %esi,%ebx
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80051a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051e:	b8 00 00 00 00       	mov    $0x0,%eax
  800523:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800527:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052a:	29 c2                	sub    %eax,%edx
  80052c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80052f:	eb 2c                	jmp    80055d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800535:	74 18                	je     80054f <vprintfmt+0x232>
  800537:	8d 50 e0             	lea    -0x20(%eax),%edx
  80053a:	83 fa 5e             	cmp    $0x5e,%edx
  80053d:	76 10                	jbe    80054f <vprintfmt+0x232>
					putch('?', putdat);
  80053f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800543:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	eb 0a                	jmp    800559 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80054f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80055d:	0f be 06             	movsbl (%esi),%eax
  800560:	83 c6 01             	add    $0x1,%esi
  800563:	85 c0                	test   %eax,%eax
  800565:	74 25                	je     80058c <vprintfmt+0x26f>
  800567:	85 ff                	test   %edi,%edi
  800569:	78 c6                	js     800531 <vprintfmt+0x214>
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	79 c1                	jns    800531 <vprintfmt+0x214>
  800570:	8b 7d 08             	mov    0x8(%ebp),%edi
  800573:	89 de                	mov    %ebx,%esi
  800575:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800585:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	83 eb 01             	sub    $0x1,%ebx
  80058a:	eb 08                	jmp    800594 <vprintfmt+0x277>
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 de                	mov    %ebx,%esi
  800591:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f e2                	jg     80057a <vprintfmt+0x25d>
  800598:	89 7d 08             	mov    %edi,0x8(%ebp)
  80059b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a0:	e9 9b fd ff ff       	jmp    800340 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a5:	83 f9 01             	cmp    $0x1,%ecx
  8005a8:	7e 10                	jle    8005ba <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 08             	lea    0x8(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 30                	mov    (%eax),%esi
  8005b5:	8b 78 04             	mov    0x4(%eax),%edi
  8005b8:	eb 26                	jmp    8005e0 <vprintfmt+0x2c3>
	else if (lflag)
  8005ba:	85 c9                	test   %ecx,%ecx
  8005bc:	74 12                	je     8005d0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 30                	mov    (%eax),%esi
  8005c9:	89 f7                	mov    %esi,%edi
  8005cb:	c1 ff 1f             	sar    $0x1f,%edi
  8005ce:	eb 10                	jmp    8005e0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 30                	mov    (%eax),%esi
  8005db:	89 f7                	mov    %esi,%edi
  8005dd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	0f 89 ac 00 00 00    	jns    800699 <vprintfmt+0x37c>
				putch('-', putdat);
  8005ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fb:	f7 de                	neg    %esi
  8005fd:	83 d7 00             	adc    $0x0,%edi
  800600:	f7 df                	neg    %edi
			}
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 8d 00 00 00       	jmp    800699 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 88 fc ff ff       	call   80029e <getuint>
  800616:	89 c6                	mov    %eax,%esi
  800618:	89 d7                	mov    %edx,%edi
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061f:	eb 78                	jmp    800699 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800625:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80062c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80063a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80063d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800641:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80064e:	e9 ed fc ff ff       	jmp    800340 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800657:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80065e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800661:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800665:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800678:	8b 30                	mov    (%eax),%esi
  80067a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800684:	eb 13                	jmp    800699 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800686:	89 ca                	mov    %ecx,%edx
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
  80068b:	e8 0e fc ff ff       	call   80029e <getuint>
  800690:	89 c6                	mov    %eax,%esi
  800692:	89 d7                	mov    %edx,%edi
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800699:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80069d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ac:	89 34 24             	mov    %esi,(%esp)
  8006af:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	e8 13 fb ff ff       	call   8001d0 <printnum>
			break;
  8006bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c0:	e9 7b fc ff ff       	jmp    800340 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d2:	e9 69 fc ff ff       	jmp    800340 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006db:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e5:	eb 03                	jmp    8006ea <vprintfmt+0x3cd>
  8006e7:	83 ee 01             	sub    $0x1,%esi
  8006ea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ee:	75 f7                	jne    8006e7 <vprintfmt+0x3ca>
  8006f0:	e9 4b fc ff ff       	jmp    800340 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006f5:	83 c4 4c             	add    $0x4c,%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 28             	sub    $0x28,%esp
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800709:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800710:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800713:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071a:	85 c0                	test   %eax,%eax
  80071c:	74 30                	je     80074e <vsnprintf+0x51>
  80071e:	85 d2                	test   %edx,%edx
  800720:	7e 2c                	jle    80074e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800733:	89 44 24 04          	mov    %eax,0x4(%esp)
  800737:	c7 04 24 d8 02 80 00 	movl   $0x8002d8,(%esp)
  80073e:	e8 da fb ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 82 ff ff ff       	call   8006fd <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
  80077d:	00 00                	add    %al,(%eax)
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 d0                	cmp    %edx,%eax
  8007ad:	74 06                	je     8007b5 <strnlen+0x1d>
  8007af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ca:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	84 c9                	test   %cl,%cl
  8007d2:	75 f2                	jne    8007c6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	89 1c 24             	mov    %ebx,(%esp)
  8007e4:	e8 97 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	e8 bd ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007fa:	89 d8                	mov    %ebx,%eax
  8007fc:	83 c4 08             	add    $0x8,%esp
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	eb 0f                	jmp    800826 <strncpy+0x24>
		*dst++ = *src;
  800817:	0f b6 1a             	movzbl (%edx),%ebx
  80081a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 3a 01             	cmpb   $0x1,(%edx)
  800820:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	39 f1                	cmp    %esi,%ecx
  800828:	75 ed                	jne    800817 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 75 08             	mov    0x8(%ebp),%esi
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	89 f0                	mov    %esi,%eax
  80083e:	85 d2                	test   %edx,%edx
  800840:	75 0a                	jne    80084c <strlcpy+0x1e>
  800842:	eb 1d                	jmp    800861 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	88 18                	mov    %bl,(%eax)
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	83 ea 01             	sub    $0x1,%edx
  80084f:	74 0b                	je     80085c <strlcpy+0x2e>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x16>
  800858:	89 c2                	mov    %eax,%edx
  80085a:	eb 02                	jmp    80085e <strlcpy+0x30>
  80085c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80085e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800861:	29 f0                	sub    %esi,%eax
}
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	eb 06                	jmp    800878 <strcmp+0x11>
		p++, q++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800878:	0f b6 01             	movzbl (%ecx),%eax
  80087b:	84 c0                	test   %al,%al
  80087d:	74 04                	je     800883 <strcmp+0x1c>
  80087f:	3a 02                	cmp    (%edx),%al
  800881:	74 ef                	je     800872 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80089a:	eb 09                	jmp    8008a5 <strncmp+0x18>
		n--, p++, q++;
  80089c:	83 ea 01             	sub    $0x1,%edx
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	74 15                	je     8008be <strncmp+0x31>
  8008a9:	0f b6 18             	movzbl (%eax),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	74 04                	je     8008b4 <strncmp+0x27>
  8008b0:	3a 19                	cmp    (%ecx),%bl
  8008b2:	74 e8                	je     80089c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 00             	movzbl (%eax),%eax
  8008b7:	0f b6 11             	movzbl (%ecx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
  8008bc:	eb 05                	jmp    8008c3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 07                	jmp    8008d9 <strchr+0x13>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0f                	je     8008e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	0f b6 10             	movzbl (%eax),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f1:	eb 07                	jmp    8008fa <strfind+0x13>
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 0a                	je     800901 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	0f b6 10             	movzbl (%eax),%edx
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f2                	jne    8008f3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80090c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80090f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800912:	8b 7d 08             	mov    0x8(%ebp),%edi
  800915:	8b 45 0c             	mov    0xc(%ebp),%eax
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 30                	je     80094f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800925:	75 25                	jne    80094c <memset+0x49>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 20                	jne    80094c <memset+0x49>
		c &= 0xFF;
  80092c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	89 d3                	mov    %edx,%ebx
  800931:	c1 e3 08             	shl    $0x8,%ebx
  800934:	89 d6                	mov    %edx,%esi
  800936:	c1 e6 18             	shl    $0x18,%esi
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e0 10             	shl    $0x10,%eax
  80093e:	09 f0                	or     %esi,%eax
  800940:	09 d0                	or     %edx,%eax
  800942:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800944:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800947:	fc                   	cld    
  800948:	f3 ab                	rep stos %eax,%es:(%edi)
  80094a:	eb 03                	jmp    80094f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094c:	fc                   	cld    
  80094d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094f:	89 f8                	mov    %edi,%eax
  800951:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800954:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800957:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80095a:	89 ec                	mov    %ebp,%esp
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800967:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800973:	39 c6                	cmp    %eax,%esi
  800975:	73 36                	jae    8009ad <memmove+0x4f>
  800977:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 2f                	jae    8009ad <memmove+0x4f>
		s += n;
		d += n;
  80097e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	f6 c2 03             	test   $0x3,%dl
  800984:	75 1b                	jne    8009a1 <memmove+0x43>
  800986:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098c:	75 13                	jne    8009a1 <memmove+0x43>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0e                	jne    8009a1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800993:	83 ef 04             	sub    $0x4,%edi
  800996:	8d 72 fc             	lea    -0x4(%edx),%esi
  800999:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099c:	fd                   	std    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 09                	jmp    8009aa <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a1:	83 ef 01             	sub    $0x1,%edi
  8009a4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a7:	fd                   	std    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009aa:	fc                   	cld    
  8009ab:	eb 20                	jmp    8009cd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b3:	75 13                	jne    8009c8 <memmove+0x6a>
  8009b5:	a8 03                	test   $0x3,%al
  8009b7:	75 0f                	jne    8009c8 <memmove+0x6a>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0a                	jne    8009c8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009be:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 05                	jmp    8009cd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c8:	89 c7                	mov    %eax,%edi
  8009ca:	fc                   	cld    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009d3:	89 ec                	mov    %ebp,%esp
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	89 04 24             	mov    %eax,(%esp)
  8009f1:	e8 68 ff ff ff       	call   80095e <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	eb 1a                	jmp    800a28 <memcmp+0x30>
		if (*s1 != *s2)
  800a0e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a1a:	38 c8                	cmp    %cl,%al
  800a1c:	74 0a                	je     800a28 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c0             	movzbl %al,%eax
  800a21:	0f b6 c9             	movzbl %cl,%ecx
  800a24:	29 c8                	sub    %ecx,%eax
  800a26:	eb 09                	jmp    800a31 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	39 da                	cmp    %ebx,%edx
  800a2a:	75 e2                	jne    800a0e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
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
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800a64:	0f b6 02             	movzbl (%edx),%eax
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f6                	je     800a61 <strtol+0xe>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f2                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	75 0a                	jne    800a7d <strtol+0x2a>
		s++;
  800a73:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 10                	jmp    800a8d <strtol+0x3a>
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 07                	jne    800a8d <strtol+0x3a>
		s++, neg = 1;
  800a86:	8d 52 01             	lea    0x1(%edx),%edx
  800a89:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	0f 94 c0             	sete   %al
  800a92:	74 05                	je     800a99 <strtol+0x46>
  800a94:	83 fb 10             	cmp    $0x10,%ebx
  800a97:	75 15                	jne    800aae <strtol+0x5b>
  800a99:	80 3a 30             	cmpb   $0x30,(%edx)
  800a9c:	75 10                	jne    800aae <strtol+0x5b>
  800a9e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa2:	75 0a                	jne    800aae <strtol+0x5b>
		s += 2, base = 16;
  800aa4:	83 c2 02             	add    $0x2,%edx
  800aa7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aac:	eb 13                	jmp    800ac1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aae:	84 c0                	test   %al,%al
  800ab0:	74 0f                	je     800ac1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab7:	80 3a 30             	cmpb   $0x30,(%edx)
  800aba:	75 05                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
  800abc:	83 c2 01             	add    $0x1,%edx
  800abf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac8:	0f b6 0a             	movzbl (%edx),%ecx
  800acb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ace:	80 fb 09             	cmp    $0x9,%bl
  800ad1:	77 08                	ja     800adb <strtol+0x88>
			dig = *s - '0';
  800ad3:	0f be c9             	movsbl %cl,%ecx
  800ad6:	83 e9 30             	sub    $0x30,%ecx
  800ad9:	eb 1e                	jmp    800af9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800adb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 08                	ja     800aeb <strtol+0x98>
			dig = *s - 'a' + 10;
  800ae3:	0f be c9             	movsbl %cl,%ecx
  800ae6:	83 e9 57             	sub    $0x57,%ecx
  800ae9:	eb 0e                	jmp    800af9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aeb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 14                	ja     800b07 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800af3:	0f be c9             	movsbl %cl,%ecx
  800af6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af9:	39 f1                	cmp    %esi,%ecx
  800afb:	7d 0e                	jge    800b0b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800afd:	83 c2 01             	add    $0x1,%edx
  800b00:	0f af c6             	imul   %esi,%eax
  800b03:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b05:	eb c1                	jmp    800ac8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b07:	89 c1                	mov    %eax,%ecx
  800b09:	eb 02                	jmp    800b0d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b11:	74 05                	je     800b18 <strtol+0xc5>
		*endptr = (char *) s;
  800b13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b16:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b18:	89 ca                	mov    %ecx,%edx
  800b1a:	f7 da                	neg    %edx
  800b1c:	85 ff                	test   %edi,%edi
  800b1e:	0f 45 c2             	cmovne %edx,%eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
	...

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	89 c6                	mov    %eax,%esi
  800b48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b53:	89 ec                	mov    %ebp,%esp
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b60:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b63:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b83:	89 ec                	mov    %ebp,%esp
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 38             	sub    $0x38,%esp
  800b8d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b90:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b93:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 cb                	mov    %ecx,%ebx
  800ba5:	89 cf                	mov    %ecx,%edi
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 28                	jle    800bd7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bba:	00 
  800bbb:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800bc2:	00 
  800bc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bca:	00 
  800bcb:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800bd2:	e8 d5 02 00 00       	call   800eac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800be0:	89 ec                	mov    %ebp,%esp
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfd:	89 d1                	mov    %edx,%ecx
  800bff:	89 d3                	mov    %edx,%ebx
  800c01:	89 d7                	mov    %edx,%edi
  800c03:	89 d6                	mov    %edx,%esi
  800c05:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c07:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c0a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c10:	89 ec                	mov    %ebp,%esp
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_yield>:

void
sys_yield(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c1d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c20:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c40:	89 ec                	mov    %ebp,%esp
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 38             	sub    $0x38,%esp
  800c4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c50:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	be 00 00 00 00       	mov    $0x0,%esi
  800c58:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 f7                	mov    %esi,%edi
  800c68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 28                	jle    800c96 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c72:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c79:	00 
  800c7a:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c81:	00 
  800c82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c89:	00 
  800c8a:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c91:	e8 16 02 00 00       	call   800eac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c9f:	89 ec                	mov    %ebp,%esp
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 38             	sub    $0x38,%esp
  800ca9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800caf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 28                	jle    800cf4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce7:	00 
  800ce8:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cef:	e8 b8 01 00 00       	call   800eac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfd:	89 ec                	mov    %ebp,%esp
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 38             	sub    $0x38,%esp
  800d07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d4d:	e8 5a 01 00 00       	call   800eac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 38             	sub    $0x38,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 08 00 00 00       	mov    $0x8,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 28                	jle    800db0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d93:	00 
  800d94:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da3:	00 
  800da4:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800dab:	e8 fc 00 00 00       	call   800eac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db9:	89 ec                	mov    %ebp,%esp
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 38             	sub    $0x38,%esp
  800dc3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800de4:	7e 28                	jle    800e0e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e09:	e8 9e 00 00 00       	call   800eac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4b:	89 ec                	mov    %ebp,%esp
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 38             	sub    $0x38,%esp
  800e55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 28                	jle    800e9f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e82:	00 
  800e83:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e9a:	e8 0d 00 00 00       	call   800eac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800eb4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eb7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ebd:	e8 22 fd ff ff       	call   800be4 <sys_getenvid>
  800ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed8:	c7 04 24 b4 14 80 00 	movl   $0x8014b4,(%esp)
  800edf:	e8 c3 f2 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ee4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee8:	8b 45 10             	mov    0x10(%ebp),%eax
  800eeb:	89 04 24             	mov    %eax,(%esp)
  800eee:	e8 53 f2 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800ef3:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800efa:	e8 a8 f2 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eff:	cc                   	int3   
  800f00:	eb fd                	jmp    800eff <_panic+0x53>
	...

00800f10 <__udivdi3>:
  800f10:	83 ec 1c             	sub    $0x1c,%esp
  800f13:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f17:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f1b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f1f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f23:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f27:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f2b:	85 ff                	test   %edi,%edi
  800f2d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f35:	89 cd                	mov    %ecx,%ebp
  800f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3b:	75 33                	jne    800f70 <__udivdi3+0x60>
  800f3d:	39 f1                	cmp    %esi,%ecx
  800f3f:	77 57                	ja     800f98 <__udivdi3+0x88>
  800f41:	85 c9                	test   %ecx,%ecx
  800f43:	75 0b                	jne    800f50 <__udivdi3+0x40>
  800f45:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4a:	31 d2                	xor    %edx,%edx
  800f4c:	f7 f1                	div    %ecx
  800f4e:	89 c1                	mov    %eax,%ecx
  800f50:	89 f0                	mov    %esi,%eax
  800f52:	31 d2                	xor    %edx,%edx
  800f54:	f7 f1                	div    %ecx
  800f56:	89 c6                	mov    %eax,%esi
  800f58:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f5c:	f7 f1                	div    %ecx
  800f5e:	89 f2                	mov    %esi,%edx
  800f60:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f64:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f68:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	c3                   	ret    
  800f70:	31 d2                	xor    %edx,%edx
  800f72:	31 c0                	xor    %eax,%eax
  800f74:	39 f7                	cmp    %esi,%edi
  800f76:	77 e8                	ja     800f60 <__udivdi3+0x50>
  800f78:	0f bd cf             	bsr    %edi,%ecx
  800f7b:	83 f1 1f             	xor    $0x1f,%ecx
  800f7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f82:	75 2c                	jne    800fb0 <__udivdi3+0xa0>
  800f84:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f88:	76 04                	jbe    800f8e <__udivdi3+0x7e>
  800f8a:	39 f7                	cmp    %esi,%edi
  800f8c:	73 d2                	jae    800f60 <__udivdi3+0x50>
  800f8e:	31 d2                	xor    %edx,%edx
  800f90:	b8 01 00 00 00       	mov    $0x1,%eax
  800f95:	eb c9                	jmp    800f60 <__udivdi3+0x50>
  800f97:	90                   	nop
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	f7 f1                	div    %ecx
  800f9c:	31 d2                	xor    %edx,%edx
  800f9e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fa6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800faa:	83 c4 1c             	add    $0x1c,%esp
  800fad:	c3                   	ret    
  800fae:	66 90                	xchg   %ax,%ax
  800fb0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fb5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fba:	89 ea                	mov    %ebp,%edx
  800fbc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fc0:	d3 e7                	shl    %cl,%edi
  800fc2:	89 c1                	mov    %eax,%ecx
  800fc4:	d3 ea                	shr    %cl,%edx
  800fc6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fcb:	09 fa                	or     %edi,%edx
  800fcd:	89 f7                	mov    %esi,%edi
  800fcf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd3:	89 f2                	mov    %esi,%edx
  800fd5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fd9:	d3 e5                	shl    %cl,%ebp
  800fdb:	89 c1                	mov    %eax,%ecx
  800fdd:	d3 ef                	shr    %cl,%edi
  800fdf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fe4:	d3 e2                	shl    %cl,%edx
  800fe6:	89 c1                	mov    %eax,%ecx
  800fe8:	d3 ee                	shr    %cl,%esi
  800fea:	09 d6                	or     %edx,%esi
  800fec:	89 fa                	mov    %edi,%edx
  800fee:	89 f0                	mov    %esi,%eax
  800ff0:	f7 74 24 0c          	divl   0xc(%esp)
  800ff4:	89 d7                	mov    %edx,%edi
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	f7 e5                	mul    %ebp
  800ffa:	39 d7                	cmp    %edx,%edi
  800ffc:	72 22                	jb     801020 <__udivdi3+0x110>
  800ffe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801002:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801007:	d3 e5                	shl    %cl,%ebp
  801009:	39 c5                	cmp    %eax,%ebp
  80100b:	73 04                	jae    801011 <__udivdi3+0x101>
  80100d:	39 d7                	cmp    %edx,%edi
  80100f:	74 0f                	je     801020 <__udivdi3+0x110>
  801011:	89 f0                	mov    %esi,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	e9 46 ff ff ff       	jmp    800f60 <__udivdi3+0x50>
  80101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801020:	8d 46 ff             	lea    -0x1(%esi),%eax
  801023:	31 d2                	xor    %edx,%edx
  801025:	8b 74 24 10          	mov    0x10(%esp),%esi
  801029:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80102d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801031:	83 c4 1c             	add    $0x1c,%esp
  801034:	c3                   	ret    
	...

00801040 <__umoddi3>:
  801040:	83 ec 1c             	sub    $0x1c,%esp
  801043:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801047:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80104b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80104f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801053:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801057:	8b 74 24 24          	mov    0x24(%esp),%esi
  80105b:	85 ed                	test   %ebp,%ebp
  80105d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801061:	89 44 24 08          	mov    %eax,0x8(%esp)
  801065:	89 cf                	mov    %ecx,%edi
  801067:	89 04 24             	mov    %eax,(%esp)
  80106a:	89 f2                	mov    %esi,%edx
  80106c:	75 1a                	jne    801088 <__umoddi3+0x48>
  80106e:	39 f1                	cmp    %esi,%ecx
  801070:	76 4e                	jbe    8010c0 <__umoddi3+0x80>
  801072:	f7 f1                	div    %ecx
  801074:	89 d0                	mov    %edx,%eax
  801076:	31 d2                	xor    %edx,%edx
  801078:	8b 74 24 10          	mov    0x10(%esp),%esi
  80107c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801080:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801084:	83 c4 1c             	add    $0x1c,%esp
  801087:	c3                   	ret    
  801088:	39 f5                	cmp    %esi,%ebp
  80108a:	77 54                	ja     8010e0 <__umoddi3+0xa0>
  80108c:	0f bd c5             	bsr    %ebp,%eax
  80108f:	83 f0 1f             	xor    $0x1f,%eax
  801092:	89 44 24 04          	mov    %eax,0x4(%esp)
  801096:	75 60                	jne    8010f8 <__umoddi3+0xb8>
  801098:	3b 0c 24             	cmp    (%esp),%ecx
  80109b:	0f 87 07 01 00 00    	ja     8011a8 <__umoddi3+0x168>
  8010a1:	89 f2                	mov    %esi,%edx
  8010a3:	8b 34 24             	mov    (%esp),%esi
  8010a6:	29 ce                	sub    %ecx,%esi
  8010a8:	19 ea                	sbb    %ebp,%edx
  8010aa:	89 34 24             	mov    %esi,(%esp)
  8010ad:	8b 04 24             	mov    (%esp),%eax
  8010b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010bc:	83 c4 1c             	add    $0x1c,%esp
  8010bf:	c3                   	ret    
  8010c0:	85 c9                	test   %ecx,%ecx
  8010c2:	75 0b                	jne    8010cf <__umoddi3+0x8f>
  8010c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c9:	31 d2                	xor    %edx,%edx
  8010cb:	f7 f1                	div    %ecx
  8010cd:	89 c1                	mov    %eax,%ecx
  8010cf:	89 f0                	mov    %esi,%eax
  8010d1:	31 d2                	xor    %edx,%edx
  8010d3:	f7 f1                	div    %ecx
  8010d5:	8b 04 24             	mov    (%esp),%eax
  8010d8:	f7 f1                	div    %ecx
  8010da:	eb 98                	jmp    801074 <__umoddi3+0x34>
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010ea:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ee:	83 c4 1c             	add    $0x1c,%esp
  8010f1:	c3                   	ret    
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010fd:	89 e8                	mov    %ebp,%eax
  8010ff:	bd 20 00 00 00       	mov    $0x20,%ebp
  801104:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801108:	89 fa                	mov    %edi,%edx
  80110a:	d3 e0                	shl    %cl,%eax
  80110c:	89 e9                	mov    %ebp,%ecx
  80110e:	d3 ea                	shr    %cl,%edx
  801110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801115:	09 c2                	or     %eax,%edx
  801117:	8b 44 24 08          	mov    0x8(%esp),%eax
  80111b:	89 14 24             	mov    %edx,(%esp)
  80111e:	89 f2                	mov    %esi,%edx
  801120:	d3 e7                	shl    %cl,%edi
  801122:	89 e9                	mov    %ebp,%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112f:	d3 e6                	shl    %cl,%esi
  801131:	89 e9                	mov    %ebp,%ecx
  801133:	d3 e8                	shr    %cl,%eax
  801135:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113a:	09 f0                	or     %esi,%eax
  80113c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801140:	f7 34 24             	divl   (%esp)
  801143:	d3 e6                	shl    %cl,%esi
  801145:	89 74 24 08          	mov    %esi,0x8(%esp)
  801149:	89 d6                	mov    %edx,%esi
  80114b:	f7 e7                	mul    %edi
  80114d:	39 d6                	cmp    %edx,%esi
  80114f:	89 c1                	mov    %eax,%ecx
  801151:	89 d7                	mov    %edx,%edi
  801153:	72 3f                	jb     801194 <__umoddi3+0x154>
  801155:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801159:	72 35                	jb     801190 <__umoddi3+0x150>
  80115b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80115f:	29 c8                	sub    %ecx,%eax
  801161:	19 fe                	sbb    %edi,%esi
  801163:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801168:	89 f2                	mov    %esi,%edx
  80116a:	d3 e8                	shr    %cl,%eax
  80116c:	89 e9                	mov    %ebp,%ecx
  80116e:	d3 e2                	shl    %cl,%edx
  801170:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801175:	09 d0                	or     %edx,%eax
  801177:	89 f2                	mov    %esi,%edx
  801179:	d3 ea                	shr    %cl,%edx
  80117b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80117f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801183:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801187:	83 c4 1c             	add    $0x1c,%esp
  80118a:	c3                   	ret    
  80118b:	90                   	nop
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	39 d6                	cmp    %edx,%esi
  801192:	75 c7                	jne    80115b <__umoddi3+0x11b>
  801194:	89 d7                	mov    %edx,%edi
  801196:	89 c1                	mov    %eax,%ecx
  801198:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80119c:	1b 3c 24             	sbb    (%esp),%edi
  80119f:	eb ba                	jmp    80115b <__umoddi3+0x11b>
  8011a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	39 f5                	cmp    %esi,%ebp
  8011aa:	0f 82 f1 fe ff ff    	jb     8010a1 <__umoddi3+0x61>
  8011b0:	e9 f8 fe ff ff       	jmp    8010ad <__umoddi3+0x6d>
