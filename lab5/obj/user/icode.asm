
obj/user/icode.debug：     文件格式 elf32-i386


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
  80002c:	e8 27 01 00 00       	call   800158 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 40 	movl   $0x802740,0x803000
  800045:	27 80 00 

	cprintf("icode startup\n");
  800048:	c7 04 24 46 27 80 00 	movl   $0x802746,(%esp)
  80004f:	e8 59 02 00 00       	call   8002ad <cprintf>

	cprintf("icode: open /motd\n");
  800054:	c7 04 24 55 27 80 00 	movl   $0x802755,(%esp)
  80005b:	e8 4d 02 00 00       	call   8002ad <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800060:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800067:	00 
  800068:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  80006f:	e8 ed 16 00 00       	call   801761 <open>
  800074:	89 c6                	mov    %eax,%esi
  800076:	85 c0                	test   %eax,%eax
  800078:	79 20                	jns    80009a <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007e:	c7 44 24 08 6e 27 80 	movl   $0x80276e,0x8(%esp)
  800085:	00 
  800086:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008d:	00 
  80008e:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  800095:	e8 1a 01 00 00       	call   8001b4 <_panic>

	cprintf("icode: read /motd\n");
  80009a:	c7 04 24 91 27 80 00 	movl   $0x802791,(%esp)
  8000a1:	e8 07 02 00 00       	call   8002ad <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a6:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ac:	eb 0c                	jmp    8000ba <umain+0x87>
		sys_cputs(buf, n);
  8000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b2:	89 1c 24             	mov    %ebx,(%esp)
  8000b5:	e8 bc 0b 00 00       	call   800c76 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ba:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c1:	00 
  8000c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c6:	89 34 24             	mov    %esi,(%esp)
  8000c9:	e8 e7 11 00 00       	call   8012b5 <read>
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	7f dc                	jg     8000ae <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d2:	c7 04 24 a4 27 80 00 	movl   $0x8027a4,(%esp)
  8000d9:	e8 cf 01 00 00       	call   8002ad <cprintf>
	close(fd);
  8000de:	89 34 24             	mov    %esi,(%esp)
  8000e1:	e8 6c 10 00 00       	call   801152 <close>

	cprintf("icode: spawn /init\n");
  8000e6:	c7 04 24 b8 27 80 00 	movl   $0x8027b8,(%esp)
  8000ed:	e8 bb 01 00 00       	call   8002ad <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000f9:	00 
  8000fa:	c7 44 24 0c cc 27 80 	movl   $0x8027cc,0xc(%esp)
  800101:	00 
  800102:	c7 44 24 08 d5 27 80 	movl   $0x8027d5,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 df 27 80 	movl   $0x8027df,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 de 27 80 00 	movl   $0x8027de,(%esp)
  800119:	e8 19 1c 00 00       	call   801d37 <spawnl>
  80011e:	85 c0                	test   %eax,%eax
  800120:	79 20                	jns    800142 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800122:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800126:	c7 44 24 08 e4 27 80 	movl   $0x8027e4,0x8(%esp)
  80012d:	00 
  80012e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800135:	00 
  800136:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  80013d:	e8 72 00 00 00       	call   8001b4 <_panic>

	cprintf("icode: exiting\n");
  800142:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  800149:	e8 5f 01 00 00       	call   8002ad <cprintf>
}
  80014e:	81 c4 30 02 00 00    	add    $0x230,%esp
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 10             	sub    $0x10,%esp
  800160:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800163:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800166:	e8 9a 0b 00 00       	call   800d05 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017d:	85 db                	test   %ebx,%ebx
  80017f:	7e 07                	jle    800188 <libmain+0x30>
		binaryname = argv[0];
  800181:	8b 06                	mov    (%esi),%eax
  800183:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	89 1c 24             	mov    %ebx,(%esp)
  80018f:	e8 9f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800194:	e8 07 00 00 00       	call   8001a0 <exit>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 01 0b 00 00       	call   800cb3 <sys_env_destroy>
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
  8001bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001c5:	e8 3b 0b 00 00       	call   800d05 <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 18 28 80 00 	movl   $0x802818,(%esp)
  8001e7:	e8 c1 00 00 00       	call   8002ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 51 00 00 00       	call   80024c <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 fe 2c 80 00 	movl   $0x802cfe,(%esp)
  800202:	e8 a6 00 00 00       	call   8002ad <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>

0080020a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	53                   	push   %ebx
  80020e:	83 ec 14             	sub    $0x14,%esp
  800211:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800214:	8b 13                	mov    (%ebx),%edx
  800216:	8d 42 01             	lea    0x1(%edx),%eax
  800219:	89 03                	mov    %eax,(%ebx)
  80021b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800222:	3d ff 00 00 00       	cmp    $0xff,%eax
  800227:	75 19                	jne    800242 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800229:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800230:	00 
  800231:	8d 43 08             	lea    0x8(%ebx),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 3a 0a 00 00       	call   800c76 <sys_cputs>
		b->idx = 0;
  80023c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800242:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800246:	83 c4 14             	add    $0x14,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800255:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025c:	00 00 00 
	b.cnt = 0;
  80025f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800266:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800269:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	89 44 24 08          	mov    %eax,0x8(%esp)
  800277:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	c7 04 24 0a 02 80 00 	movl   $0x80020a,(%esp)
  800288:	e8 77 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	e8 d1 09 00 00       	call   800c76 <sys_cputs>

	return b.cnt;
}
  8002a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	e8 87 ff ff ff       	call   80024c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    
  8002c7:	66 90                	xchg   %ax,%ax
  8002c9:	66 90                	xchg   %ax,%ax
  8002cb:	66 90                	xchg   %ax,%ax
  8002cd:	66 90                	xchg   %ax,%ax
  8002cf:	90                   	nop

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
  80033f:	e8 5c 21 00 00       	call   8024a0 <__udivdi3>
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
  80039f:	e8 2c 22 00 00       	call   8025d0 <__umoddi3>
  8003a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a8:	0f be 80 3b 28 80 00 	movsbl 0x80283b(%eax),%eax
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
  80048f:	ff 24 95 80 29 80 00 	jmp    *0x802980(,%edx,4)
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
  800537:	83 f8 0f             	cmp    $0xf,%eax
  80053a:	7f 0b                	jg     800547 <vprintfmt+0x143>
  80053c:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	75 20                	jne    800567 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800547:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054b:	c7 44 24 08 53 28 80 	movl   $0x802853,0x8(%esp)
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
  80056b:	c7 44 24 08 3a 2c 80 	movl   $0x802c3a,0x8(%esp)
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
  80059b:	b8 4c 28 80 00       	mov    $0x80284c,%eax
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
  800ce1:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf0:	00 
  800cf1:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800cf8:	e8 b7 f4 ff ff       	call   8001b4 <_panic>

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
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800d73:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d82:	00 
  800d83:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800d8a:	e8 25 f4 ff ff       	call   8001b4 <_panic>

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
  800dc6:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800dcd:	00 
  800dce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd5:	00 
  800dd6:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800ddd:	e8 d2 f3 ff ff       	call   8001b4 <_panic>

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
  800e19:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800e20:	00 
  800e21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e28:	00 
  800e29:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800e30:	e8 7f f3 ff ff       	call   8001b4 <_panic>

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
  800e6c:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800e73:	00 
  800e74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7b:	00 
  800e7c:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800e83:	e8 2c f3 ff ff       	call   8001b4 <_panic>

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

00800e90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800eb1:	7e 28                	jle    800edb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ece:	00 
  800ecf:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800ed6:	e8 d9 f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800edb:	83 c4 2c             	add    $0x2c,%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	89 df                	mov    %ebx,%edi
  800efe:	89 de                	mov    %ebx,%esi
  800f00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7e 28                	jle    800f2e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f29:	e8 86 f2 ff ff       	call   8001b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2e:	83 c4 2c             	add    $0x2c,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3c:	be 00 00 00 00       	mov    $0x0,%esi
  800f41:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f52:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f67:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 cb                	mov    %ecx,%ebx
  800f71:	89 cf                	mov    %ecx,%edi
  800f73:	89 ce                	mov    %ecx,%esi
  800f75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f77:	85 c0                	test   %eax,%eax
  800f79:	7e 28                	jle    800fa3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f86:	00 
  800f87:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f96:	00 
  800f97:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f9e:	e8 11 f2 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa3:	83 c4 2c             	add    $0x2c,%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	66 90                	xchg   %ax,%ax
  800fad:	66 90                	xchg   %ax,%ax
  800faf:	90                   	nop

00800fb0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fbb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fdd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	c1 ea 16             	shr    $0x16,%edx
  800fe7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fee:	f6 c2 01             	test   $0x1,%dl
  800ff1:	74 11                	je     801004 <fd_alloc+0x2d>
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	c1 ea 0c             	shr    $0xc,%edx
  800ff8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fff:	f6 c2 01             	test   $0x1,%dl
  801002:	75 09                	jne    80100d <fd_alloc+0x36>
			*fd_store = fd;
  801004:	89 01                	mov    %eax,(%ecx)
			return 0;
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
  80100b:	eb 17                	jmp    801024 <fd_alloc+0x4d>
  80100d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801012:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801017:	75 c9                	jne    800fe2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801019:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80101f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80102c:	83 f8 1f             	cmp    $0x1f,%eax
  80102f:	77 36                	ja     801067 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801031:	c1 e0 0c             	shl    $0xc,%eax
  801034:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801039:	89 c2                	mov    %eax,%edx
  80103b:	c1 ea 16             	shr    $0x16,%edx
  80103e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801045:	f6 c2 01             	test   $0x1,%dl
  801048:	74 24                	je     80106e <fd_lookup+0x48>
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	c1 ea 0c             	shr    $0xc,%edx
  80104f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801056:	f6 c2 01             	test   $0x1,%dl
  801059:	74 1a                	je     801075 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80105b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105e:	89 02                	mov    %eax,(%edx)
	return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
  801065:	eb 13                	jmp    80107a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801067:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80106c:	eb 0c                	jmp    80107a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80106e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801073:	eb 05                	jmp    80107a <fd_lookup+0x54>
  801075:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 18             	sub    $0x18,%esp
  801082:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801085:	ba e8 2b 80 00       	mov    $0x802be8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80108a:	eb 13                	jmp    80109f <dev_lookup+0x23>
  80108c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80108f:	39 08                	cmp    %ecx,(%eax)
  801091:	75 0c                	jne    80109f <dev_lookup+0x23>
			*dev = devtab[i];
  801093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801096:	89 01                	mov    %eax,(%ecx)
			return 0;
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	eb 30                	jmp    8010cf <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80109f:	8b 02                	mov    (%edx),%eax
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	75 e7                	jne    80108c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010aa:	8b 40 48             	mov    0x48(%eax),%eax
  8010ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  8010bc:	e8 ec f1 ff ff       	call   8002ad <cprintf>
	*dev = 0;
  8010c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 20             	sub    $0x20,%esp
  8010d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 2f ff ff ff       	call   801026 <fd_lookup>
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 05                	js     801100 <fd_close+0x2f>
	    || fd != fd2)
  8010fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010fe:	74 0c                	je     80110c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801100:	84 db                	test   %bl,%bl
  801102:	ba 00 00 00 00       	mov    $0x0,%edx
  801107:	0f 44 c2             	cmove  %edx,%eax
  80110a:	eb 3f                	jmp    80114b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80110c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801113:	8b 06                	mov    (%esi),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 5f ff ff ff       	call   80107c <dev_lookup>
  80111d:	89 c3                	mov    %eax,%ebx
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 16                	js     801139 <fd_close+0x68>
		if (dev->dev_close)
  801123:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801126:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80112e:	85 c0                	test   %eax,%eax
  801130:	74 07                	je     801139 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801132:	89 34 24             	mov    %esi,(%esp)
  801135:	ff d0                	call   *%eax
  801137:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801139:	89 74 24 04          	mov    %esi,0x4(%esp)
  80113d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801144:	e8 a1 fc ff ff       	call   800dea <sys_page_unmap>
	return r;
  801149:	89 d8                	mov    %ebx,%eax
}
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	89 04 24             	mov    %eax,(%esp)
  801165:	e8 bc fe ff ff       	call   801026 <fd_lookup>
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	85 d2                	test   %edx,%edx
  80116e:	78 13                	js     801183 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801170:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801177:	00 
  801178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 4e ff ff ff       	call   8010d1 <fd_close>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <close_all>:

void
close_all(void)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	53                   	push   %ebx
  801189:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80118c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801191:	89 1c 24             	mov    %ebx,(%esp)
  801194:	e8 b9 ff ff ff       	call   801152 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801199:	83 c3 01             	add    $0x1,%ebx
  80119c:	83 fb 20             	cmp    $0x20,%ebx
  80119f:	75 f0                	jne    801191 <close_all+0xc>
		close(i);
}
  8011a1:	83 c4 14             	add    $0x14,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 64 fe ff ff       	call   801026 <fd_lookup>
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	0f 88 e1 00 00 00    	js     8012ad <dup+0x106>
		return r;
	close(newfdnum);
  8011cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 7b ff ff ff       	call   801152 <close>

	newfd = INDEX2FD(newfdnum);
  8011d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011da:	c1 e3 0c             	shl    $0xc,%ebx
  8011dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 d2 fd ff ff       	call   800fc0 <fd2data>
  8011ee:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8011f0:	89 1c 24             	mov    %ebx,(%esp)
  8011f3:	e8 c8 fd ff ff       	call   800fc0 <fd2data>
  8011f8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011fa:	89 f0                	mov    %esi,%eax
  8011fc:	c1 e8 16             	shr    $0x16,%eax
  8011ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801206:	a8 01                	test   $0x1,%al
  801208:	74 43                	je     80124d <dup+0xa6>
  80120a:	89 f0                	mov    %esi,%eax
  80120c:	c1 e8 0c             	shr    $0xc,%eax
  80120f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 32                	je     80124d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801222:	25 07 0e 00 00       	and    $0xe07,%eax
  801227:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801236:	00 
  801237:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801242:	e8 50 fb ff ff       	call   800d97 <sys_page_map>
  801247:	89 c6                	mov    %eax,%esi
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 3e                	js     80128b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80124d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 0c             	shr    $0xc,%edx
  801255:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801262:	89 54 24 10          	mov    %edx,0x10(%esp)
  801266:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80126a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801271:	00 
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127d:	e8 15 fb ff ff       	call   800d97 <sys_page_map>
  801282:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801287:	85 f6                	test   %esi,%esi
  801289:	79 22                	jns    8012ad <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80128b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 4f fb ff ff       	call   800dea <sys_page_unmap>
	sys_page_unmap(0, nva);
  80129b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80129f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a6:	e8 3f fb ff ff       	call   800dea <sys_page_unmap>
	return r;
  8012ab:	89 f0                	mov    %esi,%eax
}
  8012ad:	83 c4 3c             	add    $0x3c,%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 24             	sub    $0x24,%esp
  8012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c6:	89 1c 24             	mov    %ebx,(%esp)
  8012c9:	e8 58 fd ff ff       	call   801026 <fd_lookup>
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	85 d2                	test   %edx,%edx
  8012d2:	78 6d                	js     801341 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012de:	8b 00                	mov    (%eax),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 94 fd ff ff       	call   80107c <dev_lookup>
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 55                	js     801341 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 50 08             	mov    0x8(%eax),%edx
  8012f2:	83 e2 03             	and    $0x3,%edx
  8012f5:	83 fa 01             	cmp    $0x1,%edx
  8012f8:	75 23                	jne    80131d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
  801302:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130a:	c7 04 24 ad 2b 80 00 	movl   $0x802bad,(%esp)
  801311:	e8 97 ef ff ff       	call   8002ad <cprintf>
		return -E_INVAL;
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb 24                	jmp    801341 <read+0x8c>
	}
	if (!dev->dev_read)
  80131d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801320:	8b 52 08             	mov    0x8(%edx),%edx
  801323:	85 d2                	test   %edx,%edx
  801325:	74 15                	je     80133c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801327:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80132a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801331:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	ff d2                	call   *%edx
  80133a:	eb 05                	jmp    801341 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801341:	83 c4 24             	add    $0x24,%esp
  801344:	5b                   	pop    %ebx
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	57                   	push   %edi
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 1c             	sub    $0x1c,%esp
  801350:	8b 7d 08             	mov    0x8(%ebp),%edi
  801353:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801356:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135b:	eb 23                	jmp    801380 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80135d:	89 f0                	mov    %esi,%eax
  80135f:	29 d8                	sub    %ebx,%eax
  801361:	89 44 24 08          	mov    %eax,0x8(%esp)
  801365:	89 d8                	mov    %ebx,%eax
  801367:	03 45 0c             	add    0xc(%ebp),%eax
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	89 3c 24             	mov    %edi,(%esp)
  801371:	e8 3f ff ff ff       	call   8012b5 <read>
		if (m < 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	78 10                	js     80138a <readn+0x43>
			return m;
		if (m == 0)
  80137a:	85 c0                	test   %eax,%eax
  80137c:	74 0a                	je     801388 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80137e:	01 c3                	add    %eax,%ebx
  801380:	39 f3                	cmp    %esi,%ebx
  801382:	72 d9                	jb     80135d <readn+0x16>
  801384:	89 d8                	mov    %ebx,%eax
  801386:	eb 02                	jmp    80138a <readn+0x43>
  801388:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80138a:	83 c4 1c             	add    $0x1c,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 24             	sub    $0x24,%esp
  801399:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	e8 7b fc ff ff       	call   801026 <fd_lookup>
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	85 d2                	test   %edx,%edx
  8013af:	78 68                	js     801419 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	8b 00                	mov    (%eax),%eax
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	e8 b7 fc ff ff       	call   80107c <dev_lookup>
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 50                	js     801419 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013d0:	75 23                	jne    8013f5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d7:	8b 40 48             	mov    0x48(%eax),%eax
  8013da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e2:	c7 04 24 c9 2b 80 00 	movl   $0x802bc9,(%esp)
  8013e9:	e8 bf ee ff ff       	call   8002ad <cprintf>
		return -E_INVAL;
  8013ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f3:	eb 24                	jmp    801419 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fb:	85 d2                	test   %edx,%edx
  8013fd:	74 15                	je     801414 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801402:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801409:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	ff d2                	call   *%edx
  801412:	eb 05                	jmp    801419 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801414:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801419:	83 c4 24             	add    $0x24,%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <seek>:

int
seek(int fdnum, off_t offset)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801425:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 ef fb ff ff       	call   801026 <fd_lookup>
  801437:	85 c0                	test   %eax,%eax
  801439:	78 0e                	js     801449 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80143b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80143e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801441:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 24             	sub    $0x24,%esp
  801452:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145c:	89 1c 24             	mov    %ebx,(%esp)
  80145f:	e8 c2 fb ff ff       	call   801026 <fd_lookup>
  801464:	89 c2                	mov    %eax,%edx
  801466:	85 d2                	test   %edx,%edx
  801468:	78 61                	js     8014cb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801474:	8b 00                	mov    (%eax),%eax
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 fe fb ff ff       	call   80107c <dev_lookup>
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 49                	js     8014cb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801485:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801489:	75 23                	jne    8014ae <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80148b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801490:	8b 40 48             	mov    0x48(%eax),%eax
  801493:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8014a2:	e8 06 ee ff ff       	call   8002ad <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ac:	eb 1d                	jmp    8014cb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b1:	8b 52 18             	mov    0x18(%edx),%edx
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 0e                	je     8014c6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	ff d2                	call   *%edx
  8014c4:	eb 05                	jmp    8014cb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014cb:	83 c4 24             	add    $0x24,%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 24             	sub    $0x24,%esp
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	89 04 24             	mov    %eax,(%esp)
  8014e8:	e8 39 fb ff ff       	call   801026 <fd_lookup>
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 d2                	test   %edx,%edx
  8014f1:	78 52                	js     801545 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	8b 00                	mov    (%eax),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 75 fb ff ff       	call   80107c <dev_lookup>
  801507:	85 c0                	test   %eax,%eax
  801509:	78 3a                	js     801545 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801512:	74 2c                	je     801540 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801514:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801517:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80151e:	00 00 00 
	stat->st_isdir = 0;
  801521:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801528:	00 00 00 
	stat->st_dev = dev;
  80152b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801531:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801535:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801538:	89 14 24             	mov    %edx,(%esp)
  80153b:	ff 50 14             	call   *0x14(%eax)
  80153e:	eb 05                	jmp    801545 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801540:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801545:	83 c4 24             	add    $0x24,%esp
  801548:	5b                   	pop    %ebx
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801553:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80155a:	00 
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	89 04 24             	mov    %eax,(%esp)
  801561:	e8 fb 01 00 00       	call   801761 <open>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	85 db                	test   %ebx,%ebx
  80156a:	78 1b                	js     801587 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80156c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	89 1c 24             	mov    %ebx,(%esp)
  801576:	e8 56 ff ff ff       	call   8014d1 <fstat>
  80157b:	89 c6                	mov    %eax,%esi
	close(fd);
  80157d:	89 1c 24             	mov    %ebx,(%esp)
  801580:	e8 cd fb ff ff       	call   801152 <close>
	return r;
  801585:	89 f0                	mov    %esi,%eax
}
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 10             	sub    $0x10,%esp
  801596:	89 c6                	mov    %eax,%esi
  801598:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80159a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015a1:	75 11                	jne    8015b4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015aa:	e8 7e 0e 00 00       	call   80242d <ipc_find_env>
  8015af:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015b4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015bb:	00 
  8015bc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015c3:	00 
  8015c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8015cd:	89 04 24             	mov    %eax,(%esp)
  8015d0:	e8 a9 0d 00 00       	call   80237e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015dc:	00 
  8015dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e8:	e8 f3 0c 00 00       	call   8022e0 <ipc_recv>
}
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	5b                   	pop    %ebx
  8015f1:	5e                   	pop    %esi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801600:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801605:	8b 45 0c             	mov    0xc(%ebp),%eax
  801608:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
  801612:	b8 02 00 00 00       	mov    $0x2,%eax
  801617:	e8 72 ff ff ff       	call   80158e <fsipc>
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	8b 40 0c             	mov    0xc(%eax),%eax
  80162a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162f:	ba 00 00 00 00       	mov    $0x0,%edx
  801634:	b8 06 00 00 00       	mov    $0x6,%eax
  801639:	e8 50 ff ff ff       	call   80158e <fsipc>
}
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 05 00 00 00       	mov    $0x5,%eax
  80165f:	e8 2a ff ff ff       	call   80158e <fsipc>
  801664:	89 c2                	mov    %eax,%edx
  801666:	85 d2                	test   %edx,%edx
  801668:	78 2b                	js     801695 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80166a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801671:	00 
  801672:	89 1c 24             	mov    %ebx,(%esp)
  801675:	e8 ad f2 ff ff       	call   800927 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80167a:	a1 80 50 80 00       	mov    0x805080,%eax
  80167f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801685:	a1 84 50 80 00       	mov    0x805084,%eax
  80168a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801695:	83 c4 14             	add    $0x14,%esp
  801698:	5b                   	pop    %ebx
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016a1:	c7 44 24 08 f8 2b 80 	movl   $0x802bf8,0x8(%esp)
  8016a8:	00 
  8016a9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016b0:	00 
  8016b1:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  8016b8:	e8 f7 ea ff ff       	call   8001b4 <_panic>

008016bd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 10             	sub    $0x10,%esp
  8016c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 03 00 00 00       	mov    $0x3,%eax
  8016e3:	e8 a6 fe ff ff       	call   80158e <fsipc>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 6a                	js     801758 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016ee:	39 c6                	cmp    %eax,%esi
  8016f0:	73 24                	jae    801716 <devfile_read+0x59>
  8016f2:	c7 44 24 0c 21 2c 80 	movl   $0x802c21,0xc(%esp)
  8016f9:	00 
  8016fa:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  801701:	00 
  801702:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801709:	00 
  80170a:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  801711:	e8 9e ea ff ff       	call   8001b4 <_panic>
	assert(r <= PGSIZE);
  801716:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80171b:	7e 24                	jle    801741 <devfile_read+0x84>
  80171d:	c7 44 24 0c 3d 2c 80 	movl   $0x802c3d,0xc(%esp)
  801724:	00 
  801725:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  80172c:	00 
  80172d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801734:	00 
  801735:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  80173c:	e8 73 ea ff ff       	call   8001b4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801741:	89 44 24 08          	mov    %eax,0x8(%esp)
  801745:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80174c:	00 
  80174d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801750:	89 04 24             	mov    %eax,(%esp)
  801753:	e8 6c f3 ff ff       	call   800ac4 <memmove>
	return r;
}
  801758:	89 d8                	mov    %ebx,%eax
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 24             	sub    $0x24,%esp
  801768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176b:	89 1c 24             	mov    %ebx,(%esp)
  80176e:	e8 7d f1 ff ff       	call   8008f0 <strlen>
  801773:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801778:	7f 60                	jg     8017da <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177d:	89 04 24             	mov    %eax,(%esp)
  801780:	e8 52 f8 ff ff       	call   800fd7 <fd_alloc>
  801785:	89 c2                	mov    %eax,%edx
  801787:	85 d2                	test   %edx,%edx
  801789:	78 54                	js     8017df <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80178b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801796:	e8 8c f1 ff ff       	call   800927 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ab:	e8 de fd ff ff       	call   80158e <fsipc>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	79 17                	jns    8017cd <open+0x6c>
		fd_close(fd, 0);
  8017b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017bd:	00 
  8017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c1:	89 04 24             	mov    %eax,(%esp)
  8017c4:	e8 08 f9 ff ff       	call   8010d1 <fd_close>
		return r;
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	eb 12                	jmp    8017df <open+0x7e>
	}

	return fd2num(fd);
  8017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	e8 d8 f7 ff ff       	call   800fb0 <fd2num>
  8017d8:	eb 05                	jmp    8017df <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017da:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017df:	83 c4 24             	add    $0x24,%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017f5:	e8 94 fd ff ff       	call   80158e <fsipc>
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    
  8017fc:	66 90                	xchg   %ax,%ax
  8017fe:	66 90                	xchg   %ax,%ax

00801800 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80180c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801813:	00 
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 42 ff ff ff       	call   801761 <open>
  80181f:	89 c1                	mov    %eax,%ecx
  801821:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801827:	85 c0                	test   %eax,%eax
  801829:	0f 88 9e 04 00 00    	js     801ccd <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80182f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801836:	00 
  801837:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	89 0c 24             	mov    %ecx,(%esp)
  801844:	e8 fe fa ff ff       	call   801347 <readn>
  801849:	3d 00 02 00 00       	cmp    $0x200,%eax
  80184e:	75 0c                	jne    80185c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801850:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801857:	45 4c 46 
  80185a:	74 36                	je     801892 <spawn+0x92>
		close(fd);
  80185c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	e8 e8 f8 ff ff       	call   801152 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80186a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801871:	46 
  801872:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187c:	c7 04 24 49 2c 80 00 	movl   $0x802c49,(%esp)
  801883:	e8 25 ea ff ff       	call   8002ad <cprintf>
		return -E_NOT_EXEC;
  801888:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80188d:	e9 9a 04 00 00       	jmp    801d2c <spawn+0x52c>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801892:	b8 07 00 00 00       	mov    $0x7,%eax
  801897:	cd 30                	int    $0x30
  801899:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80189f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 88 28 04 00 00    	js     801cd5 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018ad:	89 c6                	mov    %eax,%esi
  8018af:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8018b5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8018b8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8018be:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018c4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018cb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018d1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8018dc:	be 00 00 00 00       	mov    $0x0,%esi
  8018e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018e4:	eb 0f                	jmp    8018f5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 02 f0 ff ff       	call   8008f0 <strlen>
  8018ee:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018f2:	83 c3 01             	add    $0x1,%ebx
  8018f5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8018fc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8018ff:	85 c0                	test   %eax,%eax
  801901:	75 e3                	jne    8018e6 <spawn+0xe6>
  801903:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801909:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80190f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801914:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801916:	89 fa                	mov    %edi,%edx
  801918:	83 e2 fc             	and    $0xfffffffc,%edx
  80191b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801922:	29 c2                	sub    %eax,%edx
  801924:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80192a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80192d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801932:	0f 86 ad 03 00 00    	jbe    801ce5 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801938:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80193f:	00 
  801940:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801947:	00 
  801948:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194f:	e8 ef f3 ff ff       	call   800d43 <sys_page_alloc>
  801954:	85 c0                	test   %eax,%eax
  801956:	0f 88 d0 03 00 00    	js     801d2c <spawn+0x52c>
  80195c:	be 00 00 00 00       	mov    $0x0,%esi
  801961:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196a:	eb 30                	jmp    80199c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80196c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801972:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801978:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80197b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	89 3c 24             	mov    %edi,(%esp)
  801985:	e8 9d ef ff ff       	call   800927 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80198a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80198d:	89 04 24             	mov    %eax,(%esp)
  801990:	e8 5b ef ff ff       	call   8008f0 <strlen>
  801995:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801999:	83 c6 01             	add    $0x1,%esi
  80199c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8019a2:	7f c8                	jg     80196c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8019a4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019aa:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8019b0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8019b7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8019bd:	74 24                	je     8019e3 <spawn+0x1e3>
  8019bf:	c7 44 24 0c c0 2c 80 	movl   $0x802cc0,0xc(%esp)
  8019c6:	00 
  8019c7:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  8019ce:	00 
  8019cf:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8019d6:	00 
  8019d7:	c7 04 24 63 2c 80 00 	movl   $0x802c63,(%esp)
  8019de:	e8 d1 e7 ff ff       	call   8001b4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019e3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019e9:	89 c8                	mov    %ecx,%eax
  8019eb:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019f0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8019f3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8019f9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019fc:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801a02:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a08:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801a0f:	00 
  801a10:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801a17:	ee 
  801a18:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a29:	00 
  801a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a31:	e8 61 f3 ff ff       	call   800d97 <sys_page_map>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	0f 88 d6 02 00 00    	js     801d16 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a40:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a47:	00 
  801a48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a4f:	e8 96 f3 ff ff       	call   800dea <sys_page_unmap>
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	85 c0                	test   %eax,%eax
  801a58:	0f 88 b8 02 00 00    	js     801d16 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a5e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801a64:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801a6b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a71:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801a78:	00 00 00 
  801a7b:	e9 b6 01 00 00       	jmp    801c36 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801a80:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801a86:	83 38 01             	cmpl   $0x1,(%eax)
  801a89:	0f 85 99 01 00 00    	jne    801c28 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a8f:	89 c1                	mov    %eax,%ecx
  801a91:	8b 40 18             	mov    0x18(%eax),%eax
  801a94:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a97:	83 f8 01             	cmp    $0x1,%eax
  801a9a:	19 c0                	sbb    %eax,%eax
  801a9c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801aa2:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801aa9:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ab0:	89 c8                	mov    %ecx,%eax
  801ab2:	8b 51 04             	mov    0x4(%ecx),%edx
  801ab5:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801abb:	8b 49 10             	mov    0x10(%ecx),%ecx
  801abe:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801ac4:	8b 50 14             	mov    0x14(%eax),%edx
  801ac7:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801acd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ad7:	74 14                	je     801aed <spawn+0x2ed>
		va -= i;
  801ad9:	29 c6                	sub    %eax,%esi
		memsz += i;
  801adb:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801ae1:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ae7:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801aed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af2:	e9 23 01 00 00       	jmp    801c1a <spawn+0x41a>
		if (i >= filesz) {
  801af7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801afd:	77 2b                	ja     801b2a <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801aff:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b09:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b0d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b13:	89 04 24             	mov    %eax,(%esp)
  801b16:	e8 28 f2 ff ff       	call   800d43 <sys_page_alloc>
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 89 eb 00 00 00    	jns    801c0e <spawn+0x40e>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	e9 cc 01 00 00       	jmp    801cf6 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b2a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b31:	00 
  801b32:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b39:	00 
  801b3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b41:	e8 fd f1 ff ff       	call   800d43 <sys_page_alloc>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	0f 88 9e 01 00 00    	js     801cec <spawn+0x4ec>
  801b4e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b54:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	e8 b7 f8 ff ff       	call   80141f <seek>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	0f 88 80 01 00 00    	js     801cf0 <spawn+0x4f0>
  801b70:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b76:	29 fa                	sub    %edi,%edx
  801b78:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b7a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b80:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801b85:	0f 47 c1             	cmova  %ecx,%eax
  801b88:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b93:	00 
  801b94:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 a5 f7 ff ff       	call   801347 <readn>
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	0f 88 4a 01 00 00    	js     801cf4 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801baa:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801bb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801bb4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bb8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bc9:	00 
  801bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd1:	e8 c1 f1 ff ff       	call   800d97 <sys_page_map>
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	79 20                	jns    801bfa <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801bda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bde:	c7 44 24 08 6f 2c 80 	movl   $0x802c6f,0x8(%esp)
  801be5:	00 
  801be6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801bed:	00 
  801bee:	c7 04 24 63 2c 80 00 	movl   $0x802c63,(%esp)
  801bf5:	e8 ba e5 ff ff       	call   8001b4 <_panic>
			sys_page_unmap(0, UTEMP);
  801bfa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c01:	00 
  801c02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c09:	e8 dc f1 ff ff       	call   800dea <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c14:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c1a:	89 df                	mov    %ebx,%edi
  801c1c:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801c22:	0f 87 cf fe ff ff    	ja     801af7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c28:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c2f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c36:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c3d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c43:	0f 8c 37 fe ff ff    	jl     801a80 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c49:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c4f:	89 04 24             	mov    %eax,(%esp)
  801c52:	e8 fb f4 ff ff       	call   801152 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c57:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c61:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 21 f2 ff ff       	call   800e90 <sys_env_set_trapframe>
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	79 20                	jns    801c93 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801c73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c77:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  801c7e:	00 
  801c7f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801c86:	00 
  801c87:	c7 04 24 63 2c 80 00 	movl   $0x802c63,(%esp)
  801c8e:	e8 21 e5 ff ff       	call   8001b4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c93:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c9a:	00 
  801c9b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ca1:	89 04 24             	mov    %eax,(%esp)
  801ca4:	e8 94 f1 ff ff       	call   800e3d <sys_env_set_status>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	79 30                	jns    801cdd <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb1:	c7 44 24 08 a6 2c 80 	movl   $0x802ca6,0x8(%esp)
  801cb8:	00 
  801cb9:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801cc0:	00 
  801cc1:	c7 04 24 63 2c 80 00 	movl   $0x802c63,(%esp)
  801cc8:	e8 e7 e4 ff ff       	call   8001b4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ccd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801cd3:	eb 57                	jmp    801d2c <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801cd5:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cdb:	eb 4f                	jmp    801d2c <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801cdd:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ce3:	eb 47                	jmp    801d2c <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ce5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801cea:	eb 40                	jmp    801d2c <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	eb 06                	jmp    801cf6 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	eb 02                	jmp    801cf6 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cf4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801cf6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 af ef ff ff       	call   800cb3 <sys_env_destroy>
	close(fd);
  801d04:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 40 f4 ff ff       	call   801152 <close>
	return r;
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	eb 16                	jmp    801d2c <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d16:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d1d:	00 
  801d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d25:	e8 c0 f0 ff ff       	call   800dea <sys_page_unmap>
  801d2a:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d2c:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801d32:	5b                   	pop    %ebx
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	56                   	push   %esi
  801d3b:	53                   	push   %ebx
  801d3c:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d3f:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d42:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d47:	eb 03                	jmp    801d4c <spawnl+0x15>
		argc++;
  801d49:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d4c:	83 c0 04             	add    $0x4,%eax
  801d4f:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801d53:	75 f4                	jne    801d49 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d55:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  801d5c:	83 e0 f0             	and    $0xfffffff0,%eax
  801d5f:	29 c4                	sub    %eax,%esp
  801d61:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801d65:	c1 e8 02             	shr    $0x2,%eax
  801d68:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801d6f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d74:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801d7b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801d82:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
  801d88:	eb 0a                	jmp    801d94 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  801d8a:	83 c0 01             	add    $0x1,%eax
  801d8d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801d91:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d94:	39 d0                	cmp    %edx,%eax
  801d96:	75 f2                	jne    801d8a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d98:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	89 04 24             	mov    %eax,(%esp)
  801da2:	e8 59 fa ff ff       	call   801800 <spawn>
}
  801da7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	83 ec 10             	sub    $0x10,%esp
  801db6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	89 04 24             	mov    %eax,(%esp)
  801dbf:	e8 fc f1 ff ff       	call   800fc0 <fd2data>
  801dc4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dc6:	c7 44 24 04 e6 2c 80 	movl   $0x802ce6,0x4(%esp)
  801dcd:	00 
  801dce:	89 1c 24             	mov    %ebx,(%esp)
  801dd1:	e8 51 eb ff ff       	call   800927 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dd6:	8b 46 04             	mov    0x4(%esi),%eax
  801dd9:	2b 06                	sub    (%esi),%eax
  801ddb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801de1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801de8:	00 00 00 
	stat->st_dev = &devpipe;
  801deb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801df2:	30 80 00 
	return 0;
}
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    

00801e01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	53                   	push   %ebx
  801e05:	83 ec 14             	sub    $0x14,%esp
  801e08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e16:	e8 cf ef ff ff       	call   800dea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e1b:	89 1c 24             	mov    %ebx,(%esp)
  801e1e:	e8 9d f1 ff ff       	call   800fc0 <fd2data>
  801e23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2e:	e8 b7 ef ff ff       	call   800dea <sys_page_unmap>
}
  801e33:	83 c4 14             	add    $0x14,%esp
  801e36:	5b                   	pop    %ebx
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	57                   	push   %edi
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 2c             	sub    $0x2c,%esp
  801e42:	89 c6                	mov    %eax,%esi
  801e44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e47:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e4f:	89 34 24             	mov    %esi,(%esp)
  801e52:	e8 0e 06 00 00       	call   802465 <pageref>
  801e57:	89 c7                	mov    %eax,%edi
  801e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 01 06 00 00       	call   802465 <pageref>
  801e64:	39 c7                	cmp    %eax,%edi
  801e66:	0f 94 c2             	sete   %dl
  801e69:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e6c:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801e72:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e75:	39 fb                	cmp    %edi,%ebx
  801e77:	74 21                	je     801e9a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e79:	84 d2                	test   %dl,%dl
  801e7b:	74 ca                	je     801e47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e7d:	8b 51 58             	mov    0x58(%ecx),%edx
  801e80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e84:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8c:	c7 04 24 ed 2c 80 00 	movl   $0x802ced,(%esp)
  801e93:	e8 15 e4 ff ff       	call   8002ad <cprintf>
  801e98:	eb ad                	jmp    801e47 <_pipeisclosed+0xe>
	}
}
  801e9a:	83 c4 2c             	add    $0x2c,%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	83 ec 1c             	sub    $0x1c,%esp
  801eab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eae:	89 34 24             	mov    %esi,(%esp)
  801eb1:	e8 0a f1 ff ff       	call   800fc0 <fd2data>
  801eb6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ebd:	eb 45                	jmp    801f04 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ebf:	89 da                	mov    %ebx,%edx
  801ec1:	89 f0                	mov    %esi,%eax
  801ec3:	e8 71 ff ff ff       	call   801e39 <_pipeisclosed>
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	75 41                	jne    801f0d <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ecc:	e8 53 ee ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ed1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ed4:	8b 0b                	mov    (%ebx),%ecx
  801ed6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ed9:	39 d0                	cmp    %edx,%eax
  801edb:	73 e2                	jae    801ebf <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ee4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ee7:	99                   	cltd   
  801ee8:	c1 ea 1b             	shr    $0x1b,%edx
  801eeb:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801eee:	83 e1 1f             	and    $0x1f,%ecx
  801ef1:	29 d1                	sub    %edx,%ecx
  801ef3:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ef7:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801efb:	83 c0 01             	add    $0x1,%eax
  801efe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f01:	83 c7 01             	add    $0x1,%edi
  801f04:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f07:	75 c8                	jne    801ed1 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f09:	89 f8                	mov    %edi,%eax
  801f0b:	eb 05                	jmp    801f12 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f12:	83 c4 1c             	add    $0x1c,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	83 ec 1c             	sub    $0x1c,%esp
  801f23:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f26:	89 3c 24             	mov    %edi,(%esp)
  801f29:	e8 92 f0 ff ff       	call   800fc0 <fd2data>
  801f2e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f30:	be 00 00 00 00       	mov    $0x0,%esi
  801f35:	eb 3d                	jmp    801f74 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f37:	85 f6                	test   %esi,%esi
  801f39:	74 04                	je     801f3f <devpipe_read+0x25>
				return i;
  801f3b:	89 f0                	mov    %esi,%eax
  801f3d:	eb 43                	jmp    801f82 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f3f:	89 da                	mov    %ebx,%edx
  801f41:	89 f8                	mov    %edi,%eax
  801f43:	e8 f1 fe ff ff       	call   801e39 <_pipeisclosed>
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	75 31                	jne    801f7d <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f4c:	e8 d3 ed ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f51:	8b 03                	mov    (%ebx),%eax
  801f53:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f56:	74 df                	je     801f37 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f58:	99                   	cltd   
  801f59:	c1 ea 1b             	shr    $0x1b,%edx
  801f5c:	01 d0                	add    %edx,%eax
  801f5e:	83 e0 1f             	and    $0x1f,%eax
  801f61:	29 d0                	sub    %edx,%eax
  801f63:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f6e:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f71:	83 c6 01             	add    $0x1,%esi
  801f74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f77:	75 d8                	jne    801f51 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f79:	89 f0                	mov    %esi,%eax
  801f7b:	eb 05                	jmp    801f82 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f82:	83 c4 1c             	add    $0x1c,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 3a f0 ff ff       	call   800fd7 <fd_alloc>
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	85 d2                	test   %edx,%edx
  801fa1:	0f 88 4d 01 00 00    	js     8020f4 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fae:	00 
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbd:	e8 81 ed ff ff       	call   800d43 <sys_page_alloc>
  801fc2:	89 c2                	mov    %eax,%edx
  801fc4:	85 d2                	test   %edx,%edx
  801fc6:	0f 88 28 01 00 00    	js     8020f4 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fcf:	89 04 24             	mov    %eax,(%esp)
  801fd2:	e8 00 f0 ff ff       	call   800fd7 <fd_alloc>
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	0f 88 fe 00 00 00    	js     8020df <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe8:	00 
  801fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff7:	e8 47 ed ff ff       	call   800d43 <sys_page_alloc>
  801ffc:	89 c3                	mov    %eax,%ebx
  801ffe:	85 c0                	test   %eax,%eax
  802000:	0f 88 d9 00 00 00    	js     8020df <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802009:	89 04 24             	mov    %eax,(%esp)
  80200c:	e8 af ef ff ff       	call   800fc0 <fd2data>
  802011:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802013:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80201a:	00 
  80201b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802026:	e8 18 ed ff ff       	call   800d43 <sys_page_alloc>
  80202b:	89 c3                	mov    %eax,%ebx
  80202d:	85 c0                	test   %eax,%eax
  80202f:	0f 88 97 00 00 00    	js     8020cc <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802035:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 80 ef ff ff       	call   800fc0 <fd2data>
  802040:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802047:	00 
  802048:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802053:	00 
  802054:	89 74 24 04          	mov    %esi,0x4(%esp)
  802058:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80205f:	e8 33 ed ff ff       	call   800d97 <sys_page_map>
  802064:	89 c3                	mov    %eax,%ebx
  802066:	85 c0                	test   %eax,%eax
  802068:	78 52                	js     8020bc <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80206a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802070:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802073:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802078:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80207f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802085:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802088:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	89 04 24             	mov    %eax,(%esp)
  80209a:	e8 11 ef ff ff       	call   800fb0 <fd2num>
  80209f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a7:	89 04 24             	mov    %eax,(%esp)
  8020aa:	e8 01 ef ff ff       	call   800fb0 <fd2num>
  8020af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ba:	eb 38                	jmp    8020f4 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8020bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c7:	e8 1e ed ff ff       	call   800dea <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020da:	e8 0b ed ff ff       	call   800dea <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ed:	e8 f8 ec ff ff       	call   800dea <sys_page_unmap>
  8020f2:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8020f4:	83 c4 30             	add    $0x30,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    

008020fb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802104:	89 44 24 04          	mov    %eax,0x4(%esp)
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	89 04 24             	mov    %eax,(%esp)
  80210e:	e8 13 ef ff ff       	call   801026 <fd_lookup>
  802113:	89 c2                	mov    %eax,%edx
  802115:	85 d2                	test   %edx,%edx
  802117:	78 15                	js     80212e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211c:	89 04 24             	mov    %eax,(%esp)
  80211f:	e8 9c ee ff ff       	call   800fc0 <fd2data>
	return _pipeisclosed(fd, p);
  802124:	89 c2                	mov    %eax,%edx
  802126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802129:	e8 0b fd ff ff       	call   801e39 <_pipeisclosed>
}
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802133:	b8 00 00 00 00       	mov    $0x0,%eax
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    

0080213a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802140:	c7 44 24 04 05 2d 80 	movl   $0x802d05,0x4(%esp)
  802147:	00 
  802148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 d4 e7 ff ff       	call   800927 <strcpy>
	return 0;
}
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	c9                   	leave  
  802159:	c3                   	ret    

0080215a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	57                   	push   %edi
  80215e:	56                   	push   %esi
  80215f:	53                   	push   %ebx
  802160:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802166:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80216b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802171:	eb 31                	jmp    8021a4 <devcons_write+0x4a>
		m = n - tot;
  802173:	8b 75 10             	mov    0x10(%ebp),%esi
  802176:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802178:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80217b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802180:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802183:	89 74 24 08          	mov    %esi,0x8(%esp)
  802187:	03 45 0c             	add    0xc(%ebp),%eax
  80218a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218e:	89 3c 24             	mov    %edi,(%esp)
  802191:	e8 2e e9 ff ff       	call   800ac4 <memmove>
		sys_cputs(buf, m);
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	89 3c 24             	mov    %edi,(%esp)
  80219d:	e8 d4 ea ff ff       	call   800c76 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a2:	01 f3                	add    %esi,%ebx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021a9:	72 c8                	jb     802173 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021ab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    

008021b6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021bc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021c5:	75 07                	jne    8021ce <devcons_read+0x18>
  8021c7:	eb 2a                	jmp    8021f3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021c9:	e8 56 eb ff ff       	call   800d24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021ce:	66 90                	xchg   %ax,%ax
  8021d0:	e8 bf ea ff ff       	call   800c94 <sys_cgetc>
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	74 f0                	je     8021c9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 16                	js     8021f3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021dd:	83 f8 04             	cmp    $0x4,%eax
  8021e0:	74 0c                	je     8021ee <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8021e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e5:	88 02                	mov    %al,(%edx)
	return 1;
  8021e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ec:	eb 05                	jmp    8021f3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021ee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    

008021f5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802201:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802208:	00 
  802209:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 62 ea ff ff       	call   800c76 <sys_cputs>
}
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <getchar>:

int
getchar(void)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80221c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802223:	00 
  802224:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802232:	e8 7e f0 ff ff       	call   8012b5 <read>
	if (r < 0)
  802237:	85 c0                	test   %eax,%eax
  802239:	78 0f                	js     80224a <getchar+0x34>
		return r;
	if (r < 1)
  80223b:	85 c0                	test   %eax,%eax
  80223d:	7e 06                	jle    802245 <getchar+0x2f>
		return -E_EOF;
	return c;
  80223f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802243:	eb 05                	jmp    80224a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802245:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802252:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802255:	89 44 24 04          	mov    %eax,0x4(%esp)
  802259:	8b 45 08             	mov    0x8(%ebp),%eax
  80225c:	89 04 24             	mov    %eax,(%esp)
  80225f:	e8 c2 ed ff ff       	call   801026 <fd_lookup>
  802264:	85 c0                	test   %eax,%eax
  802266:	78 11                	js     802279 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802271:	39 10                	cmp    %edx,(%eax)
  802273:	0f 94 c0             	sete   %al
  802276:	0f b6 c0             	movzbl %al,%eax
}
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <opencons>:

int
opencons(void)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802284:	89 04 24             	mov    %eax,(%esp)
  802287:	e8 4b ed ff ff       	call   800fd7 <fd_alloc>
		return r;
  80228c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 40                	js     8022d2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802292:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802299:	00 
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a8:	e8 96 ea ff ff       	call   800d43 <sys_page_alloc>
		return r;
  8022ad:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	78 1f                	js     8022d2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c8:	89 04 24             	mov    %eax,(%esp)
  8022cb:	e8 e0 ec ff ff       	call   800fb0 <fd2num>
  8022d0:	89 c2                	mov    %eax,%edx
}
  8022d2:	89 d0                	mov    %edx,%eax
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	66 90                	xchg   %ax,%ax
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	56                   	push   %esi
  8022e4:	53                   	push   %ebx
  8022e5:	83 ec 10             	sub    $0x10,%esp
  8022e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	75 0e                	jne    802303 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8022f5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8022fc:	e8 58 ec ff ff       	call   800f59 <sys_ipc_recv>
  802301:	eb 08                	jmp    80230b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 4e ec ff ff       	call   800f59 <sys_ipc_recv>
	if(r == 0){
  80230b:	85 c0                	test   %eax,%eax
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	75 1e                	jne    802330 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802312:	85 f6                	test   %esi,%esi
  802314:	74 0a                	je     802320 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802316:	a1 04 40 80 00       	mov    0x804004,%eax
  80231b:	8b 40 74             	mov    0x74(%eax),%eax
  80231e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802320:	85 db                	test   %ebx,%ebx
  802322:	74 2c                	je     802350 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802324:	a1 04 40 80 00       	mov    0x804004,%eax
  802329:	8b 40 78             	mov    0x78(%eax),%eax
  80232c:	89 03                	mov    %eax,(%ebx)
  80232e:	eb 20                	jmp    802350 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802330:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802334:	c7 44 24 08 14 2d 80 	movl   $0x802d14,0x8(%esp)
  80233b:	00 
  80233c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802343:	00 
  802344:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  80234b:	e8 64 de ff ff       	call   8001b4 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802350:	a1 04 40 80 00       	mov    0x804004,%eax
  802355:	8b 50 70             	mov    0x70(%eax),%edx
  802358:	85 d2                	test   %edx,%edx
  80235a:	75 13                	jne    80236f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80235c:	8b 40 48             	mov    0x48(%eax),%eax
  80235f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802363:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  80236a:	e8 3e df ff ff       	call   8002ad <cprintf>
	return thisenv->env_ipc_value;
  80236f:	a1 04 40 80 00       	mov    0x804004,%eax
  802374:	8b 40 70             	mov    0x70(%eax),%eax
}
  802377:	83 c4 10             	add    $0x10,%esp
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	5d                   	pop    %ebp
  80237d:	c3                   	ret    

0080237e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 7d 08             	mov    0x8(%ebp),%edi
  80238a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80238d:	85 f6                	test   %esi,%esi
  80238f:	75 22                	jne    8023b3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802391:	8b 45 14             	mov    0x14(%ebp),%eax
  802394:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802398:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80239f:	ee 
  8023a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a7:	89 3c 24             	mov    %edi,(%esp)
  8023aa:	e8 87 eb ff ff       	call   800f36 <sys_ipc_try_send>
  8023af:	89 c3                	mov    %eax,%ebx
  8023b1:	eb 1c                	jmp    8023cf <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8023b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8023b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c5:	89 3c 24             	mov    %edi,(%esp)
  8023c8:	e8 69 eb ff ff       	call   800f36 <sys_ipc_try_send>
  8023cd:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8023cf:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8023d2:	74 3e                	je     802412 <ipc_send+0x94>
  8023d4:	89 d8                	mov    %ebx,%eax
  8023d6:	c1 e8 1f             	shr    $0x1f,%eax
  8023d9:	84 c0                	test   %al,%al
  8023db:	74 35                	je     802412 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  8023dd:	e8 23 e9 ff ff       	call   800d05 <sys_getenvid>
  8023e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e6:	c7 04 24 9a 2d 80 00 	movl   $0x802d9a,(%esp)
  8023ed:	e8 bb de ff ff       	call   8002ad <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8023f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023f6:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  8023fd:	00 
  8023fe:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802405:	00 
  802406:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  80240d:	e8 a2 dd ff ff       	call   8001b4 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802412:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802415:	75 0e                	jne    802425 <ipc_send+0xa7>
			sys_yield();
  802417:	e8 08 e9 ff ff       	call   800d24 <sys_yield>
		else break;
	}
  80241c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802420:	e9 68 ff ff ff       	jmp    80238d <ipc_send+0xf>
	
}
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    

0080242d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802433:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802438:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80243b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802441:	8b 52 50             	mov    0x50(%edx),%edx
  802444:	39 ca                	cmp    %ecx,%edx
  802446:	75 0d                	jne    802455 <ipc_find_env+0x28>
			return envs[i].env_id;
  802448:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80244b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802450:	8b 40 40             	mov    0x40(%eax),%eax
  802453:	eb 0e                	jmp    802463 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802455:	83 c0 01             	add    $0x1,%eax
  802458:	3d 00 04 00 00       	cmp    $0x400,%eax
  80245d:	75 d9                	jne    802438 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80245f:	66 b8 00 00          	mov    $0x0,%ax
}
  802463:	5d                   	pop    %ebp
  802464:	c3                   	ret    

00802465 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802465:	55                   	push   %ebp
  802466:	89 e5                	mov    %esp,%ebp
  802468:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246b:	89 d0                	mov    %edx,%eax
  80246d:	c1 e8 16             	shr    $0x16,%eax
  802470:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802477:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247c:	f6 c1 01             	test   $0x1,%cl
  80247f:	74 1d                	je     80249e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802481:	c1 ea 0c             	shr    $0xc,%edx
  802484:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80248b:	f6 c2 01             	test   $0x1,%dl
  80248e:	74 0e                	je     80249e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802490:	c1 ea 0c             	shr    $0xc,%edx
  802493:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80249a:	ef 
  80249b:	0f b7 c0             	movzwl %ax,%eax
}
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    

008024a0 <__udivdi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	83 ec 0c             	sub    $0xc,%esp
  8024a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8024ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8024b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024bc:	89 ea                	mov    %ebp,%edx
  8024be:	89 0c 24             	mov    %ecx,(%esp)
  8024c1:	75 2d                	jne    8024f0 <__udivdi3+0x50>
  8024c3:	39 e9                	cmp    %ebp,%ecx
  8024c5:	77 61                	ja     802528 <__udivdi3+0x88>
  8024c7:	85 c9                	test   %ecx,%ecx
  8024c9:	89 ce                	mov    %ecx,%esi
  8024cb:	75 0b                	jne    8024d8 <__udivdi3+0x38>
  8024cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d2:	31 d2                	xor    %edx,%edx
  8024d4:	f7 f1                	div    %ecx
  8024d6:	89 c6                	mov    %eax,%esi
  8024d8:	31 d2                	xor    %edx,%edx
  8024da:	89 e8                	mov    %ebp,%eax
  8024dc:	f7 f6                	div    %esi
  8024de:	89 c5                	mov    %eax,%ebp
  8024e0:	89 f8                	mov    %edi,%eax
  8024e2:	f7 f6                	div    %esi
  8024e4:	89 ea                	mov    %ebp,%edx
  8024e6:	83 c4 0c             	add    $0xc,%esp
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	39 e8                	cmp    %ebp,%eax
  8024f2:	77 24                	ja     802518 <__udivdi3+0x78>
  8024f4:	0f bd e8             	bsr    %eax,%ebp
  8024f7:	83 f5 1f             	xor    $0x1f,%ebp
  8024fa:	75 3c                	jne    802538 <__udivdi3+0x98>
  8024fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802500:	39 34 24             	cmp    %esi,(%esp)
  802503:	0f 86 9f 00 00 00    	jbe    8025a8 <__udivdi3+0x108>
  802509:	39 d0                	cmp    %edx,%eax
  80250b:	0f 82 97 00 00 00    	jb     8025a8 <__udivdi3+0x108>
  802511:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802518:	31 d2                	xor    %edx,%edx
  80251a:	31 c0                	xor    %eax,%eax
  80251c:	83 c4 0c             	add    $0xc,%esp
  80251f:	5e                   	pop    %esi
  802520:	5f                   	pop    %edi
  802521:	5d                   	pop    %ebp
  802522:	c3                   	ret    
  802523:	90                   	nop
  802524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802528:	89 f8                	mov    %edi,%eax
  80252a:	f7 f1                	div    %ecx
  80252c:	31 d2                	xor    %edx,%edx
  80252e:	83 c4 0c             	add    $0xc,%esp
  802531:	5e                   	pop    %esi
  802532:	5f                   	pop    %edi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    
  802535:	8d 76 00             	lea    0x0(%esi),%esi
  802538:	89 e9                	mov    %ebp,%ecx
  80253a:	8b 3c 24             	mov    (%esp),%edi
  80253d:	d3 e0                	shl    %cl,%eax
  80253f:	89 c6                	mov    %eax,%esi
  802541:	b8 20 00 00 00       	mov    $0x20,%eax
  802546:	29 e8                	sub    %ebp,%eax
  802548:	89 c1                	mov    %eax,%ecx
  80254a:	d3 ef                	shr    %cl,%edi
  80254c:	89 e9                	mov    %ebp,%ecx
  80254e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802552:	8b 3c 24             	mov    (%esp),%edi
  802555:	09 74 24 08          	or     %esi,0x8(%esp)
  802559:	89 d6                	mov    %edx,%esi
  80255b:	d3 e7                	shl    %cl,%edi
  80255d:	89 c1                	mov    %eax,%ecx
  80255f:	89 3c 24             	mov    %edi,(%esp)
  802562:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802566:	d3 ee                	shr    %cl,%esi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	d3 e2                	shl    %cl,%edx
  80256c:	89 c1                	mov    %eax,%ecx
  80256e:	d3 ef                	shr    %cl,%edi
  802570:	09 d7                	or     %edx,%edi
  802572:	89 f2                	mov    %esi,%edx
  802574:	89 f8                	mov    %edi,%eax
  802576:	f7 74 24 08          	divl   0x8(%esp)
  80257a:	89 d6                	mov    %edx,%esi
  80257c:	89 c7                	mov    %eax,%edi
  80257e:	f7 24 24             	mull   (%esp)
  802581:	39 d6                	cmp    %edx,%esi
  802583:	89 14 24             	mov    %edx,(%esp)
  802586:	72 30                	jb     8025b8 <__udivdi3+0x118>
  802588:	8b 54 24 04          	mov    0x4(%esp),%edx
  80258c:	89 e9                	mov    %ebp,%ecx
  80258e:	d3 e2                	shl    %cl,%edx
  802590:	39 c2                	cmp    %eax,%edx
  802592:	73 05                	jae    802599 <__udivdi3+0xf9>
  802594:	3b 34 24             	cmp    (%esp),%esi
  802597:	74 1f                	je     8025b8 <__udivdi3+0x118>
  802599:	89 f8                	mov    %edi,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	e9 7a ff ff ff       	jmp    80251c <__udivdi3+0x7c>
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8025af:	e9 68 ff ff ff       	jmp    80251c <__udivdi3+0x7c>
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	83 c4 0c             	add    $0xc,%esp
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	83 ec 14             	sub    $0x14,%esp
  8025d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8025da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8025de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8025e2:	89 c7                	mov    %eax,%edi
  8025e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8025f0:	89 34 24             	mov    %esi,(%esp)
  8025f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	89 c2                	mov    %eax,%edx
  8025fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025ff:	75 17                	jne    802618 <__umoddi3+0x48>
  802601:	39 fe                	cmp    %edi,%esi
  802603:	76 4b                	jbe    802650 <__umoddi3+0x80>
  802605:	89 c8                	mov    %ecx,%eax
  802607:	89 fa                	mov    %edi,%edx
  802609:	f7 f6                	div    %esi
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	31 d2                	xor    %edx,%edx
  80260f:	83 c4 14             	add    $0x14,%esp
  802612:	5e                   	pop    %esi
  802613:	5f                   	pop    %edi
  802614:	5d                   	pop    %ebp
  802615:	c3                   	ret    
  802616:	66 90                	xchg   %ax,%ax
  802618:	39 f8                	cmp    %edi,%eax
  80261a:	77 54                	ja     802670 <__umoddi3+0xa0>
  80261c:	0f bd e8             	bsr    %eax,%ebp
  80261f:	83 f5 1f             	xor    $0x1f,%ebp
  802622:	75 5c                	jne    802680 <__umoddi3+0xb0>
  802624:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802628:	39 3c 24             	cmp    %edi,(%esp)
  80262b:	0f 87 e7 00 00 00    	ja     802718 <__umoddi3+0x148>
  802631:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802635:	29 f1                	sub    %esi,%ecx
  802637:	19 c7                	sbb    %eax,%edi
  802639:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80263d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802641:	8b 44 24 08          	mov    0x8(%esp),%eax
  802645:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802649:	83 c4 14             	add    $0x14,%esp
  80264c:	5e                   	pop    %esi
  80264d:	5f                   	pop    %edi
  80264e:	5d                   	pop    %ebp
  80264f:	c3                   	ret    
  802650:	85 f6                	test   %esi,%esi
  802652:	89 f5                	mov    %esi,%ebp
  802654:	75 0b                	jne    802661 <__umoddi3+0x91>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f6                	div    %esi
  80265f:	89 c5                	mov    %eax,%ebp
  802661:	8b 44 24 04          	mov    0x4(%esp),%eax
  802665:	31 d2                	xor    %edx,%edx
  802667:	f7 f5                	div    %ebp
  802669:	89 c8                	mov    %ecx,%eax
  80266b:	f7 f5                	div    %ebp
  80266d:	eb 9c                	jmp    80260b <__umoddi3+0x3b>
  80266f:	90                   	nop
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 fa                	mov    %edi,%edx
  802674:	83 c4 14             	add    $0x14,%esp
  802677:	5e                   	pop    %esi
  802678:	5f                   	pop    %edi
  802679:	5d                   	pop    %ebp
  80267a:	c3                   	ret    
  80267b:	90                   	nop
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	8b 04 24             	mov    (%esp),%eax
  802683:	be 20 00 00 00       	mov    $0x20,%esi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	29 ee                	sub    %ebp,%esi
  80268c:	d3 e2                	shl    %cl,%edx
  80268e:	89 f1                	mov    %esi,%ecx
  802690:	d3 e8                	shr    %cl,%eax
  802692:	89 e9                	mov    %ebp,%ecx
  802694:	89 44 24 04          	mov    %eax,0x4(%esp)
  802698:	8b 04 24             	mov    (%esp),%eax
  80269b:	09 54 24 04          	or     %edx,0x4(%esp)
  80269f:	89 fa                	mov    %edi,%edx
  8026a1:	d3 e0                	shl    %cl,%eax
  8026a3:	89 f1                	mov    %esi,%ecx
  8026a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8026ad:	d3 ea                	shr    %cl,%edx
  8026af:	89 e9                	mov    %ebp,%ecx
  8026b1:	d3 e7                	shl    %cl,%edi
  8026b3:	89 f1                	mov    %esi,%ecx
  8026b5:	d3 e8                	shr    %cl,%eax
  8026b7:	89 e9                	mov    %ebp,%ecx
  8026b9:	09 f8                	or     %edi,%eax
  8026bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8026bf:	f7 74 24 04          	divl   0x4(%esp)
  8026c3:	d3 e7                	shl    %cl,%edi
  8026c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026c9:	89 d7                	mov    %edx,%edi
  8026cb:	f7 64 24 08          	mull   0x8(%esp)
  8026cf:	39 d7                	cmp    %edx,%edi
  8026d1:	89 c1                	mov    %eax,%ecx
  8026d3:	89 14 24             	mov    %edx,(%esp)
  8026d6:	72 2c                	jb     802704 <__umoddi3+0x134>
  8026d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8026dc:	72 22                	jb     802700 <__umoddi3+0x130>
  8026de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026e2:	29 c8                	sub    %ecx,%eax
  8026e4:	19 d7                	sbb    %edx,%edi
  8026e6:	89 e9                	mov    %ebp,%ecx
  8026e8:	89 fa                	mov    %edi,%edx
  8026ea:	d3 e8                	shr    %cl,%eax
  8026ec:	89 f1                	mov    %esi,%ecx
  8026ee:	d3 e2                	shl    %cl,%edx
  8026f0:	89 e9                	mov    %ebp,%ecx
  8026f2:	d3 ef                	shr    %cl,%edi
  8026f4:	09 d0                	or     %edx,%eax
  8026f6:	89 fa                	mov    %edi,%edx
  8026f8:	83 c4 14             	add    $0x14,%esp
  8026fb:	5e                   	pop    %esi
  8026fc:	5f                   	pop    %edi
  8026fd:	5d                   	pop    %ebp
  8026fe:	c3                   	ret    
  8026ff:	90                   	nop
  802700:	39 d7                	cmp    %edx,%edi
  802702:	75 da                	jne    8026de <__umoddi3+0x10e>
  802704:	8b 14 24             	mov    (%esp),%edx
  802707:	89 c1                	mov    %eax,%ecx
  802709:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80270d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802711:	eb cb                	jmp    8026de <__umoddi3+0x10e>
  802713:	90                   	nop
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80271c:	0f 82 0f ff ff ff    	jb     802631 <__umoddi3+0x61>
  802722:	e9 1a ff ff ff       	jmp    802641 <__umoddi3+0x71>
