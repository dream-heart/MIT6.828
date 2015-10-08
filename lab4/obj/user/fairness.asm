
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 e4 0b 00 00       	call   800c25 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 0e 0e 00 00       	call   800e78 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80007c:	e8 49 01 00 00       	call   8001ca <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 11 12 80 00 	movl   $0x801211,(%esp)
  800097:	e8 2e 01 00 00       	call   8001ca <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 d9 0d 00 00       	call   800e9a <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000d6:	e8 4a 0b 00 00       	call   800c25 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 30 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800104:	e8 0a 00 00 00       	call   800113 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 ae 0a 00 00       	call   800bd3 <sys_env_destroy>
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	53                   	push   %ebx
  80012b:	83 ec 14             	sub    $0x14,%esp
  80012e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800131:	8b 13                	mov    (%ebx),%edx
  800133:	8d 42 01             	lea    0x1(%edx),%eax
  800136:	89 03                	mov    %eax,(%ebx)
  800138:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800144:	75 19                	jne    80015f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800146:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014d:	00 
  80014e:	8d 43 08             	lea    0x8(%ebx),%eax
  800151:	89 04 24             	mov    %eax,(%esp)
  800154:	e8 3d 0a 00 00       	call   800b96 <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800163:	83 c4 14             	add    $0x14,%esp
  800166:	5b                   	pop    %ebx
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800172:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800179:	00 00 00 
	b.cnt = 0;
  80017c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800183:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800186:	8b 45 0c             	mov    0xc(%ebp),%eax
  800189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018d:	8b 45 08             	mov    0x8(%ebp),%eax
  800190:	89 44 24 08          	mov    %eax,0x8(%esp)
  800194:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	c7 04 24 27 01 80 00 	movl   $0x800127,(%esp)
  8001a5:	e8 7a 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001aa:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ba:	89 04 24             	mov    %eax,(%esp)
  8001bd:	e8 d4 09 00 00       	call   800b96 <sys_cputs>

	return b.cnt;
}
  8001c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 87 ff ff ff       	call   800169 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 c3                	mov    %eax,%ebx
  800209:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80020c:	8b 45 10             	mov    0x10(%ebp),%eax
  80020f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800212:	b9 00 00 00 00       	mov    $0x0,%ecx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80021d:	39 d9                	cmp    %ebx,%ecx
  80021f:	72 05                	jb     800226 <printnum+0x36>
  800221:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800224:	77 69                	ja     80028f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800226:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800229:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80022d:	83 ee 01             	sub    $0x1,%esi
  800230:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800234:	89 44 24 08          	mov    %eax,0x8(%esp)
  800238:	8b 44 24 08          	mov    0x8(%esp),%eax
  80023c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800240:	89 c3                	mov    %eax,%ebx
  800242:	89 d6                	mov    %edx,%esi
  800244:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800247:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80024a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80024e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	e8 ec 0c 00 00       	call   800f50 <__udivdi3>
  800264:	89 d9                	mov    %ebx,%ecx
  800266:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80026a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	89 54 24 04          	mov    %edx,0x4(%esp)
  800275:	89 fa                	mov    %edi,%edx
  800277:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027a:	e8 71 ff ff ff       	call   8001f0 <printnum>
  80027f:	eb 1b                	jmp    80029c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800281:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800285:	8b 45 18             	mov    0x18(%ebp),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff d3                	call   *%ebx
  80028d:	eb 03                	jmp    800292 <printnum+0xa2>
  80028f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800292:	83 ee 01             	sub    $0x1,%esi
  800295:	85 f6                	test   %esi,%esi
  800297:	7f e8                	jg     800281 <printnum+0x91>
  800299:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 bc 0d 00 00       	call   801080 <__umoddi3>
  8002c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c8:	0f be 80 32 12 80 00 	movsbl 0x801232(%eax),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d5:	ff d0                	call   *%eax
}
  8002d7:	83 c4 3c             	add    $0x3c,%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 0a                	jae    8002fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	88 02                	mov    %al,(%edx)
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 02 00 00 00       	call   800324 <vprintfmt>
	va_end(ap);
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 3c             	sub    $0x3c,%esp
  80032d:	8b 75 08             	mov    0x8(%ebp),%esi
  800330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800333:	8b 7d 10             	mov    0x10(%ebp),%edi
  800336:	eb 11                	jmp    800349 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 84 48 04 00 00    	je     800788 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800340:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e3                	jne    800338 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	eb 1f                	jmp    800394 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037c:	eb 16                	jmp    800394 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800381:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800385:	eb 0d                	jmp    800394 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800387:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8d 47 01             	lea    0x1(%edi),%eax
  800397:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039a:	0f b6 17             	movzbl (%edi),%edx
  80039d:	0f b6 c2             	movzbl %dl,%eax
  8003a0:	83 ea 23             	sub    $0x23,%edx
  8003a3:	80 fa 55             	cmp    $0x55,%dl
  8003a6:	0f 87 bf 03 00 00    	ja     80076b <vprintfmt+0x447>
  8003ac:	0f b6 d2             	movzbl %dl,%edx
  8003af:	ff 24 95 00 13 80 00 	jmp    *0x801300(,%edx,4)
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003c4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003cb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ce:	83 f9 09             	cmp    $0x9,%ecx
  8003d1:	77 3c                	ja     80040f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d6:	eb e9                	jmp    8003c1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 40 04             	lea    0x4(%eax),%eax
  8003e6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ec:	eb 27                	jmp    800415 <vprintfmt+0xf1>
  8003ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	0f 49 c2             	cmovns %edx,%eax
  8003fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800401:	eb 91                	jmp    800394 <vprintfmt+0x70>
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800406:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040d:	eb 85                	jmp    800394 <vprintfmt+0x70>
  80040f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800412:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800419:	0f 89 75 ff ff ff    	jns    800394 <vprintfmt+0x70>
  80041f:	e9 63 ff ff ff       	jmp    800387 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 65 ff ff ff       	jmp    800394 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800432:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800444:	e9 00 ff ff ff       	jmp    800349 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 09             	cmp    $0x9,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x143>
  80045c:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 20                	jne    800487 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046b:	c7 44 24 08 4a 12 80 	movl   $0x80124a,0x8(%esp)
  800472:	00 
  800473:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800477:	89 34 24             	mov    %esi,(%esp)
  80047a:	e8 7d fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800482:	e9 c2 fe ff ff       	jmp    800349 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800487:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048b:	c7 44 24 08 53 12 80 	movl   $0x801253,0x8(%esp)
  800492:	00 
  800493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800497:	89 34 24             	mov    %esi,(%esp)
  80049a:	e8 5d fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a2:	e9 a2 fe ff ff       	jmp    800349 <vprintfmt+0x25>
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	b8 43 12 80 00       	mov    $0x801243,%eax
  8004c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 92 00 00 00    	je     80055f <vprintfmt+0x23b>
  8004cd:	85 c9                	test   %ecx,%ecx
  8004cf:	0f 8e 98 00 00 00    	jle    80056d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	e8 47 03 00 00       	call   800828 <strnlen>
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8004f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fe:	89 04 24             	mov    %eax,(%esp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1d3>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	85 c9                	test   %ecx,%ecx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c1             	cmovns %ecx,%eax
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	89 cb                	mov    %ecx,%ebx
  800527:	eb 50                	jmp    800579 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1e                	je     80054d <vprintfmt+0x229>
  80052f:	0f be d2             	movsbl %dl,%edx
  800532:	83 ea 20             	sub    $0x20,%edx
  800535:	83 fa 5e             	cmp    $0x5e,%edx
  800538:	76 13                	jbe    80054d <vprintfmt+0x229>
					putch('?', putdat);
  80053a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800541:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80054d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800550:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x255>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x255>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800580:	0f be c2             	movsbl %dl,%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	74 25                	je     8005ac <vprintfmt+0x288>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 9e                	js     800529 <vprintfmt+0x205>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 99                	jns    800529 <vprintfmt+0x205>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 1a                	jmp    8005b4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 ef 01             	sub    $0x1,%edi
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x290>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f e2                	jg     80059a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 89 fd ff ff       	jmp    800349 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 f9 01             	cmp    $0x1,%ecx
  8005c3:	7e 19                	jle    8005de <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 50 04             	mov    0x4(%eax),%edx
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 40 08             	lea    0x8(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dc:	eb 38                	jmp    800616 <vprintfmt+0x2f2>
	else if (lflag)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	74 1b                	je     8005fd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	eb 19                	jmp    800616 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800616:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800619:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800621:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800625:	0f 89 04 01 00 00    	jns    80072f <vprintfmt+0x40b>
				putch('-', putdat);
  80062b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800636:	ff d6                	call   *%esi
				num = -(long long) num;
  800638:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063e:	f7 da                	neg    %edx
  800640:	83 d1 00             	adc    $0x0,%ecx
  800643:	f7 d9                	neg    %ecx
  800645:	e9 e5 00 00 00       	jmp    80072f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064a:	83 f9 01             	cmp    $0x1,%ecx
  80064d:	7e 10                	jle    80065f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	8b 48 04             	mov    0x4(%eax),%ecx
  800657:	8d 40 08             	lea    0x8(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
  80065d:	eb 26                	jmp    800685 <vprintfmt+0x361>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	74 12                	je     800675 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
  800673:	eb 10                	jmp    800685 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067f:	8d 40 04             	lea    0x4(%eax),%eax
  800682:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800685:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80068a:	e9 a0 00 00 00       	jmp    80072f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80069a:	ff d6                	call   *%esi
			putch('X', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ad:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b9:	e9 8b fc ff ff       	jmp    800349 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006ed:	eb 40                	jmp    80072f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ef:	83 f9 01             	cmp    $0x1,%ecx
  8006f2:	7e 10                	jle    800704 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 10                	mov    (%eax),%edx
  8006f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fc:	8d 40 08             	lea    0x8(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800702:	eb 26                	jmp    80072a <vprintfmt+0x406>
	else if (lflag)
  800704:	85 c9                	test   %ecx,%ecx
  800706:	74 12                	je     80071a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
  800718:	eb 10                	jmp    80072a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80072f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800733:	89 44 24 10          	mov    %eax,0x10(%esp)
  800737:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80073a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800742:	89 14 24             	mov    %edx,(%esp)
  800745:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800749:	89 da                	mov    %ebx,%edx
  80074b:	89 f0                	mov    %esi,%eax
  80074d:	e8 9e fa ff ff       	call   8001f0 <printnum>
			break;
  800752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800755:	e9 ef fb ff ff       	jmp    800349 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	89 04 24             	mov    %eax,(%esp)
  800761:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800766:	e9 de fb ff ff       	jmp    800349 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800776:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800778:	eb 03                	jmp    80077d <vprintfmt+0x459>
  80077a:	83 ef 01             	sub    $0x1,%edi
  80077d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800781:	75 f7                	jne    80077a <vprintfmt+0x456>
  800783:	e9 c1 fb ff ff       	jmp    800349 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800788:	83 c4 3c             	add    $0x3c,%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5f                   	pop    %edi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 28             	sub    $0x28,%esp
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 30                	je     8007e1 <vsnprintf+0x51>
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	7e 2c                	jle    8007e1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ca:	c7 04 24 df 02 80 00 	movl   $0x8002df,(%esp)
  8007d1:	e8 4e fb ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007df:	eb 05                	jmp    8007e6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 82 ff ff ff       	call   800790 <vsnprintf>
	va_end(ap);

	return rc;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	eb 03                	jmp    800820 <strlen+0x10>
		n++;
  80081d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800824:	75 f7                	jne    80081d <strlen+0xd>
		n++;
	return n;
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
  800836:	eb 03                	jmp    80083b <strnlen+0x13>
		n++;
  800838:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	39 d0                	cmp    %edx,%eax
  80083d:	74 06                	je     800845 <strnlen+0x1d>
  80083f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800843:	75 f3                	jne    800838 <strnlen+0x10>
		n++;
	return n;
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800851:	89 c2                	mov    %eax,%edx
  800853:	83 c2 01             	add    $0x1,%edx
  800856:	83 c1 01             	add    $0x1,%ecx
  800859:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80085d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800860:	84 db                	test   %bl,%bl
  800862:	75 ef                	jne    800853 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800871:	89 1c 24             	mov    %ebx,(%esp)
  800874:	e8 97 ff ff ff       	call   800810 <strlen>
	strcpy(dst + len, src);
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800880:	01 d8                	add    %ebx,%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 bd ff ff ff       	call   800847 <strcpy>
	return dst;
}
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 75 08             	mov    0x8(%ebp),%esi
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089d:	89 f3                	mov    %esi,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a2:	89 f2                	mov    %esi,%edx
  8008a4:	eb 0f                	jmp    8008b5 <strncpy+0x23>
		*dst++ = *src;
  8008a6:	83 c2 01             	add    $0x1,%edx
  8008a9:	0f b6 01             	movzbl (%ecx),%eax
  8008ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008af:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b5:	39 da                	cmp    %ebx,%edx
  8008b7:	75 ed                	jne    8008a6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	75 0b                	jne    8008e2 <strlcpy+0x23>
  8008d7:	eb 1d                	jmp    8008f6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 0b                	je     8008f1 <strlcpy+0x32>
  8008e6:	0f b6 0a             	movzbl (%edx),%ecx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 ec                	jne    8008d9 <strlcpy+0x1a>
  8008ed:	89 c2                	mov    %eax,%edx
  8008ef:	eb 02                	jmp    8008f3 <strlcpy+0x34>
  8008f1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f6:	29 f0                	sub    %esi,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800905:	eb 06                	jmp    80090d <strcmp+0x11>
		p++, q++;
  800907:	83 c1 01             	add    $0x1,%ecx
  80090a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	84 c0                	test   %al,%al
  800912:	74 04                	je     800918 <strcmp+0x1c>
  800914:	3a 02                	cmp    (%edx),%al
  800916:	74 ef                	je     800907 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 c0             	movzbl %al,%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	53                   	push   %ebx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 c3                	mov    %eax,%ebx
  80092e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800931:	eb 06                	jmp    800939 <strncmp+0x17>
		n--, p++, q++;
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	74 15                	je     800952 <strncmp+0x30>
  80093d:	0f b6 08             	movzbl (%eax),%ecx
  800940:	84 c9                	test   %cl,%cl
  800942:	74 04                	je     800948 <strncmp+0x26>
  800944:	3a 0a                	cmp    (%edx),%cl
  800946:	74 eb                	je     800933 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
  800950:	eb 05                	jmp    800957 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	eb 07                	jmp    80096d <strchr+0x13>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0f                	je     800979 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f2                	jne    800966 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	eb 07                	jmp    80098e <strfind+0x13>
		if (*s == c)
  800987:	38 ca                	cmp    %cl,%dl
  800989:	74 0a                	je     800995 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f2                	jne    800987 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a3:	85 c9                	test   %ecx,%ecx
  8009a5:	74 36                	je     8009dd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ad:	75 28                	jne    8009d7 <memset+0x40>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 23                	jne    8009d7 <memset+0x40>
		c &= 0xFF;
  8009b4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b8:	89 d3                	mov    %edx,%ebx
  8009ba:	c1 e3 08             	shl    $0x8,%ebx
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	c1 e6 18             	shl    $0x18,%esi
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c1 e0 10             	shl    $0x10,%eax
  8009c7:	09 f0                	or     %esi,%eax
  8009c9:	09 c2                	or     %eax,%edx
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d2:	fc                   	cld    
  8009d3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d5:	eb 06                	jmp    8009dd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	fc                   	cld    
  8009db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f2:	39 c6                	cmp    %eax,%esi
  8009f4:	73 35                	jae    800a2b <memmove+0x47>
  8009f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	73 2e                	jae    800a2b <memmove+0x47>
		s += n;
		d += n;
  8009fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a00:	89 d6                	mov    %edx,%esi
  800a02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0a:	75 13                	jne    800a1f <memmove+0x3b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0e                	jne    800a1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a11:	83 ef 04             	sub    $0x4,%edi
  800a14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1a:	fd                   	std    
  800a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1d:	eb 09                	jmp    800a28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1f:	83 ef 01             	sub    $0x1,%edi
  800a22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a25:	fd                   	std    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a28:	fc                   	cld    
  800a29:	eb 1d                	jmp    800a48 <memmove+0x64>
  800a2b:	89 f2                	mov    %esi,%edx
  800a2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2f:	f6 c2 03             	test   $0x3,%dl
  800a32:	75 0f                	jne    800a43 <memmove+0x5f>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	75 0a                	jne    800a43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a39:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 05                	jmp    800a48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a52:	8b 45 10             	mov    0x10(%ebp),%eax
  800a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 79 ff ff ff       	call   8009e4 <memmove>
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a78:	89 d6                	mov    %edx,%esi
  800a7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7d:	eb 1a                	jmp    800a99 <memcmp+0x2c>
		if (*s1 != *s2)
  800a7f:	0f b6 02             	movzbl (%edx),%eax
  800a82:	0f b6 19             	movzbl (%ecx),%ebx
  800a85:	38 d8                	cmp    %bl,%al
  800a87:	74 0a                	je     800a93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c0             	movzbl %al,%eax
  800a8c:	0f b6 db             	movzbl %bl,%ebx
  800a8f:	29 d8                	sub    %ebx,%eax
  800a91:	eb 0f                	jmp    800aa2 <memcmp+0x35>
		s1++, s2++;
  800a93:	83 c2 01             	add    $0x1,%edx
  800a96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a99:	39 f2                	cmp    %esi,%edx
  800a9b:	75 e2                	jne    800a7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab4:	eb 07                	jmp    800abd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab6:	38 08                	cmp    %cl,(%eax)
  800ab8:	74 07                	je     800ac1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	39 d0                	cmp    %edx,%eax
  800abf:	72 f5                	jb     800ab6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  800acc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acf:	eb 03                	jmp    800ad4 <strtol+0x11>
		s++;
  800ad1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad4:	0f b6 0a             	movzbl (%edx),%ecx
  800ad7:	80 f9 09             	cmp    $0x9,%cl
  800ada:	74 f5                	je     800ad1 <strtol+0xe>
  800adc:	80 f9 20             	cmp    $0x20,%cl
  800adf:	74 f0                	je     800ad1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae1:	80 f9 2b             	cmp    $0x2b,%cl
  800ae4:	75 0a                	jne    800af0 <strtol+0x2d>
		s++;
  800ae6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aee:	eb 11                	jmp    800b01 <strtol+0x3e>
  800af0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af5:	80 f9 2d             	cmp    $0x2d,%cl
  800af8:	75 07                	jne    800b01 <strtol+0x3e>
		s++, neg = 1;
  800afa:	8d 52 01             	lea    0x1(%edx),%edx
  800afd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b06:	75 15                	jne    800b1d <strtol+0x5a>
  800b08:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0b:	75 10                	jne    800b1d <strtol+0x5a>
  800b0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b11:	75 0a                	jne    800b1d <strtol+0x5a>
		s += 2, base = 16;
  800b13:	83 c2 02             	add    $0x2,%edx
  800b16:	b8 10 00 00 00       	mov    $0x10,%eax
  800b1b:	eb 10                	jmp    800b2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	75 0c                	jne    800b2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b21:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b23:	80 3a 30             	cmpb   $0x30,(%edx)
  800b26:	75 05                	jne    800b2d <strtol+0x6a>
		s++, base = 8;
  800b28:	83 c2 01             	add    $0x1,%edx
  800b2b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b35:	0f b6 0a             	movzbl (%edx),%ecx
  800b38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b3b:	89 f0                	mov    %esi,%eax
  800b3d:	3c 09                	cmp    $0x9,%al
  800b3f:	77 08                	ja     800b49 <strtol+0x86>
			dig = *s - '0';
  800b41:	0f be c9             	movsbl %cl,%ecx
  800b44:	83 e9 30             	sub    $0x30,%ecx
  800b47:	eb 20                	jmp    800b69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b4c:	89 f0                	mov    %esi,%eax
  800b4e:	3c 19                	cmp    $0x19,%al
  800b50:	77 08                	ja     800b5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b52:	0f be c9             	movsbl %cl,%ecx
  800b55:	83 e9 57             	sub    $0x57,%ecx
  800b58:	eb 0f                	jmp    800b69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b5d:	89 f0                	mov    %esi,%eax
  800b5f:	3c 19                	cmp    $0x19,%al
  800b61:	77 16                	ja     800b79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b63:	0f be c9             	movsbl %cl,%ecx
  800b66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b6c:	7d 0f                	jge    800b7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b77:	eb bc                	jmp    800b35 <strtol+0x72>
  800b79:	89 d8                	mov    %ebx,%eax
  800b7b:	eb 02                	jmp    800b7f <strtol+0xbc>
  800b7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b83:	74 05                	je     800b8a <strtol+0xc7>
		*endptr = (char *) s;
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b8a:	f7 d8                	neg    %eax
  800b8c:	85 ff                	test   %edi,%edi
  800b8e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	89 c3                	mov    %eax,%ebx
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	89 c6                	mov    %eax,%esi
  800bad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be1:	b8 03 00 00 00       	mov    $0x3,%eax
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 cb                	mov    %ecx,%ebx
  800beb:	89 cf                	mov    %ecx,%edi
  800bed:	89 ce                	mov    %ecx,%esi
  800bef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 28                	jle    800c1d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c00:	00 
  800c01:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c08:	00 
  800c09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c10:	00 
  800c11:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800c18:	e8 d7 02 00 00       	call   800ef4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1d:	83 c4 2c             	add    $0x2c,%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 02 00 00 00       	mov    $0x2,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_yield>:

void
sys_yield(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	be 00 00 00 00       	mov    $0x0,%esi
  800c71:	b8 04 00 00 00       	mov    $0x4,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	89 f7                	mov    %esi,%edi
  800c81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 28                	jle    800caf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c92:	00 
  800c93:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca2:	00 
  800ca3:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800caa:	e8 45 02 00 00       	call   800ef4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800caf:	83 c4 2c             	add    $0x2c,%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 28                	jle    800d02 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cde:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800ced:	00 
  800cee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf5:	00 
  800cf6:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800cfd:	e8 f2 01 00 00       	call   800ef4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d02:	83 c4 2c             	add    $0x2c,%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 28                	jle    800d55 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d31:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d38:	00 
  800d39:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800d50:	e8 9f 01 00 00       	call   800ef4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d55:	83 c4 2c             	add    $0x2c,%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 df                	mov    %ebx,%edi
  800d78:	89 de                	mov    %ebx,%esi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 28                	jle    800da8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d84:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d8b:	00 
  800d8c:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800d93:	00 
  800d94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9b:	00 
  800d9c:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800da3:	e8 4c 01 00 00       	call   800ef4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da8:	83 c4 2c             	add    $0x2c,%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbe:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 de                	mov    %ebx,%esi
  800dcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7e 28                	jle    800dfb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dde:	00 
  800ddf:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800de6:	00 
  800de7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dee:	00 
  800def:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800df6:	e8 f9 00 00 00       	call   800ef4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfb:	83 c4 2c             	add    $0x2c,%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	be 00 00 00 00       	mov    $0x0,%esi
  800e0e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	89 cf                	mov    %ecx,%edi
  800e40:	89 ce                	mov    %ecx,%esi
  800e42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 28                	jle    800e70 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e53:	00 
  800e54:	c7 44 24 08 88 14 80 	movl   $0x801488,0x8(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e63:	00 
  800e64:	c7 04 24 a5 14 80 00 	movl   $0x8014a5,(%esp)
  800e6b:	e8 84 00 00 00       	call   800ef4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e70:	83 c4 2c             	add    $0x2c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e7e:	c7 44 24 08 b3 14 80 	movl   $0x8014b3,0x8(%esp)
  800e85:	00 
  800e86:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800e8d:	00 
  800e8e:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  800e95:	e8 5a 00 00 00       	call   800ef4 <_panic>

00800e9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800ea0:	c7 44 24 08 d6 14 80 	movl   $0x8014d6,0x8(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800eaf:	00 
  800eb0:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  800eb7:	e8 38 00 00 00       	call   800ef4 <_panic>

00800ebc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ec7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800eca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ed0:	8b 52 50             	mov    0x50(%edx),%edx
  800ed3:	39 ca                	cmp    %ecx,%edx
  800ed5:	75 0d                	jne    800ee4 <ipc_find_env+0x28>
			return envs[i].env_id;
  800ed7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eda:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800edf:	8b 40 40             	mov    0x40(%eax),%eax
  800ee2:	eb 0e                	jmp    800ef2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ee4:	83 c0 01             	add    $0x1,%eax
  800ee7:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eec:	75 d9                	jne    800ec7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eee:	66 b8 00 00          	mov    $0x0,%ax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800efc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eff:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f05:	e8 1b fd ff ff       	call   800c25 <sys_getenvid>
  800f0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f18:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f20:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  800f27:	e8 9e f2 ff ff       	call   8001ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f30:	8b 45 10             	mov    0x10(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 2e f2 ff ff       	call   800169 <vcprintf>
	cprintf("\n");
  800f3b:	c7 04 24 0f 12 80 00 	movl   $0x80120f,(%esp)
  800f42:	e8 83 f2 ff ff       	call   8001ca <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f47:	cc                   	int3   
  800f48:	eb fd                	jmp    800f47 <_panic+0x53>
  800f4a:	00 00                	add    %al,(%eax)
  800f4c:	00 00                	add    %al,(%eax)
	...

00800f50 <__udivdi3>:
  800f50:	83 ec 1c             	sub    $0x1c,%esp
  800f53:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f63:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f6b:	85 ff                	test   %edi,%edi
  800f6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f75:	89 cd                	mov    %ecx,%ebp
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	75 33                	jne    800fb0 <__udivdi3+0x60>
  800f7d:	39 f1                	cmp    %esi,%ecx
  800f7f:	77 57                	ja     800fd8 <__udivdi3+0x88>
  800f81:	85 c9                	test   %ecx,%ecx
  800f83:	75 0b                	jne    800f90 <__udivdi3+0x40>
  800f85:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8a:	31 d2                	xor    %edx,%edx
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 c1                	mov    %eax,%ecx
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	31 d2                	xor    %edx,%edx
  800f94:	f7 f1                	div    %ecx
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9c:	f7 f1                	div    %ecx
  800f9e:	89 f2                	mov    %esi,%edx
  800fa0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fa8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fac:	83 c4 1c             	add    $0x1c,%esp
  800faf:	c3                   	ret    
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	31 c0                	xor    %eax,%eax
  800fb4:	39 f7                	cmp    %esi,%edi
  800fb6:	77 e8                	ja     800fa0 <__udivdi3+0x50>
  800fb8:	0f bd cf             	bsr    %edi,%ecx
  800fbb:	83 f1 1f             	xor    $0x1f,%ecx
  800fbe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc2:	75 2c                	jne    800ff0 <__udivdi3+0xa0>
  800fc4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fc8:	76 04                	jbe    800fce <__udivdi3+0x7e>
  800fca:	39 f7                	cmp    %esi,%edi
  800fcc:	73 d2                	jae    800fa0 <__udivdi3+0x50>
  800fce:	31 d2                	xor    %edx,%edx
  800fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd5:	eb c9                	jmp    800fa0 <__udivdi3+0x50>
  800fd7:	90                   	nop
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	f7 f1                	div    %ecx
  800fdc:	31 d2                	xor    %edx,%edx
  800fde:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fe2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fe6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fea:	83 c4 1c             	add    $0x1c,%esp
  800fed:	c3                   	ret    
  800fee:	66 90                	xchg   %ax,%ax
  800ff0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff5:	b8 20 00 00 00       	mov    $0x20,%eax
  800ffa:	89 ea                	mov    %ebp,%edx
  800ffc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801000:	d3 e7                	shl    %cl,%edi
  801002:	89 c1                	mov    %eax,%ecx
  801004:	d3 ea                	shr    %cl,%edx
  801006:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100b:	09 fa                	or     %edi,%edx
  80100d:	89 f7                	mov    %esi,%edi
  80100f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801013:	89 f2                	mov    %esi,%edx
  801015:	8b 74 24 08          	mov    0x8(%esp),%esi
  801019:	d3 e5                	shl    %cl,%ebp
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	d3 ef                	shr    %cl,%edi
  80101f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801024:	d3 e2                	shl    %cl,%edx
  801026:	89 c1                	mov    %eax,%ecx
  801028:	d3 ee                	shr    %cl,%esi
  80102a:	09 d6                	or     %edx,%esi
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	89 f0                	mov    %esi,%eax
  801030:	f7 74 24 0c          	divl   0xc(%esp)
  801034:	89 d7                	mov    %edx,%edi
  801036:	89 c6                	mov    %eax,%esi
  801038:	f7 e5                	mul    %ebp
  80103a:	39 d7                	cmp    %edx,%edi
  80103c:	72 22                	jb     801060 <__udivdi3+0x110>
  80103e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801042:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801047:	d3 e5                	shl    %cl,%ebp
  801049:	39 c5                	cmp    %eax,%ebp
  80104b:	73 04                	jae    801051 <__udivdi3+0x101>
  80104d:	39 d7                	cmp    %edx,%edi
  80104f:	74 0f                	je     801060 <__udivdi3+0x110>
  801051:	89 f0                	mov    %esi,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	e9 46 ff ff ff       	jmp    800fa0 <__udivdi3+0x50>
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	8d 46 ff             	lea    -0x1(%esi),%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	8b 74 24 10          	mov    0x10(%esp),%esi
  801069:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80106d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801071:	83 c4 1c             	add    $0x1c,%esp
  801074:	c3                   	ret    
	...

00801080 <__umoddi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801087:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801093:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ed                	test   %ebp,%ebp
  80109d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cf                	mov    %ecx,%edi
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	89 f2                	mov    %esi,%edx
  8010ac:	75 1a                	jne    8010c8 <__umoddi3+0x48>
  8010ae:	39 f1                	cmp    %esi,%ecx
  8010b0:	76 4e                	jbe    801100 <__umoddi3+0x80>
  8010b2:	f7 f1                	div    %ecx
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	c3                   	ret    
  8010c8:	39 f5                	cmp    %esi,%ebp
  8010ca:	77 54                	ja     801120 <__umoddi3+0xa0>
  8010cc:	0f bd c5             	bsr    %ebp,%eax
  8010cf:	83 f0 1f             	xor    $0x1f,%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	75 60                	jne    801138 <__umoddi3+0xb8>
  8010d8:	3b 0c 24             	cmp    (%esp),%ecx
  8010db:	0f 87 07 01 00 00    	ja     8011e8 <__umoddi3+0x168>
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	8b 34 24             	mov    (%esp),%esi
  8010e6:	29 ce                	sub    %ecx,%esi
  8010e8:	19 ea                	sbb    %ebp,%edx
  8010ea:	89 34 24             	mov    %esi,(%esp)
  8010ed:	8b 04 24             	mov    (%esp),%eax
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	85 c9                	test   %ecx,%ecx
  801102:	75 0b                	jne    80110f <__umoddi3+0x8f>
  801104:	b8 01 00 00 00       	mov    $0x1,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	89 f0                	mov    %esi,%eax
  801111:	31 d2                	xor    %edx,%edx
  801113:	f7 f1                	div    %ecx
  801115:	8b 04 24             	mov    (%esp),%eax
  801118:	f7 f1                	div    %ecx
  80111a:	eb 98                	jmp    8010b4 <__umoddi3+0x34>
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f2                	mov    %esi,%edx
  801122:	8b 74 24 10          	mov    0x10(%esp),%esi
  801126:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80112e:	83 c4 1c             	add    $0x1c,%esp
  801131:	c3                   	ret    
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113d:	89 e8                	mov    %ebp,%eax
  80113f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801144:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 e0                	shl    %cl,%eax
  80114c:	89 e9                	mov    %ebp,%ecx
  80114e:	d3 ea                	shr    %cl,%edx
  801150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801155:	09 c2                	or     %eax,%edx
  801157:	8b 44 24 08          	mov    0x8(%esp),%eax
  80115b:	89 14 24             	mov    %edx,(%esp)
  80115e:	89 f2                	mov    %esi,%edx
  801160:	d3 e7                	shl    %cl,%edi
  801162:	89 e9                	mov    %ebp,%ecx
  801164:	d3 ea                	shr    %cl,%edx
  801166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	d3 e6                	shl    %cl,%esi
  801171:	89 e9                	mov    %ebp,%ecx
  801173:	d3 e8                	shr    %cl,%eax
  801175:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117a:	09 f0                	or     %esi,%eax
  80117c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801180:	f7 34 24             	divl   (%esp)
  801183:	d3 e6                	shl    %cl,%esi
  801185:	89 74 24 08          	mov    %esi,0x8(%esp)
  801189:	89 d6                	mov    %edx,%esi
  80118b:	f7 e7                	mul    %edi
  80118d:	39 d6                	cmp    %edx,%esi
  80118f:	89 c1                	mov    %eax,%ecx
  801191:	89 d7                	mov    %edx,%edi
  801193:	72 3f                	jb     8011d4 <__umoddi3+0x154>
  801195:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801199:	72 35                	jb     8011d0 <__umoddi3+0x150>
  80119b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80119f:	29 c8                	sub    %ecx,%eax
  8011a1:	19 fe                	sbb    %edi,%esi
  8011a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	d3 e8                	shr    %cl,%eax
  8011ac:	89 e9                	mov    %ebp,%ecx
  8011ae:	d3 e2                	shl    %cl,%edx
  8011b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b5:	09 d0                	or     %edx,%eax
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	d3 ea                	shr    %cl,%edx
  8011bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c7:	83 c4 1c             	add    $0x1c,%esp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	39 d6                	cmp    %edx,%esi
  8011d2:	75 c7                	jne    80119b <__umoddi3+0x11b>
  8011d4:	89 d7                	mov    %edx,%edi
  8011d6:	89 c1                	mov    %eax,%ecx
  8011d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011dc:	1b 3c 24             	sbb    (%esp),%edi
  8011df:	eb ba                	jmp    80119b <__umoddi3+0x11b>
  8011e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	0f 82 f1 fe ff ff    	jb     8010e1 <__umoddi3+0x61>
  8011f0:	e9 f8 fe ff ff       	jmp    8010ed <__umoddi3+0x6d>
