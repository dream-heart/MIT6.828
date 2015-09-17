
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
  800039:	e8 3a 0f 00 00       	call   800f78 <fork>
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
  80005f:	e8 58 0f 00 00       	call   800fbc <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800064:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006b:	00 
  80006c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800073:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  80007a:	e8 4d 02 00 00       	call   8002cc <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80007f:	a1 04 20 80 00       	mov    0x802004,%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 84 08 00 00       	call   800910 <strlen>
  80008c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800090:	a1 04 20 80 00       	mov    0x802004,%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a0:	e8 7d 09 00 00       	call   800a22 <strncmp>
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 0c                	jne    8000b5 <umain+0x82>
			cprintf("child received correct message\n");
  8000a9:	c7 04 24 34 13 80 00 	movl   $0x801334,(%esp)
  8000b0:	e8 17 02 00 00       	call   8002cc <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b5:	a1 00 20 80 00       	mov    0x802000,%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 4e 08 00 00       	call   800910 <strlen>
  8000c2:	83 c0 01             	add    $0x1,%eax
  8000c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c9:	a1 00 20 80 00       	mov    0x802000,%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d9:	e8 6e 0a 00 00       	call   800b4c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f5:	00 
  8000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f9:	89 04 24             	mov    %eax,(%esp)
  8000fc:	e8 dd 0e 00 00       	call   800fde <ipc_send>
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
  800121:	e8 3d 0c 00 00       	call   800d63 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800126:	a1 04 20 80 00       	mov    0x802004,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 dd 07 00 00       	call   800910 <strlen>
  800133:	83 c0 01             	add    $0x1,%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	a1 04 20 80 00       	mov    0x802004,%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014a:	e8 fd 09 00 00       	call   800b4c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800166:	00 
  800167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 6c 0e 00 00       	call   800fde <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800172:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800179:	00 
  80017a:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800181:	00 
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 2f 0e 00 00       	call   800fbc <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018d:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800194:	00 
  800195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  8001a3:	e8 24 01 00 00       	call   8002cc <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a8:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 5b 07 00 00       	call   800910 <strlen>
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	a1 00 20 80 00       	mov    0x802000,%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c9:	e8 54 08 00 00       	call   800a22 <strncmp>
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 0c                	jne    8001de <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d2:	c7 04 24 54 13 80 00 	movl   $0x801354,(%esp)
  8001d9:	e8 ee 00 00 00       	call   8002cc <cprintf>
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
  8001e3:	83 ec 18             	sub    $0x18,%esp
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001ec:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8001f3:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 08                	jle    800202 <libmain+0x22>
		binaryname = argv[0];
  8001fa:	8b 0a                	mov    (%edx),%ecx
  8001fc:	89 0d 08 20 80 00    	mov    %ecx,0x802008

	// call user main routine
	umain(argc, argv);
  800202:	89 54 24 04          	mov    %edx,0x4(%esp)
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	e8 25 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020e:	e8 02 00 00 00       	call   800215 <exit>
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 ac 0a 00 00       	call   800cd3 <sys_env_destroy>
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	53                   	push   %ebx
  80022d:	83 ec 14             	sub    $0x14,%esp
  800230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800233:	8b 13                	mov    (%ebx),%edx
  800235:	8d 42 01             	lea    0x1(%edx),%eax
  800238:	89 03                	mov    %eax,(%ebx)
  80023a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800241:	3d ff 00 00 00       	cmp    $0xff,%eax
  800246:	75 19                	jne    800261 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800248:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80024f:	00 
  800250:	8d 43 08             	lea    0x8(%ebx),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 3b 0a 00 00       	call   800c96 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800261:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	5b                   	pop    %ebx
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800274:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027b:	00 00 00 
	b.cnt = 0;
  80027e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800285:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	89 44 24 08          	mov    %eax,0x8(%esp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	c7 04 24 29 02 80 00 	movl   $0x800229,(%esp)
  8002a7:	e8 78 01 00 00       	call   800424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002bc:	89 04 24             	mov    %eax,(%esp)
  8002bf:	e8 d2 09 00 00       	call   800c96 <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 87 ff ff ff       	call   80026b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
  8002e6:	66 90                	xchg   %ax,%ax
  8002e8:	66 90                	xchg   %ax,%ax
  8002ea:	66 90                	xchg   %ax,%ax
  8002ec:	66 90                	xchg   %ax,%ax
  8002ee:	66 90                	xchg   %ax,%ax

008002f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 3c             	sub    $0x3c,%esp
  8002f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fc:	89 d7                	mov    %edx,%edi
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	89 c3                	mov    %eax,%ebx
  800309:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80031d:	39 d9                	cmp    %ebx,%ecx
  80031f:	72 05                	jb     800326 <printnum+0x36>
  800321:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800324:	77 69                	ja     80038f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800326:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800329:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80032d:	83 ee 01             	sub    $0x1,%esi
  800330:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	8b 44 24 08          	mov    0x8(%esp),%eax
  80033c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800340:	89 c3                	mov    %eax,%ebx
  800342:	89 d6                	mov    %edx,%esi
  800344:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800347:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80034a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80034e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	89 04 24             	mov    %eax,(%esp)
  800358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	e8 2c 0d 00 00       	call   801090 <__udivdi3>
  800364:	89 d9                	mov    %ebx,%ecx
  800366:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80036a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	89 54 24 04          	mov    %edx,0x4(%esp)
  800375:	89 fa                	mov    %edi,%edx
  800377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037a:	e8 71 ff ff ff       	call   8002f0 <printnum>
  80037f:	eb 1b                	jmp    80039c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800381:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800385:	8b 45 18             	mov    0x18(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff d3                	call   *%ebx
  80038d:	eb 03                	jmp    800392 <printnum+0xa2>
  80038f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800392:	83 ee 01             	sub    $0x1,%esi
  800395:	85 f6                	test   %esi,%esi
  800397:	7f e8                	jg     800381 <printnum+0x91>
  800399:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b5:	89 04 24             	mov    %eax,(%esp)
  8003b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bf:	e8 fc 0d 00 00       	call   8011c0 <__umoddi3>
  8003c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c8:	0f be 80 cc 13 80 00 	movsbl 0x8013cc(%eax),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d5:	ff d0                	call   *%eax
}
  8003d7:	83 c4 3c             	add    $0x3c,%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5e                   	pop    %esi
  8003dc:	5f                   	pop    %edi
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	88 02                	mov    %al,(%edx)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800402:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800405:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800409:	8b 45 10             	mov    0x10(%ebp),%eax
  80040c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
  800413:	89 44 24 04          	mov    %eax,0x4(%esp)
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 02 00 00 00       	call   800424 <vprintfmt>
	va_end(ap);
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 3c             	sub    $0x3c,%esp
  80042d:	8b 75 08             	mov    0x8(%ebp),%esi
  800430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800433:	8b 7d 10             	mov    0x10(%ebp),%edi
  800436:	eb 11                	jmp    800449 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800438:	85 c0                	test   %eax,%eax
  80043a:	0f 84 48 04 00 00    	je     800888 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800440:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	83 c7 01             	add    $0x1,%edi
  80044c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800450:	83 f8 25             	cmp    $0x25,%eax
  800453:	75 e3                	jne    800438 <vprintfmt+0x14>
  800455:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800459:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80046e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800473:	eb 1f                	jmp    800494 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80047c:	eb 16                	jmp    800494 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800481:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800485:	eb 0d                	jmp    800494 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800487:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8d 47 01             	lea    0x1(%edi),%eax
  800497:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049a:	0f b6 17             	movzbl (%edi),%edx
  80049d:	0f b6 c2             	movzbl %dl,%eax
  8004a0:	83 ea 23             	sub    $0x23,%edx
  8004a3:	80 fa 55             	cmp    $0x55,%dl
  8004a6:	0f 87 bf 03 00 00    	ja     80086b <vprintfmt+0x447>
  8004ac:	0f b6 d2             	movzbl %dl,%edx
  8004af:	ff 24 95 a0 14 80 00 	jmp    *0x8014a0(,%edx,4)
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004c4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004c8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8004cb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ce:	83 f9 09             	cmp    $0x9,%ecx
  8004d1:	77 3c                	ja     80050f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d6:	eb e9                	jmp    8004c1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 40 04             	lea    0x4(%eax),%eax
  8004e6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ec:	eb 27                	jmp    800515 <vprintfmt+0xf1>
  8004ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f1:	85 d2                	test   %edx,%edx
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	0f 49 c2             	cmovns %edx,%eax
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	eb 91                	jmp    800494 <vprintfmt+0x70>
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800506:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80050d:	eb 85                	jmp    800494 <vprintfmt+0x70>
  80050f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800512:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800515:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800519:	0f 89 75 ff ff ff    	jns    800494 <vprintfmt+0x70>
  80051f:	e9 63 ff ff ff       	jmp    800487 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800524:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80052a:	e9 65 ff ff ff       	jmp    800494 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800532:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800536:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800544:	e9 00 ff ff ff       	jmp    800449 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	99                   	cltd   
  800553:	31 d0                	xor    %edx,%eax
  800555:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800557:	83 f8 09             	cmp    $0x9,%eax
  80055a:	7f 0b                	jg     800567 <vprintfmt+0x143>
  80055c:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800563:	85 d2                	test   %edx,%edx
  800565:	75 20                	jne    800587 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800567:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056b:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800572:	00 
  800573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800577:	89 34 24             	mov    %esi,(%esp)
  80057a:	e8 7d fe ff ff       	call   8003fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800582:	e9 c2 fe ff ff       	jmp    800449 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800587:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80058b:	c7 44 24 08 ed 13 80 	movl   $0x8013ed,0x8(%esp)
  800592:	00 
  800593:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800597:	89 34 24             	mov    %esi,(%esp)
  80059a:	e8 5d fe ff ff       	call   8003fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a2:	e9 a2 fe ff ff       	jmp    800449 <vprintfmt+0x25>
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	b8 dd 13 80 00       	mov    $0x8013dd,%eax
  8005c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005c7:	0f 84 92 00 00 00    	je     80065f <vprintfmt+0x23b>
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	0f 8e 98 00 00 00    	jle    80066d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	e8 47 03 00 00       	call   800928 <strnlen>
  8005e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005e4:	29 c1                	sub    %eax,%ecx
  8005e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8005e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f5:	eb 0f                	jmp    800606 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8005f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	83 ef 01             	sub    $0x1,%edi
  800606:	85 ff                	test   %edi,%edi
  800608:	7f ed                	jg     8005f7 <vprintfmt+0x1d3>
  80060a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80060d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800610:	85 c9                	test   %ecx,%ecx
  800612:	b8 00 00 00 00       	mov    $0x0,%eax
  800617:	0f 49 c1             	cmovns %ecx,%eax
  80061a:	29 c1                	sub    %eax,%ecx
  80061c:	89 75 08             	mov    %esi,0x8(%ebp)
  80061f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800622:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800625:	89 cb                	mov    %ecx,%ebx
  800627:	eb 50                	jmp    800679 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062d:	74 1e                	je     80064d <vprintfmt+0x229>
  80062f:	0f be d2             	movsbl %dl,%edx
  800632:	83 ea 20             	sub    $0x20,%edx
  800635:	83 fa 5e             	cmp    $0x5e,%edx
  800638:	76 13                	jbe    80064d <vprintfmt+0x229>
					putch('?', putdat);
  80063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
  80064b:	eb 0d                	jmp    80065a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80064d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800650:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	83 eb 01             	sub    $0x1,%ebx
  80065d:	eb 1a                	jmp    800679 <vprintfmt+0x255>
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800668:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066b:	eb 0c                	jmp    800679 <vprintfmt+0x255>
  80066d:	89 75 08             	mov    %esi,0x8(%ebp)
  800670:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800673:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800676:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800679:	83 c7 01             	add    $0x1,%edi
  80067c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800680:	0f be c2             	movsbl %dl,%eax
  800683:	85 c0                	test   %eax,%eax
  800685:	74 25                	je     8006ac <vprintfmt+0x288>
  800687:	85 f6                	test   %esi,%esi
  800689:	78 9e                	js     800629 <vprintfmt+0x205>
  80068b:	83 ee 01             	sub    $0x1,%esi
  80068e:	79 99                	jns    800629 <vprintfmt+0x205>
  800690:	89 df                	mov    %ebx,%edi
  800692:	8b 75 08             	mov    0x8(%ebp),%esi
  800695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800698:	eb 1a                	jmp    8006b4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a7:	83 ef 01             	sub    $0x1,%edi
  8006aa:	eb 08                	jmp    8006b4 <vprintfmt+0x290>
  8006ac:	89 df                	mov    %ebx,%edi
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	7f e2                	jg     80069a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 89 fd ff ff       	jmp    800449 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 f9 01             	cmp    $0x1,%ecx
  8006c3:	7e 19                	jle    8006de <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 50 04             	mov    0x4(%eax),%edx
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 40 08             	lea    0x8(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dc:	eb 38                	jmp    800716 <vprintfmt+0x2f2>
	else if (lflag)
  8006de:	85 c9                	test   %ecx,%ecx
  8006e0:	74 1b                	je     8006fd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 c1                	mov    %eax,%ecx
  8006ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fb:	eb 19                	jmp    800716 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800716:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800719:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800721:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800725:	0f 89 04 01 00 00    	jns    80082f <vprintfmt+0x40b>
				putch('-', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800736:	ff d6                	call   *%esi
				num = -(long long) num;
  800738:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80073b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80073e:	f7 da                	neg    %edx
  800740:	83 d1 00             	adc    $0x0,%ecx
  800743:	f7 d9                	neg    %ecx
  800745:	e9 e5 00 00 00       	jmp    80082f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074a:	83 f9 01             	cmp    $0x1,%ecx
  80074d:	7e 10                	jle    80075f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	8b 48 04             	mov    0x4(%eax),%ecx
  800757:	8d 40 08             	lea    0x8(%eax),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
  80075d:	eb 26                	jmp    800785 <vprintfmt+0x361>
	else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 12                	je     800775 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 10                	mov    (%eax),%edx
  800768:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
  800773:	eb 10                	jmp    800785 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 10                	mov    (%eax),%edx
  80077a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077f:	8d 40 04             	lea    0x4(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800785:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80078a:	e9 a0 00 00 00       	jmp    80082f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80078f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800793:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80079a:	ff d6                	call   *%esi
			putch('X', putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007a7:	ff d6                	call   *%esi
			putch('X', putdat);
  8007a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ad:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007b4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007b9:	e9 8b fc ff ff       	jmp    800449 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8007be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007d6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8007e2:	8d 40 04             	lea    0x4(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8007ed:	eb 40                	jmp    80082f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ef:	83 f9 01             	cmp    $0x1,%ecx
  8007f2:	7e 10                	jle    800804 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007fc:	8d 40 08             	lea    0x8(%eax),%eax
  8007ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800802:	eb 26                	jmp    80082a <vprintfmt+0x406>
	else if (lflag)
  800804:	85 c9                	test   %ecx,%ecx
  800806:	74 12                	je     80081a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800812:	8d 40 04             	lea    0x4(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
  800818:	eb 10                	jmp    80082a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80082a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80082f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800833:	89 44 24 10          	mov    %eax,0x10(%esp)
  800837:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80083a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800842:	89 14 24             	mov    %edx,(%esp)
  800845:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800849:	89 da                	mov    %ebx,%edx
  80084b:	89 f0                	mov    %esi,%eax
  80084d:	e8 9e fa ff ff       	call   8002f0 <printnum>
			break;
  800852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800855:	e9 ef fb ff ff       	jmp    800449 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	89 04 24             	mov    %eax,(%esp)
  800861:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800866:	e9 de fb ff ff       	jmp    800449 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800876:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800878:	eb 03                	jmp    80087d <vprintfmt+0x459>
  80087a:	83 ef 01             	sub    $0x1,%edi
  80087d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800881:	75 f7                	jne    80087a <vprintfmt+0x456>
  800883:	e9 c1 fb ff ff       	jmp    800449 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800888:	83 c4 3c             	add    $0x3c,%esp
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 28             	sub    $0x28,%esp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	74 30                	je     8008e1 <vsnprintf+0x51>
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	7e 2c                	jle    8008e1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ca:	c7 04 24 df 03 80 00 	movl   $0x8003df,(%esp)
  8008d1:	e8 4e fb ff ff       	call   800424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	eb 05                	jmp    8008e6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	e8 82 ff ff ff       	call   800890 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strlen+0x10>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800920:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800924:	75 f7                	jne    80091d <strlen+0xd>
		n++;
	return n;
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	eb 03                	jmp    80093b <strnlen+0x13>
		n++;
  800938:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	74 06                	je     800945 <strnlen+0x1d>
  80093f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800943:	75 f3                	jne    800938 <strnlen+0x10>
		n++;
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800951:	89 c2                	mov    %eax,%edx
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800960:	84 db                	test   %bl,%bl
  800962:	75 ef                	jne    800953 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800964:	5b                   	pop    %ebx
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	89 1c 24             	mov    %ebx,(%esp)
  800974:	e8 97 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800980:	01 d8                	add    %ebx,%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 bd ff ff ff       	call   800947 <strcpy>
	return dst;
}
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	83 c4 08             	add    $0x8,%esp
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 75 08             	mov    0x8(%ebp),%esi
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099d:	89 f3                	mov    %esi,%ebx
  80099f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a2:	89 f2                	mov    %esi,%edx
  8009a4:	eb 0f                	jmp    8009b5 <strncpy+0x23>
		*dst++ = *src;
  8009a6:	83 c2 01             	add    $0x1,%edx
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009af:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b5:	39 da                	cmp    %ebx,%edx
  8009b7:	75 ed                	jne    8009a6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009cd:	89 f0                	mov    %esi,%eax
  8009cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	75 0b                	jne    8009e2 <strlcpy+0x23>
  8009d7:	eb 1d                	jmp    8009f6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e2:	39 d8                	cmp    %ebx,%eax
  8009e4:	74 0b                	je     8009f1 <strlcpy+0x32>
  8009e6:	0f b6 0a             	movzbl (%edx),%ecx
  8009e9:	84 c9                	test   %cl,%cl
  8009eb:	75 ec                	jne    8009d9 <strlcpy+0x1a>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	eb 02                	jmp    8009f3 <strlcpy+0x34>
  8009f1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009f3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f6:	29 f0                	sub    %esi,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a05:	eb 06                	jmp    800a0d <strcmp+0x11>
		p++, q++;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	84 c0                	test   %al,%al
  800a12:	74 04                	je     800a18 <strcmp+0x1c>
  800a14:	3a 02                	cmp    (%edx),%al
  800a16:	74 ef                	je     800a07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 c0             	movzbl %al,%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a31:	eb 06                	jmp    800a39 <strncmp+0x17>
		n--, p++, q++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a39:	39 d8                	cmp    %ebx,%eax
  800a3b:	74 15                	je     800a52 <strncmp+0x30>
  800a3d:	0f b6 08             	movzbl (%eax),%ecx
  800a40:	84 c9                	test   %cl,%cl
  800a42:	74 04                	je     800a48 <strncmp+0x26>
  800a44:	3a 0a                	cmp    (%edx),%cl
  800a46:	74 eb                	je     800a33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
  800a50:	eb 05                	jmp    800a57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a64:	eb 07                	jmp    800a6d <strchr+0x13>
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	74 0f                	je     800a79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f2                	jne    800a66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	eb 07                	jmp    800a8e <strfind+0x13>
		if (*s == c)
  800a87:	38 ca                	cmp    %cl,%dl
  800a89:	74 0a                	je     800a95 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	84 d2                	test   %dl,%dl
  800a93:	75 f2                	jne    800a87 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa3:	85 c9                	test   %ecx,%ecx
  800aa5:	74 36                	je     800add <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aad:	75 28                	jne    800ad7 <memset+0x40>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 23                	jne    800ad7 <memset+0x40>
		c &= 0xFF;
  800ab4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	c1 e3 08             	shl    $0x8,%ebx
  800abd:	89 d6                	mov    %edx,%esi
  800abf:	c1 e6 18             	shl    $0x18,%esi
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	c1 e0 10             	shl    $0x10,%eax
  800ac7:	09 f0                	or     %esi,%eax
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	89 d0                	mov    %edx,%eax
  800acd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad2:	fc                   	cld    
  800ad3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad5:	eb 06                	jmp    800add <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	fc                   	cld    
  800adb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800add:	89 f8                	mov    %edi,%eax
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af2:	39 c6                	cmp    %eax,%esi
  800af4:	73 35                	jae    800b2b <memmove+0x47>
  800af6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af9:	39 d0                	cmp    %edx,%eax
  800afb:	73 2e                	jae    800b2b <memmove+0x47>
		s += n;
		d += n;
  800afd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0a:	75 13                	jne    800b1f <memmove+0x3b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 0e                	jne    800b1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 09                	jmp    800b28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1f:	83 ef 01             	sub    $0x1,%edi
  800b22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b25:	fd                   	std    
  800b26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b28:	fc                   	cld    
  800b29:	eb 1d                	jmp    800b48 <memmove+0x64>
  800b2b:	89 f2                	mov    %esi,%edx
  800b2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	f6 c2 03             	test   $0x3,%dl
  800b32:	75 0f                	jne    800b43 <memmove+0x5f>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0a                	jne    800b43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b39:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b3c:	89 c7                	mov    %eax,%edi
  800b3e:	fc                   	cld    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b41:	eb 05                	jmp    800b48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	fc                   	cld    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 79 ff ff ff       	call   800ae4 <memmove>
}
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7d:	eb 1a                	jmp    800b99 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7f:	0f b6 02             	movzbl (%edx),%eax
  800b82:	0f b6 19             	movzbl (%ecx),%ebx
  800b85:	38 d8                	cmp    %bl,%al
  800b87:	74 0a                	je     800b93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b89:	0f b6 c0             	movzbl %al,%eax
  800b8c:	0f b6 db             	movzbl %bl,%ebx
  800b8f:	29 d8                	sub    %ebx,%eax
  800b91:	eb 0f                	jmp    800ba2 <memcmp+0x35>
		s1++, s2++;
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b99:	39 f2                	cmp    %esi,%edx
  800b9b:	75 e2                	jne    800b7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb4:	eb 07                	jmp    800bbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb6:	38 08                	cmp    %cl,(%eax)
  800bb8:	74 07                	je     800bc1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	72 f5                	jb     800bb6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcf:	eb 03                	jmp    800bd4 <strtol+0x11>
		s++;
  800bd1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd4:	0f b6 0a             	movzbl (%edx),%ecx
  800bd7:	80 f9 09             	cmp    $0x9,%cl
  800bda:	74 f5                	je     800bd1 <strtol+0xe>
  800bdc:	80 f9 20             	cmp    $0x20,%cl
  800bdf:	74 f0                	je     800bd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be1:	80 f9 2b             	cmp    $0x2b,%cl
  800be4:	75 0a                	jne    800bf0 <strtol+0x2d>
		s++;
  800be6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bee:	eb 11                	jmp    800c01 <strtol+0x3e>
  800bf0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf5:	80 f9 2d             	cmp    $0x2d,%cl
  800bf8:	75 07                	jne    800c01 <strtol+0x3e>
		s++, neg = 1;
  800bfa:	8d 52 01             	lea    0x1(%edx),%edx
  800bfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800c06:	75 15                	jne    800c1d <strtol+0x5a>
  800c08:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0b:	75 10                	jne    800c1d <strtol+0x5a>
  800c0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c11:	75 0a                	jne    800c1d <strtol+0x5a>
		s += 2, base = 16;
  800c13:	83 c2 02             	add    $0x2,%edx
  800c16:	b8 10 00 00 00       	mov    $0x10,%eax
  800c1b:	eb 10                	jmp    800c2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	75 0c                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c21:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c23:	80 3a 30             	cmpb   $0x30,(%edx)
  800c26:	75 05                	jne    800c2d <strtol+0x6a>
		s++, base = 8;
  800c28:	83 c2 01             	add    $0x1,%edx
  800c2b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c35:	0f b6 0a             	movzbl (%edx),%ecx
  800c38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	3c 09                	cmp    $0x9,%al
  800c3f:	77 08                	ja     800c49 <strtol+0x86>
			dig = *s - '0';
  800c41:	0f be c9             	movsbl %cl,%ecx
  800c44:	83 e9 30             	sub    $0x30,%ecx
  800c47:	eb 20                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800c49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c4c:	89 f0                	mov    %esi,%eax
  800c4e:	3c 19                	cmp    $0x19,%al
  800c50:	77 08                	ja     800c5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800c52:	0f be c9             	movsbl %cl,%ecx
  800c55:	83 e9 57             	sub    $0x57,%ecx
  800c58:	eb 0f                	jmp    800c69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800c5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	3c 19                	cmp    $0x19,%al
  800c61:	77 16                	ja     800c79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800c63:	0f be c9             	movsbl %cl,%ecx
  800c66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800c6c:	7d 0f                	jge    800c7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800c75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800c77:	eb bc                	jmp    800c35 <strtol+0x72>
  800c79:	89 d8                	mov    %ebx,%eax
  800c7b:	eb 02                	jmp    800c7f <strtol+0xbc>
  800c7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800c7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c83:	74 05                	je     800c8a <strtol+0xc7>
		*endptr = (char *) s;
  800c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c8a:	f7 d8                	neg    %eax
  800c8c:	85 ff                	test   %edi,%edi
  800c8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	89 c7                	mov    %eax,%edi
  800cab:	89 c6                	mov    %eax,%esi
  800cad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 d7                	mov    %edx,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	89 cb                	mov    %ecx,%ebx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	89 ce                	mov    %ecx,%esi
  800cef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 28                	jle    800d1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d00:	00 
  800d01:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800d08:	00 
  800d09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d10:	00 
  800d11:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800d18:	e8 1b 03 00 00       	call   801038 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1d:	83 c4 2c             	add    $0x2c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 02 00 00 00       	mov    $0x2,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_yield>:

void
sys_yield(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	b8 04 00 00 00       	mov    $0x4,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	89 f7                	mov    %esi,%edi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800daa:	e8 89 02 00 00       	call   801038 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800dfd:	e8 36 02 00 00       	call   801038 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800e50:	e8 e3 01 00 00       	call   801038 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800ea3:	e8 90 01 00 00       	call   801038 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea8:	83 c4 2c             	add    $0x2c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebe:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 df                	mov    %ebx,%edi
  800ecb:	89 de                	mov    %ebx,%esi
  800ecd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	7e 28                	jle    800efb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eee:	00 
  800eef:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800ef6:	e8 3d 01 00 00       	call   801038 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efb:	83 c4 2c             	add    $0x2c,%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f09:	be 00 00 00 00       	mov    $0x0,%esi
  800f0e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	8b 55 08             	mov    0x8(%ebp),%edx
  800f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 cb                	mov    %ecx,%ebx
  800f3e:	89 cf                	mov    %ecx,%edi
  800f40:	89 ce                	mov    %ecx,%esi
  800f42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	7e 28                	jle    800f70 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f53:	00 
  800f54:	c7 44 24 08 28 16 80 	movl   $0x801628,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  800f6b:	e8 c8 00 00 00       	call   801038 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f70:	83 c4 2c             	add    $0x2c,%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f7e:	c7 44 24 08 5f 16 80 	movl   $0x80165f,0x8(%esp)
  800f85:	00 
  800f86:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 53 16 80 00 	movl   $0x801653,(%esp)
  800f95:	e8 9e 00 00 00       	call   801038 <_panic>

00800f9a <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fa0:	c7 44 24 08 5e 16 80 	movl   $0x80165e,0x8(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800faf:	00 
  800fb0:	c7 04 24 53 16 80 00 	movl   $0x801653,(%esp)
  800fb7:	e8 7c 00 00 00       	call   801038 <_panic>

00800fbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fc2:	c7 44 24 08 74 16 80 	movl   $0x801674,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 8d 16 80 00 	movl   $0x80168d,(%esp)
  800fd9:	e8 5a 00 00 00       	call   801038 <_panic>

00800fde <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fe4:	c7 44 24 08 97 16 80 	movl   $0x801697,0x8(%esp)
  800feb:	00 
  800fec:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800ff3:	00 
  800ff4:	c7 04 24 8d 16 80 00 	movl   $0x80168d,(%esp)
  800ffb:	e8 38 00 00 00       	call   801038 <_panic>

00801000 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80100b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80100e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801014:	8b 52 50             	mov    0x50(%edx),%edx
  801017:	39 ca                	cmp    %ecx,%edx
  801019:	75 0d                	jne    801028 <ipc_find_env+0x28>
			return envs[i].env_id;
  80101b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80101e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801023:	8b 40 40             	mov    0x40(%eax),%eax
  801026:	eb 0e                	jmp    801036 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801028:	83 c0 01             	add    $0x1,%eax
  80102b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801030:	75 d9                	jne    80100b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801032:	66 b8 00 00          	mov    $0x0,%ax
}
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801040:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801043:	8b 35 08 20 80 00    	mov    0x802008,%esi
  801049:	e8 d7 fc ff ff       	call   800d25 <sys_getenvid>
  80104e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801051:	89 54 24 10          	mov    %edx,0x10(%esp)
  801055:	8b 55 08             	mov    0x8(%ebp),%edx
  801058:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80105c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801060:	89 44 24 04          	mov    %eax,0x4(%esp)
  801064:	c7 04 24 b0 16 80 00 	movl   $0x8016b0,(%esp)
  80106b:	e8 5c f2 ff ff       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801074:	8b 45 10             	mov    0x10(%ebp),%eax
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	e8 ec f1 ff ff       	call   80026b <vcprintf>
	cprintf("\n");
  80107f:	c7 04 24 32 13 80 00 	movl   $0x801332,(%esp)
  801086:	e8 41 f2 ff ff       	call   8002cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108b:	cc                   	int3   
  80108c:	eb fd                	jmp    80108b <_panic+0x53>
  80108e:	66 90                	xchg   %ax,%ax

00801090 <__udivdi3>:
  801090:	55                   	push   %ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	8b 44 24 28          	mov    0x28(%esp),%eax
  80109a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80109e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8010a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ac:	89 ea                	mov    %ebp,%edx
  8010ae:	89 0c 24             	mov    %ecx,(%esp)
  8010b1:	75 2d                	jne    8010e0 <__udivdi3+0x50>
  8010b3:	39 e9                	cmp    %ebp,%ecx
  8010b5:	77 61                	ja     801118 <__udivdi3+0x88>
  8010b7:	85 c9                	test   %ecx,%ecx
  8010b9:	89 ce                	mov    %ecx,%esi
  8010bb:	75 0b                	jne    8010c8 <__udivdi3+0x38>
  8010bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	f7 f1                	div    %ecx
  8010c6:	89 c6                	mov    %eax,%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	89 e8                	mov    %ebp,%eax
  8010cc:	f7 f6                	div    %esi
  8010ce:	89 c5                	mov    %eax,%ebp
  8010d0:	89 f8                	mov    %edi,%eax
  8010d2:	f7 f6                	div    %esi
  8010d4:	89 ea                	mov    %ebp,%edx
  8010d6:	83 c4 0c             	add    $0xc,%esp
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	39 e8                	cmp    %ebp,%eax
  8010e2:	77 24                	ja     801108 <__udivdi3+0x78>
  8010e4:	0f bd e8             	bsr    %eax,%ebp
  8010e7:	83 f5 1f             	xor    $0x1f,%ebp
  8010ea:	75 3c                	jne    801128 <__udivdi3+0x98>
  8010ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010f0:	39 34 24             	cmp    %esi,(%esp)
  8010f3:	0f 86 9f 00 00 00    	jbe    801198 <__udivdi3+0x108>
  8010f9:	39 d0                	cmp    %edx,%eax
  8010fb:	0f 82 97 00 00 00    	jb     801198 <__udivdi3+0x108>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	31 d2                	xor    %edx,%edx
  80110a:	31 c0                	xor    %eax,%eax
  80110c:	83 c4 0c             	add    $0xc,%esp
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    
  801113:	90                   	nop
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	89 f8                	mov    %edi,%eax
  80111a:	f7 f1                	div    %ecx
  80111c:	31 d2                	xor    %edx,%edx
  80111e:	83 c4 0c             	add    $0xc,%esp
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    
  801125:	8d 76 00             	lea    0x0(%esi),%esi
  801128:	89 e9                	mov    %ebp,%ecx
  80112a:	8b 3c 24             	mov    (%esp),%edi
  80112d:	d3 e0                	shl    %cl,%eax
  80112f:	89 c6                	mov    %eax,%esi
  801131:	b8 20 00 00 00       	mov    $0x20,%eax
  801136:	29 e8                	sub    %ebp,%eax
  801138:	89 c1                	mov    %eax,%ecx
  80113a:	d3 ef                	shr    %cl,%edi
  80113c:	89 e9                	mov    %ebp,%ecx
  80113e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801142:	8b 3c 24             	mov    (%esp),%edi
  801145:	09 74 24 08          	or     %esi,0x8(%esp)
  801149:	89 d6                	mov    %edx,%esi
  80114b:	d3 e7                	shl    %cl,%edi
  80114d:	89 c1                	mov    %eax,%ecx
  80114f:	89 3c 24             	mov    %edi,(%esp)
  801152:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801156:	d3 ee                	shr    %cl,%esi
  801158:	89 e9                	mov    %ebp,%ecx
  80115a:	d3 e2                	shl    %cl,%edx
  80115c:	89 c1                	mov    %eax,%ecx
  80115e:	d3 ef                	shr    %cl,%edi
  801160:	09 d7                	or     %edx,%edi
  801162:	89 f2                	mov    %esi,%edx
  801164:	89 f8                	mov    %edi,%eax
  801166:	f7 74 24 08          	divl   0x8(%esp)
  80116a:	89 d6                	mov    %edx,%esi
  80116c:	89 c7                	mov    %eax,%edi
  80116e:	f7 24 24             	mull   (%esp)
  801171:	39 d6                	cmp    %edx,%esi
  801173:	89 14 24             	mov    %edx,(%esp)
  801176:	72 30                	jb     8011a8 <__udivdi3+0x118>
  801178:	8b 54 24 04          	mov    0x4(%esp),%edx
  80117c:	89 e9                	mov    %ebp,%ecx
  80117e:	d3 e2                	shl    %cl,%edx
  801180:	39 c2                	cmp    %eax,%edx
  801182:	73 05                	jae    801189 <__udivdi3+0xf9>
  801184:	3b 34 24             	cmp    (%esp),%esi
  801187:	74 1f                	je     8011a8 <__udivdi3+0x118>
  801189:	89 f8                	mov    %edi,%eax
  80118b:	31 d2                	xor    %edx,%edx
  80118d:	e9 7a ff ff ff       	jmp    80110c <__udivdi3+0x7c>
  801192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801198:	31 d2                	xor    %edx,%edx
  80119a:	b8 01 00 00 00       	mov    $0x1,%eax
  80119f:	e9 68 ff ff ff       	jmp    80110c <__udivdi3+0x7c>
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	83 c4 0c             	add    $0xc,%esp
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    
  8011b4:	66 90                	xchg   %ax,%ax
  8011b6:	66 90                	xchg   %ax,%ax
  8011b8:	66 90                	xchg   %ax,%ax
  8011ba:	66 90                	xchg   %ax,%ax
  8011bc:	66 90                	xchg   %ax,%ax
  8011be:	66 90                	xchg   %ax,%ax

008011c0 <__umoddi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 14             	sub    $0x14,%esp
  8011c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8011d2:	89 c7                	mov    %eax,%edi
  8011d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8011dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8011e0:	89 34 24             	mov    %esi,(%esp)
  8011e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ef:	75 17                	jne    801208 <__umoddi3+0x48>
  8011f1:	39 fe                	cmp    %edi,%esi
  8011f3:	76 4b                	jbe    801240 <__umoddi3+0x80>
  8011f5:	89 c8                	mov    %ecx,%eax
  8011f7:	89 fa                	mov    %edi,%edx
  8011f9:	f7 f6                	div    %esi
  8011fb:	89 d0                	mov    %edx,%eax
  8011fd:	31 d2                	xor    %edx,%edx
  8011ff:	83 c4 14             	add    $0x14,%esp
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    
  801206:	66 90                	xchg   %ax,%ax
  801208:	39 f8                	cmp    %edi,%eax
  80120a:	77 54                	ja     801260 <__umoddi3+0xa0>
  80120c:	0f bd e8             	bsr    %eax,%ebp
  80120f:	83 f5 1f             	xor    $0x1f,%ebp
  801212:	75 5c                	jne    801270 <__umoddi3+0xb0>
  801214:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801218:	39 3c 24             	cmp    %edi,(%esp)
  80121b:	0f 87 e7 00 00 00    	ja     801308 <__umoddi3+0x148>
  801221:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801225:	29 f1                	sub    %esi,%ecx
  801227:	19 c7                	sbb    %eax,%edi
  801229:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80122d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801231:	8b 44 24 08          	mov    0x8(%esp),%eax
  801235:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801239:	83 c4 14             	add    $0x14,%esp
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    
  801240:	85 f6                	test   %esi,%esi
  801242:	89 f5                	mov    %esi,%ebp
  801244:	75 0b                	jne    801251 <__umoddi3+0x91>
  801246:	b8 01 00 00 00       	mov    $0x1,%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	f7 f6                	div    %esi
  80124f:	89 c5                	mov    %eax,%ebp
  801251:	8b 44 24 04          	mov    0x4(%esp),%eax
  801255:	31 d2                	xor    %edx,%edx
  801257:	f7 f5                	div    %ebp
  801259:	89 c8                	mov    %ecx,%eax
  80125b:	f7 f5                	div    %ebp
  80125d:	eb 9c                	jmp    8011fb <__umoddi3+0x3b>
  80125f:	90                   	nop
  801260:	89 c8                	mov    %ecx,%eax
  801262:	89 fa                	mov    %edi,%edx
  801264:	83 c4 14             	add    $0x14,%esp
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
  80126b:	90                   	nop
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	8b 04 24             	mov    (%esp),%eax
  801273:	be 20 00 00 00       	mov    $0x20,%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	29 ee                	sub    %ebp,%esi
  80127c:	d3 e2                	shl    %cl,%edx
  80127e:	89 f1                	mov    %esi,%ecx
  801280:	d3 e8                	shr    %cl,%eax
  801282:	89 e9                	mov    %ebp,%ecx
  801284:	89 44 24 04          	mov    %eax,0x4(%esp)
  801288:	8b 04 24             	mov    (%esp),%eax
  80128b:	09 54 24 04          	or     %edx,0x4(%esp)
  80128f:	89 fa                	mov    %edi,%edx
  801291:	d3 e0                	shl    %cl,%eax
  801293:	89 f1                	mov    %esi,%ecx
  801295:	89 44 24 08          	mov    %eax,0x8(%esp)
  801299:	8b 44 24 10          	mov    0x10(%esp),%eax
  80129d:	d3 ea                	shr    %cl,%edx
  80129f:	89 e9                	mov    %ebp,%ecx
  8012a1:	d3 e7                	shl    %cl,%edi
  8012a3:	89 f1                	mov    %esi,%ecx
  8012a5:	d3 e8                	shr    %cl,%eax
  8012a7:	89 e9                	mov    %ebp,%ecx
  8012a9:	09 f8                	or     %edi,%eax
  8012ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8012af:	f7 74 24 04          	divl   0x4(%esp)
  8012b3:	d3 e7                	shl    %cl,%edi
  8012b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012b9:	89 d7                	mov    %edx,%edi
  8012bb:	f7 64 24 08          	mull   0x8(%esp)
  8012bf:	39 d7                	cmp    %edx,%edi
  8012c1:	89 c1                	mov    %eax,%ecx
  8012c3:	89 14 24             	mov    %edx,(%esp)
  8012c6:	72 2c                	jb     8012f4 <__umoddi3+0x134>
  8012c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8012cc:	72 22                	jb     8012f0 <__umoddi3+0x130>
  8012ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8012d2:	29 c8                	sub    %ecx,%eax
  8012d4:	19 d7                	sbb    %edx,%edi
  8012d6:	89 e9                	mov    %ebp,%ecx
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	d3 e8                	shr    %cl,%eax
  8012dc:	89 f1                	mov    %esi,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	89 e9                	mov    %ebp,%ecx
  8012e2:	d3 ef                	shr    %cl,%edi
  8012e4:	09 d0                	or     %edx,%eax
  8012e6:	89 fa                	mov    %edi,%edx
  8012e8:	83 c4 14             	add    $0x14,%esp
  8012eb:	5e                   	pop    %esi
  8012ec:	5f                   	pop    %edi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    
  8012ef:	90                   	nop
  8012f0:	39 d7                	cmp    %edx,%edi
  8012f2:	75 da                	jne    8012ce <__umoddi3+0x10e>
  8012f4:	8b 14 24             	mov    (%esp),%edx
  8012f7:	89 c1                	mov    %eax,%ecx
  8012f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8012fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801301:	eb cb                	jmp    8012ce <__umoddi3+0x10e>
  801303:	90                   	nop
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80130c:	0f 82 0f ff ff ff    	jb     801221 <__umoddi3+0x61>
  801312:	e9 1a ff ff ff       	jmp    801231 <__umoddi3+0x71>
