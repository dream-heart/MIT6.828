
obj/user/spawnhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 62 00 00 00       	call   800093 <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	89 44 24 04          	mov    %eax,0x4(%esp)
  800045:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  80004c:	e8 97 01 00 00       	call   8001e8 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 9e 26 80 	movl   $0x80269e,0x4(%esp)
  800060:	00 
  800061:	c7 04 24 9e 26 80 00 	movl   $0x80269e,(%esp)
  800068:	e8 ba 13 00 00       	call   801427 <spawnl>
  80006d:	85 c0                	test   %eax,%eax
  80006f:	79 20                	jns    800091 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800075:	c7 44 24 08 a4 26 80 	movl   $0x8026a4,0x8(%esp)
  80007c:	00 
  80007d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800084:	00 
  800085:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  80008c:	e8 5e 00 00 00       	call   8000ef <_panic>
}
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	83 ec 10             	sub    $0x10,%esp
  80009b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80009e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8000a1:	e8 9f 0b 00 00       	call   800c45 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x30>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 64 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cf:	e8 07 00 00 00       	call   8000db <exit>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e8:	e8 06 0b 00 00       	call   800bf3 <sys_env_destroy>
}
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8000f7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000fa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800100:	e8 40 0b 00 00       	call   800c45 <sys_getenvid>
  800105:	8b 55 0c             	mov    0xc(%ebp),%edx
  800108:	89 54 24 10          	mov    %edx,0x10(%esp)
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800113:	89 74 24 08          	mov    %esi,0x8(%esp)
  800117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011b:	c7 04 24 d8 26 80 00 	movl   $0x8026d8,(%esp)
  800122:	e8 c1 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800127:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012b:	8b 45 10             	mov    0x10(%ebp),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 51 00 00 00       	call   800187 <vcprintf>
	cprintf("\n");
  800136:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80013d:	e8 a6 00 00 00       	call   8001e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800142:	cc                   	int3   
  800143:	eb fd                	jmp    800142 <_panic+0x53>

00800145 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	83 ec 14             	sub    $0x14,%esp
  80014c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014f:	8b 13                	mov    (%ebx),%edx
  800151:	8d 42 01             	lea    0x1(%edx),%eax
  800154:	89 03                	mov    %eax,(%ebx)
  800156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800159:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800162:	75 19                	jne    80017d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800164:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016b:	00 
  80016c:	8d 43 08             	lea    0x8(%ebx),%eax
  80016f:	89 04 24             	mov    %eax,(%esp)
  800172:	e8 3f 0a 00 00       	call   800bb6 <sys_cputs>
		b->idx = 0;
  800177:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800181:	83 c4 14             	add    $0x14,%esp
  800184:	5b                   	pop    %ebx
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 45 01 80 00 	movl   $0x800145,(%esp)
  8001c3:	e8 7c 01 00 00       	call   800344 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 d6 09 00 00       	call   800bb6 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 87 ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    
  800202:	66 90                	xchg   %ax,%ax
  800204:	66 90                	xchg   %ax,%ax
  800206:	66 90                	xchg   %ax,%ax
  800208:	66 90                	xchg   %ax,%ax
  80020a:	66 90                	xchg   %ax,%ax
  80020c:	66 90                	xchg   %ax,%ax
  80020e:	66 90                	xchg   %ax,%ax

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 c3                	mov    %eax,%ebx
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	b9 00 00 00 00       	mov    $0x0,%ecx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023d:	39 d9                	cmp    %ebx,%ecx
  80023f:	72 05                	jb     800246 <printnum+0x36>
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	77 69                	ja     8002af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800249:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024d:	83 ee 01             	sub    $0x1,%esi
  800250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 44 24 08          	mov    0x8(%esp),%eax
  80025c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800267:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 5c 21 00 00       	call   8023e0 <__udivdi3>
  800284:	89 d9                	mov    %ebx,%ecx
  800286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 71 ff ff ff       	call   800210 <printnum>
  80029f:	eb 1b                	jmp    8002bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff d3                	call   *%ebx
  8002ad:	eb 03                	jmp    8002b2 <printnum+0xa2>
  8002af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 ee 01             	sub    $0x1,%esi
  8002b5:	85 f6                	test   %esi,%esi
  8002b7:	7f e8                	jg     8002a1 <printnum+0x91>
  8002b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 2c 22 00 00       	call   802510 <__umoddi3>
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	0f be 80 fb 26 80 00 	movsbl 0x8026fb(%eax),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f5:	ff d0                	call   *%eax
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800305:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	3b 50 04             	cmp    0x4(%eax),%edx
  80030e:	73 0a                	jae    80031a <sprintputch+0x1b>
		*b->buf++ = ch;
  800310:	8d 4a 01             	lea    0x1(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	88 02                	mov    %al,(%edx)
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800322:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	8b 45 10             	mov    0x10(%ebp),%eax
  80032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
  800333:	89 44 24 04          	mov    %eax,0x4(%esp)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	e8 02 00 00 00       	call   800344 <vprintfmt>
	va_end(ap);
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
  800350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800353:	8b 7d 10             	mov    0x10(%ebp),%edi
  800356:	eb 11                	jmp    800369 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 48 04 00 00    	je     8007a8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	83 c7 01             	add    $0x1,%edi
  80036c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800370:	83 f8 25             	cmp    $0x25,%eax
  800373:	75 e3                	jne    800358 <vprintfmt+0x14>
  800375:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800379:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800380:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800387:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800393:	eb 1f                	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800398:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80039c:	eb 16                	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a5:	eb 0d                	jmp    8003b4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8d 47 01             	lea    0x1(%edi),%eax
  8003b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ba:	0f b6 17             	movzbl (%edi),%edx
  8003bd:	0f b6 c2             	movzbl %dl,%eax
  8003c0:	83 ea 23             	sub    $0x23,%edx
  8003c3:	80 fa 55             	cmp    $0x55,%dl
  8003c6:	0f 87 bf 03 00 00    	ja     80078b <vprintfmt+0x447>
  8003cc:	0f b6 d2             	movzbl %dl,%edx
  8003cf:	ff 24 95 40 28 80 00 	jmp    *0x802840(,%edx,4)
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003e4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003e8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ee:	83 f9 09             	cmp    $0x9,%ecx
  8003f1:	77 3c                	ja     80042f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 40 04             	lea    0x4(%eax),%eax
  800406:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040c:	eb 27                	jmp    800435 <vprintfmt+0xf1>
  80040e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800411:	85 d2                	test   %edx,%edx
  800413:	b8 00 00 00 00       	mov    $0x0,%eax
  800418:	0f 49 c2             	cmovns %edx,%eax
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800421:	eb 91                	jmp    8003b4 <vprintfmt+0x70>
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800426:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042d:	eb 85                	jmp    8003b4 <vprintfmt+0x70>
  80042f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800432:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	0f 89 75 ff ff ff    	jns    8003b4 <vprintfmt+0x70>
  80043f:	e9 63 ff ff ff       	jmp    8003a7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800444:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044a:	e9 65 ff ff ff       	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800464:	e9 00 ff ff ff       	jmp    800369 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	99                   	cltd   
  800473:	31 d0                	xor    %edx,%eax
  800475:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800477:	83 f8 0f             	cmp    $0xf,%eax
  80047a:	7f 0b                	jg     800487 <vprintfmt+0x143>
  80047c:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  800483:	85 d2                	test   %edx,%edx
  800485:	75 20                	jne    8004a7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	c7 44 24 08 13 27 80 	movl   $0x802713,0x8(%esp)
  800492:	00 
  800493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800497:	89 34 24             	mov    %esi,(%esp)
  80049a:	e8 7d fe ff ff       	call   80031c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a2:	e9 c2 fe ff ff       	jmp    800369 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ab:	c7 44 24 08 56 2a 80 	movl   $0x802a56,0x8(%esp)
  8004b2:	00 
  8004b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b7:	89 34 24             	mov    %esi,(%esp)
  8004ba:	e8 5d fe ff ff       	call   80031c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	e9 a2 fe ff ff       	jmp    800369 <vprintfmt+0x25>
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	b8 0c 27 80 00       	mov    $0x80270c,%eax
  8004e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e7:	0f 84 92 00 00 00    	je     80057f <vprintfmt+0x23b>
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	0f 8e 98 00 00 00    	jle    80058d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f9:	89 3c 24             	mov    %edi,(%esp)
  8004fc:	e8 47 03 00 00       	call   800848 <strnlen>
  800501:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800504:	29 c1                	sub    %eax,%ecx
  800506:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800509:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800510:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800513:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	eb 0f                	jmp    800526 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	85 ff                	test   %edi,%edi
  800528:	7f ed                	jg     800517 <vprintfmt+0x1d3>
  80052a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800530:	85 c9                	test   %ecx,%ecx
  800532:	b8 00 00 00 00       	mov    $0x0,%eax
  800537:	0f 49 c1             	cmovns %ecx,%eax
  80053a:	29 c1                	sub    %eax,%ecx
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	89 cb                	mov    %ecx,%ebx
  800547:	eb 50                	jmp    800599 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054d:	74 1e                	je     80056d <vprintfmt+0x229>
  80054f:	0f be d2             	movsbl %dl,%edx
  800552:	83 ea 20             	sub    $0x20,%edx
  800555:	83 fa 5e             	cmp    $0x5e,%edx
  800558:	76 13                	jbe    80056d <vprintfmt+0x229>
					putch('?', putdat);
  80055a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	eb 0d                	jmp    80057a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80056d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800570:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	83 eb 01             	sub    $0x1,%ebx
  80057d:	eb 1a                	jmp    800599 <vprintfmt+0x255>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 0c                	jmp    800599 <vprintfmt+0x255>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a0:	0f be c2             	movsbl %dl,%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	74 25                	je     8005cc <vprintfmt+0x288>
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	78 9e                	js     800549 <vprintfmt+0x205>
  8005ab:	83 ee 01             	sub    $0x1,%esi
  8005ae:	79 99                	jns    800549 <vprintfmt+0x205>
  8005b0:	89 df                	mov    %ebx,%edi
  8005b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c7:	83 ef 01             	sub    $0x1,%edi
  8005ca:	eb 08                	jmp    8005d4 <vprintfmt+0x290>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f e2                	jg     8005ba <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	e9 89 fd ff ff       	jmp    800369 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7e 19                	jle    8005fe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 50 04             	mov    0x4(%eax),%edx
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 08             	lea    0x8(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fc:	eb 38                	jmp    800636 <vprintfmt+0x2f2>
	else if (lflag)
  8005fe:	85 c9                	test   %ecx,%ecx
  800600:	74 1b                	je     80061d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
  80061b:	eb 19                	jmp    800636 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 00                	mov    (%eax),%eax
  800622:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800625:	89 c1                	mov    %eax,%ecx
  800627:	c1 f9 1f             	sar    $0x1f,%ecx
  80062a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800636:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800639:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800641:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800645:	0f 89 04 01 00 00    	jns    80074f <vprintfmt+0x40b>
				putch('-', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800656:	ff d6                	call   *%esi
				num = -(long long) num;
  800658:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80065e:	f7 da                	neg    %edx
  800660:	83 d1 00             	adc    $0x0,%ecx
  800663:	f7 d9                	neg    %ecx
  800665:	e9 e5 00 00 00       	jmp    80074f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 10                	jle    80067f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
  80067d:	eb 26                	jmp    8006a5 <vprintfmt+0x361>
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 12                	je     800695 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb 10                	jmp    8006a5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006aa:	e9 a0 00 00 00       	jmp    80074f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ba:	ff d6                	call   *%esi
			putch('X', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006d4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006d9:	e9 8b fc ff ff       	jmp    800369 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800708:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80070d:	eb 40                	jmp    80074f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070f:	83 f9 01             	cmp    $0x1,%ecx
  800712:	7e 10                	jle    800724 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	8b 48 04             	mov    0x4(%eax),%ecx
  80071c:	8d 40 08             	lea    0x8(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
  800722:	eb 26                	jmp    80074a <vprintfmt+0x406>
	else if (lflag)
  800724:	85 c9                	test   %ecx,%ecx
  800726:	74 12                	je     80073a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
  800738:	eb 10                	jmp    80074a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80074a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800753:	89 44 24 10          	mov    %eax,0x10(%esp)
  800757:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800762:	89 14 24             	mov    %edx,(%esp)
  800765:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800769:	89 da                	mov    %ebx,%edx
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	e8 9e fa ff ff       	call   800210 <printnum>
			break;
  800772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800775:	e9 ef fb ff ff       	jmp    800369 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800786:	e9 de fb ff ff       	jmp    800369 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800796:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	eb 03                	jmp    80079d <vprintfmt+0x459>
  80079a:	83 ef 01             	sub    $0x1,%edi
  80079d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x456>
  8007a3:	e9 c1 fb ff ff       	jmp    800369 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007a8:	83 c4 3c             	add    $0x3c,%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 28             	sub    $0x28,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 30                	je     800801 <vsnprintf+0x51>
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	7e 2c                	jle    800801 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 ff 02 80 00 	movl   $0x8002ff,(%esp)
  8007f1:	e8 4e fb ff ff       	call   800344 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ff:	eb 05                	jmp    800806 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800815:	8b 45 10             	mov    0x10(%ebp),%eax
  800818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 82 ff ff ff       	call   8007b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800891:	89 1c 24             	mov    %ebx,(%esp)
  800894:	e8 97 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 bd ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 1d                	jmp    800916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 0b                	je     800911 <strlcpy+0x32>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	eb 02                	jmp    800913 <strlcpy+0x34>
  800911:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
		p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 15                	je     800972 <strncmp+0x30>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
  800970:	eb 05                	jmp    800977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	eb 07                	jmp    80098d <strchr+0x13>
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 0f                	je     800999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strfind+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0a                	je     8009b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 36                	je     8009fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 28                	jne    8009f7 <memset+0x40>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 23                	jne    8009f7 <memset+0x40>
		c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a12:	39 c6                	cmp    %eax,%esi
  800a14:	73 35                	jae    800a4b <memmove+0x47>
  800a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 2e                	jae    800a4b <memmove+0x47>
		s += n;
		d += n;
  800a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2a:	75 13                	jne    800a3f <memmove+0x3b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1d                	jmp    800a68 <memmove+0x64>
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c2 03             	test   $0x3,%dl
  800a52:	75 0f                	jne    800a63 <memmove+0x5f>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0a                	jne    800a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 05                	jmp    800a68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	fc                   	cld    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 79 ff ff ff       	call   800a04 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	0f b6 19             	movzbl (%ecx),%ebx
  800aa5:	38 d8                	cmp    %bl,%al
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad4:	eb 07                	jmp    800add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 07                	je     800ae1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	72 f5                	jb     800ad6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
		s++;
  800af1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	0f b6 0a             	movzbl (%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	74 f5                	je     800af1 <strtol+0xe>
  800afc:	80 f9 20             	cmp    $0x20,%cl
  800aff:	74 f0                	je     800af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b01:	80 f9 2b             	cmp    $0x2b,%cl
  800b04:	75 0a                	jne    800b10 <strtol+0x2d>
		s++;
  800b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	eb 11                	jmp    800b21 <strtol+0x3e>
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b15:	80 f9 2d             	cmp    $0x2d,%cl
  800b18:	75 07                	jne    800b21 <strtol+0x3e>
		s++, neg = 1;
  800b1a:	8d 52 01             	lea    0x1(%edx),%edx
  800b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b26:	75 15                	jne    800b3d <strtol+0x5a>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	75 10                	jne    800b3d <strtol+0x5a>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x5a>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	b8 10 00 00 00       	mov    $0x10,%eax
  800b3b:	eb 10                	jmp    800b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 0c                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 05                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b5b:	89 f0                	mov    %esi,%eax
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	77 08                	ja     800b69 <strtol+0x86>
			dig = *s - '0';
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 30             	sub    $0x30,%ecx
  800b67:	eb 20                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	3c 19                	cmp    $0x19,%al
  800b70:	77 08                	ja     800b7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0f                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	3c 19                	cmp    $0x19,%al
  800b81:	77 16                	ja     800b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b8c:	7d 0f                	jge    800b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b97:	eb bc                	jmp    800b55 <strtol+0x72>
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	eb 02                	jmp    800b9f <strtol+0xbc>
  800b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xc7>
		*endptr = (char *) s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800baa:	f7 d8                	neg    %eax
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 44 c3             	cmove  %ebx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 28                	jle    800c3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c20:	00 
  800c21:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800c28:	00 
  800c29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c30:	00 
  800c31:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800c38:	e8 b2 f4 ff ff       	call   8000ef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	83 c4 2c             	add    $0x2c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800cca:	e8 20 f4 ff ff       	call   8000ef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800d1d:	e8 cd f3 ff ff       	call   8000ef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800d70:	e8 7a f3 ff ff       	call   8000ef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800dc3:	e8 27 f3 ff ff       	call   8000ef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	83 c4 2c             	add    $0x2c,%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800e16:	e8 d4 f2 ff ff       	call   8000ef <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e1b:	83 c4 2c             	add    $0x2c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 df                	mov    %ebx,%edi
  800e3e:	89 de                	mov    %ebx,%esi
  800e40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800e69:	e8 81 f2 ff ff       	call   8000ef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6e:	83 c4 2c             	add    $0x2c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	be 00 00 00 00       	mov    $0x0,%esi
  800e81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800ede:	e8 0c f2 ff ff       	call   8000ef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee3:	83 c4 2c             	add    $0x2c,%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

00800ef0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  800efc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f03:	00 
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	89 04 24             	mov    %eax,(%esp)
  800f0a:	e8 42 0d 00 00       	call   801c51 <open>
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	0f 88 9e 04 00 00    	js     8013bd <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  800f1f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800f26:	00 
  800f27:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f31:	89 0c 24             	mov    %ecx,(%esp)
  800f34:	e8 fe 08 00 00       	call   801837 <readn>
  800f39:	3d 00 02 00 00       	cmp    $0x200,%eax
  800f3e:	75 0c                	jne    800f4c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  800f40:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  800f47:	45 4c 46 
  800f4a:	74 36                	je     800f82 <spawn+0x92>
		close(fd);
  800f4c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  800f52:	89 04 24             	mov    %eax,(%esp)
  800f55:	e8 e8 06 00 00       	call   801642 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  800f5a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  800f61:	46 
  800f62:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  800f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6c:	c7 04 24 2a 2a 80 00 	movl   $0x802a2a,(%esp)
  800f73:	e8 70 f2 ff ff       	call   8001e8 <cprintf>
		return -E_NOT_EXEC;
  800f78:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  800f7d:	e9 9a 04 00 00       	jmp    80141c <spawn+0x52c>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f82:	b8 07 00 00 00       	mov    $0x7,%eax
  800f87:	cd 30                	int    $0x30
  800f89:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  800f8f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	0f 88 28 04 00 00    	js     8013c5 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  800f9d:	89 c6                	mov    %eax,%esi
  800f9f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800fa5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  800fa8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800fae:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  800fb4:	b9 11 00 00 00       	mov    $0x11,%ecx
  800fb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  800fbb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  800fc1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  800fcc:	be 00 00 00 00       	mov    $0x0,%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fd4:	eb 0f                	jmp    800fe5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  800fd6:	89 04 24             	mov    %eax,(%esp)
  800fd9:	e8 52 f8 ff ff       	call   800830 <strlen>
  800fde:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800fe2:	83 c3 01             	add    $0x1,%ebx
  800fe5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  800fec:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	75 e3                	jne    800fd6 <spawn+0xe6>
  800ff3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  800ff9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  800fff:	bf 00 10 40 00       	mov    $0x401000,%edi
  801004:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801006:	89 fa                	mov    %edi,%edx
  801008:	83 e2 fc             	and    $0xfffffffc,%edx
  80100b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801012:	29 c2                	sub    %eax,%edx
  801014:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80101a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80101d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801022:	0f 86 ad 03 00 00    	jbe    8013d5 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801028:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103f:	e8 3f fc ff ff       	call   800c83 <sys_page_alloc>
  801044:	85 c0                	test   %eax,%eax
  801046:	0f 88 d0 03 00 00    	js     80141c <spawn+0x52c>
  80104c:	be 00 00 00 00       	mov    $0x0,%esi
  801051:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80105a:	eb 30                	jmp    80108c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80105c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801062:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801068:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80106b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80106e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801072:	89 3c 24             	mov    %edi,(%esp)
  801075:	e8 ed f7 ff ff       	call   800867 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80107a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 ab f7 ff ff       	call   800830 <strlen>
  801085:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801089:	83 c6 01             	add    $0x1,%esi
  80108c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801092:	7f c8                	jg     80105c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801094:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80109a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8010a0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8010a7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8010ad:	74 24                	je     8010d3 <spawn+0x1e3>
  8010af:	c7 44 24 0c b4 2a 80 	movl   $0x802ab4,0xc(%esp)
  8010b6:	00 
  8010b7:	c7 44 24 08 44 2a 80 	movl   $0x802a44,0x8(%esp)
  8010be:	00 
  8010bf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8010c6:	00 
  8010c7:	c7 04 24 59 2a 80 00 	movl   $0x802a59,(%esp)
  8010ce:	e8 1c f0 ff ff       	call   8000ef <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8010d3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8010d9:	89 c8                	mov    %ecx,%eax
  8010db:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8010e0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8010e3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8010e9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8010ec:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8010f2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8010f8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010ff:	00 
  801100:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801107:	ee 
  801108:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80110e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801112:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801121:	e8 b1 fb ff ff       	call   800cd7 <sys_page_map>
  801126:	89 c3                	mov    %eax,%ebx
  801128:	85 c0                	test   %eax,%eax
  80112a:	0f 88 d6 02 00 00    	js     801406 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801130:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113f:	e8 e6 fb ff ff       	call   800d2a <sys_page_unmap>
  801144:	89 c3                	mov    %eax,%ebx
  801146:	85 c0                	test   %eax,%eax
  801148:	0f 88 b8 02 00 00    	js     801406 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80114e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801154:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80115b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801161:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801168:	00 00 00 
  80116b:	e9 b6 01 00 00       	jmp    801326 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801170:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801176:	83 38 01             	cmpl   $0x1,(%eax)
  801179:	0f 85 99 01 00 00    	jne    801318 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80117f:	89 c1                	mov    %eax,%ecx
  801181:	8b 40 18             	mov    0x18(%eax),%eax
  801184:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801187:	83 f8 01             	cmp    $0x1,%eax
  80118a:	19 c0                	sbb    %eax,%eax
  80118c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801192:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801199:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	8b 51 04             	mov    0x4(%ecx),%edx
  8011a5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8011ab:	8b 49 10             	mov    0x10(%ecx),%ecx
  8011ae:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  8011b4:	8b 50 14             	mov    0x14(%eax),%edx
  8011b7:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8011bd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8011c0:	89 f0                	mov    %esi,%eax
  8011c2:	25 ff 0f 00 00       	and    $0xfff,%eax
  8011c7:	74 14                	je     8011dd <spawn+0x2ed>
		va -= i;
  8011c9:	29 c6                	sub    %eax,%esi
		memsz += i;
  8011cb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8011d1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8011d7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e2:	e9 23 01 00 00       	jmp    80130a <spawn+0x41a>
		if (i >= filesz) {
  8011e7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8011ed:	77 2b                	ja     80121a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8011ef:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011fd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 78 fa ff ff       	call   800c83 <sys_page_alloc>
  80120b:	85 c0                	test   %eax,%eax
  80120d:	0f 89 eb 00 00 00    	jns    8012fe <spawn+0x40e>
  801213:	89 c3                	mov    %eax,%ebx
  801215:	e9 cc 01 00 00       	jmp    8013e6 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80121a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801231:	e8 4d fa ff ff       	call   800c83 <sys_page_alloc>
  801236:	85 c0                	test   %eax,%eax
  801238:	0f 88 9e 01 00 00    	js     8013dc <spawn+0x4ec>
  80123e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801244:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801250:	89 04 24             	mov    %eax,(%esp)
  801253:	e8 b7 06 00 00       	call   80190f <seek>
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 80 01 00 00    	js     8013e0 <spawn+0x4f0>
  801260:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801266:	29 fa                	sub    %edi,%edx
  801268:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80126a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801270:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801275:	0f 47 c1             	cmova  %ecx,%eax
  801278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801283:	00 
  801284:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	e8 a5 05 00 00       	call   801837 <readn>
  801292:	85 c0                	test   %eax,%eax
  801294:	0f 88 4a 01 00 00    	js     8013e4 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80129a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8012a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8012ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c1:	e8 11 fa ff ff       	call   800cd7 <sys_page_map>
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	79 20                	jns    8012ea <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  8012ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ce:	c7 44 24 08 65 2a 80 	movl   $0x802a65,0x8(%esp)
  8012d5:	00 
  8012d6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  8012dd:	00 
  8012de:	c7 04 24 59 2a 80 00 	movl   $0x802a59,(%esp)
  8012e5:	e8 05 ee ff ff       	call   8000ef <_panic>
			sys_page_unmap(0, UTEMP);
  8012ea:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8012f1:	00 
  8012f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f9:	e8 2c fa ff ff       	call   800d2a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8012fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801304:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80130a:	89 df                	mov    %ebx,%edi
  80130c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801312:	0f 87 cf fe ff ff    	ja     8011e7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801318:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80131f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801326:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80132d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801333:	0f 8c 37 fe ff ff    	jl     801170 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801339:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80133f:	89 04 24             	mov    %eax,(%esp)
  801342:	e8 fb 02 00 00       	call   801642 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801347:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801357:	89 04 24             	mov    %eax,(%esp)
  80135a:	e8 71 fa ff ff       	call   800dd0 <sys_env_set_trapframe>
  80135f:	85 c0                	test   %eax,%eax
  801361:	79 20                	jns    801383 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801363:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801367:	c7 44 24 08 82 2a 80 	movl   $0x802a82,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 59 2a 80 00 	movl   $0x802a59,(%esp)
  80137e:	e8 6c ed ff ff       	call   8000ef <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801383:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80138a:	00 
  80138b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 e4 f9 ff ff       	call   800d7d <sys_env_set_status>
  801399:	85 c0                	test   %eax,%eax
  80139b:	79 30                	jns    8013cd <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  80139d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a1:	c7 44 24 08 9c 2a 80 	movl   $0x802a9c,0x8(%esp)
  8013a8:	00 
  8013a9:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8013b0:	00 
  8013b1:	c7 04 24 59 2a 80 00 	movl   $0x802a59,(%esp)
  8013b8:	e8 32 ed ff ff       	call   8000ef <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8013bd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8013c3:	eb 57                	jmp    80141c <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8013c5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8013cb:	eb 4f                	jmp    80141c <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8013cd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8013d3:	eb 47                	jmp    80141c <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8013d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8013da:	eb 40                	jmp    80141c <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	eb 06                	jmp    8013e6 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8013e0:	89 c3                	mov    %eax,%ebx
  8013e2:	eb 02                	jmp    8013e6 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8013e4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8013e6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	e8 ff f7 ff ff       	call   800bf3 <sys_env_destroy>
	close(fd);
  8013f4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	e8 40 02 00 00       	call   801642 <close>
	return r;
  801402:	89 d8                	mov    %ebx,%eax
  801404:	eb 16                	jmp    80141c <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801406:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80140d:	00 
  80140e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801415:	e8 10 f9 ff ff       	call   800d2a <sys_page_unmap>
  80141a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80141c:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801422:	5b                   	pop    %ebx
  801423:	5e                   	pop    %esi
  801424:	5f                   	pop    %edi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	56                   	push   %esi
  80142b:	53                   	push   %ebx
  80142c:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80142f:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801437:	eb 03                	jmp    80143c <spawnl+0x15>
		argc++;
  801439:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80143c:	83 c0 04             	add    $0x4,%eax
  80143f:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801443:	75 f4                	jne    801439 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801445:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80144c:	83 e0 f0             	and    $0xfffffff0,%eax
  80144f:	29 c4                	sub    %eax,%esp
  801451:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801455:	c1 e8 02             	shr    $0x2,%eax
  801458:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80145f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801464:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80146b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801472:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
  801478:	eb 0a                	jmp    801484 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80147a:	83 c0 01             	add    $0x1,%eax
  80147d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801481:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801484:	39 d0                	cmp    %edx,%eax
  801486:	75 f2                	jne    80147a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801488:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	89 04 24             	mov    %eax,(%esp)
  801492:	e8 59 fa ff ff       	call   800ef0 <spawn>
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    
  80149e:	66 90                	xchg   %ax,%ax

008014a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8014bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014c0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 16             	shr    $0x16,%edx
  8014d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	74 11                	je     8014f4 <fd_alloc+0x2d>
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	c1 ea 0c             	shr    $0xc,%edx
  8014e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ef:	f6 c2 01             	test   $0x1,%dl
  8014f2:	75 09                	jne    8014fd <fd_alloc+0x36>
			*fd_store = fd;
  8014f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fb:	eb 17                	jmp    801514 <fd_alloc+0x4d>
  8014fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801502:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801507:	75 c9                	jne    8014d2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801509:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80150f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80151c:	83 f8 1f             	cmp    $0x1f,%eax
  80151f:	77 36                	ja     801557 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801521:	c1 e0 0c             	shl    $0xc,%eax
  801524:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 16             	shr    $0x16,%edx
  80152e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	74 24                	je     80155e <fd_lookup+0x48>
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	c1 ea 0c             	shr    $0xc,%edx
  80153f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801546:	f6 c2 01             	test   $0x1,%dl
  801549:	74 1a                	je     801565 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80154b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154e:	89 02                	mov    %eax,(%edx)
	return 0;
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	eb 13                	jmp    80156a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 0c                	jmp    80156a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80155e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801563:	eb 05                	jmp    80156a <fd_lookup+0x54>
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 18             	sub    $0x18,%esp
  801572:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801575:	ba 58 2b 80 00       	mov    $0x802b58,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80157a:	eb 13                	jmp    80158f <dev_lookup+0x23>
  80157c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80157f:	39 08                	cmp    %ecx,(%eax)
  801581:	75 0c                	jne    80158f <dev_lookup+0x23>
			*dev = devtab[i];
  801583:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801586:	89 01                	mov    %eax,(%ecx)
			return 0;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
  80158d:	eb 30                	jmp    8015bf <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80158f:	8b 02                	mov    (%edx),%eax
  801591:	85 c0                	test   %eax,%eax
  801593:	75 e7                	jne    80157c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801595:	a1 04 40 80 00       	mov    0x804004,%eax
  80159a:	8b 40 48             	mov    0x48(%eax),%eax
  80159d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a5:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8015ac:	e8 37 ec ff ff       	call   8001e8 <cprintf>
	*dev = 0;
  8015b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 20             	sub    $0x20,%esp
  8015c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015dc:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 2f ff ff ff       	call   801516 <fd_lookup>
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 05                	js     8015f0 <fd_close+0x2f>
	    || fd != fd2)
  8015eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015ee:	74 0c                	je     8015fc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8015f0:	84 db                	test   %bl,%bl
  8015f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f7:	0f 44 c2             	cmove  %edx,%eax
  8015fa:	eb 3f                	jmp    80163b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	8b 06                	mov    (%esi),%eax
  801605:	89 04 24             	mov    %eax,(%esp)
  801608:	e8 5f ff ff ff       	call   80156c <dev_lookup>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 16                	js     801629 <fd_close+0x68>
		if (dev->dev_close)
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801619:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80161e:	85 c0                	test   %eax,%eax
  801620:	74 07                	je     801629 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801622:	89 34 24             	mov    %esi,(%esp)
  801625:	ff d0                	call   *%eax
  801627:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801629:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801634:	e8 f1 f6 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801639:	89 d8                	mov    %ebx,%eax
}
  80163b:	83 c4 20             	add    $0x20,%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 bc fe ff ff       	call   801516 <fd_lookup>
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	85 d2                	test   %edx,%edx
  80165e:	78 13                	js     801673 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801660:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801667:	00 
  801668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166b:	89 04 24             	mov    %eax,(%esp)
  80166e:	e8 4e ff ff ff       	call   8015c1 <fd_close>
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <close_all>:

void
close_all(void)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801681:	89 1c 24             	mov    %ebx,(%esp)
  801684:	e8 b9 ff ff ff       	call   801642 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801689:	83 c3 01             	add    $0x1,%ebx
  80168c:	83 fb 20             	cmp    $0x20,%ebx
  80168f:	75 f0                	jne    801681 <close_all+0xc>
		close(i);
}
  801691:	83 c4 14             	add    $0x14,%esp
  801694:	5b                   	pop    %ebx
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	57                   	push   %edi
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	89 04 24             	mov    %eax,(%esp)
  8016ad:	e8 64 fe ff ff       	call   801516 <fd_lookup>
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	85 d2                	test   %edx,%edx
  8016b6:	0f 88 e1 00 00 00    	js     80179d <dup+0x106>
		return r;
	close(newfdnum);
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 7b ff ff ff       	call   801642 <close>

	newfd = INDEX2FD(newfdnum);
  8016c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ca:	c1 e3 0c             	shl    $0xc,%ebx
  8016cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 d2 fd ff ff       	call   8014b0 <fd2data>
  8016de:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016e0:	89 1c 24             	mov    %ebx,(%esp)
  8016e3:	e8 c8 fd ff ff       	call   8014b0 <fd2data>
  8016e8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ea:	89 f0                	mov    %esi,%eax
  8016ec:	c1 e8 16             	shr    $0x16,%eax
  8016ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016f6:	a8 01                	test   $0x1,%al
  8016f8:	74 43                	je     80173d <dup+0xa6>
  8016fa:	89 f0                	mov    %esi,%eax
  8016fc:	c1 e8 0c             	shr    $0xc,%eax
  8016ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801706:	f6 c2 01             	test   $0x1,%dl
  801709:	74 32                	je     80173d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80170b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801712:	25 07 0e 00 00       	and    $0xe07,%eax
  801717:	89 44 24 10          	mov    %eax,0x10(%esp)
  80171b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80171f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801726:	00 
  801727:	89 74 24 04          	mov    %esi,0x4(%esp)
  80172b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801732:	e8 a0 f5 ff ff       	call   800cd7 <sys_page_map>
  801737:	89 c6                	mov    %eax,%esi
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 3e                	js     80177b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80173d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 ea 0c             	shr    $0xc,%edx
  801745:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80174c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801752:	89 54 24 10          	mov    %edx,0x10(%esp)
  801756:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80175a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801761:	00 
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176d:	e8 65 f5 ff ff       	call   800cd7 <sys_page_map>
  801772:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801774:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801777:	85 f6                	test   %esi,%esi
  801779:	79 22                	jns    80179d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80177b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801786:	e8 9f f5 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80178b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80178f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801796:	e8 8f f5 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80179b:	89 f0                	mov    %esi,%eax
}
  80179d:	83 c4 3c             	add    $0x3c,%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5f                   	pop    %edi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 24             	sub    $0x24,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	89 1c 24             	mov    %ebx,(%esp)
  8017b9:	e8 58 fd ff ff       	call   801516 <fd_lookup>
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	85 d2                	test   %edx,%edx
  8017c2:	78 6d                	js     801831 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	8b 00                	mov    (%eax),%eax
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	e8 94 fd ff ff       	call   80156c <dev_lookup>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 55                	js     801831 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017df:	8b 50 08             	mov    0x8(%eax),%edx
  8017e2:	83 e2 03             	and    $0x3,%edx
  8017e5:	83 fa 01             	cmp    $0x1,%edx
  8017e8:	75 23                	jne    80180d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ef:	8b 40 48             	mov    0x48(%eax),%eax
  8017f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fa:	c7 04 24 1d 2b 80 00 	movl   $0x802b1d,(%esp)
  801801:	e8 e2 e9 ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  801806:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180b:	eb 24                	jmp    801831 <read+0x8c>
	}
	if (!dev->dev_read)
  80180d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801810:	8b 52 08             	mov    0x8(%edx),%edx
  801813:	85 d2                	test   %edx,%edx
  801815:	74 15                	je     80182c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801817:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80181a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801821:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	ff d2                	call   *%edx
  80182a:	eb 05                	jmp    801831 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80182c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801831:	83 c4 24             	add    $0x24,%esp
  801834:	5b                   	pop    %ebx
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 1c             	sub    $0x1c,%esp
  801840:	8b 7d 08             	mov    0x8(%ebp),%edi
  801843:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801846:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184b:	eb 23                	jmp    801870 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80184d:	89 f0                	mov    %esi,%eax
  80184f:	29 d8                	sub    %ebx,%eax
  801851:	89 44 24 08          	mov    %eax,0x8(%esp)
  801855:	89 d8                	mov    %ebx,%eax
  801857:	03 45 0c             	add    0xc(%ebp),%eax
  80185a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185e:	89 3c 24             	mov    %edi,(%esp)
  801861:	e8 3f ff ff ff       	call   8017a5 <read>
		if (m < 0)
  801866:	85 c0                	test   %eax,%eax
  801868:	78 10                	js     80187a <readn+0x43>
			return m;
		if (m == 0)
  80186a:	85 c0                	test   %eax,%eax
  80186c:	74 0a                	je     801878 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80186e:	01 c3                	add    %eax,%ebx
  801870:	39 f3                	cmp    %esi,%ebx
  801872:	72 d9                	jb     80184d <readn+0x16>
  801874:	89 d8                	mov    %ebx,%eax
  801876:	eb 02                	jmp    80187a <readn+0x43>
  801878:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80187a:	83 c4 1c             	add    $0x1c,%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 24             	sub    $0x24,%esp
  801889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801893:	89 1c 24             	mov    %ebx,(%esp)
  801896:	e8 7b fc ff ff       	call   801516 <fd_lookup>
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	85 d2                	test   %edx,%edx
  80189f:	78 68                	js     801909 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ab:	8b 00                	mov    (%eax),%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 b7 fc ff ff       	call   80156c <dev_lookup>
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 50                	js     801909 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c0:	75 23                	jne    8018e5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c7:	8b 40 48             	mov    0x48(%eax),%eax
  8018ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	c7 04 24 39 2b 80 00 	movl   $0x802b39,(%esp)
  8018d9:	e8 0a e9 ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  8018de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e3:	eb 24                	jmp    801909 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018eb:	85 d2                	test   %edx,%edx
  8018ed:	74 15                	je     801904 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	ff d2                	call   *%edx
  801902:	eb 05                	jmp    801909 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801904:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801909:	83 c4 24             	add    $0x24,%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <seek>:

int
seek(int fdnum, off_t offset)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801915:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	e8 ef fb ff ff       	call   801516 <fd_lookup>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 0e                	js     801939 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80192b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80192e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801931:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 24             	sub    $0x24,%esp
  801942:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801945:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194c:	89 1c 24             	mov    %ebx,(%esp)
  80194f:	e8 c2 fb ff ff       	call   801516 <fd_lookup>
  801954:	89 c2                	mov    %eax,%edx
  801956:	85 d2                	test   %edx,%edx
  801958:	78 61                	js     8019bb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801964:	8b 00                	mov    (%eax),%eax
  801966:	89 04 24             	mov    %eax,(%esp)
  801969:	e8 fe fb ff ff       	call   80156c <dev_lookup>
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 49                	js     8019bb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801975:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801979:	75 23                	jne    80199e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80197b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801980:	8b 40 48             	mov    0x48(%eax),%eax
  801983:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  801992:	e8 51 e8 ff ff       	call   8001e8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801997:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80199c:	eb 1d                	jmp    8019bb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80199e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a1:	8b 52 18             	mov    0x18(%edx),%edx
  8019a4:	85 d2                	test   %edx,%edx
  8019a6:	74 0e                	je     8019b6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019af:	89 04 24             	mov    %eax,(%esp)
  8019b2:	ff d2                	call   *%edx
  8019b4:	eb 05                	jmp    8019bb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019bb:	83 c4 24             	add    $0x24,%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 24             	sub    $0x24,%esp
  8019c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	89 04 24             	mov    %eax,(%esp)
  8019d8:	e8 39 fb ff ff       	call   801516 <fd_lookup>
  8019dd:	89 c2                	mov    %eax,%edx
  8019df:	85 d2                	test   %edx,%edx
  8019e1:	78 52                	js     801a35 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ed:	8b 00                	mov    (%eax),%eax
  8019ef:	89 04 24             	mov    %eax,(%esp)
  8019f2:	e8 75 fb ff ff       	call   80156c <dev_lookup>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 3a                	js     801a35 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a02:	74 2c                	je     801a30 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a04:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a07:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a0e:	00 00 00 
	stat->st_isdir = 0;
  801a11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a18:	00 00 00 
	stat->st_dev = dev;
  801a1b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a28:	89 14 24             	mov    %edx,(%esp)
  801a2b:	ff 50 14             	call   *0x14(%eax)
  801a2e:	eb 05                	jmp    801a35 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a30:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a35:	83 c4 24             	add    $0x24,%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a4a:	00 
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 fb 01 00 00       	call   801c51 <open>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	85 db                	test   %ebx,%ebx
  801a5a:	78 1b                	js     801a77 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	89 1c 24             	mov    %ebx,(%esp)
  801a66:	e8 56 ff ff ff       	call   8019c1 <fstat>
  801a6b:	89 c6                	mov    %eax,%esi
	close(fd);
  801a6d:	89 1c 24             	mov    %ebx,(%esp)
  801a70:	e8 cd fb ff ff       	call   801642 <close>
	return r;
  801a75:	89 f0                	mov    %esi,%eax
}
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	83 ec 10             	sub    $0x10,%esp
  801a86:	89 c6                	mov    %eax,%esi
  801a88:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a8a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a91:	75 11                	jne    801aa4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a9a:	e8 ce 08 00 00       	call   80236d <ipc_find_env>
  801a9f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aa4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801aab:	00 
  801aac:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ab3:	00 
  801ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab8:	a1 00 40 80 00       	mov    0x804000,%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 f9 07 00 00       	call   8022be <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ac5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801acc:	00 
  801acd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad8:	e8 43 07 00 00       	call   802220 <ipc_recv>
}
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	8b 40 0c             	mov    0xc(%eax),%eax
  801af0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801afd:	ba 00 00 00 00       	mov    $0x0,%edx
  801b02:	b8 02 00 00 00       	mov    $0x2,%eax
  801b07:	e8 72 ff ff ff       	call   801a7e <fsipc>
}
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b24:	b8 06 00 00 00       	mov    $0x6,%eax
  801b29:	e8 50 ff ff ff       	call   801a7e <fsipc>
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	53                   	push   %ebx
  801b34:	83 ec 14             	sub    $0x14,%esp
  801b37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b4f:	e8 2a ff ff ff       	call   801a7e <fsipc>
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	85 d2                	test   %edx,%edx
  801b58:	78 2b                	js     801b85 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b5a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b61:	00 
  801b62:	89 1c 24             	mov    %ebx,(%esp)
  801b65:	e8 fd ec ff ff       	call   800867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b6a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b75:	a1 84 50 80 00       	mov    0x805084,%eax
  801b7a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b85:	83 c4 14             	add    $0x14,%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b91:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  801b98:	00 
  801b99:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ba0:	00 
  801ba1:	c7 04 24 86 2b 80 00 	movl   $0x802b86,(%esp)
  801ba8:	e8 42 e5 ff ff       	call   8000ef <_panic>

00801bad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 10             	sub    $0x10,%esp
  801bb5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	8b 40 0c             	mov    0xc(%eax),%eax
  801bbe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bc3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bce:	b8 03 00 00 00       	mov    $0x3,%eax
  801bd3:	e8 a6 fe ff ff       	call   801a7e <fsipc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 6a                	js     801c48 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bde:	39 c6                	cmp    %eax,%esi
  801be0:	73 24                	jae    801c06 <devfile_read+0x59>
  801be2:	c7 44 24 0c 91 2b 80 	movl   $0x802b91,0xc(%esp)
  801be9:	00 
  801bea:	c7 44 24 08 44 2a 80 	movl   $0x802a44,0x8(%esp)
  801bf1:	00 
  801bf2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bf9:	00 
  801bfa:	c7 04 24 86 2b 80 00 	movl   $0x802b86,(%esp)
  801c01:	e8 e9 e4 ff ff       	call   8000ef <_panic>
	assert(r <= PGSIZE);
  801c06:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c0b:	7e 24                	jle    801c31 <devfile_read+0x84>
  801c0d:	c7 44 24 0c 98 2b 80 	movl   $0x802b98,0xc(%esp)
  801c14:	00 
  801c15:	c7 44 24 08 44 2a 80 	movl   $0x802a44,0x8(%esp)
  801c1c:	00 
  801c1d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c24:	00 
  801c25:	c7 04 24 86 2b 80 00 	movl   $0x802b86,(%esp)
  801c2c:	e8 be e4 ff ff       	call   8000ef <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c31:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c35:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c3c:	00 
  801c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c40:	89 04 24             	mov    %eax,(%esp)
  801c43:	e8 bc ed ff ff       	call   800a04 <memmove>
	return r;
}
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	53                   	push   %ebx
  801c55:	83 ec 24             	sub    $0x24,%esp
  801c58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c5b:	89 1c 24             	mov    %ebx,(%esp)
  801c5e:	e8 cd eb ff ff       	call   800830 <strlen>
  801c63:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c68:	7f 60                	jg     801cca <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6d:	89 04 24             	mov    %eax,(%esp)
  801c70:	e8 52 f8 ff ff       	call   8014c7 <fd_alloc>
  801c75:	89 c2                	mov    %eax,%edx
  801c77:	85 d2                	test   %edx,%edx
  801c79:	78 54                	js     801ccf <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c86:	e8 dc eb ff ff       	call   800867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	e8 de fd ff ff       	call   801a7e <fsipc>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	79 17                	jns    801cbd <open+0x6c>
		fd_close(fd, 0);
  801ca6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cad:	00 
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 08 f9 ff ff       	call   8015c1 <fd_close>
		return r;
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	eb 12                	jmp    801ccf <open+0x7e>
	}

	return fd2num(fd);
  801cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc0:	89 04 24             	mov    %eax,(%esp)
  801cc3:	e8 d8 f7 ff ff       	call   8014a0 <fd2num>
  801cc8:	eb 05                	jmp    801ccf <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ccf:	83 c4 24             	add    $0x24,%esp
  801cd2:	5b                   	pop    %ebx
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce5:	e8 94 fd ff ff       	call   801a7e <fsipc>
}
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 10             	sub    $0x10,%esp
  801cf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	89 04 24             	mov    %eax,(%esp)
  801cfd:	e8 ae f7 ff ff       	call   8014b0 <fd2data>
  801d02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d04:	c7 44 24 04 a4 2b 80 	movl   $0x802ba4,0x4(%esp)
  801d0b:	00 
  801d0c:	89 1c 24             	mov    %ebx,(%esp)
  801d0f:	e8 53 eb ff ff       	call   800867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d14:	8b 46 04             	mov    0x4(%esi),%eax
  801d17:	2b 06                	sub    (%esi),%eax
  801d19:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d26:	00 00 00 
	stat->st_dev = &devpipe;
  801d29:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d30:	30 80 00 
	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	53                   	push   %ebx
  801d43:	83 ec 14             	sub    $0x14,%esp
  801d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d49:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d54:	e8 d1 ef ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d59:	89 1c 24             	mov    %ebx,(%esp)
  801d5c:	e8 4f f7 ff ff       	call   8014b0 <fd2data>
  801d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6c:	e8 b9 ef ff ff       	call   800d2a <sys_page_unmap>
}
  801d71:	83 c4 14             	add    $0x14,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	57                   	push   %edi
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 2c             	sub    $0x2c,%esp
  801d80:	89 c6                	mov    %eax,%esi
  801d82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d85:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d8d:	89 34 24             	mov    %esi,(%esp)
  801d90:	e8 10 06 00 00       	call   8023a5 <pageref>
  801d95:	89 c7                	mov    %eax,%edi
  801d97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d9a:	89 04 24             	mov    %eax,(%esp)
  801d9d:	e8 03 06 00 00       	call   8023a5 <pageref>
  801da2:	39 c7                	cmp    %eax,%edi
  801da4:	0f 94 c2             	sete   %dl
  801da7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801daa:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801db0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801db3:	39 fb                	cmp    %edi,%ebx
  801db5:	74 21                	je     801dd8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801db7:	84 d2                	test   %dl,%dl
  801db9:	74 ca                	je     801d85 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dbb:	8b 51 58             	mov    0x58(%ecx),%edx
  801dbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dca:	c7 04 24 ab 2b 80 00 	movl   $0x802bab,(%esp)
  801dd1:	e8 12 e4 ff ff       	call   8001e8 <cprintf>
  801dd6:	eb ad                	jmp    801d85 <_pipeisclosed+0xe>
	}
}
  801dd8:	83 c4 2c             	add    $0x2c,%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 1c             	sub    $0x1c,%esp
  801de9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dec:	89 34 24             	mov    %esi,(%esp)
  801def:	e8 bc f6 ff ff       	call   8014b0 <fd2data>
  801df4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df6:	bf 00 00 00 00       	mov    $0x0,%edi
  801dfb:	eb 45                	jmp    801e42 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dfd:	89 da                	mov    %ebx,%edx
  801dff:	89 f0                	mov    %esi,%eax
  801e01:	e8 71 ff ff ff       	call   801d77 <_pipeisclosed>
  801e06:	85 c0                	test   %eax,%eax
  801e08:	75 41                	jne    801e4b <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e0a:	e8 55 ee ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e0f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e12:	8b 0b                	mov    (%ebx),%ecx
  801e14:	8d 51 20             	lea    0x20(%ecx),%edx
  801e17:	39 d0                	cmp    %edx,%eax
  801e19:	73 e2                	jae    801dfd <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e22:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e25:	99                   	cltd   
  801e26:	c1 ea 1b             	shr    $0x1b,%edx
  801e29:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e2c:	83 e1 1f             	and    $0x1f,%ecx
  801e2f:	29 d1                	sub    %edx,%ecx
  801e31:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e35:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801e39:	83 c0 01             	add    $0x1,%eax
  801e3c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3f:	83 c7 01             	add    $0x1,%edi
  801e42:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e45:	75 c8                	jne    801e0f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e47:	89 f8                	mov    %edi,%eax
  801e49:	eb 05                	jmp    801e50 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e50:	83 c4 1c             	add    $0x1c,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	57                   	push   %edi
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 1c             	sub    $0x1c,%esp
  801e61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e64:	89 3c 24             	mov    %edi,(%esp)
  801e67:	e8 44 f6 ff ff       	call   8014b0 <fd2data>
  801e6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6e:	be 00 00 00 00       	mov    $0x0,%esi
  801e73:	eb 3d                	jmp    801eb2 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e75:	85 f6                	test   %esi,%esi
  801e77:	74 04                	je     801e7d <devpipe_read+0x25>
				return i;
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	eb 43                	jmp    801ec0 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e7d:	89 da                	mov    %ebx,%edx
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	e8 f1 fe ff ff       	call   801d77 <_pipeisclosed>
  801e86:	85 c0                	test   %eax,%eax
  801e88:	75 31                	jne    801ebb <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e8a:	e8 d5 ed ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e8f:	8b 03                	mov    (%ebx),%eax
  801e91:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e94:	74 df                	je     801e75 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e96:	99                   	cltd   
  801e97:	c1 ea 1b             	shr    $0x1b,%edx
  801e9a:	01 d0                	add    %edx,%eax
  801e9c:	83 e0 1f             	and    $0x1f,%eax
  801e9f:	29 d0                	sub    %edx,%eax
  801ea1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801eac:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaf:	83 c6 01             	add    $0x1,%esi
  801eb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb5:	75 d8                	jne    801e8f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	eb 05                	jmp    801ec0 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ec0:	83 c4 1c             	add    $0x1c,%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
  801ecd:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed3:	89 04 24             	mov    %eax,(%esp)
  801ed6:	e8 ec f5 ff ff       	call   8014c7 <fd_alloc>
  801edb:	89 c2                	mov    %eax,%edx
  801edd:	85 d2                	test   %edx,%edx
  801edf:	0f 88 4d 01 00 00    	js     802032 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eec:	00 
  801eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efb:	e8 83 ed ff ff       	call   800c83 <sys_page_alloc>
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	85 d2                	test   %edx,%edx
  801f04:	0f 88 28 01 00 00    	js     802032 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 b2 f5 ff ff       	call   8014c7 <fd_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	0f 88 fe 00 00 00    	js     80201d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f26:	00 
  801f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f35:	e8 49 ed ff ff       	call   800c83 <sys_page_alloc>
  801f3a:	89 c3                	mov    %eax,%ebx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	0f 88 d9 00 00 00    	js     80201d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	89 04 24             	mov    %eax,(%esp)
  801f4a:	e8 61 f5 ff ff       	call   8014b0 <fd2data>
  801f4f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f51:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f58:	00 
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f64:	e8 1a ed ff ff       	call   800c83 <sys_page_alloc>
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	0f 88 97 00 00 00    	js     80200a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 32 f5 ff ff       	call   8014b0 <fd2data>
  801f7e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f85:	00 
  801f86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f91:	00 
  801f92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9d:	e8 35 ed ff ff       	call   800cd7 <sys_page_map>
  801fa2:	89 c3                	mov    %eax,%ebx
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 52                	js     801ffa <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fa8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 c3 f4 ff ff       	call   8014a0 <fd2num>
  801fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 b3 f4 ff ff       	call   8014a0 <fd2num>
  801fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	eb 38                	jmp    802032 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801ffa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ffe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802005:	e8 20 ed ff ff       	call   800d2a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80200a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80200d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802011:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802018:	e8 0d ed ff ff       	call   800d2a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802020:	89 44 24 04          	mov    %eax,0x4(%esp)
  802024:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80202b:	e8 fa ec ff ff       	call   800d2a <sys_page_unmap>
  802030:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802032:	83 c4 30             	add    $0x30,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80203f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802042:	89 44 24 04          	mov    %eax,0x4(%esp)
  802046:	8b 45 08             	mov    0x8(%ebp),%eax
  802049:	89 04 24             	mov    %eax,(%esp)
  80204c:	e8 c5 f4 ff ff       	call   801516 <fd_lookup>
  802051:	89 c2                	mov    %eax,%edx
  802053:	85 d2                	test   %edx,%edx
  802055:	78 15                	js     80206c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205a:	89 04 24             	mov    %eax,(%esp)
  80205d:	e8 4e f4 ff ff       	call   8014b0 <fd2data>
	return _pipeisclosed(fd, p);
  802062:	89 c2                	mov    %eax,%edx
  802064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802067:	e8 0b fd ff ff       	call   801d77 <_pipeisclosed>
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    
  80206e:	66 90                	xchg   %ax,%ax

00802070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802080:	c7 44 24 04 c3 2b 80 	movl   $0x802bc3,0x4(%esp)
  802087:	00 
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 d4 e7 ff ff       	call   800867 <strcpy>
	return 0;
}
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b1:	eb 31                	jmp    8020e4 <devcons_write+0x4a>
		m = n - tot;
  8020b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8020b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020b8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020c7:	03 45 0c             	add    0xc(%ebp),%eax
  8020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ce:	89 3c 24             	mov    %edi,(%esp)
  8020d1:	e8 2e e9 ff ff       	call   800a04 <memmove>
		sys_cputs(buf, m);
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	89 3c 24             	mov    %edi,(%esp)
  8020dd:	e8 d4 ea ff ff       	call   800bb6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020e2:	01 f3                	add    %esi,%ebx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e9:	72 c8                	jb     8020b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020f1:	5b                   	pop    %ebx
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    

008020f6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802101:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802105:	75 07                	jne    80210e <devcons_read+0x18>
  802107:	eb 2a                	jmp    802133 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802109:	e8 56 eb ff ff       	call   800c64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80210e:	66 90                	xchg   %ax,%ax
  802110:	e8 bf ea ff ff       	call   800bd4 <sys_cgetc>
  802115:	85 c0                	test   %eax,%eax
  802117:	74 f0                	je     802109 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802119:	85 c0                	test   %eax,%eax
  80211b:	78 16                	js     802133 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80211d:	83 f8 04             	cmp    $0x4,%eax
  802120:	74 0c                	je     80212e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802122:	8b 55 0c             	mov    0xc(%ebp),%edx
  802125:	88 02                	mov    %al,(%edx)
	return 1;
  802127:	b8 01 00 00 00       	mov    $0x1,%eax
  80212c:	eb 05                	jmp    802133 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80213b:	8b 45 08             	mov    0x8(%ebp),%eax
  80213e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802141:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802148:	00 
  802149:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 62 ea ff ff       	call   800bb6 <sys_cputs>
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <getchar>:

int
getchar(void)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80215c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802163:	00 
  802164:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802167:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802172:	e8 2e f6 ff ff       	call   8017a5 <read>
	if (r < 0)
  802177:	85 c0                	test   %eax,%eax
  802179:	78 0f                	js     80218a <getchar+0x34>
		return r;
	if (r < 1)
  80217b:	85 c0                	test   %eax,%eax
  80217d:	7e 06                	jle    802185 <getchar+0x2f>
		return -E_EOF;
	return c;
  80217f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802183:	eb 05                	jmp    80218a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802185:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802195:	89 44 24 04          	mov    %eax,0x4(%esp)
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	89 04 24             	mov    %eax,(%esp)
  80219f:	e8 72 f3 ff ff       	call   801516 <fd_lookup>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 11                	js     8021b9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021b1:	39 10                	cmp    %edx,(%eax)
  8021b3:	0f 94 c0             	sete   %al
  8021b6:	0f b6 c0             	movzbl %al,%eax
}
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    

008021bb <opencons>:

int
opencons(void)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c4:	89 04 24             	mov    %eax,(%esp)
  8021c7:	e8 fb f2 ff ff       	call   8014c7 <fd_alloc>
		return r;
  8021cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 40                	js     802212 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d9:	00 
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e8:	e8 96 ea ff ff       	call   800c83 <sys_page_alloc>
		return r;
  8021ed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	78 1f                	js     802212 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802208:	89 04 24             	mov    %eax,(%esp)
  80220b:	e8 90 f2 ff ff       	call   8014a0 <fd2num>
  802210:	89 c2                	mov    %eax,%edx
}
  802212:	89 d0                	mov    %edx,%eax
  802214:	c9                   	leave  
  802215:	c3                   	ret    
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	83 ec 10             	sub    $0x10,%esp
  802228:	8b 75 08             	mov    0x8(%ebp),%esi
  80222b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802231:	85 c0                	test   %eax,%eax
  802233:	75 0e                	jne    802243 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802235:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80223c:	e8 58 ec ff ff       	call   800e99 <sys_ipc_recv>
  802241:	eb 08                	jmp    80224b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802243:	89 04 24             	mov    %eax,(%esp)
  802246:	e8 4e ec ff ff       	call   800e99 <sys_ipc_recv>
	if(r == 0){
  80224b:	85 c0                	test   %eax,%eax
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	75 1e                	jne    802270 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802252:	85 f6                	test   %esi,%esi
  802254:	74 0a                	je     802260 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802256:	a1 04 40 80 00       	mov    0x804004,%eax
  80225b:	8b 40 74             	mov    0x74(%eax),%eax
  80225e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802260:	85 db                	test   %ebx,%ebx
  802262:	74 2c                	je     802290 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802264:	a1 04 40 80 00       	mov    0x804004,%eax
  802269:	8b 40 78             	mov    0x78(%eax),%eax
  80226c:	89 03                	mov    %eax,(%ebx)
  80226e:	eb 20                	jmp    802290 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802270:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802274:	c7 44 24 08 d0 2b 80 	movl   $0x802bd0,0x8(%esp)
  80227b:	00 
  80227c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802283:	00 
  802284:	c7 04 24 4c 2c 80 00 	movl   $0x802c4c,(%esp)
  80228b:	e8 5f de ff ff       	call   8000ef <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802290:	a1 04 40 80 00       	mov    0x804004,%eax
  802295:	8b 50 70             	mov    0x70(%eax),%edx
  802298:	85 d2                	test   %edx,%edx
  80229a:	75 13                	jne    8022af <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80229c:	8b 40 48             	mov    0x48(%eax),%eax
  80229f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a3:	c7 04 24 00 2c 80 00 	movl   $0x802c00,(%esp)
  8022aa:	e8 39 df ff ff       	call   8001e8 <cprintf>
	return thisenv->env_ipc_value;
  8022af:	a1 04 40 80 00       	mov    0x804004,%eax
  8022b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	5b                   	pop    %ebx
  8022bb:	5e                   	pop    %esi
  8022bc:	5d                   	pop    %ebp
  8022bd:	c3                   	ret    

008022be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8022cd:	85 f6                	test   %esi,%esi
  8022cf:	75 22                	jne    8022f3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8022d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8022d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8022df:	ee 
  8022e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e7:	89 3c 24             	mov    %edi,(%esp)
  8022ea:	e8 87 eb ff ff       	call   800e76 <sys_ipc_try_send>
  8022ef:	89 c3                	mov    %eax,%ebx
  8022f1:	eb 1c                	jmp    80230f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8022f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802301:	89 44 24 04          	mov    %eax,0x4(%esp)
  802305:	89 3c 24             	mov    %edi,(%esp)
  802308:	e8 69 eb ff ff       	call   800e76 <sys_ipc_try_send>
  80230d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80230f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802312:	74 3e                	je     802352 <ipc_send+0x94>
  802314:	89 d8                	mov    %ebx,%eax
  802316:	c1 e8 1f             	shr    $0x1f,%eax
  802319:	84 c0                	test   %al,%al
  80231b:	74 35                	je     802352 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80231d:	e8 23 e9 ff ff       	call   800c45 <sys_getenvid>
  802322:	89 44 24 04          	mov    %eax,0x4(%esp)
  802326:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  80232d:	e8 b6 de ff ff       	call   8001e8 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802332:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802336:	c7 44 24 08 24 2c 80 	movl   $0x802c24,0x8(%esp)
  80233d:	00 
  80233e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802345:	00 
  802346:	c7 04 24 4c 2c 80 00 	movl   $0x802c4c,(%esp)
  80234d:	e8 9d dd ff ff       	call   8000ef <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802352:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802355:	75 0e                	jne    802365 <ipc_send+0xa7>
			sys_yield();
  802357:	e8 08 e9 ff ff       	call   800c64 <sys_yield>
		else break;
	}
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	e9 68 ff ff ff       	jmp    8022cd <ipc_send+0xf>
	
}
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802373:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802378:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80237b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802381:	8b 52 50             	mov    0x50(%edx),%edx
  802384:	39 ca                	cmp    %ecx,%edx
  802386:	75 0d                	jne    802395 <ipc_find_env+0x28>
			return envs[i].env_id;
  802388:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80238b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802390:	8b 40 40             	mov    0x40(%eax),%eax
  802393:	eb 0e                	jmp    8023a3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802395:	83 c0 01             	add    $0x1,%eax
  802398:	3d 00 04 00 00       	cmp    $0x400,%eax
  80239d:	75 d9                	jne    802378 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80239f:	66 b8 00 00          	mov    $0x0,%ax
}
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    

008023a5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	c1 e8 16             	shr    $0x16,%eax
  8023b0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023bc:	f6 c1 01             	test   $0x1,%cl
  8023bf:	74 1d                	je     8023de <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023c1:	c1 ea 0c             	shr    $0xc,%edx
  8023c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023cb:	f6 c2 01             	test   $0x1,%dl
  8023ce:	74 0e                	je     8023de <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d0:	c1 ea 0c             	shr    $0xc,%edx
  8023d3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023da:	ef 
  8023db:	0f b7 c0             	movzwl %ax,%eax
}
  8023de:	5d                   	pop    %ebp
  8023df:	c3                   	ret    

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8023f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023fc:	89 ea                	mov    %ebp,%edx
  8023fe:	89 0c 24             	mov    %ecx,(%esp)
  802401:	75 2d                	jne    802430 <__udivdi3+0x50>
  802403:	39 e9                	cmp    %ebp,%ecx
  802405:	77 61                	ja     802468 <__udivdi3+0x88>
  802407:	85 c9                	test   %ecx,%ecx
  802409:	89 ce                	mov    %ecx,%esi
  80240b:	75 0b                	jne    802418 <__udivdi3+0x38>
  80240d:	b8 01 00 00 00       	mov    $0x1,%eax
  802412:	31 d2                	xor    %edx,%edx
  802414:	f7 f1                	div    %ecx
  802416:	89 c6                	mov    %eax,%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	89 e8                	mov    %ebp,%eax
  80241c:	f7 f6                	div    %esi
  80241e:	89 c5                	mov    %eax,%ebp
  802420:	89 f8                	mov    %edi,%eax
  802422:	f7 f6                	div    %esi
  802424:	89 ea                	mov    %ebp,%edx
  802426:	83 c4 0c             	add    $0xc,%esp
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	39 e8                	cmp    %ebp,%eax
  802432:	77 24                	ja     802458 <__udivdi3+0x78>
  802434:	0f bd e8             	bsr    %eax,%ebp
  802437:	83 f5 1f             	xor    $0x1f,%ebp
  80243a:	75 3c                	jne    802478 <__udivdi3+0x98>
  80243c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802440:	39 34 24             	cmp    %esi,(%esp)
  802443:	0f 86 9f 00 00 00    	jbe    8024e8 <__udivdi3+0x108>
  802449:	39 d0                	cmp    %edx,%eax
  80244b:	0f 82 97 00 00 00    	jb     8024e8 <__udivdi3+0x108>
  802451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802458:	31 d2                	xor    %edx,%edx
  80245a:	31 c0                	xor    %eax,%eax
  80245c:	83 c4 0c             	add    $0xc,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	89 f8                	mov    %edi,%eax
  80246a:	f7 f1                	div    %ecx
  80246c:	31 d2                	xor    %edx,%edx
  80246e:	83 c4 0c             	add    $0xc,%esp
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	8b 3c 24             	mov    (%esp),%edi
  80247d:	d3 e0                	shl    %cl,%eax
  80247f:	89 c6                	mov    %eax,%esi
  802481:	b8 20 00 00 00       	mov    $0x20,%eax
  802486:	29 e8                	sub    %ebp,%eax
  802488:	89 c1                	mov    %eax,%ecx
  80248a:	d3 ef                	shr    %cl,%edi
  80248c:	89 e9                	mov    %ebp,%ecx
  80248e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802492:	8b 3c 24             	mov    (%esp),%edi
  802495:	09 74 24 08          	or     %esi,0x8(%esp)
  802499:	89 d6                	mov    %edx,%esi
  80249b:	d3 e7                	shl    %cl,%edi
  80249d:	89 c1                	mov    %eax,%ecx
  80249f:	89 3c 24             	mov    %edi,(%esp)
  8024a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024a6:	d3 ee                	shr    %cl,%esi
  8024a8:	89 e9                	mov    %ebp,%ecx
  8024aa:	d3 e2                	shl    %cl,%edx
  8024ac:	89 c1                	mov    %eax,%ecx
  8024ae:	d3 ef                	shr    %cl,%edi
  8024b0:	09 d7                	or     %edx,%edi
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	89 f8                	mov    %edi,%eax
  8024b6:	f7 74 24 08          	divl   0x8(%esp)
  8024ba:	89 d6                	mov    %edx,%esi
  8024bc:	89 c7                	mov    %eax,%edi
  8024be:	f7 24 24             	mull   (%esp)
  8024c1:	39 d6                	cmp    %edx,%esi
  8024c3:	89 14 24             	mov    %edx,(%esp)
  8024c6:	72 30                	jb     8024f8 <__udivdi3+0x118>
  8024c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024cc:	89 e9                	mov    %ebp,%ecx
  8024ce:	d3 e2                	shl    %cl,%edx
  8024d0:	39 c2                	cmp    %eax,%edx
  8024d2:	73 05                	jae    8024d9 <__udivdi3+0xf9>
  8024d4:	3b 34 24             	cmp    (%esp),%esi
  8024d7:	74 1f                	je     8024f8 <__udivdi3+0x118>
  8024d9:	89 f8                	mov    %edi,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	e9 7a ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ef:	e9 68 ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	83 c4 0c             	add    $0xc,%esp
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	83 ec 14             	sub    $0x14,%esp
  802516:	8b 44 24 28          	mov    0x28(%esp),%eax
  80251a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80251e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802522:	89 c7                	mov    %eax,%edi
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 44 24 30          	mov    0x30(%esp),%eax
  80252c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802530:	89 34 24             	mov    %esi,(%esp)
  802533:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802537:	85 c0                	test   %eax,%eax
  802539:	89 c2                	mov    %eax,%edx
  80253b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80253f:	75 17                	jne    802558 <__umoddi3+0x48>
  802541:	39 fe                	cmp    %edi,%esi
  802543:	76 4b                	jbe    802590 <__umoddi3+0x80>
  802545:	89 c8                	mov    %ecx,%eax
  802547:	89 fa                	mov    %edi,%edx
  802549:	f7 f6                	div    %esi
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	83 c4 14             	add    $0x14,%esp
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    
  802556:	66 90                	xchg   %ax,%ax
  802558:	39 f8                	cmp    %edi,%eax
  80255a:	77 54                	ja     8025b0 <__umoddi3+0xa0>
  80255c:	0f bd e8             	bsr    %eax,%ebp
  80255f:	83 f5 1f             	xor    $0x1f,%ebp
  802562:	75 5c                	jne    8025c0 <__umoddi3+0xb0>
  802564:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802568:	39 3c 24             	cmp    %edi,(%esp)
  80256b:	0f 87 e7 00 00 00    	ja     802658 <__umoddi3+0x148>
  802571:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802575:	29 f1                	sub    %esi,%ecx
  802577:	19 c7                	sbb    %eax,%edi
  802579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802581:	8b 44 24 08          	mov    0x8(%esp),%eax
  802585:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802589:	83 c4 14             	add    $0x14,%esp
  80258c:	5e                   	pop    %esi
  80258d:	5f                   	pop    %edi
  80258e:	5d                   	pop    %ebp
  80258f:	c3                   	ret    
  802590:	85 f6                	test   %esi,%esi
  802592:	89 f5                	mov    %esi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f6                	div    %esi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025a5:	31 d2                	xor    %edx,%edx
  8025a7:	f7 f5                	div    %ebp
  8025a9:	89 c8                	mov    %ecx,%eax
  8025ab:	f7 f5                	div    %ebp
  8025ad:	eb 9c                	jmp    80254b <__umoddi3+0x3b>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 fa                	mov    %edi,%edx
  8025b4:	83 c4 14             	add    $0x14,%esp
  8025b7:	5e                   	pop    %esi
  8025b8:	5f                   	pop    %edi
  8025b9:	5d                   	pop    %ebp
  8025ba:	c3                   	ret    
  8025bb:	90                   	nop
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 04 24             	mov    (%esp),%eax
  8025c3:	be 20 00 00 00       	mov    $0x20,%esi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ee                	sub    %ebp,%esi
  8025cc:	d3 e2                	shl    %cl,%edx
  8025ce:	89 f1                	mov    %esi,%ecx
  8025d0:	d3 e8                	shr    %cl,%eax
  8025d2:	89 e9                	mov    %ebp,%ecx
  8025d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d8:	8b 04 24             	mov    (%esp),%eax
  8025db:	09 54 24 04          	or     %edx,0x4(%esp)
  8025df:	89 fa                	mov    %edi,%edx
  8025e1:	d3 e0                	shl    %cl,%eax
  8025e3:	89 f1                	mov    %esi,%ecx
  8025e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025ed:	d3 ea                	shr    %cl,%edx
  8025ef:	89 e9                	mov    %ebp,%ecx
  8025f1:	d3 e7                	shl    %cl,%edi
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	d3 e8                	shr    %cl,%eax
  8025f7:	89 e9                	mov    %ebp,%ecx
  8025f9:	09 f8                	or     %edi,%eax
  8025fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8025ff:	f7 74 24 04          	divl   0x4(%esp)
  802603:	d3 e7                	shl    %cl,%edi
  802605:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802609:	89 d7                	mov    %edx,%edi
  80260b:	f7 64 24 08          	mull   0x8(%esp)
  80260f:	39 d7                	cmp    %edx,%edi
  802611:	89 c1                	mov    %eax,%ecx
  802613:	89 14 24             	mov    %edx,(%esp)
  802616:	72 2c                	jb     802644 <__umoddi3+0x134>
  802618:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80261c:	72 22                	jb     802640 <__umoddi3+0x130>
  80261e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802622:	29 c8                	sub    %ecx,%eax
  802624:	19 d7                	sbb    %edx,%edi
  802626:	89 e9                	mov    %ebp,%ecx
  802628:	89 fa                	mov    %edi,%edx
  80262a:	d3 e8                	shr    %cl,%eax
  80262c:	89 f1                	mov    %esi,%ecx
  80262e:	d3 e2                	shl    %cl,%edx
  802630:	89 e9                	mov    %ebp,%ecx
  802632:	d3 ef                	shr    %cl,%edi
  802634:	09 d0                	or     %edx,%eax
  802636:	89 fa                	mov    %edi,%edx
  802638:	83 c4 14             	add    $0x14,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
  802640:	39 d7                	cmp    %edx,%edi
  802642:	75 da                	jne    80261e <__umoddi3+0x10e>
  802644:	8b 14 24             	mov    (%esp),%edx
  802647:	89 c1                	mov    %eax,%ecx
  802649:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80264d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802651:	eb cb                	jmp    80261e <__umoddi3+0x10e>
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80265c:	0f 82 0f ff ff ff    	jb     802571 <__umoddi3+0x61>
  802662:	e9 1a ff ff ff       	jmp    802581 <__umoddi3+0x71>
