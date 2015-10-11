
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
  800052:	e8 35 0f 00 00       	call   800f8c <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 20 80 00       	mov    0x802004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 a0 12 80 00 	movl   $0x8012a0,(%esp)
  800070:	e8 28 02 00 00       	call   80029d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 ce 0e 00 00       	call   800f48 <fork>
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
  80009b:	e8 04 01 00 00       	call   8001a4 <_panic>
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
  8000ba:	e8 cd 0e 00 00       	call   800f8c <ipc_recv>
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
  8000df:	e8 ca 0e 00 00       	call   800fae <ipc_send>
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
  8000ee:	e8 55 0e 00 00       	call   800f48 <fork>
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
  800114:	e8 8b 00 00 00       	call   8001a4 <_panic>
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
  80013e:	e8 6b 0e 00 00       	call   800fae <ipc_send>
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
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800156:	e8 9a 0b 00 00       	call   800cf5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 62 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 01 0b 00 00       	call   800ca3 <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001b5:	e8 3b 0b 00 00       	call   800cf5 <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 d0 12 80 00 	movl   $0x8012d0,(%esp)
  8001d7:	e8 c1 00 00 00       	call   80029d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 51 00 00 00       	call   80023c <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  8001f2:	e8 a6 00 00 00       	call   80029d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>

008001fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 14             	sub    $0x14,%esp
  800201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800204:	8b 13                	mov    (%ebx),%edx
  800206:	8d 42 01             	lea    0x1(%edx),%eax
  800209:	89 03                	mov    %eax,(%ebx)
  80020b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 19                	jne    800232 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800219:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800220:	00 
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 3a 0a 00 00       	call   800c66 <sys_cputs>
		b->idx = 0;
  80022c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	83 c4 14             	add    $0x14,%esp
  800239:	5b                   	pop    %ebx
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800245:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024c:	00 00 00 
	b.cnt = 0;
  80024f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800256:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	c7 04 24 fa 01 80 00 	movl   $0x8001fa,(%esp)
  800278:	e8 77 01 00 00       	call   8003f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	e8 d1 09 00 00       	call   800c66 <sys_cputs>

	return b.cnt;
}
  800295:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 87 ff ff ff       	call   80023c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    
  8002b7:	66 90                	xchg   %ax,%ax
  8002b9:	66 90                	xchg   %ax,%ax
  8002bb:	66 90                	xchg   %ax,%ax
  8002bd:	66 90                	xchg   %ax,%ax
  8002bf:	90                   	nop

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 c3                	mov    %eax,%ebx
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	39 d9                	cmp    %ebx,%ecx
  8002ef:	72 05                	jb     8002f6 <printnum+0x36>
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	77 69                	ja     80035f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 dc 0c 00 00       	call   801010 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 71 ff ff ff       	call   8002c0 <printnum>
  80034f:	eb 1b                	jmp    80036c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff d3                	call   *%ebx
  80035d:	eb 03                	jmp    800362 <printnum+0xa2>
  80035f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800362:	83 ee 01             	sub    $0x1,%esi
  800365:	85 f6                	test   %esi,%esi
  800367:	7f e8                	jg     800351 <printnum+0x91>
  800369:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 ac 0d 00 00       	call   801140 <__umoddi3>
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	0f be 80 f6 12 80 00 	movsbl 0x8012f6(%eax),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003be:	73 0a                	jae    8003ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c3:	89 08                	mov    %ecx,(%eax)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	88 02                	mov    %al,(%edx)
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	e8 02 00 00 00       	call   8003f4 <vprintfmt>
	va_end(ap);
}
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	83 ec 3c             	sub    $0x3c,%esp
  8003fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800400:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800403:	8b 7d 10             	mov    0x10(%ebp),%edi
  800406:	eb 11                	jmp    800419 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800408:	85 c0                	test   %eax,%eax
  80040a:	0f 84 48 04 00 00    	je     800858 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800410:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	83 c7 01             	add    $0x1,%edi
  80041c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800420:	83 f8 25             	cmp    $0x25,%eax
  800423:	75 e3                	jne    800408 <vprintfmt+0x14>
  800425:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800429:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800430:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800437:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800443:	eb 1f                	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800448:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80044c:	eb 16                	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800451:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800455:	eb 0d                	jmp    800464 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800457:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8d 47 01             	lea    0x1(%edi),%eax
  800467:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046a:	0f b6 17             	movzbl (%edi),%edx
  80046d:	0f b6 c2             	movzbl %dl,%eax
  800470:	83 ea 23             	sub    $0x23,%edx
  800473:	80 fa 55             	cmp    $0x55,%dl
  800476:	0f 87 bf 03 00 00    	ja     80083b <vprintfmt+0x447>
  80047c:	0f b6 d2             	movzbl %dl,%edx
  80047f:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800491:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800494:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800498:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80049b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80049e:	83 f9 09             	cmp    $0x9,%ecx
  8004a1:	77 3c                	ja     8004df <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a6:	eb e9                	jmp    800491 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 40 04             	lea    0x4(%eax),%eax
  8004b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004bc:	eb 27                	jmp    8004e5 <vprintfmt+0xf1>
  8004be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c2             	cmovns %edx,%eax
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	eb 91                	jmp    800464 <vprintfmt+0x70>
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004dd:	eb 85                	jmp    800464 <vprintfmt+0x70>
  8004df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	0f 89 75 ff ff ff    	jns    800464 <vprintfmt+0x70>
  8004ef:	e9 63 ff ff ff       	jmp    800457 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004fa:	e9 65 ff ff ff       	jmp    800464 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800502:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800514:	e9 00 ff ff ff       	jmp    800419 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 09             	cmp    $0x9,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x143>
  80052c:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 20                	jne    800557 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800537:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053b:	c7 44 24 08 0e 13 80 	movl   $0x80130e,0x8(%esp)
  800542:	00 
  800543:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 7d fe ff ff       	call   8003cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800552:	e9 c2 fe ff ff       	jmp    800419 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800557:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055b:	c7 44 24 08 17 13 80 	movl   $0x801317,0x8(%esp)
  800562:	00 
  800563:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 5d fe ff ff       	call   8003cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800572:	e9 a2 fe ff ff       	jmp    800419 <vprintfmt+0x25>
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800580:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800587:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800589:	85 ff                	test   %edi,%edi
  80058b:	b8 07 13 80 00       	mov    $0x801307,%eax
  800590:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800593:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800597:	0f 84 92 00 00 00    	je     80062f <vprintfmt+0x23b>
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	0f 8e 98 00 00 00    	jle    80063d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a9:	89 3c 24             	mov    %edi,(%esp)
  8005ac:	e8 47 03 00 00       	call   8008f8 <strnlen>
  8005b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b4:	29 c1                	sub    %eax,%ecx
  8005b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	eb 0f                	jmp    8005d6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	83 ef 01             	sub    $0x1,%edi
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7f ed                	jg     8005c7 <vprintfmt+0x1d3>
  8005da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005e0:	85 c9                	test   %ecx,%ecx
  8005e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e7:	0f 49 c1             	cmovns %ecx,%eax
  8005ea:	29 c1                	sub    %eax,%ecx
  8005ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f5:	89 cb                	mov    %ecx,%ebx
  8005f7:	eb 50                	jmp    800649 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fd:	74 1e                	je     80061d <vprintfmt+0x229>
  8005ff:	0f be d2             	movsbl %dl,%edx
  800602:	83 ea 20             	sub    $0x20,%edx
  800605:	83 fa 5e             	cmp    $0x5e,%edx
  800608:	76 13                	jbe    80061d <vprintfmt+0x229>
					putch('?', putdat);
  80060a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800618:	ff 55 08             	call   *0x8(%ebp)
  80061b:	eb 0d                	jmp    80062a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80061d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800620:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	83 eb 01             	sub    $0x1,%ebx
  80062d:	eb 1a                	jmp    800649 <vprintfmt+0x255>
  80062f:	89 75 08             	mov    %esi,0x8(%ebp)
  800632:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800635:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800638:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063b:	eb 0c                	jmp    800649 <vprintfmt+0x255>
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800649:	83 c7 01             	add    $0x1,%edi
  80064c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800650:	0f be c2             	movsbl %dl,%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	74 25                	je     80067c <vprintfmt+0x288>
  800657:	85 f6                	test   %esi,%esi
  800659:	78 9e                	js     8005f9 <vprintfmt+0x205>
  80065b:	83 ee 01             	sub    $0x1,%esi
  80065e:	79 99                	jns    8005f9 <vprintfmt+0x205>
  800660:	89 df                	mov    %ebx,%edi
  800662:	8b 75 08             	mov    0x8(%ebp),%esi
  800665:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800668:	eb 1a                	jmp    800684 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800675:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800677:	83 ef 01             	sub    $0x1,%edi
  80067a:	eb 08                	jmp    800684 <vprintfmt+0x290>
  80067c:	89 df                	mov    %ebx,%edi
  80067e:	8b 75 08             	mov    0x8(%ebp),%esi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	85 ff                	test   %edi,%edi
  800686:	7f e2                	jg     80066a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068b:	e9 89 fd ff ff       	jmp    800419 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800690:	83 f9 01             	cmp    $0x1,%ecx
  800693:	7e 19                	jle    8006ae <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 40 08             	lea    0x8(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ac:	eb 38                	jmp    8006e6 <vprintfmt+0x2f2>
	else if (lflag)
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	74 1b                	je     8006cd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ba:	89 c1                	mov    %eax,%ecx
  8006bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cb:	eb 19                	jmp    8006e6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	89 c1                	mov    %eax,%ecx
  8006d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ec:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f5:	0f 89 04 01 00 00    	jns    8007ff <vprintfmt+0x40b>
				putch('-', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800706:	ff d6                	call   *%esi
				num = -(long long) num;
  800708:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80070b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80070e:	f7 da                	neg    %edx
  800710:	83 d1 00             	adc    $0x0,%ecx
  800713:	f7 d9                	neg    %ecx
  800715:	e9 e5 00 00 00       	jmp    8007ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071a:	83 f9 01             	cmp    $0x1,%ecx
  80071d:	7e 10                	jle    80072f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	8b 48 04             	mov    0x4(%eax),%ecx
  800727:	8d 40 08             	lea    0x8(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
  80072d:	eb 26                	jmp    800755 <vprintfmt+0x361>
	else if (lflag)
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	74 12                	je     800745 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
  800743:	eb 10                	jmp    800755 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800755:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80075a:	e9 a0 00 00 00       	jmp    8007ff <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80075f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800763:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80076a:	ff d6                	call   *%esi
			putch('X', putdat);
  80076c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800770:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800777:	ff d6                	call   *%esi
			putch('X', putdat);
  800779:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800784:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800789:	e9 8b fc ff ff       	jmp    800419 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80078e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800792:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800799:	ff d6                	call   *%esi
			putch('x', putdat);
  80079b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007bd:	eb 40                	jmp    8007ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bf:	83 f9 01             	cmp    $0x1,%ecx
  8007c2:	7e 10                	jle    8007d4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cc:	8d 40 08             	lea    0x8(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d2:	eb 26                	jmp    8007fa <vprintfmt+0x406>
	else if (lflag)
  8007d4:	85 c9                	test   %ecx,%ecx
  8007d6:	74 12                	je     8007ea <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e2:	8d 40 04             	lea    0x4(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e8:	eb 10                	jmp    8007fa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f4:	8d 40 04             	lea    0x4(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007fa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800803:	89 44 24 10          	mov    %eax,0x10(%esp)
  800807:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800812:	89 14 24             	mov    %edx,(%esp)
  800815:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800819:	89 da                	mov    %ebx,%edx
  80081b:	89 f0                	mov    %esi,%eax
  80081d:	e8 9e fa ff ff       	call   8002c0 <printnum>
			break;
  800822:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800825:	e9 ef fb ff ff       	jmp    800419 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800833:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800836:	e9 de fb ff ff       	jmp    800419 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800846:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800848:	eb 03                	jmp    80084d <vprintfmt+0x459>
  80084a:	83 ef 01             	sub    $0x1,%edi
  80084d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800851:	75 f7                	jne    80084a <vprintfmt+0x456>
  800853:	e9 c1 fb ff ff       	jmp    800419 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800858:	83 c4 3c             	add    $0x3c,%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5f                   	pop    %edi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 28             	sub    $0x28,%esp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800873:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800876:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 30                	je     8008b1 <vsnprintf+0x51>
  800881:	85 d2                	test   %edx,%edx
  800883:	7e 2c                	jle    8008b1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088c:	8b 45 10             	mov    0x10(%ebp),%eax
  80088f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800893:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089a:	c7 04 24 af 03 80 00 	movl   $0x8003af,(%esp)
  8008a1:	e8 4e fb ff ff       	call   8003f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008af:	eb 05                	jmp    8008b6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 82 ff ff ff       	call   800860 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 03                	jmp    8008f0 <strlen+0x10>
		n++;
  8008ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f4:	75 f7                	jne    8008ed <strlen+0xd>
		n++;
	return n;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	eb 03                	jmp    80090b <strnlen+0x13>
		n++;
  800908:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090b:	39 d0                	cmp    %edx,%eax
  80090d:	74 06                	je     800915 <strnlen+0x1d>
  80090f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800913:	75 f3                	jne    800908 <strnlen+0x10>
		n++;
	return n;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	53                   	push   %ebx
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800921:	89 c2                	mov    %eax,%edx
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	83 c1 01             	add    $0x1,%ecx
  800929:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800930:	84 db                	test   %bl,%bl
  800932:	75 ef                	jne    800923 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800941:	89 1c 24             	mov    %ebx,(%esp)
  800944:	e8 97 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800950:	01 d8                	add    %ebx,%eax
  800952:	89 04 24             	mov    %eax,(%esp)
  800955:	e8 bd ff ff ff       	call   800917 <strcpy>
	return dst;
}
  80095a:	89 d8                	mov    %ebx,%eax
  80095c:	83 c4 08             	add    $0x8,%esp
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 75 08             	mov    0x8(%ebp),%esi
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096d:	89 f3                	mov    %esi,%ebx
  80096f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800972:	89 f2                	mov    %esi,%edx
  800974:	eb 0f                	jmp    800985 <strncpy+0x23>
		*dst++ = *src;
  800976:	83 c2 01             	add    $0x1,%edx
  800979:	0f b6 01             	movzbl (%ecx),%eax
  80097c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80097f:	80 39 01             	cmpb   $0x1,(%ecx)
  800982:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800985:	39 da                	cmp    %ebx,%edx
  800987:	75 ed                	jne    800976 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800989:	89 f0                	mov    %esi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 75 08             	mov    0x8(%ebp),%esi
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80099d:	89 f0                	mov    %esi,%eax
  80099f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a3:	85 c9                	test   %ecx,%ecx
  8009a5:	75 0b                	jne    8009b2 <strlcpy+0x23>
  8009a7:	eb 1d                	jmp    8009c6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b2:	39 d8                	cmp    %ebx,%eax
  8009b4:	74 0b                	je     8009c1 <strlcpy+0x32>
  8009b6:	0f b6 0a             	movzbl (%edx),%ecx
  8009b9:	84 c9                	test   %cl,%cl
  8009bb:	75 ec                	jne    8009a9 <strlcpy+0x1a>
  8009bd:	89 c2                	mov    %eax,%edx
  8009bf:	eb 02                	jmp    8009c3 <strlcpy+0x34>
  8009c1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009c3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009c6:	29 f0                	sub    %esi,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strcmp+0x11>
		p++, q++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 04                	je     8009e8 <strcmp+0x1c>
  8009e4:	3a 02                	cmp    (%edx),%al
  8009e6:	74 ef                	je     8009d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 c0             	movzbl %al,%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a01:	eb 06                	jmp    800a09 <strncmp+0x17>
		n--, p++, q++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a09:	39 d8                	cmp    %ebx,%eax
  800a0b:	74 15                	je     800a22 <strncmp+0x30>
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 04                	je     800a18 <strncmp+0x26>
  800a14:	3a 0a                	cmp    (%edx),%cl
  800a16:	74 eb                	je     800a03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
  800a20:	eb 05                	jmp    800a27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	eb 07                	jmp    800a3d <strchr+0x13>
		if (*s == c)
  800a36:	38 ca                	cmp    %cl,%dl
  800a38:	74 0f                	je     800a49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 f2                	jne    800a36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 07                	jmp    800a5e <strfind+0x13>
		if (*s == c)
  800a57:	38 ca                	cmp    %cl,%dl
  800a59:	74 0a                	je     800a65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	0f b6 10             	movzbl (%eax),%edx
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	74 36                	je     800aad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 28                	jne    800aa7 <memset+0x40>
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	75 23                	jne    800aa7 <memset+0x40>
		c &= 0xFF;
  800a84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a88:	89 d3                	mov    %edx,%ebx
  800a8a:	c1 e3 08             	shl    $0x8,%ebx
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	c1 e6 18             	shl    $0x18,%esi
  800a92:	89 d0                	mov    %edx,%eax
  800a94:	c1 e0 10             	shl    $0x10,%eax
  800a97:	09 f0                	or     %esi,%eax
  800a99:	09 c2                	or     %eax,%edx
  800a9b:	89 d0                	mov    %edx,%eax
  800a9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa2:	fc                   	cld    
  800aa3:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa5:	eb 06                	jmp    800aad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 35                	jae    800afb <memmove+0x47>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 d0                	cmp    %edx,%eax
  800acb:	73 2e                	jae    800afb <memmove+0x47>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	75 13                	jne    800aef <memmove+0x3b>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 0e                	jne    800aef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae1:	83 ef 04             	sub    $0x4,%edi
  800ae4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aea:	fd                   	std    
  800aeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aed:	eb 09                	jmp    800af8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aef:	83 ef 01             	sub    $0x1,%edi
  800af2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af5:	fd                   	std    
  800af6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af8:	fc                   	cld    
  800af9:	eb 1d                	jmp    800b18 <memmove+0x64>
  800afb:	89 f2                	mov    %esi,%edx
  800afd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	75 0f                	jne    800b13 <memmove+0x5f>
  800b04:	f6 c1 03             	test   $0x3,%cl
  800b07:	75 0a                	jne    800b13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b0c:	89 c7                	mov    %eax,%edi
  800b0e:	fc                   	cld    
  800b0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b11:	eb 05                	jmp    800b18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	fc                   	cld    
  800b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b22:	8b 45 10             	mov    0x10(%ebp),%eax
  800b25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	89 04 24             	mov    %eax,(%esp)
  800b36:	e8 79 ff ff ff       	call   800ab4 <memmove>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4d:	eb 1a                	jmp    800b69 <memcmp+0x2c>
		if (*s1 != *s2)
  800b4f:	0f b6 02             	movzbl (%edx),%eax
  800b52:	0f b6 19             	movzbl (%ecx),%ebx
  800b55:	38 d8                	cmp    %bl,%al
  800b57:	74 0a                	je     800b63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b59:	0f b6 c0             	movzbl %al,%eax
  800b5c:	0f b6 db             	movzbl %bl,%ebx
  800b5f:	29 d8                	sub    %ebx,%eax
  800b61:	eb 0f                	jmp    800b72 <memcmp+0x35>
		s1++, s2++;
  800b63:	83 c2 01             	add    $0x1,%edx
  800b66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b69:	39 f2                	cmp    %esi,%edx
  800b6b:	75 e2                	jne    800b4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b84:	eb 07                	jmp    800b8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b86:	38 08                	cmp    %cl,(%eax)
  800b88:	74 07                	je     800b91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	39 d0                	cmp    %edx,%eax
  800b8f:	72 f5                	jb     800b86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9f:	eb 03                	jmp    800ba4 <strtol+0x11>
		s++;
  800ba1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba4:	0f b6 0a             	movzbl (%edx),%ecx
  800ba7:	80 f9 09             	cmp    $0x9,%cl
  800baa:	74 f5                	je     800ba1 <strtol+0xe>
  800bac:	80 f9 20             	cmp    $0x20,%cl
  800baf:	74 f0                	je     800ba1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb1:	80 f9 2b             	cmp    $0x2b,%cl
  800bb4:	75 0a                	jne    800bc0 <strtol+0x2d>
		s++;
  800bb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbe:	eb 11                	jmp    800bd1 <strtol+0x3e>
  800bc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc5:	80 f9 2d             	cmp    $0x2d,%cl
  800bc8:	75 07                	jne    800bd1 <strtol+0x3e>
		s++, neg = 1;
  800bca:	8d 52 01             	lea    0x1(%edx),%edx
  800bcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bd6:	75 15                	jne    800bed <strtol+0x5a>
  800bd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bdb:	75 10                	jne    800bed <strtol+0x5a>
  800bdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be1:	75 0a                	jne    800bed <strtol+0x5a>
		s += 2, base = 16;
  800be3:	83 c2 02             	add    $0x2,%edx
  800be6:	b8 10 00 00 00       	mov    $0x10,%eax
  800beb:	eb 10                	jmp    800bfd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bed:	85 c0                	test   %eax,%eax
  800bef:	75 0c                	jne    800bfd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf6:	75 05                	jne    800bfd <strtol+0x6a>
		s++, base = 8;
  800bf8:	83 c2 01             	add    $0x1,%edx
  800bfb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c05:	0f b6 0a             	movzbl (%edx),%ecx
  800c08:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c0b:	89 f0                	mov    %esi,%eax
  800c0d:	3c 09                	cmp    $0x9,%al
  800c0f:	77 08                	ja     800c19 <strtol+0x86>
			dig = *s - '0';
  800c11:	0f be c9             	movsbl %cl,%ecx
  800c14:	83 e9 30             	sub    $0x30,%ecx
  800c17:	eb 20                	jmp    800c39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c19:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c1c:	89 f0                	mov    %esi,%eax
  800c1e:	3c 19                	cmp    $0x19,%al
  800c20:	77 08                	ja     800c2a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c22:	0f be c9             	movsbl %cl,%ecx
  800c25:	83 e9 57             	sub    $0x57,%ecx
  800c28:	eb 0f                	jmp    800c39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c2d:	89 f0                	mov    %esi,%eax
  800c2f:	3c 19                	cmp    $0x19,%al
  800c31:	77 16                	ja     800c49 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c33:	0f be c9             	movsbl %cl,%ecx
  800c36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c3c:	7d 0f                	jge    800c4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c3e:	83 c2 01             	add    $0x1,%edx
  800c41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c47:	eb bc                	jmp    800c05 <strtol+0x72>
  800c49:	89 d8                	mov    %ebx,%eax
  800c4b:	eb 02                	jmp    800c4f <strtol+0xbc>
  800c4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c53:	74 05                	je     800c5a <strtol+0xc7>
		*endptr = (char *) s;
  800c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c5a:	f7 d8                	neg    %eax
  800c5c:	85 ff                	test   %edi,%edi
  800c5e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	89 c7                	mov    %eax,%edi
  800c7b:	89 c6                	mov    %eax,%esi
  800c7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c94:	89 d1                	mov    %edx,%ecx
  800c96:	89 d3                	mov    %edx,%ebx
  800c98:	89 d7                	mov    %edx,%edi
  800c9a:	89 d6                	mov    %edx,%esi
  800c9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 cb                	mov    %ecx,%ebx
  800cbb:	89 cf                	mov    %ecx,%edi
  800cbd:	89 ce                	mov    %ecx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 28                	jle    800ced <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce0:	00 
  800ce1:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800ce8:	e8 b7 f4 ff ff       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ced:	83 c4 2c             	add    $0x2c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 02 00 00 00       	mov    $0x2,%eax
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	89 d7                	mov    %edx,%edi
  800d0b:	89 d6                	mov    %edx,%esi
  800d0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_yield>:

void
sys_yield(void)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d24:	89 d1                	mov    %edx,%ecx
  800d26:	89 d3                	mov    %edx,%ebx
  800d28:	89 d7                	mov    %edx,%edi
  800d2a:	89 d6                	mov    %edx,%esi
  800d2c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	be 00 00 00 00       	mov    $0x0,%esi
  800d41:	b8 04 00 00 00       	mov    $0x4,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	89 f7                	mov    %esi,%edi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800d7a:	e8 25 f4 ff ff       	call   8001a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7f:	83 c4 2c             	add    $0x2c,%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b8 05 00 00 00       	mov    $0x5,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	8b 75 18             	mov    0x18(%ebp),%esi
  800da4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da6:	85 c0                	test   %eax,%eax
  800da8:	7e 28                	jle    800dd2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800db5:	00 
  800db6:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800dbd:	00 
  800dbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc5:	00 
  800dc6:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800dcd:	e8 d2 f3 ff ff       	call   8001a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd2:	83 c4 2c             	add    $0x2c,%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 28                	jle    800e25 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e01:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e08:	00 
  800e09:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800e10:	00 
  800e11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e18:	00 
  800e19:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800e20:	e8 7f f3 ff ff       	call   8001a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e25:	83 c4 2c             	add    $0x2c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 28                	jle    800e78 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800e63:	00 
  800e64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6b:	00 
  800e6c:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800e73:	e8 2c f3 ff ff       	call   8001a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e78:	83 c4 2c             	add    $0x2c,%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	89 df                	mov    %ebx,%edi
  800e9b:	89 de                	mov    %ebx,%esi
  800e9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	7e 28                	jle    800ecb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eae:	00 
  800eaf:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800ec6:	e8 d9 f2 ff ff       	call   8001a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ecb:	83 c4 2c             	add    $0x2c,%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	be 00 00 00 00       	mov    $0x0,%esi
  800ede:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 cb                	mov    %ecx,%ebx
  800f0e:	89 cf                	mov    %ecx,%edi
  800f10:	89 ce                	mov    %ecx,%esi
  800f12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800f3b:	e8 64 f2 ff ff       	call   8001a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f40:	83 c4 2c             	add    $0x2c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f4e:	c7 44 24 08 7f 15 80 	movl   $0x80157f,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  800f65:	e8 3a f2 ff ff       	call   8001a4 <_panic>

00800f6a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f70:	c7 44 24 08 7e 15 80 	movl   $0x80157e,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 73 15 80 00 	movl   $0x801573,(%esp)
  800f87:	e8 18 f2 ff ff       	call   8001a4 <_panic>

00800f8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f92:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  800f99:	00 
  800f9a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 ad 15 80 00 	movl   $0x8015ad,(%esp)
  800fa9:	e8 f6 f1 ff ff       	call   8001a4 <_panic>

00800fae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fb4:	c7 44 24 08 b7 15 80 	movl   $0x8015b7,0x8(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fc3:	00 
  800fc4:	c7 04 24 ad 15 80 00 	movl   $0x8015ad,(%esp)
  800fcb:	e8 d4 f1 ff ff       	call   8001a4 <_panic>

00800fd0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fd6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800fdb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fde:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fe4:	8b 52 50             	mov    0x50(%edx),%edx
  800fe7:	39 ca                	cmp    %ecx,%edx
  800fe9:	75 0d                	jne    800ff8 <ipc_find_env+0x28>
			return envs[i].env_id;
  800feb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fee:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ff3:	8b 40 40             	mov    0x40(%eax),%eax
  800ff6:	eb 0e                	jmp    801006 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ff8:	83 c0 01             	add    $0x1,%eax
  800ffb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801000:	75 d9                	jne    800fdb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801002:	66 b8 00 00          	mov    $0x0,%ax
}
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__udivdi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80101a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80101e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801022:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801026:	85 c0                	test   %eax,%eax
  801028:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80102c:	89 ea                	mov    %ebp,%edx
  80102e:	89 0c 24             	mov    %ecx,(%esp)
  801031:	75 2d                	jne    801060 <__udivdi3+0x50>
  801033:	39 e9                	cmp    %ebp,%ecx
  801035:	77 61                	ja     801098 <__udivdi3+0x88>
  801037:	85 c9                	test   %ecx,%ecx
  801039:	89 ce                	mov    %ecx,%esi
  80103b:	75 0b                	jne    801048 <__udivdi3+0x38>
  80103d:	b8 01 00 00 00       	mov    $0x1,%eax
  801042:	31 d2                	xor    %edx,%edx
  801044:	f7 f1                	div    %ecx
  801046:	89 c6                	mov    %eax,%esi
  801048:	31 d2                	xor    %edx,%edx
  80104a:	89 e8                	mov    %ebp,%eax
  80104c:	f7 f6                	div    %esi
  80104e:	89 c5                	mov    %eax,%ebp
  801050:	89 f8                	mov    %edi,%eax
  801052:	f7 f6                	div    %esi
  801054:	89 ea                	mov    %ebp,%edx
  801056:	83 c4 0c             	add    $0xc,%esp
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	39 e8                	cmp    %ebp,%eax
  801062:	77 24                	ja     801088 <__udivdi3+0x78>
  801064:	0f bd e8             	bsr    %eax,%ebp
  801067:	83 f5 1f             	xor    $0x1f,%ebp
  80106a:	75 3c                	jne    8010a8 <__udivdi3+0x98>
  80106c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801070:	39 34 24             	cmp    %esi,(%esp)
  801073:	0f 86 9f 00 00 00    	jbe    801118 <__udivdi3+0x108>
  801079:	39 d0                	cmp    %edx,%eax
  80107b:	0f 82 97 00 00 00    	jb     801118 <__udivdi3+0x108>
  801081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801088:	31 d2                	xor    %edx,%edx
  80108a:	31 c0                	xor    %eax,%eax
  80108c:	83 c4 0c             	add    $0xc,%esp
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
  801093:	90                   	nop
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	89 f8                	mov    %edi,%eax
  80109a:	f7 f1                	div    %ecx
  80109c:	31 d2                	xor    %edx,%edx
  80109e:	83 c4 0c             	add    $0xc,%esp
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    
  8010a5:	8d 76 00             	lea    0x0(%esi),%esi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	8b 3c 24             	mov    (%esp),%edi
  8010ad:	d3 e0                	shl    %cl,%eax
  8010af:	89 c6                	mov    %eax,%esi
  8010b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b6:	29 e8                	sub    %ebp,%eax
  8010b8:	89 c1                	mov    %eax,%ecx
  8010ba:	d3 ef                	shr    %cl,%edi
  8010bc:	89 e9                	mov    %ebp,%ecx
  8010be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c2:	8b 3c 24             	mov    (%esp),%edi
  8010c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010c9:	89 d6                	mov    %edx,%esi
  8010cb:	d3 e7                	shl    %cl,%edi
  8010cd:	89 c1                	mov    %eax,%ecx
  8010cf:	89 3c 24             	mov    %edi,(%esp)
  8010d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010d6:	d3 ee                	shr    %cl,%esi
  8010d8:	89 e9                	mov    %ebp,%ecx
  8010da:	d3 e2                	shl    %cl,%edx
  8010dc:	89 c1                	mov    %eax,%ecx
  8010de:	d3 ef                	shr    %cl,%edi
  8010e0:	09 d7                	or     %edx,%edi
  8010e2:	89 f2                	mov    %esi,%edx
  8010e4:	89 f8                	mov    %edi,%eax
  8010e6:	f7 74 24 08          	divl   0x8(%esp)
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	f7 24 24             	mull   (%esp)
  8010f1:	39 d6                	cmp    %edx,%esi
  8010f3:	89 14 24             	mov    %edx,(%esp)
  8010f6:	72 30                	jb     801128 <__udivdi3+0x118>
  8010f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010fc:	89 e9                	mov    %ebp,%ecx
  8010fe:	d3 e2                	shl    %cl,%edx
  801100:	39 c2                	cmp    %eax,%edx
  801102:	73 05                	jae    801109 <__udivdi3+0xf9>
  801104:	3b 34 24             	cmp    (%esp),%esi
  801107:	74 1f                	je     801128 <__udivdi3+0x118>
  801109:	89 f8                	mov    %edi,%eax
  80110b:	31 d2                	xor    %edx,%edx
  80110d:	e9 7a ff ff ff       	jmp    80108c <__udivdi3+0x7c>
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	31 d2                	xor    %edx,%edx
  80111a:	b8 01 00 00 00       	mov    $0x1,%eax
  80111f:	e9 68 ff ff ff       	jmp    80108c <__udivdi3+0x7c>
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	8d 47 ff             	lea    -0x1(%edi),%eax
  80112b:	31 d2                	xor    %edx,%edx
  80112d:	83 c4 0c             	add    $0xc,%esp
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    
  801134:	66 90                	xchg   %ax,%ax
  801136:	66 90                	xchg   %ax,%ax
  801138:	66 90                	xchg   %ax,%ax
  80113a:	66 90                	xchg   %ax,%ax
  80113c:	66 90                	xchg   %ax,%ax
  80113e:	66 90                	xchg   %ax,%ax

00801140 <__umoddi3>:
  801140:	55                   	push   %ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	83 ec 14             	sub    $0x14,%esp
  801146:	8b 44 24 28          	mov    0x28(%esp),%eax
  80114a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80114e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801152:	89 c7                	mov    %eax,%edi
  801154:	89 44 24 04          	mov    %eax,0x4(%esp)
  801158:	8b 44 24 30          	mov    0x30(%esp),%eax
  80115c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801160:	89 34 24             	mov    %esi,(%esp)
  801163:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801167:	85 c0                	test   %eax,%eax
  801169:	89 c2                	mov    %eax,%edx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	75 17                	jne    801188 <__umoddi3+0x48>
  801171:	39 fe                	cmp    %edi,%esi
  801173:	76 4b                	jbe    8011c0 <__umoddi3+0x80>
  801175:	89 c8                	mov    %ecx,%eax
  801177:	89 fa                	mov    %edi,%edx
  801179:	f7 f6                	div    %esi
  80117b:	89 d0                	mov    %edx,%eax
  80117d:	31 d2                	xor    %edx,%edx
  80117f:	83 c4 14             	add    $0x14,%esp
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
  801186:	66 90                	xchg   %ax,%ax
  801188:	39 f8                	cmp    %edi,%eax
  80118a:	77 54                	ja     8011e0 <__umoddi3+0xa0>
  80118c:	0f bd e8             	bsr    %eax,%ebp
  80118f:	83 f5 1f             	xor    $0x1f,%ebp
  801192:	75 5c                	jne    8011f0 <__umoddi3+0xb0>
  801194:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801198:	39 3c 24             	cmp    %edi,(%esp)
  80119b:	0f 87 e7 00 00 00    	ja     801288 <__umoddi3+0x148>
  8011a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011a5:	29 f1                	sub    %esi,%ecx
  8011a7:	19 c7                	sbb    %eax,%edi
  8011a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011b9:	83 c4 14             	add    $0x14,%esp
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
  8011c0:	85 f6                	test   %esi,%esi
  8011c2:	89 f5                	mov    %esi,%ebp
  8011c4:	75 0b                	jne    8011d1 <__umoddi3+0x91>
  8011c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cb:	31 d2                	xor    %edx,%edx
  8011cd:	f7 f6                	div    %esi
  8011cf:	89 c5                	mov    %eax,%ebp
  8011d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011d5:	31 d2                	xor    %edx,%edx
  8011d7:	f7 f5                	div    %ebp
  8011d9:	89 c8                	mov    %ecx,%eax
  8011db:	f7 f5                	div    %ebp
  8011dd:	eb 9c                	jmp    80117b <__umoddi3+0x3b>
  8011df:	90                   	nop
  8011e0:	89 c8                	mov    %ecx,%eax
  8011e2:	89 fa                	mov    %edi,%edx
  8011e4:	83 c4 14             	add    $0x14,%esp
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
  8011eb:	90                   	nop
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	8b 04 24             	mov    (%esp),%eax
  8011f3:	be 20 00 00 00       	mov    $0x20,%esi
  8011f8:	89 e9                	mov    %ebp,%ecx
  8011fa:	29 ee                	sub    %ebp,%esi
  8011fc:	d3 e2                	shl    %cl,%edx
  8011fe:	89 f1                	mov    %esi,%ecx
  801200:	d3 e8                	shr    %cl,%eax
  801202:	89 e9                	mov    %ebp,%ecx
  801204:	89 44 24 04          	mov    %eax,0x4(%esp)
  801208:	8b 04 24             	mov    (%esp),%eax
  80120b:	09 54 24 04          	or     %edx,0x4(%esp)
  80120f:	89 fa                	mov    %edi,%edx
  801211:	d3 e0                	shl    %cl,%eax
  801213:	89 f1                	mov    %esi,%ecx
  801215:	89 44 24 08          	mov    %eax,0x8(%esp)
  801219:	8b 44 24 10          	mov    0x10(%esp),%eax
  80121d:	d3 ea                	shr    %cl,%edx
  80121f:	89 e9                	mov    %ebp,%ecx
  801221:	d3 e7                	shl    %cl,%edi
  801223:	89 f1                	mov    %esi,%ecx
  801225:	d3 e8                	shr    %cl,%eax
  801227:	89 e9                	mov    %ebp,%ecx
  801229:	09 f8                	or     %edi,%eax
  80122b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80122f:	f7 74 24 04          	divl   0x4(%esp)
  801233:	d3 e7                	shl    %cl,%edi
  801235:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801239:	89 d7                	mov    %edx,%edi
  80123b:	f7 64 24 08          	mull   0x8(%esp)
  80123f:	39 d7                	cmp    %edx,%edi
  801241:	89 c1                	mov    %eax,%ecx
  801243:	89 14 24             	mov    %edx,(%esp)
  801246:	72 2c                	jb     801274 <__umoddi3+0x134>
  801248:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80124c:	72 22                	jb     801270 <__umoddi3+0x130>
  80124e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801252:	29 c8                	sub    %ecx,%eax
  801254:	19 d7                	sbb    %edx,%edi
  801256:	89 e9                	mov    %ebp,%ecx
  801258:	89 fa                	mov    %edi,%edx
  80125a:	d3 e8                	shr    %cl,%eax
  80125c:	89 f1                	mov    %esi,%ecx
  80125e:	d3 e2                	shl    %cl,%edx
  801260:	89 e9                	mov    %ebp,%ecx
  801262:	d3 ef                	shr    %cl,%edi
  801264:	09 d0                	or     %edx,%eax
  801266:	89 fa                	mov    %edi,%edx
  801268:	83 c4 14             	add    $0x14,%esp
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    
  80126f:	90                   	nop
  801270:	39 d7                	cmp    %edx,%edi
  801272:	75 da                	jne    80124e <__umoddi3+0x10e>
  801274:	8b 14 24             	mov    (%esp),%edx
  801277:	89 c1                	mov    %eax,%ecx
  801279:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80127d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801281:	eb cb                	jmp    80124e <__umoddi3+0x10e>
  801283:	90                   	nop
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80128c:	0f 82 0f ff ff ff    	jb     8011a1 <__umoddi3+0x61>
  801292:	e9 1a ff ff ff       	jmp    8011b1 <__umoddi3+0x71>