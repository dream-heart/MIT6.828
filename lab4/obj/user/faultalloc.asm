
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

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
  800044:	c7 04 24 00 13 80 00 	movl   $0x801300,(%esp)
  80004b:	e8 07 02 00 00       	call   800257 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 85 0c 00 00       	call   800cf4 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 20 13 80 	movl   $0x801320,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 0a 13 80 00 	movl   $0x80130a,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 4c 13 80 	movl   $0x80134c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 52 07 00 00       	call   800805 <snprintf>
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
  8000c6:	e8 91 0e 00 00       	call   800f5c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 1c 13 80 00 	movl   $0x80131c,(%esp)
  8000da:	e8 78 01 00 00       	call   800257 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 1c 13 80 00 	movl   $0x80131c,(%esp)
  8000ee:	e8 64 01 00 00       	call   800257 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80010a:	e8 85 0b 00 00       	call   800c94 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 dd 0a 00 00       	call   800c37 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 22 0b 00 00       	call   800c94 <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  80018f:	e8 c3 00 00 00       	call   800257 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 53 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 1e 13 80 00 	movl   $0x80131e,(%esp)
  8001aa:	e8 a8 00 00 00       	call   800257 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 14             	sub    $0x14,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 03                	mov    (%ebx),%eax
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c7:	83 c0 01             	add    $0x1,%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 19                	jne    8001ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001da:	00 
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 f2 09 00 00       	call   800bd8 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f0:	83 c4 14             	add    $0x14,%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800221:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	c7 04 24 b4 01 80 00 	movl   $0x8001b4,(%esp)
  800232:	e8 96 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 89 09 00 00       	call   800bd8 <sys_cputs>

	return b.cnt;
}
  80024f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 87 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	75 08                	jne    8002ac <printnum+0x2c>
  8002a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002aa:	77 59                	ja     800305 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cd:	00 
  8002ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d1:	89 04 24             	mov    %eax,(%esp)
  8002d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002db:	e8 60 0d 00 00       	call   801040 <__udivdi3>
  8002e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ef:	89 fa                	mov    %edi,%edx
  8002f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f4:	e8 87 ff ff ff       	call   800280 <printnum>
  8002f9:	eb 11                	jmp    80030c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ff:	89 34 24             	mov    %esi,(%esp)
  800302:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800305:	83 eb 01             	sub    $0x1,%ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f ef                	jg     8002fb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 3b 0e 00 00       	call   801170 <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 9b 13 80 00 	movsbl 0x80139b(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800392:	8b 10                	mov    (%eax),%edx
  800394:	3b 50 04             	cmp    0x4(%eax),%edx
  800397:	73 0a                	jae    8003a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  800399:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039c:	88 0a                	mov    %cl,(%edx)
  80039e:	83 c2 01             	add    $0x1,%edx
  8003a1:	89 10                	mov    %edx,(%eax)
}
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	e8 02 00 00 00       	call   8003cd <vprintfmt>
	va_end(ap);
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 4c             	sub    $0x4c,%esp
  8003d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003dc:	eb 12                	jmp    8003f0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	0f 84 bf 03 00 00    	je     8007a5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8003e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f0:	0f b6 06             	movzbl (%esi),%eax
  8003f3:	83 c6 01             	add    $0x1,%esi
  8003f6:	83 f8 25             	cmp    $0x25,%eax
  8003f9:	75 e3                	jne    8003de <vprintfmt+0x11>
  8003fb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ff:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800406:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041a:	eb 2b                	jmp    800447 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800423:	eb 22                	jmp    800447 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 19                	jmp    800447 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800438:	eb 0d                	jmp    800447 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80043d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800440:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	0f b6 16             	movzbl (%esi),%edx
  80044a:	0f b6 c2             	movzbl %dl,%eax
  80044d:	8d 7e 01             	lea    0x1(%esi),%edi
  800450:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800453:	83 ea 23             	sub    $0x23,%edx
  800456:	80 fa 55             	cmp    $0x55,%dl
  800459:	0f 87 28 03 00 00    	ja     800787 <vprintfmt+0x3ba>
  80045f:	0f b6 d2             	movzbl %dl,%edx
  800462:	ff 24 95 60 14 80 00 	jmp    *0x801460(,%edx,4)
  800469:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800473:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800478:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80047b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80047f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800482:	8d 50 d0             	lea    -0x30(%eax),%edx
  800485:	83 fa 09             	cmp    $0x9,%edx
  800488:	77 2f                	ja     8004b9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048d:	eb e9                	jmp    800478 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a0:	eb 1a                	jmp    8004bc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a9:	79 9c                	jns    800447 <vprintfmt+0x7a>
  8004ab:	eb 81                	jmp    80042e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004b7:	eb 8e                	jmp    800447 <vprintfmt+0x7a>
  8004b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c0:	79 85                	jns    800447 <vprintfmt+0x7a>
  8004c2:	e9 73 ff ff ff       	jmp    80043a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004cd:	e9 75 ff ff ff       	jmp    800447 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 04 24             	mov    %eax,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ea:	e9 01 ff ff ff       	jmp    8003f0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	89 c2                	mov    %eax,%edx
  8004fc:	c1 fa 1f             	sar    $0x1f,%edx
  8004ff:	31 d0                	xor    %edx,%eax
  800501:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800503:	83 f8 09             	cmp    $0x9,%eax
  800506:	7f 0b                	jg     800513 <vprintfmt+0x146>
  800508:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	75 23                	jne    800536 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800513:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800517:	c7 44 24 08 b3 13 80 	movl   $0x8013b3,0x8(%esp)
  80051e:	00 
  80051f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800523:	8b 7d 08             	mov    0x8(%ebp),%edi
  800526:	89 3c 24             	mov    %edi,(%esp)
  800529:	e8 77 fe ff ff       	call   8003a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800531:	e9 ba fe ff ff       	jmp    8003f0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800536:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053a:	c7 44 24 08 bc 13 80 	movl   $0x8013bc,0x8(%esp)
  800541:	00 
  800542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800546:	8b 7d 08             	mov    0x8(%ebp),%edi
  800549:	89 3c 24             	mov    %edi,(%esp)
  80054c:	e8 54 fe ff ff       	call   8003a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800554:	e9 97 fe ff ff       	jmp    8003f0 <vprintfmt+0x23>
  800559:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80056d:	85 f6                	test   %esi,%esi
  80056f:	ba ac 13 80 00       	mov    $0x8013ac,%edx
  800574:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800577:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057b:	0f 8e 8c 00 00 00    	jle    80060d <vprintfmt+0x240>
  800581:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800585:	0f 84 82 00 00 00    	je     80060d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058f:	89 34 24             	mov    %esi,(%esp)
  800592:	e8 b1 02 00 00       	call   800848 <strnlen>
  800597:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80059a:	29 c2                	sub    %eax,%edx
  80059c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80059f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005a9:	89 de                	mov    %ebx,%esi
  8005ab:	89 d3                	mov    %edx,%ebx
  8005ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	eb 0d                	jmp    8005be <vprintfmt+0x1f1>
					putch(padc, putdat);
  8005b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b5:	89 3c 24             	mov    %edi,(%esp)
  8005b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	85 db                	test   %ebx,%ebx
  8005c0:	7f ef                	jg     8005b1 <vprintfmt+0x1e4>
  8005c2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005c5:	89 f3                	mov    %esi,%ebx
  8005c7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8005d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005da:	29 c2                	sub    %eax,%edx
  8005dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005df:	eb 2c                	jmp    80060d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e5:	74 18                	je     8005ff <vprintfmt+0x232>
  8005e7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ea:	83 fa 5e             	cmp    $0x5e,%edx
  8005ed:	76 10                	jbe    8005ff <vprintfmt+0x232>
					putch('?', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
  8005fd:	eb 0a                	jmp    800609 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80060d:	0f be 06             	movsbl (%esi),%eax
  800610:	83 c6 01             	add    $0x1,%esi
  800613:	85 c0                	test   %eax,%eax
  800615:	74 25                	je     80063c <vprintfmt+0x26f>
  800617:	85 ff                	test   %edi,%edi
  800619:	78 c6                	js     8005e1 <vprintfmt+0x214>
  80061b:	83 ef 01             	sub    $0x1,%edi
  80061e:	79 c1                	jns    8005e1 <vprintfmt+0x214>
  800620:	8b 7d 08             	mov    0x8(%ebp),%edi
  800623:	89 de                	mov    %ebx,%esi
  800625:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800628:	eb 1a                	jmp    800644 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800635:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	83 eb 01             	sub    $0x1,%ebx
  80063a:	eb 08                	jmp    800644 <vprintfmt+0x277>
  80063c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80063f:	89 de                	mov    %ebx,%esi
  800641:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f e2                	jg     80062a <vprintfmt+0x25d>
  800648:	89 7d 08             	mov    %edi,0x8(%ebp)
  80064b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800650:	e9 9b fd ff ff       	jmp    8003f0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800655:	83 f9 01             	cmp    $0x1,%ecx
  800658:	7e 10                	jle    80066a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 08             	lea    0x8(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 30                	mov    (%eax),%esi
  800665:	8b 78 04             	mov    0x4(%eax),%edi
  800668:	eb 26                	jmp    800690 <vprintfmt+0x2c3>
	else if (lflag)
  80066a:	85 c9                	test   %ecx,%ecx
  80066c:	74 12                	je     800680 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)
  800677:	8b 30                	mov    (%eax),%esi
  800679:	89 f7                	mov    %esi,%edi
  80067b:	c1 ff 1f             	sar    $0x1f,%edi
  80067e:	eb 10                	jmp    800690 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	89 f7                	mov    %esi,%edi
  80068d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800690:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800695:	85 ff                	test   %edi,%edi
  800697:	0f 89 ac 00 00 00    	jns    800749 <vprintfmt+0x37c>
				putch('-', putdat);
  80069d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ab:	f7 de                	neg    %esi
  8006ad:	83 d7 00             	adc    $0x0,%edi
  8006b0:	f7 df                	neg    %edi
			}
			base = 10;
  8006b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b7:	e9 8d 00 00 00       	jmp    800749 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006bc:	89 ca                	mov    %ecx,%edx
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	e8 88 fc ff ff       	call   80034e <getuint>
  8006c6:	89 c6                	mov    %eax,%esi
  8006c8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006cf:	eb 78                	jmp    800749 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006dc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ea:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006fe:	e9 ed fc ff ff       	jmp    8003f0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800707:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800728:	8b 30                	mov    (%eax),%esi
  80072a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800734:	eb 13                	jmp    800749 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800736:	89 ca                	mov    %ecx,%edx
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 0e fc ff ff       	call   80034e <getuint>
  800740:	89 c6                	mov    %eax,%esi
  800742:	89 d7                	mov    %edx,%edi
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800749:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80074d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800751:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800754:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800758:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075c:	89 34 24             	mov    %esi,(%esp)
  80075f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800763:	89 da                	mov    %ebx,%edx
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	e8 13 fb ff ff       	call   800280 <printnum>
			break;
  80076d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800770:	e9 7b fc ff ff       	jmp    8003f0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	89 04 24             	mov    %eax,(%esp)
  80077c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800782:	e9 69 fc ff ff       	jmp    8003f0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800792:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800795:	eb 03                	jmp    80079a <vprintfmt+0x3cd>
  800797:	83 ee 01             	sub    $0x1,%esi
  80079a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079e:	75 f7                	jne    800797 <vprintfmt+0x3ca>
  8007a0:	e9 4b fc ff ff       	jmp    8003f0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007a5:	83 c4 4c             	add    $0x4c,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5f                   	pop    %edi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 28             	sub    $0x28,%esp
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	74 30                	je     8007fe <vsnprintf+0x51>
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	7e 2c                	jle    8007fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  8007ee:	e8 da fb ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fc:	eb 05                	jmp    800803 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800812:	8b 45 10             	mov    0x10(%ebp),%eax
  800815:	89 44 24 08          	mov    %eax,0x8(%esp)
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 82 ff ff ff       	call   8007ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    
  80082d:	00 00                	add    %al,(%eax)
	...

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
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
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
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	ba 00 00 00 00       	mov    $0x0,%edx
  800876:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	84 c9                	test   %cl,%cl
  800882:	75 f2                	jne    800876 <strcpy+0xf>
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
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c5:	eb 0f                	jmp    8008d6 <strncpy+0x24>
		*dst++ = *src;
  8008c7:	0f b6 1a             	movzbl (%edx),%ebx
  8008ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d3:	83 c1 01             	add    $0x1,%ecx
  8008d6:	39 f1                	cmp    %esi,%ecx
  8008d8:	75 ed                	jne    8008c7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ec:	89 f0                	mov    %esi,%eax
  8008ee:	85 d2                	test   %edx,%edx
  8008f0:	75 0a                	jne    8008fc <strlcpy+0x1e>
  8008f2:	eb 1d                	jmp    800911 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f4:	88 18                	mov    %bl,(%eax)
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fc:	83 ea 01             	sub    $0x1,%edx
  8008ff:	74 0b                	je     80090c <strlcpy+0x2e>
  800901:	0f b6 19             	movzbl (%ecx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	75 ec                	jne    8008f4 <strlcpy+0x16>
  800908:	89 c2                	mov    %eax,%edx
  80090a:	eb 02                	jmp    80090e <strlcpy+0x30>
  80090c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80090e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800911:	29 f0                	sub    %esi,%eax
}
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800920:	eb 06                	jmp    800928 <strcmp+0x11>
		p++, q++;
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800928:	0f b6 01             	movzbl (%ecx),%eax
  80092b:	84 c0                	test   %al,%al
  80092d:	74 04                	je     800933 <strcmp+0x1c>
  80092f:	3a 02                	cmp    (%edx),%al
  800931:	74 ef                	je     800922 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800933:	0f b6 c0             	movzbl %al,%eax
  800936:	0f b6 12             	movzbl (%edx),%edx
  800939:	29 d0                	sub    %edx,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	53                   	push   %ebx
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800947:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80094a:	eb 09                	jmp    800955 <strncmp+0x18>
		n--, p++, q++;
  80094c:	83 ea 01             	sub    $0x1,%edx
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800955:	85 d2                	test   %edx,%edx
  800957:	74 15                	je     80096e <strncmp+0x31>
  800959:	0f b6 18             	movzbl (%eax),%ebx
  80095c:	84 db                	test   %bl,%bl
  80095e:	74 04                	je     800964 <strncmp+0x27>
  800960:	3a 19                	cmp    (%ecx),%bl
  800962:	74 e8                	je     80094c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800964:	0f b6 00             	movzbl (%eax),%eax
  800967:	0f b6 11             	movzbl (%ecx),%edx
  80096a:	29 d0                	sub    %edx,%eax
  80096c:	eb 05                	jmp    800973 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	eb 07                	jmp    800989 <strchr+0x13>
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 0f                	je     800995 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a1:	eb 07                	jmp    8009aa <strfind+0x13>
		if (*s == c)
  8009a3:	38 ca                	cmp    %cl,%dl
  8009a5:	74 0a                	je     8009b1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	0f b6 10             	movzbl (%eax),%edx
  8009ad:	84 d2                	test   %dl,%dl
  8009af:	75 f2                	jne    8009a3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	83 ec 0c             	sub    $0xc,%esp
  8009b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cb:	85 c9                	test   %ecx,%ecx
  8009cd:	74 30                	je     8009ff <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d5:	75 25                	jne    8009fc <memset+0x49>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 20                	jne    8009fc <memset+0x49>
		c &= 0xFF;
  8009dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009df:	89 d3                	mov    %edx,%ebx
  8009e1:	c1 e3 08             	shl    $0x8,%ebx
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	c1 e6 18             	shl    $0x18,%esi
  8009e9:	89 d0                	mov    %edx,%eax
  8009eb:	c1 e0 10             	shl    $0x10,%eax
  8009ee:	09 f0                	or     %esi,%eax
  8009f0:	09 d0                	or     %edx,%eax
  8009f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f7:	fc                   	cld    
  8009f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fa:	eb 03                	jmp    8009ff <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fc:	fc                   	cld    
  8009fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a0a:	89 ec                	mov    %ebp,%esp
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a17:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a23:	39 c6                	cmp    %eax,%esi
  800a25:	73 36                	jae    800a5d <memmove+0x4f>
  800a27:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2a:	39 d0                	cmp    %edx,%eax
  800a2c:	73 2f                	jae    800a5d <memmove+0x4f>
		s += n;
		d += n;
  800a2e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a31:	f6 c2 03             	test   $0x3,%dl
  800a34:	75 1b                	jne    800a51 <memmove+0x43>
  800a36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3c:	75 13                	jne    800a51 <memmove+0x43>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 0e                	jne    800a51 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a43:	83 ef 04             	sub    $0x4,%edi
  800a46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a49:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 09                	jmp    800a5a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a51:	83 ef 01             	sub    $0x1,%edi
  800a54:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a57:	fd                   	std    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5a:	fc                   	cld    
  800a5b:	eb 20                	jmp    800a7d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a63:	75 13                	jne    800a78 <memmove+0x6a>
  800a65:	a8 03                	test   $0x3,%al
  800a67:	75 0f                	jne    800a78 <memmove+0x6a>
  800a69:	f6 c1 03             	test   $0x3,%cl
  800a6c:	75 0a                	jne    800a78 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a76:	eb 05                	jmp    800a7d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a78:	89 c7                	mov    %eax,%edi
  800a7a:	fc                   	cld    
  800a7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a83:	89 ec                	mov    %ebp,%esp
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	e8 68 ff ff ff       	call   800a0e <memmove>
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	ba 00 00 00 00       	mov    $0x0,%edx
  800abc:	eb 1a                	jmp    800ad8 <memcmp+0x30>
		if (*s1 != *s2)
  800abe:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ac2:	83 c2 01             	add    $0x1,%edx
  800ac5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800aca:	38 c8                	cmp    %cl,%al
  800acc:	74 0a                	je     800ad8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800ace:	0f b6 c0             	movzbl %al,%eax
  800ad1:	0f b6 c9             	movzbl %cl,%ecx
  800ad4:	29 c8                	sub    %ecx,%eax
  800ad6:	eb 09                	jmp    800ae1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad8:	39 da                	cmp    %ebx,%edx
  800ada:	75 e2                	jne    800abe <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af4:	eb 07                	jmp    800afd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	38 08                	cmp    %cl,(%eax)
  800af8:	74 07                	je     800b01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	39 d0                	cmp    %edx,%eax
  800aff:	72 f5                	jb     800af6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0f:	eb 03                	jmp    800b14 <strtol+0x11>
		s++;
  800b11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	0f b6 02             	movzbl (%edx),%eax
  800b17:	3c 20                	cmp    $0x20,%al
  800b19:	74 f6                	je     800b11 <strtol+0xe>
  800b1b:	3c 09                	cmp    $0x9,%al
  800b1d:	74 f2                	je     800b11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1f:	3c 2b                	cmp    $0x2b,%al
  800b21:	75 0a                	jne    800b2d <strtol+0x2a>
		s++;
  800b23:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b26:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2b:	eb 10                	jmp    800b3d <strtol+0x3a>
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b32:	3c 2d                	cmp    $0x2d,%al
  800b34:	75 07                	jne    800b3d <strtol+0x3a>
		s++, neg = 1;
  800b36:	8d 52 01             	lea    0x1(%edx),%edx
  800b39:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	0f 94 c0             	sete   %al
  800b42:	74 05                	je     800b49 <strtol+0x46>
  800b44:	83 fb 10             	cmp    $0x10,%ebx
  800b47:	75 15                	jne    800b5e <strtol+0x5b>
  800b49:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4c:	75 10                	jne    800b5e <strtol+0x5b>
  800b4e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b52:	75 0a                	jne    800b5e <strtol+0x5b>
		s += 2, base = 16;
  800b54:	83 c2 02             	add    $0x2,%edx
  800b57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5c:	eb 13                	jmp    800b71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5e:	84 c0                	test   %al,%al
  800b60:	74 0f                	je     800b71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b67:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6a:	75 05                	jne    800b71 <strtol+0x6e>
		s++, base = 8;
  800b6c:	83 c2 01             	add    $0x1,%edx
  800b6f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 0a             	movzbl (%edx),%ecx
  800b7b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b7e:	80 fb 09             	cmp    $0x9,%bl
  800b81:	77 08                	ja     800b8b <strtol+0x88>
			dig = *s - '0';
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 30             	sub    $0x30,%ecx
  800b89:	eb 1e                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b8b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 08                	ja     800b9b <strtol+0x98>
			dig = *s - 'a' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 57             	sub    $0x57,%ecx
  800b99:	eb 0e                	jmp    800ba9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b9b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b9e:	80 fb 19             	cmp    $0x19,%bl
  800ba1:	77 14                	ja     800bb7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ba3:	0f be c9             	movsbl %cl,%ecx
  800ba6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ba9:	39 f1                	cmp    %esi,%ecx
  800bab:	7d 0e                	jge    800bbb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	0f af c6             	imul   %esi,%eax
  800bb3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bb5:	eb c1                	jmp    800b78 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bb7:	89 c1                	mov    %eax,%ecx
  800bb9:	eb 02                	jmp    800bbd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc1:	74 05                	je     800bc8 <strtol+0xc5>
		*endptr = (char *) s;
  800bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bc8:	89 ca                	mov    %ecx,%edx
  800bca:	f7 da                	neg    %edx
  800bcc:	85 ff                	test   %edi,%edi
  800bce:	0f 45 c2             	cmovne %edx,%eax
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    
	...

00800bd8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	89 c3                	mov    %eax,%ebx
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c00:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c03:	89 ec                	mov    %ebp,%esp
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c10:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c13:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c20:	89 d1                	mov    %edx,%ecx
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	89 d7                	mov    %edx,%edi
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c30:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c33:	89 ec                	mov    %ebp,%esp
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 38             	sub    $0x38,%esp
  800c3d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c40:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c43:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 cb                	mov    %ecx,%ebx
  800c55:	89 cf                	mov    %ecx,%edi
  800c57:	89 ce                	mov    %ecx,%esi
  800c59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 28                	jle    800c87 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c63:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800c72:	00 
  800c73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7a:	00 
  800c7b:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800c82:	e8 d5 f4 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c90:	89 ec                	mov    %ebp,%esp
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	b8 02 00 00 00       	mov    $0x2,%eax
  800cad:	89 d1                	mov    %edx,%ecx
  800caf:	89 d3                	mov    %edx,%ebx
  800cb1:	89 d7                	mov    %edx,%edi
  800cb3:	89 d6                	mov    %edx,%esi
  800cb5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc0:	89 ec                	mov    %ebp,%esp
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_yield>:

void
sys_yield(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ccd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	89 d3                	mov    %edx,%ebx
  800ce1:	89 d7                	mov    %edx,%edi
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ced:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf0:	89 ec                	mov    %ebp,%esp
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 38             	sub    $0x38,%esp
  800cfa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cfd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d00:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	be 00 00 00 00       	mov    $0x0,%esi
  800d08:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 f7                	mov    %esi,%edi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 28                	jle    800d46 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d22:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d29:	00 
  800d2a:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800d31:	00 
  800d32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d39:	00 
  800d3a:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800d41:	e8 16 f4 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4f:	89 ec                	mov    %ebp,%esp
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 38             	sub    $0x38,%esp
  800d59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b8 05 00 00 00       	mov    $0x5,%eax
  800d67:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 28                	jle    800da4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d87:	00 
  800d88:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800d8f:	00 
  800d90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d97:	00 
  800d98:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800d9f:	e8 b8 f3 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800daa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dad:	89 ec                	mov    %ebp,%esp
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 38             	sub    $0x38,%esp
  800db7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800dfd:	e8 5a f3 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e02:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e05:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e08:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0b:	89 ec                	mov    %ebp,%esp
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 38             	sub    $0x38,%esp
  800e15:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e18:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	b8 08 00 00 00       	mov    $0x8,%eax
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 28                	jle    800e60 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e43:	00 
  800e44:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e53:	00 
  800e54:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800e5b:	e8 fc f2 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e60:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e63:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e66:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e69:	89 ec                	mov    %ebp,%esp
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	83 ec 38             	sub    $0x38,%esp
  800e73:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e76:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e79:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	b8 09 00 00 00       	mov    $0x9,%eax
  800e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	89 df                	mov    %ebx,%edi
  800e8e:	89 de                	mov    %ebx,%esi
  800e90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	7e 28                	jle    800ebe <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb1:	00 
  800eb2:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800eb9:	e8 9e f2 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ebe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec7:	89 ec                	mov    %ebp,%esp
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	be 00 00 00 00       	mov    $0x0,%esi
  800edf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800efb:	89 ec                	mov    %ebp,%esp
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 38             	sub    $0x38,%esp
  800f05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	89 cb                	mov    %ecx,%ebx
  800f1d:	89 cf                	mov    %ecx,%edi
  800f1f:	89 ce                	mov    %ecx,%esi
  800f21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f23:	85 c0                	test   %eax,%eax
  800f25:	7e 28                	jle    800f4f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f32:	00 
  800f33:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f42:	00 
  800f43:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800f4a:	e8 0d f2 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f58:	89 ec                	mov    %ebp,%esp
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f62:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f69:	75 44                	jne    800faf <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  800f6b:	a1 04 20 80 00       	mov    0x802004,%eax
  800f70:	8b 40 48             	mov    0x48(%eax),%eax
  800f73:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f82:	ee 
  800f83:	89 04 24             	mov    %eax,(%esp)
  800f86:	e8 69 fd ff ff       	call   800cf4 <sys_page_alloc>
		if( r < 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 20                	jns    800faf <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  800f8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f93:	c7 44 24 08 14 16 80 	movl   $0x801614,0x8(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 70 16 80 00 	movl   $0x801670,(%esp)
  800faa:	e8 ad f1 ff ff       	call   80015c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  800fb7:	e8 d8 fc ff ff       	call   800c94 <sys_getenvid>
  800fbc:	c7 44 24 04 f4 0f 80 	movl   $0x800ff4,0x4(%esp)
  800fc3:	00 
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	e8 a1 fe ff ff       	call   800e6d <sys_env_set_pgfault_upcall>
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	79 20                	jns    800ff0 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  800fd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd4:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 70 16 80 00 	movl   $0x801670,(%esp)
  800feb:	e8 6c f1 ff ff       	call   80015c <_panic>


}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    
	...

00800ff4 <_pgfault_upcall>:
  800ff4:	54                   	push   %esp
  800ff5:	a1 08 20 80 00       	mov    0x802008,%eax
  800ffa:	ff d0                	call   *%eax
  800ffc:	83 c4 04             	add    $0x4,%esp
  800fff:	8b 44 24 28          	mov    0x28(%esp),%eax
  801003:	8b 5c 24 10          	mov    0x10(%esp),%ebx
  801007:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80100b:	89 41 fc             	mov    %eax,-0x4(%ecx)
  80100e:	89 59 f8             	mov    %ebx,-0x8(%ecx)
  801011:	8d 69 f8             	lea    -0x8(%ecx),%ebp
  801014:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801018:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80101c:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801020:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801024:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801028:	8b 44 24 24          	mov    0x24(%esp),%eax
  80102c:	8d 64 24 2c          	lea    0x2c(%esp),%esp
  801030:	9d                   	popf   
  801031:	c9                   	leave  
  801032:	c3                   	ret    
	...

00801040 <__udivdi3>:
  801040:	83 ec 1c             	sub    $0x1c,%esp
  801043:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801047:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80104b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80104f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801053:	89 74 24 10          	mov    %esi,0x10(%esp)
  801057:	8b 74 24 24          	mov    0x24(%esp),%esi
  80105b:	85 ff                	test   %edi,%edi
  80105d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801061:	89 44 24 08          	mov    %eax,0x8(%esp)
  801065:	89 cd                	mov    %ecx,%ebp
  801067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106b:	75 33                	jne    8010a0 <__udivdi3+0x60>
  80106d:	39 f1                	cmp    %esi,%ecx
  80106f:	77 57                	ja     8010c8 <__udivdi3+0x88>
  801071:	85 c9                	test   %ecx,%ecx
  801073:	75 0b                	jne    801080 <__udivdi3+0x40>
  801075:	b8 01 00 00 00       	mov    $0x1,%eax
  80107a:	31 d2                	xor    %edx,%edx
  80107c:	f7 f1                	div    %ecx
  80107e:	89 c1                	mov    %eax,%ecx
  801080:	89 f0                	mov    %esi,%eax
  801082:	31 d2                	xor    %edx,%edx
  801084:	f7 f1                	div    %ecx
  801086:	89 c6                	mov    %eax,%esi
  801088:	8b 44 24 04          	mov    0x4(%esp),%eax
  80108c:	f7 f1                	div    %ecx
  80108e:	89 f2                	mov    %esi,%edx
  801090:	8b 74 24 10          	mov    0x10(%esp),%esi
  801094:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801098:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80109c:	83 c4 1c             	add    $0x1c,%esp
  80109f:	c3                   	ret    
  8010a0:	31 d2                	xor    %edx,%edx
  8010a2:	31 c0                	xor    %eax,%eax
  8010a4:	39 f7                	cmp    %esi,%edi
  8010a6:	77 e8                	ja     801090 <__udivdi3+0x50>
  8010a8:	0f bd cf             	bsr    %edi,%ecx
  8010ab:	83 f1 1f             	xor    $0x1f,%ecx
  8010ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010b2:	75 2c                	jne    8010e0 <__udivdi3+0xa0>
  8010b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010b8:	76 04                	jbe    8010be <__udivdi3+0x7e>
  8010ba:	39 f7                	cmp    %esi,%edi
  8010bc:	73 d2                	jae    801090 <__udivdi3+0x50>
  8010be:	31 d2                	xor    %edx,%edx
  8010c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c5:	eb c9                	jmp    801090 <__udivdi3+0x50>
  8010c7:	90                   	nop
  8010c8:	89 f2                	mov    %esi,%edx
  8010ca:	f7 f1                	div    %ecx
  8010cc:	31 d2                	xor    %edx,%edx
  8010ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010da:	83 c4 1c             	add    $0x1c,%esp
  8010dd:	c3                   	ret    
  8010de:	66 90                	xchg   %ax,%ax
  8010e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ea:	89 ea                	mov    %ebp,%edx
  8010ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010f0:	d3 e7                	shl    %cl,%edi
  8010f2:	89 c1                	mov    %eax,%ecx
  8010f4:	d3 ea                	shr    %cl,%edx
  8010f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010fb:	09 fa                	or     %edi,%edx
  8010fd:	89 f7                	mov    %esi,%edi
  8010ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801103:	89 f2                	mov    %esi,%edx
  801105:	8b 74 24 08          	mov    0x8(%esp),%esi
  801109:	d3 e5                	shl    %cl,%ebp
  80110b:	89 c1                	mov    %eax,%ecx
  80110d:	d3 ef                	shr    %cl,%edi
  80110f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801114:	d3 e2                	shl    %cl,%edx
  801116:	89 c1                	mov    %eax,%ecx
  801118:	d3 ee                	shr    %cl,%esi
  80111a:	09 d6                	or     %edx,%esi
  80111c:	89 fa                	mov    %edi,%edx
  80111e:	89 f0                	mov    %esi,%eax
  801120:	f7 74 24 0c          	divl   0xc(%esp)
  801124:	89 d7                	mov    %edx,%edi
  801126:	89 c6                	mov    %eax,%esi
  801128:	f7 e5                	mul    %ebp
  80112a:	39 d7                	cmp    %edx,%edi
  80112c:	72 22                	jb     801150 <__udivdi3+0x110>
  80112e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801132:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801137:	d3 e5                	shl    %cl,%ebp
  801139:	39 c5                	cmp    %eax,%ebp
  80113b:	73 04                	jae    801141 <__udivdi3+0x101>
  80113d:	39 d7                	cmp    %edx,%edi
  80113f:	74 0f                	je     801150 <__udivdi3+0x110>
  801141:	89 f0                	mov    %esi,%eax
  801143:	31 d2                	xor    %edx,%edx
  801145:	e9 46 ff ff ff       	jmp    801090 <__udivdi3+0x50>
  80114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801150:	8d 46 ff             	lea    -0x1(%esi),%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	8b 74 24 10          	mov    0x10(%esp),%esi
  801159:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80115d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801161:	83 c4 1c             	add    $0x1c,%esp
  801164:	c3                   	ret    
	...

00801170 <__umoddi3>:
  801170:	83 ec 1c             	sub    $0x1c,%esp
  801173:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801177:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80117b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80117f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801183:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801187:	8b 74 24 24          	mov    0x24(%esp),%esi
  80118b:	85 ed                	test   %ebp,%ebp
  80118d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801191:	89 44 24 08          	mov    %eax,0x8(%esp)
  801195:	89 cf                	mov    %ecx,%edi
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	89 f2                	mov    %esi,%edx
  80119c:	75 1a                	jne    8011b8 <__umoddi3+0x48>
  80119e:	39 f1                	cmp    %esi,%ecx
  8011a0:	76 4e                	jbe    8011f0 <__umoddi3+0x80>
  8011a2:	f7 f1                	div    %ecx
  8011a4:	89 d0                	mov    %edx,%eax
  8011a6:	31 d2                	xor    %edx,%edx
  8011a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b4:	83 c4 1c             	add    $0x1c,%esp
  8011b7:	c3                   	ret    
  8011b8:	39 f5                	cmp    %esi,%ebp
  8011ba:	77 54                	ja     801210 <__umoddi3+0xa0>
  8011bc:	0f bd c5             	bsr    %ebp,%eax
  8011bf:	83 f0 1f             	xor    $0x1f,%eax
  8011c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c6:	75 60                	jne    801228 <__umoddi3+0xb8>
  8011c8:	3b 0c 24             	cmp    (%esp),%ecx
  8011cb:	0f 87 07 01 00 00    	ja     8012d8 <__umoddi3+0x168>
  8011d1:	89 f2                	mov    %esi,%edx
  8011d3:	8b 34 24             	mov    (%esp),%esi
  8011d6:	29 ce                	sub    %ecx,%esi
  8011d8:	19 ea                	sbb    %ebp,%edx
  8011da:	89 34 24             	mov    %esi,(%esp)
  8011dd:	8b 04 24             	mov    (%esp),%eax
  8011e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ec:	83 c4 1c             	add    $0x1c,%esp
  8011ef:	c3                   	ret    
  8011f0:	85 c9                	test   %ecx,%ecx
  8011f2:	75 0b                	jne    8011ff <__umoddi3+0x8f>
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f1                	div    %ecx
  8011fd:	89 c1                	mov    %eax,%ecx
  8011ff:	89 f0                	mov    %esi,%eax
  801201:	31 d2                	xor    %edx,%edx
  801203:	f7 f1                	div    %ecx
  801205:	8b 04 24             	mov    (%esp),%eax
  801208:	f7 f1                	div    %ecx
  80120a:	eb 98                	jmp    8011a4 <__umoddi3+0x34>
  80120c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 f2                	mov    %esi,%edx
  801212:	8b 74 24 10          	mov    0x10(%esp),%esi
  801216:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80121a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80121e:	83 c4 1c             	add    $0x1c,%esp
  801221:	c3                   	ret    
  801222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801228:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80122d:	89 e8                	mov    %ebp,%eax
  80122f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801234:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801238:	89 fa                	mov    %edi,%edx
  80123a:	d3 e0                	shl    %cl,%eax
  80123c:	89 e9                	mov    %ebp,%ecx
  80123e:	d3 ea                	shr    %cl,%edx
  801240:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801245:	09 c2                	or     %eax,%edx
  801247:	8b 44 24 08          	mov    0x8(%esp),%eax
  80124b:	89 14 24             	mov    %edx,(%esp)
  80124e:	89 f2                	mov    %esi,%edx
  801250:	d3 e7                	shl    %cl,%edi
  801252:	89 e9                	mov    %ebp,%ecx
  801254:	d3 ea                	shr    %cl,%edx
  801256:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80125f:	d3 e6                	shl    %cl,%esi
  801261:	89 e9                	mov    %ebp,%ecx
  801263:	d3 e8                	shr    %cl,%eax
  801265:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126a:	09 f0                	or     %esi,%eax
  80126c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801270:	f7 34 24             	divl   (%esp)
  801273:	d3 e6                	shl    %cl,%esi
  801275:	89 74 24 08          	mov    %esi,0x8(%esp)
  801279:	89 d6                	mov    %edx,%esi
  80127b:	f7 e7                	mul    %edi
  80127d:	39 d6                	cmp    %edx,%esi
  80127f:	89 c1                	mov    %eax,%ecx
  801281:	89 d7                	mov    %edx,%edi
  801283:	72 3f                	jb     8012c4 <__umoddi3+0x154>
  801285:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801289:	72 35                	jb     8012c0 <__umoddi3+0x150>
  80128b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128f:	29 c8                	sub    %ecx,%eax
  801291:	19 fe                	sbb    %edi,%esi
  801293:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801298:	89 f2                	mov    %esi,%edx
  80129a:	d3 e8                	shr    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 e2                	shl    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 d0                	or     %edx,%eax
  8012a7:	89 f2                	mov    %esi,%edx
  8012a9:	d3 ea                	shr    %cl,%edx
  8012ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012b7:	83 c4 1c             	add    $0x1c,%esp
  8012ba:	c3                   	ret    
  8012bb:	90                   	nop
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	39 d6                	cmp    %edx,%esi
  8012c2:	75 c7                	jne    80128b <__umoddi3+0x11b>
  8012c4:	89 d7                	mov    %edx,%edi
  8012c6:	89 c1                	mov    %eax,%ecx
  8012c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012cc:	1b 3c 24             	sbb    (%esp),%edi
  8012cf:	eb ba                	jmp    80128b <__umoddi3+0x11b>
  8012d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	39 f5                	cmp    %esi,%ebp
  8012da:	0f 82 f1 fe ff ff    	jb     8011d1 <__umoddi3+0x61>
  8012e0:	e9 f8 fe ff ff       	jmp    8011dd <__umoddi3+0x6d>
