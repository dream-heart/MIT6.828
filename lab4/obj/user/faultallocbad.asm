
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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800043:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  80004a:	e8 d3 01 00 00       	call   800222 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800056:	00 
  800057:	89 d8                	mov    %ebx,%eax
  800059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800069:	e8 45 0c 00 00       	call   800cb3 <sys_page_alloc>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 24                	jns    800096 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800072:	89 44 24 10          	mov    %eax,0x10(%esp)
  800076:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007a:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  800081:	00 
  800082:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800089:	00 
  80008a:	c7 04 24 aa 11 80 00 	movl   $0x8011aa,(%esp)
  800091:	e8 93 00 00 00       	call   800129 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800096:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009a:	c7 44 24 08 ec 11 80 	movl   $0x8011ec,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000a9:	00 
  8000aa:	89 1c 24             	mov    %ebx,(%esp)
  8000ad:	e8 86 07 00 00       	call   800838 <snprintf>
}
  8000b2:	83 c4 24             	add    $0x24,%esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <umain>:

void
umain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000be:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000c5:	e8 fe 0d 00 00       	call   800ec8 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000ca:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d1:	00 
  8000d2:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000d9:	e8 08 0b 00 00       	call   800be6 <sys_cputs>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
  8000e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ec:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000f3:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	7e 08                	jle    800102 <libmain+0x22>
		binaryname = argv[0];
  8000fa:	8b 0a                	mov    (%edx),%ecx
  8000fc:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800102:	89 54 24 04          	mov    %edx,0x4(%esp)
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 aa ff ff ff       	call   8000b8 <umain>

	// exit gracefully
	exit();
  80010e:	e8 02 00 00 00       	call   800115 <exit>
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 fc 0a 00 00       	call   800c23 <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013a:	e8 36 0b 00 00       	call   800c75 <sys_getenvid>
  80013f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800142:	89 54 24 10          	mov    %edx,0x10(%esp)
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80014d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800151:	89 44 24 04          	mov    %eax,0x4(%esp)
  800155:	c7 04 24 18 12 80 00 	movl   $0x801218,(%esp)
  80015c:	e8 c1 00 00 00       	call   800222 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800161:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800165:	8b 45 10             	mov    0x10(%ebp),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 51 00 00 00       	call   8001c1 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 a8 11 80 00 	movl   $0x8011a8,(%esp)
  800177:	e8 a6 00 00 00       	call   800222 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017c:	cc                   	int3   
  80017d:	eb fd                	jmp    80017c <_panic+0x53>

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	83 ec 14             	sub    $0x14,%esp
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800189:	8b 13                	mov    (%ebx),%edx
  80018b:	8d 42 01             	lea    0x1(%edx),%eax
  80018e:	89 03                	mov    %eax,(%ebx)
  800190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800193:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800197:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019c:	75 19                	jne    8001b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a5:	00 
  8001a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a9:	89 04 24             	mov    %eax,(%esp)
  8001ac:	e8 35 0a 00 00       	call   800be6 <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	83 c4 14             	add    $0x14,%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d1:	00 00 00 
	b.cnt = 0;
  8001d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	c7 04 24 7f 01 80 00 	movl   $0x80017f,(%esp)
  8001fd:	e8 72 01 00 00       	call   800374 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 cc 09 00 00       	call   800be6 <sys_cputs>

	return b.cnt;
}
  80021a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800228:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	8b 45 08             	mov    0x8(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	e8 87 ff ff ff       	call   8001c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    
  80023c:	66 90                	xchg   %ax,%ax
  80023e:	66 90                	xchg   %ax,%ax

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 3c             	sub    $0x3c,%esp
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80024c:	89 d7                	mov    %edx,%edi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
  800257:	89 c3                	mov    %eax,%ebx
  800259:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80025c:	8b 45 10             	mov    0x10(%ebp),%eax
  80025f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800262:	b9 00 00 00 00       	mov    $0x0,%ecx
  800267:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026d:	39 d9                	cmp    %ebx,%ecx
  80026f:	72 05                	jb     800276 <printnum+0x36>
  800271:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800274:	77 69                	ja     8002df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800279:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80027d:	83 ee 01             	sub    $0x1,%esi
  800280:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	8b 44 24 08          	mov    0x8(%esp),%eax
  80028c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800290:	89 c3                	mov    %eax,%ebx
  800292:	89 d6                	mov    %edx,%esi
  800294:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800297:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80029a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80029e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 4c 0c 00 00       	call   800f00 <__udivdi3>
  8002b4:	89 d9                	mov    %ebx,%ecx
  8002b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c5:	89 fa                	mov    %edi,%edx
  8002c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ca:	e8 71 ff ff ff       	call   800240 <printnum>
  8002cf:	eb 1b                	jmp    8002ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff d3                	call   *%ebx
  8002dd:	eb 03                	jmp    8002e2 <printnum+0xa2>
  8002df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e2:	83 ee 01             	sub    $0x1,%esi
  8002e5:	85 f6                	test   %esi,%esi
  8002e7:	7f e8                	jg     8002d1 <printnum+0x91>
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	e8 1c 0d 00 00       	call   801030 <__umoddi3>
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	0f be 80 3b 12 80 00 	movsbl 0x80123b(%eax),%eax
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800325:	ff d0                	call   *%eax
}
  800327:	83 c4 3c             	add    $0x3c,%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800359:	8b 45 10             	mov    0x10(%ebp),%eax
  80035c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800360:	8b 45 0c             	mov    0xc(%ebp),%eax
  800363:	89 44 24 04          	mov    %eax,0x4(%esp)
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	e8 02 00 00 00       	call   800374 <vprintfmt>
	va_end(ap);
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
  80037a:	83 ec 3c             	sub    $0x3c,%esp
  80037d:	8b 75 08             	mov    0x8(%ebp),%esi
  800380:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800383:	8b 7d 10             	mov    0x10(%ebp),%edi
  800386:	eb 11                	jmp    800399 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800388:	85 c0                	test   %eax,%eax
  80038a:	0f 84 48 04 00 00    	je     8007d8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800390:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	83 c7 01             	add    $0x1,%edi
  80039c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003a0:	83 f8 25             	cmp    $0x25,%eax
  8003a3:	75 e3                	jne    800388 <vprintfmt+0x14>
  8003a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c3:	eb 1f                	jmp    8003e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003cc:	eb 16                	jmp    8003e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d5:	eb 0d                	jmp    8003e4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8d 47 01             	lea    0x1(%edi),%eax
  8003e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ea:	0f b6 17             	movzbl (%edi),%edx
  8003ed:	0f b6 c2             	movzbl %dl,%eax
  8003f0:	83 ea 23             	sub    $0x23,%edx
  8003f3:	80 fa 55             	cmp    $0x55,%dl
  8003f6:	0f 87 bf 03 00 00    	ja     8007bb <vprintfmt+0x447>
  8003fc:	0f b6 d2             	movzbl %dl,%edx
  8003ff:	ff 24 95 00 13 80 00 	jmp    *0x801300(,%edx,4)
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800411:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800414:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800418:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80041b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80041e:	83 f9 09             	cmp    $0x9,%ecx
  800421:	77 3c                	ja     80045f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800423:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800426:	eb e9                	jmp    800411 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 40 04             	lea    0x4(%eax),%eax
  800436:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043c:	eb 27                	jmp    800465 <vprintfmt+0xf1>
  80043e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	0f 49 c2             	cmovns %edx,%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800451:	eb 91                	jmp    8003e4 <vprintfmt+0x70>
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800456:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045d:	eb 85                	jmp    8003e4 <vprintfmt+0x70>
  80045f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800462:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800465:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800469:	0f 89 75 ff ff ff    	jns    8003e4 <vprintfmt+0x70>
  80046f:	e9 63 ff ff ff       	jmp    8003d7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800474:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047a:	e9 65 ff ff ff       	jmp    8003e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800482:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800486:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800494:	e9 00 ff ff ff       	jmp    800399 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	99                   	cltd   
  8004a3:	31 d0                	xor    %edx,%eax
  8004a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a7:	83 f8 09             	cmp    $0x9,%eax
  8004aa:	7f 0b                	jg     8004b7 <vprintfmt+0x143>
  8004ac:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	75 20                	jne    8004d7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bb:	c7 44 24 08 53 12 80 	movl   $0x801253,0x8(%esp)
  8004c2:	00 
  8004c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c7:	89 34 24             	mov    %esi,(%esp)
  8004ca:	e8 7d fe ff ff       	call   80034c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d2:	e9 c2 fe ff ff       	jmp    800399 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004db:	c7 44 24 08 5c 12 80 	movl   $0x80125c,0x8(%esp)
  8004e2:	00 
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	89 34 24             	mov    %esi,(%esp)
  8004ea:	e8 5d fe ff ff       	call   80034c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f2:	e9 a2 fe ff ff       	jmp    800399 <vprintfmt+0x25>
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800503:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800507:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800509:	85 ff                	test   %edi,%edi
  80050b:	b8 4c 12 80 00       	mov    $0x80124c,%eax
  800510:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800513:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800517:	0f 84 92 00 00 00    	je     8005af <vprintfmt+0x23b>
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	0f 8e 98 00 00 00    	jle    8005bd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	89 54 24 04          	mov    %edx,0x4(%esp)
  800529:	89 3c 24             	mov    %edi,(%esp)
  80052c:	e8 47 03 00 00       	call   800878 <strnlen>
  800531:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800534:	29 c1                	sub    %eax,%ecx
  800536:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800539:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80053d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800540:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800543:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	eb 0f                	jmp    800556 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800547:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	85 ff                	test   %edi,%edi
  800558:	7f ed                	jg     800547 <vprintfmt+0x1d3>
  80055a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800560:	85 c9                	test   %ecx,%ecx
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	0f 49 c1             	cmovns %ecx,%eax
  80056a:	29 c1                	sub    %eax,%ecx
  80056c:	89 75 08             	mov    %esi,0x8(%ebp)
  80056f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800572:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800575:	89 cb                	mov    %ecx,%ebx
  800577:	eb 50                	jmp    8005c9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057d:	74 1e                	je     80059d <vprintfmt+0x229>
  80057f:	0f be d2             	movsbl %dl,%edx
  800582:	83 ea 20             	sub    $0x20,%edx
  800585:	83 fa 5e             	cmp    $0x5e,%edx
  800588:	76 13                	jbe    80059d <vprintfmt+0x229>
					putch('?', putdat);
  80058a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800598:	ff 55 08             	call   *0x8(%ebp)
  80059b:	eb 0d                	jmp    8005aa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80059d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	83 eb 01             	sub    $0x1,%ebx
  8005ad:	eb 1a                	jmp    8005c9 <vprintfmt+0x255>
  8005af:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005bb:	eb 0c                	jmp    8005c9 <vprintfmt+0x255>
  8005bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c9:	83 c7 01             	add    $0x1,%edi
  8005cc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005d0:	0f be c2             	movsbl %dl,%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	74 25                	je     8005fc <vprintfmt+0x288>
  8005d7:	85 f6                	test   %esi,%esi
  8005d9:	78 9e                	js     800579 <vprintfmt+0x205>
  8005db:	83 ee 01             	sub    $0x1,%esi
  8005de:	79 99                	jns    800579 <vprintfmt+0x205>
  8005e0:	89 df                	mov    %ebx,%edi
  8005e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e8:	eb 1a                	jmp    800604 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f7:	83 ef 01             	sub    $0x1,%edi
  8005fa:	eb 08                	jmp    800604 <vprintfmt+0x290>
  8005fc:	89 df                	mov    %ebx,%edi
  8005fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800604:	85 ff                	test   %edi,%edi
  800606:	7f e2                	jg     8005ea <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060b:	e9 89 fd ff ff       	jmp    800399 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800610:	83 f9 01             	cmp    $0x1,%ecx
  800613:	7e 19                	jle    80062e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 50 04             	mov    0x4(%eax),%edx
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 40 08             	lea    0x8(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
  80062c:	eb 38                	jmp    800666 <vprintfmt+0x2f2>
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 1b                	je     80064d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 c1                	mov    %eax,%ecx
  80063c:	c1 f9 1f             	sar    $0x1f,%ecx
  80063f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
  80064b:	eb 19                	jmp    800666 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800666:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800669:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800671:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800675:	0f 89 04 01 00 00    	jns    80077f <vprintfmt+0x40b>
				putch('-', putdat);
  80067b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800686:	ff d6                	call   *%esi
				num = -(long long) num;
  800688:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80068e:	f7 da                	neg    %edx
  800690:	83 d1 00             	adc    $0x0,%ecx
  800693:	f7 d9                	neg    %ecx
  800695:	e9 e5 00 00 00       	jmp    80077f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069a:	83 f9 01             	cmp    $0x1,%ecx
  80069d:	7e 10                	jle    8006af <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a7:	8d 40 08             	lea    0x8(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ad:	eb 26                	jmp    8006d5 <vprintfmt+0x361>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	74 12                	je     8006c5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c3:	eb 10                	jmp    8006d5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006d5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006da:	e9 a0 00 00 00       	jmp    80077f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ea:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800704:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800709:	e9 8b fc ff ff       	jmp    800399 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800719:	ff d6                	call   *%esi
			putch('x', putdat);
  80071b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800726:	ff d6                	call   *%esi
			num = (unsigned long long)
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80073d:	eb 40                	jmp    80077f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073f:	83 f9 01             	cmp    $0x1,%ecx
  800742:	7e 10                	jle    800754 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8b 10                	mov    (%eax),%edx
  800749:	8b 48 04             	mov    0x4(%eax),%ecx
  80074c:	8d 40 08             	lea    0x8(%eax),%eax
  80074f:	89 45 14             	mov    %eax,0x14(%ebp)
  800752:	eb 26                	jmp    80077a <vprintfmt+0x406>
	else if (lflag)
  800754:	85 c9                	test   %ecx,%ecx
  800756:	74 12                	je     80076a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
  800768:	eb 10                	jmp    80077a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800774:	8d 40 04             	lea    0x4(%eax),%eax
  800777:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800783:	89 44 24 10          	mov    %eax,0x10(%esp)
  800787:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800792:	89 14 24             	mov    %edx,(%esp)
  800795:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800799:	89 da                	mov    %ebx,%edx
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	e8 9e fa ff ff       	call   800240 <printnum>
			break;
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a5:	e9 ef fb ff ff       	jmp    800399 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b6:	e9 de fb ff ff       	jmp    800399 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	eb 03                	jmp    8007cd <vprintfmt+0x459>
  8007ca:	83 ef 01             	sub    $0x1,%edi
  8007cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d1:	75 f7                	jne    8007ca <vprintfmt+0x456>
  8007d3:	e9 c1 fb ff ff       	jmp    800399 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007d8:	83 c4 3c             	add    $0x3c,%esp
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5f                   	pop    %edi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 28             	sub    $0x28,%esp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 30                	je     800831 <vsnprintf+0x51>
  800801:	85 d2                	test   %edx,%edx
  800803:	7e 2c                	jle    800831 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080c:	8b 45 10             	mov    0x10(%ebp),%eax
  80080f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800813:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081a:	c7 04 24 2f 03 80 00 	movl   $0x80032f,(%esp)
  800821:	e8 4e fb ff ff       	call   800374 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800826:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800829:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082f:	eb 05                	jmp    800836 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800845:	8b 45 10             	mov    0x10(%ebp),%eax
  800848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 82 ff ff ff       	call   8007e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1d>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
		n++;
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	75 ef                	jne    8008a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	89 1c 24             	mov    %ebx,(%esp)
  8008c4:	e8 97 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d0:	01 d8                	add    %ebx,%eax
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	e8 bd ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008da:	89 d8                	mov    %ebx,%eax
  8008dc:	83 c4 08             	add    $0x8,%esp
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	89 f3                	mov    %esi,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	eb 0f                	jmp    800905 <strncpy+0x23>
		*dst++ = *src;
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800902:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	39 da                	cmp    %ebx,%edx
  800907:	75 ed                	jne    8008f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800909:	89 f0                	mov    %esi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 75 08             	mov    0x8(%ebp),%esi
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800923:	85 c9                	test   %ecx,%ecx
  800925:	75 0b                	jne    800932 <strlcpy+0x23>
  800927:	eb 1d                	jmp    800946 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 d8                	cmp    %ebx,%eax
  800934:	74 0b                	je     800941 <strlcpy+0x32>
  800936:	0f b6 0a             	movzbl (%edx),%ecx
  800939:	84 c9                	test   %cl,%cl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1a>
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	eb 02                	jmp    800943 <strlcpy+0x34>
  800941:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 07                	jmp    8009de <strfind+0x13>
		if (*s == c)
  8009d7:	38 ca                	cmp    %cl,%dl
  8009d9:	74 0a                	je     8009e5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	89 d0                	mov    %edx,%eax
  800a1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 79 ff ff ff       	call   800a34 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	eb 1a                	jmp    800ae9 <memcmp+0x2c>
		if (*s1 != *s2)
  800acf:	0f b6 02             	movzbl (%edx),%eax
  800ad2:	0f b6 19             	movzbl (%ecx),%ebx
  800ad5:	38 d8                	cmp    %bl,%al
  800ad7:	74 0a                	je     800ae3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad9:	0f b6 c0             	movzbl %al,%eax
  800adc:	0f b6 db             	movzbl %bl,%ebx
  800adf:	29 d8                	sub    %ebx,%eax
  800ae1:	eb 0f                	jmp    800af2 <memcmp+0x35>
		s1++, s2++;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 f2                	cmp    %esi,%edx
  800aeb:	75 e2                	jne    800acf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b04:	eb 07                	jmp    800b0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	38 08                	cmp    %cl,(%eax)
  800b08:	74 07                	je     800b11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	72 f5                	jb     800b06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 0a             	movzbl (%edx),%ecx
  800b27:	80 f9 09             	cmp    $0x9,%cl
  800b2a:	74 f5                	je     800b21 <strtol+0xe>
  800b2c:	80 f9 20             	cmp    $0x20,%cl
  800b2f:	74 f0                	je     800b21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b31:	80 f9 2b             	cmp    $0x2b,%cl
  800b34:	75 0a                	jne    800b40 <strtol+0x2d>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb 11                	jmp    800b51 <strtol+0x3e>
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b45:	80 f9 2d             	cmp    $0x2d,%cl
  800b48:	75 07                	jne    800b51 <strtol+0x3e>
		s++, neg = 1;
  800b4a:	8d 52 01             	lea    0x1(%edx),%edx
  800b4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b56:	75 15                	jne    800b6d <strtol+0x5a>
  800b58:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5b:	75 10                	jne    800b6d <strtol+0x5a>
  800b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b61:	75 0a                	jne    800b6d <strtol+0x5a>
		s += 2, base = 16;
  800b63:	83 c2 02             	add    $0x2,%edx
  800b66:	b8 10 00 00 00       	mov    $0x10,%eax
  800b6b:	eb 10                	jmp    800b7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	75 0c                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b73:	80 3a 30             	cmpb   $0x30,(%edx)
  800b76:	75 05                	jne    800b7d <strtol+0x6a>
		s++, base = 8;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b85:	0f b6 0a             	movzbl (%edx),%ecx
  800b88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	3c 09                	cmp    $0x9,%al
  800b8f:	77 08                	ja     800b99 <strtol+0x86>
			dig = *s - '0';
  800b91:	0f be c9             	movsbl %cl,%ecx
  800b94:	83 e9 30             	sub    $0x30,%ecx
  800b97:	eb 20                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	3c 19                	cmp    $0x19,%al
  800ba0:	77 08                	ja     800baa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ba2:	0f be c9             	movsbl %cl,%ecx
  800ba5:	83 e9 57             	sub    $0x57,%ecx
  800ba8:	eb 0f                	jmp    800bb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	3c 19                	cmp    $0x19,%al
  800bb1:	77 16                	ja     800bc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bb3:	0f be c9             	movsbl %cl,%ecx
  800bb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bbc:	7d 0f                	jge    800bcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bc7:	eb bc                	jmp    800b85 <strtol+0x72>
  800bc9:	89 d8                	mov    %ebx,%eax
  800bcb:	eb 02                	jmp    800bcf <strtol+0xbc>
  800bcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xc7>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bda:	f7 d8                	neg    %eax
  800bdc:	85 ff                	test   %edi,%edi
  800bde:	0f 44 c3             	cmove  %ebx,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
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
  800c0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c31:	b8 03 00 00 00       	mov    $0x3,%eax
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 cb                	mov    %ecx,%ebx
  800c3b:	89 cf                	mov    %ecx,%edi
  800c3d:	89 ce                	mov    %ecx,%esi
  800c3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 28                	jle    800c6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c50:	00 
  800c51:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c60:	00 
  800c61:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c68:	e8 bc f4 ff ff       	call   800129 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6d:	83 c4 2c             	add    $0x2c,%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 02 00 00 00       	mov    $0x2,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_yield>:

void
sys_yield(void)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca4:	89 d1                	mov    %edx,%ecx
  800ca6:	89 d3                	mov    %edx,%ebx
  800ca8:	89 d7                	mov    %edx,%edi
  800caa:	89 d6                	mov    %edx,%esi
  800cac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	be 00 00 00 00       	mov    $0x0,%esi
  800cc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	89 f7                	mov    %esi,%edi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cfa:	e8 2a f4 ff ff       	call   800129 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b8 05 00 00 00       	mov    $0x5,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	8b 75 18             	mov    0x18(%ebp),%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d4d:	e8 d7 f3 ff ff       	call   800129 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800da0:	e8 84 f3 ff ff       	call   800129 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 28                	jle    800df8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800de3:	00 
  800de4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800deb:	00 
  800dec:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800df3:	e8 31 f3 ff ff       	call   800129 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df8:	83 c4 2c             	add    $0x2c,%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 28                	jle    800e4b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e46:	e8 de f2 ff ff       	call   800129 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4b:	83 c4 2c             	add    $0x2c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e59:	be 00 00 00 00       	mov    $0x0,%esi
  800e5e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e84:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	89 cb                	mov    %ecx,%ebx
  800e8e:	89 cf                	mov    %ecx,%edi
  800e90:	89 ce                	mov    %ecx,%esi
  800e92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e94:	85 c0                	test   %eax,%eax
  800e96:	7e 28                	jle    800ec0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800eab:	00 
  800eac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb3:	00 
  800eb4:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800ebb:	e8 69 f2 ff ff       	call   800129 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec0:	83 c4 2c             	add    $0x2c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ece:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ed5:	75 1c                	jne    800ef3 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800ed7:	c7 44 24 08 b4 14 80 	movl   $0x8014b4,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800eee:	e8 36 f2 ff ff       	call   800129 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f0a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f0e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f12:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f16:	85 c0                	test   %eax,%eax
  800f18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f1c:	89 ea                	mov    %ebp,%edx
  800f1e:	89 0c 24             	mov    %ecx,(%esp)
  800f21:	75 2d                	jne    800f50 <__udivdi3+0x50>
  800f23:	39 e9                	cmp    %ebp,%ecx
  800f25:	77 61                	ja     800f88 <__udivdi3+0x88>
  800f27:	85 c9                	test   %ecx,%ecx
  800f29:	89 ce                	mov    %ecx,%esi
  800f2b:	75 0b                	jne    800f38 <__udivdi3+0x38>
  800f2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f32:	31 d2                	xor    %edx,%edx
  800f34:	f7 f1                	div    %ecx
  800f36:	89 c6                	mov    %eax,%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	89 e8                	mov    %ebp,%eax
  800f3c:	f7 f6                	div    %esi
  800f3e:	89 c5                	mov    %eax,%ebp
  800f40:	89 f8                	mov    %edi,%eax
  800f42:	f7 f6                	div    %esi
  800f44:	89 ea                	mov    %ebp,%edx
  800f46:	83 c4 0c             	add    $0xc,%esp
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	39 e8                	cmp    %ebp,%eax
  800f52:	77 24                	ja     800f78 <__udivdi3+0x78>
  800f54:	0f bd e8             	bsr    %eax,%ebp
  800f57:	83 f5 1f             	xor    $0x1f,%ebp
  800f5a:	75 3c                	jne    800f98 <__udivdi3+0x98>
  800f5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f60:	39 34 24             	cmp    %esi,(%esp)
  800f63:	0f 86 9f 00 00 00    	jbe    801008 <__udivdi3+0x108>
  800f69:	39 d0                	cmp    %edx,%eax
  800f6b:	0f 82 97 00 00 00    	jb     801008 <__udivdi3+0x108>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	31 c0                	xor    %eax,%eax
  800f7c:	83 c4 0c             	add    $0xc,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
  800f83:	90                   	nop
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 f8                	mov    %edi,%eax
  800f8a:	f7 f1                	div    %ecx
  800f8c:	31 d2                	xor    %edx,%edx
  800f8e:	83 c4 0c             	add    $0xc,%esp
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	8b 3c 24             	mov    (%esp),%edi
  800f9d:	d3 e0                	shl    %cl,%eax
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa6:	29 e8                	sub    %ebp,%eax
  800fa8:	89 c1                	mov    %eax,%ecx
  800faa:	d3 ef                	shr    %cl,%edi
  800fac:	89 e9                	mov    %ebp,%ecx
  800fae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fb2:	8b 3c 24             	mov    (%esp),%edi
  800fb5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fb9:	89 d6                	mov    %edx,%esi
  800fbb:	d3 e7                	shl    %cl,%edi
  800fbd:	89 c1                	mov    %eax,%ecx
  800fbf:	89 3c 24             	mov    %edi,(%esp)
  800fc2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc6:	d3 ee                	shr    %cl,%esi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	d3 e2                	shl    %cl,%edx
  800fcc:	89 c1                	mov    %eax,%ecx
  800fce:	d3 ef                	shr    %cl,%edi
  800fd0:	09 d7                	or     %edx,%edi
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	f7 74 24 08          	divl   0x8(%esp)
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	f7 24 24             	mull   (%esp)
  800fe1:	39 d6                	cmp    %edx,%esi
  800fe3:	89 14 24             	mov    %edx,(%esp)
  800fe6:	72 30                	jb     801018 <__udivdi3+0x118>
  800fe8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fec:	89 e9                	mov    %ebp,%ecx
  800fee:	d3 e2                	shl    %cl,%edx
  800ff0:	39 c2                	cmp    %eax,%edx
  800ff2:	73 05                	jae    800ff9 <__udivdi3+0xf9>
  800ff4:	3b 34 24             	cmp    (%esp),%esi
  800ff7:	74 1f                	je     801018 <__udivdi3+0x118>
  800ff9:	89 f8                	mov    %edi,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	e9 7a ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	31 d2                	xor    %edx,%edx
  80100a:	b8 01 00 00 00       	mov    $0x1,%eax
  80100f:	e9 68 ff ff ff       	jmp    800f7c <__udivdi3+0x7c>
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	8d 47 ff             	lea    -0x1(%edi),%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 0c             	add    $0xc,%esp
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    
  801024:	66 90                	xchg   %ax,%ax
  801026:	66 90                	xchg   %ax,%ax
  801028:	66 90                	xchg   %ax,%ax
  80102a:	66 90                	xchg   %ax,%ax
  80102c:	66 90                	xchg   %ax,%ax
  80102e:	66 90                	xchg   %ax,%ax

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	83 ec 14             	sub    $0x14,%esp
  801036:	8b 44 24 28          	mov    0x28(%esp),%eax
  80103a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80103e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801042:	89 c7                	mov    %eax,%edi
  801044:	89 44 24 04          	mov    %eax,0x4(%esp)
  801048:	8b 44 24 30          	mov    0x30(%esp),%eax
  80104c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801050:	89 34 24             	mov    %esi,(%esp)
  801053:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801057:	85 c0                	test   %eax,%eax
  801059:	89 c2                	mov    %eax,%edx
  80105b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105f:	75 17                	jne    801078 <__umoddi3+0x48>
  801061:	39 fe                	cmp    %edi,%esi
  801063:	76 4b                	jbe    8010b0 <__umoddi3+0x80>
  801065:	89 c8                	mov    %ecx,%eax
  801067:	89 fa                	mov    %edi,%edx
  801069:	f7 f6                	div    %esi
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	83 c4 14             	add    $0x14,%esp
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
  801076:	66 90                	xchg   %ax,%ax
  801078:	39 f8                	cmp    %edi,%eax
  80107a:	77 54                	ja     8010d0 <__umoddi3+0xa0>
  80107c:	0f bd e8             	bsr    %eax,%ebp
  80107f:	83 f5 1f             	xor    $0x1f,%ebp
  801082:	75 5c                	jne    8010e0 <__umoddi3+0xb0>
  801084:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801088:	39 3c 24             	cmp    %edi,(%esp)
  80108b:	0f 87 e7 00 00 00    	ja     801178 <__umoddi3+0x148>
  801091:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801095:	29 f1                	sub    %esi,%ecx
  801097:	19 c7                	sbb    %eax,%edi
  801099:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010a9:	83 c4 14             	add    $0x14,%esp
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    
  8010b0:	85 f6                	test   %esi,%esi
  8010b2:	89 f5                	mov    %esi,%ebp
  8010b4:	75 0b                	jne    8010c1 <__umoddi3+0x91>
  8010b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	f7 f6                	div    %esi
  8010bf:	89 c5                	mov    %eax,%ebp
  8010c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010c5:	31 d2                	xor    %edx,%edx
  8010c7:	f7 f5                	div    %ebp
  8010c9:	89 c8                	mov    %ecx,%eax
  8010cb:	f7 f5                	div    %ebp
  8010cd:	eb 9c                	jmp    80106b <__umoddi3+0x3b>
  8010cf:	90                   	nop
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 fa                	mov    %edi,%edx
  8010d4:	83 c4 14             	add    $0x14,%esp
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	8b 04 24             	mov    (%esp),%eax
  8010e3:	be 20 00 00 00       	mov    $0x20,%esi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	29 ee                	sub    %ebp,%esi
  8010ec:	d3 e2                	shl    %cl,%edx
  8010ee:	89 f1                	mov    %esi,%ecx
  8010f0:	d3 e8                	shr    %cl,%eax
  8010f2:	89 e9                	mov    %ebp,%ecx
  8010f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f8:	8b 04 24             	mov    (%esp),%eax
  8010fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	d3 e0                	shl    %cl,%eax
  801103:	89 f1                	mov    %esi,%ecx
  801105:	89 44 24 08          	mov    %eax,0x8(%esp)
  801109:	8b 44 24 10          	mov    0x10(%esp),%eax
  80110d:	d3 ea                	shr    %cl,%edx
  80110f:	89 e9                	mov    %ebp,%ecx
  801111:	d3 e7                	shl    %cl,%edi
  801113:	89 f1                	mov    %esi,%ecx
  801115:	d3 e8                	shr    %cl,%eax
  801117:	89 e9                	mov    %ebp,%ecx
  801119:	09 f8                	or     %edi,%eax
  80111b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80111f:	f7 74 24 04          	divl   0x4(%esp)
  801123:	d3 e7                	shl    %cl,%edi
  801125:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801129:	89 d7                	mov    %edx,%edi
  80112b:	f7 64 24 08          	mull   0x8(%esp)
  80112f:	39 d7                	cmp    %edx,%edi
  801131:	89 c1                	mov    %eax,%ecx
  801133:	89 14 24             	mov    %edx,(%esp)
  801136:	72 2c                	jb     801164 <__umoddi3+0x134>
  801138:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80113c:	72 22                	jb     801160 <__umoddi3+0x130>
  80113e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801142:	29 c8                	sub    %ecx,%eax
  801144:	19 d7                	sbb    %edx,%edi
  801146:	89 e9                	mov    %ebp,%ecx
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 e8                	shr    %cl,%eax
  80114c:	89 f1                	mov    %esi,%ecx
  80114e:	d3 e2                	shl    %cl,%edx
  801150:	89 e9                	mov    %ebp,%ecx
  801152:	d3 ef                	shr    %cl,%edi
  801154:	09 d0                	or     %edx,%eax
  801156:	89 fa                	mov    %edi,%edx
  801158:	83 c4 14             	add    $0x14,%esp
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
  80115f:	90                   	nop
  801160:	39 d7                	cmp    %edx,%edi
  801162:	75 da                	jne    80113e <__umoddi3+0x10e>
  801164:	8b 14 24             	mov    (%esp),%edx
  801167:	89 c1                	mov    %eax,%ecx
  801169:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80116d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801171:	eb cb                	jmp    80113e <__umoddi3+0x10e>
  801173:	90                   	nop
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80117c:	0f 82 0f ff ff ff    	jb     801091 <__umoddi3+0x61>
  801182:	e9 1a ff ff ff       	jmp    8010a1 <__umoddi3+0x71>
