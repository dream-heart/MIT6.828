
obj/user/pingpong：     文件格式 elf32-i386


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
  80002c:	e8 ca 00 00 00       	call   8000fb <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	//cprintf("the peid = %d\n", sys_getenvid());
	if ((who = fork()) != 0) {
  80003c:	e8 d1 0f 00 00       	call   801012 <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	75 05                	jne    80004f <umain+0x1c>
		//cprintf("send is successful\n");
	}

	while (1) {
		//cprintf("children = 0\n");
		uint32_t i = ipc_recv(&who, 0, 0);
  80004a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004d:	eb 3e                	jmp    80008d <umain+0x5a>
	envid_t who;
	//cprintf("the peid = %d\n", sys_getenvid());
	if ((who = fork()) != 0) {
		// get the ball rolling
		//cprintf("the father = %d\n", who);
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004f:	e8 01 0c 00 00       	call   800c55 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 a0 17 80 00 	movl   $0x8017a0,(%esp)
  800063:	e8 92 01 00 00       	call   8001fa <cprintf>
		ipc_send(who, 0, 0, 0);
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800083:	89 04 24             	mov    %eax,(%esp)
  800086:	e8 63 12 00 00       	call   8012ee <ipc_send>
  80008b:	eb bd                	jmp    80004a <umain+0x17>
		//cprintf("send is successful\n");
	}

	while (1) {
		//cprintf("children = 0\n");
		uint32_t i = ipc_recv(&who, 0, 0);
  80008d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800094:	00 
  800095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009c:	00 
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 ab 11 00 00       	call   801250 <ipc_recv>
  8000a5:	89 c3                	mov    %eax,%ebx
				//cprintf("i =1");
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000aa:	e8 a6 0b 00 00       	call   800c55 <sys_getenvid>
  8000af:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bb:	c7 04 24 b6 17 80 00 	movl   $0x8017b6,(%esp)
  8000c2:	e8 33 01 00 00       	call   8001fa <cprintf>
		if (i == 10)
  8000c7:	83 fb 0a             	cmp    $0xa,%ebx
  8000ca:	74 27                	je     8000f3 <umain+0xc0>
			return;
		i++;
  8000cc:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000de:	00 
  8000df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e6:	89 04 24             	mov    %eax,(%esp)
  8000e9:	e8 00 12 00 00       	call   8012ee <ipc_send>
		
		if (i == 10)
  8000ee:	83 fb 0a             	cmp    $0xa,%ebx
  8000f1:	75 9a                	jne    80008d <umain+0x5a>
			return;
	}

}
  8000f3:	83 c4 2c             	add    $0x2c,%esp
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 10             	sub    $0x10,%esp
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800109:	e8 47 0b 00 00       	call   800c55 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x30>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012f:	89 1c 24             	mov    %ebx,(%esp)
  800132:	e8 fc fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800137:	e8 07 00 00 00       	call   800143 <exit>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800150:	e8 ae 0a 00 00       	call   800c03 <sys_env_destroy>
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	53                   	push   %ebx
  80015b:	83 ec 14             	sub    $0x14,%esp
  80015e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800161:	8b 13                	mov    (%ebx),%edx
  800163:	8d 42 01             	lea    0x1(%edx),%eax
  800166:	89 03                	mov    %eax,(%ebx)
  800168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800174:	75 19                	jne    80018f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800176:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80017d:	00 
  80017e:	8d 43 08             	lea    0x8(%ebx),%eax
  800181:	89 04 24             	mov    %eax,(%esp)
  800184:	e8 3d 0a 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  800189:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	83 c4 14             	add    $0x14,%esp
  800196:	5b                   	pop    %ebx
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a9:	00 00 00 
	b.cnt = 0;
  8001ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ce:	c7 04 24 57 01 80 00 	movl   $0x800157,(%esp)
  8001d5:	e8 7a 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	e8 d4 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  8001f2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800200:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 04 24             	mov    %eax,(%esp)
  80020d:	e8 87 ff ff ff       	call   800199 <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    
  800214:	66 90                	xchg   %ax,%ax
  800216:	66 90                	xchg   %ax,%ax
  800218:	66 90                	xchg   %ax,%ax
  80021a:	66 90                	xchg   %ax,%ax
  80021c:	66 90                	xchg   %ax,%ax
  80021e:	66 90                	xchg   %ax,%ax

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 c3                	mov    %eax,%ebx
  800239:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	b9 00 00 00 00       	mov    $0x0,%ecx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024d:	39 d9                	cmp    %ebx,%ecx
  80024f:	72 05                	jb     800256 <printnum+0x36>
  800251:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800254:	77 69                	ja     8002bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800259:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025d:	83 ee 01             	sub    $0x1,%esi
  800260:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8b 44 24 08          	mov    0x8(%esp),%eax
  80026c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800270:	89 c3                	mov    %eax,%ebx
  800272:	89 d6                	mov    %edx,%esi
  800274:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800277:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80027a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80027e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80028b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028f:	e8 6c 12 00 00       	call   801500 <__udivdi3>
  800294:	89 d9                	mov    %ebx,%ecx
  800296:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a5:	89 fa                	mov    %edi,%edx
  8002a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002aa:	e8 71 ff ff ff       	call   800220 <printnum>
  8002af:	eb 1b                	jmp    8002cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff d3                	call   *%ebx
  8002bd:	eb 03                	jmp    8002c2 <printnum+0xa2>
  8002bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 ee 01             	sub    $0x1,%esi
  8002c5:	85 f6                	test   %esi,%esi
  8002c7:	7f e8                	jg     8002b1 <printnum+0x91>
  8002c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ef:	e8 3c 13 00 00       	call   801630 <__umoddi3>
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	0f be 80 d3 17 80 00 	movsbl 0x8017d3(%eax),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800305:	ff d0                	call   *%eax
}
  800307:	83 c4 3c             	add    $0x3c,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 0a                	jae    80032a <sprintputch+0x1b>
		*b->buf++ = ch;
  800320:	8d 4a 01             	lea    0x1(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	88 02                	mov    %al,(%edx)
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800332:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	e8 02 00 00 00       	call   800354 <vprintfmt>
	va_end(ap);
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 3c             	sub    $0x3c,%esp
  80035d:	8b 75 08             	mov    0x8(%ebp),%esi
  800360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800363:	8b 7d 10             	mov    0x10(%ebp),%edi
  800366:	eb 11                	jmp    800379 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 84 48 04 00 00    	je     8007b8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800370:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	83 c7 01             	add    $0x1,%edi
  80037c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800380:	83 f8 25             	cmp    $0x25,%eax
  800383:	75 e3                	jne    800368 <vprintfmt+0x14>
  800385:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800389:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800390:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800397:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a3:	eb 1f                	jmp    8003c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ac:	eb 16                	jmp    8003c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b5:	eb 0d                	jmp    8003c4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8d 47 01             	lea    0x1(%edi),%eax
  8003c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ca:	0f b6 17             	movzbl (%edi),%edx
  8003cd:	0f b6 c2             	movzbl %dl,%eax
  8003d0:	83 ea 23             	sub    $0x23,%edx
  8003d3:	80 fa 55             	cmp    $0x55,%dl
  8003d6:	0f 87 bf 03 00 00    	ja     80079b <vprintfmt+0x447>
  8003dc:	0f b6 d2             	movzbl %dl,%edx
  8003df:	ff 24 95 a0 18 80 00 	jmp    *0x8018a0(,%edx,4)
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003f4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003f8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003fb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003fe:	83 f9 09             	cmp    $0x9,%ecx
  800401:	77 3c                	ja     80043f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800403:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800406:	eb e9                	jmp    8003f1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 40 04             	lea    0x4(%eax),%eax
  800416:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041c:	eb 27                	jmp    800445 <vprintfmt+0xf1>
  80041e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	0f 49 c2             	cmovns %edx,%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	eb 91                	jmp    8003c4 <vprintfmt+0x70>
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043d:	eb 85                	jmp    8003c4 <vprintfmt+0x70>
  80043f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800442:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	0f 89 75 ff ff ff    	jns    8003c4 <vprintfmt+0x70>
  80044f:	e9 63 ff ff ff       	jmp    8003b7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800454:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045a:	e9 65 ff ff ff       	jmp    8003c4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800462:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800466:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800474:	e9 00 ff ff ff       	jmp    800379 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800480:	8b 00                	mov    (%eax),%eax
  800482:	99                   	cltd   
  800483:	31 d0                	xor    %edx,%eax
  800485:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800487:	83 f8 09             	cmp    $0x9,%eax
  80048a:	7f 0b                	jg     800497 <vprintfmt+0x143>
  80048c:	8b 14 85 00 1a 80 00 	mov    0x801a00(,%eax,4),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	75 20                	jne    8004b7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800497:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049b:	c7 44 24 08 eb 17 80 	movl   $0x8017eb,0x8(%esp)
  8004a2:	00 
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 34 24             	mov    %esi,(%esp)
  8004aa:	e8 7d fe ff ff       	call   80032c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 c2 fe ff ff       	jmp    800379 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bb:	c7 44 24 08 f4 17 80 	movl   $0x8017f4,0x8(%esp)
  8004c2:	00 
  8004c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c7:	89 34 24             	mov    %esi,(%esp)
  8004ca:	e8 5d fe ff ff       	call   80032c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d2:	e9 a2 fe ff ff       	jmp    800379 <vprintfmt+0x25>
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004e7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	b8 e4 17 80 00       	mov    $0x8017e4,%eax
  8004f0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f7:	0f 84 92 00 00 00    	je     80058f <vprintfmt+0x23b>
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	0f 8e 98 00 00 00    	jle    80059d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 3c 24             	mov    %edi,(%esp)
  80050c:	e8 47 03 00 00       	call   800858 <strnlen>
  800511:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800514:	29 c1                	sub    %eax,%ecx
  800516:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800519:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800520:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800523:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	eb 0f                	jmp    800536 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	85 ff                	test   %edi,%edi
  800538:	7f ed                	jg     800527 <vprintfmt+0x1d3>
  80053a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800540:	85 c9                	test   %ecx,%ecx
  800542:	b8 00 00 00 00       	mov    $0x0,%eax
  800547:	0f 49 c1             	cmovns %ecx,%eax
  80054a:	29 c1                	sub    %eax,%ecx
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	89 cb                	mov    %ecx,%ebx
  800557:	eb 50                	jmp    8005a9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055d:	74 1e                	je     80057d <vprintfmt+0x229>
  80055f:	0f be d2             	movsbl %dl,%edx
  800562:	83 ea 20             	sub    $0x20,%edx
  800565:	83 fa 5e             	cmp    $0x5e,%edx
  800568:	76 13                	jbe    80057d <vprintfmt+0x229>
					putch('?', putdat);
  80056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800571:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	eb 0d                	jmp    80058a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80057d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800580:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800584:	89 04 24             	mov    %eax,(%esp)
  800587:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	eb 1a                	jmp    8005a9 <vprintfmt+0x255>
  80058f:	89 75 08             	mov    %esi,0x8(%ebp)
  800592:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800598:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059b:	eb 0c                	jmp    8005a9 <vprintfmt+0x255>
  80059d:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a9:	83 c7 01             	add    $0x1,%edi
  8005ac:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b0:	0f be c2             	movsbl %dl,%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	74 25                	je     8005dc <vprintfmt+0x288>
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	78 9e                	js     800559 <vprintfmt+0x205>
  8005bb:	83 ee 01             	sub    $0x1,%esi
  8005be:	79 99                	jns    800559 <vprintfmt+0x205>
  8005c0:	89 df                	mov    %ebx,%edi
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c8:	eb 1a                	jmp    8005e4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	eb 08                	jmp    8005e4 <vprintfmt+0x290>
  8005dc:	89 df                	mov    %ebx,%edi
  8005de:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e4:	85 ff                	test   %edi,%edi
  8005e6:	7f e2                	jg     8005ca <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005eb:	e9 89 fd ff ff       	jmp    800379 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f0:	83 f9 01             	cmp    $0x1,%ecx
  8005f3:	7e 19                	jle    80060e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 50 04             	mov    0x4(%eax),%edx
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
  80060c:	eb 38                	jmp    800646 <vprintfmt+0x2f2>
	else if (lflag)
  80060e:	85 c9                	test   %ecx,%ecx
  800610:	74 1b                	je     80062d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
  80062b:	eb 19                	jmp    800646 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	89 c1                	mov    %eax,%ecx
  800637:	c1 f9 1f             	sar    $0x1f,%ecx
  80063a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800646:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800649:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800651:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800655:	0f 89 04 01 00 00    	jns    80075f <vprintfmt+0x40b>
				putch('-', putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80066b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80066e:	f7 da                	neg    %edx
  800670:	83 d1 00             	adc    $0x0,%ecx
  800673:	f7 d9                	neg    %ecx
  800675:	e9 e5 00 00 00       	jmp    80075f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067a:	83 f9 01             	cmp    $0x1,%ecx
  80067d:	7e 10                	jle    80068f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	8b 48 04             	mov    0x4(%eax),%ecx
  800687:	8d 40 08             	lea    0x8(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
  80068d:	eb 26                	jmp    8006b5 <vprintfmt+0x361>
	else if (lflag)
  80068f:	85 c9                	test   %ecx,%ecx
  800691:	74 12                	je     8006a5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a3:	eb 10                	jmp    8006b5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006b5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006ba:	e9 a0 00 00 00       	jmp    80075f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ca:	ff d6                	call   *%esi
			putch('X', putdat);
  8006cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006d7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006e4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006e9:	e9 8b fc ff ff       	jmp    800379 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800706:	ff d6                	call   *%esi
			num = (unsigned long long)
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800718:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80071d:	eb 40                	jmp    80075f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071f:	83 f9 01             	cmp    $0x1,%ecx
  800722:	7e 10                	jle    800734 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8b 48 04             	mov    0x4(%eax),%ecx
  80072c:	8d 40 08             	lea    0x8(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
  800732:	eb 26                	jmp    80075a <vprintfmt+0x406>
	else if (lflag)
  800734:	85 c9                	test   %ecx,%ecx
  800736:	74 12                	je     80074a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
  800748:	eb 10                	jmp    80075a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80075a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800763:	89 44 24 10          	mov    %eax,0x10(%esp)
  800767:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80076a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800772:	89 14 24             	mov    %edx,(%esp)
  800775:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800779:	89 da                	mov    %ebx,%edx
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	e8 9e fa ff ff       	call   800220 <printnum>
			break;
  800782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800785:	e9 ef fb ff ff       	jmp    800379 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800796:	e9 de fb ff ff       	jmp    800379 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a8:	eb 03                	jmp    8007ad <vprintfmt+0x459>
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b1:	75 f7                	jne    8007aa <vprintfmt+0x456>
  8007b3:	e9 c1 fb ff ff       	jmp    800379 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007b8:	83 c4 3c             	add    $0x3c,%esp
  8007bb:	5b                   	pop    %ebx
  8007bc:	5e                   	pop    %esi
  8007bd:	5f                   	pop    %edi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 28             	sub    $0x28,%esp
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	74 30                	je     800811 <vsnprintf+0x51>
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	7e 2c                	jle    800811 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fa:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  800801:	e8 4e fb ff ff       	call   800354 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800806:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800809:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080f:	eb 05                	jmp    800816 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800811:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800821:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800825:	8b 45 10             	mov    0x10(%ebp),%eax
  800828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	e8 82 ff ff ff       	call   8007c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	eb 03                	jmp    800850 <strlen+0x10>
		n++;
  80084d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800854:	75 f7                	jne    80084d <strlen+0xd>
		n++;
	return n;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strnlen+0x13>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	74 06                	je     800875 <strnlen+0x1d>
  80086f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800873:	75 f3                	jne    800868 <strnlen+0x10>
		n++;
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800881:	89 c2                	mov    %eax,%edx
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800890:	84 db                	test   %bl,%bl
  800892:	75 ef                	jne    800883 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a1:	89 1c 24             	mov    %ebx,(%esp)
  8008a4:	e8 97 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 bd ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008ba:	89 d8                	mov    %ebx,%eax
  8008bc:	83 c4 08             	add    $0x8,%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
		*dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800903:	85 c9                	test   %ecx,%ecx
  800905:	75 0b                	jne    800912 <strlcpy+0x23>
  800907:	eb 1d                	jmp    800926 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c2 01             	add    $0x1,%edx
  80090f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800912:	39 d8                	cmp    %ebx,%eax
  800914:	74 0b                	je     800921 <strlcpy+0x32>
  800916:	0f b6 0a             	movzbl (%edx),%ecx
  800919:	84 c9                	test   %cl,%cl
  80091b:	75 ec                	jne    800909 <strlcpy+0x1a>
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	eb 02                	jmp    800923 <strlcpy+0x34>
  800921:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800923:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800926:	29 f0                	sub    %esi,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800935:	eb 06                	jmp    80093d <strcmp+0x11>
		p++, q++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093d:	0f b6 01             	movzbl (%ecx),%eax
  800940:	84 c0                	test   %al,%al
  800942:	74 04                	je     800948 <strcmp+0x1c>
  800944:	3a 02                	cmp    (%edx),%al
  800946:	74 ef                	je     800937 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 c0             	movzbl %al,%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	53                   	push   %ebx
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800961:	eb 06                	jmp    800969 <strncmp+0x17>
		n--, p++, q++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800969:	39 d8                	cmp    %ebx,%eax
  80096b:	74 15                	je     800982 <strncmp+0x30>
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	84 c9                	test   %cl,%cl
  800972:	74 04                	je     800978 <strncmp+0x26>
  800974:	3a 0a                	cmp    (%edx),%cl
  800976:	74 eb                	je     800963 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
  800980:	eb 05                	jmp    800987 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800994:	eb 07                	jmp    80099d <strchr+0x13>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0f                	je     8009a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	eb 07                	jmp    8009be <strfind+0x13>
		if (*s == c)
  8009b7:	38 ca                	cmp    %cl,%dl
  8009b9:	74 0a                	je     8009c5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	0f b6 10             	movzbl (%eax),%edx
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f2                	jne    8009b7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 36                	je     800a0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dd:	75 28                	jne    800a07 <memset+0x40>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 23                	jne    800a07 <memset+0x40>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d6                	mov    %edx,%esi
  8009ef:	c1 e6 18             	shl    $0x18,%esi
  8009f2:	89 d0                	mov    %edx,%eax
  8009f4:	c1 e0 10             	shl    $0x10,%eax
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	89 d0                	mov    %edx,%eax
  8009fd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a22:	39 c6                	cmp    %eax,%esi
  800a24:	73 35                	jae    800a5b <memmove+0x47>
  800a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	73 2e                	jae    800a5b <memmove+0x47>
		s += n;
		d += n;
  800a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3a:	75 13                	jne    800a4f <memmove+0x3b>
  800a3c:	f6 c1 03             	test   $0x3,%cl
  800a3f:	75 0e                	jne    800a4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a41:	83 ef 04             	sub    $0x4,%edi
  800a44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4d:	eb 09                	jmp    800a58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a55:	fd                   	std    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a58:	fc                   	cld    
  800a59:	eb 1d                	jmp    800a78 <memmove+0x64>
  800a5b:	89 f2                	mov    %esi,%edx
  800a5d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 0f                	jne    800a73 <memmove+0x5f>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0a                	jne    800a73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a69:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 05                	jmp    800a78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	fc                   	cld    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 79 ff ff ff       	call   800a14 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 02             	movzbl (%edx),%eax
  800ab2:	0f b6 19             	movzbl (%ecx),%ebx
  800ab5:	38 d8                	cmp    %bl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f2                	cmp    %esi,%edx
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	80 f9 09             	cmp    $0x9,%cl
  800b0a:	74 f5                	je     800b01 <strtol+0xe>
  800b0c:	80 f9 20             	cmp    $0x20,%cl
  800b0f:	74 f0                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b11:	80 f9 2b             	cmp    $0x2b,%cl
  800b14:	75 0a                	jne    800b20 <strtol+0x2d>
		s++;
  800b16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb 11                	jmp    800b31 <strtol+0x3e>
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b25:	80 f9 2d             	cmp    $0x2d,%cl
  800b28:	75 07                	jne    800b31 <strtol+0x3e>
		s++, neg = 1;
  800b2a:	8d 52 01             	lea    0x1(%edx),%edx
  800b2d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b36:	75 15                	jne    800b4d <strtol+0x5a>
  800b38:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3b:	75 10                	jne    800b4d <strtol+0x5a>
  800b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b41:	75 0a                	jne    800b4d <strtol+0x5a>
		s += 2, base = 16;
  800b43:	83 c2 02             	add    $0x2,%edx
  800b46:	b8 10 00 00 00       	mov    $0x10,%eax
  800b4b:	eb 10                	jmp    800b5d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 0c                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b51:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b53:	80 3a 30             	cmpb   $0x30,(%edx)
  800b56:	75 05                	jne    800b5d <strtol+0x6a>
		s++, base = 8;
  800b58:	83 c2 01             	add    $0x1,%edx
  800b5b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b62:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b65:	0f b6 0a             	movzbl (%edx),%ecx
  800b68:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b6b:	89 f0                	mov    %esi,%eax
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	77 08                	ja     800b79 <strtol+0x86>
			dig = *s - '0';
  800b71:	0f be c9             	movsbl %cl,%ecx
  800b74:	83 e9 30             	sub    $0x30,%ecx
  800b77:	eb 20                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b79:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b7c:	89 f0                	mov    %esi,%eax
  800b7e:	3c 19                	cmp    $0x19,%al
  800b80:	77 08                	ja     800b8a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b82:	0f be c9             	movsbl %cl,%ecx
  800b85:	83 e9 57             	sub    $0x57,%ecx
  800b88:	eb 0f                	jmp    800b99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b8a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	3c 19                	cmp    $0x19,%al
  800b91:	77 16                	ja     800ba9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b93:	0f be c9             	movsbl %cl,%ecx
  800b96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b99:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b9c:	7d 0f                	jge    800bad <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ba5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ba7:	eb bc                	jmp    800b65 <strtol+0x72>
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	eb 02                	jmp    800baf <strtol+0xbc>
  800bad:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800baf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb3:	74 05                	je     800bba <strtol+0xc7>
		*endptr = (char *) s;
  800bb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bba:	f7 d8                	neg    %eax
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 44 c3             	cmove  %ebx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	b8 03 00 00 00       	mov    $0x3,%eax
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 28                	jle    800c4d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c29:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c30:	00 
  800c31:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800c38:	00 
  800c39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c40:	00 
  800c41:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800c48:	e8 88 07 00 00       	call   8013d5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	83 c4 2c             	add    $0x2c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800cda:	e8 f6 06 00 00       	call   8013d5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800d2d:	e8 a3 06 00 00       	call   8013d5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800d80:	e8 50 06 00 00       	call   8013d5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800dd3:	e8 fd 05 00 00       	call   8013d5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 09 00 00 00       	mov    $0x9,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800e26:	e8 aa 05 00 00       	call   8013d5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e39:	be 00 00 00 00       	mov    $0x0,%esi
  800e3e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 cb                	mov    %ecx,%ebx
  800e6e:	89 cf                	mov    %ecx,%edi
  800e70:	89 ce                	mov    %ecx,%esi
  800e72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e74:	85 c0                	test   %eax,%eax
  800e76:	7e 28                	jle    800ea0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e83:	00 
  800e84:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e93:	00 
  800e94:	c7 04 24 45 1a 80 00 	movl   $0x801a45,(%esp)
  800e9b:	e8 35 05 00 00       	call   8013d5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea0:	83 c4 2c             	add    $0x2c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 20             	sub    $0x20,%esp
  800eb0:	8b 5d 08             	mov    0x8(%ebp),%ebx


	void *addr = (void *) utf->utf_fault_va;
  800eb3:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  800eb5:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  800eb9:	75 3f                	jne    800efa <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800ebb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebf:	c7 04 24 53 1a 80 00 	movl   $0x801a53,(%esp)
  800ec6:	e8 2f f3 ff ff       	call   8001fa <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  800ecb:	8b 43 28             	mov    0x28(%ebx),%eax
  800ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed2:	c7 04 24 63 1a 80 00 	movl   $0x801a63,(%esp)
  800ed9:	e8 1c f3 ff ff       	call   8001fa <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800ede:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  800ef5:	e8 db 04 00 00       	call   8013d5 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800efa:	89 f0                	mov    %esi,%eax
  800efc:	c1 e8 0c             	shr    $0xc,%eax
  800eff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800f06:	f6 c4 08             	test   $0x8,%ah
  800f09:	75 1c                	jne    800f27 <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  800f0b:	c7 44 24 08 d0 1a 80 	movl   $0x801ad0,0x8(%esp)
  800f12:	00 
  800f13:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f1a:	00 
  800f1b:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  800f22:	e8 ae 04 00 00       	call   8013d5 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  800f27:	e8 29 fd ff ff       	call   800c55 <sys_getenvid>
  800f2c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f3b:	00 
  800f3c:	89 04 24             	mov    %eax,(%esp)
  800f3f:	e8 4f fd ff ff       	call   800c93 <sys_page_alloc>
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 1c                	jns    800f64 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  800f48:	c7 44 24 08 f0 1a 80 	movl   $0x801af0,0x8(%esp)
  800f4f:	00 
  800f50:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f57:	00 
  800f58:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  800f5f:	e8 71 04 00 00       	call   8013d5 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  800f64:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f71:	00 
  800f72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f76:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f7d:	e8 fa fa ff ff       	call   800a7c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  800f82:	e8 ce fc ff ff       	call   800c55 <sys_getenvid>
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	e8 c7 fc ff ff       	call   800c55 <sys_getenvid>
  800f8e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f95:	00 
  800f96:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f9e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa5:	00 
  800fa6:	89 04 24             	mov    %eax,(%esp)
  800fa9:	e8 39 fd ff ff       	call   800ce7 <sys_page_map>
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 20                	jns    800fd2 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  800fb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb6:	c7 44 24 08 18 1b 80 	movl   $0x801b18,0x8(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800fc5:	00 
  800fc6:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  800fcd:	e8 03 04 00 00       	call   8013d5 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  800fd2:	e8 7e fc ff ff       	call   800c55 <sys_getenvid>
  800fd7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fde:	00 
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 53 fd ff ff       	call   800d3a <sys_page_unmap>
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 20                	jns    80100b <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  800feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fef:	c7 44 24 08 48 1b 80 	movl   $0x801b48,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  801006:	e8 ca 03 00 00       	call   8013d5 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  80100b:	83 c4 20             	add    $0x20,%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80101b:	c7 04 24 a8 0e 80 00 	movl   $0x800ea8,(%esp)
  801022:	e8 04 04 00 00       	call   80142b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801027:	b8 07 00 00 00       	mov    $0x7,%eax
  80102c:	cd 30                	int    $0x30
  80102e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801031:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	79 20                	jns    801058 <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801038:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103c:	c7 44 24 08 7c 1b 80 	movl   $0x801b7c,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  801053:	e8 7d 03 00 00       	call   8013d5 <_panic>
	if(childEid == 0){
  801058:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80105c:	75 1c                	jne    80107a <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80105e:	e8 f2 fb ff ff       	call   800c55 <sys_getenvid>
  801063:	25 ff 03 00 00       	and    $0x3ff,%eax
  801068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80106b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801070:	a3 04 20 80 00       	mov    %eax,0x802004
		return childEid;
  801075:	e9 a0 01 00 00       	jmp    80121a <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80107a:	c7 44 24 04 c1 14 80 	movl   $0x8014c1,0x4(%esp)
  801081:	00 
  801082:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801085:	89 04 24             	mov    %eax,(%esp)
  801088:	e8 53 fd ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
  80108d:	89 c7                	mov    %eax,%edi
	if(r < 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 20                	jns    8010b3 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801093:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801097:	c7 44 24 08 b0 1b 80 	movl   $0x801bb0,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8010a6:	00 
  8010a7:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  8010ae:	e8 22 03 00 00       	call   8013d5 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8010b3:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	c1 ea 16             	shr    $0x16,%edx
  8010ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d1:	f6 c2 01             	test   $0x1,%dl
  8010d4:	0f 84 f7 00 00 00    	je     8011d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8010da:	c1 e8 0c             	shr    $0xc,%eax
  8010dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8010e4:	f6 c2 04             	test   $0x4,%dl
  8010e7:	0f 84 e4 00 00 00    	je     8011d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8010ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8010f4:	a8 01                	test   $0x1,%al
  8010f6:	0f 84 d5 00 00 00    	je     8011d1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8010fc:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801102:	75 20                	jne    801124 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801104:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80110b:	00 
  80110c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801113:	ee 
  801114:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801117:	89 04 24             	mov    %eax,(%esp)
  80111a:	e8 74 fb ff ff       	call   800c93 <sys_page_alloc>
  80111f:	e9 84 00 00 00       	jmp    8011a8 <fork+0x196>
  801124:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80112a:	89 f8                	mov    %edi,%eax
  80112c:	c1 e8 0c             	shr    $0xc,%eax
  80112f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801136:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80113b:	83 f8 01             	cmp    $0x1,%eax
  80113e:	19 db                	sbb    %ebx,%ebx
  801140:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801146:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80114c:	e8 04 fb ff ff       	call   800c55 <sys_getenvid>
  801151:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801155:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801159:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80115c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801160:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801164:	89 04 24             	mov    %eax,(%esp)
  801167:	e8 7b fb ff ff       	call   800ce7 <sys_page_map>
  80116c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 35                	js     8011a8 <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801173:	e8 dd fa ff ff       	call   800c55 <sys_getenvid>
  801178:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80117b:	e8 d5 fa ff ff       	call   800c55 <sys_getenvid>
  801180:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801184:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801188:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80118b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801193:	89 04 24             	mov    %eax,(%esp)
  801196:	e8 4c fb ff ff       	call   800ce7 <sys_page_map>
  80119b:	85 c0                	test   %eax,%eax
  80119d:	bf 00 00 00 00       	mov    $0x0,%edi
  8011a2:	0f 4f c7             	cmovg  %edi,%eax
  8011a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  8011a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ac:	79 23                	jns    8011d1 <fork+0x1bf>
  8011ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8011b1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b5:	c7 44 24 08 f0 1b 80 	movl   $0x801bf0,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  8011cc:	e8 04 02 00 00       	call   8013d5 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011d1:	89 f1                	mov    %esi,%ecx
  8011d3:	89 f0                	mov    %esi,%eax
  8011d5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8011db:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8011e1:	0f 85 de fe ff ff    	jne    8010c5 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8011e7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011ee:	00 
  8011ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	e8 93 fb ff ff       	call   800d8d <sys_env_set_status>
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	79 1c                	jns    80121a <fork+0x208>
		panic("sys_env_set_status");
  8011fe:	c7 44 24 08 7f 1a 80 	movl   $0x801a7f,0x8(%esp)
  801205:	00 
  801206:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80120d:	00 
  80120e:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  801215:	e8 bb 01 00 00       	call   8013d5 <_panic>
	return childEid;
}
  80121a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80121d:	83 c4 2c             	add    $0x2c,%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <sfork>:

// Challenge!
int
sfork(void)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80122b:	c7 44 24 08 92 1a 80 	movl   $0x801a92,0x8(%esp)
  801232:	00 
  801233:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80123a:	00 
  80123b:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  801242:	e8 8e 01 00 00       	call   8013d5 <_panic>
  801247:	66 90                	xchg   %ax,%ax
  801249:	66 90                	xchg   %ax,%ax
  80124b:	66 90                	xchg   %ax,%ax
  80124d:	66 90                	xchg   %ax,%ax
  80124f:	90                   	nop

00801250 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 10             	sub    $0x10,%esp
  801258:	8b 75 08             	mov    0x8(%ebp),%esi
  80125b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801261:	85 c0                	test   %eax,%eax
  801263:	75 0e                	jne    801273 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801265:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80126c:	e8 e5 fb ff ff       	call   800e56 <sys_ipc_recv>
  801271:	eb 08                	jmp    80127b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801273:	89 04 24             	mov    %eax,(%esp)
  801276:	e8 db fb ff ff       	call   800e56 <sys_ipc_recv>
	if(r == 0){
  80127b:	85 c0                	test   %eax,%eax
  80127d:	8d 76 00             	lea    0x0(%esi),%esi
  801280:	75 1e                	jne    8012a0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801282:	85 f6                	test   %esi,%esi
  801284:	74 0a                	je     801290 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801286:	a1 04 20 80 00       	mov    0x802004,%eax
  80128b:	8b 40 74             	mov    0x74(%eax),%eax
  80128e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801290:	85 db                	test   %ebx,%ebx
  801292:	74 2c                	je     8012c0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801294:	a1 04 20 80 00       	mov    0x802004,%eax
  801299:	8b 40 78             	mov    0x78(%eax),%eax
  80129c:	89 03                	mov    %eax,(%ebx)
  80129e:	eb 20                	jmp    8012c0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8012a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a4:	c7 44 24 08 18 1c 80 	movl   $0x801c18,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012b3:	00 
  8012b4:	c7 04 24 94 1c 80 00 	movl   $0x801c94,(%esp)
  8012bb:	e8 15 01 00 00       	call   8013d5 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8012c0:	a1 04 20 80 00       	mov    0x802004,%eax
  8012c5:	8b 50 70             	mov    0x70(%eax),%edx
  8012c8:	85 d2                	test   %edx,%edx
  8012ca:	75 13                	jne    8012df <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8012cc:	8b 40 48             	mov    0x48(%eax),%eax
  8012cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d3:	c7 04 24 48 1c 80 00 	movl   $0x801c48,(%esp)
  8012da:	e8 1b ef ff ff       	call   8001fa <cprintf>
	return thisenv->env_ipc_value;
  8012df:	a1 04 20 80 00       	mov    0x802004,%eax
  8012e4:	8b 40 70             	mov    0x70(%eax),%eax
	

	


}
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	5b                   	pop    %ebx
  8012eb:	5e                   	pop    %esi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 1c             	sub    $0x1c,%esp
  8012f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	
	int r =0;
	while(1){
		if(pg == 0)
  8012fd:	85 f6                	test   %esi,%esi
  8012ff:	75 22                	jne    801323 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801301:	8b 45 14             	mov    0x14(%ebp),%eax
  801304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801308:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80130f:	ee 
  801310:	8b 45 0c             	mov    0xc(%ebp),%eax
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	89 3c 24             	mov    %edi,(%esp)
  80131a:	e8 14 fb ff ff       	call   800e33 <sys_ipc_try_send>
  80131f:	89 c3                	mov    %eax,%ebx
  801321:	eb 1c                	jmp    80133f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80132e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801331:	89 44 24 04          	mov    %eax,0x4(%esp)
  801335:	89 3c 24             	mov    %edi,(%esp)
  801338:	e8 f6 fa ff ff       	call   800e33 <sys_ipc_try_send>
  80133d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80133f:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801342:	74 3e                	je     801382 <ipc_send+0x94>
  801344:	89 d8                	mov    %ebx,%eax
  801346:	c1 e8 1f             	shr    $0x1f,%eax
  801349:	84 c0                	test   %al,%al
  80134b:	74 35                	je     801382 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80134d:	e8 03 f9 ff ff       	call   800c55 <sys_getenvid>
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	c7 04 24 9e 1c 80 00 	movl   $0x801c9e,(%esp)
  80135d:	e8 98 ee ff ff       	call   8001fa <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801362:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801366:	c7 44 24 08 6c 1c 80 	movl   $0x801c6c,0x8(%esp)
  80136d:	00 
  80136e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801375:	00 
  801376:	c7 04 24 94 1c 80 00 	movl   $0x801c94,(%esp)
  80137d:	e8 53 00 00 00       	call   8013d5 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  801382:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801385:	75 0e                	jne    801395 <ipc_send+0xa7>
			sys_yield();
  801387:	e8 e8 f8 ff ff       	call   800c74 <sys_yield>
		else break;
	}
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	e9 68 ff ff ff       	jmp    8012fd <ipc_send+0xf>
	



}
  801395:	83 c4 1c             	add    $0x1c,%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b1:	8b 52 50             	mov    0x50(%edx),%edx
  8013b4:	39 ca                	cmp    %ecx,%edx
  8013b6:	75 0d                	jne    8013c5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013bb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013c0:	8b 40 40             	mov    0x40(%eax),%eax
  8013c3:	eb 0e                	jmp    8013d3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013c5:	83 c0 01             	add    $0x1,%eax
  8013c8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013cd:	75 d9                	jne    8013a8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013cf:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013e0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8013e6:	e8 6a f8 ff ff       	call   800c55 <sys_getenvid>
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013f9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801401:	c7 04 24 b0 1c 80 00 	movl   $0x801cb0,(%esp)
  801408:	e8 ed ed ff ff       	call   8001fa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80140d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801411:	8b 45 10             	mov    0x10(%ebp),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 7d ed ff ff       	call   800199 <vcprintf>
	cprintf("\n");
  80141c:	c7 04 24 c7 17 80 00 	movl   $0x8017c7,(%esp)
  801423:	e8 d2 ed ff ff       	call   8001fa <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801428:	cc                   	int3   
  801429:	eb fd                	jmp    801428 <_panic+0x53>

0080142b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801431:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801438:	75 44                	jne    80147e <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80143a:	a1 04 20 80 00       	mov    0x802004,%eax
  80143f:	8b 40 48             	mov    0x48(%eax),%eax
  801442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801449:	00 
  80144a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801451:	ee 
  801452:	89 04 24             	mov    %eax,(%esp)
  801455:	e8 39 f8 ff ff       	call   800c93 <sys_page_alloc>
		if( r < 0)
  80145a:	85 c0                	test   %eax,%eax
  80145c:	79 20                	jns    80147e <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80145e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801462:	c7 44 24 08 d4 1c 80 	movl   $0x801cd4,0x8(%esp)
  801469:	00 
  80146a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801471:	00 
  801472:	c7 04 24 30 1d 80 00 	movl   $0x801d30,(%esp)
  801479:	e8 57 ff ff ff       	call   8013d5 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80147e:	8b 45 08             	mov    0x8(%ebp),%eax
  801481:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801486:	e8 ca f7 ff ff       	call   800c55 <sys_getenvid>
  80148b:	c7 44 24 04 c1 14 80 	movl   $0x8014c1,0x4(%esp)
  801492:	00 
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 45 f9 ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
  80149b:	85 c0                	test   %eax,%eax
  80149d:	79 20                	jns    8014bf <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80149f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a3:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8014b2:	00 
  8014b3:	c7 04 24 30 1d 80 00 	movl   $0x801d30,(%esp)
  8014ba:	e8 16 ff ff ff       	call   8013d5 <_panic>


}
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014c2:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8014c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014c9:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8014cc:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8014d0:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8014d4:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8014d8:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8014db:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8014de:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8014e1:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8014e5:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8014e9:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8014ed:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8014f1:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8014f5:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  8014f9:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8014fd:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  8014fe:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8014ff:	c3                   	ret    

00801500 <__udivdi3>:
  801500:	55                   	push   %ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	8b 44 24 28          	mov    0x28(%esp),%eax
  80150a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80150e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801512:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801516:	85 c0                	test   %eax,%eax
  801518:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80151c:	89 ea                	mov    %ebp,%edx
  80151e:	89 0c 24             	mov    %ecx,(%esp)
  801521:	75 2d                	jne    801550 <__udivdi3+0x50>
  801523:	39 e9                	cmp    %ebp,%ecx
  801525:	77 61                	ja     801588 <__udivdi3+0x88>
  801527:	85 c9                	test   %ecx,%ecx
  801529:	89 ce                	mov    %ecx,%esi
  80152b:	75 0b                	jne    801538 <__udivdi3+0x38>
  80152d:	b8 01 00 00 00       	mov    $0x1,%eax
  801532:	31 d2                	xor    %edx,%edx
  801534:	f7 f1                	div    %ecx
  801536:	89 c6                	mov    %eax,%esi
  801538:	31 d2                	xor    %edx,%edx
  80153a:	89 e8                	mov    %ebp,%eax
  80153c:	f7 f6                	div    %esi
  80153e:	89 c5                	mov    %eax,%ebp
  801540:	89 f8                	mov    %edi,%eax
  801542:	f7 f6                	div    %esi
  801544:	89 ea                	mov    %ebp,%edx
  801546:	83 c4 0c             	add    $0xc,%esp
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
  80154d:	8d 76 00             	lea    0x0(%esi),%esi
  801550:	39 e8                	cmp    %ebp,%eax
  801552:	77 24                	ja     801578 <__udivdi3+0x78>
  801554:	0f bd e8             	bsr    %eax,%ebp
  801557:	83 f5 1f             	xor    $0x1f,%ebp
  80155a:	75 3c                	jne    801598 <__udivdi3+0x98>
  80155c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801560:	39 34 24             	cmp    %esi,(%esp)
  801563:	0f 86 9f 00 00 00    	jbe    801608 <__udivdi3+0x108>
  801569:	39 d0                	cmp    %edx,%eax
  80156b:	0f 82 97 00 00 00    	jb     801608 <__udivdi3+0x108>
  801571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801578:	31 d2                	xor    %edx,%edx
  80157a:	31 c0                	xor    %eax,%eax
  80157c:	83 c4 0c             	add    $0xc,%esp
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
  801583:	90                   	nop
  801584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801588:	89 f8                	mov    %edi,%eax
  80158a:	f7 f1                	div    %ecx
  80158c:	31 d2                	xor    %edx,%edx
  80158e:	83 c4 0c             	add    $0xc,%esp
  801591:	5e                   	pop    %esi
  801592:	5f                   	pop    %edi
  801593:	5d                   	pop    %ebp
  801594:	c3                   	ret    
  801595:	8d 76 00             	lea    0x0(%esi),%esi
  801598:	89 e9                	mov    %ebp,%ecx
  80159a:	8b 3c 24             	mov    (%esp),%edi
  80159d:	d3 e0                	shl    %cl,%eax
  80159f:	89 c6                	mov    %eax,%esi
  8015a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8015a6:	29 e8                	sub    %ebp,%eax
  8015a8:	89 c1                	mov    %eax,%ecx
  8015aa:	d3 ef                	shr    %cl,%edi
  8015ac:	89 e9                	mov    %ebp,%ecx
  8015ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8015b2:	8b 3c 24             	mov    (%esp),%edi
  8015b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8015b9:	89 d6                	mov    %edx,%esi
  8015bb:	d3 e7                	shl    %cl,%edi
  8015bd:	89 c1                	mov    %eax,%ecx
  8015bf:	89 3c 24             	mov    %edi,(%esp)
  8015c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c6:	d3 ee                	shr    %cl,%esi
  8015c8:	89 e9                	mov    %ebp,%ecx
  8015ca:	d3 e2                	shl    %cl,%edx
  8015cc:	89 c1                	mov    %eax,%ecx
  8015ce:	d3 ef                	shr    %cl,%edi
  8015d0:	09 d7                	or     %edx,%edi
  8015d2:	89 f2                	mov    %esi,%edx
  8015d4:	89 f8                	mov    %edi,%eax
  8015d6:	f7 74 24 08          	divl   0x8(%esp)
  8015da:	89 d6                	mov    %edx,%esi
  8015dc:	89 c7                	mov    %eax,%edi
  8015de:	f7 24 24             	mull   (%esp)
  8015e1:	39 d6                	cmp    %edx,%esi
  8015e3:	89 14 24             	mov    %edx,(%esp)
  8015e6:	72 30                	jb     801618 <__udivdi3+0x118>
  8015e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015ec:	89 e9                	mov    %ebp,%ecx
  8015ee:	d3 e2                	shl    %cl,%edx
  8015f0:	39 c2                	cmp    %eax,%edx
  8015f2:	73 05                	jae    8015f9 <__udivdi3+0xf9>
  8015f4:	3b 34 24             	cmp    (%esp),%esi
  8015f7:	74 1f                	je     801618 <__udivdi3+0x118>
  8015f9:	89 f8                	mov    %edi,%eax
  8015fb:	31 d2                	xor    %edx,%edx
  8015fd:	e9 7a ff ff ff       	jmp    80157c <__udivdi3+0x7c>
  801602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801608:	31 d2                	xor    %edx,%edx
  80160a:	b8 01 00 00 00       	mov    $0x1,%eax
  80160f:	e9 68 ff ff ff       	jmp    80157c <__udivdi3+0x7c>
  801614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801618:	8d 47 ff             	lea    -0x1(%edi),%eax
  80161b:	31 d2                	xor    %edx,%edx
  80161d:	83 c4 0c             	add    $0xc,%esp
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    
  801624:	66 90                	xchg   %ax,%ax
  801626:	66 90                	xchg   %ax,%ax
  801628:	66 90                	xchg   %ax,%ax
  80162a:	66 90                	xchg   %ax,%ax
  80162c:	66 90                	xchg   %ax,%ax
  80162e:	66 90                	xchg   %ax,%ax

00801630 <__umoddi3>:
  801630:	55                   	push   %ebp
  801631:	57                   	push   %edi
  801632:	56                   	push   %esi
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 44 24 28          	mov    0x28(%esp),%eax
  80163a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80163e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801642:	89 c7                	mov    %eax,%edi
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	8b 44 24 30          	mov    0x30(%esp),%eax
  80164c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801650:	89 34 24             	mov    %esi,(%esp)
  801653:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801657:	85 c0                	test   %eax,%eax
  801659:	89 c2                	mov    %eax,%edx
  80165b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80165f:	75 17                	jne    801678 <__umoddi3+0x48>
  801661:	39 fe                	cmp    %edi,%esi
  801663:	76 4b                	jbe    8016b0 <__umoddi3+0x80>
  801665:	89 c8                	mov    %ecx,%eax
  801667:	89 fa                	mov    %edi,%edx
  801669:	f7 f6                	div    %esi
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	31 d2                	xor    %edx,%edx
  80166f:	83 c4 14             	add    $0x14,%esp
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    
  801676:	66 90                	xchg   %ax,%ax
  801678:	39 f8                	cmp    %edi,%eax
  80167a:	77 54                	ja     8016d0 <__umoddi3+0xa0>
  80167c:	0f bd e8             	bsr    %eax,%ebp
  80167f:	83 f5 1f             	xor    $0x1f,%ebp
  801682:	75 5c                	jne    8016e0 <__umoddi3+0xb0>
  801684:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801688:	39 3c 24             	cmp    %edi,(%esp)
  80168b:	0f 87 e7 00 00 00    	ja     801778 <__umoddi3+0x148>
  801691:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801695:	29 f1                	sub    %esi,%ecx
  801697:	19 c7                	sbb    %eax,%edi
  801699:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80169d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016a9:	83 c4 14             	add    $0x14,%esp
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    
  8016b0:	85 f6                	test   %esi,%esi
  8016b2:	89 f5                	mov    %esi,%ebp
  8016b4:	75 0b                	jne    8016c1 <__umoddi3+0x91>
  8016b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bb:	31 d2                	xor    %edx,%edx
  8016bd:	f7 f6                	div    %esi
  8016bf:	89 c5                	mov    %eax,%ebp
  8016c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016c5:	31 d2                	xor    %edx,%edx
  8016c7:	f7 f5                	div    %ebp
  8016c9:	89 c8                	mov    %ecx,%eax
  8016cb:	f7 f5                	div    %ebp
  8016cd:	eb 9c                	jmp    80166b <__umoddi3+0x3b>
  8016cf:	90                   	nop
  8016d0:	89 c8                	mov    %ecx,%eax
  8016d2:	89 fa                	mov    %edi,%edx
  8016d4:	83 c4 14             	add    $0x14,%esp
  8016d7:	5e                   	pop    %esi
  8016d8:	5f                   	pop    %edi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    
  8016db:	90                   	nop
  8016dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e0:	8b 04 24             	mov    (%esp),%eax
  8016e3:	be 20 00 00 00       	mov    $0x20,%esi
  8016e8:	89 e9                	mov    %ebp,%ecx
  8016ea:	29 ee                	sub    %ebp,%esi
  8016ec:	d3 e2                	shl    %cl,%edx
  8016ee:	89 f1                	mov    %esi,%ecx
  8016f0:	d3 e8                	shr    %cl,%eax
  8016f2:	89 e9                	mov    %ebp,%ecx
  8016f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f8:	8b 04 24             	mov    (%esp),%eax
  8016fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8016ff:	89 fa                	mov    %edi,%edx
  801701:	d3 e0                	shl    %cl,%eax
  801703:	89 f1                	mov    %esi,%ecx
  801705:	89 44 24 08          	mov    %eax,0x8(%esp)
  801709:	8b 44 24 10          	mov    0x10(%esp),%eax
  80170d:	d3 ea                	shr    %cl,%edx
  80170f:	89 e9                	mov    %ebp,%ecx
  801711:	d3 e7                	shl    %cl,%edi
  801713:	89 f1                	mov    %esi,%ecx
  801715:	d3 e8                	shr    %cl,%eax
  801717:	89 e9                	mov    %ebp,%ecx
  801719:	09 f8                	or     %edi,%eax
  80171b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80171f:	f7 74 24 04          	divl   0x4(%esp)
  801723:	d3 e7                	shl    %cl,%edi
  801725:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801729:	89 d7                	mov    %edx,%edi
  80172b:	f7 64 24 08          	mull   0x8(%esp)
  80172f:	39 d7                	cmp    %edx,%edi
  801731:	89 c1                	mov    %eax,%ecx
  801733:	89 14 24             	mov    %edx,(%esp)
  801736:	72 2c                	jb     801764 <__umoddi3+0x134>
  801738:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80173c:	72 22                	jb     801760 <__umoddi3+0x130>
  80173e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801742:	29 c8                	sub    %ecx,%eax
  801744:	19 d7                	sbb    %edx,%edi
  801746:	89 e9                	mov    %ebp,%ecx
  801748:	89 fa                	mov    %edi,%edx
  80174a:	d3 e8                	shr    %cl,%eax
  80174c:	89 f1                	mov    %esi,%ecx
  80174e:	d3 e2                	shl    %cl,%edx
  801750:	89 e9                	mov    %ebp,%ecx
  801752:	d3 ef                	shr    %cl,%edi
  801754:	09 d0                	or     %edx,%eax
  801756:	89 fa                	mov    %edi,%edx
  801758:	83 c4 14             	add    $0x14,%esp
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    
  80175f:	90                   	nop
  801760:	39 d7                	cmp    %edx,%edi
  801762:	75 da                	jne    80173e <__umoddi3+0x10e>
  801764:	8b 14 24             	mov    (%esp),%edx
  801767:	89 c1                	mov    %eax,%ecx
  801769:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80176d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801771:	eb cb                	jmp    80173e <__umoddi3+0x10e>
  801773:	90                   	nop
  801774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801778:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80177c:	0f 82 0f ff ff ff    	jb     801691 <__umoddi3+0x61>
  801782:	e9 1a ff ff ff       	jmp    8016a1 <__umoddi3+0x71>
