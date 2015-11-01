
obj/user/sendpage：     文件格式 elf32-i386


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
  80002c:	e8 c7 01 00 00       	call   8001f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 d4 10 00 00       	call   801112 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 c9 00 00 00    	jne    800112 <umain+0xdf>
		// Child
		cprintf("child\n");
  800049:	c7 04 24 a0 18 80 00 	movl   $0x8018a0,(%esp)
  800050:	e8 a2 02 00 00       	call   8002f7 <cprintf>
		ipc_recv(&who, (void*)TEMP_ADDR_CHILD, 0);
  800055:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80005c:	00 
  80005d:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800064:	00 
  800065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800068:	89 04 24             	mov    %eax,(%esp)
  80006b:	e8 e0 12 00 00       	call   801350 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800070:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800077:	00 
  800078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80007b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007f:	c7 04 24 a7 18 80 00 	movl   $0x8018a7,(%esp)
  800086:	e8 6c 02 00 00       	call   8002f7 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80008b:	a1 04 20 80 00       	mov    0x802004,%eax
  800090:	89 04 24             	mov    %eax,(%esp)
  800093:	e8 a8 08 00 00       	call   800940 <strlen>
  800098:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009c:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a5:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000ac:	e8 a1 09 00 00       	call   800a52 <strncmp>
  8000b1:	85 c0                	test   %eax,%eax
  8000b3:	75 0c                	jne    8000c1 <umain+0x8e>
			cprintf("child received correct message\n");
  8000b5:	c7 04 24 c4 18 80 00 	movl   $0x8018c4,(%esp)
  8000bc:	e8 36 02 00 00       	call   8002f7 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000c1:	a1 00 20 80 00       	mov    0x802000,%eax
  8000c6:	89 04 24             	mov    %eax,(%esp)
  8000c9:	e8 72 08 00 00       	call   800940 <strlen>
  8000ce:	83 c0 01             	add    $0x1,%eax
  8000d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000d5:	a1 00 20 80 00       	mov    0x802000,%eax
  8000da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000de:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000e5:	e8 92 0a 00 00       	call   800b7c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000ea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000f9:	00 
  8000fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800101:	00 
  800102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 e1 12 00 00       	call   8013ee <ipc_send>
		return;
  80010d:	e9 e4 00 00 00       	jmp    8001f6 <umain+0x1c3>
	}

	// Parent

	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800112:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800117:	8b 40 48             	mov    0x48(%eax),%eax
  80011a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800121:	00 
  800122:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800129:	00 
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 61 0c 00 00       	call   800d93 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800132:	a1 04 20 80 00       	mov    0x802004,%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 01 08 00 00       	call   800940 <strlen>
  80013f:	83 c0 01             	add    $0x1,%eax
  800142:	89 44 24 08          	mov    %eax,0x8(%esp)
  800146:	a1 04 20 80 00       	mov    0x802004,%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800156:	e8 21 0a 00 00       	call   800b7c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80015b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800162:	00 
  800163:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80016a:	00 
  80016b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800172:	00 
  800173:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 70 12 00 00       	call   8013ee <ipc_send>
	cprintf("parent\n");
  80017e:	c7 04 24 bb 18 80 00 	movl   $0x8018bb,(%esp)
  800185:	e8 6d 01 00 00       	call   8002f7 <cprintf>
	ipc_recv(&who, TEMP_ADDR, 0);
  80018a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800191:	00 
  800192:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800199:	00 
  80019a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 ab 11 00 00       	call   801350 <ipc_recv>

	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8001a5:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001ac:	00 
  8001ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 a7 18 80 00 	movl   $0x8018a7,(%esp)
  8001bb:	e8 37 01 00 00       	call   8002f7 <cprintf>

	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001c0:	a1 00 20 80 00       	mov    0x802000,%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	e8 73 07 00 00       	call   800940 <strlen>
  8001cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d1:	a1 00 20 80 00       	mov    0x802000,%eax
  8001d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001da:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001e1:	e8 6c 08 00 00       	call   800a52 <strncmp>
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	75 0c                	jne    8001f6 <umain+0x1c3>
		cprintf("parent received correct message\n");
  8001ea:	c7 04 24 e4 18 80 00 	movl   $0x8018e4,(%esp)
  8001f1:	e8 01 01 00 00       	call   8002f7 <cprintf>
	return;
}
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 10             	sub    $0x10,%esp
  800200:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800203:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800206:	e8 4a 0b 00 00       	call   800d55 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80020b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800210:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800213:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800218:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80021d:	85 db                	test   %ebx,%ebx
  80021f:	7e 07                	jle    800228 <libmain+0x30>
		binaryname = argv[0];
  800221:	8b 06                	mov    (%esi),%eax
  800223:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800228:	89 74 24 04          	mov    %esi,0x4(%esp)
  80022c:	89 1c 24             	mov    %ebx,(%esp)
  80022f:	e8 ff fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800234:	e8 07 00 00 00       	call   800240 <exit>
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800246:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80024d:	e8 b1 0a 00 00       	call   800d03 <sys_env_destroy>
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	53                   	push   %ebx
  800258:	83 ec 14             	sub    $0x14,%esp
  80025b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025e:	8b 13                	mov    (%ebx),%edx
  800260:	8d 42 01             	lea    0x1(%edx),%eax
  800263:	89 03                	mov    %eax,(%ebx)
  800265:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800268:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80026c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800271:	75 19                	jne    80028c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800273:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80027a:	00 
  80027b:	8d 43 08             	lea    0x8(%ebx),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	e8 40 0a 00 00       	call   800cc6 <sys_cputs>
		b->idx = 0;
  800286:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80028c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800290:	83 c4 14             	add    $0x14,%esp
  800293:	5b                   	pop    %ebx
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80029f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a6:	00 00 00 
	b.cnt = 0;
  8002a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cb:	c7 04 24 54 02 80 00 	movl   $0x800254,(%esp)
  8002d2:	e8 7d 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 d7 09 00 00       	call   800cc6 <sys_cputs>

	return b.cnt;
}
  8002ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800300:	89 44 24 04          	mov    %eax,0x4(%esp)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	e8 87 ff ff ff       	call   800296 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    
  800311:	66 90                	xchg   %ax,%ax
  800313:	66 90                	xchg   %ax,%ax
  800315:	66 90                	xchg   %ax,%ax
  800317:	66 90                	xchg   %ax,%ax
  800319:	66 90                	xchg   %ax,%ax
  80031b:	66 90                	xchg   %ax,%ax
  80031d:	66 90                	xchg   %ax,%ax
  80031f:	90                   	nop

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 3c             	sub    $0x3c,%esp
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	89 d7                	mov    %edx,%edi
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 c3                	mov    %eax,%ebx
  800339:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80033c:	8b 45 10             	mov    0x10(%ebp),%eax
  80033f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800342:	b9 00 00 00 00       	mov    $0x0,%ecx
  800347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80034d:	39 d9                	cmp    %ebx,%ecx
  80034f:	72 05                	jb     800356 <printnum+0x36>
  800351:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800354:	77 69                	ja     8003bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800356:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800359:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80035d:	83 ee 01             	sub    $0x1,%esi
  800360:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800364:	89 44 24 08          	mov    %eax,0x8(%esp)
  800368:	8b 44 24 08          	mov    0x8(%esp),%eax
  80036c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800370:	89 c3                	mov    %eax,%ebx
  800372:	89 d6                	mov    %edx,%esi
  800374:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800377:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80037a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80037e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 6c 12 00 00       	call   801600 <__udivdi3>
  800394:	89 d9                	mov    %ebx,%ecx
  800396:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80039a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003a5:	89 fa                	mov    %edi,%edx
  8003a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003aa:	e8 71 ff ff ff       	call   800320 <printnum>
  8003af:	eb 1b                	jmp    8003cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff d3                	call   *%ebx
  8003bd:	eb 03                	jmp    8003c2 <printnum+0xa2>
  8003bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c2:	83 ee 01             	sub    $0x1,%esi
  8003c5:	85 f6                	test   %esi,%esi
  8003c7:	7f e8                	jg     8003b1 <printnum+0x91>
  8003c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ef:	e8 3c 13 00 00       	call   801730 <__umoddi3>
  8003f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f8:	0f be 80 5c 19 80 00 	movsbl 0x80195c(%eax),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800405:	ff d0                	call   *%eax
}
  800407:	83 c4 3c             	add    $0x3c,%esp
  80040a:	5b                   	pop    %ebx
  80040b:	5e                   	pop    %esi
  80040c:	5f                   	pop    %edi
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800415:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 0a                	jae    80042a <sprintputch+0x1b>
		*b->buf++ = ch;
  800420:	8d 4a 01             	lea    0x1(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	88 02                	mov    %al,(%edx)
}
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800432:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800435:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800439:	8b 45 10             	mov    0x10(%ebp),%eax
  80043c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 44 24 04          	mov    %eax,0x4(%esp)
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 04 24             	mov    %eax,(%esp)
  80044d:	e8 02 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 3c             	sub    $0x3c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 11                	jmp    800479 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 48 04 00 00    	je     8008b8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800479:	83 c7 01             	add    $0x1,%edi
  80047c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800480:	83 f8 25             	cmp    $0x25,%eax
  800483:	75 e3                	jne    800468 <vprintfmt+0x14>
  800485:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800489:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800490:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800497:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a3:	eb 1f                	jmp    8004c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004ac:	eb 16                	jmp    8004c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b5:	eb 0d                	jmp    8004c4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8d 47 01             	lea    0x1(%edi),%eax
  8004c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ca:	0f b6 17             	movzbl (%edi),%edx
  8004cd:	0f b6 c2             	movzbl %dl,%eax
  8004d0:	83 ea 23             	sub    $0x23,%edx
  8004d3:	80 fa 55             	cmp    $0x55,%dl
  8004d6:	0f 87 bf 03 00 00    	ja     80089b <vprintfmt+0x447>
  8004dc:	0f b6 d2             	movzbl %dl,%edx
  8004df:	ff 24 95 20 1a 80 00 	jmp    *0x801a20(,%edx,4)
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004f4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004f8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004fb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004fe:	83 f9 09             	cmp    $0x9,%ecx
  800501:	77 3c                	ja     80053f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800503:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800506:	eb e9                	jmp    8004f1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 40 04             	lea    0x4(%eax),%eax
  800516:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80051c:	eb 27                	jmp    800545 <vprintfmt+0xf1>
  80051e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	0f 49 c2             	cmovns %edx,%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800531:	eb 91                	jmp    8004c4 <vprintfmt+0x70>
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800536:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80053d:	eb 85                	jmp    8004c4 <vprintfmt+0x70>
  80053f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800542:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800549:	0f 89 75 ff ff ff    	jns    8004c4 <vprintfmt+0x70>
  80054f:	e9 63 ff ff ff       	jmp    8004b7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800554:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055a:	e9 65 ff ff ff       	jmp    8004c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800562:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800574:	e9 00 ff ff ff       	jmp    800479 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	99                   	cltd   
  800583:	31 d0                	xor    %edx,%eax
  800585:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800587:	83 f8 09             	cmp    $0x9,%eax
  80058a:	7f 0b                	jg     800597 <vprintfmt+0x143>
  80058c:	8b 14 85 80 1b 80 00 	mov    0x801b80(,%eax,4),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	75 20                	jne    8005b7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059b:	c7 44 24 08 74 19 80 	movl   $0x801974,0x8(%esp)
  8005a2:	00 
  8005a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a7:	89 34 24             	mov    %esi,(%esp)
  8005aa:	e8 7d fe ff ff       	call   80042c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b2:	e9 c2 fe ff ff       	jmp    800479 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005bb:	c7 44 24 08 7d 19 80 	movl   $0x80197d,0x8(%esp)
  8005c2:	00 
  8005c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c7:	89 34 24             	mov    %esi,(%esp)
  8005ca:	e8 5d fe ff ff       	call   80042c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	e9 a2 fe ff ff       	jmp    800479 <vprintfmt+0x25>
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005e7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005e9:	85 ff                	test   %edi,%edi
  8005eb:	b8 6d 19 80 00       	mov    $0x80196d,%eax
  8005f0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005f7:	0f 84 92 00 00 00    	je     80068f <vprintfmt+0x23b>
  8005fd:	85 c9                	test   %ecx,%ecx
  8005ff:	0f 8e 98 00 00 00    	jle    80069d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	89 54 24 04          	mov    %edx,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	e8 47 03 00 00       	call   800958 <strnlen>
  800611:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800614:	29 c1                	sub    %eax,%ecx
  800616:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800619:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80061d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800620:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800623:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	eb 0f                	jmp    800636 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	83 ef 01             	sub    $0x1,%edi
  800636:	85 ff                	test   %edi,%edi
  800638:	7f ed                	jg     800627 <vprintfmt+0x1d3>
  80063a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80063d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800640:	85 c9                	test   %ecx,%ecx
  800642:	b8 00 00 00 00       	mov    $0x0,%eax
  800647:	0f 49 c1             	cmovns %ecx,%eax
  80064a:	29 c1                	sub    %eax,%ecx
  80064c:	89 75 08             	mov    %esi,0x8(%ebp)
  80064f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800652:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800655:	89 cb                	mov    %ecx,%ebx
  800657:	eb 50                	jmp    8006a9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800659:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80065d:	74 1e                	je     80067d <vprintfmt+0x229>
  80065f:	0f be d2             	movsbl %dl,%edx
  800662:	83 ea 20             	sub    $0x20,%edx
  800665:	83 fa 5e             	cmp    $0x5e,%edx
  800668:	76 13                	jbe    80067d <vprintfmt+0x229>
					putch('?', putdat);
  80066a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800671:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800678:	ff 55 08             	call   *0x8(%ebp)
  80067b:	eb 0d                	jmp    80068a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80067d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800680:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068a:	83 eb 01             	sub    $0x1,%ebx
  80068d:	eb 1a                	jmp    8006a9 <vprintfmt+0x255>
  80068f:	89 75 08             	mov    %esi,0x8(%ebp)
  800692:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800695:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800698:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80069b:	eb 0c                	jmp    8006a9 <vprintfmt+0x255>
  80069d:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a9:	83 c7 01             	add    $0x1,%edi
  8006ac:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006b0:	0f be c2             	movsbl %dl,%eax
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	74 25                	je     8006dc <vprintfmt+0x288>
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	78 9e                	js     800659 <vprintfmt+0x205>
  8006bb:	83 ee 01             	sub    $0x1,%esi
  8006be:	79 99                	jns    800659 <vprintfmt+0x205>
  8006c0:	89 df                	mov    %ebx,%edi
  8006c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c8:	eb 1a                	jmp    8006e4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d7:	83 ef 01             	sub    $0x1,%edi
  8006da:	eb 08                	jmp    8006e4 <vprintfmt+0x290>
  8006dc:	89 df                	mov    %ebx,%edi
  8006de:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e4:	85 ff                	test   %edi,%edi
  8006e6:	7f e2                	jg     8006ca <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006eb:	e9 89 fd ff ff       	jmp    800479 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7e 19                	jle    80070e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 50 04             	mov    0x4(%eax),%edx
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800700:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
  80070c:	eb 38                	jmp    800746 <vprintfmt+0x2f2>
	else if (lflag)
  80070e:	85 c9                	test   %ecx,%ecx
  800710:	74 1b                	je     80072d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 00                	mov    (%eax),%eax
  800717:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071a:	89 c1                	mov    %eax,%ecx
  80071c:	c1 f9 1f             	sar    $0x1f,%ecx
  80071f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 40 04             	lea    0x4(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
  80072b:	eb 19                	jmp    800746 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8b 00                	mov    (%eax),%eax
  800732:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800735:	89 c1                	mov    %eax,%ecx
  800737:	c1 f9 1f             	sar    $0x1f,%ecx
  80073a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 40 04             	lea    0x4(%eax),%eax
  800743:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800746:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800749:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80074c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800751:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800755:	0f 89 04 01 00 00    	jns    80085f <vprintfmt+0x40b>
				putch('-', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800766:	ff d6                	call   *%esi
				num = -(long long) num;
  800768:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076e:	f7 da                	neg    %edx
  800770:	83 d1 00             	adc    $0x0,%ecx
  800773:	f7 d9                	neg    %ecx
  800775:	e9 e5 00 00 00       	jmp    80085f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077a:	83 f9 01             	cmp    $0x1,%ecx
  80077d:	7e 10                	jle    80078f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8b 10                	mov    (%eax),%edx
  800784:	8b 48 04             	mov    0x4(%eax),%ecx
  800787:	8d 40 08             	lea    0x8(%eax),%eax
  80078a:	89 45 14             	mov    %eax,0x14(%ebp)
  80078d:	eb 26                	jmp    8007b5 <vprintfmt+0x361>
	else if (lflag)
  80078f:	85 c9                	test   %ecx,%ecx
  800791:	74 12                	je     8007a5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 10                	mov    (%eax),%edx
  800798:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079d:	8d 40 04             	lea    0x4(%eax),%eax
  8007a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a3:	eb 10                	jmp    8007b5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007af:	8d 40 04             	lea    0x4(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007b5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007ba:	e9 a0 00 00 00       	jmp    80085f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007ca:	ff d6                	call   *%esi
			putch('X', putdat);
  8007cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007d7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007e4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007e9:	e9 8b fc ff ff       	jmp    800479 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800806:	ff d6                	call   *%esi
			num = (unsigned long long)
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800812:	8d 40 04             	lea    0x4(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800818:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80081d:	eb 40                	jmp    80085f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081f:	83 f9 01             	cmp    $0x1,%ecx
  800822:	7e 10                	jle    800834 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	8b 48 04             	mov    0x4(%eax),%ecx
  80082c:	8d 40 08             	lea    0x8(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
  800832:	eb 26                	jmp    80085a <vprintfmt+0x406>
	else if (lflag)
  800834:	85 c9                	test   %ecx,%ecx
  800836:	74 12                	je     80084a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800842:	8d 40 04             	lea    0x4(%eax),%eax
  800845:	89 45 14             	mov    %eax,0x14(%ebp)
  800848:	eb 10                	jmp    80085a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8b 10                	mov    (%eax),%edx
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800854:	8d 40 04             	lea    0x4(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80085a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800863:	89 44 24 10          	mov    %eax,0x10(%esp)
  800867:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800872:	89 14 24             	mov    %edx,(%esp)
  800875:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800879:	89 da                	mov    %ebx,%edx
  80087b:	89 f0                	mov    %esi,%eax
  80087d:	e8 9e fa ff ff       	call   800320 <printnum>
			break;
  800882:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800885:	e9 ef fb ff ff       	jmp    800479 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800896:	e9 de fb ff ff       	jmp    800479 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a8:	eb 03                	jmp    8008ad <vprintfmt+0x459>
  8008aa:	83 ef 01             	sub    $0x1,%edi
  8008ad:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008b1:	75 f7                	jne    8008aa <vprintfmt+0x456>
  8008b3:	e9 c1 fb ff ff       	jmp    800479 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008b8:	83 c4 3c             	add    $0x3c,%esp
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 28             	sub    $0x28,%esp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	74 30                	je     800911 <vsnprintf+0x51>
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	7e 2c                	jle    800911 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	c7 04 24 0f 04 80 00 	movl   $0x80040f,(%esp)
  800901:	e8 4e fb ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800906:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800909:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090f:	eb 05                	jmp    800916 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800911:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800921:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 82 ff ff ff       	call   8008c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb 03                	jmp    800950 <strlen+0x10>
		n++;
  80094d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800950:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800954:	75 f7                	jne    80094d <strlen+0xd>
		n++;
	return n;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
  800966:	eb 03                	jmp    80096b <strnlen+0x13>
		n++;
  800968:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096b:	39 d0                	cmp    %edx,%eax
  80096d:	74 06                	je     800975 <strnlen+0x1d>
  80096f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800973:	75 f3                	jne    800968 <strnlen+0x10>
		n++;
	return n;
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800981:	89 c2                	mov    %eax,%edx
  800983:	83 c2 01             	add    $0x1,%edx
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80098d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800990:	84 db                	test   %bl,%bl
  800992:	75 ef                	jne    800983 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800994:	5b                   	pop    %ebx
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a1:	89 1c 24             	mov    %ebx,(%esp)
  8009a4:	e8 97 ff ff ff       	call   800940 <strlen>
	strcpy(dst + len, src);
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b0:	01 d8                	add    %ebx,%eax
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	e8 bd ff ff ff       	call   800977 <strcpy>
	return dst;
}
  8009ba:	89 d8                	mov    %ebx,%eax
  8009bc:	83 c4 08             	add    $0x8,%esp
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d2:	89 f2                	mov    %esi,%edx
  8009d4:	eb 0f                	jmp    8009e5 <strncpy+0x23>
		*dst++ = *src;
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	0f b6 01             	movzbl (%ecx),%eax
  8009dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009df:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e5:	39 da                	cmp    %ebx,%edx
  8009e7:	75 ed                	jne    8009d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e9:	89 f0                	mov    %esi,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009fd:	89 f0                	mov    %esi,%eax
  8009ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	75 0b                	jne    800a12 <strlcpy+0x23>
  800a07:	eb 1d                	jmp    800a26 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
  800a0f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a12:	39 d8                	cmp    %ebx,%eax
  800a14:	74 0b                	je     800a21 <strlcpy+0x32>
  800a16:	0f b6 0a             	movzbl (%edx),%ecx
  800a19:	84 c9                	test   %cl,%cl
  800a1b:	75 ec                	jne    800a09 <strlcpy+0x1a>
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	eb 02                	jmp    800a23 <strlcpy+0x34>
  800a21:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 07                	jmp    800abe <strfind+0x13>
		if (*s == c)
  800ab7:	38 ca                	cmp    %cl,%dl
  800ab9:	74 0a                	je     800ac5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	0f b6 10             	movzbl (%eax),%edx
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
  800afb:	89 d0                	mov    %edx,%eax
  800afd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b82:	8b 45 10             	mov    0x10(%ebp),%eax
  800b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	89 04 24             	mov    %eax,(%esp)
  800b96:	e8 79 ff ff ff       	call   800b14 <memmove>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bad:	eb 1a                	jmp    800bc9 <memcmp+0x2c>
		if (*s1 != *s2)
  800baf:	0f b6 02             	movzbl (%edx),%eax
  800bb2:	0f b6 19             	movzbl (%ecx),%ebx
  800bb5:	38 d8                	cmp    %bl,%al
  800bb7:	74 0a                	je     800bc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb9:	0f b6 c0             	movzbl %al,%eax
  800bbc:	0f b6 db             	movzbl %bl,%ebx
  800bbf:	29 d8                	sub    %ebx,%eax
  800bc1:	eb 0f                	jmp    800bd2 <memcmp+0x35>
		s1++, s2++;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc9:	39 f2                	cmp    %esi,%edx
  800bcb:	75 e2                	jne    800baf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bdf:	89 c2                	mov    %eax,%edx
  800be1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be4:	eb 07                	jmp    800bed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be6:	38 08                	cmp    %cl,(%eax)
  800be8:	74 07                	je     800bf1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	39 d0                	cmp    %edx,%eax
  800bef:	72 f5                	jb     800be6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bff:	eb 03                	jmp    800c04 <strtol+0x11>
		s++;
  800c01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c04:	0f b6 0a             	movzbl (%edx),%ecx
  800c07:	80 f9 09             	cmp    $0x9,%cl
  800c0a:	74 f5                	je     800c01 <strtol+0xe>
  800c0c:	80 f9 20             	cmp    $0x20,%cl
  800c0f:	74 f0                	je     800c01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c11:	80 f9 2b             	cmp    $0x2b,%cl
  800c14:	75 0a                	jne    800c20 <strtol+0x2d>
		s++;
  800c16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1e:	eb 11                	jmp    800c31 <strtol+0x3e>
  800c20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c25:	80 f9 2d             	cmp    $0x2d,%cl
  800c28:	75 07                	jne    800c31 <strtol+0x3e>
		s++, neg = 1;
  800c2a:	8d 52 01             	lea    0x1(%edx),%edx
  800c2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c36:	75 15                	jne    800c4d <strtol+0x5a>
  800c38:	80 3a 30             	cmpb   $0x30,(%edx)
  800c3b:	75 10                	jne    800c4d <strtol+0x5a>
  800c3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c41:	75 0a                	jne    800c4d <strtol+0x5a>
		s += 2, base = 16;
  800c43:	83 c2 02             	add    $0x2,%edx
  800c46:	b8 10 00 00 00       	mov    $0x10,%eax
  800c4b:	eb 10                	jmp    800c5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	75 0c                	jne    800c5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c53:	80 3a 30             	cmpb   $0x30,(%edx)
  800c56:	75 05                	jne    800c5d <strtol+0x6a>
		s++, base = 8;
  800c58:	83 c2 01             	add    $0x1,%edx
  800c5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c65:	0f b6 0a             	movzbl (%edx),%ecx
  800c68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c6b:	89 f0                	mov    %esi,%eax
  800c6d:	3c 09                	cmp    $0x9,%al
  800c6f:	77 08                	ja     800c79 <strtol+0x86>
			dig = *s - '0';
  800c71:	0f be c9             	movsbl %cl,%ecx
  800c74:	83 e9 30             	sub    $0x30,%ecx
  800c77:	eb 20                	jmp    800c99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c7c:	89 f0                	mov    %esi,%eax
  800c7e:	3c 19                	cmp    $0x19,%al
  800c80:	77 08                	ja     800c8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c82:	0f be c9             	movsbl %cl,%ecx
  800c85:	83 e9 57             	sub    $0x57,%ecx
  800c88:	eb 0f                	jmp    800c99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c8d:	89 f0                	mov    %esi,%eax
  800c8f:	3c 19                	cmp    $0x19,%al
  800c91:	77 16                	ja     800ca9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c93:	0f be c9             	movsbl %cl,%ecx
  800c96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c9c:	7d 0f                	jge    800cad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ca5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ca7:	eb bc                	jmp    800c65 <strtol+0x72>
  800ca9:	89 d8                	mov    %ebx,%eax
  800cab:	eb 02                	jmp    800caf <strtol+0xbc>
  800cad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800caf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb3:	74 05                	je     800cba <strtol+0xc7>
		*endptr = (char *) s;
  800cb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800cba:	f7 d8                	neg    %eax
  800cbc:	85 ff                	test   %edi,%edi
  800cbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 c3                	mov    %eax,%ebx
  800cd9:	89 c7                	mov    %eax,%edi
  800cdb:	89 c6                	mov    %eax,%esi
  800cdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	89 d3                	mov    %edx,%ebx
  800cf8:	89 d7                	mov    %edx,%edi
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d11:	b8 03 00 00 00       	mov    $0x3,%eax
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 cb                	mov    %ecx,%ebx
  800d1b:	89 cf                	mov    %ecx,%edi
  800d1d:	89 ce                	mov    %ecx,%esi
  800d1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7e 28                	jle    800d4d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d30:	00 
  800d31:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800d38:	00 
  800d39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d40:	00 
  800d41:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800d48:	e8 88 07 00 00       	call   8014d5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4d:	83 c4 2c             	add    $0x2c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_yield>:

void
sys_yield(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	b8 04 00 00 00       	mov    $0x4,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	89 f7                	mov    %esi,%edi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 28                	jle    800ddf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800dda:	e8 f6 06 00 00       	call   8014d5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ddf:	83 c4 2c             	add    $0x2c,%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	b8 05 00 00 00       	mov    $0x5,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e01:	8b 75 18             	mov    0x18(%ebp),%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 28                	jle    800e32 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e15:	00 
  800e16:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800e2d:	e8 a3 06 00 00       	call   8014d5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e32:	83 c4 2c             	add    $0x2c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 06 00 00 00       	mov    $0x6,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 28                	jle    800e85 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e68:	00 
  800e69:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800e70:	00 
  800e71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e78:	00 
  800e79:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800e80:	e8 50 06 00 00       	call   8014d5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e85:	83 c4 2c             	add    $0x2c,%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea6:	89 df                	mov    %ebx,%edi
  800ea8:	89 de                	mov    %ebx,%esi
  800eaa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	7e 28                	jle    800ed8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800ed3:	e8 fd 05 00 00       	call   8014d5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed8:	83 c4 2c             	add    $0x2c,%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 de                	mov    %ebx,%esi
  800efd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7e 28                	jle    800f2b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1e:	00 
  800f1f:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800f26:	e8 aa 05 00 00       	call   8014d5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2b:	83 c4 2c             	add    $0x2c,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f39:	be 00 00 00 00       	mov    $0x0,%esi
  800f3e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f69:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6c:	89 cb                	mov    %ecx,%ebx
  800f6e:	89 cf                	mov    %ecx,%edi
  800f70:	89 ce                	mov    %ecx,%esi
  800f72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	7e 28                	jle    800fa0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f83:	00 
  800f84:	c7 44 24 08 a8 1b 80 	movl   $0x801ba8,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 c5 1b 80 00 	movl   $0x801bc5,(%esp)
  800f9b:	e8 35 05 00 00       	call   8014d5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa0:	83 c4 2c             	add    $0x2c,%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 20             	sub    $0x20,%esp
  800fb0:	8b 5d 08             	mov    0x8(%ebp),%ebx


	void *addr = (void *) utf->utf_fault_va;
  800fb3:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  800fb5:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  800fb9:	75 3f                	jne    800ffa <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800fbb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fbf:	c7 04 24 d3 1b 80 00 	movl   $0x801bd3,(%esp)
  800fc6:	e8 2c f3 ff ff       	call   8002f7 <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  800fcb:	8b 43 28             	mov    0x28(%ebx),%eax
  800fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd2:	c7 04 24 e3 1b 80 00 	movl   $0x801be3,(%esp)
  800fd9:	e8 19 f3 ff ff       	call   8002f7 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800fde:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800fed:	00 
  800fee:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  800ff5:	e8 db 04 00 00       	call   8014d5 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800ffa:	89 f0                	mov    %esi,%eax
  800ffc:	c1 e8 0c             	shr    $0xc,%eax
  800fff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801006:	f6 c4 08             	test   $0x8,%ah
  801009:	75 1c                	jne    801027 <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80100b:	c7 44 24 08 50 1c 80 	movl   $0x801c50,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  801022:	e8 ae 04 00 00       	call   8014d5 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  801027:	e8 29 fd ff ff       	call   800d55 <sys_getenvid>
  80102c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103b:	00 
  80103c:	89 04 24             	mov    %eax,(%esp)
  80103f:	e8 4f fd ff ff       	call   800d93 <sys_page_alloc>
  801044:	85 c0                	test   %eax,%eax
  801046:	79 1c                	jns    801064 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  801048:	c7 44 24 08 70 1c 80 	movl   $0x801c70,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  80105f:	e8 71 04 00 00       	call   8014d5 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801064:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80106a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801071:	00 
  801072:	89 74 24 04          	mov    %esi,0x4(%esp)
  801076:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80107d:	e8 fa fa ff ff       	call   800b7c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801082:	e8 ce fc ff ff       	call   800d55 <sys_getenvid>
  801087:	89 c3                	mov    %eax,%ebx
  801089:	e8 c7 fc ff ff       	call   800d55 <sys_getenvid>
  80108e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801095:	00 
  801096:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80109a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80109e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010a5:	00 
  8010a6:	89 04 24             	mov    %eax,(%esp)
  8010a9:	e8 39 fd ff ff       	call   800de7 <sys_page_map>
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 20                	jns    8010d2 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  8010b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b6:	c7 44 24 08 98 1c 80 	movl   $0x801c98,0x8(%esp)
  8010bd:	00 
  8010be:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010c5:	00 
  8010c6:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  8010cd:	e8 03 04 00 00       	call   8014d5 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  8010d2:	e8 7e fc ff ff       	call   800d55 <sys_getenvid>
  8010d7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010de:	00 
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 53 fd ff ff       	call   800e3a <sys_page_unmap>
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 20                	jns    80110b <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8010eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ef:	c7 44 24 08 c8 1c 80 	movl   $0x801cc8,0x8(%esp)
  8010f6:	00 
  8010f7:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8010fe:	00 
  8010ff:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  801106:	e8 ca 03 00 00       	call   8014d5 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	53                   	push   %ebx
  801118:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80111b:	c7 04 24 a8 0f 80 00 	movl   $0x800fa8,(%esp)
  801122:	e8 04 04 00 00       	call   80152b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801127:	b8 07 00 00 00       	mov    $0x7,%eax
  80112c:	cd 30                	int    $0x30
  80112e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801131:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	79 20                	jns    801158 <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113c:	c7 44 24 08 fc 1c 80 	movl   $0x801cfc,0x8(%esp)
  801143:	00 
  801144:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80114b:	00 
  80114c:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  801153:	e8 7d 03 00 00       	call   8014d5 <_panic>
	if(childEid == 0){
  801158:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80115c:	75 1c                	jne    80117a <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80115e:	e8 f2 fb ff ff       	call   800d55 <sys_getenvid>
  801163:	25 ff 03 00 00       	and    $0x3ff,%eax
  801168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801170:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return childEid;
  801175:	e9 a0 01 00 00       	jmp    80131a <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80117a:	c7 44 24 04 c1 15 80 	movl   $0x8015c1,0x4(%esp)
  801181:	00 
  801182:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 53 fd ff ff       	call   800ee0 <sys_env_set_pgfault_upcall>
  80118d:	89 c7                	mov    %eax,%edi
	if(r < 0)
  80118f:	85 c0                	test   %eax,%eax
  801191:	79 20                	jns    8011b3 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801197:	c7 44 24 08 30 1d 80 	movl   $0x801d30,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  8011ae:	e8 22 03 00 00       	call   8014d5 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8011b3:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 16             	shr    $0x16,%edx
  8011ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d1:	f6 c2 01             	test   $0x1,%dl
  8011d4:	0f 84 f7 00 00 00    	je     8012d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011da:	c1 e8 0c             	shr    $0xc,%eax
  8011dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011e4:	f6 c2 04             	test   $0x4,%dl
  8011e7:	0f 84 e4 00 00 00    	je     8012d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8011ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011f4:	a8 01                	test   $0x1,%al
  8011f6:	0f 84 d5 00 00 00    	je     8012d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8011fc:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801202:	75 20                	jne    801224 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801204:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80120b:	00 
  80120c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801213:	ee 
  801214:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 74 fb ff ff       	call   800d93 <sys_page_alloc>
  80121f:	e9 84 00 00 00       	jmp    8012a8 <fork+0x196>
  801224:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80122a:	89 f8                	mov    %edi,%eax
  80122c:	c1 e8 0c             	shr    $0xc,%eax
  80122f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801236:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80123b:	83 f8 01             	cmp    $0x1,%eax
  80123e:	19 db                	sbb    %ebx,%ebx
  801240:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801246:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80124c:	e8 04 fb ff ff       	call   800d55 <sys_getenvid>
  801251:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801255:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801259:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80125c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801260:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 7b fb ff ff       	call   800de7 <sys_page_map>
  80126c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 35                	js     8012a8 <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801273:	e8 dd fa ff ff       	call   800d55 <sys_getenvid>
  801278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127b:	e8 d5 fa ff ff       	call   800d55 <sys_getenvid>
  801280:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801284:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801288:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80128b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 4c fb ff ff       	call   800de7 <sys_page_map>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	bf 00 00 00 00       	mov    $0x0,%edi
  8012a2:	0f 4f c7             	cmovg  %edi,%eax
  8012a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  8012a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ac:	79 23                	jns    8012d1 <fork+0x1bf>
  8012ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8012b1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b5:	c7 44 24 08 70 1d 80 	movl   $0x801d70,0x8(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8012c4:	00 
  8012c5:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  8012cc:	e8 04 02 00 00       	call   8014d5 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8012d1:	89 f1                	mov    %esi,%ecx
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8012db:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8012e1:	0f 85 de fe ff ff    	jne    8011c5 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8012e7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ee:	00 
  8012ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 93 fb ff ff       	call   800e8d <sys_env_set_status>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	79 1c                	jns    80131a <fork+0x208>
		panic("sys_env_set_status");
  8012fe:	c7 44 24 08 ff 1b 80 	movl   $0x801bff,0x8(%esp)
  801305:	00 
  801306:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80130d:	00 
  80130e:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  801315:	e8 bb 01 00 00       	call   8014d5 <_panic>
	return childEid;
}
  80131a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131d:	83 c4 2c             	add    $0x2c,%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <sfork>:

// Challenge!
int
sfork(void)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80132b:	c7 44 24 08 12 1c 80 	movl   $0x801c12,0x8(%esp)
  801332:	00 
  801333:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80133a:	00 
  80133b:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  801342:	e8 8e 01 00 00       	call   8014d5 <_panic>
  801347:	66 90                	xchg   %ax,%ax
  801349:	66 90                	xchg   %ax,%ax
  80134b:	66 90                	xchg   %ax,%ax
  80134d:	66 90                	xchg   %ax,%ax
  80134f:	90                   	nop

00801350 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	83 ec 10             	sub    $0x10,%esp
  801358:	8b 75 08             	mov    0x8(%ebp),%esi
  80135b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801361:	85 c0                	test   %eax,%eax
  801363:	75 0e                	jne    801373 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801365:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80136c:	e8 e5 fb ff ff       	call   800f56 <sys_ipc_recv>
  801371:	eb 08                	jmp    80137b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	e8 db fb ff ff       	call   800f56 <sys_ipc_recv>
	if(r == 0){
  80137b:	85 c0                	test   %eax,%eax
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	75 1e                	jne    8013a0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801382:	85 f6                	test   %esi,%esi
  801384:	74 0a                	je     801390 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801386:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80138b:	8b 40 74             	mov    0x74(%eax),%eax
  80138e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801390:	85 db                	test   %ebx,%ebx
  801392:	74 2c                	je     8013c0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801394:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801399:	8b 40 78             	mov    0x78(%eax),%eax
  80139c:	89 03                	mov    %eax,(%ebx)
  80139e:	eb 20                	jmp    8013c0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8013a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a4:	c7 44 24 08 98 1d 80 	movl   $0x801d98,0x8(%esp)
  8013ab:	00 
  8013ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013b3:	00 
  8013b4:	c7 04 24 14 1e 80 00 	movl   $0x801e14,(%esp)
  8013bb:	e8 15 01 00 00       	call   8014d5 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8013c0:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013c5:	8b 50 70             	mov    0x70(%eax),%edx
  8013c8:	85 d2                	test   %edx,%edx
  8013ca:	75 13                	jne    8013df <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8013cc:	8b 40 48             	mov    0x48(%eax),%eax
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	c7 04 24 c8 1d 80 00 	movl   $0x801dc8,(%esp)
  8013da:	e8 18 ef ff ff       	call   8002f7 <cprintf>
	return thisenv->env_ipc_value;
  8013df:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013e4:	8b 40 70             	mov    0x70(%eax),%eax
	

	


}
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 1c             	sub    $0x1c,%esp
  8013f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	
	int r =0;
	while(1){
		if(pg == 0)
  8013fd:	85 f6                	test   %esi,%esi
  8013ff:	75 22                	jne    801423 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801401:	8b 45 14             	mov    0x14(%ebp),%eax
  801404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801408:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80140f:	ee 
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	89 3c 24             	mov    %edi,(%esp)
  80141a:	e8 14 fb ff ff       	call   800f33 <sys_ipc_try_send>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	eb 1c                	jmp    80143f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801423:	8b 45 14             	mov    0x14(%ebp),%eax
  801426:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80142a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80142e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	89 3c 24             	mov    %edi,(%esp)
  801438:	e8 f6 fa ff ff       	call   800f33 <sys_ipc_try_send>
  80143d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80143f:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801442:	74 3e                	je     801482 <ipc_send+0x94>
  801444:	89 d8                	mov    %ebx,%eax
  801446:	c1 e8 1f             	shr    $0x1f,%eax
  801449:	84 c0                	test   %al,%al
  80144b:	74 35                	je     801482 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80144d:	e8 03 f9 ff ff       	call   800d55 <sys_getenvid>
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 1e 1e 80 00 	movl   $0x801e1e,(%esp)
  80145d:	e8 95 ee ff ff       	call   8002f7 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801462:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801466:	c7 44 24 08 ec 1d 80 	movl   $0x801dec,0x8(%esp)
  80146d:	00 
  80146e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801475:	00 
  801476:	c7 04 24 14 1e 80 00 	movl   $0x801e14,(%esp)
  80147d:	e8 53 00 00 00       	call   8014d5 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  801482:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801485:	75 0e                	jne    801495 <ipc_send+0xa7>
			sys_yield();
  801487:	e8 e8 f8 ff ff       	call   800d74 <sys_yield>
		else break;
	}
  80148c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801490:	e9 68 ff ff ff       	jmp    8013fd <ipc_send+0xf>
	



}
  801495:	83 c4 1c             	add    $0x1c,%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5f                   	pop    %edi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    

0080149d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014a3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014a8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014b1:	8b 52 50             	mov    0x50(%edx),%edx
  8014b4:	39 ca                	cmp    %ecx,%edx
  8014b6:	75 0d                	jne    8014c5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8014b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014bb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014c0:	8b 40 40             	mov    0x40(%eax),%eax
  8014c3:	eb 0e                	jmp    8014d3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014c5:	83 c0 01             	add    $0x1,%eax
  8014c8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014cd:	75 d9                	jne    8014a8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014cf:	66 b8 00 00          	mov    $0x0,%ax
}
  8014d3:	5d                   	pop    %ebp
  8014d4:	c3                   	ret    

008014d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8014dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e0:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8014e6:	e8 6a f8 ff ff       	call   800d55 <sys_getenvid>
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014f9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	c7 04 24 30 1e 80 00 	movl   $0x801e30,(%esp)
  801508:	e8 ea ed ff ff       	call   8002f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801511:	8b 45 10             	mov    0x10(%ebp),%eax
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 7a ed ff ff       	call   800296 <vcprintf>
	cprintf("\n");
  80151c:	c7 04 24 a5 18 80 00 	movl   $0x8018a5,(%esp)
  801523:	e8 cf ed ff ff       	call   8002f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801528:	cc                   	int3   
  801529:	eb fd                	jmp    801528 <_panic+0x53>

0080152b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801531:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801538:	75 44                	jne    80157e <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80153a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80153f:	8b 40 48             	mov    0x48(%eax),%eax
  801542:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801551:	ee 
  801552:	89 04 24             	mov    %eax,(%esp)
  801555:	e8 39 f8 ff ff       	call   800d93 <sys_page_alloc>
		if( r < 0)
  80155a:	85 c0                	test   %eax,%eax
  80155c:	79 20                	jns    80157e <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80155e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801562:	c7 44 24 08 54 1e 80 	movl   $0x801e54,0x8(%esp)
  801569:	00 
  80156a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801571:	00 
  801572:	c7 04 24 b0 1e 80 00 	movl   $0x801eb0,(%esp)
  801579:	e8 57 ff ff ff       	call   8014d5 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	a3 10 20 80 00       	mov    %eax,0x802010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801586:	e8 ca f7 ff ff       	call   800d55 <sys_getenvid>
  80158b:	c7 44 24 04 c1 15 80 	movl   $0x8015c1,0x4(%esp)
  801592:	00 
  801593:	89 04 24             	mov    %eax,(%esp)
  801596:	e8 45 f9 ff ff       	call   800ee0 <sys_env_set_pgfault_upcall>
  80159b:	85 c0                	test   %eax,%eax
  80159d:	79 20                	jns    8015bf <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80159f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a3:	c7 44 24 08 84 1e 80 	movl   $0x801e84,0x8(%esp)
  8015aa:	00 
  8015ab:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8015b2:	00 
  8015b3:	c7 04 24 b0 1e 80 00 	movl   $0x801eb0,(%esp)
  8015ba:	e8 16 ff ff ff       	call   8014d5 <_panic>


}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015c2:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8015c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015c9:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8015cc:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8015d0:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8015d4:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8015d8:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8015db:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8015de:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8015e1:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8015e5:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8015e9:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8015ed:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8015f1:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8015f5:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  8015f9:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8015fd:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  8015fe:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8015ff:	c3                   	ret    

00801600 <__udivdi3>:
  801600:	55                   	push   %ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8b 44 24 28          	mov    0x28(%esp),%eax
  80160a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80160e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801612:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801616:	85 c0                	test   %eax,%eax
  801618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80161c:	89 ea                	mov    %ebp,%edx
  80161e:	89 0c 24             	mov    %ecx,(%esp)
  801621:	75 2d                	jne    801650 <__udivdi3+0x50>
  801623:	39 e9                	cmp    %ebp,%ecx
  801625:	77 61                	ja     801688 <__udivdi3+0x88>
  801627:	85 c9                	test   %ecx,%ecx
  801629:	89 ce                	mov    %ecx,%esi
  80162b:	75 0b                	jne    801638 <__udivdi3+0x38>
  80162d:	b8 01 00 00 00       	mov    $0x1,%eax
  801632:	31 d2                	xor    %edx,%edx
  801634:	f7 f1                	div    %ecx
  801636:	89 c6                	mov    %eax,%esi
  801638:	31 d2                	xor    %edx,%edx
  80163a:	89 e8                	mov    %ebp,%eax
  80163c:	f7 f6                	div    %esi
  80163e:	89 c5                	mov    %eax,%ebp
  801640:	89 f8                	mov    %edi,%eax
  801642:	f7 f6                	div    %esi
  801644:	89 ea                	mov    %ebp,%edx
  801646:	83 c4 0c             	add    $0xc,%esp
  801649:	5e                   	pop    %esi
  80164a:	5f                   	pop    %edi
  80164b:	5d                   	pop    %ebp
  80164c:	c3                   	ret    
  80164d:	8d 76 00             	lea    0x0(%esi),%esi
  801650:	39 e8                	cmp    %ebp,%eax
  801652:	77 24                	ja     801678 <__udivdi3+0x78>
  801654:	0f bd e8             	bsr    %eax,%ebp
  801657:	83 f5 1f             	xor    $0x1f,%ebp
  80165a:	75 3c                	jne    801698 <__udivdi3+0x98>
  80165c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801660:	39 34 24             	cmp    %esi,(%esp)
  801663:	0f 86 9f 00 00 00    	jbe    801708 <__udivdi3+0x108>
  801669:	39 d0                	cmp    %edx,%eax
  80166b:	0f 82 97 00 00 00    	jb     801708 <__udivdi3+0x108>
  801671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801678:	31 d2                	xor    %edx,%edx
  80167a:	31 c0                	xor    %eax,%eax
  80167c:	83 c4 0c             	add    $0xc,%esp
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    
  801683:	90                   	nop
  801684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801688:	89 f8                	mov    %edi,%eax
  80168a:	f7 f1                	div    %ecx
  80168c:	31 d2                	xor    %edx,%edx
  80168e:	83 c4 0c             	add    $0xc,%esp
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    
  801695:	8d 76 00             	lea    0x0(%esi),%esi
  801698:	89 e9                	mov    %ebp,%ecx
  80169a:	8b 3c 24             	mov    (%esp),%edi
  80169d:	d3 e0                	shl    %cl,%eax
  80169f:	89 c6                	mov    %eax,%esi
  8016a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8016a6:	29 e8                	sub    %ebp,%eax
  8016a8:	89 c1                	mov    %eax,%ecx
  8016aa:	d3 ef                	shr    %cl,%edi
  8016ac:	89 e9                	mov    %ebp,%ecx
  8016ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016b2:	8b 3c 24             	mov    (%esp),%edi
  8016b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8016b9:	89 d6                	mov    %edx,%esi
  8016bb:	d3 e7                	shl    %cl,%edi
  8016bd:	89 c1                	mov    %eax,%ecx
  8016bf:	89 3c 24             	mov    %edi,(%esp)
  8016c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016c6:	d3 ee                	shr    %cl,%esi
  8016c8:	89 e9                	mov    %ebp,%ecx
  8016ca:	d3 e2                	shl    %cl,%edx
  8016cc:	89 c1                	mov    %eax,%ecx
  8016ce:	d3 ef                	shr    %cl,%edi
  8016d0:	09 d7                	or     %edx,%edi
  8016d2:	89 f2                	mov    %esi,%edx
  8016d4:	89 f8                	mov    %edi,%eax
  8016d6:	f7 74 24 08          	divl   0x8(%esp)
  8016da:	89 d6                	mov    %edx,%esi
  8016dc:	89 c7                	mov    %eax,%edi
  8016de:	f7 24 24             	mull   (%esp)
  8016e1:	39 d6                	cmp    %edx,%esi
  8016e3:	89 14 24             	mov    %edx,(%esp)
  8016e6:	72 30                	jb     801718 <__udivdi3+0x118>
  8016e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8016ec:	89 e9                	mov    %ebp,%ecx
  8016ee:	d3 e2                	shl    %cl,%edx
  8016f0:	39 c2                	cmp    %eax,%edx
  8016f2:	73 05                	jae    8016f9 <__udivdi3+0xf9>
  8016f4:	3b 34 24             	cmp    (%esp),%esi
  8016f7:	74 1f                	je     801718 <__udivdi3+0x118>
  8016f9:	89 f8                	mov    %edi,%eax
  8016fb:	31 d2                	xor    %edx,%edx
  8016fd:	e9 7a ff ff ff       	jmp    80167c <__udivdi3+0x7c>
  801702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801708:	31 d2                	xor    %edx,%edx
  80170a:	b8 01 00 00 00       	mov    $0x1,%eax
  80170f:	e9 68 ff ff ff       	jmp    80167c <__udivdi3+0x7c>
  801714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801718:	8d 47 ff             	lea    -0x1(%edi),%eax
  80171b:	31 d2                	xor    %edx,%edx
  80171d:	83 c4 0c             	add    $0xc,%esp
  801720:	5e                   	pop    %esi
  801721:	5f                   	pop    %edi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    
  801724:	66 90                	xchg   %ax,%ax
  801726:	66 90                	xchg   %ax,%ax
  801728:	66 90                	xchg   %ax,%ax
  80172a:	66 90                	xchg   %ax,%ax
  80172c:	66 90                	xchg   %ax,%ax
  80172e:	66 90                	xchg   %ax,%ax

00801730 <__umoddi3>:
  801730:	55                   	push   %ebp
  801731:	57                   	push   %edi
  801732:	56                   	push   %esi
  801733:	83 ec 14             	sub    $0x14,%esp
  801736:	8b 44 24 28          	mov    0x28(%esp),%eax
  80173a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80173e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801742:	89 c7                	mov    %eax,%edi
  801744:	89 44 24 04          	mov    %eax,0x4(%esp)
  801748:	8b 44 24 30          	mov    0x30(%esp),%eax
  80174c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801750:	89 34 24             	mov    %esi,(%esp)
  801753:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801757:	85 c0                	test   %eax,%eax
  801759:	89 c2                	mov    %eax,%edx
  80175b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80175f:	75 17                	jne    801778 <__umoddi3+0x48>
  801761:	39 fe                	cmp    %edi,%esi
  801763:	76 4b                	jbe    8017b0 <__umoddi3+0x80>
  801765:	89 c8                	mov    %ecx,%eax
  801767:	89 fa                	mov    %edi,%edx
  801769:	f7 f6                	div    %esi
  80176b:	89 d0                	mov    %edx,%eax
  80176d:	31 d2                	xor    %edx,%edx
  80176f:	83 c4 14             	add    $0x14,%esp
  801772:	5e                   	pop    %esi
  801773:	5f                   	pop    %edi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    
  801776:	66 90                	xchg   %ax,%ax
  801778:	39 f8                	cmp    %edi,%eax
  80177a:	77 54                	ja     8017d0 <__umoddi3+0xa0>
  80177c:	0f bd e8             	bsr    %eax,%ebp
  80177f:	83 f5 1f             	xor    $0x1f,%ebp
  801782:	75 5c                	jne    8017e0 <__umoddi3+0xb0>
  801784:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801788:	39 3c 24             	cmp    %edi,(%esp)
  80178b:	0f 87 e7 00 00 00    	ja     801878 <__umoddi3+0x148>
  801791:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801795:	29 f1                	sub    %esi,%ecx
  801797:	19 c7                	sbb    %eax,%edi
  801799:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80179d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8017a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8017a9:	83 c4 14             	add    $0x14,%esp
  8017ac:	5e                   	pop    %esi
  8017ad:	5f                   	pop    %edi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    
  8017b0:	85 f6                	test   %esi,%esi
  8017b2:	89 f5                	mov    %esi,%ebp
  8017b4:	75 0b                	jne    8017c1 <__umoddi3+0x91>
  8017b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017bb:	31 d2                	xor    %edx,%edx
  8017bd:	f7 f6                	div    %esi
  8017bf:	89 c5                	mov    %eax,%ebp
  8017c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8017c5:	31 d2                	xor    %edx,%edx
  8017c7:	f7 f5                	div    %ebp
  8017c9:	89 c8                	mov    %ecx,%eax
  8017cb:	f7 f5                	div    %ebp
  8017cd:	eb 9c                	jmp    80176b <__umoddi3+0x3b>
  8017cf:	90                   	nop
  8017d0:	89 c8                	mov    %ecx,%eax
  8017d2:	89 fa                	mov    %edi,%edx
  8017d4:	83 c4 14             	add    $0x14,%esp
  8017d7:	5e                   	pop    %esi
  8017d8:	5f                   	pop    %edi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    
  8017db:	90                   	nop
  8017dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017e0:	8b 04 24             	mov    (%esp),%eax
  8017e3:	be 20 00 00 00       	mov    $0x20,%esi
  8017e8:	89 e9                	mov    %ebp,%ecx
  8017ea:	29 ee                	sub    %ebp,%esi
  8017ec:	d3 e2                	shl    %cl,%edx
  8017ee:	89 f1                	mov    %esi,%ecx
  8017f0:	d3 e8                	shr    %cl,%eax
  8017f2:	89 e9                	mov    %ebp,%ecx
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	8b 04 24             	mov    (%esp),%eax
  8017fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8017ff:	89 fa                	mov    %edi,%edx
  801801:	d3 e0                	shl    %cl,%eax
  801803:	89 f1                	mov    %esi,%ecx
  801805:	89 44 24 08          	mov    %eax,0x8(%esp)
  801809:	8b 44 24 10          	mov    0x10(%esp),%eax
  80180d:	d3 ea                	shr    %cl,%edx
  80180f:	89 e9                	mov    %ebp,%ecx
  801811:	d3 e7                	shl    %cl,%edi
  801813:	89 f1                	mov    %esi,%ecx
  801815:	d3 e8                	shr    %cl,%eax
  801817:	89 e9                	mov    %ebp,%ecx
  801819:	09 f8                	or     %edi,%eax
  80181b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80181f:	f7 74 24 04          	divl   0x4(%esp)
  801823:	d3 e7                	shl    %cl,%edi
  801825:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801829:	89 d7                	mov    %edx,%edi
  80182b:	f7 64 24 08          	mull   0x8(%esp)
  80182f:	39 d7                	cmp    %edx,%edi
  801831:	89 c1                	mov    %eax,%ecx
  801833:	89 14 24             	mov    %edx,(%esp)
  801836:	72 2c                	jb     801864 <__umoddi3+0x134>
  801838:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80183c:	72 22                	jb     801860 <__umoddi3+0x130>
  80183e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801842:	29 c8                	sub    %ecx,%eax
  801844:	19 d7                	sbb    %edx,%edi
  801846:	89 e9                	mov    %ebp,%ecx
  801848:	89 fa                	mov    %edi,%edx
  80184a:	d3 e8                	shr    %cl,%eax
  80184c:	89 f1                	mov    %esi,%ecx
  80184e:	d3 e2                	shl    %cl,%edx
  801850:	89 e9                	mov    %ebp,%ecx
  801852:	d3 ef                	shr    %cl,%edi
  801854:	09 d0                	or     %edx,%eax
  801856:	89 fa                	mov    %edi,%edx
  801858:	83 c4 14             	add    $0x14,%esp
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    
  80185f:	90                   	nop
  801860:	39 d7                	cmp    %edx,%edi
  801862:	75 da                	jne    80183e <__umoddi3+0x10e>
  801864:	8b 14 24             	mov    (%esp),%edx
  801867:	89 c1                	mov    %eax,%ecx
  801869:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80186d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801871:	eb cb                	jmp    80183e <__umoddi3+0x10e>
  801873:	90                   	nop
  801874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801878:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80187c:	0f 82 0f ff ff ff    	jb     801791 <__umoddi3+0x61>
  801882:	e9 1a ff ff ff       	jmp    8017a1 <__umoddi3+0x71>
