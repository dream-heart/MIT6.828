
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
  800053:	e8 44 0f 00 00       	call   800f9c <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800071:	e8 36 02 00 00       	call   8002ac <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 dd 0e 00 00       	call   800f58 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 ec 12 80 	movl   $0x8012ec,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 f5 12 80 00 	movl   $0x8012f5,(%esp)
  80009c:	e8 12 01 00 00       	call   8001b3 <_panic>
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
  8000bb:	e8 dc 0e 00 00       	call   800f9c <ipc_recv>
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
  8000e4:	e8 d5 0e 00 00       	call   800fbe <ipc_send>
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
  8000f3:	e8 60 0e 00 00       	call   800f58 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 ec 12 80 	movl   $0x8012ec,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 f5 12 80 00 	movl   $0x8012f5,(%esp)
  800119:	e8 95 00 00 00       	call   8001b3 <_panic>
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
  800143:	e8 76 0e 00 00       	call   800fbe <ipc_send>
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
  800162:	e8 9e 0b 00 00       	call   800d05 <sys_getenvid>
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
  800190:	e8 0a 00 00 00       	call   80019f <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ac:	e8 02 0b 00 00       	call   800cb3 <sys_env_destroy>
}
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001be:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001c4:	e8 3c 0b 00 00       	call   800d05 <sys_getenvid>
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	c7 04 24 10 13 80 00 	movl   $0x801310,(%esp)
  8001e6:	e8 c1 00 00 00       	call   8002ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	e8 51 00 00 00       	call   80024b <vcprintf>
	cprintf("\n");
  8001fa:	c7 04 24 34 13 80 00 	movl   $0x801334,(%esp)
  800201:	e8 a6 00 00 00       	call   8002ac <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800206:	cc                   	int3   
  800207:	eb fd                	jmp    800206 <_panic+0x53>

00800209 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	83 ec 14             	sub    $0x14,%esp
  800210:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800213:	8b 13                	mov    (%ebx),%edx
  800215:	8d 42 01             	lea    0x1(%edx),%eax
  800218:	89 03                	mov    %eax,(%ebx)
  80021a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800221:	3d ff 00 00 00       	cmp    $0xff,%eax
  800226:	75 19                	jne    800241 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800228:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80022f:	00 
  800230:	8d 43 08             	lea    0x8(%ebx),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 3b 0a 00 00       	call   800c76 <sys_cputs>
		b->idx = 0;
  80023b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800241:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800245:	83 c4 14             	add    $0x14,%esp
  800248:	5b                   	pop    %ebx
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	89 44 24 08          	mov    %eax,0x8(%esp)
  800276:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	c7 04 24 09 02 80 00 	movl   $0x800209,(%esp)
  800287:	e8 78 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800292:	89 44 24 04          	mov    %eax,0x4(%esp)
  800296:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029c:	89 04 24             	mov    %eax,(%esp)
  80029f:	e8 d2 09 00 00       	call   800c76 <sys_cputs>

	return b.cnt;
}
  8002a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 87 ff ff ff       	call   80024b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    
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
  8002e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 c3                	mov    %eax,%ebx
  8002e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002fd:	39 d9                	cmp    %ebx,%ecx
  8002ff:	72 05                	jb     800306 <printnum+0x36>
  800301:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800304:	77 69                	ja     80036f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800306:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800309:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80030d:	83 ee 01             	sub    $0x1,%esi
  800310:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	8b 44 24 08          	mov    0x8(%esp),%eax
  80031c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800320:	89 c3                	mov    %eax,%ebx
  800322:	89 d6                	mov    %edx,%esi
  800324:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800327:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80032a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80032e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033f:	e8 dc 0c 00 00       	call   801020 <__udivdi3>
  800344:	89 d9                	mov    %ebx,%ecx
  800346:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	89 54 24 04          	mov    %edx,0x4(%esp)
  800355:	89 fa                	mov    %edi,%edx
  800357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035a:	e8 71 ff ff ff       	call   8002d0 <printnum>
  80035f:	eb 1b                	jmp    80037c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800361:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800365:	8b 45 18             	mov    0x18(%ebp),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff d3                	call   *%ebx
  80036d:	eb 03                	jmp    800372 <printnum+0xa2>
  80036f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800372:	83 ee 01             	sub    $0x1,%esi
  800375:	85 f6                	test   %esi,%esi
  800377:	7f e8                	jg     800361 <printnum+0x91>
  800379:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800380:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800384:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800387:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	e8 ac 0d 00 00       	call   801150 <__umoddi3>
  8003a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a8:	0f be 80 36 13 80 00 	movsbl 0x801336(%eax),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b5:	ff d0                	call   *%eax
}
  8003b7:	83 c4 3c             	add    $0x3c,%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	88 02                	mov    %al,(%edx)
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	e8 02 00 00 00       	call   800404 <vprintfmt>
	va_end(ap);
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 3c             	sub    $0x3c,%esp
  80040d:	8b 75 08             	mov    0x8(%ebp),%esi
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800413:	8b 7d 10             	mov    0x10(%ebp),%edi
  800416:	eb 11                	jmp    800429 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 48 04 00 00    	je     800868 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800420:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	83 c7 01             	add    $0x1,%edi
  80042c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800430:	83 f8 25             	cmp    $0x25,%eax
  800433:	75 e3                	jne    800418 <vprintfmt+0x14>
  800435:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800439:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800440:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800447:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80044e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800453:	eb 1f                	jmp    800474 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800458:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045c:	eb 16                	jmp    800474 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800461:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800465:	eb 0d                	jmp    800474 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800467:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8d 47 01             	lea    0x1(%edi),%eax
  800477:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047a:	0f b6 17             	movzbl (%edi),%edx
  80047d:	0f b6 c2             	movzbl %dl,%eax
  800480:	83 ea 23             	sub    $0x23,%edx
  800483:	80 fa 55             	cmp    $0x55,%dl
  800486:	0f 87 bf 03 00 00    	ja     80084b <vprintfmt+0x447>
  80048c:	0f b6 d2             	movzbl %dl,%edx
  80048f:	ff 24 95 00 14 80 00 	jmp    *0x801400(,%edx,4)
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ae:	83 f9 09             	cmp    $0x9,%ecx
  8004b1:	77 3c                	ja     8004ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b6:	eb e9                	jmp    8004a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 40 04             	lea    0x4(%eax),%eax
  8004c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004cc:	eb 27                	jmp    8004f5 <vprintfmt+0xf1>
  8004ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 49 c2             	cmovns %edx,%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	eb 91                	jmp    800474 <vprintfmt+0x70>
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ed:	eb 85                	jmp    800474 <vprintfmt+0x70>
  8004ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f9:	0f 89 75 ff ff ff    	jns    800474 <vprintfmt+0x70>
  8004ff:	e9 63 ff ff ff       	jmp    800467 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800504:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80050a:	e9 65 ff ff ff       	jmp    800474 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800512:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800516:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800524:	e9 00 ff ff ff       	jmp    800429 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800530:	8b 00                	mov    (%eax),%eax
  800532:	99                   	cltd   
  800533:	31 d0                	xor    %edx,%eax
  800535:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800537:	83 f8 09             	cmp    $0x9,%eax
  80053a:	7f 0b                	jg     800547 <vprintfmt+0x143>
  80053c:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	75 20                	jne    800567 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800547:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054b:	c7 44 24 08 4e 13 80 	movl   $0x80134e,0x8(%esp)
  800552:	00 
  800553:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800557:	89 34 24             	mov    %esi,(%esp)
  80055a:	e8 7d fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800562:	e9 c2 fe ff ff       	jmp    800429 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800567:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056b:	c7 44 24 08 57 13 80 	movl   $0x801357,0x8(%esp)
  800572:	00 
  800573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800577:	89 34 24             	mov    %esi,(%esp)
  80057a:	e8 5d fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 a2 fe ff ff       	jmp    800429 <vprintfmt+0x25>
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800590:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800593:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800597:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800599:	85 ff                	test   %edi,%edi
  80059b:	b8 47 13 80 00       	mov    $0x801347,%eax
  8005a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a7:	0f 84 92 00 00 00    	je     80063f <vprintfmt+0x23b>
  8005ad:	85 c9                	test   %ecx,%ecx
  8005af:	0f 8e 98 00 00 00    	jle    80064d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b9:	89 3c 24             	mov    %edi,(%esp)
  8005bc:	e8 47 03 00 00       	call   800908 <strnlen>
  8005c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c4:	29 c1                	sub    %eax,%ecx
  8005c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	eb 0f                	jmp    8005e6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 ef 01             	sub    $0x1,%edi
  8005e6:	85 ff                	test   %edi,%edi
  8005e8:	7f ed                	jg     8005d7 <vprintfmt+0x1d3>
  8005ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f0:	85 c9                	test   %ecx,%ecx
  8005f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f7:	0f 49 c1             	cmovns %ecx,%eax
  8005fa:	29 c1                	sub    %eax,%ecx
  8005fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800602:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800605:	89 cb                	mov    %ecx,%ebx
  800607:	eb 50                	jmp    800659 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800609:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060d:	74 1e                	je     80062d <vprintfmt+0x229>
  80060f:	0f be d2             	movsbl %dl,%edx
  800612:	83 ea 20             	sub    $0x20,%edx
  800615:	83 fa 5e             	cmp    $0x5e,%edx
  800618:	76 13                	jbe    80062d <vprintfmt+0x229>
					putch('?', putdat);
  80061a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800621:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	eb 0d                	jmp    80063a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80062d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800630:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063a:	83 eb 01             	sub    $0x1,%ebx
  80063d:	eb 1a                	jmp    800659 <vprintfmt+0x255>
  80063f:	89 75 08             	mov    %esi,0x8(%ebp)
  800642:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800645:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800648:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064b:	eb 0c                	jmp    800659 <vprintfmt+0x255>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	83 c7 01             	add    $0x1,%edi
  80065c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800660:	0f be c2             	movsbl %dl,%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	74 25                	je     80068c <vprintfmt+0x288>
  800667:	85 f6                	test   %esi,%esi
  800669:	78 9e                	js     800609 <vprintfmt+0x205>
  80066b:	83 ee 01             	sub    $0x1,%esi
  80066e:	79 99                	jns    800609 <vprintfmt+0x205>
  800670:	89 df                	mov    %ebx,%edi
  800672:	8b 75 08             	mov    0x8(%ebp),%esi
  800675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800678:	eb 1a                	jmp    800694 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800685:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 ef 01             	sub    $0x1,%edi
  80068a:	eb 08                	jmp    800694 <vprintfmt+0x290>
  80068c:	89 df                	mov    %ebx,%edi
  80068e:	8b 75 08             	mov    0x8(%ebp),%esi
  800691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800694:	85 ff                	test   %edi,%edi
  800696:	7f e2                	jg     80067a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 89 fd ff ff       	jmp    800429 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a0:	83 f9 01             	cmp    $0x1,%ecx
  8006a3:	7e 19                	jle    8006be <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 50 04             	mov    0x4(%eax),%edx
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 40 08             	lea    0x8(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bc:	eb 38                	jmp    8006f6 <vprintfmt+0x2f2>
	else if (lflag)
  8006be:	85 c9                	test   %ecx,%ecx
  8006c0:	74 1b                	je     8006dd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ca:	89 c1                	mov    %eax,%ecx
  8006cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006db:	eb 19                	jmp    8006f6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 c1                	mov    %eax,%ecx
  8006e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800701:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800705:	0f 89 04 01 00 00    	jns    80080f <vprintfmt+0x40b>
				putch('-', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800716:	ff d6                	call   *%esi
				num = -(long long) num;
  800718:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071e:	f7 da                	neg    %edx
  800720:	83 d1 00             	adc    $0x0,%ecx
  800723:	f7 d9                	neg    %ecx
  800725:	e9 e5 00 00 00       	jmp    80080f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072a:	83 f9 01             	cmp    $0x1,%ecx
  80072d:	7e 10                	jle    80073f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	8b 48 04             	mov    0x4(%eax),%ecx
  800737:	8d 40 08             	lea    0x8(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
  80073d:	eb 26                	jmp    800765 <vprintfmt+0x361>
	else if (lflag)
  80073f:	85 c9                	test   %ecx,%ecx
  800741:	74 12                	je     800755 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074d:	8d 40 04             	lea    0x4(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
  800753:	eb 10                	jmp    800765 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075f:	8d 40 04             	lea    0x4(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800765:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80076a:	e9 a0 00 00 00       	jmp    80080f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80076f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800773:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80077a:	ff d6                	call   *%esi
			putch('X', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800787:	ff d6                	call   *%esi
			putch('X', putdat);
  800789:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800794:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800799:	e9 8b fc ff ff       	jmp    800429 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80079e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007cd:	eb 40                	jmp    80080f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007cf:	83 f9 01             	cmp    $0x1,%ecx
  8007d2:	7e 10                	jle    8007e4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007dc:	8d 40 08             	lea    0x8(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e2:	eb 26                	jmp    80080a <vprintfmt+0x406>
	else if (lflag)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	74 12                	je     8007fa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f8:	eb 10                	jmp    80080a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800804:	8d 40 04             	lea    0x4(%eax),%eax
  800807:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80080a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800813:	89 44 24 10          	mov    %eax,0x10(%esp)
  800817:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800822:	89 14 24             	mov    %edx,(%esp)
  800825:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800829:	89 da                	mov    %ebx,%edx
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	e8 9e fa ff ff       	call   8002d0 <printnum>
			break;
  800832:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800835:	e9 ef fb ff ff       	jmp    800429 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800846:	e9 de fb ff ff       	jmp    800429 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800856:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800858:	eb 03                	jmp    80085d <vprintfmt+0x459>
  80085a:	83 ef 01             	sub    $0x1,%edi
  80085d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800861:	75 f7                	jne    80085a <vprintfmt+0x456>
  800863:	e9 c1 fb ff ff       	jmp    800429 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800868:	83 c4 3c             	add    $0x3c,%esp
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5f                   	pop    %edi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 28             	sub    $0x28,%esp
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800883:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800886:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088d:	85 c0                	test   %eax,%eax
  80088f:	74 30                	je     8008c1 <vsnprintf+0x51>
  800891:	85 d2                	test   %edx,%edx
  800893:	7e 2c                	jle    8008c1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089c:	8b 45 10             	mov    0x10(%ebp),%eax
  80089f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008aa:	c7 04 24 bf 03 80 00 	movl   $0x8003bf,(%esp)
  8008b1:	e8 4e fb ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bf:	eb 05                	jmp    8008c6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 82 ff ff ff       	call   800870 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb 03                	jmp    800900 <strlen+0x10>
		n++;
  8008fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800900:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800904:	75 f7                	jne    8008fd <strlen+0xd>
		n++;
	return n;
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 03                	jmp    80091b <strnlen+0x13>
		n++;
  800918:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	74 06                	je     800925 <strnlen+0x1d>
  80091f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800923:	75 f3                	jne    800918 <strnlen+0x10>
		n++;
	return n;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800931:	89 c2                	mov    %eax,%edx
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	83 c1 01             	add    $0x1,%ecx
  800939:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800940:	84 db                	test   %bl,%bl
  800942:	75 ef                	jne    800933 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800944:	5b                   	pop    %ebx
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800951:	89 1c 24             	mov    %ebx,(%esp)
  800954:	e8 97 ff ff ff       	call   8008f0 <strlen>
	strcpy(dst + len, src);
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800960:	01 d8                	add    %ebx,%eax
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	e8 bd ff ff ff       	call   800927 <strcpy>
	return dst;
}
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	83 c4 08             	add    $0x8,%esp
  80096f:	5b                   	pop    %ebx
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 75 08             	mov    0x8(%ebp),%esi
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097d:	89 f3                	mov    %esi,%ebx
  80097f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800982:	89 f2                	mov    %esi,%edx
  800984:	eb 0f                	jmp    800995 <strncpy+0x23>
		*dst++ = *src;
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	0f b6 01             	movzbl (%ecx),%eax
  80098c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098f:	80 39 01             	cmpb   $0x1,(%ecx)
  800992:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800995:	39 da                	cmp    %ebx,%edx
  800997:	75 ed                	jne    800986 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800999:	89 f0                	mov    %esi,%eax
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ad:	89 f0                	mov    %esi,%eax
  8009af:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	75 0b                	jne    8009c2 <strlcpy+0x23>
  8009b7:	eb 1d                	jmp    8009d6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	83 c2 01             	add    $0x1,%edx
  8009bf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c2:	39 d8                	cmp    %ebx,%eax
  8009c4:	74 0b                	je     8009d1 <strlcpy+0x32>
  8009c6:	0f b6 0a             	movzbl (%edx),%ecx
  8009c9:	84 c9                	test   %cl,%cl
  8009cb:	75 ec                	jne    8009b9 <strlcpy+0x1a>
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	eb 02                	jmp    8009d3 <strlcpy+0x34>
  8009d1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009d3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009d6:	29 f0                	sub    %esi,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e5:	eb 06                	jmp    8009ed <strcmp+0x11>
		p++, q++;
  8009e7:	83 c1 01             	add    $0x1,%ecx
  8009ea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	84 c0                	test   %al,%al
  8009f2:	74 04                	je     8009f8 <strcmp+0x1c>
  8009f4:	3a 02                	cmp    (%edx),%al
  8009f6:	74 ef                	je     8009e7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f8:	0f b6 c0             	movzbl %al,%eax
  8009fb:	0f b6 12             	movzbl (%edx),%edx
  8009fe:	29 d0                	sub    %edx,%eax
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 c3                	mov    %eax,%ebx
  800a0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a11:	eb 06                	jmp    800a19 <strncmp+0x17>
		n--, p++, q++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a19:	39 d8                	cmp    %ebx,%eax
  800a1b:	74 15                	je     800a32 <strncmp+0x30>
  800a1d:	0f b6 08             	movzbl (%eax),%ecx
  800a20:	84 c9                	test   %cl,%cl
  800a22:	74 04                	je     800a28 <strncmp+0x26>
  800a24:	3a 0a                	cmp    (%edx),%cl
  800a26:	74 eb                	je     800a13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a28:	0f b6 00             	movzbl (%eax),%eax
  800a2b:	0f b6 12             	movzbl (%edx),%edx
  800a2e:	29 d0                	sub    %edx,%eax
  800a30:	eb 05                	jmp    800a37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a44:	eb 07                	jmp    800a4d <strchr+0x13>
		if (*s == c)
  800a46:	38 ca                	cmp    %cl,%dl
  800a48:	74 0f                	je     800a59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 f2                	jne    800a46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a65:	eb 07                	jmp    800a6e <strfind+0x13>
		if (*s == c)
  800a67:	38 ca                	cmp    %cl,%dl
  800a69:	74 0a                	je     800a75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6b:	83 c0 01             	add    $0x1,%eax
  800a6e:	0f b6 10             	movzbl (%eax),%edx
  800a71:	84 d2                	test   %dl,%dl
  800a73:	75 f2                	jne    800a67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a83:	85 c9                	test   %ecx,%ecx
  800a85:	74 36                	je     800abd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8d:	75 28                	jne    800ab7 <memset+0x40>
  800a8f:	f6 c1 03             	test   $0x3,%cl
  800a92:	75 23                	jne    800ab7 <memset+0x40>
		c &= 0xFF;
  800a94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	c1 e3 08             	shl    $0x8,%ebx
  800a9d:	89 d6                	mov    %edx,%esi
  800a9f:	c1 e6 18             	shl    $0x18,%esi
  800aa2:	89 d0                	mov    %edx,%eax
  800aa4:	c1 e0 10             	shl    $0x10,%eax
  800aa7:	09 f0                	or     %esi,%eax
  800aa9:	09 c2                	or     %eax,%edx
  800aab:	89 d0                	mov    %edx,%eax
  800aad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab2:	fc                   	cld    
  800ab3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab5:	eb 06                	jmp    800abd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aba:	fc                   	cld    
  800abb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abd:	89 f8                	mov    %edi,%eax
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad2:	39 c6                	cmp    %eax,%esi
  800ad4:	73 35                	jae    800b0b <memmove+0x47>
  800ad6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad9:	39 d0                	cmp    %edx,%eax
  800adb:	73 2e                	jae    800b0b <memmove+0x47>
		s += n;
		d += n;
  800add:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aea:	75 13                	jne    800aff <memmove+0x3b>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 0e                	jne    800aff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af1:	83 ef 04             	sub    $0x4,%edi
  800af4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800afa:	fd                   	std    
  800afb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afd:	eb 09                	jmp    800b08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aff:	83 ef 01             	sub    $0x1,%edi
  800b02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b05:	fd                   	std    
  800b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b08:	fc                   	cld    
  800b09:	eb 1d                	jmp    800b28 <memmove+0x64>
  800b0b:	89 f2                	mov    %esi,%edx
  800b0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0f:	f6 c2 03             	test   $0x3,%dl
  800b12:	75 0f                	jne    800b23 <memmove+0x5f>
  800b14:	f6 c1 03             	test   $0x3,%cl
  800b17:	75 0a                	jne    800b23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b1c:	89 c7                	mov    %eax,%edi
  800b1e:	fc                   	cld    
  800b1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b21:	eb 05                	jmp    800b28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	fc                   	cld    
  800b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b32:	8b 45 10             	mov    0x10(%ebp),%eax
  800b35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	89 04 24             	mov    %eax,(%esp)
  800b46:	e8 79 ff ff ff       	call   800ac4 <memmove>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5d:	eb 1a                	jmp    800b79 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5f:	0f b6 02             	movzbl (%edx),%eax
  800b62:	0f b6 19             	movzbl (%ecx),%ebx
  800b65:	38 d8                	cmp    %bl,%al
  800b67:	74 0a                	je     800b73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c0             	movzbl %al,%eax
  800b6c:	0f b6 db             	movzbl %bl,%ebx
  800b6f:	29 d8                	sub    %ebx,%eax
  800b71:	eb 0f                	jmp    800b82 <memcmp+0x35>
		s1++, s2++;
  800b73:	83 c2 01             	add    $0x1,%edx
  800b76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b79:	39 f2                	cmp    %esi,%edx
  800b7b:	75 e2                	jne    800b5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b94:	eb 07                	jmp    800b9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	38 08                	cmp    %cl,(%eax)
  800b98:	74 07                	je     800ba1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	39 d0                	cmp    %edx,%eax
  800b9f:	72 f5                	jb     800b96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baf:	eb 03                	jmp    800bb4 <strtol+0x11>
		s++;
  800bb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb4:	0f b6 0a             	movzbl (%edx),%ecx
  800bb7:	80 f9 09             	cmp    $0x9,%cl
  800bba:	74 f5                	je     800bb1 <strtol+0xe>
  800bbc:	80 f9 20             	cmp    $0x20,%cl
  800bbf:	74 f0                	je     800bb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc1:	80 f9 2b             	cmp    $0x2b,%cl
  800bc4:	75 0a                	jne    800bd0 <strtol+0x2d>
		s++;
  800bc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bce:	eb 11                	jmp    800be1 <strtol+0x3e>
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd5:	80 f9 2d             	cmp    $0x2d,%cl
  800bd8:	75 07                	jne    800be1 <strtol+0x3e>
		s++, neg = 1;
  800bda:	8d 52 01             	lea    0x1(%edx),%edx
  800bdd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800be6:	75 15                	jne    800bfd <strtol+0x5a>
  800be8:	80 3a 30             	cmpb   $0x30,(%edx)
  800beb:	75 10                	jne    800bfd <strtol+0x5a>
  800bed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf1:	75 0a                	jne    800bfd <strtol+0x5a>
		s += 2, base = 16;
  800bf3:	83 c2 02             	add    $0x2,%edx
  800bf6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bfb:	eb 10                	jmp    800c0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	75 0c                	jne    800c0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c01:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c03:	80 3a 30             	cmpb   $0x30,(%edx)
  800c06:	75 05                	jne    800c0d <strtol+0x6a>
		s++, base = 8;
  800c08:	83 c2 01             	add    $0x1,%edx
  800c0b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c15:	0f b6 0a             	movzbl (%edx),%ecx
  800c18:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c1b:	89 f0                	mov    %esi,%eax
  800c1d:	3c 09                	cmp    $0x9,%al
  800c1f:	77 08                	ja     800c29 <strtol+0x86>
			dig = *s - '0';
  800c21:	0f be c9             	movsbl %cl,%ecx
  800c24:	83 e9 30             	sub    $0x30,%ecx
  800c27:	eb 20                	jmp    800c49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c2c:	89 f0                	mov    %esi,%eax
  800c2e:	3c 19                	cmp    $0x19,%al
  800c30:	77 08                	ja     800c3a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c32:	0f be c9             	movsbl %cl,%ecx
  800c35:	83 e9 57             	sub    $0x57,%ecx
  800c38:	eb 0f                	jmp    800c49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c3d:	89 f0                	mov    %esi,%eax
  800c3f:	3c 19                	cmp    $0x19,%al
  800c41:	77 16                	ja     800c59 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c43:	0f be c9             	movsbl %cl,%ecx
  800c46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c4c:	7d 0f                	jge    800c5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c4e:	83 c2 01             	add    $0x1,%edx
  800c51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c57:	eb bc                	jmp    800c15 <strtol+0x72>
  800c59:	89 d8                	mov    %ebx,%eax
  800c5b:	eb 02                	jmp    800c5f <strtol+0xbc>
  800c5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c63:	74 05                	je     800c6a <strtol+0xc7>
		*endptr = (char *) s;
  800c65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c6a:	f7 d8                	neg    %eax
  800c6c:	85 ff                	test   %edi,%edi
  800c6e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	89 c6                	mov    %eax,%esi
  800c8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_cgetc>:

int
sys_cgetc(void)
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
  800c9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca4:	89 d1                	mov    %edx,%ecx
  800ca6:	89 d3                	mov    %edx,%ebx
  800ca8:	89 d7                	mov    %edx,%edi
  800caa:	89 d6                	mov    %edx,%esi
  800cac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800cbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 cb                	mov    %ecx,%ebx
  800ccb:	89 cf                	mov    %ecx,%edi
  800ccd:	89 ce                	mov    %ecx,%esi
  800ccf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 28                	jle    800cfd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf0:	00 
  800cf1:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800cf8:	e8 b6 f4 ff ff       	call   8001b3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfd:	83 c4 2c             	add    $0x2c,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 04 00 00 00       	mov    $0x4,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 28                	jle    800d8f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d72:	00 
  800d73:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d82:	00 
  800d83:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800d8a:	e8 24 f4 ff ff       	call   8001b3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d8f:	83 c4 2c             	add    $0x2c,%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	b8 05 00 00 00       	mov    $0x5,%eax
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	8b 75 18             	mov    0x18(%ebp),%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 28                	jle    800de2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800dcd:	00 
  800dce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd5:	00 
  800dd6:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800ddd:	e8 d1 f3 ff ff       	call   8001b3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de2:	83 c4 2c             	add    $0x2c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 28                	jle    800e35 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e11:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e18:	00 
  800e19:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800e20:	00 
  800e21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e28:	00 
  800e29:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800e30:	e8 7e f3 ff ff       	call   8001b3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e35:	83 c4 2c             	add    $0x2c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	89 df                	mov    %ebx,%edi
  800e58:	89 de                	mov    %ebx,%esi
  800e5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	7e 28                	jle    800e88 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e64:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800e73:	00 
  800e74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7b:	00 
  800e7c:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800e83:	e8 2b f3 ff ff       	call   8001b3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e88:	83 c4 2c             	add    $0x2c,%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9e:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	89 df                	mov    %ebx,%edi
  800eab:	89 de                	mov    %ebx,%esi
  800ead:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7e 28                	jle    800edb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ece:	00 
  800ecf:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800ed6:	e8 d8 f2 ff ff       	call   8001b3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800edb:	83 c4 2c             	add    $0x2c,%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee9:	be 00 00 00 00       	mov    $0x0,%esi
  800eee:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 cb                	mov    %ecx,%ebx
  800f1e:	89 cf                	mov    %ecx,%edi
  800f20:	89 ce                	mov    %ecx,%esi
  800f22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	7e 28                	jle    800f50 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f28:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f33:	00 
  800f34:	c7 44 24 08 88 15 80 	movl   $0x801588,0x8(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f43:	00 
  800f44:	c7 04 24 a5 15 80 00 	movl   $0x8015a5,(%esp)
  800f4b:	e8 63 f2 ff ff       	call   8001b3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f50:	83 c4 2c             	add    $0x2c,%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f5e:	c7 44 24 08 bf 15 80 	movl   $0x8015bf,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 b3 15 80 00 	movl   $0x8015b3,(%esp)
  800f75:	e8 39 f2 ff ff       	call   8001b3 <_panic>

00800f7a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f80:	c7 44 24 08 be 15 80 	movl   $0x8015be,0x8(%esp)
  800f87:	00 
  800f88:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f8f:	00 
  800f90:	c7 04 24 b3 15 80 00 	movl   $0x8015b3,(%esp)
  800f97:	e8 17 f2 ff ff       	call   8001b3 <_panic>

00800f9c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fa2:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 ed 15 80 00 	movl   $0x8015ed,(%esp)
  800fb9:	e8 f5 f1 ff ff       	call   8001b3 <_panic>

00800fbe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fc4:	c7 44 24 08 f7 15 80 	movl   $0x8015f7,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 ed 15 80 00 	movl   $0x8015ed,(%esp)
  800fdb:	e8 d3 f1 ff ff       	call   8001b3 <_panic>

00800fe0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800feb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ff4:	8b 52 50             	mov    0x50(%edx),%edx
  800ff7:	39 ca                	cmp    %ecx,%edx
  800ff9:	75 0d                	jne    801008 <ipc_find_env+0x28>
			return envs[i].env_id;
  800ffb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ffe:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801003:	8b 40 40             	mov    0x40(%eax),%eax
  801006:	eb 0e                	jmp    801016 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801008:	83 c0 01             	add    $0x1,%eax
  80100b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801010:	75 d9                	jne    800feb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801012:	66 b8 00 00          	mov    $0x0,%ax
}
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
	...

00801020 <__udivdi3>:
  801020:	83 ec 1c             	sub    $0x1c,%esp
  801023:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801027:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80102b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80102f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801033:	89 74 24 10          	mov    %esi,0x10(%esp)
  801037:	8b 74 24 24          	mov    0x24(%esp),%esi
  80103b:	85 ff                	test   %edi,%edi
  80103d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801041:	89 44 24 08          	mov    %eax,0x8(%esp)
  801045:	89 cd                	mov    %ecx,%ebp
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104b:	75 33                	jne    801080 <__udivdi3+0x60>
  80104d:	39 f1                	cmp    %esi,%ecx
  80104f:	77 57                	ja     8010a8 <__udivdi3+0x88>
  801051:	85 c9                	test   %ecx,%ecx
  801053:	75 0b                	jne    801060 <__udivdi3+0x40>
  801055:	b8 01 00 00 00       	mov    $0x1,%eax
  80105a:	31 d2                	xor    %edx,%edx
  80105c:	f7 f1                	div    %ecx
  80105e:	89 c1                	mov    %eax,%ecx
  801060:	89 f0                	mov    %esi,%eax
  801062:	31 d2                	xor    %edx,%edx
  801064:	f7 f1                	div    %ecx
  801066:	89 c6                	mov    %eax,%esi
  801068:	8b 44 24 04          	mov    0x4(%esp),%eax
  80106c:	f7 f1                	div    %ecx
  80106e:	89 f2                	mov    %esi,%edx
  801070:	8b 74 24 10          	mov    0x10(%esp),%esi
  801074:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801078:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80107c:	83 c4 1c             	add    $0x1c,%esp
  80107f:	c3                   	ret    
  801080:	31 d2                	xor    %edx,%edx
  801082:	31 c0                	xor    %eax,%eax
  801084:	39 f7                	cmp    %esi,%edi
  801086:	77 e8                	ja     801070 <__udivdi3+0x50>
  801088:	0f bd cf             	bsr    %edi,%ecx
  80108b:	83 f1 1f             	xor    $0x1f,%ecx
  80108e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801092:	75 2c                	jne    8010c0 <__udivdi3+0xa0>
  801094:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801098:	76 04                	jbe    80109e <__udivdi3+0x7e>
  80109a:	39 f7                	cmp    %esi,%edi
  80109c:	73 d2                	jae    801070 <__udivdi3+0x50>
  80109e:	31 d2                	xor    %edx,%edx
  8010a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a5:	eb c9                	jmp    801070 <__udivdi3+0x50>
  8010a7:	90                   	nop
  8010a8:	89 f2                	mov    %esi,%edx
  8010aa:	f7 f1                	div    %ecx
  8010ac:	31 d2                	xor    %edx,%edx
  8010ae:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ba:	83 c4 1c             	add    $0x1c,%esp
  8010bd:	c3                   	ret    
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ca:	89 ea                	mov    %ebp,%edx
  8010cc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	89 c1                	mov    %eax,%ecx
  8010d4:	d3 ea                	shr    %cl,%edx
  8010d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010db:	09 fa                	or     %edi,%edx
  8010dd:	89 f7                	mov    %esi,%edi
  8010df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010e9:	d3 e5                	shl    %cl,%ebp
  8010eb:	89 c1                	mov    %eax,%ecx
  8010ed:	d3 ef                	shr    %cl,%edi
  8010ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f4:	d3 e2                	shl    %cl,%edx
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	d3 ee                	shr    %cl,%esi
  8010fa:	09 d6                	or     %edx,%esi
  8010fc:	89 fa                	mov    %edi,%edx
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	f7 74 24 0c          	divl   0xc(%esp)
  801104:	89 d7                	mov    %edx,%edi
  801106:	89 c6                	mov    %eax,%esi
  801108:	f7 e5                	mul    %ebp
  80110a:	39 d7                	cmp    %edx,%edi
  80110c:	72 22                	jb     801130 <__udivdi3+0x110>
  80110e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801112:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801117:	d3 e5                	shl    %cl,%ebp
  801119:	39 c5                	cmp    %eax,%ebp
  80111b:	73 04                	jae    801121 <__udivdi3+0x101>
  80111d:	39 d7                	cmp    %edx,%edi
  80111f:	74 0f                	je     801130 <__udivdi3+0x110>
  801121:	89 f0                	mov    %esi,%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	e9 46 ff ff ff       	jmp    801070 <__udivdi3+0x50>
  80112a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801130:	8d 46 ff             	lea    -0x1(%esi),%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	8b 74 24 10          	mov    0x10(%esp),%esi
  801139:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80113d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801141:	83 c4 1c             	add    $0x1c,%esp
  801144:	c3                   	ret    
	...

00801150 <__umoddi3>:
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801157:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80115b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80115f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801163:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801167:	8b 74 24 24          	mov    0x24(%esp),%esi
  80116b:	85 ed                	test   %ebp,%ebp
  80116d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 cf                	mov    %ecx,%edi
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	89 f2                	mov    %esi,%edx
  80117c:	75 1a                	jne    801198 <__umoddi3+0x48>
  80117e:	39 f1                	cmp    %esi,%ecx
  801180:	76 4e                	jbe    8011d0 <__umoddi3+0x80>
  801182:	f7 f1                	div    %ecx
  801184:	89 d0                	mov    %edx,%eax
  801186:	31 d2                	xor    %edx,%edx
  801188:	8b 74 24 10          	mov    0x10(%esp),%esi
  80118c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801190:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801194:	83 c4 1c             	add    $0x1c,%esp
  801197:	c3                   	ret    
  801198:	39 f5                	cmp    %esi,%ebp
  80119a:	77 54                	ja     8011f0 <__umoddi3+0xa0>
  80119c:	0f bd c5             	bsr    %ebp,%eax
  80119f:	83 f0 1f             	xor    $0x1f,%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	75 60                	jne    801208 <__umoddi3+0xb8>
  8011a8:	3b 0c 24             	cmp    (%esp),%ecx
  8011ab:	0f 87 07 01 00 00    	ja     8012b8 <__umoddi3+0x168>
  8011b1:	89 f2                	mov    %esi,%edx
  8011b3:	8b 34 24             	mov    (%esp),%esi
  8011b6:	29 ce                	sub    %ecx,%esi
  8011b8:	19 ea                	sbb    %ebp,%edx
  8011ba:	89 34 24             	mov    %esi,(%esp)
  8011bd:	8b 04 24             	mov    (%esp),%eax
  8011c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011cc:	83 c4 1c             	add    $0x1c,%esp
  8011cf:	c3                   	ret    
  8011d0:	85 c9                	test   %ecx,%ecx
  8011d2:	75 0b                	jne    8011df <__umoddi3+0x8f>
  8011d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f1                	div    %ecx
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	f7 f1                	div    %ecx
  8011e5:	8b 04 24             	mov    (%esp),%eax
  8011e8:	f7 f1                	div    %ecx
  8011ea:	eb 98                	jmp    801184 <__umoddi3+0x34>
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 f2                	mov    %esi,%edx
  8011f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fe:	83 c4 1c             	add    $0x1c,%esp
  801201:	c3                   	ret    
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80120d:	89 e8                	mov    %ebp,%eax
  80120f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801214:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801218:	89 fa                	mov    %edi,%edx
  80121a:	d3 e0                	shl    %cl,%eax
  80121c:	89 e9                	mov    %ebp,%ecx
  80121e:	d3 ea                	shr    %cl,%edx
  801220:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801225:	09 c2                	or     %eax,%edx
  801227:	8b 44 24 08          	mov    0x8(%esp),%eax
  80122b:	89 14 24             	mov    %edx,(%esp)
  80122e:	89 f2                	mov    %esi,%edx
  801230:	d3 e7                	shl    %cl,%edi
  801232:	89 e9                	mov    %ebp,%ecx
  801234:	d3 ea                	shr    %cl,%edx
  801236:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123f:	d3 e6                	shl    %cl,%esi
  801241:	89 e9                	mov    %ebp,%ecx
  801243:	d3 e8                	shr    %cl,%eax
  801245:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124a:	09 f0                	or     %esi,%eax
  80124c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801250:	f7 34 24             	divl   (%esp)
  801253:	d3 e6                	shl    %cl,%esi
  801255:	89 74 24 08          	mov    %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	f7 e7                	mul    %edi
  80125d:	39 d6                	cmp    %edx,%esi
  80125f:	89 c1                	mov    %eax,%ecx
  801261:	89 d7                	mov    %edx,%edi
  801263:	72 3f                	jb     8012a4 <__umoddi3+0x154>
  801265:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801269:	72 35                	jb     8012a0 <__umoddi3+0x150>
  80126b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80126f:	29 c8                	sub    %ecx,%eax
  801271:	19 fe                	sbb    %edi,%esi
  801273:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801278:	89 f2                	mov    %esi,%edx
  80127a:	d3 e8                	shr    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 d0                	or     %edx,%eax
  801287:	89 f2                	mov    %esi,%edx
  801289:	d3 ea                	shr    %cl,%edx
  80128b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80128f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801293:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801297:	83 c4 1c             	add    $0x1c,%esp
  80129a:	c3                   	ret    
  80129b:	90                   	nop
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	39 d6                	cmp    %edx,%esi
  8012a2:	75 c7                	jne    80126b <__umoddi3+0x11b>
  8012a4:	89 d7                	mov    %edx,%edi
  8012a6:	89 c1                	mov    %eax,%ecx
  8012a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012ac:	1b 3c 24             	sbb    (%esp),%edi
  8012af:	eb ba                	jmp    80126b <__umoddi3+0x11b>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	39 f5                	cmp    %esi,%ebp
  8012ba:	0f 82 f1 fe ff ff    	jb     8011b1 <__umoddi3+0x61>
  8012c0:	e9 f8 fe ff ff       	jmp    8011bd <__umoddi3+0x6d>
