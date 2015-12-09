
obj/user/testpiperace2.debug：     文件格式 elf32-i386


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
  80002c:	e8 b9 01 00 00       	call   8001ea <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  800043:	e8 f7 02 00 00       	call   80033f <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 b5 1d 00 00       	call   801e08 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x44>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 ce 26 80 	movl   $0x8026ce,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  800072:	e8 cf 01 00 00       	call   800246 <_panic>
	if ((r = fork()) < 0)
  800077:	e8 29 11 00 00       	call   8011a5 <fork>
  80007c:	89 c7                	mov    %eax,%edi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6f>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 ec 26 80 	movl   $0x8026ec,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  80009d:	e8 a4 01 00 00       	call   800246 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 75                	jne    80011b <umain+0xe8>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 d1 14 00 00       	call   801582 <close>
		for (i = 0; i < 200; i++) {
  8000b1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  8000b6:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	f7 ee                	imul   %esi
  8000bf:	c1 fa 02             	sar    $0x2,%edx
  8000c2:	89 d8                	mov    %ebx,%eax
  8000c4:	c1 f8 1f             	sar    $0x1f,%eax
  8000c7:	29 c2                	sub    %eax,%edx
  8000c9:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000cc:	01 c0                	add    %eax,%eax
  8000ce:	39 c3                	cmp    %eax,%ebx
  8000d0:	75 10                	jne    8000e2 <umain+0xaf>
				cprintf("%d.", i);
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	c7 04 24 f5 26 80 00 	movl   $0x8026f5,(%esp)
  8000dd:	e8 5d 02 00 00       	call   80033f <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000e2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8000e9:	00 
  8000ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000ed:	89 04 24             	mov    %eax,(%esp)
  8000f0:	e8 e2 14 00 00       	call   8015d7 <dup>
			sys_yield();
  8000f5:	e8 ba 0c 00 00       	call   800db4 <sys_yield>
			close(10);
  8000fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800101:	e8 7c 14 00 00       	call   801582 <close>
			sys_yield();
  800106:	e8 a9 0c 00 00       	call   800db4 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  80010b:	83 c3 01             	add    $0x1,%ebx
  80010e:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800114:	75 a5                	jne    8000bb <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  800116:	e8 17 01 00 00       	call   800232 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  80011b:	89 fb                	mov    %edi,%ebx
  80011d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800123:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800126:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80012c:	eb 28                	jmp    800156 <umain+0x123>
		if (pipeisclosed(p[0]) != 0) {
  80012e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 40 1e 00 00       	call   801f79 <pipeisclosed>
  800139:	85 c0                	test   %eax,%eax
  80013b:	74 19                	je     800156 <umain+0x123>
			cprintf("\nRACE: pipe appears closed\n");
  80013d:	c7 04 24 f9 26 80 00 	movl   $0x8026f9,(%esp)
  800144:	e8 f6 01 00 00       	call   80033f <cprintf>
			sys_env_destroy(r);
  800149:	89 3c 24             	mov    %edi,(%esp)
  80014c:	e8 f2 0b 00 00       	call   800d43 <sys_env_destroy>
			exit();
  800151:	e8 dc 00 00 00       	call   800232 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800156:	8b 43 54             	mov    0x54(%ebx),%eax
  800159:	83 f8 02             	cmp    $0x2,%eax
  80015c:	74 d0                	je     80012e <umain+0xfb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80015e:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  800165:	e8 d5 01 00 00       	call   80033f <cprintf>
	if (pipeisclosed(p[0]))
  80016a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016d:	89 04 24             	mov    %eax,(%esp)
  800170:	e8 04 1e 00 00       	call   801f79 <pipeisclosed>
  800175:	85 c0                	test   %eax,%eax
  800177:	74 1c                	je     800195 <umain+0x162>
		panic("somehow the other end of p[0] got closed!");
  800179:	c7 44 24 08 a4 26 80 	movl   $0x8026a4,0x8(%esp)
  800180:	00 
  800181:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800188:	00 
  800189:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  800190:	e8 b1 00 00 00       	call   800246 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800195:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80019f:	89 04 24             	mov    %eax,(%esp)
  8001a2:	e8 af 12 00 00       	call   801456 <fd_lookup>
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	79 20                	jns    8001cb <umain+0x198>
		panic("cannot look up p[0]: %e", r);
  8001ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001af:	c7 44 24 08 2b 27 80 	movl   $0x80272b,0x8(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001be:	00 
  8001bf:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  8001c6:	e8 7b 00 00 00       	call   800246 <_panic>
	(void) fd2data(fd);
  8001cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 1a 12 00 00       	call   8013f0 <fd2data>
	cprintf("race didn't happen\n");
  8001d6:	c7 04 24 43 27 80 00 	movl   $0x802743,(%esp)
  8001dd:	e8 5d 01 00 00       	call   80033f <cprintf>
}
  8001e2:	83 c4 2c             	add    $0x2c,%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 10             	sub    $0x10,%esp
  8001f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8001f8:	e8 98 0b 00 00       	call   800d95 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800202:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800205:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020f:	85 db                	test   %ebx,%ebx
  800211:	7e 07                	jle    80021a <libmain+0x30>
		binaryname = argv[0];
  800213:	8b 06                	mov    (%esi),%eax
  800215:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021e:	89 1c 24             	mov    %ebx,(%esp)
  800221:	e8 0d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800226:	e8 07 00 00 00       	call   800232 <exit>
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023f:	e8 ff 0a 00 00       	call   800d43 <sys_env_destroy>
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80024e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800251:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800257:	e8 39 0b 00 00       	call   800d95 <sys_getenvid>
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800263:	8b 55 08             	mov    0x8(%ebp),%edx
  800266:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80026e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800272:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  800279:	e8 c1 00 00 00       	call   80033f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80027e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800282:	8b 45 10             	mov    0x10(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 51 00 00 00       	call   8002de <vcprintf>
	cprintf("\n");
  80028d:	c7 04 24 65 2d 80 00 	movl   $0x802d65,(%esp)
  800294:	e8 a6 00 00 00       	call   80033f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800299:	cc                   	int3   
  80029a:	eb fd                	jmp    800299 <_panic+0x53>

0080029c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 14             	sub    $0x14,%esp
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a6:	8b 13                	mov    (%ebx),%edx
  8002a8:	8d 42 01             	lea    0x1(%edx),%eax
  8002ab:	89 03                	mov    %eax,(%ebx)
  8002ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b9:	75 19                	jne    8002d4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002bb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c2:	00 
  8002c3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	e8 38 0a 00 00       	call   800d06 <sys_cputs>
		b->idx = 0;
  8002ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002d8:	83 c4 14             	add    $0x14,%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ee:	00 00 00 
	b.cnt = 0;
  8002f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	c7 04 24 9c 02 80 00 	movl   $0x80029c,(%esp)
  80031a:	e8 75 01 00 00       	call   800494 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	e8 cf 09 00 00       	call   800d06 <sys_cputs>

	return b.cnt;
}
  800337:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800345:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	e8 87 ff ff ff       	call   8002de <vcprintf>
	va_end(ap);

	return cnt;
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    
  800359:	66 90                	xchg   %ax,%ax
  80035b:	66 90                	xchg   %ax,%ax
  80035d:	66 90                	xchg   %ax,%ax
  80035f:	90                   	nop

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 3c             	sub    $0x3c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d7                	mov    %edx,%edi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
  800377:	89 c3                	mov    %eax,%ebx
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	8b 45 10             	mov    0x10(%ebp),%eax
  80037f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80038d:	39 d9                	cmp    %ebx,%ecx
  80038f:	72 05                	jb     800396 <printnum+0x36>
  800391:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800394:	77 69                	ja     8003ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800396:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800399:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80039d:	83 ee 01             	sub    $0x1,%esi
  8003a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003b0:	89 c3                	mov    %eax,%ebx
  8003b2:	89 d6                	mov    %edx,%esi
  8003b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ba:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 1c 20 00 00       	call   8023f0 <__udivdi3>
  8003d4:	89 d9                	mov    %ebx,%ecx
  8003d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003de:	89 04 24             	mov    %eax,(%esp)
  8003e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e5:	89 fa                	mov    %edi,%edx
  8003e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ea:	e8 71 ff ff ff       	call   800360 <printnum>
  8003ef:	eb 1b                	jmp    80040c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	ff d3                	call   *%ebx
  8003fd:	eb 03                	jmp    800402 <printnum+0xa2>
  8003ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800402:	83 ee 01             	sub    $0x1,%esi
  800405:	85 f6                	test   %esi,%esi
  800407:	7f e8                	jg     8003f1 <printnum+0x91>
  800409:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800410:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800414:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800417:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 ec 20 00 00       	call   802520 <__umoddi3>
  800434:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800438:	0f be 80 87 27 80 00 	movsbl 0x802787(%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800445:	ff d0                	call   *%eax
}
  800447:	83 c4 3c             	add    $0x3c,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800455:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	3b 50 04             	cmp    0x4(%eax),%edx
  80045e:	73 0a                	jae    80046a <sprintputch+0x1b>
		*b->buf++ = ch;
  800460:	8d 4a 01             	lea    0x1(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	88 02                	mov    %al,(%edx)
}
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800472:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800475:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800479:	8b 45 10             	mov    0x10(%ebp),%eax
  80047c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 04          	mov    %eax,0x4(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 04 24             	mov    %eax,(%esp)
  80048d:	e8 02 00 00 00       	call   800494 <vprintfmt>
	va_end(ap);
}
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 3c             	sub    $0x3c,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a6:	eb 11                	jmp    8004b9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	0f 84 48 04 00 00    	je     8008f8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b9:	83 c7 01             	add    $0x1,%edi
  8004bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c0:	83 f8 25             	cmp    $0x25,%eax
  8004c3:	75 e3                	jne    8004a8 <vprintfmt+0x14>
  8004c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e3:	eb 1f                	jmp    800504 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004ec:	eb 16                	jmp    800504 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004f5:	eb 0d                	jmp    800504 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8d 47 01             	lea    0x1(%edi),%eax
  800507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050a:	0f b6 17             	movzbl (%edi),%edx
  80050d:	0f b6 c2             	movzbl %dl,%eax
  800510:	83 ea 23             	sub    $0x23,%edx
  800513:	80 fa 55             	cmp    $0x55,%dl
  800516:	0f 87 bf 03 00 00    	ja     8008db <vprintfmt+0x447>
  80051c:	0f b6 d2             	movzbl %dl,%edx
  80051f:	ff 24 95 c0 28 80 00 	jmp    *0x8028c0(,%edx,4)
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
  80052e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800531:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800534:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800538:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80053b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80053e:	83 f9 09             	cmp    $0x9,%ecx
  800541:	77 3c                	ja     80057f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800543:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800546:	eb e9                	jmp    800531 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 40 04             	lea    0x4(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055c:	eb 27                	jmp    800585 <vprintfmt+0xf1>
  80055e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	b8 00 00 00 00       	mov    $0x0,%eax
  800568:	0f 49 c2             	cmovns %edx,%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800571:	eb 91                	jmp    800504 <vprintfmt+0x70>
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800576:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057d:	eb 85                	jmp    800504 <vprintfmt+0x70>
  80057f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800582:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800589:	0f 89 75 ff ff ff    	jns    800504 <vprintfmt+0x70>
  80058f:	e9 63 ff ff ff       	jmp    8004f7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800594:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80059a:	e9 65 ff ff ff       	jmp    800504 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005b4:	e9 00 ff ff ff       	jmp    8004b9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	99                   	cltd   
  8005c3:	31 d0                	xor    %edx,%eax
  8005c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c7:	83 f8 0f             	cmp    $0xf,%eax
  8005ca:	7f 0b                	jg     8005d7 <vprintfmt+0x143>
  8005cc:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  8005d3:	85 d2                	test   %edx,%edx
  8005d5:	75 20                	jne    8005f7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8005d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005db:	c7 44 24 08 9f 27 80 	movl   $0x80279f,0x8(%esp)
  8005e2:	00 
  8005e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e7:	89 34 24             	mov    %esi,(%esp)
  8005ea:	e8 7d fe ff ff       	call   80046c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005f2:	e9 c2 fe ff ff       	jmp    8004b9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fb:	c7 44 24 08 3e 2d 80 	movl   $0x802d3e,0x8(%esp)
  800602:	00 
  800603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800607:	89 34 24             	mov    %esi,(%esp)
  80060a:	e8 5d fe ff ff       	call   80046c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800612:	e9 a2 fe ff ff       	jmp    8004b9 <vprintfmt+0x25>
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80061d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800620:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800623:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800627:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800629:	85 ff                	test   %edi,%edi
  80062b:	b8 98 27 80 00       	mov    $0x802798,%eax
  800630:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800633:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800637:	0f 84 92 00 00 00    	je     8006cf <vprintfmt+0x23b>
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	0f 8e 98 00 00 00    	jle    8006dd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800645:	89 54 24 04          	mov    %edx,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	e8 47 03 00 00       	call   800998 <strnlen>
  800651:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800654:	29 c1                	sub    %eax,%ecx
  800656:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800659:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800660:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800663:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800665:	eb 0f                	jmp    800676 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066e:	89 04 24             	mov    %eax,(%esp)
  800671:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800673:	83 ef 01             	sub    $0x1,%edi
  800676:	85 ff                	test   %edi,%edi
  800678:	7f ed                	jg     800667 <vprintfmt+0x1d3>
  80067a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800680:	85 c9                	test   %ecx,%ecx
  800682:	b8 00 00 00 00       	mov    $0x0,%eax
  800687:	0f 49 c1             	cmovns %ecx,%eax
  80068a:	29 c1                	sub    %eax,%ecx
  80068c:	89 75 08             	mov    %esi,0x8(%ebp)
  80068f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800692:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800695:	89 cb                	mov    %ecx,%ebx
  800697:	eb 50                	jmp    8006e9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800699:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069d:	74 1e                	je     8006bd <vprintfmt+0x229>
  80069f:	0f be d2             	movsbl %dl,%edx
  8006a2:	83 ea 20             	sub    $0x20,%edx
  8006a5:	83 fa 5e             	cmp    $0x5e,%edx
  8006a8:	76 13                	jbe    8006bd <vprintfmt+0x229>
					putch('?', putdat);
  8006aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006b8:	ff 55 08             	call   *0x8(%ebp)
  8006bb:	eb 0d                	jmp    8006ca <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8006bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	83 eb 01             	sub    $0x1,%ebx
  8006cd:	eb 1a                	jmp    8006e9 <vprintfmt+0x255>
  8006cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006db:	eb 0c                	jmp    8006e9 <vprintfmt+0x255>
  8006dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e9:	83 c7 01             	add    $0x1,%edi
  8006ec:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006f0:	0f be c2             	movsbl %dl,%eax
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 25                	je     80071c <vprintfmt+0x288>
  8006f7:	85 f6                	test   %esi,%esi
  8006f9:	78 9e                	js     800699 <vprintfmt+0x205>
  8006fb:	83 ee 01             	sub    $0x1,%esi
  8006fe:	79 99                	jns    800699 <vprintfmt+0x205>
  800700:	89 df                	mov    %ebx,%edi
  800702:	8b 75 08             	mov    0x8(%ebp),%esi
  800705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800708:	eb 1a                	jmp    800724 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800715:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800717:	83 ef 01             	sub    $0x1,%edi
  80071a:	eb 08                	jmp    800724 <vprintfmt+0x290>
  80071c:	89 df                	mov    %ebx,%edi
  80071e:	8b 75 08             	mov    0x8(%ebp),%esi
  800721:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800724:	85 ff                	test   %edi,%edi
  800726:	7f e2                	jg     80070a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072b:	e9 89 fd ff ff       	jmp    8004b9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800730:	83 f9 01             	cmp    $0x1,%ecx
  800733:	7e 19                	jle    80074e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 50 04             	mov    0x4(%eax),%edx
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800740:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 40 08             	lea    0x8(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
  80074c:	eb 38                	jmp    800786 <vprintfmt+0x2f2>
	else if (lflag)
  80074e:	85 c9                	test   %ecx,%ecx
  800750:	74 1b                	je     80076d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075a:	89 c1                	mov    %eax,%ecx
  80075c:	c1 f9 1f             	sar    $0x1f,%ecx
  80075f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 40 04             	lea    0x4(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
  80076b:	eb 19                	jmp    800786 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 00                	mov    (%eax),%eax
  800772:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800775:	89 c1                	mov    %eax,%ecx
  800777:	c1 f9 1f             	sar    $0x1f,%ecx
  80077a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8d 40 04             	lea    0x4(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800786:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800789:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800791:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800795:	0f 89 04 01 00 00    	jns    80089f <vprintfmt+0x40b>
				putch('-', putdat);
  80079b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ae:	f7 da                	neg    %edx
  8007b0:	83 d1 00             	adc    $0x0,%ecx
  8007b3:	f7 d9                	neg    %ecx
  8007b5:	e9 e5 00 00 00       	jmp    80089f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ba:	83 f9 01             	cmp    $0x1,%ecx
  8007bd:	7e 10                	jle    8007cf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8b 10                	mov    (%eax),%edx
  8007c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cd:	eb 26                	jmp    8007f5 <vprintfmt+0x361>
	else if (lflag)
  8007cf:	85 c9                	test   %ecx,%ecx
  8007d1:	74 12                	je     8007e5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dd:	8d 40 04             	lea    0x4(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e3:	eb 10                	jmp    8007f5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8b 10                	mov    (%eax),%edx
  8007ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ef:	8d 40 04             	lea    0x4(%eax),%eax
  8007f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007fa:	e9 a0 00 00 00       	jmp    80089f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800803:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80080a:	ff d6                	call   *%esi
			putch('X', putdat);
  80080c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800810:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800817:	ff d6                	call   *%esi
			putch('X', putdat);
  800819:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800824:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800829:	e9 8b fc ff ff       	jmp    8004b9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80082e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800832:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800839:	ff d6                	call   *%esi
			putch('x', putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800846:	ff d6                	call   *%esi
			num = (unsigned long long)
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8b 10                	mov    (%eax),%edx
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800852:	8d 40 04             	lea    0x4(%eax),%eax
  800855:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800858:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80085d:	eb 40                	jmp    80089f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80085f:	83 f9 01             	cmp    $0x1,%ecx
  800862:	7e 10                	jle    800874 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8b 10                	mov    (%eax),%edx
  800869:	8b 48 04             	mov    0x4(%eax),%ecx
  80086c:	8d 40 08             	lea    0x8(%eax),%eax
  80086f:	89 45 14             	mov    %eax,0x14(%ebp)
  800872:	eb 26                	jmp    80089a <vprintfmt+0x406>
	else if (lflag)
  800874:	85 c9                	test   %ecx,%ecx
  800876:	74 12                	je     80088a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
  800888:	eb 10                	jmp    80089a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800894:	8d 40 04             	lea    0x4(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80089a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8008b2:	89 14 24             	mov    %edx,(%esp)
  8008b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b9:	89 da                	mov    %ebx,%edx
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	e8 9e fa ff ff       	call   800360 <printnum>
			break;
  8008c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c5:	e9 ef fb ff ff       	jmp    8004b9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ce:	89 04 24             	mov    %eax,(%esp)
  8008d1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d6:	e9 de fb ff ff       	jmp    8004b9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e8:	eb 03                	jmp    8008ed <vprintfmt+0x459>
  8008ea:	83 ef 01             	sub    $0x1,%edi
  8008ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f1:	75 f7                	jne    8008ea <vprintfmt+0x456>
  8008f3:	e9 c1 fb ff ff       	jmp    8004b9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008f8:	83 c4 3c             	add    $0x3c,%esp
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5f                   	pop    %edi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 28             	sub    $0x28,%esp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800913:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800916:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091d:	85 c0                	test   %eax,%eax
  80091f:	74 30                	je     800951 <vsnprintf+0x51>
  800921:	85 d2                	test   %edx,%edx
  800923:	7e 2c                	jle    800951 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092c:	8b 45 10             	mov    0x10(%ebp),%eax
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	c7 04 24 4f 04 80 00 	movl   $0x80044f,(%esp)
  800941:	e8 4e fb ff ff       	call   800494 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800946:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800949:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	eb 05                	jmp    800956 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800951:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 82 ff ff ff       	call   800900 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb 03                	jmp    800990 <strlen+0x10>
		n++;
  80098d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800990:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800994:	75 f7                	jne    80098d <strlen+0xd>
		n++;
	return n;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a6:	eb 03                	jmp    8009ab <strnlen+0x13>
		n++;
  8009a8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ab:	39 d0                	cmp    %edx,%eax
  8009ad:	74 06                	je     8009b5 <strnlen+0x1d>
  8009af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009b3:	75 f3                	jne    8009a8 <strnlen+0x10>
		n++;
	return n;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	83 c1 01             	add    $0x1,%ecx
  8009c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d0:	84 db                	test   %bl,%bl
  8009d2:	75 ef                	jne    8009c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 08             	sub    $0x8,%esp
  8009de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e1:	89 1c 24             	mov    %ebx,(%esp)
  8009e4:	e8 97 ff ff ff       	call   800980 <strlen>
	strcpy(dst + len, src);
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f0:	01 d8                	add    %ebx,%eax
  8009f2:	89 04 24             	mov    %eax,(%esp)
  8009f5:	e8 bd ff ff ff       	call   8009b7 <strcpy>
	return dst;
}
  8009fa:	89 d8                	mov    %ebx,%eax
  8009fc:	83 c4 08             	add    $0x8,%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a12:	89 f2                	mov    %esi,%edx
  800a14:	eb 0f                	jmp    800a25 <strncpy+0x23>
		*dst++ = *src;
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	0f b6 01             	movzbl (%ecx),%eax
  800a1c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a22:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a25:	39 da                	cmp    %ebx,%edx
  800a27:	75 ed                	jne    800a16 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a29:	89 f0                	mov    %esi,%eax
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 08             	mov    0x8(%ebp),%esi
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a3d:	89 f0                	mov    %esi,%eax
  800a3f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	75 0b                	jne    800a52 <strlcpy+0x23>
  800a47:	eb 1d                	jmp    800a66 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a52:	39 d8                	cmp    %ebx,%eax
  800a54:	74 0b                	je     800a61 <strlcpy+0x32>
  800a56:	0f b6 0a             	movzbl (%edx),%ecx
  800a59:	84 c9                	test   %cl,%cl
  800a5b:	75 ec                	jne    800a49 <strlcpy+0x1a>
  800a5d:	89 c2                	mov    %eax,%edx
  800a5f:	eb 02                	jmp    800a63 <strlcpy+0x34>
  800a61:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a63:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a66:	29 f0                	sub    %esi,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a75:	eb 06                	jmp    800a7d <strcmp+0x11>
		p++, q++;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7d:	0f b6 01             	movzbl (%ecx),%eax
  800a80:	84 c0                	test   %al,%al
  800a82:	74 04                	je     800a88 <strcmp+0x1c>
  800a84:	3a 02                	cmp    (%edx),%al
  800a86:	74 ef                	je     800a77 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a88:	0f b6 c0             	movzbl %al,%eax
  800a8b:	0f b6 12             	movzbl (%edx),%edx
  800a8e:	29 d0                	sub    %edx,%eax
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa1:	eb 06                	jmp    800aa9 <strncmp+0x17>
		n--, p++, q++;
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa9:	39 d8                	cmp    %ebx,%eax
  800aab:	74 15                	je     800ac2 <strncmp+0x30>
  800aad:	0f b6 08             	movzbl (%eax),%ecx
  800ab0:	84 c9                	test   %cl,%cl
  800ab2:	74 04                	je     800ab8 <strncmp+0x26>
  800ab4:	3a 0a                	cmp    (%edx),%cl
  800ab6:	74 eb                	je     800aa3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab8:	0f b6 00             	movzbl (%eax),%eax
  800abb:	0f b6 12             	movzbl (%edx),%edx
  800abe:	29 d0                	sub    %edx,%eax
  800ac0:	eb 05                	jmp    800ac7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad4:	eb 07                	jmp    800add <strchr+0x13>
		if (*s == c)
  800ad6:	38 ca                	cmp    %cl,%dl
  800ad8:	74 0f                	je     800ae9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	75 f2                	jne    800ad6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af5:	eb 07                	jmp    800afe <strfind+0x13>
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 0a                	je     800b05 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	0f b6 10             	movzbl (%eax),%edx
  800b01:	84 d2                	test   %dl,%dl
  800b03:	75 f2                	jne    800af7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b13:	85 c9                	test   %ecx,%ecx
  800b15:	74 36                	je     800b4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1d:	75 28                	jne    800b47 <memset+0x40>
  800b1f:	f6 c1 03             	test   $0x3,%cl
  800b22:	75 23                	jne    800b47 <memset+0x40>
		c &= 0xFF;
  800b24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	c1 e3 08             	shl    $0x8,%ebx
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	c1 e6 18             	shl    $0x18,%esi
  800b32:	89 d0                	mov    %edx,%eax
  800b34:	c1 e0 10             	shl    $0x10,%eax
  800b37:	09 f0                	or     %esi,%eax
  800b39:	09 c2                	or     %eax,%edx
  800b3b:	89 d0                	mov    %edx,%eax
  800b3d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b42:	fc                   	cld    
  800b43:	f3 ab                	rep stos %eax,%es:(%edi)
  800b45:	eb 06                	jmp    800b4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	fc                   	cld    
  800b4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b62:	39 c6                	cmp    %eax,%esi
  800b64:	73 35                	jae    800b9b <memmove+0x47>
  800b66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b69:	39 d0                	cmp    %edx,%eax
  800b6b:	73 2e                	jae    800b9b <memmove+0x47>
		s += n;
		d += n;
  800b6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7a:	75 13                	jne    800b8f <memmove+0x3b>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 0e                	jne    800b8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b81:	83 ef 04             	sub    $0x4,%edi
  800b84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8a:	fd                   	std    
  800b8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8d:	eb 09                	jmp    800b98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8f:	83 ef 01             	sub    $0x1,%edi
  800b92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b95:	fd                   	std    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b98:	fc                   	cld    
  800b99:	eb 1d                	jmp    800bb8 <memmove+0x64>
  800b9b:	89 f2                	mov    %esi,%edx
  800b9d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9f:	f6 c2 03             	test   $0x3,%dl
  800ba2:	75 0f                	jne    800bb3 <memmove+0x5f>
  800ba4:	f6 c1 03             	test   $0x3,%cl
  800ba7:	75 0a                	jne    800bb3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	fc                   	cld    
  800baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb1:	eb 05                	jmp    800bb8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	fc                   	cld    
  800bb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	89 04 24             	mov    %eax,(%esp)
  800bd6:	e8 79 ff ff ff       	call   800b54 <memmove>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bed:	eb 1a                	jmp    800c09 <memcmp+0x2c>
		if (*s1 != *s2)
  800bef:	0f b6 02             	movzbl (%edx),%eax
  800bf2:	0f b6 19             	movzbl (%ecx),%ebx
  800bf5:	38 d8                	cmp    %bl,%al
  800bf7:	74 0a                	je     800c03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf9:	0f b6 c0             	movzbl %al,%eax
  800bfc:	0f b6 db             	movzbl %bl,%ebx
  800bff:	29 d8                	sub    %ebx,%eax
  800c01:	eb 0f                	jmp    800c12 <memcmp+0x35>
		s1++, s2++;
  800c03:	83 c2 01             	add    $0x1,%edx
  800c06:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c09:	39 f2                	cmp    %esi,%edx
  800c0b:	75 e2                	jne    800bef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c24:	eb 07                	jmp    800c2d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c26:	38 08                	cmp    %cl,(%eax)
  800c28:	74 07                	je     800c31 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	39 d0                	cmp    %edx,%eax
  800c2f:	72 f5                	jb     800c26 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3f:	eb 03                	jmp    800c44 <strtol+0x11>
		s++;
  800c41:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	0f b6 0a             	movzbl (%edx),%ecx
  800c47:	80 f9 09             	cmp    $0x9,%cl
  800c4a:	74 f5                	je     800c41 <strtol+0xe>
  800c4c:	80 f9 20             	cmp    $0x20,%cl
  800c4f:	74 f0                	je     800c41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	80 f9 2b             	cmp    $0x2b,%cl
  800c54:	75 0a                	jne    800c60 <strtol+0x2d>
		s++;
  800c56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c59:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5e:	eb 11                	jmp    800c71 <strtol+0x3e>
  800c60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c65:	80 f9 2d             	cmp    $0x2d,%cl
  800c68:	75 07                	jne    800c71 <strtol+0x3e>
		s++, neg = 1;
  800c6a:	8d 52 01             	lea    0x1(%edx),%edx
  800c6d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c71:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c76:	75 15                	jne    800c8d <strtol+0x5a>
  800c78:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7b:	75 10                	jne    800c8d <strtol+0x5a>
  800c7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c81:	75 0a                	jne    800c8d <strtol+0x5a>
		s += 2, base = 16;
  800c83:	83 c2 02             	add    $0x2,%edx
  800c86:	b8 10 00 00 00       	mov    $0x10,%eax
  800c8b:	eb 10                	jmp    800c9d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	75 0c                	jne    800c9d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c91:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c93:	80 3a 30             	cmpb   $0x30,(%edx)
  800c96:	75 05                	jne    800c9d <strtol+0x6a>
		s++, base = 8;
  800c98:	83 c2 01             	add    $0x1,%edx
  800c9b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca5:	0f b6 0a             	movzbl (%edx),%ecx
  800ca8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	3c 09                	cmp    $0x9,%al
  800caf:	77 08                	ja     800cb9 <strtol+0x86>
			dig = *s - '0';
  800cb1:	0f be c9             	movsbl %cl,%ecx
  800cb4:	83 e9 30             	sub    $0x30,%ecx
  800cb7:	eb 20                	jmp    800cd9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800cb9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cbc:	89 f0                	mov    %esi,%eax
  800cbe:	3c 19                	cmp    $0x19,%al
  800cc0:	77 08                	ja     800cca <strtol+0x97>
			dig = *s - 'a' + 10;
  800cc2:	0f be c9             	movsbl %cl,%ecx
  800cc5:	83 e9 57             	sub    $0x57,%ecx
  800cc8:	eb 0f                	jmp    800cd9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cca:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ccd:	89 f0                	mov    %esi,%eax
  800ccf:	3c 19                	cmp    $0x19,%al
  800cd1:	77 16                	ja     800ce9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cd3:	0f be c9             	movsbl %cl,%ecx
  800cd6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cd9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cdc:	7d 0f                	jge    800ced <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cde:	83 c2 01             	add    $0x1,%edx
  800ce1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ce5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ce7:	eb bc                	jmp    800ca5 <strtol+0x72>
  800ce9:	89 d8                	mov    %ebx,%eax
  800ceb:	eb 02                	jmp    800cef <strtol+0xbc>
  800ced:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf3:	74 05                	je     800cfa <strtol+0xc7>
		*endptr = (char *) s;
  800cf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cfa:	f7 d8                	neg    %eax
  800cfc:	85 ff                	test   %edi,%edi
  800cfe:	0f 44 c3             	cmove  %ebx,%eax
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 c3                	mov    %eax,%ebx
  800d19:	89 c7                	mov    %eax,%edi
  800d1b:	89 c6                	mov    %eax,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_cgetc>:

int
sys_cgetc(void)
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
  800d2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	b8 03 00 00 00       	mov    $0x3,%eax
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 28                	jle    800d8d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d69:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d70:	00 
  800d71:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800d78:	00 
  800d79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d80:	00 
  800d81:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800d88:	e8 b9 f4 ff ff       	call   800246 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8d:	83 c4 2c             	add    $0x2c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 02 00 00 00       	mov    $0x2,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_yield>:

void
sys_yield(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	b8 04 00 00 00       	mov    $0x4,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800def:	89 f7                	mov    %esi,%edi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e1a:	e8 27 f4 ff ff       	call   800246 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e1f:	83 c4 2c             	add    $0x2c,%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	b8 05 00 00 00       	mov    $0x5,%eax
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e41:	8b 75 18             	mov    0x18(%ebp),%esi
  800e44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 28                	jle    800e72 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800e6d:	e8 d4 f3 ff ff       	call   800246 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e72:	83 c4 2c             	add    $0x2c,%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800ec0:	e8 81 f3 ff ff       	call   800246 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec5:	83 c4 2c             	add    $0x2c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f13:	e8 2e f3 ff ff       	call   800246 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f18:	83 c4 2c             	add    $0x2c,%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 df                	mov    %ebx,%edi
  800f3b:	89 de                	mov    %ebx,%esi
  800f3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	7e 28                	jle    800f6b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f47:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800f56:	00 
  800f57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5e:	00 
  800f5f:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800f66:	e8 db f2 ff ff       	call   800246 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f6b:	83 c4 2c             	add    $0x2c,%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	89 df                	mov    %ebx,%edi
  800f8e:	89 de                	mov    %ebx,%esi
  800f90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 28                	jle    800fbe <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  800fa9:	00 
  800faa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  800fb9:	e8 88 f2 ff ff       	call   800246 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fbe:	83 c4 2c             	add    $0x2c,%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcc:	be 00 00 00 00       	mov    $0x0,%esi
  800fd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fff:	89 cb                	mov    %ecx,%ebx
  801001:	89 cf                	mov    %ecx,%edi
  801003:	89 ce                	mov    %ecx,%esi
  801005:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	7e 28                	jle    801033 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801016:	00 
  801017:	c7 44 24 08 7f 2a 80 	movl   $0x802a7f,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  80102e:	e8 13 f2 ff ff       	call   800246 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801033:	83 c4 2c             	add    $0x2c,%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 20             	sub    $0x20,%esp
  801043:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801046:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801048:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80104c:	75 3f                	jne    80108d <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80104e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801052:	c7 04 24 aa 2a 80 00 	movl   $0x802aaa,(%esp)
  801059:	e8 e1 f2 ff ff       	call   80033f <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80105e:	8b 43 28             	mov    0x28(%ebx),%eax
  801061:	89 44 24 04          	mov    %eax,0x4(%esp)
  801065:	c7 04 24 ba 2a 80 00 	movl   $0x802aba,(%esp)
  80106c:	e8 ce f2 ff ff       	call   80033f <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801071:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  801088:	e8 b9 f1 ff ff       	call   800246 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80108d:	89 f0                	mov    %esi,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801099:	f6 c4 08             	test   $0x8,%ah
  80109c:	75 1c                	jne    8010ba <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80109e:	c7 44 24 08 28 2b 80 	movl   $0x802b28,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8010b5:	e8 8c f1 ff ff       	call   800246 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  8010ba:	e8 d6 fc ff ff       	call   800d95 <sys_getenvid>
  8010bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ce:	00 
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 fc fc ff ff       	call   800dd3 <sys_page_alloc>
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 1c                	jns    8010f7 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  8010db:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8010f2:	e8 4f f1 ff ff       	call   800246 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8010f7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8010fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801104:	00 
  801105:	89 74 24 04          	mov    %esi,0x4(%esp)
  801109:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801110:	e8 a7 fa ff ff       	call   800bbc <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801115:	e8 7b fc ff ff       	call   800d95 <sys_getenvid>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	e8 74 fc ff ff       	call   800d95 <sys_getenvid>
  801121:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801128:	00 
  801129:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80112d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801131:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801138:	00 
  801139:	89 04 24             	mov    %eax,(%esp)
  80113c:	e8 e6 fc ff ff       	call   800e27 <sys_page_map>
  801141:	85 c0                	test   %eax,%eax
  801143:	79 20                	jns    801165 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801145:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801149:	c7 44 24 08 70 2b 80 	movl   $0x802b70,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  801160:	e8 e1 f0 ff ff       	call   800246 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801165:	e8 2b fc ff ff       	call   800d95 <sys_getenvid>
  80116a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801171:	00 
  801172:	89 04 24             	mov    %eax,(%esp)
  801175:	e8 00 fd ff ff       	call   800e7a <sys_page_unmap>
  80117a:	85 c0                	test   %eax,%eax
  80117c:	79 20                	jns    80119e <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80117e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801182:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801191:	00 
  801192:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  801199:	e8 a8 f0 ff ff       	call   800246 <_panic>
	return;
}
  80119e:	83 c4 20             	add    $0x20,%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	57                   	push   %edi
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  8011ae:	c7 04 24 3b 10 80 00 	movl   $0x80103b,(%esp)
  8011b5:	e8 9c 0f 00 00       	call   802156 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011ba:	b8 07 00 00 00       	mov    $0x7,%eax
  8011bf:	cd 30                	int    $0x30
  8011c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011c4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	79 20                	jns    8011eb <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  8011cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cf:	c7 44 24 08 d4 2b 80 	movl   $0x802bd4,0x8(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  8011de:	00 
  8011df:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8011e6:	e8 5b f0 ff ff       	call   800246 <_panic>
	if(childEid == 0){
  8011eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011ef:	75 1c                	jne    80120d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011f1:	e8 9f fb ff ff       	call   800d95 <sys_getenvid>
  8011f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801203:	a3 04 40 80 00       	mov    %eax,0x804004
		return childEid;
  801208:	e9 a0 01 00 00       	jmp    8013ad <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80120d:	c7 44 24 04 ec 21 80 	movl   $0x8021ec,0x4(%esp)
  801214:	00 
  801215:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801218:	89 04 24             	mov    %eax,(%esp)
  80121b:	e8 53 fd ff ff       	call   800f73 <sys_env_set_pgfault_upcall>
  801220:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801222:	85 c0                	test   %eax,%eax
  801224:	79 20                	jns    801246 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122a:	c7 44 24 08 08 2c 80 	movl   $0x802c08,0x8(%esp)
  801231:	00 
  801232:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801239:	00 
  80123a:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  801241:	e8 00 f0 ff ff       	call   800246 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801246:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
  801250:	b9 00 00 00 00       	mov    $0x0,%ecx
  801255:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801258:	89 c2                	mov    %eax,%edx
  80125a:	c1 ea 16             	shr    $0x16,%edx
  80125d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801264:	f6 c2 01             	test   $0x1,%dl
  801267:	0f 84 f7 00 00 00    	je     801364 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80126d:	c1 e8 0c             	shr    $0xc,%eax
  801270:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801277:	f6 c2 04             	test   $0x4,%dl
  80127a:	0f 84 e4 00 00 00    	je     801364 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801280:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801287:	a8 01                	test   $0x1,%al
  801289:	0f 84 d5 00 00 00    	je     801364 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  80128f:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801295:	75 20                	jne    8012b7 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801297:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129e:	00 
  80129f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a6:	ee 
  8012a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012aa:	89 04 24             	mov    %eax,(%esp)
  8012ad:	e8 21 fb ff ff       	call   800dd3 <sys_page_alloc>
  8012b2:	e9 84 00 00 00       	jmp    80133b <fork+0x196>
  8012b7:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  8012bd:	89 f8                	mov    %edi,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  8012c9:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  8012ce:	83 f8 01             	cmp    $0x1,%eax
  8012d1:	19 db                	sbb    %ebx,%ebx
  8012d3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8012d9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8012df:	e8 b1 fa ff ff       	call   800d95 <sys_getenvid>
  8012e4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012e8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 28 fb ff ff       	call   800e27 <sys_page_map>
  8012ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801302:	85 c0                	test   %eax,%eax
  801304:	78 35                	js     80133b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801306:	e8 8a fa ff ff       	call   800d95 <sys_getenvid>
  80130b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80130e:	e8 82 fa ff ff       	call   800d95 <sys_getenvid>
  801313:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801317:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80131e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801322:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801326:	89 04 24             	mov    %eax,(%esp)
  801329:	e8 f9 fa ff ff       	call   800e27 <sys_page_map>
  80132e:	85 c0                	test   %eax,%eax
  801330:	bf 00 00 00 00       	mov    $0x0,%edi
  801335:	0f 4f c7             	cmovg  %edi,%eax
  801338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80133b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80133f:	79 23                	jns    801364 <fork+0x1bf>
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801344:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801348:	c7 44 24 08 48 2c 80 	movl   $0x802c48,0x8(%esp)
  80134f:	00 
  801350:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801357:	00 
  801358:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  80135f:	e8 e2 ee ff ff       	call   800246 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801364:	89 f1                	mov    %esi,%ecx
  801366:	89 f0                	mov    %esi,%eax
  801368:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80136e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801374:	0f 85 de fe ff ff    	jne    801258 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80137a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801381:	00 
  801382:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 40 fb ff ff       	call   800ecd <sys_env_set_status>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	79 1c                	jns    8013ad <fork+0x208>
		panic("sys_env_set_status");
  801391:	c7 44 24 08 d6 2a 80 	movl   $0x802ad6,0x8(%esp)
  801398:	00 
  801399:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8013a0:	00 
  8013a1:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8013a8:	e8 99 ee ff ff       	call   800246 <_panic>
	return childEid;
}
  8013ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013b0:	83 c4 2c             	add    $0x2c,%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <sfork>:

// Challenge!
int
sfork(void)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013be:	c7 44 24 08 e9 2a 80 	movl   $0x802ae9,0x8(%esp)
  8013c5:	00 
  8013c6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8013cd:	00 
  8013ce:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  8013d5:	e8 6c ee ff ff       	call   800246 <_panic>
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8013fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801400:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801412:	89 c2                	mov    %eax,%edx
  801414:	c1 ea 16             	shr    $0x16,%edx
  801417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141e:	f6 c2 01             	test   $0x1,%dl
  801421:	74 11                	je     801434 <fd_alloc+0x2d>
  801423:	89 c2                	mov    %eax,%edx
  801425:	c1 ea 0c             	shr    $0xc,%edx
  801428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	75 09                	jne    80143d <fd_alloc+0x36>
			*fd_store = fd;
  801434:	89 01                	mov    %eax,(%ecx)
			return 0;
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	eb 17                	jmp    801454 <fd_alloc+0x4d>
  80143d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801442:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801447:	75 c9                	jne    801412 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801449:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80144f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80145c:	83 f8 1f             	cmp    $0x1f,%eax
  80145f:	77 36                	ja     801497 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801461:	c1 e0 0c             	shl    $0xc,%eax
  801464:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801469:	89 c2                	mov    %eax,%edx
  80146b:	c1 ea 16             	shr    $0x16,%edx
  80146e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801475:	f6 c2 01             	test   $0x1,%dl
  801478:	74 24                	je     80149e <fd_lookup+0x48>
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	c1 ea 0c             	shr    $0xc,%edx
  80147f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801486:	f6 c2 01             	test   $0x1,%dl
  801489:	74 1a                	je     8014a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80148b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148e:	89 02                	mov    %eax,(%edx)
	return 0;
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	eb 13                	jmp    8014aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149c:	eb 0c                	jmp    8014aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80149e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a3:	eb 05                	jmp    8014aa <fd_lookup+0x54>
  8014a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 18             	sub    $0x18,%esp
  8014b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b5:	ba ec 2c 80 00       	mov    $0x802cec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ba:	eb 13                	jmp    8014cf <dev_lookup+0x23>
  8014bc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014bf:	39 08                	cmp    %ecx,(%eax)
  8014c1:	75 0c                	jne    8014cf <dev_lookup+0x23>
			*dev = devtab[i];
  8014c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cd:	eb 30                	jmp    8014ff <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014cf:	8b 02                	mov    (%edx),%eax
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	75 e7                	jne    8014bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e5:	c7 04 24 70 2c 80 00 	movl   $0x802c70,(%esp)
  8014ec:	e8 4e ee ff ff       	call   80033f <cprintf>
	*dev = 0;
  8014f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 20             	sub    $0x20,%esp
  801509:	8b 75 08             	mov    0x8(%ebp),%esi
  80150c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801516:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80151c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 2f ff ff ff       	call   801456 <fd_lookup>
  801527:	85 c0                	test   %eax,%eax
  801529:	78 05                	js     801530 <fd_close+0x2f>
	    || fd != fd2)
  80152b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80152e:	74 0c                	je     80153c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801530:	84 db                	test   %bl,%bl
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	0f 44 c2             	cmove  %edx,%eax
  80153a:	eb 3f                	jmp    80157b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80153c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801543:	8b 06                	mov    (%esi),%eax
  801545:	89 04 24             	mov    %eax,(%esp)
  801548:	e8 5f ff ff ff       	call   8014ac <dev_lookup>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 16                	js     801569 <fd_close+0x68>
		if (dev->dev_close)
  801553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801556:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80155e:	85 c0                	test   %eax,%eax
  801560:	74 07                	je     801569 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801562:	89 34 24             	mov    %esi,(%esp)
  801565:	ff d0                	call   *%eax
  801567:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801574:	e8 01 f9 ff ff       	call   800e7a <sys_page_unmap>
	return r;
  801579:	89 d8                	mov    %ebx,%eax
}
  80157b:	83 c4 20             	add    $0x20,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158f:	8b 45 08             	mov    0x8(%ebp),%eax
  801592:	89 04 24             	mov    %eax,(%esp)
  801595:	e8 bc fe ff ff       	call   801456 <fd_lookup>
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	85 d2                	test   %edx,%edx
  80159e:	78 13                	js     8015b3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015a7:	00 
  8015a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ab:	89 04 24             	mov    %eax,(%esp)
  8015ae:	e8 4e ff ff ff       	call   801501 <fd_close>
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <close_all>:

void
close_all(void)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015c1:	89 1c 24             	mov    %ebx,(%esp)
  8015c4:	e8 b9 ff ff ff       	call   801582 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c9:	83 c3 01             	add    $0x1,%ebx
  8015cc:	83 fb 20             	cmp    $0x20,%ebx
  8015cf:	75 f0                	jne    8015c1 <close_all+0xc>
		close(i);
}
  8015d1:	83 c4 14             	add    $0x14,%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	e8 64 fe ff ff       	call   801456 <fd_lookup>
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	85 d2                	test   %edx,%edx
  8015f6:	0f 88 e1 00 00 00    	js     8016dd <dup+0x106>
		return r;
	close(newfdnum);
  8015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ff:	89 04 24             	mov    %eax,(%esp)
  801602:	e8 7b ff ff ff       	call   801582 <close>

	newfd = INDEX2FD(newfdnum);
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80160a:	c1 e3 0c             	shl    $0xc,%ebx
  80160d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801616:	89 04 24             	mov    %eax,(%esp)
  801619:	e8 d2 fd ff ff       	call   8013f0 <fd2data>
  80161e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801620:	89 1c 24             	mov    %ebx,(%esp)
  801623:	e8 c8 fd ff ff       	call   8013f0 <fd2data>
  801628:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80162a:	89 f0                	mov    %esi,%eax
  80162c:	c1 e8 16             	shr    $0x16,%eax
  80162f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801636:	a8 01                	test   $0x1,%al
  801638:	74 43                	je     80167d <dup+0xa6>
  80163a:	89 f0                	mov    %esi,%eax
  80163c:	c1 e8 0c             	shr    $0xc,%eax
  80163f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801646:	f6 c2 01             	test   $0x1,%dl
  801649:	74 32                	je     80167d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80164b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801652:	25 07 0e 00 00       	and    $0xe07,%eax
  801657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80165b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80165f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801666:	00 
  801667:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801672:	e8 b0 f7 ff ff       	call   800e27 <sys_page_map>
  801677:	89 c6                	mov    %eax,%esi
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 3e                	js     8016bb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80167d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801680:	89 c2                	mov    %eax,%edx
  801682:	c1 ea 0c             	shr    $0xc,%edx
  801685:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80168c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801692:	89 54 24 10          	mov    %edx,0x10(%esp)
  801696:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80169a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a1:	00 
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ad:	e8 75 f7 ff ff       	call   800e27 <sys_page_map>
  8016b2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b7:	85 f6                	test   %esi,%esi
  8016b9:	79 22                	jns    8016dd <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c6:	e8 af f7 ff ff       	call   800e7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 9f f7 ff ff       	call   800e7a <sys_page_unmap>
	return r;
  8016db:	89 f0                	mov    %esi,%eax
}
  8016dd:	83 c4 3c             	add    $0x3c,%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 24             	sub    $0x24,%esp
  8016ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f6:	89 1c 24             	mov    %ebx,(%esp)
  8016f9:	e8 58 fd ff ff       	call   801456 <fd_lookup>
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	85 d2                	test   %edx,%edx
  801702:	78 6d                	js     801771 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801704:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	8b 00                	mov    (%eax),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 94 fd ff ff       	call   8014ac <dev_lookup>
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 55                	js     801771 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80171c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171f:	8b 50 08             	mov    0x8(%eax),%edx
  801722:	83 e2 03             	and    $0x3,%edx
  801725:	83 fa 01             	cmp    $0x1,%edx
  801728:	75 23                	jne    80174d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80172a:	a1 04 40 80 00       	mov    0x804004,%eax
  80172f:	8b 40 48             	mov    0x48(%eax),%eax
  801732:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	c7 04 24 b1 2c 80 00 	movl   $0x802cb1,(%esp)
  801741:	e8 f9 eb ff ff       	call   80033f <cprintf>
		return -E_INVAL;
  801746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80174b:	eb 24                	jmp    801771 <read+0x8c>
	}
	if (!dev->dev_read)
  80174d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801750:	8b 52 08             	mov    0x8(%edx),%edx
  801753:	85 d2                	test   %edx,%edx
  801755:	74 15                	je     80176c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801757:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80175a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801761:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801765:	89 04 24             	mov    %eax,(%esp)
  801768:	ff d2                	call   *%edx
  80176a:	eb 05                	jmp    801771 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80176c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801771:	83 c4 24             	add    $0x24,%esp
  801774:	5b                   	pop    %ebx
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	57                   	push   %edi
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	83 ec 1c             	sub    $0x1c,%esp
  801780:	8b 7d 08             	mov    0x8(%ebp),%edi
  801783:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801786:	bb 00 00 00 00       	mov    $0x0,%ebx
  80178b:	eb 23                	jmp    8017b0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	29 d8                	sub    %ebx,%eax
  801791:	89 44 24 08          	mov    %eax,0x8(%esp)
  801795:	89 d8                	mov    %ebx,%eax
  801797:	03 45 0c             	add    0xc(%ebp),%eax
  80179a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179e:	89 3c 24             	mov    %edi,(%esp)
  8017a1:	e8 3f ff ff ff       	call   8016e5 <read>
		if (m < 0)
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 10                	js     8017ba <readn+0x43>
			return m;
		if (m == 0)
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	74 0a                	je     8017b8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ae:	01 c3                	add    %eax,%ebx
  8017b0:	39 f3                	cmp    %esi,%ebx
  8017b2:	72 d9                	jb     80178d <readn+0x16>
  8017b4:	89 d8                	mov    %ebx,%eax
  8017b6:	eb 02                	jmp    8017ba <readn+0x43>
  8017b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ba:	83 c4 1c             	add    $0x1c,%esp
  8017bd:	5b                   	pop    %ebx
  8017be:	5e                   	pop    %esi
  8017bf:	5f                   	pop    %edi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 24             	sub    $0x24,%esp
  8017c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	89 1c 24             	mov    %ebx,(%esp)
  8017d6:	e8 7b fc ff ff       	call   801456 <fd_lookup>
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	85 d2                	test   %edx,%edx
  8017df:	78 68                	js     801849 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017eb:	8b 00                	mov    (%eax),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 b7 fc ff ff       	call   8014ac <dev_lookup>
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 50                	js     801849 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801800:	75 23                	jne    801825 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801802:	a1 04 40 80 00       	mov    0x804004,%eax
  801807:	8b 40 48             	mov    0x48(%eax),%eax
  80180a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80180e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801812:	c7 04 24 cd 2c 80 00 	movl   $0x802ccd,(%esp)
  801819:	e8 21 eb ff ff       	call   80033f <cprintf>
		return -E_INVAL;
  80181e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801823:	eb 24                	jmp    801849 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801828:	8b 52 0c             	mov    0xc(%edx),%edx
  80182b:	85 d2                	test   %edx,%edx
  80182d:	74 15                	je     801844 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80182f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801832:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801839:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183d:	89 04 24             	mov    %eax,(%esp)
  801840:	ff d2                	call   *%edx
  801842:	eb 05                	jmp    801849 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801844:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801849:	83 c4 24             	add    $0x24,%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <seek>:

int
seek(int fdnum, off_t offset)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801855:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 ef fb ff ff       	call   801456 <fd_lookup>
  801867:	85 c0                	test   %eax,%eax
  801869:	78 0e                	js     801879 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80186b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80186e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801871:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801874:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 24             	sub    $0x24,%esp
  801882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188c:	89 1c 24             	mov    %ebx,(%esp)
  80188f:	e8 c2 fb ff ff       	call   801456 <fd_lookup>
  801894:	89 c2                	mov    %eax,%edx
  801896:	85 d2                	test   %edx,%edx
  801898:	78 61                	js     8018fb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a4:	8b 00                	mov    (%eax),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 fe fb ff ff       	call   8014ac <dev_lookup>
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 49                	js     8018fb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b9:	75 23                	jne    8018de <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018bb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c0:	8b 40 48             	mov    0x48(%eax),%eax
  8018c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  8018d2:	e8 68 ea ff ff       	call   80033f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018dc:	eb 1d                	jmp    8018fb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e1:	8b 52 18             	mov    0x18(%edx),%edx
  8018e4:	85 d2                	test   %edx,%edx
  8018e6:	74 0e                	je     8018f6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	ff d2                	call   *%edx
  8018f4:	eb 05                	jmp    8018fb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018fb:	83 c4 24             	add    $0x24,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 24             	sub    $0x24,%esp
  801908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	e8 39 fb ff ff       	call   801456 <fd_lookup>
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	85 d2                	test   %edx,%edx
  801921:	78 52                	js     801975 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192d:	8b 00                	mov    (%eax),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 75 fb ff ff       	call   8014ac <dev_lookup>
  801937:	85 c0                	test   %eax,%eax
  801939:	78 3a                	js     801975 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801942:	74 2c                	je     801970 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801944:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801947:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80194e:	00 00 00 
	stat->st_isdir = 0;
  801951:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801958:	00 00 00 
	stat->st_dev = dev;
  80195b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801965:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801968:	89 14 24             	mov    %edx,(%esp)
  80196b:	ff 50 14             	call   *0x14(%eax)
  80196e:	eb 05                	jmp    801975 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801970:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801975:	83 c4 24             	add    $0x24,%esp
  801978:	5b                   	pop    %ebx
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801983:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80198a:	00 
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	89 04 24             	mov    %eax,(%esp)
  801991:	e8 fb 01 00 00       	call   801b91 <open>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	85 db                	test   %ebx,%ebx
  80199a:	78 1b                	js     8019b7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	89 1c 24             	mov    %ebx,(%esp)
  8019a6:	e8 56 ff ff ff       	call   801901 <fstat>
  8019ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ad:	89 1c 24             	mov    %ebx,(%esp)
  8019b0:	e8 cd fb ff ff       	call   801582 <close>
	return r;
  8019b5:	89 f0                	mov    %esi,%eax
}
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 10             	sub    $0x10,%esp
  8019c6:	89 c6                	mov    %eax,%esi
  8019c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019d1:	75 11                	jne    8019e4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019da:	e8 9e 09 00 00       	call   80237d <ipc_find_env>
  8019df:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019eb:	00 
  8019ec:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019f3:	00 
  8019f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8019fd:	89 04 24             	mov    %eax,(%esp)
  801a00:	e8 c9 08 00 00       	call   8022ce <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a0c:	00 
  801a0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a18:	e8 13 08 00 00       	call   802230 <ipc_recv>
}
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a30:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a38:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a42:	b8 02 00 00 00       	mov    $0x2,%eax
  801a47:	e8 72 ff ff ff       	call   8019be <fsipc>
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a64:	b8 06 00 00 00       	mov    $0x6,%eax
  801a69:	e8 50 ff ff ff       	call   8019be <fsipc>
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	53                   	push   %ebx
  801a74:	83 ec 14             	sub    $0x14,%esp
  801a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a80:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a85:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a8f:	e8 2a ff ff ff       	call   8019be <fsipc>
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	85 d2                	test   %edx,%edx
  801a98:	78 2b                	js     801ac5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a9a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801aa1:	00 
  801aa2:	89 1c 24             	mov    %ebx,(%esp)
  801aa5:	e8 0d ef ff ff       	call   8009b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aaa:	a1 80 50 80 00       	mov    0x805080,%eax
  801aaf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ab5:	a1 84 50 80 00       	mov    0x805084,%eax
  801aba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac5:	83 c4 14             	add    $0x14,%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801ad1:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  801ad8:	00 
  801ad9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801ae0:	00 
  801ae1:	c7 04 24 1a 2d 80 00 	movl   $0x802d1a,(%esp)
  801ae8:	e8 59 e7 ff ff       	call   800246 <_panic>

00801aed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	83 ec 10             	sub    $0x10,%esp
  801af5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	8b 40 0c             	mov    0xc(%eax),%eax
  801afe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b03:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b09:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b13:	e8 a6 fe ff ff       	call   8019be <fsipc>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 6a                	js     801b88 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b1e:	39 c6                	cmp    %eax,%esi
  801b20:	73 24                	jae    801b46 <devfile_read+0x59>
  801b22:	c7 44 24 0c 25 2d 80 	movl   $0x802d25,0xc(%esp)
  801b29:	00 
  801b2a:	c7 44 24 08 2c 2d 80 	movl   $0x802d2c,0x8(%esp)
  801b31:	00 
  801b32:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b39:	00 
  801b3a:	c7 04 24 1a 2d 80 00 	movl   $0x802d1a,(%esp)
  801b41:	e8 00 e7 ff ff       	call   800246 <_panic>
	assert(r <= PGSIZE);
  801b46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4b:	7e 24                	jle    801b71 <devfile_read+0x84>
  801b4d:	c7 44 24 0c 41 2d 80 	movl   $0x802d41,0xc(%esp)
  801b54:	00 
  801b55:	c7 44 24 08 2c 2d 80 	movl   $0x802d2c,0x8(%esp)
  801b5c:	00 
  801b5d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b64:	00 
  801b65:	c7 04 24 1a 2d 80 00 	movl   $0x802d1a,(%esp)
  801b6c:	e8 d5 e6 ff ff       	call   800246 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b75:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b7c:	00 
  801b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b80:	89 04 24             	mov    %eax,(%esp)
  801b83:	e8 cc ef ff ff       	call   800b54 <memmove>
	return r;
}
  801b88:	89 d8                	mov    %ebx,%eax
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	53                   	push   %ebx
  801b95:	83 ec 24             	sub    $0x24,%esp
  801b98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b9b:	89 1c 24             	mov    %ebx,(%esp)
  801b9e:	e8 dd ed ff ff       	call   800980 <strlen>
  801ba3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba8:	7f 60                	jg     801c0a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bad:	89 04 24             	mov    %eax,(%esp)
  801bb0:	e8 52 f8 ff ff       	call   801407 <fd_alloc>
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	85 d2                	test   %edx,%edx
  801bb9:	78 54                	js     801c0f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bbf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bc6:	e8 ec ed ff ff       	call   8009b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdb:	e8 de fd ff ff       	call   8019be <fsipc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	85 c0                	test   %eax,%eax
  801be4:	79 17                	jns    801bfd <open+0x6c>
		fd_close(fd, 0);
  801be6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bed:	00 
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 08 f9 ff ff       	call   801501 <fd_close>
		return r;
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	eb 12                	jmp    801c0f <open+0x7e>
	}

	return fd2num(fd);
  801bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c00:	89 04 24             	mov    %eax,(%esp)
  801c03:	e8 d8 f7 ff ff       	call   8013e0 <fd2num>
  801c08:	eb 05                	jmp    801c0f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c0f:	83 c4 24             	add    $0x24,%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 08 00 00 00       	mov    $0x8,%eax
  801c25:	e8 94 fd ff ff       	call   8019be <fsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 10             	sub    $0x10,%esp
  801c34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	89 04 24             	mov    %eax,(%esp)
  801c3d:	e8 ae f7 ff ff       	call   8013f0 <fd2data>
  801c42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c44:	c7 44 24 04 4d 2d 80 	movl   $0x802d4d,0x4(%esp)
  801c4b:	00 
  801c4c:	89 1c 24             	mov    %ebx,(%esp)
  801c4f:	e8 63 ed ff ff       	call   8009b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c54:	8b 46 04             	mov    0x4(%esi),%eax
  801c57:	2b 06                	sub    (%esi),%eax
  801c59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c5f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c66:	00 00 00 
	stat->st_dev = &devpipe;
  801c69:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c70:	30 80 00 
	return 0;
}
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	53                   	push   %ebx
  801c83:	83 ec 14             	sub    $0x14,%esp
  801c86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c94:	e8 e1 f1 ff ff       	call   800e7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c99:	89 1c 24             	mov    %ebx,(%esp)
  801c9c:	e8 4f f7 ff ff       	call   8013f0 <fd2data>
  801ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cac:	e8 c9 f1 ff ff       	call   800e7a <sys_page_unmap>
}
  801cb1:	83 c4 14             	add    $0x14,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 2c             	sub    $0x2c,%esp
  801cc0:	89 c6                	mov    %eax,%esi
  801cc2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cc5:	a1 04 40 80 00       	mov    0x804004,%eax
  801cca:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ccd:	89 34 24             	mov    %esi,(%esp)
  801cd0:	e8 e0 06 00 00       	call   8023b5 <pageref>
  801cd5:	89 c7                	mov    %eax,%edi
  801cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cda:	89 04 24             	mov    %eax,(%esp)
  801cdd:	e8 d3 06 00 00       	call   8023b5 <pageref>
  801ce2:	39 c7                	cmp    %eax,%edi
  801ce4:	0f 94 c2             	sete   %dl
  801ce7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801cea:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801cf0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801cf3:	39 fb                	cmp    %edi,%ebx
  801cf5:	74 21                	je     801d18 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cf7:	84 d2                	test   %dl,%dl
  801cf9:	74 ca                	je     801cc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cfb:	8b 51 58             	mov    0x58(%ecx),%edx
  801cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d02:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d0a:	c7 04 24 54 2d 80 00 	movl   $0x802d54,(%esp)
  801d11:	e8 29 e6 ff ff       	call   80033f <cprintf>
  801d16:	eb ad                	jmp    801cc5 <_pipeisclosed+0xe>
	}
}
  801d18:	83 c4 2c             	add    $0x2c,%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	57                   	push   %edi
  801d24:	56                   	push   %esi
  801d25:	53                   	push   %ebx
  801d26:	83 ec 1c             	sub    $0x1c,%esp
  801d29:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d2c:	89 34 24             	mov    %esi,(%esp)
  801d2f:	e8 bc f6 ff ff       	call   8013f0 <fd2data>
  801d34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d36:	bf 00 00 00 00       	mov    $0x0,%edi
  801d3b:	eb 45                	jmp    801d82 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d3d:	89 da                	mov    %ebx,%edx
  801d3f:	89 f0                	mov    %esi,%eax
  801d41:	e8 71 ff ff ff       	call   801cb7 <_pipeisclosed>
  801d46:	85 c0                	test   %eax,%eax
  801d48:	75 41                	jne    801d8b <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d4a:	e8 65 f0 ff ff       	call   800db4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d4f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d52:	8b 0b                	mov    (%ebx),%ecx
  801d54:	8d 51 20             	lea    0x20(%ecx),%edx
  801d57:	39 d0                	cmp    %edx,%eax
  801d59:	73 e2                	jae    801d3d <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d62:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d65:	99                   	cltd   
  801d66:	c1 ea 1b             	shr    $0x1b,%edx
  801d69:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d6c:	83 e1 1f             	and    $0x1f,%ecx
  801d6f:	29 d1                	sub    %edx,%ecx
  801d71:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801d75:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801d79:	83 c0 01             	add    $0x1,%eax
  801d7c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	83 c7 01             	add    $0x1,%edi
  801d82:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d85:	75 c8                	jne    801d4f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d87:	89 f8                	mov    %edi,%eax
  801d89:	eb 05                	jmp    801d90 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	57                   	push   %edi
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	83 ec 1c             	sub    $0x1c,%esp
  801da1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801da4:	89 3c 24             	mov    %edi,(%esp)
  801da7:	e8 44 f6 ff ff       	call   8013f0 <fd2data>
  801dac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dae:	be 00 00 00 00       	mov    $0x0,%esi
  801db3:	eb 3d                	jmp    801df2 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801db5:	85 f6                	test   %esi,%esi
  801db7:	74 04                	je     801dbd <devpipe_read+0x25>
				return i;
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	eb 43                	jmp    801e00 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dbd:	89 da                	mov    %ebx,%edx
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	e8 f1 fe ff ff       	call   801cb7 <_pipeisclosed>
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	75 31                	jne    801dfb <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dca:	e8 e5 ef ff ff       	call   800db4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dcf:	8b 03                	mov    (%ebx),%eax
  801dd1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dd4:	74 df                	je     801db5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd6:	99                   	cltd   
  801dd7:	c1 ea 1b             	shr    $0x1b,%edx
  801dda:	01 d0                	add    %edx,%eax
  801ddc:	83 e0 1f             	and    $0x1f,%eax
  801ddf:	29 d0                	sub    %edx,%eax
  801de1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dec:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801def:	83 c6 01             	add    $0x1,%esi
  801df2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df5:	75 d8                	jne    801dcf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df7:	89 f0                	mov    %esi,%eax
  801df9:	eb 05                	jmp    801e00 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e13:	89 04 24             	mov    %eax,(%esp)
  801e16:	e8 ec f5 ff ff       	call   801407 <fd_alloc>
  801e1b:	89 c2                	mov    %eax,%edx
  801e1d:	85 d2                	test   %edx,%edx
  801e1f:	0f 88 4d 01 00 00    	js     801f72 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e25:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e2c:	00 
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3b:	e8 93 ef ff ff       	call   800dd3 <sys_page_alloc>
  801e40:	89 c2                	mov    %eax,%edx
  801e42:	85 d2                	test   %edx,%edx
  801e44:	0f 88 28 01 00 00    	js     801f72 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e4d:	89 04 24             	mov    %eax,(%esp)
  801e50:	e8 b2 f5 ff ff       	call   801407 <fd_alloc>
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	85 c0                	test   %eax,%eax
  801e59:	0f 88 fe 00 00 00    	js     801f5d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e66:	00 
  801e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e75:	e8 59 ef ff ff       	call   800dd3 <sys_page_alloc>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	0f 88 d9 00 00 00    	js     801f5d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e87:	89 04 24             	mov    %eax,(%esp)
  801e8a:	e8 61 f5 ff ff       	call   8013f0 <fd2data>
  801e8f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e91:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e98:	00 
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea4:	e8 2a ef ff ff       	call   800dd3 <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	0f 88 97 00 00 00    	js     801f4a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 32 f5 ff ff       	call   8013f0 <fd2data>
  801ebe:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ec5:	00 
  801ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed1:	00 
  801ed2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edd:	e8 45 ef ff ff       	call   800e27 <sys_page_map>
  801ee2:	89 c3                	mov    %eax,%ebx
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 52                	js     801f3a <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ee8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801efd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	89 04 24             	mov    %eax,(%esp)
  801f18:	e8 c3 f4 ff ff       	call   8013e0 <fd2num>
  801f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f25:	89 04 24             	mov    %eax,(%esp)
  801f28:	e8 b3 f4 ff ff       	call   8013e0 <fd2num>
  801f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	eb 38                	jmp    801f72 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801f3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f45:	e8 30 ef ff ff       	call   800e7a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f58:	e8 1d ef ff ff       	call   800e7a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6b:	e8 0a ef ff ff       	call   800e7a <sys_page_unmap>
  801f70:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801f72:	83 c4 30             	add    $0x30,%esp
  801f75:	5b                   	pop    %ebx
  801f76:	5e                   	pop    %esi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	89 04 24             	mov    %eax,(%esp)
  801f8c:	e8 c5 f4 ff ff       	call   801456 <fd_lookup>
  801f91:	89 c2                	mov    %eax,%edx
  801f93:	85 d2                	test   %edx,%edx
  801f95:	78 15                	js     801fac <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 4e f4 ff ff       	call   8013f0 <fd2data>
	return _pipeisclosed(fd, p);
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa7:	e8 0b fd ff ff       	call   801cb7 <_pipeisclosed>
}
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fc0:	c7 44 24 04 6c 2d 80 	movl   $0x802d6c,0x4(%esp)
  801fc7:	00 
  801fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcb:	89 04 24             	mov    %eax,(%esp)
  801fce:	e8 e4 e9 ff ff       	call   8009b7 <strcpy>
	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	57                   	push   %edi
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801feb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff1:	eb 31                	jmp    802024 <devcons_write+0x4a>
		m = n - tot;
  801ff3:	8b 75 10             	mov    0x10(%ebp),%esi
  801ff6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801ff8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ffb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802000:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802003:	89 74 24 08          	mov    %esi,0x8(%esp)
  802007:	03 45 0c             	add    0xc(%ebp),%eax
  80200a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200e:	89 3c 24             	mov    %edi,(%esp)
  802011:	e8 3e eb ff ff       	call   800b54 <memmove>
		sys_cputs(buf, m);
  802016:	89 74 24 04          	mov    %esi,0x4(%esp)
  80201a:	89 3c 24             	mov    %edi,(%esp)
  80201d:	e8 e4 ec ff ff       	call   800d06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802022:	01 f3                	add    %esi,%ebx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802029:	72 c8                	jb     801ff3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80202b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802041:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802045:	75 07                	jne    80204e <devcons_read+0x18>
  802047:	eb 2a                	jmp    802073 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802049:	e8 66 ed ff ff       	call   800db4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80204e:	66 90                	xchg   %ax,%ax
  802050:	e8 cf ec ff ff       	call   800d24 <sys_cgetc>
  802055:	85 c0                	test   %eax,%eax
  802057:	74 f0                	je     802049 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 16                	js     802073 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80205d:	83 f8 04             	cmp    $0x4,%eax
  802060:	74 0c                	je     80206e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802062:	8b 55 0c             	mov    0xc(%ebp),%edx
  802065:	88 02                	mov    %al,(%edx)
	return 1;
  802067:	b8 01 00 00 00       	mov    $0x1,%eax
  80206c:	eb 05                	jmp    802073 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802081:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802088:	00 
  802089:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 72 ec ff ff       	call   800d06 <sys_cputs>
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <getchar>:

int
getchar(void)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80209c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020a3:	00 
  8020a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b2:	e8 2e f6 ff ff       	call   8016e5 <read>
	if (r < 0)
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	78 0f                	js     8020ca <getchar+0x34>
		return r;
	if (r < 1)
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	7e 06                	jle    8020c5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020c3:	eb 05                	jmp    8020ca <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020dc:	89 04 24             	mov    %eax,(%esp)
  8020df:	e8 72 f3 ff ff       	call   801456 <fd_lookup>
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 11                	js     8020f9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f1:	39 10                	cmp    %edx,(%eax)
  8020f3:	0f 94 c0             	sete   %al
  8020f6:	0f b6 c0             	movzbl %al,%eax
}
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    

008020fb <opencons>:

int
opencons(void)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802104:	89 04 24             	mov    %eax,(%esp)
  802107:	e8 fb f2 ff ff       	call   801407 <fd_alloc>
		return r;
  80210c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 40                	js     802152 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802112:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802119:	00 
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802128:	e8 a6 ec ff ff       	call   800dd3 <sys_page_alloc>
		return r;
  80212d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80212f:	85 c0                	test   %eax,%eax
  802131:	78 1f                	js     802152 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802133:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802148:	89 04 24             	mov    %eax,(%esp)
  80214b:	e8 90 f2 ff ff       	call   8013e0 <fd2num>
  802150:	89 c2                	mov    %eax,%edx
}
  802152:	89 d0                	mov    %edx,%eax
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80215c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802163:	75 44                	jne    8021a9 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  802165:	a1 04 40 80 00       	mov    0x804004,%eax
  80216a:	8b 40 48             	mov    0x48(%eax),%eax
  80216d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802174:	00 
  802175:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80217c:	ee 
  80217d:	89 04 24             	mov    %eax,(%esp)
  802180:	e8 4e ec ff ff       	call   800dd3 <sys_page_alloc>
		if( r < 0)
  802185:	85 c0                	test   %eax,%eax
  802187:	79 20                	jns    8021a9 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  802189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218d:	c7 44 24 08 78 2d 80 	movl   $0x802d78,0x8(%esp)
  802194:	00 
  802195:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80219c:	00 
  80219d:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  8021a4:	e8 9d e0 ff ff       	call   800246 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ac:	a3 00 60 80 00       	mov    %eax,0x806000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8021b1:	e8 df eb ff ff       	call   800d95 <sys_getenvid>
  8021b6:	c7 44 24 04 ec 21 80 	movl   $0x8021ec,0x4(%esp)
  8021bd:	00 
  8021be:	89 04 24             	mov    %eax,(%esp)
  8021c1:	e8 ad ed ff ff       	call   800f73 <sys_env_set_pgfault_upcall>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	79 20                	jns    8021ea <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8021ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ce:	c7 44 24 08 a8 2d 80 	movl   $0x802da8,0x8(%esp)
  8021d5:	00 
  8021d6:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8021dd:	00 
  8021de:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  8021e5:	e8 5c e0 ff ff       	call   800246 <_panic>


}
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021ed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f4:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8021f7:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8021fb:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8021ff:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  802203:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  802206:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  802209:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  80220c:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  802210:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  802214:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  802218:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  80221c:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  802220:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  802224:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  802228:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  802229:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  80222a:	c3                   	ret    
  80222b:	66 90                	xchg   %ax,%ax
  80222d:	66 90                	xchg   %ax,%ax
  80222f:	90                   	nop

00802230 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 10             	sub    $0x10,%esp
  802238:	8b 75 08             	mov    0x8(%ebp),%esi
  80223b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802241:	85 c0                	test   %eax,%eax
  802243:	75 0e                	jne    802253 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802245:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80224c:	e8 98 ed ff ff       	call   800fe9 <sys_ipc_recv>
  802251:	eb 08                	jmp    80225b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802253:	89 04 24             	mov    %eax,(%esp)
  802256:	e8 8e ed ff ff       	call   800fe9 <sys_ipc_recv>
	if(r == 0){
  80225b:	85 c0                	test   %eax,%eax
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	75 1e                	jne    802280 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802262:	85 f6                	test   %esi,%esi
  802264:	74 0a                	je     802270 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802266:	a1 04 40 80 00       	mov    0x804004,%eax
  80226b:	8b 40 74             	mov    0x74(%eax),%eax
  80226e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802270:	85 db                	test   %ebx,%ebx
  802272:	74 2c                	je     8022a0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802274:	a1 04 40 80 00       	mov    0x804004,%eax
  802279:	8b 40 78             	mov    0x78(%eax),%eax
  80227c:	89 03                	mov    %eax,(%ebx)
  80227e:	eb 20                	jmp    8022a0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802280:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802284:	c7 44 24 08 e4 2d 80 	movl   $0x802de4,0x8(%esp)
  80228b:	00 
  80228c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802293:	00 
  802294:	c7 04 24 60 2e 80 00 	movl   $0x802e60,(%esp)
  80229b:	e8 a6 df ff ff       	call   800246 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8022a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8022a5:	8b 50 70             	mov    0x70(%eax),%edx
  8022a8:	85 d2                	test   %edx,%edx
  8022aa:	75 13                	jne    8022bf <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8022ac:	8b 40 48             	mov    0x48(%eax),%eax
  8022af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b3:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  8022ba:	e8 80 e0 ff ff       	call   80033f <cprintf>
	return thisenv->env_ipc_value;
  8022bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8022c4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	5b                   	pop    %ebx
  8022cb:	5e                   	pop    %esi
  8022cc:	5d                   	pop    %ebp
  8022cd:	c3                   	ret    

008022ce <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022da:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8022dd:	85 f6                	test   %esi,%esi
  8022df:	75 22                	jne    802303 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8022e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8022e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022e8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8022ef:	ee 
  8022f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f7:	89 3c 24             	mov    %edi,(%esp)
  8022fa:	e8 c7 ec ff ff       	call   800fc6 <sys_ipc_try_send>
  8022ff:	89 c3                	mov    %eax,%ebx
  802301:	eb 1c                	jmp    80231f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802303:	8b 45 14             	mov    0x14(%ebp),%eax
  802306:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80230e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802311:	89 44 24 04          	mov    %eax,0x4(%esp)
  802315:	89 3c 24             	mov    %edi,(%esp)
  802318:	e8 a9 ec ff ff       	call   800fc6 <sys_ipc_try_send>
  80231d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80231f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802322:	74 3e                	je     802362 <ipc_send+0x94>
  802324:	89 d8                	mov    %ebx,%eax
  802326:	c1 e8 1f             	shr    $0x1f,%eax
  802329:	84 c0                	test   %al,%al
  80232b:	74 35                	je     802362 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80232d:	e8 63 ea ff ff       	call   800d95 <sys_getenvid>
  802332:	89 44 24 04          	mov    %eax,0x4(%esp)
  802336:	c7 04 24 6a 2e 80 00 	movl   $0x802e6a,(%esp)
  80233d:	e8 fd df ff ff       	call   80033f <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802342:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802346:	c7 44 24 08 38 2e 80 	movl   $0x802e38,0x8(%esp)
  80234d:	00 
  80234e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802355:	00 
  802356:	c7 04 24 60 2e 80 00 	movl   $0x802e60,(%esp)
  80235d:	e8 e4 de ff ff       	call   800246 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802362:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802365:	75 0e                	jne    802375 <ipc_send+0xa7>
			sys_yield();
  802367:	e8 48 ea ff ff       	call   800db4 <sys_yield>
		else break;
	}
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	e9 68 ff ff ff       	jmp    8022dd <ipc_send+0xf>
	
}
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    

0080237d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802383:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802388:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80238b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802391:	8b 52 50             	mov    0x50(%edx),%edx
  802394:	39 ca                	cmp    %ecx,%edx
  802396:	75 0d                	jne    8023a5 <ipc_find_env+0x28>
			return envs[i].env_id;
  802398:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80239b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8023a0:	8b 40 40             	mov    0x40(%eax),%eax
  8023a3:	eb 0e                	jmp    8023b3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023a5:	83 c0 01             	add    $0x1,%eax
  8023a8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ad:	75 d9                	jne    802388 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023af:	66 b8 00 00          	mov    $0x0,%ax
}
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    

008023b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	c1 e8 16             	shr    $0x16,%eax
  8023c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023cc:	f6 c1 01             	test   $0x1,%cl
  8023cf:	74 1d                	je     8023ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023d1:	c1 ea 0c             	shr    $0xc,%edx
  8023d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023db:	f6 c2 01             	test   $0x1,%dl
  8023de:	74 0e                	je     8023ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023e0:	c1 ea 0c             	shr    $0xc,%edx
  8023e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023ea:	ef 
  8023eb:	0f b7 c0             	movzwl %ax,%eax
}
  8023ee:	5d                   	pop    %ebp
  8023ef:	c3                   	ret    

008023f0 <__udivdi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	83 ec 0c             	sub    $0xc,%esp
  8023f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802402:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802406:	85 c0                	test   %eax,%eax
  802408:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80240c:	89 ea                	mov    %ebp,%edx
  80240e:	89 0c 24             	mov    %ecx,(%esp)
  802411:	75 2d                	jne    802440 <__udivdi3+0x50>
  802413:	39 e9                	cmp    %ebp,%ecx
  802415:	77 61                	ja     802478 <__udivdi3+0x88>
  802417:	85 c9                	test   %ecx,%ecx
  802419:	89 ce                	mov    %ecx,%esi
  80241b:	75 0b                	jne    802428 <__udivdi3+0x38>
  80241d:	b8 01 00 00 00       	mov    $0x1,%eax
  802422:	31 d2                	xor    %edx,%edx
  802424:	f7 f1                	div    %ecx
  802426:	89 c6                	mov    %eax,%esi
  802428:	31 d2                	xor    %edx,%edx
  80242a:	89 e8                	mov    %ebp,%eax
  80242c:	f7 f6                	div    %esi
  80242e:	89 c5                	mov    %eax,%ebp
  802430:	89 f8                	mov    %edi,%eax
  802432:	f7 f6                	div    %esi
  802434:	89 ea                	mov    %ebp,%edx
  802436:	83 c4 0c             	add    $0xc,%esp
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	39 e8                	cmp    %ebp,%eax
  802442:	77 24                	ja     802468 <__udivdi3+0x78>
  802444:	0f bd e8             	bsr    %eax,%ebp
  802447:	83 f5 1f             	xor    $0x1f,%ebp
  80244a:	75 3c                	jne    802488 <__udivdi3+0x98>
  80244c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802450:	39 34 24             	cmp    %esi,(%esp)
  802453:	0f 86 9f 00 00 00    	jbe    8024f8 <__udivdi3+0x108>
  802459:	39 d0                	cmp    %edx,%eax
  80245b:	0f 82 97 00 00 00    	jb     8024f8 <__udivdi3+0x108>
  802461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	31 c0                	xor    %eax,%eax
  80246c:	83 c4 0c             	add    $0xc,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	89 f8                	mov    %edi,%eax
  80247a:	f7 f1                	div    %ecx
  80247c:	31 d2                	xor    %edx,%edx
  80247e:	83 c4 0c             	add    $0xc,%esp
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	8b 3c 24             	mov    (%esp),%edi
  80248d:	d3 e0                	shl    %cl,%eax
  80248f:	89 c6                	mov    %eax,%esi
  802491:	b8 20 00 00 00       	mov    $0x20,%eax
  802496:	29 e8                	sub    %ebp,%eax
  802498:	89 c1                	mov    %eax,%ecx
  80249a:	d3 ef                	shr    %cl,%edi
  80249c:	89 e9                	mov    %ebp,%ecx
  80249e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8024a2:	8b 3c 24             	mov    (%esp),%edi
  8024a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8024a9:	89 d6                	mov    %edx,%esi
  8024ab:	d3 e7                	shl    %cl,%edi
  8024ad:	89 c1                	mov    %eax,%ecx
  8024af:	89 3c 24             	mov    %edi,(%esp)
  8024b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b6:	d3 ee                	shr    %cl,%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	d3 e2                	shl    %cl,%edx
  8024bc:	89 c1                	mov    %eax,%ecx
  8024be:	d3 ef                	shr    %cl,%edi
  8024c0:	09 d7                	or     %edx,%edi
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	89 f8                	mov    %edi,%eax
  8024c6:	f7 74 24 08          	divl   0x8(%esp)
  8024ca:	89 d6                	mov    %edx,%esi
  8024cc:	89 c7                	mov    %eax,%edi
  8024ce:	f7 24 24             	mull   (%esp)
  8024d1:	39 d6                	cmp    %edx,%esi
  8024d3:	89 14 24             	mov    %edx,(%esp)
  8024d6:	72 30                	jb     802508 <__udivdi3+0x118>
  8024d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024dc:	89 e9                	mov    %ebp,%ecx
  8024de:	d3 e2                	shl    %cl,%edx
  8024e0:	39 c2                	cmp    %eax,%edx
  8024e2:	73 05                	jae    8024e9 <__udivdi3+0xf9>
  8024e4:	3b 34 24             	cmp    (%esp),%esi
  8024e7:	74 1f                	je     802508 <__udivdi3+0x118>
  8024e9:	89 f8                	mov    %edi,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	e9 7a ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ff:	e9 68 ff ff ff       	jmp    80246c <__udivdi3+0x7c>
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	8d 47 ff             	lea    -0x1(%edi),%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	83 c4 0c             	add    $0xc,%esp
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	66 90                	xchg   %ax,%ax
  802516:	66 90                	xchg   %ax,%ax
  802518:	66 90                	xchg   %ax,%ax
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	83 ec 14             	sub    $0x14,%esp
  802526:	8b 44 24 28          	mov    0x28(%esp),%eax
  80252a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80252e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802532:	89 c7                	mov    %eax,%edi
  802534:	89 44 24 04          	mov    %eax,0x4(%esp)
  802538:	8b 44 24 30          	mov    0x30(%esp),%eax
  80253c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802540:	89 34 24             	mov    %esi,(%esp)
  802543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802547:	85 c0                	test   %eax,%eax
  802549:	89 c2                	mov    %eax,%edx
  80254b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80254f:	75 17                	jne    802568 <__umoddi3+0x48>
  802551:	39 fe                	cmp    %edi,%esi
  802553:	76 4b                	jbe    8025a0 <__umoddi3+0x80>
  802555:	89 c8                	mov    %ecx,%eax
  802557:	89 fa                	mov    %edi,%edx
  802559:	f7 f6                	div    %esi
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	83 c4 14             	add    $0x14,%esp
  802562:	5e                   	pop    %esi
  802563:	5f                   	pop    %edi
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    
  802566:	66 90                	xchg   %ax,%ax
  802568:	39 f8                	cmp    %edi,%eax
  80256a:	77 54                	ja     8025c0 <__umoddi3+0xa0>
  80256c:	0f bd e8             	bsr    %eax,%ebp
  80256f:	83 f5 1f             	xor    $0x1f,%ebp
  802572:	75 5c                	jne    8025d0 <__umoddi3+0xb0>
  802574:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802578:	39 3c 24             	cmp    %edi,(%esp)
  80257b:	0f 87 e7 00 00 00    	ja     802668 <__umoddi3+0x148>
  802581:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802585:	29 f1                	sub    %esi,%ecx
  802587:	19 c7                	sbb    %eax,%edi
  802589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802591:	8b 44 24 08          	mov    0x8(%esp),%eax
  802595:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802599:	83 c4 14             	add    $0x14,%esp
  80259c:	5e                   	pop    %esi
  80259d:	5f                   	pop    %edi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    
  8025a0:	85 f6                	test   %esi,%esi
  8025a2:	89 f5                	mov    %esi,%ebp
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f6                	div    %esi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f5                	div    %ebp
  8025b9:	89 c8                	mov    %ecx,%eax
  8025bb:	f7 f5                	div    %ebp
  8025bd:	eb 9c                	jmp    80255b <__umoddi3+0x3b>
  8025bf:	90                   	nop
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 fa                	mov    %edi,%edx
  8025c4:	83 c4 14             	add    $0x14,%esp
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
  8025cb:	90                   	nop
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	8b 04 24             	mov    (%esp),%eax
  8025d3:	be 20 00 00 00       	mov    $0x20,%esi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	29 ee                	sub    %ebp,%esi
  8025dc:	d3 e2                	shl    %cl,%edx
  8025de:	89 f1                	mov    %esi,%ecx
  8025e0:	d3 e8                	shr    %cl,%eax
  8025e2:	89 e9                	mov    %ebp,%ecx
  8025e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e8:	8b 04 24             	mov    (%esp),%eax
  8025eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	d3 e0                	shl    %cl,%eax
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025fd:	d3 ea                	shr    %cl,%edx
  8025ff:	89 e9                	mov    %ebp,%ecx
  802601:	d3 e7                	shl    %cl,%edi
  802603:	89 f1                	mov    %esi,%ecx
  802605:	d3 e8                	shr    %cl,%eax
  802607:	89 e9                	mov    %ebp,%ecx
  802609:	09 f8                	or     %edi,%eax
  80260b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80260f:	f7 74 24 04          	divl   0x4(%esp)
  802613:	d3 e7                	shl    %cl,%edi
  802615:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802619:	89 d7                	mov    %edx,%edi
  80261b:	f7 64 24 08          	mull   0x8(%esp)
  80261f:	39 d7                	cmp    %edx,%edi
  802621:	89 c1                	mov    %eax,%ecx
  802623:	89 14 24             	mov    %edx,(%esp)
  802626:	72 2c                	jb     802654 <__umoddi3+0x134>
  802628:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80262c:	72 22                	jb     802650 <__umoddi3+0x130>
  80262e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802632:	29 c8                	sub    %ecx,%eax
  802634:	19 d7                	sbb    %edx,%edi
  802636:	89 e9                	mov    %ebp,%ecx
  802638:	89 fa                	mov    %edi,%edx
  80263a:	d3 e8                	shr    %cl,%eax
  80263c:	89 f1                	mov    %esi,%ecx
  80263e:	d3 e2                	shl    %cl,%edx
  802640:	89 e9                	mov    %ebp,%ecx
  802642:	d3 ef                	shr    %cl,%edi
  802644:	09 d0                	or     %edx,%eax
  802646:	89 fa                	mov    %edi,%edx
  802648:	83 c4 14             	add    $0x14,%esp
  80264b:	5e                   	pop    %esi
  80264c:	5f                   	pop    %edi
  80264d:	5d                   	pop    %ebp
  80264e:	c3                   	ret    
  80264f:	90                   	nop
  802650:	39 d7                	cmp    %edx,%edi
  802652:	75 da                	jne    80262e <__umoddi3+0x10e>
  802654:	8b 14 24             	mov    (%esp),%edx
  802657:	89 c1                	mov    %eax,%ecx
  802659:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80265d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802661:	eb cb                	jmp    80262e <__umoddi3+0x10e>
  802663:	90                   	nop
  802664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802668:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80266c:	0f 82 0f ff ff ff    	jb     802581 <__umoddi3+0x61>
  802672:	e9 1a ff ff ff       	jmp    802591 <__umoddi3+0x71>
