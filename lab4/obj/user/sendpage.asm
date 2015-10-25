
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
  800039:	e8 c1 10 00 00       	call   8010ff <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 c9 00 00 00    	jne    800112 <umain+0xdf>
		// Child
		cprintf("child\n");
  800049:	c7 04 24 60 18 80 00 	movl   $0x801860,(%esp)
  800050:	e8 a2 02 00 00       	call   8002f7 <cprintf>
		ipc_recv(&who, (void*)TEMP_ADDR_CHILD, 0);
  800055:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80005c:	00 
  80005d:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800064:	00 
  800065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800068:	89 04 24             	mov    %eax,(%esp)
  80006b:	e8 d0 12 00 00       	call   801340 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800070:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800077:	00 
  800078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80007b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007f:	c7 04 24 67 18 80 00 	movl   $0x801867,(%esp)
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
  8000b5:	c7 04 24 84 18 80 00 	movl   $0x801884,(%esp)
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
  800108:	e8 bb 12 00 00       	call   8013c8 <ipc_send>
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
  800179:	e8 4a 12 00 00       	call   8013c8 <ipc_send>
	cprintf("parent\n");
  80017e:	c7 04 24 7b 18 80 00 	movl   $0x80187b,(%esp)
  800185:	e8 6d 01 00 00       	call   8002f7 <cprintf>
	ipc_recv(&who, TEMP_ADDR, 0);
  80018a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800191:	00 
  800192:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800199:	00 
  80019a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 9b 11 00 00       	call   801340 <ipc_recv>

	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8001a5:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001ac:	00 
  8001ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 67 18 80 00 	movl   $0x801867,(%esp)
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
  8001ea:	c7 04 24 a4 18 80 00 	movl   $0x8018a4,(%esp)
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
  80038f:	e8 2c 12 00 00       	call   8015c0 <__udivdi3>
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
  8003ef:	e8 fc 12 00 00       	call   8016f0 <__umoddi3>
  8003f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f8:	0f be 80 1c 19 80 00 	movsbl 0x80191c(%eax),%eax
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
  8004df:	ff 24 95 e0 19 80 00 	jmp    *0x8019e0(,%edx,4)
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
  80058c:	8b 14 85 40 1b 80 00 	mov    0x801b40(,%eax,4),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	75 20                	jne    8005b7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800597:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059b:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
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
  8005bb:	c7 44 24 08 3d 19 80 	movl   $0x80193d,0x8(%esp)
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
  8005eb:	b8 2d 19 80 00       	mov    $0x80192d,%eax
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
  800d31:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800d38:	00 
  800d39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d40:	00 
  800d41:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800d48:	e8 45 07 00 00       	call   801492 <_panic>

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
  800dc3:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800dda:	e8 b3 06 00 00       	call   801492 <_panic>

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
  800e16:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800e2d:	e8 60 06 00 00       	call   801492 <_panic>

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
  800e69:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800e70:	00 
  800e71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e78:	00 
  800e79:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800e80:	e8 0d 06 00 00       	call   801492 <_panic>

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
  800ebc:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800ed3:	e8 ba 05 00 00       	call   801492 <_panic>

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
  800f0f:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1e:	00 
  800f1f:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800f26:	e8 67 05 00 00       	call   801492 <_panic>

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
  800f84:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 85 1b 80 00 	movl   $0x801b85,(%esp)
  800f9b:	e8 f2 04 00 00       	call   801492 <_panic>

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
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax


	void *addr = (void *) utf->utf_fault_va;
  800fb3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  800fb5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fb9:	75 2c                	jne    800fe7 <pgfault+0x3f>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800fbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fbf:	c7 04 24 93 1b 80 00 	movl   $0x801b93,(%esp)
  800fc6:	e8 2c f3 ff ff       	call   8002f7 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800fcb:	c7 44 24 08 d8 1b 80 	movl   $0x801bd8,0x8(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fda:	00 
  800fdb:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  800fe2:	e8 ab 04 00 00       	call   801492 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800fe7:	89 d8                	mov    %ebx,%eax
  800fe9:	c1 e8 0c             	shr    $0xc,%eax
  800fec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800ff3:	f6 c4 08             	test   $0x8,%ah
  800ff6:	75 1c                	jne    801014 <pgfault+0x6c>
		panic("The pgfault perm is not right\n");
  800ff8:	c7 44 24 08 00 1c 80 	movl   $0x801c00,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  80100f:	e8 7e 04 00 00       	call   801492 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  801014:	e8 3c fd ff ff       	call   800d55 <sys_getenvid>
  801019:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801028:	00 
  801029:	89 04 24             	mov    %eax,(%esp)
  80102c:	e8 62 fd ff ff       	call   800d93 <sys_page_alloc>
  801031:	85 c0                	test   %eax,%eax
  801033:	79 1c                	jns    801051 <pgfault+0xa9>
		panic("pgfault sys_page_alloc is not right\n");
  801035:	c7 44 24 08 20 1c 80 	movl   $0x801c20,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  80104c:	e8 41 04 00 00       	call   801492 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801051:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void*)PFTEMP, addr, PGSIZE);
  801057:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80105e:	00 
  80105f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801063:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80106a:	e8 0d fb ff ff       	call   800b7c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  80106f:	e8 e1 fc ff ff       	call   800d55 <sys_getenvid>
  801074:	89 c6                	mov    %eax,%esi
  801076:	e8 da fc ff ff       	call   800d55 <sys_getenvid>
  80107b:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801082:	00 
  801083:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801087:	89 74 24 08          	mov    %esi,0x8(%esp)
  80108b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801092:	00 
  801093:	89 04 24             	mov    %eax,(%esp)
  801096:	e8 4c fd ff ff       	call   800de7 <sys_page_map>
  80109b:	85 c0                	test   %eax,%eax
  80109d:	79 20                	jns    8010bf <pgfault+0x117>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  80109f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a3:	c7 44 24 08 48 1c 80 	movl   $0x801c48,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  8010ba:	e8 d3 03 00 00       	call   801492 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  8010bf:	e8 91 fc ff ff       	call   800d55 <sys_getenvid>
  8010c4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010cb:	00 
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 66 fd ff ff       	call   800e3a <sys_page_unmap>
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 20                	jns    8010f8 <pgfault+0x150>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8010d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010dc:	c7 44 24 08 78 1c 80 	movl   $0x801c78,0x8(%esp)
  8010e3:	00 
  8010e4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8010eb:	00 
  8010ec:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  8010f3:	e8 9a 03 00 00       	call   801492 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  801108:	c7 04 24 a8 0f 80 00 	movl   $0x800fa8,(%esp)
  80110f:	e8 d4 03 00 00       	call   8014e8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801114:	b8 07 00 00 00       	mov    $0x7,%eax
  801119:	cd 30                	int    $0x30
  80111b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80111e:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801121:	85 c0                	test   %eax,%eax
  801123:	79 20                	jns    801145 <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801129:	c7 44 24 08 ac 1c 80 	movl   $0x801cac,0x8(%esp)
  801130:	00 
  801131:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  801140:	e8 4d 03 00 00       	call   801492 <_panic>
	if(childEid == 0){
  801145:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801149:	75 1c                	jne    801167 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80114b:	e8 05 fc ff ff       	call   800d55 <sys_getenvid>
  801150:	25 ff 03 00 00       	and    $0x3ff,%eax
  801155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115d:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return childEid;
  801162:	e9 a0 01 00 00       	jmp    801307 <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  801167:	c7 44 24 04 7e 15 80 	movl   $0x80157e,0x4(%esp)
  80116e:	00 
  80116f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801172:	89 04 24             	mov    %eax,(%esp)
  801175:	e8 66 fd ff ff       	call   800ee0 <sys_env_set_pgfault_upcall>
  80117a:	89 c7                	mov    %eax,%edi
	if(r < 0)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 20                	jns    8011a0 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 e0 1c 80 	movl   $0x801ce0,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  80119b:	e8 f2 02 00 00       	call   801492 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8011a0:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	c1 ea 16             	shr    $0x16,%edx
  8011b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	0f 84 f7 00 00 00    	je     8012be <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
  8011ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011d1:	f6 c2 04             	test   $0x4,%dl
  8011d4:	0f 84 e4 00 00 00    	je     8012be <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8011da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011e1:	a8 01                	test   $0x1,%al
  8011e3:	0f 84 d5 00 00 00    	je     8012be <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8011e9:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8011ef:	75 20                	jne    801211 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8011f1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f8:	00 
  8011f9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801200:	ee 
  801201:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801204:	89 04 24             	mov    %eax,(%esp)
  801207:	e8 87 fb ff ff       	call   800d93 <sys_page_alloc>
  80120c:	e9 84 00 00 00       	jmp    801295 <fork+0x196>
  801211:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  801217:	89 f8                	mov    %edi,%eax
  801219:	c1 e8 0c             	shr    $0xc,%eax
  80121c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801223:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  801228:	83 f8 01             	cmp    $0x1,%eax
  80122b:	19 db                	sbb    %ebx,%ebx
  80122d:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801233:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  801239:	e8 17 fb ff ff       	call   800d55 <sys_getenvid>
  80123e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801242:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801246:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801249:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80124d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801251:	89 04 24             	mov    %eax,(%esp)
  801254:	e8 8e fb ff ff       	call   800de7 <sys_page_map>
  801259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 35                	js     801295 <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801260:	e8 f0 fa ff ff       	call   800d55 <sys_getenvid>
  801265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801268:	e8 e8 fa ff ff       	call   800d55 <sys_getenvid>
  80126d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801271:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801275:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801278:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 5f fb ff ff       	call   800de7 <sys_page_map>
  801288:	85 c0                	test   %eax,%eax
  80128a:	bf 00 00 00 00       	mov    $0x0,%edi
  80128f:	0f 4f c7             	cmovg  %edi,%eax
  801292:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801295:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801299:	79 23                	jns    8012be <fork+0x1bf>
  80129b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  80129e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012a2:	c7 44 24 08 20 1d 80 	movl   $0x801d20,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  8012b9:	e8 d4 01 00 00       	call   801492 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8012be:	89 f1                	mov    %esi,%ecx
  8012c0:	89 f0                	mov    %esi,%eax
  8012c2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8012c8:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8012ce:	0f 85 de fe ff ff    	jne    8011b2 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8012d4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012db:	00 
  8012dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012df:	89 04 24             	mov    %eax,(%esp)
  8012e2:	e8 a6 fb ff ff       	call   800e8d <sys_env_set_status>
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	79 1c                	jns    801307 <fork+0x208>
		panic("sys_env_set_status");
  8012eb:	c7 44 24 08 ae 1b 80 	movl   $0x801bae,0x8(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8012fa:	00 
  8012fb:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  801302:	e8 8b 01 00 00       	call   801492 <_panic>
	return childEid;
}
  801307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80130a:	83 c4 2c             	add    $0x2c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <sfork>:

// Challenge!
int
sfork(void)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801318:	c7 44 24 08 c1 1b 80 	movl   $0x801bc1,0x8(%esp)
  80131f:	00 
  801320:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801327:	00 
  801328:	c7 04 24 a3 1b 80 00 	movl   $0x801ba3,(%esp)
  80132f:	e8 5e 01 00 00       	call   801492 <_panic>
  801334:	66 90                	xchg   %ax,%ax
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 1c             	sub    $0x1c,%esp
  801349:	8b 7d 08             	mov    0x8(%ebp),%edi
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80134f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r = 0;
	int a;
	if((int)pg == 0xb00000)
  801352:	81 fb 00 00 b0 00    	cmp    $0xb00000,%ebx
  801358:	75 0c                	jne    801366 <ipc_recv+0x26>
		cprintf("\n");
  80135a:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  801361:	e8 91 ef ff ff       	call   8002f7 <cprintf>
	if(pg == 0)
  801366:	85 db                	test   %ebx,%ebx
  801368:	75 0e                	jne    801378 <ipc_recv+0x38>
		r= sys_ipc_recv( (void *)UTOP);
  80136a:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801371:	e8 e0 fb ff ff       	call   800f56 <sys_ipc_recv>
  801376:	eb 08                	jmp    801380 <ipc_recv+0x40>
	else
		r = sys_ipc_recv(pg);
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	e8 d6 fb ff ff       	call   800f56 <sys_ipc_recv>
	if(r == 0){
  801380:	85 c0                	test   %eax,%eax
  801382:	75 1e                	jne    8013a2 <ipc_recv+0x62>
		if( from_env_store != 0 )
  801384:	85 ff                	test   %edi,%edi
  801386:	74 0a                	je     801392 <ipc_recv+0x52>
			*from_env_store = thisenv->env_ipc_from;
  801388:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80138d:	8b 40 74             	mov    0x74(%eax),%eax
  801390:	89 07                	mov    %eax,(%edi)

		if(perm_store != 0 )
  801392:	85 f6                	test   %esi,%esi
  801394:	74 22                	je     8013b8 <ipc_recv+0x78>
			*perm_store = thisenv->env_ipc_perm;
  801396:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80139b:	8b 40 78             	mov    0x78(%eax),%eax
  80139e:	89 06                	mov    %eax,(%esi)
  8013a0:	eb 16                	jmp    8013b8 <ipc_recv+0x78>
	}
	else{
		if(from_env_store != 0 )
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	74 06                	je     8013ac <ipc_recv+0x6c>
			*from_env_store = 0;
  8013a6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)

		if(perm_store != 0 )
  8013ac:	85 f6                	test   %esi,%esi
  8013ae:	74 10                	je     8013c0 <ipc_recv+0x80>
			*perm_store = 0;
  8013b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013b6:	eb 08                	jmp    8013c0 <ipc_recv+0x80>
		return r;
	}

	return thisenv->env_ipc_value;
  8013b8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013bd:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8013c0:	83 c4 1c             	add    $0x1c,%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 1c             	sub    $0x1c,%esp
  8013d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r =0;
	while(1){
		if(pg == 0)
  8013da:	85 db                	test   %ebx,%ebx
  8013dc:	75 1d                	jne    8013fb <ipc_send+0x33>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8013de:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e5:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8013ec:	ee 
  8013ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f1:	89 3c 24             	mov    %edi,(%esp)
  8013f4:	e8 3a fb ff ff       	call   800f33 <sys_ipc_try_send>
  8013f9:	eb 1b                	jmp    801416 <ipc_send+0x4e>
		else
			r = sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8013fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801402:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801409:	ee 
  80140a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140e:	89 3c 24             	mov    %edi,(%esp)
  801411:	e8 1d fb ff ff       	call   800f33 <sys_ipc_try_send>


		if(r == 0)
  801416:	85 c0                	test   %eax,%eax
  801418:	74 38                	je     801452 <ipc_send+0x8a>
			return;
		if(r <0 && r != -E_IPC_NOT_RECV)
  80141a:	83 f8 f8             	cmp    $0xfffffff8,%eax
  80141d:	74 25                	je     801444 <ipc_send+0x7c>
  80141f:	89 c2                	mov    %eax,%edx
  801421:	c1 ea 1f             	shr    $0x1f,%edx
  801424:	84 d2                	test   %dl,%dl
  801426:	74 1c                	je     801444 <ipc_send+0x7c>
			panic("ipc_send is error\n");
  801428:	c7 44 24 08 46 1d 80 	movl   $0x801d46,0x8(%esp)
  80142f:	00 
  801430:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801437:	00 
  801438:	c7 04 24 59 1d 80 00 	movl   $0x801d59,(%esp)
  80143f:	e8 4e 00 00 00       	call   801492 <_panic>
		if(r == -E_IPC_NOT_RECV)
  801444:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801447:	75 91                	jne    8013da <ipc_send+0x12>
			sys_yield();
  801449:	e8 26 f9 ff ff       	call   800d74 <sys_yield>
  80144e:	66 90                	xchg   %ax,%ax
  801450:	eb 88                	jmp    8013da <ipc_send+0x12>
	}

}
  801452:	83 c4 1c             	add    $0x1c,%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801465:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801468:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80146e:	8b 52 50             	mov    0x50(%edx),%edx
  801471:	39 ca                	cmp    %ecx,%edx
  801473:	75 0d                	jne    801482 <ipc_find_env+0x28>
			return envs[i].env_id;
  801475:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801478:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80147d:	8b 40 40             	mov    0x40(%eax),%eax
  801480:	eb 0e                	jmp    801490 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801482:	83 c0 01             	add    $0x1,%eax
  801485:	3d 00 04 00 00       	cmp    $0x400,%eax
  80148a:	75 d9                	jne    801465 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80148c:	66 b8 00 00          	mov    $0x0,%ax
}
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80149a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80149d:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8014a3:	e8 ad f8 ff ff       	call   800d55 <sys_getenvid>
  8014a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014af:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014b6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	c7 04 24 64 1d 80 00 	movl   $0x801d64,(%esp)
  8014c5:	e8 2d ee ff ff       	call   8002f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 bd ed ff ff       	call   800296 <vcprintf>
	cprintf("\n");
  8014d9:	c7 04 24 65 18 80 00 	movl   $0x801865,(%esp)
  8014e0:	e8 12 ee ff ff       	call   8002f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014e5:	cc                   	int3   
  8014e6:	eb fd                	jmp    8014e5 <_panic+0x53>

008014e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8014ee:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8014f5:	75 44                	jne    80153b <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8014f7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8014fc:	8b 40 48             	mov    0x48(%eax),%eax
  8014ff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801506:	00 
  801507:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80150e:	ee 
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 7c f8 ff ff       	call   800d93 <sys_page_alloc>
		if( r < 0)
  801517:	85 c0                	test   %eax,%eax
  801519:	79 20                	jns    80153b <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80151b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151f:	c7 44 24 08 88 1d 80 	movl   $0x801d88,0x8(%esp)
  801526:	00 
  801527:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80152e:	00 
  80152f:	c7 04 24 e4 1d 80 00 	movl   $0x801de4,(%esp)
  801536:	e8 57 ff ff ff       	call   801492 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	a3 10 20 80 00       	mov    %eax,0x802010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801543:	e8 0d f8 ff ff       	call   800d55 <sys_getenvid>
  801548:	c7 44 24 04 7e 15 80 	movl   $0x80157e,0x4(%esp)
  80154f:	00 
  801550:	89 04 24             	mov    %eax,(%esp)
  801553:	e8 88 f9 ff ff       	call   800ee0 <sys_env_set_pgfault_upcall>
  801558:	85 c0                	test   %eax,%eax
  80155a:	79 20                	jns    80157c <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80155c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801560:	c7 44 24 08 b8 1d 80 	movl   $0x801db8,0x8(%esp)
  801567:	00 
  801568:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80156f:	00 
  801570:	c7 04 24 e4 1d 80 00 	movl   $0x801de4,(%esp)
  801577:	e8 16 ff ff ff       	call   801492 <_panic>


}
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80157e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80157f:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  801584:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801586:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  801589:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  80158d:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  801591:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  801595:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  801598:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  80159b:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  80159e:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8015a2:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8015a6:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8015aa:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8015ae:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8015b2:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  8015b6:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8015ba:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  8015bb:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8015bc:	c3                   	ret    
  8015bd:	66 90                	xchg   %ax,%ax
  8015bf:	90                   	nop

008015c0 <__udivdi3>:
  8015c0:	55                   	push   %ebp
  8015c1:	57                   	push   %edi
  8015c2:	56                   	push   %esi
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8015ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8015ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8015d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015dc:	89 ea                	mov    %ebp,%edx
  8015de:	89 0c 24             	mov    %ecx,(%esp)
  8015e1:	75 2d                	jne    801610 <__udivdi3+0x50>
  8015e3:	39 e9                	cmp    %ebp,%ecx
  8015e5:	77 61                	ja     801648 <__udivdi3+0x88>
  8015e7:	85 c9                	test   %ecx,%ecx
  8015e9:	89 ce                	mov    %ecx,%esi
  8015eb:	75 0b                	jne    8015f8 <__udivdi3+0x38>
  8015ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f2:	31 d2                	xor    %edx,%edx
  8015f4:	f7 f1                	div    %ecx
  8015f6:	89 c6                	mov    %eax,%esi
  8015f8:	31 d2                	xor    %edx,%edx
  8015fa:	89 e8                	mov    %ebp,%eax
  8015fc:	f7 f6                	div    %esi
  8015fe:	89 c5                	mov    %eax,%ebp
  801600:	89 f8                	mov    %edi,%eax
  801602:	f7 f6                	div    %esi
  801604:	89 ea                	mov    %ebp,%edx
  801606:	83 c4 0c             	add    $0xc,%esp
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    
  80160d:	8d 76 00             	lea    0x0(%esi),%esi
  801610:	39 e8                	cmp    %ebp,%eax
  801612:	77 24                	ja     801638 <__udivdi3+0x78>
  801614:	0f bd e8             	bsr    %eax,%ebp
  801617:	83 f5 1f             	xor    $0x1f,%ebp
  80161a:	75 3c                	jne    801658 <__udivdi3+0x98>
  80161c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801620:	39 34 24             	cmp    %esi,(%esp)
  801623:	0f 86 9f 00 00 00    	jbe    8016c8 <__udivdi3+0x108>
  801629:	39 d0                	cmp    %edx,%eax
  80162b:	0f 82 97 00 00 00    	jb     8016c8 <__udivdi3+0x108>
  801631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801638:	31 d2                	xor    %edx,%edx
  80163a:	31 c0                	xor    %eax,%eax
  80163c:	83 c4 0c             	add    $0xc,%esp
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    
  801643:	90                   	nop
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	89 f8                	mov    %edi,%eax
  80164a:	f7 f1                	div    %ecx
  80164c:	31 d2                	xor    %edx,%edx
  80164e:	83 c4 0c             	add    $0xc,%esp
  801651:	5e                   	pop    %esi
  801652:	5f                   	pop    %edi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    
  801655:	8d 76 00             	lea    0x0(%esi),%esi
  801658:	89 e9                	mov    %ebp,%ecx
  80165a:	8b 3c 24             	mov    (%esp),%edi
  80165d:	d3 e0                	shl    %cl,%eax
  80165f:	89 c6                	mov    %eax,%esi
  801661:	b8 20 00 00 00       	mov    $0x20,%eax
  801666:	29 e8                	sub    %ebp,%eax
  801668:	89 c1                	mov    %eax,%ecx
  80166a:	d3 ef                	shr    %cl,%edi
  80166c:	89 e9                	mov    %ebp,%ecx
  80166e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801672:	8b 3c 24             	mov    (%esp),%edi
  801675:	09 74 24 08          	or     %esi,0x8(%esp)
  801679:	89 d6                	mov    %edx,%esi
  80167b:	d3 e7                	shl    %cl,%edi
  80167d:	89 c1                	mov    %eax,%ecx
  80167f:	89 3c 24             	mov    %edi,(%esp)
  801682:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801686:	d3 ee                	shr    %cl,%esi
  801688:	89 e9                	mov    %ebp,%ecx
  80168a:	d3 e2                	shl    %cl,%edx
  80168c:	89 c1                	mov    %eax,%ecx
  80168e:	d3 ef                	shr    %cl,%edi
  801690:	09 d7                	or     %edx,%edi
  801692:	89 f2                	mov    %esi,%edx
  801694:	89 f8                	mov    %edi,%eax
  801696:	f7 74 24 08          	divl   0x8(%esp)
  80169a:	89 d6                	mov    %edx,%esi
  80169c:	89 c7                	mov    %eax,%edi
  80169e:	f7 24 24             	mull   (%esp)
  8016a1:	39 d6                	cmp    %edx,%esi
  8016a3:	89 14 24             	mov    %edx,(%esp)
  8016a6:	72 30                	jb     8016d8 <__udivdi3+0x118>
  8016a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8016ac:	89 e9                	mov    %ebp,%ecx
  8016ae:	d3 e2                	shl    %cl,%edx
  8016b0:	39 c2                	cmp    %eax,%edx
  8016b2:	73 05                	jae    8016b9 <__udivdi3+0xf9>
  8016b4:	3b 34 24             	cmp    (%esp),%esi
  8016b7:	74 1f                	je     8016d8 <__udivdi3+0x118>
  8016b9:	89 f8                	mov    %edi,%eax
  8016bb:	31 d2                	xor    %edx,%edx
  8016bd:	e9 7a ff ff ff       	jmp    80163c <__udivdi3+0x7c>
  8016c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016c8:	31 d2                	xor    %edx,%edx
  8016ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8016cf:	e9 68 ff ff ff       	jmp    80163c <__udivdi3+0x7c>
  8016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8016db:	31 d2                	xor    %edx,%edx
  8016dd:	83 c4 0c             	add    $0xc,%esp
  8016e0:	5e                   	pop    %esi
  8016e1:	5f                   	pop    %edi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    
  8016e4:	66 90                	xchg   %ax,%ax
  8016e6:	66 90                	xchg   %ax,%ax
  8016e8:	66 90                	xchg   %ax,%ax
  8016ea:	66 90                	xchg   %ax,%ax
  8016ec:	66 90                	xchg   %ax,%ax
  8016ee:	66 90                	xchg   %ax,%ax

008016f0 <__umoddi3>:
  8016f0:	55                   	push   %ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8016fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8016fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801702:	89 c7                	mov    %eax,%edi
  801704:	89 44 24 04          	mov    %eax,0x4(%esp)
  801708:	8b 44 24 30          	mov    0x30(%esp),%eax
  80170c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801710:	89 34 24             	mov    %esi,(%esp)
  801713:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801717:	85 c0                	test   %eax,%eax
  801719:	89 c2                	mov    %eax,%edx
  80171b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80171f:	75 17                	jne    801738 <__umoddi3+0x48>
  801721:	39 fe                	cmp    %edi,%esi
  801723:	76 4b                	jbe    801770 <__umoddi3+0x80>
  801725:	89 c8                	mov    %ecx,%eax
  801727:	89 fa                	mov    %edi,%edx
  801729:	f7 f6                	div    %esi
  80172b:	89 d0                	mov    %edx,%eax
  80172d:	31 d2                	xor    %edx,%edx
  80172f:	83 c4 14             	add    $0x14,%esp
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    
  801736:	66 90                	xchg   %ax,%ax
  801738:	39 f8                	cmp    %edi,%eax
  80173a:	77 54                	ja     801790 <__umoddi3+0xa0>
  80173c:	0f bd e8             	bsr    %eax,%ebp
  80173f:	83 f5 1f             	xor    $0x1f,%ebp
  801742:	75 5c                	jne    8017a0 <__umoddi3+0xb0>
  801744:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801748:	39 3c 24             	cmp    %edi,(%esp)
  80174b:	0f 87 e7 00 00 00    	ja     801838 <__umoddi3+0x148>
  801751:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801755:	29 f1                	sub    %esi,%ecx
  801757:	19 c7                	sbb    %eax,%edi
  801759:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80175d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801761:	8b 44 24 08          	mov    0x8(%esp),%eax
  801765:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801769:	83 c4 14             	add    $0x14,%esp
  80176c:	5e                   	pop    %esi
  80176d:	5f                   	pop    %edi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    
  801770:	85 f6                	test   %esi,%esi
  801772:	89 f5                	mov    %esi,%ebp
  801774:	75 0b                	jne    801781 <__umoddi3+0x91>
  801776:	b8 01 00 00 00       	mov    $0x1,%eax
  80177b:	31 d2                	xor    %edx,%edx
  80177d:	f7 f6                	div    %esi
  80177f:	89 c5                	mov    %eax,%ebp
  801781:	8b 44 24 04          	mov    0x4(%esp),%eax
  801785:	31 d2                	xor    %edx,%edx
  801787:	f7 f5                	div    %ebp
  801789:	89 c8                	mov    %ecx,%eax
  80178b:	f7 f5                	div    %ebp
  80178d:	eb 9c                	jmp    80172b <__umoddi3+0x3b>
  80178f:	90                   	nop
  801790:	89 c8                	mov    %ecx,%eax
  801792:	89 fa                	mov    %edi,%edx
  801794:	83 c4 14             	add    $0x14,%esp
  801797:	5e                   	pop    %esi
  801798:	5f                   	pop    %edi
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    
  80179b:	90                   	nop
  80179c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a0:	8b 04 24             	mov    (%esp),%eax
  8017a3:	be 20 00 00 00       	mov    $0x20,%esi
  8017a8:	89 e9                	mov    %ebp,%ecx
  8017aa:	29 ee                	sub    %ebp,%esi
  8017ac:	d3 e2                	shl    %cl,%edx
  8017ae:	89 f1                	mov    %esi,%ecx
  8017b0:	d3 e8                	shr    %cl,%eax
  8017b2:	89 e9                	mov    %ebp,%ecx
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	8b 04 24             	mov    (%esp),%eax
  8017bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8017bf:	89 fa                	mov    %edi,%edx
  8017c1:	d3 e0                	shl    %cl,%eax
  8017c3:	89 f1                	mov    %esi,%ecx
  8017c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8017cd:	d3 ea                	shr    %cl,%edx
  8017cf:	89 e9                	mov    %ebp,%ecx
  8017d1:	d3 e7                	shl    %cl,%edi
  8017d3:	89 f1                	mov    %esi,%ecx
  8017d5:	d3 e8                	shr    %cl,%eax
  8017d7:	89 e9                	mov    %ebp,%ecx
  8017d9:	09 f8                	or     %edi,%eax
  8017db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8017df:	f7 74 24 04          	divl   0x4(%esp)
  8017e3:	d3 e7                	shl    %cl,%edi
  8017e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017e9:	89 d7                	mov    %edx,%edi
  8017eb:	f7 64 24 08          	mull   0x8(%esp)
  8017ef:	39 d7                	cmp    %edx,%edi
  8017f1:	89 c1                	mov    %eax,%ecx
  8017f3:	89 14 24             	mov    %edx,(%esp)
  8017f6:	72 2c                	jb     801824 <__umoddi3+0x134>
  8017f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8017fc:	72 22                	jb     801820 <__umoddi3+0x130>
  8017fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801802:	29 c8                	sub    %ecx,%eax
  801804:	19 d7                	sbb    %edx,%edi
  801806:	89 e9                	mov    %ebp,%ecx
  801808:	89 fa                	mov    %edi,%edx
  80180a:	d3 e8                	shr    %cl,%eax
  80180c:	89 f1                	mov    %esi,%ecx
  80180e:	d3 e2                	shl    %cl,%edx
  801810:	89 e9                	mov    %ebp,%ecx
  801812:	d3 ef                	shr    %cl,%edi
  801814:	09 d0                	or     %edx,%eax
  801816:	89 fa                	mov    %edi,%edx
  801818:	83 c4 14             	add    $0x14,%esp
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    
  80181f:	90                   	nop
  801820:	39 d7                	cmp    %edx,%edi
  801822:	75 da                	jne    8017fe <__umoddi3+0x10e>
  801824:	8b 14 24             	mov    (%esp),%edx
  801827:	89 c1                	mov    %eax,%ecx
  801829:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80182d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801831:	eb cb                	jmp    8017fe <__umoddi3+0x10e>
  801833:	90                   	nop
  801834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801838:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80183c:	0f 82 0f ff ff ff    	jb     801751 <__umoddi3+0x61>
  801842:	e9 1a ff ff ff       	jmp    801761 <__umoddi3+0x71>
