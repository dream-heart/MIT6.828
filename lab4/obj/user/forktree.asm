
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
  80003d:	e8 03 0c 00 00       	call   800c45 <sys_getenvid>
  800042:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  800051:	e8 9c 01 00 00       	call   8001f2 <cprintf>

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
  80008d:	e8 9e 07 00 00       	call   800830 <strlen>
  800092:	83 f8 02             	cmp    $0x2,%eax
  800095:	7f 41                	jg     8000d8 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800097:	89 f0                	mov    %esi,%eax
  800099:	0f be f0             	movsbl %al,%esi
  80009c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a4:	c7 44 24 08 11 16 80 	movl   $0x801611,0x8(%esp)
  8000ab:	00 
  8000ac:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b3:	00 
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	89 04 24             	mov    %eax,(%esp)
  8000ba:	e8 49 07 00 00       	call   800808 <snprintf>
	if (fork() == 0) {
  8000bf:	e8 3e 0f 00 00       	call   801002 <fork>
  8000c4:	85 c0                	test   %eax,%eax
  8000c6:	75 10                	jne    8000d8 <forkchild+0x5c>
		forktree(nxt);
  8000c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 60 ff ff ff       	call   800033 <forktree>
		exit();
  8000d3:	e8 63 00 00 00       	call   80013b <exit>
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
  8000e5:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
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
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 10             	sub    $0x10,%esp
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800101:	e8 3f 0b 00 00       	call   800c45 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x30>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800123:	89 74 24 04          	mov    %esi,0x4(%esp)
  800127:	89 1c 24             	mov    %ebx,(%esp)
  80012a:	e8 b0 ff ff ff       	call   8000df <umain>

	// exit gracefully
	exit();
  80012f:	e8 07 00 00 00       	call   80013b <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 a6 0a 00 00       	call   800bf3 <sys_env_destroy>
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 14             	sub    $0x14,%esp
  800156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800159:	8b 13                	mov    (%ebx),%edx
  80015b:	8d 42 01             	lea    0x1(%edx),%eax
  80015e:	89 03                	mov    %eax,(%ebx)
  800160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800163:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016c:	75 19                	jne    800187 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 35 0a 00 00       	call   800bb6 <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	83 c4 14             	add    $0x14,%esp
  80018e:	5b                   	pop    %ebx
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a1:	00 00 00 
	b.cnt = 0;
  8001a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c6:	c7 04 24 4f 01 80 00 	movl   $0x80014f,(%esp)
  8001cd:	e8 72 01 00 00       	call   800344 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 cc 09 00 00       	call   800bb6 <sys_cputs>

	return b.cnt;
}
  8001ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	e8 87 ff ff ff       	call   800191 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    
  80020c:	66 90                	xchg   %ax,%ax
  80020e:	66 90                	xchg   %ax,%ax

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 c3                	mov    %eax,%ebx
  800229:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	b9 00 00 00 00       	mov    $0x0,%ecx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023d:	39 d9                	cmp    %ebx,%ecx
  80023f:	72 05                	jb     800246 <printnum+0x36>
  800241:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800244:	77 69                	ja     8002af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800249:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024d:	83 ee 01             	sub    $0x1,%esi
  800250:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8b 44 24 08          	mov    0x8(%esp),%eax
  80025c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800267:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	e8 ec 10 00 00       	call   801370 <__udivdi3>
  800284:	89 d9                	mov    %ebx,%ecx
  800286:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 71 ff ff ff       	call   800210 <printnum>
  80029f:	eb 1b                	jmp    8002bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff d3                	call   *%ebx
  8002ad:	eb 03                	jmp    8002b2 <printnum+0xa2>
  8002af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 ee 01             	sub    $0x1,%esi
  8002b5:	85 f6                	test   %esi,%esi
  8002b7:	7f e8                	jg     8002a1 <printnum+0x91>
  8002b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	e8 bc 11 00 00       	call   8014a0 <__umoddi3>
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	0f be 80 20 16 80 00 	movsbl 0x801620(%eax),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f5:	ff d0                	call   *%eax
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800305:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	3b 50 04             	cmp    0x4(%eax),%edx
  80030e:	73 0a                	jae    80031a <sprintputch+0x1b>
		*b->buf++ = ch;
  800310:	8d 4a 01             	lea    0x1(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	88 02                	mov    %al,(%edx)
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800322:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	8b 45 10             	mov    0x10(%ebp),%eax
  80032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
  800333:	89 44 24 04          	mov    %eax,0x4(%esp)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	e8 02 00 00 00       	call   800344 <vprintfmt>
	va_end(ap);
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
  800350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800353:	8b 7d 10             	mov    0x10(%ebp),%edi
  800356:	eb 11                	jmp    800369 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 48 04 00 00    	je     8007a8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	83 c7 01             	add    $0x1,%edi
  80036c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800370:	83 f8 25             	cmp    $0x25,%eax
  800373:	75 e3                	jne    800358 <vprintfmt+0x14>
  800375:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800379:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800380:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800387:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800393:	eb 1f                	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800398:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80039c:	eb 16                	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a5:	eb 0d                	jmp    8003b4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8d 47 01             	lea    0x1(%edi),%eax
  8003b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ba:	0f b6 17             	movzbl (%edi),%edx
  8003bd:	0f b6 c2             	movzbl %dl,%eax
  8003c0:	83 ea 23             	sub    $0x23,%edx
  8003c3:	80 fa 55             	cmp    $0x55,%dl
  8003c6:	0f 87 bf 03 00 00    	ja     80078b <vprintfmt+0x447>
  8003cc:	0f b6 d2             	movzbl %dl,%edx
  8003cf:	ff 24 95 e0 16 80 00 	jmp    *0x8016e0(,%edx,4)
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003e4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003e8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8003ee:	83 f9 09             	cmp    $0x9,%ecx
  8003f1:	77 3c                	ja     80042f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 40 04             	lea    0x4(%eax),%eax
  800406:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040c:	eb 27                	jmp    800435 <vprintfmt+0xf1>
  80040e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800411:	85 d2                	test   %edx,%edx
  800413:	b8 00 00 00 00       	mov    $0x0,%eax
  800418:	0f 49 c2             	cmovns %edx,%eax
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800421:	eb 91                	jmp    8003b4 <vprintfmt+0x70>
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800426:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042d:	eb 85                	jmp    8003b4 <vprintfmt+0x70>
  80042f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800432:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	0f 89 75 ff ff ff    	jns    8003b4 <vprintfmt+0x70>
  80043f:	e9 63 ff ff ff       	jmp    8003a7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800444:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044a:	e9 65 ff ff ff       	jmp    8003b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800464:	e9 00 ff ff ff       	jmp    800369 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	99                   	cltd   
  800473:	31 d0                	xor    %edx,%eax
  800475:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800477:	83 f8 09             	cmp    $0x9,%eax
  80047a:	7f 0b                	jg     800487 <vprintfmt+0x143>
  80047c:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  800483:	85 d2                	test   %edx,%edx
  800485:	75 20                	jne    8004a7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	c7 44 24 08 38 16 80 	movl   $0x801638,0x8(%esp)
  800492:	00 
  800493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800497:	89 34 24             	mov    %esi,(%esp)
  80049a:	e8 7d fe ff ff       	call   80031c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a2:	e9 c2 fe ff ff       	jmp    800369 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ab:	c7 44 24 08 41 16 80 	movl   $0x801641,0x8(%esp)
  8004b2:	00 
  8004b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b7:	89 34 24             	mov    %esi,(%esp)
  8004ba:	e8 5d fe ff ff       	call   80031c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	e9 a2 fe ff ff       	jmp    800369 <vprintfmt+0x25>
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	b8 31 16 80 00       	mov    $0x801631,%eax
  8004e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e7:	0f 84 92 00 00 00    	je     80057f <vprintfmt+0x23b>
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	0f 8e 98 00 00 00    	jle    80058d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f9:	89 3c 24             	mov    %edi,(%esp)
  8004fc:	e8 47 03 00 00       	call   800848 <strnlen>
  800501:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800504:	29 c1                	sub    %eax,%ecx
  800506:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800509:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800510:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800513:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	eb 0f                	jmp    800526 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	85 ff                	test   %edi,%edi
  800528:	7f ed                	jg     800517 <vprintfmt+0x1d3>
  80052a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800530:	85 c9                	test   %ecx,%ecx
  800532:	b8 00 00 00 00       	mov    $0x0,%eax
  800537:	0f 49 c1             	cmovns %ecx,%eax
  80053a:	29 c1                	sub    %eax,%ecx
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	89 cb                	mov    %ecx,%ebx
  800547:	eb 50                	jmp    800599 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054d:	74 1e                	je     80056d <vprintfmt+0x229>
  80054f:	0f be d2             	movsbl %dl,%edx
  800552:	83 ea 20             	sub    $0x20,%edx
  800555:	83 fa 5e             	cmp    $0x5e,%edx
  800558:	76 13                	jbe    80056d <vprintfmt+0x229>
					putch('?', putdat);
  80055a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	eb 0d                	jmp    80057a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80056d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800570:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	83 eb 01             	sub    $0x1,%ebx
  80057d:	eb 1a                	jmp    800599 <vprintfmt+0x255>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 0c                	jmp    800599 <vprintfmt+0x255>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a0:	0f be c2             	movsbl %dl,%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	74 25                	je     8005cc <vprintfmt+0x288>
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	78 9e                	js     800549 <vprintfmt+0x205>
  8005ab:	83 ee 01             	sub    $0x1,%esi
  8005ae:	79 99                	jns    800549 <vprintfmt+0x205>
  8005b0:	89 df                	mov    %ebx,%edi
  8005b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c7:	83 ef 01             	sub    $0x1,%edi
  8005ca:	eb 08                	jmp    8005d4 <vprintfmt+0x290>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f e2                	jg     8005ba <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	e9 89 fd ff ff       	jmp    800369 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 f9 01             	cmp    $0x1,%ecx
  8005e3:	7e 19                	jle    8005fe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 50 04             	mov    0x4(%eax),%edx
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 40 08             	lea    0x8(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fc:	eb 38                	jmp    800636 <vprintfmt+0x2f2>
	else if (lflag)
  8005fe:	85 c9                	test   %ecx,%ecx
  800600:	74 1b                	je     80061d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
  80061b:	eb 19                	jmp    800636 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 00                	mov    (%eax),%eax
  800622:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800625:	89 c1                	mov    %eax,%ecx
  800627:	c1 f9 1f             	sar    $0x1f,%ecx
  80062a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800636:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800639:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800641:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800645:	0f 89 04 01 00 00    	jns    80074f <vprintfmt+0x40b>
				putch('-', putdat);
  80064b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800656:	ff d6                	call   *%esi
				num = -(long long) num;
  800658:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80065e:	f7 da                	neg    %edx
  800660:	83 d1 00             	adc    $0x0,%ecx
  800663:	f7 d9                	neg    %ecx
  800665:	e9 e5 00 00 00       	jmp    80074f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 10                	jle    80067f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
  80067d:	eb 26                	jmp    8006a5 <vprintfmt+0x361>
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 12                	je     800695 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb 10                	jmp    8006a5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006aa:	e9 a0 00 00 00       	jmp    80074f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006ba:	ff d6                	call   *%esi
			putch('X', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c7:	ff d6                	call   *%esi
			putch('X', putdat);
  8006c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006d4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006d9:	e9 8b fc ff ff       	jmp    800369 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800708:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80070d:	eb 40                	jmp    80074f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070f:	83 f9 01             	cmp    $0x1,%ecx
  800712:	7e 10                	jle    800724 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	8b 48 04             	mov    0x4(%eax),%ecx
  80071c:	8d 40 08             	lea    0x8(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
  800722:	eb 26                	jmp    80074a <vprintfmt+0x406>
	else if (lflag)
  800724:	85 c9                	test   %ecx,%ecx
  800726:	74 12                	je     80073a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
  800738:	eb 10                	jmp    80074a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80074a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800753:	89 44 24 10          	mov    %eax,0x10(%esp)
  800757:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800762:	89 14 24             	mov    %edx,(%esp)
  800765:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800769:	89 da                	mov    %ebx,%edx
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	e8 9e fa ff ff       	call   800210 <printnum>
			break;
  800772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800775:	e9 ef fb ff ff       	jmp    800369 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800786:	e9 de fb ff ff       	jmp    800369 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800796:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	eb 03                	jmp    80079d <vprintfmt+0x459>
  80079a:	83 ef 01             	sub    $0x1,%edi
  80079d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x456>
  8007a3:	e9 c1 fb ff ff       	jmp    800369 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007a8:	83 c4 3c             	add    $0x3c,%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 28             	sub    $0x28,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 30                	je     800801 <vsnprintf+0x51>
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	7e 2c                	jle    800801 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	c7 04 24 ff 02 80 00 	movl   $0x8002ff,(%esp)
  8007f1:	e8 4e fb ff ff       	call   800344 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ff:	eb 05                	jmp    800806 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800815:	8b 45 10             	mov    0x10(%ebp),%eax
  800818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 82 ff ff ff       	call   8007b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800891:	89 1c 24             	mov    %ebx,(%esp)
  800894:	e8 97 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a0:	01 d8                	add    %ebx,%eax
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	e8 bd ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 0f                	jmp    8008d5 <strncpy+0x23>
		*dst++ = *src;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	0f b6 01             	movzbl (%ecx),%eax
  8008cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	39 da                	cmp    %ebx,%edx
  8008d7:	75 ed                	jne    8008c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 0b                	jne    800902 <strlcpy+0x23>
  8008f7:	eb 1d                	jmp    800916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
  8008ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 0b                	je     800911 <strlcpy+0x32>
  800906:	0f b6 0a             	movzbl (%edx),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1a>
  80090d:	89 c2                	mov    %eax,%edx
  80090f:	eb 02                	jmp    800913 <strlcpy+0x34>
  800911:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800916:	29 f0                	sub    %esi,%eax
}
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800925:	eb 06                	jmp    80092d <strcmp+0x11>
		p++, q++;
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092d:	0f b6 01             	movzbl (%ecx),%eax
  800930:	84 c0                	test   %al,%al
  800932:	74 04                	je     800938 <strcmp+0x1c>
  800934:	3a 02                	cmp    (%edx),%al
  800936:	74 ef                	je     800927 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800938:	0f b6 c0             	movzbl %al,%eax
  80093b:	0f b6 12             	movzbl (%edx),%edx
  80093e:	29 d0                	sub    %edx,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x17>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 15                	je     800972 <strncmp+0x30>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x26>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
  800970:	eb 05                	jmp    800977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800984:	eb 07                	jmp    80098d <strchr+0x13>
		if (*s == c)
  800986:	38 ca                	cmp    %cl,%dl
  800988:	74 0f                	je     800999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f2                	jne    800986 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	eb 07                	jmp    8009ae <strfind+0x13>
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 0a                	je     8009b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	75 f2                	jne    8009a7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c3:	85 c9                	test   %ecx,%ecx
  8009c5:	74 36                	je     8009fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 28                	jne    8009f7 <memset+0x40>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 23                	jne    8009f7 <memset+0x40>
		c &= 0xFF;
  8009d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 c2                	or     %eax,%edx
  8009eb:	89 d0                	mov    %edx,%eax
  8009ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f2:	fc                   	cld    
  8009f3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f5:	eb 06                	jmp    8009fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a12:	39 c6                	cmp    %eax,%esi
  800a14:	73 35                	jae    800a4b <memmove+0x47>
  800a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 2e                	jae    800a4b <memmove+0x47>
		s += n;
		d += n;
  800a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2a:	75 13                	jne    800a3f <memmove+0x3b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1d                	jmp    800a68 <memmove+0x64>
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c2 03             	test   $0x3,%dl
  800a52:	75 0f                	jne    800a63 <memmove+0x5f>
  800a54:	f6 c1 03             	test   $0x3,%cl
  800a57:	75 0a                	jne    800a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 05                	jmp    800a68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	fc                   	cld    
  800a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 79 ff ff ff       	call   800a04 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 02             	movzbl (%edx),%eax
  800aa2:	0f b6 19             	movzbl (%ecx),%ebx
  800aa5:	38 d8                	cmp    %bl,%al
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	39 f2                	cmp    %esi,%edx
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad4:	eb 07                	jmp    800add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 07                	je     800ae1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	39 d0                	cmp    %edx,%eax
  800adf:	72 f5                	jb     800ad6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aef:	eb 03                	jmp    800af4 <strtol+0x11>
		s++;
  800af1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	0f b6 0a             	movzbl (%edx),%ecx
  800af7:	80 f9 09             	cmp    $0x9,%cl
  800afa:	74 f5                	je     800af1 <strtol+0xe>
  800afc:	80 f9 20             	cmp    $0x20,%cl
  800aff:	74 f0                	je     800af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b01:	80 f9 2b             	cmp    $0x2b,%cl
  800b04:	75 0a                	jne    800b10 <strtol+0x2d>
		s++;
  800b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	eb 11                	jmp    800b21 <strtol+0x3e>
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b15:	80 f9 2d             	cmp    $0x2d,%cl
  800b18:	75 07                	jne    800b21 <strtol+0x3e>
		s++, neg = 1;
  800b1a:	8d 52 01             	lea    0x1(%edx),%edx
  800b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b26:	75 15                	jne    800b3d <strtol+0x5a>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	75 10                	jne    800b3d <strtol+0x5a>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x5a>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	b8 10 00 00 00       	mov    $0x10,%eax
  800b3b:	eb 10                	jmp    800b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 0c                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b43:	80 3a 30             	cmpb   $0x30,(%edx)
  800b46:	75 05                	jne    800b4d <strtol+0x6a>
		s++, base = 8;
  800b48:	83 c2 01             	add    $0x1,%edx
  800b4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 0a             	movzbl (%edx),%ecx
  800b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b5b:	89 f0                	mov    %esi,%eax
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	77 08                	ja     800b69 <strtol+0x86>
			dig = *s - '0';
  800b61:	0f be c9             	movsbl %cl,%ecx
  800b64:	83 e9 30             	sub    $0x30,%ecx
  800b67:	eb 20                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b6c:	89 f0                	mov    %esi,%eax
  800b6e:	3c 19                	cmp    $0x19,%al
  800b70:	77 08                	ja     800b7a <strtol+0x97>
			dig = *s - 'a' + 10;
  800b72:	0f be c9             	movsbl %cl,%ecx
  800b75:	83 e9 57             	sub    $0x57,%ecx
  800b78:	eb 0f                	jmp    800b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	3c 19                	cmp    $0x19,%al
  800b81:	77 16                	ja     800b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b83:	0f be c9             	movsbl %cl,%ecx
  800b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b8c:	7d 0f                	jge    800b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b97:	eb bc                	jmp    800b55 <strtol+0x72>
  800b99:	89 d8                	mov    %ebx,%eax
  800b9b:	eb 02                	jmp    800b9f <strtol+0xbc>
  800b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xc7>
		*endptr = (char *) s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800baa:	f7 d8                	neg    %eax
  800bac:	85 ff                	test   %edi,%edi
  800bae:	0f 44 c3             	cmove  %ebx,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 cb                	mov    %ecx,%ebx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	89 ce                	mov    %ecx,%esi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 28                	jle    800c3d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c19:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c20:	00 
  800c21:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c28:	00 
  800c29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c30:	00 
  800c31:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800c38:	e8 fa 05 00 00       	call   801237 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	83 c4 2c             	add    $0x2c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800cca:	e8 68 05 00 00       	call   801237 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d1d:	e8 15 05 00 00       	call   801237 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d70:	e8 c2 04 00 00       	call   801237 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800dc3:	e8 6f 04 00 00       	call   801237 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc8:	83 c4 2c             	add    $0x2c,%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 09 00 00 00       	mov    $0x9,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e16:	e8 1c 04 00 00       	call   801237 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1b:	83 c4 2c             	add    $0x2c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	be 00 00 00 00       	mov    $0x0,%esi
  800e2e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 cb                	mov    %ecx,%ebx
  800e5e:	89 cf                	mov    %ecx,%edi
  800e60:	89 ce                	mov    %ecx,%esi
  800e62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	7e 28                	jle    800e90 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e73:	00 
  800e74:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e83:	00 
  800e84:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e8b:	e8 a7 03 00 00       	call   801237 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e90:	83 c4 2c             	add    $0x2c,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	83 ec 20             	sub    $0x20,%esp
  800ea0:	8b 5d 08             	mov    0x8(%ebp),%ebx


	void *addr = (void *) utf->utf_fault_va;
  800ea3:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if( (err & FEC_WR) == 0){
  800ea5:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  800ea9:	75 3f                	jne    800eea <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  800eab:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eaf:	c7 04 24 93 18 80 00 	movl   $0x801893,(%esp)
  800eb6:	e8 37 f3 ff ff       	call   8001f2 <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  800ebb:	8b 43 28             	mov    0x28(%ebx),%eax
  800ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec2:	c7 04 24 a3 18 80 00 	movl   $0x8018a3,(%esp)
  800ec9:	e8 24 f3 ff ff       	call   8001f2 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  800ece:	c7 44 24 08 e8 18 80 	movl   $0x8018e8,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  800ee5:	e8 4d 03 00 00       	call   801237 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	c1 e8 0c             	shr    $0xc,%eax
  800eef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  800ef6:	f6 c4 08             	test   $0x8,%ah
  800ef9:	75 1c                	jne    800f17 <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  800efb:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800f02:	00 
  800f03:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f0a:	00 
  800f0b:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  800f12:	e8 20 03 00 00       	call   801237 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  800f17:	e8 29 fd ff ff       	call   800c45 <sys_getenvid>
  800f1c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f2b:	00 
  800f2c:	89 04 24             	mov    %eax,(%esp)
  800f2f:	e8 4f fd ff ff       	call   800c83 <sys_page_alloc>
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 1c                	jns    800f54 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  800f38:	c7 44 24 08 30 19 80 	movl   $0x801930,0x8(%esp)
  800f3f:	00 
  800f40:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800f47:	00 
  800f48:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  800f4f:	e8 e3 02 00 00       	call   801237 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  800f54:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f61:	00 
  800f62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f66:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f6d:	e8 fa fa ff ff       	call   800a6c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  800f72:	e8 ce fc ff ff       	call   800c45 <sys_getenvid>
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	e8 c7 fc ff ff       	call   800c45 <sys_getenvid>
  800f7e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f85:	00 
  800f86:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f8a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f8e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f95:	00 
  800f96:	89 04 24             	mov    %eax,(%esp)
  800f99:	e8 39 fd ff ff       	call   800cd7 <sys_page_map>
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 20                	jns    800fc2 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  800fa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa6:	c7 44 24 08 58 19 80 	movl   $0x801958,0x8(%esp)
  800fad:	00 
  800fae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800fb5:	00 
  800fb6:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  800fbd:	e8 75 02 00 00       	call   801237 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  800fc2:	e8 7e fc ff ff       	call   800c45 <sys_getenvid>
  800fc7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fce:	00 
  800fcf:	89 04 24             	mov    %eax,(%esp)
  800fd2:	e8 53 fd ff ff       	call   800d2a <sys_page_unmap>
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	79 20                	jns    800ffb <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  800fdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fdf:	c7 44 24 08 88 19 80 	movl   $0x801988,0x8(%esp)
  800fe6:	00 
  800fe7:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  800fee:	00 
  800fef:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  800ff6:	e8 3c 02 00 00       	call   801237 <_panic>
	return;

	

	//panic("pgfault not implemented");
}
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	57                   	push   %edi
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80100b:	c7 04 24 98 0e 80 00 	movl   $0x800e98,(%esp)
  801012:	e8 76 02 00 00       	call   80128d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801017:	b8 07 00 00 00       	mov    $0x7,%eax
  80101c:	cd 30                	int    $0x30
  80101e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801021:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	79 20                	jns    801048 <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801028:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80102c:	c7 44 24 08 bc 19 80 	movl   $0x8019bc,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  801043:	e8 ef 01 00 00       	call   801237 <_panic>
	if(childEid == 0){
  801048:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80104c:	75 1c                	jne    80106a <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80104e:	e8 f2 fb ff ff       	call   800c45 <sys_getenvid>
  801053:	25 ff 03 00 00       	and    $0x3ff,%eax
  801058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80105b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801060:	a3 04 20 80 00       	mov    %eax,0x802004
		return childEid;
  801065:	e9 a0 01 00 00       	jmp    80120a <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80106a:	c7 44 24 04 23 13 80 	movl   $0x801323,0x4(%esp)
  801071:	00 
  801072:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801075:	89 04 24             	mov    %eax,(%esp)
  801078:	e8 53 fd ff ff       	call   800dd0 <sys_env_set_pgfault_upcall>
  80107d:	89 c7                	mov    %eax,%edi
	if(r < 0)
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 20                	jns    8010a3 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801087:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  80109e:	e8 94 01 00 00       	call   801237 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8010a3:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	c1 ea 16             	shr    $0x16,%edx
  8010ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c1:	f6 c2 01             	test   $0x1,%dl
  8010c4:	0f 84 f7 00 00 00    	je     8011c1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8010ca:	c1 e8 0c             	shr    $0xc,%eax
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8010d4:	f6 c2 04             	test   $0x4,%dl
  8010d7:	0f 84 e4 00 00 00    	je     8011c1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8010dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8010e4:	a8 01                	test   $0x1,%al
  8010e6:	0f 84 d5 00 00 00    	je     8011c1 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8010ec:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8010f2:	75 20                	jne    801114 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8010f4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801103:	ee 
  801104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801107:	89 04 24             	mov    %eax,(%esp)
  80110a:	e8 74 fb ff ff       	call   800c83 <sys_page_alloc>
  80110f:	e9 84 00 00 00       	jmp    801198 <fork+0x196>
  801114:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80111a:	89 f8                	mov    %edi,%eax
  80111c:	c1 e8 0c             	shr    $0xc,%eax
  80111f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801126:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80112b:	83 f8 01             	cmp    $0x1,%eax
  80112e:	19 db                	sbb    %ebx,%ebx
  801130:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801136:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80113c:	e8 04 fb ff ff       	call   800c45 <sys_getenvid>
  801141:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801145:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801149:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80114c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801150:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801154:	89 04 24             	mov    %eax,(%esp)
  801157:	e8 7b fb ff ff       	call   800cd7 <sys_page_map>
  80115c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 35                	js     801198 <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801163:	e8 dd fa ff ff       	call   800c45 <sys_getenvid>
  801168:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80116b:	e8 d5 fa ff ff       	call   800c45 <sys_getenvid>
  801170:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801174:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801178:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80117b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801183:	89 04 24             	mov    %eax,(%esp)
  801186:	e8 4c fb ff ff       	call   800cd7 <sys_page_map>
  80118b:	85 c0                	test   %eax,%eax
  80118d:	bf 00 00 00 00       	mov    $0x0,%edi
  801192:	0f 4f c7             	cmovg  %edi,%eax
  801195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801198:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80119c:	79 23                	jns    8011c1 <fork+0x1bf>
  80119e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8011a1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a5:	c7 44 24 08 30 1a 80 	movl   $0x801a30,0x8(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8011b4:	00 
  8011b5:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  8011bc:	e8 76 00 00 00       	call   801237 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8011c1:	89 f1                	mov    %esi,%ecx
  8011c3:	89 f0                	mov    %esi,%eax
  8011c5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8011cb:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8011d1:	0f 85 de fe ff ff    	jne    8010b5 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8011d7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011de:	00 
  8011df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011e2:	89 04 24             	mov    %eax,(%esp)
  8011e5:	e8 93 fb ff ff       	call   800d7d <sys_env_set_status>
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 1c                	jns    80120a <fork+0x208>
		panic("sys_env_set_status");
  8011ee:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011fd:	00 
  8011fe:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  801205:	e8 2d 00 00 00       	call   801237 <_panic>
	return childEid;
}
  80120a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120d:	83 c4 2c             	add    $0x2c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sfork>:

// Challenge!
int
sfork(void)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80121b:	c7 44 24 08 d2 18 80 	movl   $0x8018d2,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 b4 18 80 00 	movl   $0x8018b4,(%esp)
  801232:	e8 00 00 00 00       	call   801237 <_panic>

00801237 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80123f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801242:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801248:	e8 f8 f9 ff ff       	call   800c45 <sys_getenvid>
  80124d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801250:	89 54 24 10          	mov    %edx,0x10(%esp)
  801254:	8b 55 08             	mov    0x8(%ebp),%edx
  801257:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80125b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	c7 04 24 58 1a 80 00 	movl   $0x801a58,(%esp)
  80126a:	e8 83 ef ff ff       	call   8001f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80126f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801273:	8b 45 10             	mov    0x10(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 13 ef ff ff       	call   800191 <vcprintf>
	cprintf("\n");
  80127e:	c7 04 24 0f 16 80 00 	movl   $0x80160f,(%esp)
  801285:	e8 68 ef ff ff       	call   8001f2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80128a:	cc                   	int3   
  80128b:	eb fd                	jmp    80128a <_panic+0x53>

0080128d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801293:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80129a:	75 44                	jne    8012e0 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80129c:	a1 04 20 80 00       	mov    0x802004,%eax
  8012a1:	8b 40 48             	mov    0x48(%eax),%eax
  8012a4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012b3:	ee 
  8012b4:	89 04 24             	mov    %eax,(%esp)
  8012b7:	e8 c7 f9 ff ff       	call   800c83 <sys_page_alloc>
		if( r < 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	79 20                	jns    8012e0 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  8012c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c4:	c7 44 24 08 7c 1a 80 	movl   $0x801a7c,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d3:	00 
  8012d4:	c7 04 24 d8 1a 80 00 	movl   $0x801ad8,(%esp)
  8012db:	e8 57 ff ff ff       	call   801237 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e3:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  8012e8:	e8 58 f9 ff ff       	call   800c45 <sys_getenvid>
  8012ed:	c7 44 24 04 23 13 80 	movl   $0x801323,0x4(%esp)
  8012f4:	00 
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	e8 d3 fa ff ff       	call   800dd0 <sys_env_set_pgfault_upcall>
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	79 20                	jns    801321 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  801301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801305:	c7 44 24 08 ac 1a 80 	movl   $0x801aac,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 d8 1a 80 00 	movl   $0x801ad8,(%esp)
  80131c:	e8 16 ff ff ff       	call   801237 <_panic>


}
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801323:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801324:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801329:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80132b:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  80132e:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  801332:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  801336:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  80133a:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  80133d:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  801340:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  801343:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  801347:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  80134b:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  80134f:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  801353:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  801357:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  80135b:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  80135f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  801360:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801361:	c3                   	ret    
  801362:	66 90                	xchg   %ax,%ax
  801364:	66 90                	xchg   %ax,%ax
  801366:	66 90                	xchg   %ax,%ax
  801368:	66 90                	xchg   %ax,%ax
  80136a:	66 90                	xchg   %ax,%ax
  80136c:	66 90                	xchg   %ax,%ax
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__udivdi3>:
  801370:	55                   	push   %ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80137a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80137e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801382:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801386:	85 c0                	test   %eax,%eax
  801388:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80138c:	89 ea                	mov    %ebp,%edx
  80138e:	89 0c 24             	mov    %ecx,(%esp)
  801391:	75 2d                	jne    8013c0 <__udivdi3+0x50>
  801393:	39 e9                	cmp    %ebp,%ecx
  801395:	77 61                	ja     8013f8 <__udivdi3+0x88>
  801397:	85 c9                	test   %ecx,%ecx
  801399:	89 ce                	mov    %ecx,%esi
  80139b:	75 0b                	jne    8013a8 <__udivdi3+0x38>
  80139d:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a2:	31 d2                	xor    %edx,%edx
  8013a4:	f7 f1                	div    %ecx
  8013a6:	89 c6                	mov    %eax,%esi
  8013a8:	31 d2                	xor    %edx,%edx
  8013aa:	89 e8                	mov    %ebp,%eax
  8013ac:	f7 f6                	div    %esi
  8013ae:	89 c5                	mov    %eax,%ebp
  8013b0:	89 f8                	mov    %edi,%eax
  8013b2:	f7 f6                	div    %esi
  8013b4:	89 ea                	mov    %ebp,%edx
  8013b6:	83 c4 0c             	add    $0xc,%esp
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
  8013bd:	8d 76 00             	lea    0x0(%esi),%esi
  8013c0:	39 e8                	cmp    %ebp,%eax
  8013c2:	77 24                	ja     8013e8 <__udivdi3+0x78>
  8013c4:	0f bd e8             	bsr    %eax,%ebp
  8013c7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ca:	75 3c                	jne    801408 <__udivdi3+0x98>
  8013cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013d0:	39 34 24             	cmp    %esi,(%esp)
  8013d3:	0f 86 9f 00 00 00    	jbe    801478 <__udivdi3+0x108>
  8013d9:	39 d0                	cmp    %edx,%eax
  8013db:	0f 82 97 00 00 00    	jb     801478 <__udivdi3+0x108>
  8013e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	31 c0                	xor    %eax,%eax
  8013ec:	83 c4 0c             	add    $0xc,%esp
  8013ef:	5e                   	pop    %esi
  8013f0:	5f                   	pop    %edi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    
  8013f3:	90                   	nop
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	89 f8                	mov    %edi,%eax
  8013fa:	f7 f1                	div    %ecx
  8013fc:	31 d2                	xor    %edx,%edx
  8013fe:	83 c4 0c             	add    $0xc,%esp
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    
  801405:	8d 76 00             	lea    0x0(%esi),%esi
  801408:	89 e9                	mov    %ebp,%ecx
  80140a:	8b 3c 24             	mov    (%esp),%edi
  80140d:	d3 e0                	shl    %cl,%eax
  80140f:	89 c6                	mov    %eax,%esi
  801411:	b8 20 00 00 00       	mov    $0x20,%eax
  801416:	29 e8                	sub    %ebp,%eax
  801418:	89 c1                	mov    %eax,%ecx
  80141a:	d3 ef                	shr    %cl,%edi
  80141c:	89 e9                	mov    %ebp,%ecx
  80141e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801422:	8b 3c 24             	mov    (%esp),%edi
  801425:	09 74 24 08          	or     %esi,0x8(%esp)
  801429:	89 d6                	mov    %edx,%esi
  80142b:	d3 e7                	shl    %cl,%edi
  80142d:	89 c1                	mov    %eax,%ecx
  80142f:	89 3c 24             	mov    %edi,(%esp)
  801432:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801436:	d3 ee                	shr    %cl,%esi
  801438:	89 e9                	mov    %ebp,%ecx
  80143a:	d3 e2                	shl    %cl,%edx
  80143c:	89 c1                	mov    %eax,%ecx
  80143e:	d3 ef                	shr    %cl,%edi
  801440:	09 d7                	or     %edx,%edi
  801442:	89 f2                	mov    %esi,%edx
  801444:	89 f8                	mov    %edi,%eax
  801446:	f7 74 24 08          	divl   0x8(%esp)
  80144a:	89 d6                	mov    %edx,%esi
  80144c:	89 c7                	mov    %eax,%edi
  80144e:	f7 24 24             	mull   (%esp)
  801451:	39 d6                	cmp    %edx,%esi
  801453:	89 14 24             	mov    %edx,(%esp)
  801456:	72 30                	jb     801488 <__udivdi3+0x118>
  801458:	8b 54 24 04          	mov    0x4(%esp),%edx
  80145c:	89 e9                	mov    %ebp,%ecx
  80145e:	d3 e2                	shl    %cl,%edx
  801460:	39 c2                	cmp    %eax,%edx
  801462:	73 05                	jae    801469 <__udivdi3+0xf9>
  801464:	3b 34 24             	cmp    (%esp),%esi
  801467:	74 1f                	je     801488 <__udivdi3+0x118>
  801469:	89 f8                	mov    %edi,%eax
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	e9 7a ff ff ff       	jmp    8013ec <__udivdi3+0x7c>
  801472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801478:	31 d2                	xor    %edx,%edx
  80147a:	b8 01 00 00 00       	mov    $0x1,%eax
  80147f:	e9 68 ff ff ff       	jmp    8013ec <__udivdi3+0x7c>
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	8d 47 ff             	lea    -0x1(%edi),%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	83 c4 0c             	add    $0xc,%esp
  801490:	5e                   	pop    %esi
  801491:	5f                   	pop    %edi
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    
  801494:	66 90                	xchg   %ax,%ax
  801496:	66 90                	xchg   %ax,%ax
  801498:	66 90                	xchg   %ax,%ax
  80149a:	66 90                	xchg   %ax,%ax
  80149c:	66 90                	xchg   %ax,%ax
  80149e:	66 90                	xchg   %ax,%ax

008014a0 <__umoddi3>:
  8014a0:	55                   	push   %ebp
  8014a1:	57                   	push   %edi
  8014a2:	56                   	push   %esi
  8014a3:	83 ec 14             	sub    $0x14,%esp
  8014a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014b2:	89 c7                	mov    %eax,%edi
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014c0:	89 34 24             	mov    %esi,(%esp)
  8014c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014cf:	75 17                	jne    8014e8 <__umoddi3+0x48>
  8014d1:	39 fe                	cmp    %edi,%esi
  8014d3:	76 4b                	jbe    801520 <__umoddi3+0x80>
  8014d5:	89 c8                	mov    %ecx,%eax
  8014d7:	89 fa                	mov    %edi,%edx
  8014d9:	f7 f6                	div    %esi
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	31 d2                	xor    %edx,%edx
  8014df:	83 c4 14             	add    $0x14,%esp
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
  8014e6:	66 90                	xchg   %ax,%ax
  8014e8:	39 f8                	cmp    %edi,%eax
  8014ea:	77 54                	ja     801540 <__umoddi3+0xa0>
  8014ec:	0f bd e8             	bsr    %eax,%ebp
  8014ef:	83 f5 1f             	xor    $0x1f,%ebp
  8014f2:	75 5c                	jne    801550 <__umoddi3+0xb0>
  8014f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014f8:	39 3c 24             	cmp    %edi,(%esp)
  8014fb:	0f 87 e7 00 00 00    	ja     8015e8 <__umoddi3+0x148>
  801501:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801505:	29 f1                	sub    %esi,%ecx
  801507:	19 c7                	sbb    %eax,%edi
  801509:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80150d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801511:	8b 44 24 08          	mov    0x8(%esp),%eax
  801515:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801519:	83 c4 14             	add    $0x14,%esp
  80151c:	5e                   	pop    %esi
  80151d:	5f                   	pop    %edi
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    
  801520:	85 f6                	test   %esi,%esi
  801522:	89 f5                	mov    %esi,%ebp
  801524:	75 0b                	jne    801531 <__umoddi3+0x91>
  801526:	b8 01 00 00 00       	mov    $0x1,%eax
  80152b:	31 d2                	xor    %edx,%edx
  80152d:	f7 f6                	div    %esi
  80152f:	89 c5                	mov    %eax,%ebp
  801531:	8b 44 24 04          	mov    0x4(%esp),%eax
  801535:	31 d2                	xor    %edx,%edx
  801537:	f7 f5                	div    %ebp
  801539:	89 c8                	mov    %ecx,%eax
  80153b:	f7 f5                	div    %ebp
  80153d:	eb 9c                	jmp    8014db <__umoddi3+0x3b>
  80153f:	90                   	nop
  801540:	89 c8                	mov    %ecx,%eax
  801542:	89 fa                	mov    %edi,%edx
  801544:	83 c4 14             	add    $0x14,%esp
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    
  80154b:	90                   	nop
  80154c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801550:	8b 04 24             	mov    (%esp),%eax
  801553:	be 20 00 00 00       	mov    $0x20,%esi
  801558:	89 e9                	mov    %ebp,%ecx
  80155a:	29 ee                	sub    %ebp,%esi
  80155c:	d3 e2                	shl    %cl,%edx
  80155e:	89 f1                	mov    %esi,%ecx
  801560:	d3 e8                	shr    %cl,%eax
  801562:	89 e9                	mov    %ebp,%ecx
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 04 24             	mov    (%esp),%eax
  80156b:	09 54 24 04          	or     %edx,0x4(%esp)
  80156f:	89 fa                	mov    %edi,%edx
  801571:	d3 e0                	shl    %cl,%eax
  801573:	89 f1                	mov    %esi,%ecx
  801575:	89 44 24 08          	mov    %eax,0x8(%esp)
  801579:	8b 44 24 10          	mov    0x10(%esp),%eax
  80157d:	d3 ea                	shr    %cl,%edx
  80157f:	89 e9                	mov    %ebp,%ecx
  801581:	d3 e7                	shl    %cl,%edi
  801583:	89 f1                	mov    %esi,%ecx
  801585:	d3 e8                	shr    %cl,%eax
  801587:	89 e9                	mov    %ebp,%ecx
  801589:	09 f8                	or     %edi,%eax
  80158b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80158f:	f7 74 24 04          	divl   0x4(%esp)
  801593:	d3 e7                	shl    %cl,%edi
  801595:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801599:	89 d7                	mov    %edx,%edi
  80159b:	f7 64 24 08          	mull   0x8(%esp)
  80159f:	39 d7                	cmp    %edx,%edi
  8015a1:	89 c1                	mov    %eax,%ecx
  8015a3:	89 14 24             	mov    %edx,(%esp)
  8015a6:	72 2c                	jb     8015d4 <__umoddi3+0x134>
  8015a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015ac:	72 22                	jb     8015d0 <__umoddi3+0x130>
  8015ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015b2:	29 c8                	sub    %ecx,%eax
  8015b4:	19 d7                	sbb    %edx,%edi
  8015b6:	89 e9                	mov    %ebp,%ecx
  8015b8:	89 fa                	mov    %edi,%edx
  8015ba:	d3 e8                	shr    %cl,%eax
  8015bc:	89 f1                	mov    %esi,%ecx
  8015be:	d3 e2                	shl    %cl,%edx
  8015c0:	89 e9                	mov    %ebp,%ecx
  8015c2:	d3 ef                	shr    %cl,%edi
  8015c4:	09 d0                	or     %edx,%eax
  8015c6:	89 fa                	mov    %edi,%edx
  8015c8:	83 c4 14             	add    $0x14,%esp
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    
  8015cf:	90                   	nop
  8015d0:	39 d7                	cmp    %edx,%edi
  8015d2:	75 da                	jne    8015ae <__umoddi3+0x10e>
  8015d4:	8b 14 24             	mov    (%esp),%edx
  8015d7:	89 c1                	mov    %eax,%ecx
  8015d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015e1:	eb cb                	jmp    8015ae <__umoddi3+0x10e>
  8015e3:	90                   	nop
  8015e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015ec:	0f 82 0f ff ff ff    	jb     801501 <__umoddi3+0x61>
  8015f2:	e9 1a ff ff ff       	jmp    801511 <__umoddi3+0x71>
