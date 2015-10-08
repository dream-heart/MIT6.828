
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 59 0f 00 00       	call   800f98 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bd 00 00 00    	jne    800107 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 77 0f 00 00       	call   800fdc <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  80007b:	e8 6a 02 00 00       	call   8002ea <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 a3 08 00 00       	call   800930 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 9c 09 00 00       	call   800a42 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 13 80 00 	movl   $0x801374,(%esp)
  8000b1:	e8 34 02 00 00       	call   8002ea <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 6d 08 00 00       	call   800930 <strlen>
  8000c3:	83 c0 01             	add    $0x1,%eax
  8000c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ca:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d3:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000da:	e8 8d 0a 00 00       	call   800b6c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000df:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e6:	00 
  8000e7:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f6:	00 
  8000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000fa:	89 04 24             	mov    %eax,(%esp)
  8000fd:	e8 fc 0e 00 00       	call   800ffe <ipc_send>
		return;
  800102:	e9 d8 00 00 00       	jmp    8001df <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800107:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010c:	8b 40 48             	mov    0x48(%eax),%eax
  80010f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011e:	00 
  80011f:	89 04 24             	mov    %eax,(%esp)
  800122:	e8 5c 0c 00 00       	call   800d83 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800127:	a1 04 20 80 00       	mov    0x802004,%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 fc 07 00 00       	call   800930 <strlen>
  800134:	83 c0 01             	add    $0x1,%eax
  800137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013b:	a1 04 20 80 00       	mov    0x802004,%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014b:	e8 1c 0a 00 00       	call   800b6c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800150:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800157:	00 
  800158:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800167:	00 
  800168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 8b 0e 00 00       	call   800ffe <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800173:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017a:	00 
  80017b:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800182:	00 
  800183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 4e 0e 00 00       	call   800fdc <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018e:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800195:	00 
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  8001a4:	e8 41 01 00 00       	call   8002ea <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a9:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 7a 07 00 00       	call   800930 <strlen>
  8001b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ba:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c3:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001ca:	e8 73 08 00 00       	call   800a42 <strncmp>
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	75 0c                	jne    8001df <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d3:	c7 04 24 94 13 80 00 	movl   $0x801394,(%esp)
  8001da:	e8 0b 01 00 00       	call   8002ea <cprintf>
	return;
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    
  8001e1:	00 00                	add    %al,(%eax)
	...

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 18             	sub    $0x18,%esp
  8001ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001f6:	e8 4a 0b 00 00       	call   800d45 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800200:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800203:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800208:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020d:	85 f6                	test   %esi,%esi
  80020f:	7e 07                	jle    800218 <libmain+0x34>
		binaryname = argv[0];
  800211:	8b 03                	mov    (%ebx),%eax
  800213:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021c:	89 34 24             	mov    %esi,(%esp)
  80021f:	e8 10 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800224:	e8 0a 00 00 00       	call   800233 <exit>
}
  800229:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80022c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800240:	e8 ae 0a 00 00       	call   800cf3 <sys_env_destroy>
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	83 ec 14             	sub    $0x14,%esp
  80024e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800251:	8b 13                	mov    (%ebx),%edx
  800253:	8d 42 01             	lea    0x1(%edx),%eax
  800256:	89 03                	mov    %eax,(%ebx)
  800258:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80025f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800264:	75 19                	jne    80027f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800266:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80026d:	00 
  80026e:	8d 43 08             	lea    0x8(%ebx),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 3d 0a 00 00       	call   800cb6 <sys_cputs>
		b->idx = 0;
  800279:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800283:	83 c4 14             	add    $0x14,%esp
  800286:	5b                   	pop    %ebx
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800292:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800299:	00 00 00 
	b.cnt = 0;
  80029c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002be:	c7 04 24 47 02 80 00 	movl   $0x800247,(%esp)
  8002c5:	e8 7a 01 00 00       	call   800444 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ca:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	e8 d4 09 00 00       	call   800cb6 <sys_cputs>

	return b.cnt;
}
  8002e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 87 ff ff ff       	call   800289 <vcprintf>
	va_end(ap);

	return cnt;
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    
	...

00800310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 3c             	sub    $0x3c,%esp
  800319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031c:	89 d7                	mov    %edx,%edi
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	89 c3                	mov    %eax,%ebx
  800329:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80032c:	8b 45 10             	mov    0x10(%ebp),%eax
  80032f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033d:	39 d9                	cmp    %ebx,%ecx
  80033f:	72 05                	jb     800346 <printnum+0x36>
  800341:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800344:	77 69                	ja     8003af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800346:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800349:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80034d:	83 ee 01             	sub    $0x1,%esi
  800350:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	8b 44 24 08          	mov    0x8(%esp),%eax
  80035c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800360:	89 c3                	mov    %eax,%ebx
  800362:	89 d6                	mov    %edx,%esi
  800364:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800367:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80036a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80036e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80037b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037f:	e8 2c 0d 00 00       	call   8010b0 <__udivdi3>
  800384:	89 d9                	mov    %ebx,%ecx
  800386:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80038a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80038e:	89 04 24             	mov    %eax,(%esp)
  800391:	89 54 24 04          	mov    %edx,0x4(%esp)
  800395:	89 fa                	mov    %edi,%edx
  800397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80039a:	e8 71 ff ff ff       	call   800310 <printnum>
  80039f:	eb 1b                	jmp    8003bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	eb 03                	jmp    8003b2 <printnum+0xa2>
  8003af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b2:	83 ee 01             	sub    $0x1,%esi
  8003b5:	85 f6                	test   %esi,%esi
  8003b7:	7f e8                	jg     8003a1 <printnum+0x91>
  8003b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d5:	89 04 24             	mov    %eax,(%esp)
  8003d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	e8 fc 0d 00 00       	call   8011e0 <__umoddi3>
  8003e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e8:	0f be 80 0c 14 80 00 	movsbl 0x80140c(%eax),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f5:	ff d0                	call   *%eax
}
  8003f7:	83 c4 3c             	add    $0x3c,%esp
  8003fa:	5b                   	pop    %ebx
  8003fb:	5e                   	pop    %esi
  8003fc:	5f                   	pop    %edi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800405:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	3b 50 04             	cmp    0x4(%eax),%edx
  80040e:	73 0a                	jae    80041a <sprintputch+0x1b>
		*b->buf++ = ch;
  800410:	8d 4a 01             	lea    0x1(%edx),%ecx
  800413:	89 08                	mov    %ecx,(%eax)
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	88 02                	mov    %al,(%edx)
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800422:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800425:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800429:	8b 45 10             	mov    0x10(%ebp),%eax
  80042c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800430:	8b 45 0c             	mov    0xc(%ebp),%eax
  800433:	89 44 24 04          	mov    %eax,0x4(%esp)
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	e8 02 00 00 00       	call   800444 <vprintfmt>
	va_end(ap);
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 3c             	sub    $0x3c,%esp
  80044d:	8b 75 08             	mov    0x8(%ebp),%esi
  800450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800453:	8b 7d 10             	mov    0x10(%ebp),%edi
  800456:	eb 11                	jmp    800469 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800458:	85 c0                	test   %eax,%eax
  80045a:	0f 84 48 04 00 00    	je     8008a8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800460:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800469:	83 c7 01             	add    $0x1,%edi
  80046c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800470:	83 f8 25             	cmp    $0x25,%eax
  800473:	75 e3                	jne    800458 <vprintfmt+0x14>
  800475:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800479:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800480:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800487:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80048e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800493:	eb 1f                	jmp    8004b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800498:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80049c:	eb 16                	jmp    8004b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a5:	eb 0d                	jmp    8004b4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8d 47 01             	lea    0x1(%edi),%eax
  8004b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ba:	0f b6 17             	movzbl (%edi),%edx
  8004bd:	0f b6 c2             	movzbl %dl,%eax
  8004c0:	83 ea 23             	sub    $0x23,%edx
  8004c3:	80 fa 55             	cmp    $0x55,%dl
  8004c6:	0f 87 bf 03 00 00    	ja     80088b <vprintfmt+0x447>
  8004cc:	0f b6 d2             	movzbl %dl,%edx
  8004cf:	ff 24 95 e0 14 80 00 	jmp    *0x8014e0(,%edx,4)
  8004d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004e4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004e8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ee:	83 f9 09             	cmp    $0x9,%ecx
  8004f1:	77 3c                	ja     80052f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f6:	eb e9                	jmp    8004e1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 40 04             	lea    0x4(%eax),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050c:	eb 27                	jmp    800535 <vprintfmt+0xf1>
  80050e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800511:	85 d2                	test   %edx,%edx
  800513:	b8 00 00 00 00       	mov    $0x0,%eax
  800518:	0f 49 c2             	cmovns %edx,%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800521:	eb 91                	jmp    8004b4 <vprintfmt+0x70>
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800526:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052d:	eb 85                	jmp    8004b4 <vprintfmt+0x70>
  80052f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800532:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800535:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800539:	0f 89 75 ff ff ff    	jns    8004b4 <vprintfmt+0x70>
  80053f:	e9 63 ff ff ff       	jmp    8004a7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800544:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054a:	e9 65 ff ff ff       	jmp    8004b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800552:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800564:	e9 00 ff ff ff       	jmp    800469 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	99                   	cltd   
  800573:	31 d0                	xor    %edx,%eax
  800575:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800577:	83 f8 09             	cmp    $0x9,%eax
  80057a:	7f 0b                	jg     800587 <vprintfmt+0x143>
  80057c:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	75 20                	jne    8005a7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800587:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058b:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  800592:	00 
  800593:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800597:	89 34 24             	mov    %esi,(%esp)
  80059a:	e8 7d fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a2:	e9 c2 fe ff ff       	jmp    800469 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ab:	c7 44 24 08 2d 14 80 	movl   $0x80142d,0x8(%esp)
  8005b2:	00 
  8005b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b7:	89 34 24             	mov    %esi,(%esp)
  8005ba:	e8 5d fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	e9 a2 fe ff ff       	jmp    800469 <vprintfmt+0x25>
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d9:	85 ff                	test   %edi,%edi
  8005db:	b8 1d 14 80 00       	mov    $0x80141d,%eax
  8005e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e7:	0f 84 92 00 00 00    	je     80067f <vprintfmt+0x23b>
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	0f 8e 98 00 00 00    	jle    80068d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f9:	89 3c 24             	mov    %edi,(%esp)
  8005fc:	e8 47 03 00 00       	call   800948 <strnlen>
  800601:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800604:	29 c1                	sub    %eax,%ecx
  800606:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800609:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800613:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	eb 0f                	jmp    800626 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	89 04 24             	mov    %eax,(%esp)
  800621:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	85 ff                	test   %edi,%edi
  800628:	7f ed                	jg     800617 <vprintfmt+0x1d3>
  80062a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800630:	85 c9                	test   %ecx,%ecx
  800632:	b8 00 00 00 00       	mov    $0x0,%eax
  800637:	0f 49 c1             	cmovns %ecx,%eax
  80063a:	29 c1                	sub    %eax,%ecx
  80063c:	89 75 08             	mov    %esi,0x8(%ebp)
  80063f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800642:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800645:	89 cb                	mov    %ecx,%ebx
  800647:	eb 50                	jmp    800699 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800649:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064d:	74 1e                	je     80066d <vprintfmt+0x229>
  80064f:	0f be d2             	movsbl %dl,%edx
  800652:	83 ea 20             	sub    $0x20,%edx
  800655:	83 fa 5e             	cmp    $0x5e,%edx
  800658:	76 13                	jbe    80066d <vprintfmt+0x229>
					putch('?', putdat);
  80065a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800661:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800668:	ff 55 08             	call   *0x8(%ebp)
  80066b:	eb 0d                	jmp    80067a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80066d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800670:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	83 eb 01             	sub    $0x1,%ebx
  80067d:	eb 1a                	jmp    800699 <vprintfmt+0x255>
  80067f:	89 75 08             	mov    %esi,0x8(%ebp)
  800682:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800685:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800688:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068b:	eb 0c                	jmp    800699 <vprintfmt+0x255>
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800699:	83 c7 01             	add    $0x1,%edi
  80069c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006a0:	0f be c2             	movsbl %dl,%eax
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 25                	je     8006cc <vprintfmt+0x288>
  8006a7:	85 f6                	test   %esi,%esi
  8006a9:	78 9e                	js     800649 <vprintfmt+0x205>
  8006ab:	83 ee 01             	sub    $0x1,%esi
  8006ae:	79 99                	jns    800649 <vprintfmt+0x205>
  8006b0:	89 df                	mov    %ebx,%edi
  8006b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b8:	eb 1a                	jmp    8006d4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c7:	83 ef 01             	sub    $0x1,%edi
  8006ca:	eb 08                	jmp    8006d4 <vprintfmt+0x290>
  8006cc:	89 df                	mov    %ebx,%edi
  8006ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d4:	85 ff                	test   %edi,%edi
  8006d6:	7f e2                	jg     8006ba <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 89 fd ff ff       	jmp    800469 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e0:	83 f9 01             	cmp    $0x1,%ecx
  8006e3:	7e 19                	jle    8006fe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 50 04             	mov    0x4(%eax),%edx
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 40 08             	lea    0x8(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fc:	eb 38                	jmp    800736 <vprintfmt+0x2f2>
	else if (lflag)
  8006fe:	85 c9                	test   %ecx,%ecx
  800700:	74 1b                	je     80071d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070a:	89 c1                	mov    %eax,%ecx
  80070c:	c1 f9 1f             	sar    $0x1f,%ecx
  80070f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 40 04             	lea    0x4(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
  80071b:	eb 19                	jmp    800736 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 00                	mov    (%eax),%eax
  800722:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800725:	89 c1                	mov    %eax,%ecx
  800727:	c1 f9 1f             	sar    $0x1f,%ecx
  80072a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800736:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800739:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80073c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800741:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800745:	0f 89 04 01 00 00    	jns    80084f <vprintfmt+0x40b>
				putch('-', putdat);
  80074b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800756:	ff d6                	call   *%esi
				num = -(long long) num;
  800758:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80075e:	f7 da                	neg    %edx
  800760:	83 d1 00             	adc    $0x0,%ecx
  800763:	f7 d9                	neg    %ecx
  800765:	e9 e5 00 00 00       	jmp    80084f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076a:	83 f9 01             	cmp    $0x1,%ecx
  80076d:	7e 10                	jle    80077f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	8b 48 04             	mov    0x4(%eax),%ecx
  800777:	8d 40 08             	lea    0x8(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
  80077d:	eb 26                	jmp    8007a5 <vprintfmt+0x361>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	74 12                	je     800795 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
  800793:	eb 10                	jmp    8007a5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 10                	mov    (%eax),%edx
  80079a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079f:	8d 40 04             	lea    0x4(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007a5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8007aa:	e9 a0 00 00 00       	jmp    80084f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007ba:	ff d6                	call   *%esi
			putch('X', putdat);
  8007bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007c7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007d4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007d9:	e9 8b fc ff ff       	jmp    800469 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800802:	8d 40 04             	lea    0x4(%eax),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800808:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80080d:	eb 40                	jmp    80084f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080f:	83 f9 01             	cmp    $0x1,%ecx
  800812:	7e 10                	jle    800824 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8b 48 04             	mov    0x4(%eax),%ecx
  80081c:	8d 40 08             	lea    0x8(%eax),%eax
  80081f:	89 45 14             	mov    %eax,0x14(%ebp)
  800822:	eb 26                	jmp    80084a <vprintfmt+0x406>
	else if (lflag)
  800824:	85 c9                	test   %ecx,%ecx
  800826:	74 12                	je     80083a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	8d 40 04             	lea    0x4(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
  800838:	eb 10                	jmp    80084a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80084a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800853:	89 44 24 10          	mov    %eax,0x10(%esp)
  800857:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800862:	89 14 24             	mov    %edx,(%esp)
  800865:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800869:	89 da                	mov    %ebx,%edx
  80086b:	89 f0                	mov    %esi,%eax
  80086d:	e8 9e fa ff ff       	call   800310 <printnum>
			break;
  800872:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800875:	e9 ef fb ff ff       	jmp    800469 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800886:	e9 de fb ff ff       	jmp    800469 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800896:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800898:	eb 03                	jmp    80089d <vprintfmt+0x459>
  80089a:	83 ef 01             	sub    $0x1,%edi
  80089d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008a1:	75 f7                	jne    80089a <vprintfmt+0x456>
  8008a3:	e9 c1 fb ff ff       	jmp    800469 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8008a8:	83 c4 3c             	add    $0x3c,%esp
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5f                   	pop    %edi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 28             	sub    $0x28,%esp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 30                	je     800901 <vsnprintf+0x51>
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	7e 2c                	jle    800901 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	c7 04 24 ff 03 80 00 	movl   $0x8003ff,(%esp)
  8008f1:	e8 4e fb ff ff       	call   800444 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ff:	eb 05                	jmp    800906 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800911:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800915:	8b 45 10             	mov    0x10(%ebp),%eax
  800918:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 82 ff ff ff       	call   8008b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	eb 03                	jmp    800940 <strlen+0x10>
		n++;
  80093d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800940:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800944:	75 f7                	jne    80093d <strlen+0xd>
		n++;
	return n;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 03                	jmp    80095b <strnlen+0x13>
		n++;
  800958:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	74 06                	je     800965 <strnlen+0x1d>
  80095f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800963:	75 f3                	jne    800958 <strnlen+0x10>
		n++;
	return n;
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800971:	89 c2                	mov    %eax,%edx
  800973:	83 c2 01             	add    $0x1,%edx
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80097d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800980:	84 db                	test   %bl,%bl
  800982:	75 ef                	jne    800973 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800984:	5b                   	pop    %ebx
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800991:	89 1c 24             	mov    %ebx,(%esp)
  800994:	e8 97 ff ff ff       	call   800930 <strlen>
	strcpy(dst + len, src);
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a0:	01 d8                	add    %ebx,%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 bd ff ff ff       	call   800967 <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	83 c4 08             	add    $0x8,%esp
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ed:	89 f0                	mov    %esi,%eax
  8009ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	75 0b                	jne    800a02 <strlcpy+0x23>
  8009f7:	eb 1d                	jmp    800a16 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a02:	39 d8                	cmp    %ebx,%eax
  800a04:	74 0b                	je     800a11 <strlcpy+0x32>
  800a06:	0f b6 0a             	movzbl (%edx),%ecx
  800a09:	84 c9                	test   %cl,%cl
  800a0b:	75 ec                	jne    8009f9 <strlcpy+0x1a>
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	eb 02                	jmp    800a13 <strlcpy+0x34>
  800a11:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a13:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a16:	29 f0                	sub    %esi,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strcmp+0x11>
		p++, q++;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	84 c0                	test   %al,%al
  800a32:	74 04                	je     800a38 <strcmp+0x1c>
  800a34:	3a 02                	cmp    (%edx),%al
  800a36:	74 ef                	je     800a27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 c0             	movzbl %al,%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strncmp+0x17>
		n--, p++, q++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a59:	39 d8                	cmp    %ebx,%eax
  800a5b:	74 15                	je     800a72 <strncmp+0x30>
  800a5d:	0f b6 08             	movzbl (%eax),%ecx
  800a60:	84 c9                	test   %cl,%cl
  800a62:	74 04                	je     800a68 <strncmp+0x26>
  800a64:	3a 0a                	cmp    (%edx),%cl
  800a66:	74 eb                	je     800a53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
  800a70:	eb 05                	jmp    800a77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 07                	jmp    800a8d <strchr+0x13>
		if (*s == c)
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 0f                	je     800a99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 07                	jmp    800aae <strfind+0x13>
		if (*s == c)
  800aa7:	38 ca                	cmp    %cl,%dl
  800aa9:	74 0a                	je     800ab5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	0f b6 10             	movzbl (%eax),%edx
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 36                	je     800afd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acd:	75 28                	jne    800af7 <memset+0x40>
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 23                	jne    800af7 <memset+0x40>
		c &= 0xFF;
  800ad4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 c2                	or     %eax,%edx
  800aeb:	89 d0                	mov    %edx,%eax
  800aed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af2:	fc                   	cld    
  800af3:	f3 ab                	rep stos %eax,%es:(%edi)
  800af5:	eb 06                	jmp    800afd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b12:	39 c6                	cmp    %eax,%esi
  800b14:	73 35                	jae    800b4b <memmove+0x47>
  800b16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b19:	39 d0                	cmp    %edx,%eax
  800b1b:	73 2e                	jae    800b4b <memmove+0x47>
		s += n;
		d += n;
  800b1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2a:	75 13                	jne    800b3f <memmove+0x3b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 09                	jmp    800b48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3f:	83 ef 01             	sub    $0x1,%edi
  800b42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b45:	fd                   	std    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b48:	fc                   	cld    
  800b49:	eb 1d                	jmp    800b68 <memmove+0x64>
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 0f                	jne    800b63 <memmove+0x5f>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0a                	jne    800b63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b61:	eb 05                	jmp    800b68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 79 ff ff ff       	call   800b04 <memmove>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9d:	eb 1a                	jmp    800bb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b9f:	0f b6 02             	movzbl (%edx),%eax
  800ba2:	0f b6 19             	movzbl (%ecx),%ebx
  800ba5:	38 d8                	cmp    %bl,%al
  800ba7:	74 0a                	je     800bb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba9:	0f b6 c0             	movzbl %al,%eax
  800bac:	0f b6 db             	movzbl %bl,%ebx
  800baf:	29 d8                	sub    %ebx,%eax
  800bb1:	eb 0f                	jmp    800bc2 <memcmp+0x35>
		s1++, s2++;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb9:	39 f2                	cmp    %esi,%edx
  800bbb:	75 e2                	jne    800b9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd4:	eb 07                	jmp    800bdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	38 08                	cmp    %cl,(%eax)
  800bd8:	74 07                	je     800be1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	72 f5                	jb     800bd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 0a             	movzbl (%edx),%ecx
  800bf7:	80 f9 09             	cmp    $0x9,%cl
  800bfa:	74 f5                	je     800bf1 <strtol+0xe>
  800bfc:	80 f9 20             	cmp    $0x20,%cl
  800bff:	74 f0                	je     800bf1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c01:	80 f9 2b             	cmp    $0x2b,%cl
  800c04:	75 0a                	jne    800c10 <strtol+0x2d>
		s++;
  800c06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c09:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0e:	eb 11                	jmp    800c21 <strtol+0x3e>
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c15:	80 f9 2d             	cmp    $0x2d,%cl
  800c18:	75 07                	jne    800c21 <strtol+0x3e>
		s++, neg = 1;
  800c1a:	8d 52 01             	lea    0x1(%edx),%edx
  800c1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c26:	75 15                	jne    800c3d <strtol+0x5a>
  800c28:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2b:	75 10                	jne    800c3d <strtol+0x5a>
  800c2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c31:	75 0a                	jne    800c3d <strtol+0x5a>
		s += 2, base = 16;
  800c33:	83 c2 02             	add    $0x2,%edx
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 10                	jmp    800c4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	75 0c                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c43:	80 3a 30             	cmpb   $0x30,(%edx)
  800c46:	75 05                	jne    800c4d <strtol+0x6a>
		s++, base = 8;
  800c48:	83 c2 01             	add    $0x1,%edx
  800c4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c55:	0f b6 0a             	movzbl (%edx),%ecx
  800c58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	77 08                	ja     800c69 <strtol+0x86>
			dig = *s - '0';
  800c61:	0f be c9             	movsbl %cl,%ecx
  800c64:	83 e9 30             	sub    $0x30,%ecx
  800c67:	eb 20                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	3c 19                	cmp    $0x19,%al
  800c70:	77 08                	ja     800c7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c72:	0f be c9             	movsbl %cl,%ecx
  800c75:	83 e9 57             	sub    $0x57,%ecx
  800c78:	eb 0f                	jmp    800c89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	3c 19                	cmp    $0x19,%al
  800c81:	77 16                	ja     800c99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c83:	0f be c9             	movsbl %cl,%ecx
  800c86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c8c:	7d 0f                	jge    800c9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c97:	eb bc                	jmp    800c55 <strtol+0x72>
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	eb 02                	jmp    800c9f <strtol+0xbc>
  800c9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca3:	74 05                	je     800caa <strtol+0xc7>
		*endptr = (char *) s;
  800ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800caa:	f7 d8                	neg    %eax
  800cac:	85 ff                	test   %edi,%edi
  800cae:	0f 44 c3             	cmove  %ebx,%eax
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	89 c7                	mov    %eax,%edi
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_cgetc>:

int
sys_cgetc(void)
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
  800cdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 03 00 00 00       	mov    $0x3,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 28                	jle    800d3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d20:	00 
  800d21:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800d28:	00 
  800d29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d30:	00 
  800d31:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800d38:	e8 1b 03 00 00       	call   801058 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3d:	83 c4 2c             	add    $0x2c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_yield>:

void
sys_yield(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d74:	89 d1                	mov    %edx,%ecx
  800d76:	89 d3                	mov    %edx,%ebx
  800d78:	89 d7                	mov    %edx,%edi
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	be 00 00 00 00       	mov    $0x0,%esi
  800d91:	b8 04 00 00 00       	mov    $0x4,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	89 f7                	mov    %esi,%edi
  800da1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 28                	jle    800dcf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db2:	00 
  800db3:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800dba:	00 
  800dbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc2:	00 
  800dc3:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800dca:	e8 89 02 00 00       	call   801058 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dcf:	83 c4 2c             	add    $0x2c,%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	b8 05 00 00 00       	mov    $0x5,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df1:	8b 75 18             	mov    0x18(%ebp),%esi
  800df4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800e1d:	e8 36 02 00 00       	call   801058 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e22:	83 c4 2c             	add    $0x2c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800e70:	e8 e3 01 00 00       	call   801058 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e75:	83 c4 2c             	add    $0x2c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	89 df                	mov    %ebx,%edi
  800e98:	89 de                	mov    %ebx,%esi
  800e9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7e 28                	jle    800ec8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eab:	00 
  800eac:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebb:	00 
  800ebc:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800ec3:	e8 90 01 00 00       	call   801058 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec8:	83 c4 2c             	add    $0x2c,%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 28                	jle    800f1b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800f16:	e8 3d 01 00 00       	call   801058 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f1b:	83 c4 2c             	add    $0x2c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f29:	be 00 00 00 00       	mov    $0x0,%esi
  800f2e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	89 cb                	mov    %ecx,%ebx
  800f5e:	89 cf                	mov    %ecx,%edi
  800f60:	89 ce                	mov    %ecx,%esi
  800f62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	7e 28                	jle    800f90 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f73:	00 
  800f74:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f83:	00 
  800f84:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800f8b:	e8 c8 00 00 00       	call   801058 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f90:	83 c4 2c             	add    $0x2c,%esp
  800f93:	5b                   	pop    %ebx
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f9e:	c7 44 24 08 9f 16 80 	movl   $0x80169f,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800fad:	00 
  800fae:	c7 04 24 93 16 80 00 	movl   $0x801693,(%esp)
  800fb5:	e8 9e 00 00 00       	call   801058 <_panic>

00800fba <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fc0:	c7 44 24 08 9e 16 80 	movl   $0x80169e,0x8(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800fcf:	00 
  800fd0:	c7 04 24 93 16 80 00 	movl   $0x801693,(%esp)
  800fd7:	e8 7c 00 00 00       	call   801058 <_panic>

00800fdc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fe2:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 cd 16 80 00 	movl   $0x8016cd,(%esp)
  800ff9:	e8 5a 00 00 00       	call   801058 <_panic>

00800ffe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801004:	c7 44 24 08 d7 16 80 	movl   $0x8016d7,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 cd 16 80 00 	movl   $0x8016cd,(%esp)
  80101b:	e8 38 00 00 00       	call   801058 <_panic>

00801020 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80102b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80102e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801034:	8b 52 50             	mov    0x50(%edx),%edx
  801037:	39 ca                	cmp    %ecx,%edx
  801039:	75 0d                	jne    801048 <ipc_find_env+0x28>
			return envs[i].env_id;
  80103b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80103e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801043:	8b 40 40             	mov    0x40(%eax),%eax
  801046:	eb 0e                	jmp    801056 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801048:	83 c0 01             	add    $0x1,%eax
  80104b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801050:	75 d9                	jne    80102b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801052:	66 b8 00 00          	mov    $0x0,%ax
}
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801060:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801063:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801069:	e8 d7 fc ff ff       	call   800d45 <sys_getenvid>
  80106e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801071:	89 54 24 10          	mov    %edx,0x10(%esp)
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80107c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  80108b:	e8 5a f2 ff ff       	call   8002ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801094:	8b 45 10             	mov    0x10(%ebp),%eax
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	e8 ea f1 ff ff       	call   800289 <vcprintf>
	cprintf("\n");
  80109f:	c7 04 24 72 13 80 00 	movl   $0x801372,(%esp)
  8010a6:	e8 3f f2 ff ff       	call   8002ea <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x53>
	...

008010b0 <__udivdi3>:
  8010b0:	83 ec 1c             	sub    $0x1c,%esp
  8010b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010cb:	85 ff                	test   %edi,%edi
  8010cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d5:	89 cd                	mov    %ecx,%ebp
  8010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010db:	75 33                	jne    801110 <__udivdi3+0x60>
  8010dd:	39 f1                	cmp    %esi,%ecx
  8010df:	77 57                	ja     801138 <__udivdi3+0x88>
  8010e1:	85 c9                	test   %ecx,%ecx
  8010e3:	75 0b                	jne    8010f0 <__udivdi3+0x40>
  8010e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ea:	31 d2                	xor    %edx,%edx
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 c1                	mov    %eax,%ecx
  8010f0:	89 f0                	mov    %esi,%eax
  8010f2:	31 d2                	xor    %edx,%edx
  8010f4:	f7 f1                	div    %ecx
  8010f6:	89 c6                	mov    %eax,%esi
  8010f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010fc:	f7 f1                	div    %ecx
  8010fe:	89 f2                	mov    %esi,%edx
  801100:	8b 74 24 10          	mov    0x10(%esp),%esi
  801104:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801108:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110c:	83 c4 1c             	add    $0x1c,%esp
  80110f:	c3                   	ret    
  801110:	31 d2                	xor    %edx,%edx
  801112:	31 c0                	xor    %eax,%eax
  801114:	39 f7                	cmp    %esi,%edi
  801116:	77 e8                	ja     801100 <__udivdi3+0x50>
  801118:	0f bd cf             	bsr    %edi,%ecx
  80111b:	83 f1 1f             	xor    $0x1f,%ecx
  80111e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801122:	75 2c                	jne    801150 <__udivdi3+0xa0>
  801124:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801128:	76 04                	jbe    80112e <__udivdi3+0x7e>
  80112a:	39 f7                	cmp    %esi,%edi
  80112c:	73 d2                	jae    801100 <__udivdi3+0x50>
  80112e:	31 d2                	xor    %edx,%edx
  801130:	b8 01 00 00 00       	mov    $0x1,%eax
  801135:	eb c9                	jmp    801100 <__udivdi3+0x50>
  801137:	90                   	nop
  801138:	89 f2                	mov    %esi,%edx
  80113a:	f7 f1                	div    %ecx
  80113c:	31 d2                	xor    %edx,%edx
  80113e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801142:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801146:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114a:	83 c4 1c             	add    $0x1c,%esp
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax
  801150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801155:	b8 20 00 00 00       	mov    $0x20,%eax
  80115a:	89 ea                	mov    %ebp,%edx
  80115c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801160:	d3 e7                	shl    %cl,%edi
  801162:	89 c1                	mov    %eax,%ecx
  801164:	d3 ea                	shr    %cl,%edx
  801166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116b:	09 fa                	or     %edi,%edx
  80116d:	89 f7                	mov    %esi,%edi
  80116f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801173:	89 f2                	mov    %esi,%edx
  801175:	8b 74 24 08          	mov    0x8(%esp),%esi
  801179:	d3 e5                	shl    %cl,%ebp
  80117b:	89 c1                	mov    %eax,%ecx
  80117d:	d3 ef                	shr    %cl,%edi
  80117f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	89 c1                	mov    %eax,%ecx
  801188:	d3 ee                	shr    %cl,%esi
  80118a:	09 d6                	or     %edx,%esi
  80118c:	89 fa                	mov    %edi,%edx
  80118e:	89 f0                	mov    %esi,%eax
  801190:	f7 74 24 0c          	divl   0xc(%esp)
  801194:	89 d7                	mov    %edx,%edi
  801196:	89 c6                	mov    %eax,%esi
  801198:	f7 e5                	mul    %ebp
  80119a:	39 d7                	cmp    %edx,%edi
  80119c:	72 22                	jb     8011c0 <__udivdi3+0x110>
  80119e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a7:	d3 e5                	shl    %cl,%ebp
  8011a9:	39 c5                	cmp    %eax,%ebp
  8011ab:	73 04                	jae    8011b1 <__udivdi3+0x101>
  8011ad:	39 d7                	cmp    %edx,%edi
  8011af:	74 0f                	je     8011c0 <__udivdi3+0x110>
  8011b1:	89 f0                	mov    %esi,%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	e9 46 ff ff ff       	jmp    801100 <__udivdi3+0x50>
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011c3:	31 d2                	xor    %edx,%edx
  8011c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011d1:	83 c4 1c             	add    $0x1c,%esp
  8011d4:	c3                   	ret    
	...

008011e0 <__umoddi3>:
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
  8011e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011fb:	85 ed                	test   %ebp,%ebp
  8011fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801201:	89 44 24 08          	mov    %eax,0x8(%esp)
  801205:	89 cf                	mov    %ecx,%edi
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	89 f2                	mov    %esi,%edx
  80120c:	75 1a                	jne    801228 <__umoddi3+0x48>
  80120e:	39 f1                	cmp    %esi,%ecx
  801210:	76 4e                	jbe    801260 <__umoddi3+0x80>
  801212:	f7 f1                	div    %ecx
  801214:	89 d0                	mov    %edx,%eax
  801216:	31 d2                	xor    %edx,%edx
  801218:	8b 74 24 10          	mov    0x10(%esp),%esi
  80121c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801220:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801224:	83 c4 1c             	add    $0x1c,%esp
  801227:	c3                   	ret    
  801228:	39 f5                	cmp    %esi,%ebp
  80122a:	77 54                	ja     801280 <__umoddi3+0xa0>
  80122c:	0f bd c5             	bsr    %ebp,%eax
  80122f:	83 f0 1f             	xor    $0x1f,%eax
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	75 60                	jne    801298 <__umoddi3+0xb8>
  801238:	3b 0c 24             	cmp    (%esp),%ecx
  80123b:	0f 87 07 01 00 00    	ja     801348 <__umoddi3+0x168>
  801241:	89 f2                	mov    %esi,%edx
  801243:	8b 34 24             	mov    (%esp),%esi
  801246:	29 ce                	sub    %ecx,%esi
  801248:	19 ea                	sbb    %ebp,%edx
  80124a:	89 34 24             	mov    %esi,(%esp)
  80124d:	8b 04 24             	mov    (%esp),%eax
  801250:	8b 74 24 10          	mov    0x10(%esp),%esi
  801254:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801258:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	c3                   	ret    
  801260:	85 c9                	test   %ecx,%ecx
  801262:	75 0b                	jne    80126f <__umoddi3+0x8f>
  801264:	b8 01 00 00 00       	mov    $0x1,%eax
  801269:	31 d2                	xor    %edx,%edx
  80126b:	f7 f1                	div    %ecx
  80126d:	89 c1                	mov    %eax,%ecx
  80126f:	89 f0                	mov    %esi,%eax
  801271:	31 d2                	xor    %edx,%edx
  801273:	f7 f1                	div    %ecx
  801275:	8b 04 24             	mov    (%esp),%eax
  801278:	f7 f1                	div    %ecx
  80127a:	eb 98                	jmp    801214 <__umoddi3+0x34>
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 f2                	mov    %esi,%edx
  801282:	8b 74 24 10          	mov    0x10(%esp),%esi
  801286:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80128a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80128e:	83 c4 1c             	add    $0x1c,%esp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129d:	89 e8                	mov    %ebp,%eax
  80129f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8012a8:	89 fa                	mov    %edi,%edx
  8012aa:	d3 e0                	shl    %cl,%eax
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 ea                	shr    %cl,%edx
  8012b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012b5:	09 c2                	or     %eax,%edx
  8012b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bb:	89 14 24             	mov    %edx,(%esp)
  8012be:	89 f2                	mov    %esi,%edx
  8012c0:	d3 e7                	shl    %cl,%edi
  8012c2:	89 e9                	mov    %ebp,%ecx
  8012c4:	d3 ea                	shr    %cl,%edx
  8012c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	d3 e6                	shl    %cl,%esi
  8012d1:	89 e9                	mov    %ebp,%ecx
  8012d3:	d3 e8                	shr    %cl,%eax
  8012d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012da:	09 f0                	or     %esi,%eax
  8012dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012e0:	f7 34 24             	divl   (%esp)
  8012e3:	d3 e6                	shl    %cl,%esi
  8012e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012e9:	89 d6                	mov    %edx,%esi
  8012eb:	f7 e7                	mul    %edi
  8012ed:	39 d6                	cmp    %edx,%esi
  8012ef:	89 c1                	mov    %eax,%ecx
  8012f1:	89 d7                	mov    %edx,%edi
  8012f3:	72 3f                	jb     801334 <__umoddi3+0x154>
  8012f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012f9:	72 35                	jb     801330 <__umoddi3+0x150>
  8012fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ff:	29 c8                	sub    %ecx,%eax
  801301:	19 fe                	sbb    %edi,%esi
  801303:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801308:	89 f2                	mov    %esi,%edx
  80130a:	d3 e8                	shr    %cl,%eax
  80130c:	89 e9                	mov    %ebp,%ecx
  80130e:	d3 e2                	shl    %cl,%edx
  801310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801315:	09 d0                	or     %edx,%eax
  801317:	89 f2                	mov    %esi,%edx
  801319:	d3 ea                	shr    %cl,%edx
  80131b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80131f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801323:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801327:	83 c4 1c             	add    $0x1c,%esp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	39 d6                	cmp    %edx,%esi
  801332:	75 c7                	jne    8012fb <__umoddi3+0x11b>
  801334:	89 d7                	mov    %edx,%edi
  801336:	89 c1                	mov    %eax,%ecx
  801338:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80133c:	1b 3c 24             	sbb    (%esp),%edi
  80133f:	eb ba                	jmp    8012fb <__umoddi3+0x11b>
  801341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801348:	39 f5                	cmp    %esi,%ebp
  80134a:	0f 82 f1 fe ff ff    	jb     801241 <__umoddi3+0x61>
  801350:	e9 f8 fe ff ff       	jmp    80124d <__umoddi3+0x6d>
