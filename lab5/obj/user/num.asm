
obj/user/num.debug：     文件格式 elf32-i386


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
  80002c:	e8 95 01 00 00       	call   8001c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 30             	sub    $0x30,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	e9 84 00 00 00       	jmp    8000ca <num+0x97>
		if (bol) {
  800046:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004d:	74 27                	je     800076 <num+0x43>
			printf("%5d ", ++line);
  80004f:	a1 00 40 80 00       	mov    0x804000,%eax
  800054:	83 c0 01             	add    $0x1,%eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800060:	c7 04 24 40 23 80 00 	movl   $0x802340,(%esp)
  800067:	e8 15 19 00 00       	call   801981 <printf>
			bol = 0;
  80006c:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800073:	00 00 00 
		}
		if ((r = write(1, &c, 1)) != 1)
  800076:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80007d:	00 
  80007e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800082:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800089:	e8 74 13 00 00       	call   801402 <write>
  80008e:	83 f8 01             	cmp    $0x1,%eax
  800091:	74 27                	je     8000ba <num+0x87>
			panic("write error copying %s: %e", s, r);
  800093:	89 44 24 10          	mov    %eax,0x10(%esp)
  800097:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009e:	c7 44 24 08 45 23 80 	movl   $0x802345,0x8(%esp)
  8000a5:	00 
  8000a6:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000ad:	00 
  8000ae:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  8000b5:	e8 68 01 00 00       	call   800222 <_panic>
		if (c == '\n')
  8000ba:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000be:	75 0a                	jne    8000ca <num+0x97>
			bol = 1;
  8000c0:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c7:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d1:	00 
  8000d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d6:	89 34 24             	mov    %esi,(%esp)
  8000d9:	e8 47 12 00 00       	call   801325 <read>
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 8f 60 ff ff ff    	jg     800046 <num+0x13>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	79 27                	jns    800111 <num+0xde>
		panic("error reading %s: %e", s, n);
  8000ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f5:	c7 44 24 08 6b 23 80 	movl   $0x80236b,0x8(%esp)
  8000fc:	00 
  8000fd:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  800104:	00 
  800105:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  80010c:	e8 11 01 00 00       	call   800222 <_panic>
}
  800111:	83 c4 30             	add    $0x30,%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <umain>:

void
umain(int argc, char **argv)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 2c             	sub    $0x2c,%esp
	int f, i;

	binaryname = "num";
  800121:	c7 05 04 30 80 00 80 	movl   $0x802380,0x803004
  800128:	23 80 00 
	if (argc == 1)
  80012b:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80012f:	74 0d                	je     80013e <umain+0x26>
  800131:	8b 45 0c             	mov    0xc(%ebp),%eax
  800134:	8d 58 04             	lea    0x4(%eax),%ebx
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
  80013c:	eb 76                	jmp    8001b4 <umain+0x9c>
		num(0, "<stdin>");
  80013e:	c7 44 24 04 84 23 80 	movl   $0x802384,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 e1 fe ff ff       	call   800033 <num>
  800152:	eb 65                	jmp    8001b9 <umain+0xa1>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800154:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800157:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80015e:	00 
  80015f:	8b 03                	mov    (%ebx),%eax
  800161:	89 04 24             	mov    %eax,(%esp)
  800164:	e8 68 16 00 00       	call   8017d1 <open>
  800169:	89 c6                	mov    %eax,%esi
			if (f < 0)
  80016b:	85 c0                	test   %eax,%eax
  80016d:	79 29                	jns    800198 <umain+0x80>
				panic("can't open %s: %e", argv[i], f);
  80016f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800176:	8b 00                	mov    (%eax),%eax
  800178:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017c:	c7 44 24 08 8c 23 80 	movl   $0x80238c,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80018b:	00 
  80018c:	c7 04 24 60 23 80 00 	movl   $0x802360,(%esp)
  800193:	e8 8a 00 00 00       	call   800222 <_panic>
			else {
				num(f, argv[i]);
  800198:	8b 03                	mov    (%ebx),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	89 34 24             	mov    %esi,(%esp)
  8001a1:	e8 8d fe ff ff       	call   800033 <num>
				close(f);
  8001a6:	89 34 24             	mov    %esi,(%esp)
  8001a9:	e8 14 10 00 00       	call   8011c2 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8001ae:	83 c7 01             	add    $0x1,%edi
  8001b1:	83 c3 04             	add    $0x4,%ebx
  8001b4:	3b 7d 08             	cmp    0x8(%ebp),%edi
  8001b7:	7c 9b                	jl     800154 <umain+0x3c>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  8001b9:	e8 50 00 00 00       	call   80020e <exit>
}
  8001be:	83 c4 2c             	add    $0x2c,%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 10             	sub    $0x10,%esp
  8001ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8001d4:	e8 9c 0b 00 00       	call   800d75 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e6:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	7e 07                	jle    8001f6 <libmain+0x30>
		binaryname = argv[0];
  8001ef:	8b 06                	mov    (%esi),%eax
  8001f1:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fa:	89 1c 24             	mov    %ebx,(%esp)
  8001fd:	e8 16 ff ff ff       	call   800118 <umain>

	// exit gracefully
	exit();
  800202:	e8 07 00 00 00       	call   80020e <exit>
}
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021b:	e8 03 0b 00 00       	call   800d23 <sys_env_destroy>
}
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80022a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800233:	e8 3d 0b 00 00       	call   800d75 <sys_getenvid>
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800246:	89 74 24 08          	mov    %esi,0x8(%esp)
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
  800255:	e8 c1 00 00 00       	call   80031b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80025e:	8b 45 10             	mov    0x10(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 51 00 00 00       	call   8002ba <vcprintf>
	cprintf("\n");
  800269:	c7 04 24 e1 27 80 00 	movl   $0x8027e1,(%esp)
  800270:	e8 a6 00 00 00       	call   80031b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800275:	cc                   	int3   
  800276:	eb fd                	jmp    800275 <_panic+0x53>

00800278 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	53                   	push   %ebx
  80027c:	83 ec 14             	sub    $0x14,%esp
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800282:	8b 13                	mov    (%ebx),%edx
  800284:	8d 42 01             	lea    0x1(%edx),%eax
  800287:	89 03                	mov    %eax,(%ebx)
  800289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800290:	3d ff 00 00 00       	cmp    $0xff,%eax
  800295:	75 19                	jne    8002b0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800297:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80029e:	00 
  80029f:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	e8 3c 0a 00 00       	call   800ce6 <sys_cputs>
		b->idx = 0;
  8002aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b4:	83 c4 14             	add    $0x14,%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ca:	00 00 00 
	b.cnt = 0;
  8002cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	c7 04 24 78 02 80 00 	movl   $0x800278,(%esp)
  8002f6:	e8 79 01 00 00       	call   800474 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002fb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800301:	89 44 24 04          	mov    %eax,0x4(%esp)
  800305:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d3 09 00 00       	call   800ce6 <sys_cputs>

	return b.cnt;
}
  800313:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800321:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	e8 87 ff ff ff       	call   8002ba <vcprintf>
	va_end(ap);

	return cnt;
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    
  800335:	66 90                	xchg   %ax,%ax
  800337:	66 90                	xchg   %ax,%ax
  800339:	66 90                	xchg   %ax,%ax
  80033b:	66 90                	xchg   %ax,%ax
  80033d:	66 90                	xchg   %ax,%ax
  80033f:	90                   	nop

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 3c             	sub    $0x3c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d7                	mov    %edx,%edi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	8b 45 0c             	mov    0xc(%ebp),%eax
  800357:	89 c3                	mov    %eax,%ebx
  800359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80036d:	39 d9                	cmp    %ebx,%ecx
  80036f:	72 05                	jb     800376 <printnum+0x36>
  800371:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800374:	77 69                	ja     8003df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800376:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800379:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80037d:	83 ee 01             	sub    $0x1,%esi
  800380:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800384:	89 44 24 08          	mov    %eax,0x8(%esp)
  800388:	8b 44 24 08          	mov    0x8(%esp),%eax
  80038c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800390:	89 c3                	mov    %eax,%ebx
  800392:	89 d6                	mov    %edx,%esi
  800394:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800397:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80039a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80039e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 ec 1c 00 00       	call   8020a0 <__udivdi3>
  8003b4:	89 d9                	mov    %ebx,%ecx
  8003b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c5:	89 fa                	mov    %edi,%edx
  8003c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ca:	e8 71 ff ff ff       	call   800340 <printnum>
  8003cf:	eb 1b                	jmp    8003ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff d3                	call   *%ebx
  8003dd:	eb 03                	jmp    8003e2 <printnum+0xa2>
  8003df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e2:	83 ee 01             	sub    $0x1,%esi
  8003e5:	85 f6                	test   %esi,%esi
  8003e7:	7f e8                	jg     8003d1 <printnum+0x91>
  8003e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040f:	e8 bc 1d 00 00       	call   8021d0 <__umoddi3>
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	0f be 80 cb 23 80 00 	movsbl 0x8023cb(%eax),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800425:	ff d0                	call   *%eax
}
  800427:	83 c4 3c             	add    $0x3c,%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800435:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	3b 50 04             	cmp    0x4(%eax),%edx
  80043e:	73 0a                	jae    80044a <sprintputch+0x1b>
		*b->buf++ = ch;
  800440:	8d 4a 01             	lea    0x1(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	88 02                	mov    %al,(%edx)
}
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800452:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800459:	8b 45 10             	mov    0x10(%ebp),%eax
  80045c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 44 24 04          	mov    %eax,0x4(%esp)
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	89 04 24             	mov    %eax,(%esp)
  80046d:	e8 02 00 00 00       	call   800474 <vprintfmt>
	va_end(ap);
}
  800472:	c9                   	leave  
  800473:	c3                   	ret    

00800474 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	57                   	push   %edi
  800478:	56                   	push   %esi
  800479:	53                   	push   %ebx
  80047a:	83 ec 3c             	sub    $0x3c,%esp
  80047d:	8b 75 08             	mov    0x8(%ebp),%esi
  800480:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800483:	8b 7d 10             	mov    0x10(%ebp),%edi
  800486:	eb 11                	jmp    800499 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800488:	85 c0                	test   %eax,%eax
  80048a:	0f 84 48 04 00 00    	je     8008d8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800490:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800499:	83 c7 01             	add    $0x1,%edi
  80049c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a0:	83 f8 25             	cmp    $0x25,%eax
  8004a3:	75 e3                	jne    800488 <vprintfmt+0x14>
  8004a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c3:	eb 1f                	jmp    8004e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004cc:	eb 16                	jmp    8004e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8d 47 01             	lea    0x1(%edi),%eax
  8004e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ea:	0f b6 17             	movzbl (%edi),%edx
  8004ed:	0f b6 c2             	movzbl %dl,%eax
  8004f0:	83 ea 23             	sub    $0x23,%edx
  8004f3:	80 fa 55             	cmp    $0x55,%dl
  8004f6:	0f 87 bf 03 00 00    	ja     8008bb <vprintfmt+0x447>
  8004fc:	0f b6 d2             	movzbl %dl,%edx
  8004ff:	ff 24 95 00 25 80 00 	jmp    *0x802500(,%edx,4)
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
  80050e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800511:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800514:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800518:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80051b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051e:	83 f9 09             	cmp    $0x9,%ecx
  800521:	77 3c                	ja     80055f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800523:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800526:	eb e9                	jmp    800511 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 40 04             	lea    0x4(%eax),%eax
  800536:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053c:	eb 27                	jmp    800565 <vprintfmt+0xf1>
  80053e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800541:	85 d2                	test   %edx,%edx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c2             	cmovns %edx,%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	eb 91                	jmp    8004e4 <vprintfmt+0x70>
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80055d:	eb 85                	jmp    8004e4 <vprintfmt+0x70>
  80055f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800562:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800565:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800569:	0f 89 75 ff ff ff    	jns    8004e4 <vprintfmt+0x70>
  80056f:	e9 63 ff ff ff       	jmp    8004d7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800574:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80057a:	e9 65 ff ff ff       	jmp    8004e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800582:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800586:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800594:	e9 00 ff ff ff       	jmp    800499 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	99                   	cltd   
  8005a3:	31 d0                	xor    %edx,%eax
  8005a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a7:	83 f8 0f             	cmp    $0xf,%eax
  8005aa:	7f 0b                	jg     8005b7 <vprintfmt+0x143>
  8005ac:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	75 20                	jne    8005d7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8005b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bb:	c7 44 24 08 e3 23 80 	movl   $0x8023e3,0x8(%esp)
  8005c2:	00 
  8005c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c7:	89 34 24             	mov    %esi,(%esp)
  8005ca:	e8 7d fe ff ff       	call   80044c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d2:	e9 c2 fe ff ff       	jmp    800499 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005db:	c7 44 24 08 ba 27 80 	movl   $0x8027ba,0x8(%esp)
  8005e2:	00 
  8005e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e7:	89 34 24             	mov    %esi,(%esp)
  8005ea:	e8 5d fe ff ff       	call   80044c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f2:	e9 a2 fe ff ff       	jmp    800499 <vprintfmt+0x25>
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800603:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800607:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800609:	85 ff                	test   %edi,%edi
  80060b:	b8 dc 23 80 00       	mov    $0x8023dc,%eax
  800610:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800613:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800617:	0f 84 92 00 00 00    	je     8006af <vprintfmt+0x23b>
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	0f 8e 98 00 00 00    	jle    8006bd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	89 3c 24             	mov    %edi,(%esp)
  80062c:	e8 47 03 00 00       	call   800978 <strnlen>
  800631:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800634:	29 c1                	sub    %eax,%ecx
  800636:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800639:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80063d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800640:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800643:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800645:	eb 0f                	jmp    800656 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	85 ff                	test   %edi,%edi
  800658:	7f ed                	jg     800647 <vprintfmt+0x1d3>
  80065a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80065d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800660:	85 c9                	test   %ecx,%ecx
  800662:	b8 00 00 00 00       	mov    $0x0,%eax
  800667:	0f 49 c1             	cmovns %ecx,%eax
  80066a:	29 c1                	sub    %eax,%ecx
  80066c:	89 75 08             	mov    %esi,0x8(%ebp)
  80066f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800672:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800675:	89 cb                	mov    %ecx,%ebx
  800677:	eb 50                	jmp    8006c9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800679:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067d:	74 1e                	je     80069d <vprintfmt+0x229>
  80067f:	0f be d2             	movsbl %dl,%edx
  800682:	83 ea 20             	sub    $0x20,%edx
  800685:	83 fa 5e             	cmp    $0x5e,%edx
  800688:	76 13                	jbe    80069d <vprintfmt+0x229>
					putch('?', putdat);
  80068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800691:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
  80069b:	eb 0d                	jmp    8006aa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80069d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006aa:	83 eb 01             	sub    $0x1,%ebx
  8006ad:	eb 1a                	jmp    8006c9 <vprintfmt+0x255>
  8006af:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006bb:	eb 0c                	jmp    8006c9 <vprintfmt+0x255>
  8006bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006c9:	83 c7 01             	add    $0x1,%edi
  8006cc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006d0:	0f be c2             	movsbl %dl,%eax
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 25                	je     8006fc <vprintfmt+0x288>
  8006d7:	85 f6                	test   %esi,%esi
  8006d9:	78 9e                	js     800679 <vprintfmt+0x205>
  8006db:	83 ee 01             	sub    $0x1,%esi
  8006de:	79 99                	jns    800679 <vprintfmt+0x205>
  8006e0:	89 df                	mov    %ebx,%edi
  8006e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e8:	eb 1a                	jmp    800704 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006f5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f7:	83 ef 01             	sub    $0x1,%edi
  8006fa:	eb 08                	jmp    800704 <vprintfmt+0x290>
  8006fc:	89 df                	mov    %ebx,%edi
  8006fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800704:	85 ff                	test   %edi,%edi
  800706:	7f e2                	jg     8006ea <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070b:	e9 89 fd ff ff       	jmp    800499 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800710:	83 f9 01             	cmp    $0x1,%ecx
  800713:	7e 19                	jle    80072e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 50 04             	mov    0x4(%eax),%edx
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800720:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 40 08             	lea    0x8(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
  80072c:	eb 38                	jmp    800766 <vprintfmt+0x2f2>
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 1b                	je     80074d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 c1                	mov    %eax,%ecx
  80073c:	c1 f9 1f             	sar    $0x1f,%ecx
  80073f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 40 04             	lea    0x4(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
  80074b:	eb 19                	jmp    800766 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 00                	mov    (%eax),%eax
  800752:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800755:	89 c1                	mov    %eax,%ecx
  800757:	c1 f9 1f             	sar    $0x1f,%ecx
  80075a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8d 40 04             	lea    0x4(%eax),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800766:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800769:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80076c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800771:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800775:	0f 89 04 01 00 00    	jns    80087f <vprintfmt+0x40b>
				putch('-', putdat);
  80077b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800786:	ff d6                	call   *%esi
				num = -(long long) num;
  800788:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80078b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078e:	f7 da                	neg    %edx
  800790:	83 d1 00             	adc    $0x0,%ecx
  800793:	f7 d9                	neg    %ecx
  800795:	e9 e5 00 00 00       	jmp    80087f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079a:	83 f9 01             	cmp    $0x1,%ecx
  80079d:	7e 10                	jle    8007af <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a7:	8d 40 08             	lea    0x8(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ad:	eb 26                	jmp    8007d5 <vprintfmt+0x361>
	else if (lflag)
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	74 12                	je     8007c5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 10                	mov    (%eax),%edx
  8007b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bd:	8d 40 04             	lea    0x4(%eax),%eax
  8007c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c3:	eb 10                	jmp    8007d5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cf:	8d 40 04             	lea    0x4(%eax),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007da:	e9 a0 00 00 00       	jmp    80087f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007ea:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800804:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800809:	e9 8b fc ff ff       	jmp    800499 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80080e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800812:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800819:	ff d6                	call   *%esi
			putch('x', putdat);
  80081b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800826:	ff d6                	call   *%esi
			num = (unsigned long long)
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800832:	8d 40 04             	lea    0x4(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800838:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80083d:	eb 40                	jmp    80087f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083f:	83 f9 01             	cmp    $0x1,%ecx
  800842:	7e 10                	jle    800854 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8b 10                	mov    (%eax),%edx
  800849:	8b 48 04             	mov    0x4(%eax),%ecx
  80084c:	8d 40 08             	lea    0x8(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
  800852:	eb 26                	jmp    80087a <vprintfmt+0x406>
	else if (lflag)
  800854:	85 c9                	test   %ecx,%ecx
  800856:	74 12                	je     80086a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	8d 40 04             	lea    0x4(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
  800868:	eb 10                	jmp    80087a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8b 10                	mov    (%eax),%edx
  80086f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800874:	8d 40 04             	lea    0x4(%eax),%eax
  800877:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80087a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800883:	89 44 24 10          	mov    %eax,0x10(%esp)
  800887:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800892:	89 14 24             	mov    %edx,(%esp)
  800895:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800899:	89 da                	mov    %ebx,%edx
  80089b:	89 f0                	mov    %esi,%eax
  80089d:	e8 9e fa ff ff       	call   800340 <printnum>
			break;
  8008a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a5:	e9 ef fb ff ff       	jmp    800499 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b6:	e9 de fb ff ff       	jmp    800499 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	eb 03                	jmp    8008cd <vprintfmt+0x459>
  8008ca:	83 ef 01             	sub    $0x1,%edi
  8008cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d1:	75 f7                	jne    8008ca <vprintfmt+0x456>
  8008d3:	e9 c1 fb ff ff       	jmp    800499 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008d8:	83 c4 3c             	add    $0x3c,%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 28             	sub    $0x28,%esp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	74 30                	je     800931 <vsnprintf+0x51>
  800901:	85 d2                	test   %edx,%edx
  800903:	7e 2c                	jle    800931 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090c:	8b 45 10             	mov    0x10(%ebp),%eax
  80090f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800913:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	c7 04 24 2f 04 80 00 	movl   $0x80042f,(%esp)
  800921:	e8 4e fb ff ff       	call   800474 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800926:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800929:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092f:	eb 05                	jmp    800936 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800931:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800941:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800945:	8b 45 10             	mov    0x10(%ebp),%eax
  800948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	e8 82 ff ff ff       	call   8008e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	eb 03                	jmp    800970 <strlen+0x10>
		n++;
  80096d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800970:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800974:	75 f7                	jne    80096d <strlen+0xd>
		n++;
	return n;
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strnlen+0x13>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098b:	39 d0                	cmp    %edx,%eax
  80098d:	74 06                	je     800995 <strnlen+0x1d>
  80098f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800993:	75 f3                	jne    800988 <strnlen+0x10>
		n++;
	return n;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b0:	84 db                	test   %bl,%bl
  8009b2:	75 ef                	jne    8009a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c1:	89 1c 24             	mov    %ebx,(%esp)
  8009c4:	e8 97 ff ff ff       	call   800960 <strlen>
	strcpy(dst + len, src);
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d0:	01 d8                	add    %ebx,%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 bd ff ff ff       	call   800997 <strcpy>
	return dst;
}
  8009da:	89 d8                	mov    %ebx,%eax
  8009dc:	83 c4 08             	add    $0x8,%esp
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 0f                	jmp    800a05 <strncpy+0x23>
		*dst++ = *src;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800a02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a05:	39 da                	cmp    %ebx,%edx
  800a07:	75 ed                	jne    8009f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	75 0b                	jne    800a32 <strlcpy+0x23>
  800a27:	eb 1d                	jmp    800a46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	83 c2 01             	add    $0x1,%edx
  800a2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	74 0b                	je     800a41 <strlcpy+0x32>
  800a36:	0f b6 0a             	movzbl (%edx),%ecx
  800a39:	84 c9                	test   %cl,%cl
  800a3b:	75 ec                	jne    800a29 <strlcpy+0x1a>
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	eb 02                	jmp    800a43 <strlcpy+0x34>
  800a41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a46:	29 f0                	sub    %esi,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a55:	eb 06                	jmp    800a5d <strcmp+0x11>
		p++, q++;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5d:	0f b6 01             	movzbl (%ecx),%eax
  800a60:	84 c0                	test   %al,%al
  800a62:	74 04                	je     800a68 <strcmp+0x1c>
  800a64:	3a 02                	cmp    (%edx),%al
  800a66:	74 ef                	je     800a57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 c0             	movzbl %al,%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strncmp+0x17>
		n--, p++, q++;
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a89:	39 d8                	cmp    %ebx,%eax
  800a8b:	74 15                	je     800aa2 <strncmp+0x30>
  800a8d:	0f b6 08             	movzbl (%eax),%ecx
  800a90:	84 c9                	test   %cl,%cl
  800a92:	74 04                	je     800a98 <strncmp+0x26>
  800a94:	3a 0a                	cmp    (%edx),%cl
  800a96:	74 eb                	je     800a83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 00             	movzbl (%eax),%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
  800aa0:	eb 05                	jmp    800aa7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab4:	eb 07                	jmp    800abd <strchr+0x13>
		if (*s == c)
  800ab6:	38 ca                	cmp    %cl,%dl
  800ab8:	74 0f                	je     800ac9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 f2                	jne    800ab6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	eb 07                	jmp    800ade <strfind+0x13>
		if (*s == c)
  800ad7:	38 ca                	cmp    %cl,%dl
  800ad9:	74 0a                	je     800ae5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	0f b6 10             	movzbl (%eax),%edx
  800ae1:	84 d2                	test   %dl,%dl
  800ae3:	75 f2                	jne    800ad7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af3:	85 c9                	test   %ecx,%ecx
  800af5:	74 36                	je     800b2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afd:	75 28                	jne    800b27 <memset+0x40>
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 23                	jne    800b27 <memset+0x40>
		c &= 0xFF;
  800b04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	c1 e3 08             	shl    $0x8,%ebx
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	c1 e6 18             	shl    $0x18,%esi
  800b12:	89 d0                	mov    %edx,%eax
  800b14:	c1 e0 10             	shl    $0x10,%eax
  800b17:	09 f0                	or     %esi,%eax
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b22:	fc                   	cld    
  800b23:	f3 ab                	rep stos %eax,%es:(%edi)
  800b25:	eb 06                	jmp    800b2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 35                	jae    800b7b <memmove+0x47>
  800b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 2e                	jae    800b7b <memmove+0x47>
		s += n;
		d += n;
  800b4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5a:	75 13                	jne    800b6f <memmove+0x3b>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0e                	jne    800b6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b61:	83 ef 04             	sub    $0x4,%edi
  800b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b6a:	fd                   	std    
  800b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6d:	eb 09                	jmp    800b78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b6f:	83 ef 01             	sub    $0x1,%edi
  800b72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b75:	fd                   	std    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b78:	fc                   	cld    
  800b79:	eb 1d                	jmp    800b98 <memmove+0x64>
  800b7b:	89 f2                	mov    %esi,%edx
  800b7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	f6 c2 03             	test   $0x3,%dl
  800b82:	75 0f                	jne    800b93 <memmove+0x5f>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0a                	jne    800b93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 05                	jmp    800b98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	e8 79 ff ff ff       	call   800b34 <memmove>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcd:	eb 1a                	jmp    800be9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bcf:	0f b6 02             	movzbl (%edx),%eax
  800bd2:	0f b6 19             	movzbl (%ecx),%ebx
  800bd5:	38 d8                	cmp    %bl,%al
  800bd7:	74 0a                	je     800be3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd9:	0f b6 c0             	movzbl %al,%eax
  800bdc:	0f b6 db             	movzbl %bl,%ebx
  800bdf:	29 d8                	sub    %ebx,%eax
  800be1:	eb 0f                	jmp    800bf2 <memcmp+0x35>
		s1++, s2++;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be9:	39 f2                	cmp    %esi,%edx
  800beb:	75 e2                	jne    800bcf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c04:	eb 07                	jmp    800c0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c06:	38 08                	cmp    %cl,(%eax)
  800c08:	74 07                	je     800c11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	39 d0                	cmp    %edx,%eax
  800c0f:	72 f5                	jb     800c06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1f:	eb 03                	jmp    800c24 <strtol+0x11>
		s++;
  800c21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c24:	0f b6 0a             	movzbl (%edx),%ecx
  800c27:	80 f9 09             	cmp    $0x9,%cl
  800c2a:	74 f5                	je     800c21 <strtol+0xe>
  800c2c:	80 f9 20             	cmp    $0x20,%cl
  800c2f:	74 f0                	je     800c21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c31:	80 f9 2b             	cmp    $0x2b,%cl
  800c34:	75 0a                	jne    800c40 <strtol+0x2d>
		s++;
  800c36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3e:	eb 11                	jmp    800c51 <strtol+0x3e>
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c45:	80 f9 2d             	cmp    $0x2d,%cl
  800c48:	75 07                	jne    800c51 <strtol+0x3e>
		s++, neg = 1;
  800c4a:	8d 52 01             	lea    0x1(%edx),%edx
  800c4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c56:	75 15                	jne    800c6d <strtol+0x5a>
  800c58:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5b:	75 10                	jne    800c6d <strtol+0x5a>
  800c5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c61:	75 0a                	jne    800c6d <strtol+0x5a>
		s += 2, base = 16;
  800c63:	83 c2 02             	add    $0x2,%edx
  800c66:	b8 10 00 00 00       	mov    $0x10,%eax
  800c6b:	eb 10                	jmp    800c7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	75 0c                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	80 3a 30             	cmpb   $0x30,(%edx)
  800c76:	75 05                	jne    800c7d <strtol+0x6a>
		s++, base = 8;
  800c78:	83 c2 01             	add    $0x1,%edx
  800c7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c85:	0f b6 0a             	movzbl (%edx),%ecx
  800c88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c8b:	89 f0                	mov    %esi,%eax
  800c8d:	3c 09                	cmp    $0x9,%al
  800c8f:	77 08                	ja     800c99 <strtol+0x86>
			dig = *s - '0';
  800c91:	0f be c9             	movsbl %cl,%ecx
  800c94:	83 e9 30             	sub    $0x30,%ecx
  800c97:	eb 20                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	3c 19                	cmp    $0x19,%al
  800ca0:	77 08                	ja     800caa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ca2:	0f be c9             	movsbl %cl,%ecx
  800ca5:	83 e9 57             	sub    $0x57,%ecx
  800ca8:	eb 0f                	jmp    800cb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800caa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cad:	89 f0                	mov    %esi,%eax
  800caf:	3c 19                	cmp    $0x19,%al
  800cb1:	77 16                	ja     800cc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800cb3:	0f be c9             	movsbl %cl,%ecx
  800cb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cbc:	7d 0f                	jge    800ccd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cc7:	eb bc                	jmp    800c85 <strtol+0x72>
  800cc9:	89 d8                	mov    %ebx,%eax
  800ccb:	eb 02                	jmp    800ccf <strtol+0xbc>
  800ccd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ccf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd3:	74 05                	je     800cda <strtol+0xc7>
		*endptr = (char *) s;
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cda:	f7 d8                	neg    %eax
  800cdc:	85 ff                	test   %edi,%edi
  800cde:	0f 44 c3             	cmove  %ebx,%eax
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 c3                	mov    %eax,%ebx
  800cf9:	89 c7                	mov    %eax,%edi
  800cfb:	89 c6                	mov    %eax,%esi
  800cfd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_cgetc>:

int
sys_cgetc(void)
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
  800d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d14:	89 d1                	mov    %edx,%ecx
  800d16:	89 d3                	mov    %edx,%ebx
  800d18:	89 d7                	mov    %edx,%edi
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 03 00 00 00       	mov    $0x3,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 28                	jle    800d6d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d49:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d50:	00 
  800d51:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800d58:	00 
  800d59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d60:	00 
  800d61:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800d68:	e8 b5 f4 ff ff       	call   800222 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6d:	83 c4 2c             	add    $0x2c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 02 00 00 00       	mov    $0x2,%eax
  800d85:	89 d1                	mov    %edx,%ecx
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	89 d7                	mov    %edx,%edi
  800d8b:	89 d6                	mov    %edx,%esi
  800d8d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_yield>:

void
sys_yield(void)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da4:	89 d1                	mov    %edx,%ecx
  800da6:	89 d3                	mov    %edx,%ebx
  800da8:	89 d7                	mov    %edx,%edi
  800daa:	89 d6                	mov    %edx,%esi
  800dac:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	be 00 00 00 00       	mov    $0x0,%esi
  800dc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	89 f7                	mov    %esi,%edi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 28                	jle    800dff <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800dea:	00 
  800deb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df2:	00 
  800df3:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800dfa:	e8 23 f4 ff ff       	call   800222 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dff:	83 c4 2c             	add    $0x2c,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	b8 05 00 00 00       	mov    $0x5,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e21:	8b 75 18             	mov    0x18(%ebp),%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800e4d:	e8 d0 f3 ff ff       	call   800222 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800ea0:	e8 7d f3 ff ff       	call   800222 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea5:	83 c4 2c             	add    $0x2c,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800ef3:	e8 2a f3 ff ff       	call   800222 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef8:	83 c4 2c             	add    $0x2c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	89 df                	mov    %ebx,%edi
  800f1b:	89 de                	mov    %ebx,%esi
  800f1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7e 28                	jle    800f4b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f27:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800f46:	e8 d7 f2 ff ff       	call   800222 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f4b:	83 c4 2c             	add    $0x2c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	57                   	push   %edi
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 df                	mov    %ebx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	7e 28                	jle    800f9e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  800f99:	e8 84 f2 ff ff       	call   800222 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f9e:	83 c4 2c             	add    $0x2c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdf:	89 cb                	mov    %ecx,%ebx
  800fe1:	89 cf                	mov    %ecx,%edi
  800fe3:	89 ce                	mov    %ecx,%esi
  800fe5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 28                	jle    801013 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fef:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 bf 26 80 	movl   $0x8026bf,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  80100e:	e8 0f f2 ff ff       	call   800222 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801013:	83 c4 2c             	add    $0x2c,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
  80101b:	66 90                	xchg   %ax,%ax
  80101d:	66 90                	xchg   %ax,%ax
  80101f:	90                   	nop

00801020 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801040:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801052:	89 c2                	mov    %eax,%edx
  801054:	c1 ea 16             	shr    $0x16,%edx
  801057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105e:	f6 c2 01             	test   $0x1,%dl
  801061:	74 11                	je     801074 <fd_alloc+0x2d>
  801063:	89 c2                	mov    %eax,%edx
  801065:	c1 ea 0c             	shr    $0xc,%edx
  801068:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	75 09                	jne    80107d <fd_alloc+0x36>
			*fd_store = fd;
  801074:	89 01                	mov    %eax,(%ecx)
			return 0;
  801076:	b8 00 00 00 00       	mov    $0x0,%eax
  80107b:	eb 17                	jmp    801094 <fd_alloc+0x4d>
  80107d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801082:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801087:	75 c9                	jne    801052 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801089:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80108f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109c:	83 f8 1f             	cmp    $0x1f,%eax
  80109f:	77 36                	ja     8010d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a1:	c1 e0 0c             	shl    $0xc,%eax
  8010a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 24                	je     8010de <fd_lookup+0x48>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	74 1a                	je     8010e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d5:	eb 13                	jmp    8010ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb 0c                	jmp    8010ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e3:	eb 05                	jmp    8010ea <fd_lookup+0x54>
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 18             	sub    $0x18,%esp
  8010f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f5:	ba 68 27 80 00       	mov    $0x802768,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fa:	eb 13                	jmp    80110f <dev_lookup+0x23>
  8010fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010ff:	39 08                	cmp    %ecx,(%eax)
  801101:	75 0c                	jne    80110f <dev_lookup+0x23>
			*dev = devtab[i];
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	89 01                	mov    %eax,(%ecx)
			return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	eb 30                	jmp    80113f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80110f:	8b 02                	mov    (%edx),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	75 e7                	jne    8010fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801115:	a1 08 40 80 00       	mov    0x804008,%eax
  80111a:	8b 40 48             	mov    0x48(%eax),%eax
  80111d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801121:	89 44 24 04          	mov    %eax,0x4(%esp)
  801125:	c7 04 24 ec 26 80 00 	movl   $0x8026ec,(%esp)
  80112c:	e8 ea f1 ff ff       	call   80031b <cprintf>
	*dev = 0;
  801131:	8b 45 0c             	mov    0xc(%ebp),%eax
  801134:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80113a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 20             	sub    $0x20,%esp
  801149:	8b 75 08             	mov    0x8(%ebp),%esi
  80114c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801152:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801156:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80115c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115f:	89 04 24             	mov    %eax,(%esp)
  801162:	e8 2f ff ff ff       	call   801096 <fd_lookup>
  801167:	85 c0                	test   %eax,%eax
  801169:	78 05                	js     801170 <fd_close+0x2f>
	    || fd != fd2)
  80116b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116e:	74 0c                	je     80117c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801170:	84 db                	test   %bl,%bl
  801172:	ba 00 00 00 00       	mov    $0x0,%edx
  801177:	0f 44 c2             	cmove  %edx,%eax
  80117a:	eb 3f                	jmp    8011bb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801183:	8b 06                	mov    (%esi),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 5f ff ff ff       	call   8010ec <dev_lookup>
  80118d:	89 c3                	mov    %eax,%ebx
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 16                	js     8011a9 <fd_close+0x68>
		if (dev->dev_close)
  801193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801196:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801199:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	74 07                	je     8011a9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8011a2:	89 34 24             	mov    %esi,(%esp)
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b4:	e8 a1 fc ff ff       	call   800e5a <sys_page_unmap>
	return r;
  8011b9:	89 d8                	mov    %ebx,%eax
}
  8011bb:	83 c4 20             	add    $0x20,%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	89 04 24             	mov    %eax,(%esp)
  8011d5:	e8 bc fe ff ff       	call   801096 <fd_lookup>
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	85 d2                	test   %edx,%edx
  8011de:	78 13                	js     8011f3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8011e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011e7:	00 
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	89 04 24             	mov    %eax,(%esp)
  8011ee:	e8 4e ff ff ff       	call   801141 <fd_close>
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <close_all>:

void
close_all(void)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801201:	89 1c 24             	mov    %ebx,(%esp)
  801204:	e8 b9 ff ff ff       	call   8011c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801209:	83 c3 01             	add    $0x1,%ebx
  80120c:	83 fb 20             	cmp    $0x20,%ebx
  80120f:	75 f0                	jne    801201 <close_all+0xc>
		close(i);
}
  801211:	83 c4 14             	add    $0x14,%esp
  801214:	5b                   	pop    %ebx
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	57                   	push   %edi
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801220:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801223:	89 44 24 04          	mov    %eax,0x4(%esp)
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
  80122a:	89 04 24             	mov    %eax,(%esp)
  80122d:	e8 64 fe ff ff       	call   801096 <fd_lookup>
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	0f 88 e1 00 00 00    	js     80131d <dup+0x106>
		return r;
	close(newfdnum);
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123f:	89 04 24             	mov    %eax,(%esp)
  801242:	e8 7b ff ff ff       	call   8011c2 <close>

	newfd = INDEX2FD(newfdnum);
  801247:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80124a:	c1 e3 0c             	shl    $0xc,%ebx
  80124d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801256:	89 04 24             	mov    %eax,(%esp)
  801259:	e8 d2 fd ff ff       	call   801030 <fd2data>
  80125e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801260:	89 1c 24             	mov    %ebx,(%esp)
  801263:	e8 c8 fd ff ff       	call   801030 <fd2data>
  801268:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80126a:	89 f0                	mov    %esi,%eax
  80126c:	c1 e8 16             	shr    $0x16,%eax
  80126f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801276:	a8 01                	test   $0x1,%al
  801278:	74 43                	je     8012bd <dup+0xa6>
  80127a:	89 f0                	mov    %esi,%eax
  80127c:	c1 e8 0c             	shr    $0xc,%eax
  80127f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801286:	f6 c2 01             	test   $0x1,%dl
  801289:	74 32                	je     8012bd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80128b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801292:	25 07 0e 00 00       	and    $0xe07,%eax
  801297:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a6:	00 
  8012a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b2:	e8 50 fb ff ff       	call   800e07 <sys_page_map>
  8012b7:	89 c6                	mov    %eax,%esi
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 3e                	js     8012fb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 ea 0c             	shr    $0xc,%edx
  8012c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e1:	00 
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ed:	e8 15 fb ff ff       	call   800e07 <sys_page_map>
  8012f2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8012f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f7:	85 f6                	test   %esi,%esi
  8012f9:	79 22                	jns    80131d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801306:	e8 4f fb ff ff       	call   800e5a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80130b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801316:	e8 3f fb ff ff       	call   800e5a <sys_page_unmap>
	return r;
  80131b:	89 f0                	mov    %esi,%eax
}
  80131d:	83 c4 3c             	add    $0x3c,%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	53                   	push   %ebx
  801329:	83 ec 24             	sub    $0x24,%esp
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	89 44 24 04          	mov    %eax,0x4(%esp)
  801336:	89 1c 24             	mov    %ebx,(%esp)
  801339:	e8 58 fd ff ff       	call   801096 <fd_lookup>
  80133e:	89 c2                	mov    %eax,%edx
  801340:	85 d2                	test   %edx,%edx
  801342:	78 6d                	js     8013b1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	8b 00                	mov    (%eax),%eax
  801350:	89 04 24             	mov    %eax,(%esp)
  801353:	e8 94 fd ff ff       	call   8010ec <dev_lookup>
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 55                	js     8013b1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135f:	8b 50 08             	mov    0x8(%eax),%edx
  801362:	83 e2 03             	and    $0x3,%edx
  801365:	83 fa 01             	cmp    $0x1,%edx
  801368:	75 23                	jne    80138d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136a:	a1 08 40 80 00       	mov    0x804008,%eax
  80136f:	8b 40 48             	mov    0x48(%eax),%eax
  801372:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	c7 04 24 2d 27 80 00 	movl   $0x80272d,(%esp)
  801381:	e8 95 ef ff ff       	call   80031b <cprintf>
		return -E_INVAL;
  801386:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138b:	eb 24                	jmp    8013b1 <read+0x8c>
	}
	if (!dev->dev_read)
  80138d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801390:	8b 52 08             	mov    0x8(%edx),%edx
  801393:	85 d2                	test   %edx,%edx
  801395:	74 15                	je     8013ac <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801397:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80139a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a5:	89 04 24             	mov    %eax,(%esp)
  8013a8:	ff d2                	call   *%edx
  8013aa:	eb 05                	jmp    8013b1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013b1:	83 c4 24             	add    $0x24,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	57                   	push   %edi
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 1c             	sub    $0x1c,%esp
  8013c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cb:	eb 23                	jmp    8013f0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013cd:	89 f0                	mov    %esi,%eax
  8013cf:	29 d8                	sub    %ebx,%eax
  8013d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d5:	89 d8                	mov    %ebx,%eax
  8013d7:	03 45 0c             	add    0xc(%ebp),%eax
  8013da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013de:	89 3c 24             	mov    %edi,(%esp)
  8013e1:	e8 3f ff ff ff       	call   801325 <read>
		if (m < 0)
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 10                	js     8013fa <readn+0x43>
			return m;
		if (m == 0)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 0a                	je     8013f8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ee:	01 c3                	add    %eax,%ebx
  8013f0:	39 f3                	cmp    %esi,%ebx
  8013f2:	72 d9                	jb     8013cd <readn+0x16>
  8013f4:	89 d8                	mov    %ebx,%eax
  8013f6:	eb 02                	jmp    8013fa <readn+0x43>
  8013f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fa:	83 c4 1c             	add    $0x1c,%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5f                   	pop    %edi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	53                   	push   %ebx
  801406:	83 ec 24             	sub    $0x24,%esp
  801409:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	89 1c 24             	mov    %ebx,(%esp)
  801416:	e8 7b fc ff ff       	call   801096 <fd_lookup>
  80141b:	89 c2                	mov    %eax,%edx
  80141d:	85 d2                	test   %edx,%edx
  80141f:	78 68                	js     801489 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142b:	8b 00                	mov    (%eax),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 b7 fc ff ff       	call   8010ec <dev_lookup>
  801435:	85 c0                	test   %eax,%eax
  801437:	78 50                	js     801489 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801440:	75 23                	jne    801465 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801442:	a1 08 40 80 00       	mov    0x804008,%eax
  801447:	8b 40 48             	mov    0x48(%eax),%eax
  80144a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	c7 04 24 49 27 80 00 	movl   $0x802749,(%esp)
  801459:	e8 bd ee ff ff       	call   80031b <cprintf>
		return -E_INVAL;
  80145e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801463:	eb 24                	jmp    801489 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801465:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801468:	8b 52 0c             	mov    0xc(%edx),%edx
  80146b:	85 d2                	test   %edx,%edx
  80146d:	74 15                	je     801484 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801472:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801476:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801479:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80147d:	89 04 24             	mov    %eax,(%esp)
  801480:	ff d2                	call   *%edx
  801482:	eb 05                	jmp    801489 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801484:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801489:	83 c4 24             	add    $0x24,%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <seek>:

int
seek(int fdnum, off_t offset)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801495:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 ef fb ff ff       	call   801096 <fd_lookup>
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 0e                	js     8014b9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 24             	sub    $0x24,%esp
  8014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cc:	89 1c 24             	mov    %ebx,(%esp)
  8014cf:	e8 c2 fb ff ff       	call   801096 <fd_lookup>
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	85 d2                	test   %edx,%edx
  8014d8:	78 61                	js     80153b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	8b 00                	mov    (%eax),%eax
  8014e6:	89 04 24             	mov    %eax,(%esp)
  8014e9:	e8 fe fb ff ff       	call   8010ec <dev_lookup>
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 49                	js     80153b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f9:	75 23                	jne    80151e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801500:	8b 40 48             	mov    0x48(%eax),%eax
  801503:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	c7 04 24 0c 27 80 00 	movl   $0x80270c,(%esp)
  801512:	e8 04 ee ff ff       	call   80031b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151c:	eb 1d                	jmp    80153b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 18             	mov    0x18(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 0e                	je     801536 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801528:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80152b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	ff d2                	call   *%edx
  801534:	eb 05                	jmp    80153b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801536:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80153b:	83 c4 24             	add    $0x24,%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 24             	sub    $0x24,%esp
  801548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 39 fb ff ff       	call   801096 <fd_lookup>
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	85 d2                	test   %edx,%edx
  801561:	78 52                	js     8015b5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	8b 00                	mov    (%eax),%eax
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	e8 75 fb ff ff       	call   8010ec <dev_lookup>
  801577:	85 c0                	test   %eax,%eax
  801579:	78 3a                	js     8015b5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80157b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801582:	74 2c                	je     8015b0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801584:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801587:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158e:	00 00 00 
	stat->st_isdir = 0;
  801591:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801598:	00 00 00 
	stat->st_dev = dev;
  80159b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a8:	89 14 24             	mov    %edx,(%esp)
  8015ab:	ff 50 14             	call   *0x14(%eax)
  8015ae:	eb 05                	jmp    8015b5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015b5:	83 c4 24             	add    $0x24,%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5d                   	pop    %ebp
  8015ba:	c3                   	ret    

008015bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015ca:	00 
  8015cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ce:	89 04 24             	mov    %eax,(%esp)
  8015d1:	e8 fb 01 00 00       	call   8017d1 <open>
  8015d6:	89 c3                	mov    %eax,%ebx
  8015d8:	85 db                	test   %ebx,%ebx
  8015da:	78 1b                	js     8015f7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e3:	89 1c 24             	mov    %ebx,(%esp)
  8015e6:	e8 56 ff ff ff       	call   801541 <fstat>
  8015eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ed:	89 1c 24             	mov    %ebx,(%esp)
  8015f0:	e8 cd fb ff ff       	call   8011c2 <close>
	return r;
  8015f5:	89 f0                	mov    %esi,%eax
}
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 10             	sub    $0x10,%esp
  801606:	89 c6                	mov    %eax,%esi
  801608:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80160a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801611:	75 11                	jne    801624 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801613:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80161a:	e8 0e 0a 00 00       	call   80202d <ipc_find_env>
  80161f:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801624:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80162b:	00 
  80162c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801633:	00 
  801634:	89 74 24 04          	mov    %esi,0x4(%esp)
  801638:	a1 04 40 80 00       	mov    0x804004,%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 39 09 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801645:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164c:	00 
  80164d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801658:	e8 83 08 00 00       	call   801ee0 <ipc_recv>
}
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	8b 40 0c             	mov    0xc(%eax),%eax
  801670:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801675:	8b 45 0c             	mov    0xc(%ebp),%eax
  801678:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	b8 02 00 00 00       	mov    $0x2,%eax
  801687:	e8 72 ff ff ff       	call   8015fe <fsipc>
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	8b 40 0c             	mov    0xc(%eax),%eax
  80169a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a9:	e8 50 ff ff ff       	call   8015fe <fsipc>
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 14             	sub    $0x14,%esp
  8016b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8016cf:	e8 2a ff ff ff       	call   8015fe <fsipc>
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	85 d2                	test   %edx,%edx
  8016d8:	78 2b                	js     801705 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016e1:	00 
  8016e2:	89 1c 24             	mov    %ebx,(%esp)
  8016e5:	e8 ad f2 ff ff       	call   800997 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8016fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801705:	83 c4 14             	add    $0x14,%esp
  801708:	5b                   	pop    %ebx
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801711:	c7 44 24 08 78 27 80 	movl   $0x802778,0x8(%esp)
  801718:	00 
  801719:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801720:	00 
  801721:	c7 04 24 96 27 80 00 	movl   $0x802796,(%esp)
  801728:	e8 f5 ea ff ff       	call   800222 <_panic>

0080172d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	83 ec 10             	sub    $0x10,%esp
  801735:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
  80173e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801743:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 03 00 00 00       	mov    $0x3,%eax
  801753:	e8 a6 fe ff ff       	call   8015fe <fsipc>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 6a                	js     8017c8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80175e:	39 c6                	cmp    %eax,%esi
  801760:	73 24                	jae    801786 <devfile_read+0x59>
  801762:	c7 44 24 0c a1 27 80 	movl   $0x8027a1,0xc(%esp)
  801769:	00 
  80176a:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  801771:	00 
  801772:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801779:	00 
  80177a:	c7 04 24 96 27 80 00 	movl   $0x802796,(%esp)
  801781:	e8 9c ea ff ff       	call   800222 <_panic>
	assert(r <= PGSIZE);
  801786:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178b:	7e 24                	jle    8017b1 <devfile_read+0x84>
  80178d:	c7 44 24 0c bd 27 80 	movl   $0x8027bd,0xc(%esp)
  801794:	00 
  801795:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  80179c:	00 
  80179d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017a4:	00 
  8017a5:	c7 04 24 96 27 80 00 	movl   $0x802796,(%esp)
  8017ac:	e8 71 ea ff ff       	call   800222 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017bc:	00 
  8017bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	e8 6c f3 ff ff       	call   800b34 <memmove>
	return r;
}
  8017c8:	89 d8                	mov    %ebx,%eax
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	5b                   	pop    %ebx
  8017ce:	5e                   	pop    %esi
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 24             	sub    $0x24,%esp
  8017d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017db:	89 1c 24             	mov    %ebx,(%esp)
  8017de:	e8 7d f1 ff ff       	call   800960 <strlen>
  8017e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e8:	7f 60                	jg     80184a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 52 f8 ff ff       	call   801047 <fd_alloc>
  8017f5:	89 c2                	mov    %eax,%edx
  8017f7:	85 d2                	test   %edx,%edx
  8017f9:	78 54                	js     80184f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ff:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801806:	e8 8c f1 ff ff       	call   800997 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80180b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801816:	b8 01 00 00 00       	mov    $0x1,%eax
  80181b:	e8 de fd ff ff       	call   8015fe <fsipc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	85 c0                	test   %eax,%eax
  801824:	79 17                	jns    80183d <open+0x6c>
		fd_close(fd, 0);
  801826:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80182d:	00 
  80182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801831:	89 04 24             	mov    %eax,(%esp)
  801834:	e8 08 f9 ff ff       	call   801141 <fd_close>
		return r;
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	eb 12                	jmp    80184f <open+0x7e>
	}

	return fd2num(fd);
  80183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801840:	89 04 24             	mov    %eax,(%esp)
  801843:	e8 d8 f7 ff ff       	call   801020 <fd2num>
  801848:	eb 05                	jmp    80184f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80184a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80184f:	83 c4 24             	add    $0x24,%esp
  801852:	5b                   	pop    %ebx
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 08 00 00 00       	mov    $0x8,%eax
  801865:	e8 94 fd ff ff       	call   8015fe <fsipc>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 14             	sub    $0x14,%esp
  801873:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801875:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801879:	7e 31                	jle    8018ac <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80187b:	8b 40 04             	mov    0x4(%eax),%eax
  80187e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801882:	8d 43 10             	lea    0x10(%ebx),%eax
  801885:	89 44 24 04          	mov    %eax,0x4(%esp)
  801889:	8b 03                	mov    (%ebx),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 6f fb ff ff       	call   801402 <write>
		if (result > 0)
  801893:	85 c0                	test   %eax,%eax
  801895:	7e 03                	jle    80189a <writebuf+0x2e>
			b->result += result;
  801897:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80189a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80189d:	74 0d                	je     8018ac <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a6:	0f 4f c2             	cmovg  %edx,%eax
  8018a9:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018ac:	83 c4 14             	add    $0x14,%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <putch>:

static void
putch(int ch, void *thunk)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018bc:	8b 53 04             	mov    0x4(%ebx),%edx
  8018bf:	8d 42 01             	lea    0x1(%edx),%eax
  8018c2:	89 43 04             	mov    %eax,0x4(%ebx)
  8018c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018cc:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018d1:	75 0e                	jne    8018e1 <putch+0x2f>
		writebuf(b);
  8018d3:	89 d8                	mov    %ebx,%eax
  8018d5:	e8 92 ff ff ff       	call   80186c <writebuf>
		b->idx = 0;
  8018da:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018e1:	83 c4 04             	add    $0x4,%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018f9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801900:	00 00 00 
	b.result = 0;
  801903:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80190a:	00 00 00 
	b.error = 1;
  80190d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801914:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801917:	8b 45 10             	mov    0x10(%ebp),%eax
  80191a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801921:	89 44 24 08          	mov    %eax,0x8(%esp)
  801925:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80192b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192f:	c7 04 24 b2 18 80 00 	movl   $0x8018b2,(%esp)
  801936:	e8 39 eb ff ff       	call   800474 <vprintfmt>
	if (b.idx > 0)
  80193b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801942:	7e 0b                	jle    80194f <vfprintf+0x68>
		writebuf(&b);
  801944:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80194a:	e8 1d ff ff ff       	call   80186c <writebuf>

	return (b.result ? b.result : b.error);
  80194f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801966:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801969:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801970:	89 44 24 04          	mov    %eax,0x4(%esp)
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 68 ff ff ff       	call   8018e7 <vfprintf>
	va_end(ap);

	return cnt;
}
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <printf>:

int
printf(const char *fmt, ...)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801987:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80198a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198e:	8b 45 08             	mov    0x8(%ebp),%eax
  801991:	89 44 24 04          	mov    %eax,0x4(%esp)
  801995:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80199c:	e8 46 ff ff ff       	call   8018e7 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 10             	sub    $0x10,%esp
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	89 04 24             	mov    %eax,(%esp)
  8019b4:	e8 77 f6 ff ff       	call   801030 <fd2data>
  8019b9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bb:	c7 44 24 04 c9 27 80 	movl   $0x8027c9,0x4(%esp)
  8019c2:	00 
  8019c3:	89 1c 24             	mov    %ebx,(%esp)
  8019c6:	e8 cc ef ff ff       	call   800997 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019cb:	8b 46 04             	mov    0x4(%esi),%eax
  8019ce:	2b 06                	sub    (%esi),%eax
  8019d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019dd:	00 00 00 
	stat->st_dev = &devpipe;
  8019e0:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8019e7:	30 80 00 
	return 0;
}
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	5b                   	pop    %ebx
  8019f3:	5e                   	pop    %esi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 14             	sub    $0x14,%esp
  8019fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0b:	e8 4a f4 ff ff       	call   800e5a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a10:	89 1c 24             	mov    %ebx,(%esp)
  801a13:	e8 18 f6 ff ff       	call   801030 <fd2data>
  801a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a23:	e8 32 f4 ff ff       	call   800e5a <sys_page_unmap>
}
  801a28:	83 c4 14             	add    $0x14,%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	57                   	push   %edi
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 2c             	sub    $0x2c,%esp
  801a37:	89 c6                	mov    %eax,%esi
  801a39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a3c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a41:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a44:	89 34 24             	mov    %esi,(%esp)
  801a47:	e8 19 06 00 00       	call   802065 <pageref>
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a51:	89 04 24             	mov    %eax,(%esp)
  801a54:	e8 0c 06 00 00       	call   802065 <pageref>
  801a59:	39 c7                	cmp    %eax,%edi
  801a5b:	0f 94 c2             	sete   %dl
  801a5e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a61:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a67:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a6a:	39 fb                	cmp    %edi,%ebx
  801a6c:	74 21                	je     801a8f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a6e:	84 d2                	test   %dl,%dl
  801a70:	74 ca                	je     801a3c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a72:	8b 51 58             	mov    0x58(%ecx),%edx
  801a75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a79:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a81:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  801a88:	e8 8e e8 ff ff       	call   80031b <cprintf>
  801a8d:	eb ad                	jmp    801a3c <_pipeisclosed+0xe>
	}
}
  801a8f:	83 c4 2c             	add    $0x2c,%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 1c             	sub    $0x1c,%esp
  801aa0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa3:	89 34 24             	mov    %esi,(%esp)
  801aa6:	e8 85 f5 ff ff       	call   801030 <fd2data>
  801aab:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aad:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab2:	eb 45                	jmp    801af9 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab4:	89 da                	mov    %ebx,%edx
  801ab6:	89 f0                	mov    %esi,%eax
  801ab8:	e8 71 ff ff ff       	call   801a2e <_pipeisclosed>
  801abd:	85 c0                	test   %eax,%eax
  801abf:	75 41                	jne    801b02 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac1:	e8 ce f2 ff ff       	call   800d94 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac9:	8b 0b                	mov    (%ebx),%ecx
  801acb:	8d 51 20             	lea    0x20(%ecx),%edx
  801ace:	39 d0                	cmp    %edx,%eax
  801ad0:	73 e2                	jae    801ab4 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ad9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801adc:	99                   	cltd   
  801add:	c1 ea 1b             	shr    $0x1b,%edx
  801ae0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801ae3:	83 e1 1f             	and    $0x1f,%ecx
  801ae6:	29 d1                	sub    %edx,%ecx
  801ae8:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801aec:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801af0:	83 c0 01             	add    $0x1,%eax
  801af3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af6:	83 c7 01             	add    $0x1,%edi
  801af9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801afc:	75 c8                	jne    801ac6 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801afe:	89 f8                	mov    %edi,%eax
  801b00:	eb 05                	jmp    801b07 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b02:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b07:	83 c4 1c             	add    $0x1c,%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 1c             	sub    $0x1c,%esp
  801b18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1b:	89 3c 24             	mov    %edi,(%esp)
  801b1e:	e8 0d f5 ff ff       	call   801030 <fd2data>
  801b23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b25:	be 00 00 00 00       	mov    $0x0,%esi
  801b2a:	eb 3d                	jmp    801b69 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b2c:	85 f6                	test   %esi,%esi
  801b2e:	74 04                	je     801b34 <devpipe_read+0x25>
				return i;
  801b30:	89 f0                	mov    %esi,%eax
  801b32:	eb 43                	jmp    801b77 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b34:	89 da                	mov    %ebx,%edx
  801b36:	89 f8                	mov    %edi,%eax
  801b38:	e8 f1 fe ff ff       	call   801a2e <_pipeisclosed>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	75 31                	jne    801b72 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b41:	e8 4e f2 ff ff       	call   800d94 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b46:	8b 03                	mov    (%ebx),%eax
  801b48:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b4b:	74 df                	je     801b2c <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4d:	99                   	cltd   
  801b4e:	c1 ea 1b             	shr    $0x1b,%edx
  801b51:	01 d0                	add    %edx,%eax
  801b53:	83 e0 1f             	and    $0x1f,%eax
  801b56:	29 d0                	sub    %edx,%eax
  801b58:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b60:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b63:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b66:	83 c6 01             	add    $0x1,%esi
  801b69:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b6c:	75 d8                	jne    801b46 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6e:	89 f0                	mov    %esi,%eax
  801b70:	eb 05                	jmp    801b77 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b77:	83 c4 1c             	add    $0x1c,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5f                   	pop    %edi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8a:	89 04 24             	mov    %eax,(%esp)
  801b8d:	e8 b5 f4 ff ff       	call   801047 <fd_alloc>
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	85 d2                	test   %edx,%edx
  801b96:	0f 88 4d 01 00 00    	js     801ce9 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ba3:	00 
  801ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb2:	e8 fc f1 ff ff       	call   800db3 <sys_page_alloc>
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	85 d2                	test   %edx,%edx
  801bbb:	0f 88 28 01 00 00    	js     801ce9 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc4:	89 04 24             	mov    %eax,(%esp)
  801bc7:	e8 7b f4 ff ff       	call   801047 <fd_alloc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	0f 88 fe 00 00 00    	js     801cd4 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bdd:	00 
  801bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bec:	e8 c2 f1 ff ff       	call   800db3 <sys_page_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	0f 88 d9 00 00 00    	js     801cd4 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	89 04 24             	mov    %eax,(%esp)
  801c01:	e8 2a f4 ff ff       	call   801030 <fd2data>
  801c06:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c08:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c0f:	00 
  801c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1b:	e8 93 f1 ff ff       	call   800db3 <sys_page_alloc>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 97 00 00 00    	js     801cc1 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 fb f3 ff ff       	call   801030 <fd2data>
  801c35:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801c3c:	00 
  801c3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c48:	00 
  801c49:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c54:	e8 ae f1 ff ff       	call   800e07 <sys_page_map>
  801c59:	89 c3                	mov    %eax,%ebx
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 52                	js     801cb1 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c68:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c74:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8c:	89 04 24             	mov    %eax,(%esp)
  801c8f:	e8 8c f3 ff ff       	call   801020 <fd2num>
  801c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c97:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9c:	89 04 24             	mov    %eax,(%esp)
  801c9f:	e8 7c f3 ff ff       	call   801020 <fd2num>
  801ca4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
  801caf:	eb 38                	jmp    801ce9 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801cb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cbc:	e8 99 f1 ff ff       	call   800e5a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccf:	e8 86 f1 ff ff       	call   800e5a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce2:	e8 73 f1 ff ff       	call   800e5a <sys_page_unmap>
  801ce7:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801ce9:	83 c4 30             	add    $0x30,%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	89 04 24             	mov    %eax,(%esp)
  801d03:	e8 8e f3 ff ff       	call   801096 <fd_lookup>
  801d08:	89 c2                	mov    %eax,%edx
  801d0a:	85 d2                	test   %edx,%edx
  801d0c:	78 15                	js     801d23 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 17 f3 ff ff       	call   801030 <fd2data>
	return _pipeisclosed(fd, p);
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	e8 0b fd ff ff       	call   801a2e <_pipeisclosed>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
  801d25:	66 90                	xchg   %ax,%ax
  801d27:	66 90                	xchg   %ax,%ax
  801d29:	66 90                	xchg   %ax,%ax
  801d2b:	66 90                	xchg   %ax,%ax
  801d2d:	66 90                	xchg   %ax,%ax
  801d2f:	90                   	nop

00801d30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801d40:	c7 44 24 04 e8 27 80 	movl   $0x8027e8,0x4(%esp)
  801d47:	00 
  801d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 44 ec ff ff       	call   800997 <strcpy>
	return 0;
}
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	57                   	push   %edi
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d66:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d71:	eb 31                	jmp    801da4 <devcons_write+0x4a>
		m = n - tot;
  801d73:	8b 75 10             	mov    0x10(%ebp),%esi
  801d76:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d78:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d7b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d80:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d83:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d87:	03 45 0c             	add    0xc(%ebp),%eax
  801d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8e:	89 3c 24             	mov    %edi,(%esp)
  801d91:	e8 9e ed ff ff       	call   800b34 <memmove>
		sys_cputs(buf, m);
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	89 3c 24             	mov    %edi,(%esp)
  801d9d:	e8 44 ef ff ff       	call   800ce6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da2:	01 f3                	add    %esi,%ebx
  801da4:	89 d8                	mov    %ebx,%eax
  801da6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801da9:	72 c8                	jb     801d73 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dab:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801dc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc5:	75 07                	jne    801dce <devcons_read+0x18>
  801dc7:	eb 2a                	jmp    801df3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc9:	e8 c6 ef ff ff       	call   800d94 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dce:	66 90                	xchg   %ax,%ax
  801dd0:	e8 2f ef ff ff       	call   800d04 <sys_cgetc>
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	74 f0                	je     801dc9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 16                	js     801df3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ddd:	83 f8 04             	cmp    $0x4,%eax
  801de0:	74 0c                	je     801dee <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801de2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de5:	88 02                	mov    %al,(%edx)
	return 1;
  801de7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dec:	eb 05                	jmp    801df3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e08:	00 
  801e09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0c:	89 04 24             	mov    %eax,(%esp)
  801e0f:	e8 d2 ee ff ff       	call   800ce6 <sys_cputs>
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <getchar>:

int
getchar(void)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e23:	00 
  801e24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e32:	e8 ee f4 ff ff       	call   801325 <read>
	if (r < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 0f                	js     801e4a <getchar+0x34>
		return r;
	if (r < 1)
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	7e 06                	jle    801e45 <getchar+0x2f>
		return -E_EOF;
	return c;
  801e3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e43:	eb 05                	jmp    801e4a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	89 04 24             	mov    %eax,(%esp)
  801e5f:	e8 32 f2 ff ff       	call   801096 <fd_lookup>
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 11                	js     801e79 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801e71:	39 10                	cmp    %edx,(%eax)
  801e73:	0f 94 c0             	sete   %al
  801e76:	0f b6 c0             	movzbl %al,%eax
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <opencons>:

int
opencons(void)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 bb f1 ff ff       	call   801047 <fd_alloc>
		return r;
  801e8c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 40                	js     801ed2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e99:	00 
  801e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea8:	e8 06 ef ff ff       	call   800db3 <sys_page_alloc>
		return r;
  801ead:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 1f                	js     801ed2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 50 f1 ff ff       	call   801020 <fd2num>
  801ed0:	89 c2                	mov    %eax,%edx
}
  801ed2:	89 d0                	mov    %edx,%eax
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    
  801ed6:	66 90                	xchg   %ax,%ax
  801ed8:	66 90                	xchg   %ax,%ax
  801eda:	66 90                	xchg   %ax,%ax
  801edc:	66 90                	xchg   %ax,%ax
  801ede:	66 90                	xchg   %ax,%ax

00801ee0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 10             	sub    $0x10,%esp
  801ee8:	8b 75 08             	mov    0x8(%ebp),%esi
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	75 0e                	jne    801f03 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801ef5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801efc:	e8 c8 f0 ff ff       	call   800fc9 <sys_ipc_recv>
  801f01:	eb 08                	jmp    801f0b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801f03:	89 04 24             	mov    %eax,(%esp)
  801f06:	e8 be f0 ff ff       	call   800fc9 <sys_ipc_recv>
	if(r == 0){
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	8d 76 00             	lea    0x0(%esi),%esi
  801f10:	75 1e                	jne    801f30 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801f12:	85 f6                	test   %esi,%esi
  801f14:	74 0a                	je     801f20 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801f16:	a1 08 40 80 00       	mov    0x804008,%eax
  801f1b:	8b 40 74             	mov    0x74(%eax),%eax
  801f1e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801f20:	85 db                	test   %ebx,%ebx
  801f22:	74 2c                	je     801f50 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801f24:	a1 08 40 80 00       	mov    0x804008,%eax
  801f29:	8b 40 78             	mov    0x78(%eax),%eax
  801f2c:	89 03                	mov    %eax,(%ebx)
  801f2e:	eb 20                	jmp    801f50 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801f30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f34:	c7 44 24 08 f4 27 80 	movl   $0x8027f4,0x8(%esp)
  801f3b:	00 
  801f3c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801f43:	00 
  801f44:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  801f4b:	e8 d2 e2 ff ff       	call   800222 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801f50:	a1 08 40 80 00       	mov    0x804008,%eax
  801f55:	8b 50 70             	mov    0x70(%eax),%edx
  801f58:	85 d2                	test   %edx,%edx
  801f5a:	75 13                	jne    801f6f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  801f5c:	8b 40 48             	mov    0x48(%eax),%eax
  801f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f63:	c7 04 24 24 28 80 00 	movl   $0x802824,(%esp)
  801f6a:	e8 ac e3 ff ff       	call   80031b <cprintf>
	return thisenv->env_ipc_value;
  801f6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f74:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  801f8d:	85 f6                	test   %esi,%esi
  801f8f:	75 22                	jne    801fb3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801f91:	8b 45 14             	mov    0x14(%ebp),%eax
  801f94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f98:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801f9f:	ee 
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	89 3c 24             	mov    %edi,(%esp)
  801faa:	e8 f7 ef ff ff       	call   800fa6 <sys_ipc_try_send>
  801faf:	89 c3                	mov    %eax,%ebx
  801fb1:	eb 1c                	jmp    801fcf <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801fb3:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fba:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc5:	89 3c 24             	mov    %edi,(%esp)
  801fc8:	e8 d9 ef ff ff       	call   800fa6 <sys_ipc_try_send>
  801fcd:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  801fcf:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801fd2:	74 3e                	je     802012 <ipc_send+0x94>
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	c1 e8 1f             	shr    $0x1f,%eax
  801fd9:	84 c0                	test   %al,%al
  801fdb:	74 35                	je     802012 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  801fdd:	e8 93 ed ff ff       	call   800d75 <sys_getenvid>
  801fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe6:	c7 04 24 7a 28 80 00 	movl   $0x80287a,(%esp)
  801fed:	e8 29 e3 ff ff       	call   80031b <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801ff2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ff6:	c7 44 24 08 48 28 80 	movl   $0x802848,0x8(%esp)
  801ffd:	00 
  801ffe:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802005:	00 
  802006:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  80200d:	e8 10 e2 ff ff       	call   800222 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802012:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802015:	75 0e                	jne    802025 <ipc_send+0xa7>
			sys_yield();
  802017:	e8 78 ed ff ff       	call   800d94 <sys_yield>
		else break;
	}
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	e9 68 ff ff ff       	jmp    801f8d <ipc_send+0xf>
	
}
  802025:	83 c4 1c             	add    $0x1c,%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802038:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80203b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802041:	8b 52 50             	mov    0x50(%edx),%edx
  802044:	39 ca                	cmp    %ecx,%edx
  802046:	75 0d                	jne    802055 <ipc_find_env+0x28>
			return envs[i].env_id;
  802048:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80204b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802050:	8b 40 40             	mov    0x40(%eax),%eax
  802053:	eb 0e                	jmp    802063 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802055:	83 c0 01             	add    $0x1,%eax
  802058:	3d 00 04 00 00       	cmp    $0x400,%eax
  80205d:	75 d9                	jne    802038 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80205f:	66 b8 00 00          	mov    $0x0,%ax
}
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    

00802065 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	c1 e8 16             	shr    $0x16,%eax
  802070:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80207c:	f6 c1 01             	test   $0x1,%cl
  80207f:	74 1d                	je     80209e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802081:	c1 ea 0c             	shr    $0xc,%edx
  802084:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80208b:	f6 c2 01             	test   $0x1,%dl
  80208e:	74 0e                	je     80209e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802090:	c1 ea 0c             	shr    $0xc,%edx
  802093:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80209a:	ef 
  80209b:	0f b7 c0             	movzwl %ax,%eax
}
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8020aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8020ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8020b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020bc:	89 ea                	mov    %ebp,%edx
  8020be:	89 0c 24             	mov    %ecx,(%esp)
  8020c1:	75 2d                	jne    8020f0 <__udivdi3+0x50>
  8020c3:	39 e9                	cmp    %ebp,%ecx
  8020c5:	77 61                	ja     802128 <__udivdi3+0x88>
  8020c7:	85 c9                	test   %ecx,%ecx
  8020c9:	89 ce                	mov    %ecx,%esi
  8020cb:	75 0b                	jne    8020d8 <__udivdi3+0x38>
  8020cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d2:	31 d2                	xor    %edx,%edx
  8020d4:	f7 f1                	div    %ecx
  8020d6:	89 c6                	mov    %eax,%esi
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	89 e8                	mov    %ebp,%eax
  8020dc:	f7 f6                	div    %esi
  8020de:	89 c5                	mov    %eax,%ebp
  8020e0:	89 f8                	mov    %edi,%eax
  8020e2:	f7 f6                	div    %esi
  8020e4:	89 ea                	mov    %ebp,%edx
  8020e6:	83 c4 0c             	add    $0xc,%esp
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
  8020f0:	39 e8                	cmp    %ebp,%eax
  8020f2:	77 24                	ja     802118 <__udivdi3+0x78>
  8020f4:	0f bd e8             	bsr    %eax,%ebp
  8020f7:	83 f5 1f             	xor    $0x1f,%ebp
  8020fa:	75 3c                	jne    802138 <__udivdi3+0x98>
  8020fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  802100:	39 34 24             	cmp    %esi,(%esp)
  802103:	0f 86 9f 00 00 00    	jbe    8021a8 <__udivdi3+0x108>
  802109:	39 d0                	cmp    %edx,%eax
  80210b:	0f 82 97 00 00 00    	jb     8021a8 <__udivdi3+0x108>
  802111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802118:	31 d2                	xor    %edx,%edx
  80211a:	31 c0                	xor    %eax,%eax
  80211c:	83 c4 0c             	add    $0xc,%esp
  80211f:	5e                   	pop    %esi
  802120:	5f                   	pop    %edi
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    
  802123:	90                   	nop
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	89 f8                	mov    %edi,%eax
  80212a:	f7 f1                	div    %ecx
  80212c:	31 d2                	xor    %edx,%edx
  80212e:	83 c4 0c             	add    $0xc,%esp
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	89 e9                	mov    %ebp,%ecx
  80213a:	8b 3c 24             	mov    (%esp),%edi
  80213d:	d3 e0                	shl    %cl,%eax
  80213f:	89 c6                	mov    %eax,%esi
  802141:	b8 20 00 00 00       	mov    $0x20,%eax
  802146:	29 e8                	sub    %ebp,%eax
  802148:	89 c1                	mov    %eax,%ecx
  80214a:	d3 ef                	shr    %cl,%edi
  80214c:	89 e9                	mov    %ebp,%ecx
  80214e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802152:	8b 3c 24             	mov    (%esp),%edi
  802155:	09 74 24 08          	or     %esi,0x8(%esp)
  802159:	89 d6                	mov    %edx,%esi
  80215b:	d3 e7                	shl    %cl,%edi
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	89 3c 24             	mov    %edi,(%esp)
  802162:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802166:	d3 ee                	shr    %cl,%esi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	d3 e2                	shl    %cl,%edx
  80216c:	89 c1                	mov    %eax,%ecx
  80216e:	d3 ef                	shr    %cl,%edi
  802170:	09 d7                	or     %edx,%edi
  802172:	89 f2                	mov    %esi,%edx
  802174:	89 f8                	mov    %edi,%eax
  802176:	f7 74 24 08          	divl   0x8(%esp)
  80217a:	89 d6                	mov    %edx,%esi
  80217c:	89 c7                	mov    %eax,%edi
  80217e:	f7 24 24             	mull   (%esp)
  802181:	39 d6                	cmp    %edx,%esi
  802183:	89 14 24             	mov    %edx,(%esp)
  802186:	72 30                	jb     8021b8 <__udivdi3+0x118>
  802188:	8b 54 24 04          	mov    0x4(%esp),%edx
  80218c:	89 e9                	mov    %ebp,%ecx
  80218e:	d3 e2                	shl    %cl,%edx
  802190:	39 c2                	cmp    %eax,%edx
  802192:	73 05                	jae    802199 <__udivdi3+0xf9>
  802194:	3b 34 24             	cmp    (%esp),%esi
  802197:	74 1f                	je     8021b8 <__udivdi3+0x118>
  802199:	89 f8                	mov    %edi,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	e9 7a ff ff ff       	jmp    80211c <__udivdi3+0x7c>
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8021af:	e9 68 ff ff ff       	jmp    80211c <__udivdi3+0x7c>
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	83 c4 0c             	add    $0xc,%esp
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	83 ec 14             	sub    $0x14,%esp
  8021d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8021da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8021de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8021e2:	89 c7                	mov    %eax,%edi
  8021e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8021ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8021f0:	89 34 24             	mov    %esi,(%esp)
  8021f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	89 c2                	mov    %eax,%edx
  8021fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021ff:	75 17                	jne    802218 <__umoddi3+0x48>
  802201:	39 fe                	cmp    %edi,%esi
  802203:	76 4b                	jbe    802250 <__umoddi3+0x80>
  802205:	89 c8                	mov    %ecx,%eax
  802207:	89 fa                	mov    %edi,%edx
  802209:	f7 f6                	div    %esi
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	31 d2                	xor    %edx,%edx
  80220f:	83 c4 14             	add    $0x14,%esp
  802212:	5e                   	pop    %esi
  802213:	5f                   	pop    %edi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    
  802216:	66 90                	xchg   %ax,%ax
  802218:	39 f8                	cmp    %edi,%eax
  80221a:	77 54                	ja     802270 <__umoddi3+0xa0>
  80221c:	0f bd e8             	bsr    %eax,%ebp
  80221f:	83 f5 1f             	xor    $0x1f,%ebp
  802222:	75 5c                	jne    802280 <__umoddi3+0xb0>
  802224:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802228:	39 3c 24             	cmp    %edi,(%esp)
  80222b:	0f 87 e7 00 00 00    	ja     802318 <__umoddi3+0x148>
  802231:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802235:	29 f1                	sub    %esi,%ecx
  802237:	19 c7                	sbb    %eax,%edi
  802239:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802241:	8b 44 24 08          	mov    0x8(%esp),%eax
  802245:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802249:	83 c4 14             	add    $0x14,%esp
  80224c:	5e                   	pop    %esi
  80224d:	5f                   	pop    %edi
  80224e:	5d                   	pop    %ebp
  80224f:	c3                   	ret    
  802250:	85 f6                	test   %esi,%esi
  802252:	89 f5                	mov    %esi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f6                	div    %esi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	8b 44 24 04          	mov    0x4(%esp),%eax
  802265:	31 d2                	xor    %edx,%edx
  802267:	f7 f5                	div    %ebp
  802269:	89 c8                	mov    %ecx,%eax
  80226b:	f7 f5                	div    %ebp
  80226d:	eb 9c                	jmp    80220b <__umoddi3+0x3b>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 fa                	mov    %edi,%edx
  802274:	83 c4 14             	add    $0x14,%esp
  802277:	5e                   	pop    %esi
  802278:	5f                   	pop    %edi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    
  80227b:	90                   	nop
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 04 24             	mov    (%esp),%eax
  802283:	be 20 00 00 00       	mov    $0x20,%esi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ee                	sub    %ebp,%esi
  80228c:	d3 e2                	shl    %cl,%edx
  80228e:	89 f1                	mov    %esi,%ecx
  802290:	d3 e8                	shr    %cl,%eax
  802292:	89 e9                	mov    %ebp,%ecx
  802294:	89 44 24 04          	mov    %eax,0x4(%esp)
  802298:	8b 04 24             	mov    (%esp),%eax
  80229b:	09 54 24 04          	or     %edx,0x4(%esp)
  80229f:	89 fa                	mov    %edi,%edx
  8022a1:	d3 e0                	shl    %cl,%eax
  8022a3:	89 f1                	mov    %esi,%ecx
  8022a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022ad:	d3 ea                	shr    %cl,%edx
  8022af:	89 e9                	mov    %ebp,%ecx
  8022b1:	d3 e7                	shl    %cl,%edi
  8022b3:	89 f1                	mov    %esi,%ecx
  8022b5:	d3 e8                	shr    %cl,%eax
  8022b7:	89 e9                	mov    %ebp,%ecx
  8022b9:	09 f8                	or     %edi,%eax
  8022bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8022bf:	f7 74 24 04          	divl   0x4(%esp)
  8022c3:	d3 e7                	shl    %cl,%edi
  8022c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022c9:	89 d7                	mov    %edx,%edi
  8022cb:	f7 64 24 08          	mull   0x8(%esp)
  8022cf:	39 d7                	cmp    %edx,%edi
  8022d1:	89 c1                	mov    %eax,%ecx
  8022d3:	89 14 24             	mov    %edx,(%esp)
  8022d6:	72 2c                	jb     802304 <__umoddi3+0x134>
  8022d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8022dc:	72 22                	jb     802300 <__umoddi3+0x130>
  8022de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022e2:	29 c8                	sub    %ecx,%eax
  8022e4:	19 d7                	sbb    %edx,%edi
  8022e6:	89 e9                	mov    %ebp,%ecx
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	d3 e8                	shr    %cl,%eax
  8022ec:	89 f1                	mov    %esi,%ecx
  8022ee:	d3 e2                	shl    %cl,%edx
  8022f0:	89 e9                	mov    %ebp,%ecx
  8022f2:	d3 ef                	shr    %cl,%edi
  8022f4:	09 d0                	or     %edx,%eax
  8022f6:	89 fa                	mov    %edi,%edx
  8022f8:	83 c4 14             	add    $0x14,%esp
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop
  802300:	39 d7                	cmp    %edx,%edi
  802302:	75 da                	jne    8022de <__umoddi3+0x10e>
  802304:	8b 14 24             	mov    (%esp),%edx
  802307:	89 c1                	mov    %eax,%ecx
  802309:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80230d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802311:	eb cb                	jmp    8022de <__umoddi3+0x10e>
  802313:	90                   	nop
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80231c:	0f 82 0f ff ff ff    	jb     802231 <__umoddi3+0x61>
  802322:	e9 1a ff ff ff       	jmp    802241 <__umoddi3+0x71>
