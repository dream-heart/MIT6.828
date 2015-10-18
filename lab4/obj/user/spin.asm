
obj/user/spin：     文件格式 elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80004e:	e8 74 01 00 00       	call   8001c7 <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 74 0e 00 00       	call   800ecc <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 78 12 80 00 	movl   $0x801278,(%esp)
  800065:	e8 5d 01 00 00       	call   8001c7 <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 28 12 80 00 	movl   $0x801228,(%esp)
  800073:	e8 4f 01 00 00       	call   8001c7 <cprintf>
	sys_yield();
  800078:	e8 b7 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80007d:	e8 b2 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800082:	e8 ad 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800087:	e8 a8 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 9f 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  800095:	e8 9a 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80009a:	e8 95 0b 00 00       	call   800c34 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 8f 0b 00 00       	call   800c34 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 50 12 80 00 	movl   $0x801250,(%esp)
  8000ac:	e8 16 01 00 00       	call   8001c7 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ee 0a 00 00       	call   800ba7 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
  8000bf:	90                   	nop

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000d2:	e8 2d 0b 00 00       	call   800c04 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 40 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
  80010f:	90                   	nop

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800116:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011d:	e8 85 0a 00 00       	call   800ba7 <sys_env_destroy>
}
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 14             	sub    $0x14,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800137:	83 c0 01             	add    $0x1,%eax
  80013a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800141:	75 19                	jne    80015c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800143:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014a:	00 
  80014b:	8d 43 08             	lea    0x8(%ebx),%eax
  80014e:	89 04 24             	mov    %eax,(%esp)
  800151:	e8 f2 09 00 00       	call   800b48 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800160:	83 c4 14             	add    $0x14,%esp
  800163:	5b                   	pop    %ebx
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800176:	00 00 00 
	b.cnt = 0;
  800179:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800180:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800183:	8b 45 0c             	mov    0xc(%ebp),%eax
  800186:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800191:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	c7 04 24 24 01 80 00 	movl   $0x800124,(%esp)
  8001a2:	e8 96 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 89 09 00 00       	call   800b48 <sys_cputs>

	return b.cnt;
}
  8001bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 87 ff ff ff       	call   800166 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    
  8001e1:	66 90                	xchg   %ax,%ax
  8001e3:	66 90                	xchg   %ax,%ax
  8001e5:	66 90                	xchg   %ax,%ax
  8001e7:	66 90                	xchg   %ax,%ax
  8001e9:	66 90                	xchg   %ax,%ax
  8001eb:	66 90                	xchg   %ax,%ax
  8001ed:	66 90                	xchg   %ax,%ax
  8001ef:	90                   	nop

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	85 c0                	test   %eax,%eax
  800212:	75 08                	jne    80021c <printnum+0x2c>
  800214:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 59                	ja     800275 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800227:	8b 45 10             	mov    0x10(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800232:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800236:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023d:	00 
  80023e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	e8 20 0d 00 00       	call   800f70 <__udivdi3>
  800250:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800254:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	89 fa                	mov    %edi,%edx
  800261:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800264:	e8 87 ff ff ff       	call   8001f0 <printnum>
  800269:	eb 11                	jmp    80027c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026f:	89 34 24             	mov    %esi,(%esp)
  800272:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f ef                	jg     80026b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800280:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800284:	8b 45 10             	mov    0x10(%ebp),%eax
  800287:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800292:	00 
  800293:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800296:	89 04 24             	mov    %eax,(%esp)
  800299:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	e8 fb 0d 00 00       	call   8010a0 <__umoddi3>
  8002a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a9:	0f be 80 a0 12 80 00 	movsbl 0x8012a0(%eax),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b6:	83 c4 3c             	add    $0x3c,%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030c:	88 0a                	mov    %cl,(%edx)
  80030e:	83 c2 01             	add    $0x1,%edx
  800311:	89 10                	mov    %edx,(%eax)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800322:	8b 45 10             	mov    0x10(%ebp),%eax
  800325:	89 44 24 08          	mov    %eax,0x8(%esp)
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	e8 02 00 00 00       	call   80033d <vprintfmt>
	va_end(ap);
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 4c             	sub    $0x4c,%esp
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 75 10             	mov    0x10(%ebp),%esi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 bf 03 00 00    	je     800715 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	0f b6 06             	movzbl (%esi),%eax
  800363:	83 c6 01             	add    $0x1,%esi
  800366:	83 f8 25             	cmp    $0x25,%eax
  800369:	75 e3                	jne    80034e <vprintfmt+0x11>
  80036b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80036f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800376:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80037b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80038a:	eb 2b                	jmp    8003b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800393:	eb 22                	jmp    8003b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80039c:	eb 19                	jmp    8003b7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a8:	eb 0d                	jmp    8003b7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	0f b6 16             	movzbl (%esi),%edx
  8003ba:	0f b6 c2             	movzbl %dl,%eax
  8003bd:	8d 7e 01             	lea    0x1(%esi),%edi
  8003c0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003c3:	83 ea 23             	sub    $0x23,%edx
  8003c6:	80 fa 55             	cmp    $0x55,%dl
  8003c9:	0f 87 28 03 00 00    	ja     8006f7 <vprintfmt+0x3ba>
  8003cf:	0f b6 d2             	movzbl %dl,%edx
  8003d2:	ff 24 95 60 13 80 00 	jmp    *0x801360(,%edx,4)
  8003d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003dc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003e3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003eb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ef:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003f5:	83 fa 09             	cmp    $0x9,%edx
  8003f8:	77 2f                	ja     800429 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fd:	eb e9                	jmp    8003e8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800410:	eb 1a                	jmp    80042c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800419:	79 9c                	jns    8003b7 <vprintfmt+0x7a>
  80041b:	eb 81                	jmp    80039e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800420:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800427:	eb 8e                	jmp    8003b7 <vprintfmt+0x7a>
  800429:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80042c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800430:	79 85                	jns    8003b7 <vprintfmt+0x7a>
  800432:	e9 73 ff ff ff       	jmp    8003aa <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043d:	e9 75 ff ff ff       	jmp    8003b7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045a:	e9 01 ff ff ff       	jmp    800360 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	89 c2                	mov    %eax,%edx
  80046c:	c1 fa 1f             	sar    $0x1f,%edx
  80046f:	31 d0                	xor    %edx,%eax
  800471:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 09             	cmp    $0x9,%eax
  800476:	7f 0b                	jg     800483 <vprintfmt+0x146>
  800478:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	75 23                	jne    8004a6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800487:	c7 44 24 08 b8 12 80 	movl   $0x8012b8,0x8(%esp)
  80048e:	00 
  80048f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800493:	8b 7d 08             	mov    0x8(%ebp),%edi
  800496:	89 3c 24             	mov    %edi,(%esp)
  800499:	e8 77 fe ff ff       	call   800315 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 ba fe ff ff       	jmp    800360 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004aa:	c7 44 24 08 c1 12 80 	movl   $0x8012c1,0x8(%esp)
  8004b1:	00 
  8004b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004b9:	89 3c 24             	mov    %edi,(%esp)
  8004bc:	e8 54 fe ff ff       	call   800315 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c4:	e9 97 fe ff ff       	jmp    800360 <vprintfmt+0x23>
  8004c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004dd:	85 f6                	test   %esi,%esi
  8004df:	ba b1 12 80 00       	mov    $0x8012b1,%edx
  8004e4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004eb:	0f 8e 8c 00 00 00    	jle    80057d <vprintfmt+0x240>
  8004f1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f5:	0f 84 82 00 00 00    	je     80057d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ff:	89 34 24             	mov    %esi,(%esp)
  800502:	e8 b1 02 00 00       	call   8007b8 <strnlen>
  800507:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80050f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800513:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800516:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800519:	89 de                	mov    %ebx,%esi
  80051b:	89 d3                	mov    %edx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0d                	jmp    80052e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	89 3c 24             	mov    %edi,(%esp)
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	83 eb 01             	sub    $0x1,%ebx
  80052e:	85 db                	test   %ebx,%ebx
  800530:	7f ef                	jg     800521 <vprintfmt+0x1e4>
  800532:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800535:	89 f3                	mov    %esi,%ebx
  800537:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80053a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053e:	b8 00 00 00 00       	mov    $0x0,%eax
  800543:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800547:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054f:	eb 2c                	jmp    80057d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800555:	74 18                	je     80056f <vprintfmt+0x232>
  800557:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055a:	83 fa 5e             	cmp    $0x5e,%edx
  80055d:	76 10                	jbe    80056f <vprintfmt+0x232>
					putch('?', putdat);
  80055f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800563:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056a:	ff 55 08             	call   *0x8(%ebp)
  80056d:	eb 0a                	jmp    800579 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80056f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800579:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80057d:	0f be 06             	movsbl (%esi),%eax
  800580:	83 c6 01             	add    $0x1,%esi
  800583:	85 c0                	test   %eax,%eax
  800585:	74 25                	je     8005ac <vprintfmt+0x26f>
  800587:	85 ff                	test   %edi,%edi
  800589:	78 c6                	js     800551 <vprintfmt+0x214>
  80058b:	83 ef 01             	sub    $0x1,%edi
  80058e:	79 c1                	jns    800551 <vprintfmt+0x214>
  800590:	8b 7d 08             	mov    0x8(%ebp),%edi
  800593:	89 de                	mov    %ebx,%esi
  800595:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800598:	eb 1a                	jmp    8005b4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 eb 01             	sub    $0x1,%ebx
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x277>
  8005ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005af:	89 de                	mov    %ebx,%esi
  8005b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f e2                	jg     80059a <vprintfmt+0x25d>
  8005b8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005bb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c0:	e9 9b fd ff ff       	jmp    800360 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c5:	83 f9 01             	cmp    $0x1,%ecx
  8005c8:	7e 10                	jle    8005da <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 08             	lea    0x8(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 30                	mov    (%eax),%esi
  8005d5:	8b 78 04             	mov    0x4(%eax),%edi
  8005d8:	eb 26                	jmp    800600 <vprintfmt+0x2c3>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 12                	je     8005f0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	89 f7                	mov    %esi,%edi
  8005eb:	c1 ff 1f             	sar    $0x1f,%edi
  8005ee:	eb 10                	jmp    800600 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 30                	mov    (%eax),%esi
  8005fb:	89 f7                	mov    %esi,%edi
  8005fd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800600:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800605:	85 ff                	test   %edi,%edi
  800607:	0f 89 ac 00 00 00    	jns    8006b9 <vprintfmt+0x37c>
				putch('-', putdat);
  80060d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800611:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80061b:	f7 de                	neg    %esi
  80061d:	83 d7 00             	adc    $0x0,%edi
  800620:	f7 df                	neg    %edi
			}
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
  800627:	e9 8d 00 00 00       	jmp    8006b9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 88 fc ff ff       	call   8002be <getuint>
  800636:	89 c6                	mov    %eax,%esi
  800638:	89 d7                	mov    %edx,%edi
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063f:	eb 78                	jmp    8006b9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80064f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800653:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80065a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80065d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800661:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80066e:	e9 ed fc ff ff       	jmp    800360 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800673:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800677:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800681:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800685:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80068c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800698:	8b 30                	mov    (%eax),%esi
  80069a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a4:	eb 13                	jmp    8006b9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	89 ca                	mov    %ecx,%edx
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ab:	e8 0e fc ff ff       	call   8002be <getuint>
  8006b0:	89 c6                	mov    %eax,%esi
  8006b2:	89 d7                	mov    %edx,%edi
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cc:	89 34 24             	mov    %esi,(%esp)
  8006cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d3:	89 da                	mov    %ebx,%edx
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	e8 13 fb ff ff       	call   8001f0 <printnum>
			break;
  8006dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e0:	e9 7b fc ff ff       	jmp    800360 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e9:	89 04 24             	mov    %eax,(%esp)
  8006ec:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f2:	e9 69 fc ff ff       	jmp    800360 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800702:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800705:	eb 03                	jmp    80070a <vprintfmt+0x3cd>
  800707:	83 ee 01             	sub    $0x1,%esi
  80070a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070e:	75 f7                	jne    800707 <vprintfmt+0x3ca>
  800710:	e9 4b fc ff ff       	jmp    800360 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800715:	83 c4 4c             	add    $0x4c,%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 28             	sub    $0x28,%esp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800730:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 30                	je     80076e <vsnprintf+0x51>
  80073e:	85 d2                	test   %edx,%edx
  800740:	7e 2c                	jle    80076e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800749:	8b 45 10             	mov    0x10(%ebp),%eax
  80074c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800750:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800753:	89 44 24 04          	mov    %eax,0x4(%esp)
  800757:	c7 04 24 f8 02 80 00 	movl   $0x8002f8,(%esp)
  80075e:	e8 da fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	eb 05                	jmp    800773 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 82 ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    
  80079d:	66 90                	xchg   %ax,%ax
  80079f:	90                   	nop

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	eb 03                	jmp    8007b0 <strlen+0x10>
		n++;
  8007ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b4:	75 f7                	jne    8007ad <strlen+0xd>
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 03                	jmp    8007cb <strnlen+0x13>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	39 d0                	cmp    %edx,%eax
  8007cd:	74 06                	je     8007d5 <strnlen+0x1d>
  8007cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d3:	75 f3                	jne    8007c8 <strnlen+0x10>
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ea:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	75 f2                	jne    8007e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800801:	89 1c 24             	mov    %ebx,(%esp)
  800804:	e8 97 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800810:	01 d8                	add    %ebx,%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 bd ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  80081a:	89 d8                	mov    %ebx,%eax
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	b9 00 00 00 00       	mov    $0x0,%ecx
  800835:	eb 0f                	jmp    800846 <strncpy+0x24>
		*dst++ = *src;
  800837:	0f b6 1a             	movzbl (%edx),%ebx
  80083a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083d:	80 3a 01             	cmpb   $0x1,(%edx)
  800840:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	39 f1                	cmp    %esi,%ecx
  800848:	75 ed                	jne    800837 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 75 08             	mov    0x8(%ebp),%esi
  800856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800859:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	85 d2                	test   %edx,%edx
  800860:	75 0a                	jne    80086c <strlcpy+0x1e>
  800862:	eb 1d                	jmp    800881 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800864:	88 18                	mov    %bl,(%eax)
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	83 ea 01             	sub    $0x1,%edx
  80086f:	74 0b                	je     80087c <strlcpy+0x2e>
  800871:	0f b6 19             	movzbl (%ecx),%ebx
  800874:	84 db                	test   %bl,%bl
  800876:	75 ec                	jne    800864 <strlcpy+0x16>
  800878:	89 c2                	mov    %eax,%edx
  80087a:	eb 02                	jmp    80087e <strlcpy+0x30>
  80087c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80087e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800881:	29 f0                	sub    %esi,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	eb 06                	jmp    800898 <strcmp+0x11>
		p++, q++;
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	0f b6 01             	movzbl (%ecx),%eax
  80089b:	84 c0                	test   %al,%al
  80089d:	74 04                	je     8008a3 <strcmp+0x1c>
  80089f:	3a 02                	cmp    (%edx),%al
  8008a1:	74 ef                	je     800892 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 c0             	movzbl %al,%eax
  8008a6:	0f b6 12             	movzbl (%edx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008ba:	eb 09                	jmp    8008c5 <strncmp+0x18>
		n--, p++, q++;
  8008bc:	83 ea 01             	sub    $0x1,%edx
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c5:	85 d2                	test   %edx,%edx
  8008c7:	74 15                	je     8008de <strncmp+0x31>
  8008c9:	0f b6 18             	movzbl (%eax),%ebx
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	74 04                	je     8008d4 <strncmp+0x27>
  8008d0:	3a 19                	cmp    (%ecx),%bl
  8008d2:	74 e8                	je     8008bc <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 00             	movzbl (%eax),%eax
  8008d7:	0f b6 11             	movzbl (%ecx),%edx
  8008da:	29 d0                	sub    %edx,%eax
  8008dc:	eb 05                	jmp    8008e3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	eb 07                	jmp    8008f9 <strchr+0x13>
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 0f                	je     800905 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	0f b6 10             	movzbl (%eax),%edx
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	75 f2                	jne    8008f2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800911:	eb 07                	jmp    80091a <strfind+0x13>
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 0a                	je     800921 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	0f b6 10             	movzbl (%eax),%edx
  80091d:	84 d2                	test   %dl,%dl
  80091f:	75 f2                	jne    800913 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80092c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80092f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800932:	8b 7d 08             	mov    0x8(%ebp),%edi
  800935:	8b 45 0c             	mov    0xc(%ebp),%eax
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 30                	je     80096f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 25                	jne    80096c <memset+0x49>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 20                	jne    80096c <memset+0x49>
		c &= 0xFF;
  80094c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 18             	shl    $0x18,%esi
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 10             	shl    $0x10,%eax
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 d0                	or     %edx,%eax
  800962:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800964:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800967:	fc                   	cld    
  800968:	f3 ab                	rep stos %eax,%es:(%edi)
  80096a:	eb 03                	jmp    80096f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800974:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800977:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80097a:	89 ec                	mov    %ebp,%esp
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 08             	sub    $0x8,%esp
  800984:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800987:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 36                	jae    8009cd <memmove+0x4f>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	73 2f                	jae    8009cd <memmove+0x4f>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	f6 c2 03             	test   $0x3,%dl
  8009a4:	75 1b                	jne    8009c1 <memmove+0x43>
  8009a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ac:	75 13                	jne    8009c1 <memmove+0x43>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0e                	jne    8009c1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b3:	83 ef 04             	sub    $0x4,%edi
  8009b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bc:	fd                   	std    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 09                	jmp    8009ca <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c1:	83 ef 01             	sub    $0x1,%edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 20                	jmp    8009ed <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d3:	75 13                	jne    8009e8 <memmove+0x6a>
  8009d5:	a8 03                	test   $0x3,%al
  8009d7:	75 0f                	jne    8009e8 <memmove+0x6a>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 0a                	jne    8009e8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009de:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 05                	jmp    8009ed <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009f3:	89 ec                	mov    %ebp,%esp
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800a00:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	89 04 24             	mov    %eax,(%esp)
  800a11:	e8 68 ff ff ff       	call   80097e <memmove>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2c:	eb 1a                	jmp    800a48 <memcmp+0x30>
		if (*s1 != *s2)
  800a2e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a32:	83 c2 01             	add    $0x1,%edx
  800a35:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a3a:	38 c8                	cmp    %cl,%al
  800a3c:	74 0a                	je     800a48 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c0             	movzbl %al,%eax
  800a41:	0f b6 c9             	movzbl %cl,%ecx
  800a44:	29 c8                	sub    %ecx,%eax
  800a46:	eb 09                	jmp    800a51 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	39 da                	cmp    %ebx,%edx
  800a4a:	75 e2                	jne    800a2e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
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
  800a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800a84:	0f b6 02             	movzbl (%edx),%eax
  800a87:	3c 20                	cmp    $0x20,%al
  800a89:	74 f6                	je     800a81 <strtol+0xe>
  800a8b:	3c 09                	cmp    $0x9,%al
  800a8d:	74 f2                	je     800a81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8f:	3c 2b                	cmp    $0x2b,%al
  800a91:	75 0a                	jne    800a9d <strtol+0x2a>
		s++;
  800a93:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a96:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9b:	eb 10                	jmp    800aad <strtol+0x3a>
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa2:	3c 2d                	cmp    $0x2d,%al
  800aa4:	75 07                	jne    800aad <strtol+0x3a>
		s++, neg = 1;
  800aa6:	8d 52 01             	lea    0x1(%edx),%edx
  800aa9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	0f 94 c0             	sete   %al
  800ab2:	74 05                	je     800ab9 <strtol+0x46>
  800ab4:	83 fb 10             	cmp    $0x10,%ebx
  800ab7:	75 15                	jne    800ace <strtol+0x5b>
  800ab9:	80 3a 30             	cmpb   $0x30,(%edx)
  800abc:	75 10                	jne    800ace <strtol+0x5b>
  800abe:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac2:	75 0a                	jne    800ace <strtol+0x5b>
		s += 2, base = 16;
  800ac4:	83 c2 02             	add    $0x2,%edx
  800ac7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acc:	eb 13                	jmp    800ae1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ace:	84 c0                	test   %al,%al
  800ad0:	74 0f                	je     800ae1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	80 3a 30             	cmpb   $0x30,(%edx)
  800ada:	75 05                	jne    800ae1 <strtol+0x6e>
		s++, base = 8;
  800adc:	83 c2 01             	add    $0x1,%edx
  800adf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae8:	0f b6 0a             	movzbl (%edx),%ecx
  800aeb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aee:	80 fb 09             	cmp    $0x9,%bl
  800af1:	77 08                	ja     800afb <strtol+0x88>
			dig = *s - '0';
  800af3:	0f be c9             	movsbl %cl,%ecx
  800af6:	83 e9 30             	sub    $0x30,%ecx
  800af9:	eb 1e                	jmp    800b19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 08                	ja     800b0b <strtol+0x98>
			dig = *s - 'a' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 57             	sub    $0x57,%ecx
  800b09:	eb 0e                	jmp    800b19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 14                	ja     800b27 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800b13:	0f be c9             	movsbl %cl,%ecx
  800b16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b19:	39 f1                	cmp    %esi,%ecx
  800b1b:	7d 0e                	jge    800b2b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800b1d:	83 c2 01             	add    $0x1,%edx
  800b20:	0f af c6             	imul   %esi,%eax
  800b23:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b25:	eb c1                	jmp    800ae8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b27:	89 c1                	mov    %eax,%ecx
  800b29:	eb 02                	jmp    800b2d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 05                	je     800b38 <strtol+0xc5>
		*endptr = (char *) s;
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b36:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b38:	89 ca                	mov    %ecx,%edx
  800b3a:	f7 da                	neg    %edx
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	0f 45 c2             	cmovne %edx,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
  800b46:	66 90                	xchg   %ax,%ax

00800b48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b54:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	89 c6                	mov    %eax,%esi
  800b68:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b73:	89 ec                	mov    %ebp,%esp
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba3:	89 ec                	mov    %ebp,%esp
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 38             	sub    $0x38,%esp
  800bad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	89 cb                	mov    %ecx,%ebx
  800bc5:	89 cf                	mov    %ecx,%edi
  800bc7:	89 ce                	mov    %ecx,%esi
  800bc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 28                	jle    800bf7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bda:	00 
  800bdb:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800be2:	00 
  800be3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bea:	00 
  800beb:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800bf2:	e8 19 03 00 00       	call   800f10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c00:	89 ec                	mov    %ebp,%esp
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c30:	89 ec                	mov    %ebp,%esp
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_yield>:

void
sys_yield(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c60:	89 ec                	mov    %ebp,%esp
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 38             	sub    $0x38,%esp
  800c6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c70:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	be 00 00 00 00       	mov    $0x0,%esi
  800c78:	b8 04 00 00 00       	mov    $0x4,%eax
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 f7                	mov    %esi,%edi
  800c88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 28                	jle    800cb6 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c92:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c99:	00 
  800c9a:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800ca1:	00 
  800ca2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca9:	00 
  800caa:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800cb1:	e8 5a 02 00 00       	call   800f10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbf:	89 ec                	mov    %ebp,%esp
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 38             	sub    $0x38,%esp
  800cc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ccc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ccf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 28                	jle    800d14 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800cff:	00 
  800d00:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d07:	00 
  800d08:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800d0f:	e8 fc 01 00 00       	call   800f10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d17:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d1a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d1d:	89 ec                	mov    %ebp,%esp
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 38             	sub    $0x38,%esp
  800d27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 28                	jle    800d72 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d55:	00 
  800d56:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800d5d:	00 
  800d5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d65:	00 
  800d66:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800d6d:	e8 9e 01 00 00       	call   800f10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d72:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d75:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d78:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d7b:	89 ec                	mov    %ebp,%esp
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 38             	sub    $0x38,%esp
  800d85:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d88:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 08 00 00 00       	mov    $0x8,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 28                	jle    800dd0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dac:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db3:	00 
  800db4:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc3:	00 
  800dc4:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800dcb:	e8 40 01 00 00       	call   800f10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd9:	89 ec                	mov    %ebp,%esp
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	83 ec 38             	sub    $0x38,%esp
  800de3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df1:	b8 09 00 00 00       	mov    $0x9,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	89 df                	mov    %ebx,%edi
  800dfe:	89 de                	mov    %ebx,%esi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 28                	jle    800e2e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e11:	00 
  800e12:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800e19:	00 
  800e1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800e29:	e8 e2 00 00 00       	call   800f10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e37:	89 ec                	mov    %ebp,%esp
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	be 00 00 00 00       	mov    $0x0,%esi
  800e4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6b:	89 ec                	mov    %ebp,%esp
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 38             	sub    $0x38,%esp
  800e75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	89 cb                	mov    %ecx,%ebx
  800e8d:	89 cf                	mov    %ecx,%edi
  800e8f:	89 ce                	mov    %ecx,%esi
  800e91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 28                	jle    800ebf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb2:	00 
  800eb3:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800eba:	e8 51 00 00 00       	call   800f10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800ed2:	c7 44 24 08 1f 15 80 	movl   $0x80151f,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 13 15 80 00 	movl   $0x801513,(%esp)
  800ee9:	e8 22 00 00 00       	call   800f10 <_panic>

00800eee <sfork>:
}

// Challenge!
int
sfork(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800ef4:	c7 44 24 08 1e 15 80 	movl   $0x80151e,0x8(%esp)
  800efb:	00 
  800efc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f03:	00 
  800f04:	c7 04 24 13 15 80 00 	movl   $0x801513,(%esp)
  800f0b:	e8 00 00 00 00       	call   800f10 <_panic>

00800f10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f18:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f1b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f21:	e8 de fc ff ff       	call   800c04 <sys_getenvid>
  800f26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f29:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3c:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  800f43:	e8 7f f2 ff ff       	call   8001c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 0f f2 ff ff       	call   800166 <vcprintf>
	cprintf("\n");
  800f57:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800f5e:	e8 64 f2 ff ff       	call   8001c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f63:	cc                   	int3   
  800f64:	eb fd                	jmp    800f63 <_panic+0x53>
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__udivdi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f86:	85 c0                	test   %eax,%eax
  800f88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f8c:	89 ea                	mov    %ebp,%edx
  800f8e:	89 0c 24             	mov    %ecx,(%esp)
  800f91:	75 2d                	jne    800fc0 <__udivdi3+0x50>
  800f93:	39 e9                	cmp    %ebp,%ecx
  800f95:	77 61                	ja     800ff8 <__udivdi3+0x88>
  800f97:	85 c9                	test   %ecx,%ecx
  800f99:	89 ce                	mov    %ecx,%esi
  800f9b:	75 0b                	jne    800fa8 <__udivdi3+0x38>
  800f9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa2:	31 d2                	xor    %edx,%edx
  800fa4:	f7 f1                	div    %ecx
  800fa6:	89 c6                	mov    %eax,%esi
  800fa8:	31 d2                	xor    %edx,%edx
  800faa:	89 e8                	mov    %ebp,%eax
  800fac:	f7 f6                	div    %esi
  800fae:	89 c5                	mov    %eax,%ebp
  800fb0:	89 f8                	mov    %edi,%eax
  800fb2:	f7 f6                	div    %esi
  800fb4:	89 ea                	mov    %ebp,%edx
  800fb6:	83 c4 0c             	add    $0xc,%esp
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
  800fc0:	39 e8                	cmp    %ebp,%eax
  800fc2:	77 24                	ja     800fe8 <__udivdi3+0x78>
  800fc4:	0f bd e8             	bsr    %eax,%ebp
  800fc7:	83 f5 1f             	xor    $0x1f,%ebp
  800fca:	75 3c                	jne    801008 <__udivdi3+0x98>
  800fcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fd0:	39 34 24             	cmp    %esi,(%esp)
  800fd3:	0f 86 9f 00 00 00    	jbe    801078 <__udivdi3+0x108>
  800fd9:	39 d0                	cmp    %edx,%eax
  800fdb:	0f 82 97 00 00 00    	jb     801078 <__udivdi3+0x108>
  800fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	31 c0                	xor    %eax,%eax
  800fec:	83 c4 0c             	add    $0xc,%esp
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    
  800ff3:	90                   	nop
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	89 f8                	mov    %edi,%eax
  800ffa:	f7 f1                	div    %ecx
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	83 c4 0c             	add    $0xc,%esp
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    
  801005:	8d 76 00             	lea    0x0(%esi),%esi
  801008:	89 e9                	mov    %ebp,%ecx
  80100a:	8b 3c 24             	mov    (%esp),%edi
  80100d:	d3 e0                	shl    %cl,%eax
  80100f:	89 c6                	mov    %eax,%esi
  801011:	b8 20 00 00 00       	mov    $0x20,%eax
  801016:	29 e8                	sub    %ebp,%eax
  801018:	89 c1                	mov    %eax,%ecx
  80101a:	d3 ef                	shr    %cl,%edi
  80101c:	89 e9                	mov    %ebp,%ecx
  80101e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801022:	8b 3c 24             	mov    (%esp),%edi
  801025:	09 74 24 08          	or     %esi,0x8(%esp)
  801029:	89 d6                	mov    %edx,%esi
  80102b:	d3 e7                	shl    %cl,%edi
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 3c 24             	mov    %edi,(%esp)
  801032:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801036:	d3 ee                	shr    %cl,%esi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	d3 e2                	shl    %cl,%edx
  80103c:	89 c1                	mov    %eax,%ecx
  80103e:	d3 ef                	shr    %cl,%edi
  801040:	09 d7                	or     %edx,%edi
  801042:	89 f2                	mov    %esi,%edx
  801044:	89 f8                	mov    %edi,%eax
  801046:	f7 74 24 08          	divl   0x8(%esp)
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	89 c7                	mov    %eax,%edi
  80104e:	f7 24 24             	mull   (%esp)
  801051:	39 d6                	cmp    %edx,%esi
  801053:	89 14 24             	mov    %edx,(%esp)
  801056:	72 30                	jb     801088 <__udivdi3+0x118>
  801058:	8b 54 24 04          	mov    0x4(%esp),%edx
  80105c:	89 e9                	mov    %ebp,%ecx
  80105e:	d3 e2                	shl    %cl,%edx
  801060:	39 c2                	cmp    %eax,%edx
  801062:	73 05                	jae    801069 <__udivdi3+0xf9>
  801064:	3b 34 24             	cmp    (%esp),%esi
  801067:	74 1f                	je     801088 <__udivdi3+0x118>
  801069:	89 f8                	mov    %edi,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	e9 7a ff ff ff       	jmp    800fec <__udivdi3+0x7c>
  801072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801078:	31 d2                	xor    %edx,%edx
  80107a:	b8 01 00 00 00       	mov    $0x1,%eax
  80107f:	e9 68 ff ff ff       	jmp    800fec <__udivdi3+0x7c>
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	8d 47 ff             	lea    -0x1(%edi),%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 0c             	add    $0xc,%esp
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    
  801094:	66 90                	xchg   %ax,%ax
  801096:	66 90                	xchg   %ax,%ax
  801098:	66 90                	xchg   %ax,%ax
  80109a:	66 90                	xchg   %ax,%ax
  80109c:	66 90                	xchg   %ax,%ax
  80109e:	66 90                	xchg   %ax,%ax

008010a0 <__umoddi3>:
  8010a0:	55                   	push   %ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	83 ec 14             	sub    $0x14,%esp
  8010a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8010b2:	89 c7                	mov    %eax,%edi
  8010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010c0:	89 34 24             	mov    %esi,(%esp)
  8010c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	75 17                	jne    8010e8 <__umoddi3+0x48>
  8010d1:	39 fe                	cmp    %edi,%esi
  8010d3:	76 4b                	jbe    801120 <__umoddi3+0x80>
  8010d5:	89 c8                	mov    %ecx,%eax
  8010d7:	89 fa                	mov    %edi,%edx
  8010d9:	f7 f6                	div    %esi
  8010db:	89 d0                	mov    %edx,%eax
  8010dd:	31 d2                	xor    %edx,%edx
  8010df:	83 c4 14             	add    $0x14,%esp
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	39 f8                	cmp    %edi,%eax
  8010ea:	77 54                	ja     801140 <__umoddi3+0xa0>
  8010ec:	0f bd e8             	bsr    %eax,%ebp
  8010ef:	83 f5 1f             	xor    $0x1f,%ebp
  8010f2:	75 5c                	jne    801150 <__umoddi3+0xb0>
  8010f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010f8:	39 3c 24             	cmp    %edi,(%esp)
  8010fb:	0f 87 e7 00 00 00    	ja     8011e8 <__umoddi3+0x148>
  801101:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801105:	29 f1                	sub    %esi,%ecx
  801107:	19 c7                	sbb    %eax,%edi
  801109:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801111:	8b 44 24 08          	mov    0x8(%esp),%eax
  801115:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801119:	83 c4 14             	add    $0x14,%esp
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
  801120:	85 f6                	test   %esi,%esi
  801122:	89 f5                	mov    %esi,%ebp
  801124:	75 0b                	jne    801131 <__umoddi3+0x91>
  801126:	b8 01 00 00 00       	mov    $0x1,%eax
  80112b:	31 d2                	xor    %edx,%edx
  80112d:	f7 f6                	div    %esi
  80112f:	89 c5                	mov    %eax,%ebp
  801131:	8b 44 24 04          	mov    0x4(%esp),%eax
  801135:	31 d2                	xor    %edx,%edx
  801137:	f7 f5                	div    %ebp
  801139:	89 c8                	mov    %ecx,%eax
  80113b:	f7 f5                	div    %ebp
  80113d:	eb 9c                	jmp    8010db <__umoddi3+0x3b>
  80113f:	90                   	nop
  801140:	89 c8                	mov    %ecx,%eax
  801142:	89 fa                	mov    %edi,%edx
  801144:	83 c4 14             	add    $0x14,%esp
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    
  80114b:	90                   	nop
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	8b 04 24             	mov    (%esp),%eax
  801153:	be 20 00 00 00       	mov    $0x20,%esi
  801158:	89 e9                	mov    %ebp,%ecx
  80115a:	29 ee                	sub    %ebp,%esi
  80115c:	d3 e2                	shl    %cl,%edx
  80115e:	89 f1                	mov    %esi,%ecx
  801160:	d3 e8                	shr    %cl,%eax
  801162:	89 e9                	mov    %ebp,%ecx
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	8b 04 24             	mov    (%esp),%eax
  80116b:	09 54 24 04          	or     %edx,0x4(%esp)
  80116f:	89 fa                	mov    %edi,%edx
  801171:	d3 e0                	shl    %cl,%eax
  801173:	89 f1                	mov    %esi,%ecx
  801175:	89 44 24 08          	mov    %eax,0x8(%esp)
  801179:	8b 44 24 10          	mov    0x10(%esp),%eax
  80117d:	d3 ea                	shr    %cl,%edx
  80117f:	89 e9                	mov    %ebp,%ecx
  801181:	d3 e7                	shl    %cl,%edi
  801183:	89 f1                	mov    %esi,%ecx
  801185:	d3 e8                	shr    %cl,%eax
  801187:	89 e9                	mov    %ebp,%ecx
  801189:	09 f8                	or     %edi,%eax
  80118b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80118f:	f7 74 24 04          	divl   0x4(%esp)
  801193:	d3 e7                	shl    %cl,%edi
  801195:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801199:	89 d7                	mov    %edx,%edi
  80119b:	f7 64 24 08          	mull   0x8(%esp)
  80119f:	39 d7                	cmp    %edx,%edi
  8011a1:	89 c1                	mov    %eax,%ecx
  8011a3:	89 14 24             	mov    %edx,(%esp)
  8011a6:	72 2c                	jb     8011d4 <__umoddi3+0x134>
  8011a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011ac:	72 22                	jb     8011d0 <__umoddi3+0x130>
  8011ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011b2:	29 c8                	sub    %ecx,%eax
  8011b4:	19 d7                	sbb    %edx,%edi
  8011b6:	89 e9                	mov    %ebp,%ecx
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	d3 e8                	shr    %cl,%eax
  8011bc:	89 f1                	mov    %esi,%ecx
  8011be:	d3 e2                	shl    %cl,%edx
  8011c0:	89 e9                	mov    %ebp,%ecx
  8011c2:	d3 ef                	shr    %cl,%edi
  8011c4:	09 d0                	or     %edx,%eax
  8011c6:	89 fa                	mov    %edi,%edx
  8011c8:	83 c4 14             	add    $0x14,%esp
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    
  8011cf:	90                   	nop
  8011d0:	39 d7                	cmp    %edx,%edi
  8011d2:	75 da                	jne    8011ae <__umoddi3+0x10e>
  8011d4:	8b 14 24             	mov    (%esp),%edx
  8011d7:	89 c1                	mov    %eax,%ecx
  8011d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8011dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8011e1:	eb cb                	jmp    8011ae <__umoddi3+0x10e>
  8011e3:	90                   	nop
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8011ec:	0f 82 0f ff ff ff    	jb     801101 <__umoddi3+0x61>
  8011f2:	e9 1a ff ff ff       	jmp    801111 <__umoddi3+0x71>
