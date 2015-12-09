
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 e8 01 00 00       	call   800219 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800043:	00 
  800044:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  80004b:	e8 71 1b 00 00       	call   801bc1 <open>
  800050:	89 c3                	mov    %eax,%ebx
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("open motd: %e", fd);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 25 27 80 	movl   $0x802725,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  800071:	e8 ff 01 00 00       	call   800275 <_panic>
	seek(fd, 0);
  800076:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007d:	00 
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 f9 17 00 00       	call   80187f <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800086:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800095:	00 
  800096:	89 1c 24             	mov    %ebx,(%esp)
  800099:	e8 09 17 00 00       	call   8017a7 <readn>
  80009e:	89 c7                	mov    %eax,%edi
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	7f 20                	jg     8000c4 <umain+0x91>
		panic("readn: %e", n);
  8000a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a8:	c7 44 24 08 48 27 80 	movl   $0x802748,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b7:	00 
  8000b8:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  8000bf:	e8 b1 01 00 00       	call   800275 <_panic>

	if ((r = fork()) < 0)
  8000c4:	e8 0c 11 00 00       	call   8011d5 <fork>
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	79 20                	jns    8000ef <umain+0xbc>
		panic("fork: %e", r);
  8000cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d3:	c7 44 24 08 52 27 80 	movl   $0x802752,0x8(%esp)
  8000da:	00 
  8000db:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e2:	00 
  8000e3:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  8000ea:	e8 86 01 00 00       	call   800275 <_panic>
	if (r == 0) {
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	0f 85 bd 00 00 00    	jne    8001b4 <umain+0x181>
		seek(fd, 0);
  8000f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000fe:	00 
  8000ff:	89 1c 24             	mov    %ebx,(%esp)
  800102:	e8 78 17 00 00       	call   80187f <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800107:	c7 04 24 90 27 80 00 	movl   $0x802790,(%esp)
  80010e:	e8 5b 02 00 00       	call   80036e <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800113:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800122:	00 
  800123:	89 1c 24             	mov    %ebx,(%esp)
  800126:	e8 7c 16 00 00       	call   8017a7 <readn>
  80012b:	39 f8                	cmp    %edi,%eax
  80012d:	74 24                	je     800153 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800137:	c7 44 24 08 d4 27 80 	movl   $0x8027d4,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  80014e:	e8 22 01 00 00       	call   800275 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800166:	e8 a2 0a 00 00       	call   800c0d <memcmp>
  80016b:	85 c0                	test   %eax,%eax
  80016d:	74 1c                	je     80018b <umain+0x158>
			panic("read in parent got different bytes from read in child");
  80016f:	c7 44 24 08 00 28 80 	movl   $0x802800,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  800186:	e8 ea 00 00 00       	call   800275 <_panic>
		cprintf("read in child succeeded\n");
  80018b:	c7 04 24 5b 27 80 00 	movl   $0x80275b,(%esp)
  800192:	e8 d7 01 00 00       	call   80036e <cprintf>
		seek(fd, 0);
  800197:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019e:	00 
  80019f:	89 1c 24             	mov    %ebx,(%esp)
  8001a2:	e8 d8 16 00 00       	call   80187f <seek>
		close(fd);
  8001a7:	89 1c 24             	mov    %ebx,(%esp)
  8001aa:	e8 03 14 00 00       	call   8015b2 <close>
		exit();
  8001af:	e8 ad 00 00 00       	call   800261 <exit>
	}
	wait(r);
  8001b4:	89 34 24             	mov    %esi,(%esp)
  8001b7:	e8 22 1e 00 00       	call   801fde <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cb:	00 
  8001cc:	89 1c 24             	mov    %ebx,(%esp)
  8001cf:	e8 d3 15 00 00       	call   8017a7 <readn>
  8001d4:	39 f8                	cmp    %edi,%eax
  8001d6:	74 24                	je     8001fc <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e0:	c7 44 24 08 38 28 80 	movl   $0x802838,0x8(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  8001f7:	e8 79 00 00 00       	call   800275 <_panic>
	cprintf("read in parent succeeded\n");
  8001fc:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  800203:	e8 66 01 00 00       	call   80036e <cprintf>
	close(fd);
  800208:	89 1c 24             	mov    %ebx,(%esp)
  80020b:	e8 a2 13 00 00       	call   8015b2 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800210:	cc                   	int3   

	breakpoint();
}
  800211:	83 c4 2c             	add    $0x2c,%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 10             	sub    $0x10,%esp
  800221:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800224:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800227:	e8 99 0b 00 00       	call   800dc5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80022c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800231:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800234:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800239:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023e:	85 db                	test   %ebx,%ebx
  800240:	7e 07                	jle    800249 <libmain+0x30>
		binaryname = argv[0];
  800242:	8b 06                	mov    (%esi),%eax
  800244:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800249:	89 74 24 04          	mov    %esi,0x4(%esp)
  80024d:	89 1c 24             	mov    %ebx,(%esp)
  800250:	e8 de fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800255:	e8 07 00 00 00       	call   800261 <exit>
}
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800267:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80026e:	e8 00 0b 00 00       	call   800d73 <sys_env_destroy>
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80027d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800280:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800286:	e8 3a 0b 00 00       	call   800dc5 <sys_getenvid>
  80028b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800292:	8b 55 08             	mov    0x8(%ebp),%edx
  800295:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800299:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	c7 04 24 68 28 80 00 	movl   $0x802868,(%esp)
  8002a8:	e8 c1 00 00 00       	call   80036e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 51 00 00 00       	call   80030d <vcprintf>
	cprintf("\n");
  8002bc:	c7 04 24 72 27 80 00 	movl   $0x802772,(%esp)
  8002c3:	e8 a6 00 00 00       	call   80036e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c8:	cc                   	int3   
  8002c9:	eb fd                	jmp    8002c8 <_panic+0x53>

008002cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 14             	sub    $0x14,%esp
  8002d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002d5:	8b 13                	mov    (%ebx),%edx
  8002d7:	8d 42 01             	lea    0x1(%edx),%eax
  8002da:	89 03                	mov    %eax,(%ebx)
  8002dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002e3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e8:	75 19                	jne    800303 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ea:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002f1:	00 
  8002f2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	e8 39 0a 00 00       	call   800d36 <sys_cputs>
		b->idx = 0;
  8002fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800303:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800307:	83 c4 14             	add    $0x14,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800316:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80031d:	00 00 00 
	b.cnt = 0;
  800320:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800327:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80033e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800342:	c7 04 24 cb 02 80 00 	movl   $0x8002cb,(%esp)
  800349:	e8 76 01 00 00       	call   8004c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	e8 d0 09 00 00       	call   800d36 <sys_cputs>

	return b.cnt;
}
  800366:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800374:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	e8 87 ff ff ff       	call   80030d <vcprintf>
	va_end(ap);

	return cnt;
}
  800386:	c9                   	leave  
  800387:	c3                   	ret    
  800388:	66 90                	xchg   %ax,%ax
  80038a:	66 90                	xchg   %ax,%ax
  80038c:	66 90                	xchg   %ax,%ax
  80038e:	66 90                	xchg   %ax,%ax

00800390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	89 d7                	mov    %edx,%edi
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a7:	89 c3                	mov    %eax,%ebx
  8003a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8003af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003bd:	39 d9                	cmp    %ebx,%ecx
  8003bf:	72 05                	jb     8003c6 <printnum+0x36>
  8003c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003c4:	77 69                	ja     80042f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003cd:	83 ee 01             	sub    $0x1,%esi
  8003d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8003e0:	89 c3                	mov    %eax,%ebx
  8003e2:	89 d6                	mov    %edx,%esi
  8003e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8003ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 7c 20 00 00       	call   802480 <__udivdi3>
  800404:	89 d9                	mov    %ebx,%ecx
  800406:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80040a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80040e:	89 04 24             	mov    %eax,(%esp)
  800411:	89 54 24 04          	mov    %edx,0x4(%esp)
  800415:	89 fa                	mov    %edi,%edx
  800417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041a:	e8 71 ff ff ff       	call   800390 <printnum>
  80041f:	eb 1b                	jmp    80043c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800421:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800425:	8b 45 18             	mov    0x18(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff d3                	call   *%ebx
  80042d:	eb 03                	jmp    800432 <printnum+0xa2>
  80042f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800432:	83 ee 01             	sub    $0x1,%esi
  800435:	85 f6                	test   %esi,%esi
  800437:	7f e8                	jg     800421 <printnum+0x91>
  800439:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80043c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800440:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800444:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800447:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	89 04 24             	mov    %eax,(%esp)
  800458:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045f:	e8 4c 21 00 00       	call   8025b0 <__umoddi3>
  800464:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800468:	0f be 80 8b 28 80 00 	movsbl 0x80288b(%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800475:	ff d0                	call   *%eax
}
  800477:	83 c4 3c             	add    $0x3c,%esp
  80047a:	5b                   	pop    %ebx
  80047b:	5e                   	pop    %esi
  80047c:	5f                   	pop    %edi
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800485:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800489:	8b 10                	mov    (%eax),%edx
  80048b:	3b 50 04             	cmp    0x4(%eax),%edx
  80048e:	73 0a                	jae    80049a <sprintputch+0x1b>
		*b->buf++ = ch;
  800490:	8d 4a 01             	lea    0x1(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	88 02                	mov    %al,(%edx)
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ba:	89 04 24             	mov    %eax,(%esp)
  8004bd:	e8 02 00 00 00       	call   8004c4 <vprintfmt>
	va_end(ap);
}
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
  8004ca:	83 ec 3c             	sub    $0x3c,%esp
  8004cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004d6:	eb 11                	jmp    8004e9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	0f 84 48 04 00 00    	je     800928 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8004e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	83 f8 25             	cmp    $0x25,%eax
  8004f3:	75 e3                	jne    8004d8 <vprintfmt+0x14>
  8004f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800507:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800513:	eb 1f                	jmp    800534 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800518:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80051c:	eb 16                	jmp    800534 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800521:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800525:	eb 0d                	jmp    800534 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800527:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8d 47 01             	lea    0x1(%edi),%eax
  800537:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053a:	0f b6 17             	movzbl (%edi),%edx
  80053d:	0f b6 c2             	movzbl %dl,%eax
  800540:	83 ea 23             	sub    $0x23,%edx
  800543:	80 fa 55             	cmp    $0x55,%dl
  800546:	0f 87 bf 03 00 00    	ja     80090b <vprintfmt+0x447>
  80054c:	0f b6 d2             	movzbl %dl,%edx
  80054f:	ff 24 95 c0 29 80 00 	jmp    *0x8029c0(,%edx,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800561:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800564:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800568:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80056b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80056e:	83 f9 09             	cmp    $0x9,%ecx
  800571:	77 3c                	ja     8005af <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800573:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800576:	eb e9                	jmp    800561 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 04             	lea    0x4(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058c:	eb 27                	jmp    8005b5 <vprintfmt+0xf1>
  80058e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	0f 49 c2             	cmovns %edx,%eax
  80059b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	eb 91                	jmp    800534 <vprintfmt+0x70>
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ad:	eb 85                	jmp    800534 <vprintfmt+0x70>
  8005af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b9:	0f 89 75 ff ff ff    	jns    800534 <vprintfmt+0x70>
  8005bf:	e9 63 ff ff ff       	jmp    800527 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ca:	e9 65 ff ff ff       	jmp    800534 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e4:	e9 00 ff ff ff       	jmp    8004e9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ec:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	99                   	cltd   
  8005f3:	31 d0                	xor    %edx,%eax
  8005f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f7:	83 f8 0f             	cmp    $0xf,%eax
  8005fa:	7f 0b                	jg     800607 <vprintfmt+0x143>
  8005fc:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	75 20                	jne    800627 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800607:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060b:	c7 44 24 08 a3 28 80 	movl   $0x8028a3,0x8(%esp)
  800612:	00 
  800613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800617:	89 34 24             	mov    %esi,(%esp)
  80061a:	e8 7d fe ff ff       	call   80049c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800622:	e9 c2 fe ff ff       	jmp    8004e9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800627:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062b:	c7 44 24 08 3e 2e 80 	movl   $0x802e3e,0x8(%esp)
  800632:	00 
  800633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	e8 5d fe ff ff       	call   80049c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fe ff ff       	jmp    8004e9 <vprintfmt+0x25>
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80064d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800650:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 9c 28 80 00       	mov    $0x80289c,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800667:	0f 84 92 00 00 00    	je     8006ff <vprintfmt+0x23b>
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	0f 8e 98 00 00 00    	jle    80070d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800675:	89 54 24 04          	mov    %edx,0x4(%esp)
  800679:	89 3c 24             	mov    %edi,(%esp)
  80067c:	e8 47 03 00 00       	call   8009c8 <strnlen>
  800681:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800684:	29 c1                	sub    %eax,%ecx
  800686:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800689:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800690:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800693:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	83 ef 01             	sub    $0x1,%edi
  8006a6:	85 ff                	test   %edi,%edi
  8006a8:	7f ed                	jg     800697 <vprintfmt+0x1d3>
  8006aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	0f 49 c1             	cmovns %ecx,%eax
  8006ba:	29 c1                	sub    %eax,%ecx
  8006bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c5:	89 cb                	mov    %ecx,%ebx
  8006c7:	eb 50                	jmp    800719 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006cd:	74 1e                	je     8006ed <vprintfmt+0x229>
  8006cf:	0f be d2             	movsbl %dl,%edx
  8006d2:	83 ea 20             	sub    $0x20,%edx
  8006d5:	83 fa 5e             	cmp    $0x5e,%edx
  8006d8:	76 13                	jbe    8006ed <vprintfmt+0x229>
					putch('?', putdat);
  8006da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e8:	ff 55 08             	call   *0x8(%ebp)
  8006eb:	eb 0d                	jmp    8006fa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8006ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fa:	83 eb 01             	sub    $0x1,%ebx
  8006fd:	eb 1a                	jmp    800719 <vprintfmt+0x255>
  8006ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800702:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800705:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800708:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070b:	eb 0c                	jmp    800719 <vprintfmt+0x255>
  80070d:	89 75 08             	mov    %esi,0x8(%ebp)
  800710:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800713:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800716:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800719:	83 c7 01             	add    $0x1,%edi
  80071c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800720:	0f be c2             	movsbl %dl,%eax
  800723:	85 c0                	test   %eax,%eax
  800725:	74 25                	je     80074c <vprintfmt+0x288>
  800727:	85 f6                	test   %esi,%esi
  800729:	78 9e                	js     8006c9 <vprintfmt+0x205>
  80072b:	83 ee 01             	sub    $0x1,%esi
  80072e:	79 99                	jns    8006c9 <vprintfmt+0x205>
  800730:	89 df                	mov    %ebx,%edi
  800732:	8b 75 08             	mov    0x8(%ebp),%esi
  800735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800738:	eb 1a                	jmp    800754 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800745:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800747:	83 ef 01             	sub    $0x1,%edi
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x290>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e2                	jg     80073a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 89 fd ff ff       	jmp    8004e9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 f9 01             	cmp    $0x1,%ecx
  800763:	7e 19                	jle    80077e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 50 04             	mov    0x4(%eax),%edx
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800770:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8d 40 08             	lea    0x8(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
  80077c:	eb 38                	jmp    8007b6 <vprintfmt+0x2f2>
	else if (lflag)
  80077e:	85 c9                	test   %ecx,%ecx
  800780:	74 1b                	je     80079d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 00                	mov    (%eax),%eax
  800787:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078a:	89 c1                	mov    %eax,%ecx
  80078c:	c1 f9 1f             	sar    $0x1f,%ecx
  80078f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 40 04             	lea    0x4(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
  80079b:	eb 19                	jmp    8007b6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 40 04             	lea    0x4(%eax),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c5:	0f 89 04 01 00 00    	jns    8008cf <vprintfmt+0x40b>
				putch('-', putdat);
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007de:	f7 da                	neg    %edx
  8007e0:	83 d1 00             	adc    $0x0,%ecx
  8007e3:	f7 d9                	neg    %ecx
  8007e5:	e9 e5 00 00 00       	jmp    8008cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ea:	83 f9 01             	cmp    $0x1,%ecx
  8007ed:	7e 10                	jle    8007ff <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f7:	8d 40 08             	lea    0x8(%eax),%eax
  8007fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fd:	eb 26                	jmp    800825 <vprintfmt+0x361>
	else if (lflag)
  8007ff:	85 c9                	test   %ecx,%ecx
  800801:	74 12                	je     800815 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 10                	mov    (%eax),%edx
  800808:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080d:	8d 40 04             	lea    0x4(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
  800813:	eb 10                	jmp    800825 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081f:	8d 40 04             	lea    0x4(%eax),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800825:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80082a:	e9 a0 00 00 00       	jmp    8008cf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80082f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800833:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80083a:	ff d6                	call   *%esi
			putch('X', putdat);
  80083c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800840:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800847:	ff d6                	call   *%esi
			putch('X', putdat);
  800849:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800854:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800859:	e9 8b fc ff ff       	jmp    8004e9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80085e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800862:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800869:	ff d6                	call   *%esi
			putch('x', putdat);
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800876:	ff d6                	call   *%esi
			num = (unsigned long long)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800888:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80088d:	eb 40                	jmp    8008cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80088f:	83 f9 01             	cmp    $0x1,%ecx
  800892:	7e 10                	jle    8008a4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	8b 48 04             	mov    0x4(%eax),%ecx
  80089c:	8d 40 08             	lea    0x8(%eax),%eax
  80089f:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a2:	eb 26                	jmp    8008ca <vprintfmt+0x406>
	else if (lflag)
  8008a4:	85 c9                	test   %ecx,%ecx
  8008a6:	74 12                	je     8008ba <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 10                	mov    (%eax),%edx
  8008ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b2:	8d 40 04             	lea    0x4(%eax),%eax
  8008b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b8:	eb 10                	jmp    8008ca <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8b 10                	mov    (%eax),%edx
  8008bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c4:	8d 40 04             	lea    0x4(%eax),%eax
  8008c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ca:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8008e2:	89 14 24             	mov    %edx,(%esp)
  8008e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e9:	89 da                	mov    %ebx,%edx
  8008eb:	89 f0                	mov    %esi,%eax
  8008ed:	e8 9e fa ff ff       	call   800390 <printnum>
			break;
  8008f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f5:	e9 ef fb ff ff       	jmp    8004e9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800906:	e9 de fb ff ff       	jmp    8004e9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800916:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800918:	eb 03                	jmp    80091d <vprintfmt+0x459>
  80091a:	83 ef 01             	sub    $0x1,%edi
  80091d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800921:	75 f7                	jne    80091a <vprintfmt+0x456>
  800923:	e9 c1 fb ff ff       	jmp    8004e9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800928:	83 c4 3c             	add    $0x3c,%esp
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 28             	sub    $0x28,%esp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800943:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	74 30                	je     800981 <vsnprintf+0x51>
  800951:	85 d2                	test   %edx,%edx
  800953:	7e 2c                	jle    800981 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095c:	8b 45 10             	mov    0x10(%ebp),%eax
  80095f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800963:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	c7 04 24 7f 04 80 00 	movl   $0x80047f,(%esp)
  800971:	e8 4e fb ff ff       	call   8004c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800976:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800979:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097f:	eb 05                	jmp    800986 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800981:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800991:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800995:	8b 45 10             	mov    0x10(%ebp),%eax
  800998:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	e8 82 ff ff ff       	call   800930 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	eb 03                	jmp    8009c0 <strlen+0x10>
		n++;
  8009bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c4:	75 f7                	jne    8009bd <strlen+0xd>
		n++;
	return n;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	eb 03                	jmp    8009db <strnlen+0x13>
		n++;
  8009d8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009db:	39 d0                	cmp    %edx,%eax
  8009dd:	74 06                	je     8009e5 <strnlen+0x1d>
  8009df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009e3:	75 f3                	jne    8009d8 <strnlen+0x10>
		n++;
	return n;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f1:	89 c2                	mov    %eax,%edx
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a00:	84 db                	test   %bl,%bl
  800a02:	75 ef                	jne    8009f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a04:	5b                   	pop    %ebx
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a11:	89 1c 24             	mov    %ebx,(%esp)
  800a14:	e8 97 ff ff ff       	call   8009b0 <strlen>
	strcpy(dst + len, src);
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a20:	01 d8                	add    %ebx,%eax
  800a22:	89 04 24             	mov    %eax,(%esp)
  800a25:	e8 bd ff ff ff       	call   8009e7 <strcpy>
	return dst;
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	83 c4 08             	add    $0x8,%esp
  800a2f:	5b                   	pop    %ebx
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3d:	89 f3                	mov    %esi,%ebx
  800a3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a42:	89 f2                	mov    %esi,%edx
  800a44:	eb 0f                	jmp    800a55 <strncpy+0x23>
		*dst++ = *src;
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a55:	39 da                	cmp    %ebx,%edx
  800a57:	75 ed                	jne    800a46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a59:	89 f0                	mov    %esi,%eax
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 75 08             	mov    0x8(%ebp),%esi
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a6d:	89 f0                	mov    %esi,%eax
  800a6f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	75 0b                	jne    800a82 <strlcpy+0x23>
  800a77:	eb 1d                	jmp    800a96 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a82:	39 d8                	cmp    %ebx,%eax
  800a84:	74 0b                	je     800a91 <strlcpy+0x32>
  800a86:	0f b6 0a             	movzbl (%edx),%ecx
  800a89:	84 c9                	test   %cl,%cl
  800a8b:	75 ec                	jne    800a79 <strlcpy+0x1a>
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	eb 02                	jmp    800a93 <strlcpy+0x34>
  800a91:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a93:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a96:	29 f0                	sub    %esi,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa5:	eb 06                	jmp    800aad <strcmp+0x11>
		p++, q++;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aad:	0f b6 01             	movzbl (%ecx),%eax
  800ab0:	84 c0                	test   %al,%al
  800ab2:	74 04                	je     800ab8 <strcmp+0x1c>
  800ab4:	3a 02                	cmp    (%edx),%al
  800ab6:	74 ef                	je     800aa7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab8:	0f b6 c0             	movzbl %al,%eax
  800abb:	0f b6 12             	movzbl (%edx),%edx
  800abe:	29 d0                	sub    %edx,%eax
}
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad1:	eb 06                	jmp    800ad9 <strncmp+0x17>
		n--, p++, q++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad9:	39 d8                	cmp    %ebx,%eax
  800adb:	74 15                	je     800af2 <strncmp+0x30>
  800add:	0f b6 08             	movzbl (%eax),%ecx
  800ae0:	84 c9                	test   %cl,%cl
  800ae2:	74 04                	je     800ae8 <strncmp+0x26>
  800ae4:	3a 0a                	cmp    (%edx),%cl
  800ae6:	74 eb                	je     800ad3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae8:	0f b6 00             	movzbl (%eax),%eax
  800aeb:	0f b6 12             	movzbl (%edx),%edx
  800aee:	29 d0                	sub    %edx,%eax
  800af0:	eb 05                	jmp    800af7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b04:	eb 07                	jmp    800b0d <strchr+0x13>
		if (*s == c)
  800b06:	38 ca                	cmp    %cl,%dl
  800b08:	74 0f                	je     800b19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	84 d2                	test   %dl,%dl
  800b12:	75 f2                	jne    800b06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	eb 07                	jmp    800b2e <strfind+0x13>
		if (*s == c)
  800b27:	38 ca                	cmp    %cl,%dl
  800b29:	74 0a                	je     800b35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b2b:	83 c0 01             	add    $0x1,%eax
  800b2e:	0f b6 10             	movzbl (%eax),%edx
  800b31:	84 d2                	test   %dl,%dl
  800b33:	75 f2                	jne    800b27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b43:	85 c9                	test   %ecx,%ecx
  800b45:	74 36                	je     800b7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4d:	75 28                	jne    800b77 <memset+0x40>
  800b4f:	f6 c1 03             	test   $0x3,%cl
  800b52:	75 23                	jne    800b77 <memset+0x40>
		c &= 0xFF;
  800b54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	c1 e3 08             	shl    $0x8,%ebx
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	c1 e6 18             	shl    $0x18,%esi
  800b62:	89 d0                	mov    %edx,%eax
  800b64:	c1 e0 10             	shl    $0x10,%eax
  800b67:	09 f0                	or     %esi,%eax
  800b69:	09 c2                	or     %eax,%edx
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b72:	fc                   	cld    
  800b73:	f3 ab                	rep stos %eax,%es:(%edi)
  800b75:	eb 06                	jmp    800b7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	fc                   	cld    
  800b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b92:	39 c6                	cmp    %eax,%esi
  800b94:	73 35                	jae    800bcb <memmove+0x47>
  800b96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b99:	39 d0                	cmp    %edx,%eax
  800b9b:	73 2e                	jae    800bcb <memmove+0x47>
		s += n;
		d += n;
  800b9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800baa:	75 13                	jne    800bbf <memmove+0x3b>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 0e                	jne    800bbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bb1:	83 ef 04             	sub    $0x4,%edi
  800bb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bba:	fd                   	std    
  800bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbd:	eb 09                	jmp    800bc8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bbf:	83 ef 01             	sub    $0x1,%edi
  800bc2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc5:	fd                   	std    
  800bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc8:	fc                   	cld    
  800bc9:	eb 1d                	jmp    800be8 <memmove+0x64>
  800bcb:	89 f2                	mov    %esi,%edx
  800bcd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcf:	f6 c2 03             	test   $0x3,%dl
  800bd2:	75 0f                	jne    800be3 <memmove+0x5f>
  800bd4:	f6 c1 03             	test   $0x3,%cl
  800bd7:	75 0a                	jne    800be3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bd9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bdc:	89 c7                	mov    %eax,%edi
  800bde:	fc                   	cld    
  800bdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be1:	eb 05                	jmp    800be8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be3:	89 c7                	mov    %eax,%edi
  800be5:	fc                   	cld    
  800be6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	89 04 24             	mov    %eax,(%esp)
  800c06:	e8 79 ff ff ff       	call   800b84 <memmove>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	89 d6                	mov    %edx,%esi
  800c1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1d:	eb 1a                	jmp    800c39 <memcmp+0x2c>
		if (*s1 != *s2)
  800c1f:	0f b6 02             	movzbl (%edx),%eax
  800c22:	0f b6 19             	movzbl (%ecx),%ebx
  800c25:	38 d8                	cmp    %bl,%al
  800c27:	74 0a                	je     800c33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c29:	0f b6 c0             	movzbl %al,%eax
  800c2c:	0f b6 db             	movzbl %bl,%ebx
  800c2f:	29 d8                	sub    %ebx,%eax
  800c31:	eb 0f                	jmp    800c42 <memcmp+0x35>
		s1++, s2++;
  800c33:	83 c2 01             	add    $0x1,%edx
  800c36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c39:	39 f2                	cmp    %esi,%edx
  800c3b:	75 e2                	jne    800c1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c54:	eb 07                	jmp    800c5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c56:	38 08                	cmp    %cl,(%eax)
  800c58:	74 07                	je     800c61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	39 d0                	cmp    %edx,%eax
  800c5f:	72 f5                	jb     800c56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6f:	eb 03                	jmp    800c74 <strtol+0x11>
		s++;
  800c71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c74:	0f b6 0a             	movzbl (%edx),%ecx
  800c77:	80 f9 09             	cmp    $0x9,%cl
  800c7a:	74 f5                	je     800c71 <strtol+0xe>
  800c7c:	80 f9 20             	cmp    $0x20,%cl
  800c7f:	74 f0                	je     800c71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c81:	80 f9 2b             	cmp    $0x2b,%cl
  800c84:	75 0a                	jne    800c90 <strtol+0x2d>
		s++;
  800c86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c89:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8e:	eb 11                	jmp    800ca1 <strtol+0x3e>
  800c90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c95:	80 f9 2d             	cmp    $0x2d,%cl
  800c98:	75 07                	jne    800ca1 <strtol+0x3e>
		s++, neg = 1;
  800c9a:	8d 52 01             	lea    0x1(%edx),%edx
  800c9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800ca6:	75 15                	jne    800cbd <strtol+0x5a>
  800ca8:	80 3a 30             	cmpb   $0x30,(%edx)
  800cab:	75 10                	jne    800cbd <strtol+0x5a>
  800cad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb1:	75 0a                	jne    800cbd <strtol+0x5a>
		s += 2, base = 16;
  800cb3:	83 c2 02             	add    $0x2,%edx
  800cb6:	b8 10 00 00 00       	mov    $0x10,%eax
  800cbb:	eb 10                	jmp    800ccd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	75 0c                	jne    800ccd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc6:	75 05                	jne    800ccd <strtol+0x6a>
		s++, base = 8;
  800cc8:	83 c2 01             	add    $0x1,%edx
  800ccb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd5:	0f b6 0a             	movzbl (%edx),%ecx
  800cd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cdb:	89 f0                	mov    %esi,%eax
  800cdd:	3c 09                	cmp    $0x9,%al
  800cdf:	77 08                	ja     800ce9 <strtol+0x86>
			dig = *s - '0';
  800ce1:	0f be c9             	movsbl %cl,%ecx
  800ce4:	83 e9 30             	sub    $0x30,%ecx
  800ce7:	eb 20                	jmp    800d09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ce9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800cec:	89 f0                	mov    %esi,%eax
  800cee:	3c 19                	cmp    $0x19,%al
  800cf0:	77 08                	ja     800cfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800cf2:	0f be c9             	movsbl %cl,%ecx
  800cf5:	83 e9 57             	sub    $0x57,%ecx
  800cf8:	eb 0f                	jmp    800d09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	3c 19                	cmp    $0x19,%al
  800d01:	77 16                	ja     800d19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d03:	0f be c9             	movsbl %cl,%ecx
  800d06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d0c:	7d 0f                	jge    800d1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800d0e:	83 c2 01             	add    $0x1,%edx
  800d11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d17:	eb bc                	jmp    800cd5 <strtol+0x72>
  800d19:	89 d8                	mov    %ebx,%eax
  800d1b:	eb 02                	jmp    800d1f <strtol+0xbc>
  800d1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d23:	74 05                	je     800d2a <strtol+0xc7>
		*endptr = (char *) s;
  800d25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d2a:	f7 d8                	neg    %eax
  800d2c:	85 ff                	test   %edi,%edi
  800d2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	89 c7                	mov    %eax,%edi
  800d4b:	89 c6                	mov    %eax,%esi
  800d4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 03 00 00 00       	mov    $0x3,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 28                	jle    800dbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800da0:	00 
  800da1:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800da8:	00 
  800da9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db0:	00 
  800db1:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800db8:	e8 b8 f4 ff ff       	call   800275 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dbd:	83 c4 2c             	add    $0x2c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_yield>:

void
sys_yield(void)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	ba 00 00 00 00       	mov    $0x0,%edx
  800def:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df4:	89 d1                	mov    %edx,%ecx
  800df6:	89 d3                	mov    %edx,%ebx
  800df8:	89 d7                	mov    %edx,%edi
  800dfa:	89 d6                	mov    %edx,%esi
  800dfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 04 00 00 00       	mov    $0x4,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	89 f7                	mov    %esi,%edi
  800e21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 28                	jle    800e4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e32:	00 
  800e33:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e4a:	e8 26 f4 ff ff       	call   800275 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4f:	83 c4 2c             	add    $0x2c,%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	b8 05 00 00 00       	mov    $0x5,%eax
  800e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e71:	8b 75 18             	mov    0x18(%ebp),%esi
  800e74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7e 28                	jle    800ea2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e85:	00 
  800e86:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e95:	00 
  800e96:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e9d:	e8 d3 f3 ff ff       	call   800275 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea2:	83 c4 2c             	add    $0x2c,%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	89 df                	mov    %ebx,%edi
  800ec5:	89 de                	mov    %ebx,%esi
  800ec7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	7e 28                	jle    800ef5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee8:	00 
  800ee9:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800ef0:	e8 80 f3 ff ff       	call   800275 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ef5:	83 c4 2c             	add    $0x2c,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	89 df                	mov    %ebx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	7e 28                	jle    800f48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3b:	00 
  800f3c:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f43:	e8 2d f3 ff ff       	call   800275 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f48:	83 c4 2c             	add    $0x2c,%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
  800f69:	89 df                	mov    %ebx,%edi
  800f6b:	89 de                	mov    %ebx,%esi
  800f6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	7e 28                	jle    800f9b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f86:	00 
  800f87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8e:	00 
  800f8f:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f96:	e8 da f2 ff ff       	call   800275 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f9b:	83 c4 2c             	add    $0x2c,%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	89 df                	mov    %ebx,%edi
  800fbe:	89 de                	mov    %ebx,%esi
  800fc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	7e 28                	jle    800fee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800fe9:	e8 87 f2 ff ff       	call   800275 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fee:	83 c4 2c             	add    $0x2c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	be 00 00 00 00       	mov    $0x0,%esi
  801001:	b8 0c 00 00 00       	mov    $0xc,%eax
  801006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801012:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801022:	b9 00 00 00 00       	mov    $0x0,%ecx
  801027:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	89 cb                	mov    %ecx,%ebx
  801031:	89 cf                	mov    %ecx,%edi
  801033:	89 ce                	mov    %ecx,%esi
  801035:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	7e 28                	jle    801063 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801046:	00 
  801047:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  80105e:	e8 12 f2 ff ff       	call   800275 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801063:	83 c4 2c             	add    $0x2c,%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 20             	sub    $0x20,%esp
  801073:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801076:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801078:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80107c:	75 3f                	jne    8010bd <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80107e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801082:	c7 04 24 aa 2b 80 00 	movl   $0x802baa,(%esp)
  801089:	e8 e0 f2 ff ff       	call   80036e <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80108e:	8b 43 28             	mov    0x28(%ebx),%eax
  801091:	89 44 24 04          	mov    %eax,0x4(%esp)
  801095:	c7 04 24 ba 2b 80 00 	movl   $0x802bba,(%esp)
  80109c:	e8 cd f2 ff ff       	call   80036e <cprintf>

		 panic("The err is not right of the pgfault\n ");
  8010a1:	c7 44 24 08 00 2c 80 	movl   $0x802c00,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  8010b8:	e8 b8 f1 ff ff       	call   800275 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  8010bd:	89 f0                	mov    %esi,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  8010c9:	f6 c4 08             	test   $0x8,%ah
  8010cc:	75 1c                	jne    8010ea <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  8010ce:	c7 44 24 08 28 2c 80 	movl   $0x802c28,0x8(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010dd:	00 
  8010de:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  8010e5:	e8 8b f1 ff ff       	call   800275 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  8010ea:	e8 d6 fc ff ff       	call   800dc5 <sys_getenvid>
  8010ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fe:	00 
  8010ff:	89 04 24             	mov    %eax,(%esp)
  801102:	e8 fc fc ff ff       	call   800e03 <sys_page_alloc>
  801107:	85 c0                	test   %eax,%eax
  801109:	79 1c                	jns    801127 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  80110b:	c7 44 24 08 48 2c 80 	movl   $0x802c48,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  801122:	e8 4e f1 ff ff       	call   800275 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801127:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80112d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801134:	00 
  801135:	89 74 24 04          	mov    %esi,0x4(%esp)
  801139:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801140:	e8 a7 fa ff ff       	call   800bec <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801145:	e8 7b fc ff ff       	call   800dc5 <sys_getenvid>
  80114a:	89 c3                	mov    %eax,%ebx
  80114c:	e8 74 fc ff ff       	call   800dc5 <sys_getenvid>
  801151:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801158:	00 
  801159:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80115d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801161:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801168:	00 
  801169:	89 04 24             	mov    %eax,(%esp)
  80116c:	e8 e6 fc ff ff       	call   800e57 <sys_page_map>
  801171:	85 c0                	test   %eax,%eax
  801173:	79 20                	jns    801195 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801175:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801179:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  801180:	00 
  801181:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  801190:	e8 e0 f0 ff ff       	call   800275 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801195:	e8 2b fc ff ff       	call   800dc5 <sys_getenvid>
  80119a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011a1:	00 
  8011a2:	89 04 24             	mov    %eax,(%esp)
  8011a5:	e8 00 fd ff ff       	call   800eaa <sys_page_unmap>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 20                	jns    8011ce <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8011ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b2:	c7 44 24 08 a0 2c 80 	movl   $0x802ca0,0x8(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8011c1:	00 
  8011c2:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  8011c9:	e8 a7 f0 ff ff       	call   800275 <_panic>
	return;
}
  8011ce:	83 c4 20             	add    $0x20,%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  8011de:	c7 04 24 6b 10 80 00 	movl   $0x80106b,(%esp)
  8011e5:	e8 fc 0f 00 00       	call   8021e6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8011ef:	cd 30                	int    $0x30
  8011f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 20                	jns    80121b <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  8011fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ff:	c7 44 24 08 d4 2c 80 	movl   $0x802cd4,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80120e:	00 
  80120f:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  801216:	e8 5a f0 ff ff       	call   800275 <_panic>
	if(childEid == 0){
  80121b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80121f:	75 1c                	jne    80123d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801221:	e8 9f fb ff ff       	call   800dc5 <sys_getenvid>
  801226:	25 ff 03 00 00       	and    $0x3ff,%eax
  80122b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80122e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801233:	a3 20 44 80 00       	mov    %eax,0x804420
		return childEid;
  801238:	e9 a0 01 00 00       	jmp    8013dd <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80123d:	c7 44 24 04 7c 22 80 	movl   $0x80227c,0x4(%esp)
  801244:	00 
  801245:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	e8 53 fd ff ff       	call   800fa3 <sys_env_set_pgfault_upcall>
  801250:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801252:	85 c0                	test   %eax,%eax
  801254:	79 20                	jns    801276 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125a:	c7 44 24 08 08 2d 80 	movl   $0x802d08,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  801271:	e8 ff ef ff ff       	call   800275 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801276:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	b9 00 00 00 00       	mov    $0x0,%ecx
  801285:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801288:	89 c2                	mov    %eax,%edx
  80128a:	c1 ea 16             	shr    $0x16,%edx
  80128d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801294:	f6 c2 01             	test   $0x1,%dl
  801297:	0f 84 f7 00 00 00    	je     801394 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80129d:	c1 e8 0c             	shr    $0xc,%eax
  8012a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8012a7:	f6 c2 04             	test   $0x4,%dl
  8012aa:	0f 84 e4 00 00 00    	je     801394 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8012b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8012b7:	a8 01                	test   $0x1,%al
  8012b9:	0f 84 d5 00 00 00    	je     801394 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8012bf:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8012c5:	75 20                	jne    8012e7 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8012c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012d6:	ee 
  8012d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012da:	89 04 24             	mov    %eax,(%esp)
  8012dd:	e8 21 fb ff ff       	call   800e03 <sys_page_alloc>
  8012e2:	e9 84 00 00 00       	jmp    80136b <fork+0x196>
  8012e7:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  8012ed:	89 f8                	mov    %edi,%eax
  8012ef:	c1 e8 0c             	shr    $0xc,%eax
  8012f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  8012f9:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  8012fe:	83 f8 01             	cmp    $0x1,%eax
  801301:	19 db                	sbb    %ebx,%ebx
  801303:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801309:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80130f:	e8 b1 fa ff ff       	call   800dc5 <sys_getenvid>
  801314:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801318:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80131f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801323:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801327:	89 04 24             	mov    %eax,(%esp)
  80132a:	e8 28 fb ff ff       	call   800e57 <sys_page_map>
  80132f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801332:	85 c0                	test   %eax,%eax
  801334:	78 35                	js     80136b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801336:	e8 8a fa ff ff       	call   800dc5 <sys_getenvid>
  80133b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80133e:	e8 82 fa ff ff       	call   800dc5 <sys_getenvid>
  801343:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801347:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80134e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	e8 f9 fa ff ff       	call   800e57 <sys_page_map>
  80135e:	85 c0                	test   %eax,%eax
  801360:	bf 00 00 00 00       	mov    $0x0,%edi
  801365:	0f 4f c7             	cmovg  %edi,%eax
  801368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80136b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80136f:	79 23                	jns    801394 <fork+0x1bf>
  801371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801374:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801378:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  80137f:	00 
  801380:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801387:	00 
  801388:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  80138f:	e8 e1 ee ff ff       	call   800275 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801394:	89 f1                	mov    %esi,%ecx
  801396:	89 f0                	mov    %esi,%eax
  801398:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80139e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8013a4:	0f 85 de fe ff ff    	jne    801288 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8013aa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013b1:	00 
  8013b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013b5:	89 04 24             	mov    %eax,(%esp)
  8013b8:	e8 40 fb ff ff       	call   800efd <sys_env_set_status>
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	79 1c                	jns    8013dd <fork+0x208>
		panic("sys_env_set_status");
  8013c1:	c7 44 24 08 d6 2b 80 	movl   $0x802bd6,0x8(%esp)
  8013c8:	00 
  8013c9:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8013d0:	00 
  8013d1:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  8013d8:	e8 98 ee ff ff       	call   800275 <_panic>
	return childEid;
}
  8013dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013e0:	83 c4 2c             	add    $0x2c,%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <sfork>:

// Challenge!
int
sfork(void)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013ee:	c7 44 24 08 e9 2b 80 	movl   $0x802be9,0x8(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8013fd:	00 
  8013fe:	c7 04 24 cb 2b 80 00 	movl   $0x802bcb,(%esp)
  801405:	e8 6b ee ff ff       	call   800275 <_panic>
  80140a:	66 90                	xchg   %ax,%ax
  80140c:	66 90                	xchg   %ax,%ax
  80140e:	66 90                	xchg   %ax,%ax

00801410 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	05 00 00 00 30       	add    $0x30000000,%eax
  80141b:	c1 e8 0c             	shr    $0xc,%eax
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801423:	8b 45 08             	mov    0x8(%ebp),%eax
  801426:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80142b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801430:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801435:	5d                   	pop    %ebp
  801436:	c3                   	ret    

00801437 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 16             	shr    $0x16,%edx
  801447:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	74 11                	je     801464 <fd_alloc+0x2d>
  801453:	89 c2                	mov    %eax,%edx
  801455:	c1 ea 0c             	shr    $0xc,%edx
  801458:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145f:	f6 c2 01             	test   $0x1,%dl
  801462:	75 09                	jne    80146d <fd_alloc+0x36>
			*fd_store = fd;
  801464:	89 01                	mov    %eax,(%ecx)
			return 0;
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	eb 17                	jmp    801484 <fd_alloc+0x4d>
  80146d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801472:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801477:	75 c9                	jne    801442 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801479:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80147f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80148c:	83 f8 1f             	cmp    $0x1f,%eax
  80148f:	77 36                	ja     8014c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801491:	c1 e0 0c             	shl    $0xc,%eax
  801494:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801499:	89 c2                	mov    %eax,%edx
  80149b:	c1 ea 16             	shr    $0x16,%edx
  80149e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a5:	f6 c2 01             	test   $0x1,%dl
  8014a8:	74 24                	je     8014ce <fd_lookup+0x48>
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	c1 ea 0c             	shr    $0xc,%edx
  8014af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b6:	f6 c2 01             	test   $0x1,%dl
  8014b9:	74 1a                	je     8014d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014be:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c5:	eb 13                	jmp    8014da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cc:	eb 0c                	jmp    8014da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb 05                	jmp    8014da <fd_lookup+0x54>
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 18             	sub    $0x18,%esp
  8014e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e5:	ba ec 2d 80 00       	mov    $0x802dec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ea:	eb 13                	jmp    8014ff <dev_lookup+0x23>
  8014ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014ef:	39 08                	cmp    %ecx,(%eax)
  8014f1:	75 0c                	jne    8014ff <dev_lookup+0x23>
			*dev = devtab[i];
  8014f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fd:	eb 30                	jmp    80152f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ff:	8b 02                	mov    (%edx),%eax
  801501:	85 c0                	test   %eax,%eax
  801503:	75 e7                	jne    8014ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801505:	a1 20 44 80 00       	mov    0x804420,%eax
  80150a:	8b 40 48             	mov    0x48(%eax),%eax
  80150d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801511:	89 44 24 04          	mov    %eax,0x4(%esp)
  801515:	c7 04 24 70 2d 80 00 	movl   $0x802d70,(%esp)
  80151c:	e8 4d ee ff ff       	call   80036e <cprintf>
	*dev = 0;
  801521:	8b 45 0c             	mov    0xc(%ebp),%eax
  801524:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80152a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 20             	sub    $0x20,%esp
  801539:	8b 75 08             	mov    0x8(%ebp),%esi
  80153c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80153f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801546:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80154c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80154f:	89 04 24             	mov    %eax,(%esp)
  801552:	e8 2f ff ff ff       	call   801486 <fd_lookup>
  801557:	85 c0                	test   %eax,%eax
  801559:	78 05                	js     801560 <fd_close+0x2f>
	    || fd != fd2)
  80155b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80155e:	74 0c                	je     80156c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801560:	84 db                	test   %bl,%bl
  801562:	ba 00 00 00 00       	mov    $0x0,%edx
  801567:	0f 44 c2             	cmove  %edx,%eax
  80156a:	eb 3f                	jmp    8015ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80156c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 06                	mov    (%esi),%eax
  801575:	89 04 24             	mov    %eax,(%esp)
  801578:	e8 5f ff ff ff       	call   8014dc <dev_lookup>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 16                	js     801599 <fd_close+0x68>
		if (dev->dev_close)
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801589:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80158e:	85 c0                	test   %eax,%eax
  801590:	74 07                	je     801599 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801592:	89 34 24             	mov    %esi,(%esp)
  801595:	ff d0                	call   *%eax
  801597:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80159d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a4:	e8 01 f9 ff ff       	call   800eaa <sys_page_unmap>
	return r;
  8015a9:	89 d8                	mov    %ebx,%eax
}
  8015ab:	83 c4 20             	add    $0x20,%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	e8 bc fe ff ff       	call   801486 <fd_lookup>
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	85 d2                	test   %edx,%edx
  8015ce:	78 13                	js     8015e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8015d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015d7:	00 
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	89 04 24             	mov    %eax,(%esp)
  8015de:	e8 4e ff ff ff       	call   801531 <fd_close>
}
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <close_all>:

void
close_all(void)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015f1:	89 1c 24             	mov    %ebx,(%esp)
  8015f4:	e8 b9 ff ff ff       	call   8015b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f9:	83 c3 01             	add    $0x1,%ebx
  8015fc:	83 fb 20             	cmp    $0x20,%ebx
  8015ff:	75 f0                	jne    8015f1 <close_all+0xc>
		close(i);
}
  801601:	83 c4 14             	add    $0x14,%esp
  801604:	5b                   	pop    %ebx
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801610:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801613:	89 44 24 04          	mov    %eax,0x4(%esp)
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	89 04 24             	mov    %eax,(%esp)
  80161d:	e8 64 fe ff ff       	call   801486 <fd_lookup>
  801622:	89 c2                	mov    %eax,%edx
  801624:	85 d2                	test   %edx,%edx
  801626:	0f 88 e1 00 00 00    	js     80170d <dup+0x106>
		return r;
	close(newfdnum);
  80162c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162f:	89 04 24             	mov    %eax,(%esp)
  801632:	e8 7b ff ff ff       	call   8015b2 <close>

	newfd = INDEX2FD(newfdnum);
  801637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80163a:	c1 e3 0c             	shl    $0xc,%ebx
  80163d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 d2 fd ff ff       	call   801420 <fd2data>
  80164e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801650:	89 1c 24             	mov    %ebx,(%esp)
  801653:	e8 c8 fd ff ff       	call   801420 <fd2data>
  801658:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80165a:	89 f0                	mov    %esi,%eax
  80165c:	c1 e8 16             	shr    $0x16,%eax
  80165f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801666:	a8 01                	test   $0x1,%al
  801668:	74 43                	je     8016ad <dup+0xa6>
  80166a:	89 f0                	mov    %esi,%eax
  80166c:	c1 e8 0c             	shr    $0xc,%eax
  80166f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801676:	f6 c2 01             	test   $0x1,%dl
  801679:	74 32                	je     8016ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80167b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801682:	25 07 0e 00 00       	and    $0xe07,%eax
  801687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80168b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80168f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801696:	00 
  801697:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a2:	e8 b0 f7 ff ff       	call   800e57 <sys_page_map>
  8016a7:	89 c6                	mov    %eax,%esi
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 3e                	js     8016eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b0:	89 c2                	mov    %eax,%edx
  8016b2:	c1 ea 0c             	shr    $0xc,%edx
  8016b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d1:	00 
  8016d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dd:	e8 75 f7 ff ff       	call   800e57 <sys_page_map>
  8016e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8016e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e7:	85 f6                	test   %esi,%esi
  8016e9:	79 22                	jns    80170d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f6:	e8 af f7 ff ff       	call   800eaa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801706:	e8 9f f7 ff ff       	call   800eaa <sys_page_unmap>
	return r;
  80170b:	89 f0                	mov    %esi,%eax
}
  80170d:	83 c4 3c             	add    $0x3c,%esp
  801710:	5b                   	pop    %ebx
  801711:	5e                   	pop    %esi
  801712:	5f                   	pop    %edi
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 24             	sub    $0x24,%esp
  80171c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	89 44 24 04          	mov    %eax,0x4(%esp)
  801726:	89 1c 24             	mov    %ebx,(%esp)
  801729:	e8 58 fd ff ff       	call   801486 <fd_lookup>
  80172e:	89 c2                	mov    %eax,%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	78 6d                	js     8017a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	8b 00                	mov    (%eax),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	e8 94 fd ff ff       	call   8014dc <dev_lookup>
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 55                	js     8017a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	8b 50 08             	mov    0x8(%eax),%edx
  801752:	83 e2 03             	and    $0x3,%edx
  801755:	83 fa 01             	cmp    $0x1,%edx
  801758:	75 23                	jne    80177d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80175a:	a1 20 44 80 00       	mov    0x804420,%eax
  80175f:	8b 40 48             	mov    0x48(%eax),%eax
  801762:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176a:	c7 04 24 b1 2d 80 00 	movl   $0x802db1,(%esp)
  801771:	e8 f8 eb ff ff       	call   80036e <cprintf>
		return -E_INVAL;
  801776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80177b:	eb 24                	jmp    8017a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80177d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801780:	8b 52 08             	mov    0x8(%edx),%edx
  801783:	85 d2                	test   %edx,%edx
  801785:	74 15                	je     80179c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801787:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80178a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80178e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801791:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	ff d2                	call   *%edx
  80179a:	eb 05                	jmp    8017a1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80179c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017a1:	83 c4 24             	add    $0x24,%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	57                   	push   %edi
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 1c             	sub    $0x1c,%esp
  8017b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017bb:	eb 23                	jmp    8017e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	29 d8                	sub    %ebx,%eax
  8017c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c5:	89 d8                	mov    %ebx,%eax
  8017c7:	03 45 0c             	add    0xc(%ebp),%eax
  8017ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ce:	89 3c 24             	mov    %edi,(%esp)
  8017d1:	e8 3f ff ff ff       	call   801715 <read>
		if (m < 0)
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 10                	js     8017ea <readn+0x43>
			return m;
		if (m == 0)
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	74 0a                	je     8017e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017de:	01 c3                	add    %eax,%ebx
  8017e0:	39 f3                	cmp    %esi,%ebx
  8017e2:	72 d9                	jb     8017bd <readn+0x16>
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	eb 02                	jmp    8017ea <readn+0x43>
  8017e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ea:	83 c4 1c             	add    $0x1c,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 24             	sub    $0x24,%esp
  8017f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	89 1c 24             	mov    %ebx,(%esp)
  801806:	e8 7b fc ff ff       	call   801486 <fd_lookup>
  80180b:	89 c2                	mov    %eax,%edx
  80180d:	85 d2                	test   %edx,%edx
  80180f:	78 68                	js     801879 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	89 44 24 04          	mov    %eax,0x4(%esp)
  801818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181b:	8b 00                	mov    (%eax),%eax
  80181d:	89 04 24             	mov    %eax,(%esp)
  801820:	e8 b7 fc ff ff       	call   8014dc <dev_lookup>
  801825:	85 c0                	test   %eax,%eax
  801827:	78 50                	js     801879 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801830:	75 23                	jne    801855 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801832:	a1 20 44 80 00       	mov    0x804420,%eax
  801837:	8b 40 48             	mov    0x48(%eax),%eax
  80183a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	c7 04 24 cd 2d 80 00 	movl   $0x802dcd,(%esp)
  801849:	e8 20 eb ff ff       	call   80036e <cprintf>
		return -E_INVAL;
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801853:	eb 24                	jmp    801879 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801855:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801858:	8b 52 0c             	mov    0xc(%edx),%edx
  80185b:	85 d2                	test   %edx,%edx
  80185d:	74 15                	je     801874 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801862:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801869:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186d:	89 04 24             	mov    %eax,(%esp)
  801870:	ff d2                	call   *%edx
  801872:	eb 05                	jmp    801879 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801874:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801879:	83 c4 24             	add    $0x24,%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <seek>:

int
seek(int fdnum, off_t offset)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801885:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 ef fb ff ff       	call   801486 <fd_lookup>
  801897:	85 c0                	test   %eax,%eax
  801899:	78 0e                	js     8018a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80189b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80189e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 24             	sub    $0x24,%esp
  8018b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	89 1c 24             	mov    %ebx,(%esp)
  8018bf:	e8 c2 fb ff ff       	call   801486 <fd_lookup>
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 d2                	test   %edx,%edx
  8018c8:	78 61                	js     80192b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	8b 00                	mov    (%eax),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 fe fb ff ff       	call   8014dc <dev_lookup>
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 49                	js     80192b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e9:	75 23                	jne    80190e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018eb:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f0:	8b 40 48             	mov    0x48(%eax),%eax
  8018f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fb:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  801902:	e8 67 ea ff ff       	call   80036e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801907:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190c:	eb 1d                	jmp    80192b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80190e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801911:	8b 52 18             	mov    0x18(%edx),%edx
  801914:	85 d2                	test   %edx,%edx
  801916:	74 0e                	je     801926 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	ff d2                	call   *%edx
  801924:	eb 05                	jmp    80192b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801926:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80192b:	83 c4 24             	add    $0x24,%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	53                   	push   %ebx
  801935:	83 ec 24             	sub    $0x24,%esp
  801938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	e8 39 fb ff ff       	call   801486 <fd_lookup>
  80194d:	89 c2                	mov    %eax,%edx
  80194f:	85 d2                	test   %edx,%edx
  801951:	78 52                	js     8019a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195d:	8b 00                	mov    (%eax),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 75 fb ff ff       	call   8014dc <dev_lookup>
  801967:	85 c0                	test   %eax,%eax
  801969:	78 3a                	js     8019a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801972:	74 2c                	je     8019a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801974:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801977:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80197e:	00 00 00 
	stat->st_isdir = 0;
  801981:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801988:	00 00 00 
	stat->st_dev = dev;
  80198b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801991:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801995:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801998:	89 14 24             	mov    %edx,(%esp)
  80199b:	ff 50 14             	call   *0x14(%eax)
  80199e:	eb 05                	jmp    8019a5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019a5:	83 c4 24             	add    $0x24,%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ba:	00 
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	89 04 24             	mov    %eax,(%esp)
  8019c1:	e8 fb 01 00 00       	call   801bc1 <open>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	85 db                	test   %ebx,%ebx
  8019ca:	78 1b                	js     8019e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d3:	89 1c 24             	mov    %ebx,(%esp)
  8019d6:	e8 56 ff ff ff       	call   801931 <fstat>
  8019db:	89 c6                	mov    %eax,%esi
	close(fd);
  8019dd:	89 1c 24             	mov    %ebx,(%esp)
  8019e0:	e8 cd fb ff ff       	call   8015b2 <close>
	return r;
  8019e5:	89 f0                	mov    %esi,%eax
}
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	83 ec 10             	sub    $0x10,%esp
  8019f6:	89 c6                	mov    %eax,%esi
  8019f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a01:	75 11                	jne    801a14 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a0a:	e8 fe 09 00 00       	call   80240d <ipc_find_env>
  801a0f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a14:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a1b:	00 
  801a1c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a23:	00 
  801a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a28:	a1 00 40 80 00       	mov    0x804000,%eax
  801a2d:	89 04 24             	mov    %eax,(%esp)
  801a30:	e8 29 09 00 00       	call   80235e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a3c:	00 
  801a3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a48:	e8 73 08 00 00       	call   8022c0 <ipc_recv>
}
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	b8 02 00 00 00       	mov    $0x2,%eax
  801a77:	e8 72 ff ff ff       	call   8019ee <fsipc>
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a84:	8b 45 08             	mov    0x8(%ebp),%eax
  801a87:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a94:	b8 06 00 00 00       	mov    $0x6,%eax
  801a99:	e8 50 ff ff ff       	call   8019ee <fsipc>
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 14             	sub    $0x14,%esp
  801aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 05 00 00 00       	mov    $0x5,%eax
  801abf:	e8 2a ff ff ff       	call   8019ee <fsipc>
  801ac4:	89 c2                	mov    %eax,%edx
  801ac6:	85 d2                	test   %edx,%edx
  801ac8:	78 2b                	js     801af5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ad1:	00 
  801ad2:	89 1c 24             	mov    %ebx,(%esp)
  801ad5:	e8 0d ef ff ff       	call   8009e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ada:	a1 80 50 80 00       	mov    0x805080,%eax
  801adf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ae5:	a1 84 50 80 00       	mov    0x805084,%eax
  801aea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af5:	83 c4 14             	add    $0x14,%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b01:	c7 44 24 08 fc 2d 80 	movl   $0x802dfc,0x8(%esp)
  801b08:	00 
  801b09:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b10:	00 
  801b11:	c7 04 24 1a 2e 80 00 	movl   $0x802e1a,(%esp)
  801b18:	e8 58 e7 ff ff       	call   800275 <_panic>

00801b1d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 10             	sub    $0x10,%esp
  801b25:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b33:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b39:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b43:	e8 a6 fe ff ff       	call   8019ee <fsipc>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 6a                	js     801bb8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b4e:	39 c6                	cmp    %eax,%esi
  801b50:	73 24                	jae    801b76 <devfile_read+0x59>
  801b52:	c7 44 24 0c 25 2e 80 	movl   $0x802e25,0xc(%esp)
  801b59:	00 
  801b5a:	c7 44 24 08 2c 2e 80 	movl   $0x802e2c,0x8(%esp)
  801b61:	00 
  801b62:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b69:	00 
  801b6a:	c7 04 24 1a 2e 80 00 	movl   $0x802e1a,(%esp)
  801b71:	e8 ff e6 ff ff       	call   800275 <_panic>
	assert(r <= PGSIZE);
  801b76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b7b:	7e 24                	jle    801ba1 <devfile_read+0x84>
  801b7d:	c7 44 24 0c 41 2e 80 	movl   $0x802e41,0xc(%esp)
  801b84:	00 
  801b85:	c7 44 24 08 2c 2e 80 	movl   $0x802e2c,0x8(%esp)
  801b8c:	00 
  801b8d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b94:	00 
  801b95:	c7 04 24 1a 2e 80 00 	movl   $0x802e1a,(%esp)
  801b9c:	e8 d4 e6 ff ff       	call   800275 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bac:	00 
  801bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb0:	89 04 24             	mov    %eax,(%esp)
  801bb3:	e8 cc ef ff ff       	call   800b84 <memmove>
	return r;
}
  801bb8:	89 d8                	mov    %ebx,%eax
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 24             	sub    $0x24,%esp
  801bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bcb:	89 1c 24             	mov    %ebx,(%esp)
  801bce:	e8 dd ed ff ff       	call   8009b0 <strlen>
  801bd3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd8:	7f 60                	jg     801c3a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 52 f8 ff ff       	call   801437 <fd_alloc>
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	85 d2                	test   %edx,%edx
  801be9:	78 54                	js     801c3f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801beb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bf6:	e8 ec ed ff ff       	call   8009e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c06:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0b:	e8 de fd ff ff       	call   8019ee <fsipc>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	85 c0                	test   %eax,%eax
  801c14:	79 17                	jns    801c2d <open+0x6c>
		fd_close(fd, 0);
  801c16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c1d:	00 
  801c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 08 f9 ff ff       	call   801531 <fd_close>
		return r;
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	eb 12                	jmp    801c3f <open+0x7e>
	}

	return fd2num(fd);
  801c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c30:	89 04 24             	mov    %eax,(%esp)
  801c33:	e8 d8 f7 ff ff       	call   801410 <fd2num>
  801c38:	eb 05                	jmp    801c3f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c3f:	83 c4 24             	add    $0x24,%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c50:	b8 08 00 00 00       	mov    $0x8,%eax
  801c55:	e8 94 fd ff ff       	call   8019ee <fsipc>
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	83 ec 10             	sub    $0x10,%esp
  801c64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	89 04 24             	mov    %eax,(%esp)
  801c6d:	e8 ae f7 ff ff       	call   801420 <fd2data>
  801c72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c74:	c7 44 24 04 4d 2e 80 	movl   $0x802e4d,0x4(%esp)
  801c7b:	00 
  801c7c:	89 1c 24             	mov    %ebx,(%esp)
  801c7f:	e8 63 ed ff ff       	call   8009e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c84:	8b 46 04             	mov    0x4(%esi),%eax
  801c87:	2b 06                	sub    (%esi),%eax
  801c89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c96:	00 00 00 
	stat->st_dev = &devpipe;
  801c99:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ca0:	30 80 00 
	return 0;
}
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5e                   	pop    %esi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	53                   	push   %ebx
  801cb3:	83 ec 14             	sub    $0x14,%esp
  801cb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc4:	e8 e1 f1 ff ff       	call   800eaa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc9:	89 1c 24             	mov    %ebx,(%esp)
  801ccc:	e8 4f f7 ff ff       	call   801420 <fd2data>
  801cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdc:	e8 c9 f1 ff ff       	call   800eaa <sys_page_unmap>
}
  801ce1:	83 c4 14             	add    $0x14,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	57                   	push   %edi
  801ceb:	56                   	push   %esi
  801cec:	53                   	push   %ebx
  801ced:	83 ec 2c             	sub    $0x2c,%esp
  801cf0:	89 c6                	mov    %eax,%esi
  801cf2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cf5:	a1 20 44 80 00       	mov    0x804420,%eax
  801cfa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cfd:	89 34 24             	mov    %esi,(%esp)
  801d00:	e8 40 07 00 00       	call   802445 <pageref>
  801d05:	89 c7                	mov    %eax,%edi
  801d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 33 07 00 00       	call   802445 <pageref>
  801d12:	39 c7                	cmp    %eax,%edi
  801d14:	0f 94 c2             	sete   %dl
  801d17:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d1a:	8b 0d 20 44 80 00    	mov    0x804420,%ecx
  801d20:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d23:	39 fb                	cmp    %edi,%ebx
  801d25:	74 21                	je     801d48 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d27:	84 d2                	test   %dl,%dl
  801d29:	74 ca                	je     801cf5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d2b:	8b 51 58             	mov    0x58(%ecx),%edx
  801d2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d32:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3a:	c7 04 24 54 2e 80 00 	movl   $0x802e54,(%esp)
  801d41:	e8 28 e6 ff ff       	call   80036e <cprintf>
  801d46:	eb ad                	jmp    801cf5 <_pipeisclosed+0xe>
	}
}
  801d48:	83 c4 2c             	add    $0x2c,%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	57                   	push   %edi
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	83 ec 1c             	sub    $0x1c,%esp
  801d59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d5c:	89 34 24             	mov    %esi,(%esp)
  801d5f:	e8 bc f6 ff ff       	call   801420 <fd2data>
  801d64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d66:	bf 00 00 00 00       	mov    $0x0,%edi
  801d6b:	eb 45                	jmp    801db2 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d6d:	89 da                	mov    %ebx,%edx
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	e8 71 ff ff ff       	call   801ce7 <_pipeisclosed>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	75 41                	jne    801dbb <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d7a:	e8 65 f0 ff ff       	call   800de4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d82:	8b 0b                	mov    (%ebx),%ecx
  801d84:	8d 51 20             	lea    0x20(%ecx),%edx
  801d87:	39 d0                	cmp    %edx,%eax
  801d89:	73 e2                	jae    801d6d <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d95:	99                   	cltd   
  801d96:	c1 ea 1b             	shr    $0x1b,%edx
  801d99:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801d9c:	83 e1 1f             	and    $0x1f,%ecx
  801d9f:	29 d1                	sub    %edx,%ecx
  801da1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801da5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801da9:	83 c0 01             	add    $0x1,%eax
  801dac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801daf:	83 c7 01             	add    $0x1,%edi
  801db2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801db5:	75 c8                	jne    801d7f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801db7:	89 f8                	mov    %edi,%eax
  801db9:	eb 05                	jmp    801dc0 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dc0:	83 c4 1c             	add    $0x1c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	57                   	push   %edi
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	83 ec 1c             	sub    $0x1c,%esp
  801dd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd4:	89 3c 24             	mov    %edi,(%esp)
  801dd7:	e8 44 f6 ff ff       	call   801420 <fd2data>
  801ddc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dde:	be 00 00 00 00       	mov    $0x0,%esi
  801de3:	eb 3d                	jmp    801e22 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801de5:	85 f6                	test   %esi,%esi
  801de7:	74 04                	je     801ded <devpipe_read+0x25>
				return i;
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	eb 43                	jmp    801e30 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ded:	89 da                	mov    %ebx,%edx
  801def:	89 f8                	mov    %edi,%eax
  801df1:	e8 f1 fe ff ff       	call   801ce7 <_pipeisclosed>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	75 31                	jne    801e2b <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dfa:	e8 e5 ef ff ff       	call   800de4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dff:	8b 03                	mov    (%ebx),%eax
  801e01:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e04:	74 df                	je     801de5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e06:	99                   	cltd   
  801e07:	c1 ea 1b             	shr    $0x1b,%edx
  801e0a:	01 d0                	add    %edx,%eax
  801e0c:	83 e0 1f             	and    $0x1f,%eax
  801e0f:	29 d0                	sub    %edx,%eax
  801e11:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e19:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e1c:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e1f:	83 c6 01             	add    $0x1,%esi
  801e22:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e25:	75 d8                	jne    801dff <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e27:	89 f0                	mov    %esi,%eax
  801e29:	eb 05                	jmp    801e30 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e30:	83 c4 1c             	add    $0x1c,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e43:	89 04 24             	mov    %eax,(%esp)
  801e46:	e8 ec f5 ff ff       	call   801437 <fd_alloc>
  801e4b:	89 c2                	mov    %eax,%edx
  801e4d:	85 d2                	test   %edx,%edx
  801e4f:	0f 88 4d 01 00 00    	js     801fa2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e55:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e5c:	00 
  801e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6b:	e8 93 ef ff ff       	call   800e03 <sys_page_alloc>
  801e70:	89 c2                	mov    %eax,%edx
  801e72:	85 d2                	test   %edx,%edx
  801e74:	0f 88 28 01 00 00    	js     801fa2 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7d:	89 04 24             	mov    %eax,(%esp)
  801e80:	e8 b2 f5 ff ff       	call   801437 <fd_alloc>
  801e85:	89 c3                	mov    %eax,%ebx
  801e87:	85 c0                	test   %eax,%eax
  801e89:	0f 88 fe 00 00 00    	js     801f8d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e96:	00 
  801e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea5:	e8 59 ef ff ff       	call   800e03 <sys_page_alloc>
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	85 c0                	test   %eax,%eax
  801eae:	0f 88 d9 00 00 00    	js     801f8d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb7:	89 04 24             	mov    %eax,(%esp)
  801eba:	e8 61 f5 ff ff       	call   801420 <fd2data>
  801ebf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec8:	00 
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 2a ef ff ff       	call   800e03 <sys_page_alloc>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	85 c0                	test   %eax,%eax
  801edd:	0f 88 97 00 00 00    	js     801f7a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 32 f5 ff ff       	call   801420 <fd2data>
  801eee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ef5:	00 
  801ef6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801efa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f01:	00 
  801f02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0d:	e8 45 ef ff ff       	call   800e57 <sys_page_map>
  801f12:	89 c3                	mov    %eax,%ebx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 52                	js     801f6a <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f45:	89 04 24             	mov    %eax,(%esp)
  801f48:	e8 c3 f4 ff ff       	call   801410 <fd2num>
  801f4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 b3 f4 ff ff       	call   801410 <fd2num>
  801f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	eb 38                	jmp    801fa2 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f75:	e8 30 ef ff ff       	call   800eaa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f88:	e8 1d ef ff ff       	call   800eaa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9b:	e8 0a ef ff ff       	call   800eaa <sys_page_unmap>
  801fa0:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801fa2:	83 c4 30             	add    $0x30,%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 c5 f4 ff ff       	call   801486 <fd_lookup>
  801fc1:	89 c2                	mov    %eax,%edx
  801fc3:	85 d2                	test   %edx,%edx
  801fc5:	78 15                	js     801fdc <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fca:	89 04 24             	mov    %eax,(%esp)
  801fcd:	e8 4e f4 ff ff       	call   801420 <fd2data>
	return _pipeisclosed(fd, p);
  801fd2:	89 c2                	mov    %eax,%edx
  801fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd7:	e8 0b fd ff ff       	call   801ce7 <_pipeisclosed>
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 10             	sub    $0x10,%esp
  801fe6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801fe9:	85 f6                	test   %esi,%esi
  801feb:	75 24                	jne    802011 <wait+0x33>
  801fed:	c7 44 24 0c 6c 2e 80 	movl   $0x802e6c,0xc(%esp)
  801ff4:	00 
  801ff5:	c7 44 24 08 2c 2e 80 	movl   $0x802e2c,0x8(%esp)
  801ffc:	00 
  801ffd:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802004:	00 
  802005:	c7 04 24 77 2e 80 00 	movl   $0x802e77,(%esp)
  80200c:	e8 64 e2 ff ff       	call   800275 <_panic>
	e = &envs[ENVX(envid)];
  802011:	89 f3                	mov    %esi,%ebx
  802013:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802019:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80201c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802022:	eb 05                	jmp    802029 <wait+0x4b>
		sys_yield();
  802024:	e8 bb ed ff ff       	call   800de4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802029:	8b 43 48             	mov    0x48(%ebx),%eax
  80202c:	39 f0                	cmp    %esi,%eax
  80202e:	75 07                	jne    802037 <wait+0x59>
  802030:	8b 43 54             	mov    0x54(%ebx),%eax
  802033:	85 c0                	test   %eax,%eax
  802035:	75 ed                	jne    802024 <wait+0x46>
		sys_yield();
}
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    
  80203e:	66 90                	xchg   %ax,%ax

00802040 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802050:	c7 44 24 04 82 2e 80 	movl   $0x802e82,0x4(%esp)
  802057:	00 
  802058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205b:	89 04 24             	mov    %eax,(%esp)
  80205e:	e8 84 e9 ff ff       	call   8009e7 <strcpy>
	return 0;
}
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	57                   	push   %edi
  80206e:	56                   	push   %esi
  80206f:	53                   	push   %ebx
  802070:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802076:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80207b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802081:	eb 31                	jmp    8020b4 <devcons_write+0x4a>
		m = n - tot;
  802083:	8b 75 10             	mov    0x10(%ebp),%esi
  802086:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802088:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80208b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802090:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802093:	89 74 24 08          	mov    %esi,0x8(%esp)
  802097:	03 45 0c             	add    0xc(%ebp),%eax
  80209a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209e:	89 3c 24             	mov    %edi,(%esp)
  8020a1:	e8 de ea ff ff       	call   800b84 <memmove>
		sys_cputs(buf, m);
  8020a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020aa:	89 3c 24             	mov    %edi,(%esp)
  8020ad:	e8 84 ec ff ff       	call   800d36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b2:	01 f3                	add    %esi,%ebx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020b9:	72 c8                	jb     802083 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020bb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020c1:	5b                   	pop    %ebx
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    

008020c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8020d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020d5:	75 07                	jne    8020de <devcons_read+0x18>
  8020d7:	eb 2a                	jmp    802103 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d9:	e8 06 ed ff ff       	call   800de4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020de:	66 90                	xchg   %ax,%ax
  8020e0:	e8 6f ec ff ff       	call   800d54 <sys_cgetc>
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	74 f0                	je     8020d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	78 16                	js     802103 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ed:	83 f8 04             	cmp    $0x4,%eax
  8020f0:	74 0c                	je     8020fe <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8020f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f5:	88 02                	mov    %al,(%edx)
	return 1;
  8020f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fc:	eb 05                	jmp    802103 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802103:	c9                   	leave  
  802104:	c3                   	ret    

00802105 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80210b:	8b 45 08             	mov    0x8(%ebp),%eax
  80210e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802111:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802118:	00 
  802119:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80211c:	89 04 24             	mov    %eax,(%esp)
  80211f:	e8 12 ec ff ff       	call   800d36 <sys_cputs>
}
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <getchar>:

int
getchar(void)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80212c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802133:	00 
  802134:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802142:	e8 ce f5 ff ff       	call   801715 <read>
	if (r < 0)
  802147:	85 c0                	test   %eax,%eax
  802149:	78 0f                	js     80215a <getchar+0x34>
		return r;
	if (r < 1)
  80214b:	85 c0                	test   %eax,%eax
  80214d:	7e 06                	jle    802155 <getchar+0x2f>
		return -E_EOF;
	return c;
  80214f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802153:	eb 05                	jmp    80215a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802155:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802162:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802165:	89 44 24 04          	mov    %eax,0x4(%esp)
  802169:	8b 45 08             	mov    0x8(%ebp),%eax
  80216c:	89 04 24             	mov    %eax,(%esp)
  80216f:	e8 12 f3 ff ff       	call   801486 <fd_lookup>
  802174:	85 c0                	test   %eax,%eax
  802176:	78 11                	js     802189 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802181:	39 10                	cmp    %edx,(%eax)
  802183:	0f 94 c0             	sete   %al
  802186:	0f b6 c0             	movzbl %al,%eax
}
  802189:	c9                   	leave  
  80218a:	c3                   	ret    

0080218b <opencons>:

int
opencons(void)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802194:	89 04 24             	mov    %eax,(%esp)
  802197:	e8 9b f2 ff ff       	call   801437 <fd_alloc>
		return r;
  80219c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 40                	js     8021e2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021a9:	00 
  8021aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b8:	e8 46 ec ff ff       	call   800e03 <sys_page_alloc>
		return r;
  8021bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	78 1f                	js     8021e2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021c3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 30 f2 ff ff       	call   801410 <fd2num>
  8021e0:	89 c2                	mov    %eax,%edx
}
  8021e2:	89 d0                	mov    %edx,%eax
  8021e4:	c9                   	leave  
  8021e5:	c3                   	ret    

008021e6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021ec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021f3:	75 44                	jne    802239 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8021f5:	a1 20 44 80 00       	mov    0x804420,%eax
  8021fa:	8b 40 48             	mov    0x48(%eax),%eax
  8021fd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802204:	00 
  802205:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80220c:	ee 
  80220d:	89 04 24             	mov    %eax,(%esp)
  802210:	e8 ee eb ff ff       	call   800e03 <sys_page_alloc>
		if( r < 0)
  802215:	85 c0                	test   %eax,%eax
  802217:	79 20                	jns    802239 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  802219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221d:	c7 44 24 08 90 2e 80 	movl   $0x802e90,0x8(%esp)
  802224:	00 
  802225:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80222c:	00 
  80222d:	c7 04 24 ec 2e 80 00 	movl   $0x802eec,(%esp)
  802234:	e8 3c e0 ff ff       	call   800275 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	a3 00 60 80 00       	mov    %eax,0x806000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  802241:	e8 7f eb ff ff       	call   800dc5 <sys_getenvid>
  802246:	c7 44 24 04 7c 22 80 	movl   $0x80227c,0x4(%esp)
  80224d:	00 
  80224e:	89 04 24             	mov    %eax,(%esp)
  802251:	e8 4d ed ff ff       	call   800fa3 <sys_env_set_pgfault_upcall>
  802256:	85 c0                	test   %eax,%eax
  802258:	79 20                	jns    80227a <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80225a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225e:	c7 44 24 08 c0 2e 80 	movl   $0x802ec0,0x8(%esp)
  802265:	00 
  802266:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80226d:	00 
  80226e:	c7 04 24 ec 2e 80 00 	movl   $0x802eec,(%esp)
  802275:	e8 fb df ff ff       	call   800275 <_panic>


}
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80227c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80227d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802282:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802284:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  802287:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  80228b:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  80228f:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  802293:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  802296:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  802299:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  80229c:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8022a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8022a4:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8022a8:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8022ac:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8022b0:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8022b4:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8022b8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  8022b9:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  8022ba:	c3                   	ret    
  8022bb:	66 90                	xchg   %ax,%ax
  8022bd:	66 90                	xchg   %ax,%ax
  8022bf:	90                   	nop

008022c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	56                   	push   %esi
  8022c4:	53                   	push   %ebx
  8022c5:	83 ec 10             	sub    $0x10,%esp
  8022c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8022cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	75 0e                	jne    8022e3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8022d5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8022dc:	e8 38 ed ff ff       	call   801019 <sys_ipc_recv>
  8022e1:	eb 08                	jmp    8022eb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8022e3:	89 04 24             	mov    %eax,(%esp)
  8022e6:	e8 2e ed ff ff       	call   801019 <sys_ipc_recv>
	if(r == 0){
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	75 1e                	jne    802310 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8022f2:	85 f6                	test   %esi,%esi
  8022f4:	74 0a                	je     802300 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8022f6:	a1 20 44 80 00       	mov    0x804420,%eax
  8022fb:	8b 40 74             	mov    0x74(%eax),%eax
  8022fe:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802300:	85 db                	test   %ebx,%ebx
  802302:	74 2c                	je     802330 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802304:	a1 20 44 80 00       	mov    0x804420,%eax
  802309:	8b 40 78             	mov    0x78(%eax),%eax
  80230c:	89 03                	mov    %eax,(%ebx)
  80230e:	eb 20                	jmp    802330 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802310:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802314:	c7 44 24 08 fc 2e 80 	movl   $0x802efc,0x8(%esp)
  80231b:	00 
  80231c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802323:	00 
  802324:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  80232b:	e8 45 df ff ff       	call   800275 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802330:	a1 20 44 80 00       	mov    0x804420,%eax
  802335:	8b 50 70             	mov    0x70(%eax),%edx
  802338:	85 d2                	test   %edx,%edx
  80233a:	75 13                	jne    80234f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80233c:	8b 40 48             	mov    0x48(%eax),%eax
  80233f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802343:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  80234a:	e8 1f e0 ff ff       	call   80036e <cprintf>
	return thisenv->env_ipc_value;
  80234f:	a1 20 44 80 00       	mov    0x804420,%eax
  802354:	8b 40 70             	mov    0x70(%eax),%eax
}
  802357:	83 c4 10             	add    $0x10,%esp
  80235a:	5b                   	pop    %ebx
  80235b:	5e                   	pop    %esi
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    

0080235e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 7d 08             	mov    0x8(%ebp),%edi
  80236a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80236d:	85 f6                	test   %esi,%esi
  80236f:	75 22                	jne    802393 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802371:	8b 45 14             	mov    0x14(%ebp),%eax
  802374:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802378:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80237f:	ee 
  802380:	8b 45 0c             	mov    0xc(%ebp),%eax
  802383:	89 44 24 04          	mov    %eax,0x4(%esp)
  802387:	89 3c 24             	mov    %edi,(%esp)
  80238a:	e8 67 ec ff ff       	call   800ff6 <sys_ipc_try_send>
  80238f:	89 c3                	mov    %eax,%ebx
  802391:	eb 1c                	jmp    8023af <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802393:	8b 45 14             	mov    0x14(%ebp),%eax
  802396:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80239e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a5:	89 3c 24             	mov    %edi,(%esp)
  8023a8:	e8 49 ec ff ff       	call   800ff6 <sys_ipc_try_send>
  8023ad:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8023af:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8023b2:	74 3e                	je     8023f2 <ipc_send+0x94>
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	c1 e8 1f             	shr    $0x1f,%eax
  8023b9:	84 c0                	test   %al,%al
  8023bb:	74 35                	je     8023f2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  8023bd:	e8 03 ea ff ff       	call   800dc5 <sys_getenvid>
  8023c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c6:	c7 04 24 82 2f 80 00 	movl   $0x802f82,(%esp)
  8023cd:	e8 9c df ff ff       	call   80036e <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8023d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023d6:	c7 44 24 08 50 2f 80 	movl   $0x802f50,0x8(%esp)
  8023dd:	00 
  8023de:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8023e5:	00 
  8023e6:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  8023ed:	e8 83 de ff ff       	call   800275 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8023f2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8023f5:	75 0e                	jne    802405 <ipc_send+0xa7>
			sys_yield();
  8023f7:	e8 e8 e9 ff ff       	call   800de4 <sys_yield>
		else break;
	}
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	e9 68 ff ff ff       	jmp    80236d <ipc_send+0xf>
	
}
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    

0080240d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802413:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802418:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80241b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802421:	8b 52 50             	mov    0x50(%edx),%edx
  802424:	39 ca                	cmp    %ecx,%edx
  802426:	75 0d                	jne    802435 <ipc_find_env+0x28>
			return envs[i].env_id;
  802428:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80242b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802430:	8b 40 40             	mov    0x40(%eax),%eax
  802433:	eb 0e                	jmp    802443 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802435:	83 c0 01             	add    $0x1,%eax
  802438:	3d 00 04 00 00       	cmp    $0x400,%eax
  80243d:	75 d9                	jne    802418 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80243f:	66 b8 00 00          	mov    $0x0,%ax
}
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    

00802445 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	c1 e8 16             	shr    $0x16,%eax
  802450:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80245c:	f6 c1 01             	test   $0x1,%cl
  80245f:	74 1d                	je     80247e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802461:	c1 ea 0c             	shr    $0xc,%edx
  802464:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80246b:	f6 c2 01             	test   $0x1,%dl
  80246e:	74 0e                	je     80247e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802470:	c1 ea 0c             	shr    $0xc,%edx
  802473:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80247a:	ef 
  80247b:	0f b7 c0             	movzwl %ax,%eax
}
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    

00802480 <__udivdi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	83 ec 0c             	sub    $0xc,%esp
  802486:	8b 44 24 28          	mov    0x28(%esp),%eax
  80248a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80248e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802492:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802496:	85 c0                	test   %eax,%eax
  802498:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80249c:	89 ea                	mov    %ebp,%edx
  80249e:	89 0c 24             	mov    %ecx,(%esp)
  8024a1:	75 2d                	jne    8024d0 <__udivdi3+0x50>
  8024a3:	39 e9                	cmp    %ebp,%ecx
  8024a5:	77 61                	ja     802508 <__udivdi3+0x88>
  8024a7:	85 c9                	test   %ecx,%ecx
  8024a9:	89 ce                	mov    %ecx,%esi
  8024ab:	75 0b                	jne    8024b8 <__udivdi3+0x38>
  8024ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b2:	31 d2                	xor    %edx,%edx
  8024b4:	f7 f1                	div    %ecx
  8024b6:	89 c6                	mov    %eax,%esi
  8024b8:	31 d2                	xor    %edx,%edx
  8024ba:	89 e8                	mov    %ebp,%eax
  8024bc:	f7 f6                	div    %esi
  8024be:	89 c5                	mov    %eax,%ebp
  8024c0:	89 f8                	mov    %edi,%eax
  8024c2:	f7 f6                	div    %esi
  8024c4:	89 ea                	mov    %ebp,%edx
  8024c6:	83 c4 0c             	add    $0xc,%esp
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	39 e8                	cmp    %ebp,%eax
  8024d2:	77 24                	ja     8024f8 <__udivdi3+0x78>
  8024d4:	0f bd e8             	bsr    %eax,%ebp
  8024d7:	83 f5 1f             	xor    $0x1f,%ebp
  8024da:	75 3c                	jne    802518 <__udivdi3+0x98>
  8024dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8024e0:	39 34 24             	cmp    %esi,(%esp)
  8024e3:	0f 86 9f 00 00 00    	jbe    802588 <__udivdi3+0x108>
  8024e9:	39 d0                	cmp    %edx,%eax
  8024eb:	0f 82 97 00 00 00    	jb     802588 <__udivdi3+0x108>
  8024f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	31 c0                	xor    %eax,%eax
  8024fc:	83 c4 0c             	add    $0xc,%esp
  8024ff:	5e                   	pop    %esi
  802500:	5f                   	pop    %edi
  802501:	5d                   	pop    %ebp
  802502:	c3                   	ret    
  802503:	90                   	nop
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	89 f8                	mov    %edi,%eax
  80250a:	f7 f1                	div    %ecx
  80250c:	31 d2                	xor    %edx,%edx
  80250e:	83 c4 0c             	add    $0xc,%esp
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	8d 76 00             	lea    0x0(%esi),%esi
  802518:	89 e9                	mov    %ebp,%ecx
  80251a:	8b 3c 24             	mov    (%esp),%edi
  80251d:	d3 e0                	shl    %cl,%eax
  80251f:	89 c6                	mov    %eax,%esi
  802521:	b8 20 00 00 00       	mov    $0x20,%eax
  802526:	29 e8                	sub    %ebp,%eax
  802528:	89 c1                	mov    %eax,%ecx
  80252a:	d3 ef                	shr    %cl,%edi
  80252c:	89 e9                	mov    %ebp,%ecx
  80252e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802532:	8b 3c 24             	mov    (%esp),%edi
  802535:	09 74 24 08          	or     %esi,0x8(%esp)
  802539:	89 d6                	mov    %edx,%esi
  80253b:	d3 e7                	shl    %cl,%edi
  80253d:	89 c1                	mov    %eax,%ecx
  80253f:	89 3c 24             	mov    %edi,(%esp)
  802542:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802546:	d3 ee                	shr    %cl,%esi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	d3 e2                	shl    %cl,%edx
  80254c:	89 c1                	mov    %eax,%ecx
  80254e:	d3 ef                	shr    %cl,%edi
  802550:	09 d7                	or     %edx,%edi
  802552:	89 f2                	mov    %esi,%edx
  802554:	89 f8                	mov    %edi,%eax
  802556:	f7 74 24 08          	divl   0x8(%esp)
  80255a:	89 d6                	mov    %edx,%esi
  80255c:	89 c7                	mov    %eax,%edi
  80255e:	f7 24 24             	mull   (%esp)
  802561:	39 d6                	cmp    %edx,%esi
  802563:	89 14 24             	mov    %edx,(%esp)
  802566:	72 30                	jb     802598 <__udivdi3+0x118>
  802568:	8b 54 24 04          	mov    0x4(%esp),%edx
  80256c:	89 e9                	mov    %ebp,%ecx
  80256e:	d3 e2                	shl    %cl,%edx
  802570:	39 c2                	cmp    %eax,%edx
  802572:	73 05                	jae    802579 <__udivdi3+0xf9>
  802574:	3b 34 24             	cmp    (%esp),%esi
  802577:	74 1f                	je     802598 <__udivdi3+0x118>
  802579:	89 f8                	mov    %edi,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	e9 7a ff ff ff       	jmp    8024fc <__udivdi3+0x7c>
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 d2                	xor    %edx,%edx
  80258a:	b8 01 00 00 00       	mov    $0x1,%eax
  80258f:	e9 68 ff ff ff       	jmp    8024fc <__udivdi3+0x7c>
  802594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802598:	8d 47 ff             	lea    -0x1(%edi),%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	83 c4 0c             	add    $0xc,%esp
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	83 ec 14             	sub    $0x14,%esp
  8025b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8025ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8025be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8025c2:	89 c7                	mov    %eax,%edi
  8025c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8025d0:	89 34 24             	mov    %esi,(%esp)
  8025d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d7:	85 c0                	test   %eax,%eax
  8025d9:	89 c2                	mov    %eax,%edx
  8025db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025df:	75 17                	jne    8025f8 <__umoddi3+0x48>
  8025e1:	39 fe                	cmp    %edi,%esi
  8025e3:	76 4b                	jbe    802630 <__umoddi3+0x80>
  8025e5:	89 c8                	mov    %ecx,%eax
  8025e7:	89 fa                	mov    %edi,%edx
  8025e9:	f7 f6                	div    %esi
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	31 d2                	xor    %edx,%edx
  8025ef:	83 c4 14             	add    $0x14,%esp
  8025f2:	5e                   	pop    %esi
  8025f3:	5f                   	pop    %edi
  8025f4:	5d                   	pop    %ebp
  8025f5:	c3                   	ret    
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	39 f8                	cmp    %edi,%eax
  8025fa:	77 54                	ja     802650 <__umoddi3+0xa0>
  8025fc:	0f bd e8             	bsr    %eax,%ebp
  8025ff:	83 f5 1f             	xor    $0x1f,%ebp
  802602:	75 5c                	jne    802660 <__umoddi3+0xb0>
  802604:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802608:	39 3c 24             	cmp    %edi,(%esp)
  80260b:	0f 87 e7 00 00 00    	ja     8026f8 <__umoddi3+0x148>
  802611:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802615:	29 f1                	sub    %esi,%ecx
  802617:	19 c7                	sbb    %eax,%edi
  802619:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80261d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802621:	8b 44 24 08          	mov    0x8(%esp),%eax
  802625:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802629:	83 c4 14             	add    $0x14,%esp
  80262c:	5e                   	pop    %esi
  80262d:	5f                   	pop    %edi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    
  802630:	85 f6                	test   %esi,%esi
  802632:	89 f5                	mov    %esi,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x91>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f6                	div    %esi
  80263f:	89 c5                	mov    %eax,%ebp
  802641:	8b 44 24 04          	mov    0x4(%esp),%eax
  802645:	31 d2                	xor    %edx,%edx
  802647:	f7 f5                	div    %ebp
  802649:	89 c8                	mov    %ecx,%eax
  80264b:	f7 f5                	div    %ebp
  80264d:	eb 9c                	jmp    8025eb <__umoddi3+0x3b>
  80264f:	90                   	nop
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 fa                	mov    %edi,%edx
  802654:	83 c4 14             	add    $0x14,%esp
  802657:	5e                   	pop    %esi
  802658:	5f                   	pop    %edi
  802659:	5d                   	pop    %ebp
  80265a:	c3                   	ret    
  80265b:	90                   	nop
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	8b 04 24             	mov    (%esp),%eax
  802663:	be 20 00 00 00       	mov    $0x20,%esi
  802668:	89 e9                	mov    %ebp,%ecx
  80266a:	29 ee                	sub    %ebp,%esi
  80266c:	d3 e2                	shl    %cl,%edx
  80266e:	89 f1                	mov    %esi,%ecx
  802670:	d3 e8                	shr    %cl,%eax
  802672:	89 e9                	mov    %ebp,%ecx
  802674:	89 44 24 04          	mov    %eax,0x4(%esp)
  802678:	8b 04 24             	mov    (%esp),%eax
  80267b:	09 54 24 04          	or     %edx,0x4(%esp)
  80267f:	89 fa                	mov    %edi,%edx
  802681:	d3 e0                	shl    %cl,%eax
  802683:	89 f1                	mov    %esi,%ecx
  802685:	89 44 24 08          	mov    %eax,0x8(%esp)
  802689:	8b 44 24 10          	mov    0x10(%esp),%eax
  80268d:	d3 ea                	shr    %cl,%edx
  80268f:	89 e9                	mov    %ebp,%ecx
  802691:	d3 e7                	shl    %cl,%edi
  802693:	89 f1                	mov    %esi,%ecx
  802695:	d3 e8                	shr    %cl,%eax
  802697:	89 e9                	mov    %ebp,%ecx
  802699:	09 f8                	or     %edi,%eax
  80269b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80269f:	f7 74 24 04          	divl   0x4(%esp)
  8026a3:	d3 e7                	shl    %cl,%edi
  8026a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026a9:	89 d7                	mov    %edx,%edi
  8026ab:	f7 64 24 08          	mull   0x8(%esp)
  8026af:	39 d7                	cmp    %edx,%edi
  8026b1:	89 c1                	mov    %eax,%ecx
  8026b3:	89 14 24             	mov    %edx,(%esp)
  8026b6:	72 2c                	jb     8026e4 <__umoddi3+0x134>
  8026b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8026bc:	72 22                	jb     8026e0 <__umoddi3+0x130>
  8026be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026c2:	29 c8                	sub    %ecx,%eax
  8026c4:	19 d7                	sbb    %edx,%edi
  8026c6:	89 e9                	mov    %ebp,%ecx
  8026c8:	89 fa                	mov    %edi,%edx
  8026ca:	d3 e8                	shr    %cl,%eax
  8026cc:	89 f1                	mov    %esi,%ecx
  8026ce:	d3 e2                	shl    %cl,%edx
  8026d0:	89 e9                	mov    %ebp,%ecx
  8026d2:	d3 ef                	shr    %cl,%edi
  8026d4:	09 d0                	or     %edx,%eax
  8026d6:	89 fa                	mov    %edi,%edx
  8026d8:	83 c4 14             	add    $0x14,%esp
  8026db:	5e                   	pop    %esi
  8026dc:	5f                   	pop    %edi
  8026dd:	5d                   	pop    %ebp
  8026de:	c3                   	ret    
  8026df:	90                   	nop
  8026e0:	39 d7                	cmp    %edx,%edi
  8026e2:	75 da                	jne    8026be <__umoddi3+0x10e>
  8026e4:	8b 14 24             	mov    (%esp),%edx
  8026e7:	89 c1                	mov    %eax,%ecx
  8026e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8026ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8026f1:	eb cb                	jmp    8026be <__umoddi3+0x10e>
  8026f3:	90                   	nop
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8026fc:	0f 82 0f ff ff ff    	jb     802611 <__umoddi3+0x61>
  802702:	e9 1a ff ff ff       	jmp    802621 <__umoddi3+0x71>
