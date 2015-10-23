
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 d0 12 00 00       	call   801328 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  800071:	e8 39 02 00 00       	call   8002af <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 78 10 00 00       	call   8010f3 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 4c 17 80 	movl   $0x80174c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 55 17 80 00 	movl   $0x801755,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 68 12 00 00       	call   801328 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 61 12 00 00       	call   80134a <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 fb 0f 00 00       	call   8010f3 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 4c 17 80 	movl   $0x80174c,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 55 17 80 00 	movl   $0x801755,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 02 12 00 00       	call   80134a <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800162:	e8 7d 0b 00 00       	call   800ce4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 d5 0a 00 00       	call   800c87 <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001bc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c5:	e8 1a 0b 00 00       	call   800ce4 <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  8001e7:	e8 c3 00 00 00       	call   8002af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 53 00 00 00       	call   80024e <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 93 17 80 00 	movl   $0x801793,(%esp)
  800202:	e8 a8 00 00 00       	call   8002af <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>
	...

0080020c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 14             	sub    $0x14,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 03                	mov    (%ebx),%eax
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021f:	83 c0 01             	add    $0x1,%eax
  800222:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800224:	3d ff 00 00 00       	cmp    $0xff,%eax
  800229:	75 19                	jne    800244 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800232:	00 
  800233:	8d 43 08             	lea    0x8(%ebx),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 ea 09 00 00       	call   800c28 <sys_cputs>
		b->idx = 0;
  80023e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800244:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800257:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025e:	00 00 00 
	b.cnt = 0;
  800261:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800268:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 44 24 08          	mov    %eax,0x8(%esp)
  800279:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800283:	c7 04 24 0c 02 80 00 	movl   $0x80020c,(%esp)
  80028a:	e8 8e 01 00 00       	call   80041d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800295:	89 44 24 04          	mov    %eax,0x4(%esp)
  800299:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 81 09 00 00       	call   800c28 <sys_cputs>

	return b.cnt;
}
  8002a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	e8 87 ff ff ff       	call   80024e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
  8002cb:	00 00                	add    %al,(%eax)
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 3c             	sub    $0x3c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d7                	mov    %edx,%edi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	75 08                	jne    8002fc <printnum+0x2c>
  8002f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fa:	77 59                	ja     800355 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fc:	89 74 24 10          	mov    %esi,0x10(%esp)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800312:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800316:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031d:	00 
  80031e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800327:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032b:	e8 50 11 00 00       	call   801480 <__udivdi3>
  800330:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800334:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033f:	89 fa                	mov    %edi,%edx
  800341:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800344:	e8 87 ff ff ff       	call   8002d0 <printnum>
  800349:	eb 11                	jmp    80035c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034f:	89 34 24             	mov    %esi,(%esp)
  800352:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800355:	83 eb 01             	sub    $0x1,%ebx
  800358:	85 db                	test   %ebx,%ebx
  80035a:	7f ef                	jg     80034b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800360:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800372:	00 
  800373:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	e8 2b 12 00 00       	call   8015b0 <__umoddi3>
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	0f be 80 95 17 80 00 	movsbl 0x801795(%eax),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800396:	83 c4 3c             	add    $0x3c,%esp
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a1:	83 fa 01             	cmp    $0x1,%edx
  8003a4:	7e 0e                	jle    8003b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	8b 52 04             	mov    0x4(%edx),%edx
  8003b2:	eb 22                	jmp    8003d6 <getuint+0x38>
	else if (lflag)
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	74 10                	je     8003c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 0e                	jmp    8003d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003de:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e7:	73 0a                	jae    8003f3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ec:	88 0a                	mov    %cl,(%edx)
  8003ee:	83 c2 01             	add    $0x1,%edx
  8003f1:	89 10                	mov    %edx,(%eax)
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800402:	8b 45 10             	mov    0x10(%ebp),%eax
  800405:	89 44 24 08          	mov    %eax,0x8(%esp)
  800409:	8b 45 0c             	mov    0xc(%ebp),%eax
  80040c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	89 04 24             	mov    %eax,(%esp)
  800416:	e8 02 00 00 00       	call   80041d <vprintfmt>
	va_end(ap);
}
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 4c             	sub    $0x4c,%esp
  800426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800429:	8b 75 10             	mov    0x10(%ebp),%esi
  80042c:	eb 12                	jmp    800440 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042e:	85 c0                	test   %eax,%eax
  800430:	0f 84 bf 03 00 00    	je     8007f5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800440:	0f b6 06             	movzbl (%esi),%eax
  800443:	83 c6 01             	add    $0x1,%esi
  800446:	83 f8 25             	cmp    $0x25,%eax
  800449:	75 e3                	jne    80042e <vprintfmt+0x11>
  80044b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80044f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800456:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80045b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046a:	eb 2b                	jmp    800497 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800473:	eb 22                	jmp    800497 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800478:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80047c:	eb 19                	jmp    800497 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800481:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800488:	eb 0d                	jmp    800497 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80048d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800490:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	0f b6 16             	movzbl (%esi),%edx
  80049a:	0f b6 c2             	movzbl %dl,%eax
  80049d:	8d 7e 01             	lea    0x1(%esi),%edi
  8004a0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004a3:	83 ea 23             	sub    $0x23,%edx
  8004a6:	80 fa 55             	cmp    $0x55,%dl
  8004a9:	0f 87 28 03 00 00    	ja     8007d7 <vprintfmt+0x3ba>
  8004af:	0f b6 d2             	movzbl %dl,%edx
  8004b2:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
  8004b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004bc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004c3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004cb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004cf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d5:	83 fa 09             	cmp    $0x9,%edx
  8004d8:	77 2f                	ja     800509 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004da:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004dd:	eb e9                	jmp    8004c8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 00                	mov    (%eax),%eax
  8004ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f0:	eb 1a                	jmp    80050c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f9:	79 9c                	jns    800497 <vprintfmt+0x7a>
  8004fb:	eb 81                	jmp    80047e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800500:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800507:	eb 8e                	jmp    800497 <vprintfmt+0x7a>
  800509:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80050c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800510:	79 85                	jns    800497 <vprintfmt+0x7a>
  800512:	e9 73 ff ff ff       	jmp    80048a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800517:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051d:	e9 75 ff ff ff       	jmp    800497 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053a:	e9 01 ff ff ff       	jmp    800440 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 c2                	mov    %eax,%edx
  80054c:	c1 fa 1f             	sar    $0x1f,%edx
  80054f:	31 d0                	xor    %edx,%eax
  800551:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800553:	83 f8 09             	cmp    $0x9,%eax
  800556:	7f 0b                	jg     800563 <vprintfmt+0x146>
  800558:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  80055f:	85 d2                	test   %edx,%edx
  800561:	75 23                	jne    800586 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800563:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800567:	c7 44 24 08 ad 17 80 	movl   $0x8017ad,0x8(%esp)
  80056e:	00 
  80056f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800573:	8b 7d 08             	mov    0x8(%ebp),%edi
  800576:	89 3c 24             	mov    %edi,(%esp)
  800579:	e8 77 fe ff ff       	call   8003f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800581:	e9 ba fe ff ff       	jmp    800440 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800586:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058a:	c7 44 24 08 b6 17 80 	movl   $0x8017b6,0x8(%esp)
  800591:	00 
  800592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800596:	8b 7d 08             	mov    0x8(%ebp),%edi
  800599:	89 3c 24             	mov    %edi,(%esp)
  80059c:	e8 54 fe ff ff       	call   8003f5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a4:	e9 97 fe ff ff       	jmp    800440 <vprintfmt+0x23>
  8005a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	ba a6 17 80 00       	mov    $0x8017a6,%edx
  8005c4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005cb:	0f 8e 8c 00 00 00    	jle    80065d <vprintfmt+0x240>
  8005d1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005d5:	0f 84 82 00 00 00    	je     80065d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005df:	89 34 24             	mov    %esi,(%esp)
  8005e2:	e8 b1 02 00 00       	call   800898 <strnlen>
  8005e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ea:	29 c2                	sub    %eax,%edx
  8005ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005ef:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005f6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005f9:	89 de                	mov    %ebx,%esi
  8005fb:	89 d3                	mov    %edx,%ebx
  8005fd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ff:	eb 0d                	jmp    80060e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800601:	89 74 24 04          	mov    %esi,0x4(%esp)
  800605:	89 3c 24             	mov    %edi,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	83 eb 01             	sub    $0x1,%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f ef                	jg     800601 <vprintfmt+0x1e4>
  800612:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800615:	89 f3                	mov    %esi,%ebx
  800617:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80061a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061e:	b8 00 00 00 00       	mov    $0x0,%eax
  800623:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800627:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062a:	29 c2                	sub    %eax,%edx
  80062c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80062f:	eb 2c                	jmp    80065d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800631:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800635:	74 18                	je     80064f <vprintfmt+0x232>
  800637:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063a:	83 fa 5e             	cmp    $0x5e,%edx
  80063d:	76 10                	jbe    80064f <vprintfmt+0x232>
					putch('?', putdat);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064a:	ff 55 08             	call   *0x8(%ebp)
  80064d:	eb 0a                	jmp    800659 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80064f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800659:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	83 c6 01             	add    $0x1,%esi
  800663:	85 c0                	test   %eax,%eax
  800665:	74 25                	je     80068c <vprintfmt+0x26f>
  800667:	85 ff                	test   %edi,%edi
  800669:	78 c6                	js     800631 <vprintfmt+0x214>
  80066b:	83 ef 01             	sub    $0x1,%edi
  80066e:	79 c1                	jns    800631 <vprintfmt+0x214>
  800670:	8b 7d 08             	mov    0x8(%ebp),%edi
  800673:	89 de                	mov    %ebx,%esi
  800675:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800685:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 eb 01             	sub    $0x1,%ebx
  80068a:	eb 08                	jmp    800694 <vprintfmt+0x277>
  80068c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80068f:	89 de                	mov    %ebx,%esi
  800691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800694:	85 db                	test   %ebx,%ebx
  800696:	7f e2                	jg     80067a <vprintfmt+0x25d>
  800698:	89 7d 08             	mov    %edi,0x8(%ebp)
  80069b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a0:	e9 9b fd ff ff       	jmp    800440 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a5:	83 f9 01             	cmp    $0x1,%ecx
  8006a8:	7e 10                	jle    8006ba <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 08             	lea    0x8(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	8b 78 04             	mov    0x4(%eax),%edi
  8006b8:	eb 26                	jmp    8006e0 <vprintfmt+0x2c3>
	else if (lflag)
  8006ba:	85 c9                	test   %ecx,%ecx
  8006bc:	74 12                	je     8006d0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c7:	8b 30                	mov    (%eax),%esi
  8006c9:	89 f7                	mov    %esi,%edi
  8006cb:	c1 ff 1f             	sar    $0x1f,%edi
  8006ce:	eb 10                	jmp    8006e0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 30                	mov    (%eax),%esi
  8006db:	89 f7                	mov    %esi,%edi
  8006dd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	0f 89 ac 00 00 00    	jns    800799 <vprintfmt+0x37c>
				putch('-', putdat);
  8006ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fb:	f7 de                	neg    %esi
  8006fd:	83 d7 00             	adc    $0x0,%edi
  800700:	f7 df                	neg    %edi
			}
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 8d 00 00 00       	jmp    800799 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070c:	89 ca                	mov    %ecx,%edx
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
  800711:	e8 88 fc ff ff       	call   80039e <getuint>
  800716:	89 c6                	mov    %eax,%esi
  800718:	89 d7                	mov    %edx,%edi
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80071f:	eb 78                	jmp    800799 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80072c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80072f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800733:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80073a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80073d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800741:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80074e:	e9 ed fc ff ff       	jmp    800440 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80075e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800761:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800765:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 04             	lea    0x4(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800778:	8b 30                	mov    (%eax),%esi
  80077a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800784:	eb 13                	jmp    800799 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800786:	89 ca                	mov    %ecx,%edx
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
  80078b:	e8 0e fc ff ff       	call   80039e <getuint>
  800790:	89 c6                	mov    %eax,%esi
  800792:	89 d7                	mov    %edx,%edi
			base = 16;
  800794:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800799:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80079d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ac:	89 34 24             	mov    %esi,(%esp)
  8007af:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b3:	89 da                	mov    %ebx,%edx
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	e8 13 fb ff ff       	call   8002d0 <printnum>
			break;
  8007bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c0:	e9 7b fc ff ff       	jmp    800440 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c9:	89 04 24             	mov    %eax,(%esp)
  8007cc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d2:	e9 69 fc ff ff       	jmp    800440 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e5:	eb 03                	jmp    8007ea <vprintfmt+0x3cd>
  8007e7:	83 ee 01             	sub    $0x1,%esi
  8007ea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ee:	75 f7                	jne    8007e7 <vprintfmt+0x3ca>
  8007f0:	e9 4b fc ff ff       	jmp    800440 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007f5:	83 c4 4c             	add    $0x4c,%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5f                   	pop    %edi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 28             	sub    $0x28,%esp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800809:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800810:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800813:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081a:	85 c0                	test   %eax,%eax
  80081c:	74 30                	je     80084e <vsnprintf+0x51>
  80081e:	85 d2                	test   %edx,%edx
  800820:	7e 2c                	jle    80084e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800829:	8b 45 10             	mov    0x10(%ebp),%eax
  80082c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800830:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800833:	89 44 24 04          	mov    %eax,0x4(%esp)
  800837:	c7 04 24 d8 03 80 00 	movl   $0x8003d8,(%esp)
  80083e:	e8 da fb ff ff       	call   80041d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800843:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800846:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084c:	eb 05                	jmp    800853 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
  800865:	89 44 24 08          	mov    %eax,0x8(%esp)
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	89 04 24             	mov    %eax,(%esp)
  800876:	e8 82 ff ff ff       	call   8007fd <vsnprintf>
	va_end(ap);

	return rc;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
  80087d:	00 00                	add    %al,(%eax)
	...

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
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
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
  8008be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ca:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008cd:	83 c2 01             	add    $0x1,%edx
  8008d0:	84 c9                	test   %cl,%cl
  8008d2:	75 f2                	jne    8008c6 <strcpy+0xf>
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
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800910:	b9 00 00 00 00       	mov    $0x0,%ecx
  800915:	eb 0f                	jmp    800926 <strncpy+0x24>
		*dst++ = *src;
  800917:	0f b6 1a             	movzbl (%edx),%ebx
  80091a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091d:	80 3a 01             	cmpb   $0x1,(%edx)
  800920:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800923:	83 c1 01             	add    $0x1,%ecx
  800926:	39 f1                	cmp    %esi,%ecx
  800928:	75 ed                	jne    800917 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	85 d2                	test   %edx,%edx
  800940:	75 0a                	jne    80094c <strlcpy+0x1e>
  800942:	eb 1d                	jmp    800961 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800944:	88 18                	mov    %bl,(%eax)
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094c:	83 ea 01             	sub    $0x1,%edx
  80094f:	74 0b                	je     80095c <strlcpy+0x2e>
  800951:	0f b6 19             	movzbl (%ecx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	75 ec                	jne    800944 <strlcpy+0x16>
  800958:	89 c2                	mov    %eax,%edx
  80095a:	eb 02                	jmp    80095e <strlcpy+0x30>
  80095c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80095e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800961:	29 f0                	sub    %esi,%eax
}
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800970:	eb 06                	jmp    800978 <strcmp+0x11>
		p++, q++;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800978:	0f b6 01             	movzbl (%ecx),%eax
  80097b:	84 c0                	test   %al,%al
  80097d:	74 04                	je     800983 <strcmp+0x1c>
  80097f:	3a 02                	cmp    (%edx),%al
  800981:	74 ef                	je     800972 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800983:	0f b6 c0             	movzbl %al,%eax
  800986:	0f b6 12             	movzbl (%edx),%edx
  800989:	29 d0                	sub    %edx,%eax
}
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80099a:	eb 09                	jmp    8009a5 <strncmp+0x18>
		n--, p++, q++;
  80099c:	83 ea 01             	sub    $0x1,%edx
  80099f:	83 c0 01             	add    $0x1,%eax
  8009a2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	74 15                	je     8009be <strncmp+0x31>
  8009a9:	0f b6 18             	movzbl (%eax),%ebx
  8009ac:	84 db                	test   %bl,%bl
  8009ae:	74 04                	je     8009b4 <strncmp+0x27>
  8009b0:	3a 19                	cmp    (%ecx),%bl
  8009b2:	74 e8                	je     80099c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	0f b6 11             	movzbl (%ecx),%edx
  8009ba:	29 d0                	sub    %edx,%eax
  8009bc:	eb 05                	jmp    8009c3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d0:	eb 07                	jmp    8009d9 <strchr+0x13>
		if (*s == c)
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	74 0f                	je     8009e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	75 f2                	jne    8009d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f1:	eb 07                	jmp    8009fa <strfind+0x13>
		if (*s == c)
  8009f3:	38 ca                	cmp    %cl,%dl
  8009f5:	74 0a                	je     800a01 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	0f b6 10             	movzbl (%eax),%edx
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	75 f2                	jne    8009f3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1b:	85 c9                	test   %ecx,%ecx
  800a1d:	74 30                	je     800a4f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a25:	75 25                	jne    800a4c <memset+0x49>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	75 20                	jne    800a4c <memset+0x49>
		c &= 0xFF;
  800a2c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a2f:	89 d3                	mov    %edx,%ebx
  800a31:	c1 e3 08             	shl    $0x8,%ebx
  800a34:	89 d6                	mov    %edx,%esi
  800a36:	c1 e6 18             	shl    $0x18,%esi
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	c1 e0 10             	shl    $0x10,%eax
  800a3e:	09 f0                	or     %esi,%eax
  800a40:	09 d0                	or     %edx,%eax
  800a42:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a44:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a47:	fc                   	cld    
  800a48:	f3 ab                	rep stos %eax,%es:(%edi)
  800a4a:	eb 03                	jmp    800a4f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4c:	fc                   	cld    
  800a4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a54:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a57:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a5a:	89 ec                	mov    %ebp,%esp
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a67:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a73:	39 c6                	cmp    %eax,%esi
  800a75:	73 36                	jae    800aad <memmove+0x4f>
  800a77:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	73 2f                	jae    800aad <memmove+0x4f>
		s += n;
		d += n;
  800a7e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	f6 c2 03             	test   $0x3,%dl
  800a84:	75 1b                	jne    800aa1 <memmove+0x43>
  800a86:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8c:	75 13                	jne    800aa1 <memmove+0x43>
  800a8e:	f6 c1 03             	test   $0x3,%cl
  800a91:	75 0e                	jne    800aa1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a93:	83 ef 04             	sub    $0x4,%edi
  800a96:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a99:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a9c:	fd                   	std    
  800a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9f:	eb 09                	jmp    800aaa <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa1:	83 ef 01             	sub    $0x1,%edi
  800aa4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa7:	fd                   	std    
  800aa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaa:	fc                   	cld    
  800aab:	eb 20                	jmp    800acd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab3:	75 13                	jne    800ac8 <memmove+0x6a>
  800ab5:	a8 03                	test   $0x3,%al
  800ab7:	75 0f                	jne    800ac8 <memmove+0x6a>
  800ab9:	f6 c1 03             	test   $0x3,%cl
  800abc:	75 0a                	jne    800ac8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac1:	89 c7                	mov    %eax,%edi
  800ac3:	fc                   	cld    
  800ac4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac6:	eb 05                	jmp    800acd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac8:	89 c7                	mov    %eax,%edi
  800aca:	fc                   	cld    
  800acb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ad0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ad3:	89 ec                	mov    %ebp,%esp
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800add:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	89 04 24             	mov    %eax,(%esp)
  800af1:	e8 68 ff ff ff       	call   800a5e <memmove>
}
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	eb 1a                	jmp    800b28 <memcmp+0x30>
		if (*s1 != *s2)
  800b0e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b12:	83 c2 01             	add    $0x1,%edx
  800b15:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800b1a:	38 c8                	cmp    %cl,%al
  800b1c:	74 0a                	je     800b28 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c0             	movzbl %al,%eax
  800b21:	0f b6 c9             	movzbl %cl,%ecx
  800b24:	29 c8                	sub    %ecx,%eax
  800b26:	eb 09                	jmp    800b31 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b28:	39 da                	cmp    %ebx,%edx
  800b2a:	75 e2                	jne    800b0e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b44:	eb 07                	jmp    800b4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b46:	38 08                	cmp    %cl,(%eax)
  800b48:	74 07                	je     800b51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	39 d0                	cmp    %edx,%eax
  800b4f:	72 f5                	jb     800b46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5f:	eb 03                	jmp    800b64 <strtol+0x11>
		s++;
  800b61:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b64:	0f b6 02             	movzbl (%edx),%eax
  800b67:	3c 20                	cmp    $0x20,%al
  800b69:	74 f6                	je     800b61 <strtol+0xe>
  800b6b:	3c 09                	cmp    $0x9,%al
  800b6d:	74 f2                	je     800b61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b6f:	3c 2b                	cmp    $0x2b,%al
  800b71:	75 0a                	jne    800b7d <strtol+0x2a>
		s++;
  800b73:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b76:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7b:	eb 10                	jmp    800b8d <strtol+0x3a>
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b82:	3c 2d                	cmp    $0x2d,%al
  800b84:	75 07                	jne    800b8d <strtol+0x3a>
		s++, neg = 1;
  800b86:	8d 52 01             	lea    0x1(%edx),%edx
  800b89:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8d:	85 db                	test   %ebx,%ebx
  800b8f:	0f 94 c0             	sete   %al
  800b92:	74 05                	je     800b99 <strtol+0x46>
  800b94:	83 fb 10             	cmp    $0x10,%ebx
  800b97:	75 15                	jne    800bae <strtol+0x5b>
  800b99:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9c:	75 10                	jne    800bae <strtol+0x5b>
  800b9e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba2:	75 0a                	jne    800bae <strtol+0x5b>
		s += 2, base = 16;
  800ba4:	83 c2 02             	add    $0x2,%edx
  800ba7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bac:	eb 13                	jmp    800bc1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bae:	84 c0                	test   %al,%al
  800bb0:	74 0f                	je     800bc1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bba:	75 05                	jne    800bc1 <strtol+0x6e>
		s++, base = 8;
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc8:	0f b6 0a             	movzbl (%edx),%ecx
  800bcb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bce:	80 fb 09             	cmp    $0x9,%bl
  800bd1:	77 08                	ja     800bdb <strtol+0x88>
			dig = *s - '0';
  800bd3:	0f be c9             	movsbl %cl,%ecx
  800bd6:	83 e9 30             	sub    $0x30,%ecx
  800bd9:	eb 1e                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bdb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bde:	80 fb 19             	cmp    $0x19,%bl
  800be1:	77 08                	ja     800beb <strtol+0x98>
			dig = *s - 'a' + 10;
  800be3:	0f be c9             	movsbl %cl,%ecx
  800be6:	83 e9 57             	sub    $0x57,%ecx
  800be9:	eb 0e                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800beb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bee:	80 fb 19             	cmp    $0x19,%bl
  800bf1:	77 14                	ja     800c07 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800bf3:	0f be c9             	movsbl %cl,%ecx
  800bf6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bf9:	39 f1                	cmp    %esi,%ecx
  800bfb:	7d 0e                	jge    800c0b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800bfd:	83 c2 01             	add    $0x1,%edx
  800c00:	0f af c6             	imul   %esi,%eax
  800c03:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c05:	eb c1                	jmp    800bc8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c07:	89 c1                	mov    %eax,%ecx
  800c09:	eb 02                	jmp    800c0d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c0b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c11:	74 05                	je     800c18 <strtol+0xc5>
		*endptr = (char *) s;
  800c13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c16:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c18:	89 ca                	mov    %ecx,%edx
  800c1a:	f7 da                	neg    %edx
  800c1c:	85 ff                	test   %edi,%edi
  800c1e:	0f 45 c2             	cmovne %edx,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
	...

00800c28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 c3                	mov    %eax,%ebx
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	89 c6                	mov    %eax,%esi
  800c48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c53:	89 ec                	mov    %ebp,%esp
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c60:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c63:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c83:	89 ec                	mov    %ebp,%esp
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 38             	sub    $0x38,%esp
  800c8d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c90:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c93:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 cb                	mov    %ecx,%ebx
  800ca5:	89 cf                	mov    %ecx,%edi
  800ca7:	89 ce                	mov    %ecx,%esi
  800ca9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 28                	jle    800cd7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cba:	00 
  800cbb:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cca:	00 
  800ccb:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800cd2:	e8 dd f4 ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce0:	89 ec                	mov    %ebp,%esp
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ced:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf8:	b8 02 00 00 00       	mov    $0x2,%eax
  800cfd:	89 d1                	mov    %edx,%ecx
  800cff:	89 d3                	mov    %edx,%ebx
  800d01:	89 d7                	mov    %edx,%edi
  800d03:	89 d6                	mov    %edx,%esi
  800d05:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d07:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d10:	89 ec                	mov    %ebp,%esp
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_yield>:

void
sys_yield(void)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d20:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2d:	89 d1                	mov    %edx,%ecx
  800d2f:	89 d3                	mov    %edx,%ebx
  800d31:	89 d7                	mov    %edx,%edi
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d40:	89 ec                	mov    %ebp,%esp
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 38             	sub    $0x38,%esp
  800d4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d50:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	be 00 00 00 00       	mov    $0x0,%esi
  800d58:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 f7                	mov    %esi,%edi
  800d68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 28                	jle    800d96 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d72:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d79:	00 
  800d7a:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800d81:	00 
  800d82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d89:	00 
  800d8a:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800d91:	e8 1e f4 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9f:	89 ec                	mov    %ebp,%esp
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 38             	sub    $0x38,%esp
  800da9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800daf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	b8 05 00 00 00       	mov    $0x5,%eax
  800db7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800def:	e8 c0 f3 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 38             	sub    $0x38,%esp
  800e07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800e4d:	e8 62 f3 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5b:	89 ec                	mov    %ebp,%esp
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 38             	sub    $0x38,%esp
  800e65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 08 00 00 00       	mov    $0x8,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800eab:	e8 04 f3 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb9:	89 ec                	mov    %ebp,%esp
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 38             	sub    $0x38,%esp
  800ec3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 28                	jle    800f0e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eea:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f01:	00 
  800f02:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800f09:	e8 a6 f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f17:	89 ec                	mov    %ebp,%esp
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2a:	be 00 00 00 00       	mov    $0x0,%esi
  800f2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4b:	89 ec                	mov    %ebp,%esp
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 38             	sub    $0x38,%esp
  800f55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	89 cb                	mov    %ecx,%ebx
  800f6d:	89 cf                	mov    %ecx,%edi
  800f6f:	89 ce                	mov    %ecx,%esi
  800f71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 28                	jle    800f9f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f82:	00 
  800f83:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f92:	00 
  800f93:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  800f9a:	e8 15 f2 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa8:	89 ec                	mov    %ebp,%esp
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 20             	sub    $0x20,%esp
  800fb4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0)
  800fb9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbd:	75 1c                	jne    800fdb <pgfault+0x2f>
		 panic("The err is not right of the pgfault\n");
  800fbf:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800fce:	00 
  800fcf:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  800fd6:	e8 d9 f1 ff ff       	call   8001b4 <_panic>
	pte_t PTE =uvpt[PGNUM(addr)];
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	c1 e8 0c             	shr    $0xc,%eax
  800fe0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800fe7:	f6 c4 08             	test   $0x8,%ah
  800fea:	75 1c                	jne    801008 <pgfault+0x5c>
		panic("The pgfault perm is not right\n");
  800fec:	c7 44 24 08 3c 1a 80 	movl   $0x801a3c,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  801003:	e8 ac f1 ff ff       	call   8001b4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  801008:	e8 d7 fc ff ff       	call   800ce4 <sys_getenvid>
  80100d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 1f fd ff ff       	call   800d44 <sys_page_alloc>
  801025:	85 c0                	test   %eax,%eax
  801027:	79 1c                	jns    801045 <pgfault+0x99>
		panic("pgfault sys_page_alloc is not right\n");
  801029:	c7 44 24 08 5c 1a 80 	movl   $0x801a5c,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  801040:	e8 6f f1 ff ff       	call   8001b4 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801045:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80104b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801052:	00 
  801053:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801057:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80105e:	e8 74 fa ff ff       	call   800ad7 <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801063:	e8 7c fc ff ff       	call   800ce4 <sys_getenvid>
  801068:	89 c6                	mov    %eax,%esi
  80106a:	e8 75 fc ff ff       	call   800ce4 <sys_getenvid>
  80106f:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801076:	00 
  801077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80107b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80107f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801086:	00 
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 14 fd ff ff       	call   800da3 <sys_page_map>
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 20                	jns    8010b3 <pgfault+0x107>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801093:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801097:	c7 44 24 08 84 1a 80 	movl   $0x801a84,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010a6:	00 
  8010a7:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  8010ae:	e8 01 f1 ff ff       	call   8001b4 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  8010b3:	e8 2c fc ff ff       	call   800ce4 <sys_getenvid>
  8010b8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010bf:	00 
  8010c0:	89 04 24             	mov    %eax,(%esp)
  8010c3:	e8 39 fd ff ff       	call   800e01 <sys_page_unmap>
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	79 20                	jns    8010ec <pgfault+0x140>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8010cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d0:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  8010e7:	e8 c8 f0 ff ff       	call   8001b4 <_panic>




	//panic("pgfault not implemented");
}
  8010ec:	83 c4 20             	add    $0x20,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  8010fc:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  801103:	e8 9c 02 00 00       	call   8013a4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801108:	ba 07 00 00 00       	mov    $0x7,%edx
  80110d:	89 d0                	mov    %edx,%eax
  80110f:	cd 30                	int    $0x30
  801111:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801114:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	79 20                	jns    80113b <fork+0x48>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80111b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111f:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  801136:	e8 79 f0 ff ff       	call   8001b4 <_panic>
	if(childEid == 0){
  80113b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80113f:	75 1c                	jne    80115d <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801141:	e8 9e fb ff ff       	call   800ce4 <sys_getenvid>
  801146:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80114e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801153:	a3 04 20 80 00       	mov    %eax,0x802004
		return childEid;
  801158:	e9 9d 01 00 00       	jmp    8012fa <fork+0x207>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80115d:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  801164:	00 
  801165:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801168:	89 04 24             	mov    %eax,(%esp)
  80116b:	e8 4d fd ff ff       	call   800ebd <sys_env_set_pgfault_upcall>
  801170:	89 c6                	mov    %eax,%esi
	if(r < 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	79 20                	jns    801196 <fork+0xa3>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801176:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117a:	c7 44 24 08 1c 1b 80 	movl   $0x801b1c,0x8(%esp)
  801181:	00 
  801182:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801189:	00 
  80118a:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  801191:	e8 1e f0 ff ff       	call   8001b4 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801196:	bb 00 10 00 00       	mov    $0x1000,%ebx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80119b:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a5:	eb 04                	jmp    8011ab <fork+0xb8>
  8011a7:	89 da                	mov    %ebx,%edx
  8011a9:	89 c3                	mov    %eax,%ebx
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011ab:	89 d0                	mov    %edx,%eax
  8011ad:	c1 e8 16             	shr    $0x16,%eax
  8011b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b7:	a8 01                	test   $0x1,%al
  8011b9:	0f 84 f5 00 00 00    	je     8012b4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011bf:	c1 ea 0c             	shr    $0xc,%edx
  8011c2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011c9:	a8 04                	test   $0x4,%al
  8011cb:	0f 84 e3 00 00 00    	je     8012b4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8011d1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011d8:	a8 01                	test   $0x1,%al
  8011da:	0f 84 d4 00 00 00    	je     8012b4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8011e0:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8011e6:	75 20                	jne    801208 <fork+0x115>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8011e8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011f7:	ee 
  8011f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011fb:	89 14 24             	mov    %edx,(%esp)
  8011fe:	e8 41 fb ff ff       	call   800d44 <sys_page_alloc>
  801203:	e9 88 00 00 00       	jmp    801290 <fork+0x19d>
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  801208:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  80120e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801211:	c1 e8 0c             	shr    $0xc,%eax
  801214:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  80121b:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  801220:	83 f8 01             	cmp    $0x1,%eax
  801223:	19 ff                	sbb    %edi,%edi
  801225:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80122b:	81 c7 05 08 00 00    	add    $0x805,%edi
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  801231:	e8 ae fa ff ff       	call   800ce4 <sys_getenvid>
  801236:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80123a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80123d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801241:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801244:	89 54 24 08          	mov    %edx,0x8(%esp)
  801248:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80124b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 4c fb ff ff       	call   800da3 <sys_page_map>
  801257:	89 c6                	mov    %eax,%esi
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 33                	js     801290 <fork+0x19d>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  80125d:	e8 82 fa ff ff       	call   800ce4 <sys_getenvid>
  801262:	89 c6                	mov    %eax,%esi
  801264:	e8 7b fa ff ff       	call   800ce4 <sys_getenvid>
  801269:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80126d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801270:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801274:	89 74 24 08          	mov    %esi,0x8(%esp)
  801278:	89 54 24 04          	mov    %edx,0x4(%esp)
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 1f fb ff ff       	call   800da3 <sys_page_map>
  801284:	89 c6                	mov    %eax,%esi
						<0)  
		return r;

	return 0;
  801286:	85 c0                	test   %eax,%eax
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
  80128d:	0f 49 f0             	cmovns %eax,%esi
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801290:	85 f6                	test   %esi,%esi
  801292:	79 20                	jns    8012b4 <fork+0x1c1>
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801294:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801298:	c7 44 24 08 5c 1b 80 	movl   $0x801b5c,0x8(%esp)
  80129f:	00 
  8012a0:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8012a7:	00 
  8012a8:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  8012af:	e8 00 ef ff ff       	call   8001b4 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8012b4:	89 d9                	mov    %ebx,%ecx
  8012b6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  8012bc:	3d 00 10 c0 ee       	cmp    $0xeec01000,%eax
  8012c1:	0f 85 e0 fe ff ff    	jne    8011a7 <fork+0xb4>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8012c7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ce:	00 
  8012cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 85 fb ff ff       	call   800e5f <sys_env_set_status>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	79 1c                	jns    8012fa <fork+0x207>
		panic("sys_env_set_status");
  8012de:	c7 44 24 08 8d 1b 80 	movl   $0x801b8d,0x8(%esp)
  8012e5:	00 
  8012e6:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8012ed:	00 
  8012ee:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  8012f5:	e8 ba ee ff ff       	call   8001b4 <_panic>
	return childEid;
}
  8012fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fd:	83 c4 3c             	add    $0x3c,%esp
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sfork>:

// Challenge!
int
sfork(void)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80130b:	c7 44 24 08 a0 1b 80 	movl   $0x801ba0,0x8(%esp)
  801312:	00 
  801313:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80131a:	00 
  80131b:	c7 04 24 82 1b 80 00 	movl   $0x801b82,(%esp)
  801322:	e8 8d ee ff ff       	call   8001b4 <_panic>
	...

00801328 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80132e:	c7 44 24 08 b6 1b 80 	movl   $0x801bb6,0x8(%esp)
  801335:	00 
  801336:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80133d:	00 
  80133e:	c7 04 24 cf 1b 80 00 	movl   $0x801bcf,(%esp)
  801345:	e8 6a ee ff ff       	call   8001b4 <_panic>

0080134a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801350:	c7 44 24 08 d9 1b 80 	movl   $0x801bd9,0x8(%esp)
  801357:	00 
  801358:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80135f:	00 
  801360:	c7 04 24 cf 1b 80 00 	movl   $0x801bcf,(%esp)
  801367:	e8 48 ee ff ff       	call   8001b4 <_panic>

0080136c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801377:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80137a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801380:	8b 52 50             	mov    0x50(%edx),%edx
  801383:	39 ca                	cmp    %ecx,%edx
  801385:	75 0d                	jne    801394 <ipc_find_env+0x28>
			return envs[i].env_id;
  801387:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138a:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80138f:	8b 40 40             	mov    0x40(%eax),%eax
  801392:	eb 0e                	jmp    8013a2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801394:	83 c0 01             	add    $0x1,%eax
  801397:	3d 00 04 00 00       	cmp    $0x400,%eax
  80139c:	75 d9                	jne    801377 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80139e:	66 b8 00 00          	mov    $0x0,%ax
}
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013aa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013b1:	75 44                	jne    8013f7 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8013b3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013b8:	8b 40 48             	mov    0x48(%eax),%eax
  8013bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c2:	00 
  8013c3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013ca:	ee 
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 71 f9 ff ff       	call   800d44 <sys_page_alloc>
		if( r < 0)
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	79 20                	jns    8013f7 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  8013d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013db:	c7 44 24 08 f4 1b 80 	movl   $0x801bf4,0x8(%esp)
  8013e2:	00 
  8013e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ea:	00 
  8013eb:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  8013f2:	e8 bd ed ff ff       	call   8001b4 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8013ff:	e8 e0 f8 ff ff       	call   800ce4 <sys_getenvid>
  801404:	c7 44 24 04 3c 14 80 	movl   $0x80143c,0x4(%esp)
  80140b:	00 
  80140c:	89 04 24             	mov    %eax,(%esp)
  80140f:	e8 a9 fa ff ff       	call   800ebd <sys_env_set_pgfault_upcall>
  801414:	85 c0                	test   %eax,%eax
  801416:	79 20                	jns    801438 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  801418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141c:	c7 44 24 08 24 1c 80 	movl   $0x801c24,0x8(%esp)
  801423:	00 
  801424:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80142b:	00 
  80142c:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  801433:	e8 7c ed ff ff       	call   8001b4 <_panic>


}
  801438:	c9                   	leave  
  801439:	c3                   	ret    
	...

0080143c <_pgfault_upcall>:
  80143c:	54                   	push   %esp
  80143d:	a1 08 20 80 00       	mov    0x802008,%eax
  801442:	ff d0                	call   *%eax
  801444:	83 c4 04             	add    $0x4,%esp
  801447:	8b 44 24 28          	mov    0x28(%esp),%eax
  80144b:	8b 5c 24 10          	mov    0x10(%esp),%ebx
  80144f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801453:	89 41 fc             	mov    %eax,-0x4(%ecx)
  801456:	89 59 f8             	mov    %ebx,-0x8(%ecx)
  801459:	8d 69 f8             	lea    -0x8(%ecx),%ebp
  80145c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801460:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801464:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801468:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  80146c:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801470:	8b 44 24 24          	mov    0x24(%esp),%eax
  801474:	8d 64 24 2c          	lea    0x2c(%esp),%esp
  801478:	9d                   	popf   
  801479:	c9                   	leave  
  80147a:	c3                   	ret    
  80147b:	00 00                	add    %al,(%eax)
  80147d:	00 00                	add    %al,(%eax)
	...

00801480 <__udivdi3>:
  801480:	83 ec 1c             	sub    $0x1c,%esp
  801483:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801487:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80148b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80148f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801493:	89 74 24 10          	mov    %esi,0x10(%esp)
  801497:	8b 74 24 24          	mov    0x24(%esp),%esi
  80149b:	85 ff                	test   %edi,%edi
  80149d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a5:	89 cd                	mov    %ecx,%ebp
  8014a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ab:	75 33                	jne    8014e0 <__udivdi3+0x60>
  8014ad:	39 f1                	cmp    %esi,%ecx
  8014af:	77 57                	ja     801508 <__udivdi3+0x88>
  8014b1:	85 c9                	test   %ecx,%ecx
  8014b3:	75 0b                	jne    8014c0 <__udivdi3+0x40>
  8014b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ba:	31 d2                	xor    %edx,%edx
  8014bc:	f7 f1                	div    %ecx
  8014be:	89 c1                	mov    %eax,%ecx
  8014c0:	89 f0                	mov    %esi,%eax
  8014c2:	31 d2                	xor    %edx,%edx
  8014c4:	f7 f1                	div    %ecx
  8014c6:	89 c6                	mov    %eax,%esi
  8014c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014cc:	f7 f1                	div    %ecx
  8014ce:	89 f2                	mov    %esi,%edx
  8014d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014dc:	83 c4 1c             	add    $0x1c,%esp
  8014df:	c3                   	ret    
  8014e0:	31 d2                	xor    %edx,%edx
  8014e2:	31 c0                	xor    %eax,%eax
  8014e4:	39 f7                	cmp    %esi,%edi
  8014e6:	77 e8                	ja     8014d0 <__udivdi3+0x50>
  8014e8:	0f bd cf             	bsr    %edi,%ecx
  8014eb:	83 f1 1f             	xor    $0x1f,%ecx
  8014ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f2:	75 2c                	jne    801520 <__udivdi3+0xa0>
  8014f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8014f8:	76 04                	jbe    8014fe <__udivdi3+0x7e>
  8014fa:	39 f7                	cmp    %esi,%edi
  8014fc:	73 d2                	jae    8014d0 <__udivdi3+0x50>
  8014fe:	31 d2                	xor    %edx,%edx
  801500:	b8 01 00 00 00       	mov    $0x1,%eax
  801505:	eb c9                	jmp    8014d0 <__udivdi3+0x50>
  801507:	90                   	nop
  801508:	89 f2                	mov    %esi,%edx
  80150a:	f7 f1                	div    %ecx
  80150c:	31 d2                	xor    %edx,%edx
  80150e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801512:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801516:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80151a:	83 c4 1c             	add    $0x1c,%esp
  80151d:	c3                   	ret    
  80151e:	66 90                	xchg   %ax,%ax
  801520:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801525:	b8 20 00 00 00       	mov    $0x20,%eax
  80152a:	89 ea                	mov    %ebp,%edx
  80152c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801530:	d3 e7                	shl    %cl,%edi
  801532:	89 c1                	mov    %eax,%ecx
  801534:	d3 ea                	shr    %cl,%edx
  801536:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80153b:	09 fa                	or     %edi,%edx
  80153d:	89 f7                	mov    %esi,%edi
  80153f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801543:	89 f2                	mov    %esi,%edx
  801545:	8b 74 24 08          	mov    0x8(%esp),%esi
  801549:	d3 e5                	shl    %cl,%ebp
  80154b:	89 c1                	mov    %eax,%ecx
  80154d:	d3 ef                	shr    %cl,%edi
  80154f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801554:	d3 e2                	shl    %cl,%edx
  801556:	89 c1                	mov    %eax,%ecx
  801558:	d3 ee                	shr    %cl,%esi
  80155a:	09 d6                	or     %edx,%esi
  80155c:	89 fa                	mov    %edi,%edx
  80155e:	89 f0                	mov    %esi,%eax
  801560:	f7 74 24 0c          	divl   0xc(%esp)
  801564:	89 d7                	mov    %edx,%edi
  801566:	89 c6                	mov    %eax,%esi
  801568:	f7 e5                	mul    %ebp
  80156a:	39 d7                	cmp    %edx,%edi
  80156c:	72 22                	jb     801590 <__udivdi3+0x110>
  80156e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801572:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801577:	d3 e5                	shl    %cl,%ebp
  801579:	39 c5                	cmp    %eax,%ebp
  80157b:	73 04                	jae    801581 <__udivdi3+0x101>
  80157d:	39 d7                	cmp    %edx,%edi
  80157f:	74 0f                	je     801590 <__udivdi3+0x110>
  801581:	89 f0                	mov    %esi,%eax
  801583:	31 d2                	xor    %edx,%edx
  801585:	e9 46 ff ff ff       	jmp    8014d0 <__udivdi3+0x50>
  80158a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801590:	8d 46 ff             	lea    -0x1(%esi),%eax
  801593:	31 d2                	xor    %edx,%edx
  801595:	8b 74 24 10          	mov    0x10(%esp),%esi
  801599:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80159d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015a1:	83 c4 1c             	add    $0x1c,%esp
  8015a4:	c3                   	ret    
	...

008015b0 <__umoddi3>:
  8015b0:	83 ec 1c             	sub    $0x1c,%esp
  8015b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8015b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8015bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8015bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8015c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8015c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8015cb:	85 ed                	test   %ebp,%ebp
  8015cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8015d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d5:	89 cf                	mov    %ecx,%edi
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	89 f2                	mov    %esi,%edx
  8015dc:	75 1a                	jne    8015f8 <__umoddi3+0x48>
  8015de:	39 f1                	cmp    %esi,%ecx
  8015e0:	76 4e                	jbe    801630 <__umoddi3+0x80>
  8015e2:	f7 f1                	div    %ecx
  8015e4:	89 d0                	mov    %edx,%eax
  8015e6:	31 d2                	xor    %edx,%edx
  8015e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015f4:	83 c4 1c             	add    $0x1c,%esp
  8015f7:	c3                   	ret    
  8015f8:	39 f5                	cmp    %esi,%ebp
  8015fa:	77 54                	ja     801650 <__umoddi3+0xa0>
  8015fc:	0f bd c5             	bsr    %ebp,%eax
  8015ff:	83 f0 1f             	xor    $0x1f,%eax
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	75 60                	jne    801668 <__umoddi3+0xb8>
  801608:	3b 0c 24             	cmp    (%esp),%ecx
  80160b:	0f 87 07 01 00 00    	ja     801718 <__umoddi3+0x168>
  801611:	89 f2                	mov    %esi,%edx
  801613:	8b 34 24             	mov    (%esp),%esi
  801616:	29 ce                	sub    %ecx,%esi
  801618:	19 ea                	sbb    %ebp,%edx
  80161a:	89 34 24             	mov    %esi,(%esp)
  80161d:	8b 04 24             	mov    (%esp),%eax
  801620:	8b 74 24 10          	mov    0x10(%esp),%esi
  801624:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801628:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80162c:	83 c4 1c             	add    $0x1c,%esp
  80162f:	c3                   	ret    
  801630:	85 c9                	test   %ecx,%ecx
  801632:	75 0b                	jne    80163f <__umoddi3+0x8f>
  801634:	b8 01 00 00 00       	mov    $0x1,%eax
  801639:	31 d2                	xor    %edx,%edx
  80163b:	f7 f1                	div    %ecx
  80163d:	89 c1                	mov    %eax,%ecx
  80163f:	89 f0                	mov    %esi,%eax
  801641:	31 d2                	xor    %edx,%edx
  801643:	f7 f1                	div    %ecx
  801645:	8b 04 24             	mov    (%esp),%eax
  801648:	f7 f1                	div    %ecx
  80164a:	eb 98                	jmp    8015e4 <__umoddi3+0x34>
  80164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801650:	89 f2                	mov    %esi,%edx
  801652:	8b 74 24 10          	mov    0x10(%esp),%esi
  801656:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80165a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80165e:	83 c4 1c             	add    $0x1c,%esp
  801661:	c3                   	ret    
  801662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801668:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80166d:	89 e8                	mov    %ebp,%eax
  80166f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801674:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801678:	89 fa                	mov    %edi,%edx
  80167a:	d3 e0                	shl    %cl,%eax
  80167c:	89 e9                	mov    %ebp,%ecx
  80167e:	d3 ea                	shr    %cl,%edx
  801680:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801685:	09 c2                	or     %eax,%edx
  801687:	8b 44 24 08          	mov    0x8(%esp),%eax
  80168b:	89 14 24             	mov    %edx,(%esp)
  80168e:	89 f2                	mov    %esi,%edx
  801690:	d3 e7                	shl    %cl,%edi
  801692:	89 e9                	mov    %ebp,%ecx
  801694:	d3 ea                	shr    %cl,%edx
  801696:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80169b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80169f:	d3 e6                	shl    %cl,%esi
  8016a1:	89 e9                	mov    %ebp,%ecx
  8016a3:	d3 e8                	shr    %cl,%eax
  8016a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016aa:	09 f0                	or     %esi,%eax
  8016ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8016b0:	f7 34 24             	divl   (%esp)
  8016b3:	d3 e6                	shl    %cl,%esi
  8016b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8016b9:	89 d6                	mov    %edx,%esi
  8016bb:	f7 e7                	mul    %edi
  8016bd:	39 d6                	cmp    %edx,%esi
  8016bf:	89 c1                	mov    %eax,%ecx
  8016c1:	89 d7                	mov    %edx,%edi
  8016c3:	72 3f                	jb     801704 <__umoddi3+0x154>
  8016c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8016c9:	72 35                	jb     801700 <__umoddi3+0x150>
  8016cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016cf:	29 c8                	sub    %ecx,%eax
  8016d1:	19 fe                	sbb    %edi,%esi
  8016d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016d8:	89 f2                	mov    %esi,%edx
  8016da:	d3 e8                	shr    %cl,%eax
  8016dc:	89 e9                	mov    %ebp,%ecx
  8016de:	d3 e2                	shl    %cl,%edx
  8016e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8016e5:	09 d0                	or     %edx,%eax
  8016e7:	89 f2                	mov    %esi,%edx
  8016e9:	d3 ea                	shr    %cl,%edx
  8016eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016f7:	83 c4 1c             	add    $0x1c,%esp
  8016fa:	c3                   	ret    
  8016fb:	90                   	nop
  8016fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801700:	39 d6                	cmp    %edx,%esi
  801702:	75 c7                	jne    8016cb <__umoddi3+0x11b>
  801704:	89 d7                	mov    %edx,%edi
  801706:	89 c1                	mov    %eax,%ecx
  801708:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80170c:	1b 3c 24             	sbb    (%esp),%edi
  80170f:	eb ba                	jmp    8016cb <__umoddi3+0x11b>
  801711:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801718:	39 f5                	cmp    %esi,%ebp
  80171a:	0f 82 f1 fe ff ff    	jb     801611 <__umoddi3+0x61>
  801720:	e9 f8 fe ff ff       	jmp    80161d <__umoddi3+0x6d>
