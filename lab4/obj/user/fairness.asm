
obj/user/fairness：     文件格式 elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 d5 0b 00 00       	call   800c15 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 34                	jne    800082 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800058:	00 
  800059:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800060:	00 
  800061:	89 34 24             	mov    %esi,(%esp)
  800064:	e8 07 0e 00 00       	call   800e70 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800069:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  80007b:	e8 41 01 00 00       	call   8001c1 <cprintf>
  800080:	eb cf                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800082:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	c7 04 24 f1 12 80 00 	movl   $0x8012f1,(%esp)
  800096:	e8 26 01 00 00       	call   8001c1 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a7:	00 
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 4e 0e 00 00       	call   800f0e <ipc_send>
  8000c0:	eb d9                	jmp    80009b <umain+0x68>

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 10             	sub    $0x10,%esp
  8000ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000d0:	e8 40 0b 00 00       	call   800c15 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x30>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	e8 35 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000fe:	e8 07 00 00 00       	call   80010a <exit>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800117:	e8 a7 0a 00 00       	call   800bc3 <sys_env_destroy>
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 14             	sub    $0x14,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 36 0a 00 00       	call   800b86 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015a:	83 c4 14             	add    $0x14,%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	c7 04 24 1e 01 80 00 	movl   $0x80011e,(%esp)
  80019c:	e8 73 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 cd 09 00 00       	call   800b86 <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 87 ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    
  8001db:	66 90                	xchg   %ax,%ax
  8001dd:	66 90                	xchg   %ax,%ax
  8001df:	90                   	nop

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 fc 0d 00 00       	call   801050 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 cc 0e 00 00       	call   801180 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 12 13 80 00 	movsbl 0x801312(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 0a                	jae    8002ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	88 02                	mov    %al,(%edx)
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	e8 02 00 00 00       	call   800314 <vprintfmt>
	va_end(ap);
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 3c             	sub    $0x3c,%esp
  80031d:	8b 75 08             	mov    0x8(%ebp),%esi
  800320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800323:	8b 7d 10             	mov    0x10(%ebp),%edi
  800326:	eb 11                	jmp    800339 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800328:	85 c0                	test   %eax,%eax
  80032a:	0f 84 48 04 00 00    	je     800778 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800330:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	83 c7 01             	add    $0x1,%edi
  80033c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800340:	83 f8 25             	cmp    $0x25,%eax
  800343:	75 e3                	jne    800328 <vprintfmt+0x14>
  800345:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800349:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800350:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800357:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800363:	eb 1f                	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800368:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036c:	eb 16                	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800371:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800375:	eb 0d                	jmp    800384 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800377:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8d 47 01             	lea    0x1(%edi),%eax
  800387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038a:	0f b6 17             	movzbl (%edi),%edx
  80038d:	0f b6 c2             	movzbl %dl,%eax
  800390:	83 ea 23             	sub    $0x23,%edx
  800393:	80 fa 55             	cmp    $0x55,%dl
  800396:	0f 87 bf 03 00 00    	ja     80075b <vprintfmt+0x447>
  80039c:	0f b6 d2             	movzbl %dl,%edx
  80039f:	ff 24 95 e0 13 80 00 	jmp    *0x8013e0(,%edx,4)
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003b4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3c                	ja     8003ff <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 27                	jmp    800405 <vprintfmt+0xf1>
  8003de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	0f 49 c2             	cmovns %edx,%eax
  8003eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 91                	jmp    800384 <vprintfmt+0x70>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	eb 85                	jmp    800384 <vprintfmt+0x70>
  8003ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800402:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	0f 89 75 ff ff ff    	jns    800384 <vprintfmt+0x70>
  80040f:	e9 63 ff ff ff       	jmp    800377 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041a:	e9 65 ff ff ff       	jmp    800384 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800422:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800434:	e9 00 ff ff ff       	jmp    800339 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
  800443:	31 d0                	xor    %edx,%eax
  800445:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 09             	cmp    $0x9,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x143>
  80044c:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 20                	jne    800477 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045b:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800462:	00 
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 34 24             	mov    %esi,(%esp)
  80046a:	e8 7d fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800472:	e9 c2 fe ff ff       	jmp    800339 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800477:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047b:	c7 44 24 08 33 13 80 	movl   $0x801333,0x8(%esp)
  800482:	00 
  800483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800487:	89 34 24             	mov    %esi,(%esp)
  80048a:	e8 5d fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 a2 fe ff ff       	jmp    800339 <vprintfmt+0x25>
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a9:	85 ff                	test   %edi,%edi
  8004ab:	b8 23 13 80 00       	mov    $0x801323,%eax
  8004b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b7:	0f 84 92 00 00 00    	je     80054f <vprintfmt+0x23b>
  8004bd:	85 c9                	test   %ecx,%ecx
  8004bf:	0f 8e 98 00 00 00    	jle    80055d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c9:	89 3c 24             	mov    %edi,(%esp)
  8004cc:	e8 47 03 00 00       	call   800818 <strnlen>
  8004d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1d3>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 50                	jmp    800569 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1e                	je     80053d <vprintfmt+0x229>
  80051f:	0f be d2             	movsbl %dl,%edx
  800522:	83 ea 20             	sub    $0x20,%edx
  800525:	83 fa 5e             	cmp    $0x5e,%edx
  800528:	76 13                	jbe    80053d <vprintfmt+0x229>
					putch('?', putdat);
  80052a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	eb 0d                	jmp    80054a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80053d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800540:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	83 eb 01             	sub    $0x1,%ebx
  80054d:	eb 1a                	jmp    800569 <vprintfmt+0x255>
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055b:	eb 0c                	jmp    800569 <vprintfmt+0x255>
  80055d:	89 75 08             	mov    %esi,0x8(%ebp)
  800560:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800566:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800569:	83 c7 01             	add    $0x1,%edi
  80056c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800570:	0f be c2             	movsbl %dl,%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	74 25                	je     80059c <vprintfmt+0x288>
  800577:	85 f6                	test   %esi,%esi
  800579:	78 9e                	js     800519 <vprintfmt+0x205>
  80057b:	83 ee 01             	sub    $0x1,%esi
  80057e:	79 99                	jns    800519 <vprintfmt+0x205>
  800580:	89 df                	mov    %ebx,%edi
  800582:	8b 75 08             	mov    0x8(%ebp),%esi
  800585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800588:	eb 1a                	jmp    8005a4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	eb 08                	jmp    8005a4 <vprintfmt+0x290>
  80059c:	89 df                	mov    %ebx,%edi
  80059e:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a4:	85 ff                	test   %edi,%edi
  8005a6:	7f e2                	jg     80058a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 89 fd ff ff       	jmp    800339 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b0:	83 f9 01             	cmp    $0x1,%ecx
  8005b3:	7e 19                	jle    8005ce <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 50 04             	mov    0x4(%eax),%edx
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cc:	eb 38                	jmp    800606 <vprintfmt+0x2f2>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 1b                	je     8005ed <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005da:	89 c1                	mov    %eax,%ecx
  8005dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005eb:	eb 19                	jmp    800606 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800606:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800611:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800615:	0f 89 04 01 00 00    	jns    80071f <vprintfmt+0x40b>
				putch('-', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80062e:	f7 da                	neg    %edx
  800630:	83 d1 00             	adc    $0x0,%ecx
  800633:	f7 d9                	neg    %ecx
  800635:	e9 e5 00 00 00       	jmp    80071f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063a:	83 f9 01             	cmp    $0x1,%ecx
  80063d:	7e 10                	jle    80064f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	8b 48 04             	mov    0x4(%eax),%ecx
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	eb 26                	jmp    800675 <vprintfmt+0x361>
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 12                	je     800665 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
  800663:	eb 10                	jmp    800675 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800675:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80067a:	e9 a0 00 00 00       	jmp    80071f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80068a:	ff d6                	call   *%esi
			putch('X', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800697:	ff d6                	call   *%esi
			putch('X', putdat);
  800699:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006a9:	e9 8b fc ff ff       	jmp    800339 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006dd:	eb 40                	jmp    80071f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ec:	8d 40 08             	lea    0x8(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x406>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
  800708:	eb 10                	jmp    80071a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800723:	89 44 24 10          	mov    %eax,0x10(%esp)
  800727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800732:	89 14 24             	mov    %edx,(%esp)
  800735:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800739:	89 da                	mov    %ebx,%edx
  80073b:	89 f0                	mov    %esi,%eax
  80073d:	e8 9e fa ff ff       	call   8001e0 <printnum>
			break;
  800742:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800745:	e9 ef fb ff ff       	jmp    800339 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800756:	e9 de fb ff ff       	jmp    800339 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800766:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800768:	eb 03                	jmp    80076d <vprintfmt+0x459>
  80076a:	83 ef 01             	sub    $0x1,%edi
  80076d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800771:	75 f7                	jne    80076a <vprintfmt+0x456>
  800773:	e9 c1 fb ff ff       	jmp    800339 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800778:	83 c4 3c             	add    $0x3c,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 28             	sub    $0x28,%esp
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800793:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 30                	je     8007d1 <vsnprintf+0x51>
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	7e 2c                	jle    8007d1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8007af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ba:	c7 04 24 cf 02 80 00 	movl   $0x8002cf,(%esp)
  8007c1:	e8 4e fb ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cf:	eb 05                	jmp    8007d6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	e8 82 ff ff ff       	call   800780 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strlen+0x10>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800814:	75 f7                	jne    80080d <strlen+0xd>
		n++;
	return n;
}
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strnlen+0x13>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	39 d0                	cmp    %edx,%eax
  80082d:	74 06                	je     800835 <strnlen+0x1d>
  80082f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800833:	75 f3                	jne    800828 <strnlen+0x10>
		n++;
	return n;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800850:	84 db                	test   %bl,%bl
  800852:	75 ef                	jne    800843 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800861:	89 1c 24             	mov    %ebx,(%esp)
  800864:	e8 97 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800870:	01 d8                	add    %ebx,%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 bd ff ff ff       	call   800837 <strcpy>
	return dst;
}
  80087a:	89 d8                	mov    %ebx,%eax
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	89 f3                	mov    %esi,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800892:	89 f2                	mov    %esi,%edx
  800894:	eb 0f                	jmp    8008a5 <strncpy+0x23>
		*dst++ = *src;
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	0f b6 01             	movzbl (%ecx),%eax
  80089c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089f:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	39 da                	cmp    %ebx,%edx
  8008a7:	75 ed                	jne    800896 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	75 0b                	jne    8008d2 <strlcpy+0x23>
  8008c7:	eb 1d                	jmp    8008e6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 0b                	je     8008e1 <strlcpy+0x32>
  8008d6:	0f b6 0a             	movzbl (%edx),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	75 ec                	jne    8008c9 <strlcpy+0x1a>
  8008dd:	89 c2                	mov    %eax,%edx
  8008df:	eb 02                	jmp    8008e3 <strlcpy+0x34>
  8008e1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008e3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008e6:	29 f0                	sub    %esi,%eax
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f5:	eb 06                	jmp    8008fd <strcmp+0x11>
		p++, q++;
  8008f7:	83 c1 01             	add    $0x1,%ecx
  8008fa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fd:	0f b6 01             	movzbl (%ecx),%eax
  800900:	84 c0                	test   %al,%al
  800902:	74 04                	je     800908 <strcmp+0x1c>
  800904:	3a 02                	cmp    (%edx),%al
  800906:	74 ef                	je     8008f7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 c3                	mov    %eax,%ebx
  80091e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800921:	eb 06                	jmp    800929 <strncmp+0x17>
		n--, p++, q++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800929:	39 d8                	cmp    %ebx,%eax
  80092b:	74 15                	je     800942 <strncmp+0x30>
  80092d:	0f b6 08             	movzbl (%eax),%ecx
  800930:	84 c9                	test   %cl,%cl
  800932:	74 04                	je     800938 <strncmp+0x26>
  800934:	3a 0a                	cmp    (%edx),%cl
  800936:	74 eb                	je     800923 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 00             	movzbl (%eax),%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
  800940:	eb 05                	jmp    800947 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	eb 07                	jmp    80095d <strchr+0x13>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 0f                	je     800969 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f2                	jne    800956 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	eb 07                	jmp    80097e <strfind+0x13>
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	74 0a                	je     800985 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	0f b6 10             	movzbl (%eax),%edx
  800981:	84 d2                	test   %dl,%dl
  800983:	75 f2                	jne    800977 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800993:	85 c9                	test   %ecx,%ecx
  800995:	74 36                	je     8009cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800997:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099d:	75 28                	jne    8009c7 <memset+0x40>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 23                	jne    8009c7 <memset+0x40>
		c &= 0xFF;
  8009a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a8:	89 d3                	mov    %edx,%ebx
  8009aa:	c1 e3 08             	shl    $0x8,%ebx
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	c1 e6 18             	shl    $0x18,%esi
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	c1 e0 10             	shl    $0x10,%eax
  8009b7:	09 f0                	or     %esi,%eax
  8009b9:	09 c2                	or     %eax,%edx
  8009bb:	89 d0                	mov    %edx,%eax
  8009bd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c2:	fc                   	cld    
  8009c3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c5:	eb 06                	jmp    8009cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 35                	jae    800a1b <memmove+0x47>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2e                	jae    800a1b <memmove+0x47>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009f0:	89 d6                	mov    %edx,%esi
  8009f2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fa:	75 13                	jne    800a0f <memmove+0x3b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 0e                	jne    800a0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a01:	83 ef 04             	sub    $0x4,%edi
  800a04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb 09                	jmp    800a18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0f:	83 ef 01             	sub    $0x1,%edi
  800a12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a15:	fd                   	std    
  800a16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a18:	fc                   	cld    
  800a19:	eb 1d                	jmp    800a38 <memmove+0x64>
  800a1b:	89 f2                	mov    %esi,%edx
  800a1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	f6 c2 03             	test   $0x3,%dl
  800a22:	75 0f                	jne    800a33 <memmove+0x5f>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	75 0a                	jne    800a33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 05                	jmp    800a38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	fc                   	cld    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a42:	8b 45 10             	mov    0x10(%ebp),%eax
  800a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	e8 79 ff ff ff       	call   8009d4 <memmove>
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6d:	eb 1a                	jmp    800a89 <memcmp+0x2c>
		if (*s1 != *s2)
  800a6f:	0f b6 02             	movzbl (%edx),%eax
  800a72:	0f b6 19             	movzbl (%ecx),%ebx
  800a75:	38 d8                	cmp    %bl,%al
  800a77:	74 0a                	je     800a83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c0             	movzbl %al,%eax
  800a7c:	0f b6 db             	movzbl %bl,%ebx
  800a7f:	29 d8                	sub    %ebx,%eax
  800a81:	eb 0f                	jmp    800a92 <memcmp+0x35>
		s1++, s2++;
  800a83:	83 c2 01             	add    $0x1,%edx
  800a86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a89:	39 f2                	cmp    %esi,%edx
  800a8b:	75 e2                	jne    800a6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9f:	89 c2                	mov    %eax,%edx
  800aa1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa4:	eb 07                	jmp    800aad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	38 08                	cmp    %cl,(%eax)
  800aa8:	74 07                	je     800ab1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	39 d0                	cmp    %edx,%eax
  800aaf:	72 f5                	jb     800aa6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 55 08             	mov    0x8(%ebp),%edx
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abf:	eb 03                	jmp    800ac4 <strtol+0x11>
		s++;
  800ac1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac4:	0f b6 0a             	movzbl (%edx),%ecx
  800ac7:	80 f9 09             	cmp    $0x9,%cl
  800aca:	74 f5                	je     800ac1 <strtol+0xe>
  800acc:	80 f9 20             	cmp    $0x20,%cl
  800acf:	74 f0                	je     800ac1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad1:	80 f9 2b             	cmp    $0x2b,%cl
  800ad4:	75 0a                	jne    800ae0 <strtol+0x2d>
		s++;
  800ad6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb 11                	jmp    800af1 <strtol+0x3e>
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae5:	80 f9 2d             	cmp    $0x2d,%cl
  800ae8:	75 07                	jne    800af1 <strtol+0x3e>
		s++, neg = 1;
  800aea:	8d 52 01             	lea    0x1(%edx),%edx
  800aed:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800af6:	75 15                	jne    800b0d <strtol+0x5a>
  800af8:	80 3a 30             	cmpb   $0x30,(%edx)
  800afb:	75 10                	jne    800b0d <strtol+0x5a>
  800afd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b01:	75 0a                	jne    800b0d <strtol+0x5a>
		s += 2, base = 16;
  800b03:	83 c2 02             	add    $0x2,%edx
  800b06:	b8 10 00 00 00       	mov    $0x10,%eax
  800b0b:	eb 10                	jmp    800b1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	75 0c                	jne    800b1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	80 3a 30             	cmpb   $0x30,(%edx)
  800b16:	75 05                	jne    800b1d <strtol+0x6a>
		s++, base = 8;
  800b18:	83 c2 01             	add    $0x1,%edx
  800b1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b25:	0f b6 0a             	movzbl (%edx),%ecx
  800b28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	3c 09                	cmp    $0x9,%al
  800b2f:	77 08                	ja     800b39 <strtol+0x86>
			dig = *s - '0';
  800b31:	0f be c9             	movsbl %cl,%ecx
  800b34:	83 e9 30             	sub    $0x30,%ecx
  800b37:	eb 20                	jmp    800b59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	3c 19                	cmp    $0x19,%al
  800b40:	77 08                	ja     800b4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b42:	0f be c9             	movsbl %cl,%ecx
  800b45:	83 e9 57             	sub    $0x57,%ecx
  800b48:	eb 0f                	jmp    800b59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	3c 19                	cmp    $0x19,%al
  800b51:	77 16                	ja     800b69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b53:	0f be c9             	movsbl %cl,%ecx
  800b56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b5c:	7d 0f                	jge    800b6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b67:	eb bc                	jmp    800b25 <strtol+0x72>
  800b69:	89 d8                	mov    %ebx,%eax
  800b6b:	eb 02                	jmp    800b6f <strtol+0xbc>
  800b6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b73:	74 05                	je     800b7a <strtol+0xc7>
		*endptr = (char *) s;
  800b75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b7a:	f7 d8                	neg    %eax
  800b7c:	85 ff                	test   %edi,%edi
  800b7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	89 c6                	mov    %eax,%esi
  800b9d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 cb                	mov    %ecx,%ebx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	89 ce                	mov    %ecx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 28                	jle    800c0d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800bf8:	00 
  800bf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c00:	00 
  800c01:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800c08:	e8 e8 03 00 00       	call   800ff5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0d:	83 c4 2c             	add    $0x2c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 02 00 00 00       	mov    $0x2,%eax
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 d3                	mov    %edx,%ebx
  800c29:	89 d7                	mov    %edx,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_yield>:

void
sys_yield(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	b8 04 00 00 00       	mov    $0x4,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	89 f7                	mov    %esi,%edi
  800c71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800c9a:	e8 56 03 00 00       	call   800ff5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9f:	83 c4 2c             	add    $0x2c,%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 28                	jle    800cf2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cce:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd5:	00 
  800cd6:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800cdd:	00 
  800cde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce5:	00 
  800ce6:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800ced:	e8 03 03 00 00       	call   800ff5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf2:	83 c4 2c             	add    $0x2c,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 28                	jle    800d45 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d21:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d28:	00 
  800d29:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d30:	00 
  800d31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d38:	00 
  800d39:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d40:	e8 b0 02 00 00       	call   800ff5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d45:	83 c4 2c             	add    $0x2c,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 28                	jle    800d98 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d74:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d83:	00 
  800d84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8b:	00 
  800d8c:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d93:	e8 5d 02 00 00       	call   800ff5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	83 c4 2c             	add    $0x2c,%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 28                	jle    800deb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dde:	00 
  800ddf:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800de6:	e8 0a 02 00 00       	call   800ff5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800deb:	83 c4 2c             	add    $0x2c,%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	be 00 00 00 00       	mov    $0x0,%esi
  800dfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 cb                	mov    %ecx,%ebx
  800e2e:	89 cf                	mov    %ecx,%edi
  800e30:	89 ce                	mov    %ecx,%esi
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 28                	jle    800e60 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e43:	00 
  800e44:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800e4b:	00 
  800e4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e53:	00 
  800e54:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800e5b:	e8 95 01 00 00       	call   800ff5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e60:	83 c4 2c             	add    $0x2c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 10             	sub    $0x10,%esp
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r =0;
	int a;
	if(pg == 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	75 0e                	jne    800e93 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  800e85:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  800e8c:	e8 85 ff ff ff       	call   800e16 <sys_ipc_recv>
  800e91:	eb 08                	jmp    800e9b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  800e93:	89 04 24             	mov    %eax,(%esp)
  800e96:	e8 7b ff ff ff       	call   800e16 <sys_ipc_recv>
	if(r == 0){
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	75 1e                	jne    800ec0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  800ea2:	85 f6                	test   %esi,%esi
  800ea4:	74 0a                	je     800eb0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  800ea6:	a1 04 20 80 00       	mov    0x802004,%eax
  800eab:	8b 40 74             	mov    0x74(%eax),%eax
  800eae:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  800eb0:	85 db                	test   %ebx,%ebx
  800eb2:	74 2c                	je     800ee0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  800eb4:	a1 04 20 80 00       	mov    0x802004,%eax
  800eb9:	8b 40 78             	mov    0x78(%eax),%eax
  800ebc:	89 03                	mov    %eax,(%ebx)
  800ebe:	eb 20                	jmp    800ee0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  800ec0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec4:	c7 44 24 08 94 15 80 	movl   $0x801594,0x8(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800ed3:	00 
  800ed4:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  800edb:	e8 15 01 00 00       	call   800ff5 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  800ee0:	a1 04 20 80 00       	mov    0x802004,%eax
  800ee5:	8b 50 70             	mov    0x70(%eax),%edx
  800ee8:	85 d2                	test   %edx,%edx
  800eea:	75 13                	jne    800eff <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  800eec:	8b 40 48             	mov    0x48(%eax),%eax
  800eef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef3:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  800efa:	e8 c2 f2 ff ff       	call   8001c1 <cprintf>
	return thisenv->env_ipc_value;
  800eff:	a1 04 20 80 00       	mov    0x802004,%eax
  800f04:	8b 40 70             	mov    0x70(%eax),%eax
	

	


}
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f1a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	
	int r =0;
	while(1){
		if(pg == 0)
  800f1d:	85 f6                	test   %esi,%esi
  800f1f:	75 22                	jne    800f43 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  800f21:	8b 45 14             	mov    0x14(%ebp),%eax
  800f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f28:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  800f2f:	ee 
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f37:	89 3c 24             	mov    %edi,(%esp)
  800f3a:	e8 b4 fe ff ff       	call   800df3 <sys_ipc_try_send>
  800f3f:	89 c3                	mov    %eax,%ebx
  800f41:	eb 1c                	jmp    800f5f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  800f43:	8b 45 14             	mov    0x14(%ebp),%eax
  800f46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f4a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f55:	89 3c 24             	mov    %edi,(%esp)
  800f58:	e8 96 fe ff ff       	call   800df3 <sys_ipc_try_send>
  800f5d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  800f5f:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800f62:	74 3e                	je     800fa2 <ipc_send+0x94>
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	c1 e8 1f             	shr    $0x1f,%eax
  800f69:	84 c0                	test   %al,%al
  800f6b:	74 35                	je     800fa2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  800f6d:	e8 a3 fc ff ff       	call   800c15 <sys_getenvid>
  800f72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f76:	c7 04 24 1a 16 80 00 	movl   $0x80161a,(%esp)
  800f7d:	e8 3f f2 ff ff       	call   8001c1 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  800f82:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f86:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  800f9d:	e8 53 00 00 00       	call   800ff5 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  800fa2:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800fa5:	75 0e                	jne    800fb5 <ipc_send+0xa7>
			sys_yield();
  800fa7:	e8 88 fc ff ff       	call   800c34 <sys_yield>
		else break;
	}
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	e9 68 ff ff ff       	jmp    800f1d <ipc_send+0xf>
	



}
  800fb5:	83 c4 1c             	add    $0x1c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800fc8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800fcb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fd1:	8b 52 50             	mov    0x50(%edx),%edx
  800fd4:	39 ca                	cmp    %ecx,%edx
  800fd6:	75 0d                	jne    800fe5 <ipc_find_env+0x28>
			return envs[i].env_id;
  800fd8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fdb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800fe0:	8b 40 40             	mov    0x40(%eax),%eax
  800fe3:	eb 0e                	jmp    800ff3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fe5:	83 c0 01             	add    $0x1,%eax
  800fe8:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fed:	75 d9                	jne    800fc8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800fef:	66 b8 00 00          	mov    $0x0,%ax
}
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ffd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801000:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801006:	e8 0a fc ff ff       	call   800c15 <sys_getenvid>
  80100b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801012:	8b 55 08             	mov    0x8(%ebp),%edx
  801015:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801019:	89 74 24 08          	mov    %esi,0x8(%esp)
  80101d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801021:	c7 04 24 2c 16 80 00 	movl   $0x80162c,(%esp)
  801028:	e8 94 f1 ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801031:	8b 45 10             	mov    0x10(%ebp),%eax
  801034:	89 04 24             	mov    %eax,(%esp)
  801037:	e8 24 f1 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  80103c:	c7 04 24 ef 12 80 00 	movl   $0x8012ef,(%esp)
  801043:	e8 79 f1 ff ff       	call   8001c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801048:	cc                   	int3   
  801049:	eb fd                	jmp    801048 <_panic+0x53>
  80104b:	66 90                	xchg   %ax,%ax
  80104d:	66 90                	xchg   %ax,%ax
  80104f:	90                   	nop

00801050 <__udivdi3>:
  801050:	55                   	push   %ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	8b 44 24 28          	mov    0x28(%esp),%eax
  80105a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80105e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801062:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801066:	85 c0                	test   %eax,%eax
  801068:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80106c:	89 ea                	mov    %ebp,%edx
  80106e:	89 0c 24             	mov    %ecx,(%esp)
  801071:	75 2d                	jne    8010a0 <__udivdi3+0x50>
  801073:	39 e9                	cmp    %ebp,%ecx
  801075:	77 61                	ja     8010d8 <__udivdi3+0x88>
  801077:	85 c9                	test   %ecx,%ecx
  801079:	89 ce                	mov    %ecx,%esi
  80107b:	75 0b                	jne    801088 <__udivdi3+0x38>
  80107d:	b8 01 00 00 00       	mov    $0x1,%eax
  801082:	31 d2                	xor    %edx,%edx
  801084:	f7 f1                	div    %ecx
  801086:	89 c6                	mov    %eax,%esi
  801088:	31 d2                	xor    %edx,%edx
  80108a:	89 e8                	mov    %ebp,%eax
  80108c:	f7 f6                	div    %esi
  80108e:	89 c5                	mov    %eax,%ebp
  801090:	89 f8                	mov    %edi,%eax
  801092:	f7 f6                	div    %esi
  801094:	89 ea                	mov    %ebp,%edx
  801096:	83 c4 0c             	add    $0xc,%esp
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	39 e8                	cmp    %ebp,%eax
  8010a2:	77 24                	ja     8010c8 <__udivdi3+0x78>
  8010a4:	0f bd e8             	bsr    %eax,%ebp
  8010a7:	83 f5 1f             	xor    $0x1f,%ebp
  8010aa:	75 3c                	jne    8010e8 <__udivdi3+0x98>
  8010ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010b0:	39 34 24             	cmp    %esi,(%esp)
  8010b3:	0f 86 9f 00 00 00    	jbe    801158 <__udivdi3+0x108>
  8010b9:	39 d0                	cmp    %edx,%eax
  8010bb:	0f 82 97 00 00 00    	jb     801158 <__udivdi3+0x108>
  8010c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	31 c0                	xor    %eax,%eax
  8010cc:	83 c4 0c             	add    $0xc,%esp
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    
  8010d3:	90                   	nop
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	89 f8                	mov    %edi,%eax
  8010da:	f7 f1                	div    %ecx
  8010dc:	31 d2                	xor    %edx,%edx
  8010de:	83 c4 0c             	add    $0xc,%esp
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    
  8010e5:	8d 76 00             	lea    0x0(%esi),%esi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	8b 3c 24             	mov    (%esp),%edi
  8010ed:	d3 e0                	shl    %cl,%eax
  8010ef:	89 c6                	mov    %eax,%esi
  8010f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010f6:	29 e8                	sub    %ebp,%eax
  8010f8:	89 c1                	mov    %eax,%ecx
  8010fa:	d3 ef                	shr    %cl,%edi
  8010fc:	89 e9                	mov    %ebp,%ecx
  8010fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801102:	8b 3c 24             	mov    (%esp),%edi
  801105:	09 74 24 08          	or     %esi,0x8(%esp)
  801109:	89 d6                	mov    %edx,%esi
  80110b:	d3 e7                	shl    %cl,%edi
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	89 3c 24             	mov    %edi,(%esp)
  801112:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801116:	d3 ee                	shr    %cl,%esi
  801118:	89 e9                	mov    %ebp,%ecx
  80111a:	d3 e2                	shl    %cl,%edx
  80111c:	89 c1                	mov    %eax,%ecx
  80111e:	d3 ef                	shr    %cl,%edi
  801120:	09 d7                	or     %edx,%edi
  801122:	89 f2                	mov    %esi,%edx
  801124:	89 f8                	mov    %edi,%eax
  801126:	f7 74 24 08          	divl   0x8(%esp)
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	89 c7                	mov    %eax,%edi
  80112e:	f7 24 24             	mull   (%esp)
  801131:	39 d6                	cmp    %edx,%esi
  801133:	89 14 24             	mov    %edx,(%esp)
  801136:	72 30                	jb     801168 <__udivdi3+0x118>
  801138:	8b 54 24 04          	mov    0x4(%esp),%edx
  80113c:	89 e9                	mov    %ebp,%ecx
  80113e:	d3 e2                	shl    %cl,%edx
  801140:	39 c2                	cmp    %eax,%edx
  801142:	73 05                	jae    801149 <__udivdi3+0xf9>
  801144:	3b 34 24             	cmp    (%esp),%esi
  801147:	74 1f                	je     801168 <__udivdi3+0x118>
  801149:	89 f8                	mov    %edi,%eax
  80114b:	31 d2                	xor    %edx,%edx
  80114d:	e9 7a ff ff ff       	jmp    8010cc <__udivdi3+0x7c>
  801152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801158:	31 d2                	xor    %edx,%edx
  80115a:	b8 01 00 00 00       	mov    $0x1,%eax
  80115f:	e9 68 ff ff ff       	jmp    8010cc <__udivdi3+0x7c>
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	8d 47 ff             	lea    -0x1(%edi),%eax
  80116b:	31 d2                	xor    %edx,%edx
  80116d:	83 c4 0c             	add    $0xc,%esp
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    
  801174:	66 90                	xchg   %ax,%ax
  801176:	66 90                	xchg   %ax,%ax
  801178:	66 90                	xchg   %ax,%ax
  80117a:	66 90                	xchg   %ax,%ax
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__umoddi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	83 ec 14             	sub    $0x14,%esp
  801186:	8b 44 24 28          	mov    0x28(%esp),%eax
  80118a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80118e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801192:	89 c7                	mov    %eax,%edi
  801194:	89 44 24 04          	mov    %eax,0x4(%esp)
  801198:	8b 44 24 30          	mov    0x30(%esp),%eax
  80119c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8011a0:	89 34 24             	mov    %esi,(%esp)
  8011a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011af:	75 17                	jne    8011c8 <__umoddi3+0x48>
  8011b1:	39 fe                	cmp    %edi,%esi
  8011b3:	76 4b                	jbe    801200 <__umoddi3+0x80>
  8011b5:	89 c8                	mov    %ecx,%eax
  8011b7:	89 fa                	mov    %edi,%edx
  8011b9:	f7 f6                	div    %esi
  8011bb:	89 d0                	mov    %edx,%eax
  8011bd:	31 d2                	xor    %edx,%edx
  8011bf:	83 c4 14             	add    $0x14,%esp
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	66 90                	xchg   %ax,%ax
  8011c8:	39 f8                	cmp    %edi,%eax
  8011ca:	77 54                	ja     801220 <__umoddi3+0xa0>
  8011cc:	0f bd e8             	bsr    %eax,%ebp
  8011cf:	83 f5 1f             	xor    $0x1f,%ebp
  8011d2:	75 5c                	jne    801230 <__umoddi3+0xb0>
  8011d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011d8:	39 3c 24             	cmp    %edi,(%esp)
  8011db:	0f 87 e7 00 00 00    	ja     8012c8 <__umoddi3+0x148>
  8011e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011e5:	29 f1                	sub    %esi,%ecx
  8011e7:	19 c7                	sbb    %eax,%edi
  8011e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011f9:	83 c4 14             	add    $0x14,%esp
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    
  801200:	85 f6                	test   %esi,%esi
  801202:	89 f5                	mov    %esi,%ebp
  801204:	75 0b                	jne    801211 <__umoddi3+0x91>
  801206:	b8 01 00 00 00       	mov    $0x1,%eax
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	f7 f6                	div    %esi
  80120f:	89 c5                	mov    %eax,%ebp
  801211:	8b 44 24 04          	mov    0x4(%esp),%eax
  801215:	31 d2                	xor    %edx,%edx
  801217:	f7 f5                	div    %ebp
  801219:	89 c8                	mov    %ecx,%eax
  80121b:	f7 f5                	div    %ebp
  80121d:	eb 9c                	jmp    8011bb <__umoddi3+0x3b>
  80121f:	90                   	nop
  801220:	89 c8                	mov    %ecx,%eax
  801222:	89 fa                	mov    %edi,%edx
  801224:	83 c4 14             	add    $0x14,%esp
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    
  80122b:	90                   	nop
  80122c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801230:	8b 04 24             	mov    (%esp),%eax
  801233:	be 20 00 00 00       	mov    $0x20,%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	29 ee                	sub    %ebp,%esi
  80123c:	d3 e2                	shl    %cl,%edx
  80123e:	89 f1                	mov    %esi,%ecx
  801240:	d3 e8                	shr    %cl,%eax
  801242:	89 e9                	mov    %ebp,%ecx
  801244:	89 44 24 04          	mov    %eax,0x4(%esp)
  801248:	8b 04 24             	mov    (%esp),%eax
  80124b:	09 54 24 04          	or     %edx,0x4(%esp)
  80124f:	89 fa                	mov    %edi,%edx
  801251:	d3 e0                	shl    %cl,%eax
  801253:	89 f1                	mov    %esi,%ecx
  801255:	89 44 24 08          	mov    %eax,0x8(%esp)
  801259:	8b 44 24 10          	mov    0x10(%esp),%eax
  80125d:	d3 ea                	shr    %cl,%edx
  80125f:	89 e9                	mov    %ebp,%ecx
  801261:	d3 e7                	shl    %cl,%edi
  801263:	89 f1                	mov    %esi,%ecx
  801265:	d3 e8                	shr    %cl,%eax
  801267:	89 e9                	mov    %ebp,%ecx
  801269:	09 f8                	or     %edi,%eax
  80126b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80126f:	f7 74 24 04          	divl   0x4(%esp)
  801273:	d3 e7                	shl    %cl,%edi
  801275:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801279:	89 d7                	mov    %edx,%edi
  80127b:	f7 64 24 08          	mull   0x8(%esp)
  80127f:	39 d7                	cmp    %edx,%edi
  801281:	89 c1                	mov    %eax,%ecx
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 2c                	jb     8012b4 <__umoddi3+0x134>
  801288:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80128c:	72 22                	jb     8012b0 <__umoddi3+0x130>
  80128e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801292:	29 c8                	sub    %ecx,%eax
  801294:	19 d7                	sbb    %edx,%edi
  801296:	89 e9                	mov    %ebp,%ecx
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 e8                	shr    %cl,%eax
  80129c:	89 f1                	mov    %esi,%ecx
  80129e:	d3 e2                	shl    %cl,%edx
  8012a0:	89 e9                	mov    %ebp,%ecx
  8012a2:	d3 ef                	shr    %cl,%edi
  8012a4:	09 d0                	or     %edx,%eax
  8012a6:	89 fa                	mov    %edi,%edx
  8012a8:	83 c4 14             	add    $0x14,%esp
  8012ab:	5e                   	pop    %esi
  8012ac:	5f                   	pop    %edi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    
  8012af:	90                   	nop
  8012b0:	39 d7                	cmp    %edx,%edi
  8012b2:	75 da                	jne    80128e <__umoddi3+0x10e>
  8012b4:	8b 14 24             	mov    (%esp),%edx
  8012b7:	89 c1                	mov    %eax,%ecx
  8012b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8012bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8012c1:	eb cb                	jmp    80128e <__umoddi3+0x10e>
  8012c3:	90                   	nop
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8012cc:	0f 82 0f ff ff ff    	jb     8011e1 <__umoddi3+0x61>
  8012d2:	e9 1a ff ff ff       	jmp    8011f1 <__umoddi3+0x71>
