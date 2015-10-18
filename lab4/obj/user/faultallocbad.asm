
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  80004b:	e8 f3 01 00 00       	call   800243 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 65 0c 00 00       	call   800cd4 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ca 12 80 00 	movl   $0x8012ca,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 0c 13 80 	movl   $0x80130c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 32 07 00 00       	call   8007e5 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 71 0e 00 00       	call   800f3c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 d9 0a 00 00       	call   800bb8 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	66 90                	xchg   %ax,%ax
  8000e3:	90                   	nop

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000f6:	e8 79 0b 00 00       	call   800c74 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
  800133:	90                   	nop

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 d1 0a 00 00       	call   800c17 <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 16 0b 00 00       	call   800c74 <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  80017b:	e8 c3 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 53 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 c8 12 80 00 	movl   $0x8012c8,(%esp)
  800196:	e8 a8 00 00 00       	call   800243 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
  80019e:	66 90                	xchg   %ax,%ax

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	83 c0 01             	add    $0x1,%eax
  8001b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 19                	jne    8001d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c6:	00 
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 e6 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	83 c4 14             	add    $0x14,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800206:	8b 45 08             	mov    0x8(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021e:	e8 8a 01 00 00       	call   8003ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800223:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 7d 09 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8b 45 08             	mov    0x8(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 87 ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    
  80025d:	66 90                	xchg   %ax,%ax
  80025f:	90                   	nop

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 59                	ja     8002e5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	83 eb 01             	sub    $0x1,%ebx
  800293:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800297:	8b 45 10             	mov    0x10(%ebp),%eax
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ad:	00 
  8002ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bb:	e8 60 0d 00 00       	call   801020 <__udivdi3>
  8002c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cf:	89 fa                	mov    %edi,%edx
  8002d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d4:	e8 87 ff ff ff       	call   800260 <printnum>
  8002d9:	eb 11                	jmp    8002ec <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002df:	89 34 24             	mov    %esi,(%esp)
  8002e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e5:	83 eb 01             	sub    $0x1,%ebx
  8002e8:	85 db                	test   %ebx,%ebx
  8002ea:	7f ef                	jg     8002db <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800302:	00 
  800303:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	e8 3b 0e 00 00       	call   801150 <__umoddi3>
  800315:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800319:	0f be 80 5b 13 80 00 	movsbl 0x80135b(%eax),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800326:	83 c4 3c             	add    $0x3c,%esp
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800331:	83 fa 01             	cmp    $0x1,%edx
  800334:	7e 0e                	jle    800344 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	8b 52 04             	mov    0x4(%edx),%edx
  800342:	eb 22                	jmp    800366 <getuint+0x38>
	else if (lflag)
  800344:	85 d2                	test   %edx,%edx
  800346:	74 10                	je     800358 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 0e                	jmp    800366 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800372:	8b 10                	mov    (%eax),%edx
  800374:	3b 50 04             	cmp    0x4(%eax),%edx
  800377:	73 0a                	jae    800383 <sprintputch+0x1b>
		*b->buf++ = ch;
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	88 0a                	mov    %cl,(%edx)
  80037e:	83 c2 01             	add    $0x1,%edx
  800381:	89 10                	mov    %edx,(%eax)
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800392:	8b 45 10             	mov    0x10(%ebp),%eax
  800395:	89 44 24 08          	mov    %eax,0x8(%esp)
  800399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	e8 02 00 00 00       	call   8003ad <vprintfmt>
	va_end(ap);
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	57                   	push   %edi
  8003b1:	56                   	push   %esi
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 4c             	sub    $0x4c,%esp
  8003b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bc:	eb 12                	jmp    8003d0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	0f 84 bf 03 00 00    	je     800785 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8003c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d0:	0f b6 06             	movzbl (%esi),%eax
  8003d3:	83 c6 01             	add    $0x1,%esi
  8003d6:	83 f8 25             	cmp    $0x25,%eax
  8003d9:	75 e3                	jne    8003be <vprintfmt+0x11>
  8003db:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003eb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fa:	eb 2b                	jmp    800427 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 22                	jmp    800427 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 19                	jmp    800427 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 0d                	jmp    800427 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80041d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800420:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	0f b6 16             	movzbl (%esi),%edx
  80042a:	0f b6 c2             	movzbl %dl,%eax
  80042d:	8d 7e 01             	lea    0x1(%esi),%edi
  800430:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800433:	83 ea 23             	sub    $0x23,%edx
  800436:	80 fa 55             	cmp    $0x55,%dl
  800439:	0f 87 28 03 00 00    	ja     800767 <vprintfmt+0x3ba>
  80043f:	0f b6 d2             	movzbl %dl,%edx
  800442:	ff 24 95 20 14 80 00 	jmp    *0x801420(,%edx,4)
  800449:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800453:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800458:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800462:	8d 50 d0             	lea    -0x30(%eax),%edx
  800465:	83 fa 09             	cmp    $0x9,%edx
  800468:	77 2f                	ja     800499 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046d:	eb e9                	jmp    800458 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800480:	eb 1a                	jmp    80049c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800485:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800489:	79 9c                	jns    800427 <vprintfmt+0x7a>
  80048b:	eb 81                	jmp    80040e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800490:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800497:	eb 8e                	jmp    800427 <vprintfmt+0x7a>
  800499:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80049c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a0:	79 85                	jns    800427 <vprintfmt+0x7a>
  8004a2:	e9 73 ff ff ff       	jmp    80041a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ad:	e9 75 ff ff ff       	jmp    800427 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ca:	e9 01 ff ff ff       	jmp    8003d0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	89 c2                	mov    %eax,%edx
  8004dc:	c1 fa 1f             	sar    $0x1f,%edx
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 09             	cmp    $0x9,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x146>
  8004e8:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 23                	jne    800516 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	c7 44 24 08 73 13 80 	movl   $0x801373,0x8(%esp)
  8004fe:	00 
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	8b 7d 08             	mov    0x8(%ebp),%edi
  800506:	89 3c 24             	mov    %edi,(%esp)
  800509:	e8 77 fe ff ff       	call   800385 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800511:	e9 ba fe ff ff       	jmp    8003d0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051a:	c7 44 24 08 7c 13 80 	movl   $0x80137c,0x8(%esp)
  800521:	00 
  800522:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800526:	8b 7d 08             	mov    0x8(%ebp),%edi
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	e8 54 fe ff ff       	call   800385 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800534:	e9 97 fe ff ff       	jmp    8003d0 <vprintfmt+0x23>
  800539:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80054d:	85 f6                	test   %esi,%esi
  80054f:	ba 6c 13 80 00       	mov    $0x80136c,%edx
  800554:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	0f 8e 8c 00 00 00    	jle    8005ed <vprintfmt+0x240>
  800561:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800565:	0f 84 82 00 00 00    	je     8005ed <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056f:	89 34 24             	mov    %esi,(%esp)
  800572:	e8 b1 02 00 00       	call   800828 <strnlen>
  800577:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80057a:	29 c2                	sub    %eax,%edx
  80057c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800583:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800586:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800589:	89 de                	mov    %ebx,%esi
  80058b:	89 d3                	mov    %edx,%ebx
  80058d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	eb 0d                	jmp    80059e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800591:	89 74 24 04          	mov    %esi,0x4(%esp)
  800595:	89 3c 24             	mov    %edi,(%esp)
  800598:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	83 eb 01             	sub    $0x1,%ebx
  80059e:	85 db                	test   %ebx,%ebx
  8005a0:	7f ef                	jg     800591 <vprintfmt+0x1e4>
  8005a2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a5:	89 f3                	mov    %esi,%ebx
  8005a7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8005b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ba:	29 c2                	sub    %eax,%edx
  8005bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005bf:	eb 2c                	jmp    8005ed <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c5:	74 18                	je     8005df <vprintfmt+0x232>
  8005c7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ca:	83 fa 5e             	cmp    $0x5e,%edx
  8005cd:	76 10                	jbe    8005df <vprintfmt+0x232>
					putch('?', putdat);
  8005cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005da:	ff 55 08             	call   *0x8(%ebp)
  8005dd:	eb 0a                	jmp    8005e9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005ed:	0f be 06             	movsbl (%esi),%eax
  8005f0:	83 c6 01             	add    $0x1,%esi
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	74 25                	je     80061c <vprintfmt+0x26f>
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	78 c6                	js     8005c1 <vprintfmt+0x214>
  8005fb:	83 ef 01             	sub    $0x1,%edi
  8005fe:	79 c1                	jns    8005c1 <vprintfmt+0x214>
  800600:	8b 7d 08             	mov    0x8(%ebp),%edi
  800603:	89 de                	mov    %ebx,%esi
  800605:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800608:	eb 1a                	jmp    800624 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800615:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	83 eb 01             	sub    $0x1,%ebx
  80061a:	eb 08                	jmp    800624 <vprintfmt+0x277>
  80061c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80061f:	89 de                	mov    %ebx,%esi
  800621:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f e2                	jg     80060a <vprintfmt+0x25d>
  800628:	89 7d 08             	mov    %edi,0x8(%ebp)
  80062b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800630:	e9 9b fd ff ff       	jmp    8003d0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 10                	jle    80064a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 08             	lea    0x8(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	8b 78 04             	mov    0x4(%eax),%edi
  800648:	eb 26                	jmp    800670 <vprintfmt+0x2c3>
	else if (lflag)
  80064a:	85 c9                	test   %ecx,%ecx
  80064c:	74 12                	je     800660 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 30                	mov    (%eax),%esi
  800659:	89 f7                	mov    %esi,%edi
  80065b:	c1 ff 1f             	sar    $0x1f,%edi
  80065e:	eb 10                	jmp    800670 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	8b 30                	mov    (%eax),%esi
  80066b:	89 f7                	mov    %esi,%edi
  80066d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800675:	85 ff                	test   %edi,%edi
  800677:	0f 89 ac 00 00 00    	jns    800729 <vprintfmt+0x37c>
				putch('-', putdat);
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80068b:	f7 de                	neg    %esi
  80068d:	83 d7 00             	adc    $0x0,%edi
  800690:	f7 df                	neg    %edi
			}
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
  800697:	e9 8d 00 00 00       	jmp    800729 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069c:	89 ca                	mov    %ecx,%edx
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 88 fc ff ff       	call   80032e <getuint>
  8006a6:	89 c6                	mov    %eax,%esi
  8006a8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006af:	eb 78                	jmp    800729 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ca:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006db:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006de:	e9 ed fc ff ff       	jmp    8003d0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006fc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 50 04             	lea    0x4(%eax),%edx
  800705:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800708:	8b 30                	mov    (%eax),%esi
  80070a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800714:	eb 13                	jmp    800729 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800716:	89 ca                	mov    %ecx,%edx
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
  80071b:	e8 0e fc ff ff       	call   80032e <getuint>
  800720:	89 c6                	mov    %eax,%esi
  800722:	89 d7                	mov    %edx,%edi
			base = 16;
  800724:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800729:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80072d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800731:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800734:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073c:	89 34 24             	mov    %esi,(%esp)
  80073f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800743:	89 da                	mov    %ebx,%edx
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	e8 13 fb ff ff       	call   800260 <printnum>
			break;
  80074d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800750:	e9 7b fc ff ff       	jmp    8003d0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800759:	89 04 24             	mov    %eax,(%esp)
  80075c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800762:	e9 69 fc ff ff       	jmp    8003d0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800767:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800772:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800775:	eb 03                	jmp    80077a <vprintfmt+0x3cd>
  800777:	83 ee 01             	sub    $0x1,%esi
  80077a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80077e:	75 f7                	jne    800777 <vprintfmt+0x3ca>
  800780:	e9 4b fc ff ff       	jmp    8003d0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800785:	83 c4 4c             	add    $0x4c,%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 28             	sub    $0x28,%esp
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	74 30                	je     8007de <vsnprintf+0x51>
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	7e 2c                	jle    8007de <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c7:	c7 04 24 68 03 80 00 	movl   $0x800368,(%esp)
  8007ce:	e8 da fb ff ff       	call   8003ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	eb 05                	jmp    8007e3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	e8 82 ff ff ff       	call   80078d <vsnprintf>
	va_end(ap);

	return rc;
}
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    
  80080d:	66 90                	xchg   %ax,%ax
  80080f:	90                   	nop

00800810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	eb 03                	jmp    800820 <strlen+0x10>
		n++;
  80081d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800824:	75 f7                	jne    80081d <strlen+0xd>
		n++;
	return n;
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
  800836:	eb 03                	jmp    80083b <strnlen+0x13>
		n++;
  800838:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	39 d0                	cmp    %edx,%eax
  80083d:	74 06                	je     800845 <strnlen+0x1d>
  80083f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800843:	75 f3                	jne    800838 <strnlen+0x10>
		n++;
	return n;
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
  800856:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80085a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	84 c9                	test   %cl,%cl
  800862:	75 f2                	jne    800856 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800871:	89 1c 24             	mov    %ebx,(%esp)
  800874:	e8 97 ff ff ff       	call   800810 <strlen>
	strcpy(dst + len, src);
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800880:	01 d8                	add    %ebx,%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 bd ff ff ff       	call   800847 <strcpy>
	return dst;
}
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a5:	eb 0f                	jmp    8008b6 <strncpy+0x24>
		*dst++ = *src;
  8008a7:	0f b6 1a             	movzbl (%edx),%ebx
  8008aa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ad:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	39 f1                	cmp    %esi,%ecx
  8008b8:	75 ed                	jne    8008a7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	75 0a                	jne    8008dc <strlcpy+0x1e>
  8008d2:	eb 1d                	jmp    8008f1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d4:	88 18                	mov    %bl,(%eax)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008dc:	83 ea 01             	sub    $0x1,%edx
  8008df:	74 0b                	je     8008ec <strlcpy+0x2e>
  8008e1:	0f b6 19             	movzbl (%ecx),%ebx
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ec                	jne    8008d4 <strlcpy+0x16>
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	eb 02                	jmp    8008ee <strlcpy+0x30>
  8008ec:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ee:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f1:	29 f0                	sub    %esi,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	eb 06                	jmp    800908 <strcmp+0x11>
		p++, q++;
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800908:	0f b6 01             	movzbl (%ecx),%eax
  80090b:	84 c0                	test   %al,%al
  80090d:	74 04                	je     800913 <strcmp+0x1c>
  80090f:	3a 02                	cmp    (%edx),%al
  800911:	74 ef                	je     800902 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 c0             	movzbl %al,%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800927:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80092a:	eb 09                	jmp    800935 <strncmp+0x18>
		n--, p++, q++;
  80092c:	83 ea 01             	sub    $0x1,%edx
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800935:	85 d2                	test   %edx,%edx
  800937:	74 15                	je     80094e <strncmp+0x31>
  800939:	0f b6 18             	movzbl (%eax),%ebx
  80093c:	84 db                	test   %bl,%bl
  80093e:	74 04                	je     800944 <strncmp+0x27>
  800940:	3a 19                	cmp    (%ecx),%bl
  800942:	74 e8                	je     80092c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	0f b6 00             	movzbl (%eax),%eax
  800947:	0f b6 11             	movzbl (%ecx),%edx
  80094a:	29 d0                	sub    %edx,%eax
  80094c:	eb 05                	jmp    800953 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800960:	eb 07                	jmp    800969 <strchr+0x13>
		if (*s == c)
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 0f                	je     800975 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	0f b6 10             	movzbl (%eax),%edx
  80096c:	84 d2                	test   %dl,%dl
  80096e:	75 f2                	jne    800962 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800981:	eb 07                	jmp    80098a <strfind+0x13>
		if (*s == c)
  800983:	38 ca                	cmp    %cl,%dl
  800985:	74 0a                	je     800991 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	0f b6 10             	movzbl (%eax),%edx
  80098d:	84 d2                	test   %dl,%dl
  80098f:	75 f2                	jne    800983 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 0c             	sub    $0xc,%esp
  800999:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80099c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80099f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 30                	je     8009df <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b5:	75 25                	jne    8009dc <memset+0x49>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 20                	jne    8009dc <memset+0x49>
		c &= 0xFF;
  8009bc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	c1 e6 18             	shl    $0x18,%esi
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 10             	shl    $0x10,%eax
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 d0                	or     %edx,%eax
  8009d2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d7:	fc                   	cld    
  8009d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009da:	eb 03                	jmp    8009df <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009dc:	fc                   	cld    
  8009dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009e4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009e7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009ea:	89 ec                	mov    %ebp,%esp
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 08             	sub    $0x8,%esp
  8009f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a03:	39 c6                	cmp    %eax,%esi
  800a05:	73 36                	jae    800a3d <memmove+0x4f>
  800a07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	73 2f                	jae    800a3d <memmove+0x4f>
		s += n;
		d += n;
  800a0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a11:	f6 c2 03             	test   $0x3,%dl
  800a14:	75 1b                	jne    800a31 <memmove+0x43>
  800a16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1c:	75 13                	jne    800a31 <memmove+0x43>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 0e                	jne    800a31 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a23:	83 ef 04             	sub    $0x4,%edi
  800a26:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a29:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2f:	eb 09                	jmp    800a3a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a31:	83 ef 01             	sub    $0x1,%edi
  800a34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a37:	fd                   	std    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3a:	fc                   	cld    
  800a3b:	eb 20                	jmp    800a5d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 13                	jne    800a58 <memmove+0x6a>
  800a45:	a8 03                	test   $0x3,%al
  800a47:	75 0f                	jne    800a58 <memmove+0x6a>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 0a                	jne    800a58 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 05                	jmp    800a5d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a63:	89 ec                	mov    %ebp,%esp
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	e8 68 ff ff ff       	call   8009ee <memmove>
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	eb 1a                	jmp    800ab8 <memcmp+0x30>
		if (*s1 != *s2)
  800a9e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800aa2:	83 c2 01             	add    $0x1,%edx
  800aa5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800aaa:	38 c8                	cmp    %cl,%al
  800aac:	74 0a                	je     800ab8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800aae:	0f b6 c0             	movzbl %al,%eax
  800ab1:	0f b6 c9             	movzbl %cl,%ecx
  800ab4:	29 c8                	sub    %ecx,%eax
  800ab6:	eb 09                	jmp    800ac1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab8:	39 da                	cmp    %ebx,%edx
  800aba:	75 e2                	jne    800a9e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
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
  800aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800af4:	0f b6 02             	movzbl (%edx),%eax
  800af7:	3c 20                	cmp    $0x20,%al
  800af9:	74 f6                	je     800af1 <strtol+0xe>
  800afb:	3c 09                	cmp    $0x9,%al
  800afd:	74 f2                	je     800af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aff:	3c 2b                	cmp    $0x2b,%al
  800b01:	75 0a                	jne    800b0d <strtol+0x2a>
		s++;
  800b03:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b06:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0b:	eb 10                	jmp    800b1d <strtol+0x3a>
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b12:	3c 2d                	cmp    $0x2d,%al
  800b14:	75 07                	jne    800b1d <strtol+0x3a>
		s++, neg = 1;
  800b16:	8d 52 01             	lea    0x1(%edx),%edx
  800b19:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	0f 94 c0             	sete   %al
  800b22:	74 05                	je     800b29 <strtol+0x46>
  800b24:	83 fb 10             	cmp    $0x10,%ebx
  800b27:	75 15                	jne    800b3e <strtol+0x5b>
  800b29:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2c:	75 10                	jne    800b3e <strtol+0x5b>
  800b2e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b32:	75 0a                	jne    800b3e <strtol+0x5b>
		s += 2, base = 16;
  800b34:	83 c2 02             	add    $0x2,%edx
  800b37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3c:	eb 13                	jmp    800b51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b3e:	84 c0                	test   %al,%al
  800b40:	74 0f                	je     800b51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b47:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4a:	75 05                	jne    800b51 <strtol+0x6e>
		s++, base = 8;
  800b4c:	83 c2 01             	add    $0x1,%edx
  800b4f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b58:	0f b6 0a             	movzbl (%edx),%ecx
  800b5b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5e:	80 fb 09             	cmp    $0x9,%bl
  800b61:	77 08                	ja     800b6b <strtol+0x88>
			dig = *s - '0';
  800b63:	0f be c9             	movsbl %cl,%ecx
  800b66:	83 e9 30             	sub    $0x30,%ecx
  800b69:	eb 1e                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b6b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 08                	ja     800b7b <strtol+0x98>
			dig = *s - 'a' + 10;
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 57             	sub    $0x57,%ecx
  800b79:	eb 0e                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b7b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7e:	80 fb 19             	cmp    $0x19,%bl
  800b81:	77 14                	ja     800b97 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b89:	39 f1                	cmp    %esi,%ecx
  800b8b:	7d 0e                	jge    800b9b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800b8d:	83 c2 01             	add    $0x1,%edx
  800b90:	0f af c6             	imul   %esi,%eax
  800b93:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b95:	eb c1                	jmp    800b58 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b97:	89 c1                	mov    %eax,%ecx
  800b99:	eb 02                	jmp    800b9d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba1:	74 05                	je     800ba8 <strtol+0xc5>
		*endptr = (char *) s;
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba8:	89 ca                	mov    %ecx,%edx
  800baa:	f7 da                	neg    %edx
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 45 c2             	cmovne %edx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
  800bb6:	66 90                	xchg   %ax,%ax

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bc1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bc4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	89 c3                	mov    %eax,%ebx
  800bd4:	89 c7                	mov    %eax,%edi
  800bd6:	89 c6                	mov    %eax,%esi
  800bd8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800be0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800be3:	89 ec                	mov    %ebp,%esp
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	89 d1                	mov    %edx,%ecx
  800c02:	89 d3                	mov    %edx,%ebx
  800c04:	89 d7                	mov    %edx,%edi
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c13:	89 ec                	mov    %ebp,%esp
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 38             	sub    $0x38,%esp
  800c1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 28                	jle    800c67 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c43:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800c52:	00 
  800c53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5a:	00 
  800c5b:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800c62:	e8 e1 f4 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c70:	89 ec                	mov    %ebp,%esp
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c7d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c80:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca0:	89 ec                	mov    %ebp,%esp
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbd:	89 d1                	mov    %edx,%ecx
  800cbf:	89 d3                	mov    %edx,%ebx
  800cc1:	89 d7                	mov    %edx,%edi
  800cc3:	89 d6                	mov    %edx,%esi
  800cc5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ccd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd0:	89 ec                	mov    %ebp,%esp
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 38             	sub    $0x38,%esp
  800cda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cdd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	be 00 00 00 00       	mov    $0x0,%esi
  800ce8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 f7                	mov    %esi,%edi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800d21:	e8 22 f4 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2f:	89 ec                	mov    %ebp,%esp
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 38             	sub    $0x38,%esp
  800d39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 05 00 00 00       	mov    $0x5,%eax
  800d47:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800d7f:	e8 c4 f3 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8d:	89 ec                	mov    %ebp,%esp
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 38             	sub    $0x38,%esp
  800d97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 06 00 00 00       	mov    $0x6,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 28                	jle    800de2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800dcd:	00 
  800dce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd5:	00 
  800dd6:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800ddd:	e8 66 f3 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 38             	sub    $0x38,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	b8 08 00 00 00       	mov    $0x8,%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 28                	jle    800e40 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e23:	00 
  800e24:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800e3b:	e8 08 f3 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e49:	89 ec                	mov    %ebp,%esp
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 38             	sub    $0x38,%esp
  800e53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e59:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	b8 09 00 00 00       	mov    $0x9,%eax
  800e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800e99:	e8 aa f2 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea7:	89 ec                	mov    %ebp,%esp
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	be 00 00 00 00       	mov    $0x0,%esi
  800ebf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edb:	89 ec                	mov    %ebp,%esp
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 38             	sub    $0x38,%esp
  800ee5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eeb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	89 cb                	mov    %ecx,%ebx
  800efd:	89 cf                	mov    %ecx,%edi
  800eff:	89 ce                	mov    %ecx,%esi
  800f01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	7e 28                	jle    800f2f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 a8 15 80 	movl   $0x8015a8,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 c5 15 80 00 	movl   $0x8015c5,(%esp)
  800f2a:	e8 19 f2 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f38:	89 ec                	mov    %ebp,%esp
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f42:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f49:	75 44                	jne    800f8f <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  800f4b:	a1 04 20 80 00       	mov    0x802004,%eax
  800f50:	8b 40 48             	mov    0x48(%eax),%eax
  800f53:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f62:	ee 
  800f63:	89 04 24             	mov    %eax,(%esp)
  800f66:	e8 69 fd ff ff       	call   800cd4 <sys_page_alloc>
		if( r < 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	79 20                	jns    800f8f <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  800f6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f73:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 30 16 80 00 	movl   $0x801630,(%esp)
  800f8a:	e8 b9 f1 ff ff       	call   800148 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  800f97:	e8 d8 fc ff ff       	call   800c74 <sys_getenvid>
  800f9c:	c7 44 24 04 d4 0f 80 	movl   $0x800fd4,0x4(%esp)
  800fa3:	00 
  800fa4:	89 04 24             	mov    %eax,(%esp)
  800fa7:	e8 a1 fe ff ff       	call   800e4d <sys_env_set_pgfault_upcall>
  800fac:	85 c0                	test   %eax,%eax
  800fae:	79 20                	jns    800fd0 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  800fb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb4:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fc3:	00 
  800fc4:	c7 04 24 30 16 80 00 	movl   $0x801630,(%esp)
  800fcb:	e8 78 f1 ff ff       	call   800148 <_panic>


}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    
  800fd2:	66 90                	xchg   %ax,%ax

00800fd4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fd4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fd5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fda:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fdc:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  800fdf:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  800fe3:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  800fe7:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  800feb:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  800fee:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  800ff1:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  800ff4:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  800ff8:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  800ffc:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  801000:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801004:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801008:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  80100c:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  801010:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  801011:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801012:	c3                   	ret    
  801013:	66 90                	xchg   %ax,%ax
  801015:	66 90                	xchg   %ax,%ax
  801017:	66 90                	xchg   %ax,%ax
  801019:	66 90                	xchg   %ax,%ax
  80101b:	66 90                	xchg   %ax,%ax
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <__udivdi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	8b 44 24 28          	mov    0x28(%esp),%eax
  80102a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80102e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801032:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801036:	85 c0                	test   %eax,%eax
  801038:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80103c:	89 ea                	mov    %ebp,%edx
  80103e:	89 0c 24             	mov    %ecx,(%esp)
  801041:	75 2d                	jne    801070 <__udivdi3+0x50>
  801043:	39 e9                	cmp    %ebp,%ecx
  801045:	77 61                	ja     8010a8 <__udivdi3+0x88>
  801047:	85 c9                	test   %ecx,%ecx
  801049:	89 ce                	mov    %ecx,%esi
  80104b:	75 0b                	jne    801058 <__udivdi3+0x38>
  80104d:	b8 01 00 00 00       	mov    $0x1,%eax
  801052:	31 d2                	xor    %edx,%edx
  801054:	f7 f1                	div    %ecx
  801056:	89 c6                	mov    %eax,%esi
  801058:	31 d2                	xor    %edx,%edx
  80105a:	89 e8                	mov    %ebp,%eax
  80105c:	f7 f6                	div    %esi
  80105e:	89 c5                	mov    %eax,%ebp
  801060:	89 f8                	mov    %edi,%eax
  801062:	f7 f6                	div    %esi
  801064:	89 ea                	mov    %ebp,%edx
  801066:	83 c4 0c             	add    $0xc,%esp
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	39 e8                	cmp    %ebp,%eax
  801072:	77 24                	ja     801098 <__udivdi3+0x78>
  801074:	0f bd e8             	bsr    %eax,%ebp
  801077:	83 f5 1f             	xor    $0x1f,%ebp
  80107a:	75 3c                	jne    8010b8 <__udivdi3+0x98>
  80107c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801080:	39 34 24             	cmp    %esi,(%esp)
  801083:	0f 86 9f 00 00 00    	jbe    801128 <__udivdi3+0x108>
  801089:	39 d0                	cmp    %edx,%eax
  80108b:	0f 82 97 00 00 00    	jb     801128 <__udivdi3+0x108>
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	31 d2                	xor    %edx,%edx
  80109a:	31 c0                	xor    %eax,%eax
  80109c:	83 c4 0c             	add    $0xc,%esp
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    
  8010a3:	90                   	nop
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	f7 f1                	div    %ecx
  8010ac:	31 d2                	xor    %edx,%edx
  8010ae:	83 c4 0c             	add    $0xc,%esp
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
  8010b5:	8d 76 00             	lea    0x0(%esi),%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	8b 3c 24             	mov    (%esp),%edi
  8010bd:	d3 e0                	shl    %cl,%eax
  8010bf:	89 c6                	mov    %eax,%esi
  8010c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010c6:	29 e8                	sub    %ebp,%eax
  8010c8:	89 c1                	mov    %eax,%ecx
  8010ca:	d3 ef                	shr    %cl,%edi
  8010cc:	89 e9                	mov    %ebp,%ecx
  8010ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010d2:	8b 3c 24             	mov    (%esp),%edi
  8010d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010d9:	89 d6                	mov    %edx,%esi
  8010db:	d3 e7                	shl    %cl,%edi
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	89 3c 24             	mov    %edi,(%esp)
  8010e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010e6:	d3 ee                	shr    %cl,%esi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	d3 e2                	shl    %cl,%edx
  8010ec:	89 c1                	mov    %eax,%ecx
  8010ee:	d3 ef                	shr    %cl,%edi
  8010f0:	09 d7                	or     %edx,%edi
  8010f2:	89 f2                	mov    %esi,%edx
  8010f4:	89 f8                	mov    %edi,%eax
  8010f6:	f7 74 24 08          	divl   0x8(%esp)
  8010fa:	89 d6                	mov    %edx,%esi
  8010fc:	89 c7                	mov    %eax,%edi
  8010fe:	f7 24 24             	mull   (%esp)
  801101:	39 d6                	cmp    %edx,%esi
  801103:	89 14 24             	mov    %edx,(%esp)
  801106:	72 30                	jb     801138 <__udivdi3+0x118>
  801108:	8b 54 24 04          	mov    0x4(%esp),%edx
  80110c:	89 e9                	mov    %ebp,%ecx
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	39 c2                	cmp    %eax,%edx
  801112:	73 05                	jae    801119 <__udivdi3+0xf9>
  801114:	3b 34 24             	cmp    (%esp),%esi
  801117:	74 1f                	je     801138 <__udivdi3+0x118>
  801119:	89 f8                	mov    %edi,%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	e9 7a ff ff ff       	jmp    80109c <__udivdi3+0x7c>
  801122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801128:	31 d2                	xor    %edx,%edx
  80112a:	b8 01 00 00 00       	mov    $0x1,%eax
  80112f:	e9 68 ff ff ff       	jmp    80109c <__udivdi3+0x7c>
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	8d 47 ff             	lea    -0x1(%edi),%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	83 c4 0c             	add    $0xc,%esp
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    
  801144:	66 90                	xchg   %ax,%ax
  801146:	66 90                	xchg   %ax,%ax
  801148:	66 90                	xchg   %ax,%ax
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__umoddi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	83 ec 14             	sub    $0x14,%esp
  801156:	8b 44 24 28          	mov    0x28(%esp),%eax
  80115a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80115e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801162:	89 c7                	mov    %eax,%edi
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	8b 44 24 30          	mov    0x30(%esp),%eax
  80116c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801170:	89 34 24             	mov    %esi,(%esp)
  801173:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801177:	85 c0                	test   %eax,%eax
  801179:	89 c2                	mov    %eax,%edx
  80117b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80117f:	75 17                	jne    801198 <__umoddi3+0x48>
  801181:	39 fe                	cmp    %edi,%esi
  801183:	76 4b                	jbe    8011d0 <__umoddi3+0x80>
  801185:	89 c8                	mov    %ecx,%eax
  801187:	89 fa                	mov    %edi,%edx
  801189:	f7 f6                	div    %esi
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	31 d2                	xor    %edx,%edx
  80118f:	83 c4 14             	add    $0x14,%esp
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	66 90                	xchg   %ax,%ax
  801198:	39 f8                	cmp    %edi,%eax
  80119a:	77 54                	ja     8011f0 <__umoddi3+0xa0>
  80119c:	0f bd e8             	bsr    %eax,%ebp
  80119f:	83 f5 1f             	xor    $0x1f,%ebp
  8011a2:	75 5c                	jne    801200 <__umoddi3+0xb0>
  8011a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011a8:	39 3c 24             	cmp    %edi,(%esp)
  8011ab:	0f 87 e7 00 00 00    	ja     801298 <__umoddi3+0x148>
  8011b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011b5:	29 f1                	sub    %esi,%ecx
  8011b7:	19 c7                	sbb    %eax,%edi
  8011b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    
  8011d0:	85 f6                	test   %esi,%esi
  8011d2:	89 f5                	mov    %esi,%ebp
  8011d4:	75 0b                	jne    8011e1 <__umoddi3+0x91>
  8011d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f6                	div    %esi
  8011df:	89 c5                	mov    %eax,%ebp
  8011e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011e5:	31 d2                	xor    %edx,%edx
  8011e7:	f7 f5                	div    %ebp
  8011e9:	89 c8                	mov    %ecx,%eax
  8011eb:	f7 f5                	div    %ebp
  8011ed:	eb 9c                	jmp    80118b <__umoddi3+0x3b>
  8011ef:	90                   	nop
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 fa                	mov    %edi,%edx
  8011f4:	83 c4 14             	add    $0x14,%esp
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    
  8011fb:	90                   	nop
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	8b 04 24             	mov    (%esp),%eax
  801203:	be 20 00 00 00       	mov    $0x20,%esi
  801208:	89 e9                	mov    %ebp,%ecx
  80120a:	29 ee                	sub    %ebp,%esi
  80120c:	d3 e2                	shl    %cl,%edx
  80120e:	89 f1                	mov    %esi,%ecx
  801210:	d3 e8                	shr    %cl,%eax
  801212:	89 e9                	mov    %ebp,%ecx
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 04 24             	mov    (%esp),%eax
  80121b:	09 54 24 04          	or     %edx,0x4(%esp)
  80121f:	89 fa                	mov    %edi,%edx
  801221:	d3 e0                	shl    %cl,%eax
  801223:	89 f1                	mov    %esi,%ecx
  801225:	89 44 24 08          	mov    %eax,0x8(%esp)
  801229:	8b 44 24 10          	mov    0x10(%esp),%eax
  80122d:	d3 ea                	shr    %cl,%edx
  80122f:	89 e9                	mov    %ebp,%ecx
  801231:	d3 e7                	shl    %cl,%edi
  801233:	89 f1                	mov    %esi,%ecx
  801235:	d3 e8                	shr    %cl,%eax
  801237:	89 e9                	mov    %ebp,%ecx
  801239:	09 f8                	or     %edi,%eax
  80123b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80123f:	f7 74 24 04          	divl   0x4(%esp)
  801243:	d3 e7                	shl    %cl,%edi
  801245:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801249:	89 d7                	mov    %edx,%edi
  80124b:	f7 64 24 08          	mull   0x8(%esp)
  80124f:	39 d7                	cmp    %edx,%edi
  801251:	89 c1                	mov    %eax,%ecx
  801253:	89 14 24             	mov    %edx,(%esp)
  801256:	72 2c                	jb     801284 <__umoddi3+0x134>
  801258:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80125c:	72 22                	jb     801280 <__umoddi3+0x130>
  80125e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801262:	29 c8                	sub    %ecx,%eax
  801264:	19 d7                	sbb    %edx,%edi
  801266:	89 e9                	mov    %ebp,%ecx
  801268:	89 fa                	mov    %edi,%edx
  80126a:	d3 e8                	shr    %cl,%eax
  80126c:	89 f1                	mov    %esi,%ecx
  80126e:	d3 e2                	shl    %cl,%edx
  801270:	89 e9                	mov    %ebp,%ecx
  801272:	d3 ef                	shr    %cl,%edi
  801274:	09 d0                	or     %edx,%eax
  801276:	89 fa                	mov    %edi,%edx
  801278:	83 c4 14             	add    $0x14,%esp
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    
  80127f:	90                   	nop
  801280:	39 d7                	cmp    %edx,%edi
  801282:	75 da                	jne    80125e <__umoddi3+0x10e>
  801284:	8b 14 24             	mov    (%esp),%edx
  801287:	89 c1                	mov    %eax,%ecx
  801289:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80128d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801291:	eb cb                	jmp    80125e <__umoddi3+0x10e>
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80129c:	0f 82 0f ff ff ff    	jb     8011b1 <__umoddi3+0x61>
  8012a2:	e9 1a ff ff ff       	jmp    8011c1 <__umoddi3+0x71>
