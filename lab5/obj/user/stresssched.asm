
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
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

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 68 0c 00 00       	call   800cb5 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 6c 10 00 00       	call   8010c5 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 16                	jmp    80007d <umain+0x3d>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 11                	je     80007d <umain+0x3d>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800075:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007b:	eb 0c                	jmp    800089 <umain+0x49>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007d:	e8 52 0c 00 00       	call   800cd4 <sys_yield>
		return;
  800082:	e9 83 00 00 00       	jmp    80010a <umain+0xca>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800087:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800089:	8b 42 50             	mov    0x50(%edx),%eax
  80008c:	85 c0                	test   %eax,%eax
  80008e:	66 90                	xchg   %ax,%ax
  800090:	75 f5                	jne    800087 <umain+0x47>
  800092:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800097:	e8 38 0c 00 00       	call   800cd4 <sys_yield>
  80009c:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a1:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a7:	83 c2 01             	add    $0x1,%edx
  8000aa:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b0:	83 e8 01             	sub    $0x1,%eax
  8000b3:	75 ec                	jne    8000a1 <umain+0x61>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000b5:	83 eb 01             	sub    $0x1,%ebx
  8000b8:	75 dd                	jne    800097 <umain+0x57>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000ba:	a1 04 20 80 00       	mov    0x802004,%eax
  8000bf:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c4:	74 25                	je     8000eb <umain+0xab>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000c6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cf:	c7 44 24 08 60 16 80 	movl   $0x801660,0x8(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000de:	00 
  8000df:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  8000e6:	e8 82 00 00 00       	call   80016d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000eb:	a1 08 20 80 00       	mov    0x802008,%eax
  8000f0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000f3:	8b 40 48             	mov    0x48(%eax),%eax
  8000f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fe:	c7 04 24 9b 16 80 00 	movl   $0x80169b,(%esp)
  800105:	e8 5c 01 00 00       	call   800266 <cprintf>

}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	83 ec 10             	sub    $0x10,%esp
  800119:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80011c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  80011f:	e8 91 0b 00 00       	call   800cb5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800124:	25 ff 03 00 00       	and    $0x3ff,%eax
  800129:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x30>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	e8 f3 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80014d:	e8 07 00 00 00       	call   800159 <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 f8 0a 00 00       	call   800c63 <sys_env_destroy>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800175:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800178:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80017e:	e8 32 0b 00 00       	call   800cb5 <sys_getenvid>
  800183:	8b 55 0c             	mov    0xc(%ebp),%edx
  800186:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800191:	89 74 24 08          	mov    %esi,0x8(%esp)
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 c4 16 80 00 	movl   $0x8016c4,(%esp)
  8001a0:	e8 c1 00 00 00       	call   800266 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 51 00 00 00       	call   800205 <vcprintf>
	cprintf("\n");
  8001b4:	c7 04 24 b7 16 80 00 	movl   $0x8016b7,(%esp)
  8001bb:	e8 a6 00 00 00       	call   800266 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c0:	cc                   	int3   
  8001c1:	eb fd                	jmp    8001c0 <_panic+0x53>

008001c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 14             	sub    $0x14,%esp
  8001ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001cd:	8b 13                	mov    (%ebx),%edx
  8001cf:	8d 42 01             	lea    0x1(%edx),%eax
  8001d2:	89 03                	mov    %eax,(%ebx)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e0:	75 19                	jne    8001fb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e9:	00 
  8001ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 31 0a 00 00       	call   800c26 <sys_cputs>
		b->idx = 0;
  8001f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ff:	83 c4 14             	add    $0x14,%esp
  800202:	5b                   	pop    %ebx
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    

00800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800215:	00 00 00 
	b.cnt = 0;
  800218:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	c7 04 24 c3 01 80 00 	movl   $0x8001c3,(%esp)
  800241:	e8 6e 01 00 00       	call   8003b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800246:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 c8 09 00 00       	call   800c26 <sys_cputs>

	return b.cnt;
}
  80025e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	e8 87 ff ff ff       	call   800205 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 c3                	mov    %eax,%ebx
  800299:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ad:	39 d9                	cmp    %ebx,%ecx
  8002af:	72 05                	jb     8002b6 <printnum+0x36>
  8002b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bd:	83 ee 01             	sub    $0x1,%esi
  8002c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	89 d6                	mov    %edx,%esi
  8002d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 dc 10 00 00       	call   8013d0 <__udivdi3>
  8002f4:	89 d9                	mov    %ebx,%ecx
  8002f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 71 ff ff ff       	call   800280 <printnum>
  80030f:	eb 1b                	jmp    80032c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	8b 45 18             	mov    0x18(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff d3                	call   *%ebx
  80031d:	eb 03                	jmp    800322 <printnum+0xa2>
  80031f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800322:	83 ee 01             	sub    $0x1,%esi
  800325:	85 f6                	test   %esi,%esi
  800327:	7f e8                	jg     800311 <printnum+0x91>
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 ac 11 00 00       	call   801500 <__umoddi3>
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	0f be 80 e7 16 80 00 	movsbl 0x8016e7(%eax),%eax
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800365:	ff d0                	call   *%eax
}
  800367:	83 c4 3c             	add    $0x3c,%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800375:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 0a                	jae    80038a <sprintputch+0x1b>
		*b->buf++ = ch;
  800380:	8d 4a 01             	lea    0x1(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	88 02                	mov    %al,(%edx)
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800392:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800399:	8b 45 10             	mov    0x10(%ebp),%eax
  80039c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	e8 02 00 00 00       	call   8003b4 <vprintfmt>
	va_end(ap);
}
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 3c             	sub    $0x3c,%esp
  8003bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c6:	eb 11                	jmp    8003d9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	0f 84 48 04 00 00    	je     800818 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d9:	83 c7 01             	add    $0x1,%edi
  8003dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e0:	83 f8 25             	cmp    $0x25,%eax
  8003e3:	75 e3                	jne    8003c8 <vprintfmt+0x14>
  8003e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800403:	eb 1f                	jmp    800424 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800408:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80040c:	eb 16                	jmp    800424 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800411:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800415:	eb 0d                	jmp    800424 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800417:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8d 47 01             	lea    0x1(%edi),%eax
  800427:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042a:	0f b6 17             	movzbl (%edi),%edx
  80042d:	0f b6 c2             	movzbl %dl,%eax
  800430:	83 ea 23             	sub    $0x23,%edx
  800433:	80 fa 55             	cmp    $0x55,%dl
  800436:	0f 87 bf 03 00 00    	ja     8007fb <vprintfmt+0x447>
  80043c:	0f b6 d2             	movzbl %dl,%edx
  80043f:	ff 24 95 20 18 80 00 	jmp    *0x801820(,%edx,4)
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800454:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800458:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80045b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80045e:	83 f9 09             	cmp    $0x9,%ecx
  800461:	77 3c                	ja     80049f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 40 04             	lea    0x4(%eax),%eax
  800476:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047c:	eb 27                	jmp    8004a5 <vprintfmt+0xf1>
  80047e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800481:	85 d2                	test   %edx,%edx
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	0f 49 c2             	cmovns %edx,%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800491:	eb 91                	jmp    800424 <vprintfmt+0x70>
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049d:	eb 85                	jmp    800424 <vprintfmt+0x70>
  80049f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004a2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	0f 89 75 ff ff ff    	jns    800424 <vprintfmt+0x70>
  8004af:	e9 63 ff ff ff       	jmp    800417 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ba:	e9 65 ff ff ff       	jmp    800424 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d4:	e9 00 ff ff ff       	jmp    8003d9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004dc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	99                   	cltd   
  8004e3:	31 d0                	xor    %edx,%eax
  8004e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e7:	83 f8 0f             	cmp    $0xf,%eax
  8004ea:	7f 0b                	jg     8004f7 <vprintfmt+0x143>
  8004ec:	8b 14 85 80 19 80 00 	mov    0x801980(,%eax,4),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	75 20                	jne    800517 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fb:	c7 44 24 08 ff 16 80 	movl   $0x8016ff,0x8(%esp)
  800502:	00 
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	89 34 24             	mov    %esi,(%esp)
  80050a:	e8 7d fe ff ff       	call   80038c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800512:	e9 c2 fe ff ff       	jmp    8003d9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800517:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051b:	c7 44 24 08 08 17 80 	movl   $0x801708,0x8(%esp)
  800522:	00 
  800523:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800527:	89 34 24             	mov    %esi,(%esp)
  80052a:	e8 5d fe ff ff       	call   80038c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800532:	e9 a2 fe ff ff       	jmp    8003d9 <vprintfmt+0x25>
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80053d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800540:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800547:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800549:	85 ff                	test   %edi,%edi
  80054b:	b8 f8 16 80 00       	mov    $0x8016f8,%eax
  800550:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800553:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800557:	0f 84 92 00 00 00    	je     8005ef <vprintfmt+0x23b>
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	0f 8e 98 00 00 00    	jle    8005fd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	89 54 24 04          	mov    %edx,0x4(%esp)
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	e8 47 03 00 00       	call   8008b8 <strnlen>
  800571:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800574:	29 c1                	sub    %eax,%ecx
  800576:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800579:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800587:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	83 ef 01             	sub    $0x1,%edi
  800596:	85 ff                	test   %edi,%edi
  800598:	7f ed                	jg     800587 <vprintfmt+0x1d3>
  80059a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c1             	cmovns %ecx,%eax
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b5:	89 cb                	mov    %ecx,%ebx
  8005b7:	eb 50                	jmp    800609 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1e                	je     8005dd <vprintfmt+0x229>
  8005bf:	0f be d2             	movsbl %dl,%edx
  8005c2:	83 ea 20             	sub    $0x20,%edx
  8005c5:	83 fa 5e             	cmp    $0x5e,%edx
  8005c8:	76 13                	jbe    8005dd <vprintfmt+0x229>
					putch('?', putdat);
  8005ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d8:	ff 55 08             	call   *0x8(%ebp)
  8005db:	eb 0d                	jmp    8005ea <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ea:	83 eb 01             	sub    $0x1,%ebx
  8005ed:	eb 1a                	jmp    800609 <vprintfmt+0x255>
  8005ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fb:	eb 0c                	jmp    800609 <vprintfmt+0x255>
  8005fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800606:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800609:	83 c7 01             	add    $0x1,%edi
  80060c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800610:	0f be c2             	movsbl %dl,%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	74 25                	je     80063c <vprintfmt+0x288>
  800617:	85 f6                	test   %esi,%esi
  800619:	78 9e                	js     8005b9 <vprintfmt+0x205>
  80061b:	83 ee 01             	sub    $0x1,%esi
  80061e:	79 99                	jns    8005b9 <vprintfmt+0x205>
  800620:	89 df                	mov    %ebx,%edi
  800622:	8b 75 08             	mov    0x8(%ebp),%esi
  800625:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800628:	eb 1a                	jmp    800644 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800635:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	83 ef 01             	sub    $0x1,%edi
  80063a:	eb 08                	jmp    800644 <vprintfmt+0x290>
  80063c:	89 df                	mov    %ebx,%edi
  80063e:	8b 75 08             	mov    0x8(%ebp),%esi
  800641:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800644:	85 ff                	test   %edi,%edi
  800646:	7f e2                	jg     80062a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064b:	e9 89 fd ff ff       	jmp    8003d9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7e 19                	jle    80066e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 50 04             	mov    0x4(%eax),%edx
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 40 08             	lea    0x8(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
  80066c:	eb 38                	jmp    8006a6 <vprintfmt+0x2f2>
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	74 1b                	je     80068d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	89 c1                	mov    %eax,%ecx
  80067c:	c1 f9 1f             	sar    $0x1f,%ecx
  80067f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
  80068b:	eb 19                	jmp    8006a6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	89 c1                	mov    %eax,%ecx
  800697:	c1 f9 1f             	sar    $0x1f,%ecx
  80069a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 40 04             	lea    0x4(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b5:	0f 89 04 01 00 00    	jns    8007bf <vprintfmt+0x40b>
				putch('-', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ce:	f7 da                	neg    %edx
  8006d0:	83 d1 00             	adc    $0x0,%ecx
  8006d3:	f7 d9                	neg    %ecx
  8006d5:	e9 e5 00 00 00       	jmp    8007bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006da:	83 f9 01             	cmp    $0x1,%ecx
  8006dd:	7e 10                	jle    8006ef <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ed:	eb 26                	jmp    800715 <vprintfmt+0x361>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	74 12                	je     800705 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
  800703:	eb 10                	jmp    800715 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800715:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80071a:	e9 a0 00 00 00       	jmp    8007bf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80071f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800723:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80072a:	ff d6                	call   *%esi
			putch('X', putdat);
  80072c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800730:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800737:	ff d6                	call   *%esi
			putch('X', putdat);
  800739:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800744:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800749:	e9 8b fc ff ff       	jmp    8003d9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80074e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800752:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800759:	ff d6                	call   *%esi
			putch('x', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800766:	ff d6                	call   *%esi
			num = (unsigned long long)
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800778:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80077d:	eb 40                	jmp    8007bf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077f:	83 f9 01             	cmp    $0x1,%ecx
  800782:	7e 10                	jle    800794 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 10                	mov    (%eax),%edx
  800789:	8b 48 04             	mov    0x4(%eax),%ecx
  80078c:	8d 40 08             	lea    0x8(%eax),%eax
  80078f:	89 45 14             	mov    %eax,0x14(%ebp)
  800792:	eb 26                	jmp    8007ba <vprintfmt+0x406>
	else if (lflag)
  800794:	85 c9                	test   %ecx,%ecx
  800796:	74 12                	je     8007aa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a2:	8d 40 04             	lea    0x4(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a8:	eb 10                	jmp    8007ba <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b4:	8d 40 04             	lea    0x4(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ba:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007d2:	89 14 24             	mov    %edx,(%esp)
  8007d5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007d9:	89 da                	mov    %ebx,%edx
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	e8 9e fa ff ff       	call   800280 <printnum>
			break;
  8007e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e5:	e9 ef fb ff ff       	jmp    8003d9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ee:	89 04 24             	mov    %eax,(%esp)
  8007f1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f6:	e9 de fb ff ff       	jmp    8003d9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800806:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800808:	eb 03                	jmp    80080d <vprintfmt+0x459>
  80080a:	83 ef 01             	sub    $0x1,%edi
  80080d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800811:	75 f7                	jne    80080a <vprintfmt+0x456>
  800813:	e9 c1 fb ff ff       	jmp    8003d9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800818:	83 c4 3c             	add    $0x3c,%esp
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5f                   	pop    %edi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 28             	sub    $0x28,%esp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800833:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800836:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 30                	je     800871 <vsnprintf+0x51>
  800841:	85 d2                	test   %edx,%edx
  800843:	7e 2c                	jle    800871 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084c:	8b 45 10             	mov    0x10(%ebp),%eax
  80084f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800853:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800856:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085a:	c7 04 24 6f 03 80 00 	movl   $0x80036f,(%esp)
  800861:	e8 4e fb ff ff       	call   8003b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800866:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800869:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086f:	eb 05                	jmp    800876 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800881:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 82 ff ff ff       	call   800820 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 03                	jmp    8008b0 <strlen+0x10>
		n++;
  8008ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b4:	75 f7                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 03                	jmp    8008cb <strnlen+0x13>
		n++;
  8008c8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	39 d0                	cmp    %edx,%eax
  8008cd:	74 06                	je     8008d5 <strnlen+0x1d>
  8008cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d3:	75 f3                	jne    8008c8 <strnlen+0x10>
		n++;
	return n;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	83 c2 01             	add    $0x1,%edx
  8008e6:	83 c1 01             	add    $0x1,%ecx
  8008e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	75 ef                	jne    8008e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800901:	89 1c 24             	mov    %ebx,(%esp)
  800904:	e8 97 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800910:	01 d8                	add    %ebx,%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 bd ff ff ff       	call   8008d7 <strcpy>
	return dst;
}
  80091a:	89 d8                	mov    %ebx,%eax
  80091c:	83 c4 08             	add    $0x8,%esp
  80091f:	5b                   	pop    %ebx
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	89 f3                	mov    %esi,%ebx
  80092f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	89 f2                	mov    %esi,%edx
  800934:	eb 0f                	jmp    800945 <strncpy+0x23>
		*dst++ = *src;
  800936:	83 c2 01             	add    $0x1,%edx
  800939:	0f b6 01             	movzbl (%ecx),%eax
  80093c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093f:	80 39 01             	cmpb   $0x1,(%ecx)
  800942:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	39 da                	cmp    %ebx,%edx
  800947:	75 ed                	jne    800936 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800949:	89 f0                	mov    %esi,%eax
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 75 08             	mov    0x8(%ebp),%esi
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095d:	89 f0                	mov    %esi,%eax
  80095f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800963:	85 c9                	test   %ecx,%ecx
  800965:	75 0b                	jne    800972 <strlcpy+0x23>
  800967:	eb 1d                	jmp    800986 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800972:	39 d8                	cmp    %ebx,%eax
  800974:	74 0b                	je     800981 <strlcpy+0x32>
  800976:	0f b6 0a             	movzbl (%edx),%ecx
  800979:	84 c9                	test   %cl,%cl
  80097b:	75 ec                	jne    800969 <strlcpy+0x1a>
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	eb 02                	jmp    800983 <strlcpy+0x34>
  800981:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800983:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800986:	29 f0                	sub    %esi,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800995:	eb 06                	jmp    80099d <strcmp+0x11>
		p++, q++;
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 04                	je     8009a8 <strcmp+0x1c>
  8009a4:	3a 02                	cmp    (%edx),%al
  8009a6:	74 ef                	je     800997 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 c0             	movzbl %al,%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	89 c3                	mov    %eax,%ebx
  8009be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c1:	eb 06                	jmp    8009c9 <strncmp+0x17>
		n--, p++, q++;
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c9:	39 d8                	cmp    %ebx,%eax
  8009cb:	74 15                	je     8009e2 <strncmp+0x30>
  8009cd:	0f b6 08             	movzbl (%eax),%ecx
  8009d0:	84 c9                	test   %cl,%cl
  8009d2:	74 04                	je     8009d8 <strncmp+0x26>
  8009d4:	3a 0a                	cmp    (%edx),%cl
  8009d6:	74 eb                	je     8009c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
  8009e0:	eb 05                	jmp    8009e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	eb 07                	jmp    8009fd <strchr+0x13>
		if (*s == c)
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	74 0f                	je     800a09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	eb 07                	jmp    800a1e <strfind+0x13>
		if (*s == c)
  800a17:	38 ca                	cmp    %cl,%dl
  800a19:	74 0a                	je     800a25 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	0f b6 10             	movzbl (%eax),%edx
  800a21:	84 d2                	test   %dl,%dl
  800a23:	75 f2                	jne    800a17 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a33:	85 c9                	test   %ecx,%ecx
  800a35:	74 36                	je     800a6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3d:	75 28                	jne    800a67 <memset+0x40>
  800a3f:	f6 c1 03             	test   $0x3,%cl
  800a42:	75 23                	jne    800a67 <memset+0x40>
		c &= 0xFF;
  800a44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a48:	89 d3                	mov    %edx,%ebx
  800a4a:	c1 e3 08             	shl    $0x8,%ebx
  800a4d:	89 d6                	mov    %edx,%esi
  800a4f:	c1 e6 18             	shl    $0x18,%esi
  800a52:	89 d0                	mov    %edx,%eax
  800a54:	c1 e0 10             	shl    $0x10,%eax
  800a57:	09 f0                	or     %esi,%eax
  800a59:	09 c2                	or     %eax,%edx
  800a5b:	89 d0                	mov    %edx,%eax
  800a5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a62:	fc                   	cld    
  800a63:	f3 ab                	rep stos %eax,%es:(%edi)
  800a65:	eb 06                	jmp    800a6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6a:	fc                   	cld    
  800a6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6d:	89 f8                	mov    %edi,%eax
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a82:	39 c6                	cmp    %eax,%esi
  800a84:	73 35                	jae    800abb <memmove+0x47>
  800a86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a89:	39 d0                	cmp    %edx,%eax
  800a8b:	73 2e                	jae    800abb <memmove+0x47>
		s += n;
		d += n;
  800a8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a90:	89 d6                	mov    %edx,%esi
  800a92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9a:	75 13                	jne    800aaf <memmove+0x3b>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 0e                	jne    800aaf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa1:	83 ef 04             	sub    $0x4,%edi
  800aa4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aaa:	fd                   	std    
  800aab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aad:	eb 09                	jmp    800ab8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aaf:	83 ef 01             	sub    $0x1,%edi
  800ab2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab5:	fd                   	std    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab8:	fc                   	cld    
  800ab9:	eb 1d                	jmp    800ad8 <memmove+0x64>
  800abb:	89 f2                	mov    %esi,%edx
  800abd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abf:	f6 c2 03             	test   $0x3,%dl
  800ac2:	75 0f                	jne    800ad3 <memmove+0x5f>
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 0a                	jne    800ad3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb 05                	jmp    800ad8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	fc                   	cld    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 79 ff ff ff       	call   800a74 <memmove>
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0d:	eb 1a                	jmp    800b29 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0f:	0f b6 02             	movzbl (%edx),%eax
  800b12:	0f b6 19             	movzbl (%ecx),%ebx
  800b15:	38 d8                	cmp    %bl,%al
  800b17:	74 0a                	je     800b23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 db             	movzbl %bl,%ebx
  800b1f:	29 d8                	sub    %ebx,%eax
  800b21:	eb 0f                	jmp    800b32 <memcmp+0x35>
		s1++, s2++;
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b29:	39 f2                	cmp    %esi,%edx
  800b2b:	75 e2                	jne    800b0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
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
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
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
  800b64:	0f b6 0a             	movzbl (%edx),%ecx
  800b67:	80 f9 09             	cmp    $0x9,%cl
  800b6a:	74 f5                	je     800b61 <strtol+0xe>
  800b6c:	80 f9 20             	cmp    $0x20,%cl
  800b6f:	74 f0                	je     800b61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b71:	80 f9 2b             	cmp    $0x2b,%cl
  800b74:	75 0a                	jne    800b80 <strtol+0x2d>
		s++;
  800b76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7e:	eb 11                	jmp    800b91 <strtol+0x3e>
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b85:	80 f9 2d             	cmp    $0x2d,%cl
  800b88:	75 07                	jne    800b91 <strtol+0x3e>
		s++, neg = 1;
  800b8a:	8d 52 01             	lea    0x1(%edx),%edx
  800b8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b96:	75 15                	jne    800bad <strtol+0x5a>
  800b98:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9b:	75 10                	jne    800bad <strtol+0x5a>
  800b9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba1:	75 0a                	jne    800bad <strtol+0x5a>
		s += 2, base = 16;
  800ba3:	83 c2 02             	add    $0x2,%edx
  800ba6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bab:	eb 10                	jmp    800bbd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bad:	85 c0                	test   %eax,%eax
  800baf:	75 0c                	jne    800bbd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb6:	75 05                	jne    800bbd <strtol+0x6a>
		s++, base = 8;
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc5:	0f b6 0a             	movzbl (%edx),%ecx
  800bc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	3c 09                	cmp    $0x9,%al
  800bcf:	77 08                	ja     800bd9 <strtol+0x86>
			dig = *s - '0';
  800bd1:	0f be c9             	movsbl %cl,%ecx
  800bd4:	83 e9 30             	sub    $0x30,%ecx
  800bd7:	eb 20                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bdc:	89 f0                	mov    %esi,%eax
  800bde:	3c 19                	cmp    $0x19,%al
  800be0:	77 08                	ja     800bea <strtol+0x97>
			dig = *s - 'a' + 10;
  800be2:	0f be c9             	movsbl %cl,%ecx
  800be5:	83 e9 57             	sub    $0x57,%ecx
  800be8:	eb 0f                	jmp    800bf9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bed:	89 f0                	mov    %esi,%eax
  800bef:	3c 19                	cmp    $0x19,%al
  800bf1:	77 16                	ja     800c09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bf3:	0f be c9             	movsbl %cl,%ecx
  800bf6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bf9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bfc:	7d 0f                	jge    800c0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c07:	eb bc                	jmp    800bc5 <strtol+0x72>
  800c09:	89 d8                	mov    %ebx,%eax
  800c0b:	eb 02                	jmp    800c0f <strtol+0xbc>
  800c0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c13:	74 05                	je     800c1a <strtol+0xc7>
		*endptr = (char *) s;
  800c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c1a:	f7 d8                	neg    %eax
  800c1c:	85 ff                	test   %edi,%edi
  800c1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	89 c6                	mov    %eax,%esi
  800c3d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c71:	b8 03 00 00 00       	mov    $0x3,%eax
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 cb                	mov    %ecx,%ebx
  800c7b:	89 cf                	mov    %ecx,%edi
  800c7d:	89 ce                	mov    %ecx,%esi
  800c7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800ca8:	e8 c0 f4 ff ff       	call   80016d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_yield>:

void
sys_yield(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	be 00 00 00 00       	mov    $0x0,%esi
  800d01:	b8 04 00 00 00       	mov    $0x4,%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0f:	89 f7                	mov    %esi,%edi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800d3a:	e8 2e f4 ff ff       	call   80016d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3f:	83 c4 2c             	add    $0x2c,%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	b8 05 00 00 00       	mov    $0x5,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	8b 75 18             	mov    0x18(%ebp),%esi
  800d64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 28                	jle    800d92 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d75:	00 
  800d76:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d85:	00 
  800d86:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800d8d:	e8 db f3 ff ff       	call   80016d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d92:	83 c4 2c             	add    $0x2c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800de0:	e8 88 f3 ff ff       	call   80016d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800e33:	e8 35 f3 ff ff       	call   80016d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 df                	mov    %ebx,%edi
  800e5b:	89 de                	mov    %ebx,%esi
  800e5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7e 28                	jle    800e8b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e67:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800e86:	e8 e2 f2 ff ff       	call   80016d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e8b:	83 c4 2c             	add    $0x2c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 28                	jle    800ede <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800ed9:	e8 8f f2 ff ff       	call   80016d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ede:	83 c4 2c             	add    $0x2c,%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eec:	be 00 00 00 00       	mov    $0x0,%esi
  800ef1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f02:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 cb                	mov    %ecx,%ebx
  800f21:	89 cf                	mov    %ecx,%edi
  800f23:	89 ce                	mov    %ecx,%esi
  800f25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 28                	jle    800f53 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f36:	00 
  800f37:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 fc 19 80 00 	movl   $0x8019fc,(%esp)
  800f4e:	e8 1a f2 ff ff       	call   80016d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f53:	83 c4 2c             	add    $0x2c,%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 20             	sub    $0x20,%esp
  800f63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  800f66:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  800f68:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  800f6c:	75 3f                	jne    800fad <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800f6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f72:	c7 04 24 0a 1a 80 00 	movl   $0x801a0a,(%esp)
  800f79:	e8 e8 f2 ff ff       	call   800266 <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  800f7e:	8b 43 28             	mov    0x28(%ebx),%eax
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	c7 04 24 1a 1a 80 00 	movl   $0x801a1a,(%esp)
  800f8c:	e8 d5 f2 ff ff       	call   800266 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800f91:	c7 44 24 08 60 1a 80 	movl   $0x801a60,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  800fa8:	e8 c0 f1 ff ff       	call   80016d <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	c1 e8 0c             	shr    $0xc,%eax
  800fb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800fb9:	f6 c4 08             	test   $0x8,%ah
  800fbc:	75 1c                	jne    800fda <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  800fbe:	c7 44 24 08 88 1a 80 	movl   $0x801a88,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fcd:	00 
  800fce:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  800fd5:	e8 93 f1 ff ff       	call   80016d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  800fda:	e8 d6 fc ff ff       	call   800cb5 <sys_getenvid>
  800fdf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fee:	00 
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	e8 fc fc ff ff       	call   800cf3 <sys_page_alloc>
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	79 1c                	jns    801017 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  800ffb:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  801012:	e8 56 f1 ff ff       	call   80016d <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801017:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80101d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801024:	00 
  801025:	89 74 24 04          	mov    %esi,0x4(%esp)
  801029:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801030:	e8 a7 fa ff ff       	call   800adc <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801035:	e8 7b fc ff ff       	call   800cb5 <sys_getenvid>
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	e8 74 fc ff ff       	call   800cb5 <sys_getenvid>
  801041:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801048:	00 
  801049:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80104d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801051:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801058:	00 
  801059:	89 04 24             	mov    %eax,(%esp)
  80105c:	e8 e6 fc ff ff       	call   800d47 <sys_page_map>
  801061:	85 c0                	test   %eax,%eax
  801063:	79 20                	jns    801085 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801069:	c7 44 24 08 d0 1a 80 	movl   $0x801ad0,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  801080:	e8 e8 f0 ff ff       	call   80016d <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801085:	e8 2b fc ff ff       	call   800cb5 <sys_getenvid>
  80108a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801091:	00 
  801092:	89 04 24             	mov    %eax,(%esp)
  801095:	e8 00 fd ff ff       	call   800d9a <sys_page_unmap>
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 20                	jns    8010be <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80109e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a2:	c7 44 24 08 00 1b 80 	movl   $0x801b00,0x8(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8010b1:	00 
  8010b2:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  8010b9:	e8 af f0 ff ff       	call   80016d <_panic>
	return;
}
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  8010ce:	c7 04 24 5b 0f 80 00 	movl   $0x800f5b,(%esp)
  8010d5:	e8 20 02 00 00       	call   8012fa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010da:	b8 07 00 00 00       	mov    $0x7,%eax
  8010df:	cd 30                	int    $0x30
  8010e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 20                	jns    80110b <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  8010eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ef:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  8010fe:	00 
  8010ff:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  801106:	e8 62 f0 ff ff       	call   80016d <_panic>
	if(childEid == 0){
  80110b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80110f:	75 1c                	jne    80112d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801111:	e8 9f fb ff ff       	call   800cb5 <sys_getenvid>
  801116:	25 ff 03 00 00       	and    $0x3ff,%eax
  80111b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80111e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801123:	a3 08 20 80 00       	mov    %eax,0x802008
		return childEid;
  801128:	e9 a0 01 00 00       	jmp    8012cd <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80112d:	c7 44 24 04 90 13 80 	movl   $0x801390,0x4(%esp)
  801134:	00 
  801135:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801138:	89 04 24             	mov    %eax,(%esp)
  80113b:	e8 53 fd ff ff       	call   800e93 <sys_env_set_pgfault_upcall>
  801140:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	79 20                	jns    801166 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801146:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114a:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801159:	00 
  80115a:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  801161:	e8 07 f0 ff ff       	call   80016d <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801166:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	b9 00 00 00 00       	mov    $0x0,%ecx
  801175:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801178:	89 c2                	mov    %eax,%edx
  80117a:	c1 ea 16             	shr    $0x16,%edx
  80117d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801184:	f6 c2 01             	test   $0x1,%dl
  801187:	0f 84 f7 00 00 00    	je     801284 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80118d:	c1 e8 0c             	shr    $0xc,%eax
  801190:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801197:	f6 c2 04             	test   $0x4,%dl
  80119a:	0f 84 e4 00 00 00    	je     801284 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8011a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011a7:	a8 01                	test   $0x1,%al
  8011a9:	0f 84 d5 00 00 00    	je     801284 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8011af:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8011b5:	75 20                	jne    8011d7 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8011b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011c6:	ee 
  8011c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ca:	89 04 24             	mov    %eax,(%esp)
  8011cd:	e8 21 fb ff ff       	call   800cf3 <sys_page_alloc>
  8011d2:	e9 84 00 00 00       	jmp    80125b <fork+0x196>
  8011d7:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  8011dd:	89 f8                	mov    %edi,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
  8011e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  8011e9:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  8011ee:	83 f8 01             	cmp    $0x1,%eax
  8011f1:	19 db                	sbb    %ebx,%ebx
  8011f3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8011f9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8011ff:	e8 b1 fa ff ff       	call   800cb5 <sys_getenvid>
  801204:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801208:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80120c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80120f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801213:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 28 fb ff ff       	call   800d47 <sys_page_map>
  80121f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801222:	85 c0                	test   %eax,%eax
  801224:	78 35                	js     80125b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801226:	e8 8a fa ff ff       	call   800cb5 <sys_getenvid>
  80122b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80122e:	e8 82 fa ff ff       	call   800cb5 <sys_getenvid>
  801233:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801237:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80123e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	e8 f9 fa ff ff       	call   800d47 <sys_page_map>
  80124e:	85 c0                	test   %eax,%eax
  801250:	bf 00 00 00 00       	mov    $0x0,%edi
  801255:	0f 4f c7             	cmovg  %edi,%eax
  801258:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80125b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80125f:	79 23                	jns    801284 <fork+0x1bf>
  801261:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801264:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801268:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  80126f:	00 
  801270:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801277:	00 
  801278:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  80127f:	e8 e9 ee ff ff       	call   80016d <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801284:	89 f1                	mov    %esi,%ecx
  801286:	89 f0                	mov    %esi,%eax
  801288:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80128e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801294:	0f 85 de fe ff ff    	jne    801178 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80129a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012a1:	00 
  8012a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a5:	89 04 24             	mov    %eax,(%esp)
  8012a8:	e8 40 fb ff ff       	call   800ded <sys_env_set_status>
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	79 1c                	jns    8012cd <fork+0x208>
		panic("sys_env_set_status");
  8012b1:	c7 44 24 08 36 1a 80 	movl   $0x801a36,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  8012c8:	e8 a0 ee ff ff       	call   80016d <_panic>
	return childEid;
}
  8012cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d0:	83 c4 2c             	add    $0x2c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <sfork>:

// Challenge!
int
sfork(void)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012de:	c7 44 24 08 49 1a 80 	movl   $0x801a49,0x8(%esp)
  8012e5:	00 
  8012e6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8012ed:	00 
  8012ee:	c7 04 24 2b 1a 80 00 	movl   $0x801a2b,(%esp)
  8012f5:	e8 73 ee ff ff       	call   80016d <_panic>

008012fa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801300:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801307:	75 44                	jne    80134d <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  801309:	a1 08 20 80 00       	mov    0x802008,%eax
  80130e:	8b 40 48             	mov    0x48(%eax),%eax
  801311:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801318:	00 
  801319:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801320:	ee 
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 ca f9 ff ff       	call   800cf3 <sys_page_alloc>
		if( r < 0)
  801329:	85 c0                	test   %eax,%eax
  80132b:	79 20                	jns    80134d <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80132d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801331:	c7 44 24 08 d0 1b 80 	movl   $0x801bd0,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 2c 1c 80 00 	movl   $0x801c2c,(%esp)
  801348:	e8 20 ee ff ff       	call   80016d <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801355:	e8 5b f9 ff ff       	call   800cb5 <sys_getenvid>
  80135a:	c7 44 24 04 90 13 80 	movl   $0x801390,0x4(%esp)
  801361:	00 
  801362:	89 04 24             	mov    %eax,(%esp)
  801365:	e8 29 fb ff ff       	call   800e93 <sys_env_set_pgfault_upcall>
  80136a:	85 c0                	test   %eax,%eax
  80136c:	79 20                	jns    80138e <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80136e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801372:	c7 44 24 08 00 1c 80 	movl   $0x801c00,0x8(%esp)
  801379:	00 
  80137a:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801381:	00 
  801382:	c7 04 24 2c 1c 80 00 	movl   $0x801c2c,(%esp)
  801389:	e8 df ed ff ff       	call   80016d <_panic>


}
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801390:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801391:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801396:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801398:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  80139b:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  80139f:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8013a3:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8013a7:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8013aa:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8013ad:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8013b0:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8013b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8013b8:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8013bc:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8013c0:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8013c4:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8013c8:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8013cc:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  8013cd:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  8013ce:	c3                   	ret    
  8013cf:	90                   	nop

008013d0 <__udivdi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ec:	89 ea                	mov    %ebp,%edx
  8013ee:	89 0c 24             	mov    %ecx,(%esp)
  8013f1:	75 2d                	jne    801420 <__udivdi3+0x50>
  8013f3:	39 e9                	cmp    %ebp,%ecx
  8013f5:	77 61                	ja     801458 <__udivdi3+0x88>
  8013f7:	85 c9                	test   %ecx,%ecx
  8013f9:	89 ce                	mov    %ecx,%esi
  8013fb:	75 0b                	jne    801408 <__udivdi3+0x38>
  8013fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801402:	31 d2                	xor    %edx,%edx
  801404:	f7 f1                	div    %ecx
  801406:	89 c6                	mov    %eax,%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	89 e8                	mov    %ebp,%eax
  80140c:	f7 f6                	div    %esi
  80140e:	89 c5                	mov    %eax,%ebp
  801410:	89 f8                	mov    %edi,%eax
  801412:	f7 f6                	div    %esi
  801414:	89 ea                	mov    %ebp,%edx
  801416:	83 c4 0c             	add    $0xc,%esp
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
  80141d:	8d 76 00             	lea    0x0(%esi),%esi
  801420:	39 e8                	cmp    %ebp,%eax
  801422:	77 24                	ja     801448 <__udivdi3+0x78>
  801424:	0f bd e8             	bsr    %eax,%ebp
  801427:	83 f5 1f             	xor    $0x1f,%ebp
  80142a:	75 3c                	jne    801468 <__udivdi3+0x98>
  80142c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801430:	39 34 24             	cmp    %esi,(%esp)
  801433:	0f 86 9f 00 00 00    	jbe    8014d8 <__udivdi3+0x108>
  801439:	39 d0                	cmp    %edx,%eax
  80143b:	0f 82 97 00 00 00    	jb     8014d8 <__udivdi3+0x108>
  801441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801448:	31 d2                	xor    %edx,%edx
  80144a:	31 c0                	xor    %eax,%eax
  80144c:	83 c4 0c             	add    $0xc,%esp
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	89 f8                	mov    %edi,%eax
  80145a:	f7 f1                	div    %ecx
  80145c:	31 d2                	xor    %edx,%edx
  80145e:	83 c4 0c             	add    $0xc,%esp
  801461:	5e                   	pop    %esi
  801462:	5f                   	pop    %edi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    
  801465:	8d 76 00             	lea    0x0(%esi),%esi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	8b 3c 24             	mov    (%esp),%edi
  80146d:	d3 e0                	shl    %cl,%eax
  80146f:	89 c6                	mov    %eax,%esi
  801471:	b8 20 00 00 00       	mov    $0x20,%eax
  801476:	29 e8                	sub    %ebp,%eax
  801478:	89 c1                	mov    %eax,%ecx
  80147a:	d3 ef                	shr    %cl,%edi
  80147c:	89 e9                	mov    %ebp,%ecx
  80147e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801482:	8b 3c 24             	mov    (%esp),%edi
  801485:	09 74 24 08          	or     %esi,0x8(%esp)
  801489:	89 d6                	mov    %edx,%esi
  80148b:	d3 e7                	shl    %cl,%edi
  80148d:	89 c1                	mov    %eax,%ecx
  80148f:	89 3c 24             	mov    %edi,(%esp)
  801492:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801496:	d3 ee                	shr    %cl,%esi
  801498:	89 e9                	mov    %ebp,%ecx
  80149a:	d3 e2                	shl    %cl,%edx
  80149c:	89 c1                	mov    %eax,%ecx
  80149e:	d3 ef                	shr    %cl,%edi
  8014a0:	09 d7                	or     %edx,%edi
  8014a2:	89 f2                	mov    %esi,%edx
  8014a4:	89 f8                	mov    %edi,%eax
  8014a6:	f7 74 24 08          	divl   0x8(%esp)
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	f7 24 24             	mull   (%esp)
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	89 14 24             	mov    %edx,(%esp)
  8014b6:	72 30                	jb     8014e8 <__udivdi3+0x118>
  8014b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014bc:	89 e9                	mov    %ebp,%ecx
  8014be:	d3 e2                	shl    %cl,%edx
  8014c0:	39 c2                	cmp    %eax,%edx
  8014c2:	73 05                	jae    8014c9 <__udivdi3+0xf9>
  8014c4:	3b 34 24             	cmp    (%esp),%esi
  8014c7:	74 1f                	je     8014e8 <__udivdi3+0x118>
  8014c9:	89 f8                	mov    %edi,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	e9 7a ff ff ff       	jmp    80144c <__udivdi3+0x7c>
  8014d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014d8:	31 d2                	xor    %edx,%edx
  8014da:	b8 01 00 00 00       	mov    $0x1,%eax
  8014df:	e9 68 ff ff ff       	jmp    80144c <__udivdi3+0x7c>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014eb:	31 d2                	xor    %edx,%edx
  8014ed:	83 c4 0c             	add    $0xc,%esp
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    
  8014f4:	66 90                	xchg   %ax,%ax
  8014f6:	66 90                	xchg   %ax,%ax
  8014f8:	66 90                	xchg   %ax,%ax
  8014fa:	66 90                	xchg   %ax,%ax
  8014fc:	66 90                	xchg   %ax,%ax
  8014fe:	66 90                	xchg   %ax,%ax

00801500 <__umoddi3>:
  801500:	55                   	push   %ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	83 ec 14             	sub    $0x14,%esp
  801506:	8b 44 24 28          	mov    0x28(%esp),%eax
  80150a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80150e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801512:	89 c7                	mov    %eax,%edi
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	8b 44 24 30          	mov    0x30(%esp),%eax
  80151c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801520:	89 34 24             	mov    %esi,(%esp)
  801523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801527:	85 c0                	test   %eax,%eax
  801529:	89 c2                	mov    %eax,%edx
  80152b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80152f:	75 17                	jne    801548 <__umoddi3+0x48>
  801531:	39 fe                	cmp    %edi,%esi
  801533:	76 4b                	jbe    801580 <__umoddi3+0x80>
  801535:	89 c8                	mov    %ecx,%eax
  801537:	89 fa                	mov    %edi,%edx
  801539:	f7 f6                	div    %esi
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	31 d2                	xor    %edx,%edx
  80153f:	83 c4 14             	add    $0x14,%esp
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
  801546:	66 90                	xchg   %ax,%ax
  801548:	39 f8                	cmp    %edi,%eax
  80154a:	77 54                	ja     8015a0 <__umoddi3+0xa0>
  80154c:	0f bd e8             	bsr    %eax,%ebp
  80154f:	83 f5 1f             	xor    $0x1f,%ebp
  801552:	75 5c                	jne    8015b0 <__umoddi3+0xb0>
  801554:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801558:	39 3c 24             	cmp    %edi,(%esp)
  80155b:	0f 87 e7 00 00 00    	ja     801648 <__umoddi3+0x148>
  801561:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801565:	29 f1                	sub    %esi,%ecx
  801567:	19 c7                	sbb    %eax,%edi
  801569:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801571:	8b 44 24 08          	mov    0x8(%esp),%eax
  801575:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801579:	83 c4 14             	add    $0x14,%esp
  80157c:	5e                   	pop    %esi
  80157d:	5f                   	pop    %edi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
  801580:	85 f6                	test   %esi,%esi
  801582:	89 f5                	mov    %esi,%ebp
  801584:	75 0b                	jne    801591 <__umoddi3+0x91>
  801586:	b8 01 00 00 00       	mov    $0x1,%eax
  80158b:	31 d2                	xor    %edx,%edx
  80158d:	f7 f6                	div    %esi
  80158f:	89 c5                	mov    %eax,%ebp
  801591:	8b 44 24 04          	mov    0x4(%esp),%eax
  801595:	31 d2                	xor    %edx,%edx
  801597:	f7 f5                	div    %ebp
  801599:	89 c8                	mov    %ecx,%eax
  80159b:	f7 f5                	div    %ebp
  80159d:	eb 9c                	jmp    80153b <__umoddi3+0x3b>
  80159f:	90                   	nop
  8015a0:	89 c8                	mov    %ecx,%eax
  8015a2:	89 fa                	mov    %edi,%edx
  8015a4:	83 c4 14             	add    $0x14,%esp
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    
  8015ab:	90                   	nop
  8015ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015b0:	8b 04 24             	mov    (%esp),%eax
  8015b3:	be 20 00 00 00       	mov    $0x20,%esi
  8015b8:	89 e9                	mov    %ebp,%ecx
  8015ba:	29 ee                	sub    %ebp,%esi
  8015bc:	d3 e2                	shl    %cl,%edx
  8015be:	89 f1                	mov    %esi,%ecx
  8015c0:	d3 e8                	shr    %cl,%eax
  8015c2:	89 e9                	mov    %ebp,%ecx
  8015c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c8:	8b 04 24             	mov    (%esp),%eax
  8015cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015cf:	89 fa                	mov    %edi,%edx
  8015d1:	d3 e0                	shl    %cl,%eax
  8015d3:	89 f1                	mov    %esi,%ecx
  8015d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015dd:	d3 ea                	shr    %cl,%edx
  8015df:	89 e9                	mov    %ebp,%ecx
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	89 f1                	mov    %esi,%ecx
  8015e5:	d3 e8                	shr    %cl,%eax
  8015e7:	89 e9                	mov    %ebp,%ecx
  8015e9:	09 f8                	or     %edi,%eax
  8015eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015ef:	f7 74 24 04          	divl   0x4(%esp)
  8015f3:	d3 e7                	shl    %cl,%edi
  8015f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015f9:	89 d7                	mov    %edx,%edi
  8015fb:	f7 64 24 08          	mull   0x8(%esp)
  8015ff:	39 d7                	cmp    %edx,%edi
  801601:	89 c1                	mov    %eax,%ecx
  801603:	89 14 24             	mov    %edx,(%esp)
  801606:	72 2c                	jb     801634 <__umoddi3+0x134>
  801608:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80160c:	72 22                	jb     801630 <__umoddi3+0x130>
  80160e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801612:	29 c8                	sub    %ecx,%eax
  801614:	19 d7                	sbb    %edx,%edi
  801616:	89 e9                	mov    %ebp,%ecx
  801618:	89 fa                	mov    %edi,%edx
  80161a:	d3 e8                	shr    %cl,%eax
  80161c:	89 f1                	mov    %esi,%ecx
  80161e:	d3 e2                	shl    %cl,%edx
  801620:	89 e9                	mov    %ebp,%ecx
  801622:	d3 ef                	shr    %cl,%edi
  801624:	09 d0                	or     %edx,%eax
  801626:	89 fa                	mov    %edi,%edx
  801628:	83 c4 14             	add    $0x14,%esp
  80162b:	5e                   	pop    %esi
  80162c:	5f                   	pop    %edi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    
  80162f:	90                   	nop
  801630:	39 d7                	cmp    %edx,%edi
  801632:	75 da                	jne    80160e <__umoddi3+0x10e>
  801634:	8b 14 24             	mov    (%esp),%edx
  801637:	89 c1                	mov    %eax,%ecx
  801639:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80163d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801641:	eb cb                	jmp    80160e <__umoddi3+0x10e>
  801643:	90                   	nop
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80164c:	0f 82 0f ff ff ff    	jb     801561 <__umoddi3+0x61>
  801652:	e9 1a ff ff ff       	jmp    801571 <__umoddi3+0x71>
