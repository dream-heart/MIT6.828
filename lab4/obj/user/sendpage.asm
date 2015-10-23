
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
  80003a:	e8 f4 10 00 00       	call   801133 <fork>
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
  800060:	e8 03 13 00 00       	call   801368 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 e0 17 80 00 	movl   $0x8017e0,(%esp)
  80007b:	e8 6b 02 00 00       	call   8002eb <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 33 08 00 00       	call   8008c0 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 27 09 00 00       	call   8009cd <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 f4 17 80 00 	movl   $0x8017f4,(%esp)
  8000b1:	e8 35 02 00 00       	call   8002eb <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 fd 07 00 00       	call   8008c0 <strlen>
  8000c3:	83 c0 01             	add    $0x1,%eax
  8000c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ca:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d3:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000da:	e8 38 0a 00 00       	call   800b17 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000df:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e6:	00 
  8000e7:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f6:	00 
  8000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000fa:	89 04 24             	mov    %eax,(%esp)
  8000fd:	e8 88 12 00 00       	call   80138a <ipc_send>
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
  800122:	e8 5d 0c 00 00       	call   800d84 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800127:	a1 04 20 80 00       	mov    0x802004,%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 8c 07 00 00       	call   8008c0 <strlen>
  800134:	83 c0 01             	add    $0x1,%eax
  800137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013b:	a1 04 20 80 00       	mov    0x802004,%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014b:	e8 c7 09 00 00       	call   800b17 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800150:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800157:	00 
  800158:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800167:	00 
  800168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 17 12 00 00       	call   80138a <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800173:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017a:	00 
  80017b:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800182:	00 
  800183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 da 11 00 00       	call   801368 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018e:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800195:	00 
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	c7 04 24 e0 17 80 00 	movl   $0x8017e0,(%esp)
  8001a4:	e8 42 01 00 00       	call   8002eb <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a9:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 0a 07 00 00       	call   8008c0 <strlen>
  8001b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ba:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c3:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001ca:	e8 fe 07 00 00       	call   8009cd <strncmp>
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	75 0c                	jne    8001df <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d3:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8001da:	e8 0c 01 00 00       	call   8002eb <cprintf>
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
  8001f6:	e8 29 0b 00 00       	call   800d24 <sys_getenvid>
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
  800224:	e8 0b 00 00 00       	call   800234 <exit>
}
  800229:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80022c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 81 0a 00 00       	call   800cc7 <sys_env_destroy>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	53                   	push   %ebx
  80024c:	83 ec 14             	sub    $0x14,%esp
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800252:	8b 03                	mov    (%ebx),%eax
  800254:	8b 55 08             	mov    0x8(%ebp),%edx
  800257:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80025b:	83 c0 01             	add    $0x1,%eax
  80025e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800260:	3d ff 00 00 00       	cmp    $0xff,%eax
  800265:	75 19                	jne    800280 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800267:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80026e:	00 
  80026f:	8d 43 08             	lea    0x8(%ebx),%eax
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	e8 ee 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  80027a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800280:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800284:	83 c4 14             	add    $0x14,%esp
  800287:	5b                   	pop    %ebx
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800293:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029a:	00 00 00 
	b.cnt = 0;
  80029d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	c7 04 24 48 02 80 00 	movl   $0x800248,(%esp)
  8002c6:	e8 92 01 00 00       	call   80045d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002cb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	e8 85 09 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  8002e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	e8 87 ff ff ff       	call   80028a <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    
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
  800321:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80032d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800330:	85 c0                	test   %eax,%eax
  800332:	75 08                	jne    80033c <printnum+0x2c>
  800334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800337:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033a:	77 59                	ja     800395 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800340:	83 eb 01             	sub    $0x1,%ebx
  800343:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800347:	8b 45 10             	mov    0x10(%ebp),%eax
  80034a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800352:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800356:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035d:	00 
  80035e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800361:	89 04 24             	mov    %eax,(%esp)
  800364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036b:	e8 b0 11 00 00       	call   801520 <__udivdi3>
  800370:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800374:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037f:	89 fa                	mov    %edi,%edx
  800381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800384:	e8 87 ff ff ff       	call   800310 <printnum>
  800389:	eb 11                	jmp    80039c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038f:	89 34 24             	mov    %esi,(%esp)
  800392:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800395:	83 eb 01             	sub    $0x1,%ebx
  800398:	85 db                	test   %ebx,%ebx
  80039a:	7f ef                	jg     80038b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003b2:	00 
  8003b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b6:	89 04 24             	mov    %eax,(%esp)
  8003b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c0:	e8 8b 12 00 00       	call   801650 <__umoddi3>
  8003c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c9:	0f be 80 8c 18 80 00 	movsbl 0x80188c(%eax),%eax
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003d6:	83 c4 3c             	add    $0x3c,%esp
  8003d9:	5b                   	pop    %ebx
  8003da:	5e                   	pop    %esi
  8003db:	5f                   	pop    %edi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e1:	83 fa 01             	cmp    $0x1,%edx
  8003e4:	7e 0e                	jle    8003f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e6:	8b 10                	mov    (%eax),%edx
  8003e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 02                	mov    (%edx),%eax
  8003ef:	8b 52 04             	mov    0x4(%edx),%edx
  8003f2:	eb 22                	jmp    800416 <getuint+0x38>
	else if (lflag)
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	74 10                	je     800408 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 02                	mov    (%edx),%eax
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
  800406:	eb 0e                	jmp    800416 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800408:	8b 10                	mov    (%eax),%edx
  80040a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040d:	89 08                	mov    %ecx,(%eax)
  80040f:	8b 02                	mov    (%edx),%eax
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800422:	8b 10                	mov    (%eax),%edx
  800424:	3b 50 04             	cmp    0x4(%eax),%edx
  800427:	73 0a                	jae    800433 <sprintputch+0x1b>
		*b->buf++ = ch;
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	88 0a                	mov    %cl,(%edx)
  80042e:	83 c2 01             	add    $0x1,%edx
  800431:	89 10                	mov    %edx,(%eax)
}
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80043b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800442:	8b 45 10             	mov    0x10(%ebp),%eax
  800445:	89 44 24 08          	mov    %eax,0x8(%esp)
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	8b 45 08             	mov    0x8(%ebp),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	e8 02 00 00 00       	call   80045d <vprintfmt>
	va_end(ap);
}
  80045b:	c9                   	leave  
  80045c:	c3                   	ret    

0080045d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	57                   	push   %edi
  800461:	56                   	push   %esi
  800462:	53                   	push   %ebx
  800463:	83 ec 4c             	sub    $0x4c,%esp
  800466:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800469:	8b 75 10             	mov    0x10(%ebp),%esi
  80046c:	eb 12                	jmp    800480 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80046e:	85 c0                	test   %eax,%eax
  800470:	0f 84 bf 03 00 00    	je     800835 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800476:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047a:	89 04 24             	mov    %eax,(%esp)
  80047d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800480:	0f b6 06             	movzbl (%esi),%eax
  800483:	83 c6 01             	add    $0x1,%esi
  800486:	83 f8 25             	cmp    $0x25,%eax
  800489:	75 e3                	jne    80046e <vprintfmt+0x11>
  80048b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80048f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800496:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80049b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004aa:	eb 2b                	jmp    8004d7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004af:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004b3:	eb 22                	jmp    8004d7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004bc:	eb 19                	jmp    8004d7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004c1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c8:	eb 0d                	jmp    8004d7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	0f b6 16             	movzbl (%esi),%edx
  8004da:	0f b6 c2             	movzbl %dl,%eax
  8004dd:	8d 7e 01             	lea    0x1(%esi),%edi
  8004e0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004e3:	83 ea 23             	sub    $0x23,%edx
  8004e6:	80 fa 55             	cmp    $0x55,%dl
  8004e9:	0f 87 28 03 00 00    	ja     800817 <vprintfmt+0x3ba>
  8004ef:	0f b6 d2             	movzbl %dl,%edx
  8004f2:	ff 24 95 60 19 80 00 	jmp    *0x801960(,%edx,4)
  8004f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800503:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800508:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80050b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80050f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800512:	8d 50 d0             	lea    -0x30(%eax),%edx
  800515:	83 fa 09             	cmp    $0x9,%edx
  800518:	77 2f                	ja     800549 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80051a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80051d:	eb e9                	jmp    800508 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800530:	eb 1a                	jmp    80054c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800535:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800539:	79 9c                	jns    8004d7 <vprintfmt+0x7a>
  80053b:	eb 81                	jmp    8004be <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800540:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800547:	eb 8e                	jmp    8004d7 <vprintfmt+0x7a>
  800549:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80054c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800550:	79 85                	jns    8004d7 <vprintfmt+0x7a>
  800552:	e9 73 ff ff ff       	jmp    8004ca <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800557:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055d:	e9 75 ff ff ff       	jmp    8004d7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057a:	e9 01 ff ff ff       	jmp    800480 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 c2                	mov    %eax,%edx
  80058c:	c1 fa 1f             	sar    $0x1f,%edx
  80058f:	31 d0                	xor    %edx,%eax
  800591:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800593:	83 f8 09             	cmp    $0x9,%eax
  800596:	7f 0b                	jg     8005a3 <vprintfmt+0x146>
  800598:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	75 23                	jne    8005c6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8005a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a7:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  8005ae:	00 
  8005af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b6:	89 3c 24             	mov    %edi,(%esp)
  8005b9:	e8 77 fe ff ff       	call   800435 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c1:	e9 ba fe ff ff       	jmp    800480 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ca:	c7 44 24 08 ad 18 80 	movl   $0x8018ad,0x8(%esp)
  8005d1:	00 
  8005d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	e8 54 fe ff ff       	call   800435 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e4:	e9 97 fe ff ff       	jmp    800480 <vprintfmt+0x23>
  8005e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005fd:	85 f6                	test   %esi,%esi
  8005ff:	ba 9d 18 80 00       	mov    $0x80189d,%edx
  800604:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800607:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060b:	0f 8e 8c 00 00 00    	jle    80069d <vprintfmt+0x240>
  800611:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800615:	0f 84 82 00 00 00    	je     80069d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	e8 b1 02 00 00       	call   8008d8 <strnlen>
  800627:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062a:	29 c2                	sub    %eax,%edx
  80062c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80062f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800633:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800636:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800639:	89 de                	mov    %ebx,%esi
  80063b:	89 d3                	mov    %edx,%ebx
  80063d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	eb 0d                	jmp    80064e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800641:	89 74 24 04          	mov    %esi,0x4(%esp)
  800645:	89 3c 24             	mov    %edi,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064b:	83 eb 01             	sub    $0x1,%ebx
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7f ef                	jg     800641 <vprintfmt+0x1e4>
  800652:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800655:	89 f3                	mov    %esi,%ebx
  800657:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065e:	b8 00 00 00 00       	mov    $0x0,%eax
  800663:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800667:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066a:	29 c2                	sub    %eax,%edx
  80066c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80066f:	eb 2c                	jmp    80069d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800675:	74 18                	je     80068f <vprintfmt+0x232>
  800677:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067a:	83 fa 5e             	cmp    $0x5e,%edx
  80067d:	76 10                	jbe    80068f <vprintfmt+0x232>
					putch('?', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	eb 0a                	jmp    800699 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800699:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	83 c6 01             	add    $0x1,%esi
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 25                	je     8006cc <vprintfmt+0x26f>
  8006a7:	85 ff                	test   %edi,%edi
  8006a9:	78 c6                	js     800671 <vprintfmt+0x214>
  8006ab:	83 ef 01             	sub    $0x1,%edi
  8006ae:	79 c1                	jns    800671 <vprintfmt+0x214>
  8006b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b3:	89 de                	mov    %ebx,%esi
  8006b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b8:	eb 1a                	jmp    8006d4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c7:	83 eb 01             	sub    $0x1,%ebx
  8006ca:	eb 08                	jmp    8006d4 <vprintfmt+0x277>
  8006cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cf:	89 de                	mov    %ebx,%esi
  8006d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d4:	85 db                	test   %ebx,%ebx
  8006d6:	7f e2                	jg     8006ba <vprintfmt+0x25d>
  8006d8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006db:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e0:	e9 9b fd ff ff       	jmp    800480 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e5:	83 f9 01             	cmp    $0x1,%ecx
  8006e8:	7e 10                	jle    8006fa <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 08             	lea    0x8(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 30                	mov    (%eax),%esi
  8006f5:	8b 78 04             	mov    0x4(%eax),%edi
  8006f8:	eb 26                	jmp    800720 <vprintfmt+0x2c3>
	else if (lflag)
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	74 12                	je     800710 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)
  800707:	8b 30                	mov    (%eax),%esi
  800709:	89 f7                	mov    %esi,%edi
  80070b:	c1 ff 1f             	sar    $0x1f,%edi
  80070e:	eb 10                	jmp    800720 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	8b 30                	mov    (%eax),%esi
  80071b:	89 f7                	mov    %esi,%edi
  80071d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800720:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800725:	85 ff                	test   %edi,%edi
  800727:	0f 89 ac 00 00 00    	jns    8007d9 <vprintfmt+0x37c>
				putch('-', putdat);
  80072d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800731:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800738:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073b:	f7 de                	neg    %esi
  80073d:	83 d7 00             	adc    $0x0,%edi
  800740:	f7 df                	neg    %edi
			}
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 8d 00 00 00       	jmp    8007d9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074c:	89 ca                	mov    %ecx,%edx
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 88 fc ff ff       	call   8003de <getuint>
  800756:	89 c6                	mov    %eax,%esi
  800758:	89 d7                	mov    %edx,%edi
			base = 10;
  80075a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80075f:	eb 78                	jmp    8007d9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800761:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800765:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80076c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80076f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800773:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80077a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80077d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800781:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800788:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80078e:	e9 ed fc ff ff       	jmp    800480 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80079e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b8:	8b 30                	mov    (%eax),%esi
  8007ba:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007c4:	eb 13                	jmp    8007d9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c6:	89 ca                	mov    %ecx,%edx
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cb:	e8 0e fc ff ff       	call   8003de <getuint>
  8007d0:	89 c6                	mov    %eax,%esi
  8007d2:	89 d7                	mov    %edx,%edi
			base = 16;
  8007d4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ec:	89 34 24             	mov    %esi,(%esp)
  8007ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f3:	89 da                	mov    %ebx,%edx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	e8 13 fb ff ff       	call   800310 <printnum>
			break;
  8007fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800800:	e9 7b fc ff ff       	jmp    800480 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800805:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800809:	89 04 24             	mov    %eax,(%esp)
  80080c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800812:	e9 69 fc ff ff       	jmp    800480 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800822:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800825:	eb 03                	jmp    80082a <vprintfmt+0x3cd>
  800827:	83 ee 01             	sub    $0x1,%esi
  80082a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80082e:	75 f7                	jne    800827 <vprintfmt+0x3ca>
  800830:	e9 4b fc ff ff       	jmp    800480 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800835:	83 c4 4c             	add    $0x4c,%esp
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5f                   	pop    %edi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 28             	sub    $0x28,%esp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800850:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 30                	je     80088e <vsnprintf+0x51>
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 2c                	jle    80088e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800869:	8b 45 10             	mov    0x10(%ebp),%eax
  80086c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800870:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800873:	89 44 24 04          	mov    %eax,0x4(%esp)
  800877:	c7 04 24 18 04 80 00 	movl   $0x800418,(%esp)
  80087e:	e8 da fb ff ff       	call   80045d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800883:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800886:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088c:	eb 05                	jmp    800893 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80088e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 82 ff ff ff       	call   80083d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    
  8008bd:	00 00                	add    %al,(%eax)
	...

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
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
{
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
  8008fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800901:	ba 00 00 00 00       	mov    $0x0,%edx
  800906:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80090a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80090d:	83 c2 01             	add    $0x1,%edx
  800910:	84 c9                	test   %cl,%cl
  800912:	75 f2                	jne    800906 <strcpy+0xf>
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
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800950:	b9 00 00 00 00       	mov    $0x0,%ecx
  800955:	eb 0f                	jmp    800966 <strncpy+0x24>
		*dst++ = *src;
  800957:	0f b6 1a             	movzbl (%edx),%ebx
  80095a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095d:	80 3a 01             	cmpb   $0x1,(%edx)
  800960:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800963:	83 c1 01             	add    $0x1,%ecx
  800966:	39 f1                	cmp    %esi,%ecx
  800968:	75 ed                	jne    800957 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 75 08             	mov    0x8(%ebp),%esi
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800979:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	85 d2                	test   %edx,%edx
  800980:	75 0a                	jne    80098c <strlcpy+0x1e>
  800982:	eb 1d                	jmp    8009a1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800984:	88 18                	mov    %bl,(%eax)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098c:	83 ea 01             	sub    $0x1,%edx
  80098f:	74 0b                	je     80099c <strlcpy+0x2e>
  800991:	0f b6 19             	movzbl (%ecx),%ebx
  800994:	84 db                	test   %bl,%bl
  800996:	75 ec                	jne    800984 <strlcpy+0x16>
  800998:	89 c2                	mov    %eax,%edx
  80099a:	eb 02                	jmp    80099e <strlcpy+0x30>
  80099c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80099e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009a1:	29 f0                	sub    %esi,%eax
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b0:	eb 06                	jmp    8009b8 <strcmp+0x11>
		p++, q++;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b8:	0f b6 01             	movzbl (%ecx),%eax
  8009bb:	84 c0                	test   %al,%al
  8009bd:	74 04                	je     8009c3 <strcmp+0x1c>
  8009bf:	3a 02                	cmp    (%edx),%al
  8009c1:	74 ef                	je     8009b2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c3:	0f b6 c0             	movzbl %al,%eax
  8009c6:	0f b6 12             	movzbl (%edx),%edx
  8009c9:	29 d0                	sub    %edx,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009da:	eb 09                	jmp    8009e5 <strncmp+0x18>
		n--, p++, q++;
  8009dc:	83 ea 01             	sub    $0x1,%edx
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e5:	85 d2                	test   %edx,%edx
  8009e7:	74 15                	je     8009fe <strncmp+0x31>
  8009e9:	0f b6 18             	movzbl (%eax),%ebx
  8009ec:	84 db                	test   %bl,%bl
  8009ee:	74 04                	je     8009f4 <strncmp+0x27>
  8009f0:	3a 19                	cmp    (%ecx),%bl
  8009f2:	74 e8                	je     8009dc <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f4:	0f b6 00             	movzbl (%eax),%eax
  8009f7:	0f b6 11             	movzbl (%ecx),%edx
  8009fa:	29 d0                	sub    %edx,%eax
  8009fc:	eb 05                	jmp    800a03 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a10:	eb 07                	jmp    800a19 <strchr+0x13>
		if (*s == c)
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	74 0f                	je     800a25 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 10             	movzbl (%eax),%edx
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f2                	jne    800a12 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a31:	eb 07                	jmp    800a3a <strfind+0x13>
		if (*s == c)
  800a33:	38 ca                	cmp    %cl,%dl
  800a35:	74 0a                	je     800a41 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	0f b6 10             	movzbl (%eax),%edx
  800a3d:	84 d2                	test   %dl,%dl
  800a3f:	75 f2                	jne    800a33 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a5b:	85 c9                	test   %ecx,%ecx
  800a5d:	74 30                	je     800a8f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 25                	jne    800a8c <memset+0x49>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 20                	jne    800a8c <memset+0x49>
		c &= 0xFF;
  800a6c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	c1 e3 08             	shl    $0x8,%ebx
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	c1 e6 18             	shl    $0x18,%esi
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	c1 e0 10             	shl    $0x10,%eax
  800a7e:	09 f0                	or     %esi,%eax
  800a80:	09 d0                	or     %edx,%eax
  800a82:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a84:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a87:	fc                   	cld    
  800a88:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8a:	eb 03                	jmp    800a8f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8c:	fc                   	cld    
  800a8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8f:	89 f8                	mov    %edi,%eax
  800a91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a9a:	89 ec                	mov    %ebp,%esp
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 08             	sub    $0x8,%esp
  800aa4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aa7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab3:	39 c6                	cmp    %eax,%esi
  800ab5:	73 36                	jae    800aed <memmove+0x4f>
  800ab7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aba:	39 d0                	cmp    %edx,%eax
  800abc:	73 2f                	jae    800aed <memmove+0x4f>
		s += n;
		d += n;
  800abe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	f6 c2 03             	test   $0x3,%dl
  800ac4:	75 1b                	jne    800ae1 <memmove+0x43>
  800ac6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acc:	75 13                	jne    800ae1 <memmove+0x43>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 0e                	jne    800ae1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad3:	83 ef 04             	sub    $0x4,%edi
  800ad6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800adc:	fd                   	std    
  800add:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800adf:	eb 09                	jmp    800aea <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae1:	83 ef 01             	sub    $0x1,%edi
  800ae4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae7:	fd                   	std    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aea:	fc                   	cld    
  800aeb:	eb 20                	jmp    800b0d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af3:	75 13                	jne    800b08 <memmove+0x6a>
  800af5:	a8 03                	test   $0x3,%al
  800af7:	75 0f                	jne    800b08 <memmove+0x6a>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 0a                	jne    800b08 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	fc                   	cld    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 05                	jmp    800b0d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	fc                   	cld    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b13:	89 ec                	mov    %ebp,%esp
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	89 04 24             	mov    %eax,(%esp)
  800b31:	e8 68 ff ff ff       	call   800a9e <memmove>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	eb 1a                	jmp    800b68 <memcmp+0x30>
		if (*s1 != *s2)
  800b4e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b52:	83 c2 01             	add    $0x1,%edx
  800b55:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800b5a:	38 c8                	cmp    %cl,%al
  800b5c:	74 0a                	je     800b68 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800b5e:	0f b6 c0             	movzbl %al,%eax
  800b61:	0f b6 c9             	movzbl %cl,%ecx
  800b64:	29 c8                	sub    %ecx,%eax
  800b66:	eb 09                	jmp    800b71 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b68:	39 da                	cmp    %ebx,%edx
  800b6a:	75 e2                	jne    800b4e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b84:	eb 07                	jmp    800b8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b86:	38 08                	cmp    %cl,(%eax)
  800b88:	74 07                	je     800b91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	39 d0                	cmp    %edx,%eax
  800b8f:	72 f5                	jb     800b86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9f:	eb 03                	jmp    800ba4 <strtol+0x11>
		s++;
  800ba1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba4:	0f b6 02             	movzbl (%edx),%eax
  800ba7:	3c 20                	cmp    $0x20,%al
  800ba9:	74 f6                	je     800ba1 <strtol+0xe>
  800bab:	3c 09                	cmp    $0x9,%al
  800bad:	74 f2                	je     800ba1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800baf:	3c 2b                	cmp    $0x2b,%al
  800bb1:	75 0a                	jne    800bbd <strtol+0x2a>
		s++;
  800bb3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbb:	eb 10                	jmp    800bcd <strtol+0x3a>
  800bbd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc2:	3c 2d                	cmp    $0x2d,%al
  800bc4:	75 07                	jne    800bcd <strtol+0x3a>
		s++, neg = 1;
  800bc6:	8d 52 01             	lea    0x1(%edx),%edx
  800bc9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	0f 94 c0             	sete   %al
  800bd2:	74 05                	je     800bd9 <strtol+0x46>
  800bd4:	83 fb 10             	cmp    $0x10,%ebx
  800bd7:	75 15                	jne    800bee <strtol+0x5b>
  800bd9:	80 3a 30             	cmpb   $0x30,(%edx)
  800bdc:	75 10                	jne    800bee <strtol+0x5b>
  800bde:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be2:	75 0a                	jne    800bee <strtol+0x5b>
		s += 2, base = 16;
  800be4:	83 c2 02             	add    $0x2,%edx
  800be7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bec:	eb 13                	jmp    800c01 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bee:	84 c0                	test   %al,%al
  800bf0:	74 0f                	je     800c01 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfa:	75 05                	jne    800c01 <strtol+0x6e>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 0a             	movzbl (%edx),%ecx
  800c0b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c0e:	80 fb 09             	cmp    $0x9,%bl
  800c11:	77 08                	ja     800c1b <strtol+0x88>
			dig = *s - '0';
  800c13:	0f be c9             	movsbl %cl,%ecx
  800c16:	83 e9 30             	sub    $0x30,%ecx
  800c19:	eb 1e                	jmp    800c39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c1b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c1e:	80 fb 19             	cmp    $0x19,%bl
  800c21:	77 08                	ja     800c2b <strtol+0x98>
			dig = *s - 'a' + 10;
  800c23:	0f be c9             	movsbl %cl,%ecx
  800c26:	83 e9 57             	sub    $0x57,%ecx
  800c29:	eb 0e                	jmp    800c39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c2b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 14                	ja     800c47 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800c33:	0f be c9             	movsbl %cl,%ecx
  800c36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c39:	39 f1                	cmp    %esi,%ecx
  800c3b:	7d 0e                	jge    800c4b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800c3d:	83 c2 01             	add    $0x1,%edx
  800c40:	0f af c6             	imul   %esi,%eax
  800c43:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c45:	eb c1                	jmp    800c08 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c47:	89 c1                	mov    %eax,%ecx
  800c49:	eb 02                	jmp    800c4d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c51:	74 05                	je     800c58 <strtol+0xc5>
		*endptr = (char *) s;
  800c53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c56:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c58:	89 ca                	mov    %ecx,%edx
  800c5a:	f7 da                	neg    %edx
  800c5c:	85 ff                	test   %edi,%edi
  800c5e:	0f 45 c2             	cmovne %edx,%eax
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    
	...

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c71:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c74:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	89 c3                	mov    %eax,%ebx
  800c84:	89 c7                	mov    %eax,%edi
  800c86:	89 c6                	mov    %eax,%esi
  800c88:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c93:	89 ec                	mov    %ebp,%esp
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb0:	89 d1                	mov    %edx,%ecx
  800cb2:	89 d3                	mov    %edx,%ebx
  800cb4:	89 d7                	mov    %edx,%edi
  800cb6:	89 d6                	mov    %edx,%esi
  800cb8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc3:	89 ec                	mov    %ebp,%esp
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 38             	sub    $0x38,%esp
  800ccd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 cb                	mov    %ecx,%ebx
  800ce5:	89 cf                	mov    %ecx,%edi
  800ce7:	89 ce                	mov    %ecx,%esi
  800ce9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 28                	jle    800d17 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800d02:	00 
  800d03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0a:	00 
  800d0b:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800d12:	e8 cd 06 00 00       	call   8013e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d17:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d1d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d20:	89 ec                	mov    %ebp,%esp
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d2d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d30:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d50:	89 ec                	mov    %ebp,%esp
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d60:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
  800d68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6d:	89 d1                	mov    %edx,%ecx
  800d6f:	89 d3                	mov    %edx,%ebx
  800d71:	89 d7                	mov    %edx,%edi
  800d73:	89 d6                	mov    %edx,%esi
  800d75:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d80:	89 ec                	mov    %ebp,%esp
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 38             	sub    $0x38,%esp
  800d8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d90:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 f7                	mov    %esi,%edi
  800da8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 28                	jle    800dd6 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800db9:	00 
  800dba:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc9:	00 
  800dca:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800dd1:	e8 0e 06 00 00       	call   8013e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ddc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddf:	89 ec                	mov    %ebp,%esp
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	83 ec 38             	sub    $0x38,%esp
  800de9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800def:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b8 05 00 00 00       	mov    $0x5,%eax
  800df7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	7e 28                	jle    800e34 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e10:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e17:	00 
  800e18:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800e1f:	00 
  800e20:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e27:	00 
  800e28:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800e2f:	e8 b0 05 00 00       	call   8013e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e34:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e37:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e3a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3d:	89 ec                	mov    %ebp,%esp
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 38             	sub    $0x38,%esp
  800e47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800e8d:	e8 52 05 00 00       	call   8013e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 38             	sub    $0x38,%esp
  800ea5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb3:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 df                	mov    %ebx,%edi
  800ec0:	89 de                	mov    %ebx,%esi
  800ec2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 28                	jle    800ef0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecc:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800edb:	00 
  800edc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee3:	00 
  800ee4:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800eeb:	e8 f4 04 00 00       	call   8013e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef9:	89 ec                	mov    %ebp,%esp
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 38             	sub    $0x38,%esp
  800f03:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f06:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f09:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	b8 09 00 00 00       	mov    $0x9,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800f49:	e8 96 04 00 00       	call   8013e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f57:	89 ec                	mov    %ebp,%esp
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6a:	be 00 00 00 00       	mov    $0x0,%esi
  800f6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8b:	89 ec                	mov    %ebp,%esp
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 38             	sub    $0x38,%esp
  800f95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	89 cb                	mov    %ecx,%ebx
  800fad:	89 cf                	mov    %ecx,%edi
  800faf:	89 ce                	mov    %ecx,%esi
  800fb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 28                	jle    800fdf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 05 1b 80 00 	movl   $0x801b05,(%esp)
  800fda:	e8 05 04 00 00       	call   8013e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe8:	89 ec                	mov    %ebp,%esp
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 20             	sub    $0x20,%esp
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ff7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0)
  800ff9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ffd:	75 1c                	jne    80101b <pgfault+0x2f>
		 panic("The err is not right of the pgfault\n");
  800fff:	c7 44 24 08 14 1b 80 	movl   $0x801b14,0x8(%esp)
  801006:	00 
  801007:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80100e:	00 
  80100f:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801016:	e8 c9 03 00 00       	call   8013e4 <_panic>
	pte_t PTE =uvpt[PGNUM(addr)];
  80101b:	89 d8                	mov    %ebx,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	75 1c                	jne    801048 <pgfault+0x5c>
		panic("The pgfault perm is not right\n");
  80102c:	c7 44 24 08 3c 1b 80 	movl   $0x801b3c,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801043:	e8 9c 03 00 00       	call   8013e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  801048:	e8 d7 fc ff ff       	call   800d24 <sys_getenvid>
  80104d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80105c:	00 
  80105d:	89 04 24             	mov    %eax,(%esp)
  801060:	e8 1f fd ff ff       	call   800d84 <sys_page_alloc>
  801065:	85 c0                	test   %eax,%eax
  801067:	79 1c                	jns    801085 <pgfault+0x99>
		panic("pgfault sys_page_alloc is not right\n");
  801069:	c7 44 24 08 5c 1b 80 	movl   $0x801b5c,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801080:	e8 5f 03 00 00       	call   8013e4 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801085:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80108b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801092:	00 
  801093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801097:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80109e:	e8 74 fa ff ff       	call   800b17 <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8010a3:	e8 7c fc ff ff       	call   800d24 <sys_getenvid>
  8010a8:	89 c6                	mov    %eax,%esi
  8010aa:	e8 75 fc ff ff       	call   800d24 <sys_getenvid>
  8010af:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010b6:	00 
  8010b7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010bb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010bf:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c6:	00 
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	e8 14 fd ff ff       	call   800de3 <sys_page_map>
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	79 20                	jns    8010f3 <pgfault+0x107>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  8010d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d7:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  8010ee:	e8 f1 02 00 00       	call   8013e4 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  8010f3:	e8 2c fc ff ff       	call   800d24 <sys_getenvid>
  8010f8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ff:	00 
  801100:	89 04 24             	mov    %eax,(%esp)
  801103:	e8 39 fd ff ff       	call   800e41 <sys_page_unmap>
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 20                	jns    80112c <pgfault+0x140>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80110c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801110:	c7 44 24 08 b4 1b 80 	movl   $0x801bb4,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801127:	e8 b8 02 00 00       	call   8013e4 <_panic>




	//panic("pgfault not implemented");
}
  80112c:	83 c4 20             	add    $0x20,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80113c:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  801143:	e8 f4 02 00 00       	call   80143c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801148:	ba 07 00 00 00       	mov    $0x7,%edx
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	cd 30                	int    $0x30
  801151:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801154:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801157:	85 c0                	test   %eax,%eax
  801159:	79 20                	jns    80117b <fork+0x48>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80115b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115f:	c7 44 24 08 e8 1b 80 	movl   $0x801be8,0x8(%esp)
  801166:	00 
  801167:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801176:	e8 69 02 00 00       	call   8013e4 <_panic>
	if(childEid == 0){
  80117b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80117f:	75 1c                	jne    80119d <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801181:	e8 9e fb ff ff       	call   800d24 <sys_getenvid>
  801186:	25 ff 03 00 00       	and    $0x3ff,%eax
  80118b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801193:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return childEid;
  801198:	e9 9d 01 00 00       	jmp    80133a <fork+0x207>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80119d:	c7 44 24 04 d4 14 80 	movl   $0x8014d4,0x4(%esp)
  8011a4:	00 
  8011a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	e8 4d fd ff ff       	call   800efd <sys_env_set_pgfault_upcall>
  8011b0:	89 c6                	mov    %eax,%esi
	if(r < 0)
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 20                	jns    8011d6 <fork+0xa3>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  8011b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ba:	c7 44 24 08 1c 1c 80 	movl   $0x801c1c,0x8(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011c9:	00 
  8011ca:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  8011d1:	e8 0e 02 00 00       	call   8013e4 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8011d6:	bb 00 10 00 00       	mov    $0x1000,%ebx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011db:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e5:	eb 04                	jmp    8011eb <fork+0xb8>
  8011e7:	89 da                	mov    %ebx,%edx
  8011e9:	89 c3                	mov    %eax,%ebx
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011eb:	89 d0                	mov    %edx,%eax
  8011ed:	c1 e8 16             	shr    $0x16,%eax
  8011f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f7:	a8 01                	test   $0x1,%al
  8011f9:	0f 84 f5 00 00 00    	je     8012f4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8011ff:	c1 ea 0c             	shr    $0xc,%edx
  801202:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801209:	a8 04                	test   $0x4,%al
  80120b:	0f 84 e3 00 00 00    	je     8012f4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801211:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801218:	a8 01                	test   $0x1,%al
  80121a:	0f 84 d4 00 00 00    	je     8012f4 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  801220:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801226:	75 20                	jne    801248 <fork+0x115>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801228:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80122f:	00 
  801230:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801237:	ee 
  801238:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80123b:	89 14 24             	mov    %edx,(%esp)
  80123e:	e8 41 fb ff ff       	call   800d84 <sys_page_alloc>
  801243:	e9 88 00 00 00       	jmp    8012d0 <fork+0x19d>
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  801248:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  80124e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801251:	c1 e8 0c             	shr    $0xc,%eax
  801254:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  80125b:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  801260:	83 f8 01             	cmp    $0x1,%eax
  801263:	19 ff                	sbb    %edi,%edi
  801265:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80126b:	81 c7 05 08 00 00    	add    $0x805,%edi
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  801271:	e8 ae fa ff ff       	call   800d24 <sys_getenvid>
  801276:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80127a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80127d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801281:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801284:	89 54 24 08          	mov    %edx,0x8(%esp)
  801288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80128b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 4c fb ff ff       	call   800de3 <sys_page_map>
  801297:	89 c6                	mov    %eax,%esi
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 33                	js     8012d0 <fork+0x19d>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  80129d:	e8 82 fa ff ff       	call   800d24 <sys_getenvid>
  8012a2:	89 c6                	mov    %eax,%esi
  8012a4:	e8 7b fa ff ff       	call   800d24 <sys_getenvid>
  8012a9:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8012ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012b4:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012bc:	89 04 24             	mov    %eax,(%esp)
  8012bf:	e8 1f fb ff ff       	call   800de3 <sys_page_map>
  8012c4:	89 c6                	mov    %eax,%esi
						<0)  
		return r;

	return 0;
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cd:	0f 49 f0             	cmovns %eax,%esi
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  8012d0:	85 f6                	test   %esi,%esi
  8012d2:	79 20                	jns    8012f4 <fork+0x1c1>
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8012d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d8:	c7 44 24 08 5c 1c 80 	movl   $0x801c5c,0x8(%esp)
  8012df:	00 
  8012e0:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  8012e7:	00 
  8012e8:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  8012ef:	e8 f0 00 00 00       	call   8013e4 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8012f4:	89 d9                	mov    %ebx,%ecx
  8012f6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  8012fc:	3d 00 10 c0 ee       	cmp    $0xeec01000,%eax
  801301:	0f 85 e0 fe ff ff    	jne    8011e7 <fork+0xb4>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  801307:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80130e:	00 
  80130f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 85 fb ff ff       	call   800e9f <sys_env_set_status>
  80131a:	85 c0                	test   %eax,%eax
  80131c:	79 1c                	jns    80133a <fork+0x207>
		panic("sys_env_set_status");
  80131e:	c7 44 24 08 8d 1c 80 	movl   $0x801c8d,0x8(%esp)
  801325:	00 
  801326:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80132d:	00 
  80132e:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801335:	e8 aa 00 00 00       	call   8013e4 <_panic>
	return childEid;
}
  80133a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80133d:	83 c4 3c             	add    $0x3c,%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <sfork>:

// Challenge!
int
sfork(void)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80134b:	c7 44 24 08 a0 1c 80 	movl   $0x801ca0,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 82 1c 80 00 	movl   $0x801c82,(%esp)
  801362:	e8 7d 00 00 00       	call   8013e4 <_panic>
	...

00801368 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80136e:	c7 44 24 08 b6 1c 80 	movl   $0x801cb6,0x8(%esp)
  801375:	00 
  801376:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80137d:	00 
  80137e:	c7 04 24 cf 1c 80 00 	movl   $0x801ccf,(%esp)
  801385:	e8 5a 00 00 00       	call   8013e4 <_panic>

0080138a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801390:	c7 44 24 08 d9 1c 80 	movl   $0x801cd9,0x8(%esp)
  801397:	00 
  801398:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80139f:	00 
  8013a0:	c7 04 24 cf 1c 80 00 	movl   $0x801ccf,(%esp)
  8013a7:	e8 38 00 00 00       	call   8013e4 <_panic>

008013ac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013b7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013ba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013c0:	8b 52 50             	mov    0x50(%edx),%edx
  8013c3:	39 ca                	cmp    %ecx,%edx
  8013c5:	75 0d                	jne    8013d4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013ca:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013cf:	8b 40 40             	mov    0x40(%eax),%eax
  8013d2:	eb 0e                	jmp    8013e2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013d4:	83 c0 01             	add    $0x1,%eax
  8013d7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013dc:	75 d9                	jne    8013b7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013de:	66 b8 00 00          	mov    $0x0,%ax
}
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013ec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ef:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8013f5:	e8 2a f9 ff ff       	call   800d24 <sys_getenvid>
  8013fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801401:	8b 55 08             	mov    0x8(%ebp),%edx
  801404:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801408:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80140c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801410:	c7 04 24 f4 1c 80 00 	movl   $0x801cf4,(%esp)
  801417:	e8 cf ee ff ff       	call   8002eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80141c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801420:	8b 45 10             	mov    0x10(%ebp),%eax
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 5f ee ff ff       	call   80028a <vcprintf>
	cprintf("\n");
  80142b:	c7 04 24 f2 17 80 00 	movl   $0x8017f2,(%esp)
  801432:	e8 b4 ee ff ff       	call   8002eb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801437:	cc                   	int3   
  801438:	eb fd                	jmp    801437 <_panic+0x53>
	...

0080143c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801442:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801449:	75 44                	jne    80148f <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80144b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801450:	8b 40 48             	mov    0x48(%eax),%eax
  801453:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80145a:	00 
  80145b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801462:	ee 
  801463:	89 04 24             	mov    %eax,(%esp)
  801466:	e8 19 f9 ff ff       	call   800d84 <sys_page_alloc>
		if( r < 0)
  80146b:	85 c0                	test   %eax,%eax
  80146d:	79 20                	jns    80148f <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80146f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801473:	c7 44 24 08 18 1d 80 	movl   $0x801d18,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 74 1d 80 00 	movl   $0x801d74,(%esp)
  80148a:	e8 55 ff ff ff       	call   8013e4 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	a3 10 20 80 00       	mov    %eax,0x802010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801497:	e8 88 f8 ff ff       	call   800d24 <sys_getenvid>
  80149c:	c7 44 24 04 d4 14 80 	movl   $0x8014d4,0x4(%esp)
  8014a3:	00 
  8014a4:	89 04 24             	mov    %eax,(%esp)
  8014a7:	e8 51 fa ff ff       	call   800efd <sys_env_set_pgfault_upcall>
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	79 20                	jns    8014d0 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8014b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b4:	c7 44 24 08 48 1d 80 	movl   $0x801d48,0x8(%esp)
  8014bb:	00 
  8014bc:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8014c3:	00 
  8014c4:	c7 04 24 74 1d 80 00 	movl   $0x801d74,(%esp)
  8014cb:	e8 14 ff ff ff       	call   8013e4 <_panic>


}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    
	...

008014d4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014d4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014d5:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8014da:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014dc:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8014df:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8014e3:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8014e7:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8014eb:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8014ee:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8014f1:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8014f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8014f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8014fc:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  801500:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801504:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801508:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  80150c:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  801510:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  801511:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801512:	c3                   	ret    
	...

00801520 <__udivdi3>:
  801520:	83 ec 1c             	sub    $0x1c,%esp
  801523:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801527:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80152b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80152f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801533:	89 74 24 10          	mov    %esi,0x10(%esp)
  801537:	8b 74 24 24          	mov    0x24(%esp),%esi
  80153b:	85 ff                	test   %edi,%edi
  80153d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801541:	89 44 24 08          	mov    %eax,0x8(%esp)
  801545:	89 cd                	mov    %ecx,%ebp
  801547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154b:	75 33                	jne    801580 <__udivdi3+0x60>
  80154d:	39 f1                	cmp    %esi,%ecx
  80154f:	77 57                	ja     8015a8 <__udivdi3+0x88>
  801551:	85 c9                	test   %ecx,%ecx
  801553:	75 0b                	jne    801560 <__udivdi3+0x40>
  801555:	b8 01 00 00 00       	mov    $0x1,%eax
  80155a:	31 d2                	xor    %edx,%edx
  80155c:	f7 f1                	div    %ecx
  80155e:	89 c1                	mov    %eax,%ecx
  801560:	89 f0                	mov    %esi,%eax
  801562:	31 d2                	xor    %edx,%edx
  801564:	f7 f1                	div    %ecx
  801566:	89 c6                	mov    %eax,%esi
  801568:	8b 44 24 04          	mov    0x4(%esp),%eax
  80156c:	f7 f1                	div    %ecx
  80156e:	89 f2                	mov    %esi,%edx
  801570:	8b 74 24 10          	mov    0x10(%esp),%esi
  801574:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801578:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80157c:	83 c4 1c             	add    $0x1c,%esp
  80157f:	c3                   	ret    
  801580:	31 d2                	xor    %edx,%edx
  801582:	31 c0                	xor    %eax,%eax
  801584:	39 f7                	cmp    %esi,%edi
  801586:	77 e8                	ja     801570 <__udivdi3+0x50>
  801588:	0f bd cf             	bsr    %edi,%ecx
  80158b:	83 f1 1f             	xor    $0x1f,%ecx
  80158e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801592:	75 2c                	jne    8015c0 <__udivdi3+0xa0>
  801594:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801598:	76 04                	jbe    80159e <__udivdi3+0x7e>
  80159a:	39 f7                	cmp    %esi,%edi
  80159c:	73 d2                	jae    801570 <__udivdi3+0x50>
  80159e:	31 d2                	xor    %edx,%edx
  8015a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a5:	eb c9                	jmp    801570 <__udivdi3+0x50>
  8015a7:	90                   	nop
  8015a8:	89 f2                	mov    %esi,%edx
  8015aa:	f7 f1                	div    %ecx
  8015ac:	31 d2                	xor    %edx,%edx
  8015ae:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015ba:	83 c4 1c             	add    $0x1c,%esp
  8015bd:	c3                   	ret    
  8015be:	66 90                	xchg   %ax,%ax
  8015c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015c5:	b8 20 00 00 00       	mov    $0x20,%eax
  8015ca:	89 ea                	mov    %ebp,%edx
  8015cc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015d0:	d3 e7                	shl    %cl,%edi
  8015d2:	89 c1                	mov    %eax,%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015db:	09 fa                	or     %edi,%edx
  8015dd:	89 f7                	mov    %esi,%edi
  8015df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015e9:	d3 e5                	shl    %cl,%ebp
  8015eb:	89 c1                	mov    %eax,%ecx
  8015ed:	d3 ef                	shr    %cl,%edi
  8015ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015f4:	d3 e2                	shl    %cl,%edx
  8015f6:	89 c1                	mov    %eax,%ecx
  8015f8:	d3 ee                	shr    %cl,%esi
  8015fa:	09 d6                	or     %edx,%esi
  8015fc:	89 fa                	mov    %edi,%edx
  8015fe:	89 f0                	mov    %esi,%eax
  801600:	f7 74 24 0c          	divl   0xc(%esp)
  801604:	89 d7                	mov    %edx,%edi
  801606:	89 c6                	mov    %eax,%esi
  801608:	f7 e5                	mul    %ebp
  80160a:	39 d7                	cmp    %edx,%edi
  80160c:	72 22                	jb     801630 <__udivdi3+0x110>
  80160e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801612:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801617:	d3 e5                	shl    %cl,%ebp
  801619:	39 c5                	cmp    %eax,%ebp
  80161b:	73 04                	jae    801621 <__udivdi3+0x101>
  80161d:	39 d7                	cmp    %edx,%edi
  80161f:	74 0f                	je     801630 <__udivdi3+0x110>
  801621:	89 f0                	mov    %esi,%eax
  801623:	31 d2                	xor    %edx,%edx
  801625:	e9 46 ff ff ff       	jmp    801570 <__udivdi3+0x50>
  80162a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801630:	8d 46 ff             	lea    -0x1(%esi),%eax
  801633:	31 d2                	xor    %edx,%edx
  801635:	8b 74 24 10          	mov    0x10(%esp),%esi
  801639:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80163d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801641:	83 c4 1c             	add    $0x1c,%esp
  801644:	c3                   	ret    
	...

00801650 <__umoddi3>:
  801650:	83 ec 1c             	sub    $0x1c,%esp
  801653:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801657:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80165b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80165f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801663:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801667:	8b 74 24 24          	mov    0x24(%esp),%esi
  80166b:	85 ed                	test   %ebp,%ebp
  80166d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801671:	89 44 24 08          	mov    %eax,0x8(%esp)
  801675:	89 cf                	mov    %ecx,%edi
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	89 f2                	mov    %esi,%edx
  80167c:	75 1a                	jne    801698 <__umoddi3+0x48>
  80167e:	39 f1                	cmp    %esi,%ecx
  801680:	76 4e                	jbe    8016d0 <__umoddi3+0x80>
  801682:	f7 f1                	div    %ecx
  801684:	89 d0                	mov    %edx,%eax
  801686:	31 d2                	xor    %edx,%edx
  801688:	8b 74 24 10          	mov    0x10(%esp),%esi
  80168c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801690:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801694:	83 c4 1c             	add    $0x1c,%esp
  801697:	c3                   	ret    
  801698:	39 f5                	cmp    %esi,%ebp
  80169a:	77 54                	ja     8016f0 <__umoddi3+0xa0>
  80169c:	0f bd c5             	bsr    %ebp,%eax
  80169f:	83 f0 1f             	xor    $0x1f,%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	75 60                	jne    801708 <__umoddi3+0xb8>
  8016a8:	3b 0c 24             	cmp    (%esp),%ecx
  8016ab:	0f 87 07 01 00 00    	ja     8017b8 <__umoddi3+0x168>
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	8b 34 24             	mov    (%esp),%esi
  8016b6:	29 ce                	sub    %ecx,%esi
  8016b8:	19 ea                	sbb    %ebp,%edx
  8016ba:	89 34 24             	mov    %esi,(%esp)
  8016bd:	8b 04 24             	mov    (%esp),%eax
  8016c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016cc:	83 c4 1c             	add    $0x1c,%esp
  8016cf:	c3                   	ret    
  8016d0:	85 c9                	test   %ecx,%ecx
  8016d2:	75 0b                	jne    8016df <__umoddi3+0x8f>
  8016d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d9:	31 d2                	xor    %edx,%edx
  8016db:	f7 f1                	div    %ecx
  8016dd:	89 c1                	mov    %eax,%ecx
  8016df:	89 f0                	mov    %esi,%eax
  8016e1:	31 d2                	xor    %edx,%edx
  8016e3:	f7 f1                	div    %ecx
  8016e5:	8b 04 24             	mov    (%esp),%eax
  8016e8:	f7 f1                	div    %ecx
  8016ea:	eb 98                	jmp    801684 <__umoddi3+0x34>
  8016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	89 f2                	mov    %esi,%edx
  8016f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016fe:	83 c4 1c             	add    $0x1c,%esp
  801701:	c3                   	ret    
  801702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801708:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80170d:	89 e8                	mov    %ebp,%eax
  80170f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801714:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801718:	89 fa                	mov    %edi,%edx
  80171a:	d3 e0                	shl    %cl,%eax
  80171c:	89 e9                	mov    %ebp,%ecx
  80171e:	d3 ea                	shr    %cl,%edx
  801720:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801725:	09 c2                	or     %eax,%edx
  801727:	8b 44 24 08          	mov    0x8(%esp),%eax
  80172b:	89 14 24             	mov    %edx,(%esp)
  80172e:	89 f2                	mov    %esi,%edx
  801730:	d3 e7                	shl    %cl,%edi
  801732:	89 e9                	mov    %ebp,%ecx
  801734:	d3 ea                	shr    %cl,%edx
  801736:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80173b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80173f:	d3 e6                	shl    %cl,%esi
  801741:	89 e9                	mov    %ebp,%ecx
  801743:	d3 e8                	shr    %cl,%eax
  801745:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80174a:	09 f0                	or     %esi,%eax
  80174c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801750:	f7 34 24             	divl   (%esp)
  801753:	d3 e6                	shl    %cl,%esi
  801755:	89 74 24 08          	mov    %esi,0x8(%esp)
  801759:	89 d6                	mov    %edx,%esi
  80175b:	f7 e7                	mul    %edi
  80175d:	39 d6                	cmp    %edx,%esi
  80175f:	89 c1                	mov    %eax,%ecx
  801761:	89 d7                	mov    %edx,%edi
  801763:	72 3f                	jb     8017a4 <__umoddi3+0x154>
  801765:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801769:	72 35                	jb     8017a0 <__umoddi3+0x150>
  80176b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80176f:	29 c8                	sub    %ecx,%eax
  801771:	19 fe                	sbb    %edi,%esi
  801773:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801778:	89 f2                	mov    %esi,%edx
  80177a:	d3 e8                	shr    %cl,%eax
  80177c:	89 e9                	mov    %ebp,%ecx
  80177e:	d3 e2                	shl    %cl,%edx
  801780:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801785:	09 d0                	or     %edx,%eax
  801787:	89 f2                	mov    %esi,%edx
  801789:	d3 ea                	shr    %cl,%edx
  80178b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80178f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801793:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801797:	83 c4 1c             	add    $0x1c,%esp
  80179a:	c3                   	ret    
  80179b:	90                   	nop
  80179c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a0:	39 d6                	cmp    %edx,%esi
  8017a2:	75 c7                	jne    80176b <__umoddi3+0x11b>
  8017a4:	89 d7                	mov    %edx,%edi
  8017a6:	89 c1                	mov    %eax,%ecx
  8017a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8017ac:	1b 3c 24             	sbb    (%esp),%edi
  8017af:	eb ba                	jmp    80176b <__umoddi3+0x11b>
  8017b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017b8:	39 f5                	cmp    %esi,%ebp
  8017ba:	0f 82 f1 fe ff ff    	jb     8016b1 <__umoddi3+0x61>
  8017c0:	e9 f8 fe ff ff       	jmp    8016bd <__umoddi3+0x6d>
