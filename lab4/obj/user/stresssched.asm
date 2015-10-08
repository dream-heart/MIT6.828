
obj/user/stresssched:     file format elf32-i386


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
	...

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
  800048:	e8 88 0c 00 00       	call   800cd5 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 cf 0e 00 00       	call   800f28 <fork>
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
  800070:	e8 7f 0c 00 00       	call   800cf4 <sys_yield>
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
  80009f:	e8 50 0c 00 00       	call   800cf4 <sys_yield>
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
  8000d7:	c7 44 24 08 20 12 80 	movl   $0x801220,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 48 12 80 00 	movl   $0x801248,(%esp)
  8000ee:	e8 8c 00 00 00       	call   80017f <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000f3:	a1 08 20 80 00       	mov    0x802008,%eax
  8000f8:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000fb:	8b 40 48             	mov    0x48(%eax),%eax
  8000fe:	89 54 24 08          	mov    %edx,0x8(%esp)
  800102:	89 44 24 04          	mov    %eax,0x4(%esp)
  800106:	c7 04 24 5b 12 80 00 	movl   $0x80125b,(%esp)
  80010d:	e8 66 01 00 00       	call   800278 <cprintf>

}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
  800119:	00 00                	add    %al,(%eax)
	...

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
  80012e:	e8 a2 0b 00 00       	call   800cd5 <sys_getenvid>
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
  80015c:	e8 0a 00 00 00       	call   80016b <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800178:	e8 06 0b 00 00       	call   800c83 <sys_env_destroy>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800187:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800190:	e8 40 0b 00 00       	call   800cd5 <sys_getenvid>
  800195:	8b 55 0c             	mov    0xc(%ebp),%edx
  800198:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	c7 04 24 84 12 80 00 	movl   $0x801284,(%esp)
  8001b2:	e8 c1 00 00 00       	call   800278 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 51 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001c6:	c7 04 24 77 12 80 00 	movl   $0x801277,(%esp)
  8001cd:	e8 a6 00 00 00       	call   800278 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x53>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 14             	sub    $0x14,%esp
  8001dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001df:	8b 13                	mov    (%ebx),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 03                	mov    %eax,(%ebx)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	75 19                	jne    80020d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fb:	00 
  8001fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 3f 0a 00 00       	call   800c46 <sys_cputs>
		b->idx = 0;
  800207:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80020d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800211:	83 c4 14             	add    $0x14,%esp
  800214:	5b                   	pop    %ebx
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800220:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800227:	00 00 00 
	b.cnt = 0;
  80022a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800231:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800242:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024c:	c7 04 24 d5 01 80 00 	movl   $0x8001d5,(%esp)
  800253:	e8 7c 01 00 00       	call   8003d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800262:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	e8 d6 09 00 00       	call   800c46 <sys_cputs>

	return b.cnt;
}
  800270:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800281:	89 44 24 04          	mov    %eax,0x4(%esp)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	e8 87 ff ff ff       	call   800217 <vcprintf>
	va_end(ap);

	return cnt;
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    
	...

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
  8002b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 c3                	mov    %eax,%ebx
  8002b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002cd:	39 d9                	cmp    %ebx,%ecx
  8002cf:	72 05                	jb     8002d6 <printnum+0x36>
  8002d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d4:	77 69                	ja     80033f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002dd:	83 ee 01             	sub    $0x1,%esi
  8002e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002f0:	89 c3                	mov    %eax,%ebx
  8002f2:	89 d6                	mov    %edx,%esi
  8002f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	e8 5c 0c 00 00       	call   800f70 <__udivdi3>
  800314:	89 d9                	mov    %ebx,%ecx
  800316:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	89 54 24 04          	mov    %edx,0x4(%esp)
  800325:	89 fa                	mov    %edi,%edx
  800327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032a:	e8 71 ff ff ff       	call   8002a0 <printnum>
  80032f:	eb 1b                	jmp    80034c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	8b 45 18             	mov    0x18(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff d3                	call   *%ebx
  80033d:	eb 03                	jmp    800342 <printnum+0xa2>
  80033f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800342:	83 ee 01             	sub    $0x1,%esi
  800345:	85 f6                	test   %esi,%esi
  800347:	7f e8                	jg     800331 <printnum+0x91>
  800349:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800350:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800354:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800357:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 2c 0d 00 00       	call   8010a0 <__umoddi3>
  800374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800378:	0f be 80 a8 12 80 00 	movsbl 0x8012a8(%eax),%eax
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800385:	ff d0                	call   *%eax
}
  800387:	83 c4 3c             	add    $0x3c,%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800395:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 0a                	jae    8003aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	88 02                	mov    %al,(%edx)
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	e8 02 00 00 00       	call   8003d4 <vprintfmt>
	va_end(ap);
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 3c             	sub    $0x3c,%esp
  8003dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e6:	eb 11                	jmp    8003f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	0f 84 48 04 00 00    	je     800838 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	83 c7 01             	add    $0x1,%edi
  8003fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800400:	83 f8 25             	cmp    $0x25,%eax
  800403:	75 e3                	jne    8003e8 <vprintfmt+0x14>
  800405:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800409:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800410:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800417:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80041e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800423:	eb 1f                	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800428:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80042c:	eb 16                	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800431:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800435:	eb 0d                	jmp    800444 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800437:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8d 47 01             	lea    0x1(%edi),%eax
  800447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044a:	0f b6 17             	movzbl (%edi),%edx
  80044d:	0f b6 c2             	movzbl %dl,%eax
  800450:	83 ea 23             	sub    $0x23,%edx
  800453:	80 fa 55             	cmp    $0x55,%dl
  800456:	0f 87 bf 03 00 00    	ja     80081b <vprintfmt+0x447>
  80045c:	0f b6 d2             	movzbl %dl,%edx
  80045f:	ff 24 95 60 13 80 00 	jmp    *0x801360(,%edx,4)
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800471:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800474:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800478:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80047b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80047e:	83 f9 09             	cmp    $0x9,%ecx
  800481:	77 3c                	ja     8004bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800483:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800486:	eb e9                	jmp    800471 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 40 04             	lea    0x4(%eax),%eax
  800496:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049c:	eb 27                	jmp    8004c5 <vprintfmt+0xf1>
  80049e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	0f 49 c2             	cmovns %edx,%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b1:	eb 91                	jmp    800444 <vprintfmt+0x70>
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bd:	eb 85                	jmp    800444 <vprintfmt+0x70>
  8004bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	0f 89 75 ff ff ff    	jns    800444 <vprintfmt+0x70>
  8004cf:	e9 63 ff ff ff       	jmp    800437 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004da:	e9 65 ff ff ff       	jmp    800444 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f4:	e9 00 ff ff ff       	jmp    8003f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	99                   	cltd   
  800503:	31 d0                	xor    %edx,%eax
  800505:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800507:	83 f8 09             	cmp    $0x9,%eax
  80050a:	7f 0b                	jg     800517 <vprintfmt+0x143>
  80050c:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  800513:	85 d2                	test   %edx,%edx
  800515:	75 20                	jne    800537 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051b:	c7 44 24 08 c0 12 80 	movl   $0x8012c0,0x8(%esp)
  800522:	00 
  800523:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800527:	89 34 24             	mov    %esi,(%esp)
  80052a:	e8 7d fe ff ff       	call   8003ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800532:	e9 c2 fe ff ff       	jmp    8003f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800537:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053b:	c7 44 24 08 c9 12 80 	movl   $0x8012c9,0x8(%esp)
  800542:	00 
  800543:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 5d fe ff ff       	call   8003ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800552:	e9 a2 fe ff ff       	jmp    8003f9 <vprintfmt+0x25>
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80055d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800560:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800563:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800567:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800569:	85 ff                	test   %edi,%edi
  80056b:	b8 b9 12 80 00       	mov    $0x8012b9,%eax
  800570:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800573:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800577:	0f 84 92 00 00 00    	je     80060f <vprintfmt+0x23b>
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	0f 8e 98 00 00 00    	jle    80061d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	89 54 24 04          	mov    %edx,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	e8 47 03 00 00       	call   8008d8 <strnlen>
  800591:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800594:	29 c1                	sub    %eax,%ecx
  800596:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800599:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	eb 0f                	jmp    8005b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	7f ed                	jg     8005a7 <vprintfmt+0x1d3>
  8005ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	0f 49 c1             	cmovns %ecx,%eax
  8005ca:	29 c1                	sub    %eax,%ecx
  8005cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d5:	89 cb                	mov    %ecx,%ebx
  8005d7:	eb 50                	jmp    800629 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dd:	74 1e                	je     8005fd <vprintfmt+0x229>
  8005df:	0f be d2             	movsbl %dl,%edx
  8005e2:	83 ea 20             	sub    $0x20,%edx
  8005e5:	83 fa 5e             	cmp    $0x5e,%edx
  8005e8:	76 13                	jbe    8005fd <vprintfmt+0x229>
					putch('?', putdat);
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f8:	ff 55 08             	call   *0x8(%ebp)
  8005fb:	eb 0d                	jmp    80060a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800600:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060a:	83 eb 01             	sub    $0x1,%ebx
  80060d:	eb 1a                	jmp    800629 <vprintfmt+0x255>
  80060f:	89 75 08             	mov    %esi,0x8(%ebp)
  800612:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800615:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800618:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061b:	eb 0c                	jmp    800629 <vprintfmt+0x255>
  80061d:	89 75 08             	mov    %esi,0x8(%ebp)
  800620:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800623:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800626:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800630:	0f be c2             	movsbl %dl,%eax
  800633:	85 c0                	test   %eax,%eax
  800635:	74 25                	je     80065c <vprintfmt+0x288>
  800637:	85 f6                	test   %esi,%esi
  800639:	78 9e                	js     8005d9 <vprintfmt+0x205>
  80063b:	83 ee 01             	sub    $0x1,%esi
  80063e:	79 99                	jns    8005d9 <vprintfmt+0x205>
  800640:	89 df                	mov    %ebx,%edi
  800642:	8b 75 08             	mov    0x8(%ebp),%esi
  800645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800648:	eb 1a                	jmp    800664 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800655:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800657:	83 ef 01             	sub    $0x1,%edi
  80065a:	eb 08                	jmp    800664 <vprintfmt+0x290>
  80065c:	89 df                	mov    %ebx,%edi
  80065e:	8b 75 08             	mov    0x8(%ebp),%esi
  800661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800664:	85 ff                	test   %edi,%edi
  800666:	7f e2                	jg     80064a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066b:	e9 89 fd ff ff       	jmp    8003f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800670:	83 f9 01             	cmp    $0x1,%ecx
  800673:	7e 19                	jle    80068e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 50 04             	mov    0x4(%eax),%edx
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800680:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 40 08             	lea    0x8(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
  80068c:	eb 38                	jmp    8006c6 <vprintfmt+0x2f2>
	else if (lflag)
  80068e:	85 c9                	test   %ecx,%ecx
  800690:	74 1b                	je     8006ad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069a:	89 c1                	mov    %eax,%ecx
  80069c:	c1 f9 1f             	sar    $0x1f,%ecx
  80069f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ab:	eb 19                	jmp    8006c6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b5:	89 c1                	mov    %eax,%ecx
  8006b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 40 04             	lea    0x4(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d5:	0f 89 04 01 00 00    	jns    8007df <vprintfmt+0x40b>
				putch('-', putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ee:	f7 da                	neg    %edx
  8006f0:	83 d1 00             	adc    $0x0,%ecx
  8006f3:	f7 d9                	neg    %ecx
  8006f5:	e9 e5 00 00 00       	jmp    8007df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fa:	83 f9 01             	cmp    $0x1,%ecx
  8006fd:	7e 10                	jle    80070f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	8b 48 04             	mov    0x4(%eax),%ecx
  800707:	8d 40 08             	lea    0x8(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
  80070d:	eb 26                	jmp    800735 <vprintfmt+0x361>
	else if (lflag)
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	74 12                	je     800725 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071d:	8d 40 04             	lea    0x4(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
  800723:	eb 10                	jmp    800735 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800735:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80073a:	e9 a0 00 00 00       	jmp    8007df <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80073f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800743:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80074a:	ff d6                	call   *%esi
			putch('X', putdat);
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800757:	ff d6                	call   *%esi
			putch('X', putdat);
  800759:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800764:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800769:	e9 8b fc ff ff       	jmp    8003f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800786:	ff d6                	call   *%esi
			num = (unsigned long long)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800798:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80079d:	eb 40                	jmp    8007df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079f:	83 f9 01             	cmp    $0x1,%ecx
  8007a2:	7e 10                	jle    8007b4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ac:	8d 40 08             	lea    0x8(%eax),%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b2:	eb 26                	jmp    8007da <vprintfmt+0x406>
	else if (lflag)
  8007b4:	85 c9                	test   %ecx,%ecx
  8007b6:	74 12                	je     8007ca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c8:	eb 10                	jmp    8007da <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d4:	8d 40 04             	lea    0x4(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007da:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007f2:	89 14 24             	mov    %edx,(%esp)
  8007f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f9:	89 da                	mov    %ebx,%edx
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	e8 9e fa ff ff       	call   8002a0 <printnum>
			break;
  800802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800805:	e9 ef fb ff ff       	jmp    8003f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80080a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800816:	e9 de fb ff ff       	jmp    8003f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800826:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800828:	eb 03                	jmp    80082d <vprintfmt+0x459>
  80082a:	83 ef 01             	sub    $0x1,%edi
  80082d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800831:	75 f7                	jne    80082a <vprintfmt+0x456>
  800833:	e9 c1 fb ff ff       	jmp    8003f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800838:	83 c4 3c             	add    $0x3c,%esp
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 28             	sub    $0x28,%esp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800853:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 30                	je     800891 <vsnprintf+0x51>
  800861:	85 d2                	test   %edx,%edx
  800863:	7e 2c                	jle    800891 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086c:	8b 45 10             	mov    0x10(%ebp),%eax
  80086f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800873:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087a:	c7 04 24 8f 03 80 00 	movl   $0x80038f,(%esp)
  800881:	e8 4e fb ff ff       	call   8003d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800886:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800889:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088f:	eb 05                	jmp    800896 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800891:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 82 ff ff ff       	call   800840 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 03                	jmp    8008d0 <strlen+0x10>
		n++;
  8008cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d4:	75 f7                	jne    8008cd <strlen+0xd>
		n++;
	return n;
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb 03                	jmp    8008eb <strnlen+0x13>
		n++;
  8008e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008eb:	39 d0                	cmp    %edx,%eax
  8008ed:	74 06                	je     8008f5 <strnlen+0x1d>
  8008ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f3:	75 f3                	jne    8008e8 <strnlen+0x10>
		n++;
	return n;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800901:	89 c2                	mov    %eax,%edx
  800903:	83 c2 01             	add    $0x1,%edx
  800906:	83 c1 01             	add    $0x1,%ecx
  800909:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800910:	84 db                	test   %bl,%bl
  800912:	75 ef                	jne    800903 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	53                   	push   %ebx
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800921:	89 1c 24             	mov    %ebx,(%esp)
  800924:	e8 97 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800930:	01 d8                	add    %ebx,%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	e8 bd ff ff ff       	call   8008f7 <strcpy>
	return dst;
}
  80093a:	89 d8                	mov    %ebx,%eax
  80093c:	83 c4 08             	add    $0x8,%esp
  80093f:	5b                   	pop    %ebx
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 75 08             	mov    0x8(%ebp),%esi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800952:	89 f2                	mov    %esi,%edx
  800954:	eb 0f                	jmp    800965 <strncpy+0x23>
		*dst++ = *src;
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095f:	80 39 01             	cmpb   $0x1,(%ecx)
  800962:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	39 da                	cmp    %ebx,%edx
  800967:	75 ed                	jne    800956 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800969:	89 f0                	mov    %esi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 75 08             	mov    0x8(%ebp),%esi
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80097d:	89 f0                	mov    %esi,%eax
  80097f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	85 c9                	test   %ecx,%ecx
  800985:	75 0b                	jne    800992 <strlcpy+0x23>
  800987:	eb 1d                	jmp    8009a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 0b                	je     8009a1 <strlcpy+0x32>
  800996:	0f b6 0a             	movzbl (%edx),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	75 ec                	jne    800989 <strlcpy+0x1a>
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	eb 02                	jmp    8009a3 <strlcpy+0x34>
  8009a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009a6:	29 f0                	sub    %esi,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b5:	eb 06                	jmp    8009bd <strcmp+0x11>
		p++, q++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
  8009ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bd:	0f b6 01             	movzbl (%ecx),%eax
  8009c0:	84 c0                	test   %al,%al
  8009c2:	74 04                	je     8009c8 <strcmp+0x1c>
  8009c4:	3a 02                	cmp    (%edx),%al
  8009c6:	74 ef                	je     8009b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 c0             	movzbl %al,%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 c3                	mov    %eax,%ebx
  8009de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e1:	eb 06                	jmp    8009e9 <strncmp+0x17>
		n--, p++, q++;
  8009e3:	83 c0 01             	add    $0x1,%eax
  8009e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e9:	39 d8                	cmp    %ebx,%eax
  8009eb:	74 15                	je     800a02 <strncmp+0x30>
  8009ed:	0f b6 08             	movzbl (%eax),%ecx
  8009f0:	84 c9                	test   %cl,%cl
  8009f2:	74 04                	je     8009f8 <strncmp+0x26>
  8009f4:	3a 0a                	cmp    (%edx),%cl
  8009f6:	74 eb                	je     8009e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f8:	0f b6 00             	movzbl (%eax),%eax
  8009fb:	0f b6 12             	movzbl (%edx),%edx
  8009fe:	29 d0                	sub    %edx,%eax
  800a00:	eb 05                	jmp    800a07 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	eb 07                	jmp    800a1d <strchr+0x13>
		if (*s == c)
  800a16:	38 ca                	cmp    %cl,%dl
  800a18:	74 0f                	je     800a29 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	eb 07                	jmp    800a3e <strfind+0x13>
		if (*s == c)
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	74 0a                	je     800a45 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	0f b6 10             	movzbl (%eax),%edx
  800a41:	84 d2                	test   %dl,%dl
  800a43:	75 f2                	jne    800a37 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a53:	85 c9                	test   %ecx,%ecx
  800a55:	74 36                	je     800a8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a57:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5d:	75 28                	jne    800a87 <memset+0x40>
  800a5f:	f6 c1 03             	test   $0x3,%cl
  800a62:	75 23                	jne    800a87 <memset+0x40>
		c &= 0xFF;
  800a64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	c1 e3 08             	shl    $0x8,%ebx
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	c1 e6 18             	shl    $0x18,%esi
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	c1 e0 10             	shl    $0x10,%eax
  800a77:	09 f0                	or     %esi,%eax
  800a79:	09 c2                	or     %eax,%edx
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a7f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a82:	fc                   	cld    
  800a83:	f3 ab                	rep stos %eax,%es:(%edi)
  800a85:	eb 06                	jmp    800a8d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8d:	89 f8                	mov    %edi,%eax
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 35                	jae    800adb <memmove+0x47>
  800aa6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa9:	39 d0                	cmp    %edx,%eax
  800aab:	73 2e                	jae    800adb <memmove+0x47>
		s += n;
		d += n;
  800aad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aba:	75 13                	jne    800acf <memmove+0x3b>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 0e                	jne    800acf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac1:	83 ef 04             	sub    $0x4,%edi
  800ac4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aca:	fd                   	std    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 09                	jmp    800ad8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acf:	83 ef 01             	sub    $0x1,%edi
  800ad2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad5:	fd                   	std    
  800ad6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad8:	fc                   	cld    
  800ad9:	eb 1d                	jmp    800af8 <memmove+0x64>
  800adb:	89 f2                	mov    %esi,%edx
  800add:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	f6 c2 03             	test   $0x3,%dl
  800ae2:	75 0f                	jne    800af3 <memmove+0x5f>
  800ae4:	f6 c1 03             	test   $0x3,%cl
  800ae7:	75 0a                	jne    800af3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af1:	eb 05                	jmp    800af8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	fc                   	cld    
  800af6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 79 ff ff ff       	call   800a94 <memmove>
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2d:	eb 1a                	jmp    800b49 <memcmp+0x2c>
		if (*s1 != *s2)
  800b2f:	0f b6 02             	movzbl (%edx),%eax
  800b32:	0f b6 19             	movzbl (%ecx),%ebx
  800b35:	38 d8                	cmp    %bl,%al
  800b37:	74 0a                	je     800b43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c0             	movzbl %al,%eax
  800b3c:	0f b6 db             	movzbl %bl,%ebx
  800b3f:	29 d8                	sub    %ebx,%eax
  800b41:	eb 0f                	jmp    800b52 <memcmp+0x35>
		s1++, s2++;
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b49:	39 f2                	cmp    %esi,%edx
  800b4b:	75 e2                	jne    800b2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b5f:	89 c2                	mov    %eax,%edx
  800b61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b64:	eb 07                	jmp    800b6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b66:	38 08                	cmp    %cl,(%eax)
  800b68:	74 07                	je     800b71 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	39 d0                	cmp    %edx,%eax
  800b6f:	72 f5                	jb     800b66 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7f:	eb 03                	jmp    800b84 <strtol+0x11>
		s++;
  800b81:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b84:	0f b6 0a             	movzbl (%edx),%ecx
  800b87:	80 f9 09             	cmp    $0x9,%cl
  800b8a:	74 f5                	je     800b81 <strtol+0xe>
  800b8c:	80 f9 20             	cmp    $0x20,%cl
  800b8f:	74 f0                	je     800b81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b91:	80 f9 2b             	cmp    $0x2b,%cl
  800b94:	75 0a                	jne    800ba0 <strtol+0x2d>
		s++;
  800b96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9e:	eb 11                	jmp    800bb1 <strtol+0x3e>
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba5:	80 f9 2d             	cmp    $0x2d,%cl
  800ba8:	75 07                	jne    800bb1 <strtol+0x3e>
		s++, neg = 1;
  800baa:	8d 52 01             	lea    0x1(%edx),%edx
  800bad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bb6:	75 15                	jne    800bcd <strtol+0x5a>
  800bb8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbb:	75 10                	jne    800bcd <strtol+0x5a>
  800bbd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc1:	75 0a                	jne    800bcd <strtol+0x5a>
		s += 2, base = 16;
  800bc3:	83 c2 02             	add    $0x2,%edx
  800bc6:	b8 10 00 00 00       	mov    $0x10,%eax
  800bcb:	eb 10                	jmp    800bdd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	75 0c                	jne    800bdd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd6:	75 05                	jne    800bdd <strtol+0x6a>
		s++, base = 8;
  800bd8:	83 c2 01             	add    $0x1,%edx
  800bdb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 0a             	movzbl (%edx),%ecx
  800be8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800beb:	89 f0                	mov    %esi,%eax
  800bed:	3c 09                	cmp    $0x9,%al
  800bef:	77 08                	ja     800bf9 <strtol+0x86>
			dig = *s - '0';
  800bf1:	0f be c9             	movsbl %cl,%ecx
  800bf4:	83 e9 30             	sub    $0x30,%ecx
  800bf7:	eb 20                	jmp    800c19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bf9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bfc:	89 f0                	mov    %esi,%eax
  800bfe:	3c 19                	cmp    $0x19,%al
  800c00:	77 08                	ja     800c0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c02:	0f be c9             	movsbl %cl,%ecx
  800c05:	83 e9 57             	sub    $0x57,%ecx
  800c08:	eb 0f                	jmp    800c19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	3c 19                	cmp    $0x19,%al
  800c11:	77 16                	ja     800c29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c13:	0f be c9             	movsbl %cl,%ecx
  800c16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c1c:	7d 0f                	jge    800c2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c27:	eb bc                	jmp    800be5 <strtol+0x72>
  800c29:	89 d8                	mov    %ebx,%eax
  800c2b:	eb 02                	jmp    800c2f <strtol+0xbc>
  800c2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c33:	74 05                	je     800c3a <strtol+0xc7>
		*endptr = (char *) s;
  800c35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c3a:	f7 d8                	neg    %eax
  800c3c:	85 ff                	test   %edi,%edi
  800c3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	89 c7                	mov    %eax,%edi
  800c5b:	89 c6                	mov    %eax,%esi
  800c5d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c91:	b8 03 00 00 00       	mov    $0x3,%eax
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 cb                	mov    %ecx,%ebx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	89 ce                	mov    %ecx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 28                	jle    800ccd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800cb8:	00 
  800cb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc0:	00 
  800cc1:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800cc8:	e8 b2 f4 ff ff       	call   80017f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ccd:	83 c4 2c             	add    $0x2c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_yield>:

void
sys_yield(void)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800cff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d04:	89 d1                	mov    %edx,%ecx
  800d06:	89 d3                	mov    %edx,%ebx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	be 00 00 00 00       	mov    $0x0,%esi
  800d21:	b8 04 00 00 00       	mov    $0x4,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	89 f7                	mov    %esi,%edi
  800d31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800d5a:	e8 20 f4 ff ff       	call   80017f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	83 c4 2c             	add    $0x2c,%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 28                	jle    800db2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d95:	00 
  800d96:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da5:	00 
  800da6:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800dad:	e8 cd f3 ff ff       	call   80017f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db2:	83 c4 2c             	add    $0x2c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800e00:	e8 7a f3 ff ff       	call   80017f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800e53:	e8 27 f3 ff ff       	call   80017f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 df                	mov    %ebx,%edi
  800e7b:	89 de                	mov    %ebx,%esi
  800e7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	7e 28                	jle    800eab <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e87:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800ea6:	e8 d4 f2 ff ff       	call   80017f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eab:	83 c4 2c             	add    $0x2c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	be 00 00 00 00       	mov    $0x0,%esi
  800ebe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
  800edc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	89 cb                	mov    %ecx,%ebx
  800eee:	89 cf                	mov    %ecx,%edi
  800ef0:	89 ce                	mov    %ecx,%esi
  800ef2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 28                	jle    800f20 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f03:	00 
  800f04:	c7 44 24 08 e8 14 80 	movl   $0x8014e8,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 05 15 80 00 	movl   $0x801505,(%esp)
  800f1b:	e8 5f f2 ff ff       	call   80017f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f20:	83 c4 2c             	add    $0x2c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f2e:	c7 44 24 08 1f 15 80 	movl   $0x80151f,0x8(%esp)
  800f35:	00 
  800f36:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 13 15 80 00 	movl   $0x801513,(%esp)
  800f45:	e8 35 f2 ff ff       	call   80017f <_panic>

00800f4a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f50:	c7 44 24 08 1e 15 80 	movl   $0x80151e,0x8(%esp)
  800f57:	00 
  800f58:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f5f:	00 
  800f60:	c7 04 24 13 15 80 00 	movl   $0x801513,(%esp)
  800f67:	e8 13 f2 ff ff       	call   80017f <_panic>
  800f6c:	00 00                	add    %al,(%eax)
	...

00800f70 <__udivdi3>:
  800f70:	83 ec 1c             	sub    $0x1c,%esp
  800f73:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f83:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f87:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f8b:	85 ff                	test   %edi,%edi
  800f8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f95:	89 cd                	mov    %ecx,%ebp
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	75 33                	jne    800fd0 <__udivdi3+0x60>
  800f9d:	39 f1                	cmp    %esi,%ecx
  800f9f:	77 57                	ja     800ff8 <__udivdi3+0x88>
  800fa1:	85 c9                	test   %ecx,%ecx
  800fa3:	75 0b                	jne    800fb0 <__udivdi3+0x40>
  800fa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800faa:	31 d2                	xor    %edx,%edx
  800fac:	f7 f1                	div    %ecx
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	31 d2                	xor    %edx,%edx
  800fb4:	f7 f1                	div    %ecx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fbc:	f7 f1                	div    %ecx
  800fbe:	89 f2                	mov    %esi,%edx
  800fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fcc:	83 c4 1c             	add    $0x1c,%esp
  800fcf:	c3                   	ret    
  800fd0:	31 d2                	xor    %edx,%edx
  800fd2:	31 c0                	xor    %eax,%eax
  800fd4:	39 f7                	cmp    %esi,%edi
  800fd6:	77 e8                	ja     800fc0 <__udivdi3+0x50>
  800fd8:	0f bd cf             	bsr    %edi,%ecx
  800fdb:	83 f1 1f             	xor    $0x1f,%ecx
  800fde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fe2:	75 2c                	jne    801010 <__udivdi3+0xa0>
  800fe4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fe8:	76 04                	jbe    800fee <__udivdi3+0x7e>
  800fea:	39 f7                	cmp    %esi,%edi
  800fec:	73 d2                	jae    800fc0 <__udivdi3+0x50>
  800fee:	31 d2                	xor    %edx,%edx
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff5:	eb c9                	jmp    800fc0 <__udivdi3+0x50>
  800ff7:	90                   	nop
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	f7 f1                	div    %ecx
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801002:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801006:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80100a:	83 c4 1c             	add    $0x1c,%esp
  80100d:	c3                   	ret    
  80100e:	66 90                	xchg   %ax,%ax
  801010:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801015:	b8 20 00 00 00       	mov    $0x20,%eax
  80101a:	89 ea                	mov    %ebp,%edx
  80101c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801020:	d3 e7                	shl    %cl,%edi
  801022:	89 c1                	mov    %eax,%ecx
  801024:	d3 ea                	shr    %cl,%edx
  801026:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102b:	09 fa                	or     %edi,%edx
  80102d:	89 f7                	mov    %esi,%edi
  80102f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801033:	89 f2                	mov    %esi,%edx
  801035:	8b 74 24 08          	mov    0x8(%esp),%esi
  801039:	d3 e5                	shl    %cl,%ebp
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	d3 ef                	shr    %cl,%edi
  80103f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801044:	d3 e2                	shl    %cl,%edx
  801046:	89 c1                	mov    %eax,%ecx
  801048:	d3 ee                	shr    %cl,%esi
  80104a:	09 d6                	or     %edx,%esi
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	f7 74 24 0c          	divl   0xc(%esp)
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 c6                	mov    %eax,%esi
  801058:	f7 e5                	mul    %ebp
  80105a:	39 d7                	cmp    %edx,%edi
  80105c:	72 22                	jb     801080 <__udivdi3+0x110>
  80105e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801062:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801067:	d3 e5                	shl    %cl,%ebp
  801069:	39 c5                	cmp    %eax,%ebp
  80106b:	73 04                	jae    801071 <__udivdi3+0x101>
  80106d:	39 d7                	cmp    %edx,%edi
  80106f:	74 0f                	je     801080 <__udivdi3+0x110>
  801071:	89 f0                	mov    %esi,%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	e9 46 ff ff ff       	jmp    800fc0 <__udivdi3+0x50>
  80107a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801080:	8d 46 ff             	lea    -0x1(%esi),%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	8b 74 24 10          	mov    0x10(%esp),%esi
  801089:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80108d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	c3                   	ret    
	...

008010a0 <__umoddi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ed                	test   %ebp,%ebp
  8010bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cf                	mov    %ecx,%edi
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	89 f2                	mov    %esi,%edx
  8010cc:	75 1a                	jne    8010e8 <__umoddi3+0x48>
  8010ce:	39 f1                	cmp    %esi,%ecx
  8010d0:	76 4e                	jbe    801120 <__umoddi3+0x80>
  8010d2:	f7 f1                	div    %ecx
  8010d4:	89 d0                	mov    %edx,%eax
  8010d6:	31 d2                	xor    %edx,%edx
  8010d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010e4:	83 c4 1c             	add    $0x1c,%esp
  8010e7:	c3                   	ret    
  8010e8:	39 f5                	cmp    %esi,%ebp
  8010ea:	77 54                	ja     801140 <__umoddi3+0xa0>
  8010ec:	0f bd c5             	bsr    %ebp,%eax
  8010ef:	83 f0 1f             	xor    $0x1f,%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	75 60                	jne    801158 <__umoddi3+0xb8>
  8010f8:	3b 0c 24             	cmp    (%esp),%ecx
  8010fb:	0f 87 07 01 00 00    	ja     801208 <__umoddi3+0x168>
  801101:	89 f2                	mov    %esi,%edx
  801103:	8b 34 24             	mov    (%esp),%esi
  801106:	29 ce                	sub    %ecx,%esi
  801108:	19 ea                	sbb    %ebp,%edx
  80110a:	89 34 24             	mov    %esi,(%esp)
  80110d:	8b 04 24             	mov    (%esp),%eax
  801110:	8b 74 24 10          	mov    0x10(%esp),%esi
  801114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	c3                   	ret    
  801120:	85 c9                	test   %ecx,%ecx
  801122:	75 0b                	jne    80112f <__umoddi3+0x8f>
  801124:	b8 01 00 00 00       	mov    $0x1,%eax
  801129:	31 d2                	xor    %edx,%edx
  80112b:	f7 f1                	div    %ecx
  80112d:	89 c1                	mov    %eax,%ecx
  80112f:	89 f0                	mov    %esi,%eax
  801131:	31 d2                	xor    %edx,%edx
  801133:	f7 f1                	div    %ecx
  801135:	8b 04 24             	mov    (%esp),%eax
  801138:	f7 f1                	div    %ecx
  80113a:	eb 98                	jmp    8010d4 <__umoddi3+0x34>
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	89 f2                	mov    %esi,%edx
  801142:	8b 74 24 10          	mov    0x10(%esp),%esi
  801146:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80114a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114e:	83 c4 1c             	add    $0x1c,%esp
  801151:	c3                   	ret    
  801152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801158:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115d:	89 e8                	mov    %ebp,%eax
  80115f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801164:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 e0                	shl    %cl,%eax
  80116c:	89 e9                	mov    %ebp,%ecx
  80116e:	d3 ea                	shr    %cl,%edx
  801170:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801175:	09 c2                	or     %eax,%edx
  801177:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117b:	89 14 24             	mov    %edx,(%esp)
  80117e:	89 f2                	mov    %esi,%edx
  801180:	d3 e7                	shl    %cl,%edi
  801182:	89 e9                	mov    %ebp,%ecx
  801184:	d3 ea                	shr    %cl,%edx
  801186:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118f:	d3 e6                	shl    %cl,%esi
  801191:	89 e9                	mov    %ebp,%ecx
  801193:	d3 e8                	shr    %cl,%eax
  801195:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80119a:	09 f0                	or     %esi,%eax
  80119c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011a0:	f7 34 24             	divl   (%esp)
  8011a3:	d3 e6                	shl    %cl,%esi
  8011a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011a9:	89 d6                	mov    %edx,%esi
  8011ab:	f7 e7                	mul    %edi
  8011ad:	39 d6                	cmp    %edx,%esi
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	89 d7                	mov    %edx,%edi
  8011b3:	72 3f                	jb     8011f4 <__umoddi3+0x154>
  8011b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011b9:	72 35                	jb     8011f0 <__umoddi3+0x150>
  8011bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011bf:	29 c8                	sub    %ecx,%eax
  8011c1:	19 fe                	sbb    %edi,%esi
  8011c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	d3 e8                	shr    %cl,%eax
  8011cc:	89 e9                	mov    %ebp,%ecx
  8011ce:	d3 e2                	shl    %cl,%edx
  8011d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011d5:	09 d0                	or     %edx,%eax
  8011d7:	89 f2                	mov    %esi,%edx
  8011d9:	d3 ea                	shr    %cl,%edx
  8011db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e7:	83 c4 1c             	add    $0x1c,%esp
  8011ea:	c3                   	ret    
  8011eb:	90                   	nop
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 d6                	cmp    %edx,%esi
  8011f2:	75 c7                	jne    8011bb <__umoddi3+0x11b>
  8011f4:	89 d7                	mov    %edx,%edi
  8011f6:	89 c1                	mov    %eax,%ecx
  8011f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011fc:	1b 3c 24             	sbb    (%esp),%edi
  8011ff:	eb ba                	jmp    8011bb <__umoddi3+0x11b>
  801201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801208:	39 f5                	cmp    %esi,%ebp
  80120a:	0f 82 f1 fe ff ff    	jb     801101 <__umoddi3+0x61>
  801210:	e9 f8 fe ff ff       	jmp    80110d <__umoddi3+0x6d>
