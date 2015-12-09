
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 86 01 00 00       	call   8001b7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	strcpy(VA, msg2);
  800039:	a1 00 40 80 00       	mov    0x804000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800049:	e8 39 09 00 00       	call   800987 <strcpy>
	exit();
  80004e:	e8 ac 01 00 00       	call   8001ff <exit>
}
  800053:	c9                   	leave  
  800054:	c3                   	ret    

00800055 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800055:	55                   	push   %ebp
  800056:	89 e5                	mov    %esp,%ebp
  800058:	53                   	push   %ebx
  800059:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (argc != 0)
  80005c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800060:	74 05                	je     800067 <umain+0x12>
		childofspawn();
  800062:	e8 cc ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800067:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 00 00 00 	movl   $0xa0000000,0x4(%esp)
  800076:	a0 
  800077:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80007e:	e8 20 0d 00 00       	call   800da3 <sys_page_alloc>
  800083:	85 c0                	test   %eax,%eax
  800085:	79 20                	jns    8000a7 <umain+0x52>
		panic("sys_page_alloc: %e", r);
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 9f 2c 80 00 	movl   $0x802c9f,(%esp)
  8000a2:	e8 6c 01 00 00       	call   800213 <_panic>

	// check fork
	if ((r = fork()) < 0)
  8000a7:	e8 c9 10 00 00       	call   801175 <fork>
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	85 c0                	test   %eax,%eax
  8000b0:	79 20                	jns    8000d2 <umain+0x7d>
		panic("fork: %e", r);
  8000b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b6:	c7 44 24 08 b3 2c 80 	movl   $0x802cb3,0x8(%esp)
  8000bd:	00 
  8000be:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8000c5:	00 
  8000c6:	c7 04 24 9f 2c 80 00 	movl   $0x802c9f,(%esp)
  8000cd:	e8 41 01 00 00       	call   800213 <_panic>
	if (r == 0) {
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	75 1a                	jne    8000f0 <umain+0x9b>
		strcpy(VA, msg);
  8000d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  8000e6:	e8 9c 08 00 00       	call   800987 <strcpy>
		exit();
  8000eb:	e8 0f 01 00 00       	call   8001ff <exit>
	}
	wait(r);
  8000f0:	89 1c 24             	mov    %ebx,(%esp)
  8000f3:	e8 66 18 00 00       	call   80195e <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  800108:	e8 2f 09 00 00       	call   800a3c <strcmp>
  80010d:	85 c0                	test   %eax,%eax
  80010f:	b8 80 2c 80 00       	mov    $0x802c80,%eax
  800114:	ba 86 2c 80 00       	mov    $0x802c86,%edx
  800119:	0f 45 c2             	cmovne %edx,%eax
  80011c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800120:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800127:	e8 e0 01 00 00       	call   80030c <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 d7 2c 80 	movl   $0x802cd7,0x8(%esp)
  80013b:	00 
  80013c:	c7 44 24 04 dc 2c 80 	movl   $0x802cdc,0x4(%esp)
  800143:	00 
  800144:	c7 04 24 db 2c 80 00 	movl   $0x802cdb,(%esp)
  80014b:	e8 97 17 00 00       	call   8018e7 <spawnl>
  800150:	85 c0                	test   %eax,%eax
  800152:	79 20                	jns    800174 <umain+0x11f>
		panic("spawn: %e", r);
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	c7 44 24 08 e9 2c 80 	movl   $0x802ce9,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800167:	00 
  800168:	c7 04 24 9f 2c 80 00 	movl   $0x802c9f,(%esp)
  80016f:	e8 9f 00 00 00       	call   800213 <_panic>
	wait(r);
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 e2 17 00 00       	call   80195e <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80017c:	a1 00 40 80 00       	mov    0x804000,%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	c7 04 24 00 00 00 a0 	movl   $0xa0000000,(%esp)
  80018c:	e8 ab 08 00 00       	call   800a3c <strcmp>
  800191:	85 c0                	test   %eax,%eax
  800193:	b8 80 2c 80 00       	mov    $0x802c80,%eax
  800198:	ba 86 2c 80 00       	mov    $0x802c86,%edx
  80019d:	0f 45 c2             	cmovne %edx,%eax
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 f3 2c 80 00 	movl   $0x802cf3,(%esp)
  8001ab:	e8 5c 01 00 00       	call   80030c <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001b0:	cc                   	int3   

	breakpoint();
}
  8001b1:	83 c4 14             	add    $0x14,%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 10             	sub    $0x10,%esp
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8001c5:	e8 9b 0b 00 00       	call   800d65 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001ca:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d7:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7e 07                	jle    8001e7 <libmain+0x30>
		binaryname = argv[0];
  8001e0:	8b 06                	mov    (%esi),%eax
  8001e2:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001eb:	89 1c 24             	mov    %ebx,(%esp)
  8001ee:	e8 62 fe ff ff       	call   800055 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 07 00 00 00       	call   8001ff <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800205:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80020c:	e8 02 0b 00 00       	call   800d13 <sys_env_destroy>
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80021b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80021e:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800224:	e8 3c 0b 00 00       	call   800d65 <sys_getenvid>
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800237:	89 74 24 08          	mov    %esi,0x8(%esp)
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	c7 04 24 38 2d 80 00 	movl   $0x802d38,(%esp)
  800246:	e8 c1 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80024f:	8b 45 10             	mov    0x10(%ebp),%eax
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	e8 51 00 00 00       	call   8002ab <vcprintf>
	cprintf("\n");
  80025a:	c7 04 24 60 34 80 00 	movl   $0x803460,(%esp)
  800261:	e8 a6 00 00 00       	call   80030c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800266:	cc                   	int3   
  800267:	eb fd                	jmp    800266 <_panic+0x53>

00800269 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	53                   	push   %ebx
  80026d:	83 ec 14             	sub    $0x14,%esp
  800270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800273:	8b 13                	mov    (%ebx),%edx
  800275:	8d 42 01             	lea    0x1(%edx),%eax
  800278:	89 03                	mov    %eax,(%ebx)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800281:	3d ff 00 00 00       	cmp    $0xff,%eax
  800286:	75 19                	jne    8002a1 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800288:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80028f:	00 
  800290:	8d 43 08             	lea    0x8(%ebx),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	e8 3b 0a 00 00       	call   800cd6 <sys_cputs>
		b->idx = 0;
  80029b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a5:	83 c4 14             	add    $0x14,%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bb:	00 00 00 
	b.cnt = 0;
  8002be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	c7 04 24 69 02 80 00 	movl   $0x800269,(%esp)
  8002e7:	e8 78 01 00 00       	call   800464 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	e8 d2 09 00 00       	call   800cd6 <sys_cputs>

	return b.cnt;
}
  800304:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 87 ff ff ff       	call   8002ab <vcprintf>
	va_end(ap);

	return cnt;
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    
  800326:	66 90                	xchg   %ax,%ax
  800328:	66 90                	xchg   %ax,%ax
  80032a:	66 90                	xchg   %ax,%ax
  80032c:	66 90                	xchg   %ax,%ax
  80032e:	66 90                	xchg   %ax,%ax

00800330 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033c:	89 d7                	mov    %edx,%edi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	89 c3                	mov    %eax,%ebx
  800349:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80034c:	8b 45 10             	mov    0x10(%ebp),%eax
  80034f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035d:	39 d9                	cmp    %ebx,%ecx
  80035f:	72 05                	jb     800366 <printnum+0x36>
  800361:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800364:	77 69                	ja     8003cf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800366:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800369:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80036d:	83 ee 01             	sub    $0x1,%esi
  800370:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	8b 44 24 08          	mov    0x8(%esp),%eax
  80037c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800380:	89 c3                	mov    %eax,%ebx
  800382:	89 d6                	mov    %edx,%esi
  800384:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800387:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80038a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80038e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	e8 3c 26 00 00       	call   8029e0 <__udivdi3>
  8003a4:	89 d9                	mov    %ebx,%ecx
  8003a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b5:	89 fa                	mov    %edi,%edx
  8003b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ba:	e8 71 ff ff ff       	call   800330 <printnum>
  8003bf:	eb 1b                	jmp    8003dc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff d3                	call   *%ebx
  8003cd:	eb 03                	jmp    8003d2 <printnum+0xa2>
  8003cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d2:	83 ee 01             	sub    $0x1,%esi
  8003d5:	85 f6                	test   %esi,%esi
  8003d7:	7f e8                	jg     8003c1 <printnum+0x91>
  8003d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	e8 0c 27 00 00       	call   802b10 <__umoddi3>
  800404:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800408:	0f be 80 5b 2d 80 00 	movsbl 0x802d5b(%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800415:	ff d0                	call   *%eax
}
  800417:	83 c4 3c             	add    $0x3c,%esp
  80041a:	5b                   	pop    %ebx
  80041b:	5e                   	pop    %esi
  80041c:	5f                   	pop    %edi
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800425:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800429:	8b 10                	mov    (%eax),%edx
  80042b:	3b 50 04             	cmp    0x4(%eax),%edx
  80042e:	73 0a                	jae    80043a <sprintputch+0x1b>
		*b->buf++ = ch;
  800430:	8d 4a 01             	lea    0x1(%edx),%ecx
  800433:	89 08                	mov    %ecx,(%eax)
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	88 02                	mov    %al,(%edx)
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800442:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800445:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800449:	8b 45 10             	mov    0x10(%ebp),%eax
  80044c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800450:	8b 45 0c             	mov    0xc(%ebp),%eax
  800453:	89 44 24 04          	mov    %eax,0x4(%esp)
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	89 04 24             	mov    %eax,(%esp)
  80045d:	e8 02 00 00 00       	call   800464 <vprintfmt>
	va_end(ap);
}
  800462:	c9                   	leave  
  800463:	c3                   	ret    

00800464 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	57                   	push   %edi
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 3c             	sub    $0x3c,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800473:	8b 7d 10             	mov    0x10(%ebp),%edi
  800476:	eb 11                	jmp    800489 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800478:	85 c0                	test   %eax,%eax
  80047a:	0f 84 48 04 00 00    	je     8008c8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800490:	83 f8 25             	cmp    $0x25,%eax
  800493:	75 e3                	jne    800478 <vprintfmt+0x14>
  800495:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800499:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b3:	eb 1f                	jmp    8004d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004bc:	eb 16                	jmp    8004d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c5:	eb 0d                	jmp    8004d4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8d 47 01             	lea    0x1(%edi),%eax
  8004d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004da:	0f b6 17             	movzbl (%edi),%edx
  8004dd:	0f b6 c2             	movzbl %dl,%eax
  8004e0:	83 ea 23             	sub    $0x23,%edx
  8004e3:	80 fa 55             	cmp    $0x55,%dl
  8004e6:	0f 87 bf 03 00 00    	ja     8008ab <vprintfmt+0x447>
  8004ec:	0f b6 d2             	movzbl %dl,%edx
  8004ef:	ff 24 95 a0 2e 80 00 	jmp    *0x802ea0(,%edx,4)
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800501:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800504:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800508:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80050b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80050e:	83 f9 09             	cmp    $0x9,%ecx
  800511:	77 3c                	ja     80054f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800513:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800516:	eb e9                	jmp    800501 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80052c:	eb 27                	jmp    800555 <vprintfmt+0xf1>
  80052e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	b8 00 00 00 00       	mov    $0x0,%eax
  800538:	0f 49 c2             	cmovns %edx,%eax
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800541:	eb 91                	jmp    8004d4 <vprintfmt+0x70>
  800543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800546:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80054d:	eb 85                	jmp    8004d4 <vprintfmt+0x70>
  80054f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800552:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	0f 89 75 ff ff ff    	jns    8004d4 <vprintfmt+0x70>
  80055f:	e9 63 ff ff ff       	jmp    8004c7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800564:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056a:	e9 65 ff ff ff       	jmp    8004d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800572:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800584:	e9 00 ff ff ff       	jmp    800489 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800590:	8b 00                	mov    (%eax),%eax
  800592:	99                   	cltd   
  800593:	31 d0                	xor    %edx,%eax
  800595:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800597:	83 f8 0f             	cmp    $0xf,%eax
  80059a:	7f 0b                	jg     8005a7 <vprintfmt+0x143>
  80059c:	8b 14 85 00 30 80 00 	mov    0x803000(,%eax,4),%edx
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	75 20                	jne    8005c7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8005a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ab:	c7 44 24 08 73 2d 80 	movl   $0x802d73,0x8(%esp)
  8005b2:	00 
  8005b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b7:	89 34 24             	mov    %esi,(%esp)
  8005ba:	e8 7d fe ff ff       	call   80043c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c2:	e9 c2 fe ff ff       	jmp    800489 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cb:	c7 44 24 08 7a 32 80 	movl   $0x80327a,0x8(%esp)
  8005d2:	00 
  8005d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d7:	89 34 24             	mov    %esi,(%esp)
  8005da:	e8 5d fe ff ff       	call   80043c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e2:	e9 a2 fe ff ff       	jmp    800489 <vprintfmt+0x25>
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	b8 6c 2d 80 00       	mov    $0x802d6c,%eax
  800600:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800603:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800607:	0f 84 92 00 00 00    	je     80069f <vprintfmt+0x23b>
  80060d:	85 c9                	test   %ecx,%ecx
  80060f:	0f 8e 98 00 00 00    	jle    8006ad <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	89 54 24 04          	mov    %edx,0x4(%esp)
  800619:	89 3c 24             	mov    %edi,(%esp)
  80061c:	e8 47 03 00 00       	call   800968 <strnlen>
  800621:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800624:	29 c1                	sub    %eax,%ecx
  800626:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800629:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80062d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800630:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800633:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	85 ff                	test   %edi,%edi
  800648:	7f ed                	jg     800637 <vprintfmt+0x1d3>
  80064a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80064d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800650:	85 c9                	test   %ecx,%ecx
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
  800657:	0f 49 c1             	cmovns %ecx,%eax
  80065a:	29 c1                	sub    %eax,%ecx
  80065c:	89 75 08             	mov    %esi,0x8(%ebp)
  80065f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800662:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800665:	89 cb                	mov    %ecx,%ebx
  800667:	eb 50                	jmp    8006b9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800669:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80066d:	74 1e                	je     80068d <vprintfmt+0x229>
  80066f:	0f be d2             	movsbl %dl,%edx
  800672:	83 ea 20             	sub    $0x20,%edx
  800675:	83 fa 5e             	cmp    $0x5e,%edx
  800678:	76 13                	jbe    80068d <vprintfmt+0x229>
					putch('?', putdat);
  80067a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800681:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800688:	ff 55 08             	call   *0x8(%ebp)
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80068d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800690:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 eb 01             	sub    $0x1,%ebx
  80069d:	eb 1a                	jmp    8006b9 <vprintfmt+0x255>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb 0c                	jmp    8006b9 <vprintfmt+0x255>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	83 c7 01             	add    $0x1,%edi
  8006bc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006c0:	0f be c2             	movsbl %dl,%eax
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 25                	je     8006ec <vprintfmt+0x288>
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	78 9e                	js     800669 <vprintfmt+0x205>
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	79 99                	jns    800669 <vprintfmt+0x205>
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb 1a                	jmp    8006f4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e7:	83 ef 01             	sub    $0x1,%edi
  8006ea:	eb 08                	jmp    8006f4 <vprintfmt+0x290>
  8006ec:	89 df                	mov    %ebx,%edi
  8006ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f4:	85 ff                	test   %edi,%edi
  8006f6:	7f e2                	jg     8006da <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fb:	e9 89 fd ff ff       	jmp    800489 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800700:	83 f9 01             	cmp    $0x1,%ecx
  800703:	7e 19                	jle    80071e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 50 04             	mov    0x4(%eax),%edx
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800710:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 40 08             	lea    0x8(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
  80071c:	eb 38                	jmp    800756 <vprintfmt+0x2f2>
	else if (lflag)
  80071e:	85 c9                	test   %ecx,%ecx
  800720:	74 1b                	je     80073d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 00                	mov    (%eax),%eax
  800727:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072a:	89 c1                	mov    %eax,%ecx
  80072c:	c1 f9 1f             	sar    $0x1f,%ecx
  80072f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 40 04             	lea    0x4(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
  80073b:	eb 19                	jmp    800756 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 00                	mov    (%eax),%eax
  800742:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800745:	89 c1                	mov    %eax,%ecx
  800747:	c1 f9 1f             	sar    $0x1f,%ecx
  80074a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800756:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800759:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800761:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800765:	0f 89 04 01 00 00    	jns    80086f <vprintfmt+0x40b>
				putch('-', putdat);
  80076b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077e:	f7 da                	neg    %edx
  800780:	83 d1 00             	adc    $0x0,%ecx
  800783:	f7 d9                	neg    %ecx
  800785:	e9 e5 00 00 00       	jmp    80086f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078a:	83 f9 01             	cmp    $0x1,%ecx
  80078d:	7e 10                	jle    80079f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 10                	mov    (%eax),%edx
  800794:	8b 48 04             	mov    0x4(%eax),%ecx
  800797:	8d 40 08             	lea    0x8(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
  80079d:	eb 26                	jmp    8007c5 <vprintfmt+0x361>
	else if (lflag)
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	74 12                	je     8007b5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 10                	mov    (%eax),%edx
  8007a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	eb 10                	jmp    8007c5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007ca:	e9 a0 00 00 00       	jmp    80086f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007da:	ff d6                	call   *%esi
			putch('X', putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007e7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ed:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007f4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007f9:	e9 8b fc ff ff       	jmp    800489 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800802:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800809:	ff d6                	call   *%esi
			putch('x', putdat);
  80080b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800816:	ff d6                	call   *%esi
			num = (unsigned long long)
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800828:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80082d:	eb 40                	jmp    80086f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80082f:	83 f9 01             	cmp    $0x1,%ecx
  800832:	7e 10                	jle    800844 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
  800839:	8b 48 04             	mov    0x4(%eax),%ecx
  80083c:	8d 40 08             	lea    0x8(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
  800842:	eb 26                	jmp    80086a <vprintfmt+0x406>
	else if (lflag)
  800844:	85 c9                	test   %ecx,%ecx
  800846:	74 12                	je     80085a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8b 10                	mov    (%eax),%edx
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	8d 40 04             	lea    0x4(%eax),%eax
  800855:	89 45 14             	mov    %eax,0x14(%ebp)
  800858:	eb 10                	jmp    80086a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800864:	8d 40 04             	lea    0x4(%eax),%eax
  800867:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80086a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800873:	89 44 24 10          	mov    %eax,0x10(%esp)
  800877:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80087a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800882:	89 14 24             	mov    %edx,(%esp)
  800885:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800889:	89 da                	mov    %ebx,%edx
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	e8 9e fa ff ff       	call   800330 <printnum>
			break;
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	e9 ef fb ff ff       	jmp    800489 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089e:	89 04 24             	mov    %eax,(%esp)
  8008a1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a6:	e9 de fb ff ff       	jmp    800489 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008af:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b8:	eb 03                	jmp    8008bd <vprintfmt+0x459>
  8008ba:	83 ef 01             	sub    $0x1,%edi
  8008bd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c1:	75 f7                	jne    8008ba <vprintfmt+0x456>
  8008c3:	e9 c1 fb ff ff       	jmp    800489 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008c8:	83 c4 3c             	add    $0x3c,%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 28             	sub    $0x28,%esp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	74 30                	je     800921 <vsnprintf+0x51>
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	7e 2c                	jle    800921 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800903:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	c7 04 24 1f 04 80 00 	movl   $0x80041f,(%esp)
  800911:	e8 4e fb ff ff       	call   800464 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800916:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800919:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091f:	eb 05                	jmp    800926 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800921:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800931:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800935:	8b 45 10             	mov    0x10(%ebp),%eax
  800938:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 82 ff ff ff       	call   8008d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	eb 03                	jmp    800960 <strlen+0x10>
		n++;
  80095d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800960:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800964:	75 f7                	jne    80095d <strlen+0xd>
		n++;
	return n;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
  800976:	eb 03                	jmp    80097b <strnlen+0x13>
		n++;
  800978:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097b:	39 d0                	cmp    %edx,%eax
  80097d:	74 06                	je     800985 <strnlen+0x1d>
  80097f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800983:	75 f3                	jne    800978 <strnlen+0x10>
		n++;
	return n;
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800991:	89 c2                	mov    %eax,%edx
  800993:	83 c2 01             	add    $0x1,%edx
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80099d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a0:	84 db                	test   %bl,%bl
  8009a2:	75 ef                	jne    800993 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b1:	89 1c 24             	mov    %ebx,(%esp)
  8009b4:	e8 97 ff ff ff       	call   800950 <strlen>
	strcpy(dst + len, src);
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c0:	01 d8                	add    %ebx,%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 bd ff ff ff       	call   800987 <strcpy>
	return dst;
}
  8009ca:	89 d8                	mov    %ebx,%eax
  8009cc:	83 c4 08             	add    $0x8,%esp
  8009cf:	5b                   	pop    %ebx
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	eb 0f                	jmp    8009f5 <strncpy+0x23>
		*dst++ = *src;
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	75 ed                	jne    8009e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f9:	89 f0                	mov    %esi,%eax
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 08             	mov    0x8(%ebp),%esi
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a0d:	89 f0                	mov    %esi,%eax
  800a0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	75 0b                	jne    800a22 <strlcpy+0x23>
  800a17:	eb 1d                	jmp    800a36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	83 c2 01             	add    $0x1,%edx
  800a1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a22:	39 d8                	cmp    %ebx,%eax
  800a24:	74 0b                	je     800a31 <strlcpy+0x32>
  800a26:	0f b6 0a             	movzbl (%edx),%ecx
  800a29:	84 c9                	test   %cl,%cl
  800a2b:	75 ec                	jne    800a19 <strlcpy+0x1a>
  800a2d:	89 c2                	mov    %eax,%edx
  800a2f:	eb 02                	jmp    800a33 <strlcpy+0x34>
  800a31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a36:	29 f0                	sub    %esi,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a45:	eb 06                	jmp    800a4d <strcmp+0x11>
		p++, q++;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4d:	0f b6 01             	movzbl (%ecx),%eax
  800a50:	84 c0                	test   %al,%al
  800a52:	74 04                	je     800a58 <strcmp+0x1c>
  800a54:	3a 02                	cmp    (%edx),%al
  800a56:	74 ef                	je     800a47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a58:	0f b6 c0             	movzbl %al,%eax
  800a5b:	0f b6 12             	movzbl (%edx),%edx
  800a5e:	29 d0                	sub    %edx,%eax
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	53                   	push   %ebx
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6c:	89 c3                	mov    %eax,%ebx
  800a6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a71:	eb 06                	jmp    800a79 <strncmp+0x17>
		n--, p++, q++;
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a79:	39 d8                	cmp    %ebx,%eax
  800a7b:	74 15                	je     800a92 <strncmp+0x30>
  800a7d:	0f b6 08             	movzbl (%eax),%ecx
  800a80:	84 c9                	test   %cl,%cl
  800a82:	74 04                	je     800a88 <strncmp+0x26>
  800a84:	3a 0a                	cmp    (%edx),%cl
  800a86:	74 eb                	je     800a73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a88:	0f b6 00             	movzbl (%eax),%eax
  800a8b:	0f b6 12             	movzbl (%edx),%edx
  800a8e:	29 d0                	sub    %edx,%eax
  800a90:	eb 05                	jmp    800a97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa4:	eb 07                	jmp    800aad <strchr+0x13>
		if (*s == c)
  800aa6:	38 ca                	cmp    %cl,%dl
  800aa8:	74 0f                	je     800ab9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 f2                	jne    800aa6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	eb 07                	jmp    800ace <strfind+0x13>
		if (*s == c)
  800ac7:	38 ca                	cmp    %cl,%dl
  800ac9:	74 0a                	je     800ad5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	84 d2                	test   %dl,%dl
  800ad3:	75 f2                	jne    800ac7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae3:	85 c9                	test   %ecx,%ecx
  800ae5:	74 36                	je     800b1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aed:	75 28                	jne    800b17 <memset+0x40>
  800aef:	f6 c1 03             	test   $0x3,%cl
  800af2:	75 23                	jne    800b17 <memset+0x40>
		c &= 0xFF;
  800af4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	c1 e3 08             	shl    $0x8,%ebx
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	c1 e6 18             	shl    $0x18,%esi
  800b02:	89 d0                	mov    %edx,%eax
  800b04:	c1 e0 10             	shl    $0x10,%eax
  800b07:	09 f0                	or     %esi,%eax
  800b09:	09 c2                	or     %eax,%edx
  800b0b:	89 d0                	mov    %edx,%eax
  800b0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b12:	fc                   	cld    
  800b13:	f3 ab                	rep stos %eax,%es:(%edi)
  800b15:	eb 06                	jmp    800b1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	fc                   	cld    
  800b1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1d:	89 f8                	mov    %edi,%eax
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b32:	39 c6                	cmp    %eax,%esi
  800b34:	73 35                	jae    800b6b <memmove+0x47>
  800b36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b39:	39 d0                	cmp    %edx,%eax
  800b3b:	73 2e                	jae    800b6b <memmove+0x47>
		s += n;
		d += n;
  800b3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4a:	75 13                	jne    800b5f <memmove+0x3b>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 0e                	jne    800b5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b51:	83 ef 04             	sub    $0x4,%edi
  800b54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b5a:	fd                   	std    
  800b5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5d:	eb 09                	jmp    800b68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b5f:	83 ef 01             	sub    $0x1,%edi
  800b62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b65:	fd                   	std    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b68:	fc                   	cld    
  800b69:	eb 1d                	jmp    800b88 <memmove+0x64>
  800b6b:	89 f2                	mov    %esi,%edx
  800b6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6f:	f6 c2 03             	test   $0x3,%dl
  800b72:	75 0f                	jne    800b83 <memmove+0x5f>
  800b74:	f6 c1 03             	test   $0x3,%cl
  800b77:	75 0a                	jne    800b83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b7c:	89 c7                	mov    %eax,%edi
  800b7e:	fc                   	cld    
  800b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b81:	eb 05                	jmp    800b88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b83:	89 c7                	mov    %eax,%edi
  800b85:	fc                   	cld    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	e8 79 ff ff ff       	call   800b24 <memmove>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbd:	eb 1a                	jmp    800bd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbf:	0f b6 02             	movzbl (%edx),%eax
  800bc2:	0f b6 19             	movzbl (%ecx),%ebx
  800bc5:	38 d8                	cmp    %bl,%al
  800bc7:	74 0a                	je     800bd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc9:	0f b6 c0             	movzbl %al,%eax
  800bcc:	0f b6 db             	movzbl %bl,%ebx
  800bcf:	29 d8                	sub    %ebx,%eax
  800bd1:	eb 0f                	jmp    800be2 <memcmp+0x35>
		s1++, s2++;
  800bd3:	83 c2 01             	add    $0x1,%edx
  800bd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd9:	39 f2                	cmp    %esi,%edx
  800bdb:	75 e2                	jne    800bbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bef:	89 c2                	mov    %eax,%edx
  800bf1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf4:	eb 07                	jmp    800bfd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf6:	38 08                	cmp    %cl,(%eax)
  800bf8:	74 07                	je     800c01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfa:	83 c0 01             	add    $0x1,%eax
  800bfd:	39 d0                	cmp    %edx,%eax
  800bff:	72 f5                	jb     800bf6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0f:	eb 03                	jmp    800c14 <strtol+0x11>
		s++;
  800c11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c14:	0f b6 0a             	movzbl (%edx),%ecx
  800c17:	80 f9 09             	cmp    $0x9,%cl
  800c1a:	74 f5                	je     800c11 <strtol+0xe>
  800c1c:	80 f9 20             	cmp    $0x20,%cl
  800c1f:	74 f0                	je     800c11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c21:	80 f9 2b             	cmp    $0x2b,%cl
  800c24:	75 0a                	jne    800c30 <strtol+0x2d>
		s++;
  800c26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c29:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2e:	eb 11                	jmp    800c41 <strtol+0x3e>
  800c30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c35:	80 f9 2d             	cmp    $0x2d,%cl
  800c38:	75 07                	jne    800c41 <strtol+0x3e>
		s++, neg = 1;
  800c3a:	8d 52 01             	lea    0x1(%edx),%edx
  800c3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c46:	75 15                	jne    800c5d <strtol+0x5a>
  800c48:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4b:	75 10                	jne    800c5d <strtol+0x5a>
  800c4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c51:	75 0a                	jne    800c5d <strtol+0x5a>
		s += 2, base = 16;
  800c53:	83 c2 02             	add    $0x2,%edx
  800c56:	b8 10 00 00 00       	mov    $0x10,%eax
  800c5b:	eb 10                	jmp    800c6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	75 0c                	jne    800c6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c63:	80 3a 30             	cmpb   $0x30,(%edx)
  800c66:	75 05                	jne    800c6d <strtol+0x6a>
		s++, base = 8;
  800c68:	83 c2 01             	add    $0x1,%edx
  800c6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c75:	0f b6 0a             	movzbl (%edx),%ecx
  800c78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c7b:	89 f0                	mov    %esi,%eax
  800c7d:	3c 09                	cmp    $0x9,%al
  800c7f:	77 08                	ja     800c89 <strtol+0x86>
			dig = *s - '0';
  800c81:	0f be c9             	movsbl %cl,%ecx
  800c84:	83 e9 30             	sub    $0x30,%ecx
  800c87:	eb 20                	jmp    800ca9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c8c:	89 f0                	mov    %esi,%eax
  800c8e:	3c 19                	cmp    $0x19,%al
  800c90:	77 08                	ja     800c9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c92:	0f be c9             	movsbl %cl,%ecx
  800c95:	83 e9 57             	sub    $0x57,%ecx
  800c98:	eb 0f                	jmp    800ca9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c9d:	89 f0                	mov    %esi,%eax
  800c9f:	3c 19                	cmp    $0x19,%al
  800ca1:	77 16                	ja     800cb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ca3:	0f be c9             	movsbl %cl,%ecx
  800ca6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ca9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800cac:	7d 0f                	jge    800cbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800cae:	83 c2 01             	add    $0x1,%edx
  800cb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800cb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800cb7:	eb bc                	jmp    800c75 <strtol+0x72>
  800cb9:	89 d8                	mov    %ebx,%eax
  800cbb:	eb 02                	jmp    800cbf <strtol+0xbc>
  800cbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800cbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc3:	74 05                	je     800cca <strtol+0xc7>
		*endptr = (char *) s;
  800cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cca:	f7 d8                	neg    %eax
  800ccc:	85 ff                	test   %edi,%edi
  800cce:	0f 44 c3             	cmove  %ebx,%eax
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 c3                	mov    %eax,%ebx
  800ce9:	89 c7                	mov    %eax,%edi
  800ceb:	89 c6                	mov    %eax,%esi
  800ced:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_cgetc>:

int
sys_cgetc(void)
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
  800cff:	b8 01 00 00 00       	mov    $0x1,%eax
  800d04:	89 d1                	mov    %edx,%ecx
  800d06:	89 d3                	mov    %edx,%ebx
  800d08:	89 d7                	mov    %edx,%edi
  800d0a:	89 d6                	mov    %edx,%esi
  800d0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800d1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d21:	b8 03 00 00 00       	mov    $0x3,%eax
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 cb                	mov    %ecx,%ebx
  800d2b:	89 cf                	mov    %ecx,%edi
  800d2d:	89 ce                	mov    %ecx,%esi
  800d2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7e 28                	jle    800d5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d40:	00 
  800d41:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800d48:	00 
  800d49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d50:	00 
  800d51:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800d58:	e8 b6 f4 ff ff       	call   800213 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5d:	83 c4 2c             	add    $0x2c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 02 00 00 00       	mov    $0x2,%eax
  800d75:	89 d1                	mov    %edx,%ecx
  800d77:	89 d3                	mov    %edx,%ebx
  800d79:	89 d7                	mov    %edx,%edi
  800d7b:	89 d6                	mov    %edx,%esi
  800d7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_yield>:

void
sys_yield(void)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d94:	89 d1                	mov    %edx,%ecx
  800d96:	89 d3                	mov    %edx,%ebx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 d6                	mov    %edx,%esi
  800d9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	be 00 00 00 00       	mov    $0x0,%esi
  800db1:	b8 04 00 00 00       	mov    $0x4,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	89 f7                	mov    %esi,%edi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 28                	jle    800def <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800dda:	00 
  800ddb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de2:	00 
  800de3:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800dea:	e8 24 f4 ff ff       	call   800213 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800def:	83 c4 2c             	add    $0x2c,%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	b8 05 00 00 00       	mov    $0x5,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e11:	8b 75 18             	mov    0x18(%ebp),%esi
  800e14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7e 28                	jle    800e42 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e25:	00 
  800e26:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800e2d:	00 
  800e2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e35:	00 
  800e36:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800e3d:	e8 d1 f3 ff ff       	call   800213 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e42:	83 c4 2c             	add    $0x2c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 28                	jle    800e95 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e78:	00 
  800e79:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800e90:	e8 7e f3 ff ff       	call   800213 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e95:	83 c4 2c             	add    $0x2c,%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eab:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 df                	mov    %ebx,%edi
  800eb8:	89 de                	mov    %ebx,%esi
  800eba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7e 28                	jle    800ee8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edb:	00 
  800edc:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800ee3:	e8 2b f3 ff ff       	call   800213 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ee8:	83 c4 2c             	add    $0x2c,%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efe:	b8 09 00 00 00       	mov    $0x9,%eax
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 df                	mov    %ebx,%edi
  800f0b:	89 de                	mov    %ebx,%esi
  800f0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7e 28                	jle    800f3b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f17:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800f26:	00 
  800f27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2e:	00 
  800f2f:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800f36:	e8 d8 f2 ff ff       	call   800213 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f3b:	83 c4 2c             	add    $0x2c,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	89 df                	mov    %ebx,%edi
  800f5e:	89 de                	mov    %ebx,%esi
  800f60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f62:	85 c0                	test   %eax,%eax
  800f64:	7e 28                	jle    800f8e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f71:	00 
  800f72:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f81:	00 
  800f82:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800f89:	e8 85 f2 ff ff       	call   800213 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f8e:	83 c4 2c             	add    $0x2c,%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	be 00 00 00 00       	mov    $0x0,%esi
  800fa1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800faf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcf:	89 cb                	mov    %ecx,%ebx
  800fd1:	89 cf                	mov    %ecx,%edi
  800fd3:	89 ce                	mov    %ecx,%esi
  800fd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	7e 28                	jle    801003 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  800fee:	00 
  800fef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff6:	00 
  800ff7:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800ffe:	e8 10 f2 ff ff       	call   800213 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801003:	83 c4 2c             	add    $0x2c,%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	83 ec 20             	sub    $0x20,%esp
  801013:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801016:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801018:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80101c:	75 3f                	jne    80105d <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80101e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801022:	c7 04 24 8a 30 80 00 	movl   $0x80308a,(%esp)
  801029:	e8 de f2 ff ff       	call   80030c <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80102e:	8b 43 28             	mov    0x28(%ebx),%eax
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	c7 04 24 9a 30 80 00 	movl   $0x80309a,(%esp)
  80103c:	e8 cb f2 ff ff       	call   80030c <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801041:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801058:	e8 b6 f1 ff ff       	call   800213 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80105d:	89 f0                	mov    %esi,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801069:	f6 c4 08             	test   $0x8,%ah
  80106c:	75 1c                	jne    80108a <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80106e:	c7 44 24 08 08 31 80 	movl   $0x803108,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801085:	e8 89 f1 ff ff       	call   800213 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80108a:	e8 d6 fc ff ff       	call   800d65 <sys_getenvid>
  80108f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801096:	00 
  801097:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80109e:	00 
  80109f:	89 04 24             	mov    %eax,(%esp)
  8010a2:	e8 fc fc ff ff       	call   800da3 <sys_page_alloc>
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 1c                	jns    8010c7 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  8010ab:	c7 44 24 08 28 31 80 	movl   $0x803128,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  8010c2:	e8 4c f1 ff ff       	call   800213 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8010c7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8010cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010d4:	00 
  8010d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010e0:	e8 a7 fa ff ff       	call   800b8c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8010e5:	e8 7b fc ff ff       	call   800d65 <sys_getenvid>
  8010ea:	89 c3                	mov    %eax,%ebx
  8010ec:	e8 74 fc ff ff       	call   800d65 <sys_getenvid>
  8010f1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010f8:	00 
  8010f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801101:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801108:	00 
  801109:	89 04 24             	mov    %eax,(%esp)
  80110c:	e8 e6 fc ff ff       	call   800df7 <sys_page_map>
  801111:	85 c0                	test   %eax,%eax
  801113:	79 20                	jns    801135 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801115:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801119:	c7 44 24 08 50 31 80 	movl   $0x803150,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801130:	e8 de f0 ff ff       	call   800213 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801135:	e8 2b fc ff ff       	call   800d65 <sys_getenvid>
  80113a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801141:	00 
  801142:	89 04 24             	mov    %eax,(%esp)
  801145:	e8 00 fd ff ff       	call   800e4a <sys_page_unmap>
  80114a:	85 c0                	test   %eax,%eax
  80114c:	79 20                	jns    80116e <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80114e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801152:	c7 44 24 08 80 31 80 	movl   $0x803180,0x8(%esp)
  801159:	00 
  80115a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801161:	00 
  801162:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801169:	e8 a5 f0 ff ff       	call   800213 <_panic>
	return;
}
  80116e:	83 c4 20             	add    $0x20,%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80117e:	c7 04 24 0b 10 80 00 	movl   $0x80100b,(%esp)
  801185:	e8 34 08 00 00       	call   8019be <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80118a:	b8 07 00 00 00       	mov    $0x7,%eax
  80118f:	cd 30                	int    $0x30
  801191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801194:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801197:	85 c0                	test   %eax,%eax
  801199:	79 20                	jns    8011bb <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80119b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119f:	c7 44 24 08 b4 31 80 	movl   $0x8031b4,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  8011ae:	00 
  8011af:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  8011b6:	e8 58 f0 ff ff       	call   800213 <_panic>
	if(childEid == 0){
  8011bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011bf:	75 1c                	jne    8011dd <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011c1:	e8 9f fb ff ff       	call   800d65 <sys_getenvid>
  8011c6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011d3:	a3 04 50 80 00       	mov    %eax,0x805004
		return childEid;
  8011d8:	e9 a0 01 00 00       	jmp    80137d <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  8011dd:	c7 44 24 04 54 1a 80 	movl   $0x801a54,0x4(%esp)
  8011e4:	00 
  8011e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011e8:	89 04 24             	mov    %eax,(%esp)
  8011eb:	e8 53 fd ff ff       	call   800f43 <sys_env_set_pgfault_upcall>
  8011f0:	89 c7                	mov    %eax,%edi
	if(r < 0)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	79 20                	jns    801216 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  8011f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fa:	c7 44 24 08 e8 31 80 	movl   $0x8031e8,0x8(%esp)
  801201:	00 
  801202:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801211:	e8 fd ef ff ff       	call   800213 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801216:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	b9 00 00 00 00       	mov    $0x0,%ecx
  801225:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801228:	89 c2                	mov    %eax,%edx
  80122a:	c1 ea 16             	shr    $0x16,%edx
  80122d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	0f 84 f7 00 00 00    	je     801334 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80123d:	c1 e8 0c             	shr    $0xc,%eax
  801240:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801247:	f6 c2 04             	test   $0x4,%dl
  80124a:	0f 84 e4 00 00 00    	je     801334 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801250:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801257:	a8 01                	test   $0x1,%al
  801259:	0f 84 d5 00 00 00    	je     801334 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  80125f:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801265:	75 20                	jne    801287 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801267:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80126e:	00 
  80126f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801276:	ee 
  801277:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127a:	89 04 24             	mov    %eax,(%esp)
  80127d:	e8 21 fb ff ff       	call   800da3 <sys_page_alloc>
  801282:	e9 84 00 00 00       	jmp    80130b <fork+0x196>
  801287:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80128d:	89 f8                	mov    %edi,%eax
  80128f:	c1 e8 0c             	shr    $0xc,%eax
  801292:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801299:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80129e:	83 f8 01             	cmp    $0x1,%eax
  8012a1:	19 db                	sbb    %ebx,%ebx
  8012a3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8012a9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8012af:	e8 b1 fa ff ff       	call   800d65 <sys_getenvid>
  8012b4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012b8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c7:	89 04 24             	mov    %eax,(%esp)
  8012ca:	e8 28 fb ff ff       	call   800df7 <sys_page_map>
  8012cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 35                	js     80130b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  8012d6:	e8 8a fa ff ff       	call   800d65 <sys_getenvid>
  8012db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012de:	e8 82 fa ff ff       	call   800d65 <sys_getenvid>
  8012e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f6:	89 04 24             	mov    %eax,(%esp)
  8012f9:	e8 f9 fa ff ff       	call   800df7 <sys_page_map>
  8012fe:	85 c0                	test   %eax,%eax
  801300:	bf 00 00 00 00       	mov    $0x0,%edi
  801305:	0f 4f c7             	cmovg  %edi,%eax
  801308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80130b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80130f:	79 23                	jns    801334 <fork+0x1bf>
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801314:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801318:	c7 44 24 08 28 32 80 	movl   $0x803228,0x8(%esp)
  80131f:	00 
  801320:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801327:	00 
  801328:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  80132f:	e8 df ee ff ff       	call   800213 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801334:	89 f1                	mov    %esi,%ecx
  801336:	89 f0                	mov    %esi,%eax
  801338:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80133e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801344:	0f 85 de fe ff ff    	jne    801228 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80134a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801351:	00 
  801352:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 40 fb ff ff       	call   800e9d <sys_env_set_status>
  80135d:	85 c0                	test   %eax,%eax
  80135f:	79 1c                	jns    80137d <fork+0x208>
		panic("sys_env_set_status");
  801361:	c7 44 24 08 b6 30 80 	movl   $0x8030b6,0x8(%esp)
  801368:	00 
  801369:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801370:	00 
  801371:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  801378:	e8 96 ee ff ff       	call   800213 <_panic>
	return childEid;
}
  80137d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801380:	83 c4 2c             	add    $0x2c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <sfork>:

// Challenge!
int
sfork(void)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80138e:	c7 44 24 08 c9 30 80 	movl   $0x8030c9,0x8(%esp)
  801395:	00 
  801396:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80139d:	00 
  80139e:	c7 04 24 ab 30 80 00 	movl   $0x8030ab,(%esp)
  8013a5:	e8 69 ee ff ff       	call   800213 <_panic>
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8013bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013c3:	00 
  8013c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 82 0e 00 00       	call   802251 <open>
  8013cf:	89 c1                	mov    %eax,%ecx
  8013d1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	0f 88 9e 04 00 00    	js     80187d <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8013df:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8013e6:	00 
  8013e7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f1:	89 0c 24             	mov    %ecx,(%esp)
  8013f4:	e8 3e 0a 00 00       	call   801e37 <readn>
  8013f9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8013fe:	75 0c                	jne    80140c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801400:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801407:	45 4c 46 
  80140a:	74 36                	je     801442 <spawn+0x92>
		close(fd);
  80140c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 28 08 00 00       	call   801c42 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80141a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801421:	46 
  801422:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	c7 04 24 4e 32 80 00 	movl   $0x80324e,(%esp)
  801433:	e8 d4 ee ff ff       	call   80030c <cprintf>
		return -E_NOT_EXEC;
  801438:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80143d:	e9 9a 04 00 00       	jmp    8018dc <spawn+0x52c>
  801442:	b8 07 00 00 00       	mov    $0x7,%eax
  801447:	cd 30                	int    $0x30
  801449:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80144f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801455:	85 c0                	test   %eax,%eax
  801457:	0f 88 28 04 00 00    	js     801885 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80145d:	89 c6                	mov    %eax,%esi
  80145f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801465:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801468:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80146e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801474:	b9 11 00 00 00       	mov    $0x11,%ecx
  801479:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80147b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801481:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80148c:	be 00 00 00 00       	mov    $0x0,%esi
  801491:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801494:	eb 0f                	jmp    8014a5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 b2 f4 ff ff       	call   800950 <strlen>
  80149e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8014a2:	83 c3 01             	add    $0x1,%ebx
  8014a5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8014ac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	75 e3                	jne    801496 <spawn+0xe6>
  8014b3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8014b9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8014bf:	bf 00 10 40 00       	mov    $0x401000,%edi
  8014c4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8014c6:	89 fa                	mov    %edi,%edx
  8014c8:	83 e2 fc             	and    $0xfffffffc,%edx
  8014cb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8014d2:	29 c2                	sub    %eax,%edx
  8014d4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8014da:	8d 42 f8             	lea    -0x8(%edx),%eax
  8014dd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8014e2:	0f 86 ad 03 00 00    	jbe    801895 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8014e8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014ef:	00 
  8014f0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8014f7:	00 
  8014f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ff:	e8 9f f8 ff ff       	call   800da3 <sys_page_alloc>
  801504:	85 c0                	test   %eax,%eax
  801506:	0f 88 d0 03 00 00    	js     8018dc <spawn+0x52c>
  80150c:	be 00 00 00 00       	mov    $0x0,%esi
  801511:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80151a:	eb 30                	jmp    80154c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80151c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801522:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801528:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80152b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	89 3c 24             	mov    %edi,(%esp)
  801535:	e8 4d f4 ff ff       	call   800987 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80153a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 0b f4 ff ff       	call   800950 <strlen>
  801545:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801549:	83 c6 01             	add    $0x1,%esi
  80154c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801552:	7f c8                	jg     80151c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801554:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80155a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801560:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801567:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80156d:	74 24                	je     801593 <spawn+0x1e3>
  80156f:	c7 44 24 0c d8 32 80 	movl   $0x8032d8,0xc(%esp)
  801576:	00 
  801577:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  80157e:	00 
  80157f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801586:	00 
  801587:	c7 04 24 7d 32 80 00 	movl   $0x80327d,(%esp)
  80158e:	e8 80 ec ff ff       	call   800213 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801593:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801599:	89 c8                	mov    %ecx,%eax
  80159b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8015a0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8015a3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8015a9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8015ac:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8015b2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8015b8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8015bf:	00 
  8015c0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8015c7:	ee 
  8015c8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8015ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8015d9:	00 
  8015da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e1:	e8 11 f8 ff ff       	call   800df7 <sys_page_map>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	0f 88 d6 02 00 00    	js     8018c6 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8015f0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8015f7:	00 
  8015f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ff:	e8 46 f8 ff ff       	call   800e4a <sys_page_unmap>
  801604:	89 c3                	mov    %eax,%ebx
  801606:	85 c0                	test   %eax,%eax
  801608:	0f 88 b8 02 00 00    	js     8018c6 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80160e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801614:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80161b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801621:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801628:	00 00 00 
  80162b:	e9 b6 01 00 00       	jmp    8017e6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801630:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801636:	83 38 01             	cmpl   $0x1,(%eax)
  801639:	0f 85 99 01 00 00    	jne    8017d8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80163f:	89 c1                	mov    %eax,%ecx
  801641:	8b 40 18             	mov    0x18(%eax),%eax
  801644:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801647:	83 f8 01             	cmp    $0x1,%eax
  80164a:	19 c0                	sbb    %eax,%eax
  80164c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801652:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801659:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801660:	89 c8                	mov    %ecx,%eax
  801662:	8b 51 04             	mov    0x4(%ecx),%edx
  801665:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80166b:	8b 49 10             	mov    0x10(%ecx),%ecx
  80166e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801674:	8b 50 14             	mov    0x14(%eax),%edx
  801677:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80167d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801680:	89 f0                	mov    %esi,%eax
  801682:	25 ff 0f 00 00       	and    $0xfff,%eax
  801687:	74 14                	je     80169d <spawn+0x2ed>
		va -= i;
  801689:	29 c6                	sub    %eax,%esi
		memsz += i;
  80168b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801691:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801697:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80169d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a2:	e9 23 01 00 00       	jmp    8017ca <spawn+0x41a>
		if (i >= filesz) {
  8016a7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8016ad:	77 2b                	ja     8016da <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8016af:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8016b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016bd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8016c3:	89 04 24             	mov    %eax,(%esp)
  8016c6:	e8 d8 f6 ff ff       	call   800da3 <sys_page_alloc>
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 89 eb 00 00 00    	jns    8017be <spawn+0x40e>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	e9 cc 01 00 00       	jmp    8018a6 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016da:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016e1:	00 
  8016e2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8016e9:	00 
  8016ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f1:	e8 ad f6 ff ff       	call   800da3 <sys_page_alloc>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	0f 88 9e 01 00 00    	js     80189c <spawn+0x4ec>
  8016fe:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801704:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 f7 07 00 00       	call   801f0f <seek>
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 80 01 00 00    	js     8018a0 <spawn+0x4f0>
  801720:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801726:	29 fa                	sub    %edi,%edx
  801728:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80172a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801730:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801735:	0f 47 c1             	cmova  %ecx,%eax
  801738:	89 44 24 08          	mov    %eax,0x8(%esp)
  80173c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801743:	00 
  801744:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80174a:	89 04 24             	mov    %eax,(%esp)
  80174d:	e8 e5 06 00 00       	call   801e37 <readn>
  801752:	85 c0                	test   %eax,%eax
  801754:	0f 88 4a 01 00 00    	js     8018a4 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80175a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801760:	89 44 24 10          	mov    %eax,0x10(%esp)
  801764:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801768:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80176e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801772:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801779:	00 
  80177a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801781:	e8 71 f6 ff ff       	call   800df7 <sys_page_map>
  801786:	85 c0                	test   %eax,%eax
  801788:	79 20                	jns    8017aa <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  80178a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80178e:	c7 44 24 08 89 32 80 	movl   $0x803289,0x8(%esp)
  801795:	00 
  801796:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80179d:	00 
  80179e:	c7 04 24 7d 32 80 00 	movl   $0x80327d,(%esp)
  8017a5:	e8 69 ea ff ff       	call   800213 <_panic>
			sys_page_unmap(0, UTEMP);
  8017aa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8017b1:	00 
  8017b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b9:	e8 8c f6 ff ff       	call   800e4a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8017be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8017c4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8017ca:	89 df                	mov    %ebx,%edi
  8017cc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8017d2:	0f 87 cf fe ff ff    	ja     8016a7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017d8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8017df:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8017e6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8017ed:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8017f3:	0f 8c 37 fe ff ff    	jl     801630 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8017f9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 3b 04 00 00       	call   801c42 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801807:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 d1 f6 ff ff       	call   800ef0 <sys_env_set_trapframe>
  80181f:	85 c0                	test   %eax,%eax
  801821:	79 20                	jns    801843 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801827:	c7 44 24 08 a6 32 80 	movl   $0x8032a6,0x8(%esp)
  80182e:	00 
  80182f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801836:	00 
  801837:	c7 04 24 7d 32 80 00 	movl   $0x80327d,(%esp)
  80183e:	e8 d0 e9 ff ff       	call   800213 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801843:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80184a:	00 
  80184b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801851:	89 04 24             	mov    %eax,(%esp)
  801854:	e8 44 f6 ff ff       	call   800e9d <sys_env_set_status>
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 30                	jns    80188d <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  80185d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801861:	c7 44 24 08 c0 32 80 	movl   $0x8032c0,0x8(%esp)
  801868:	00 
  801869:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801870:	00 
  801871:	c7 04 24 7d 32 80 00 	movl   $0x80327d,(%esp)
  801878:	e8 96 e9 ff ff       	call   800213 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80187d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801883:	eb 57                	jmp    8018dc <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801885:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80188b:	eb 4f                	jmp    8018dc <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80188d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801893:	eb 47                	jmp    8018dc <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801895:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80189a:	eb 40                	jmp    8018dc <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	eb 06                	jmp    8018a6 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	eb 02                	jmp    8018a6 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018a4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8018a6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	e8 5f f4 ff ff       	call   800d13 <sys_env_destroy>
	close(fd);
  8018b4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8018ba:	89 04 24             	mov    %eax,(%esp)
  8018bd:	e8 80 03 00 00       	call   801c42 <close>
	return r;
  8018c2:	89 d8                	mov    %ebx,%eax
  8018c4:	eb 16                	jmp    8018dc <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8018c6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018cd:	00 
  8018ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d5:	e8 70 f5 ff ff       	call   800e4a <sys_page_unmap>
  8018da:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8018dc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5f                   	pop    %edi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8018ef:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8018f7:	eb 03                	jmp    8018fc <spawnl+0x15>
		argc++;
  8018f9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8018fc:	83 c0 04             	add    $0x4,%eax
  8018ff:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801903:	75 f4                	jne    8018f9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801905:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80190c:	83 e0 f0             	and    $0xfffffff0,%eax
  80190f:	29 c4                	sub    %eax,%esp
  801911:	8d 44 24 0b          	lea    0xb(%esp),%eax
  801915:	c1 e8 02             	shr    $0x2,%eax
  801918:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80191f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801924:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80192b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  801932:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801933:	b8 00 00 00 00       	mov    $0x0,%eax
  801938:	eb 0a                	jmp    801944 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80193a:	83 c0 01             	add    $0x1,%eax
  80193d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801941:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801944:	39 d0                	cmp    %edx,%eax
  801946:	75 f2                	jne    80193a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801948:	89 74 24 04          	mov    %esi,0x4(%esp)
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	e8 59 fa ff ff       	call   8013b0 <spawn>
}
  801957:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195a:	5b                   	pop    %ebx
  80195b:	5e                   	pop    %esi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	83 ec 10             	sub    $0x10,%esp
  801966:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801969:	85 f6                	test   %esi,%esi
  80196b:	75 24                	jne    801991 <wait+0x33>
  80196d:	c7 44 24 0c fe 32 80 	movl   $0x8032fe,0xc(%esp)
  801974:	00 
  801975:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  80197c:	00 
  80197d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801984:	00 
  801985:	c7 04 24 09 33 80 00 	movl   $0x803309,(%esp)
  80198c:	e8 82 e8 ff ff       	call   800213 <_panic>
	e = &envs[ENVX(envid)];
  801991:	89 f3                	mov    %esi,%ebx
  801993:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801999:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80199c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8019a2:	eb 05                	jmp    8019a9 <wait+0x4b>
		sys_yield();
  8019a4:	e8 db f3 ff ff       	call   800d84 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8019a9:	8b 43 48             	mov    0x48(%ebx),%eax
  8019ac:	39 f0                	cmp    %esi,%eax
  8019ae:	75 07                	jne    8019b7 <wait+0x59>
  8019b0:	8b 43 54             	mov    0x54(%ebx),%eax
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	75 ed                	jne    8019a4 <wait+0x46>
		sys_yield();
}
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019c4:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8019cb:	75 44                	jne    801a11 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8019cd:	a1 04 50 80 00       	mov    0x805004,%eax
  8019d2:	8b 40 48             	mov    0x48(%eax),%eax
  8019d5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019dc:	00 
  8019dd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8019e4:	ee 
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 b6 f3 ff ff       	call   800da3 <sys_page_alloc>
		if( r < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	79 20                	jns    801a11 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  8019f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f5:	c7 44 24 08 14 33 80 	movl   $0x803314,0x8(%esp)
  8019fc:	00 
  8019fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a04:	00 
  801a05:	c7 04 24 70 33 80 00 	movl   $0x803370,(%esp)
  801a0c:	e8 02 e8 ff ff       	call   800213 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	a3 08 50 80 00       	mov    %eax,0x805008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801a19:	e8 47 f3 ff ff       	call   800d65 <sys_getenvid>
  801a1e:	c7 44 24 04 54 1a 80 	movl   $0x801a54,0x4(%esp)
  801a25:	00 
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 15 f5 ff ff       	call   800f43 <sys_env_set_pgfault_upcall>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	79 20                	jns    801a52 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  801a32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a36:	c7 44 24 08 44 33 80 	movl   $0x803344,0x8(%esp)
  801a3d:	00 
  801a3e:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801a45:	00 
  801a46:	c7 04 24 70 33 80 00 	movl   $0x803370,(%esp)
  801a4d:	e8 c1 e7 ff ff       	call   800213 <_panic>


}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801a54:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801a55:	a1 08 50 80 00       	mov    0x805008,%eax
	call *%eax
  801a5a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801a5c:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  801a5f:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  801a63:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  801a67:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  801a6b:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  801a6e:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  801a71:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  801a74:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  801a78:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  801a7c:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  801a80:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801a84:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801a88:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  801a8c:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  801a90:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  801a91:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  801a92:	c3                   	ret    
  801a93:	66 90                	xchg   %ax,%ax
  801a95:	66 90                	xchg   %ax,%ax
  801a97:	66 90                	xchg   %ax,%ax
  801a99:	66 90                	xchg   %ax,%ax
  801a9b:	66 90                	xchg   %ax,%ax
  801a9d:	66 90                	xchg   %ax,%ax
  801a9f:	90                   	nop

00801aa0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	05 00 00 00 30       	add    $0x30000000,%eax
  801aab:	c1 e8 0c             	shr    $0xc,%eax
}
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801abb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801ac0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801acd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	c1 ea 16             	shr    $0x16,%edx
  801ad7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ade:	f6 c2 01             	test   $0x1,%dl
  801ae1:	74 11                	je     801af4 <fd_alloc+0x2d>
  801ae3:	89 c2                	mov    %eax,%edx
  801ae5:	c1 ea 0c             	shr    $0xc,%edx
  801ae8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801aef:	f6 c2 01             	test   $0x1,%dl
  801af2:	75 09                	jne    801afd <fd_alloc+0x36>
			*fd_store = fd;
  801af4:	89 01                	mov    %eax,(%ecx)
			return 0;
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
  801afb:	eb 17                	jmp    801b14 <fd_alloc+0x4d>
  801afd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b02:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b07:	75 c9                	jne    801ad2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b09:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801b0f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b1c:	83 f8 1f             	cmp    $0x1f,%eax
  801b1f:	77 36                	ja     801b57 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b21:	c1 e0 0c             	shl    $0xc,%eax
  801b24:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b29:	89 c2                	mov    %eax,%edx
  801b2b:	c1 ea 16             	shr    $0x16,%edx
  801b2e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b35:	f6 c2 01             	test   $0x1,%dl
  801b38:	74 24                	je     801b5e <fd_lookup+0x48>
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	c1 ea 0c             	shr    $0xc,%edx
  801b3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 1a                	je     801b65 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4e:	89 02                	mov    %eax,(%edx)
	return 0;
  801b50:	b8 00 00 00 00       	mov    $0x0,%eax
  801b55:	eb 13                	jmp    801b6a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b5c:	eb 0c                	jmp    801b6a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b63:	eb 05                	jmp    801b6a <fd_lookup+0x54>
  801b65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 18             	sub    $0x18,%esp
  801b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b75:	ba fc 33 80 00       	mov    $0x8033fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801b7a:	eb 13                	jmp    801b8f <dev_lookup+0x23>
  801b7c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801b7f:	39 08                	cmp    %ecx,(%eax)
  801b81:	75 0c                	jne    801b8f <dev_lookup+0x23>
			*dev = devtab[i];
  801b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b86:	89 01                	mov    %eax,(%ecx)
			return 0;
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8d:	eb 30                	jmp    801bbf <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801b8f:	8b 02                	mov    (%edx),%eax
  801b91:	85 c0                	test   %eax,%eax
  801b93:	75 e7                	jne    801b7c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801b95:	a1 04 50 80 00       	mov    0x805004,%eax
  801b9a:	8b 40 48             	mov    0x48(%eax),%eax
  801b9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba5:	c7 04 24 80 33 80 00 	movl   $0x803380,(%esp)
  801bac:	e8 5b e7 ff ff       	call   80030c <cprintf>
	*dev = 0;
  801bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801bba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 20             	sub    $0x20,%esp
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801bcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bd6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801bdc:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801bdf:	89 04 24             	mov    %eax,(%esp)
  801be2:	e8 2f ff ff ff       	call   801b16 <fd_lookup>
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 05                	js     801bf0 <fd_close+0x2f>
	    || fd != fd2)
  801beb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801bee:	74 0c                	je     801bfc <fd_close+0x3b>
		return (must_exist ? r : 0);
  801bf0:	84 db                	test   %bl,%bl
  801bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf7:	0f 44 c2             	cmove  %edx,%eax
  801bfa:	eb 3f                	jmp    801c3b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801bfc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c03:	8b 06                	mov    (%esi),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 5f ff ff ff       	call   801b6c <dev_lookup>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 16                	js     801c29 <fd_close+0x68>
		if (dev->dev_close)
  801c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c16:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801c19:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	74 07                	je     801c29 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801c22:	89 34 24             	mov    %esi,(%esp)
  801c25:	ff d0                	call   *%eax
  801c27:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c29:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c34:	e8 11 f2 ff ff       	call   800e4a <sys_page_unmap>
	return r;
  801c39:	89 d8                	mov    %ebx,%eax
}
  801c3b:	83 c4 20             	add    $0x20,%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 bc fe ff ff       	call   801b16 <fd_lookup>
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	85 d2                	test   %edx,%edx
  801c5e:	78 13                	js     801c73 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801c60:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c67:	00 
  801c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 4e ff ff ff       	call   801bc1 <fd_close>
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <close_all>:

void
close_all(void)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801c81:	89 1c 24             	mov    %ebx,(%esp)
  801c84:	e8 b9 ff ff ff       	call   801c42 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c89:	83 c3 01             	add    $0x1,%ebx
  801c8c:	83 fb 20             	cmp    $0x20,%ebx
  801c8f:	75 f0                	jne    801c81 <close_all+0xc>
		close(i);
}
  801c91:	83 c4 14             	add    $0x14,%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ca0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	89 04 24             	mov    %eax,(%esp)
  801cad:	e8 64 fe ff ff       	call   801b16 <fd_lookup>
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	85 d2                	test   %edx,%edx
  801cb6:	0f 88 e1 00 00 00    	js     801d9d <dup+0x106>
		return r;
	close(newfdnum);
  801cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 7b ff ff ff       	call   801c42 <close>

	newfd = INDEX2FD(newfdnum);
  801cc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cca:	c1 e3 0c             	shl    $0xc,%ebx
  801ccd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801cd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd6:	89 04 24             	mov    %eax,(%esp)
  801cd9:	e8 d2 fd ff ff       	call   801ab0 <fd2data>
  801cde:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801ce0:	89 1c 24             	mov    %ebx,(%esp)
  801ce3:	e8 c8 fd ff ff       	call   801ab0 <fd2data>
  801ce8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801cea:	89 f0                	mov    %esi,%eax
  801cec:	c1 e8 16             	shr    $0x16,%eax
  801cef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cf6:	a8 01                	test   $0x1,%al
  801cf8:	74 43                	je     801d3d <dup+0xa6>
  801cfa:	89 f0                	mov    %esi,%eax
  801cfc:	c1 e8 0c             	shr    $0xc,%eax
  801cff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d06:	f6 c2 01             	test   $0x1,%dl
  801d09:	74 32                	je     801d3d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801d0b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d12:	25 07 0e 00 00       	and    $0xe07,%eax
  801d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d26:	00 
  801d27:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d32:	e8 c0 f0 ff ff       	call   800df7 <sys_page_map>
  801d37:	89 c6                	mov    %eax,%esi
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 3e                	js     801d7b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	c1 ea 0c             	shr    $0xc,%edx
  801d45:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d4c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d52:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d56:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d61:	00 
  801d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6d:	e8 85 f0 ff ff       	call   800df7 <sys_page_map>
  801d72:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801d74:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d77:	85 f6                	test   %esi,%esi
  801d79:	79 22                	jns    801d9d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 bf f0 ff ff       	call   800e4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d96:	e8 af f0 ff ff       	call   800e4a <sys_page_unmap>
	return r;
  801d9b:	89 f0                	mov    %esi,%eax
}
  801d9d:	83 c4 3c             	add    $0x3c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	53                   	push   %ebx
  801da9:	83 ec 24             	sub    $0x24,%esp
  801dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801daf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db6:	89 1c 24             	mov    %ebx,(%esp)
  801db9:	e8 58 fd ff ff       	call   801b16 <fd_lookup>
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	85 d2                	test   %edx,%edx
  801dc2:	78 6d                	js     801e31 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dce:	8b 00                	mov    (%eax),%eax
  801dd0:	89 04 24             	mov    %eax,(%esp)
  801dd3:	e8 94 fd ff ff       	call   801b6c <dev_lookup>
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 55                	js     801e31 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ddf:	8b 50 08             	mov    0x8(%eax),%edx
  801de2:	83 e2 03             	and    $0x3,%edx
  801de5:	83 fa 01             	cmp    $0x1,%edx
  801de8:	75 23                	jne    801e0d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801dea:	a1 04 50 80 00       	mov    0x805004,%eax
  801def:	8b 40 48             	mov    0x48(%eax),%eax
  801df2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfa:	c7 04 24 c1 33 80 00 	movl   $0x8033c1,(%esp)
  801e01:	e8 06 e5 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801e06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e0b:	eb 24                	jmp    801e31 <read+0x8c>
	}
	if (!dev->dev_read)
  801e0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e10:	8b 52 08             	mov    0x8(%edx),%edx
  801e13:	85 d2                	test   %edx,%edx
  801e15:	74 15                	je     801e2c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e17:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801e1a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e21:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	ff d2                	call   *%edx
  801e2a:	eb 05                	jmp    801e31 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801e2c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801e31:	83 c4 24             	add    $0x24,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    

00801e37 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	57                   	push   %edi
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 1c             	sub    $0x1c,%esp
  801e40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e43:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e46:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e4b:	eb 23                	jmp    801e70 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e4d:	89 f0                	mov    %esi,%eax
  801e4f:	29 d8                	sub    %ebx,%eax
  801e51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e55:	89 d8                	mov    %ebx,%eax
  801e57:	03 45 0c             	add    0xc(%ebp),%eax
  801e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5e:	89 3c 24             	mov    %edi,(%esp)
  801e61:	e8 3f ff ff ff       	call   801da5 <read>
		if (m < 0)
  801e66:	85 c0                	test   %eax,%eax
  801e68:	78 10                	js     801e7a <readn+0x43>
			return m;
		if (m == 0)
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	74 0a                	je     801e78 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e6e:	01 c3                	add    %eax,%ebx
  801e70:	39 f3                	cmp    %esi,%ebx
  801e72:	72 d9                	jb     801e4d <readn+0x16>
  801e74:	89 d8                	mov    %ebx,%eax
  801e76:	eb 02                	jmp    801e7a <readn+0x43>
  801e78:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e7a:	83 c4 1c             	add    $0x1c,%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    

00801e82 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	53                   	push   %ebx
  801e86:	83 ec 24             	sub    $0x24,%esp
  801e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e93:	89 1c 24             	mov    %ebx,(%esp)
  801e96:	e8 7b fc ff ff       	call   801b16 <fd_lookup>
  801e9b:	89 c2                	mov    %eax,%edx
  801e9d:	85 d2                	test   %edx,%edx
  801e9f:	78 68                	js     801f09 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eab:	8b 00                	mov    (%eax),%eax
  801ead:	89 04 24             	mov    %eax,(%esp)
  801eb0:	e8 b7 fc ff ff       	call   801b6c <dev_lookup>
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	78 50                	js     801f09 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ec0:	75 23                	jne    801ee5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ec2:	a1 04 50 80 00       	mov    0x805004,%eax
  801ec7:	8b 40 48             	mov    0x48(%eax),%eax
  801eca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed2:	c7 04 24 dd 33 80 00 	movl   $0x8033dd,(%esp)
  801ed9:	e8 2e e4 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ee3:	eb 24                	jmp    801f09 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee8:	8b 52 0c             	mov    0xc(%edx),%edx
  801eeb:	85 d2                	test   %edx,%edx
  801eed:	74 15                	je     801f04 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801eef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ef2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	ff d2                	call   *%edx
  801f02:	eb 05                	jmp    801f09 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f04:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801f09:	83 c4 24             	add    $0x24,%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <seek>:

int
seek(int fdnum, off_t offset)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f15:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	89 04 24             	mov    %eax,(%esp)
  801f22:	e8 ef fb ff ff       	call   801b16 <fd_lookup>
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 0e                	js     801f39 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801f2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f31:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f39:	c9                   	leave  
  801f3a:	c3                   	ret    

00801f3b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	53                   	push   %ebx
  801f3f:	83 ec 24             	sub    $0x24,%esp
  801f42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4c:	89 1c 24             	mov    %ebx,(%esp)
  801f4f:	e8 c2 fb ff ff       	call   801b16 <fd_lookup>
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	85 d2                	test   %edx,%edx
  801f58:	78 61                	js     801fbb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f64:	8b 00                	mov    (%eax),%eax
  801f66:	89 04 24             	mov    %eax,(%esp)
  801f69:	e8 fe fb ff ff       	call   801b6c <dev_lookup>
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 49                	js     801fbb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f75:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f79:	75 23                	jne    801f9e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f7b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f80:	8b 40 48             	mov    0x48(%eax),%eax
  801f83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8b:	c7 04 24 a0 33 80 00 	movl   $0x8033a0,(%esp)
  801f92:	e8 75 e3 ff ff       	call   80030c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f9c:	eb 1d                	jmp    801fbb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fa1:	8b 52 18             	mov    0x18(%edx),%edx
  801fa4:	85 d2                	test   %edx,%edx
  801fa6:	74 0e                	je     801fb6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	ff d2                	call   *%edx
  801fb4:	eb 05                	jmp    801fbb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801fb6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801fbb:	83 c4 24             	add    $0x24,%esp
  801fbe:	5b                   	pop    %ebx
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 24             	sub    $0x24,%esp
  801fc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 39 fb ff ff       	call   801b16 <fd_lookup>
  801fdd:	89 c2                	mov    %eax,%edx
  801fdf:	85 d2                	test   %edx,%edx
  801fe1:	78 52                	js     802035 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fed:	8b 00                	mov    (%eax),%eax
  801fef:	89 04 24             	mov    %eax,(%esp)
  801ff2:	e8 75 fb ff ff       	call   801b6c <dev_lookup>
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 3a                	js     802035 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802002:	74 2c                	je     802030 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802004:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802007:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80200e:	00 00 00 
	stat->st_isdir = 0;
  802011:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802018:	00 00 00 
	stat->st_dev = dev;
  80201b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802021:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802025:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802028:	89 14 24             	mov    %edx,(%esp)
  80202b:	ff 50 14             	call   *0x14(%eax)
  80202e:	eb 05                	jmp    802035 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802030:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802035:	83 c4 24             	add    $0x24,%esp
  802038:	5b                   	pop    %ebx
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    

0080203b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	56                   	push   %esi
  80203f:	53                   	push   %ebx
  802040:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802043:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80204a:	00 
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	89 04 24             	mov    %eax,(%esp)
  802051:	e8 fb 01 00 00       	call   802251 <open>
  802056:	89 c3                	mov    %eax,%ebx
  802058:	85 db                	test   %ebx,%ebx
  80205a:	78 1b                	js     802077 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802063:	89 1c 24             	mov    %ebx,(%esp)
  802066:	e8 56 ff ff ff       	call   801fc1 <fstat>
  80206b:	89 c6                	mov    %eax,%esi
	close(fd);
  80206d:	89 1c 24             	mov    %ebx,(%esp)
  802070:	e8 cd fb ff ff       	call   801c42 <close>
	return r;
  802075:	89 f0                	mov    %esi,%eax
}
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	56                   	push   %esi
  802082:	53                   	push   %ebx
  802083:	83 ec 10             	sub    $0x10,%esp
  802086:	89 c6                	mov    %eax,%esi
  802088:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80208a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  802091:	75 11                	jne    8020a4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802093:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80209a:	e8 ce 08 00 00       	call   80296d <ipc_find_env>
  80209f:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8020a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020ab:	00 
  8020ac:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8020b3:	00 
  8020b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b8:	a1 00 50 80 00       	mov    0x805000,%eax
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 f9 07 00 00       	call   8028be <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8020c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020cc:	00 
  8020cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d8:	e8 43 07 00 00       	call   802820 <ipc_recv>
}
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8020ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8020f0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8020f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f8:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8020fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802102:	b8 02 00 00 00       	mov    $0x2,%eax
  802107:	e8 72 ff ff ff       	call   80207e <fsipc>
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802114:	8b 45 08             	mov    0x8(%ebp),%eax
  802117:	8b 40 0c             	mov    0xc(%eax),%eax
  80211a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80211f:	ba 00 00 00 00       	mov    $0x0,%edx
  802124:	b8 06 00 00 00       	mov    $0x6,%eax
  802129:	e8 50 ff ff ff       	call   80207e <fsipc>
}
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	53                   	push   %ebx
  802134:	83 ec 14             	sub    $0x14,%esp
  802137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	8b 40 0c             	mov    0xc(%eax),%eax
  802140:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802145:	ba 00 00 00 00       	mov    $0x0,%edx
  80214a:	b8 05 00 00 00       	mov    $0x5,%eax
  80214f:	e8 2a ff ff ff       	call   80207e <fsipc>
  802154:	89 c2                	mov    %eax,%edx
  802156:	85 d2                	test   %edx,%edx
  802158:	78 2b                	js     802185 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80215a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802161:	00 
  802162:	89 1c 24             	mov    %ebx,(%esp)
  802165:	e8 1d e8 ff ff       	call   800987 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80216a:	a1 80 60 80 00       	mov    0x806080,%eax
  80216f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802175:	a1 84 60 80 00       	mov    0x806084,%eax
  80217a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802180:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802185:	83 c4 14             	add    $0x14,%esp
  802188:	5b                   	pop    %ebx
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802191:	c7 44 24 08 0c 34 80 	movl   $0x80340c,0x8(%esp)
  802198:	00 
  802199:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8021a0:	00 
  8021a1:	c7 04 24 2a 34 80 00 	movl   $0x80342a,(%esp)
  8021a8:	e8 66 e0 ff ff       	call   800213 <_panic>

008021ad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	56                   	push   %esi
  8021b1:	53                   	push   %ebx
  8021b2:	83 ec 10             	sub    $0x10,%esp
  8021b5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8021be:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8021c3:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8021c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8021d3:	e8 a6 fe ff ff       	call   80207e <fsipc>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	78 6a                	js     802248 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8021de:	39 c6                	cmp    %eax,%esi
  8021e0:	73 24                	jae    802206 <devfile_read+0x59>
  8021e2:	c7 44 24 0c 35 34 80 	movl   $0x803435,0xc(%esp)
  8021e9:	00 
  8021ea:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  8021f1:	00 
  8021f2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8021f9:	00 
  8021fa:	c7 04 24 2a 34 80 00 	movl   $0x80342a,(%esp)
  802201:	e8 0d e0 ff ff       	call   800213 <_panic>
	assert(r <= PGSIZE);
  802206:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80220b:	7e 24                	jle    802231 <devfile_read+0x84>
  80220d:	c7 44 24 0c 3c 34 80 	movl   $0x80343c,0xc(%esp)
  802214:	00 
  802215:	c7 44 24 08 68 32 80 	movl   $0x803268,0x8(%esp)
  80221c:	00 
  80221d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802224:	00 
  802225:	c7 04 24 2a 34 80 00 	movl   $0x80342a,(%esp)
  80222c:	e8 e2 df ff ff       	call   800213 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802231:	89 44 24 08          	mov    %eax,0x8(%esp)
  802235:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80223c:	00 
  80223d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802240:	89 04 24             	mov    %eax,(%esp)
  802243:	e8 dc e8 ff ff       	call   800b24 <memmove>
	return r;
}
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	83 c4 10             	add    $0x10,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	53                   	push   %ebx
  802255:	83 ec 24             	sub    $0x24,%esp
  802258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80225b:	89 1c 24             	mov    %ebx,(%esp)
  80225e:	e8 ed e6 ff ff       	call   800950 <strlen>
  802263:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802268:	7f 60                	jg     8022ca <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80226a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226d:	89 04 24             	mov    %eax,(%esp)
  802270:	e8 52 f8 ff ff       	call   801ac7 <fd_alloc>
  802275:	89 c2                	mov    %eax,%edx
  802277:	85 d2                	test   %edx,%edx
  802279:	78 54                	js     8022cf <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80227b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80227f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802286:	e8 fc e6 ff ff       	call   800987 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80228b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	e8 de fd ff ff       	call   80207e <fsipc>
  8022a0:	89 c3                	mov    %eax,%ebx
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	79 17                	jns    8022bd <open+0x6c>
		fd_close(fd, 0);
  8022a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022ad:	00 
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	89 04 24             	mov    %eax,(%esp)
  8022b4:	e8 08 f9 ff ff       	call   801bc1 <fd_close>
		return r;
  8022b9:	89 d8                	mov    %ebx,%eax
  8022bb:	eb 12                	jmp    8022cf <open+0x7e>
	}

	return fd2num(fd);
  8022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c0:	89 04 24             	mov    %eax,(%esp)
  8022c3:	e8 d8 f7 ff ff       	call   801aa0 <fd2num>
  8022c8:	eb 05                	jmp    8022cf <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8022ca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8022cf:	83 c4 24             	add    $0x24,%esp
  8022d2:	5b                   	pop    %ebx
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8022db:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8022e5:	e8 94 fd ff ff       	call   80207e <fsipc>
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	83 ec 10             	sub    $0x10,%esp
  8022f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fa:	89 04 24             	mov    %eax,(%esp)
  8022fd:	e8 ae f7 ff ff       	call   801ab0 <fd2data>
  802302:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802304:	c7 44 24 04 48 34 80 	movl   $0x803448,0x4(%esp)
  80230b:	00 
  80230c:	89 1c 24             	mov    %ebx,(%esp)
  80230f:	e8 73 e6 ff ff       	call   800987 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802314:	8b 46 04             	mov    0x4(%esi),%eax
  802317:	2b 06                	sub    (%esi),%eax
  802319:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80231f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802326:	00 00 00 
	stat->st_dev = &devpipe;
  802329:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  802330:	40 80 00 
	return 0;
}
  802333:	b8 00 00 00 00       	mov    $0x0,%eax
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	5b                   	pop    %ebx
  80233c:	5e                   	pop    %esi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    

0080233f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	53                   	push   %ebx
  802343:	83 ec 14             	sub    $0x14,%esp
  802346:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802349:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80234d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802354:	e8 f1 ea ff ff       	call   800e4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802359:	89 1c 24             	mov    %ebx,(%esp)
  80235c:	e8 4f f7 ff ff       	call   801ab0 <fd2data>
  802361:	89 44 24 04          	mov    %eax,0x4(%esp)
  802365:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236c:	e8 d9 ea ff ff       	call   800e4a <sys_page_unmap>
}
  802371:	83 c4 14             	add    $0x14,%esp
  802374:	5b                   	pop    %ebx
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	57                   	push   %edi
  80237b:	56                   	push   %esi
  80237c:	53                   	push   %ebx
  80237d:	83 ec 2c             	sub    $0x2c,%esp
  802380:	89 c6                	mov    %eax,%esi
  802382:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802385:	a1 04 50 80 00       	mov    0x805004,%eax
  80238a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80238d:	89 34 24             	mov    %esi,(%esp)
  802390:	e8 10 06 00 00       	call   8029a5 <pageref>
  802395:	89 c7                	mov    %eax,%edi
  802397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80239a:	89 04 24             	mov    %eax,(%esp)
  80239d:	e8 03 06 00 00       	call   8029a5 <pageref>
  8023a2:	39 c7                	cmp    %eax,%edi
  8023a4:	0f 94 c2             	sete   %dl
  8023a7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8023aa:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  8023b0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  8023b3:	39 fb                	cmp    %edi,%ebx
  8023b5:	74 21                	je     8023d8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023b7:	84 d2                	test   %dl,%dl
  8023b9:	74 ca                	je     802385 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023bb:	8b 51 58             	mov    0x58(%ecx),%edx
  8023be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023ca:	c7 04 24 4f 34 80 00 	movl   $0x80344f,(%esp)
  8023d1:	e8 36 df ff ff       	call   80030c <cprintf>
  8023d6:	eb ad                	jmp    802385 <_pipeisclosed+0xe>
	}
}
  8023d8:	83 c4 2c             	add    $0x2c,%esp
  8023db:	5b                   	pop    %ebx
  8023dc:	5e                   	pop    %esi
  8023dd:	5f                   	pop    %edi
  8023de:	5d                   	pop    %ebp
  8023df:	c3                   	ret    

008023e0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	57                   	push   %edi
  8023e4:	56                   	push   %esi
  8023e5:	53                   	push   %ebx
  8023e6:	83 ec 1c             	sub    $0x1c,%esp
  8023e9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023ec:	89 34 24             	mov    %esi,(%esp)
  8023ef:	e8 bc f6 ff ff       	call   801ab0 <fd2data>
  8023f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8023fb:	eb 45                	jmp    802442 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023fd:	89 da                	mov    %ebx,%edx
  8023ff:	89 f0                	mov    %esi,%eax
  802401:	e8 71 ff ff ff       	call   802377 <_pipeisclosed>
  802406:	85 c0                	test   %eax,%eax
  802408:	75 41                	jne    80244b <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80240a:	e8 75 e9 ff ff       	call   800d84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80240f:	8b 43 04             	mov    0x4(%ebx),%eax
  802412:	8b 0b                	mov    (%ebx),%ecx
  802414:	8d 51 20             	lea    0x20(%ecx),%edx
  802417:	39 d0                	cmp    %edx,%eax
  802419:	73 e2                	jae    8023fd <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80241b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80241e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802422:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802425:	99                   	cltd   
  802426:	c1 ea 1b             	shr    $0x1b,%edx
  802429:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80242c:	83 e1 1f             	and    $0x1f,%ecx
  80242f:	29 d1                	sub    %edx,%ecx
  802431:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802435:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802439:	83 c0 01             	add    $0x1,%eax
  80243c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243f:	83 c7 01             	add    $0x1,%edi
  802442:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802445:	75 c8                	jne    80240f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802447:	89 f8                	mov    %edi,%eax
  802449:	eb 05                	jmp    802450 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    

00802458 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	57                   	push   %edi
  80245c:	56                   	push   %esi
  80245d:	53                   	push   %ebx
  80245e:	83 ec 1c             	sub    $0x1c,%esp
  802461:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802464:	89 3c 24             	mov    %edi,(%esp)
  802467:	e8 44 f6 ff ff       	call   801ab0 <fd2data>
  80246c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80246e:	be 00 00 00 00       	mov    $0x0,%esi
  802473:	eb 3d                	jmp    8024b2 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802475:	85 f6                	test   %esi,%esi
  802477:	74 04                	je     80247d <devpipe_read+0x25>
				return i;
  802479:	89 f0                	mov    %esi,%eax
  80247b:	eb 43                	jmp    8024c0 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80247d:	89 da                	mov    %ebx,%edx
  80247f:	89 f8                	mov    %edi,%eax
  802481:	e8 f1 fe ff ff       	call   802377 <_pipeisclosed>
  802486:	85 c0                	test   %eax,%eax
  802488:	75 31                	jne    8024bb <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80248a:	e8 f5 e8 ff ff       	call   800d84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80248f:	8b 03                	mov    (%ebx),%eax
  802491:	3b 43 04             	cmp    0x4(%ebx),%eax
  802494:	74 df                	je     802475 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802496:	99                   	cltd   
  802497:	c1 ea 1b             	shr    $0x1b,%edx
  80249a:	01 d0                	add    %edx,%eax
  80249c:	83 e0 1f             	and    $0x1f,%eax
  80249f:	29 d0                	sub    %edx,%eax
  8024a1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8024a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024a9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8024ac:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024af:	83 c6 01             	add    $0x1,%esi
  8024b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024b5:	75 d8                	jne    80248f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024b7:	89 f0                	mov    %esi,%eax
  8024b9:	eb 05                	jmp    8024c0 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024bb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    

008024c8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	56                   	push   %esi
  8024cc:	53                   	push   %ebx
  8024cd:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024d3:	89 04 24             	mov    %eax,(%esp)
  8024d6:	e8 ec f5 ff ff       	call   801ac7 <fd_alloc>
  8024db:	89 c2                	mov    %eax,%edx
  8024dd:	85 d2                	test   %edx,%edx
  8024df:	0f 88 4d 01 00 00    	js     802632 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024ec:	00 
  8024ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024fb:	e8 a3 e8 ff ff       	call   800da3 <sys_page_alloc>
  802500:	89 c2                	mov    %eax,%edx
  802502:	85 d2                	test   %edx,%edx
  802504:	0f 88 28 01 00 00    	js     802632 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80250a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80250d:	89 04 24             	mov    %eax,(%esp)
  802510:	e8 b2 f5 ff ff       	call   801ac7 <fd_alloc>
  802515:	89 c3                	mov    %eax,%ebx
  802517:	85 c0                	test   %eax,%eax
  802519:	0f 88 fe 00 00 00    	js     80261d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80251f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802526:	00 
  802527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80252a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802535:	e8 69 e8 ff ff       	call   800da3 <sys_page_alloc>
  80253a:	89 c3                	mov    %eax,%ebx
  80253c:	85 c0                	test   %eax,%eax
  80253e:	0f 88 d9 00 00 00    	js     80261d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802547:	89 04 24             	mov    %eax,(%esp)
  80254a:	e8 61 f5 ff ff       	call   801ab0 <fd2data>
  80254f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802551:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802558:	00 
  802559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802564:	e8 3a e8 ff ff       	call   800da3 <sys_page_alloc>
  802569:	89 c3                	mov    %eax,%ebx
  80256b:	85 c0                	test   %eax,%eax
  80256d:	0f 88 97 00 00 00    	js     80260a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802576:	89 04 24             	mov    %eax,(%esp)
  802579:	e8 32 f5 ff ff       	call   801ab0 <fd2data>
  80257e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802585:	00 
  802586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80258a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802591:	00 
  802592:	89 74 24 04          	mov    %esi,0x4(%esp)
  802596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80259d:	e8 55 e8 ff ff       	call   800df7 <sys_page_map>
  8025a2:	89 c3                	mov    %eax,%ebx
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	78 52                	js     8025fa <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025a8:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8025ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8025bd:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8025c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025c6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d5:	89 04 24             	mov    %eax,(%esp)
  8025d8:	e8 c3 f4 ff ff       	call   801aa0 <fd2num>
  8025dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8025e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025e5:	89 04 24             	mov    %eax,(%esp)
  8025e8:	e8 b3 f4 ff ff       	call   801aa0 <fd2num>
  8025ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025f0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f8:	eb 38                	jmp    802632 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8025fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802605:	e8 40 e8 ff ff       	call   800e4a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80260a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80260d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802611:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802618:	e8 2d e8 ff ff       	call   800e4a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80261d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802620:	89 44 24 04          	mov    %eax,0x4(%esp)
  802624:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262b:	e8 1a e8 ff ff       	call   800e4a <sys_page_unmap>
  802630:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802632:	83 c4 30             	add    $0x30,%esp
  802635:	5b                   	pop    %ebx
  802636:	5e                   	pop    %esi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    

00802639 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802639:	55                   	push   %ebp
  80263a:	89 e5                	mov    %esp,%ebp
  80263c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80263f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802642:	89 44 24 04          	mov    %eax,0x4(%esp)
  802646:	8b 45 08             	mov    0x8(%ebp),%eax
  802649:	89 04 24             	mov    %eax,(%esp)
  80264c:	e8 c5 f4 ff ff       	call   801b16 <fd_lookup>
  802651:	89 c2                	mov    %eax,%edx
  802653:	85 d2                	test   %edx,%edx
  802655:	78 15                	js     80266c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802657:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265a:	89 04 24             	mov    %eax,(%esp)
  80265d:	e8 4e f4 ff ff       	call   801ab0 <fd2data>
	return _pipeisclosed(fd, p);
  802662:	89 c2                	mov    %eax,%edx
  802664:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802667:	e8 0b fd ff ff       	call   802377 <_pipeisclosed>
}
  80266c:	c9                   	leave  
  80266d:	c3                   	ret    
  80266e:	66 90                	xchg   %ax,%ax

00802670 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802673:	b8 00 00 00 00       	mov    $0x0,%eax
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    

0080267a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80267a:	55                   	push   %ebp
  80267b:	89 e5                	mov    %esp,%ebp
  80267d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802680:	c7 44 24 04 67 34 80 	movl   $0x803467,0x4(%esp)
  802687:	00 
  802688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80268b:	89 04 24             	mov    %eax,(%esp)
  80268e:	e8 f4 e2 ff ff       	call   800987 <strcpy>
	return 0;
}
  802693:	b8 00 00 00 00       	mov    $0x0,%eax
  802698:	c9                   	leave  
  802699:	c3                   	ret    

0080269a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
  8026a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026b1:	eb 31                	jmp    8026e4 <devcons_write+0x4a>
		m = n - tot;
  8026b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8026b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026b8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8026bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8026c0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026c3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026c7:	03 45 0c             	add    0xc(%ebp),%eax
  8026ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ce:	89 3c 24             	mov    %edi,(%esp)
  8026d1:	e8 4e e4 ff ff       	call   800b24 <memmove>
		sys_cputs(buf, m);
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	89 3c 24             	mov    %edi,(%esp)
  8026dd:	e8 f4 e5 ff ff       	call   800cd6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026e2:	01 f3                	add    %esi,%ebx
  8026e4:	89 d8                	mov    %ebx,%eax
  8026e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026e9:	72 c8                	jb     8026b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5e                   	pop    %esi
  8026f3:	5f                   	pop    %edi
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    

008026f6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026f6:	55                   	push   %ebp
  8026f7:	89 e5                	mov    %esp,%ebp
  8026f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8026fc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802705:	75 07                	jne    80270e <devcons_read+0x18>
  802707:	eb 2a                	jmp    802733 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802709:	e8 76 e6 ff ff       	call   800d84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80270e:	66 90                	xchg   %ax,%ax
  802710:	e8 df e5 ff ff       	call   800cf4 <sys_cgetc>
  802715:	85 c0                	test   %eax,%eax
  802717:	74 f0                	je     802709 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802719:	85 c0                	test   %eax,%eax
  80271b:	78 16                	js     802733 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80271d:	83 f8 04             	cmp    $0x4,%eax
  802720:	74 0c                	je     80272e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802722:	8b 55 0c             	mov    0xc(%ebp),%edx
  802725:	88 02                	mov    %al,(%edx)
	return 1;
  802727:	b8 01 00 00 00       	mov    $0x1,%eax
  80272c:	eb 05                	jmp    802733 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80272e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802733:	c9                   	leave  
  802734:	c3                   	ret    

00802735 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80273b:	8b 45 08             	mov    0x8(%ebp),%eax
  80273e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802741:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802748:	00 
  802749:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80274c:	89 04 24             	mov    %eax,(%esp)
  80274f:	e8 82 e5 ff ff       	call   800cd6 <sys_cputs>
}
  802754:	c9                   	leave  
  802755:	c3                   	ret    

00802756 <getchar>:

int
getchar(void)
{
  802756:	55                   	push   %ebp
  802757:	89 e5                	mov    %esp,%ebp
  802759:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80275c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802763:	00 
  802764:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80276b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802772:	e8 2e f6 ff ff       	call   801da5 <read>
	if (r < 0)
  802777:	85 c0                	test   %eax,%eax
  802779:	78 0f                	js     80278a <getchar+0x34>
		return r;
	if (r < 1)
  80277b:	85 c0                	test   %eax,%eax
  80277d:	7e 06                	jle    802785 <getchar+0x2f>
		return -E_EOF;
	return c;
  80277f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802783:	eb 05                	jmp    80278a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802785:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80278a:	c9                   	leave  
  80278b:	c3                   	ret    

0080278c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80278c:	55                   	push   %ebp
  80278d:	89 e5                	mov    %esp,%ebp
  80278f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802795:	89 44 24 04          	mov    %eax,0x4(%esp)
  802799:	8b 45 08             	mov    0x8(%ebp),%eax
  80279c:	89 04 24             	mov    %eax,(%esp)
  80279f:	e8 72 f3 ff ff       	call   801b16 <fd_lookup>
  8027a4:	85 c0                	test   %eax,%eax
  8027a6:	78 11                	js     8027b9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ab:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8027b1:	39 10                	cmp    %edx,(%eax)
  8027b3:	0f 94 c0             	sete   %al
  8027b6:	0f b6 c0             	movzbl %al,%eax
}
  8027b9:	c9                   	leave  
  8027ba:	c3                   	ret    

008027bb <opencons>:

int
opencons(void)
{
  8027bb:	55                   	push   %ebp
  8027bc:	89 e5                	mov    %esp,%ebp
  8027be:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027c4:	89 04 24             	mov    %eax,(%esp)
  8027c7:	e8 fb f2 ff ff       	call   801ac7 <fd_alloc>
		return r;
  8027cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027ce:	85 c0                	test   %eax,%eax
  8027d0:	78 40                	js     802812 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027d9:	00 
  8027da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027e8:	e8 b6 e5 ff ff       	call   800da3 <sys_page_alloc>
		return r;
  8027ed:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027ef:	85 c0                	test   %eax,%eax
  8027f1:	78 1f                	js     802812 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027f3:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8027f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027fc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802801:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802808:	89 04 24             	mov    %eax,(%esp)
  80280b:	e8 90 f2 ff ff       	call   801aa0 <fd2num>
  802810:	89 c2                	mov    %eax,%edx
}
  802812:	89 d0                	mov    %edx,%eax
  802814:	c9                   	leave  
  802815:	c3                   	ret    
  802816:	66 90                	xchg   %ax,%ax
  802818:	66 90                	xchg   %ax,%ax
  80281a:	66 90                	xchg   %ax,%ax
  80281c:	66 90                	xchg   %ax,%ax
  80281e:	66 90                	xchg   %ax,%ax

00802820 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	56                   	push   %esi
  802824:	53                   	push   %ebx
  802825:	83 ec 10             	sub    $0x10,%esp
  802828:	8b 75 08             	mov    0x8(%ebp),%esi
  80282b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80282e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802831:	85 c0                	test   %eax,%eax
  802833:	75 0e                	jne    802843 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802835:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80283c:	e8 78 e7 ff ff       	call   800fb9 <sys_ipc_recv>
  802841:	eb 08                	jmp    80284b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802843:	89 04 24             	mov    %eax,(%esp)
  802846:	e8 6e e7 ff ff       	call   800fb9 <sys_ipc_recv>
	if(r == 0){
  80284b:	85 c0                	test   %eax,%eax
  80284d:	8d 76 00             	lea    0x0(%esi),%esi
  802850:	75 1e                	jne    802870 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802852:	85 f6                	test   %esi,%esi
  802854:	74 0a                	je     802860 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802856:	a1 04 50 80 00       	mov    0x805004,%eax
  80285b:	8b 40 74             	mov    0x74(%eax),%eax
  80285e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802860:	85 db                	test   %ebx,%ebx
  802862:	74 2c                	je     802890 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802864:	a1 04 50 80 00       	mov    0x805004,%eax
  802869:	8b 40 78             	mov    0x78(%eax),%eax
  80286c:	89 03                	mov    %eax,(%ebx)
  80286e:	eb 20                	jmp    802890 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802870:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802874:	c7 44 24 08 74 34 80 	movl   $0x803474,0x8(%esp)
  80287b:	00 
  80287c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802883:	00 
  802884:	c7 04 24 f0 34 80 00 	movl   $0x8034f0,(%esp)
  80288b:	e8 83 d9 ff ff       	call   800213 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802890:	a1 04 50 80 00       	mov    0x805004,%eax
  802895:	8b 50 70             	mov    0x70(%eax),%edx
  802898:	85 d2                	test   %edx,%edx
  80289a:	75 13                	jne    8028af <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80289c:	8b 40 48             	mov    0x48(%eax),%eax
  80289f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028a3:	c7 04 24 a4 34 80 00 	movl   $0x8034a4,(%esp)
  8028aa:	e8 5d da ff ff       	call   80030c <cprintf>
	return thisenv->env_ipc_value;
  8028af:	a1 04 50 80 00       	mov    0x805004,%eax
  8028b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028b7:	83 c4 10             	add    $0x10,%esp
  8028ba:	5b                   	pop    %ebx
  8028bb:	5e                   	pop    %esi
  8028bc:	5d                   	pop    %ebp
  8028bd:	c3                   	ret    

008028be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028be:	55                   	push   %ebp
  8028bf:	89 e5                	mov    %esp,%ebp
  8028c1:	57                   	push   %edi
  8028c2:	56                   	push   %esi
  8028c3:	53                   	push   %ebx
  8028c4:	83 ec 1c             	sub    $0x1c,%esp
  8028c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8028ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8028cd:	85 f6                	test   %esi,%esi
  8028cf:	75 22                	jne    8028f3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8028d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8028d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8028df:	ee 
  8028e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028e7:	89 3c 24             	mov    %edi,(%esp)
  8028ea:	e8 a7 e6 ff ff       	call   800f96 <sys_ipc_try_send>
  8028ef:	89 c3                	mov    %eax,%ebx
  8028f1:	eb 1c                	jmp    80290f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8028f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8028f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028fa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8028fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802901:	89 44 24 04          	mov    %eax,0x4(%esp)
  802905:	89 3c 24             	mov    %edi,(%esp)
  802908:	e8 89 e6 ff ff       	call   800f96 <sys_ipc_try_send>
  80290d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80290f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802912:	74 3e                	je     802952 <ipc_send+0x94>
  802914:	89 d8                	mov    %ebx,%eax
  802916:	c1 e8 1f             	shr    $0x1f,%eax
  802919:	84 c0                	test   %al,%al
  80291b:	74 35                	je     802952 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80291d:	e8 43 e4 ff ff       	call   800d65 <sys_getenvid>
  802922:	89 44 24 04          	mov    %eax,0x4(%esp)
  802926:	c7 04 24 fa 34 80 00 	movl   $0x8034fa,(%esp)
  80292d:	e8 da d9 ff ff       	call   80030c <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802932:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802936:	c7 44 24 08 c8 34 80 	movl   $0x8034c8,0x8(%esp)
  80293d:	00 
  80293e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802945:	00 
  802946:	c7 04 24 f0 34 80 00 	movl   $0x8034f0,(%esp)
  80294d:	e8 c1 d8 ff ff       	call   800213 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802952:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802955:	75 0e                	jne    802965 <ipc_send+0xa7>
			sys_yield();
  802957:	e8 28 e4 ff ff       	call   800d84 <sys_yield>
		else break;
	}
  80295c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802960:	e9 68 ff ff ff       	jmp    8028cd <ipc_send+0xf>
	
}
  802965:	83 c4 1c             	add    $0x1c,%esp
  802968:	5b                   	pop    %ebx
  802969:	5e                   	pop    %esi
  80296a:	5f                   	pop    %edi
  80296b:	5d                   	pop    %ebp
  80296c:	c3                   	ret    

0080296d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80296d:	55                   	push   %ebp
  80296e:	89 e5                	mov    %esp,%ebp
  802970:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802973:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802978:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80297b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802981:	8b 52 50             	mov    0x50(%edx),%edx
  802984:	39 ca                	cmp    %ecx,%edx
  802986:	75 0d                	jne    802995 <ipc_find_env+0x28>
			return envs[i].env_id;
  802988:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80298b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802990:	8b 40 40             	mov    0x40(%eax),%eax
  802993:	eb 0e                	jmp    8029a3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802995:	83 c0 01             	add    $0x1,%eax
  802998:	3d 00 04 00 00       	cmp    $0x400,%eax
  80299d:	75 d9                	jne    802978 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80299f:	66 b8 00 00          	mov    $0x0,%ax
}
  8029a3:	5d                   	pop    %ebp
  8029a4:	c3                   	ret    

008029a5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029a5:	55                   	push   %ebp
  8029a6:	89 e5                	mov    %esp,%ebp
  8029a8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029ab:	89 d0                	mov    %edx,%eax
  8029ad:	c1 e8 16             	shr    $0x16,%eax
  8029b0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029b7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029bc:	f6 c1 01             	test   $0x1,%cl
  8029bf:	74 1d                	je     8029de <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029c1:	c1 ea 0c             	shr    $0xc,%edx
  8029c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029cb:	f6 c2 01             	test   $0x1,%dl
  8029ce:	74 0e                	je     8029de <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029d0:	c1 ea 0c             	shr    $0xc,%edx
  8029d3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029da:	ef 
  8029db:	0f b7 c0             	movzwl %ax,%eax
}
  8029de:	5d                   	pop    %ebp
  8029df:	c3                   	ret    

008029e0 <__udivdi3>:
  8029e0:	55                   	push   %ebp
  8029e1:	57                   	push   %edi
  8029e2:	56                   	push   %esi
  8029e3:	83 ec 0c             	sub    $0xc,%esp
  8029e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8029ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8029ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8029f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8029f6:	85 c0                	test   %eax,%eax
  8029f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029fc:	89 ea                	mov    %ebp,%edx
  8029fe:	89 0c 24             	mov    %ecx,(%esp)
  802a01:	75 2d                	jne    802a30 <__udivdi3+0x50>
  802a03:	39 e9                	cmp    %ebp,%ecx
  802a05:	77 61                	ja     802a68 <__udivdi3+0x88>
  802a07:	85 c9                	test   %ecx,%ecx
  802a09:	89 ce                	mov    %ecx,%esi
  802a0b:	75 0b                	jne    802a18 <__udivdi3+0x38>
  802a0d:	b8 01 00 00 00       	mov    $0x1,%eax
  802a12:	31 d2                	xor    %edx,%edx
  802a14:	f7 f1                	div    %ecx
  802a16:	89 c6                	mov    %eax,%esi
  802a18:	31 d2                	xor    %edx,%edx
  802a1a:	89 e8                	mov    %ebp,%eax
  802a1c:	f7 f6                	div    %esi
  802a1e:	89 c5                	mov    %eax,%ebp
  802a20:	89 f8                	mov    %edi,%eax
  802a22:	f7 f6                	div    %esi
  802a24:	89 ea                	mov    %ebp,%edx
  802a26:	83 c4 0c             	add    $0xc,%esp
  802a29:	5e                   	pop    %esi
  802a2a:	5f                   	pop    %edi
  802a2b:	5d                   	pop    %ebp
  802a2c:	c3                   	ret    
  802a2d:	8d 76 00             	lea    0x0(%esi),%esi
  802a30:	39 e8                	cmp    %ebp,%eax
  802a32:	77 24                	ja     802a58 <__udivdi3+0x78>
  802a34:	0f bd e8             	bsr    %eax,%ebp
  802a37:	83 f5 1f             	xor    $0x1f,%ebp
  802a3a:	75 3c                	jne    802a78 <__udivdi3+0x98>
  802a3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802a40:	39 34 24             	cmp    %esi,(%esp)
  802a43:	0f 86 9f 00 00 00    	jbe    802ae8 <__udivdi3+0x108>
  802a49:	39 d0                	cmp    %edx,%eax
  802a4b:	0f 82 97 00 00 00    	jb     802ae8 <__udivdi3+0x108>
  802a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a58:	31 d2                	xor    %edx,%edx
  802a5a:	31 c0                	xor    %eax,%eax
  802a5c:	83 c4 0c             	add    $0xc,%esp
  802a5f:	5e                   	pop    %esi
  802a60:	5f                   	pop    %edi
  802a61:	5d                   	pop    %ebp
  802a62:	c3                   	ret    
  802a63:	90                   	nop
  802a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a68:	89 f8                	mov    %edi,%eax
  802a6a:	f7 f1                	div    %ecx
  802a6c:	31 d2                	xor    %edx,%edx
  802a6e:	83 c4 0c             	add    $0xc,%esp
  802a71:	5e                   	pop    %esi
  802a72:	5f                   	pop    %edi
  802a73:	5d                   	pop    %ebp
  802a74:	c3                   	ret    
  802a75:	8d 76 00             	lea    0x0(%esi),%esi
  802a78:	89 e9                	mov    %ebp,%ecx
  802a7a:	8b 3c 24             	mov    (%esp),%edi
  802a7d:	d3 e0                	shl    %cl,%eax
  802a7f:	89 c6                	mov    %eax,%esi
  802a81:	b8 20 00 00 00       	mov    $0x20,%eax
  802a86:	29 e8                	sub    %ebp,%eax
  802a88:	89 c1                	mov    %eax,%ecx
  802a8a:	d3 ef                	shr    %cl,%edi
  802a8c:	89 e9                	mov    %ebp,%ecx
  802a8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802a92:	8b 3c 24             	mov    (%esp),%edi
  802a95:	09 74 24 08          	or     %esi,0x8(%esp)
  802a99:	89 d6                	mov    %edx,%esi
  802a9b:	d3 e7                	shl    %cl,%edi
  802a9d:	89 c1                	mov    %eax,%ecx
  802a9f:	89 3c 24             	mov    %edi,(%esp)
  802aa2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802aa6:	d3 ee                	shr    %cl,%esi
  802aa8:	89 e9                	mov    %ebp,%ecx
  802aaa:	d3 e2                	shl    %cl,%edx
  802aac:	89 c1                	mov    %eax,%ecx
  802aae:	d3 ef                	shr    %cl,%edi
  802ab0:	09 d7                	or     %edx,%edi
  802ab2:	89 f2                	mov    %esi,%edx
  802ab4:	89 f8                	mov    %edi,%eax
  802ab6:	f7 74 24 08          	divl   0x8(%esp)
  802aba:	89 d6                	mov    %edx,%esi
  802abc:	89 c7                	mov    %eax,%edi
  802abe:	f7 24 24             	mull   (%esp)
  802ac1:	39 d6                	cmp    %edx,%esi
  802ac3:	89 14 24             	mov    %edx,(%esp)
  802ac6:	72 30                	jb     802af8 <__udivdi3+0x118>
  802ac8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802acc:	89 e9                	mov    %ebp,%ecx
  802ace:	d3 e2                	shl    %cl,%edx
  802ad0:	39 c2                	cmp    %eax,%edx
  802ad2:	73 05                	jae    802ad9 <__udivdi3+0xf9>
  802ad4:	3b 34 24             	cmp    (%esp),%esi
  802ad7:	74 1f                	je     802af8 <__udivdi3+0x118>
  802ad9:	89 f8                	mov    %edi,%eax
  802adb:	31 d2                	xor    %edx,%edx
  802add:	e9 7a ff ff ff       	jmp    802a5c <__udivdi3+0x7c>
  802ae2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ae8:	31 d2                	xor    %edx,%edx
  802aea:	b8 01 00 00 00       	mov    $0x1,%eax
  802aef:	e9 68 ff ff ff       	jmp    802a5c <__udivdi3+0x7c>
  802af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802af8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802afb:	31 d2                	xor    %edx,%edx
  802afd:	83 c4 0c             	add    $0xc,%esp
  802b00:	5e                   	pop    %esi
  802b01:	5f                   	pop    %edi
  802b02:	5d                   	pop    %ebp
  802b03:	c3                   	ret    
  802b04:	66 90                	xchg   %ax,%ax
  802b06:	66 90                	xchg   %ax,%ax
  802b08:	66 90                	xchg   %ax,%ax
  802b0a:	66 90                	xchg   %ax,%ax
  802b0c:	66 90                	xchg   %ax,%ax
  802b0e:	66 90                	xchg   %ax,%ax

00802b10 <__umoddi3>:
  802b10:	55                   	push   %ebp
  802b11:	57                   	push   %edi
  802b12:	56                   	push   %esi
  802b13:	83 ec 14             	sub    $0x14,%esp
  802b16:	8b 44 24 28          	mov    0x28(%esp),%eax
  802b1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802b1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802b22:	89 c7                	mov    %eax,%edi
  802b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b28:	8b 44 24 30          	mov    0x30(%esp),%eax
  802b2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802b30:	89 34 24             	mov    %esi,(%esp)
  802b33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b37:	85 c0                	test   %eax,%eax
  802b39:	89 c2                	mov    %eax,%edx
  802b3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b3f:	75 17                	jne    802b58 <__umoddi3+0x48>
  802b41:	39 fe                	cmp    %edi,%esi
  802b43:	76 4b                	jbe    802b90 <__umoddi3+0x80>
  802b45:	89 c8                	mov    %ecx,%eax
  802b47:	89 fa                	mov    %edi,%edx
  802b49:	f7 f6                	div    %esi
  802b4b:	89 d0                	mov    %edx,%eax
  802b4d:	31 d2                	xor    %edx,%edx
  802b4f:	83 c4 14             	add    $0x14,%esp
  802b52:	5e                   	pop    %esi
  802b53:	5f                   	pop    %edi
  802b54:	5d                   	pop    %ebp
  802b55:	c3                   	ret    
  802b56:	66 90                	xchg   %ax,%ax
  802b58:	39 f8                	cmp    %edi,%eax
  802b5a:	77 54                	ja     802bb0 <__umoddi3+0xa0>
  802b5c:	0f bd e8             	bsr    %eax,%ebp
  802b5f:	83 f5 1f             	xor    $0x1f,%ebp
  802b62:	75 5c                	jne    802bc0 <__umoddi3+0xb0>
  802b64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802b68:	39 3c 24             	cmp    %edi,(%esp)
  802b6b:	0f 87 e7 00 00 00    	ja     802c58 <__umoddi3+0x148>
  802b71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b75:	29 f1                	sub    %esi,%ecx
  802b77:	19 c7                	sbb    %eax,%edi
  802b79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b81:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802b89:	83 c4 14             	add    $0x14,%esp
  802b8c:	5e                   	pop    %esi
  802b8d:	5f                   	pop    %edi
  802b8e:	5d                   	pop    %ebp
  802b8f:	c3                   	ret    
  802b90:	85 f6                	test   %esi,%esi
  802b92:	89 f5                	mov    %esi,%ebp
  802b94:	75 0b                	jne    802ba1 <__umoddi3+0x91>
  802b96:	b8 01 00 00 00       	mov    $0x1,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	f7 f6                	div    %esi
  802b9f:	89 c5                	mov    %eax,%ebp
  802ba1:	8b 44 24 04          	mov    0x4(%esp),%eax
  802ba5:	31 d2                	xor    %edx,%edx
  802ba7:	f7 f5                	div    %ebp
  802ba9:	89 c8                	mov    %ecx,%eax
  802bab:	f7 f5                	div    %ebp
  802bad:	eb 9c                	jmp    802b4b <__umoddi3+0x3b>
  802baf:	90                   	nop
  802bb0:	89 c8                	mov    %ecx,%eax
  802bb2:	89 fa                	mov    %edi,%edx
  802bb4:	83 c4 14             	add    $0x14,%esp
  802bb7:	5e                   	pop    %esi
  802bb8:	5f                   	pop    %edi
  802bb9:	5d                   	pop    %ebp
  802bba:	c3                   	ret    
  802bbb:	90                   	nop
  802bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bc0:	8b 04 24             	mov    (%esp),%eax
  802bc3:	be 20 00 00 00       	mov    $0x20,%esi
  802bc8:	89 e9                	mov    %ebp,%ecx
  802bca:	29 ee                	sub    %ebp,%esi
  802bcc:	d3 e2                	shl    %cl,%edx
  802bce:	89 f1                	mov    %esi,%ecx
  802bd0:	d3 e8                	shr    %cl,%eax
  802bd2:	89 e9                	mov    %ebp,%ecx
  802bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bd8:	8b 04 24             	mov    (%esp),%eax
  802bdb:	09 54 24 04          	or     %edx,0x4(%esp)
  802bdf:	89 fa                	mov    %edi,%edx
  802be1:	d3 e0                	shl    %cl,%eax
  802be3:	89 f1                	mov    %esi,%ecx
  802be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802be9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802bed:	d3 ea                	shr    %cl,%edx
  802bef:	89 e9                	mov    %ebp,%ecx
  802bf1:	d3 e7                	shl    %cl,%edi
  802bf3:	89 f1                	mov    %esi,%ecx
  802bf5:	d3 e8                	shr    %cl,%eax
  802bf7:	89 e9                	mov    %ebp,%ecx
  802bf9:	09 f8                	or     %edi,%eax
  802bfb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802bff:	f7 74 24 04          	divl   0x4(%esp)
  802c03:	d3 e7                	shl    %cl,%edi
  802c05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c09:	89 d7                	mov    %edx,%edi
  802c0b:	f7 64 24 08          	mull   0x8(%esp)
  802c0f:	39 d7                	cmp    %edx,%edi
  802c11:	89 c1                	mov    %eax,%ecx
  802c13:	89 14 24             	mov    %edx,(%esp)
  802c16:	72 2c                	jb     802c44 <__umoddi3+0x134>
  802c18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802c1c:	72 22                	jb     802c40 <__umoddi3+0x130>
  802c1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802c22:	29 c8                	sub    %ecx,%eax
  802c24:	19 d7                	sbb    %edx,%edi
  802c26:	89 e9                	mov    %ebp,%ecx
  802c28:	89 fa                	mov    %edi,%edx
  802c2a:	d3 e8                	shr    %cl,%eax
  802c2c:	89 f1                	mov    %esi,%ecx
  802c2e:	d3 e2                	shl    %cl,%edx
  802c30:	89 e9                	mov    %ebp,%ecx
  802c32:	d3 ef                	shr    %cl,%edi
  802c34:	09 d0                	or     %edx,%eax
  802c36:	89 fa                	mov    %edi,%edx
  802c38:	83 c4 14             	add    $0x14,%esp
  802c3b:	5e                   	pop    %esi
  802c3c:	5f                   	pop    %edi
  802c3d:	5d                   	pop    %ebp
  802c3e:	c3                   	ret    
  802c3f:	90                   	nop
  802c40:	39 d7                	cmp    %edx,%edi
  802c42:	75 da                	jne    802c1e <__umoddi3+0x10e>
  802c44:	8b 14 24             	mov    (%esp),%edx
  802c47:	89 c1                	mov    %eax,%ecx
  802c49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802c4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802c51:	eb cb                	jmp    802c1e <__umoddi3+0x10e>
  802c53:	90                   	nop
  802c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802c5c:	0f 82 0f ff ff ff    	jb     802b71 <__umoddi3+0x61>
  802c62:	e9 1a ff ff ff       	jmp    802b81 <__umoddi3+0x71>
