
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
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
  800039:	e8 07 11 00 00       	call   801145 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 bd 00 00 00    	jne    800106 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800050:	00 
  800051:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800058:	00 
  800059:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 1c 13 00 00       	call   801380 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800064:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006b:	00 
  80006c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800073:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  80007a:	e8 60 02 00 00       	call   8002df <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80007f:	a1 04 20 80 00       	mov    0x802004,%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 94 08 00 00       	call   800920 <strlen>
  80008c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800090:	a1 04 20 80 00       	mov    0x802004,%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a0:	e8 8d 09 00 00       	call   800a32 <strncmp>
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 0c                	jne    8000b5 <umain+0x82>
			cprintf("child received correct message\n");
  8000a9:	c7 04 24 d4 18 80 00 	movl   $0x8018d4,(%esp)
  8000b0:	e8 2a 02 00 00       	call   8002df <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b5:	a1 00 20 80 00       	mov    0x802000,%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 5e 08 00 00       	call   800920 <strlen>
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c9:	a1 00 20 80 00       	mov    0x802000,%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d9:	e8 7e 0a 00 00       	call   800b5c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f5:	00 
  8000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f9:	89 04 24             	mov    %eax,(%esp)
  8000fc:	e8 1d 13 00 00       	call   80141e <ipc_send>
		return;
  800101:	e9 d8 00 00 00       	jmp    8001de <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800106:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010b:	8b 40 48             	mov    0x48(%eax),%eax
  80010e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800115:	00 
  800116:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011d:	00 
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 4d 0c 00 00       	call   800d73 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800126:	a1 04 20 80 00       	mov    0x802004,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 ed 07 00 00       	call   800920 <strlen>
  800133:	83 c0 01             	add    $0x1,%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	a1 04 20 80 00       	mov    0x802004,%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014a:	e8 0d 0a 00 00       	call   800b5c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800166:	00 
  800167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 ac 12 00 00       	call   80141e <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800179:	00 
  80017a:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800181:	00 
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 f3 11 00 00       	call   801380 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018d:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800194:	00 
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  8001a3:	e8 37 01 00 00       	call   8002df <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a8:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 6b 07 00 00       	call   800920 <strlen>
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	a1 00 20 80 00       	mov    0x802000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c9:	e8 64 08 00 00       	call   800a32 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 0c                	jne    8001de <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d2:	c7 04 24 f4 18 80 00 	movl   $0x8018f4,(%esp)
  8001d9:	e8 01 01 00 00       	call   8002df <cprintf>
	return;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8001ee:	e8 42 0b 00 00       	call   800d35 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800200:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 db                	test   %ebx,%ebx
  800207:	7e 07                	jle    800210 <libmain+0x30>
		binaryname = argv[0];
  800209:	8b 06                	mov    (%esi),%eax
  80020b:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	89 1c 24             	mov    %ebx,(%esp)
  800217:	e8 17 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021c:	e8 07 00 00 00       	call   800228 <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80022e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800235:	e8 a9 0a 00 00       	call   800ce3 <sys_env_destroy>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 14             	sub    $0x14,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 13                	mov    (%ebx),%edx
  800248:	8d 42 01             	lea    0x1(%edx),%eax
  80024b:	89 03                	mov    %eax,(%ebx)
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800254:	3d ff 00 00 00       	cmp    $0xff,%eax
  800259:	75 19                	jne    800274 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80025b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800262:	00 
  800263:	8d 43 08             	lea    0x8(%ebx),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	e8 38 0a 00 00       	call   800ca6 <sys_cputs>
		b->idx = 0;
  80026e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800274:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800278:	83 c4 14             	add    $0x14,%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800287:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028e:	00 00 00 
	b.cnt = 0;
  800291:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800298:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	c7 04 24 3c 02 80 00 	movl   $0x80023c,(%esp)
  8002ba:	e8 75 01 00 00       	call   800434 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 cf 09 00 00       	call   800ca6 <sys_cputs>

	return b.cnt;
}
  8002d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 87 ff ff ff       	call   80027e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    
  8002f9:	66 90                	xchg   %ax,%ax
  8002fb:	66 90                	xchg   %ax,%ax
  8002fd:	66 90                	xchg   %ax,%ax
  8002ff:	90                   	nop

00800300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	89 d7                	mov    %edx,%edi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
  800317:	89 c3                	mov    %eax,%ebx
  800319:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032d:	39 d9                	cmp    %ebx,%ecx
  80032f:	72 05                	jb     800336 <printnum+0x36>
  800331:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800334:	77 69                	ja     80039f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800336:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800339:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80033d:	83 ee 01             	sub    $0x1,%esi
  800340:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 44 24 08          	mov    0x8(%esp),%eax
  80034c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800350:	89 c3                	mov    %eax,%ebx
  800352:	89 d6                	mov    %edx,%esi
  800354:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800357:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80035a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80035e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 bc 12 00 00       	call   801630 <__udivdi3>
  800374:	89 d9                	mov    %ebx,%ecx
  800376:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	89 54 24 04          	mov    %edx,0x4(%esp)
  800385:	89 fa                	mov    %edi,%edx
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	e8 71 ff ff ff       	call   800300 <printnum>
  80038f:	eb 1b                	jmp    8003ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	8b 45 18             	mov    0x18(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff d3                	call   *%ebx
  80039d:	eb 03                	jmp    8003a2 <printnum+0xa2>
  80039f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a2:	83 ee 01             	sub    $0x1,%esi
  8003a5:	85 f6                	test   %esi,%esi
  8003a7:	7f e8                	jg     800391 <printnum+0x91>
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	e8 8c 13 00 00       	call   801760 <__umoddi3>
  8003d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d8:	0f be 80 6c 19 80 00 	movsbl 0x80196c(%eax),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003e5:	ff d0                	call   *%eax
}
  8003e7:	83 c4 3c             	add    $0x3c,%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 0a                	jae    80040a <sprintputch+0x1b>
		*b->buf++ = ch;
  800400:	8d 4a 01             	lea    0x1(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	88 02                	mov    %al,(%edx)
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800412:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800415:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800420:	8b 45 0c             	mov    0xc(%ebp),%eax
  800423:	89 44 24 04          	mov    %eax,0x4(%esp)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	e8 02 00 00 00       	call   800434 <vprintfmt>
	va_end(ap);
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 3c             	sub    $0x3c,%esp
  80043d:	8b 75 08             	mov    0x8(%ebp),%esi
  800440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800443:	8b 7d 10             	mov    0x10(%ebp),%edi
  800446:	eb 11                	jmp    800459 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800448:	85 c0                	test   %eax,%eax
  80044a:	0f 84 48 04 00 00    	je     800898 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800450:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800459:	83 c7 01             	add    $0x1,%edi
  80045c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800460:	83 f8 25             	cmp    $0x25,%eax
  800463:	75 e3                	jne    800448 <vprintfmt+0x14>
  800465:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800469:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800470:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800477:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80047e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800483:	eb 1f                	jmp    8004a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800488:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80048c:	eb 16                	jmp    8004a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800491:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800495:	eb 0d                	jmp    8004a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800497:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 17             	movzbl (%edi),%edx
  8004ad:	0f b6 c2             	movzbl %dl,%eax
  8004b0:	83 ea 23             	sub    $0x23,%edx
  8004b3:	80 fa 55             	cmp    $0x55,%dl
  8004b6:	0f 87 bf 03 00 00    	ja     80087b <vprintfmt+0x447>
  8004bc:	0f b6 d2             	movzbl %dl,%edx
  8004bf:	ff 24 95 c0 1a 80 00 	jmp    *0x801ac0(,%edx,4)
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004d8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004de:	83 f9 09             	cmp    $0x9,%ecx
  8004e1:	77 3c                	ja     80051f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e6:	eb e9                	jmp    8004d1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 40 04             	lea    0x4(%eax),%eax
  8004f6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xf1>
  8004fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c2             	cmovns %edx,%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 91                	jmp    8004a4 <vprintfmt+0x70>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 85                	jmp    8004a4 <vprintfmt+0x70>
  80051f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800522:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 75 ff ff ff    	jns    8004a4 <vprintfmt+0x70>
  80052f:	e9 63 ff ff ff       	jmp    800497 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800534:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053a:	e9 65 ff ff ff       	jmp    8004a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800546:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800554:	e9 00 ff ff ff       	jmp    800459 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800560:	8b 00                	mov    (%eax),%eax
  800562:	99                   	cltd   
  800563:	31 d0                	xor    %edx,%eax
  800565:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800567:	83 f8 0f             	cmp    $0xf,%eax
  80056a:	7f 0b                	jg     800577 <vprintfmt+0x143>
  80056c:	8b 14 85 20 1c 80 00 	mov    0x801c20(,%eax,4),%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	75 20                	jne    800597 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800577:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057b:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800582:	00 
  800583:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 7d fe ff ff       	call   80040c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800592:	e9 c2 fe ff ff       	jmp    800459 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800597:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059b:	c7 44 24 08 8d 19 80 	movl   $0x80198d,0x8(%esp)
  8005a2:	00 
  8005a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a7:	89 34 24             	mov    %esi,(%esp)
  8005aa:	e8 5d fe ff ff       	call   80040c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	e9 a2 fe ff ff       	jmp    800459 <vprintfmt+0x25>
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	b8 7d 19 80 00       	mov    $0x80197d,%eax
  8005d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d7:	0f 84 92 00 00 00    	je     80066f <vprintfmt+0x23b>
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	0f 8e 98 00 00 00    	jle    80067d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	89 3c 24             	mov    %edi,(%esp)
  8005ec:	e8 47 03 00 00       	call   800938 <strnlen>
  8005f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f4:	29 c1                	sub    %eax,%ecx
  8005f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800600:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800603:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	eb 0f                	jmp    800616 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800607:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800613:	83 ef 01             	sub    $0x1,%edi
  800616:	85 ff                	test   %edi,%edi
  800618:	7f ed                	jg     800607 <vprintfmt+0x1d3>
  80061a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800620:	85 c9                	test   %ecx,%ecx
  800622:	b8 00 00 00 00       	mov    $0x0,%eax
  800627:	0f 49 c1             	cmovns %ecx,%eax
  80062a:	29 c1                	sub    %eax,%ecx
  80062c:	89 75 08             	mov    %esi,0x8(%ebp)
  80062f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800632:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800635:	89 cb                	mov    %ecx,%ebx
  800637:	eb 50                	jmp    800689 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800639:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063d:	74 1e                	je     80065d <vprintfmt+0x229>
  80063f:	0f be d2             	movsbl %dl,%edx
  800642:	83 ea 20             	sub    $0x20,%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 13                	jbe    80065d <vprintfmt+0x229>
					putch('?', putdat);
  80064a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800651:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800658:	ff 55 08             	call   *0x8(%ebp)
  80065b:	eb 0d                	jmp    80066a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80065d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800660:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	83 eb 01             	sub    $0x1,%ebx
  80066d:	eb 1a                	jmp    800689 <vprintfmt+0x255>
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067b:	eb 0c                	jmp    800689 <vprintfmt+0x255>
  80067d:	89 75 08             	mov    %esi,0x8(%ebp)
  800680:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800683:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800686:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800689:	83 c7 01             	add    $0x1,%edi
  80068c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800690:	0f be c2             	movsbl %dl,%eax
  800693:	85 c0                	test   %eax,%eax
  800695:	74 25                	je     8006bc <vprintfmt+0x288>
  800697:	85 f6                	test   %esi,%esi
  800699:	78 9e                	js     800639 <vprintfmt+0x205>
  80069b:	83 ee 01             	sub    $0x1,%esi
  80069e:	79 99                	jns    800639 <vprintfmt+0x205>
  8006a0:	89 df                	mov    %ebx,%edi
  8006a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a8:	eb 1a                	jmp    8006c4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b7:	83 ef 01             	sub    $0x1,%edi
  8006ba:	eb 08                	jmp    8006c4 <vprintfmt+0x290>
  8006bc:	89 df                	mov    %ebx,%edi
  8006be:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c4:	85 ff                	test   %edi,%edi
  8006c6:	7f e2                	jg     8006aa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cb:	e9 89 fd ff ff       	jmp    800459 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 19                	jle    8006ee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 40 08             	lea    0x8(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ec:	eb 38                	jmp    800726 <vprintfmt+0x2f2>
	else if (lflag)
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	74 1b                	je     80070d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 c1                	mov    %eax,%ecx
  8006fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
  80070b:	eb 19                	jmp    800726 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 00                	mov    (%eax),%eax
  800712:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800715:	89 c1                	mov    %eax,%ecx
  800717:	c1 f9 1f             	sar    $0x1f,%ecx
  80071a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8d 40 04             	lea    0x4(%eax),%eax
  800723:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800726:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800729:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800731:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800735:	0f 89 04 01 00 00    	jns    80083f <vprintfmt+0x40b>
				putch('-', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80074b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80074e:	f7 da                	neg    %edx
  800750:	83 d1 00             	adc    $0x0,%ecx
  800753:	f7 d9                	neg    %ecx
  800755:	e9 e5 00 00 00       	jmp    80083f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7e 10                	jle    80076f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 10                	mov    (%eax),%edx
  800764:	8b 48 04             	mov    0x4(%eax),%ecx
  800767:	8d 40 08             	lea    0x8(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	eb 26                	jmp    800795 <vprintfmt+0x361>
	else if (lflag)
  80076f:	85 c9                	test   %ecx,%ecx
  800771:	74 12                	je     800785 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8b 10                	mov    (%eax),%edx
  800778:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077d:	8d 40 04             	lea    0x4(%eax),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
  800783:	eb 10                	jmp    800795 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078f:	8d 40 04             	lea    0x4(%eax),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800795:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80079a:	e9 a0 00 00 00       	jmp    80083f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80079f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007b7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007c4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007c9:	e9 8b fc ff ff       	jmp    800459 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007fd:	eb 40                	jmp    80083f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ff:	83 f9 01             	cmp    $0x1,%ecx
  800802:	7e 10                	jle    800814 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8b 10                	mov    (%eax),%edx
  800809:	8b 48 04             	mov    0x4(%eax),%ecx
  80080c:	8d 40 08             	lea    0x8(%eax),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
  800812:	eb 26                	jmp    80083a <vprintfmt+0x406>
	else if (lflag)
  800814:	85 c9                	test   %ecx,%ecx
  800816:	74 12                	je     80082a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
  800828:	eb 10                	jmp    80083a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800834:	8d 40 04             	lea    0x4(%eax),%eax
  800837:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80083a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800843:	89 44 24 10          	mov    %eax,0x10(%esp)
  800847:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800852:	89 14 24             	mov    %edx,(%esp)
  800855:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800859:	89 da                	mov    %ebx,%edx
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	e8 9e fa ff ff       	call   800300 <printnum>
			break;
  800862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800865:	e9 ef fb ff ff       	jmp    800459 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800876:	e9 de fb ff ff       	jmp    800459 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800886:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	eb 03                	jmp    80088d <vprintfmt+0x459>
  80088a:	83 ef 01             	sub    $0x1,%edi
  80088d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800891:	75 f7                	jne    80088a <vprintfmt+0x456>
  800893:	e9 c1 fb ff ff       	jmp    800459 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800898:	83 c4 3c             	add    $0x3c,%esp
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 28             	sub    $0x28,%esp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	74 30                	je     8008f1 <vsnprintf+0x51>
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	7e 2c                	jle    8008f1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	c7 04 24 ef 03 80 00 	movl   $0x8003ef,(%esp)
  8008e1:	e8 4e fb ff ff       	call   800434 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ef:	eb 05                	jmp    8008f6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800905:	8b 45 10             	mov    0x10(%ebp),%eax
  800908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 82 ff ff ff       	call   8008a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 03                	jmp    800930 <strlen+0x10>
		n++;
  80092d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800930:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800934:	75 f7                	jne    80092d <strlen+0xd>
		n++;
	return n;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	eb 03                	jmp    80094b <strnlen+0x13>
		n++;
  800948:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094b:	39 d0                	cmp    %edx,%eax
  80094d:	74 06                	je     800955 <strnlen+0x1d>
  80094f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800953:	75 f3                	jne    800948 <strnlen+0x10>
		n++;
	return n;
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800961:	89 c2                	mov    %eax,%edx
  800963:	83 c2 01             	add    $0x1,%edx
  800966:	83 c1 01             	add    $0x1,%ecx
  800969:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80096d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800970:	84 db                	test   %bl,%bl
  800972:	75 ef                	jne    800963 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800974:	5b                   	pop    %ebx
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800981:	89 1c 24             	mov    %ebx,(%esp)
  800984:	e8 97 ff ff ff       	call   800920 <strlen>
	strcpy(dst + len, src);
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800990:	01 d8                	add    %ebx,%eax
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	e8 bd ff ff ff       	call   800957 <strcpy>
	return dst;
}
  80099a:	89 d8                	mov    %ebx,%eax
  80099c:	83 c4 08             	add    $0x8,%esp
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ad:	89 f3                	mov    %esi,%ebx
  8009af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b2:	89 f2                	mov    %esi,%edx
  8009b4:	eb 0f                	jmp    8009c5 <strncpy+0x23>
		*dst++ = *src;
  8009b6:	83 c2 01             	add    $0x1,%edx
  8009b9:	0f b6 01             	movzbl (%ecx),%eax
  8009bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c5:	39 da                	cmp    %ebx,%edx
  8009c7:	75 ed                	jne    8009b6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c9:	89 f0                	mov    %esi,%eax
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009dd:	89 f0                	mov    %esi,%eax
  8009df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	75 0b                	jne    8009f2 <strlcpy+0x23>
  8009e7:	eb 1d                	jmp    800a06 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f2:	39 d8                	cmp    %ebx,%eax
  8009f4:	74 0b                	je     800a01 <strlcpy+0x32>
  8009f6:	0f b6 0a             	movzbl (%edx),%ecx
  8009f9:	84 c9                	test   %cl,%cl
  8009fb:	75 ec                	jne    8009e9 <strlcpy+0x1a>
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	eb 02                	jmp    800a03 <strlcpy+0x34>
  800a01:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a03:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a06:	29 f0                	sub    %esi,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a15:	eb 06                	jmp    800a1d <strcmp+0x11>
		p++, q++;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	84 c0                	test   %al,%al
  800a22:	74 04                	je     800a28 <strcmp+0x1c>
  800a24:	3a 02                	cmp    (%edx),%al
  800a26:	74 ef                	je     800a17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a28:	0f b6 c0             	movzbl %al,%eax
  800a2b:	0f b6 12             	movzbl (%edx),%edx
  800a2e:	29 d0                	sub    %edx,%eax
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a41:	eb 06                	jmp    800a49 <strncmp+0x17>
		n--, p++, q++;
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a49:	39 d8                	cmp    %ebx,%eax
  800a4b:	74 15                	je     800a62 <strncmp+0x30>
  800a4d:	0f b6 08             	movzbl (%eax),%ecx
  800a50:	84 c9                	test   %cl,%cl
  800a52:	74 04                	je     800a58 <strncmp+0x26>
  800a54:	3a 0a                	cmp    (%edx),%cl
  800a56:	74 eb                	je     800a43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a58:	0f b6 00             	movzbl (%eax),%eax
  800a5b:	0f b6 12             	movzbl (%edx),%edx
  800a5e:	29 d0                	sub    %edx,%eax
  800a60:	eb 05                	jmp    800a67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a74:	eb 07                	jmp    800a7d <strchr+0x13>
		if (*s == c)
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 0f                	je     800a89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	75 f2                	jne    800a76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	eb 07                	jmp    800a9e <strfind+0x13>
		if (*s == c)
  800a97:	38 ca                	cmp    %cl,%dl
  800a99:	74 0a                	je     800aa5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a9b:	83 c0 01             	add    $0x1,%eax
  800a9e:	0f b6 10             	movzbl (%eax),%edx
  800aa1:	84 d2                	test   %dl,%dl
  800aa3:	75 f2                	jne    800a97 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab3:	85 c9                	test   %ecx,%ecx
  800ab5:	74 36                	je     800aed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abd:	75 28                	jne    800ae7 <memset+0x40>
  800abf:	f6 c1 03             	test   $0x3,%cl
  800ac2:	75 23                	jne    800ae7 <memset+0x40>
		c &= 0xFF;
  800ac4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	c1 e3 08             	shl    $0x8,%ebx
  800acd:	89 d6                	mov    %edx,%esi
  800acf:	c1 e6 18             	shl    $0x18,%esi
  800ad2:	89 d0                	mov    %edx,%eax
  800ad4:	c1 e0 10             	shl    $0x10,%eax
  800ad7:	09 f0                	or     %esi,%eax
  800ad9:	09 c2                	or     %eax,%edx
  800adb:	89 d0                	mov    %edx,%eax
  800add:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800adf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae2:	fc                   	cld    
  800ae3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae5:	eb 06                	jmp    800aed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	fc                   	cld    
  800aeb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b02:	39 c6                	cmp    %eax,%esi
  800b04:	73 35                	jae    800b3b <memmove+0x47>
  800b06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b09:	39 d0                	cmp    %edx,%eax
  800b0b:	73 2e                	jae    800b3b <memmove+0x47>
		s += n;
		d += n;
  800b0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1a:	75 13                	jne    800b2f <memmove+0x3b>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 0e                	jne    800b2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b21:	83 ef 04             	sub    $0x4,%edi
  800b24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2a:	fd                   	std    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 09                	jmp    800b38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2f:	83 ef 01             	sub    $0x1,%edi
  800b32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b35:	fd                   	std    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b38:	fc                   	cld    
  800b39:	eb 1d                	jmp    800b58 <memmove+0x64>
  800b3b:	89 f2                	mov    %esi,%edx
  800b3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3f:	f6 c2 03             	test   $0x3,%dl
  800b42:	75 0f                	jne    800b53 <memmove+0x5f>
  800b44:	f6 c1 03             	test   $0x3,%cl
  800b47:	75 0a                	jne    800b53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	fc                   	cld    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b51:	eb 05                	jmp    800b58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	fc                   	cld    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b62:	8b 45 10             	mov    0x10(%ebp),%eax
  800b65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 04 24             	mov    %eax,(%esp)
  800b76:	e8 79 ff ff ff       	call   800af4 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	eb 1a                	jmp    800ba9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8f:	0f b6 02             	movzbl (%edx),%eax
  800b92:	0f b6 19             	movzbl (%ecx),%ebx
  800b95:	38 d8                	cmp    %bl,%al
  800b97:	74 0a                	je     800ba3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c0             	movzbl %al,%eax
  800b9c:	0f b6 db             	movzbl %bl,%ebx
  800b9f:	29 d8                	sub    %ebx,%eax
  800ba1:	eb 0f                	jmp    800bb2 <memcmp+0x35>
		s1++, s2++;
  800ba3:	83 c2 01             	add    $0x1,%edx
  800ba6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f2                	cmp    %esi,%edx
  800bab:	75 e2                	jne    800b8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bbf:	89 c2                	mov    %eax,%edx
  800bc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc4:	eb 07                	jmp    800bcd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc6:	38 08                	cmp    %cl,(%eax)
  800bc8:	74 07                	je     800bd1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	72 f5                	jb     800bc6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bdf:	eb 03                	jmp    800be4 <strtol+0x11>
		s++;
  800be1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be4:	0f b6 0a             	movzbl (%edx),%ecx
  800be7:	80 f9 09             	cmp    $0x9,%cl
  800bea:	74 f5                	je     800be1 <strtol+0xe>
  800bec:	80 f9 20             	cmp    $0x20,%cl
  800bef:	74 f0                	je     800be1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf1:	80 f9 2b             	cmp    $0x2b,%cl
  800bf4:	75 0a                	jne    800c00 <strtol+0x2d>
		s++;
  800bf6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfe:	eb 11                	jmp    800c11 <strtol+0x3e>
  800c00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c05:	80 f9 2d             	cmp    $0x2d,%cl
  800c08:	75 07                	jne    800c11 <strtol+0x3e>
		s++, neg = 1;
  800c0a:	8d 52 01             	lea    0x1(%edx),%edx
  800c0d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c16:	75 15                	jne    800c2d <strtol+0x5a>
  800c18:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1b:	75 10                	jne    800c2d <strtol+0x5a>
  800c1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c21:	75 0a                	jne    800c2d <strtol+0x5a>
		s += 2, base = 16;
  800c23:	83 c2 02             	add    $0x2,%edx
  800c26:	b8 10 00 00 00       	mov    $0x10,%eax
  800c2b:	eb 10                	jmp    800c3d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	75 0c                	jne    800c3d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c31:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c33:	80 3a 30             	cmpb   $0x30,(%edx)
  800c36:	75 05                	jne    800c3d <strtol+0x6a>
		s++, base = 8;
  800c38:	83 c2 01             	add    $0x1,%edx
  800c3b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c45:	0f b6 0a             	movzbl (%edx),%ecx
  800c48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c4b:	89 f0                	mov    %esi,%eax
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	77 08                	ja     800c59 <strtol+0x86>
			dig = *s - '0';
  800c51:	0f be c9             	movsbl %cl,%ecx
  800c54:	83 e9 30             	sub    $0x30,%ecx
  800c57:	eb 20                	jmp    800c79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c5c:	89 f0                	mov    %esi,%eax
  800c5e:	3c 19                	cmp    $0x19,%al
  800c60:	77 08                	ja     800c6a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c62:	0f be c9             	movsbl %cl,%ecx
  800c65:	83 e9 57             	sub    $0x57,%ecx
  800c68:	eb 0f                	jmp    800c79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c6d:	89 f0                	mov    %esi,%eax
  800c6f:	3c 19                	cmp    $0x19,%al
  800c71:	77 16                	ja     800c89 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c73:	0f be c9             	movsbl %cl,%ecx
  800c76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c7c:	7d 0f                	jge    800c8d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c85:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c87:	eb bc                	jmp    800c45 <strtol+0x72>
  800c89:	89 d8                	mov    %ebx,%eax
  800c8b:	eb 02                	jmp    800c8f <strtol+0xbc>
  800c8d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c93:	74 05                	je     800c9a <strtol+0xc7>
		*endptr = (char *) s;
  800c95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c98:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c9a:	f7 d8                	neg    %eax
  800c9c:	85 ff                	test   %edi,%edi
  800c9e:	0f 44 c3             	cmove  %ebx,%eax
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 c3                	mov    %eax,%ebx
  800cb9:	89 c7                	mov    %eax,%edi
  800cbb:	89 c6                	mov    %eax,%esi
  800cbd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd4:	89 d1                	mov    %edx,%ecx
  800cd6:	89 d3                	mov    %edx,%ebx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 cb                	mov    %ecx,%ebx
  800cfb:	89 cf                	mov    %ecx,%edi
  800cfd:	89 ce                	mov    %ecx,%esi
  800cff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 28                	jle    800d2d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d09:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d10:	00 
  800d11:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800d18:	00 
  800d19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d20:	00 
  800d21:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800d28:	e8 d8 07 00 00       	call   801505 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2d:	83 c4 2c             	add    $0x2c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
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
  800d5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	b8 04 00 00 00       	mov    $0x4,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	89 f7                	mov    %esi,%edi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 28                	jle    800dbf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800da2:	00 
  800da3:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800daa:	00 
  800dab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db2:	00 
  800db3:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800dba:	e8 46 07 00 00       	call   801505 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dbf:	83 c4 2c             	add    $0x2c,%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de1:	8b 75 18             	mov    0x18(%ebp),%esi
  800de4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 28                	jle    800e12 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800df5:	00 
  800df6:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e05:	00 
  800e06:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800e0d:	e8 f3 06 00 00       	call   801505 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e12:	83 c4 2c             	add    $0x2c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e28:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	89 df                	mov    %ebx,%edi
  800e35:	89 de                	mov    %ebx,%esi
  800e37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 28                	jle    800e65 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e41:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800e60:	e8 a0 06 00 00       	call   801505 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e65:	83 c4 2c             	add    $0x2c,%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	89 df                	mov    %ebx,%edi
  800e88:	89 de                	mov    %ebx,%esi
  800e8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	7e 28                	jle    800eb8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eab:	00 
  800eac:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800eb3:	e8 4d 06 00 00       	call   801505 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb8:	83 c4 2c             	add    $0x2c,%esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ece:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 de                	mov    %ebx,%esi
  800edd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	7e 28                	jle    800f0b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eee:	00 
  800eef:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800ef6:	00 
  800ef7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efe:	00 
  800eff:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800f06:	e8 fa 05 00 00       	call   801505 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f0b:	83 c4 2c             	add    $0x2c,%esp
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f21:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800f34:	7e 28                	jle    800f5e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800f59:	e8 a7 05 00 00       	call   801505 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f5e:	83 c4 2c             	add    $0x2c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	be 00 00 00 00       	mov    $0x0,%esi
  800f71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9f:	89 cb                	mov    %ecx,%ebx
  800fa1:	89 cf                	mov    %ecx,%edi
  800fa3:	89 ce                	mov    %ecx,%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 28                	jle    800fd3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faf:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 08 7f 1c 80 	movl   $0x801c7f,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 9c 1c 80 00 	movl   $0x801c9c,(%esp)
  800fce:	e8 32 05 00 00       	call   801505 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fd3:	83 c4 2c             	add    $0x2c,%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 20             	sub    $0x20,%esp
  800fe3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  800fe6:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  800fe8:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  800fec:	75 3f                	jne    80102d <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800fee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff2:	c7 04 24 aa 1c 80 00 	movl   $0x801caa,(%esp)
  800ff9:	e8 e1 f2 ff ff       	call   8002df <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  800ffe:	8b 43 28             	mov    0x28(%ebx),%eax
  801001:	89 44 24 04          	mov    %eax,0x4(%esp)
  801005:	c7 04 24 ba 1c 80 00 	movl   $0x801cba,(%esp)
  80100c:	e8 ce f2 ff ff       	call   8002df <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801011:	c7 44 24 08 00 1d 80 	movl   $0x801d00,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801028:	e8 d8 04 00 00       	call   801505 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	c1 e8 0c             	shr    $0xc,%eax
  801032:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801039:	f6 c4 08             	test   $0x8,%ah
  80103c:	75 1c                	jne    80105a <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80103e:	c7 44 24 08 28 1d 80 	movl   $0x801d28,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801055:	e8 ab 04 00 00       	call   801505 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80105a:	e8 d6 fc ff ff       	call   800d35 <sys_getenvid>
  80105f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801066:	00 
  801067:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80106e:	00 
  80106f:	89 04 24             	mov    %eax,(%esp)
  801072:	e8 fc fc ff ff       	call   800d73 <sys_page_alloc>
  801077:	85 c0                	test   %eax,%eax
  801079:	79 1c                	jns    801097 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  80107b:	c7 44 24 08 48 1d 80 	movl   $0x801d48,0x8(%esp)
  801082:	00 
  801083:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801092:	e8 6e 04 00 00       	call   801505 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801097:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80109d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010a4:	00 
  8010a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010b0:	e8 a7 fa ff ff       	call   800b5c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8010b5:	e8 7b fc ff ff       	call   800d35 <sys_getenvid>
  8010ba:	89 c3                	mov    %eax,%ebx
  8010bc:	e8 74 fc ff ff       	call   800d35 <sys_getenvid>
  8010c1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010c8:	00 
  8010c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010d1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010d8:	00 
  8010d9:	89 04 24             	mov    %eax,(%esp)
  8010dc:	e8 e6 fc ff ff       	call   800dc7 <sys_page_map>
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 20                	jns    801105 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  8010e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e9:	c7 44 24 08 70 1d 80 	movl   $0x801d70,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801100:	e8 00 04 00 00       	call   801505 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801105:	e8 2b fc ff ff       	call   800d35 <sys_getenvid>
  80110a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801111:	00 
  801112:	89 04 24             	mov    %eax,(%esp)
  801115:	e8 00 fd ff ff       	call   800e1a <sys_page_unmap>
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 20                	jns    80113e <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80111e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801122:	c7 44 24 08 a0 1d 80 	movl   $0x801da0,0x8(%esp)
  801129:	00 
  80112a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801131:	00 
  801132:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801139:	e8 c7 03 00 00       	call   801505 <_panic>
	return;
}
  80113e:	83 c4 20             	add    $0x20,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80114e:	c7 04 24 db 0f 80 00 	movl   $0x800fdb,(%esp)
  801155:	e8 01 04 00 00       	call   80155b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80115a:	b8 07 00 00 00       	mov    $0x7,%eax
  80115f:	cd 30                	int    $0x30
  801161:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801164:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	79 20                	jns    80118b <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80116b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116f:	c7 44 24 08 d4 1d 80 	movl   $0x801dd4,0x8(%esp)
  801176:	00 
  801177:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80117e:	00 
  80117f:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801186:	e8 7a 03 00 00       	call   801505 <_panic>
	if(childEid == 0){
  80118b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80118f:	75 1c                	jne    8011ad <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801191:	e8 9f fb ff ff       	call   800d35 <sys_getenvid>
  801196:	25 ff 03 00 00       	and    $0x3ff,%eax
  80119b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a3:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return childEid;
  8011a8:	e9 a0 01 00 00       	jmp    80134d <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  8011ad:	c7 44 24 04 f1 15 80 	movl   $0x8015f1,0x4(%esp)
  8011b4:	00 
  8011b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b8:	89 04 24             	mov    %eax,(%esp)
  8011bb:	e8 53 fd ff ff       	call   800f13 <sys_env_set_pgfault_upcall>
  8011c0:	89 c7                	mov    %eax,%edi
	if(r < 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	79 20                	jns    8011e6 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  8011c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ca:	c7 44 24 08 08 1e 80 	movl   $0x801e08,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  8011e1:	e8 1f 03 00 00       	call   801505 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8011e6:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 16             	shr    $0x16,%edx
  8011fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	0f 84 f7 00 00 00    	je     801304 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80120d:	c1 e8 0c             	shr    $0xc,%eax
  801210:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801217:	f6 c2 04             	test   $0x4,%dl
  80121a:	0f 84 e4 00 00 00    	je     801304 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801220:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801227:	a8 01                	test   $0x1,%al
  801229:	0f 84 d5 00 00 00    	je     801304 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  80122f:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801235:	75 20                	jne    801257 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801237:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801246:	ee 
  801247:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80124a:	89 04 24             	mov    %eax,(%esp)
  80124d:	e8 21 fb ff ff       	call   800d73 <sys_page_alloc>
  801252:	e9 84 00 00 00       	jmp    8012db <fork+0x196>
  801257:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80125d:	89 f8                	mov    %edi,%eax
  80125f:	c1 e8 0c             	shr    $0xc,%eax
  801262:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801269:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80126e:	83 f8 01             	cmp    $0x1,%eax
  801271:	19 db                	sbb    %ebx,%ebx
  801273:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801279:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80127f:	e8 b1 fa ff ff       	call   800d35 <sys_getenvid>
  801284:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801288:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80128f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801293:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801297:	89 04 24             	mov    %eax,(%esp)
  80129a:	e8 28 fb ff ff       	call   800dc7 <sys_page_map>
  80129f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 35                	js     8012db <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  8012a6:	e8 8a fa ff ff       	call   800d35 <sys_getenvid>
  8012ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ae:	e8 82 fa ff ff       	call   800d35 <sys_getenvid>
  8012b3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012b7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 f9 fa ff ff       	call   800dc7 <sys_page_map>
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8012d5:	0f 4f c7             	cmovg  %edi,%eax
  8012d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  8012db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012df:	79 23                	jns    801304 <fork+0x1bf>
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8012e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012e8:	c7 44 24 08 48 1e 80 	movl   $0x801e48,0x8(%esp)
  8012ef:	00 
  8012f0:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8012f7:	00 
  8012f8:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  8012ff:	e8 01 02 00 00       	call   801505 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801304:	89 f1                	mov    %esi,%ecx
  801306:	89 f0                	mov    %esi,%eax
  801308:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80130e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801314:	0f 85 de fe ff ff    	jne    8011f8 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80131a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801321:	00 
  801322:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 40 fb ff ff       	call   800e6d <sys_env_set_status>
  80132d:	85 c0                	test   %eax,%eax
  80132f:	79 1c                	jns    80134d <fork+0x208>
		panic("sys_env_set_status");
  801331:	c7 44 24 08 d6 1c 80 	movl   $0x801cd6,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801348:	e8 b8 01 00 00       	call   801505 <_panic>
	return childEid;
}
  80134d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801350:	83 c4 2c             	add    $0x2c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <sfork>:

// Challenge!
int
sfork(void)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80135e:	c7 44 24 08 e9 1c 80 	movl   $0x801ce9,0x8(%esp)
  801365:	00 
  801366:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80136d:	00 
  80136e:	c7 04 24 cb 1c 80 00 	movl   $0x801ccb,(%esp)
  801375:	e8 8b 01 00 00       	call   801505 <_panic>
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 10             	sub    $0x10,%esp
  801388:	8b 75 08             	mov    0x8(%ebp),%esi
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801391:	85 c0                	test   %eax,%eax
  801393:	75 0e                	jne    8013a3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801395:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80139c:	e8 e8 fb ff ff       	call   800f89 <sys_ipc_recv>
  8013a1:	eb 08                	jmp    8013ab <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 de fb ff ff       	call   800f89 <sys_ipc_recv>
	if(r == 0){
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	75 1e                	jne    8013d0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8013b2:	85 f6                	test   %esi,%esi
  8013b4:	74 0a                	je     8013c0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8013b6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013bb:	8b 40 74             	mov    0x74(%eax),%eax
  8013be:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  8013c0:	85 db                	test   %ebx,%ebx
  8013c2:	74 2c                	je     8013f0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  8013c4:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013c9:	8b 40 78             	mov    0x78(%eax),%eax
  8013cc:	89 03                	mov    %eax,(%ebx)
  8013ce:	eb 20                	jmp    8013f0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8013d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d4:	c7 44 24 08 70 1e 80 	movl   $0x801e70,0x8(%esp)
  8013db:	00 
  8013dc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013e3:	00 
  8013e4:	c7 04 24 ec 1e 80 00 	movl   $0x801eec,(%esp)
  8013eb:	e8 15 01 00 00       	call   801505 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8013f0:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013f5:	8b 50 70             	mov    0x70(%eax),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	75 13                	jne    80140f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8013fc:	8b 40 48             	mov    0x48(%eax),%eax
  8013ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801403:	c7 04 24 a0 1e 80 00 	movl   $0x801ea0,(%esp)
  80140a:	e8 d0 ee ff ff       	call   8002df <cprintf>
	return thisenv->env_ipc_value;
  80140f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801414:	8b 40 70             	mov    0x70(%eax),%eax
}
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	83 ec 1c             	sub    $0x1c,%esp
  801427:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80142d:	85 f6                	test   %esi,%esi
  80142f:	75 22                	jne    801453 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801431:	8b 45 14             	mov    0x14(%ebp),%eax
  801434:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801438:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80143f:	ee 
  801440:	8b 45 0c             	mov    0xc(%ebp),%eax
  801443:	89 44 24 04          	mov    %eax,0x4(%esp)
  801447:	89 3c 24             	mov    %edi,(%esp)
  80144a:	e8 17 fb ff ff       	call   800f66 <sys_ipc_try_send>
  80144f:	89 c3                	mov    %eax,%ebx
  801451:	eb 1c                	jmp    80146f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801453:	8b 45 14             	mov    0x14(%ebp),%eax
  801456:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80145e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801461:	89 44 24 04          	mov    %eax,0x4(%esp)
  801465:	89 3c 24             	mov    %edi,(%esp)
  801468:	e8 f9 fa ff ff       	call   800f66 <sys_ipc_try_send>
  80146d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80146f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801472:	74 3e                	je     8014b2 <ipc_send+0x94>
  801474:	89 d8                	mov    %ebx,%eax
  801476:	c1 e8 1f             	shr    $0x1f,%eax
  801479:	84 c0                	test   %al,%al
  80147b:	74 35                	je     8014b2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80147d:	e8 b3 f8 ff ff       	call   800d35 <sys_getenvid>
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	c7 04 24 f6 1e 80 00 	movl   $0x801ef6,(%esp)
  80148d:	e8 4d ee ff ff       	call   8002df <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801492:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801496:	c7 44 24 08 c4 1e 80 	movl   $0x801ec4,0x8(%esp)
  80149d:	00 
  80149e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8014a5:	00 
  8014a6:	c7 04 24 ec 1e 80 00 	movl   $0x801eec,(%esp)
  8014ad:	e8 53 00 00 00       	call   801505 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8014b2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8014b5:	75 0e                	jne    8014c5 <ipc_send+0xa7>
			sys_yield();
  8014b7:	e8 98 f8 ff ff       	call   800d54 <sys_yield>
		else break;
	}
  8014bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c0:	e9 68 ff ff ff       	jmp    80142d <ipc_send+0xf>
	
}
  8014c5:	83 c4 1c             	add    $0x1c,%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014d8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8014db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014e1:	8b 52 50             	mov    0x50(%edx),%edx
  8014e4:	39 ca                	cmp    %ecx,%edx
  8014e6:	75 0d                	jne    8014f5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8014e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014eb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014f0:	8b 40 40             	mov    0x40(%eax),%eax
  8014f3:	eb 0e                	jmp    801503 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014f5:	83 c0 01             	add    $0x1,%eax
  8014f8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014fd:	75 d9                	jne    8014d8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014ff:	66 b8 00 00          	mov    $0x0,%ax
}
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	56                   	push   %esi
  801509:	53                   	push   %ebx
  80150a:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80150d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801510:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801516:	e8 1a f8 ff ff       	call   800d35 <sys_getenvid>
  80151b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80151e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801522:	8b 55 08             	mov    0x8(%ebp),%edx
  801525:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801529:	89 74 24 08          	mov    %esi,0x8(%esp)
  80152d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801531:	c7 04 24 08 1f 80 00 	movl   $0x801f08,(%esp)
  801538:	e8 a2 ed ff ff       	call   8002df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80153d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801541:	8b 45 10             	mov    0x10(%ebp),%eax
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	e8 32 ed ff ff       	call   80027e <vcprintf>
	cprintf("\n");
  80154c:	c7 04 24 d2 18 80 00 	movl   $0x8018d2,(%esp)
  801553:	e8 87 ed ff ff       	call   8002df <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801558:	cc                   	int3   
  801559:	eb fd                	jmp    801558 <_panic+0x53>

0080155b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801561:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801568:	75 44                	jne    8015ae <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80156a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80156f:	8b 40 48             	mov    0x48(%eax),%eax
  801572:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801579:	00 
  80157a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801581:	ee 
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	e8 e9 f7 ff ff       	call   800d73 <sys_page_alloc>
		if( r < 0)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	79 20                	jns    8015ae <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80158e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801592:	c7 44 24 08 2c 1f 80 	movl   $0x801f2c,0x8(%esp)
  801599:	00 
  80159a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015a1:	00 
  8015a2:	c7 04 24 88 1f 80 00 	movl   $0x801f88,(%esp)
  8015a9:	e8 57 ff ff ff       	call   801505 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	a3 10 20 80 00       	mov    %eax,0x802010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8015b6:	e8 7a f7 ff ff       	call   800d35 <sys_getenvid>
  8015bb:	c7 44 24 04 f1 15 80 	movl   $0x8015f1,0x4(%esp)
  8015c2:	00 
  8015c3:	89 04 24             	mov    %eax,(%esp)
  8015c6:	e8 48 f9 ff ff       	call   800f13 <sys_env_set_pgfault_upcall>
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 20                	jns    8015ef <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8015cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d3:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  8015da:	00 
  8015db:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8015e2:	00 
  8015e3:	c7 04 24 88 1f 80 00 	movl   $0x801f88,(%esp)
  8015ea:	e8 16 ff ff ff       	call   801505 <_panic>


}
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015f1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015f2:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8015f7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015f9:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8015fc:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  801600:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  801604:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  801608:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  80160b:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  80160e:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  801611:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  801615:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  801619:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  80161d:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801621:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801625:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  801629:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  80162d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  80162e:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  80162f:	c3                   	ret    

00801630 <__udivdi3>:
  801630:	55                   	push   %ebp
  801631:	57                   	push   %edi
  801632:	56                   	push   %esi
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	8b 44 24 28          	mov    0x28(%esp),%eax
  80163a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80163e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801642:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801646:	85 c0                	test   %eax,%eax
  801648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80164c:	89 ea                	mov    %ebp,%edx
  80164e:	89 0c 24             	mov    %ecx,(%esp)
  801651:	75 2d                	jne    801680 <__udivdi3+0x50>
  801653:	39 e9                	cmp    %ebp,%ecx
  801655:	77 61                	ja     8016b8 <__udivdi3+0x88>
  801657:	85 c9                	test   %ecx,%ecx
  801659:	89 ce                	mov    %ecx,%esi
  80165b:	75 0b                	jne    801668 <__udivdi3+0x38>
  80165d:	b8 01 00 00 00       	mov    $0x1,%eax
  801662:	31 d2                	xor    %edx,%edx
  801664:	f7 f1                	div    %ecx
  801666:	89 c6                	mov    %eax,%esi
  801668:	31 d2                	xor    %edx,%edx
  80166a:	89 e8                	mov    %ebp,%eax
  80166c:	f7 f6                	div    %esi
  80166e:	89 c5                	mov    %eax,%ebp
  801670:	89 f8                	mov    %edi,%eax
  801672:	f7 f6                	div    %esi
  801674:	89 ea                	mov    %ebp,%edx
  801676:	83 c4 0c             	add    $0xc,%esp
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    
  80167d:	8d 76 00             	lea    0x0(%esi),%esi
  801680:	39 e8                	cmp    %ebp,%eax
  801682:	77 24                	ja     8016a8 <__udivdi3+0x78>
  801684:	0f bd e8             	bsr    %eax,%ebp
  801687:	83 f5 1f             	xor    $0x1f,%ebp
  80168a:	75 3c                	jne    8016c8 <__udivdi3+0x98>
  80168c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801690:	39 34 24             	cmp    %esi,(%esp)
  801693:	0f 86 9f 00 00 00    	jbe    801738 <__udivdi3+0x108>
  801699:	39 d0                	cmp    %edx,%eax
  80169b:	0f 82 97 00 00 00    	jb     801738 <__udivdi3+0x108>
  8016a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8016a8:	31 d2                	xor    %edx,%edx
  8016aa:	31 c0                	xor    %eax,%eax
  8016ac:	83 c4 0c             	add    $0xc,%esp
  8016af:	5e                   	pop    %esi
  8016b0:	5f                   	pop    %edi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    
  8016b3:	90                   	nop
  8016b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b8:	89 f8                	mov    %edi,%eax
  8016ba:	f7 f1                	div    %ecx
  8016bc:	31 d2                	xor    %edx,%edx
  8016be:	83 c4 0c             	add    $0xc,%esp
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    
  8016c5:	8d 76 00             	lea    0x0(%esi),%esi
  8016c8:	89 e9                	mov    %ebp,%ecx
  8016ca:	8b 3c 24             	mov    (%esp),%edi
  8016cd:	d3 e0                	shl    %cl,%eax
  8016cf:	89 c6                	mov    %eax,%esi
  8016d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8016d6:	29 e8                	sub    %ebp,%eax
  8016d8:	89 c1                	mov    %eax,%ecx
  8016da:	d3 ef                	shr    %cl,%edi
  8016dc:	89 e9                	mov    %ebp,%ecx
  8016de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016e2:	8b 3c 24             	mov    (%esp),%edi
  8016e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8016e9:	89 d6                	mov    %edx,%esi
  8016eb:	d3 e7                	shl    %cl,%edi
  8016ed:	89 c1                	mov    %eax,%ecx
  8016ef:	89 3c 24             	mov    %edi,(%esp)
  8016f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8016f6:	d3 ee                	shr    %cl,%esi
  8016f8:	89 e9                	mov    %ebp,%ecx
  8016fa:	d3 e2                	shl    %cl,%edx
  8016fc:	89 c1                	mov    %eax,%ecx
  8016fe:	d3 ef                	shr    %cl,%edi
  801700:	09 d7                	or     %edx,%edi
  801702:	89 f2                	mov    %esi,%edx
  801704:	89 f8                	mov    %edi,%eax
  801706:	f7 74 24 08          	divl   0x8(%esp)
  80170a:	89 d6                	mov    %edx,%esi
  80170c:	89 c7                	mov    %eax,%edi
  80170e:	f7 24 24             	mull   (%esp)
  801711:	39 d6                	cmp    %edx,%esi
  801713:	89 14 24             	mov    %edx,(%esp)
  801716:	72 30                	jb     801748 <__udivdi3+0x118>
  801718:	8b 54 24 04          	mov    0x4(%esp),%edx
  80171c:	89 e9                	mov    %ebp,%ecx
  80171e:	d3 e2                	shl    %cl,%edx
  801720:	39 c2                	cmp    %eax,%edx
  801722:	73 05                	jae    801729 <__udivdi3+0xf9>
  801724:	3b 34 24             	cmp    (%esp),%esi
  801727:	74 1f                	je     801748 <__udivdi3+0x118>
  801729:	89 f8                	mov    %edi,%eax
  80172b:	31 d2                	xor    %edx,%edx
  80172d:	e9 7a ff ff ff       	jmp    8016ac <__udivdi3+0x7c>
  801732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801738:	31 d2                	xor    %edx,%edx
  80173a:	b8 01 00 00 00       	mov    $0x1,%eax
  80173f:	e9 68 ff ff ff       	jmp    8016ac <__udivdi3+0x7c>
  801744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801748:	8d 47 ff             	lea    -0x1(%edi),%eax
  80174b:	31 d2                	xor    %edx,%edx
  80174d:	83 c4 0c             	add    $0xc,%esp
  801750:	5e                   	pop    %esi
  801751:	5f                   	pop    %edi
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    
  801754:	66 90                	xchg   %ax,%ax
  801756:	66 90                	xchg   %ax,%ax
  801758:	66 90                	xchg   %ax,%ax
  80175a:	66 90                	xchg   %ax,%ax
  80175c:	66 90                	xchg   %ax,%ax
  80175e:	66 90                	xchg   %ax,%ax

00801760 <__umoddi3>:
  801760:	55                   	push   %ebp
  801761:	57                   	push   %edi
  801762:	56                   	push   %esi
  801763:	83 ec 14             	sub    $0x14,%esp
  801766:	8b 44 24 28          	mov    0x28(%esp),%eax
  80176a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80176e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801772:	89 c7                	mov    %eax,%edi
  801774:	89 44 24 04          	mov    %eax,0x4(%esp)
  801778:	8b 44 24 30          	mov    0x30(%esp),%eax
  80177c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801780:	89 34 24             	mov    %esi,(%esp)
  801783:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801787:	85 c0                	test   %eax,%eax
  801789:	89 c2                	mov    %eax,%edx
  80178b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80178f:	75 17                	jne    8017a8 <__umoddi3+0x48>
  801791:	39 fe                	cmp    %edi,%esi
  801793:	76 4b                	jbe    8017e0 <__umoddi3+0x80>
  801795:	89 c8                	mov    %ecx,%eax
  801797:	89 fa                	mov    %edi,%edx
  801799:	f7 f6                	div    %esi
  80179b:	89 d0                	mov    %edx,%eax
  80179d:	31 d2                	xor    %edx,%edx
  80179f:	83 c4 14             	add    $0x14,%esp
  8017a2:	5e                   	pop    %esi
  8017a3:	5f                   	pop    %edi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    
  8017a6:	66 90                	xchg   %ax,%ax
  8017a8:	39 f8                	cmp    %edi,%eax
  8017aa:	77 54                	ja     801800 <__umoddi3+0xa0>
  8017ac:	0f bd e8             	bsr    %eax,%ebp
  8017af:	83 f5 1f             	xor    $0x1f,%ebp
  8017b2:	75 5c                	jne    801810 <__umoddi3+0xb0>
  8017b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8017b8:	39 3c 24             	cmp    %edi,(%esp)
  8017bb:	0f 87 e7 00 00 00    	ja     8018a8 <__umoddi3+0x148>
  8017c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017c5:	29 f1                	sub    %esi,%ecx
  8017c7:	19 c7                	sbb    %eax,%edi
  8017c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8017d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8017d9:	83 c4 14             	add    $0x14,%esp
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    
  8017e0:	85 f6                	test   %esi,%esi
  8017e2:	89 f5                	mov    %esi,%ebp
  8017e4:	75 0b                	jne    8017f1 <__umoddi3+0x91>
  8017e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8017eb:	31 d2                	xor    %edx,%edx
  8017ed:	f7 f6                	div    %esi
  8017ef:	89 c5                	mov    %eax,%ebp
  8017f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8017f5:	31 d2                	xor    %edx,%edx
  8017f7:	f7 f5                	div    %ebp
  8017f9:	89 c8                	mov    %ecx,%eax
  8017fb:	f7 f5                	div    %ebp
  8017fd:	eb 9c                	jmp    80179b <__umoddi3+0x3b>
  8017ff:	90                   	nop
  801800:	89 c8                	mov    %ecx,%eax
  801802:	89 fa                	mov    %edi,%edx
  801804:	83 c4 14             	add    $0x14,%esp
  801807:	5e                   	pop    %esi
  801808:	5f                   	pop    %edi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    
  80180b:	90                   	nop
  80180c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801810:	8b 04 24             	mov    (%esp),%eax
  801813:	be 20 00 00 00       	mov    $0x20,%esi
  801818:	89 e9                	mov    %ebp,%ecx
  80181a:	29 ee                	sub    %ebp,%esi
  80181c:	d3 e2                	shl    %cl,%edx
  80181e:	89 f1                	mov    %esi,%ecx
  801820:	d3 e8                	shr    %cl,%eax
  801822:	89 e9                	mov    %ebp,%ecx
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	8b 04 24             	mov    (%esp),%eax
  80182b:	09 54 24 04          	or     %edx,0x4(%esp)
  80182f:	89 fa                	mov    %edi,%edx
  801831:	d3 e0                	shl    %cl,%eax
  801833:	89 f1                	mov    %esi,%ecx
  801835:	89 44 24 08          	mov    %eax,0x8(%esp)
  801839:	8b 44 24 10          	mov    0x10(%esp),%eax
  80183d:	d3 ea                	shr    %cl,%edx
  80183f:	89 e9                	mov    %ebp,%ecx
  801841:	d3 e7                	shl    %cl,%edi
  801843:	89 f1                	mov    %esi,%ecx
  801845:	d3 e8                	shr    %cl,%eax
  801847:	89 e9                	mov    %ebp,%ecx
  801849:	09 f8                	or     %edi,%eax
  80184b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80184f:	f7 74 24 04          	divl   0x4(%esp)
  801853:	d3 e7                	shl    %cl,%edi
  801855:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801859:	89 d7                	mov    %edx,%edi
  80185b:	f7 64 24 08          	mull   0x8(%esp)
  80185f:	39 d7                	cmp    %edx,%edi
  801861:	89 c1                	mov    %eax,%ecx
  801863:	89 14 24             	mov    %edx,(%esp)
  801866:	72 2c                	jb     801894 <__umoddi3+0x134>
  801868:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80186c:	72 22                	jb     801890 <__umoddi3+0x130>
  80186e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801872:	29 c8                	sub    %ecx,%eax
  801874:	19 d7                	sbb    %edx,%edi
  801876:	89 e9                	mov    %ebp,%ecx
  801878:	89 fa                	mov    %edi,%edx
  80187a:	d3 e8                	shr    %cl,%eax
  80187c:	89 f1                	mov    %esi,%ecx
  80187e:	d3 e2                	shl    %cl,%edx
  801880:	89 e9                	mov    %ebp,%ecx
  801882:	d3 ef                	shr    %cl,%edi
  801884:	09 d0                	or     %edx,%eax
  801886:	89 fa                	mov    %edi,%edx
  801888:	83 c4 14             	add    $0x14,%esp
  80188b:	5e                   	pop    %esi
  80188c:	5f                   	pop    %edi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    
  80188f:	90                   	nop
  801890:	39 d7                	cmp    %edx,%edi
  801892:	75 da                	jne    80186e <__umoddi3+0x10e>
  801894:	8b 14 24             	mov    (%esp),%edx
  801897:	89 c1                	mov    %eax,%ecx
  801899:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80189d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8018a1:	eb cb                	jmp    80186e <__umoddi3+0x10e>
  8018a3:	90                   	nop
  8018a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8018ac:	0f 82 0f ff ff ff    	jb     8017c1 <__umoddi3+0x61>
  8018b2:	e9 1a ff ff ff       	jmp    8017d1 <__umoddi3+0x71>
