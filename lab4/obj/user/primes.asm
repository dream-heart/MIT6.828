
obj/user/primes：     文件格式 elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 25 0f 00 00       	call   800f7c <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 20 80 00       	mov    0x802004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 a0 12 80 00 	movl   $0x8012a0,(%esp)
  800070:	e8 15 02 00 00       	call   80028a <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 be 0e 00 00       	call   800f38 <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 ac 12 80 	movl   $0x8012ac,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 b5 12 80 00 	movl   $0x8012b5,(%esp)
  80009b:	e8 f1 00 00 00       	call   800191 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 bd 0e 00 00       	call   800f7c <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 ba 0e 00 00       	call   800f9e <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 45 0e 00 00       	call   800f38 <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 ac 12 80 	movl   $0x8012ac,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 b5 12 80 00 	movl   $0x8012b5,(%esp)
  800114:	e8 78 00 00 00       	call   800191 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 5b 0e 00 00       	call   800f9e <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
  80014e:	8b 45 08             	mov    0x8(%ebp),%eax
  800151:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800154:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80015b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015e:	85 c0                	test   %eax,%eax
  800160:	7e 08                	jle    80016a <libmain+0x22>
		binaryname = argv[0];
  800162:	8b 0a                	mov    (%edx),%ecx
  800164:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80016a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80016e:	89 04 24             	mov    %eax,(%esp)
  800171:	e8 70 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800176:	e8 02 00 00 00       	call   80017d <exit>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018a:	e8 04 0b 00 00       	call   800c93 <sys_env_destroy>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001a2:	e8 3e 0b 00 00       	call   800ce5 <sys_getenvid>
  8001a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001aa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bd:	c7 04 24 d0 12 80 00 	movl   $0x8012d0,(%esp)
  8001c4:	e8 c1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 51 00 00 00       	call   800229 <vcprintf>
	cprintf("\n");
  8001d8:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  8001df:	e8 a6 00 00 00       	call   80028a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e4:	cc                   	int3   
  8001e5:	eb fd                	jmp    8001e4 <_panic+0x53>

008001e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 14             	sub    $0x14,%esp
  8001ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f1:	8b 13                	mov    (%ebx),%edx
  8001f3:	8d 42 01             	lea    0x1(%edx),%eax
  8001f6:	89 03                	mov    %eax,(%ebx)
  8001f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800204:	75 19                	jne    80021f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800206:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80020d:	00 
  80020e:	8d 43 08             	lea    0x8(%ebx),%eax
  800211:	89 04 24             	mov    %eax,(%esp)
  800214:	e8 3d 0a 00 00       	call   800c56 <sys_cputs>
		b->idx = 0;
  800219:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80021f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800223:	83 c4 14             	add    $0x14,%esp
  800226:	5b                   	pop    %ebx
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800232:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800239:	00 00 00 
	b.cnt = 0;
  80023c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800243:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800246:	8b 45 0c             	mov    0xc(%ebp),%eax
  800249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024d:	8b 45 08             	mov    0x8(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	c7 04 24 e7 01 80 00 	movl   $0x8001e7,(%esp)
  800265:	e8 7a 01 00 00       	call   8003e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800270:	89 44 24 04          	mov    %eax,0x4(%esp)
  800274:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	e8 d4 09 00 00       	call   800c56 <sys_cputs>

	return b.cnt;
}
  800282:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	e8 87 ff ff ff       	call   800229 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    
  8002a4:	66 90                	xchg   %ax,%ax
  8002a6:	66 90                	xchg   %ax,%ax
  8002a8:	66 90                	xchg   %ax,%ax
  8002aa:	66 90                	xchg   %ax,%ax
  8002ac:	66 90                	xchg   %ax,%ax
  8002ae:	66 90                	xchg   %ax,%ax

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002dd:	39 d9                	cmp    %ebx,%ecx
  8002df:	72 05                	jb     8002e6 <printnum+0x36>
  8002e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002e4:	77 69                	ja     80034f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ed:	83 ee 01             	sub    $0x1,%esi
  8002f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800300:	89 c3                	mov    %eax,%ebx
  800302:	89 d6                	mov    %edx,%esi
  800304:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800307:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80030a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80030e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 dc 0c 00 00       	call   801000 <__udivdi3>
  800324:	89 d9                	mov    %ebx,%ecx
  800326:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	89 54 24 04          	mov    %edx,0x4(%esp)
  800335:	89 fa                	mov    %edi,%edx
  800337:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033a:	e8 71 ff ff ff       	call   8002b0 <printnum>
  80033f:	eb 1b                	jmp    80035c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800341:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800345:	8b 45 18             	mov    0x18(%ebp),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff d3                	call   *%ebx
  80034d:	eb 03                	jmp    800352 <printnum+0xa2>
  80034f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800352:	83 ee 01             	sub    $0x1,%esi
  800355:	85 f6                	test   %esi,%esi
  800357:	7f e8                	jg     800341 <printnum+0x91>
  800359:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800360:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800364:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800367:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80036a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80037b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037f:	e8 ac 0d 00 00       	call   801130 <__umoddi3>
  800384:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800388:	0f be 80 f6 12 80 00 	movsbl 0x8012f6(%eax),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800395:	ff d0                	call   *%eax
}
  800397:	83 c4 3c             	add    $0x3c,%esp
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ae:	73 0a                	jae    8003ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	88 02                	mov    %al,(%edx)
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	89 04 24             	mov    %eax,(%esp)
  8003dd:	e8 02 00 00 00       	call   8003e4 <vprintfmt>
	va_end(ap);
}
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	57                   	push   %edi
  8003e8:	56                   	push   %esi
  8003e9:	53                   	push   %ebx
  8003ea:	83 ec 3c             	sub    $0x3c,%esp
  8003ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f6:	eb 11                	jmp    800409 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	0f 84 48 04 00 00    	je     800848 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800400:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	83 c7 01             	add    $0x1,%edi
  80040c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800410:	83 f8 25             	cmp    $0x25,%eax
  800413:	75 e3                	jne    8003f8 <vprintfmt+0x14>
  800415:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800419:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800420:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800427:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80042e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800433:	eb 1f                	jmp    800454 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800438:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80043c:	eb 16                	jmp    800454 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800441:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800445:	eb 0d                	jmp    800454 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800447:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8d 47 01             	lea    0x1(%edi),%eax
  800457:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045a:	0f b6 17             	movzbl (%edi),%edx
  80045d:	0f b6 c2             	movzbl %dl,%eax
  800460:	83 ea 23             	sub    $0x23,%edx
  800463:	80 fa 55             	cmp    $0x55,%dl
  800466:	0f 87 bf 03 00 00    	ja     80082b <vprintfmt+0x447>
  80046c:	0f b6 d2             	movzbl %dl,%edx
  80046f:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800481:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800484:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800488:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80048b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80048e:	83 f9 09             	cmp    $0x9,%ecx
  800491:	77 3c                	ja     8004cf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800493:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800496:	eb e9                	jmp    800481 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 40 04             	lea    0x4(%eax),%eax
  8004a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ac:	eb 27                	jmp    8004d5 <vprintfmt+0xf1>
  8004ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	0f 49 c2             	cmovns %edx,%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c1:	eb 91                	jmp    800454 <vprintfmt+0x70>
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cd:	eb 85                	jmp    800454 <vprintfmt+0x70>
  8004cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d9:	0f 89 75 ff ff ff    	jns    800454 <vprintfmt+0x70>
  8004df:	e9 63 ff ff ff       	jmp    800447 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ea:	e9 65 ff ff ff       	jmp    800454 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800504:	e9 00 ff ff ff       	jmp    800409 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800510:	8b 00                	mov    (%eax),%eax
  800512:	99                   	cltd   
  800513:	31 d0                	xor    %edx,%eax
  800515:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 09             	cmp    $0x9,%eax
  80051a:	7f 0b                	jg     800527 <vprintfmt+0x143>
  80051c:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800523:	85 d2                	test   %edx,%edx
  800525:	75 20                	jne    800547 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800527:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052b:	c7 44 24 08 0e 13 80 	movl   $0x80130e,0x8(%esp)
  800532:	00 
  800533:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800537:	89 34 24             	mov    %esi,(%esp)
  80053a:	e8 7d fe ff ff       	call   8003bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800542:	e9 c2 fe ff ff       	jmp    800409 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800547:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054b:	c7 44 24 08 17 13 80 	movl   $0x801317,0x8(%esp)
  800552:	00 
  800553:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800557:	89 34 24             	mov    %esi,(%esp)
  80055a:	e8 5d fe ff ff       	call   8003bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 a2 fe ff ff       	jmp    800409 <vprintfmt+0x25>
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800570:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800577:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800579:	85 ff                	test   %edi,%edi
  80057b:	b8 07 13 80 00       	mov    $0x801307,%eax
  800580:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800583:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800587:	0f 84 92 00 00 00    	je     80061f <vprintfmt+0x23b>
  80058d:	85 c9                	test   %ecx,%ecx
  80058f:	0f 8e 98 00 00 00    	jle    80062d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	89 54 24 04          	mov    %edx,0x4(%esp)
  800599:	89 3c 24             	mov    %edi,(%esp)
  80059c:	e8 47 03 00 00       	call   8008e8 <strnlen>
  8005a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	eb 0f                	jmp    8005c6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f ed                	jg     8005b7 <vprintfmt+0x1d3>
  8005ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d7:	0f 49 c1             	cmovns %ecx,%eax
  8005da:	29 c1                	sub    %eax,%ecx
  8005dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e5:	89 cb                	mov    %ecx,%ebx
  8005e7:	eb 50                	jmp    800639 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ed:	74 1e                	je     80060d <vprintfmt+0x229>
  8005ef:	0f be d2             	movsbl %dl,%edx
  8005f2:	83 ea 20             	sub    $0x20,%edx
  8005f5:	83 fa 5e             	cmp    $0x5e,%edx
  8005f8:	76 13                	jbe    80060d <vprintfmt+0x229>
					putch('?', putdat);
  8005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800608:	ff 55 08             	call   *0x8(%ebp)
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80060d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800610:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	eb 1a                	jmp    800639 <vprintfmt+0x255>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	eb 0c                	jmp    800639 <vprintfmt+0x255>
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800640:	0f be c2             	movsbl %dl,%eax
  800643:	85 c0                	test   %eax,%eax
  800645:	74 25                	je     80066c <vprintfmt+0x288>
  800647:	85 f6                	test   %esi,%esi
  800649:	78 9e                	js     8005e9 <vprintfmt+0x205>
  80064b:	83 ee 01             	sub    $0x1,%esi
  80064e:	79 99                	jns    8005e9 <vprintfmt+0x205>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	eb 1a                	jmp    800674 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800665:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	83 ef 01             	sub    $0x1,%edi
  80066a:	eb 08                	jmp    800674 <vprintfmt+0x290>
  80066c:	89 df                	mov    %ebx,%edi
  80066e:	8b 75 08             	mov    0x8(%ebp),%esi
  800671:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800674:	85 ff                	test   %edi,%edi
  800676:	7f e2                	jg     80065a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800678:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067b:	e9 89 fd ff ff       	jmp    800409 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 19                	jle    80069e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 50 04             	mov    0x4(%eax),%edx
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
  80069c:	eb 38                	jmp    8006d6 <vprintfmt+0x2f2>
	else if (lflag)
  80069e:	85 c9                	test   %ecx,%ecx
  8006a0:	74 1b                	je     8006bd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006aa:	89 c1                	mov    %eax,%ecx
  8006ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8006af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bb:	eb 19                	jmp    8006d6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c5:	89 c1                	mov    %eax,%ecx
  8006c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006dc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e5:	0f 89 04 01 00 00    	jns    8007ef <vprintfmt+0x40b>
				putch('-', putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fe:	f7 da                	neg    %edx
  800700:	83 d1 00             	adc    $0x0,%ecx
  800703:	f7 d9                	neg    %ecx
  800705:	e9 e5 00 00 00       	jmp    8007ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070a:	83 f9 01             	cmp    $0x1,%ecx
  80070d:	7e 10                	jle    80071f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	8b 48 04             	mov    0x4(%eax),%ecx
  800717:	8d 40 08             	lea    0x8(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
  80071d:	eb 26                	jmp    800745 <vprintfmt+0x361>
	else if (lflag)
  80071f:	85 c9                	test   %ecx,%ecx
  800721:	74 12                	je     800735 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8b 10                	mov    (%eax),%edx
  800728:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072d:	8d 40 04             	lea    0x4(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
  800733:	eb 10                	jmp    800745 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800745:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80074a:	e9 a0 00 00 00       	jmp    8007ef <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80074f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800753:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80075a:	ff d6                	call   *%esi
			putch('X', putdat);
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800767:	ff d6                	call   *%esi
			putch('X', putdat);
  800769:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800774:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800779:	e9 8b fc ff ff       	jmp    800409 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80077e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800782:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800789:	ff d6                	call   *%esi
			putch('x', putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800796:	ff d6                	call   *%esi
			num = (unsigned long long)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007a2:	8d 40 04             	lea    0x4(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007ad:	eb 40                	jmp    8007ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007af:	83 f9 01             	cmp    $0x1,%ecx
  8007b2:	7e 10                	jle    8007c4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bc:	8d 40 08             	lea    0x8(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c2:	eb 26                	jmp    8007ea <vprintfmt+0x406>
	else if (lflag)
  8007c4:	85 c9                	test   %ecx,%ecx
  8007c6:	74 12                	je     8007da <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d8:	eb 10                	jmp    8007ea <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800802:	89 14 24             	mov    %edx,(%esp)
  800805:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800809:	89 da                	mov    %ebx,%edx
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	e8 9e fa ff ff       	call   8002b0 <printnum>
			break;
  800812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800815:	e9 ef fb ff ff       	jmp    800409 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800826:	e9 de fb ff ff       	jmp    800409 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800836:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800838:	eb 03                	jmp    80083d <vprintfmt+0x459>
  80083a:	83 ef 01             	sub    $0x1,%edi
  80083d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800841:	75 f7                	jne    80083a <vprintfmt+0x456>
  800843:	e9 c1 fb ff ff       	jmp    800409 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800848:	83 c4 3c             	add    $0x3c,%esp
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5f                   	pop    %edi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 28             	sub    $0x28,%esp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800863:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800866:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086d:	85 c0                	test   %eax,%eax
  80086f:	74 30                	je     8008a1 <vsnprintf+0x51>
  800871:	85 d2                	test   %edx,%edx
  800873:	7e 2c                	jle    8008a1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087c:	8b 45 10             	mov    0x10(%ebp),%eax
  80087f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800883:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088a:	c7 04 24 9f 03 80 00 	movl   $0x80039f,(%esp)
  800891:	e8 4e fb ff ff       	call   8003e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800896:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800899:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089f:	eb 05                	jmp    8008a6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 82 ff ff ff       	call   800850 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strlen+0x10>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e4:	75 f7                	jne    8008dd <strlen+0xd>
		n++;
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 03                	jmp    8008fb <strnlen+0x13>
		n++;
  8008f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	74 06                	je     800905 <strnlen+0x1d>
  8008ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800903:	75 f3                	jne    8008f8 <strnlen+0x10>
		n++;
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800911:	89 c2                	mov    %eax,%edx
  800913:	83 c2 01             	add    $0x1,%edx
  800916:	83 c1 01             	add    $0x1,%ecx
  800919:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80091d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800920:	84 db                	test   %bl,%bl
  800922:	75 ef                	jne    800913 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 97 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	01 d8                	add    %ebx,%eax
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	e8 bd ff ff ff       	call   800907 <strcpy>
	return dst;
}
  80094a:	89 d8                	mov    %ebx,%eax
  80094c:	83 c4 08             	add    $0x8,%esp
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 75 08             	mov    0x8(%ebp),%esi
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	89 f3                	mov    %esi,%ebx
  80095f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	89 f2                	mov    %esi,%edx
  800964:	eb 0f                	jmp    800975 <strncpy+0x23>
		*dst++ = *src;
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096f:	80 39 01             	cmpb   $0x1,(%ecx)
  800972:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800975:	39 da                	cmp    %ebx,%edx
  800977:	75 ed                	jne    800966 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800979:	89 f0                	mov    %esi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80098d:	89 f0                	mov    %esi,%eax
  80098f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800993:	85 c9                	test   %ecx,%ecx
  800995:	75 0b                	jne    8009a2 <strlcpy+0x23>
  800997:	eb 1d                	jmp    8009b6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a2:	39 d8                	cmp    %ebx,%eax
  8009a4:	74 0b                	je     8009b1 <strlcpy+0x32>
  8009a6:	0f b6 0a             	movzbl (%edx),%ecx
  8009a9:	84 c9                	test   %cl,%cl
  8009ab:	75 ec                	jne    800999 <strlcpy+0x1a>
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	eb 02                	jmp    8009b3 <strlcpy+0x34>
  8009b1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009b3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009b6:	29 f0                	sub    %esi,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c5:	eb 06                	jmp    8009cd <strcmp+0x11>
		p++, q++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cd:	0f b6 01             	movzbl (%ecx),%eax
  8009d0:	84 c0                	test   %al,%al
  8009d2:	74 04                	je     8009d8 <strcmp+0x1c>
  8009d4:	3a 02                	cmp    (%edx),%al
  8009d6:	74 ef                	je     8009c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 c0             	movzbl %al,%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strncmp+0x17>
		n--, p++, q++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f9:	39 d8                	cmp    %ebx,%eax
  8009fb:	74 15                	je     800a12 <strncmp+0x30>
  8009fd:	0f b6 08             	movzbl (%eax),%ecx
  800a00:	84 c9                	test   %cl,%cl
  800a02:	74 04                	je     800a08 <strncmp+0x26>
  800a04:	3a 0a                	cmp    (%edx),%cl
  800a06:	74 eb                	je     8009f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
  800a10:	eb 05                	jmp    800a17 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	eb 07                	jmp    800a2d <strchr+0x13>
		if (*s == c)
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 0f                	je     800a39 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f2                	jne    800a26 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	eb 07                	jmp    800a4e <strfind+0x13>
		if (*s == c)
  800a47:	38 ca                	cmp    %cl,%dl
  800a49:	74 0a                	je     800a55 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	0f b6 10             	movzbl (%eax),%edx
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f2                	jne    800a47 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a63:	85 c9                	test   %ecx,%ecx
  800a65:	74 36                	je     800a9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6d:	75 28                	jne    800a97 <memset+0x40>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 23                	jne    800a97 <memset+0x40>
		c &= 0xFF;
  800a74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	c1 e3 08             	shl    $0x8,%ebx
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	c1 e6 18             	shl    $0x18,%esi
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	c1 e0 10             	shl    $0x10,%eax
  800a87:	09 f0                	or     %esi,%eax
  800a89:	09 c2                	or     %eax,%edx
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a92:	fc                   	cld    
  800a93:	f3 ab                	rep stos %eax,%es:(%edi)
  800a95:	eb 06                	jmp    800a9d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	fc                   	cld    
  800a9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9d:	89 f8                	mov    %edi,%eax
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 35                	jae    800aeb <memmove+0x47>
  800ab6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	73 2e                	jae    800aeb <memmove+0x47>
		s += n;
		d += n;
  800abd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aca:	75 13                	jne    800adf <memmove+0x3b>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0e                	jne    800adf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad1:	83 ef 04             	sub    $0x4,%edi
  800ad4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ada:	fd                   	std    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 09                	jmp    800ae8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adf:	83 ef 01             	sub    $0x1,%edi
  800ae2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae8:	fc                   	cld    
  800ae9:	eb 1d                	jmp    800b08 <memmove+0x64>
  800aeb:	89 f2                	mov    %esi,%edx
  800aed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	f6 c2 03             	test   $0x3,%dl
  800af2:	75 0f                	jne    800b03 <memmove+0x5f>
  800af4:	f6 c1 03             	test   $0x3,%cl
  800af7:	75 0a                	jne    800b03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800afc:	89 c7                	mov    %eax,%edi
  800afe:	fc                   	cld    
  800aff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b01:	eb 05                	jmp    800b08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	fc                   	cld    
  800b06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 79 ff ff ff       	call   800aa4 <memmove>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3d:	eb 1a                	jmp    800b59 <memcmp+0x2c>
		if (*s1 != *s2)
  800b3f:	0f b6 02             	movzbl (%edx),%eax
  800b42:	0f b6 19             	movzbl (%ecx),%ebx
  800b45:	38 d8                	cmp    %bl,%al
  800b47:	74 0a                	je     800b53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b49:	0f b6 c0             	movzbl %al,%eax
  800b4c:	0f b6 db             	movzbl %bl,%ebx
  800b4f:	29 d8                	sub    %ebx,%eax
  800b51:	eb 0f                	jmp    800b62 <memcmp+0x35>
		s1++, s2++;
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b59:	39 f2                	cmp    %esi,%edx
  800b5b:	75 e2                	jne    800b3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b74:	eb 07                	jmp    800b7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b76:	38 08                	cmp    %cl,(%eax)
  800b78:	74 07                	je     800b81 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	39 d0                	cmp    %edx,%eax
  800b7f:	72 f5                	jb     800b76 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8f:	eb 03                	jmp    800b94 <strtol+0x11>
		s++;
  800b91:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b94:	0f b6 0a             	movzbl (%edx),%ecx
  800b97:	80 f9 09             	cmp    $0x9,%cl
  800b9a:	74 f5                	je     800b91 <strtol+0xe>
  800b9c:	80 f9 20             	cmp    $0x20,%cl
  800b9f:	74 f0                	je     800b91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba1:	80 f9 2b             	cmp    $0x2b,%cl
  800ba4:	75 0a                	jne    800bb0 <strtol+0x2d>
		s++;
  800ba6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	eb 11                	jmp    800bc1 <strtol+0x3e>
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb5:	80 f9 2d             	cmp    $0x2d,%cl
  800bb8:	75 07                	jne    800bc1 <strtol+0x3e>
		s++, neg = 1;
  800bba:	8d 52 01             	lea    0x1(%edx),%edx
  800bbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bc6:	75 15                	jne    800bdd <strtol+0x5a>
  800bc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcb:	75 10                	jne    800bdd <strtol+0x5a>
  800bcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd1:	75 0a                	jne    800bdd <strtol+0x5a>
		s += 2, base = 16;
  800bd3:	83 c2 02             	add    $0x2,%edx
  800bd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bdb:	eb 10                	jmp    800bed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	75 0c                	jne    800bed <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be3:	80 3a 30             	cmpb   $0x30,(%edx)
  800be6:	75 05                	jne    800bed <strtol+0x6a>
		s++, base = 8;
  800be8:	83 c2 01             	add    $0x1,%edx
  800beb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 0a             	movzbl (%edx),%ecx
  800bf8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bfb:	89 f0                	mov    %esi,%eax
  800bfd:	3c 09                	cmp    $0x9,%al
  800bff:	77 08                	ja     800c09 <strtol+0x86>
			dig = *s - '0';
  800c01:	0f be c9             	movsbl %cl,%ecx
  800c04:	83 e9 30             	sub    $0x30,%ecx
  800c07:	eb 20                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c0c:	89 f0                	mov    %esi,%eax
  800c0e:	3c 19                	cmp    $0x19,%al
  800c10:	77 08                	ja     800c1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c12:	0f be c9             	movsbl %cl,%ecx
  800c15:	83 e9 57             	sub    $0x57,%ecx
  800c18:	eb 0f                	jmp    800c29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c1d:	89 f0                	mov    %esi,%eax
  800c1f:	3c 19                	cmp    $0x19,%al
  800c21:	77 16                	ja     800c39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c23:	0f be c9             	movsbl %cl,%ecx
  800c26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c2c:	7d 0f                	jge    800c3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c37:	eb bc                	jmp    800bf5 <strtol+0x72>
  800c39:	89 d8                	mov    %ebx,%eax
  800c3b:	eb 02                	jmp    800c3f <strtol+0xbc>
  800c3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c43:	74 05                	je     800c4a <strtol+0xc7>
		*endptr = (char *) s;
  800c45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c4a:	f7 d8                	neg    %eax
  800c4c:	85 ff                	test   %edi,%edi
  800c4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	89 c6                	mov    %eax,%esi
  800c6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 cb                	mov    %ecx,%ebx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	89 ce                	mov    %ecx,%esi
  800caf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 28                	jle    800cdd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cc0:	00 
  800cc1:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800cc8:	00 
  800cc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd0:	00 
  800cd1:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800cd8:	e8 b4 f4 ff ff       	call   800191 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdd:	83 c4 2c             	add    $0x2c,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_yield>:

void
sys_yield(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 04 00 00 00       	mov    $0x4,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	89 f7                	mov    %esi,%edi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 28                	jle    800d6f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800d6a:	e8 22 f4 ff ff       	call   800191 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6f:	83 c4 2c             	add    $0x2c,%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d80:	b8 05 00 00 00       	mov    $0x5,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	8b 75 18             	mov    0x18(%ebp),%esi
  800d94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	7e 28                	jle    800dc2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da5:	00 
  800da6:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800dad:	00 
  800dae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db5:	00 
  800db6:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800dbd:	e8 cf f3 ff ff       	call   800191 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc2:	83 c4 2c             	add    $0x2c,%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 28                	jle    800e15 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df8:	00 
  800df9:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800e00:	00 
  800e01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e08:	00 
  800e09:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800e10:	e8 7c f3 ff ff       	call   800191 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e15:	83 c4 2c             	add    $0x2c,%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 df                	mov    %ebx,%edi
  800e38:	89 de                	mov    %ebx,%esi
  800e3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7e 28                	jle    800e68 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800e53:	00 
  800e54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5b:	00 
  800e5c:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800e63:	e8 29 f3 ff ff       	call   800191 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e68:	83 c4 2c             	add    $0x2c,%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 28                	jle    800ebb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e97:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800eb6:	e8 d6 f2 ff ff       	call   800191 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ebb:	83 c4 2c             	add    $0x2c,%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	be 00 00 00 00       	mov    $0x0,%esi
  800ece:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	89 cb                	mov    %ecx,%ebx
  800efe:	89 cf                	mov    %ecx,%edi
  800f00:	89 ce                	mov    %ecx,%esi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 28                	jle    800f30 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f13:	00 
  800f14:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800f2b:	e8 61 f2 ff ff       	call   800191 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f30:	83 c4 2c             	add    $0x2c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f3e:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  800f55:	e8 37 f2 ff ff       	call   800191 <_panic>

00800f5a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f60:	c7 44 24 08 7e 15 80 	movl   $0x80157e,0x8(%esp)
  800f67:	00 
  800f68:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f6f:	00 
  800f70:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  800f77:	e8 15 f2 ff ff       	call   800191 <_panic>

00800f7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f82:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 ad 15 80 00 	movl   $0x8015ad,(%esp)
  800f99:	e8 f3 f1 ff ff       	call   800191 <_panic>

00800f9e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fa4:	c7 44 24 08 b7 15 80 	movl   $0x8015b7,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 ad 15 80 00 	movl   $0x8015ad,(%esp)
  800fbb:	e8 d1 f1 ff ff       	call   800191 <_panic>

00800fc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800fcb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fd4:	8b 52 50             	mov    0x50(%edx),%edx
  800fd7:	39 ca                	cmp    %ecx,%edx
  800fd9:	75 0d                	jne    800fe8 <ipc_find_env+0x28>
			return envs[i].env_id;
  800fdb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fde:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800fe3:	8b 40 40             	mov    0x40(%eax),%eax
  800fe6:	eb 0e                	jmp    800ff6 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fe8:	83 c0 01             	add    $0x1,%eax
  800feb:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ff0:	75 d9                	jne    800fcb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ff2:	66 b8 00 00          	mov    $0x0,%ax
}
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    
  800ff8:	66 90                	xchg   %ax,%ax
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <__udivdi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	8b 44 24 28          	mov    0x28(%esp),%eax
  80100a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80100e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801012:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801016:	85 c0                	test   %eax,%eax
  801018:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80101c:	89 ea                	mov    %ebp,%edx
  80101e:	89 0c 24             	mov    %ecx,(%esp)
  801021:	75 2d                	jne    801050 <__udivdi3+0x50>
  801023:	39 e9                	cmp    %ebp,%ecx
  801025:	77 61                	ja     801088 <__udivdi3+0x88>
  801027:	85 c9                	test   %ecx,%ecx
  801029:	89 ce                	mov    %ecx,%esi
  80102b:	75 0b                	jne    801038 <__udivdi3+0x38>
  80102d:	b8 01 00 00 00       	mov    $0x1,%eax
  801032:	31 d2                	xor    %edx,%edx
  801034:	f7 f1                	div    %ecx
  801036:	89 c6                	mov    %eax,%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	89 e8                	mov    %ebp,%eax
  80103c:	f7 f6                	div    %esi
  80103e:	89 c5                	mov    %eax,%ebp
  801040:	89 f8                	mov    %edi,%eax
  801042:	f7 f6                	div    %esi
  801044:	89 ea                	mov    %ebp,%edx
  801046:	83 c4 0c             	add    $0xc,%esp
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	39 e8                	cmp    %ebp,%eax
  801052:	77 24                	ja     801078 <__udivdi3+0x78>
  801054:	0f bd e8             	bsr    %eax,%ebp
  801057:	83 f5 1f             	xor    $0x1f,%ebp
  80105a:	75 3c                	jne    801098 <__udivdi3+0x98>
  80105c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801060:	39 34 24             	cmp    %esi,(%esp)
  801063:	0f 86 9f 00 00 00    	jbe    801108 <__udivdi3+0x108>
  801069:	39 d0                	cmp    %edx,%eax
  80106b:	0f 82 97 00 00 00    	jb     801108 <__udivdi3+0x108>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	31 d2                	xor    %edx,%edx
  80107a:	31 c0                	xor    %eax,%eax
  80107c:	83 c4 0c             	add    $0xc,%esp
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    
  801083:	90                   	nop
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	89 f8                	mov    %edi,%eax
  80108a:	f7 f1                	div    %ecx
  80108c:	31 d2                	xor    %edx,%edx
  80108e:	83 c4 0c             	add    $0xc,%esp
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	8b 3c 24             	mov    (%esp),%edi
  80109d:	d3 e0                	shl    %cl,%eax
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a6:	29 e8                	sub    %ebp,%eax
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	d3 ef                	shr    %cl,%edi
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010b2:	8b 3c 24             	mov    (%esp),%edi
  8010b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010b9:	89 d6                	mov    %edx,%esi
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	89 3c 24             	mov    %edi,(%esp)
  8010c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c6:	d3 ee                	shr    %cl,%esi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	d3 e2                	shl    %cl,%edx
  8010cc:	89 c1                	mov    %eax,%ecx
  8010ce:	d3 ef                	shr    %cl,%edi
  8010d0:	09 d7                	or     %edx,%edi
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	89 f8                	mov    %edi,%eax
  8010d6:	f7 74 24 08          	divl   0x8(%esp)
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	f7 24 24             	mull   (%esp)
  8010e1:	39 d6                	cmp    %edx,%esi
  8010e3:	89 14 24             	mov    %edx,(%esp)
  8010e6:	72 30                	jb     801118 <__udivdi3+0x118>
  8010e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010ec:	89 e9                	mov    %ebp,%ecx
  8010ee:	d3 e2                	shl    %cl,%edx
  8010f0:	39 c2                	cmp    %eax,%edx
  8010f2:	73 05                	jae    8010f9 <__udivdi3+0xf9>
  8010f4:	3b 34 24             	cmp    (%esp),%esi
  8010f7:	74 1f                	je     801118 <__udivdi3+0x118>
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	e9 7a ff ff ff       	jmp    80107c <__udivdi3+0x7c>
  801102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	b8 01 00 00 00       	mov    $0x1,%eax
  80110f:	e9 68 ff ff ff       	jmp    80107c <__udivdi3+0x7c>
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	8d 47 ff             	lea    -0x1(%edi),%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	83 c4 0c             	add    $0xc,%esp
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    
  801124:	66 90                	xchg   %ax,%ax
  801126:	66 90                	xchg   %ax,%ax
  801128:	66 90                	xchg   %ax,%ax
  80112a:	66 90                	xchg   %ax,%ax
  80112c:	66 90                	xchg   %ax,%ax
  80112e:	66 90                	xchg   %ax,%ax

00801130 <__umoddi3>:
  801130:	55                   	push   %ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	83 ec 14             	sub    $0x14,%esp
  801136:	8b 44 24 28          	mov    0x28(%esp),%eax
  80113a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80113e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801142:	89 c7                	mov    %eax,%edi
  801144:	89 44 24 04          	mov    %eax,0x4(%esp)
  801148:	8b 44 24 30          	mov    0x30(%esp),%eax
  80114c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801150:	89 34 24             	mov    %esi,(%esp)
  801153:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801157:	85 c0                	test   %eax,%eax
  801159:	89 c2                	mov    %eax,%edx
  80115b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115f:	75 17                	jne    801178 <__umoddi3+0x48>
  801161:	39 fe                	cmp    %edi,%esi
  801163:	76 4b                	jbe    8011b0 <__umoddi3+0x80>
  801165:	89 c8                	mov    %ecx,%eax
  801167:	89 fa                	mov    %edi,%edx
  801169:	f7 f6                	div    %esi
  80116b:	89 d0                	mov    %edx,%eax
  80116d:	31 d2                	xor    %edx,%edx
  80116f:	83 c4 14             	add    $0x14,%esp
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    
  801176:	66 90                	xchg   %ax,%ax
  801178:	39 f8                	cmp    %edi,%eax
  80117a:	77 54                	ja     8011d0 <__umoddi3+0xa0>
  80117c:	0f bd e8             	bsr    %eax,%ebp
  80117f:	83 f5 1f             	xor    $0x1f,%ebp
  801182:	75 5c                	jne    8011e0 <__umoddi3+0xb0>
  801184:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801188:	39 3c 24             	cmp    %edi,(%esp)
  80118b:	0f 87 e7 00 00 00    	ja     801278 <__umoddi3+0x148>
  801191:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801195:	29 f1                	sub    %esi,%ecx
  801197:	19 c7                	sbb    %eax,%edi
  801199:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80119d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011a9:	83 c4 14             	add    $0x14,%esp
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    
  8011b0:	85 f6                	test   %esi,%esi
  8011b2:	89 f5                	mov    %esi,%ebp
  8011b4:	75 0b                	jne    8011c1 <__umoddi3+0x91>
  8011b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	f7 f6                	div    %esi
  8011bf:	89 c5                	mov    %eax,%ebp
  8011c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011c5:	31 d2                	xor    %edx,%edx
  8011c7:	f7 f5                	div    %ebp
  8011c9:	89 c8                	mov    %ecx,%eax
  8011cb:	f7 f5                	div    %ebp
  8011cd:	eb 9c                	jmp    80116b <__umoddi3+0x3b>
  8011cf:	90                   	nop
  8011d0:	89 c8                	mov    %ecx,%eax
  8011d2:	89 fa                	mov    %edi,%edx
  8011d4:	83 c4 14             	add    $0x14,%esp
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    
  8011db:	90                   	nop
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	8b 04 24             	mov    (%esp),%eax
  8011e3:	be 20 00 00 00       	mov    $0x20,%esi
  8011e8:	89 e9                	mov    %ebp,%ecx
  8011ea:	29 ee                	sub    %ebp,%esi
  8011ec:	d3 e2                	shl    %cl,%edx
  8011ee:	89 f1                	mov    %esi,%ecx
  8011f0:	d3 e8                	shr    %cl,%eax
  8011f2:	89 e9                	mov    %ebp,%ecx
  8011f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f8:	8b 04 24             	mov    (%esp),%eax
  8011fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011ff:	89 fa                	mov    %edi,%edx
  801201:	d3 e0                	shl    %cl,%eax
  801203:	89 f1                	mov    %esi,%ecx
  801205:	89 44 24 08          	mov    %eax,0x8(%esp)
  801209:	8b 44 24 10          	mov    0x10(%esp),%eax
  80120d:	d3 ea                	shr    %cl,%edx
  80120f:	89 e9                	mov    %ebp,%ecx
  801211:	d3 e7                	shl    %cl,%edi
  801213:	89 f1                	mov    %esi,%ecx
  801215:	d3 e8                	shr    %cl,%eax
  801217:	89 e9                	mov    %ebp,%ecx
  801219:	09 f8                	or     %edi,%eax
  80121b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80121f:	f7 74 24 04          	divl   0x4(%esp)
  801223:	d3 e7                	shl    %cl,%edi
  801225:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801229:	89 d7                	mov    %edx,%edi
  80122b:	f7 64 24 08          	mull   0x8(%esp)
  80122f:	39 d7                	cmp    %edx,%edi
  801231:	89 c1                	mov    %eax,%ecx
  801233:	89 14 24             	mov    %edx,(%esp)
  801236:	72 2c                	jb     801264 <__umoddi3+0x134>
  801238:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80123c:	72 22                	jb     801260 <__umoddi3+0x130>
  80123e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801242:	29 c8                	sub    %ecx,%eax
  801244:	19 d7                	sbb    %edx,%edi
  801246:	89 e9                	mov    %ebp,%ecx
  801248:	89 fa                	mov    %edi,%edx
  80124a:	d3 e8                	shr    %cl,%eax
  80124c:	89 f1                	mov    %esi,%ecx
  80124e:	d3 e2                	shl    %cl,%edx
  801250:	89 e9                	mov    %ebp,%ecx
  801252:	d3 ef                	shr    %cl,%edi
  801254:	09 d0                	or     %edx,%eax
  801256:	89 fa                	mov    %edi,%edx
  801258:	83 c4 14             	add    $0x14,%esp
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    
  80125f:	90                   	nop
  801260:	39 d7                	cmp    %edx,%edi
  801262:	75 da                	jne    80123e <__umoddi3+0x10e>
  801264:	8b 14 24             	mov    (%esp),%edx
  801267:	89 c1                	mov    %eax,%ecx
  801269:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80126d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801271:	eb cb                	jmp    80123e <__umoddi3+0x10e>
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80127c:	0f 82 0f ff ff ff    	jb     801191 <__umoddi3+0x61>
  801282:	e9 1a ff ff ff       	jmp    8011a1 <__umoddi3+0x71>
