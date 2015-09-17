
obj/user/pingpongs：     文件格式 elf32-i386


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
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 b9 0e 00 00       	call   800efa <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 5e                	je     8000a6 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 32 0c 00 00       	call   800c85 <sys_getenvid>
  800053:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 80 12 80 00 	movl   $0x801280,(%esp)
  800062:	e8 cc 01 00 00       	call   800233 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800067:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006a:	e8 16 0c 00 00       	call   800c85 <sys_getenvid>
  80006f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 9a 12 80 00 	movl   $0x80129a,(%esp)
  80007e:	e8 b0 01 00 00       	call   800233 <cprintf>
		ipc_send(who, 0, 0, 0);
  800083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008a:	00 
  80008b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009a:	00 
  80009b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009e:	89 04 24             	mov    %eax,(%esp)
  8000a1:	e8 98 0e 00 00       	call   800f3e <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 5b 0e 00 00       	call   800f1c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c1:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c7:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000cd:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d5:	e8 ab 0b 00 00       	call   800c85 <sys_getenvid>
  8000da:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000de:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000e9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	c7 04 24 b0 12 80 00 	movl   $0x8012b0,(%esp)
  8000f8:	e8 36 01 00 00       	call   800233 <cprintf>
		if (val == 10)
  8000fd:	a1 04 20 80 00       	mov    0x802004,%eax
  800102:	83 f8 0a             	cmp    $0xa,%eax
  800105:	74 38                	je     80013f <umain+0x10c>
			return;
		++val;
  800107:	83 c0 01             	add    $0x1,%eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 0c 0e 00 00       	call   800f3e <ipc_send>
		if (val == 10)
  800132:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  800139:	0f 85 67 ff ff ff    	jne    8000a6 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 3c             	add    $0x3c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 18             	sub    $0x18,%esp
  80014d:	8b 45 08             	mov    0x8(%ebp),%eax
  800150:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800153:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80015a:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 c0                	test   %eax,%eax
  80015f:	7e 08                	jle    800169 <libmain+0x22>
		binaryname = argv[0];
  800161:	8b 0a                	mov    (%edx),%ecx
  800163:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800169:	89 54 24 04          	mov    %edx,0x4(%esp)
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 be fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800175:	e8 02 00 00 00       	call   80017c <exit>
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800182:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800189:	e8 a5 0a 00 00       	call   800c33 <sys_env_destroy>
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 14             	sub    $0x14,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 13                	mov    (%ebx),%edx
  80019c:	8d 42 01             	lea    0x1(%edx),%eax
  80019f:	89 03                	mov    %eax,(%ebx)
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ad:	75 19                	jne    8001c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b6:	00 
  8001b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ba:	89 04 24             	mov    %eax,(%esp)
  8001bd:	e8 34 0a 00 00       	call   800bf6 <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cc:	83 c4 14             	add    $0x14,%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	c7 04 24 90 01 80 00 	movl   $0x800190,(%esp)
  80020e:	e8 71 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800213:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 cb 09 00 00       	call   800bf6 <sys_cputs>

	return b.cnt;
}
  80022b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	e8 87 ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
  80024d:	66 90                	xchg   %ax,%ax
  80024f:	90                   	nop

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c3                	mov    %eax,%ebx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	39 d9                	cmp    %ebx,%ecx
  80027f:	72 05                	jb     800286 <printnum+0x36>
  800281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800284:	77 69                	ja     8002ef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028d:	83 ee 01             	sub    $0x1,%esi
  800290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 2c 0d 00 00       	call   800ff0 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 71 ff ff ff       	call   800250 <printnum>
  8002df:	eb 1b                	jmp    8002fc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa2>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	83 ee 01             	sub    $0x1,%esi
  8002f5:	85 f6                	test   %esi,%esi
  8002f7:	7f e8                	jg     8002e1 <printnum+0x91>
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 fc 0d 00 00       	call   801120 <__umoddi3>
  800324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800328:	0f be 80 e0 12 80 00 	movsbl 0x8012e0(%eax),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800335:	ff d0                	call   *%eax
}
  800337:	83 c4 3c             	add    $0x3c,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800345:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	3b 50 04             	cmp    0x4(%eax),%edx
  80034e:	73 0a                	jae    80035a <sprintputch+0x1b>
		*b->buf++ = ch;
  800350:	8d 4a 01             	lea    0x1(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	88 02                	mov    %al,(%edx)
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	e8 02 00 00 00       	call   800384 <vprintfmt>
	va_end(ap);
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 3c             	sub    $0x3c,%esp
  80038d:	8b 75 08             	mov    0x8(%ebp),%esi
  800390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800393:	8b 7d 10             	mov    0x10(%ebp),%edi
  800396:	eb 11                	jmp    8003a9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800398:	85 c0                	test   %eax,%eax
  80039a:	0f 84 48 04 00 00    	je     8007e8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	83 c7 01             	add    $0x1,%edi
  8003ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b0:	83 f8 25             	cmp    $0x25,%eax
  8003b3:	75 e3                	jne    800398 <vprintfmt+0x14>
  8003b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d3:	eb 1f                	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003dc:	eb 16                	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e5:	eb 0d                	jmp    8003f4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8d 47 01             	lea    0x1(%edi),%eax
  8003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fa:	0f b6 17             	movzbl (%edi),%edx
  8003fd:	0f b6 c2             	movzbl %dl,%eax
  800400:	83 ea 23             	sub    $0x23,%edx
  800403:	80 fa 55             	cmp    $0x55,%dl
  800406:	0f 87 bf 03 00 00    	ja     8007cb <vprintfmt+0x447>
  80040c:	0f b6 d2             	movzbl %dl,%edx
  80040f:	ff 24 95 a0 13 80 00 	jmp    *0x8013a0(,%edx,4)
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
  80041e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800421:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800424:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800428:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80042b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80042e:	83 f9 09             	cmp    $0x9,%ecx
  800431:	77 3c                	ja     80046f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800433:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800436:	eb e9                	jmp    800421 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 40 04             	lea    0x4(%eax),%eax
  800446:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044c:	eb 27                	jmp    800475 <vprintfmt+0xf1>
  80044e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c2             	cmovns %edx,%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	eb 91                	jmp    8003f4 <vprintfmt+0x70>
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800466:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80046d:	eb 85                	jmp    8003f4 <vprintfmt+0x70>
  80046f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800472:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800479:	0f 89 75 ff ff ff    	jns    8003f4 <vprintfmt+0x70>
  80047f:	e9 63 ff ff ff       	jmp    8003e7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800484:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048a:	e9 65 ff ff ff       	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800492:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800496:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a4:	e9 00 ff ff ff       	jmp    8003a9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ac:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	99                   	cltd   
  8004b3:	31 d0                	xor    %edx,%eax
  8004b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b7:	83 f8 09             	cmp    $0x9,%eax
  8004ba:	7f 0b                	jg     8004c7 <vprintfmt+0x143>
  8004bc:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	75 20                	jne    8004e7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cb:	c7 44 24 08 f8 12 80 	movl   $0x8012f8,0x8(%esp)
  8004d2:	00 
  8004d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d7:	89 34 24             	mov    %esi,(%esp)
  8004da:	e8 7d fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e2:	e9 c2 fe ff ff       	jmp    8003a9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004eb:	c7 44 24 08 01 13 80 	movl   $0x801301,0x8(%esp)
  8004f2:	00 
  8004f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 5d fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800502:	e9 a2 fe ff ff       	jmp    8003a9 <vprintfmt+0x25>
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80050d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800510:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800513:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800519:	85 ff                	test   %edi,%edi
  80051b:	b8 f1 12 80 00       	mov    $0x8012f1,%eax
  800520:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800523:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800527:	0f 84 92 00 00 00    	je     8005bf <vprintfmt+0x23b>
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	0f 8e 98 00 00 00    	jle    8005cd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	89 3c 24             	mov    %edi,(%esp)
  80053c:	e8 47 03 00 00       	call   800888 <strnlen>
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	29 c1                	sub    %eax,%ecx
  800546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800549:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800550:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800553:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	eb 0f                	jmp    800566 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	85 ff                	test   %edi,%edi
  800568:	7f ed                	jg     800557 <vprintfmt+0x1d3>
  80056a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800570:	85 c9                	test   %ecx,%ecx
  800572:	b8 00 00 00 00       	mov    $0x0,%eax
  800577:	0f 49 c1             	cmovns %ecx,%eax
  80057a:	29 c1                	sub    %eax,%ecx
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	89 cb                	mov    %ecx,%ebx
  800587:	eb 50                	jmp    8005d9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058d:	74 1e                	je     8005ad <vprintfmt+0x229>
  80058f:	0f be d2             	movsbl %dl,%edx
  800592:	83 ea 20             	sub    $0x20,%edx
  800595:	83 fa 5e             	cmp    $0x5e,%edx
  800598:	76 13                	jbe    8005ad <vprintfmt+0x229>
					putch('?', putdat);
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a8:	ff 55 08             	call   *0x8(%ebp)
  8005ab:	eb 0d                	jmp    8005ba <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	83 eb 01             	sub    $0x1,%ebx
  8005bd:	eb 1a                	jmp    8005d9 <vprintfmt+0x255>
  8005bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cb:	eb 0c                	jmp    8005d9 <vprintfmt+0x255>
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d9:	83 c7 01             	add    $0x1,%edi
  8005dc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005e0:	0f be c2             	movsbl %dl,%eax
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	74 25                	je     80060c <vprintfmt+0x288>
  8005e7:	85 f6                	test   %esi,%esi
  8005e9:	78 9e                	js     800589 <vprintfmt+0x205>
  8005eb:	83 ee 01             	sub    $0x1,%esi
  8005ee:	79 99                	jns    800589 <vprintfmt+0x205>
  8005f0:	89 df                	mov    %ebx,%edi
  8005f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f8:	eb 1a                	jmp    800614 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800605:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	83 ef 01             	sub    $0x1,%edi
  80060a:	eb 08                	jmp    800614 <vprintfmt+0x290>
  80060c:	89 df                	mov    %ebx,%edi
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800614:	85 ff                	test   %edi,%edi
  800616:	7f e2                	jg     8005fa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 89 fd ff ff       	jmp    8003a9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 19                	jle    80063e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 50 04             	mov    0x4(%eax),%edx
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
  80063c:	eb 38                	jmp    800676 <vprintfmt+0x2f2>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 1b                	je     80065d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 c1                	mov    %eax,%ecx
  80064c:	c1 f9 1f             	sar    $0x1f,%ecx
  80064f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
  80065b:	eb 19                	jmp    800676 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c1                	mov    %eax,%ecx
  800667:	c1 f9 1f             	sar    $0x1f,%ecx
  80066a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	0f 89 04 01 00 00    	jns    80078f <vprintfmt+0x40b>
				putch('-', putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069e:	f7 da                	neg    %edx
  8006a0:	83 d1 00             	adc    $0x0,%ecx
  8006a3:	f7 d9                	neg    %ecx
  8006a5:	e9 e5 00 00 00       	jmp    80078f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006aa:	83 f9 01             	cmp    $0x1,%ecx
  8006ad:	7e 10                	jle    8006bf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bd:	eb 26                	jmp    8006e5 <vprintfmt+0x361>
	else if (lflag)
  8006bf:	85 c9                	test   %ecx,%ecx
  8006c1:	74 12                	je     8006d5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cd:	8d 40 04             	lea    0x4(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d3:	eb 10                	jmp    8006e5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006ea:	e9 a0 00 00 00       	jmp    80078f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006fa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800714:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800719:	e9 8b fc ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80071e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800722:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800729:	ff d6                	call   *%esi
			putch('x', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800736:	ff d6                	call   *%esi
			num = (unsigned long long)
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800748:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80074d:	eb 40                	jmp    80078f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 f9 01             	cmp    $0x1,%ecx
  800752:	7e 10                	jle    800764 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	8b 48 04             	mov    0x4(%eax),%ecx
  80075c:	8d 40 08             	lea    0x8(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
  800762:	eb 26                	jmp    80078a <vprintfmt+0x406>
	else if (lflag)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 12                	je     80077a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
  800778:	eb 10                	jmp    80078a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800784:	8d 40 04             	lea    0x4(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80078a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800793:	89 44 24 10          	mov    %eax,0x10(%esp)
  800797:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007a2:	89 14 24             	mov    %edx,(%esp)
  8007a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a9:	89 da                	mov    %ebx,%edx
  8007ab:	89 f0                	mov    %esi,%eax
  8007ad:	e8 9e fa ff ff       	call   800250 <printnum>
			break;
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 ef fb ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c6:	e9 de fb ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	eb 03                	jmp    8007dd <vprintfmt+0x459>
  8007da:	83 ef 01             	sub    $0x1,%edi
  8007dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e1:	75 f7                	jne    8007da <vprintfmt+0x456>
  8007e3:	e9 c1 fb ff ff       	jmp    8003a9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007e8:	83 c4 3c             	add    $0x3c,%esp
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5f                   	pop    %edi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 28             	sub    $0x28,%esp
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800803:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800806:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 30                	je     800841 <vsnprintf+0x51>
  800811:	85 d2                	test   %edx,%edx
  800813:	7e 2c                	jle    800841 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
  80081f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082a:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  800831:	e8 4e fb ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800836:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800839:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083f:	eb 05                	jmp    800846 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800841:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800851:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800855:	8b 45 10             	mov    0x10(%ebp),%eax
  800858:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 82 ff ff ff       	call   8007f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 03                	jmp    800880 <strlen+0x10>
		n++;
  80087d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800884:	75 f7                	jne    80087d <strlen+0xd>
		n++;
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb 03                	jmp    80089b <strnlen+0x13>
		n++;
  800898:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	74 06                	je     8008a5 <strnlen+0x1d>
  80089f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a3:	75 f3                	jne    800898 <strnlen+0x10>
		n++;
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	83 c2 01             	add    $0x1,%edx
  8008b6:	83 c1 01             	add    $0x1,%ecx
  8008b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	75 ef                	jne    8008b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d1:	89 1c 24             	mov    %ebx,(%esp)
  8008d4:	e8 97 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e0:	01 d8                	add    %ebx,%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 bd ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008ea:	89 d8                	mov    %ebx,%eax
  8008ec:	83 c4 08             	add    $0x8,%esp
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	89 f3                	mov    %esi,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800902:	89 f2                	mov    %esi,%edx
  800904:	eb 0f                	jmp    800915 <strncpy+0x23>
		*dst++ = *src;
  800906:	83 c2 01             	add    $0x1,%edx
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090f:	80 39 01             	cmpb   $0x1,(%ecx)
  800912:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800915:	39 da                	cmp    %ebx,%edx
  800917:	75 ed                	jne    800906 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800919:	89 f0                	mov    %esi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	85 c9                	test   %ecx,%ecx
  800935:	75 0b                	jne    800942 <strlcpy+0x23>
  800937:	eb 1d                	jmp    800956 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 0b                	je     800951 <strlcpy+0x32>
  800946:	0f b6 0a             	movzbl (%edx),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	75 ec                	jne    800939 <strlcpy+0x1a>
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	eb 02                	jmp    800953 <strlcpy+0x34>
  800951:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800953:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800956:	29 f0                	sub    %esi,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800965:	eb 06                	jmp    80096d <strcmp+0x11>
		p++, q++;
  800967:	83 c1 01             	add    $0x1,%ecx
  80096a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	84 c0                	test   %al,%al
  800972:	74 04                	je     800978 <strcmp+0x1c>
  800974:	3a 02                	cmp    (%edx),%al
  800976:	74 ef                	je     800967 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 c0             	movzbl %al,%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800991:	eb 06                	jmp    800999 <strncmp+0x17>
		n--, p++, q++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	39 d8                	cmp    %ebx,%eax
  80099b:	74 15                	je     8009b2 <strncmp+0x30>
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	74 04                	je     8009a8 <strncmp+0x26>
  8009a4:	3a 0a                	cmp    (%edx),%cl
  8009a6:	74 eb                	je     800993 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
  8009b0:	eb 05                	jmp    8009b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 07                	jmp    8009cd <strchr+0x13>
		if (*s == c)
  8009c6:	38 ca                	cmp    %cl,%dl
  8009c8:	74 0f                	je     8009d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f2                	jne    8009c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	eb 07                	jmp    8009ee <strfind+0x13>
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	74 0a                	je     8009f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	75 f2                	jne    8009e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	74 36                	je     800a3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0d:	75 28                	jne    800a37 <memset+0x40>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 23                	jne    800a37 <memset+0x40>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 18             	shl    $0x18,%esi
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 10             	shl    $0x10,%eax
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a32:	fc                   	cld    
  800a33:	f3 ab                	rep stos %eax,%es:(%edi)
  800a35:	eb 06                	jmp    800a3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a52:	39 c6                	cmp    %eax,%esi
  800a54:	73 35                	jae    800a8b <memmove+0x47>
  800a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 2e                	jae    800a8b <memmove+0x47>
		s += n;
		d += n;
  800a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 13                	jne    800a7f <memmove+0x3b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0e                	jne    800a7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 09                	jmp    800a88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7f:	83 ef 01             	sub    $0x1,%edi
  800a82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a85:	fd                   	std    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a88:	fc                   	cld    
  800a89:	eb 1d                	jmp    800aa8 <memmove+0x64>
  800a8b:	89 f2                	mov    %esi,%edx
  800a8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 0f                	jne    800aa3 <memmove+0x5f>
  800a94:	f6 c1 03             	test   $0x3,%cl
  800a97:	75 0a                	jne    800aa3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a99:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 05                	jmp    800aa8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 79 ff ff ff       	call   800a44 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 02             	movzbl (%edx),%eax
  800ae2:	0f b6 19             	movzbl (%ecx),%ebx
  800ae5:	38 d8                	cmp    %bl,%al
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f2                	cmp    %esi,%edx
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b14:	eb 07                	jmp    800b1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	38 08                	cmp    %cl,(%eax)
  800b18:	74 07                	je     800b21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	39 d0                	cmp    %edx,%eax
  800b1f:	72 f5                	jb     800b16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	eb 03                	jmp    800b34 <strtol+0x11>
		s++;
  800b31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	0f b6 0a             	movzbl (%edx),%ecx
  800b37:	80 f9 09             	cmp    $0x9,%cl
  800b3a:	74 f5                	je     800b31 <strtol+0xe>
  800b3c:	80 f9 20             	cmp    $0x20,%cl
  800b3f:	74 f0                	je     800b31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b41:	80 f9 2b             	cmp    $0x2b,%cl
  800b44:	75 0a                	jne    800b50 <strtol+0x2d>
		s++;
  800b46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4e:	eb 11                	jmp    800b61 <strtol+0x3e>
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b55:	80 f9 2d             	cmp    $0x2d,%cl
  800b58:	75 07                	jne    800b61 <strtol+0x3e>
		s++, neg = 1;
  800b5a:	8d 52 01             	lea    0x1(%edx),%edx
  800b5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b66:	75 15                	jne    800b7d <strtol+0x5a>
  800b68:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6b:	75 10                	jne    800b7d <strtol+0x5a>
  800b6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b71:	75 0a                	jne    800b7d <strtol+0x5a>
		s += 2, base = 16;
  800b73:	83 c2 02             	add    $0x2,%edx
  800b76:	b8 10 00 00 00       	mov    $0x10,%eax
  800b7b:	eb 10                	jmp    800b8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 0c                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b83:	80 3a 30             	cmpb   $0x30,(%edx)
  800b86:	75 05                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
  800b88:	83 c2 01             	add    $0x1,%edx
  800b8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b95:	0f b6 0a             	movzbl (%edx),%ecx
  800b98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b9b:	89 f0                	mov    %esi,%eax
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	77 08                	ja     800ba9 <strtol+0x86>
			dig = *s - '0';
  800ba1:	0f be c9             	movsbl %cl,%ecx
  800ba4:	83 e9 30             	sub    $0x30,%ecx
  800ba7:	eb 20                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	3c 19                	cmp    $0x19,%al
  800bb0:	77 08                	ja     800bba <strtol+0x97>
			dig = *s - 'a' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 57             	sub    $0x57,%ecx
  800bb8:	eb 0f                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	3c 19                	cmp    $0x19,%al
  800bc1:	77 16                	ja     800bd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bc3:	0f be c9             	movsbl %cl,%ecx
  800bc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bcc:	7d 0f                	jge    800bdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bce:	83 c2 01             	add    $0x1,%edx
  800bd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bd7:	eb bc                	jmp    800b95 <strtol+0x72>
  800bd9:	89 d8                	mov    %ebx,%eax
  800bdb:	eb 02                	jmp    800bdf <strtol+0xbc>
  800bdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be3:	74 05                	je     800bea <strtol+0xc7>
		*endptr = (char *) s;
  800be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bea:	f7 d8                	neg    %eax
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 44 c3             	cmove  %ebx,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	b8 03 00 00 00       	mov    $0x3,%eax
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 cb                	mov    %ecx,%ebx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	89 ce                	mov    %ecx,%esi
  800c4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 28                	jle    800c7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c60:	00 
  800c61:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800c68:	00 
  800c69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c70:	00 
  800c71:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800c78:	e8 1b 03 00 00       	call   800f98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	83 c4 2c             	add    $0x2c,%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800d0a:	e8 89 02 00 00       	call   800f98 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b8 05 00 00 00       	mov    $0x5,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 75 18             	mov    0x18(%ebp),%esi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 28                	jle    800d62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d45:	00 
  800d46:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d55:	00 
  800d56:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800d5d:	e8 36 02 00 00       	call   800f98 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d62:	83 c4 2c             	add    $0x2c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800db0:	e8 e3 01 00 00       	call   800f98 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 28                	jle    800e08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800deb:	00 
  800dec:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800df3:	00 
  800df4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfb:	00 
  800dfc:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800e03:	e8 90 01 00 00       	call   800f98 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e08:	83 c4 2c             	add    $0x2c,%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 de                	mov    %ebx,%esi
  800e2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800e56:	e8 3d 01 00 00       	call   800f98 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5b:	83 c4 2c             	add    $0x2c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 cb                	mov    %ecx,%ebx
  800e9e:	89 cf                	mov    %ecx,%edi
  800ea0:	89 ce                	mov    %ecx,%esi
  800ea2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800ecb:	e8 c8 00 00 00       	call   800f98 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed0:	83 c4 2c             	add    $0x2c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800ede:	c7 44 24 08 5f 15 80 	movl   $0x80155f,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800ef5:	e8 9e 00 00 00       	call   800f98 <_panic>

00800efa <sfork>:
}

// Challenge!
int
sfork(void)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f00:	c7 44 24 08 5e 15 80 	movl   $0x80155e,0x8(%esp)
  800f07:	00 
  800f08:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f0f:	00 
  800f10:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800f17:	e8 7c 00 00 00       	call   800f98 <_panic>

00800f1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f22:	c7 44 24 08 74 15 80 	movl   $0x801574,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 8d 15 80 00 	movl   $0x80158d,(%esp)
  800f39:	e8 5a 00 00 00       	call   800f98 <_panic>

00800f3e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f44:	c7 44 24 08 97 15 80 	movl   $0x801597,0x8(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f53:	00 
  800f54:	c7 04 24 8d 15 80 00 	movl   $0x80158d,(%esp)
  800f5b:	e8 38 00 00 00       	call   800f98 <_panic>

00800f60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f74:	8b 52 50             	mov    0x50(%edx),%edx
  800f77:	39 ca                	cmp    %ecx,%edx
  800f79:	75 0d                	jne    800f88 <ipc_find_env+0x28>
			return envs[i].env_id;
  800f7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800f83:	8b 40 40             	mov    0x40(%eax),%eax
  800f86:	eb 0e                	jmp    800f96 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f88:	83 c0 01             	add    $0x1,%eax
  800f8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f90:	75 d9                	jne    800f6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f92:	66 b8 00 00          	mov    $0x0,%ax
}
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fa0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fa3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fa9:	e8 d7 fc ff ff       	call   800c85 <sys_getenvid>
  800fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fbc:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc4:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  800fcb:	e8 63 f2 ff ff       	call   800233 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	e8 f3 f1 ff ff       	call   8001d2 <vcprintf>
	cprintf("\n");
  800fdf:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  800fe6:	e8 48 f2 ff ff       	call   800233 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800feb:	cc                   	int3   
  800fec:	eb fd                	jmp    800feb <_panic+0x53>
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ffa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ffe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801002:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801006:	85 c0                	test   %eax,%eax
  801008:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80100c:	89 ea                	mov    %ebp,%edx
  80100e:	89 0c 24             	mov    %ecx,(%esp)
  801011:	75 2d                	jne    801040 <__udivdi3+0x50>
  801013:	39 e9                	cmp    %ebp,%ecx
  801015:	77 61                	ja     801078 <__udivdi3+0x88>
  801017:	85 c9                	test   %ecx,%ecx
  801019:	89 ce                	mov    %ecx,%esi
  80101b:	75 0b                	jne    801028 <__udivdi3+0x38>
  80101d:	b8 01 00 00 00       	mov    $0x1,%eax
  801022:	31 d2                	xor    %edx,%edx
  801024:	f7 f1                	div    %ecx
  801026:	89 c6                	mov    %eax,%esi
  801028:	31 d2                	xor    %edx,%edx
  80102a:	89 e8                	mov    %ebp,%eax
  80102c:	f7 f6                	div    %esi
  80102e:	89 c5                	mov    %eax,%ebp
  801030:	89 f8                	mov    %edi,%eax
  801032:	f7 f6                	div    %esi
  801034:	89 ea                	mov    %ebp,%edx
  801036:	83 c4 0c             	add    $0xc,%esp
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	39 e8                	cmp    %ebp,%eax
  801042:	77 24                	ja     801068 <__udivdi3+0x78>
  801044:	0f bd e8             	bsr    %eax,%ebp
  801047:	83 f5 1f             	xor    $0x1f,%ebp
  80104a:	75 3c                	jne    801088 <__udivdi3+0x98>
  80104c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801050:	39 34 24             	cmp    %esi,(%esp)
  801053:	0f 86 9f 00 00 00    	jbe    8010f8 <__udivdi3+0x108>
  801059:	39 d0                	cmp    %edx,%eax
  80105b:	0f 82 97 00 00 00    	jb     8010f8 <__udivdi3+0x108>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	31 d2                	xor    %edx,%edx
  80106a:	31 c0                	xor    %eax,%eax
  80106c:	83 c4 0c             	add    $0xc,%esp
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    
  801073:	90                   	nop
  801074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801078:	89 f8                	mov    %edi,%eax
  80107a:	f7 f1                	div    %ecx
  80107c:	31 d2                	xor    %edx,%edx
  80107e:	83 c4 0c             	add    $0xc,%esp
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
  801085:	8d 76 00             	lea    0x0(%esi),%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	8b 3c 24             	mov    (%esp),%edi
  80108d:	d3 e0                	shl    %cl,%eax
  80108f:	89 c6                	mov    %eax,%esi
  801091:	b8 20 00 00 00       	mov    $0x20,%eax
  801096:	29 e8                	sub    %ebp,%eax
  801098:	89 c1                	mov    %eax,%ecx
  80109a:	d3 ef                	shr    %cl,%edi
  80109c:	89 e9                	mov    %ebp,%ecx
  80109e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010a2:	8b 3c 24             	mov    (%esp),%edi
  8010a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010a9:	89 d6                	mov    %edx,%esi
  8010ab:	d3 e7                	shl    %cl,%edi
  8010ad:	89 c1                	mov    %eax,%ecx
  8010af:	89 3c 24             	mov    %edi,(%esp)
  8010b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b6:	d3 ee                	shr    %cl,%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	d3 e2                	shl    %cl,%edx
  8010bc:	89 c1                	mov    %eax,%ecx
  8010be:	d3 ef                	shr    %cl,%edi
  8010c0:	09 d7                	or     %edx,%edi
  8010c2:	89 f2                	mov    %esi,%edx
  8010c4:	89 f8                	mov    %edi,%eax
  8010c6:	f7 74 24 08          	divl   0x8(%esp)
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	f7 24 24             	mull   (%esp)
  8010d1:	39 d6                	cmp    %edx,%esi
  8010d3:	89 14 24             	mov    %edx,(%esp)
  8010d6:	72 30                	jb     801108 <__udivdi3+0x118>
  8010d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010dc:	89 e9                	mov    %ebp,%ecx
  8010de:	d3 e2                	shl    %cl,%edx
  8010e0:	39 c2                	cmp    %eax,%edx
  8010e2:	73 05                	jae    8010e9 <__udivdi3+0xf9>
  8010e4:	3b 34 24             	cmp    (%esp),%esi
  8010e7:	74 1f                	je     801108 <__udivdi3+0x118>
  8010e9:	89 f8                	mov    %edi,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	e9 7a ff ff ff       	jmp    80106c <__udivdi3+0x7c>
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	31 d2                	xor    %edx,%edx
  8010fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ff:	e9 68 ff ff ff       	jmp    80106c <__udivdi3+0x7c>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 47 ff             	lea    -0x1(%edi),%eax
  80110b:	31 d2                	xor    %edx,%edx
  80110d:	83 c4 0c             	add    $0xc,%esp
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    
  801114:	66 90                	xchg   %ax,%ax
  801116:	66 90                	xchg   %ax,%ax
  801118:	66 90                	xchg   %ax,%ax
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	66 90                	xchg   %ax,%ax
  80111e:	66 90                	xchg   %ax,%ax

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	83 ec 14             	sub    $0x14,%esp
  801126:	8b 44 24 28          	mov    0x28(%esp),%eax
  80112a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80112e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801132:	89 c7                	mov    %eax,%edi
  801134:	89 44 24 04          	mov    %eax,0x4(%esp)
  801138:	8b 44 24 30          	mov    0x30(%esp),%eax
  80113c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801140:	89 34 24             	mov    %esi,(%esp)
  801143:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801147:	85 c0                	test   %eax,%eax
  801149:	89 c2                	mov    %eax,%edx
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	75 17                	jne    801168 <__umoddi3+0x48>
  801151:	39 fe                	cmp    %edi,%esi
  801153:	76 4b                	jbe    8011a0 <__umoddi3+0x80>
  801155:	89 c8                	mov    %ecx,%eax
  801157:	89 fa                	mov    %edi,%edx
  801159:	f7 f6                	div    %esi
  80115b:	89 d0                	mov    %edx,%eax
  80115d:	31 d2                	xor    %edx,%edx
  80115f:	83 c4 14             	add    $0x14,%esp
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    
  801166:	66 90                	xchg   %ax,%ax
  801168:	39 f8                	cmp    %edi,%eax
  80116a:	77 54                	ja     8011c0 <__umoddi3+0xa0>
  80116c:	0f bd e8             	bsr    %eax,%ebp
  80116f:	83 f5 1f             	xor    $0x1f,%ebp
  801172:	75 5c                	jne    8011d0 <__umoddi3+0xb0>
  801174:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801178:	39 3c 24             	cmp    %edi,(%esp)
  80117b:	0f 87 e7 00 00 00    	ja     801268 <__umoddi3+0x148>
  801181:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801185:	29 f1                	sub    %esi,%ecx
  801187:	19 c7                	sbb    %eax,%edi
  801189:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801191:	8b 44 24 08          	mov    0x8(%esp),%eax
  801195:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801199:	83 c4 14             	add    $0x14,%esp
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    
  8011a0:	85 f6                	test   %esi,%esi
  8011a2:	89 f5                	mov    %esi,%ebp
  8011a4:	75 0b                	jne    8011b1 <__umoddi3+0x91>
  8011a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	f7 f6                	div    %esi
  8011af:	89 c5                	mov    %eax,%ebp
  8011b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011b5:	31 d2                	xor    %edx,%edx
  8011b7:	f7 f5                	div    %ebp
  8011b9:	89 c8                	mov    %ecx,%eax
  8011bb:	f7 f5                	div    %ebp
  8011bd:	eb 9c                	jmp    80115b <__umoddi3+0x3b>
  8011bf:	90                   	nop
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 fa                	mov    %edi,%edx
  8011c4:	83 c4 14             	add    $0x14,%esp
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	8b 04 24             	mov    (%esp),%eax
  8011d3:	be 20 00 00 00       	mov    $0x20,%esi
  8011d8:	89 e9                	mov    %ebp,%ecx
  8011da:	29 ee                	sub    %ebp,%esi
  8011dc:	d3 e2                	shl    %cl,%edx
  8011de:	89 f1                	mov    %esi,%ecx
  8011e0:	d3 e8                	shr    %cl,%eax
  8011e2:	89 e9                	mov    %ebp,%ecx
  8011e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e8:	8b 04 24             	mov    (%esp),%eax
  8011eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011ef:	89 fa                	mov    %edi,%edx
  8011f1:	d3 e0                	shl    %cl,%eax
  8011f3:	89 f1                	mov    %esi,%ecx
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011fd:	d3 ea                	shr    %cl,%edx
  8011ff:	89 e9                	mov    %ebp,%ecx
  801201:	d3 e7                	shl    %cl,%edi
  801203:	89 f1                	mov    %esi,%ecx
  801205:	d3 e8                	shr    %cl,%eax
  801207:	89 e9                	mov    %ebp,%ecx
  801209:	09 f8                	or     %edi,%eax
  80120b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80120f:	f7 74 24 04          	divl   0x4(%esp)
  801213:	d3 e7                	shl    %cl,%edi
  801215:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801219:	89 d7                	mov    %edx,%edi
  80121b:	f7 64 24 08          	mull   0x8(%esp)
  80121f:	39 d7                	cmp    %edx,%edi
  801221:	89 c1                	mov    %eax,%ecx
  801223:	89 14 24             	mov    %edx,(%esp)
  801226:	72 2c                	jb     801254 <__umoddi3+0x134>
  801228:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80122c:	72 22                	jb     801250 <__umoddi3+0x130>
  80122e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801232:	29 c8                	sub    %ecx,%eax
  801234:	19 d7                	sbb    %edx,%edi
  801236:	89 e9                	mov    %ebp,%ecx
  801238:	89 fa                	mov    %edi,%edx
  80123a:	d3 e8                	shr    %cl,%eax
  80123c:	89 f1                	mov    %esi,%ecx
  80123e:	d3 e2                	shl    %cl,%edx
  801240:	89 e9                	mov    %ebp,%ecx
  801242:	d3 ef                	shr    %cl,%edi
  801244:	09 d0                	or     %edx,%eax
  801246:	89 fa                	mov    %edi,%edx
  801248:	83 c4 14             	add    $0x14,%esp
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    
  80124f:	90                   	nop
  801250:	39 d7                	cmp    %edx,%edi
  801252:	75 da                	jne    80122e <__umoddi3+0x10e>
  801254:	8b 14 24             	mov    (%esp),%edx
  801257:	89 c1                	mov    %eax,%ecx
  801259:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80125d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801261:	eb cb                	jmp    80122e <__umoddi3+0x10e>
  801263:	90                   	nop
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80126c:	0f 82 0f ff ff ff    	jb     801181 <__umoddi3+0x61>
  801272:	e9 1a ff ff ff       	jmp    801191 <__umoddi3+0x71>
