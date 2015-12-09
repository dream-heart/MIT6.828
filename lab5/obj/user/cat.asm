
obj/user/cat.debug：     文件格式 elf32-i386


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
  80002c:	e8 34 01 00 00       	call   800165 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003e:	eb 43                	jmp    800083 <cat+0x50>
		if ((r = write(1, buf, n)) != n)
  800040:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800044:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80004b:	00 
  80004c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800053:	e8 4a 13 00 00       	call   8013a2 <write>
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 27                	je     800083 <cat+0x50>
			panic("write error copying %s: %e", s, r);
  80005c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800060:	8b 45 0c             	mov    0xc(%ebp),%eax
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 e0 22 80 	movl   $0x8022e0,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  80007e:	e8 3e 01 00 00       	call   8001c1 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800083:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008a:	00 
  80008b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800092:	00 
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 2a 12 00 00       	call   8012c5 <read>
  80009b:	89 c3                	mov    %eax,%ebx
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f 9f                	jg     800040 <cat+0xd>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	79 27                	jns    8000cc <cat+0x99>
		panic("error reading %s: %e", s, n);
  8000a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 06 23 80 	movl   $0x802306,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 fb 22 80 00 	movl   $0x8022fb,(%esp)
  8000c7:	e8 f5 00 00 00       	call   8001c1 <_panic>
}
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 1b 	movl   $0x80231b,0x803000
  8000e6:	23 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	74 07                	je     8000f6 <umain+0x23>
  8000ef:	bb 01 00 00 00       	mov    $0x1,%ebx
  8000f4:	eb 62                	jmp    800158 <umain+0x85>
		cat(0, "<stdin>");
  8000f6:	c7 44 24 04 1f 23 80 	movl   $0x80231f,0x4(%esp)
  8000fd:	00 
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 29 ff ff ff       	call   800033 <cat>
  80010a:	eb 51                	jmp    80015d <umain+0x8a>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80010c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800113:	00 
  800114:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800117:	89 04 24             	mov    %eax,(%esp)
  80011a:	e8 52 16 00 00       	call   801771 <open>
  80011f:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	79 19                	jns    80013e <umain+0x6b>
				printf("can't open %s: %e\n", argv[i], f);
  800125:	89 44 24 08          	mov    %eax,0x8(%esp)
  800129:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800137:	e8 e5 17 00 00       	call   801921 <printf>
  80013c:	eb 17                	jmp    800155 <umain+0x82>
			else {
				cat(f, argv[i]);
  80013e:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e6 fe ff ff       	call   800033 <cat>
				close(f);
  80014d:	89 34 24             	mov    %esi,(%esp)
  800150:	e8 0d 10 00 00       	call   801162 <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800155:	83 c3 01             	add    $0x1,%ebx
  800158:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80015b:	7c af                	jl     80010c <umain+0x39>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015d:	83 c4 1c             	add    $0x1c,%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800170:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800173:	e8 9d 0b 00 00       	call   800d15 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800178:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 db                	test   %ebx,%ebx
  80018c:	7e 07                	jle    800195 <libmain+0x30>
		binaryname = argv[0];
  80018e:	8b 06                	mov    (%esi),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	89 74 24 04          	mov    %esi,0x4(%esp)
  800199:	89 1c 24             	mov    %ebx,(%esp)
  80019c:	e8 32 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 07 00 00 00       	call   8001ad <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ba:	e8 04 0b 00 00       	call   800cc3 <sys_env_destroy>
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001d2:	e8 3e 0b 00 00       	call   800d15 <sys_getenvid>
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 44 23 80 00 	movl   $0x802344,(%esp)
  8001f4:	e8 c1 00 00 00       	call   8002ba <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	e8 51 00 00 00       	call   800259 <vcprintf>
	cprintf("\n");
  800208:	c7 04 24 81 27 80 00 	movl   $0x802781,(%esp)
  80020f:	e8 a6 00 00 00       	call   8002ba <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800214:	cc                   	int3   
  800215:	eb fd                	jmp    800214 <_panic+0x53>

00800217 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	53                   	push   %ebx
  80021b:	83 ec 14             	sub    $0x14,%esp
  80021e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800221:	8b 13                	mov    (%ebx),%edx
  800223:	8d 42 01             	lea    0x1(%edx),%eax
  800226:	89 03                	mov    %eax,(%ebx)
  800228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80022f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800234:	75 19                	jne    80024f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800236:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023d:	00 
  80023e:	8d 43 08             	lea    0x8(%ebx),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 3d 0a 00 00       	call   800c86 <sys_cputs>
		b->idx = 0;
  800249:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80024f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	5b                   	pop    %ebx
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800262:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800269:	00 00 00 
	b.cnt = 0;
  80026c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800273:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
  800279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 44 24 08          	mov    %eax,0x8(%esp)
  800284:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	c7 04 24 17 02 80 00 	movl   $0x800217,(%esp)
  800295:	e8 7a 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002aa:	89 04 24             	mov    %eax,(%esp)
  8002ad:	e8 d4 09 00 00       	call   800c86 <sys_cputs>

	return b.cnt;
}
  8002b2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	e8 87 ff ff ff       	call   800259 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    
  8002d4:	66 90                	xchg   %ax,%ax
  8002d6:	66 90                	xchg   %ax,%ax
  8002d8:	66 90                	xchg   %ax,%ax
  8002da:	66 90                	xchg   %ax,%ax
  8002dc:	66 90                	xchg   %ax,%ax
  8002de:	66 90                	xchg   %ax,%ax

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 c3                	mov    %eax,%ebx
  8002f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800302:	b9 00 00 00 00       	mov    $0x0,%ecx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80030d:	39 d9                	cmp    %ebx,%ecx
  80030f:	72 05                	jb     800316 <printnum+0x36>
  800311:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800314:	77 69                	ja     80037f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800316:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031d:	83 ee 01             	sub    $0x1,%esi
  800320:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80032c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800330:	89 c3                	mov    %eax,%ebx
  800332:	89 d6                	mov    %edx,%esi
  800334:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800337:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80033a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80033e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	e8 ec 1c 00 00       	call   802040 <__udivdi3>
  800354:	89 d9                	mov    %ebx,%ecx
  800356:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	89 54 24 04          	mov    %edx,0x4(%esp)
  800365:	89 fa                	mov    %edi,%edx
  800367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036a:	e8 71 ff ff ff       	call   8002e0 <printnum>
  80036f:	eb 1b                	jmp    80038c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800371:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800375:	8b 45 18             	mov    0x18(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	ff d3                	call   *%ebx
  80037d:	eb 03                	jmp    800382 <printnum+0xa2>
  80037f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800382:	83 ee 01             	sub    $0x1,%esi
  800385:	85 f6                	test   %esi,%esi
  800387:	7f e8                	jg     800371 <printnum+0x91>
  800389:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800397:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003af:	e8 bc 1d 00 00       	call   802170 <__umoddi3>
  8003b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b8:	0f be 80 67 23 80 00 	movsbl 0x802367(%eax),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003c5:	ff d0                	call   *%eax
}
  8003c7:	83 c4 3c             	add    $0x3c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 0a                	jae    8003ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	88 02                	mov    %al,(%edx)
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 02 00 00 00       	call   800414 <vprintfmt>
	va_end(ap);
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 3c             	sub    $0x3c,%esp
  80041d:	8b 75 08             	mov    0x8(%ebp),%esi
  800420:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800423:	8b 7d 10             	mov    0x10(%ebp),%edi
  800426:	eb 11                	jmp    800439 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800428:	85 c0                	test   %eax,%eax
  80042a:	0f 84 48 04 00 00    	je     800878 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800430:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800439:	83 c7 01             	add    $0x1,%edi
  80043c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800440:	83 f8 25             	cmp    $0x25,%eax
  800443:	75 e3                	jne    800428 <vprintfmt+0x14>
  800445:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800449:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800450:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800457:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80045e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800463:	eb 1f                	jmp    800484 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800468:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80046c:	eb 16                	jmp    800484 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800471:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800475:	eb 0d                	jmp    800484 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800477:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8d 47 01             	lea    0x1(%edi),%eax
  800487:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048a:	0f b6 17             	movzbl (%edi),%edx
  80048d:	0f b6 c2             	movzbl %dl,%eax
  800490:	83 ea 23             	sub    $0x23,%edx
  800493:	80 fa 55             	cmp    $0x55,%dl
  800496:	0f 87 bf 03 00 00    	ja     80085b <vprintfmt+0x447>
  80049c:	0f b6 d2             	movzbl %dl,%edx
  80049f:	ff 24 95 a0 24 80 00 	jmp    *0x8024a0(,%edx,4)
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004b4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004b8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004be:	83 f9 09             	cmp    $0x9,%ecx
  8004c1:	77 3c                	ja     8004ff <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb e9                	jmp    8004b1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 40 04             	lea    0x4(%eax),%eax
  8004d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004dc:	eb 27                	jmp    800505 <vprintfmt+0xf1>
  8004de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	0f 49 c2             	cmovns %edx,%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f1:	eb 91                	jmp    800484 <vprintfmt+0x70>
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fd:	eb 85                	jmp    800484 <vprintfmt+0x70>
  8004ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800502:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800505:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800509:	0f 89 75 ff ff ff    	jns    800484 <vprintfmt+0x70>
  80050f:	e9 63 ff ff ff       	jmp    800477 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800514:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80051a:	e9 65 ff ff ff       	jmp    800484 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800522:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800526:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800534:	e9 00 ff ff ff       	jmp    800439 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800540:	8b 00                	mov    (%eax),%eax
  800542:	99                   	cltd   
  800543:	31 d0                	xor    %edx,%eax
  800545:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800547:	83 f8 0f             	cmp    $0xf,%eax
  80054a:	7f 0b                	jg     800557 <vprintfmt+0x143>
  80054c:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  800553:	85 d2                	test   %edx,%edx
  800555:	75 20                	jne    800577 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800557:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055b:	c7 44 24 08 7f 23 80 	movl   $0x80237f,0x8(%esp)
  800562:	00 
  800563:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 7d fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800572:	e9 c2 fe ff ff       	jmp    800439 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800577:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057b:	c7 44 24 08 5a 27 80 	movl   $0x80275a,0x8(%esp)
  800582:	00 
  800583:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 5d fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800592:	e9 a2 fe ff ff       	jmp    800439 <vprintfmt+0x25>
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a9:	85 ff                	test   %edi,%edi
  8005ab:	b8 78 23 80 00       	mov    $0x802378,%eax
  8005b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b7:	0f 84 92 00 00 00    	je     80064f <vprintfmt+0x23b>
  8005bd:	85 c9                	test   %ecx,%ecx
  8005bf:	0f 8e 98 00 00 00    	jle    80065d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c9:	89 3c 24             	mov    %edi,(%esp)
  8005cc:	e8 47 03 00 00       	call   800918 <strnlen>
  8005d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d4:	29 c1                	sub    %eax,%ecx
  8005d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e5:	eb 0f                	jmp    8005f6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 ef 01             	sub    $0x1,%edi
  8005f6:	85 ff                	test   %edi,%edi
  8005f8:	7f ed                	jg     8005e7 <vprintfmt+0x1d3>
  8005fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800600:	85 c9                	test   %ecx,%ecx
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	0f 49 c1             	cmovns %ecx,%eax
  80060a:	29 c1                	sub    %eax,%ecx
  80060c:	89 75 08             	mov    %esi,0x8(%ebp)
  80060f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800612:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800615:	89 cb                	mov    %ecx,%ebx
  800617:	eb 50                	jmp    800669 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061d:	74 1e                	je     80063d <vprintfmt+0x229>
  80061f:	0f be d2             	movsbl %dl,%edx
  800622:	83 ea 20             	sub    $0x20,%edx
  800625:	83 fa 5e             	cmp    $0x5e,%edx
  800628:	76 13                	jbe    80063d <vprintfmt+0x229>
					putch('?', putdat);
  80062a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800631:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800638:	ff 55 08             	call   *0x8(%ebp)
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80063d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800640:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 eb 01             	sub    $0x1,%ebx
  80064d:	eb 1a                	jmp    800669 <vprintfmt+0x255>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800655:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065b:	eb 0c                	jmp    800669 <vprintfmt+0x255>
  80065d:	89 75 08             	mov    %esi,0x8(%ebp)
  800660:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800663:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800666:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800669:	83 c7 01             	add    $0x1,%edi
  80066c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800670:	0f be c2             	movsbl %dl,%eax
  800673:	85 c0                	test   %eax,%eax
  800675:	74 25                	je     80069c <vprintfmt+0x288>
  800677:	85 f6                	test   %esi,%esi
  800679:	78 9e                	js     800619 <vprintfmt+0x205>
  80067b:	83 ee 01             	sub    $0x1,%esi
  80067e:	79 99                	jns    800619 <vprintfmt+0x205>
  800680:	89 df                	mov    %ebx,%edi
  800682:	8b 75 08             	mov    0x8(%ebp),%esi
  800685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800688:	eb 1a                	jmp    8006a4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800695:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800697:	83 ef 01             	sub    $0x1,%edi
  80069a:	eb 08                	jmp    8006a4 <vprintfmt+0x290>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	85 ff                	test   %edi,%edi
  8006a6:	7f e2                	jg     80068a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 89 fd ff ff       	jmp    800439 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 19                	jle    8006ce <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb 38                	jmp    800706 <vprintfmt+0x2f2>
	else if (lflag)
  8006ce:	85 c9                	test   %ecx,%ecx
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006eb:	eb 19                	jmp    800706 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 c1                	mov    %eax,%ecx
  8006f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800711:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800715:	0f 89 04 01 00 00    	jns    80081f <vprintfmt+0x40b>
				putch('-', putdat);
  80071b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800726:	ff d6                	call   *%esi
				num = -(long long) num;
  800728:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80072b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80072e:	f7 da                	neg    %edx
  800730:	83 d1 00             	adc    $0x0,%ecx
  800733:	f7 d9                	neg    %ecx
  800735:	e9 e5 00 00 00       	jmp    80081f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073a:	83 f9 01             	cmp    $0x1,%ecx
  80073d:	7e 10                	jle    80074f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	8b 48 04             	mov    0x4(%eax),%ecx
  800747:	8d 40 08             	lea    0x8(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
  80074d:	eb 26                	jmp    800775 <vprintfmt+0x361>
	else if (lflag)
  80074f:	85 c9                	test   %ecx,%ecx
  800751:	74 12                	je     800765 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075d:	8d 40 04             	lea    0x4(%eax),%eax
  800760:	89 45 14             	mov    %eax,0x14(%ebp)
  800763:	eb 10                	jmp    800775 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800775:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80077a:	e9 a0 00 00 00       	jmp    80081f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80077f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800783:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80078a:	ff d6                	call   *%esi
			putch('X', putdat);
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800797:	ff d6                	call   *%esi
			putch('X', putdat);
  800799:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007a4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a9:	e9 8b fc ff ff       	jmp    800439 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007dd:	eb 40                	jmp    80081f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 10                	jle    8007f4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ec:	8d 40 08             	lea    0x8(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f2:	eb 26                	jmp    80081a <vprintfmt+0x406>
	else if (lflag)
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 12                	je     80080a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	8d 40 04             	lea    0x4(%eax),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
  800808:	eb 10                	jmp    80081a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800814:	8d 40 04             	lea    0x4(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80081a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800823:	89 44 24 10          	mov    %eax,0x10(%esp)
  800827:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800832:	89 14 24             	mov    %edx,(%esp)
  800835:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800839:	89 da                	mov    %ebx,%edx
  80083b:	89 f0                	mov    %esi,%eax
  80083d:	e8 9e fa ff ff       	call   8002e0 <printnum>
			break;
  800842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800845:	e9 ef fb ff ff       	jmp    800439 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800853:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800856:	e9 de fb ff ff       	jmp    800439 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800866:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	eb 03                	jmp    80086d <vprintfmt+0x459>
  80086a:	83 ef 01             	sub    $0x1,%edi
  80086d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800871:	75 f7                	jne    80086a <vprintfmt+0x456>
  800873:	e9 c1 fb ff ff       	jmp    800439 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800878:	83 c4 3c             	add    $0x3c,%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 28             	sub    $0x28,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800893:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 30                	je     8008d1 <vsnprintf+0x51>
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	7e 2c                	jle    8008d1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8008af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ba:	c7 04 24 cf 03 80 00 	movl   $0x8003cf,(%esp)
  8008c1:	e8 4e fb ff ff       	call   800414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cf:	eb 05                	jmp    8008d6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 82 ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	eb 03                	jmp    800910 <strlen+0x10>
		n++;
  80090d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800910:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800914:	75 f7                	jne    80090d <strlen+0xd>
		n++;
	return n;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb 03                	jmp    80092b <strnlen+0x13>
		n++;
  800928:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	39 d0                	cmp    %edx,%eax
  80092d:	74 06                	je     800935 <strnlen+0x1d>
  80092f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800933:	75 f3                	jne    800928 <strnlen+0x10>
		n++;
	return n;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800941:	89 c2                	mov    %eax,%edx
  800943:	83 c2 01             	add    $0x1,%edx
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80094d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800950:	84 db                	test   %bl,%bl
  800952:	75 ef                	jne    800943 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800961:	89 1c 24             	mov    %ebx,(%esp)
  800964:	e8 97 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800970:	01 d8                	add    %ebx,%eax
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	e8 bd ff ff ff       	call   800937 <strcpy>
	return dst;
}
  80097a:	89 d8                	mov    %ebx,%eax
  80097c:	83 c4 08             	add    $0x8,%esp
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	89 f2                	mov    %esi,%edx
  800994:	eb 0f                	jmp    8009a5 <strncpy+0x23>
		*dst++ = *src;
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	39 da                	cmp    %ebx,%edx
  8009a7:	75 ed                	jne    800996 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bd:	89 f0                	mov    %esi,%eax
  8009bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	75 0b                	jne    8009d2 <strlcpy+0x23>
  8009c7:	eb 1d                	jmp    8009e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d2:	39 d8                	cmp    %ebx,%eax
  8009d4:	74 0b                	je     8009e1 <strlcpy+0x32>
  8009d6:	0f b6 0a             	movzbl (%edx),%ecx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	75 ec                	jne    8009c9 <strlcpy+0x1a>
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	eb 02                	jmp    8009e3 <strlcpy+0x34>
  8009e1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e6:	29 f0                	sub    %esi,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f5:	eb 06                	jmp    8009fd <strcmp+0x11>
		p++, q++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	84 c0                	test   %al,%al
  800a02:	74 04                	je     800a08 <strcmp+0x1c>
  800a04:	3a 02                	cmp    (%edx),%al
  800a06:	74 ef                	je     8009f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 c0             	movzbl %al,%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 c3                	mov    %eax,%ebx
  800a1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a21:	eb 06                	jmp    800a29 <strncmp+0x17>
		n--, p++, q++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a29:	39 d8                	cmp    %ebx,%eax
  800a2b:	74 15                	je     800a42 <strncmp+0x30>
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	84 c9                	test   %cl,%cl
  800a32:	74 04                	je     800a38 <strncmp+0x26>
  800a34:	3a 0a                	cmp    (%edx),%cl
  800a36:	74 eb                	je     800a23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
  800a40:	eb 05                	jmp    800a47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 07                	jmp    800a5d <strchr+0x13>
		if (*s == c)
  800a56:	38 ca                	cmp    %cl,%dl
  800a58:	74 0f                	je     800a69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	eb 07                	jmp    800a7e <strfind+0x13>
		if (*s == c)
  800a77:	38 ca                	cmp    %cl,%dl
  800a79:	74 0a                	je     800a85 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	74 36                	je     800acd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9d:	75 28                	jne    800ac7 <memset+0x40>
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	75 23                	jne    800ac7 <memset+0x40>
		c &= 0xFF;
  800aa4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	c1 e3 08             	shl    $0x8,%ebx
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	c1 e6 18             	shl    $0x18,%esi
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 10             	shl    $0x10,%eax
  800ab7:	09 f0                	or     %esi,%eax
  800ab9:	09 c2                	or     %eax,%edx
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac2:	fc                   	cld    
  800ac3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac5:	eb 06                	jmp    800acd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 35                	jae    800b1b <memmove+0x47>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 d0                	cmp    %edx,%eax
  800aeb:	73 2e                	jae    800b1b <memmove+0x47>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afa:	75 13                	jne    800b0f <memmove+0x3b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 0e                	jne    800b0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b01:	83 ef 04             	sub    $0x4,%edi
  800b04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0d:	eb 09                	jmp    800b18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0f:	83 ef 01             	sub    $0x1,%edi
  800b12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b15:	fd                   	std    
  800b16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b18:	fc                   	cld    
  800b19:	eb 1d                	jmp    800b38 <memmove+0x64>
  800b1b:	89 f2                	mov    %esi,%edx
  800b1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f6 c2 03             	test   $0x3,%dl
  800b22:	75 0f                	jne    800b33 <memmove+0x5f>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0a                	jne    800b33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb 05                	jmp    800b38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	fc                   	cld    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 79 ff ff ff       	call   800ad4 <memmove>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6d:	eb 1a                	jmp    800b89 <memcmp+0x2c>
		if (*s1 != *s2)
  800b6f:	0f b6 02             	movzbl (%edx),%eax
  800b72:	0f b6 19             	movzbl (%ecx),%ebx
  800b75:	38 d8                	cmp    %bl,%al
  800b77:	74 0a                	je     800b83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 0f                	jmp    800b92 <memcmp+0x35>
		s1++, s2++;
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b89:	39 f2                	cmp    %esi,%edx
  800b8b:	75 e2                	jne    800b6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9f:	89 c2                	mov    %eax,%edx
  800ba1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba4:	eb 07                	jmp    800bad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba6:	38 08                	cmp    %cl,(%eax)
  800ba8:	74 07                	je     800bb1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	39 d0                	cmp    %edx,%eax
  800baf:	72 f5                	jb     800ba6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbf:	eb 03                	jmp    800bc4 <strtol+0x11>
		s++;
  800bc1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc4:	0f b6 0a             	movzbl (%edx),%ecx
  800bc7:	80 f9 09             	cmp    $0x9,%cl
  800bca:	74 f5                	je     800bc1 <strtol+0xe>
  800bcc:	80 f9 20             	cmp    $0x20,%cl
  800bcf:	74 f0                	je     800bc1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd1:	80 f9 2b             	cmp    $0x2b,%cl
  800bd4:	75 0a                	jne    800be0 <strtol+0x2d>
		s++;
  800bd6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bde:	eb 11                	jmp    800bf1 <strtol+0x3e>
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be5:	80 f9 2d             	cmp    $0x2d,%cl
  800be8:	75 07                	jne    800bf1 <strtol+0x3e>
		s++, neg = 1;
  800bea:	8d 52 01             	lea    0x1(%edx),%edx
  800bed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800bf6:	75 15                	jne    800c0d <strtol+0x5a>
  800bf8:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfb:	75 10                	jne    800c0d <strtol+0x5a>
  800bfd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c01:	75 0a                	jne    800c0d <strtol+0x5a>
		s += 2, base = 16;
  800c03:	83 c2 02             	add    $0x2,%edx
  800c06:	b8 10 00 00 00       	mov    $0x10,%eax
  800c0b:	eb 10                	jmp    800c1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	75 0c                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c13:	80 3a 30             	cmpb   $0x30,(%edx)
  800c16:	75 05                	jne    800c1d <strtol+0x6a>
		s++, base = 8;
  800c18:	83 c2 01             	add    $0x1,%edx
  800c1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c25:	0f b6 0a             	movzbl (%edx),%ecx
  800c28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c2b:	89 f0                	mov    %esi,%eax
  800c2d:	3c 09                	cmp    $0x9,%al
  800c2f:	77 08                	ja     800c39 <strtol+0x86>
			dig = *s - '0';
  800c31:	0f be c9             	movsbl %cl,%ecx
  800c34:	83 e9 30             	sub    $0x30,%ecx
  800c37:	eb 20                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c3c:	89 f0                	mov    %esi,%eax
  800c3e:	3c 19                	cmp    $0x19,%al
  800c40:	77 08                	ja     800c4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c42:	0f be c9             	movsbl %cl,%ecx
  800c45:	83 e9 57             	sub    $0x57,%ecx
  800c48:	eb 0f                	jmp    800c59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c4d:	89 f0                	mov    %esi,%eax
  800c4f:	3c 19                	cmp    $0x19,%al
  800c51:	77 16                	ja     800c69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c53:	0f be c9             	movsbl %cl,%ecx
  800c56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c5c:	7d 0f                	jge    800c6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c67:	eb bc                	jmp    800c25 <strtol+0x72>
  800c69:	89 d8                	mov    %ebx,%eax
  800c6b:	eb 02                	jmp    800c6f <strtol+0xbc>
  800c6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 05                	je     800c7a <strtol+0xc7>
		*endptr = (char *) s;
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c7a:	f7 d8                	neg    %eax
  800c7c:	85 ff                	test   %edi,%edi
  800c7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	89 c6                	mov    %eax,%esi
  800c9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 cb                	mov    %ecx,%ebx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	89 ce                	mov    %ecx,%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800d08:	e8 b4 f4 ff ff       	call   8001c1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 02 00 00 00       	mov    $0x2,%eax
  800d25:	89 d1                	mov    %edx,%ecx
  800d27:	89 d3                	mov    %edx,%ebx
  800d29:	89 d7                	mov    %edx,%edi
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_yield>:

void
sys_yield(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d44:	89 d1                	mov    %edx,%ecx
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	89 d7                	mov    %edx,%edi
  800d4a:	89 d6                	mov    %edx,%esi
  800d4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	b8 04 00 00 00       	mov    $0x4,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6f:	89 f7                	mov    %esi,%edi
  800d71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800d9a:	e8 22 f4 ff ff       	call   8001c1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9f:	83 c4 2c             	add    $0x2c,%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b8 05 00 00 00       	mov    $0x5,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800ded:	e8 cf f3 ff ff       	call   8001c1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e40:	e8 7c f3 ff ff       	call   8001c1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800e93:	e8 29 f3 ff ff       	call   8001c1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e98:	83 c4 2c             	add    $0x2c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 28                	jle    800eeb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800ee6:	e8 d6 f2 ff ff       	call   8001c1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eeb:	83 c4 2c             	add    $0x2c,%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	89 df                	mov    %ebx,%edi
  800f0e:	89 de                	mov    %ebx,%esi
  800f10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 28                	jle    800f3e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800f39:	e8 83 f2 ff ff       	call   8001c1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f3e:	83 c4 2c             	add    $0x2c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	be 00 00 00 00       	mov    $0x0,%esi
  800f51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	89 cb                	mov    %ecx,%ebx
  800f81:	89 cf                	mov    %ecx,%edi
  800f83:	89 ce                	mov    %ecx,%esi
  800f85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 28                	jle    800fb3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f96:	00 
  800f97:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800fae:	e8 0e f2 ff ff       	call   8001c1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb3:	83 c4 2c             	add    $0x2c,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	66 90                	xchg   %ax,%ax
  800fbd:	66 90                	xchg   %ax,%ax
  800fbf:	90                   	nop

00800fc0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	05 00 00 00 30       	add    $0x30000000,%eax
  800fcb:	c1 e8 0c             	shr    $0xc,%eax
}
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800fdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fe0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fed:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ff2:	89 c2                	mov    %eax,%edx
  800ff4:	c1 ea 16             	shr    $0x16,%edx
  800ff7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ffe:	f6 c2 01             	test   $0x1,%dl
  801001:	74 11                	je     801014 <fd_alloc+0x2d>
  801003:	89 c2                	mov    %eax,%edx
  801005:	c1 ea 0c             	shr    $0xc,%edx
  801008:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80100f:	f6 c2 01             	test   $0x1,%dl
  801012:	75 09                	jne    80101d <fd_alloc+0x36>
			*fd_store = fd;
  801014:	89 01                	mov    %eax,(%ecx)
			return 0;
  801016:	b8 00 00 00 00       	mov    $0x0,%eax
  80101b:	eb 17                	jmp    801034 <fd_alloc+0x4d>
  80101d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801022:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801027:	75 c9                	jne    800ff2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801029:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80102f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80103c:	83 f8 1f             	cmp    $0x1f,%eax
  80103f:	77 36                	ja     801077 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801041:	c1 e0 0c             	shl    $0xc,%eax
  801044:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801049:	89 c2                	mov    %eax,%edx
  80104b:	c1 ea 16             	shr    $0x16,%edx
  80104e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801055:	f6 c2 01             	test   $0x1,%dl
  801058:	74 24                	je     80107e <fd_lookup+0x48>
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	c1 ea 0c             	shr    $0xc,%edx
  80105f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801066:	f6 c2 01             	test   $0x1,%dl
  801069:	74 1a                	je     801085 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80106b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106e:	89 02                	mov    %eax,(%edx)
	return 0;
  801070:	b8 00 00 00 00       	mov    $0x0,%eax
  801075:	eb 13                	jmp    80108a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801077:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80107c:	eb 0c                	jmp    80108a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80107e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801083:	eb 05                	jmp    80108a <fd_lookup+0x54>
  801085:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 18             	sub    $0x18,%esp
  801092:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801095:	ba 08 27 80 00       	mov    $0x802708,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80109a:	eb 13                	jmp    8010af <dev_lookup+0x23>
  80109c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80109f:	39 08                	cmp    %ecx,(%eax)
  8010a1:	75 0c                	jne    8010af <dev_lookup+0x23>
			*dev = devtab[i];
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	eb 30                	jmp    8010df <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010af:	8b 02                	mov    (%edx),%eax
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	75 e7                	jne    80109c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010b5:	a1 20 60 80 00       	mov    0x806020,%eax
  8010ba:	8b 40 48             	mov    0x48(%eax),%eax
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c5:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8010cc:	e8 e9 f1 ff ff       	call   8002ba <cprintf>
	*dev = 0;
  8010d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 20             	sub    $0x20,%esp
  8010e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ff:	89 04 24             	mov    %eax,(%esp)
  801102:	e8 2f ff ff ff       	call   801036 <fd_lookup>
  801107:	85 c0                	test   %eax,%eax
  801109:	78 05                	js     801110 <fd_close+0x2f>
	    || fd != fd2)
  80110b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80110e:	74 0c                	je     80111c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801110:	84 db                	test   %bl,%bl
  801112:	ba 00 00 00 00       	mov    $0x0,%edx
  801117:	0f 44 c2             	cmove  %edx,%eax
  80111a:	eb 3f                	jmp    80115b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80111c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801123:	8b 06                	mov    (%esi),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 5f ff ff ff       	call   80108c <dev_lookup>
  80112d:	89 c3                	mov    %eax,%ebx
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 16                	js     801149 <fd_close+0x68>
		if (dev->dev_close)
  801133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801136:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80113e:	85 c0                	test   %eax,%eax
  801140:	74 07                	je     801149 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801142:	89 34 24             	mov    %esi,(%esp)
  801145:	ff d0                	call   *%eax
  801147:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801149:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801154:	e8 a1 fc ff ff       	call   800dfa <sys_page_unmap>
	return r;
  801159:	89 d8                	mov    %ebx,%eax
}
  80115b:	83 c4 20             	add    $0x20,%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801168:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	89 04 24             	mov    %eax,(%esp)
  801175:	e8 bc fe ff ff       	call   801036 <fd_lookup>
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	85 d2                	test   %edx,%edx
  80117e:	78 13                	js     801193 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801180:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801187:	00 
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118b:	89 04 24             	mov    %eax,(%esp)
  80118e:	e8 4e ff ff ff       	call   8010e1 <fd_close>
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <close_all>:

void
close_all(void)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	53                   	push   %ebx
  801199:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011a1:	89 1c 24             	mov    %ebx,(%esp)
  8011a4:	e8 b9 ff ff ff       	call   801162 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011a9:	83 c3 01             	add    $0x1,%ebx
  8011ac:	83 fb 20             	cmp    $0x20,%ebx
  8011af:	75 f0                	jne    8011a1 <close_all+0xc>
		close(i);
}
  8011b1:	83 c4 14             	add    $0x14,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	89 04 24             	mov    %eax,(%esp)
  8011cd:	e8 64 fe ff ff       	call   801036 <fd_lookup>
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	85 d2                	test   %edx,%edx
  8011d6:	0f 88 e1 00 00 00    	js     8012bd <dup+0x106>
		return r;
	close(newfdnum);
  8011dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 7b ff ff ff       	call   801162 <close>

	newfd = INDEX2FD(newfdnum);
  8011e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ea:	c1 e3 0c             	shl    $0xc,%ebx
  8011ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8011f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 d2 fd ff ff       	call   800fd0 <fd2data>
  8011fe:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801200:	89 1c 24             	mov    %ebx,(%esp)
  801203:	e8 c8 fd ff ff       	call   800fd0 <fd2data>
  801208:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80120a:	89 f0                	mov    %esi,%eax
  80120c:	c1 e8 16             	shr    $0x16,%eax
  80120f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801216:	a8 01                	test   $0x1,%al
  801218:	74 43                	je     80125d <dup+0xa6>
  80121a:	89 f0                	mov    %esi,%eax
  80121c:	c1 e8 0c             	shr    $0xc,%eax
  80121f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	74 32                	je     80125d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80122b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801232:	25 07 0e 00 00       	and    $0xe07,%eax
  801237:	89 44 24 10          	mov    %eax,0x10(%esp)
  80123b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801246:	00 
  801247:	89 74 24 04          	mov    %esi,0x4(%esp)
  80124b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801252:	e8 50 fb ff ff       	call   800da7 <sys_page_map>
  801257:	89 c6                	mov    %eax,%esi
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 3e                	js     80129b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80125d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 0c             	shr    $0xc,%edx
  801265:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801272:	89 54 24 10          	mov    %edx,0x10(%esp)
  801276:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80127a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801281:	00 
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128d:	e8 15 fb ff ff       	call   800da7 <sys_page_map>
  801292:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801297:	85 f6                	test   %esi,%esi
  801299:	79 22                	jns    8012bd <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80129b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80129f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a6:	e8 4f fb ff ff       	call   800dfa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b6:	e8 3f fb ff ff       	call   800dfa <sys_page_unmap>
	return r;
  8012bb:	89 f0                	mov    %esi,%eax
}
  8012bd:	83 c4 3c             	add    $0x3c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 24             	sub    $0x24,%esp
  8012cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d6:	89 1c 24             	mov    %ebx,(%esp)
  8012d9:	e8 58 fd ff ff       	call   801036 <fd_lookup>
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	85 d2                	test   %edx,%edx
  8012e2:	78 6d                	js     801351 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	8b 00                	mov    (%eax),%eax
  8012f0:	89 04 24             	mov    %eax,(%esp)
  8012f3:	e8 94 fd ff ff       	call   80108c <dev_lookup>
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 55                	js     801351 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	8b 50 08             	mov    0x8(%eax),%edx
  801302:	83 e2 03             	and    $0x3,%edx
  801305:	83 fa 01             	cmp    $0x1,%edx
  801308:	75 23                	jne    80132d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80130a:	a1 20 60 80 00       	mov    0x806020,%eax
  80130f:	8b 40 48             	mov    0x48(%eax),%eax
  801312:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  801321:	e8 94 ef ff ff       	call   8002ba <cprintf>
		return -E_INVAL;
  801326:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132b:	eb 24                	jmp    801351 <read+0x8c>
	}
	if (!dev->dev_read)
  80132d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801330:	8b 52 08             	mov    0x8(%edx),%edx
  801333:	85 d2                	test   %edx,%edx
  801335:	74 15                	je     80134c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801337:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80133a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801341:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	ff d2                	call   *%edx
  80134a:	eb 05                	jmp    801351 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80134c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801351:	83 c4 24             	add    $0x24,%esp
  801354:	5b                   	pop    %ebx
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	57                   	push   %edi
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 1c             	sub    $0x1c,%esp
  801360:	8b 7d 08             	mov    0x8(%ebp),%edi
  801363:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801366:	bb 00 00 00 00       	mov    $0x0,%ebx
  80136b:	eb 23                	jmp    801390 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80136d:	89 f0                	mov    %esi,%eax
  80136f:	29 d8                	sub    %ebx,%eax
  801371:	89 44 24 08          	mov    %eax,0x8(%esp)
  801375:	89 d8                	mov    %ebx,%eax
  801377:	03 45 0c             	add    0xc(%ebp),%eax
  80137a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137e:	89 3c 24             	mov    %edi,(%esp)
  801381:	e8 3f ff ff ff       	call   8012c5 <read>
		if (m < 0)
  801386:	85 c0                	test   %eax,%eax
  801388:	78 10                	js     80139a <readn+0x43>
			return m;
		if (m == 0)
  80138a:	85 c0                	test   %eax,%eax
  80138c:	74 0a                	je     801398 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138e:	01 c3                	add    %eax,%ebx
  801390:	39 f3                	cmp    %esi,%ebx
  801392:	72 d9                	jb     80136d <readn+0x16>
  801394:	89 d8                	mov    %ebx,%eax
  801396:	eb 02                	jmp    80139a <readn+0x43>
  801398:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80139a:	83 c4 1c             	add    $0x1c,%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5f                   	pop    %edi
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 24             	sub    $0x24,%esp
  8013a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b3:	89 1c 24             	mov    %ebx,(%esp)
  8013b6:	e8 7b fc ff ff       	call   801036 <fd_lookup>
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	85 d2                	test   %edx,%edx
  8013bf:	78 68                	js     801429 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cb:	8b 00                	mov    (%eax),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 b7 fc ff ff       	call   80108c <dev_lookup>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 50                	js     801429 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e0:	75 23                	jne    801405 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e2:	a1 20 60 80 00       	mov    0x806020,%eax
  8013e7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f2:	c7 04 24 e9 26 80 00 	movl   $0x8026e9,(%esp)
  8013f9:	e8 bc ee ff ff       	call   8002ba <cprintf>
		return -E_INVAL;
  8013fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801403:	eb 24                	jmp    801429 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801405:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801408:	8b 52 0c             	mov    0xc(%edx),%edx
  80140b:	85 d2                	test   %edx,%edx
  80140d:	74 15                	je     801424 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80140f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801412:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801416:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801419:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	ff d2                	call   *%edx
  801422:	eb 05                	jmp    801429 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801424:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801429:	83 c4 24             	add    $0x24,%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <seek>:

int
seek(int fdnum, off_t offset)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801435:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801438:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 ef fb ff ff       	call   801036 <fd_lookup>
  801447:	85 c0                	test   %eax,%eax
  801449:	78 0e                	js     801459 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80144b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80144e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801451:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801454:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	53                   	push   %ebx
  80145f:	83 ec 24             	sub    $0x24,%esp
  801462:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801465:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801468:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146c:	89 1c 24             	mov    %ebx,(%esp)
  80146f:	e8 c2 fb ff ff       	call   801036 <fd_lookup>
  801474:	89 c2                	mov    %eax,%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	78 61                	js     8014db <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	8b 00                	mov    (%eax),%eax
  801486:	89 04 24             	mov    %eax,(%esp)
  801489:	e8 fe fb ff ff       	call   80108c <dev_lookup>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 49                	js     8014db <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801499:	75 23                	jne    8014be <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80149b:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a0:	8b 40 48             	mov    0x48(%eax),%eax
  8014a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ab:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8014b2:	e8 03 ee ff ff       	call   8002ba <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bc:	eb 1d                	jmp    8014db <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8014be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c1:	8b 52 18             	mov    0x18(%edx),%edx
  8014c4:	85 d2                	test   %edx,%edx
  8014c6:	74 0e                	je     8014d6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	ff d2                	call   *%edx
  8014d4:	eb 05                	jmp    8014db <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8014db:	83 c4 24             	add    $0x24,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    

008014e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 24             	sub    $0x24,%esp
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	89 04 24             	mov    %eax,(%esp)
  8014f8:	e8 39 fb ff ff       	call   801036 <fd_lookup>
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	85 d2                	test   %edx,%edx
  801501:	78 52                	js     801555 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150d:	8b 00                	mov    (%eax),%eax
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 75 fb ff ff       	call   80108c <dev_lookup>
  801517:	85 c0                	test   %eax,%eax
  801519:	78 3a                	js     801555 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80151b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801522:	74 2c                	je     801550 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801524:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801527:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80152e:	00 00 00 
	stat->st_isdir = 0;
  801531:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801538:	00 00 00 
	stat->st_dev = dev;
  80153b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801545:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801548:	89 14 24             	mov    %edx,(%esp)
  80154b:	ff 50 14             	call   *0x14(%eax)
  80154e:	eb 05                	jmp    801555 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801550:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801555:	83 c4 24             	add    $0x24,%esp
  801558:	5b                   	pop    %ebx
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801563:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80156a:	00 
  80156b:	8b 45 08             	mov    0x8(%ebp),%eax
  80156e:	89 04 24             	mov    %eax,(%esp)
  801571:	e8 fb 01 00 00       	call   801771 <open>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	85 db                	test   %ebx,%ebx
  80157a:	78 1b                	js     801597 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80157c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801583:	89 1c 24             	mov    %ebx,(%esp)
  801586:	e8 56 ff ff ff       	call   8014e1 <fstat>
  80158b:	89 c6                	mov    %eax,%esi
	close(fd);
  80158d:	89 1c 24             	mov    %ebx,(%esp)
  801590:	e8 cd fb ff ff       	call   801162 <close>
	return r;
  801595:	89 f0                	mov    %esi,%eax
}
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 10             	sub    $0x10,%esp
  8015a6:	89 c6                	mov    %eax,%esi
  8015a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015aa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015b1:	75 11                	jne    8015c4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015ba:	e8 0e 0a 00 00       	call   801fcd <ipc_find_env>
  8015bf:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015c4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015cb:	00 
  8015cc:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8015d3:	00 
  8015d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d8:	a1 00 40 80 00       	mov    0x804000,%eax
  8015dd:	89 04 24             	mov    %eax,(%esp)
  8015e0:	e8 39 09 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ec:	00 
  8015ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f8:	e8 83 08 00 00       	call   801e80 <ipc_recv>
}
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801615:	8b 45 0c             	mov    0xc(%ebp),%eax
  801618:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80161d:	ba 00 00 00 00       	mov    $0x0,%edx
  801622:	b8 02 00 00 00       	mov    $0x2,%eax
  801627:	e8 72 ff ff ff       	call   80159e <fsipc>
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	8b 40 0c             	mov    0xc(%eax),%eax
  80163a:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80163f:	ba 00 00 00 00       	mov    $0x0,%edx
  801644:	b8 06 00 00 00       	mov    $0x6,%eax
  801649:	e8 50 ff ff ff       	call   80159e <fsipc>
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 14             	sub    $0x14,%esp
  801657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 40 0c             	mov    0xc(%eax),%eax
  801660:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 05 00 00 00       	mov    $0x5,%eax
  80166f:	e8 2a ff ff ff       	call   80159e <fsipc>
  801674:	89 c2                	mov    %eax,%edx
  801676:	85 d2                	test   %edx,%edx
  801678:	78 2b                	js     8016a5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80167a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801681:	00 
  801682:	89 1c 24             	mov    %ebx,(%esp)
  801685:	e8 ad f2 ff ff       	call   800937 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168a:	a1 80 70 80 00       	mov    0x807080,%eax
  80168f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801695:	a1 84 70 80 00       	mov    0x807084,%eax
  80169a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	83 c4 14             	add    $0x14,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016b1:	c7 44 24 08 18 27 80 	movl   $0x802718,0x8(%esp)
  8016b8:	00 
  8016b9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016c0:	00 
  8016c1:	c7 04 24 36 27 80 00 	movl   $0x802736,(%esp)
  8016c8:	e8 f4 ea ff ff       	call   8001c1 <_panic>

008016cd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	56                   	push   %esi
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 10             	sub    $0x10,%esp
  8016d5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016db:	8b 40 0c             	mov    0xc(%eax),%eax
  8016de:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8016e3:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8016f3:	e8 a6 fe ff ff       	call   80159e <fsipc>
  8016f8:	89 c3                	mov    %eax,%ebx
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 6a                	js     801768 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016fe:	39 c6                	cmp    %eax,%esi
  801700:	73 24                	jae    801726 <devfile_read+0x59>
  801702:	c7 44 24 0c 41 27 80 	movl   $0x802741,0xc(%esp)
  801709:	00 
  80170a:	c7 44 24 08 48 27 80 	movl   $0x802748,0x8(%esp)
  801711:	00 
  801712:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801719:	00 
  80171a:	c7 04 24 36 27 80 00 	movl   $0x802736,(%esp)
  801721:	e8 9b ea ff ff       	call   8001c1 <_panic>
	assert(r <= PGSIZE);
  801726:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80172b:	7e 24                	jle    801751 <devfile_read+0x84>
  80172d:	c7 44 24 0c 5d 27 80 	movl   $0x80275d,0xc(%esp)
  801734:	00 
  801735:	c7 44 24 08 48 27 80 	movl   $0x802748,0x8(%esp)
  80173c:	00 
  80173d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801744:	00 
  801745:	c7 04 24 36 27 80 00 	movl   $0x802736,(%esp)
  80174c:	e8 70 ea ff ff       	call   8001c1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801751:	89 44 24 08          	mov    %eax,0x8(%esp)
  801755:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80175c:	00 
  80175d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801760:	89 04 24             	mov    %eax,(%esp)
  801763:	e8 6c f3 ff ff       	call   800ad4 <memmove>
	return r;
}
  801768:	89 d8                	mov    %ebx,%eax
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 24             	sub    $0x24,%esp
  801778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80177b:	89 1c 24             	mov    %ebx,(%esp)
  80177e:	e8 7d f1 ff ff       	call   800900 <strlen>
  801783:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801788:	7f 60                	jg     8017ea <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	89 04 24             	mov    %eax,(%esp)
  801790:	e8 52 f8 ff ff       	call   800fe7 <fd_alloc>
  801795:	89 c2                	mov    %eax,%edx
  801797:	85 d2                	test   %edx,%edx
  801799:	78 54                	js     8017ef <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80179b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80179f:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8017a6:	e8 8c f1 ff ff       	call   800937 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ae:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017bb:	e8 de fd ff ff       	call   80159e <fsipc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	79 17                	jns    8017dd <open+0x6c>
		fd_close(fd, 0);
  8017c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017cd:	00 
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 08 f9 ff ff       	call   8010e1 <fd_close>
		return r;
  8017d9:	89 d8                	mov    %ebx,%eax
  8017db:	eb 12                	jmp    8017ef <open+0x7e>
	}

	return fd2num(fd);
  8017dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 d8 f7 ff ff       	call   800fc0 <fd2num>
  8017e8:	eb 05                	jmp    8017ef <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017ea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017ef:	83 c4 24             	add    $0x24,%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801800:	b8 08 00 00 00       	mov    $0x8,%eax
  801805:	e8 94 fd ff ff       	call   80159e <fsipc>
}
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 14             	sub    $0x14,%esp
  801813:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801815:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801819:	7e 31                	jle    80184c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80181b:	8b 40 04             	mov    0x4(%eax),%eax
  80181e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801822:	8d 43 10             	lea    0x10(%ebx),%eax
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	8b 03                	mov    (%ebx),%eax
  80182b:	89 04 24             	mov    %eax,(%esp)
  80182e:	e8 6f fb ff ff       	call   8013a2 <write>
		if (result > 0)
  801833:	85 c0                	test   %eax,%eax
  801835:	7e 03                	jle    80183a <writebuf+0x2e>
			b->result += result;
  801837:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80183a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80183d:	74 0d                	je     80184c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  80183f:	85 c0                	test   %eax,%eax
  801841:	ba 00 00 00 00       	mov    $0x0,%edx
  801846:	0f 4f c2             	cmovg  %edx,%eax
  801849:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80184c:	83 c4 14             	add    $0x14,%esp
  80184f:	5b                   	pop    %ebx
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <putch>:

static void
putch(int ch, void *thunk)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80185c:	8b 53 04             	mov    0x4(%ebx),%edx
  80185f:	8d 42 01             	lea    0x1(%edx),%eax
  801862:	89 43 04             	mov    %eax,0x4(%ebx)
  801865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801868:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80186c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801871:	75 0e                	jne    801881 <putch+0x2f>
		writebuf(b);
  801873:	89 d8                	mov    %ebx,%eax
  801875:	e8 92 ff ff ff       	call   80180c <writebuf>
		b->idx = 0;
  80187a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801881:	83 c4 04             	add    $0x4,%esp
  801884:	5b                   	pop    %ebx
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801899:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018a0:	00 00 00 
	b.result = 0;
  8018a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018aa:	00 00 00 
	b.error = 1;
  8018ad:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018b4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cf:	c7 04 24 52 18 80 00 	movl   $0x801852,(%esp)
  8018d6:	e8 39 eb ff ff       	call   800414 <vprintfmt>
	if (b.idx > 0)
  8018db:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018e2:	7e 0b                	jle    8018ef <vfprintf+0x68>
		writebuf(&b);
  8018e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018ea:	e8 1d ff ff ff       	call   80180c <writebuf>

	return (b.result ? b.result : b.error);
  8018ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801906:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801909:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	89 04 24             	mov    %eax,(%esp)
  80191a:	e8 68 ff ff ff       	call   801887 <vfprintf>
	va_end(ap);

	return cnt;
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <printf>:

int
printf(const char *fmt, ...)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801927:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80192a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	89 44 24 04          	mov    %eax,0x4(%esp)
  801935:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80193c:	e8 46 ff ff ff       	call   801887 <vfprintf>
	va_end(ap);

	return cnt;
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	56                   	push   %esi
  801947:	53                   	push   %ebx
  801948:	83 ec 10             	sub    $0x10,%esp
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 77 f6 ff ff       	call   800fd0 <fd2data>
  801959:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80195b:	c7 44 24 04 69 27 80 	movl   $0x802769,0x4(%esp)
  801962:	00 
  801963:	89 1c 24             	mov    %ebx,(%esp)
  801966:	e8 cc ef ff ff       	call   800937 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196b:	8b 46 04             	mov    0x4(%esi),%eax
  80196e:	2b 06                	sub    (%esi),%eax
  801970:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197d:	00 00 00 
	stat->st_dev = &devpipe;
  801980:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801987:	30 80 00 
	return 0;
}
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 14             	sub    $0x14,%esp
  80199d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ab:	e8 4a f4 ff ff       	call   800dfa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b0:	89 1c 24             	mov    %ebx,(%esp)
  8019b3:	e8 18 f6 ff ff       	call   800fd0 <fd2data>
  8019b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c3:	e8 32 f4 ff ff       	call   800dfa <sys_page_unmap>
}
  8019c8:	83 c4 14             	add    $0x14,%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	57                   	push   %edi
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 2c             	sub    $0x2c,%esp
  8019d7:	89 c6                	mov    %eax,%esi
  8019d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019dc:	a1 20 60 80 00       	mov    0x806020,%eax
  8019e1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019e4:	89 34 24             	mov    %esi,(%esp)
  8019e7:	e8 19 06 00 00       	call   802005 <pageref>
  8019ec:	89 c7                	mov    %eax,%edi
  8019ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f1:	89 04 24             	mov    %eax,(%esp)
  8019f4:	e8 0c 06 00 00       	call   802005 <pageref>
  8019f9:	39 c7                	cmp    %eax,%edi
  8019fb:	0f 94 c2             	sete   %dl
  8019fe:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801a01:	8b 0d 20 60 80 00    	mov    0x806020,%ecx
  801a07:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801a0a:	39 fb                	cmp    %edi,%ebx
  801a0c:	74 21                	je     801a2f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a0e:	84 d2                	test   %dl,%dl
  801a10:	74 ca                	je     8019dc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a12:	8b 51 58             	mov    0x58(%ecx),%edx
  801a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a19:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a21:	c7 04 24 70 27 80 00 	movl   $0x802770,(%esp)
  801a28:	e8 8d e8 ff ff       	call   8002ba <cprintf>
  801a2d:	eb ad                	jmp    8019dc <_pipeisclosed+0xe>
	}
}
  801a2f:	83 c4 2c             	add    $0x2c,%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5f                   	pop    %edi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    

00801a37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	57                   	push   %edi
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 1c             	sub    $0x1c,%esp
  801a40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a43:	89 34 24             	mov    %esi,(%esp)
  801a46:	e8 85 f5 ff ff       	call   800fd0 <fd2data>
  801a4b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a52:	eb 45                	jmp    801a99 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a54:	89 da                	mov    %ebx,%edx
  801a56:	89 f0                	mov    %esi,%eax
  801a58:	e8 71 ff ff ff       	call   8019ce <_pipeisclosed>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	75 41                	jne    801aa2 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a61:	e8 ce f2 ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a66:	8b 43 04             	mov    0x4(%ebx),%eax
  801a69:	8b 0b                	mov    (%ebx),%ecx
  801a6b:	8d 51 20             	lea    0x20(%ecx),%edx
  801a6e:	39 d0                	cmp    %edx,%eax
  801a70:	73 e2                	jae    801a54 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a7c:	99                   	cltd   
  801a7d:	c1 ea 1b             	shr    $0x1b,%edx
  801a80:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801a83:	83 e1 1f             	and    $0x1f,%ecx
  801a86:	29 d1                	sub    %edx,%ecx
  801a88:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801a8c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801a90:	83 c0 01             	add    $0x1,%eax
  801a93:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a96:	83 c7 01             	add    $0x1,%edi
  801a99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9c:	75 c8                	jne    801a66 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9e:	89 f8                	mov    %edi,%eax
  801aa0:	eb 05                	jmp    801aa7 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa7:	83 c4 1c             	add    $0x1c,%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 1c             	sub    $0x1c,%esp
  801ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abb:	89 3c 24             	mov    %edi,(%esp)
  801abe:	e8 0d f5 ff ff       	call   800fd0 <fd2data>
  801ac3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac5:	be 00 00 00 00       	mov    $0x0,%esi
  801aca:	eb 3d                	jmp    801b09 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801acc:	85 f6                	test   %esi,%esi
  801ace:	74 04                	je     801ad4 <devpipe_read+0x25>
				return i;
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	eb 43                	jmp    801b17 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	89 f8                	mov    %edi,%eax
  801ad8:	e8 f1 fe ff ff       	call   8019ce <_pipeisclosed>
  801add:	85 c0                	test   %eax,%eax
  801adf:	75 31                	jne    801b12 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae1:	e8 4e f2 ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae6:	8b 03                	mov    (%ebx),%eax
  801ae8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aeb:	74 df                	je     801acc <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aed:	99                   	cltd   
  801aee:	c1 ea 1b             	shr    $0x1b,%edx
  801af1:	01 d0                	add    %edx,%eax
  801af3:	83 e0 1f             	and    $0x1f,%eax
  801af6:	29 d0                	sub    %edx,%eax
  801af8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b00:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b03:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	83 c6 01             	add    $0x1,%esi
  801b09:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b0c:	75 d8                	jne    801ae6 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b0e:	89 f0                	mov    %esi,%eax
  801b10:	eb 05                	jmp    801b17 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b17:	83 c4 1c             	add    $0x1c,%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5f                   	pop    %edi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2a:	89 04 24             	mov    %eax,(%esp)
  801b2d:	e8 b5 f4 ff ff       	call   800fe7 <fd_alloc>
  801b32:	89 c2                	mov    %eax,%edx
  801b34:	85 d2                	test   %edx,%edx
  801b36:	0f 88 4d 01 00 00    	js     801c89 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b43:	00 
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b52:	e8 fc f1 ff ff       	call   800d53 <sys_page_alloc>
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	85 d2                	test   %edx,%edx
  801b5b:	0f 88 28 01 00 00    	js     801c89 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b64:	89 04 24             	mov    %eax,(%esp)
  801b67:	e8 7b f4 ff ff       	call   800fe7 <fd_alloc>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	0f 88 fe 00 00 00    	js     801c74 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b7d:	00 
  801b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8c:	e8 c2 f1 ff ff       	call   800d53 <sys_page_alloc>
  801b91:	89 c3                	mov    %eax,%ebx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 d9 00 00 00    	js     801c74 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9e:	89 04 24             	mov    %eax,(%esp)
  801ba1:	e8 2a f4 ff ff       	call   800fd0 <fd2data>
  801ba6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801baf:	00 
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bbb:	e8 93 f1 ff ff       	call   800d53 <sys_page_alloc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	0f 88 97 00 00 00    	js     801c61 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bcd:	89 04 24             	mov    %eax,(%esp)
  801bd0:	e8 fb f3 ff ff       	call   800fd0 <fd2data>
  801bd5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801bdc:	00 
  801bdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801be8:	00 
  801be9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf4:	e8 ae f1 ff ff       	call   800da7 <sys_page_map>
  801bf9:	89 c3                	mov    %eax,%ebx
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 52                	js     801c51 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2c:	89 04 24             	mov    %eax,(%esp)
  801c2f:	e8 8c f3 ff ff       	call   800fc0 <fd2num>
  801c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c37:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3c:	89 04 24             	mov    %eax,(%esp)
  801c3f:	e8 7c f3 ff ff       	call   800fc0 <fd2num>
  801c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c47:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4f:	eb 38                	jmp    801c89 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801c51:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5c:	e8 99 f1 ff ff       	call   800dfa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c6f:	e8 86 f1 ff ff       	call   800dfa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c82:	e8 73 f1 ff ff       	call   800dfa <sys_page_unmap>
  801c87:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801c89:	83 c4 30             	add    $0x30,%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	89 04 24             	mov    %eax,(%esp)
  801ca3:	e8 8e f3 ff ff       	call   801036 <fd_lookup>
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	85 d2                	test   %edx,%edx
  801cac:	78 15                	js     801cc3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 17 f3 ff ff       	call   800fd0 <fd2data>
	return _pipeisclosed(fd, p);
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	e8 0b fd ff ff       	call   8019ce <_pipeisclosed>
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    
  801cc5:	66 90                	xchg   %ax,%ax
  801cc7:	66 90                	xchg   %ax,%ax
  801cc9:	66 90                	xchg   %ax,%ax
  801ccb:	66 90                	xchg   %ax,%ax
  801ccd:	66 90                	xchg   %ax,%ax
  801ccf:	90                   	nop

00801cd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801ce0:	c7 44 24 04 88 27 80 	movl   $0x802788,0x4(%esp)
  801ce7:	00 
  801ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ceb:	89 04 24             	mov    %eax,(%esp)
  801cee:	e8 44 ec ff ff       	call   800937 <strcpy>
	return 0;
}
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	57                   	push   %edi
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d06:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d11:	eb 31                	jmp    801d44 <devcons_write+0x4a>
		m = n - tot;
  801d13:	8b 75 10             	mov    0x10(%ebp),%esi
  801d16:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801d18:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d1b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d20:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d23:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d27:	03 45 0c             	add    0xc(%ebp),%eax
  801d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d2e:	89 3c 24             	mov    %edi,(%esp)
  801d31:	e8 9e ed ff ff       	call   800ad4 <memmove>
		sys_cputs(buf, m);
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	89 3c 24             	mov    %edi,(%esp)
  801d3d:	e8 44 ef ff ff       	call   800c86 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d42:	01 f3                	add    %esi,%ebx
  801d44:	89 d8                	mov    %ebx,%eax
  801d46:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d49:	72 c8                	jb     801d13 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d4b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5f                   	pop    %edi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801d5c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801d61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d65:	75 07                	jne    801d6e <devcons_read+0x18>
  801d67:	eb 2a                	jmp    801d93 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d69:	e8 c6 ef ff ff       	call   800d34 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d6e:	66 90                	xchg   %ax,%ax
  801d70:	e8 2f ef ff ff       	call   800ca4 <sys_cgetc>
  801d75:	85 c0                	test   %eax,%eax
  801d77:	74 f0                	je     801d69 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 16                	js     801d93 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d7d:	83 f8 04             	cmp    $0x4,%eax
  801d80:	74 0c                	je     801d8e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801d82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d85:	88 02                	mov    %al,(%edx)
	return 1;
  801d87:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8c:	eb 05                	jmp    801d93 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801da8:	00 
  801da9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dac:	89 04 24             	mov    %eax,(%esp)
  801daf:	e8 d2 ee ff ff       	call   800c86 <sys_cputs>
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <getchar>:

int
getchar(void)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801dc3:	00 
  801dc4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd2:	e8 ee f4 ff ff       	call   8012c5 <read>
	if (r < 0)
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 0f                	js     801dea <getchar+0x34>
		return r;
	if (r < 1)
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	7e 06                	jle    801de5 <getchar+0x2f>
		return -E_EOF;
	return c;
  801ddf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de3:	eb 05                	jmp    801dea <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	89 04 24             	mov    %eax,(%esp)
  801dff:	e8 32 f2 ff ff       	call   801036 <fd_lookup>
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 11                	js     801e19 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e11:	39 10                	cmp    %edx,(%eax)
  801e13:	0f 94 c0             	sete   %al
  801e16:	0f b6 c0             	movzbl %al,%eax
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <opencons>:

int
opencons(void)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	89 04 24             	mov    %eax,(%esp)
  801e27:	e8 bb f1 ff ff       	call   800fe7 <fd_alloc>
		return r;
  801e2c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 40                	js     801e72 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e39:	00 
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e48:	e8 06 ef ff ff       	call   800d53 <sys_page_alloc>
		return r;
  801e4d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 1f                	js     801e72 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e53:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e68:	89 04 24             	mov    %eax,(%esp)
  801e6b:	e8 50 f1 ff ff       	call   800fc0 <fd2num>
  801e70:	89 c2                	mov    %eax,%edx
}
  801e72:	89 d0                	mov    %edx,%eax
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	56                   	push   %esi
  801e84:	53                   	push   %ebx
  801e85:	83 ec 10             	sub    $0x10,%esp
  801e88:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801e91:	85 c0                	test   %eax,%eax
  801e93:	75 0e                	jne    801ea3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801e95:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801e9c:	e8 c8 f0 ff ff       	call   800f69 <sys_ipc_recv>
  801ea1:	eb 08                	jmp    801eab <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 be f0 ff ff       	call   800f69 <sys_ipc_recv>
	if(r == 0){
  801eab:	85 c0                	test   %eax,%eax
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	75 1e                	jne    801ed0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801eb2:	85 f6                	test   %esi,%esi
  801eb4:	74 0a                	je     801ec0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801eb6:	a1 20 60 80 00       	mov    0x806020,%eax
  801ebb:	8b 40 74             	mov    0x74(%eax),%eax
  801ebe:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801ec0:	85 db                	test   %ebx,%ebx
  801ec2:	74 2c                	je     801ef0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801ec4:	a1 20 60 80 00       	mov    0x806020,%eax
  801ec9:	8b 40 78             	mov    0x78(%eax),%eax
  801ecc:	89 03                	mov    %eax,(%ebx)
  801ece:	eb 20                	jmp    801ef0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801ed0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ed4:	c7 44 24 08 94 27 80 	movl   $0x802794,0x8(%esp)
  801edb:	00 
  801edc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801ee3:	00 
  801ee4:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  801eeb:	e8 d1 e2 ff ff       	call   8001c1 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801ef0:	a1 20 60 80 00       	mov    0x806020,%eax
  801ef5:	8b 50 70             	mov    0x70(%eax),%edx
  801ef8:	85 d2                	test   %edx,%edx
  801efa:	75 13                	jne    801f0f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  801efc:	8b 40 48             	mov    0x48(%eax),%eax
  801eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f03:	c7 04 24 c4 27 80 00 	movl   $0x8027c4,(%esp)
  801f0a:	e8 ab e3 ff ff       	call   8002ba <cprintf>
	return thisenv->env_ipc_value;
  801f0f:	a1 20 60 80 00       	mov    0x806020,%eax
  801f14:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  801f2d:	85 f6                	test   %esi,%esi
  801f2f:	75 22                	jne    801f53 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801f31:	8b 45 14             	mov    0x14(%ebp),%eax
  801f34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f38:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801f3f:	ee 
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f47:	89 3c 24             	mov    %edi,(%esp)
  801f4a:	e8 f7 ef ff ff       	call   800f46 <sys_ipc_try_send>
  801f4f:	89 c3                	mov    %eax,%ebx
  801f51:	eb 1c                	jmp    801f6f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801f53:	8b 45 14             	mov    0x14(%ebp),%eax
  801f56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	89 3c 24             	mov    %edi,(%esp)
  801f68:	e8 d9 ef ff ff       	call   800f46 <sys_ipc_try_send>
  801f6d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  801f6f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801f72:	74 3e                	je     801fb2 <ipc_send+0x94>
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	c1 e8 1f             	shr    $0x1f,%eax
  801f79:	84 c0                	test   %al,%al
  801f7b:	74 35                	je     801fb2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  801f7d:	e8 93 ed ff ff       	call   800d15 <sys_getenvid>
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	c7 04 24 1a 28 80 00 	movl   $0x80281a,(%esp)
  801f8d:	e8 28 e3 ff ff       	call   8002ba <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801f92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f96:	c7 44 24 08 e8 27 80 	movl   $0x8027e8,0x8(%esp)
  801f9d:	00 
  801f9e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801fa5:	00 
  801fa6:	c7 04 24 10 28 80 00 	movl   $0x802810,(%esp)
  801fad:	e8 0f e2 ff ff       	call   8001c1 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  801fb2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801fb5:	75 0e                	jne    801fc5 <ipc_send+0xa7>
			sys_yield();
  801fb7:	e8 78 ed ff ff       	call   800d34 <sys_yield>
		else break;
	}
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	e9 68 ff ff ff       	jmp    801f2d <ipc_send+0xf>
	
}
  801fc5:	83 c4 1c             	add    $0x1c,%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fdb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe1:	8b 52 50             	mov    0x50(%edx),%edx
  801fe4:	39 ca                	cmp    %ecx,%edx
  801fe6:	75 0d                	jne    801ff5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801feb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ff0:	8b 40 40             	mov    0x40(%eax),%eax
  801ff3:	eb 0e                	jmp    802003 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff5:	83 c0 01             	add    $0x1,%eax
  801ff8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ffd:	75 d9                	jne    801fd8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fff:	66 b8 00 00          	mov    $0x0,%ax
}
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200b:	89 d0                	mov    %edx,%eax
  80200d:	c1 e8 16             	shr    $0x16,%eax
  802010:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201c:	f6 c1 01             	test   $0x1,%cl
  80201f:	74 1d                	je     80203e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802021:	c1 ea 0c             	shr    $0xc,%edx
  802024:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80202b:	f6 c2 01             	test   $0x1,%dl
  80202e:	74 0e                	je     80203e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802030:	c1 ea 0c             	shr    $0xc,%edx
  802033:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80203a:	ef 
  80203b:	0f b7 c0             	movzwl %ax,%eax
}
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	83 ec 0c             	sub    $0xc,%esp
  802046:	8b 44 24 28          	mov    0x28(%esp),%eax
  80204a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80204e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802052:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802056:	85 c0                	test   %eax,%eax
  802058:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80205c:	89 ea                	mov    %ebp,%edx
  80205e:	89 0c 24             	mov    %ecx,(%esp)
  802061:	75 2d                	jne    802090 <__udivdi3+0x50>
  802063:	39 e9                	cmp    %ebp,%ecx
  802065:	77 61                	ja     8020c8 <__udivdi3+0x88>
  802067:	85 c9                	test   %ecx,%ecx
  802069:	89 ce                	mov    %ecx,%esi
  80206b:	75 0b                	jne    802078 <__udivdi3+0x38>
  80206d:	b8 01 00 00 00       	mov    $0x1,%eax
  802072:	31 d2                	xor    %edx,%edx
  802074:	f7 f1                	div    %ecx
  802076:	89 c6                	mov    %eax,%esi
  802078:	31 d2                	xor    %edx,%edx
  80207a:	89 e8                	mov    %ebp,%eax
  80207c:	f7 f6                	div    %esi
  80207e:	89 c5                	mov    %eax,%ebp
  802080:	89 f8                	mov    %edi,%eax
  802082:	f7 f6                	div    %esi
  802084:	89 ea                	mov    %ebp,%edx
  802086:	83 c4 0c             	add    $0xc,%esp
  802089:	5e                   	pop    %esi
  80208a:	5f                   	pop    %edi
  80208b:	5d                   	pop    %ebp
  80208c:	c3                   	ret    
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
  802090:	39 e8                	cmp    %ebp,%eax
  802092:	77 24                	ja     8020b8 <__udivdi3+0x78>
  802094:	0f bd e8             	bsr    %eax,%ebp
  802097:	83 f5 1f             	xor    $0x1f,%ebp
  80209a:	75 3c                	jne    8020d8 <__udivdi3+0x98>
  80209c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8020a0:	39 34 24             	cmp    %esi,(%esp)
  8020a3:	0f 86 9f 00 00 00    	jbe    802148 <__udivdi3+0x108>
  8020a9:	39 d0                	cmp    %edx,%eax
  8020ab:	0f 82 97 00 00 00    	jb     802148 <__udivdi3+0x108>
  8020b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	31 d2                	xor    %edx,%edx
  8020ba:	31 c0                	xor    %eax,%eax
  8020bc:	83 c4 0c             	add    $0xc,%esp
  8020bf:	5e                   	pop    %esi
  8020c0:	5f                   	pop    %edi
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	90                   	nop
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	89 f8                	mov    %edi,%eax
  8020ca:	f7 f1                	div    %ecx
  8020cc:	31 d2                	xor    %edx,%edx
  8020ce:	83 c4 0c             	add    $0xc,%esp
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
  8020d8:	89 e9                	mov    %ebp,%ecx
  8020da:	8b 3c 24             	mov    (%esp),%edi
  8020dd:	d3 e0                	shl    %cl,%eax
  8020df:	89 c6                	mov    %eax,%esi
  8020e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8020e6:	29 e8                	sub    %ebp,%eax
  8020e8:	89 c1                	mov    %eax,%ecx
  8020ea:	d3 ef                	shr    %cl,%edi
  8020ec:	89 e9                	mov    %ebp,%ecx
  8020ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8020f2:	8b 3c 24             	mov    (%esp),%edi
  8020f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8020f9:	89 d6                	mov    %edx,%esi
  8020fb:	d3 e7                	shl    %cl,%edi
  8020fd:	89 c1                	mov    %eax,%ecx
  8020ff:	89 3c 24             	mov    %edi,(%esp)
  802102:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802106:	d3 ee                	shr    %cl,%esi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	d3 e2                	shl    %cl,%edx
  80210c:	89 c1                	mov    %eax,%ecx
  80210e:	d3 ef                	shr    %cl,%edi
  802110:	09 d7                	or     %edx,%edi
  802112:	89 f2                	mov    %esi,%edx
  802114:	89 f8                	mov    %edi,%eax
  802116:	f7 74 24 08          	divl   0x8(%esp)
  80211a:	89 d6                	mov    %edx,%esi
  80211c:	89 c7                	mov    %eax,%edi
  80211e:	f7 24 24             	mull   (%esp)
  802121:	39 d6                	cmp    %edx,%esi
  802123:	89 14 24             	mov    %edx,(%esp)
  802126:	72 30                	jb     802158 <__udivdi3+0x118>
  802128:	8b 54 24 04          	mov    0x4(%esp),%edx
  80212c:	89 e9                	mov    %ebp,%ecx
  80212e:	d3 e2                	shl    %cl,%edx
  802130:	39 c2                	cmp    %eax,%edx
  802132:	73 05                	jae    802139 <__udivdi3+0xf9>
  802134:	3b 34 24             	cmp    (%esp),%esi
  802137:	74 1f                	je     802158 <__udivdi3+0x118>
  802139:	89 f8                	mov    %edi,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	e9 7a ff ff ff       	jmp    8020bc <__udivdi3+0x7c>
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 d2                	xor    %edx,%edx
  80214a:	b8 01 00 00 00       	mov    $0x1,%eax
  80214f:	e9 68 ff ff ff       	jmp    8020bc <__udivdi3+0x7c>
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	8d 47 ff             	lea    -0x1(%edi),%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 0c             	add    $0xc,%esp
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	83 ec 14             	sub    $0x14,%esp
  802176:	8b 44 24 28          	mov    0x28(%esp),%eax
  80217a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80217e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802182:	89 c7                	mov    %eax,%edi
  802184:	89 44 24 04          	mov    %eax,0x4(%esp)
  802188:	8b 44 24 30          	mov    0x30(%esp),%eax
  80218c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802190:	89 34 24             	mov    %esi,(%esp)
  802193:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802197:	85 c0                	test   %eax,%eax
  802199:	89 c2                	mov    %eax,%edx
  80219b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80219f:	75 17                	jne    8021b8 <__umoddi3+0x48>
  8021a1:	39 fe                	cmp    %edi,%esi
  8021a3:	76 4b                	jbe    8021f0 <__umoddi3+0x80>
  8021a5:	89 c8                	mov    %ecx,%eax
  8021a7:	89 fa                	mov    %edi,%edx
  8021a9:	f7 f6                	div    %esi
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	83 c4 14             	add    $0x14,%esp
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	39 f8                	cmp    %edi,%eax
  8021ba:	77 54                	ja     802210 <__umoddi3+0xa0>
  8021bc:	0f bd e8             	bsr    %eax,%ebp
  8021bf:	83 f5 1f             	xor    $0x1f,%ebp
  8021c2:	75 5c                	jne    802220 <__umoddi3+0xb0>
  8021c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8021c8:	39 3c 24             	cmp    %edi,(%esp)
  8021cb:	0f 87 e7 00 00 00    	ja     8022b8 <__umoddi3+0x148>
  8021d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021d5:	29 f1                	sub    %esi,%ecx
  8021d7:	19 c7                	sbb    %eax,%edi
  8021d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021e9:	83 c4 14             	add    $0x14,%esp
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    
  8021f0:	85 f6                	test   %esi,%esi
  8021f2:	89 f5                	mov    %esi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f6                	div    %esi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	8b 44 24 04          	mov    0x4(%esp),%eax
  802205:	31 d2                	xor    %edx,%edx
  802207:	f7 f5                	div    %ebp
  802209:	89 c8                	mov    %ecx,%eax
  80220b:	f7 f5                	div    %ebp
  80220d:	eb 9c                	jmp    8021ab <__umoddi3+0x3b>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 fa                	mov    %edi,%edx
  802214:	83 c4 14             	add    $0x14,%esp
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	90                   	nop
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 04 24             	mov    (%esp),%eax
  802223:	be 20 00 00 00       	mov    $0x20,%esi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ee                	sub    %ebp,%esi
  80222c:	d3 e2                	shl    %cl,%edx
  80222e:	89 f1                	mov    %esi,%ecx
  802230:	d3 e8                	shr    %cl,%eax
  802232:	89 e9                	mov    %ebp,%ecx
  802234:	89 44 24 04          	mov    %eax,0x4(%esp)
  802238:	8b 04 24             	mov    (%esp),%eax
  80223b:	09 54 24 04          	or     %edx,0x4(%esp)
  80223f:	89 fa                	mov    %edi,%edx
  802241:	d3 e0                	shl    %cl,%eax
  802243:	89 f1                	mov    %esi,%ecx
  802245:	89 44 24 08          	mov    %eax,0x8(%esp)
  802249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80224d:	d3 ea                	shr    %cl,%edx
  80224f:	89 e9                	mov    %ebp,%ecx
  802251:	d3 e7                	shl    %cl,%edi
  802253:	89 f1                	mov    %esi,%ecx
  802255:	d3 e8                	shr    %cl,%eax
  802257:	89 e9                	mov    %ebp,%ecx
  802259:	09 f8                	or     %edi,%eax
  80225b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80225f:	f7 74 24 04          	divl   0x4(%esp)
  802263:	d3 e7                	shl    %cl,%edi
  802265:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802269:	89 d7                	mov    %edx,%edi
  80226b:	f7 64 24 08          	mull   0x8(%esp)
  80226f:	39 d7                	cmp    %edx,%edi
  802271:	89 c1                	mov    %eax,%ecx
  802273:	89 14 24             	mov    %edx,(%esp)
  802276:	72 2c                	jb     8022a4 <__umoddi3+0x134>
  802278:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80227c:	72 22                	jb     8022a0 <__umoddi3+0x130>
  80227e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802282:	29 c8                	sub    %ecx,%eax
  802284:	19 d7                	sbb    %edx,%edi
  802286:	89 e9                	mov    %ebp,%ecx
  802288:	89 fa                	mov    %edi,%edx
  80228a:	d3 e8                	shr    %cl,%eax
  80228c:	89 f1                	mov    %esi,%ecx
  80228e:	d3 e2                	shl    %cl,%edx
  802290:	89 e9                	mov    %ebp,%ecx
  802292:	d3 ef                	shr    %cl,%edi
  802294:	09 d0                	or     %edx,%eax
  802296:	89 fa                	mov    %edi,%edx
  802298:	83 c4 14             	add    $0x14,%esp
  80229b:	5e                   	pop    %esi
  80229c:	5f                   	pop    %edi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    
  80229f:	90                   	nop
  8022a0:	39 d7                	cmp    %edx,%edi
  8022a2:	75 da                	jne    80227e <__umoddi3+0x10e>
  8022a4:	8b 14 24             	mov    (%esp),%edx
  8022a7:	89 c1                	mov    %eax,%ecx
  8022a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8022ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8022b1:	eb cb                	jmp    80227e <__umoddi3+0x10e>
  8022b3:	90                   	nop
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8022bc:	0f 82 0f ff ff ff    	jb     8021d1 <__umoddi3+0x61>
  8022c2:	e9 1a ff ff ff       	jmp    8021e1 <__umoddi3+0x71>
