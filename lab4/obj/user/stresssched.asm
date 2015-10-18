
obj/user/stresssched：     文件格式 elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
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
  800048:	e8 67 0c 00 00       	call   800cb4 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 23 0f 00 00       	call   800f7c <fork>
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
  800065:	eb 05                	jmp    80006c <umain+0x2c>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	75 16                	jne    800082 <umain+0x42>
		sys_yield();
  80006c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800070:	e8 6f 0c 00 00       	call   800ce4 <sys_yield>
		return;
  800075:	e9 98 00 00 00       	jmp    800112 <umain+0xd2>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  80007a:	f3 90                	pause  
  80007c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800080:	eb 11                	jmp    800093 <umain+0x53>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800082:	89 f2                	mov    %esi,%edx
  800084:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  80008a:	6b d2 7c             	imul   $0x7c,%edx,%edx
  80008d:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800093:	8b 42 50             	mov    0x50(%edx),%eax
  800096:	85 c0                	test   %eax,%eax
  800098:	75 e0                	jne    80007a <umain+0x3a>
  80009a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80009f:	e8 40 0c 00 00       	call   800ce4 <sys_yield>
  8000a4:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a9:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000af:	83 c2 01             	add    $0x1,%edx
  8000b2:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b8:	83 e8 01             	sub    $0x1,%eax
  8000bb:	75 ec                	jne    8000a9 <umain+0x69>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000bd:	83 eb 01             	sub    $0x1,%ebx
  8000c0:	75 dd                	jne    80009f <umain+0x5f>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000c2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c7:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000cc:	74 25                	je     8000f3 <umain+0xb3>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000ce:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d7:	c7 44 24 08 60 12 80 	movl   $0x801260,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 88 12 80 00 	movl   $0x801288,(%esp)
  8000ee:	e8 8d 00 00 00       	call   800180 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000f3:	a1 08 20 80 00       	mov    0x802008,%eax
  8000f8:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000fb:	8b 40 48             	mov    0x48(%eax),%eax
  8000fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  800102:	89 44 24 04          	mov    %eax,0x4(%esp)
  800106:	c7 04 24 9b 12 80 00 	movl   $0x80129b,(%esp)
  80010d:	e8 69 01 00 00       	call   80027b <cprintf>

}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
  800119:	66 90                	xchg   %ax,%ax
  80011b:	90                   	nop

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80012e:	e8 81 0b 00 00       	call   800cb4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800140:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 f6                	test   %esi,%esi
  800147:	7e 07                	jle    800150 <libmain+0x34>
		binaryname = argv[0];
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800154:	89 34 24             	mov    %esi,(%esp)
  800157:	e8 e4 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
  80016b:	90                   	nop

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 d9 0a 00 00       	call   800c57 <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800188:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800191:	e8 1e 0b 00 00       	call   800cb4 <sys_getenvid>
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 c4 12 80 00 	movl   $0x8012c4,(%esp)
  8001b3:	e8 c3 00 00 00       	call   80027b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 53 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 b7 12 80 00 	movl   $0x8012b7,(%esp)
  8001ce:	e8 a8 00 00 00       	call   80027b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x53>
  8001d6:	66 90                	xchg   %ax,%ax

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 14             	sub    $0x14,%esp
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e2:	8b 03                	mov    (%ebx),%eax
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001eb:	83 c0 01             	add    $0x1,%eax
  8001ee:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f5:	75 19                	jne    800210 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fe:	00 
  8001ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 ee 09 00 00       	call   800bf8 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800210:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800214:	83 c4 14             	add    $0x14,%esp
  800217:	5b                   	pop    %ebx
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800223:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022a:	00 00 00 
	b.cnt = 0;
  80022d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800234:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	c7 04 24 d8 01 80 00 	movl   $0x8001d8,(%esp)
  800256:	e8 92 01 00 00       	call   8003ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 85 09 00 00       	call   800bf8 <sys_cputs>

	return b.cnt;
}
  800273:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800281:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 87 ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    
  800295:	66 90                	xchg   %ax,%ax
  800297:	66 90                	xchg   %ax,%ax
  800299:	66 90                	xchg   %ax,%ax
  80029b:	66 90                	xchg   %ax,%ax
  80029d:	66 90                	xchg   %ax,%ax
  80029f:	90                   	nop

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	75 08                	jne    8002cc <printnum+0x2c>
  8002c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ca:	77 59                	ja     800325 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002d0:	83 eb 01             	sub    $0x1,%ebx
  8002d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002e2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ed:	00 
  8002ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f1:	89 04 24             	mov    %eax,(%esp)
  8002f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fb:	e8 c0 0c 00 00       	call   800fc0 <__udivdi3>
  800300:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800304:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	89 fa                	mov    %edi,%edx
  800311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800314:	e8 87 ff ff ff       	call   8002a0 <printnum>
  800319:	eb 11                	jmp    80032c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031f:	89 34 24             	mov    %esi,(%esp)
  800322:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800325:	83 eb 01             	sub    $0x1,%ebx
  800328:	85 db                	test   %ebx,%ebx
  80032a:	7f ef                	jg     80031b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800334:	8b 45 10             	mov    0x10(%ebp),%eax
  800337:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800342:	00 
  800343:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800350:	e8 9b 0d 00 00       	call   8010f0 <__umoddi3>
  800355:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800359:	0f be 80 e8 12 80 00 	movsbl 0x8012e8(%eax),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800366:	83 c4 3c             	add    $0x3c,%esp
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800371:	83 fa 01             	cmp    $0x1,%edx
  800374:	7e 0e                	jle    800384 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800376:	8b 10                	mov    (%eax),%edx
  800378:	8d 4a 08             	lea    0x8(%edx),%ecx
  80037b:	89 08                	mov    %ecx,(%eax)
  80037d:	8b 02                	mov    (%edx),%eax
  80037f:	8b 52 04             	mov    0x4(%edx),%edx
  800382:	eb 22                	jmp    8003a6 <getuint+0x38>
	else if (lflag)
  800384:	85 d2                	test   %edx,%edx
  800386:	74 10                	je     800398 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 02                	mov    (%edx),%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	eb 0e                	jmp    8003a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800398:	8b 10                	mov    (%eax),%edx
  80039a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 02                	mov    (%edx),%eax
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b7:	73 0a                	jae    8003c3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bc:	88 0a                	mov    %cl,(%edx)
  8003be:	83 c2 01             	add    $0x1,%edx
  8003c1:	89 10                	mov    %edx,(%eax)
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	e8 02 00 00 00       	call   8003ed <vprintfmt>
	va_end(ap);
}
  8003eb:	c9                   	leave  
  8003ec:	c3                   	ret    

008003ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 4c             	sub    $0x4c,%esp
  8003f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003fc:	eb 12                	jmp    800410 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fe:	85 c0                	test   %eax,%eax
  800400:	0f 84 bf 03 00 00    	je     8007c5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800410:	0f b6 06             	movzbl (%esi),%eax
  800413:	83 c6 01             	add    $0x1,%esi
  800416:	83 f8 25             	cmp    $0x25,%eax
  800419:	75 e3                	jne    8003fe <vprintfmt+0x11>
  80041b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80041f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800426:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80042b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800432:	b9 00 00 00 00       	mov    $0x0,%ecx
  800437:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043a:	eb 2b                	jmp    800467 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800443:	eb 22                	jmp    800467 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800448:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80044c:	eb 19                	jmp    800467 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800451:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800458:	eb 0d                	jmp    800467 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80045a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800460:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	0f b6 16             	movzbl (%esi),%edx
  80046a:	0f b6 c2             	movzbl %dl,%eax
  80046d:	8d 7e 01             	lea    0x1(%esi),%edi
  800470:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800473:	83 ea 23             	sub    $0x23,%edx
  800476:	80 fa 55             	cmp    $0x55,%dl
  800479:	0f 87 28 03 00 00    	ja     8007a7 <vprintfmt+0x3ba>
  80047f:	0f b6 d2             	movzbl %dl,%edx
  800482:	ff 24 95 a0 13 80 00 	jmp    *0x8013a0(,%edx,4)
  800489:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800493:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800498:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80049b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80049f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a5:	83 fa 09             	cmp    $0x9,%edx
  8004a8:	77 2f                	ja     8004d9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004aa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ad:	eb e9                	jmp    800498 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c0:	eb 1a                	jmp    8004dc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c9:	79 9c                	jns    800467 <vprintfmt+0x7a>
  8004cb:	eb 81                	jmp    80044e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004d7:	eb 8e                	jmp    800467 <vprintfmt+0x7a>
  8004d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	79 85                	jns    800467 <vprintfmt+0x7a>
  8004e2:	e9 73 ff ff ff       	jmp    80045a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ed:	e9 75 ff ff ff       	jmp    800467 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 04 24             	mov    %eax,(%esp)
  800504:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050a:	e9 01 ff ff ff       	jmp    800410 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 c2                	mov    %eax,%edx
  80051c:	c1 fa 1f             	sar    $0x1f,%edx
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 09             	cmp    $0x9,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x146>
  800528:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	75 23                	jne    800556 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800533:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800537:	c7 44 24 08 00 13 80 	movl   $0x801300,0x8(%esp)
  80053e:	00 
  80053f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800543:	8b 7d 08             	mov    0x8(%ebp),%edi
  800546:	89 3c 24             	mov    %edi,(%esp)
  800549:	e8 77 fe ff ff       	call   8003c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800551:	e9 ba fe ff ff       	jmp    800410 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800556:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055a:	c7 44 24 08 09 13 80 	movl   $0x801309,0x8(%esp)
  800561:	00 
  800562:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800566:	8b 7d 08             	mov    0x8(%ebp),%edi
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	e8 54 fe ff ff       	call   8003c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800574:	e9 97 fe ff ff       	jmp    800410 <vprintfmt+0x23>
  800579:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80058d:	85 f6                	test   %esi,%esi
  80058f:	ba f9 12 80 00       	mov    $0x8012f9,%edx
  800594:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 8e 8c 00 00 00    	jle    80062d <vprintfmt+0x240>
  8005a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005a5:	0f 84 82 00 00 00    	je     80062d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005af:	89 34 24             	mov    %esi,(%esp)
  8005b2:	e8 b1 02 00 00       	call   800868 <strnlen>
  8005b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ba:	29 c2                	sub    %eax,%edx
  8005bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005bf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005c9:	89 de                	mov    %ebx,%esi
  8005cb:	89 d3                	mov    %edx,%ebx
  8005cd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	eb 0d                	jmp    8005de <vprintfmt+0x1f1>
					putch(padc, putdat);
  8005d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d5:	89 3c 24             	mov    %edi,(%esp)
  8005d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	7f ef                	jg     8005d1 <vprintfmt+0x1e4>
  8005e2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005e5:	89 f3                	mov    %esi,%ebx
  8005e7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8005f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fa:	29 c2                	sub    %eax,%edx
  8005fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ff:	eb 2c                	jmp    80062d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	74 18                	je     80061f <vprintfmt+0x232>
  800607:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060a:	83 fa 5e             	cmp    $0x5e,%edx
  80060d:	76 10                	jbe    80061f <vprintfmt+0x232>
					putch('?', putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061a:	ff 55 08             	call   *0x8(%ebp)
  80061d:	eb 0a                	jmp    800629 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800629:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80062d:	0f be 06             	movsbl (%esi),%eax
  800630:	83 c6 01             	add    $0x1,%esi
  800633:	85 c0                	test   %eax,%eax
  800635:	74 25                	je     80065c <vprintfmt+0x26f>
  800637:	85 ff                	test   %edi,%edi
  800639:	78 c6                	js     800601 <vprintfmt+0x214>
  80063b:	83 ef 01             	sub    $0x1,%edi
  80063e:	79 c1                	jns    800601 <vprintfmt+0x214>
  800640:	8b 7d 08             	mov    0x8(%ebp),%edi
  800643:	89 de                	mov    %ebx,%esi
  800645:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800648:	eb 1a                	jmp    800664 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800655:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800657:	83 eb 01             	sub    $0x1,%ebx
  80065a:	eb 08                	jmp    800664 <vprintfmt+0x277>
  80065c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80065f:	89 de                	mov    %ebx,%esi
  800661:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800664:	85 db                	test   %ebx,%ebx
  800666:	7f e2                	jg     80064a <vprintfmt+0x25d>
  800668:	89 7d 08             	mov    %edi,0x8(%ebp)
  80066b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800670:	e9 9b fd ff ff       	jmp    800410 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7e 10                	jle    80068a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 08             	lea    0x8(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 30                	mov    (%eax),%esi
  800685:	8b 78 04             	mov    0x4(%eax),%edi
  800688:	eb 26                	jmp    8006b0 <vprintfmt+0x2c3>
	else if (lflag)
  80068a:	85 c9                	test   %ecx,%ecx
  80068c:	74 12                	je     8006a0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)
  800697:	8b 30                	mov    (%eax),%esi
  800699:	89 f7                	mov    %esi,%edi
  80069b:	c1 ff 1f             	sar    $0x1f,%edi
  80069e:	eb 10                	jmp    8006b0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 30                	mov    (%eax),%esi
  8006ab:	89 f7                	mov    %esi,%edi
  8006ad:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	0f 89 ac 00 00 00    	jns    800769 <vprintfmt+0x37c>
				putch('-', putdat);
  8006bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006cb:	f7 de                	neg    %esi
  8006cd:	83 d7 00             	adc    $0x0,%edi
  8006d0:	f7 df                	neg    %edi
			}
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d7:	e9 8d 00 00 00       	jmp    800769 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006dc:	89 ca                	mov    %ecx,%edx
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e1:	e8 88 fc ff ff       	call   80036e <getuint>
  8006e6:	89 c6                	mov    %eax,%esi
  8006e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ef:	eb 78                	jmp    800769 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006fc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80070a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80070d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800711:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800718:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80071e:	e9 ed fc ff ff       	jmp    800410 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800727:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800731:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800735:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80073c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 04             	lea    0x4(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800748:	8b 30                	mov    (%eax),%esi
  80074a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800754:	eb 13                	jmp    800769 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800756:	89 ca                	mov    %ecx,%edx
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
  80075b:	e8 0e fc ff ff       	call   80036e <getuint>
  800760:	89 c6                	mov    %eax,%esi
  800762:	89 d7                	mov    %edx,%edi
			base = 16;
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800769:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80076d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800771:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800774:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077c:	89 34 24             	mov    %esi,(%esp)
  80077f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800783:	89 da                	mov    %ebx,%edx
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	e8 13 fb ff ff       	call   8002a0 <printnum>
			break;
  80078d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800790:	e9 7b fc ff ff       	jmp    800410 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800795:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800799:	89 04 24             	mov    %eax,(%esp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a2:	e9 69 fc ff ff       	jmp    800410 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b5:	eb 03                	jmp    8007ba <vprintfmt+0x3cd>
  8007b7:	83 ee 01             	sub    $0x1,%esi
  8007ba:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007be:	75 f7                	jne    8007b7 <vprintfmt+0x3ca>
  8007c0:	e9 4b fc ff ff       	jmp    800410 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007c5:	83 c4 4c             	add    $0x4c,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 30                	je     80081e <vsnprintf+0x51>
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 2c                	jle    80081e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	89 44 24 04          	mov    %eax,0x4(%esp)
  800807:	c7 04 24 a8 03 80 00 	movl   $0x8003a8,(%esp)
  80080e:	e8 da fb ff ff       	call   8003ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800813:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800816:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
  800835:	89 44 24 08          	mov    %eax,0x8(%esp)
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 82 ff ff ff       	call   8007cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    
  80084d:	66 90                	xchg   %ax,%ax
  80084f:	90                   	nop

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	eb 03                	jmp    800860 <strlen+0x10>
		n++;
  80085d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f7                	jne    80085d <strlen+0xd>
		n++;
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb 03                	jmp    80087b <strnlen+0x13>
		n++;
  800878:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087b:	39 d0                	cmp    %edx,%eax
  80087d:	74 06                	je     800885 <strnlen+0x1d>
  80087f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800883:	75 f3                	jne    800878 <strnlen+0x10>
		n++;
	return n;
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800891:	ba 00 00 00 00       	mov    $0x0,%edx
  800896:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	75 f2                	jne    800896 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b1:	89 1c 24             	mov    %ebx,(%esp)
  8008b4:	e8 97 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c0:	01 d8                	add    %ebx,%eax
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 bd ff ff ff       	call   800887 <strcpy>
	return dst;
}
  8008ca:	89 d8                	mov    %ebx,%eax
  8008cc:	83 c4 08             	add    $0x8,%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e5:	eb 0f                	jmp    8008f6 <strncpy+0x24>
		*dst++ = *src;
  8008e7:	0f b6 1a             	movzbl (%edx),%ebx
  8008ea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ed:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	39 f1                	cmp    %esi,%ecx
  8008f8:	75 ed                	jne    8008e7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 75 08             	mov    0x8(%ebp),%esi
  800906:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800909:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	85 d2                	test   %edx,%edx
  800910:	75 0a                	jne    80091c <strlcpy+0x1e>
  800912:	eb 1d                	jmp    800931 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800914:	88 18                	mov    %bl,(%eax)
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091c:	83 ea 01             	sub    $0x1,%edx
  80091f:	74 0b                	je     80092c <strlcpy+0x2e>
  800921:	0f b6 19             	movzbl (%ecx),%ebx
  800924:	84 db                	test   %bl,%bl
  800926:	75 ec                	jne    800914 <strlcpy+0x16>
  800928:	89 c2                	mov    %eax,%edx
  80092a:	eb 02                	jmp    80092e <strlcpy+0x30>
  80092c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80092e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800931:	29 f0                	sub    %esi,%eax
}
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800940:	eb 06                	jmp    800948 <strcmp+0x11>
		p++, q++;
  800942:	83 c1 01             	add    $0x1,%ecx
  800945:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800948:	0f b6 01             	movzbl (%ecx),%eax
  80094b:	84 c0                	test   %al,%al
  80094d:	74 04                	je     800953 <strcmp+0x1c>
  80094f:	3a 02                	cmp    (%edx),%al
  800951:	74 ef                	je     800942 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 c0             	movzbl %al,%eax
  800956:	0f b6 12             	movzbl (%edx),%edx
  800959:	29 d0                	sub    %edx,%eax
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800967:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80096a:	eb 09                	jmp    800975 <strncmp+0x18>
		n--, p++, q++;
  80096c:	83 ea 01             	sub    $0x1,%edx
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800975:	85 d2                	test   %edx,%edx
  800977:	74 15                	je     80098e <strncmp+0x31>
  800979:	0f b6 18             	movzbl (%eax),%ebx
  80097c:	84 db                	test   %bl,%bl
  80097e:	74 04                	je     800984 <strncmp+0x27>
  800980:	3a 19                	cmp    (%ecx),%bl
  800982:	74 e8                	je     80096c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800984:	0f b6 00             	movzbl (%eax),%eax
  800987:	0f b6 11             	movzbl (%ecx),%edx
  80098a:	29 d0                	sub    %edx,%eax
  80098c:	eb 05                	jmp    800993 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a0:	eb 07                	jmp    8009a9 <strchr+0x13>
		if (*s == c)
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	74 0f                	je     8009b5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	0f b6 10             	movzbl (%eax),%edx
  8009ac:	84 d2                	test   %dl,%dl
  8009ae:	75 f2                	jne    8009a2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	eb 07                	jmp    8009ca <strfind+0x13>
		if (*s == c)
  8009c3:	38 ca                	cmp    %cl,%dl
  8009c5:	74 0a                	je     8009d1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	0f b6 10             	movzbl (%eax),%edx
  8009cd:	84 d2                	test   %dl,%dl
  8009cf:	75 f2                	jne    8009c3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009df:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	74 30                	je     800a1f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f5:	75 25                	jne    800a1c <memset+0x49>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 20                	jne    800a1c <memset+0x49>
		c &= 0xFF;
  8009fc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 d0                	or     %edx,%eax
  800a12:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a14:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a17:	fc                   	cld    
  800a18:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1a:	eb 03                	jmp    800a1f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a2a:	89 ec                	mov    %ebp,%esp
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a43:	39 c6                	cmp    %eax,%esi
  800a45:	73 36                	jae    800a7d <memmove+0x4f>
  800a47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 2f                	jae    800a7d <memmove+0x4f>
		s += n;
		d += n;
  800a4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a51:	f6 c2 03             	test   $0x3,%dl
  800a54:	75 1b                	jne    800a71 <memmove+0x43>
  800a56:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5c:	75 13                	jne    800a71 <memmove+0x43>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0e                	jne    800a71 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a63:	83 ef 04             	sub    $0x4,%edi
  800a66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a69:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 09                	jmp    800a7a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a71:	83 ef 01             	sub    $0x1,%edi
  800a74:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a77:	fd                   	std    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7a:	fc                   	cld    
  800a7b:	eb 20                	jmp    800a9d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a83:	75 13                	jne    800a98 <memmove+0x6a>
  800a85:	a8 03                	test   $0x3,%al
  800a87:	75 0f                	jne    800a98 <memmove+0x6a>
  800a89:	f6 c1 03             	test   $0x3,%cl
  800a8c:	75 0a                	jne    800a98 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a96:	eb 05                	jmp    800a9d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a98:	89 c7                	mov    %eax,%edi
  800a9a:	fc                   	cld    
  800a9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aa3:	89 ec                	mov    %ebp,%esp
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aad:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	e8 68 ff ff ff       	call   800a2e <memmove>
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	eb 1a                	jmp    800af8 <memcmp+0x30>
		if (*s1 != *s2)
  800ade:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ae2:	83 c2 01             	add    $0x1,%edx
  800ae5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800aea:	38 c8                	cmp    %cl,%al
  800aec:	74 0a                	je     800af8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800aee:	0f b6 c0             	movzbl %al,%eax
  800af1:	0f b6 c9             	movzbl %cl,%ecx
  800af4:	29 c8                	sub    %ecx,%eax
  800af6:	eb 09                	jmp    800b01 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af8:	39 da                	cmp    %ebx,%edx
  800afa:	75 e2                	jne    800ade <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
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
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800b34:	0f b6 02             	movzbl (%edx),%eax
  800b37:	3c 20                	cmp    $0x20,%al
  800b39:	74 f6                	je     800b31 <strtol+0xe>
  800b3b:	3c 09                	cmp    $0x9,%al
  800b3d:	74 f2                	je     800b31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3f:	3c 2b                	cmp    $0x2b,%al
  800b41:	75 0a                	jne    800b4d <strtol+0x2a>
		s++;
  800b43:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb 10                	jmp    800b5d <strtol+0x3a>
  800b4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b52:	3c 2d                	cmp    $0x2d,%al
  800b54:	75 07                	jne    800b5d <strtol+0x3a>
		s++, neg = 1;
  800b56:	8d 52 01             	lea    0x1(%edx),%edx
  800b59:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	0f 94 c0             	sete   %al
  800b62:	74 05                	je     800b69 <strtol+0x46>
  800b64:	83 fb 10             	cmp    $0x10,%ebx
  800b67:	75 15                	jne    800b7e <strtol+0x5b>
  800b69:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6c:	75 10                	jne    800b7e <strtol+0x5b>
  800b6e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b72:	75 0a                	jne    800b7e <strtol+0x5b>
		s += 2, base = 16;
  800b74:	83 c2 02             	add    $0x2,%edx
  800b77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7c:	eb 13                	jmp    800b91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b7e:	84 c0                	test   %al,%al
  800b80:	74 0f                	je     800b91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b82:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b87:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8a:	75 05                	jne    800b91 <strtol+0x6e>
		s++, base = 8;
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 0a             	movzbl (%edx),%ecx
  800b9b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b9e:	80 fb 09             	cmp    $0x9,%bl
  800ba1:	77 08                	ja     800bab <strtol+0x88>
			dig = *s - '0';
  800ba3:	0f be c9             	movsbl %cl,%ecx
  800ba6:	83 e9 30             	sub    $0x30,%ecx
  800ba9:	eb 1e                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bab:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0x98>
			dig = *s - 'a' + 10;
  800bb3:	0f be c9             	movsbl %cl,%ecx
  800bb6:	83 e9 57             	sub    $0x57,%ecx
  800bb9:	eb 0e                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bbe:	80 fb 19             	cmp    $0x19,%bl
  800bc1:	77 14                	ja     800bd7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800bc3:	0f be c9             	movsbl %cl,%ecx
  800bc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc9:	39 f1                	cmp    %esi,%ecx
  800bcb:	7d 0e                	jge    800bdb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	0f af c6             	imul   %esi,%eax
  800bd3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd5:	eb c1                	jmp    800b98 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd7:	89 c1                	mov    %eax,%ecx
  800bd9:	eb 02                	jmp    800bdd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be1:	74 05                	je     800be8 <strtol+0xc5>
		*endptr = (char *) s;
  800be3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be8:	89 ca                	mov    %ecx,%edx
  800bea:	f7 da                	neg    %edx
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 45 c2             	cmovne %edx,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
  800bf6:	66 90                	xchg   %ax,%ax

00800bf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c01:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c04:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	89 c3                	mov    %eax,%ebx
  800c14:	89 c7                	mov    %eax,%edi
  800c16:	89 c6                	mov    %eax,%esi
  800c18:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c23:	89 ec                	mov    %ebp,%esp
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c30:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c33:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c40:	89 d1                	mov    %edx,%ecx
  800c42:	89 d3                	mov    %edx,%ebx
  800c44:	89 d7                	mov    %edx,%edi
  800c46:	89 d6                	mov    %edx,%esi
  800c48:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c53:	89 ec                	mov    %ebp,%esp
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 38             	sub    $0x38,%esp
  800c5d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c60:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c63:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 cb                	mov    %ecx,%ebx
  800c75:	89 cf                	mov    %ecx,%edi
  800c77:	89 ce                	mov    %ecx,%esi
  800c79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 28                	jle    800ca7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800c92:	00 
  800c93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9a:	00 
  800c9b:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800ca2:	e8 d9 f4 ff ff       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800caa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb0:	89 ec                	mov    %ebp,%esp
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800cc8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	89 d3                	mov    %edx,%ebx
  800cd1:	89 d7                	mov    %edx,%edi
  800cd3:	89 d6                	mov    %edx,%esi
  800cd5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce0:	89 ec                	mov    %ebp,%esp
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_yield>:

void
sys_yield(void)
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
  800cf8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfd:	89 d1                	mov    %edx,%ecx
  800cff:	89 d3                	mov    %edx,%ebx
  800d01:	89 d7                	mov    %edx,%edi
  800d03:	89 d6                	mov    %edx,%esi
  800d05:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d07:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d10:	89 ec                	mov    %ebp,%esp
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 38             	sub    $0x38,%esp
  800d1a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d20:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	be 00 00 00 00       	mov    $0x0,%esi
  800d28:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 f7                	mov    %esi,%edi
  800d38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 28                	jle    800d66 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d42:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d49:	00 
  800d4a:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800d51:	00 
  800d52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d59:	00 
  800d5a:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800d61:	e8 1a f4 ff ff       	call   800180 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6f:	89 ec                	mov    %ebp,%esp
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 38             	sub    $0x38,%esp
  800d79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	b8 05 00 00 00       	mov    $0x5,%eax
  800d87:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800dbf:	e8 bc f3 ff ff       	call   800180 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcd:	89 ec                	mov    %ebp,%esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 38             	sub    $0x38,%esp
  800dd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de5:	b8 06 00 00 00       	mov    $0x6,%eax
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	89 df                	mov    %ebx,%edi
  800df2:	89 de                	mov    %ebx,%esi
  800df4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800e1d:	e8 5e f3 ff ff       	call   800180 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2b:	89 ec                	mov    %ebp,%esp
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 38             	sub    $0x38,%esp
  800e35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e43:	b8 08 00 00 00       	mov    $0x8,%eax
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	89 df                	mov    %ebx,%edi
  800e50:	89 de                	mov    %ebx,%esi
  800e52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 28                	jle    800e80 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e63:	00 
  800e64:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e73:	00 
  800e74:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800e7b:	e8 00 f3 ff ff       	call   800180 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e80:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e86:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e89:	89 ec                	mov    %ebp,%esp
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 38             	sub    $0x38,%esp
  800e93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e99:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800eb4:	7e 28                	jle    800ede <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eba:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800ec9:	00 
  800eca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed1:	00 
  800ed2:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800ed9:	e8 a2 f2 ff ff       	call   800180 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ede:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee7:	89 ec                	mov    %ebp,%esp
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	be 00 00 00 00       	mov    $0x0,%esi
  800eff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f12:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f15:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f18:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1b:	89 ec                	mov    %ebp,%esp
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 38             	sub    $0x38,%esp
  800f25:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f28:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f38:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3b:	89 cb                	mov    %ecx,%ebx
  800f3d:	89 cf                	mov    %ecx,%edi
  800f3f:	89 ce                	mov    %ecx,%esi
  800f41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7e 28                	jle    800f6f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f52:	00 
  800f53:	c7 44 24 08 28 15 80 	movl   $0x801528,0x8(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f62:	00 
  800f63:	c7 04 24 45 15 80 00 	movl   $0x801545,(%esp)
  800f6a:	e8 11 f2 ff ff       	call   800180 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f78:	89 ec                	mov    %ebp,%esp
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f82:	c7 44 24 08 5f 15 80 	movl   $0x80155f,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800f99:	e8 e2 f1 ff ff       	call   800180 <_panic>

00800f9e <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fa4:	c7 44 24 08 5e 15 80 	movl   $0x80155e,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 53 15 80 00 	movl   $0x801553,(%esp)
  800fbb:	e8 c0 f1 ff ff       	call   800180 <_panic>

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800fce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fdc:	89 ea                	mov    %ebp,%edx
  800fde:	89 0c 24             	mov    %ecx,(%esp)
  800fe1:	75 2d                	jne    801010 <__udivdi3+0x50>
  800fe3:	39 e9                	cmp    %ebp,%ecx
  800fe5:	77 61                	ja     801048 <__udivdi3+0x88>
  800fe7:	85 c9                	test   %ecx,%ecx
  800fe9:	89 ce                	mov    %ecx,%esi
  800feb:	75 0b                	jne    800ff8 <__udivdi3+0x38>
  800fed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff2:	31 d2                	xor    %edx,%edx
  800ff4:	f7 f1                	div    %ecx
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	89 e8                	mov    %ebp,%eax
  800ffc:	f7 f6                	div    %esi
  800ffe:	89 c5                	mov    %eax,%ebp
  801000:	89 f8                	mov    %edi,%eax
  801002:	f7 f6                	div    %esi
  801004:	89 ea                	mov    %ebp,%edx
  801006:	83 c4 0c             	add    $0xc,%esp
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	39 e8                	cmp    %ebp,%eax
  801012:	77 24                	ja     801038 <__udivdi3+0x78>
  801014:	0f bd e8             	bsr    %eax,%ebp
  801017:	83 f5 1f             	xor    $0x1f,%ebp
  80101a:	75 3c                	jne    801058 <__udivdi3+0x98>
  80101c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801020:	39 34 24             	cmp    %esi,(%esp)
  801023:	0f 86 9f 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801029:	39 d0                	cmp    %edx,%eax
  80102b:	0f 82 97 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	31 c0                	xor    %eax,%eax
  80103c:	83 c4 0c             	add    $0xc,%esp
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 f8                	mov    %edi,%eax
  80104a:	f7 f1                	div    %ecx
  80104c:	31 d2                	xor    %edx,%edx
  80104e:	83 c4 0c             	add    $0xc,%esp
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	8b 3c 24             	mov    (%esp),%edi
  80105d:	d3 e0                	shl    %cl,%eax
  80105f:	89 c6                	mov    %eax,%esi
  801061:	b8 20 00 00 00       	mov    $0x20,%eax
  801066:	29 e8                	sub    %ebp,%eax
  801068:	89 c1                	mov    %eax,%ecx
  80106a:	d3 ef                	shr    %cl,%edi
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801072:	8b 3c 24             	mov    (%esp),%edi
  801075:	09 74 24 08          	or     %esi,0x8(%esp)
  801079:	89 d6                	mov    %edx,%esi
  80107b:	d3 e7                	shl    %cl,%edi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 3c 24             	mov    %edi,(%esp)
  801082:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801086:	d3 ee                	shr    %cl,%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	d3 e2                	shl    %cl,%edx
  80108c:	89 c1                	mov    %eax,%ecx
  80108e:	d3 ef                	shr    %cl,%edi
  801090:	09 d7                	or     %edx,%edi
  801092:	89 f2                	mov    %esi,%edx
  801094:	89 f8                	mov    %edi,%eax
  801096:	f7 74 24 08          	divl   0x8(%esp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 24 24             	mull   (%esp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 14 24             	mov    %edx,(%esp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	39 c2                	cmp    %eax,%edx
  8010b2:	73 05                	jae    8010b9 <__udivdi3+0xf9>
  8010b4:	3b 34 24             	cmp    (%esp),%esi
  8010b7:	74 1f                	je     8010d8 <__udivdi3+0x118>
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	e9 7a ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cf:	e9 68 ff ff ff       	jmp    80103c <__udivdi3+0x7c>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	83 c4 0c             	add    $0xc,%esp
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    
  8010e4:	66 90                	xchg   %ax,%ax
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	66 90                	xchg   %ax,%ax
  8010ea:	66 90                	xchg   %ax,%ax
  8010ec:	66 90                	xchg   %ax,%ax
  8010ee:	66 90                	xchg   %ax,%ax

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	83 ec 14             	sub    $0x14,%esp
  8010f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801102:	89 c7                	mov    %eax,%edi
  801104:	89 44 24 04          	mov    %eax,0x4(%esp)
  801108:	8b 44 24 30          	mov    0x30(%esp),%eax
  80110c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801110:	89 34 24             	mov    %esi,(%esp)
  801113:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801117:	85 c0                	test   %eax,%eax
  801119:	89 c2                	mov    %eax,%edx
  80111b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111f:	75 17                	jne    801138 <__umoddi3+0x48>
  801121:	39 fe                	cmp    %edi,%esi
  801123:	76 4b                	jbe    801170 <__umoddi3+0x80>
  801125:	89 c8                	mov    %ecx,%eax
  801127:	89 fa                	mov    %edi,%edx
  801129:	f7 f6                	div    %esi
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	31 d2                	xor    %edx,%edx
  80112f:	83 c4 14             	add    $0x14,%esp
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
  801136:	66 90                	xchg   %ax,%ax
  801138:	39 f8                	cmp    %edi,%eax
  80113a:	77 54                	ja     801190 <__umoddi3+0xa0>
  80113c:	0f bd e8             	bsr    %eax,%ebp
  80113f:	83 f5 1f             	xor    $0x1f,%ebp
  801142:	75 5c                	jne    8011a0 <__umoddi3+0xb0>
  801144:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801148:	39 3c 24             	cmp    %edi,(%esp)
  80114b:	0f 87 e7 00 00 00    	ja     801238 <__umoddi3+0x148>
  801151:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801155:	29 f1                	sub    %esi,%ecx
  801157:	19 c7                	sbb    %eax,%edi
  801159:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801161:	8b 44 24 08          	mov    0x8(%esp),%eax
  801165:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801169:	83 c4 14             	add    $0x14,%esp
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
  801170:	85 f6                	test   %esi,%esi
  801172:	89 f5                	mov    %esi,%ebp
  801174:	75 0b                	jne    801181 <__umoddi3+0x91>
  801176:	b8 01 00 00 00       	mov    $0x1,%eax
  80117b:	31 d2                	xor    %edx,%edx
  80117d:	f7 f6                	div    %esi
  80117f:	89 c5                	mov    %eax,%ebp
  801181:	8b 44 24 04          	mov    0x4(%esp),%eax
  801185:	31 d2                	xor    %edx,%edx
  801187:	f7 f5                	div    %ebp
  801189:	89 c8                	mov    %ecx,%eax
  80118b:	f7 f5                	div    %ebp
  80118d:	eb 9c                	jmp    80112b <__umoddi3+0x3b>
  80118f:	90                   	nop
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 fa                	mov    %edi,%edx
  801194:	83 c4 14             	add    $0x14,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	8b 04 24             	mov    (%esp),%eax
  8011a3:	be 20 00 00 00       	mov    $0x20,%esi
  8011a8:	89 e9                	mov    %ebp,%ecx
  8011aa:	29 ee                	sub    %ebp,%esi
  8011ac:	d3 e2                	shl    %cl,%edx
  8011ae:	89 f1                	mov    %esi,%ecx
  8011b0:	d3 e8                	shr    %cl,%eax
  8011b2:	89 e9                	mov    %ebp,%ecx
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	8b 04 24             	mov    (%esp),%eax
  8011bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	d3 e0                	shl    %cl,%eax
  8011c3:	89 f1                	mov    %esi,%ecx
  8011c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8011cd:	d3 ea                	shr    %cl,%edx
  8011cf:	89 e9                	mov    %ebp,%ecx
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f1                	mov    %esi,%ecx
  8011d5:	d3 e8                	shr    %cl,%eax
  8011d7:	89 e9                	mov    %ebp,%ecx
  8011d9:	09 f8                	or     %edi,%eax
  8011db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8011df:	f7 74 24 04          	divl   0x4(%esp)
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e9:	89 d7                	mov    %edx,%edi
  8011eb:	f7 64 24 08          	mull   0x8(%esp)
  8011ef:	39 d7                	cmp    %edx,%edi
  8011f1:	89 c1                	mov    %eax,%ecx
  8011f3:	89 14 24             	mov    %edx,(%esp)
  8011f6:	72 2c                	jb     801224 <__umoddi3+0x134>
  8011f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011fc:	72 22                	jb     801220 <__umoddi3+0x130>
  8011fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801202:	29 c8                	sub    %ecx,%eax
  801204:	19 d7                	sbb    %edx,%edi
  801206:	89 e9                	mov    %ebp,%ecx
  801208:	89 fa                	mov    %edi,%edx
  80120a:	d3 e8                	shr    %cl,%eax
  80120c:	89 f1                	mov    %esi,%ecx
  80120e:	d3 e2                	shl    %cl,%edx
  801210:	89 e9                	mov    %ebp,%ecx
  801212:	d3 ef                	shr    %cl,%edi
  801214:	09 d0                	or     %edx,%eax
  801216:	89 fa                	mov    %edi,%edx
  801218:	83 c4 14             	add    $0x14,%esp
  80121b:	5e                   	pop    %esi
  80121c:	5f                   	pop    %edi
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    
  80121f:	90                   	nop
  801220:	39 d7                	cmp    %edx,%edi
  801222:	75 da                	jne    8011fe <__umoddi3+0x10e>
  801224:	8b 14 24             	mov    (%esp),%edx
  801227:	89 c1                	mov    %eax,%ecx
  801229:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80122d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801231:	eb cb                	jmp    8011fe <__umoddi3+0x10e>
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80123c:	0f 82 0f ff ff ff    	jb     801151 <__umoddi3+0x61>
  801242:	e9 1a ff ff ff       	jmp    801161 <__umoddi3+0x71>
