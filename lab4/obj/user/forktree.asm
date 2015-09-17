
obj/user/forktree：     文件格式 elf32-i386


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
  80002c:	e8 c2 00 00 00       	call   8000f3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 f3 0b 00 00       	call   800c35 <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  800051:	e8 89 01 00 00       	call   8001df <cprintf>

	forkchild(cur, '0');
  800056:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005d:	00 
  80005e:	89 1c 24             	mov    %ebx,(%esp)
  800061:	e8 16 00 00 00       	call   80007c <forkchild>
	forkchild(cur, '1');
  800066:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006d:	00 
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 06 00 00 00       	call   80007c <forkchild>
}
  800076:	83 c4 14             	add    $0x14,%esp
  800079:	5b                   	pop    %ebx
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	83 ec 30             	sub    $0x30,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008a:	89 1c 24             	mov    %ebx,(%esp)
  80008d:	e8 8e 07 00 00       	call   800820 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 d1 11 80 	movl   $0x8011d1,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 39 07 00 00       	call   8007f8 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 c4 0d 00 00       	call   800e88 <fork>
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	75 10                	jne    8000d8 <forkchild+0x5c>
		forktree(nxt);
  8000c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <forktree>
		exit();
  8000d3:	e8 50 00 00 00       	call   800128 <exit>
	}
}
  8000d8:	83 c4 30             	add    $0x30,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e5:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  8000ec:	e8 42 ff ff ff       	call   800033 <forktree>
}
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 18             	sub    $0x18,%esp
  8000f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ff:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800106:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 08                	jle    800115 <libmain+0x22>
		binaryname = argv[0];
  80010d:	8b 0a                	mov    (%edx),%ecx
  80010f:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800115:	89 54 24 04          	mov    %edx,0x4(%esp)
  800119:	89 04 24             	mov    %eax,(%esp)
  80011c:	e8 be ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  800121:	e8 02 00 00 00       	call   800128 <exit>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 a9 0a 00 00       	call   800be3 <sys_env_destroy>
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	53                   	push   %ebx
  800140:	83 ec 14             	sub    $0x14,%esp
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800146:	8b 13                	mov    (%ebx),%edx
  800148:	8d 42 01             	lea    0x1(%edx),%eax
  80014b:	89 03                	mov    %eax,(%ebx)
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800154:	3d ff 00 00 00       	cmp    $0xff,%eax
  800159:	75 19                	jne    800174 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800162:	00 
  800163:	8d 43 08             	lea    0x8(%ebx),%eax
  800166:	89 04 24             	mov    %eax,(%esp)
  800169:	e8 38 0a 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  80016e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800174:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800178:	83 c4 14             	add    $0x14,%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800187:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018e:	00 00 00 
	b.cnt = 0;
  800191:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800198:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b3:	c7 04 24 3c 01 80 00 	movl   $0x80013c,(%esp)
  8001ba:	e8 75 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cf:	89 04 24             	mov    %eax,(%esp)
  8001d2:	e8 cf 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  8001d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 87 ff ff ff       	call   80017e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    
  8001f9:	66 90                	xchg   %ax,%ax
  8001fb:	66 90                	xchg   %ax,%ax
  8001fd:	66 90                	xchg   %ax,%ax
  8001ff:	90                   	nop

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 3c             	sub    $0x3c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d7                	mov    %edx,%edi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 c3                	mov    %eax,%ebx
  800219:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80021c:	8b 45 10             	mov    0x10(%ebp),%eax
  80021f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800222:	b9 00 00 00 00       	mov    $0x0,%ecx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022d:	39 d9                	cmp    %ebx,%ecx
  80022f:	72 05                	jb     800236 <printnum+0x36>
  800231:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800234:	77 69                	ja     80029f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800236:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800239:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80023d:	83 ee 01             	sub    $0x1,%esi
  800240:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800244:	89 44 24 08          	mov    %eax,0x8(%esp)
  800248:	8b 44 24 08          	mov    0x8(%esp),%eax
  80024c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800250:	89 c3                	mov    %eax,%ebx
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800257:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80025a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800262:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026f:	e8 bc 0c 00 00       	call   800f30 <__udivdi3>
  800274:	89 d9                	mov    %ebx,%ecx
  800276:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 71 ff ff ff       	call   800200 <printnum>
  80028f:	eb 1b                	jmp    8002ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	8b 45 18             	mov    0x18(%ebp),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff d3                	call   *%ebx
  80029d:	eb 03                	jmp    8002a2 <printnum+0xa2>
  80029f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 ee 01             	sub    $0x1,%esi
  8002a5:	85 f6                	test   %esi,%esi
  8002a7:	7f e8                	jg     800291 <printnum+0x91>
  8002a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 8c 0d 00 00       	call   801060 <__umoddi3>
  8002d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d8:	0f be 80 e0 11 80 00 	movsbl 0x8011e0(%eax),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002e5:	ff d0                	call   *%eax
}
  8002e7:	83 c4 3c             	add    $0x3c,%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800319:	8b 45 10             	mov    0x10(%ebp),%eax
  80031c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 44 24 04          	mov    %eax,0x4(%esp)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	e8 02 00 00 00       	call   800334 <vprintfmt>
	va_end(ap);
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 3c             	sub    $0x3c,%esp
  80033d:	8b 75 08             	mov    0x8(%ebp),%esi
  800340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800343:	8b 7d 10             	mov    0x10(%ebp),%edi
  800346:	eb 11                	jmp    800359 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800348:	85 c0                	test   %eax,%eax
  80034a:	0f 84 48 04 00 00    	je     800798 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800350:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	83 c7 01             	add    $0x1,%edi
  80035c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800360:	83 f8 25             	cmp    $0x25,%eax
  800363:	75 e3                	jne    800348 <vprintfmt+0x14>
  800365:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800369:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800370:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800377:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800383:	eb 1f                	jmp    8003a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800388:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80038c:	eb 16                	jmp    8003a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800391:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800395:	eb 0d                	jmp    8003a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800397:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8d 47 01             	lea    0x1(%edi),%eax
  8003a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003aa:	0f b6 17             	movzbl (%edi),%edx
  8003ad:	0f b6 c2             	movzbl %dl,%eax
  8003b0:	83 ea 23             	sub    $0x23,%edx
  8003b3:	80 fa 55             	cmp    $0x55,%dl
  8003b6:	0f 87 bf 03 00 00    	ja     80077b <vprintfmt+0x447>
  8003bc:	0f b6 d2             	movzbl %dl,%edx
  8003bf:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003d4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003d8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003de:	83 f9 09             	cmp    $0x9,%ecx
  8003e1:	77 3c                	ja     80041f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e6:	eb e9                	jmp    8003d1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 40 04             	lea    0x4(%eax),%eax
  8003f6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fc:	eb 27                	jmp    800425 <vprintfmt+0xf1>
  8003fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800401:	85 d2                	test   %edx,%edx
  800403:	b8 00 00 00 00       	mov    $0x0,%eax
  800408:	0f 49 c2             	cmovns %edx,%eax
  80040b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800411:	eb 91                	jmp    8003a4 <vprintfmt+0x70>
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800416:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041d:	eb 85                	jmp    8003a4 <vprintfmt+0x70>
  80041f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800422:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800429:	0f 89 75 ff ff ff    	jns    8003a4 <vprintfmt+0x70>
  80042f:	e9 63 ff ff ff       	jmp    800397 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800434:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043a:	e9 65 ff ff ff       	jmp    8003a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800442:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800446:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 00 ff ff ff       	jmp    800359 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800460:	8b 00                	mov    (%eax),%eax
  800462:	99                   	cltd   
  800463:	31 d0                	xor    %edx,%eax
  800465:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 09             	cmp    $0x9,%eax
  80046a:	7f 0b                	jg     800477 <vprintfmt+0x143>
  80046c:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  800473:	85 d2                	test   %edx,%edx
  800475:	75 20                	jne    800497 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047b:	c7 44 24 08 f8 11 80 	movl   $0x8011f8,0x8(%esp)
  800482:	00 
  800483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800487:	89 34 24             	mov    %esi,(%esp)
  80048a:	e8 7d fe ff ff       	call   80030c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800492:	e9 c2 fe ff ff       	jmp    800359 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800497:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049b:	c7 44 24 08 01 12 80 	movl   $0x801201,0x8(%esp)
  8004a2:	00 
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 34 24             	mov    %esi,(%esp)
  8004aa:	e8 5d fe ff ff       	call   80030c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b2:	e9 a2 fe ff ff       	jmp    800359 <vprintfmt+0x25>
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 f1 11 80 00       	mov    $0x8011f1,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d7:	0f 84 92 00 00 00    	je     80056f <vprintfmt+0x23b>
  8004dd:	85 c9                	test   %ecx,%ecx
  8004df:	0f 8e 98 00 00 00    	jle    80057d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e9:	89 3c 24             	mov    %edi,(%esp)
  8004ec:	e8 47 03 00 00       	call   800838 <strnlen>
  8004f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f4:	29 c1                	sub    %eax,%ecx
  8004f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8004f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800500:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800503:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	eb 0f                	jmp    800516 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800507:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	83 ef 01             	sub    $0x1,%edi
  800516:	85 ff                	test   %edi,%edi
  800518:	7f ed                	jg     800507 <vprintfmt+0x1d3>
  80051a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800520:	85 c9                	test   %ecx,%ecx
  800522:	b8 00 00 00 00       	mov    $0x0,%eax
  800527:	0f 49 c1             	cmovns %ecx,%eax
  80052a:	29 c1                	sub    %eax,%ecx
  80052c:	89 75 08             	mov    %esi,0x8(%ebp)
  80052f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800532:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800535:	89 cb                	mov    %ecx,%ebx
  800537:	eb 50                	jmp    800589 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053d:	74 1e                	je     80055d <vprintfmt+0x229>
  80053f:	0f be d2             	movsbl %dl,%edx
  800542:	83 ea 20             	sub    $0x20,%edx
  800545:	83 fa 5e             	cmp    $0x5e,%edx
  800548:	76 13                	jbe    80055d <vprintfmt+0x229>
					putch('?', putdat);
  80054a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800551:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800558:	ff 55 08             	call   *0x8(%ebp)
  80055b:	eb 0d                	jmp    80056a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80055d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800560:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056a:	83 eb 01             	sub    $0x1,%ebx
  80056d:	eb 1a                	jmp    800589 <vprintfmt+0x255>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	eb 0c                	jmp    800589 <vprintfmt+0x255>
  80057d:	89 75 08             	mov    %esi,0x8(%ebp)
  800580:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800589:	83 c7 01             	add    $0x1,%edi
  80058c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800590:	0f be c2             	movsbl %dl,%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	74 25                	je     8005bc <vprintfmt+0x288>
  800597:	85 f6                	test   %esi,%esi
  800599:	78 9e                	js     800539 <vprintfmt+0x205>
  80059b:	83 ee 01             	sub    $0x1,%esi
  80059e:	79 99                	jns    800539 <vprintfmt+0x205>
  8005a0:	89 df                	mov    %ebx,%edi
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	eb 1a                	jmp    8005c4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b7:	83 ef 01             	sub    $0x1,%edi
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x290>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e2                	jg     8005aa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 89 fd ff ff       	jmp    800359 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 f9 01             	cmp    $0x1,%ecx
  8005d3:	7e 19                	jle    8005ee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 50 04             	mov    0x4(%eax),%edx
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 08             	lea    0x8(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ec:	eb 38                	jmp    800626 <vprintfmt+0x2f2>
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 1b                	je     80060d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
  80060b:	eb 19                	jmp    800626 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 40 04             	lea    0x4(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800626:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800629:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800631:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800635:	0f 89 04 01 00 00    	jns    80073f <vprintfmt+0x40b>
				putch('-', putdat);
  80063b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800646:	ff d6                	call   *%esi
				num = -(long long) num;
  800648:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064e:	f7 da                	neg    %edx
  800650:	83 d1 00             	adc    $0x0,%ecx
  800653:	f7 d9                	neg    %ecx
  800655:	e9 e5 00 00 00       	jmp    80073f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065a:	83 f9 01             	cmp    $0x1,%ecx
  80065d:	7e 10                	jle    80066f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	8b 48 04             	mov    0x4(%eax),%ecx
  800667:	8d 40 08             	lea    0x8(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
  80066d:	eb 26                	jmp    800695 <vprintfmt+0x361>
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 12                	je     800685 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
  800683:	eb 10                	jmp    800695 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800695:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80069a:	e9 a0 00 00 00       	jmp    80073f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c9:	e9 8b fc ff ff       	jmp    800359 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8006fd:	eb 40                	jmp    80073f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 10                	jle    800714 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
  800712:	eb 26                	jmp    80073a <vprintfmt+0x406>
	else if (lflag)
  800714:	85 c9                	test   %ecx,%ecx
  800716:	74 12                	je     80072a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800722:	8d 40 04             	lea    0x4(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
  800728:	eb 10                	jmp    80073a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 10                	mov    (%eax),%edx
  80072f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800734:	8d 40 04             	lea    0x4(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80073a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800743:	89 44 24 10          	mov    %eax,0x10(%esp)
  800747:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800752:	89 14 24             	mov    %edx,(%esp)
  800755:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800759:	89 da                	mov    %ebx,%edx
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	e8 9e fa ff ff       	call   800200 <printnum>
			break;
  800762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800765:	e9 ef fb ff ff       	jmp    800359 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	89 04 24             	mov    %eax,(%esp)
  800771:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800776:	e9 de fb ff ff       	jmp    800359 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800786:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	eb 03                	jmp    80078d <vprintfmt+0x459>
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800791:	75 f7                	jne    80078a <vprintfmt+0x456>
  800793:	e9 c1 fb ff ff       	jmp    800359 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800798:	83 c4 3c             	add    $0x3c,%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 28             	sub    $0x28,%esp
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	74 30                	je     8007f1 <vsnprintf+0x51>
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	7e 2c                	jle    8007f1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007da:	c7 04 24 ef 02 80 00 	movl   $0x8002ef,(%esp)
  8007e1:	e8 4e fb ff ff       	call   800334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ef:	eb 05                	jmp    8007f6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800805:	8b 45 10             	mov    0x10(%ebp),%eax
  800808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	e8 82 ff ff ff       	call   8007a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	74 06                	je     800855 <strnlen+0x1d>
  80084f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
		n++;
	return n;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800861:	89 c2                	mov    %eax,%edx
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800870:	84 db                	test   %bl,%bl
  800872:	75 ef                	jne    800863 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	89 1c 24             	mov    %ebx,(%esp)
  800884:	e8 97 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800890:	01 d8                	add    %ebx,%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 bd ff ff ff       	call   800857 <strcpy>
	return dst;
}
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	5b                   	pop    %ebx
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ad:	89 f3                	mov    %esi,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b2:	89 f2                	mov    %esi,%edx
  8008b4:	eb 0f                	jmp    8008c5 <strncpy+0x23>
		*dst++ = *src;
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	0f b6 01             	movzbl (%ecx),%eax
  8008bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	39 da                	cmp    %ebx,%edx
  8008c7:	75 ed                	jne    8008b6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c9:	89 f0                	mov    %esi,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008dd:	89 f0                	mov    %esi,%eax
  8008df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	75 0b                	jne    8008f2 <strlcpy+0x23>
  8008e7:	eb 1d                	jmp    800906 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 0b                	je     800901 <strlcpy+0x32>
  8008f6:	0f b6 0a             	movzbl (%edx),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	75 ec                	jne    8008e9 <strlcpy+0x1a>
  8008fd:	89 c2                	mov    %eax,%edx
  8008ff:	eb 02                	jmp    800903 <strlcpy+0x34>
  800901:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800903:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800906:	29 f0                	sub    %esi,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800915:	eb 06                	jmp    80091d <strcmp+0x11>
		p++, q++;
  800917:	83 c1 01             	add    $0x1,%ecx
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091d:	0f b6 01             	movzbl (%ecx),%eax
  800920:	84 c0                	test   %al,%al
  800922:	74 04                	je     800928 <strcmp+0x1c>
  800924:	3a 02                	cmp    (%edx),%al
  800926:	74 ef                	je     800917 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 c0             	movzbl %al,%eax
  80092b:	0f b6 12             	movzbl (%edx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	53                   	push   %ebx
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800941:	eb 06                	jmp    800949 <strncmp+0x17>
		n--, p++, q++;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800949:	39 d8                	cmp    %ebx,%eax
  80094b:	74 15                	je     800962 <strncmp+0x30>
  80094d:	0f b6 08             	movzbl (%eax),%ecx
  800950:	84 c9                	test   %cl,%cl
  800952:	74 04                	je     800958 <strncmp+0x26>
  800954:	3a 0a                	cmp    (%edx),%cl
  800956:	74 eb                	je     800943 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f b6 12             	movzbl (%edx),%edx
  80095e:	29 d0                	sub    %edx,%eax
  800960:	eb 05                	jmp    800967 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	eb 07                	jmp    80097d <strchr+0x13>
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 0f                	je     800989 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	84 d2                	test   %dl,%dl
  800982:	75 f2                	jne    800976 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	eb 07                	jmp    80099e <strfind+0x13>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 0a                	je     8009a5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f2                	jne    800997 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b3:	85 c9                	test   %ecx,%ecx
  8009b5:	74 36                	je     8009ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bd:	75 28                	jne    8009e7 <memset+0x40>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 23                	jne    8009e7 <memset+0x40>
		c &= 0xFF;
  8009c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d6                	mov    %edx,%esi
  8009cf:	c1 e6 18             	shl    $0x18,%esi
  8009d2:	89 d0                	mov    %edx,%eax
  8009d4:	c1 e0 10             	shl    $0x10,%eax
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009df:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e2:	fc                   	cld    
  8009e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e5:	eb 06                	jmp    8009ed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 35                	jae    800a3b <memmove+0x47>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	73 2e                	jae    800a3b <memmove+0x47>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a10:	89 d6                	mov    %edx,%esi
  800a12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1a:	75 13                	jne    800a2f <memmove+0x3b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 09                	jmp    800a38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	83 ef 01             	sub    $0x1,%edi
  800a32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a35:	fd                   	std    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a38:	fc                   	cld    
  800a39:	eb 1d                	jmp    800a58 <memmove+0x64>
  800a3b:	89 f2                	mov    %esi,%edx
  800a3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	f6 c2 03             	test   $0x3,%dl
  800a42:	75 0f                	jne    800a53 <memmove+0x5f>
  800a44:	f6 c1 03             	test   $0x3,%cl
  800a47:	75 0a                	jne    800a53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4c:	89 c7                	mov    %eax,%edi
  800a4e:	fc                   	cld    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 05                	jmp    800a58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	fc                   	cld    
  800a56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a62:	8b 45 10             	mov    0x10(%ebp),%eax
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 79 ff ff ff       	call   8009f4 <memmove>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8d:	eb 1a                	jmp    800aa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8f:	0f b6 02             	movzbl (%edx),%eax
  800a92:	0f b6 19             	movzbl (%ecx),%ebx
  800a95:	38 d8                	cmp    %bl,%al
  800a97:	74 0a                	je     800aa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a99:	0f b6 c0             	movzbl %al,%eax
  800a9c:	0f b6 db             	movzbl %bl,%ebx
  800a9f:	29 d8                	sub    %ebx,%eax
  800aa1:	eb 0f                	jmp    800ab2 <memcmp+0x35>
		s1++, s2++;
  800aa3:	83 c2 01             	add    $0x1,%edx
  800aa6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa9:	39 f2                	cmp    %esi,%edx
  800aab:	75 e2                	jne    800a8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac4:	eb 07                	jmp    800acd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac6:	38 08                	cmp    %cl,(%eax)
  800ac8:	74 07                	je     800ad1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	39 d0                	cmp    %edx,%eax
  800acf:	72 f5                	jb     800ac6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 55 08             	mov    0x8(%ebp),%edx
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800adf:	eb 03                	jmp    800ae4 <strtol+0x11>
		s++;
  800ae1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae4:	0f b6 0a             	movzbl (%edx),%ecx
  800ae7:	80 f9 09             	cmp    $0x9,%cl
  800aea:	74 f5                	je     800ae1 <strtol+0xe>
  800aec:	80 f9 20             	cmp    $0x20,%cl
  800aef:	74 f0                	je     800ae1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af1:	80 f9 2b             	cmp    $0x2b,%cl
  800af4:	75 0a                	jne    800b00 <strtol+0x2d>
		s++;
  800af6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
  800afe:	eb 11                	jmp    800b11 <strtol+0x3e>
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b05:	80 f9 2d             	cmp    $0x2d,%cl
  800b08:	75 07                	jne    800b11 <strtol+0x3e>
		s++, neg = 1;
  800b0a:	8d 52 01             	lea    0x1(%edx),%edx
  800b0d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b16:	75 15                	jne    800b2d <strtol+0x5a>
  800b18:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1b:	75 10                	jne    800b2d <strtol+0x5a>
  800b1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b21:	75 0a                	jne    800b2d <strtol+0x5a>
		s += 2, base = 16;
  800b23:	83 c2 02             	add    $0x2,%edx
  800b26:	b8 10 00 00 00       	mov    $0x10,%eax
  800b2b:	eb 10                	jmp    800b3d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	75 0c                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b31:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	80 3a 30             	cmpb   $0x30,(%edx)
  800b36:	75 05                	jne    800b3d <strtol+0x6a>
		s++, base = 8;
  800b38:	83 c2 01             	add    $0x1,%edx
  800b3b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b42:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b45:	0f b6 0a             	movzbl (%edx),%ecx
  800b48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b4b:	89 f0                	mov    %esi,%eax
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	77 08                	ja     800b59 <strtol+0x86>
			dig = *s - '0';
  800b51:	0f be c9             	movsbl %cl,%ecx
  800b54:	83 e9 30             	sub    $0x30,%ecx
  800b57:	eb 20                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b5c:	89 f0                	mov    %esi,%eax
  800b5e:	3c 19                	cmp    $0x19,%al
  800b60:	77 08                	ja     800b6a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 57             	sub    $0x57,%ecx
  800b68:	eb 0f                	jmp    800b79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	3c 19                	cmp    $0x19,%al
  800b71:	77 16                	ja     800b89 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b73:	0f be c9             	movsbl %cl,%ecx
  800b76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b7c:	7d 0f                	jge    800b8d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b85:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b87:	eb bc                	jmp    800b45 <strtol+0x72>
  800b89:	89 d8                	mov    %ebx,%eax
  800b8b:	eb 02                	jmp    800b8f <strtol+0xbc>
  800b8d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b93:	74 05                	je     800b9a <strtol+0xc7>
		*endptr = (char *) s;
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b9a:	f7 d8                	neg    %eax
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	0f 44 c3             	cmove  %ebx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 c6                	mov    %eax,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 cb                	mov    %ecx,%ebx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	89 ce                	mov    %ecx,%esi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800c28:	e8 9f 02 00 00       	call   800ecc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_yield>:

void
sys_yield(void)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c64:	89 d1                	mov    %edx,%ecx
  800c66:	89 d3                	mov    %edx,%ebx
  800c68:	89 d7                	mov    %edx,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 04 00 00 00       	mov    $0x4,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	89 f7                	mov    %esi,%edi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 28                	jle    800cbf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800caa:	00 
  800cab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb2:	00 
  800cb3:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800cba:	e8 0d 02 00 00       	call   800ecc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbf:	83 c4 2c             	add    $0x2c,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800d0d:	e8 ba 01 00 00       	call   800ecc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800d60:	e8 67 01 00 00       	call   800ecc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 df                	mov    %ebx,%edi
  800d88:	89 de                	mov    %ebx,%esi
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800db3:	e8 14 01 00 00       	call   800ecc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800e06:	e8 c1 00 00 00       	call   800ecc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e0b:	83 c4 2c             	add    $0x2c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	be 00 00 00 00       	mov    $0x0,%esi
  800e1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e44:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 cb                	mov    %ecx,%ebx
  800e4e:	89 cf                	mov    %ecx,%edi
  800e50:	89 ce                	mov    %ecx,%esi
  800e52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 28                	jle    800e80 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e63:	00 
  800e64:	c7 44 24 08 28 14 80 	movl   $0x801428,0x8(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e73:	00 
  800e74:	c7 04 24 45 14 80 00 	movl   $0x801445,(%esp)
  800e7b:	e8 4c 00 00 00       	call   800ecc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	83 c4 2c             	add    $0x2c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e8e:	c7 44 24 08 5f 14 80 	movl   $0x80145f,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 53 14 80 00 	movl   $0x801453,(%esp)
  800ea5:	e8 22 00 00 00       	call   800ecc <_panic>

00800eaa <sfork>:
}

// Challenge!
int
sfork(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800eb0:	c7 44 24 08 5e 14 80 	movl   $0x80145e,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 53 14 80 00 	movl   $0x801453,(%esp)
  800ec7:	e8 00 00 00 00       	call   800ecc <_panic>

00800ecc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ed4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ed7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800edd:	e8 53 fd ff ff       	call   800c35 <sys_getenvid>
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef0:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef8:	c7 04 24 74 14 80 00 	movl   $0x801474,(%esp)
  800eff:	e8 db f2 ff ff       	call   8001df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	89 04 24             	mov    %eax,(%esp)
  800f0e:	e8 6b f2 ff ff       	call   80017e <vcprintf>
	cprintf("\n");
  800f13:	c7 04 24 cf 11 80 00 	movl   $0x8011cf,(%esp)
  800f1a:	e8 c0 f2 ff ff       	call   8001df <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f1f:	cc                   	int3   
  800f20:	eb fd                	jmp    800f1f <_panic+0x53>
  800f22:	66 90                	xchg   %ax,%ax
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__udivdi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f46:	85 c0                	test   %eax,%eax
  800f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f4c:	89 ea                	mov    %ebp,%edx
  800f4e:	89 0c 24             	mov    %ecx,(%esp)
  800f51:	75 2d                	jne    800f80 <__udivdi3+0x50>
  800f53:	39 e9                	cmp    %ebp,%ecx
  800f55:	77 61                	ja     800fb8 <__udivdi3+0x88>
  800f57:	85 c9                	test   %ecx,%ecx
  800f59:	89 ce                	mov    %ecx,%esi
  800f5b:	75 0b                	jne    800f68 <__udivdi3+0x38>
  800f5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f62:	31 d2                	xor    %edx,%edx
  800f64:	f7 f1                	div    %ecx
  800f66:	89 c6                	mov    %eax,%esi
  800f68:	31 d2                	xor    %edx,%edx
  800f6a:	89 e8                	mov    %ebp,%eax
  800f6c:	f7 f6                	div    %esi
  800f6e:	89 c5                	mov    %eax,%ebp
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	f7 f6                	div    %esi
  800f74:	89 ea                	mov    %ebp,%edx
  800f76:	83 c4 0c             	add    $0xc,%esp
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	39 e8                	cmp    %ebp,%eax
  800f82:	77 24                	ja     800fa8 <__udivdi3+0x78>
  800f84:	0f bd e8             	bsr    %eax,%ebp
  800f87:	83 f5 1f             	xor    $0x1f,%ebp
  800f8a:	75 3c                	jne    800fc8 <__udivdi3+0x98>
  800f8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f90:	39 34 24             	cmp    %esi,(%esp)
  800f93:	0f 86 9f 00 00 00    	jbe    801038 <__udivdi3+0x108>
  800f99:	39 d0                	cmp    %edx,%eax
  800f9b:	0f 82 97 00 00 00    	jb     801038 <__udivdi3+0x108>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	31 d2                	xor    %edx,%edx
  800faa:	31 c0                	xor    %eax,%eax
  800fac:	83 c4 0c             	add    $0xc,%esp
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    
  800fb3:	90                   	nop
  800fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	89 f8                	mov    %edi,%eax
  800fba:	f7 f1                	div    %ecx
  800fbc:	31 d2                	xor    %edx,%edx
  800fbe:	83 c4 0c             	add    $0xc,%esp
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	8b 3c 24             	mov    (%esp),%edi
  800fcd:	d3 e0                	shl    %cl,%eax
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd6:	29 e8                	sub    %ebp,%eax
  800fd8:	89 c1                	mov    %eax,%ecx
  800fda:	d3 ef                	shr    %cl,%edi
  800fdc:	89 e9                	mov    %ebp,%ecx
  800fde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe2:	8b 3c 24             	mov    (%esp),%edi
  800fe5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fe9:	89 d6                	mov    %edx,%esi
  800feb:	d3 e7                	shl    %cl,%edi
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	89 3c 24             	mov    %edi,(%esp)
  800ff2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff6:	d3 ee                	shr    %cl,%esi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	d3 e2                	shl    %cl,%edx
  800ffc:	89 c1                	mov    %eax,%ecx
  800ffe:	d3 ef                	shr    %cl,%edi
  801000:	09 d7                	or     %edx,%edi
  801002:	89 f2                	mov    %esi,%edx
  801004:	89 f8                	mov    %edi,%eax
  801006:	f7 74 24 08          	divl   0x8(%esp)
  80100a:	89 d6                	mov    %edx,%esi
  80100c:	89 c7                	mov    %eax,%edi
  80100e:	f7 24 24             	mull   (%esp)
  801011:	39 d6                	cmp    %edx,%esi
  801013:	89 14 24             	mov    %edx,(%esp)
  801016:	72 30                	jb     801048 <__udivdi3+0x118>
  801018:	8b 54 24 04          	mov    0x4(%esp),%edx
  80101c:	89 e9                	mov    %ebp,%ecx
  80101e:	d3 e2                	shl    %cl,%edx
  801020:	39 c2                	cmp    %eax,%edx
  801022:	73 05                	jae    801029 <__udivdi3+0xf9>
  801024:	3b 34 24             	cmp    (%esp),%esi
  801027:	74 1f                	je     801048 <__udivdi3+0x118>
  801029:	89 f8                	mov    %edi,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	e9 7a ff ff ff       	jmp    800fac <__udivdi3+0x7c>
  801032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801038:	31 d2                	xor    %edx,%edx
  80103a:	b8 01 00 00 00       	mov    $0x1,%eax
  80103f:	e9 68 ff ff ff       	jmp    800fac <__udivdi3+0x7c>
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	8d 47 ff             	lea    -0x1(%edi),%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	83 c4 0c             	add    $0xc,%esp
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    
  801054:	66 90                	xchg   %ax,%ax
  801056:	66 90                	xchg   %ax,%ax
  801058:	66 90                	xchg   %ax,%ax
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	83 ec 14             	sub    $0x14,%esp
  801066:	8b 44 24 28          	mov    0x28(%esp),%eax
  80106a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80106e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801072:	89 c7                	mov    %eax,%edi
  801074:	89 44 24 04          	mov    %eax,0x4(%esp)
  801078:	8b 44 24 30          	mov    0x30(%esp),%eax
  80107c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801080:	89 34 24             	mov    %esi,(%esp)
  801083:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801087:	85 c0                	test   %eax,%eax
  801089:	89 c2                	mov    %eax,%edx
  80108b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108f:	75 17                	jne    8010a8 <__umoddi3+0x48>
  801091:	39 fe                	cmp    %edi,%esi
  801093:	76 4b                	jbe    8010e0 <__umoddi3+0x80>
  801095:	89 c8                	mov    %ecx,%eax
  801097:	89 fa                	mov    %edi,%edx
  801099:	f7 f6                	div    %esi
  80109b:	89 d0                	mov    %edx,%eax
  80109d:	31 d2                	xor    %edx,%edx
  80109f:	83 c4 14             	add    $0x14,%esp
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
  8010a6:	66 90                	xchg   %ax,%ax
  8010a8:	39 f8                	cmp    %edi,%eax
  8010aa:	77 54                	ja     801100 <__umoddi3+0xa0>
  8010ac:	0f bd e8             	bsr    %eax,%ebp
  8010af:	83 f5 1f             	xor    $0x1f,%ebp
  8010b2:	75 5c                	jne    801110 <__umoddi3+0xb0>
  8010b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010b8:	39 3c 24             	cmp    %edi,(%esp)
  8010bb:	0f 87 e7 00 00 00    	ja     8011a8 <__umoddi3+0x148>
  8010c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010c5:	29 f1                	sub    %esi,%ecx
  8010c7:	19 c7                	sbb    %eax,%edi
  8010c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010d9:	83 c4 14             	add    $0x14,%esp
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    
  8010e0:	85 f6                	test   %esi,%esi
  8010e2:	89 f5                	mov    %esi,%ebp
  8010e4:	75 0b                	jne    8010f1 <__umoddi3+0x91>
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f6                	div    %esi
  8010ef:	89 c5                	mov    %eax,%ebp
  8010f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010f5:	31 d2                	xor    %edx,%edx
  8010f7:	f7 f5                	div    %ebp
  8010f9:	89 c8                	mov    %ecx,%eax
  8010fb:	f7 f5                	div    %ebp
  8010fd:	eb 9c                	jmp    80109b <__umoddi3+0x3b>
  8010ff:	90                   	nop
  801100:	89 c8                	mov    %ecx,%eax
  801102:	89 fa                	mov    %edi,%edx
  801104:	83 c4 14             	add    $0x14,%esp
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    
  80110b:	90                   	nop
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	8b 04 24             	mov    (%esp),%eax
  801113:	be 20 00 00 00       	mov    $0x20,%esi
  801118:	89 e9                	mov    %ebp,%ecx
  80111a:	29 ee                	sub    %ebp,%esi
  80111c:	d3 e2                	shl    %cl,%edx
  80111e:	89 f1                	mov    %esi,%ecx
  801120:	d3 e8                	shr    %cl,%eax
  801122:	89 e9                	mov    %ebp,%ecx
  801124:	89 44 24 04          	mov    %eax,0x4(%esp)
  801128:	8b 04 24             	mov    (%esp),%eax
  80112b:	09 54 24 04          	or     %edx,0x4(%esp)
  80112f:	89 fa                	mov    %edi,%edx
  801131:	d3 e0                	shl    %cl,%eax
  801133:	89 f1                	mov    %esi,%ecx
  801135:	89 44 24 08          	mov    %eax,0x8(%esp)
  801139:	8b 44 24 10          	mov    0x10(%esp),%eax
  80113d:	d3 ea                	shr    %cl,%edx
  80113f:	89 e9                	mov    %ebp,%ecx
  801141:	d3 e7                	shl    %cl,%edi
  801143:	89 f1                	mov    %esi,%ecx
  801145:	d3 e8                	shr    %cl,%eax
  801147:	89 e9                	mov    %ebp,%ecx
  801149:	09 f8                	or     %edi,%eax
  80114b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80114f:	f7 74 24 04          	divl   0x4(%esp)
  801153:	d3 e7                	shl    %cl,%edi
  801155:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801159:	89 d7                	mov    %edx,%edi
  80115b:	f7 64 24 08          	mull   0x8(%esp)
  80115f:	39 d7                	cmp    %edx,%edi
  801161:	89 c1                	mov    %eax,%ecx
  801163:	89 14 24             	mov    %edx,(%esp)
  801166:	72 2c                	jb     801194 <__umoddi3+0x134>
  801168:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80116c:	72 22                	jb     801190 <__umoddi3+0x130>
  80116e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801172:	29 c8                	sub    %ecx,%eax
  801174:	19 d7                	sbb    %edx,%edi
  801176:	89 e9                	mov    %ebp,%ecx
  801178:	89 fa                	mov    %edi,%edx
  80117a:	d3 e8                	shr    %cl,%eax
  80117c:	89 f1                	mov    %esi,%ecx
  80117e:	d3 e2                	shl    %cl,%edx
  801180:	89 e9                	mov    %ebp,%ecx
  801182:	d3 ef                	shr    %cl,%edi
  801184:	09 d0                	or     %edx,%eax
  801186:	89 fa                	mov    %edi,%edx
  801188:	83 c4 14             	add    $0x14,%esp
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    
  80118f:	90                   	nop
  801190:	39 d7                	cmp    %edx,%edi
  801192:	75 da                	jne    80116e <__umoddi3+0x10e>
  801194:	8b 14 24             	mov    (%esp),%edx
  801197:	89 c1                	mov    %eax,%ecx
  801199:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80119d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8011a1:	eb cb                	jmp    80116e <__umoddi3+0x10e>
  8011a3:	90                   	nop
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8011ac:	0f 82 0f ff ff ff    	jb     8010c1 <__umoddi3+0x61>
  8011b2:	e9 1a ff ff ff       	jmp    8010d1 <__umoddi3+0x71>
