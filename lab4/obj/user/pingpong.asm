
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 ba 0e 00 00       	call   800efc <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 e4 0b 00 00       	call   800c34 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  80005f:	e8 9b 01 00 00       	call   8001ff <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 db 0e 00 00       	call   800f62 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 9e 0e 00 00       	call   800f40 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 88 0b 00 00       	call   800c34 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 f6 12 80 00 	movl   $0x8012f6,(%esp)
  8000bf:	e8 3b 01 00 00       	call   8001ff <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 77 0e 00 00       	call   800f62 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80010a:	e8 25 0b 00 00       	call   800c34 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 7d 0a 00 00       	call   800bd7 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	83 c0 01             	add    $0x1,%eax
  800172:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800174:	3d ff 00 00 00       	cmp    $0xff,%eax
  800179:	75 19                	jne    800194 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800182:	00 
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 ea 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	83 c4 14             	add    $0x14,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ae:	00 00 00 
	b.cnt = 0;
  8001b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d3:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001da:	e8 8e 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 81 09 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  8001f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800205:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	8b 45 08             	mov    0x8(%ebp),%eax
  80020f:	89 04 24             	mov    %eax,(%esp)
  800212:	e8 87 ff ff ff       	call   80019e <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    
  800219:	00 00                	add    %al,(%eax)
  80021b:	00 00                	add    %al,(%eax)
  80021d:	00 00                	add    %al,(%eax)
	...

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
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	85 c0                	test   %eax,%eax
  800242:	75 08                	jne    80024c <printnum+0x2c>
  800244:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 59                	ja     8002a5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800250:	83 eb 01             	sub    $0x1,%ebx
  800253:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800257:	8b 45 10             	mov    0x10(%ebp),%eax
  80025a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800262:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800266:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026d:	00 
  80026e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027b:	e8 a0 0d 00 00       	call   801020 <__udivdi3>
  800280:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800284:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028f:	89 fa                	mov    %edi,%edx
  800291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800294:	e8 87 ff ff ff       	call   800220 <printnum>
  800299:	eb 11                	jmp    8002ac <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029f:	89 34 24             	mov    %esi,(%esp)
  8002a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f ef                	jg     80029b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c2:	00 
  8002c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	e8 7b 0e 00 00       	call   801150 <__umoddi3>
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	0f be 80 13 13 80 00 	movsbl 0x801313(%eax),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002e6:	83 c4 3c             	add    $0x3c,%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800332:	8b 10                	mov    (%eax),%edx
  800334:	3b 50 04             	cmp    0x4(%eax),%edx
  800337:	73 0a                	jae    800343 <sprintputch+0x1b>
		*b->buf++ = ch;
  800339:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033c:	88 0a                	mov    %cl,(%edx)
  80033e:	83 c2 01             	add    $0x1,%edx
  800341:	89 10                	mov    %edx,(%eax)
}
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80034b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800352:	8b 45 10             	mov    0x10(%ebp),%eax
  800355:	89 44 24 08          	mov    %eax,0x8(%esp)
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 02 00 00 00       	call   80036d <vprintfmt>
	va_end(ap);
}
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 4c             	sub    $0x4c,%esp
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800379:	8b 75 10             	mov    0x10(%ebp),%esi
  80037c:	eb 12                	jmp    800390 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 bf 03 00 00    	je     800745 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800386:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038a:	89 04 24             	mov    %eax,(%esp)
  80038d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	0f b6 06             	movzbl (%esi),%eax
  800393:	83 c6 01             	add    $0x1,%esi
  800396:	83 f8 25             	cmp    $0x25,%eax
  800399:	75 e3                	jne    80037e <vprintfmt+0x11>
  80039b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ab:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ba:	eb 2b                	jmp    8003e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003c3:	eb 22                	jmp    8003e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003cc:	eb 19                	jmp    8003e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d8:	eb 0d                	jmp    8003e7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	0f b6 16             	movzbl (%esi),%edx
  8003ea:	0f b6 c2             	movzbl %dl,%eax
  8003ed:	8d 7e 01             	lea    0x1(%esi),%edi
  8003f0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003f3:	83 ea 23             	sub    $0x23,%edx
  8003f6:	80 fa 55             	cmp    $0x55,%dl
  8003f9:	0f 87 28 03 00 00    	ja     800727 <vprintfmt+0x3ba>
  8003ff:	0f b6 d2             	movzbl %dl,%edx
  800402:	ff 24 95 e0 13 80 00 	jmp    *0x8013e0(,%edx,4)
  800409:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80040c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800413:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800418:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80041b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80041f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800422:	8d 50 d0             	lea    -0x30(%eax),%edx
  800425:	83 fa 09             	cmp    $0x9,%edx
  800428:	77 2f                	ja     800459 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042d:	eb e9                	jmp    800418 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800440:	eb 1a                	jmp    80045c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800445:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800449:	79 9c                	jns    8003e7 <vprintfmt+0x7a>
  80044b:	eb 81                	jmp    8003ce <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800450:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800457:	eb 8e                	jmp    8003e7 <vprintfmt+0x7a>
  800459:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80045c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800460:	79 85                	jns    8003e7 <vprintfmt+0x7a>
  800462:	e9 73 ff ff ff       	jmp    8003da <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800467:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046d:	e9 75 ff ff ff       	jmp    8003e7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 04 24             	mov    %eax,(%esp)
  800484:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048a:	e9 01 ff ff ff       	jmp    800390 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	89 c2                	mov    %eax,%edx
  80049c:	c1 fa 1f             	sar    $0x1f,%edx
  80049f:	31 d0                	xor    %edx,%eax
  8004a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 f8 09             	cmp    $0x9,%eax
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x146>
  8004a8:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	75 23                	jne    8004d6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b7:	c7 44 24 08 2b 13 80 	movl   $0x80132b,0x8(%esp)
  8004be:	00 
  8004bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c6:	89 3c 24             	mov    %edi,(%esp)
  8004c9:	e8 77 fe ff ff       	call   800345 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d1:	e9 ba fe ff ff       	jmp    800390 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004da:	c7 44 24 08 34 13 80 	movl   $0x801334,0x8(%esp)
  8004e1:	00 
  8004e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e9:	89 3c 24             	mov    %edi,(%esp)
  8004ec:	e8 54 fe ff ff       	call   800345 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f4:	e9 97 fe ff ff       	jmp    800390 <vprintfmt+0x23>
  8004f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 50 04             	lea    0x4(%eax),%edx
  800508:	89 55 14             	mov    %edx,0x14(%ebp)
  80050b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80050d:	85 f6                	test   %esi,%esi
  80050f:	ba 24 13 80 00       	mov    $0x801324,%edx
  800514:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800517:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051b:	0f 8e 8c 00 00 00    	jle    8005ad <vprintfmt+0x240>
  800521:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800525:	0f 84 82 00 00 00    	je     8005ad <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052f:	89 34 24             	mov    %esi,(%esp)
  800532:	e8 b1 02 00 00       	call   8007e8 <strnlen>
  800537:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053a:	29 c2                	sub    %eax,%edx
  80053c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80053f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800543:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800546:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800549:	89 de                	mov    %ebx,%esi
  80054b:	89 d3                	mov    %edx,%ebx
  80054d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	eb 0d                	jmp    80055e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	89 3c 24             	mov    %edi,(%esp)
  800558:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	83 eb 01             	sub    $0x1,%ebx
  80055e:	85 db                	test   %ebx,%ebx
  800560:	7f ef                	jg     800551 <vprintfmt+0x1e4>
  800562:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800565:	89 f3                	mov    %esi,%ebx
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80056a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800577:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057a:	29 c2                	sub    %eax,%edx
  80057c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80057f:	eb 2c                	jmp    8005ad <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800585:	74 18                	je     80059f <vprintfmt+0x232>
  800587:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058a:	83 fa 5e             	cmp    $0x5e,%edx
  80058d:	76 10                	jbe    80059f <vprintfmt+0x232>
					putch('?', putdat);
  80058f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800593:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059a:	ff 55 08             	call   *0x8(%ebp)
  80059d:	eb 0a                	jmp    8005a9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80059f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005ad:	0f be 06             	movsbl (%esi),%eax
  8005b0:	83 c6 01             	add    $0x1,%esi
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	74 25                	je     8005dc <vprintfmt+0x26f>
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	78 c6                	js     800581 <vprintfmt+0x214>
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	79 c1                	jns    800581 <vprintfmt+0x214>
  8005c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005c3:	89 de                	mov    %ebx,%esi
  8005c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c8:	eb 1a                	jmp    8005e4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 eb 01             	sub    $0x1,%ebx
  8005da:	eb 08                	jmp    8005e4 <vprintfmt+0x277>
  8005dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f e2                	jg     8005ca <vprintfmt+0x25d>
  8005e8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005eb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f0:	e9 9b fd ff ff       	jmp    800390 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f5:	83 f9 01             	cmp    $0x1,%ecx
  8005f8:	7e 10                	jle    80060a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 08             	lea    0x8(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 30                	mov    (%eax),%esi
  800605:	8b 78 04             	mov    0x4(%eax),%edi
  800608:	eb 26                	jmp    800630 <vprintfmt+0x2c3>
	else if (lflag)
  80060a:	85 c9                	test   %ecx,%ecx
  80060c:	74 12                	je     800620 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 30                	mov    (%eax),%esi
  800619:	89 f7                	mov    %esi,%edi
  80061b:	c1 ff 1f             	sar    $0x1f,%edi
  80061e:	eb 10                	jmp    800630 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800635:	85 ff                	test   %edi,%edi
  800637:	0f 89 ac 00 00 00    	jns    8006e9 <vprintfmt+0x37c>
				putch('-', putdat);
  80063d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800641:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064b:	f7 de                	neg    %esi
  80064d:	83 d7 00             	adc    $0x0,%edi
  800650:	f7 df                	neg    %edi
			}
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 8d 00 00 00       	jmp    8006e9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065c:	89 ca                	mov    %ecx,%edx
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 88 fc ff ff       	call   8002ee <getuint>
  800666:	89 c6                	mov    %eax,%esi
  800668:	89 d7                	mov    %edx,%edi
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066f:	eb 78                	jmp    8006e9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800671:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800675:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80067c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80068a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80069e:	e9 ed fc ff ff       	jmp    800390 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ae:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c8:	8b 30                	mov    (%eax),%esi
  8006ca:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d4:	eb 13                	jmp    8006e9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d6:	89 ca                	mov    %ecx,%edx
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006db:	e8 0e fc ff ff       	call   8002ee <getuint>
  8006e0:	89 c6                	mov    %eax,%esi
  8006e2:	89 d7                	mov    %edx,%edi
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fc:	89 34 24             	mov    %esi,(%esp)
  8006ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800703:	89 da                	mov    %ebx,%edx
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	e8 13 fb ff ff       	call   800220 <printnum>
			break;
  80070d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800710:	e9 7b fc ff ff       	jmp    800390 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800715:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800722:	e9 69 fc ff ff       	jmp    800390 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800727:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800732:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	eb 03                	jmp    80073a <vprintfmt+0x3cd>
  800737:	83 ee 01             	sub    $0x1,%esi
  80073a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073e:	75 f7                	jne    800737 <vprintfmt+0x3ca>
  800740:	e9 4b fc ff ff       	jmp    800390 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800745:	83 c4 4c             	add    $0x4c,%esp
  800748:	5b                   	pop    %ebx
  800749:	5e                   	pop    %esi
  80074a:	5f                   	pop    %edi
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 28             	sub    $0x28,%esp
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800759:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800760:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076a:	85 c0                	test   %eax,%eax
  80076c:	74 30                	je     80079e <vsnprintf+0x51>
  80076e:	85 d2                	test   %edx,%edx
  800770:	7e 2c                	jle    80079e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800779:	8b 45 10             	mov    0x10(%ebp),%eax
  80077c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800780:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800783:	89 44 24 04          	mov    %eax,0x4(%esp)
  800787:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  80078e:	e8 da fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800793:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800796:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079c:	eb 05                	jmp    8007a3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 82 ff ff ff       	call   80074d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
  8007cd:	00 00                	add    %al,(%eax)
	...

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strlen+0x10>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e4:	75 f7                	jne    8007dd <strlen+0xd>
		n++;
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	eb 03                	jmp    8007fb <strnlen+0x13>
		n++;
  8007f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1d>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f3                	jne    8007f8 <strnlen+0x10>
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
  800816:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80081a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	84 c9                	test   %cl,%cl
  800822:	75 f2                	jne    800816 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800831:	89 1c 24             	mov    %ebx,(%esp)
  800834:	e8 97 ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800840:	01 d8                	add    %ebx,%eax
  800842:	89 04 24             	mov    %eax,(%esp)
  800845:	e8 bd ff ff ff       	call   800807 <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	5b                   	pop    %ebx
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	b9 00 00 00 00       	mov    $0x0,%ecx
  800865:	eb 0f                	jmp    800876 <strncpy+0x24>
		*dst++ = *src;
  800867:	0f b6 1a             	movzbl (%edx),%ebx
  80086a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 3a 01             	cmpb   $0x1,(%edx)
  800870:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	39 f1                	cmp    %esi,%ecx
  800878:	75 ed                	jne    800867 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	85 d2                	test   %edx,%edx
  800890:	75 0a                	jne    80089c <strlcpy+0x1e>
  800892:	eb 1d                	jmp    8008b1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800894:	88 18                	mov    %bl,(%eax)
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089c:	83 ea 01             	sub    $0x1,%edx
  80089f:	74 0b                	je     8008ac <strlcpy+0x2e>
  8008a1:	0f b6 19             	movzbl (%ecx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	75 ec                	jne    800894 <strlcpy+0x16>
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 02                	jmp    8008ae <strlcpy+0x30>
  8008ac:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ae:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b1:	29 f0                	sub    %esi,%eax
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c0:	eb 06                	jmp    8008c8 <strcmp+0x11>
		p++, q++;
  8008c2:	83 c1 01             	add    $0x1,%ecx
  8008c5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c8:	0f b6 01             	movzbl (%ecx),%eax
  8008cb:	84 c0                	test   %al,%al
  8008cd:	74 04                	je     8008d3 <strcmp+0x1c>
  8008cf:	3a 02                	cmp    (%edx),%al
  8008d1:	74 ef                	je     8008c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 c0             	movzbl %al,%eax
  8008d6:	0f b6 12             	movzbl (%edx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008ea:	eb 09                	jmp    8008f5 <strncmp+0x18>
		n--, p++, q++;
  8008ec:	83 ea 01             	sub    $0x1,%edx
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 15                	je     80090e <strncmp+0x31>
  8008f9:	0f b6 18             	movzbl (%eax),%ebx
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	74 04                	je     800904 <strncmp+0x27>
  800900:	3a 19                	cmp    (%ecx),%bl
  800902:	74 e8                	je     8008ec <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800904:	0f b6 00             	movzbl (%eax),%eax
  800907:	0f b6 11             	movzbl (%ecx),%edx
  80090a:	29 d0                	sub    %edx,%eax
  80090c:	eb 05                	jmp    800913 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800920:	eb 07                	jmp    800929 <strchr+0x13>
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	74 0f                	je     800935 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f2                	jne    800922 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800941:	eb 07                	jmp    80094a <strfind+0x13>
		if (*s == c)
  800943:	38 ca                	cmp    %cl,%dl
  800945:	74 0a                	je     800951 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	75 f2                	jne    800943 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 0c             	sub    $0xc,%esp
  800959:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80095c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80095f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800962:	8b 7d 08             	mov    0x8(%ebp),%edi
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	74 30                	je     80099f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800975:	75 25                	jne    80099c <memset+0x49>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 20                	jne    80099c <memset+0x49>
		c &= 0xFF;
  80097c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d6                	mov    %edx,%esi
  800986:	c1 e6 18             	shl    $0x18,%esi
  800989:	89 d0                	mov    %edx,%eax
  80098b:	c1 e0 10             	shl    $0x10,%eax
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 d0                	or     %edx,%eax
  800992:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800997:	fc                   	cld    
  800998:	f3 ab                	rep stos %eax,%es:(%edi)
  80099a:	eb 03                	jmp    80099f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099c:	fc                   	cld    
  80099d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099f:	89 f8                	mov    %edi,%eax
  8009a1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009a4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8009a7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8009aa:	89 ec                	mov    %ebp,%esp
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
  8009b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c3:	39 c6                	cmp    %eax,%esi
  8009c5:	73 36                	jae    8009fd <memmove+0x4f>
  8009c7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	73 2f                	jae    8009fd <memmove+0x4f>
		s += n;
		d += n;
  8009ce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f6 c2 03             	test   $0x3,%dl
  8009d4:	75 1b                	jne    8009f1 <memmove+0x43>
  8009d6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009dc:	75 13                	jne    8009f1 <memmove+0x43>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0e                	jne    8009f1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e3:	83 ef 04             	sub    $0x4,%edi
  8009e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 09                	jmp    8009fa <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fa:	fc                   	cld    
  8009fb:	eb 20                	jmp    800a1d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a03:	75 13                	jne    800a18 <memmove+0x6a>
  800a05:	a8 03                	test   $0x3,%al
  800a07:	75 0f                	jne    800a18 <memmove+0x6a>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	75 0a                	jne    800a18 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a11:	89 c7                	mov    %eax,%edi
  800a13:	fc                   	cld    
  800a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a16:	eb 05                	jmp    800a1d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a18:	89 c7                	mov    %eax,%edi
  800a1a:	fc                   	cld    
  800a1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a23:	89 ec                	mov    %ebp,%esp
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 68 ff ff ff       	call   8009ae <memmove>
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	eb 1a                	jmp    800a78 <memcmp+0x30>
		if (*s1 != *s2)
  800a5e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a6a:	38 c8                	cmp    %cl,%al
  800a6c:	74 0a                	je     800a78 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800a6e:	0f b6 c0             	movzbl %al,%eax
  800a71:	0f b6 c9             	movzbl %cl,%ecx
  800a74:	29 c8                	sub    %ecx,%eax
  800a76:	eb 09                	jmp    800a81 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a78:	39 da                	cmp    %ebx,%edx
  800a7a:	75 e2                	jne    800a5e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a94:	eb 07                	jmp    800a9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 07                	je     800aa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	72 f5                	jb     800a96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	eb 03                	jmp    800ab4 <strtol+0x11>
		s++;
  800ab1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	0f b6 02             	movzbl (%edx),%eax
  800ab7:	3c 20                	cmp    $0x20,%al
  800ab9:	74 f6                	je     800ab1 <strtol+0xe>
  800abb:	3c 09                	cmp    $0x9,%al
  800abd:	74 f2                	je     800ab1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abf:	3c 2b                	cmp    $0x2b,%al
  800ac1:	75 0a                	jne    800acd <strtol+0x2a>
		s++;
  800ac3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac6:	bf 00 00 00 00       	mov    $0x0,%edi
  800acb:	eb 10                	jmp    800add <strtol+0x3a>
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad2:	3c 2d                	cmp    $0x2d,%al
  800ad4:	75 07                	jne    800add <strtol+0x3a>
		s++, neg = 1;
  800ad6:	8d 52 01             	lea    0x1(%edx),%edx
  800ad9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	85 db                	test   %ebx,%ebx
  800adf:	0f 94 c0             	sete   %al
  800ae2:	74 05                	je     800ae9 <strtol+0x46>
  800ae4:	83 fb 10             	cmp    $0x10,%ebx
  800ae7:	75 15                	jne    800afe <strtol+0x5b>
  800ae9:	80 3a 30             	cmpb   $0x30,(%edx)
  800aec:	75 10                	jne    800afe <strtol+0x5b>
  800aee:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af2:	75 0a                	jne    800afe <strtol+0x5b>
		s += 2, base = 16;
  800af4:	83 c2 02             	add    $0x2,%edx
  800af7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800afc:	eb 13                	jmp    800b11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800afe:	84 c0                	test   %al,%al
  800b00:	74 0f                	je     800b11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b07:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0a:	75 05                	jne    800b11 <strtol+0x6e>
		s++, base = 8;
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b18:	0f b6 0a             	movzbl (%edx),%ecx
  800b1b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b1e:	80 fb 09             	cmp    $0x9,%bl
  800b21:	77 08                	ja     800b2b <strtol+0x88>
			dig = *s - '0';
  800b23:	0f be c9             	movsbl %cl,%ecx
  800b26:	83 e9 30             	sub    $0x30,%ecx
  800b29:	eb 1e                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b2b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x98>
			dig = *s - 'a' + 10;
  800b33:	0f be c9             	movsbl %cl,%ecx
  800b36:	83 e9 57             	sub    $0x57,%ecx
  800b39:	eb 0e                	jmp    800b49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b3e:	80 fb 19             	cmp    $0x19,%bl
  800b41:	77 14                	ja     800b57 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800b43:	0f be c9             	movsbl %cl,%ecx
  800b46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b49:	39 f1                	cmp    %esi,%ecx
  800b4b:	7d 0e                	jge    800b5b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800b4d:	83 c2 01             	add    $0x1,%edx
  800b50:	0f af c6             	imul   %esi,%eax
  800b53:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b55:	eb c1                	jmp    800b18 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b57:	89 c1                	mov    %eax,%ecx
  800b59:	eb 02                	jmp    800b5d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b61:	74 05                	je     800b68 <strtol+0xc5>
		*endptr = (char *) s;
  800b63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b66:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b68:	89 ca                	mov    %ecx,%edx
  800b6a:	f7 da                	neg    %edx
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 45 c2             	cmovne %edx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
	...

00800b78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b81:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b84:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	89 c3                	mov    %eax,%ebx
  800b94:	89 c7                	mov    %eax,%edi
  800b96:	89 c6                	mov    %eax,%esi
  800b98:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba3:	89 ec                	mov    %ebp,%esp
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc0:	89 d1                	mov    %edx,%ecx
  800bc2:	89 d3                	mov    %edx,%ebx
  800bc4:	89 d7                	mov    %edx,%edi
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bcd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd3:	89 ec                	mov    %ebp,%esp
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 38             	sub    $0x38,%esp
  800bdd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800be0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800c22:	e8 95 03 00 00       	call   800fbc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c30:	89 ec                	mov    %ebp,%esp
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c60:	89 ec                	mov    %ebp,%esp
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c70:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
  800c78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7d:	89 d1                	mov    %edx,%ecx
  800c7f:	89 d3                	mov    %edx,%ebx
  800c81:	89 d7                	mov    %edx,%edi
  800c83:	89 d6                	mov    %edx,%esi
  800c85:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c90:	89 ec                	mov    %ebp,%esp
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 38             	sub    $0x38,%esp
  800c9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	be 00 00 00 00       	mov    $0x0,%esi
  800ca8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 f7                	mov    %esi,%edi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 28                	jle    800ce6 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cc9:	00 
  800cca:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd9:	00 
  800cda:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800ce1:	e8 d6 02 00 00       	call   800fbc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cef:	89 ec                	mov    %ebp,%esp
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 38             	sub    $0x38,%esp
  800cf9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b8 05 00 00 00       	mov    $0x5,%eax
  800d07:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 28                	jle    800d44 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d27:	00 
  800d28:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d2f:	00 
  800d30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d37:	00 
  800d38:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d3f:	e8 78 02 00 00       	call   800fbc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d4d:	89 ec                	mov    %ebp,%esp
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 38             	sub    $0x38,%esp
  800d57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 28                	jle    800da2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d85:	00 
  800d86:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d95:	00 
  800d96:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800d9d:	e8 1a 02 00 00       	call   800fbc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dab:	89 ec                	mov    %ebp,%esp
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 38             	sub    $0x38,%esp
  800db5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7e 28                	jle    800e00 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddc:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de3:	00 
  800de4:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800deb:	00 
  800dec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df3:	00 
  800df4:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800dfb:	e8 bc 01 00 00       	call   800fbc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e00:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e03:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e06:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e09:	89 ec                	mov    %ebp,%esp
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 38             	sub    $0x38,%esp
  800e13:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e16:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e19:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 09 00 00 00       	mov    $0x9,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800e59:	e8 5e 01 00 00       	call   800fbc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e67:	89 ec                	mov    %ebp,%esp
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	be 00 00 00 00       	mov    $0x0,%esi
  800e7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9b:	89 ec                	mov    %ebp,%esp
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800eae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	89 cb                	mov    %ecx,%ebx
  800ebd:	89 cf                	mov    %ecx,%edi
  800ebf:	89 ce                	mov    %ecx,%esi
  800ec1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 28                	jle    800eef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 08 68 15 80 	movl   $0x801568,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 85 15 80 00 	movl   $0x801585,(%esp)
  800eea:	e8 cd 00 00 00       	call   800fbc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef8:	89 ec                	mov    %ebp,%esp
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f02:	c7 44 24 08 9f 15 80 	movl   $0x80159f,0x8(%esp)
  800f09:	00 
  800f0a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800f11:	00 
  800f12:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  800f19:	e8 9e 00 00 00       	call   800fbc <_panic>

00800f1e <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f24:	c7 44 24 08 9e 15 80 	movl   $0x80159e,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 93 15 80 00 	movl   $0x801593,(%esp)
  800f3b:	e8 7c 00 00 00       	call   800fbc <_panic>

00800f40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f46:	c7 44 24 08 b4 15 80 	movl   $0x8015b4,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800f55:	00 
  800f56:	c7 04 24 cd 15 80 00 	movl   $0x8015cd,(%esp)
  800f5d:	e8 5a 00 00 00       	call   800fbc <_panic>

00800f62 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f68:	c7 44 24 08 d7 15 80 	movl   $0x8015d7,0x8(%esp)
  800f6f:	00 
  800f70:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f77:	00 
  800f78:	c7 04 24 cd 15 80 00 	movl   $0x8015cd,(%esp)
  800f7f:	e8 38 00 00 00       	call   800fbc <_panic>

00800f84 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f8f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f92:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f98:	8b 52 50             	mov    0x50(%edx),%edx
  800f9b:	39 ca                	cmp    %ecx,%edx
  800f9d:	75 0d                	jne    800fac <ipc_find_env+0x28>
			return envs[i].env_id;
  800f9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa2:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800fa7:	8b 40 40             	mov    0x40(%eax),%eax
  800faa:	eb 0e                	jmp    800fba <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fac:	83 c0 01             	add    $0x1,%eax
  800faf:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fb4:	75 d9                	jne    800f8f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800fb6:	66 b8 00 00          	mov    $0x0,%ax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800fc4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fc7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fcd:	e8 62 fc ff ff       	call   800c34 <sys_getenvid>
  800fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe8:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  800fef:	e8 0b f2 ff ff       	call   8001ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 9b f1 ff ff       	call   80019e <vcprintf>
	cprintf("\n");
  801003:	c7 04 24 07 13 80 00 	movl   $0x801307,(%esp)
  80100a:	e8 f0 f1 ff ff       	call   8001ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100f:	cc                   	int3   
  801010:	eb fd                	jmp    80100f <_panic+0x53>
	...

00801020 <__udivdi3>:
  801020:	83 ec 1c             	sub    $0x1c,%esp
  801023:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801027:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80102b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80102f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801033:	89 74 24 10          	mov    %esi,0x10(%esp)
  801037:	8b 74 24 24          	mov    0x24(%esp),%esi
  80103b:	85 ff                	test   %edi,%edi
  80103d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801041:	89 44 24 08          	mov    %eax,0x8(%esp)
  801045:	89 cd                	mov    %ecx,%ebp
  801047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104b:	75 33                	jne    801080 <__udivdi3+0x60>
  80104d:	39 f1                	cmp    %esi,%ecx
  80104f:	77 57                	ja     8010a8 <__udivdi3+0x88>
  801051:	85 c9                	test   %ecx,%ecx
  801053:	75 0b                	jne    801060 <__udivdi3+0x40>
  801055:	b8 01 00 00 00       	mov    $0x1,%eax
  80105a:	31 d2                	xor    %edx,%edx
  80105c:	f7 f1                	div    %ecx
  80105e:	89 c1                	mov    %eax,%ecx
  801060:	89 f0                	mov    %esi,%eax
  801062:	31 d2                	xor    %edx,%edx
  801064:	f7 f1                	div    %ecx
  801066:	89 c6                	mov    %eax,%esi
  801068:	8b 44 24 04          	mov    0x4(%esp),%eax
  80106c:	f7 f1                	div    %ecx
  80106e:	89 f2                	mov    %esi,%edx
  801070:	8b 74 24 10          	mov    0x10(%esp),%esi
  801074:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801078:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80107c:	83 c4 1c             	add    $0x1c,%esp
  80107f:	c3                   	ret    
  801080:	31 d2                	xor    %edx,%edx
  801082:	31 c0                	xor    %eax,%eax
  801084:	39 f7                	cmp    %esi,%edi
  801086:	77 e8                	ja     801070 <__udivdi3+0x50>
  801088:	0f bd cf             	bsr    %edi,%ecx
  80108b:	83 f1 1f             	xor    $0x1f,%ecx
  80108e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801092:	75 2c                	jne    8010c0 <__udivdi3+0xa0>
  801094:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801098:	76 04                	jbe    80109e <__udivdi3+0x7e>
  80109a:	39 f7                	cmp    %esi,%edi
  80109c:	73 d2                	jae    801070 <__udivdi3+0x50>
  80109e:	31 d2                	xor    %edx,%edx
  8010a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a5:	eb c9                	jmp    801070 <__udivdi3+0x50>
  8010a7:	90                   	nop
  8010a8:	89 f2                	mov    %esi,%edx
  8010aa:	f7 f1                	div    %ecx
  8010ac:	31 d2                	xor    %edx,%edx
  8010ae:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ba:	83 c4 1c             	add    $0x1c,%esp
  8010bd:	c3                   	ret    
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ca:	89 ea                	mov    %ebp,%edx
  8010cc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	89 c1                	mov    %eax,%ecx
  8010d4:	d3 ea                	shr    %cl,%edx
  8010d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010db:	09 fa                	or     %edi,%edx
  8010dd:	89 f7                	mov    %esi,%edi
  8010df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010e9:	d3 e5                	shl    %cl,%ebp
  8010eb:	89 c1                	mov    %eax,%ecx
  8010ed:	d3 ef                	shr    %cl,%edi
  8010ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f4:	d3 e2                	shl    %cl,%edx
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	d3 ee                	shr    %cl,%esi
  8010fa:	09 d6                	or     %edx,%esi
  8010fc:	89 fa                	mov    %edi,%edx
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	f7 74 24 0c          	divl   0xc(%esp)
  801104:	89 d7                	mov    %edx,%edi
  801106:	89 c6                	mov    %eax,%esi
  801108:	f7 e5                	mul    %ebp
  80110a:	39 d7                	cmp    %edx,%edi
  80110c:	72 22                	jb     801130 <__udivdi3+0x110>
  80110e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801112:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801117:	d3 e5                	shl    %cl,%ebp
  801119:	39 c5                	cmp    %eax,%ebp
  80111b:	73 04                	jae    801121 <__udivdi3+0x101>
  80111d:	39 d7                	cmp    %edx,%edi
  80111f:	74 0f                	je     801130 <__udivdi3+0x110>
  801121:	89 f0                	mov    %esi,%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	e9 46 ff ff ff       	jmp    801070 <__udivdi3+0x50>
  80112a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801130:	8d 46 ff             	lea    -0x1(%esi),%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	8b 74 24 10          	mov    0x10(%esp),%esi
  801139:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80113d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801141:	83 c4 1c             	add    $0x1c,%esp
  801144:	c3                   	ret    
	...

00801150 <__umoddi3>:
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801157:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80115b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80115f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801163:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801167:	8b 74 24 24          	mov    0x24(%esp),%esi
  80116b:	85 ed                	test   %ebp,%ebp
  80116d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 cf                	mov    %ecx,%edi
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	89 f2                	mov    %esi,%edx
  80117c:	75 1a                	jne    801198 <__umoddi3+0x48>
  80117e:	39 f1                	cmp    %esi,%ecx
  801180:	76 4e                	jbe    8011d0 <__umoddi3+0x80>
  801182:	f7 f1                	div    %ecx
  801184:	89 d0                	mov    %edx,%eax
  801186:	31 d2                	xor    %edx,%edx
  801188:	8b 74 24 10          	mov    0x10(%esp),%esi
  80118c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801190:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801194:	83 c4 1c             	add    $0x1c,%esp
  801197:	c3                   	ret    
  801198:	39 f5                	cmp    %esi,%ebp
  80119a:	77 54                	ja     8011f0 <__umoddi3+0xa0>
  80119c:	0f bd c5             	bsr    %ebp,%eax
  80119f:	83 f0 1f             	xor    $0x1f,%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	75 60                	jne    801208 <__umoddi3+0xb8>
  8011a8:	3b 0c 24             	cmp    (%esp),%ecx
  8011ab:	0f 87 07 01 00 00    	ja     8012b8 <__umoddi3+0x168>
  8011b1:	89 f2                	mov    %esi,%edx
  8011b3:	8b 34 24             	mov    (%esp),%esi
  8011b6:	29 ce                	sub    %ecx,%esi
  8011b8:	19 ea                	sbb    %ebp,%edx
  8011ba:	89 34 24             	mov    %esi,(%esp)
  8011bd:	8b 04 24             	mov    (%esp),%eax
  8011c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011cc:	83 c4 1c             	add    $0x1c,%esp
  8011cf:	c3                   	ret    
  8011d0:	85 c9                	test   %ecx,%ecx
  8011d2:	75 0b                	jne    8011df <__umoddi3+0x8f>
  8011d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f1                	div    %ecx
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	f7 f1                	div    %ecx
  8011e5:	8b 04 24             	mov    (%esp),%eax
  8011e8:	f7 f1                	div    %ecx
  8011ea:	eb 98                	jmp    801184 <__umoddi3+0x34>
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 f2                	mov    %esi,%edx
  8011f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fe:	83 c4 1c             	add    $0x1c,%esp
  801201:	c3                   	ret    
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80120d:	89 e8                	mov    %ebp,%eax
  80120f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801214:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801218:	89 fa                	mov    %edi,%edx
  80121a:	d3 e0                	shl    %cl,%eax
  80121c:	89 e9                	mov    %ebp,%ecx
  80121e:	d3 ea                	shr    %cl,%edx
  801220:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801225:	09 c2                	or     %eax,%edx
  801227:	8b 44 24 08          	mov    0x8(%esp),%eax
  80122b:	89 14 24             	mov    %edx,(%esp)
  80122e:	89 f2                	mov    %esi,%edx
  801230:	d3 e7                	shl    %cl,%edi
  801232:	89 e9                	mov    %ebp,%ecx
  801234:	d3 ea                	shr    %cl,%edx
  801236:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123f:	d3 e6                	shl    %cl,%esi
  801241:	89 e9                	mov    %ebp,%ecx
  801243:	d3 e8                	shr    %cl,%eax
  801245:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124a:	09 f0                	or     %esi,%eax
  80124c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801250:	f7 34 24             	divl   (%esp)
  801253:	d3 e6                	shl    %cl,%esi
  801255:	89 74 24 08          	mov    %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	f7 e7                	mul    %edi
  80125d:	39 d6                	cmp    %edx,%esi
  80125f:	89 c1                	mov    %eax,%ecx
  801261:	89 d7                	mov    %edx,%edi
  801263:	72 3f                	jb     8012a4 <__umoddi3+0x154>
  801265:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801269:	72 35                	jb     8012a0 <__umoddi3+0x150>
  80126b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80126f:	29 c8                	sub    %ecx,%eax
  801271:	19 fe                	sbb    %edi,%esi
  801273:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801278:	89 f2                	mov    %esi,%edx
  80127a:	d3 e8                	shr    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 d0                	or     %edx,%eax
  801287:	89 f2                	mov    %esi,%edx
  801289:	d3 ea                	shr    %cl,%edx
  80128b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80128f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801293:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801297:	83 c4 1c             	add    $0x1c,%esp
  80129a:	c3                   	ret    
  80129b:	90                   	nop
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	39 d6                	cmp    %edx,%esi
  8012a2:	75 c7                	jne    80126b <__umoddi3+0x11b>
  8012a4:	89 d7                	mov    %edx,%edi
  8012a6:	89 c1                	mov    %eax,%ecx
  8012a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012ac:	1b 3c 24             	sbb    (%esp),%edi
  8012af:	eb ba                	jmp    80126b <__umoddi3+0x11b>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	39 f5                	cmp    %esi,%ebp
  8012ba:	0f 82 f1 fe ff ff    	jb     8011b1 <__umoddi3+0x61>
  8012c0:	e9 f8 fe ff ff       	jmp    8011bd <__umoddi3+0x6d>
