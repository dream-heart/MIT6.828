
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
  80002c:	e8 cb 01 00 00       	call   8001fc <libmain>
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
  80003a:	e8 29 11 00 00       	call   801168 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 c9 00 00 00    	jne    800113 <umain+0xdf>
		// Child
		cprintf("child\n");
  80004a:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800051:	e8 ad 02 00 00       	call   800303 <cprintf>
		ipc_recv(&who, (void*)TEMP_ADDR_CHILD, 0);
  800056:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80005d:	00 
  80005e:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800065:	00 
  800066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800069:	89 04 24             	mov    %eax,(%esp)
  80006c:	e8 2f 13 00 00       	call   8013a0 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800071:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800078:	00 
  800079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80007c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800080:	c7 04 24 27 19 80 00 	movl   $0x801927,(%esp)
  800087:	e8 77 02 00 00       	call   800303 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80008c:	a1 04 20 80 00       	mov    0x802004,%eax
  800091:	89 04 24             	mov    %eax,(%esp)
  800094:	e8 37 08 00 00       	call   8008d0 <strlen>
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a6:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000ad:	e8 2b 09 00 00       	call   8009dd <strncmp>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	75 0c                	jne    8000c2 <umain+0x8e>
			cprintf("child received correct message\n");
  8000b6:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  8000bd:	e8 41 02 00 00       	call   800303 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000c2:	a1 00 20 80 00       	mov    0x802000,%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 01 08 00 00       	call   8008d0 <strlen>
  8000cf:	83 c0 01             	add    $0x1,%eax
  8000d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000d6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000e6:	e8 3c 0a 00 00       	call   800b27 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000eb:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800102:	00 
  800103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 30 13 00 00       	call   80143e <ipc_send>
		return;
  80010e:	e9 e4 00 00 00       	jmp    8001f7 <umain+0x1c3>
	}

	// Parent

	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800113:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800118:	8b 40 48             	mov    0x48(%eax),%eax
  80011b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80012a:	00 
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 61 0c 00 00       	call   800d94 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800133:	a1 04 20 80 00       	mov    0x802004,%eax
  800138:	89 04 24             	mov    %eax,(%esp)
  80013b:	e8 90 07 00 00       	call   8008d0 <strlen>
  800140:	83 c0 01             	add    $0x1,%eax
  800143:	89 44 24 08          	mov    %eax,0x8(%esp)
  800147:	a1 04 20 80 00       	mov    0x802004,%eax
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800157:	e8 cb 09 00 00       	call   800b27 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80015c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800163:	00 
  800164:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80016b:	00 
  80016c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800173:	00 
  800174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 bf 12 00 00       	call   80143e <ipc_send>
	cprintf("parent\n");
  80017f:	c7 04 24 3b 19 80 00 	movl   $0x80193b,(%esp)
  800186:	e8 78 01 00 00       	call   800303 <cprintf>
	ipc_recv(&who, TEMP_ADDR, 0);
  80018b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800192:	00 
  800193:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80019a:	00 
  80019b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80019e:	89 04 24             	mov    %eax,(%esp)
  8001a1:	e8 fa 11 00 00       	call   8013a0 <ipc_recv>

	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8001a6:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001ad:	00 
  8001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	c7 04 24 27 19 80 00 	movl   $0x801927,(%esp)
  8001bc:	e8 42 01 00 00       	call   800303 <cprintf>

	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001c1:	a1 00 20 80 00       	mov    0x802000,%eax
  8001c6:	89 04 24             	mov    %eax,(%esp)
  8001c9:	e8 02 07 00 00       	call   8008d0 <strlen>
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	a1 00 20 80 00       	mov    0x802000,%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001e2:	e8 f6 07 00 00       	call   8009dd <strncmp>
  8001e7:	85 c0                	test   %eax,%eax
  8001e9:	75 0c                	jne    8001f7 <umain+0x1c3>
		cprintf("parent received correct message\n");
  8001eb:	c7 04 24 64 19 80 00 	movl   $0x801964,(%esp)
  8001f2:	e8 0c 01 00 00       	call   800303 <cprintf>
	return;
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    
  8001f9:	00 00                	add    %al,(%eax)
	...

008001fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
  800202:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800205:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800208:	8b 75 08             	mov    0x8(%ebp),%esi
  80020b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80020e:	e8 21 0b 00 00       	call   800d34 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800213:	25 ff 03 00 00       	and    $0x3ff,%eax
  800218:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80021b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800220:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800225:	85 f6                	test   %esi,%esi
  800227:	7e 07                	jle    800230 <libmain+0x34>
		binaryname = argv[0];
  800229:	8b 03                	mov    (%ebx),%eax
  80022b:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800230:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800234:	89 34 24             	mov    %esi,(%esp)
  800237:	e8 f8 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80023c:	e8 0b 00 00 00       	call   80024c <exit>
}
  800241:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800244:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800247:	89 ec                	mov    %ebp,%esp
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    
	...

0080024c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800252:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800259:	e8 79 0a 00 00       	call   800cd7 <sys_env_destroy>
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	53                   	push   %ebx
  800264:	83 ec 14             	sub    $0x14,%esp
  800267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80026a:	8b 03                	mov    (%ebx),%eax
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800273:	83 c0 01             	add    $0x1,%eax
  800276:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800278:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027d:	75 19                	jne    800298 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80027f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800286:	00 
  800287:	8d 43 08             	lea    0x8(%ebx),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	e8 e6 09 00 00       	call   800c78 <sys_cputs>
		b->idx = 0;
  800292:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800298:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b2:	00 00 00 
	b.cnt = 0;
  8002b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	c7 04 24 60 02 80 00 	movl   $0x800260,(%esp)
  8002de:	e8 8a 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 7d 09 00 00       	call   800c78 <sys_cputs>

	return b.cnt;
}
  8002fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800309:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	e8 87 ff ff ff       	call   8002a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    
  80031d:	00 00                	add    %al,(%eax)
	...

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
  800331:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80033d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800340:	85 c0                	test   %eax,%eax
  800342:	75 08                	jne    80034c <printnum+0x2c>
  800344:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800347:	39 45 10             	cmp    %eax,0x10(%ebp)
  80034a:	77 59                	ja     8003a5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800350:	83 eb 01             	sub    $0x1,%ebx
  800353:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800357:	8b 45 10             	mov    0x10(%ebp),%eax
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800362:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800366:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036d:	00 
  80036e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	e8 e0 12 00 00       	call   801660 <__udivdi3>
  800380:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800384:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038f:	89 fa                	mov    %edi,%edx
  800391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800394:	e8 87 ff ff ff       	call   800320 <printnum>
  800399:	eb 11                	jmp    8003ac <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039f:	89 34 24             	mov    %esi,(%esp)
  8003a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a5:	83 eb 01             	sub    $0x1,%ebx
  8003a8:	85 db                	test   %ebx,%ebx
  8003aa:	7f ef                	jg     80039b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003c2:	00 
  8003c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d0:	e8 bb 13 00 00       	call   801790 <__umoddi3>
  8003d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d9:	0f be 80 dc 19 80 00 	movsbl 0x8019dc(%eax),%eax
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003e6:	83 c4 3c             	add    $0x3c,%esp
  8003e9:	5b                   	pop    %ebx
  8003ea:	5e                   	pop    %esi
  8003eb:	5f                   	pop    %edi
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f1:	83 fa 01             	cmp    $0x1,%edx
  8003f4:	7e 0e                	jle    800404 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f6:	8b 10                	mov    (%eax),%edx
  8003f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003fb:	89 08                	mov    %ecx,(%eax)
  8003fd:	8b 02                	mov    (%edx),%eax
  8003ff:	8b 52 04             	mov    0x4(%edx),%edx
  800402:	eb 22                	jmp    800426 <getuint+0x38>
	else if (lflag)
  800404:	85 d2                	test   %edx,%edx
  800406:	74 10                	je     800418 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800408:	8b 10                	mov    (%eax),%edx
  80040a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040d:	89 08                	mov    %ecx,(%eax)
  80040f:	8b 02                	mov    (%edx),%eax
  800411:	ba 00 00 00 00       	mov    $0x0,%edx
  800416:	eb 0e                	jmp    800426 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800418:	8b 10                	mov    (%eax),%edx
  80041a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 02                	mov    (%edx),%eax
  800421:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800432:	8b 10                	mov    (%eax),%edx
  800434:	3b 50 04             	cmp    0x4(%eax),%edx
  800437:	73 0a                	jae    800443 <sprintputch+0x1b>
		*b->buf++ = ch;
  800439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043c:	88 0a                	mov    %cl,(%edx)
  80043e:	83 c2 01             	add    $0x1,%edx
  800441:	89 10                	mov    %edx,(%eax)
}
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80044b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800452:	8b 45 10             	mov    0x10(%ebp),%eax
  800455:	89 44 24 08          	mov    %eax,0x8(%esp)
  800459:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 02 00 00 00       	call   80046d <vprintfmt>
	va_end(ap);
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 4c             	sub    $0x4c,%esp
  800476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800479:	8b 75 10             	mov    0x10(%ebp),%esi
  80047c:	eb 12                	jmp    800490 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80047e:	85 c0                	test   %eax,%eax
  800480:	0f 84 bf 03 00 00    	je     800845 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800486:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048a:	89 04 24             	mov    %eax,(%esp)
  80048d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800490:	0f b6 06             	movzbl (%esi),%eax
  800493:	83 c6 01             	add    $0x1,%esi
  800496:	83 f8 25             	cmp    $0x25,%eax
  800499:	75 e3                	jne    80047e <vprintfmt+0x11>
  80049b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80049f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004a6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004ab:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ba:	eb 2b                	jmp    8004e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004c3:	eb 22                	jmp    8004e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004cc:	eb 19                	jmp    8004e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004d8:	eb 0d                	jmp    8004e7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	0f b6 16             	movzbl (%esi),%edx
  8004ea:	0f b6 c2             	movzbl %dl,%eax
  8004ed:	8d 7e 01             	lea    0x1(%esi),%edi
  8004f0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004f3:	83 ea 23             	sub    $0x23,%edx
  8004f6:	80 fa 55             	cmp    $0x55,%dl
  8004f9:	0f 87 28 03 00 00    	ja     800827 <vprintfmt+0x3ba>
  8004ff:	0f b6 d2             	movzbl %dl,%edx
  800502:	ff 24 95 a0 1a 80 00 	jmp    *0x801aa0(,%edx,4)
  800509:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800513:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800518:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80051b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80051f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800522:	8d 50 d0             	lea    -0x30(%eax),%edx
  800525:	83 fa 09             	cmp    $0x9,%edx
  800528:	77 2f                	ja     800559 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80052d:	eb e9                	jmp    800518 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800540:	eb 1a                	jmp    80055c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800549:	79 9c                	jns    8004e7 <vprintfmt+0x7a>
  80054b:	eb 81                	jmp    8004ce <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800550:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800557:	eb 8e                	jmp    8004e7 <vprintfmt+0x7a>
  800559:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80055c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800560:	79 85                	jns    8004e7 <vprintfmt+0x7a>
  800562:	e9 73 ff ff ff       	jmp    8004da <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056d:	e9 75 ff ff ff       	jmp    8004e7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 04 24             	mov    %eax,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80058a:	e9 01 ff ff ff       	jmp    800490 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 c2                	mov    %eax,%edx
  80059c:	c1 fa 1f             	sar    $0x1f,%edx
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 09             	cmp    $0x9,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x146>
  8005a8:	8b 14 85 00 1c 80 00 	mov    0x801c00(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 23                	jne    8005d6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 f4 19 80 	movl   $0x8019f4,0x8(%esp)
  8005be:	00 
  8005bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c6:	89 3c 24             	mov    %edi,(%esp)
  8005c9:	e8 77 fe ff ff       	call   800445 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d1:	e9 ba fe ff ff       	jmp    800490 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005da:	c7 44 24 08 fd 19 80 	movl   $0x8019fd,0x8(%esp)
  8005e1:	00 
  8005e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	e8 54 fe ff ff       	call   800445 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f4:	e9 97 fe ff ff       	jmp    800490 <vprintfmt+0x23>
  8005f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80060d:	85 f6                	test   %esi,%esi
  80060f:	ba ed 19 80 00       	mov    $0x8019ed,%edx
  800614:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800617:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061b:	0f 8e 8c 00 00 00    	jle    8006ad <vprintfmt+0x240>
  800621:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800625:	0f 84 82 00 00 00    	je     8006ad <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80062b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062f:	89 34 24             	mov    %esi,(%esp)
  800632:	e8 b1 02 00 00       	call   8008e8 <strnlen>
  800637:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063a:	29 c2                	sub    %eax,%edx
  80063c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80063f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800643:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800646:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800649:	89 de                	mov    %ebx,%esi
  80064b:	89 d3                	mov    %edx,%ebx
  80064d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	eb 0d                	jmp    80065e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	89 3c 24             	mov    %edi,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065b:	83 eb 01             	sub    $0x1,%ebx
  80065e:	85 db                	test   %ebx,%ebx
  800660:	7f ef                	jg     800651 <vprintfmt+0x1e4>
  800662:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800665:	89 f3                	mov    %esi,%ebx
  800667:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80066a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066e:	b8 00 00 00 00       	mov    $0x0,%eax
  800673:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800677:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067a:	29 c2                	sub    %eax,%edx
  80067c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80067f:	eb 2c                	jmp    8006ad <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	74 18                	je     80069f <vprintfmt+0x232>
  800687:	8d 50 e0             	lea    -0x20(%eax),%edx
  80068a:	83 fa 5e             	cmp    $0x5e,%edx
  80068d:	76 10                	jbe    80069f <vprintfmt+0x232>
					putch('?', putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80069a:	ff 55 08             	call   *0x8(%ebp)
  80069d:	eb 0a                	jmp    8006a9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80069f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006ad:	0f be 06             	movsbl (%esi),%eax
  8006b0:	83 c6 01             	add    $0x1,%esi
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	74 25                	je     8006dc <vprintfmt+0x26f>
  8006b7:	85 ff                	test   %edi,%edi
  8006b9:	78 c6                	js     800681 <vprintfmt+0x214>
  8006bb:	83 ef 01             	sub    $0x1,%edi
  8006be:	79 c1                	jns    800681 <vprintfmt+0x214>
  8006c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c3:	89 de                	mov    %ebx,%esi
  8006c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006c8:	eb 1a                	jmp    8006e4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d7:	83 eb 01             	sub    $0x1,%ebx
  8006da:	eb 08                	jmp    8006e4 <vprintfmt+0x277>
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	89 de                	mov    %ebx,%esi
  8006e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006e4:	85 db                	test   %ebx,%ebx
  8006e6:	7f e2                	jg     8006ca <vprintfmt+0x25d>
  8006e8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006eb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f0:	e9 9b fd ff ff       	jmp    800490 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f5:	83 f9 01             	cmp    $0x1,%ecx
  8006f8:	7e 10                	jle    80070a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 08             	lea    0x8(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 30                	mov    (%eax),%esi
  800705:	8b 78 04             	mov    0x4(%eax),%edi
  800708:	eb 26                	jmp    800730 <vprintfmt+0x2c3>
	else if (lflag)
  80070a:	85 c9                	test   %ecx,%ecx
  80070c:	74 12                	je     800720 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)
  800717:	8b 30                	mov    (%eax),%esi
  800719:	89 f7                	mov    %esi,%edi
  80071b:	c1 ff 1f             	sar    $0x1f,%edi
  80071e:	eb 10                	jmp    800730 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	8b 30                	mov    (%eax),%esi
  80072b:	89 f7                	mov    %esi,%edi
  80072d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800735:	85 ff                	test   %edi,%edi
  800737:	0f 89 ac 00 00 00    	jns    8007e9 <vprintfmt+0x37c>
				putch('-', putdat);
  80073d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800741:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80074b:	f7 de                	neg    %esi
  80074d:	83 d7 00             	adc    $0x0,%edi
  800750:	f7 df                	neg    %edi
			}
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
  800757:	e9 8d 00 00 00       	jmp    8007e9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 88 fc ff ff       	call   8003ee <getuint>
  800766:	89 c6                	mov    %eax,%esi
  800768:	89 d7                	mov    %edx,%edi
			base = 10;
  80076a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80076f:	eb 78                	jmp    8007e9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800771:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800775:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80077c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80077f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800783:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80078a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80078d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800791:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80079e:	e9 ed fc ff ff       	jmp    800490 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ae:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c8:	8b 30                	mov    (%eax),%esi
  8007ca:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d4:	eb 13                	jmp    8007e9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d6:	89 ca                	mov    %ecx,%edx
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007db:	e8 0e fc ff ff       	call   8003ee <getuint>
  8007e0:	89 c6                	mov    %eax,%esi
  8007e2:	89 d7                	mov    %edx,%edi
			base = 16;
  8007e4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fc:	89 34 24             	mov    %esi,(%esp)
  8007ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800803:	89 da                	mov    %ebx,%edx
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	e8 13 fb ff ff       	call   800320 <printnum>
			break;
  80080d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800810:	e9 7b fc ff ff       	jmp    800490 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800819:	89 04 24             	mov    %eax,(%esp)
  80081c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800822:	e9 69 fc ff ff       	jmp    800490 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800827:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800832:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800835:	eb 03                	jmp    80083a <vprintfmt+0x3cd>
  800837:	83 ee 01             	sub    $0x1,%esi
  80083a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80083e:	75 f7                	jne    800837 <vprintfmt+0x3ca>
  800840:	e9 4b fc ff ff       	jmp    800490 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800845:	83 c4 4c             	add    $0x4c,%esp
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5f                   	pop    %edi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	83 ec 28             	sub    $0x28,%esp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800860:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086a:	85 c0                	test   %eax,%eax
  80086c:	74 30                	je     80089e <vsnprintf+0x51>
  80086e:	85 d2                	test   %edx,%edx
  800870:	7e 2c                	jle    80089e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800879:	8b 45 10             	mov    0x10(%ebp),%eax
  80087c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	89 44 24 04          	mov    %eax,0x4(%esp)
  800887:	c7 04 24 28 04 80 00 	movl   $0x800428,(%esp)
  80088e:	e8 da fb ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800893:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800896:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	eb 05                	jmp    8008a3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	e8 82 ff ff ff       	call   80084d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    
  8008cd:	00 00                	add    %al,(%eax)
	...

008008d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008db:	eb 03                	jmp    8008e0 <strlen+0x10>
		n++;
  8008dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e4:	75 f7                	jne    8008dd <strlen+0xd>
		n++;
	return n;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 03                	jmp    8008fb <strnlen+0x13>
		n++;
  8008f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	74 06                	je     800905 <strnlen+0x1d>
  8008ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800903:	75 f3                	jne    8008f8 <strnlen+0x10>
		n++;
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800911:	ba 00 00 00 00       	mov    $0x0,%edx
  800916:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80091a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80091d:	83 c2 01             	add    $0x1,%edx
  800920:	84 c9                	test   %cl,%cl
  800922:	75 f2                	jne    800916 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800924:	5b                   	pop    %ebx
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 97 ff ff ff       	call   8008d0 <strlen>
	strcpy(dst + len, src);
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800940:	01 d8                	add    %ebx,%eax
  800942:	89 04 24             	mov    %eax,(%esp)
  800945:	e8 bd ff ff ff       	call   800907 <strcpy>
	return dst;
}
  80094a:	89 d8                	mov    %ebx,%eax
  80094c:	83 c4 08             	add    $0x8,%esp
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800960:	b9 00 00 00 00       	mov    $0x0,%ecx
  800965:	eb 0f                	jmp    800976 <strncpy+0x24>
		*dst++ = *src;
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096d:	80 3a 01             	cmpb   $0x1,(%edx)
  800970:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	83 c1 01             	add    $0x1,%ecx
  800976:	39 f1                	cmp    %esi,%ecx
  800978:	75 ed                	jne    800967 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 75 08             	mov    0x8(%ebp),%esi
  800986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800989:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098c:	89 f0                	mov    %esi,%eax
  80098e:	85 d2                	test   %edx,%edx
  800990:	75 0a                	jne    80099c <strlcpy+0x1e>
  800992:	eb 1d                	jmp    8009b1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800994:	88 18                	mov    %bl,(%eax)
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80099c:	83 ea 01             	sub    $0x1,%edx
  80099f:	74 0b                	je     8009ac <strlcpy+0x2e>
  8009a1:	0f b6 19             	movzbl (%ecx),%ebx
  8009a4:	84 db                	test   %bl,%bl
  8009a6:	75 ec                	jne    800994 <strlcpy+0x16>
  8009a8:	89 c2                	mov    %eax,%edx
  8009aa:	eb 02                	jmp    8009ae <strlcpy+0x30>
  8009ac:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009ae:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009b1:	29 f0                	sub    %esi,%eax
}
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c0:	eb 06                	jmp    8009c8 <strcmp+0x11>
		p++, q++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
  8009c5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	84 c0                	test   %al,%al
  8009cd:	74 04                	je     8009d3 <strcmp+0x1c>
  8009cf:	3a 02                	cmp    (%edx),%al
  8009d1:	74 ef                	je     8009c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 c0             	movzbl %al,%eax
  8009d6:	0f b6 12             	movzbl (%edx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009ea:	eb 09                	jmp    8009f5 <strncmp+0x18>
		n--, p++, q++;
  8009ec:	83 ea 01             	sub    $0x1,%edx
  8009ef:	83 c0 01             	add    $0x1,%eax
  8009f2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	74 15                	je     800a0e <strncmp+0x31>
  8009f9:	0f b6 18             	movzbl (%eax),%ebx
  8009fc:	84 db                	test   %bl,%bl
  8009fe:	74 04                	je     800a04 <strncmp+0x27>
  800a00:	3a 19                	cmp    (%ecx),%bl
  800a02:	74 e8                	je     8009ec <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	0f b6 00             	movzbl (%eax),%eax
  800a07:	0f b6 11             	movzbl (%ecx),%edx
  800a0a:	29 d0                	sub    %edx,%eax
  800a0c:	eb 05                	jmp    800a13 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a13:	5b                   	pop    %ebx
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a20:	eb 07                	jmp    800a29 <strchr+0x13>
		if (*s == c)
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	74 0f                	je     800a35 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	0f b6 10             	movzbl (%eax),%edx
  800a2c:	84 d2                	test   %dl,%dl
  800a2e:	75 f2                	jne    800a22 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a41:	eb 07                	jmp    800a4a <strfind+0x13>
		if (*s == c)
  800a43:	38 ca                	cmp    %cl,%dl
  800a45:	74 0a                	je     800a51 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	84 d2                	test   %dl,%dl
  800a4f:	75 f2                	jne    800a43 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 0c             	sub    $0xc,%esp
  800a59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a62:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6b:	85 c9                	test   %ecx,%ecx
  800a6d:	74 30                	je     800a9f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a75:	75 25                	jne    800a9c <memset+0x49>
  800a77:	f6 c1 03             	test   $0x3,%cl
  800a7a:	75 20                	jne    800a9c <memset+0x49>
		c &= 0xFF;
  800a7c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	c1 e3 08             	shl    $0x8,%ebx
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	c1 e6 18             	shl    $0x18,%esi
  800a89:	89 d0                	mov    %edx,%eax
  800a8b:	c1 e0 10             	shl    $0x10,%eax
  800a8e:	09 f0                	or     %esi,%eax
  800a90:	09 d0                	or     %edx,%eax
  800a92:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a94:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a97:	fc                   	cld    
  800a98:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9a:	eb 03                	jmp    800a9f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9c:	fc                   	cld    
  800a9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9f:	89 f8                	mov    %edi,%eax
  800aa1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800aa4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aaa:	89 ec                	mov    %ebp,%esp
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ab7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac3:	39 c6                	cmp    %eax,%esi
  800ac5:	73 36                	jae    800afd <memmove+0x4f>
  800ac7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	73 2f                	jae    800afd <memmove+0x4f>
		s += n;
		d += n;
  800ace:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	f6 c2 03             	test   $0x3,%dl
  800ad4:	75 1b                	jne    800af1 <memmove+0x43>
  800ad6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adc:	75 13                	jne    800af1 <memmove+0x43>
  800ade:	f6 c1 03             	test   $0x3,%cl
  800ae1:	75 0e                	jne    800af1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae3:	83 ef 04             	sub    $0x4,%edi
  800ae6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aec:	fd                   	std    
  800aed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aef:	eb 09                	jmp    800afa <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af1:	83 ef 01             	sub    $0x1,%edi
  800af4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af7:	fd                   	std    
  800af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afa:	fc                   	cld    
  800afb:	eb 20                	jmp    800b1d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b03:	75 13                	jne    800b18 <memmove+0x6a>
  800b05:	a8 03                	test   $0x3,%al
  800b07:	75 0f                	jne    800b18 <memmove+0x6a>
  800b09:	f6 c1 03             	test   $0x3,%cl
  800b0c:	75 0a                	jne    800b18 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b0e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b11:	89 c7                	mov    %eax,%edi
  800b13:	fc                   	cld    
  800b14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b16:	eb 05                	jmp    800b1d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	fc                   	cld    
  800b1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b23:	89 ec                	mov    %ebp,%esp
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	89 04 24             	mov    %eax,(%esp)
  800b41:	e8 68 ff ff ff       	call   800aae <memmove>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	eb 1a                	jmp    800b78 <memcmp+0x30>
		if (*s1 != *s2)
  800b5e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b62:	83 c2 01             	add    $0x1,%edx
  800b65:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800b6a:	38 c8                	cmp    %cl,%al
  800b6c:	74 0a                	je     800b78 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800b6e:	0f b6 c0             	movzbl %al,%eax
  800b71:	0f b6 c9             	movzbl %cl,%ecx
  800b74:	29 c8                	sub    %ecx,%eax
  800b76:	eb 09                	jmp    800b81 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b78:	39 da                	cmp    %ebx,%edx
  800b7a:	75 e2                	jne    800b5e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
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
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800bb4:	0f b6 02             	movzbl (%edx),%eax
  800bb7:	3c 20                	cmp    $0x20,%al
  800bb9:	74 f6                	je     800bb1 <strtol+0xe>
  800bbb:	3c 09                	cmp    $0x9,%al
  800bbd:	74 f2                	je     800bb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bbf:	3c 2b                	cmp    $0x2b,%al
  800bc1:	75 0a                	jne    800bcd <strtol+0x2a>
		s++;
  800bc3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcb:	eb 10                	jmp    800bdd <strtol+0x3a>
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd2:	3c 2d                	cmp    $0x2d,%al
  800bd4:	75 07                	jne    800bdd <strtol+0x3a>
		s++, neg = 1;
  800bd6:	8d 52 01             	lea    0x1(%edx),%edx
  800bd9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdd:	85 db                	test   %ebx,%ebx
  800bdf:	0f 94 c0             	sete   %al
  800be2:	74 05                	je     800be9 <strtol+0x46>
  800be4:	83 fb 10             	cmp    $0x10,%ebx
  800be7:	75 15                	jne    800bfe <strtol+0x5b>
  800be9:	80 3a 30             	cmpb   $0x30,(%edx)
  800bec:	75 10                	jne    800bfe <strtol+0x5b>
  800bee:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf2:	75 0a                	jne    800bfe <strtol+0x5b>
		s += 2, base = 16;
  800bf4:	83 c2 02             	add    $0x2,%edx
  800bf7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfc:	eb 13                	jmp    800c11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bfe:	84 c0                	test   %al,%al
  800c00:	74 0f                	je     800c11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c07:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0a:	75 05                	jne    800c11 <strtol+0x6e>
		s++, base = 8;
  800c0c:	83 c2 01             	add    $0x1,%edx
  800c0f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
  800c16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c18:	0f b6 0a             	movzbl (%edx),%ecx
  800c1b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c1e:	80 fb 09             	cmp    $0x9,%bl
  800c21:	77 08                	ja     800c2b <strtol+0x88>
			dig = *s - '0';
  800c23:	0f be c9             	movsbl %cl,%ecx
  800c26:	83 e9 30             	sub    $0x30,%ecx
  800c29:	eb 1e                	jmp    800c49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c2b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 08                	ja     800c3b <strtol+0x98>
			dig = *s - 'a' + 10;
  800c33:	0f be c9             	movsbl %cl,%ecx
  800c36:	83 e9 57             	sub    $0x57,%ecx
  800c39:	eb 0e                	jmp    800c49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c3b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c3e:	80 fb 19             	cmp    $0x19,%bl
  800c41:	77 14                	ja     800c57 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800c43:	0f be c9             	movsbl %cl,%ecx
  800c46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c49:	39 f1                	cmp    %esi,%ecx
  800c4b:	7d 0e                	jge    800c5b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800c4d:	83 c2 01             	add    $0x1,%edx
  800c50:	0f af c6             	imul   %esi,%eax
  800c53:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c55:	eb c1                	jmp    800c18 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c57:	89 c1                	mov    %eax,%ecx
  800c59:	eb 02                	jmp    800c5d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c5b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c61:	74 05                	je     800c68 <strtol+0xc5>
		*endptr = (char *) s;
  800c63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c66:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c68:	89 ca                	mov    %ecx,%edx
  800c6a:	f7 da                	neg    %edx
  800c6c:	85 ff                	test   %edi,%edi
  800c6e:	0f 45 c2             	cmovne %edx,%eax
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
	...

00800c78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c81:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c84:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	89 c3                	mov    %eax,%ebx
  800c94:	89 c7                	mov    %eax,%edi
  800c96:	89 c6                	mov    %eax,%esi
  800c98:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca3:	89 ec                	mov    %ebp,%esp
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc0:	89 d1                	mov    %edx,%ecx
  800cc2:	89 d3                	mov    %edx,%ebx
  800cc4:	89 d7                	mov    %edx,%edi
  800cc6:	89 d6                	mov    %edx,%esi
  800cc8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ccd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd3:	89 ec                	mov    %ebp,%esp
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 38             	sub    $0x38,%esp
  800cdd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ceb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 cb                	mov    %ecx,%ebx
  800cf5:	89 cf                	mov    %ecx,%edi
  800cf7:	89 ce                	mov    %ecx,%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 28                	jle    800d27 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800d12:	00 
  800d13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1a:	00 
  800d1b:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800d22:	e8 01 08 00 00       	call   801528 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d30:	89 ec                	mov    %ebp,%esp
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	ba 00 00 00 00       	mov    $0x0,%edx
  800d48:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4d:	89 d1                	mov    %edx,%ecx
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	89 d7                	mov    %edx,%edi
  800d53:	89 d6                	mov    %edx,%esi
  800d55:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d60:	89 ec                	mov    %ebp,%esp
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_yield>:

void
sys_yield(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d70:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	ba 00 00 00 00       	mov    $0x0,%edx
  800d78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7d:	89 d1                	mov    %edx,%ecx
  800d7f:	89 d3                	mov    %edx,%ebx
  800d81:	89 d7                	mov    %edx,%edi
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d90:	89 ec                	mov    %ebp,%esp
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 38             	sub    $0x38,%esp
  800d9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	be 00 00 00 00       	mov    $0x0,%esi
  800da8:	b8 04 00 00 00       	mov    $0x4,%eax
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 f7                	mov    %esi,%edi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 28                	jle    800de6 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dc9:	00 
  800dca:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd9:	00 
  800dda:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800de1:	e8 42 07 00 00       	call   801528 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800def:	89 ec                	mov    %ebp,%esp
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	83 ec 38             	sub    $0x38,%esp
  800df9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b8 05 00 00 00       	mov    $0x5,%eax
  800e07:	8b 75 18             	mov    0x18(%ebp),%esi
  800e0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	7e 28                	jle    800e44 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e27:	00 
  800e28:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800e2f:	00 
  800e30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e37:	00 
  800e38:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800e3f:	e8 e4 06 00 00       	call   801528 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4d:	89 ec                	mov    %ebp,%esp
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 38             	sub    $0x38,%esp
  800e57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e65:	b8 06 00 00 00       	mov    $0x6,%eax
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	89 df                	mov    %ebx,%edi
  800e72:	89 de                	mov    %ebx,%esi
  800e74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	7e 28                	jle    800ea2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e85:	00 
  800e86:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800e8d:	00 
  800e8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e95:	00 
  800e96:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800e9d:	e8 86 06 00 00       	call   801528 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ea2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eab:	89 ec                	mov    %ebp,%esp
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 38             	sub    $0x38,%esp
  800eb5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 df                	mov    %ebx,%edi
  800ed0:	89 de                	mov    %ebx,%esi
  800ed2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 28                	jle    800f00 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edc:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800eeb:	00 
  800eec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef3:	00 
  800ef4:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800efb:	e8 28 06 00 00       	call   801528 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f00:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f03:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f06:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f09:	89 ec                	mov    %ebp,%esp
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 38             	sub    $0x38,%esp
  800f13:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f16:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f19:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f21:	b8 09 00 00 00       	mov    $0x9,%eax
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	89 df                	mov    %ebx,%edi
  800f2e:	89 de                	mov    %ebx,%esi
  800f30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f32:	85 c0                	test   %eax,%eax
  800f34:	7e 28                	jle    800f5e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800f59:	e8 ca 05 00 00       	call   801528 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f67:	89 ec                	mov    %ebp,%esp
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	be 00 00 00 00       	mov    $0x0,%esi
  800f7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9b:	89 ec                	mov    %ebp,%esp
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 38             	sub    $0x38,%esp
  800fa5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 cb                	mov    %ecx,%ebx
  800fbd:	89 cf                	mov    %ecx,%edi
  800fbf:	89 ce                	mov    %ecx,%esi
  800fc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 28 1c 80 	movl   $0x801c28,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 45 1c 80 00 	movl   $0x801c45,(%esp)
  800fea:	e8 39 05 00 00       	call   801528 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff8:	89 ec                	mov    %ebp,%esp
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	83 ec 20             	sub    $0x20,%esp
  801004:	8b 5d 08             	mov    0x8(%ebp),%ebx


	void *addr = (void *) utf->utf_fault_va;
  801007:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  801009:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80100d:	75 3f                	jne    80104e <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80100f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801013:	c7 04 24 53 1c 80 00 	movl   $0x801c53,(%esp)
  80101a:	e8 e4 f2 ff ff       	call   800303 <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80101f:	8b 43 28             	mov    0x28(%ebx),%eax
  801022:	89 44 24 04          	mov    %eax,0x4(%esp)
  801026:	c7 04 24 63 1c 80 00 	movl   $0x801c63,(%esp)
  80102d:	e8 d1 f2 ff ff       	call   800303 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801032:	c7 44 24 08 a8 1c 80 	movl   $0x801ca8,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801049:	e8 da 04 00 00       	call   801528 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80104e:	89 f0                	mov    %esi,%eax
  801050:	c1 e8 0c             	shr    $0xc,%eax
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  80105a:	f6 c4 08             	test   $0x8,%ah
  80105d:	75 1c                	jne    80107b <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80105f:	c7 44 24 08 d0 1c 80 	movl   $0x801cd0,0x8(%esp)
  801066:	00 
  801067:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80106e:	00 
  80106f:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801076:	e8 ad 04 00 00       	call   801528 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80107b:	e8 b4 fc ff ff       	call   800d34 <sys_getenvid>
  801080:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801087:	00 
  801088:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80108f:	00 
  801090:	89 04 24             	mov    %eax,(%esp)
  801093:	e8 fc fc ff ff       	call   800d94 <sys_page_alloc>
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 1c                	jns    8010b8 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  80109c:	c7 44 24 08 f0 1c 80 	movl   $0x801cf0,0x8(%esp)
  8010a3:	00 
  8010a4:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8010ab:	00 
  8010ac:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  8010b3:	e8 70 04 00 00       	call   801528 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8010b8:	89 f3                	mov    %esi,%ebx
  8010ba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8010c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010c7:	00 
  8010c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010cc:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010d3:	e8 4f fa ff ff       	call   800b27 <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8010d8:	e8 57 fc ff ff       	call   800d34 <sys_getenvid>
  8010dd:	89 c6                	mov    %eax,%esi
  8010df:	e8 50 fc ff ff       	call   800d34 <sys_getenvid>
  8010e4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010eb:	00 
  8010ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010f0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010f4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fb:	00 
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 ef fc ff ff       	call   800df3 <sys_page_map>
  801104:	85 c0                	test   %eax,%eax
  801106:	79 20                	jns    801128 <pgfault+0x12c>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801108:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110c:	c7 44 24 08 18 1d 80 	movl   $0x801d18,0x8(%esp)
  801113:	00 
  801114:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801123:	e8 00 04 00 00       	call   801528 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801128:	e8 07 fc ff ff       	call   800d34 <sys_getenvid>
  80112d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801134:	00 
  801135:	89 04 24             	mov    %eax,(%esp)
  801138:	e8 14 fd ff ff       	call   800e51 <sys_page_unmap>
  80113d:	85 c0                	test   %eax,%eax
  80113f:	79 20                	jns    801161 <pgfault+0x165>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  801141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801145:	c7 44 24 08 48 1d 80 	movl   $0x801d48,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  80115c:	e8 c7 03 00 00       	call   801528 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  801171:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  801178:	e8 03 04 00 00       	call   801580 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80117d:	ba 07 00 00 00       	mov    $0x7,%edx
  801182:	89 d0                	mov    %edx,%eax
  801184:	cd 30                	int    $0x30
  801186:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801189:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 20                	jns    8011b0 <fork+0x48>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801190:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801194:	c7 44 24 08 7c 1d 80 	movl   $0x801d7c,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  8011ab:	e8 78 03 00 00       	call   801528 <_panic>
	if(childEid == 0){
  8011b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011b4:	75 1c                	jne    8011d2 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011b6:	e8 79 fb ff ff       	call   800d34 <sys_getenvid>
  8011bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c8:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return childEid;
  8011cd:	e9 9d 01 00 00       	jmp    80136f <fork+0x207>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  8011d2:	c7 44 24 04 18 16 80 	movl   $0x801618,0x4(%esp)
  8011d9:	00 
  8011da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011dd:	89 04 24             	mov    %eax,(%esp)
  8011e0:	e8 28 fd ff ff       	call   800f0d <sys_env_set_pgfault_upcall>
  8011e5:	89 c6                	mov    %eax,%esi
	if(r < 0)
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 20                	jns    80120b <fork+0xa3>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  8011eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ef:	c7 44 24 08 b0 1d 80 	movl   $0x801db0,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801206:	e8 1d 03 00 00       	call   801528 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  80120b:	bb 00 10 00 00       	mov    $0x1000,%ebx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801210:	ba 00 00 00 00       	mov    $0x0,%edx
  801215:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121a:	eb 04                	jmp    801220 <fork+0xb8>
  80121c:	89 da                	mov    %ebx,%edx
  80121e:	89 c3                	mov    %eax,%ebx
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801220:	89 d0                	mov    %edx,%eax
  801222:	c1 e8 16             	shr    $0x16,%eax
  801225:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122c:	a8 01                	test   $0x1,%al
  80122e:	0f 84 f5 00 00 00    	je     801329 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  80123e:	a8 04                	test   $0x4,%al
  801240:	0f 84 e3 00 00 00    	je     801329 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801246:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80124d:	a8 01                	test   $0x1,%al
  80124f:	0f 84 d4 00 00 00    	je     801329 <fork+0x1c1>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  801255:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  80125b:	75 20                	jne    80127d <fork+0x115>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  80125d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126c:	ee 
  80126d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801270:	89 14 24             	mov    %edx,(%esp)
  801273:	e8 1c fb ff ff       	call   800d94 <sys_page_alloc>
  801278:	e9 88 00 00 00       	jmp    801305 <fork+0x19d>
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80127d:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  801283:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801286:	c1 e8 0c             	shr    $0xc,%eax
  801289:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801290:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  801295:	83 f8 01             	cmp    $0x1,%eax
  801298:	19 ff                	sbb    %edi,%edi
  80129a:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8012a0:	81 c7 05 08 00 00    	add    $0x805,%edi
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8012a6:	e8 89 fa ff ff       	call   800d34 <sys_getenvid>
  8012ab:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8012af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8012b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c4:	89 04 24             	mov    %eax,(%esp)
  8012c7:	e8 27 fb ff ff       	call   800df3 <sys_page_map>
  8012cc:	89 c6                	mov    %eax,%esi
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 33                	js     801305 <fork+0x19d>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  8012d2:	e8 5d fa ff ff       	call   800d34 <sys_getenvid>
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	e8 56 fa ff ff       	call   800d34 <sys_getenvid>
  8012de:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8012e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012e9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f1:	89 04 24             	mov    %eax,(%esp)
  8012f4:	e8 fa fa ff ff       	call   800df3 <sys_page_map>
  8012f9:	89 c6                	mov    %eax,%esi
						<0)  
		return r;

	return 0;
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	0f 49 f0             	cmovns %eax,%esi
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801305:	85 f6                	test   %esi,%esi
  801307:	79 20                	jns    801329 <fork+0x1c1>
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801309:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80130d:	c7 44 24 08 f0 1d 80 	movl   $0x801df0,0x8(%esp)
  801314:	00 
  801315:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80131c:	00 
  80131d:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801324:	e8 ff 01 00 00       	call   801528 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801329:	89 d9                	mov    %ebx,%ecx
  80132b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  801331:	3d 00 10 c0 ee       	cmp    $0xeec01000,%eax
  801336:	0f 85 e0 fe ff ff    	jne    80121c <fork+0xb4>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80133c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801343:	00 
  801344:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801347:	89 04 24             	mov    %eax,(%esp)
  80134a:	e8 60 fb ff ff       	call   800eaf <sys_env_set_status>
  80134f:	85 c0                	test   %eax,%eax
  801351:	79 1c                	jns    80136f <fork+0x207>
		panic("sys_env_set_status");
  801353:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  80136a:	e8 b9 01 00 00       	call   801528 <_panic>
	return childEid;
}
  80136f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801372:	83 c4 3c             	add    $0x3c,%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5f                   	pop    %edi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <sfork>:

// Challenge!
int
sfork(void)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801380:	c7 44 24 08 92 1c 80 	movl   $0x801c92,0x8(%esp)
  801387:	00 
  801388:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 74 1c 80 00 	movl   $0x801c74,(%esp)
  801397:	e8 8c 01 00 00       	call   801528 <_panic>
  80139c:	00 00                	add    %al,(%eax)
	...

008013a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 10             	sub    $0x10,%esp
  8013a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	75 0e                	jne    8013c3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8013b5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8013bc:	e8 de fb ff ff       	call   800f9f <sys_ipc_recv>
  8013c1:	eb 08                	jmp    8013cb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8013c3:	89 04 24             	mov    %eax,(%esp)
  8013c6:	e8 d4 fb ff ff       	call   800f9f <sys_ipc_recv>
	if(r == 0){
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	75 1e                	jne    8013f0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8013d2:	85 db                	test   %ebx,%ebx
  8013d4:	74 0a                	je     8013e0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8013d6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013db:	8b 40 74             	mov    0x74(%eax),%eax
  8013de:	89 03                	mov    %eax,(%ebx)

		if(perm_store != 0 )
  8013e0:	85 f6                	test   %esi,%esi
  8013e2:	74 2c                	je     801410 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  8013e4:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013e9:	8b 40 78             	mov    0x78(%eax),%eax
  8013ec:	89 06                	mov    %eax,(%esi)
  8013ee:	eb 20                	jmp    801410 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8013f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f4:	c7 44 24 08 18 1e 80 	movl   $0x801e18,0x8(%esp)
  8013fb:	00 
  8013fc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801403:	00 
  801404:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  80140b:	e8 18 01 00 00       	call   801528 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801410:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801415:	8b 50 70             	mov    0x70(%eax),%edx
  801418:	85 d2                	test   %edx,%edx
  80141a:	75 13                	jne    80142f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80141c:	8b 40 48             	mov    0x48(%eax),%eax
  80141f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801423:	c7 04 24 48 1e 80 00 	movl   $0x801e48,(%esp)
  80142a:	e8 d4 ee ff ff       	call   800303 <cprintf>
	return thisenv->env_ipc_value;
  80142f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801434:	8b 40 70             	mov    0x70(%eax),%eax
	

	


}
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 1c             	sub    $0x1c,%esp
  801447:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	
	int r =0;
	while(1){
		if(pg == 0)
  80144d:	85 f6                	test   %esi,%esi
  80144f:	75 22                	jne    801473 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801451:	8b 45 14             	mov    0x14(%ebp),%eax
  801454:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801458:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80145f:	ee 
  801460:	8b 45 0c             	mov    0xc(%ebp),%eax
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	89 3c 24             	mov    %edi,(%esp)
  80146a:	e8 fc fa ff ff       	call   800f6b <sys_ipc_try_send>
  80146f:	89 c3                	mov    %eax,%ebx
  801471:	eb 1c                	jmp    80148f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801473:	8b 45 14             	mov    0x14(%ebp),%eax
  801476:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80147e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	89 3c 24             	mov    %edi,(%esp)
  801488:	e8 de fa ff ff       	call   800f6b <sys_ipc_try_send>
  80148d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80148f:	89 d8                	mov    %ebx,%eax
  801491:	c1 e8 1f             	shr    $0x1f,%eax
  801494:	84 c0                	test   %al,%al
  801496:	74 3a                	je     8014d2 <ipc_send+0x94>
  801498:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80149b:	74 35                	je     8014d2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80149d:	e8 92 f8 ff ff       	call   800d34 <sys_getenvid>
  8014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a6:	c7 04 24 9e 1e 80 00 	movl   $0x801e9e,(%esp)
  8014ad:	e8 51 ee ff ff       	call   800303 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8014b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014b6:	c7 44 24 08 6c 1e 80 	movl   $0x801e6c,0x8(%esp)
  8014bd:	00 
  8014be:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8014c5:	00 
  8014c6:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  8014cd:	e8 56 00 00 00       	call   801528 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8014d2:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8014d5:	75 0e                	jne    8014e5 <ipc_send+0xa7>
			sys_yield();
  8014d7:	e8 88 f8 ff ff       	call   800d64 <sys_yield>
		else break;
	}
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	e9 68 ff ff ff       	jmp    80144d <ipc_send+0xf>
	



}
  8014e5:	83 c4 1c             	add    $0x1c,%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801501:	8b 52 50             	mov    0x50(%edx),%edx
  801504:	39 ca                	cmp    %ecx,%edx
  801506:	75 0d                	jne    801515 <ipc_find_env+0x28>
			return envs[i].env_id;
  801508:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80150b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801510:	8b 40 40             	mov    0x40(%eax),%eax
  801513:	eb 0e                	jmp    801523 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801515:	83 c0 01             	add    $0x1,%eax
  801518:	3d 00 04 00 00       	cmp    $0x400,%eax
  80151d:	75 d9                	jne    8014f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80151f:	66 b8 00 00          	mov    $0x0,%ax
}
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    
  801525:	00 00                	add    %al,(%eax)
	...

00801528 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801530:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801533:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  801539:	e8 f6 f7 ff ff       	call   800d34 <sys_getenvid>
  80153e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801541:	89 54 24 10          	mov    %edx,0x10(%esp)
  801545:	8b 55 08             	mov    0x8(%ebp),%edx
  801548:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80154c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801550:	89 44 24 04          	mov    %eax,0x4(%esp)
  801554:	c7 04 24 b0 1e 80 00 	movl   $0x801eb0,(%esp)
  80155b:	e8 a3 ed ff ff       	call   800303 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801560:	89 74 24 04          	mov    %esi,0x4(%esp)
  801564:	8b 45 10             	mov    0x10(%ebp),%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 33 ed ff ff       	call   8002a2 <vcprintf>
	cprintf("\n");
  80156f:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  801576:	e8 88 ed ff ff       	call   800303 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80157b:	cc                   	int3   
  80157c:	eb fd                	jmp    80157b <_panic+0x53>
	...

00801580 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801586:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80158d:	75 44                	jne    8015d3 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80158f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801594:	8b 40 48             	mov    0x48(%eax),%eax
  801597:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80159e:	00 
  80159f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015a6:	ee 
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 e5 f7 ff ff       	call   800d94 <sys_page_alloc>
		if( r < 0)
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	79 20                	jns    8015d3 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  8015b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b7:	c7 44 24 08 d4 1e 80 	movl   $0x801ed4,0x8(%esp)
  8015be:	00 
  8015bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015c6:	00 
  8015c7:	c7 04 24 30 1f 80 00 	movl   $0x801f30,(%esp)
  8015ce:	e8 55 ff ff ff       	call   801528 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	a3 10 20 80 00       	mov    %eax,0x802010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8015db:	e8 54 f7 ff ff       	call   800d34 <sys_getenvid>
  8015e0:	c7 44 24 04 18 16 80 	movl   $0x801618,0x4(%esp)
  8015e7:	00 
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 1d f9 ff ff       	call   800f0d <sys_env_set_pgfault_upcall>
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	79 20                	jns    801614 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8015f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f8:	c7 44 24 08 04 1f 80 	movl   $0x801f04,0x8(%esp)
  8015ff:	00 
  801600:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801607:	00 
  801608:	c7 04 24 30 1f 80 00 	movl   $0x801f30,(%esp)
  80160f:	e8 14 ff ff ff       	call   801528 <_panic>


}
  801614:	c9                   	leave  
  801615:	c3                   	ret    
	...

00801618 <_pgfault_upcall>:
  801618:	54                   	push   %esp
  801619:	a1 10 20 80 00       	mov    0x802010,%eax
  80161e:	ff d0                	call   *%eax
  801620:	83 c4 04             	add    $0x4,%esp
  801623:	8b 44 24 28          	mov    0x28(%esp),%eax
  801627:	8b 5c 24 10          	mov    0x10(%esp),%ebx
  80162b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80162f:	89 41 fc             	mov    %eax,-0x4(%ecx)
  801632:	89 59 f8             	mov    %ebx,-0x8(%ecx)
  801635:	8d 69 f8             	lea    -0x8(%ecx),%ebp
  801638:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80163c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801640:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801644:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801648:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  80164c:	8b 44 24 24          	mov    0x24(%esp),%eax
  801650:	8d 64 24 2c          	lea    0x2c(%esp),%esp
  801654:	9d                   	popf   
  801655:	c9                   	leave  
  801656:	c3                   	ret    
	...

00801660 <__udivdi3>:
  801660:	83 ec 1c             	sub    $0x1c,%esp
  801663:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801667:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80166b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80166f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801673:	89 74 24 10          	mov    %esi,0x10(%esp)
  801677:	8b 74 24 24          	mov    0x24(%esp),%esi
  80167b:	85 ff                	test   %edi,%edi
  80167d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801681:	89 44 24 08          	mov    %eax,0x8(%esp)
  801685:	89 cd                	mov    %ecx,%ebp
  801687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168b:	75 33                	jne    8016c0 <__udivdi3+0x60>
  80168d:	39 f1                	cmp    %esi,%ecx
  80168f:	77 57                	ja     8016e8 <__udivdi3+0x88>
  801691:	85 c9                	test   %ecx,%ecx
  801693:	75 0b                	jne    8016a0 <__udivdi3+0x40>
  801695:	b8 01 00 00 00       	mov    $0x1,%eax
  80169a:	31 d2                	xor    %edx,%edx
  80169c:	f7 f1                	div    %ecx
  80169e:	89 c1                	mov    %eax,%ecx
  8016a0:	89 f0                	mov    %esi,%eax
  8016a2:	31 d2                	xor    %edx,%edx
  8016a4:	f7 f1                	div    %ecx
  8016a6:	89 c6                	mov    %eax,%esi
  8016a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016ac:	f7 f1                	div    %ecx
  8016ae:	89 f2                	mov    %esi,%edx
  8016b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016bc:	83 c4 1c             	add    $0x1c,%esp
  8016bf:	c3                   	ret    
  8016c0:	31 d2                	xor    %edx,%edx
  8016c2:	31 c0                	xor    %eax,%eax
  8016c4:	39 f7                	cmp    %esi,%edi
  8016c6:	77 e8                	ja     8016b0 <__udivdi3+0x50>
  8016c8:	0f bd cf             	bsr    %edi,%ecx
  8016cb:	83 f1 1f             	xor    $0x1f,%ecx
  8016ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016d2:	75 2c                	jne    801700 <__udivdi3+0xa0>
  8016d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8016d8:	76 04                	jbe    8016de <__udivdi3+0x7e>
  8016da:	39 f7                	cmp    %esi,%edi
  8016dc:	73 d2                	jae    8016b0 <__udivdi3+0x50>
  8016de:	31 d2                	xor    %edx,%edx
  8016e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e5:	eb c9                	jmp    8016b0 <__udivdi3+0x50>
  8016e7:	90                   	nop
  8016e8:	89 f2                	mov    %esi,%edx
  8016ea:	f7 f1                	div    %ecx
  8016ec:	31 d2                	xor    %edx,%edx
  8016ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016fa:	83 c4 1c             	add    $0x1c,%esp
  8016fd:	c3                   	ret    
  8016fe:	66 90                	xchg   %ax,%ax
  801700:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801705:	b8 20 00 00 00       	mov    $0x20,%eax
  80170a:	89 ea                	mov    %ebp,%edx
  80170c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801710:	d3 e7                	shl    %cl,%edi
  801712:	89 c1                	mov    %eax,%ecx
  801714:	d3 ea                	shr    %cl,%edx
  801716:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80171b:	09 fa                	or     %edi,%edx
  80171d:	89 f7                	mov    %esi,%edi
  80171f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801723:	89 f2                	mov    %esi,%edx
  801725:	8b 74 24 08          	mov    0x8(%esp),%esi
  801729:	d3 e5                	shl    %cl,%ebp
  80172b:	89 c1                	mov    %eax,%ecx
  80172d:	d3 ef                	shr    %cl,%edi
  80172f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801734:	d3 e2                	shl    %cl,%edx
  801736:	89 c1                	mov    %eax,%ecx
  801738:	d3 ee                	shr    %cl,%esi
  80173a:	09 d6                	or     %edx,%esi
  80173c:	89 fa                	mov    %edi,%edx
  80173e:	89 f0                	mov    %esi,%eax
  801740:	f7 74 24 0c          	divl   0xc(%esp)
  801744:	89 d7                	mov    %edx,%edi
  801746:	89 c6                	mov    %eax,%esi
  801748:	f7 e5                	mul    %ebp
  80174a:	39 d7                	cmp    %edx,%edi
  80174c:	72 22                	jb     801770 <__udivdi3+0x110>
  80174e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801752:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801757:	d3 e5                	shl    %cl,%ebp
  801759:	39 c5                	cmp    %eax,%ebp
  80175b:	73 04                	jae    801761 <__udivdi3+0x101>
  80175d:	39 d7                	cmp    %edx,%edi
  80175f:	74 0f                	je     801770 <__udivdi3+0x110>
  801761:	89 f0                	mov    %esi,%eax
  801763:	31 d2                	xor    %edx,%edx
  801765:	e9 46 ff ff ff       	jmp    8016b0 <__udivdi3+0x50>
  80176a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801770:	8d 46 ff             	lea    -0x1(%esi),%eax
  801773:	31 d2                	xor    %edx,%edx
  801775:	8b 74 24 10          	mov    0x10(%esp),%esi
  801779:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80177d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801781:	83 c4 1c             	add    $0x1c,%esp
  801784:	c3                   	ret    
	...

00801790 <__umoddi3>:
  801790:	83 ec 1c             	sub    $0x1c,%esp
  801793:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801797:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80179b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80179f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8017a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8017ab:	85 ed                	test   %ebp,%ebp
  8017ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8017b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b5:	89 cf                	mov    %ecx,%edi
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	89 f2                	mov    %esi,%edx
  8017bc:	75 1a                	jne    8017d8 <__umoddi3+0x48>
  8017be:	39 f1                	cmp    %esi,%ecx
  8017c0:	76 4e                	jbe    801810 <__umoddi3+0x80>
  8017c2:	f7 f1                	div    %ecx
  8017c4:	89 d0                	mov    %edx,%eax
  8017c6:	31 d2                	xor    %edx,%edx
  8017c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017d4:	83 c4 1c             	add    $0x1c,%esp
  8017d7:	c3                   	ret    
  8017d8:	39 f5                	cmp    %esi,%ebp
  8017da:	77 54                	ja     801830 <__umoddi3+0xa0>
  8017dc:	0f bd c5             	bsr    %ebp,%eax
  8017df:	83 f0 1f             	xor    $0x1f,%eax
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	75 60                	jne    801848 <__umoddi3+0xb8>
  8017e8:	3b 0c 24             	cmp    (%esp),%ecx
  8017eb:	0f 87 07 01 00 00    	ja     8018f8 <__umoddi3+0x168>
  8017f1:	89 f2                	mov    %esi,%edx
  8017f3:	8b 34 24             	mov    (%esp),%esi
  8017f6:	29 ce                	sub    %ecx,%esi
  8017f8:	19 ea                	sbb    %ebp,%edx
  8017fa:	89 34 24             	mov    %esi,(%esp)
  8017fd:	8b 04 24             	mov    (%esp),%eax
  801800:	8b 74 24 10          	mov    0x10(%esp),%esi
  801804:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801808:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80180c:	83 c4 1c             	add    $0x1c,%esp
  80180f:	c3                   	ret    
  801810:	85 c9                	test   %ecx,%ecx
  801812:	75 0b                	jne    80181f <__umoddi3+0x8f>
  801814:	b8 01 00 00 00       	mov    $0x1,%eax
  801819:	31 d2                	xor    %edx,%edx
  80181b:	f7 f1                	div    %ecx
  80181d:	89 c1                	mov    %eax,%ecx
  80181f:	89 f0                	mov    %esi,%eax
  801821:	31 d2                	xor    %edx,%edx
  801823:	f7 f1                	div    %ecx
  801825:	8b 04 24             	mov    (%esp),%eax
  801828:	f7 f1                	div    %ecx
  80182a:	eb 98                	jmp    8017c4 <__umoddi3+0x34>
  80182c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801830:	89 f2                	mov    %esi,%edx
  801832:	8b 74 24 10          	mov    0x10(%esp),%esi
  801836:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80183a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80183e:	83 c4 1c             	add    $0x1c,%esp
  801841:	c3                   	ret    
  801842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801848:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80184d:	89 e8                	mov    %ebp,%eax
  80184f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801854:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801858:	89 fa                	mov    %edi,%edx
  80185a:	d3 e0                	shl    %cl,%eax
  80185c:	89 e9                	mov    %ebp,%ecx
  80185e:	d3 ea                	shr    %cl,%edx
  801860:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801865:	09 c2                	or     %eax,%edx
  801867:	8b 44 24 08          	mov    0x8(%esp),%eax
  80186b:	89 14 24             	mov    %edx,(%esp)
  80186e:	89 f2                	mov    %esi,%edx
  801870:	d3 e7                	shl    %cl,%edi
  801872:	89 e9                	mov    %ebp,%ecx
  801874:	d3 ea                	shr    %cl,%edx
  801876:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80187b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80187f:	d3 e6                	shl    %cl,%esi
  801881:	89 e9                	mov    %ebp,%ecx
  801883:	d3 e8                	shr    %cl,%eax
  801885:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80188a:	09 f0                	or     %esi,%eax
  80188c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801890:	f7 34 24             	divl   (%esp)
  801893:	d3 e6                	shl    %cl,%esi
  801895:	89 74 24 08          	mov    %esi,0x8(%esp)
  801899:	89 d6                	mov    %edx,%esi
  80189b:	f7 e7                	mul    %edi
  80189d:	39 d6                	cmp    %edx,%esi
  80189f:	89 c1                	mov    %eax,%ecx
  8018a1:	89 d7                	mov    %edx,%edi
  8018a3:	72 3f                	jb     8018e4 <__umoddi3+0x154>
  8018a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8018a9:	72 35                	jb     8018e0 <__umoddi3+0x150>
  8018ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018af:	29 c8                	sub    %ecx,%eax
  8018b1:	19 fe                	sbb    %edi,%esi
  8018b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018b8:	89 f2                	mov    %esi,%edx
  8018ba:	d3 e8                	shr    %cl,%eax
  8018bc:	89 e9                	mov    %ebp,%ecx
  8018be:	d3 e2                	shl    %cl,%edx
  8018c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018c5:	09 d0                	or     %edx,%eax
  8018c7:	89 f2                	mov    %esi,%edx
  8018c9:	d3 ea                	shr    %cl,%edx
  8018cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8018cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8018d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8018d7:	83 c4 1c             	add    $0x1c,%esp
  8018da:	c3                   	ret    
  8018db:	90                   	nop
  8018dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018e0:	39 d6                	cmp    %edx,%esi
  8018e2:	75 c7                	jne    8018ab <__umoddi3+0x11b>
  8018e4:	89 d7                	mov    %edx,%edi
  8018e6:	89 c1                	mov    %eax,%ecx
  8018e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8018ec:	1b 3c 24             	sbb    (%esp),%edi
  8018ef:	eb ba                	jmp    8018ab <__umoddi3+0x11b>
  8018f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018f8:	39 f5                	cmp    %esi,%ebp
  8018fa:	0f 82 f1 fe ff ff    	jb     8017f1 <__umoddi3+0x61>
  801900:	e9 f8 fe ff ff       	jmp    8017fd <__umoddi3+0x6d>
