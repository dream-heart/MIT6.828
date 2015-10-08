
obj/user/faultallocbad:     file format elf32-i386


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
  800044:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  80004b:	e8 f0 01 00 00       	call   800240 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 64 0c 00 00       	call   800cd3 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 00 12 80 	movl   $0x801200,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 ea 11 80 00 	movl   $0x8011ea,(%esp)
  800092:	e8 b0 00 00 00       	call   800147 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 2c 12 80 	movl   $0x80122c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 a5 07 00 00       	call   800858 <snprintf>
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
  8000c6:	e8 1d 0e 00 00       	call   800ee8 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 27 0b 00 00       	call   800c06 <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

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
  8000f6:	e8 9a 0b 00 00       	call   800c95 <sys_getenvid>
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
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800139:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800140:	e8 fe 0a 00 00       	call   800c43 <sys_env_destroy>
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80014f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800152:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800158:	e8 38 0b 00 00       	call   800c95 <sys_getenvid>
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 54 24 10          	mov    %edx,0x10(%esp)
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80016f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800173:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  80017a:	e8 c1 00 00 00       	call   800240 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800183:	8b 45 10             	mov    0x10(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 51 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018e:	c7 04 24 e8 11 80 00 	movl   $0x8011e8,(%esp)
  800195:	e8 a6 00 00 00       	call   800240 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x53>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 14             	sub    $0x14,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	75 19                	jne    8001d5 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c3:	00 
  8001c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 37 0a 00 00       	call   800c06 <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d9:	83 c4 14             	add    $0x14,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800203:	8b 45 08             	mov    0x8(%ebp),%eax
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 9d 01 80 00 	movl   $0x80019d,(%esp)
  80021b:	e8 74 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800220:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 ce 09 00 00       	call   800c06 <sys_cputs>

	return b.cnt;
}
  800238:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800246:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 87 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    
  80025a:	00 00                	add    %al,(%eax)
  80025c:	00 00                	add    %al,(%eax)
	...

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
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 c3                	mov    %eax,%ebx
  800279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80027c:	8b 45 10             	mov    0x10(%ebp),%eax
  80027f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
  800287:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	39 d9                	cmp    %ebx,%ecx
  80028f:	72 05                	jb     800296 <printnum+0x36>
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800299:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029d:	83 ee 01             	sub    $0x1,%esi
  8002a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 4c 0c 00 00       	call   800f20 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 71 ff ff ff       	call   800260 <printnum>
  8002ef:	eb 1b                	jmp    80030c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa2>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 ee 01             	sub    $0x1,%esi
  800305:	85 f6                	test   %esi,%esi
  800307:	7f e8                	jg     8002f1 <printnum+0x91>
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800317:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80031a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 1c 0d 00 00       	call   801050 <__umoddi3>
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	0f be 80 7b 12 80 00 	movsbl 0x80127b(%eax),%eax
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800345:	ff d0                	call   *%eax
}
  800347:	83 c4 3c             	add    $0x3c,%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 45 0c             	mov    0xc(%ebp),%eax
  800383:	89 44 24 04          	mov    %eax,0x4(%esp)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	e8 02 00 00 00       	call   800394 <vprintfmt>
	va_end(ap);
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 3c             	sub    $0x3c,%esp
  80039d:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a6:	eb 11                	jmp    8003b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	0f 84 48 04 00 00    	je     8007f8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b9:	83 c7 01             	add    $0x1,%edi
  8003bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c0:	83 f8 25             	cmp    $0x25,%eax
  8003c3:	75 e3                	jne    8003a8 <vprintfmt+0x14>
  8003c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e3:	eb 1f                	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ec:	eb 16                	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f5:	eb 0d                	jmp    800404 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8d 47 01             	lea    0x1(%edi),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	0f b6 17             	movzbl (%edi),%edx
  80040d:	0f b6 c2             	movzbl %dl,%eax
  800410:	83 ea 23             	sub    $0x23,%edx
  800413:	80 fa 55             	cmp    $0x55,%dl
  800416:	0f 87 bf 03 00 00    	ja     8007db <vprintfmt+0x447>
  80041c:	0f b6 d2             	movzbl %dl,%edx
  80041f:	ff 24 95 40 13 80 00 	jmp    *0x801340(,%edx,4)
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800434:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800438:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80043b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80043e:	83 f9 09             	cmp    $0x9,%ecx
  800441:	77 3c                	ja     80047f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 40 04             	lea    0x4(%eax),%eax
  800456:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045c:	eb 27                	jmp    800485 <vprintfmt+0xf1>
  80045e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c2             	cmovns %edx,%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800471:	eb 91                	jmp    800404 <vprintfmt+0x70>
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800476:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047d:	eb 85                	jmp    800404 <vprintfmt+0x70>
  80047f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800482:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800485:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800489:	0f 89 75 ff ff ff    	jns    800404 <vprintfmt+0x70>
  80048f:	e9 63 ff ff ff       	jmp    8003f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800494:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049a:	e9 65 ff ff ff       	jmp    800404 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b4:	e9 00 ff ff ff       	jmp    8003b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	99                   	cltd   
  8004c3:	31 d0                	xor    %edx,%eax
  8004c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c7:	83 f8 09             	cmp    $0x9,%eax
  8004ca:	7f 0b                	jg     8004d7 <vprintfmt+0x143>
  8004cc:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	75 20                	jne    8004f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004db:	c7 44 24 08 93 12 80 	movl   $0x801293,0x8(%esp)
  8004e2:	00 
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	89 34 24             	mov    %esi,(%esp)
  8004ea:	e8 7d fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f2:	e9 c2 fe ff ff       	jmp    8003b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fb:	c7 44 24 08 9c 12 80 	movl   $0x80129c,0x8(%esp)
  800502:	00 
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	89 34 24             	mov    %esi,(%esp)
  80050a:	e8 5d fe ff ff       	call   80036c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800512:	e9 a2 fe ff ff       	jmp    8003b9 <vprintfmt+0x25>
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800527:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800529:	85 ff                	test   %edi,%edi
  80052b:	b8 8c 12 80 00       	mov    $0x80128c,%eax
  800530:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800533:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800537:	0f 84 92 00 00 00    	je     8005cf <vprintfmt+0x23b>
  80053d:	85 c9                	test   %ecx,%ecx
  80053f:	0f 8e 98 00 00 00    	jle    8005dd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	89 54 24 04          	mov    %edx,0x4(%esp)
  800549:	89 3c 24             	mov    %edi,(%esp)
  80054c:	e8 47 03 00 00       	call   800898 <strnlen>
  800551:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800554:	29 c1                	sub    %eax,%ecx
  800556:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800559:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	eb 0f                	jmp    800576 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800567:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	85 ff                	test   %edi,%edi
  800578:	7f ed                	jg     800567 <vprintfmt+0x1d3>
  80057a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800580:	85 c9                	test   %ecx,%ecx
  800582:	b8 00 00 00 00       	mov    $0x0,%eax
  800587:	0f 49 c1             	cmovns %ecx,%eax
  80058a:	29 c1                	sub    %eax,%ecx
  80058c:	89 75 08             	mov    %esi,0x8(%ebp)
  80058f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800592:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800595:	89 cb                	mov    %ecx,%ebx
  800597:	eb 50                	jmp    8005e9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059d:	74 1e                	je     8005bd <vprintfmt+0x229>
  80059f:	0f be d2             	movsbl %dl,%edx
  8005a2:	83 ea 20             	sub    $0x20,%edx
  8005a5:	83 fa 5e             	cmp    $0x5e,%edx
  8005a8:	76 13                	jbe    8005bd <vprintfmt+0x229>
					putch('?', putdat);
  8005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b8:	ff 55 08             	call   *0x8(%ebp)
  8005bb:	eb 0d                	jmp    8005ca <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	83 eb 01             	sub    $0x1,%ebx
  8005cd:	eb 1a                	jmp    8005e9 <vprintfmt+0x255>
  8005cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005db:	eb 0c                	jmp    8005e9 <vprintfmt+0x255>
  8005dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e9:	83 c7 01             	add    $0x1,%edi
  8005ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005f0:	0f be c2             	movsbl %dl,%eax
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	74 25                	je     80061c <vprintfmt+0x288>
  8005f7:	85 f6                	test   %esi,%esi
  8005f9:	78 9e                	js     800599 <vprintfmt+0x205>
  8005fb:	83 ee 01             	sub    $0x1,%esi
  8005fe:	79 99                	jns    800599 <vprintfmt+0x205>
  800600:	89 df                	mov    %ebx,%edi
  800602:	8b 75 08             	mov    0x8(%ebp),%esi
  800605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800608:	eb 1a                	jmp    800624 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800615:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	83 ef 01             	sub    $0x1,%edi
  80061a:	eb 08                	jmp    800624 <vprintfmt+0x290>
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	85 ff                	test   %edi,%edi
  800626:	7f e2                	jg     80060a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062b:	e9 89 fd ff ff       	jmp    8003b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800630:	83 f9 01             	cmp    $0x1,%ecx
  800633:	7e 19                	jle    80064e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 50 04             	mov    0x4(%eax),%edx
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 40 08             	lea    0x8(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
  80064c:	eb 38                	jmp    800686 <vprintfmt+0x2f2>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	74 1b                	je     80066d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	89 c1                	mov    %eax,%ecx
  80065c:	c1 f9 1f             	sar    $0x1f,%ecx
  80065f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb 19                	jmp    800686 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	89 c1                	mov    %eax,%ecx
  800677:	c1 f9 1f             	sar    $0x1f,%ecx
  80067a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800686:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800689:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80068c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800691:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800695:	0f 89 04 01 00 00    	jns    80079f <vprintfmt+0x40b>
				putch('-', putdat);
  80069b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ae:	f7 da                	neg    %edx
  8006b0:	83 d1 00             	adc    $0x0,%ecx
  8006b3:	f7 d9                	neg    %ecx
  8006b5:	e9 e5 00 00 00       	jmp    80079f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ba:	83 f9 01             	cmp    $0x1,%ecx
  8006bd:	7e 10                	jle    8006cf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cd:	eb 26                	jmp    8006f5 <vprintfmt+0x361>
	else if (lflag)
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	74 12                	je     8006e5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e3:	eb 10                	jmp    8006f5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006fa:	e9 a0 00 00 00       	jmp    80079f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070a:	ff d6                	call   *%esi
			putch('X', putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800717:	ff d6                	call   *%esi
			putch('X', putdat);
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800724:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800729:	e9 8b fc ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800739:	ff d6                	call   *%esi
			putch('x', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800746:	ff d6                	call   *%esi
			num = (unsigned long long)
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80075d:	eb 40                	jmp    80079f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075f:	83 f9 01             	cmp    $0x1,%ecx
  800762:	7e 10                	jle    800774 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 10                	mov    (%eax),%edx
  800769:	8b 48 04             	mov    0x4(%eax),%ecx
  80076c:	8d 40 08             	lea    0x8(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
  800772:	eb 26                	jmp    80079a <vprintfmt+0x406>
	else if (lflag)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	74 12                	je     80078a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
  800788:	eb 10                	jmp    80079a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800794:	8d 40 04             	lea    0x4(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80079a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007b2:	89 14 24             	mov    %edx,(%esp)
  8007b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b9:	89 da                	mov    %ebx,%edx
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	e8 9e fa ff ff       	call   800260 <printnum>
			break;
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c5:	e9 ef fb ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d6:	e9 de fb ff ff       	jmp    8003b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	eb 03                	jmp    8007ed <vprintfmt+0x459>
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f1:	75 f7                	jne    8007ea <vprintfmt+0x456>
  8007f3:	e9 c1 fb ff ff       	jmp    8003b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007f8:	83 c4 3c             	add    $0x3c,%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 28             	sub    $0x28,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 30                	je     800851 <vsnprintf+0x51>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 2c                	jle    800851 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800833:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083a:	c7 04 24 4f 03 80 00 	movl   $0x80034f,(%esp)
  800841:	e8 4e fb ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800846:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800849:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084f:	eb 05                	jmp    800856 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800861:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800865:	8b 45 10             	mov    0x10(%ebp),%eax
  800868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 82 ff ff ff       	call   800800 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 03                	jmp    800890 <strlen+0x10>
		n++;
  80088d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800890:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800894:	75 f7                	jne    80088d <strlen+0xd>
		n++;
	return n;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	eb 03                	jmp    8008ab <strnlen+0x13>
		n++;
  8008a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ab:	39 d0                	cmp    %edx,%eax
  8008ad:	74 06                	je     8008b5 <strnlen+0x1d>
  8008af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b3:	75 f3                	jne    8008a8 <strnlen+0x10>
		n++;
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ef                	jne    8008c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 97 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f0:	01 d8                	add    %ebx,%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 bd ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	83 c4 08             	add    $0x8,%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800943:	85 c9                	test   %ecx,%ecx
  800945:	75 0b                	jne    800952 <strlcpy+0x23>
  800947:	eb 1d                	jmp    800966 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	39 d8                	cmp    %ebx,%eax
  800954:	74 0b                	je     800961 <strlcpy+0x32>
  800956:	0f b6 0a             	movzbl (%edx),%ecx
  800959:	84 c9                	test   %cl,%cl
  80095b:	75 ec                	jne    800949 <strlcpy+0x1a>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	eb 02                	jmp    800963 <strlcpy+0x34>
  800961:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800963:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800966:	29 f0                	sub    %esi,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800975:	eb 06                	jmp    80097d <strcmp+0x11>
		p++, q++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 04                	je     800988 <strcmp+0x1c>
  800984:	3a 02                	cmp    (%edx),%al
  800986:	74 ef                	je     800977 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 c0             	movzbl %al,%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strncmp+0x17>
		n--, p++, q++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	39 d8                	cmp    %ebx,%eax
  8009ab:	74 15                	je     8009c2 <strncmp+0x30>
  8009ad:	0f b6 08             	movzbl (%eax),%ecx
  8009b0:	84 c9                	test   %cl,%cl
  8009b2:	74 04                	je     8009b8 <strncmp+0x26>
  8009b4:	3a 0a                	cmp    (%edx),%cl
  8009b6:	74 eb                	je     8009a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
  8009c0:	eb 05                	jmp    8009c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 07                	jmp    8009dd <strchr+0x13>
		if (*s == c)
  8009d6:	38 ca                	cmp    %cl,%dl
  8009d8:	74 0f                	je     8009e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 f2                	jne    8009d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 07                	jmp    8009fe <strfind+0x13>
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	74 0a                	je     800a05 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f2                	jne    8009f7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	74 36                	je     800a4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1d:	75 28                	jne    800a47 <memset+0x40>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	75 23                	jne    800a47 <memset+0x40>
		c &= 0xFF;
  800a24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a28:	89 d3                	mov    %edx,%ebx
  800a2a:	c1 e3 08             	shl    $0x8,%ebx
  800a2d:	89 d6                	mov    %edx,%esi
  800a2f:	c1 e6 18             	shl    $0x18,%esi
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	c1 e0 10             	shl    $0x10,%eax
  800a37:	09 f0                	or     %esi,%eax
  800a39:	09 c2                	or     %eax,%edx
  800a3b:	89 d0                	mov    %edx,%eax
  800a3d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a42:	fc                   	cld    
  800a43:	f3 ab                	rep stos %eax,%es:(%edi)
  800a45:	eb 06                	jmp    800a4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 35                	jae    800a9b <memmove+0x47>
  800a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a69:	39 d0                	cmp    %edx,%eax
  800a6b:	73 2e                	jae    800a9b <memmove+0x47>
		s += n;
		d += n;
  800a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7a:	75 13                	jne    800a8f <memmove+0x3b>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 0e                	jne    800a8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1d                	jmp    800ab8 <memmove+0x64>
  800a9b:	89 f2                	mov    %esi,%edx
  800a9d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	75 0f                	jne    800ab3 <memmove+0x5f>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0a                	jne    800ab3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 05                	jmp    800ab8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	fc                   	cld    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	89 04 24             	mov    %eax,(%esp)
  800ad6:	e8 79 ff ff ff       	call   800a54 <memmove>
}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aed:	eb 1a                	jmp    800b09 <memcmp+0x2c>
		if (*s1 != *s2)
  800aef:	0f b6 02             	movzbl (%edx),%eax
  800af2:	0f b6 19             	movzbl (%ecx),%ebx
  800af5:	38 d8                	cmp    %bl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 db             	movzbl %bl,%ebx
  800aff:	29 d8                	sub    %ebx,%eax
  800b01:	eb 0f                	jmp    800b12 <memcmp+0x35>
		s1++, s2++;
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 f2                	cmp    %esi,%edx
  800b0b:	75 e2                	jne    800aef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b24:	eb 07                	jmp    800b2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	38 08                	cmp    %cl,(%eax)
  800b28:	74 07                	je     800b31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	39 d0                	cmp    %edx,%eax
  800b2f:	72 f5                	jb     800b26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3f:	eb 03                	jmp    800b44 <strtol+0x11>
		s++;
  800b41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b44:	0f b6 0a             	movzbl (%edx),%ecx
  800b47:	80 f9 09             	cmp    $0x9,%cl
  800b4a:	74 f5                	je     800b41 <strtol+0xe>
  800b4c:	80 f9 20             	cmp    $0x20,%cl
  800b4f:	74 f0                	je     800b41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b51:	80 f9 2b             	cmp    $0x2b,%cl
  800b54:	75 0a                	jne    800b60 <strtol+0x2d>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	eb 11                	jmp    800b71 <strtol+0x3e>
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b65:	80 f9 2d             	cmp    $0x2d,%cl
  800b68:	75 07                	jne    800b71 <strtol+0x3e>
		s++, neg = 1;
  800b6a:	8d 52 01             	lea    0x1(%edx),%edx
  800b6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b76:	75 15                	jne    800b8d <strtol+0x5a>
  800b78:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7b:	75 10                	jne    800b8d <strtol+0x5a>
  800b7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b81:	75 0a                	jne    800b8d <strtol+0x5a>
		s += 2, base = 16;
  800b83:	83 c2 02             	add    $0x2,%edx
  800b86:	b8 10 00 00 00       	mov    $0x10,%eax
  800b8b:	eb 10                	jmp    800b9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	75 0c                	jne    800b9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b93:	80 3a 30             	cmpb   $0x30,(%edx)
  800b96:	75 05                	jne    800b9d <strtol+0x6a>
		s++, base = 8;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba5:	0f b6 0a             	movzbl (%edx),%ecx
  800ba8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	3c 09                	cmp    $0x9,%al
  800baf:	77 08                	ja     800bb9 <strtol+0x86>
			dig = *s - '0';
  800bb1:	0f be c9             	movsbl %cl,%ecx
  800bb4:	83 e9 30             	sub    $0x30,%ecx
  800bb7:	eb 20                	jmp    800bd9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bb9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	3c 19                	cmp    $0x19,%al
  800bc0:	77 08                	ja     800bca <strtol+0x97>
			dig = *s - 'a' + 10;
  800bc2:	0f be c9             	movsbl %cl,%ecx
  800bc5:	83 e9 57             	sub    $0x57,%ecx
  800bc8:	eb 0f                	jmp    800bd9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	3c 19                	cmp    $0x19,%al
  800bd1:	77 16                	ja     800be9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bd3:	0f be c9             	movsbl %cl,%ecx
  800bd6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bd9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bdc:	7d 0f                	jge    800bed <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800be5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800be7:	eb bc                	jmp    800ba5 <strtol+0x72>
  800be9:	89 d8                	mov    %ebx,%eax
  800beb:	eb 02                	jmp    800bef <strtol+0xbc>
  800bed:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf3:	74 05                	je     800bfa <strtol+0xc7>
		*endptr = (char *) s;
  800bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bfa:	f7 d8                	neg    %eax
  800bfc:	85 ff                	test   %edi,%edi
  800bfe:	0f 44 c3             	cmove  %ebx,%eax
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 c3                	mov    %eax,%ebx
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	89 c6                	mov    %eax,%esi
  800c1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_cgetc>:

int
sys_cgetc(void)
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
  800c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c51:	b8 03 00 00 00       	mov    $0x3,%eax
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 cb                	mov    %ecx,%ebx
  800c5b:	89 cf                	mov    %ecx,%edi
  800c5d:	89 ce                	mov    %ecx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 28                	jle    800c8d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c69:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c70:	00 
  800c71:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800c78:	00 
  800c79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c80:	00 
  800c81:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800c88:	e8 ba f4 ff ff       	call   800147 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8d:	83 c4 2c             	add    $0x2c,%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	89 d3                	mov    %edx,%ebx
  800ca9:	89 d7                	mov    %edx,%edi
  800cab:	89 d6                	mov    %edx,%esi
  800cad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_yield>:

void
sys_yield(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 d7                	mov    %edx,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	be 00 00 00 00       	mov    $0x0,%esi
  800ce1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	89 f7                	mov    %esi,%edi
  800cf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 28                	jle    800d1f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d02:	00 
  800d03:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d12:	00 
  800d13:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800d1a:	e8 28 f4 ff ff       	call   800147 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1f:	83 c4 2c             	add    $0x2c,%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b8 05 00 00 00       	mov    $0x5,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d41:	8b 75 18             	mov    0x18(%ebp),%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 28                	jle    800d72 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d55:	00 
  800d56:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800d5d:	00 
  800d5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d65:	00 
  800d66:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800d6d:	e8 d5 f3 ff ff       	call   800147 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d72:	83 c4 2c             	add    $0x2c,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 28                	jle    800dc5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800da8:	00 
  800da9:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800db0:	00 
  800db1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db8:	00 
  800db9:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800dc0:	e8 82 f3 ff ff       	call   800147 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc5:	83 c4 2c             	add    $0x2c,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	b8 08 00 00 00       	mov    $0x8,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 28                	jle    800e18 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dfb:	00 
  800dfc:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800e03:	00 
  800e04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0b:	00 
  800e0c:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800e13:	e8 2f f3 ff ff       	call   800147 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e18:	83 c4 2c             	add    $0x2c,%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 df                	mov    %ebx,%edi
  800e3b:	89 de                	mov    %ebx,%esi
  800e3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	7e 28                	jle    800e6b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e47:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800e56:	00 
  800e57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5e:	00 
  800e5f:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800e66:	e8 dc f2 ff ff       	call   800147 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6b:	83 c4 2c             	add    $0x2c,%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	be 00 00 00 00       	mov    $0x0,%esi
  800e7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 cb                	mov    %ecx,%ebx
  800eae:	89 cf                	mov    %ecx,%edi
  800eb0:	89 ce                	mov    %ecx,%esi
  800eb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	7e 28                	jle    800ee0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed3:	00 
  800ed4:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800edb:	e8 67 f2 ff ff       	call   800147 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee0:	83 c4 2c             	add    $0x2c,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ef5:	75 1c                	jne    800f13 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800ef7:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800efe:	00 
  800eff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 18 15 80 00 	movl   $0x801518,(%esp)
  800f0e:	e8 34 f2 ff ff       	call   800147 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    
  800f1d:	00 00                	add    %al,(%eax)
	...

00800f20 <__udivdi3>:
  800f20:	83 ec 1c             	sub    $0x1c,%esp
  800f23:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f27:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f2b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f2f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f33:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f37:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f3b:	85 ff                	test   %edi,%edi
  800f3d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f45:	89 cd                	mov    %ecx,%ebp
  800f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4b:	75 33                	jne    800f80 <__udivdi3+0x60>
  800f4d:	39 f1                	cmp    %esi,%ecx
  800f4f:	77 57                	ja     800fa8 <__udivdi3+0x88>
  800f51:	85 c9                	test   %ecx,%ecx
  800f53:	75 0b                	jne    800f60 <__udivdi3+0x40>
  800f55:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5a:	31 d2                	xor    %edx,%edx
  800f5c:	f7 f1                	div    %ecx
  800f5e:	89 c1                	mov    %eax,%ecx
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	31 d2                	xor    %edx,%edx
  800f64:	f7 f1                	div    %ecx
  800f66:	89 c6                	mov    %eax,%esi
  800f68:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f6c:	f7 f1                	div    %ecx
  800f6e:	89 f2                	mov    %esi,%edx
  800f70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f7c:	83 c4 1c             	add    $0x1c,%esp
  800f7f:	c3                   	ret    
  800f80:	31 d2                	xor    %edx,%edx
  800f82:	31 c0                	xor    %eax,%eax
  800f84:	39 f7                	cmp    %esi,%edi
  800f86:	77 e8                	ja     800f70 <__udivdi3+0x50>
  800f88:	0f bd cf             	bsr    %edi,%ecx
  800f8b:	83 f1 1f             	xor    $0x1f,%ecx
  800f8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f92:	75 2c                	jne    800fc0 <__udivdi3+0xa0>
  800f94:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f98:	76 04                	jbe    800f9e <__udivdi3+0x7e>
  800f9a:	39 f7                	cmp    %esi,%edi
  800f9c:	73 d2                	jae    800f70 <__udivdi3+0x50>
  800f9e:	31 d2                	xor    %edx,%edx
  800fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa5:	eb c9                	jmp    800f70 <__udivdi3+0x50>
  800fa7:	90                   	nop
  800fa8:	89 f2                	mov    %esi,%edx
  800faa:	f7 f1                	div    %ecx
  800fac:	31 d2                	xor    %edx,%edx
  800fae:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fb2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fb6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	c3                   	ret    
  800fbe:	66 90                	xchg   %ax,%ax
  800fc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fc5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fca:	89 ea                	mov    %ebp,%edx
  800fcc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fd0:	d3 e7                	shl    %cl,%edi
  800fd2:	89 c1                	mov    %eax,%ecx
  800fd4:	d3 ea                	shr    %cl,%edx
  800fd6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fdb:	09 fa                	or     %edi,%edx
  800fdd:	89 f7                	mov    %esi,%edi
  800fdf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fe9:	d3 e5                	shl    %cl,%ebp
  800feb:	89 c1                	mov    %eax,%ecx
  800fed:	d3 ef                	shr    %cl,%edi
  800fef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff4:	d3 e2                	shl    %cl,%edx
  800ff6:	89 c1                	mov    %eax,%ecx
  800ff8:	d3 ee                	shr    %cl,%esi
  800ffa:	09 d6                	or     %edx,%esi
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	89 f0                	mov    %esi,%eax
  801000:	f7 74 24 0c          	divl   0xc(%esp)
  801004:	89 d7                	mov    %edx,%edi
  801006:	89 c6                	mov    %eax,%esi
  801008:	f7 e5                	mul    %ebp
  80100a:	39 d7                	cmp    %edx,%edi
  80100c:	72 22                	jb     801030 <__udivdi3+0x110>
  80100e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801012:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801017:	d3 e5                	shl    %cl,%ebp
  801019:	39 c5                	cmp    %eax,%ebp
  80101b:	73 04                	jae    801021 <__udivdi3+0x101>
  80101d:	39 d7                	cmp    %edx,%edi
  80101f:	74 0f                	je     801030 <__udivdi3+0x110>
  801021:	89 f0                	mov    %esi,%eax
  801023:	31 d2                	xor    %edx,%edx
  801025:	e9 46 ff ff ff       	jmp    800f70 <__udivdi3+0x50>
  80102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801030:	8d 46 ff             	lea    -0x1(%esi),%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	8b 74 24 10          	mov    0x10(%esp),%esi
  801039:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80103d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801041:	83 c4 1c             	add    $0x1c,%esp
  801044:	c3                   	ret    
	...

00801050 <__umoddi3>:
  801050:	83 ec 1c             	sub    $0x1c,%esp
  801053:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801057:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80105b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80105f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801063:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801067:	8b 74 24 24          	mov    0x24(%esp),%esi
  80106b:	85 ed                	test   %ebp,%ebp
  80106d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801071:	89 44 24 08          	mov    %eax,0x8(%esp)
  801075:	89 cf                	mov    %ecx,%edi
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	89 f2                	mov    %esi,%edx
  80107c:	75 1a                	jne    801098 <__umoddi3+0x48>
  80107e:	39 f1                	cmp    %esi,%ecx
  801080:	76 4e                	jbe    8010d0 <__umoddi3+0x80>
  801082:	f7 f1                	div    %ecx
  801084:	89 d0                	mov    %edx,%eax
  801086:	31 d2                	xor    %edx,%edx
  801088:	8b 74 24 10          	mov    0x10(%esp),%esi
  80108c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801090:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801094:	83 c4 1c             	add    $0x1c,%esp
  801097:	c3                   	ret    
  801098:	39 f5                	cmp    %esi,%ebp
  80109a:	77 54                	ja     8010f0 <__umoddi3+0xa0>
  80109c:	0f bd c5             	bsr    %ebp,%eax
  80109f:	83 f0 1f             	xor    $0x1f,%eax
  8010a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a6:	75 60                	jne    801108 <__umoddi3+0xb8>
  8010a8:	3b 0c 24             	cmp    (%esp),%ecx
  8010ab:	0f 87 07 01 00 00    	ja     8011b8 <__umoddi3+0x168>
  8010b1:	89 f2                	mov    %esi,%edx
  8010b3:	8b 34 24             	mov    (%esp),%esi
  8010b6:	29 ce                	sub    %ecx,%esi
  8010b8:	19 ea                	sbb    %ebp,%edx
  8010ba:	89 34 24             	mov    %esi,(%esp)
  8010bd:	8b 04 24             	mov    (%esp),%eax
  8010c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010cc:	83 c4 1c             	add    $0x1c,%esp
  8010cf:	c3                   	ret    
  8010d0:	85 c9                	test   %ecx,%ecx
  8010d2:	75 0b                	jne    8010df <__umoddi3+0x8f>
  8010d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d9:	31 d2                	xor    %edx,%edx
  8010db:	f7 f1                	div    %ecx
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	89 f0                	mov    %esi,%eax
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	f7 f1                	div    %ecx
  8010e5:	8b 04 24             	mov    (%esp),%eax
  8010e8:	f7 f1                	div    %ecx
  8010ea:	eb 98                	jmp    801084 <__umoddi3+0x34>
  8010ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	89 f2                	mov    %esi,%edx
  8010f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fe:	83 c4 1c             	add    $0x1c,%esp
  801101:	c3                   	ret    
  801102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801108:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110d:	89 e8                	mov    %ebp,%eax
  80110f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801114:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801118:	89 fa                	mov    %edi,%edx
  80111a:	d3 e0                	shl    %cl,%eax
  80111c:	89 e9                	mov    %ebp,%ecx
  80111e:	d3 ea                	shr    %cl,%edx
  801120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801125:	09 c2                	or     %eax,%edx
  801127:	8b 44 24 08          	mov    0x8(%esp),%eax
  80112b:	89 14 24             	mov    %edx,(%esp)
  80112e:	89 f2                	mov    %esi,%edx
  801130:	d3 e7                	shl    %cl,%edi
  801132:	89 e9                	mov    %ebp,%ecx
  801134:	d3 ea                	shr    %cl,%edx
  801136:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113f:	d3 e6                	shl    %cl,%esi
  801141:	89 e9                	mov    %ebp,%ecx
  801143:	d3 e8                	shr    %cl,%eax
  801145:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114a:	09 f0                	or     %esi,%eax
  80114c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801150:	f7 34 24             	divl   (%esp)
  801153:	d3 e6                	shl    %cl,%esi
  801155:	89 74 24 08          	mov    %esi,0x8(%esp)
  801159:	89 d6                	mov    %edx,%esi
  80115b:	f7 e7                	mul    %edi
  80115d:	39 d6                	cmp    %edx,%esi
  80115f:	89 c1                	mov    %eax,%ecx
  801161:	89 d7                	mov    %edx,%edi
  801163:	72 3f                	jb     8011a4 <__umoddi3+0x154>
  801165:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801169:	72 35                	jb     8011a0 <__umoddi3+0x150>
  80116b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80116f:	29 c8                	sub    %ecx,%eax
  801171:	19 fe                	sbb    %edi,%esi
  801173:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801178:	89 f2                	mov    %esi,%edx
  80117a:	d3 e8                	shr    %cl,%eax
  80117c:	89 e9                	mov    %ebp,%ecx
  80117e:	d3 e2                	shl    %cl,%edx
  801180:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801185:	09 d0                	or     %edx,%eax
  801187:	89 f2                	mov    %esi,%edx
  801189:	d3 ea                	shr    %cl,%edx
  80118b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80118f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801193:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801197:	83 c4 1c             	add    $0x1c,%esp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	39 d6                	cmp    %edx,%esi
  8011a2:	75 c7                	jne    80116b <__umoddi3+0x11b>
  8011a4:	89 d7                	mov    %edx,%edi
  8011a6:	89 c1                	mov    %eax,%ecx
  8011a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011ac:	1b 3c 24             	sbb    (%esp),%edi
  8011af:	eb ba                	jmp    80116b <__umoddi3+0x11b>
  8011b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	39 f5                	cmp    %esi,%ebp
  8011ba:	0f 82 f1 fe ff ff    	jb     8010b1 <__umoddi3+0x61>
  8011c0:	e9 f8 fe ff ff       	jmp    8010bd <__umoddi3+0x6d>
