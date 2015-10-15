
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 2c 0f 00 00       	call   800f6e <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 30 0c 00 00       	call   800c84 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  800063:	e8 eb 01 00 00       	call   800253 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 14 0c 00 00       	call   800c84 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 3a 13 80 00 	movl   $0x80133a,(%esp)
  80007f:	e8 cf 01 00 00       	call   800253 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 0b 0f 00 00       	call   800fb2 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 ce 0e 00 00       	call   800f90 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 a8 0b 00 00       	call   800c84 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 50 13 80 00 	movl   $0x801350,(%esp)
  8000fa:	e8 54 01 00 00       	call   800253 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 7e 0e 00 00       	call   800fb2 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80015e:	e8 21 0b 00 00       	call   800c84 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 79 0a 00 00       	call   800c27 <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	83 c0 01             	add    $0x1,%eax
  8001c6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cd:	75 19                	jne    8001e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d6:	00 
  8001d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 e6 09 00 00       	call   800bc8 <sys_cputs>
		b->idx = 0;
  8001e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800223:	89 44 24 04          	mov    %eax,0x4(%esp)
  800227:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022e:	e8 8a 01 00 00       	call   8003bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800233:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	e8 7d 09 00 00       	call   800bc8 <sys_cputs>

	return b.cnt;
}
  80024b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800259:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 87 ff ff ff       	call   8001f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	85 c0                	test   %eax,%eax
  800292:	75 08                	jne    80029c <printnum+0x2c>
  800294:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800297:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029a:	77 59                	ja     8002f5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bd:	00 
  8002be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c1:	89 04 24             	mov    %eax,(%esp)
  8002c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cb:	e8 a0 0d 00 00       	call   801070 <__udivdi3>
  8002d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002df:	89 fa                	mov    %edi,%edx
  8002e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e4:	e8 87 ff ff ff       	call   800270 <printnum>
  8002e9:	eb 11                	jmp    8002fc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ef:	89 34 24             	mov    %esi,(%esp)
  8002f2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f5:	83 eb 01             	sub    $0x1,%ebx
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7f ef                	jg     8002eb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800312:	00 
  800313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800320:	e8 7b 0e 00 00       	call   8011a0 <__umoddi3>
  800325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800329:	0f be 80 80 13 80 00 	movsbl 0x801380(%eax),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800336:	83 c4 3c             	add    $0x3c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800382:	8b 10                	mov    (%eax),%edx
  800384:	3b 50 04             	cmp    0x4(%eax),%edx
  800387:	73 0a                	jae    800393 <sprintputch+0x1b>
		*b->buf++ = ch;
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 0a                	mov    %cl,(%edx)
  80038e:	83 c2 01             	add    $0x1,%edx
  800391:	89 10                	mov    %edx,(%eax)
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 02 00 00 00       	call   8003bd <vprintfmt>
	va_end(ap);
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 4c             	sub    $0x4c,%esp
  8003c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003cc:	eb 12                	jmp    8003e0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	0f 84 bf 03 00 00    	je     800795 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8003d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e0:	0f b6 06             	movzbl (%esi),%eax
  8003e3:	83 c6 01             	add    $0x1,%esi
  8003e6:	83 f8 25             	cmp    $0x25,%eax
  8003e9:	75 e3                	jne    8003ce <vprintfmt+0x11>
  8003eb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80040a:	eb 2b                	jmp    800437 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800413:	eb 22                	jmp    800437 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 19                	jmp    800437 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800428:	eb 0d                	jmp    800437 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800430:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	0f b6 16             	movzbl (%esi),%edx
  80043a:	0f b6 c2             	movzbl %dl,%eax
  80043d:	8d 7e 01             	lea    0x1(%esi),%edi
  800440:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800443:	83 ea 23             	sub    $0x23,%edx
  800446:	80 fa 55             	cmp    $0x55,%dl
  800449:	0f 87 28 03 00 00    	ja     800777 <vprintfmt+0x3ba>
  80044f:	0f b6 d2             	movzbl %dl,%edx
  800452:	ff 24 95 40 14 80 00 	jmp    *0x801440(,%edx,4)
  800459:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800463:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800468:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800472:	8d 50 d0             	lea    -0x30(%eax),%edx
  800475:	83 fa 09             	cmp    $0x9,%edx
  800478:	77 2f                	ja     8004a9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047d:	eb e9                	jmp    800468 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800490:	eb 1a                	jmp    8004ac <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800495:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800499:	79 9c                	jns    800437 <vprintfmt+0x7a>
  80049b:	eb 81                	jmp    80041e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a7:	eb 8e                	jmp    800437 <vprintfmt+0x7a>
  8004a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b0:	79 85                	jns    800437 <vprintfmt+0x7a>
  8004b2:	e9 73 ff ff ff       	jmp    80042a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bd:	e9 75 ff ff ff       	jmp    800437 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 04 24             	mov    %eax,(%esp)
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004da:	e9 01 ff ff ff       	jmp    8003e0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 00                	mov    (%eax),%eax
  8004ea:	89 c2                	mov    %eax,%edx
  8004ec:	c1 fa 1f             	sar    $0x1f,%edx
  8004ef:	31 d0                	xor    %edx,%eax
  8004f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 09             	cmp    $0x9,%eax
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x146>
  8004f8:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	75 23                	jne    800526 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800503:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800507:	c7 44 24 08 98 13 80 	movl   $0x801398,0x8(%esp)
  80050e:	00 
  80050f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800513:	8b 7d 08             	mov    0x8(%ebp),%edi
  800516:	89 3c 24             	mov    %edi,(%esp)
  800519:	e8 77 fe ff ff       	call   800395 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800521:	e9 ba fe ff ff       	jmp    8003e0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800526:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80052a:	c7 44 24 08 a1 13 80 	movl   $0x8013a1,0x8(%esp)
  800531:	00 
  800532:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800536:	8b 7d 08             	mov    0x8(%ebp),%edi
  800539:	89 3c 24             	mov    %edi,(%esp)
  80053c:	e8 54 fe ff ff       	call   800395 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800544:	e9 97 fe ff ff       	jmp    8003e0 <vprintfmt+0x23>
  800549:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80055d:	85 f6                	test   %esi,%esi
  80055f:	ba 91 13 80 00       	mov    $0x801391,%edx
  800564:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800567:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80056b:	0f 8e 8c 00 00 00    	jle    8005fd <vprintfmt+0x240>
  800571:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800575:	0f 84 82 00 00 00    	je     8005fd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057f:	89 34 24             	mov    %esi,(%esp)
  800582:	e8 b1 02 00 00       	call   800838 <strnlen>
  800587:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80058a:	29 c2                	sub    %eax,%edx
  80058c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80058f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800593:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800596:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800599:	89 de                	mov    %ebx,%esi
  80059b:	89 d3                	mov    %edx,%ebx
  80059d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	eb 0d                	jmp    8005ae <vprintfmt+0x1f1>
					putch(padc, putdat);
  8005a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a5:	89 3c 24             	mov    %edi,(%esp)
  8005a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	83 eb 01             	sub    $0x1,%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f ef                	jg     8005a1 <vprintfmt+0x1e4>
  8005b2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005b5:	89 f3                	mov    %esi,%ebx
  8005b7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005be:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8005c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ca:	29 c2                	sub    %eax,%edx
  8005cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005cf:	eb 2c                	jmp    8005fd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d5:	74 18                	je     8005ef <vprintfmt+0x232>
  8005d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005da:	83 fa 5e             	cmp    $0x5e,%edx
  8005dd:	76 10                	jbe    8005ef <vprintfmt+0x232>
					putch('?', putdat);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ea:	ff 55 08             	call   *0x8(%ebp)
  8005ed:	eb 0a                	jmp    8005f9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005fd:	0f be 06             	movsbl (%esi),%eax
  800600:	83 c6 01             	add    $0x1,%esi
  800603:	85 c0                	test   %eax,%eax
  800605:	74 25                	je     80062c <vprintfmt+0x26f>
  800607:	85 ff                	test   %edi,%edi
  800609:	78 c6                	js     8005d1 <vprintfmt+0x214>
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	79 c1                	jns    8005d1 <vprintfmt+0x214>
  800610:	8b 7d 08             	mov    0x8(%ebp),%edi
  800613:	89 de                	mov    %ebx,%esi
  800615:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800625:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800627:	83 eb 01             	sub    $0x1,%ebx
  80062a:	eb 08                	jmp    800634 <vprintfmt+0x277>
  80062c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062f:	89 de                	mov    %ebx,%esi
  800631:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800634:	85 db                	test   %ebx,%ebx
  800636:	7f e2                	jg     80061a <vprintfmt+0x25d>
  800638:	89 7d 08             	mov    %edi,0x8(%ebp)
  80063b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800640:	e9 9b fd ff ff       	jmp    8003e0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800645:	83 f9 01             	cmp    $0x1,%ecx
  800648:	7e 10                	jle    80065a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 08             	lea    0x8(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	8b 78 04             	mov    0x4(%eax),%edi
  800658:	eb 26                	jmp    800680 <vprintfmt+0x2c3>
	else if (lflag)
  80065a:	85 c9                	test   %ecx,%ecx
  80065c:	74 12                	je     800670 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	89 f7                	mov    %esi,%edi
  80066b:	c1 ff 1f             	sar    $0x1f,%edi
  80066e:	eb 10                	jmp    800680 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	8b 30                	mov    (%eax),%esi
  80067b:	89 f7                	mov    %esi,%edi
  80067d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800685:	85 ff                	test   %edi,%edi
  800687:	0f 89 ac 00 00 00    	jns    800739 <vprintfmt+0x37c>
				putch('-', putdat);
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069b:	f7 de                	neg    %esi
  80069d:	83 d7 00             	adc    $0x0,%edi
  8006a0:	f7 df                	neg    %edi
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 8d 00 00 00       	jmp    800739 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ac:	89 ca                	mov    %ecx,%edx
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 88 fc ff ff       	call   80033e <getuint>
  8006b6:	89 c6                	mov    %eax,%esi
  8006b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006bf:	eb 78                	jmp    800739 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006cc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006da:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006e8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006ee:	e9 ed fc ff ff       	jmp    8003e0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006fe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800701:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800705:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800718:	8b 30                	mov    (%eax),%esi
  80071a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800724:	eb 13                	jmp    800739 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800726:	89 ca                	mov    %ecx,%edx
  800728:	8d 45 14             	lea    0x14(%ebp),%eax
  80072b:	e8 0e fc ff ff       	call   80033e <getuint>
  800730:	89 c6                	mov    %eax,%esi
  800732:	89 d7                	mov    %edx,%edi
			base = 16;
  800734:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800739:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80073d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800741:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800744:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800748:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074c:	89 34 24             	mov    %esi,(%esp)
  80074f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800753:	89 da                	mov    %ebx,%edx
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	e8 13 fb ff ff       	call   800270 <printnum>
			break;
  80075d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800760:	e9 7b fc ff ff       	jmp    8003e0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800765:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800772:	e9 69 fc ff ff       	jmp    8003e0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800782:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800785:	eb 03                	jmp    80078a <vprintfmt+0x3cd>
  800787:	83 ee 01             	sub    $0x1,%esi
  80078a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078e:	75 f7                	jne    800787 <vprintfmt+0x3ca>
  800790:	e9 4b fc ff ff       	jmp    8003e0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800795:	83 c4 4c             	add    $0x4c,%esp
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5f                   	pop    %edi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 28             	sub    $0x28,%esp
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	74 30                	je     8007ee <vsnprintf+0x51>
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	7e 2c                	jle    8007ee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d7:	c7 04 24 78 03 80 00 	movl   $0x800378,(%esp)
  8007de:	e8 da fb ff ff       	call   8003bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	eb 05                	jmp    8007f3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	89 44 24 08          	mov    %eax,0x8(%esp)
  800809:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 82 ff ff ff       	call   80079d <vsnprintf>
	va_end(ap);

	return rc;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    
  80081d:	00 00                	add    %al,(%eax)
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	74 06                	je     800855 <strnlen+0x1d>
  80084f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
		n++;
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800861:	ba 00 00 00 00       	mov    $0x0,%edx
  800866:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80086a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	84 c9                	test   %cl,%cl
  800872:	75 f2                	jne    800866 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	89 1c 24             	mov    %ebx,(%esp)
  800884:	e8 97 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800890:	01 d8                	add    %ebx,%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 bd ff ff ff       	call   800857 <strcpy>
	return dst;
}
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b5:	eb 0f                	jmp    8008c6 <strncpy+0x24>
		*dst++ = *src;
  8008b7:	0f b6 1a             	movzbl (%edx),%ebx
  8008ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	83 c1 01             	add    $0x1,%ecx
  8008c6:	39 f1                	cmp    %esi,%ecx
  8008c8:	75 ed                	jne    8008b7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008dc:	89 f0                	mov    %esi,%eax
  8008de:	85 d2                	test   %edx,%edx
  8008e0:	75 0a                	jne    8008ec <strlcpy+0x1e>
  8008e2:	eb 1d                	jmp    800901 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e4:	88 18                	mov    %bl,(%eax)
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ec:	83 ea 01             	sub    $0x1,%edx
  8008ef:	74 0b                	je     8008fc <strlcpy+0x2e>
  8008f1:	0f b6 19             	movzbl (%ecx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x16>
  8008f8:	89 c2                	mov    %eax,%edx
  8008fa:	eb 02                	jmp    8008fe <strlcpy+0x30>
  8008fc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008fe:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800901:	29 f0                	sub    %esi,%eax
}
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800910:	eb 06                	jmp    800918 <strcmp+0x11>
		p++, q++;
  800912:	83 c1 01             	add    $0x1,%ecx
  800915:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800918:	0f b6 01             	movzbl (%ecx),%eax
  80091b:	84 c0                	test   %al,%al
  80091d:	74 04                	je     800923 <strcmp+0x1c>
  80091f:	3a 02                	cmp    (%edx),%al
  800921:	74 ef                	je     800912 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800923:	0f b6 c0             	movzbl %al,%eax
  800926:	0f b6 12             	movzbl (%edx),%edx
  800929:	29 d0                	sub    %edx,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80093a:	eb 09                	jmp    800945 <strncmp+0x18>
		n--, p++, q++;
  80093c:	83 ea 01             	sub    $0x1,%edx
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800945:	85 d2                	test   %edx,%edx
  800947:	74 15                	je     80095e <strncmp+0x31>
  800949:	0f b6 18             	movzbl (%eax),%ebx
  80094c:	84 db                	test   %bl,%bl
  80094e:	74 04                	je     800954 <strncmp+0x27>
  800950:	3a 19                	cmp    (%ecx),%bl
  800952:	74 e8                	je     80093c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800954:	0f b6 00             	movzbl (%eax),%eax
  800957:	0f b6 11             	movzbl (%ecx),%edx
  80095a:	29 d0                	sub    %edx,%eax
  80095c:	eb 05                	jmp    800963 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800963:	5b                   	pop    %ebx
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800970:	eb 07                	jmp    800979 <strchr+0x13>
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 0f                	je     800985 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800976:	83 c0 01             	add    $0x1,%eax
  800979:	0f b6 10             	movzbl (%eax),%edx
  80097c:	84 d2                	test   %dl,%dl
  80097e:	75 f2                	jne    800972 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800991:	eb 07                	jmp    80099a <strfind+0x13>
		if (*s == c)
  800993:	38 ca                	cmp    %cl,%dl
  800995:	74 0a                	je     8009a1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	0f b6 10             	movzbl (%eax),%edx
  80099d:	84 d2                	test   %dl,%dl
  80099f:	75 f2                	jne    800993 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	83 ec 0c             	sub    $0xc,%esp
  8009a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009af:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bb:	85 c9                	test   %ecx,%ecx
  8009bd:	74 30                	je     8009ef <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c5:	75 25                	jne    8009ec <memset+0x49>
  8009c7:	f6 c1 03             	test   $0x3,%cl
  8009ca:	75 20                	jne    8009ec <memset+0x49>
		c &= 0xFF;
  8009cc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cf:	89 d3                	mov    %edx,%ebx
  8009d1:	c1 e3 08             	shl    $0x8,%ebx
  8009d4:	89 d6                	mov    %edx,%esi
  8009d6:	c1 e6 18             	shl    $0x18,%esi
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	c1 e0 10             	shl    $0x10,%eax
  8009de:	09 f0                	or     %esi,%eax
  8009e0:	09 d0                	or     %edx,%eax
  8009e2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e7:	fc                   	cld    
  8009e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ea:	eb 03                	jmp    8009ef <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ec:	fc                   	cld    
  8009ed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ef:	89 f8                	mov    %edi,%eax
  8009f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009f4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009f7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009fa:	89 ec                	mov    %ebp,%esp
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 08             	sub    $0x8,%esp
  800a04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a07:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a13:	39 c6                	cmp    %eax,%esi
  800a15:	73 36                	jae    800a4d <memmove+0x4f>
  800a17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	73 2f                	jae    800a4d <memmove+0x4f>
		s += n;
		d += n;
  800a1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a21:	f6 c2 03             	test   $0x3,%dl
  800a24:	75 1b                	jne    800a41 <memmove+0x43>
  800a26:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2c:	75 13                	jne    800a41 <memmove+0x43>
  800a2e:	f6 c1 03             	test   $0x3,%cl
  800a31:	75 0e                	jne    800a41 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a33:	83 ef 04             	sub    $0x4,%edi
  800a36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a39:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3c:	fd                   	std    
  800a3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3f:	eb 09                	jmp    800a4a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a47:	fd                   	std    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4a:	fc                   	cld    
  800a4b:	eb 20                	jmp    800a6d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a53:	75 13                	jne    800a68 <memmove+0x6a>
  800a55:	a8 03                	test   $0x3,%al
  800a57:	75 0f                	jne    800a68 <memmove+0x6a>
  800a59:	f6 c1 03             	test   $0x3,%cl
  800a5c:	75 0a                	jne    800a68 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	fc                   	cld    
  800a64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a66:	eb 05                	jmp    800a6d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a68:	89 c7                	mov    %eax,%edi
  800a6a:	fc                   	cld    
  800a6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a73:	89 ec                	mov    %ebp,%esp
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	89 04 24             	mov    %eax,(%esp)
  800a91:	e8 68 ff ff ff       	call   8009fe <memmove>
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	eb 1a                	jmp    800ac8 <memcmp+0x30>
		if (*s1 != *s2)
  800aae:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ab2:	83 c2 01             	add    $0x1,%edx
  800ab5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800aba:	38 c8                	cmp    %cl,%al
  800abc:	74 0a                	je     800ac8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800abe:	0f b6 c0             	movzbl %al,%eax
  800ac1:	0f b6 c9             	movzbl %cl,%ecx
  800ac4:	29 c8                	sub    %ecx,%eax
  800ac6:	eb 09                	jmp    800ad1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac8:	39 da                	cmp    %ebx,%edx
  800aca:	75 e2                	jne    800aae <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 02             	movzbl (%edx),%eax
  800b07:	3c 20                	cmp    $0x20,%al
  800b09:	74 f6                	je     800b01 <strtol+0xe>
  800b0b:	3c 09                	cmp    $0x9,%al
  800b0d:	74 f2                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x2a>
		s++;
  800b13:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 10                	jmp    800b2d <strtol+0x3a>
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	75 07                	jne    800b2d <strtol+0x3a>
		s++, neg = 1;
  800b26:	8d 52 01             	lea    0x1(%edx),%edx
  800b29:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	0f 94 c0             	sete   %al
  800b32:	74 05                	je     800b39 <strtol+0x46>
  800b34:	83 fb 10             	cmp    $0x10,%ebx
  800b37:	75 15                	jne    800b4e <strtol+0x5b>
  800b39:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3c:	75 10                	jne    800b4e <strtol+0x5b>
  800b3e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b42:	75 0a                	jne    800b4e <strtol+0x5b>
		s += 2, base = 16;
  800b44:	83 c2 02             	add    $0x2,%edx
  800b47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4c:	eb 13                	jmp    800b61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4e:	84 c0                	test   %al,%al
  800b50:	74 0f                	je     800b61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b57:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5a:	75 05                	jne    800b61 <strtol+0x6e>
		s++, base = 8;
  800b5c:	83 c2 01             	add    $0x1,%edx
  800b5f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b68:	0f b6 0a             	movzbl (%edx),%ecx
  800b6b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b6e:	80 fb 09             	cmp    $0x9,%bl
  800b71:	77 08                	ja     800b7b <strtol+0x88>
			dig = *s - '0';
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 30             	sub    $0x30,%ecx
  800b79:	eb 1e                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b7b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b7e:	80 fb 19             	cmp    $0x19,%bl
  800b81:	77 08                	ja     800b8b <strtol+0x98>
			dig = *s - 'a' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 57             	sub    $0x57,%ecx
  800b89:	eb 0e                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b8b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 14                	ja     800ba7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b99:	39 f1                	cmp    %esi,%ecx
  800b9b:	7d 0e                	jge    800bab <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800b9d:	83 c2 01             	add    $0x1,%edx
  800ba0:	0f af c6             	imul   %esi,%eax
  800ba3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ba5:	eb c1                	jmp    800b68 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ba7:	89 c1                	mov    %eax,%ecx
  800ba9:	eb 02                	jmp    800bad <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bab:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb1:	74 05                	je     800bb8 <strtol+0xc5>
		*endptr = (char *) s;
  800bb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb8:	89 ca                	mov    %ecx,%edx
  800bba:	f7 da                	neg    %edx
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 45 c2             	cmovne %edx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    
	...

00800bc8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	89 c3                	mov    %eax,%ebx
  800be4:	89 c7                	mov    %eax,%edi
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf3:	89 ec                	mov    %ebp,%esp
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c00:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c03:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c10:	89 d1                	mov    %edx,%ecx
  800c12:	89 d3                	mov    %edx,%ebx
  800c14:	89 d7                	mov    %edx,%edi
  800c16:	89 d6                	mov    %edx,%esi
  800c18:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c23:	89 ec                	mov    %ebp,%esp
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 38             	sub    $0x38,%esp
  800c2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c33:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 28                	jle    800c77 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c53:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800c62:	00 
  800c63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6a:	00 
  800c6b:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800c72:	e8 95 03 00 00       	call   80100c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c80:	89 ec                	mov    %ebp,%esp
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c90:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	89 d3                	mov    %edx,%ebx
  800ca1:	89 d7                	mov    %edx,%edi
  800ca3:	89 d6                	mov    %edx,%esi
  800ca5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800caa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb0:	89 ec                	mov    %ebp,%esp
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_yield>:

void
sys_yield(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cbd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	89 d3                	mov    %edx,%ebx
  800cd1:	89 d7                	mov    %edx,%edi
  800cd3:	89 d6                	mov    %edx,%esi
  800cd5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce0:	89 ec                	mov    %ebp,%esp
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 38             	sub    $0x38,%esp
  800cea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ced:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	be 00 00 00 00       	mov    $0x0,%esi
  800cf8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 f7                	mov    %esi,%edi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 28                	jle    800d36 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d12:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d19:	00 
  800d1a:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800d21:	00 
  800d22:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d29:	00 
  800d2a:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800d31:	e8 d6 02 00 00       	call   80100c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3f:	89 ec                	mov    %ebp,%esp
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 38             	sub    $0x38,%esp
  800d49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b8 05 00 00 00       	mov    $0x5,%eax
  800d57:	8b 75 18             	mov    0x18(%ebp),%esi
  800d5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 28                	jle    800d94 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d70:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d77:	00 
  800d78:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800d7f:	00 
  800d80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d87:	00 
  800d88:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800d8f:	e8 78 02 00 00       	call   80100c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9d:	89 ec                	mov    %ebp,%esp
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 38             	sub    $0x38,%esp
  800da7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800daa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dad:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 06 00 00 00       	mov    $0x6,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800ded:	e8 1a 02 00 00       	call   80100c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfb:	89 ec                	mov    %ebp,%esp
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 38             	sub    $0x38,%esp
  800e05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 08 00 00 00       	mov    $0x8,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 28                	jle    800e50 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e33:	00 
  800e34:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e43:	00 
  800e44:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800e4b:	e8 bc 01 00 00       	call   80100c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e50:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e53:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e56:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e59:	89 ec                	mov    %ebp,%esp
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 38             	sub    $0x38,%esp
  800e63:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e66:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e69:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e71:	b8 09 00 00 00       	mov    $0x9,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 df                	mov    %ebx,%edi
  800e7e:	89 de                	mov    %ebx,%esi
  800e80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 28                	jle    800eae <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800ea9:	e8 5e 01 00 00       	call   80100c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb7:	89 ec                	mov    %ebp,%esp
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	be 00 00 00 00       	mov    $0x0,%esi
  800ecf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eeb:	89 ec                	mov    %ebp,%esp
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 38             	sub    $0x38,%esp
  800ef5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 cb                	mov    %ecx,%ebx
  800f0d:	89 cf                	mov    %ecx,%edi
  800f0f:	89 ce                	mov    %ecx,%esi
  800f11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7e 28                	jle    800f3f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f22:	00 
  800f23:	c7 44 24 08 c8 15 80 	movl   $0x8015c8,0x8(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f32:	00 
  800f33:	c7 04 24 e5 15 80 00 	movl   $0x8015e5,(%esp)
  800f3a:	e8 cd 00 00 00       	call   80100c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f52:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 f3 15 80 00 	movl   $0x8015f3,(%esp)
  800f69:	e8 9e 00 00 00       	call   80100c <_panic>

00800f6e <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f74:	c7 44 24 08 fe 15 80 	movl   $0x8015fe,0x8(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f83:	00 
  800f84:	c7 04 24 f3 15 80 00 	movl   $0x8015f3,(%esp)
  800f8b:	e8 7c 00 00 00       	call   80100c <_panic>

00800f90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f96:	c7 44 24 08 14 16 80 	movl   $0x801614,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 2d 16 80 00 	movl   $0x80162d,(%esp)
  800fad:	e8 5a 00 00 00       	call   80100c <_panic>

00800fb2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fb8:	c7 44 24 08 37 16 80 	movl   $0x801637,0x8(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fc7:	00 
  800fc8:	c7 04 24 2d 16 80 00 	movl   $0x80162d,(%esp)
  800fcf:	e8 38 00 00 00       	call   80100c <_panic>

00800fd4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800fdf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fe2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fe8:	8b 52 50             	mov    0x50(%edx),%edx
  800feb:	39 ca                	cmp    %ecx,%edx
  800fed:	75 0d                	jne    800ffc <ipc_find_env+0x28>
			return envs[i].env_id;
  800fef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff2:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ff7:	8b 40 40             	mov    0x40(%eax),%eax
  800ffa:	eb 0e                	jmp    80100a <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ffc:	83 c0 01             	add    $0x1,%eax
  800fff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801004:	75 d9                	jne    800fdf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801006:	66 b8 00 00          	mov    $0x0,%ax
}
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801014:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801017:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80101d:	e8 62 fc ff ff       	call   800c84 <sys_getenvid>
  801022:	8b 55 0c             	mov    0xc(%ebp),%edx
  801025:	89 54 24 10          	mov    %edx,0x10(%esp)
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801030:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801034:	89 44 24 04          	mov    %eax,0x4(%esp)
  801038:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  80103f:	e8 0f f2 ff ff       	call   800253 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801044:	89 74 24 04          	mov    %esi,0x4(%esp)
  801048:	8b 45 10             	mov    0x10(%ebp),%eax
  80104b:	89 04 24             	mov    %eax,(%esp)
  80104e:	e8 9f f1 ff ff       	call   8001f2 <vcprintf>
	cprintf("\n");
  801053:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  80105a:	e8 f4 f1 ff ff       	call   800253 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105f:	cc                   	int3   
  801060:	eb fd                	jmp    80105f <_panic+0x53>
	...

00801070 <__udivdi3>:
  801070:	83 ec 1c             	sub    $0x1c,%esp
  801073:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801077:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80107b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80107f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801083:	89 74 24 10          	mov    %esi,0x10(%esp)
  801087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80108b:	85 ff                	test   %edi,%edi
  80108d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801091:	89 44 24 08          	mov    %eax,0x8(%esp)
  801095:	89 cd                	mov    %ecx,%ebp
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	75 33                	jne    8010d0 <__udivdi3+0x60>
  80109d:	39 f1                	cmp    %esi,%ecx
  80109f:	77 57                	ja     8010f8 <__udivdi3+0x88>
  8010a1:	85 c9                	test   %ecx,%ecx
  8010a3:	75 0b                	jne    8010b0 <__udivdi3+0x40>
  8010a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010aa:	31 d2                	xor    %edx,%edx
  8010ac:	f7 f1                	div    %ecx
  8010ae:	89 c1                	mov    %eax,%ecx
  8010b0:	89 f0                	mov    %esi,%eax
  8010b2:	31 d2                	xor    %edx,%edx
  8010b4:	f7 f1                	div    %ecx
  8010b6:	89 c6                	mov    %eax,%esi
  8010b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 f2                	mov    %esi,%edx
  8010c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010cc:	83 c4 1c             	add    $0x1c,%esp
  8010cf:	c3                   	ret    
  8010d0:	31 d2                	xor    %edx,%edx
  8010d2:	31 c0                	xor    %eax,%eax
  8010d4:	39 f7                	cmp    %esi,%edi
  8010d6:	77 e8                	ja     8010c0 <__udivdi3+0x50>
  8010d8:	0f bd cf             	bsr    %edi,%ecx
  8010db:	83 f1 1f             	xor    $0x1f,%ecx
  8010de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010e2:	75 2c                	jne    801110 <__udivdi3+0xa0>
  8010e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010e8:	76 04                	jbe    8010ee <__udivdi3+0x7e>
  8010ea:	39 f7                	cmp    %esi,%edi
  8010ec:	73 d2                	jae    8010c0 <__udivdi3+0x50>
  8010ee:	31 d2                	xor    %edx,%edx
  8010f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f5:	eb c9                	jmp    8010c0 <__udivdi3+0x50>
  8010f7:	90                   	nop
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	f7 f1                	div    %ecx
  8010fc:	31 d2                	xor    %edx,%edx
  8010fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801102:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801106:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110a:	83 c4 1c             	add    $0x1c,%esp
  80110d:	c3                   	ret    
  80110e:	66 90                	xchg   %ax,%ax
  801110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801115:	b8 20 00 00 00       	mov    $0x20,%eax
  80111a:	89 ea                	mov    %ebp,%edx
  80111c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801120:	d3 e7                	shl    %cl,%edi
  801122:	89 c1                	mov    %eax,%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112b:	09 fa                	or     %edi,%edx
  80112d:	89 f7                	mov    %esi,%edi
  80112f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801133:	89 f2                	mov    %esi,%edx
  801135:	8b 74 24 08          	mov    0x8(%esp),%esi
  801139:	d3 e5                	shl    %cl,%ebp
  80113b:	89 c1                	mov    %eax,%ecx
  80113d:	d3 ef                	shr    %cl,%edi
  80113f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801144:	d3 e2                	shl    %cl,%edx
  801146:	89 c1                	mov    %eax,%ecx
  801148:	d3 ee                	shr    %cl,%esi
  80114a:	09 d6                	or     %edx,%esi
  80114c:	89 fa                	mov    %edi,%edx
  80114e:	89 f0                	mov    %esi,%eax
  801150:	f7 74 24 0c          	divl   0xc(%esp)
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 c6                	mov    %eax,%esi
  801158:	f7 e5                	mul    %ebp
  80115a:	39 d7                	cmp    %edx,%edi
  80115c:	72 22                	jb     801180 <__udivdi3+0x110>
  80115e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801162:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801167:	d3 e5                	shl    %cl,%ebp
  801169:	39 c5                	cmp    %eax,%ebp
  80116b:	73 04                	jae    801171 <__udivdi3+0x101>
  80116d:	39 d7                	cmp    %edx,%edi
  80116f:	74 0f                	je     801180 <__udivdi3+0x110>
  801171:	89 f0                	mov    %esi,%eax
  801173:	31 d2                	xor    %edx,%edx
  801175:	e9 46 ff ff ff       	jmp    8010c0 <__udivdi3+0x50>
  80117a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801180:	8d 46 ff             	lea    -0x1(%esi),%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	8b 74 24 10          	mov    0x10(%esp),%esi
  801189:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80118d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801191:	83 c4 1c             	add    $0x1c,%esp
  801194:	c3                   	ret    
	...

008011a0 <__umoddi3>:
  8011a0:	83 ec 1c             	sub    $0x1c,%esp
  8011a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011bb:	85 ed                	test   %ebp,%ebp
  8011bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	89 cf                	mov    %ecx,%edi
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	89 f2                	mov    %esi,%edx
  8011cc:	75 1a                	jne    8011e8 <__umoddi3+0x48>
  8011ce:	39 f1                	cmp    %esi,%ecx
  8011d0:	76 4e                	jbe    801220 <__umoddi3+0x80>
  8011d2:	f7 f1                	div    %ecx
  8011d4:	89 d0                	mov    %edx,%eax
  8011d6:	31 d2                	xor    %edx,%edx
  8011d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e4:	83 c4 1c             	add    $0x1c,%esp
  8011e7:	c3                   	ret    
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	77 54                	ja     801240 <__umoddi3+0xa0>
  8011ec:	0f bd c5             	bsr    %ebp,%eax
  8011ef:	83 f0 1f             	xor    $0x1f,%eax
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	75 60                	jne    801258 <__umoddi3+0xb8>
  8011f8:	3b 0c 24             	cmp    (%esp),%ecx
  8011fb:	0f 87 07 01 00 00    	ja     801308 <__umoddi3+0x168>
  801201:	89 f2                	mov    %esi,%edx
  801203:	8b 34 24             	mov    (%esp),%esi
  801206:	29 ce                	sub    %ecx,%esi
  801208:	19 ea                	sbb    %ebp,%edx
  80120a:	89 34 24             	mov    %esi,(%esp)
  80120d:	8b 04 24             	mov    (%esp),%eax
  801210:	8b 74 24 10          	mov    0x10(%esp),%esi
  801214:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801218:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80121c:	83 c4 1c             	add    $0x1c,%esp
  80121f:	c3                   	ret    
  801220:	85 c9                	test   %ecx,%ecx
  801222:	75 0b                	jne    80122f <__umoddi3+0x8f>
  801224:	b8 01 00 00 00       	mov    $0x1,%eax
  801229:	31 d2                	xor    %edx,%edx
  80122b:	f7 f1                	div    %ecx
  80122d:	89 c1                	mov    %eax,%ecx
  80122f:	89 f0                	mov    %esi,%eax
  801231:	31 d2                	xor    %edx,%edx
  801233:	f7 f1                	div    %ecx
  801235:	8b 04 24             	mov    (%esp),%eax
  801238:	f7 f1                	div    %ecx
  80123a:	eb 98                	jmp    8011d4 <__umoddi3+0x34>
  80123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801240:	89 f2                	mov    %esi,%edx
  801242:	8b 74 24 10          	mov    0x10(%esp),%esi
  801246:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80124a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124e:	83 c4 1c             	add    $0x1c,%esp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125d:	89 e8                	mov    %ebp,%eax
  80125f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801264:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801268:	89 fa                	mov    %edi,%edx
  80126a:	d3 e0                	shl    %cl,%eax
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	d3 ea                	shr    %cl,%edx
  801270:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801275:	09 c2                	or     %eax,%edx
  801277:	8b 44 24 08          	mov    0x8(%esp),%eax
  80127b:	89 14 24             	mov    %edx,(%esp)
  80127e:	89 f2                	mov    %esi,%edx
  801280:	d3 e7                	shl    %cl,%edi
  801282:	89 e9                	mov    %ebp,%ecx
  801284:	d3 ea                	shr    %cl,%edx
  801286:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128f:	d3 e6                	shl    %cl,%esi
  801291:	89 e9                	mov    %ebp,%ecx
  801293:	d3 e8                	shr    %cl,%eax
  801295:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129a:	09 f0                	or     %esi,%eax
  80129c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012a0:	f7 34 24             	divl   (%esp)
  8012a3:	d3 e6                	shl    %cl,%esi
  8012a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012a9:	89 d6                	mov    %edx,%esi
  8012ab:	f7 e7                	mul    %edi
  8012ad:	39 d6                	cmp    %edx,%esi
  8012af:	89 c1                	mov    %eax,%ecx
  8012b1:	89 d7                	mov    %edx,%edi
  8012b3:	72 3f                	jb     8012f4 <__umoddi3+0x154>
  8012b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012b9:	72 35                	jb     8012f0 <__umoddi3+0x150>
  8012bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bf:	29 c8                	sub    %ecx,%eax
  8012c1:	19 fe                	sbb    %edi,%esi
  8012c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c8:	89 f2                	mov    %esi,%edx
  8012ca:	d3 e8                	shr    %cl,%eax
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d5:	09 d0                	or     %edx,%eax
  8012d7:	89 f2                	mov    %esi,%edx
  8012d9:	d3 ea                	shr    %cl,%edx
  8012db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012e7:	83 c4 1c             	add    $0x1c,%esp
  8012ea:	c3                   	ret    
  8012eb:	90                   	nop
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	39 d6                	cmp    %edx,%esi
  8012f2:	75 c7                	jne    8012bb <__umoddi3+0x11b>
  8012f4:	89 d7                	mov    %edx,%edi
  8012f6:	89 c1                	mov    %eax,%ecx
  8012f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012fc:	1b 3c 24             	sbb    (%esp),%edi
  8012ff:	eb ba                	jmp    8012bb <__umoddi3+0x11b>
  801301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 f5                	cmp    %esi,%ebp
  80130a:	0f 82 f1 fe ff ff    	jb     801201 <__umoddi3+0x61>
  801310:	e9 f8 fe ff ff       	jmp    80120d <__umoddi3+0x6d>
