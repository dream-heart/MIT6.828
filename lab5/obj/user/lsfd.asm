
obj/user/lsfd.debug：     文件格式 elf32-i386


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
  80002c:	e8 01 01 00 00       	call   800132 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800040:	e8 ec 01 00 00       	call   800231 <cprintf>
	exit();
  800045:	e8 30 01 00 00       	call   80017a <exit>
}
  80004a:	c9                   	leave  
  80004b:	c3                   	ret    

0080004c <umain>:

void
umain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	57                   	push   %edi
  800050:	56                   	push   %esi
  800051:	53                   	push   %ebx
  800052:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800058:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800062:	8b 45 0c             	mov    0xc(%ebp),%eax
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	8d 45 08             	lea    0x8(%ebp),%eax
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 b7 0e 00 00       	call   800f2b <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800074:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800079:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007f:	eb 11                	jmp    800092 <umain+0x46>
		if (i == '1')
  800081:	83 f8 31             	cmp    $0x31,%eax
  800084:	75 07                	jne    80008d <umain+0x41>
			usefprint = 1;
  800086:	be 01 00 00 00       	mov    $0x1,%esi
  80008b:	eb 05                	jmp    800092 <umain+0x46>
		else
			usage();
  80008d:	e8 a1 ff ff ff       	call   800033 <usage>
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800092:	89 1c 24             	mov    %ebx,(%esp)
  800095:	e8 c9 0e 00 00       	call   800f63 <argnext>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 e3                	jns    800081 <umain+0x35>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a3:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000ad:	89 1c 24             	mov    %ebx,(%esp)
  8000b0:	e8 fc 14 00 00       	call   8015b1 <fstat>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 66                	js     80011f <umain+0xd3>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 36                	je     8000f3 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000ca:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000dd:	c7 44 24 04 14 24 80 	movl   $0x802414,0x4(%esp)
  8000e4:	00 
  8000e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000ec:	e8 df 18 00 00       	call   8019d0 <fprintf>
  8000f1:	eb 2c                	jmp    80011f <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000f6:	8b 40 04             	mov    0x4(%eax),%eax
  8000f9:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800100:	89 44 24 10          	mov    %eax,0x10(%esp)
  800104:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800107:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010b:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80010f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800113:	c7 04 24 14 24 80 00 	movl   $0x802414,(%esp)
  80011a:	e8 12 01 00 00       	call   800231 <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  80011f:	83 c3 01             	add    $0x1,%ebx
  800122:	83 fb 20             	cmp    $0x20,%ebx
  800125:	75 82                	jne    8000a9 <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800127:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
  800137:	83 ec 10             	sub    $0x10,%esp
  80013a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800140:	e8 40 0b 00 00       	call   800c85 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800145:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800152:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800157:	85 db                	test   %ebx,%ebx
  800159:	7e 07                	jle    800162 <libmain+0x30>
		binaryname = argv[0];
  80015b:	8b 06                	mov    (%esi),%eax
  80015d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800162:	89 74 24 04          	mov    %esi,0x4(%esp)
  800166:	89 1c 24             	mov    %ebx,(%esp)
  800169:	e8 de fe ff ff       	call   80004c <umain>

	// exit gracefully
	exit();
  80016e:	e8 07 00 00 00       	call   80017a <exit>
}
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800187:	e8 a7 0a 00 00       	call   800c33 <sys_env_destroy>
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 14             	sub    $0x14,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	75 19                	jne    8001c6 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b4:	00 
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 36 0a 00 00       	call   800bf6 <sys_cputs>
		b->idx = 0;
  8001c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ca:	83 c4 14             	add    $0x14,%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e0:	00 00 00 
	b.cnt = 0;
  8001e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	c7 04 24 8e 01 80 00 	movl   $0x80018e,(%esp)
  80020c:	e8 73 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 cd 09 00 00       	call   800bf6 <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 87 ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    
  80024b:	66 90                	xchg   %ax,%ax
  80024d:	66 90                	xchg   %ax,%ax
  80024f:	90                   	nop

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 c3                	mov    %eax,%ebx
  800269:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	39 d9                	cmp    %ebx,%ecx
  80027f:	72 05                	jb     800286 <printnum+0x36>
  800281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800284:	77 69                	ja     8002ef <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800289:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028d:	83 ee 01             	sub    $0x1,%esi
  800290:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8b 44 24 08          	mov    0x8(%esp),%eax
  80029c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002a0:	89 c3                	mov    %eax,%ebx
  8002a2:	89 d6                	mov    %edx,%esi
  8002a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bf:	e8 9c 1e 00 00       	call   802160 <__udivdi3>
  8002c4:	89 d9                	mov    %ebx,%ecx
  8002c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 71 ff ff ff       	call   800250 <printnum>
  8002df:	eb 1b                	jmp    8002fc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff d3                	call   *%ebx
  8002ed:	eb 03                	jmp    8002f2 <printnum+0xa2>
  8002ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	83 ee 01             	sub    $0x1,%esi
  8002f5:	85 f6                	test   %esi,%esi
  8002f7:	7f e8                	jg     8002e1 <printnum+0x91>
  8002f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800304:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800307:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	e8 6c 1f 00 00       	call   802290 <__umoddi3>
  800324:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800328:	0f be 80 46 24 80 00 	movsbl 0x802446(%eax),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800335:	ff d0                	call   *%eax
}
  800337:	83 c4 3c             	add    $0x3c,%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800345:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	3b 50 04             	cmp    0x4(%eax),%edx
  80034e:	73 0a                	jae    80035a <sprintputch+0x1b>
		*b->buf++ = ch;
  800350:	8d 4a 01             	lea    0x1(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	88 02                	mov    %al,(%edx)
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	e8 02 00 00 00       	call   800384 <vprintfmt>
	va_end(ap);
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 3c             	sub    $0x3c,%esp
  80038d:	8b 75 08             	mov    0x8(%ebp),%esi
  800390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800393:	8b 7d 10             	mov    0x10(%ebp),%edi
  800396:	eb 11                	jmp    8003a9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800398:	85 c0                	test   %eax,%eax
  80039a:	0f 84 48 04 00 00    	je     8007e8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8003a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	83 c7 01             	add    $0x1,%edi
  8003ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b0:	83 f8 25             	cmp    $0x25,%eax
  8003b3:	75 e3                	jne    800398 <vprintfmt+0x14>
  8003b5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003b9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d3:	eb 1f                	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003dc:	eb 16                	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e5:	eb 0d                	jmp    8003f4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8d 47 01             	lea    0x1(%edi),%eax
  8003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fa:	0f b6 17             	movzbl (%edi),%edx
  8003fd:	0f b6 c2             	movzbl %dl,%eax
  800400:	83 ea 23             	sub    $0x23,%edx
  800403:	80 fa 55             	cmp    $0x55,%dl
  800406:	0f 87 bf 03 00 00    	ja     8007cb <vprintfmt+0x447>
  80040c:	0f b6 d2             	movzbl %dl,%edx
  80040f:	ff 24 95 80 25 80 00 	jmp    *0x802580(,%edx,4)
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	ba 00 00 00 00       	mov    $0x0,%edx
  80041e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800421:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800424:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800428:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80042b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80042e:	83 f9 09             	cmp    $0x9,%ecx
  800431:	77 3c                	ja     80046f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800433:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800436:	eb e9                	jmp    800421 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 40 04             	lea    0x4(%eax),%eax
  800446:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044c:	eb 27                	jmp    800475 <vprintfmt+0xf1>
  80044e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c2             	cmovns %edx,%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	eb 91                	jmp    8003f4 <vprintfmt+0x70>
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800466:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80046d:	eb 85                	jmp    8003f4 <vprintfmt+0x70>
  80046f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800472:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800475:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800479:	0f 89 75 ff ff ff    	jns    8003f4 <vprintfmt+0x70>
  80047f:	e9 63 ff ff ff       	jmp    8003e7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800484:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048a:	e9 65 ff ff ff       	jmp    8003f4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800492:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800496:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a4:	e9 00 ff ff ff       	jmp    8003a9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ac:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	99                   	cltd   
  8004b3:	31 d0                	xor    %edx,%eax
  8004b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b7:	83 f8 0f             	cmp    $0xf,%eax
  8004ba:	7f 0b                	jg     8004c7 <vprintfmt+0x143>
  8004bc:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	75 20                	jne    8004e7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cb:	c7 44 24 08 5e 24 80 	movl   $0x80245e,0x8(%esp)
  8004d2:	00 
  8004d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d7:	89 34 24             	mov    %esi,(%esp)
  8004da:	e8 7d fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e2:	e9 c2 fe ff ff       	jmp    8003a9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004eb:	c7 44 24 08 3a 28 80 	movl   $0x80283a,0x8(%esp)
  8004f2:	00 
  8004f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 5d fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800502:	e9 a2 fe ff ff       	jmp    8003a9 <vprintfmt+0x25>
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80050d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800510:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800513:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800519:	85 ff                	test   %edi,%edi
  80051b:	b8 57 24 80 00       	mov    $0x802457,%eax
  800520:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800523:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800527:	0f 84 92 00 00 00    	je     8005bf <vprintfmt+0x23b>
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	0f 8e 98 00 00 00    	jle    8005cd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	89 3c 24             	mov    %edi,(%esp)
  80053c:	e8 47 03 00 00       	call   800888 <strnlen>
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	29 c1                	sub    %eax,%ecx
  800546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800549:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800550:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800553:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	eb 0f                	jmp    800566 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	85 ff                	test   %edi,%edi
  800568:	7f ed                	jg     800557 <vprintfmt+0x1d3>
  80056a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800570:	85 c9                	test   %ecx,%ecx
  800572:	b8 00 00 00 00       	mov    $0x0,%eax
  800577:	0f 49 c1             	cmovns %ecx,%eax
  80057a:	29 c1                	sub    %eax,%ecx
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	89 cb                	mov    %ecx,%ebx
  800587:	eb 50                	jmp    8005d9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058d:	74 1e                	je     8005ad <vprintfmt+0x229>
  80058f:	0f be d2             	movsbl %dl,%edx
  800592:	83 ea 20             	sub    $0x20,%edx
  800595:	83 fa 5e             	cmp    $0x5e,%edx
  800598:	76 13                	jbe    8005ad <vprintfmt+0x229>
					putch('?', putdat);
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a8:	ff 55 08             	call   *0x8(%ebp)
  8005ab:	eb 0d                	jmp    8005ba <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8005ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	83 eb 01             	sub    $0x1,%ebx
  8005bd:	eb 1a                	jmp    8005d9 <vprintfmt+0x255>
  8005bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cb:	eb 0c                	jmp    8005d9 <vprintfmt+0x255>
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d9:	83 c7 01             	add    $0x1,%edi
  8005dc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005e0:	0f be c2             	movsbl %dl,%eax
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	74 25                	je     80060c <vprintfmt+0x288>
  8005e7:	85 f6                	test   %esi,%esi
  8005e9:	78 9e                	js     800589 <vprintfmt+0x205>
  8005eb:	83 ee 01             	sub    $0x1,%esi
  8005ee:	79 99                	jns    800589 <vprintfmt+0x205>
  8005f0:	89 df                	mov    %ebx,%edi
  8005f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f8:	eb 1a                	jmp    800614 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800605:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800607:	83 ef 01             	sub    $0x1,%edi
  80060a:	eb 08                	jmp    800614 <vprintfmt+0x290>
  80060c:	89 df                	mov    %ebx,%edi
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800614:	85 ff                	test   %edi,%edi
  800616:	7f e2                	jg     8005fa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 89 fd ff ff       	jmp    8003a9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 19                	jle    80063e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 50 04             	mov    0x4(%eax),%edx
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 40 08             	lea    0x8(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
  80063c:	eb 38                	jmp    800676 <vprintfmt+0x2f2>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 1b                	je     80065d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 c1                	mov    %eax,%ecx
  80064c:	c1 f9 1f             	sar    $0x1f,%ecx
  80064f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
  80065b:	eb 19                	jmp    800676 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c1                	mov    %eax,%ecx
  800667:	c1 f9 1f             	sar    $0x1f,%ecx
  80066a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	0f 89 04 01 00 00    	jns    80078f <vprintfmt+0x40b>
				putch('-', putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069e:	f7 da                	neg    %edx
  8006a0:	83 d1 00             	adc    $0x0,%ecx
  8006a3:	f7 d9                	neg    %ecx
  8006a5:	e9 e5 00 00 00       	jmp    80078f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006aa:	83 f9 01             	cmp    $0x1,%ecx
  8006ad:	7e 10                	jle    8006bf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bd:	eb 26                	jmp    8006e5 <vprintfmt+0x361>
	else if (lflag)
  8006bf:	85 c9                	test   %ecx,%ecx
  8006c1:	74 12                	je     8006d5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cd:	8d 40 04             	lea    0x4(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d3:	eb 10                	jmp    8006e5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8006ea:	e9 a0 00 00 00       	jmp    80078f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006fa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800714:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800719:	e9 8b fc ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80071e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800722:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800729:	ff d6                	call   *%esi
			putch('x', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800736:	ff d6                	call   *%esi
			num = (unsigned long long)
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800748:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80074d:	eb 40                	jmp    80078f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074f:	83 f9 01             	cmp    $0x1,%ecx
  800752:	7e 10                	jle    800764 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	8b 48 04             	mov    0x4(%eax),%ecx
  80075c:	8d 40 08             	lea    0x8(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
  800762:	eb 26                	jmp    80078a <vprintfmt+0x406>
	else if (lflag)
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 12                	je     80077a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
  800778:	eb 10                	jmp    80078a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800784:	8d 40 04             	lea    0x4(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80078a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800793:	89 44 24 10          	mov    %eax,0x10(%esp)
  800797:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8007a2:	89 14 24             	mov    %edx,(%esp)
  8007a5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a9:	89 da                	mov    %ebx,%edx
  8007ab:	89 f0                	mov    %esi,%eax
  8007ad:	e8 9e fa ff ff       	call   800250 <printnum>
			break;
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 ef fb ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c6:	e9 de fb ff ff       	jmp    8003a9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	eb 03                	jmp    8007dd <vprintfmt+0x459>
  8007da:	83 ef 01             	sub    $0x1,%edi
  8007dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e1:	75 f7                	jne    8007da <vprintfmt+0x456>
  8007e3:	e9 c1 fb ff ff       	jmp    8003a9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007e8:	83 c4 3c             	add    $0x3c,%esp
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5f                   	pop    %edi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 28             	sub    $0x28,%esp
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800803:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800806:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 30                	je     800841 <vsnprintf+0x51>
  800811:	85 d2                	test   %edx,%edx
  800813:	7e 2c                	jle    800841 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
  80081f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082a:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  800831:	e8 4e fb ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800836:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800839:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083f:	eb 05                	jmp    800846 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800841:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800851:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800855:	8b 45 10             	mov    0x10(%ebp),%eax
  800858:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 82 ff ff ff       	call   8007f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 03                	jmp    800880 <strlen+0x10>
		n++;
  80087d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800884:	75 f7                	jne    80087d <strlen+0xd>
		n++;
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb 03                	jmp    80089b <strnlen+0x13>
		n++;
  800898:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	74 06                	je     8008a5 <strnlen+0x1d>
  80089f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a3:	75 f3                	jne    800898 <strnlen+0x10>
		n++;
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	83 c2 01             	add    $0x1,%edx
  8008b6:	83 c1 01             	add    $0x1,%ecx
  8008b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	75 ef                	jne    8008b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d1:	89 1c 24             	mov    %ebx,(%esp)
  8008d4:	e8 97 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e0:	01 d8                	add    %ebx,%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 bd ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008ea:	89 d8                	mov    %ebx,%eax
  8008ec:	83 c4 08             	add    $0x8,%esp
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	89 f3                	mov    %esi,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800902:	89 f2                	mov    %esi,%edx
  800904:	eb 0f                	jmp    800915 <strncpy+0x23>
		*dst++ = *src;
  800906:	83 c2 01             	add    $0x1,%edx
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090f:	80 39 01             	cmpb   $0x1,(%ecx)
  800912:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800915:	39 da                	cmp    %ebx,%edx
  800917:	75 ed                	jne    800906 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800919:	89 f0                	mov    %esi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	85 c9                	test   %ecx,%ecx
  800935:	75 0b                	jne    800942 <strlcpy+0x23>
  800937:	eb 1d                	jmp    800956 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 0b                	je     800951 <strlcpy+0x32>
  800946:	0f b6 0a             	movzbl (%edx),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	75 ec                	jne    800939 <strlcpy+0x1a>
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	eb 02                	jmp    800953 <strlcpy+0x34>
  800951:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800953:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800956:	29 f0                	sub    %esi,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800965:	eb 06                	jmp    80096d <strcmp+0x11>
		p++, q++;
  800967:	83 c1 01             	add    $0x1,%ecx
  80096a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	84 c0                	test   %al,%al
  800972:	74 04                	je     800978 <strcmp+0x1c>
  800974:	3a 02                	cmp    (%edx),%al
  800976:	74 ef                	je     800967 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 c0             	movzbl %al,%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800991:	eb 06                	jmp    800999 <strncmp+0x17>
		n--, p++, q++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	39 d8                	cmp    %ebx,%eax
  80099b:	74 15                	je     8009b2 <strncmp+0x30>
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	74 04                	je     8009a8 <strncmp+0x26>
  8009a4:	3a 0a                	cmp    (%edx),%cl
  8009a6:	74 eb                	je     800993 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
  8009b0:	eb 05                	jmp    8009b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 07                	jmp    8009cd <strchr+0x13>
		if (*s == c)
  8009c6:	38 ca                	cmp    %cl,%dl
  8009c8:	74 0f                	je     8009d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f2                	jne    8009c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	eb 07                	jmp    8009ee <strfind+0x13>
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	74 0a                	je     8009f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	75 f2                	jne    8009e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	74 36                	je     800a3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0d:	75 28                	jne    800a37 <memset+0x40>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 23                	jne    800a37 <memset+0x40>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 18             	shl    $0x18,%esi
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 10             	shl    $0x10,%eax
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a32:	fc                   	cld    
  800a33:	f3 ab                	rep stos %eax,%es:(%edi)
  800a35:	eb 06                	jmp    800a3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a52:	39 c6                	cmp    %eax,%esi
  800a54:	73 35                	jae    800a8b <memmove+0x47>
  800a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 2e                	jae    800a8b <memmove+0x47>
		s += n;
		d += n;
  800a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 13                	jne    800a7f <memmove+0x3b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0e                	jne    800a7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 09                	jmp    800a88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7f:	83 ef 01             	sub    $0x1,%edi
  800a82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a85:	fd                   	std    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a88:	fc                   	cld    
  800a89:	eb 1d                	jmp    800aa8 <memmove+0x64>
  800a8b:	89 f2                	mov    %esi,%edx
  800a8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 0f                	jne    800aa3 <memmove+0x5f>
  800a94:	f6 c1 03             	test   $0x3,%cl
  800a97:	75 0a                	jne    800aa3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a99:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 05                	jmp    800aa8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 79 ff ff ff       	call   800a44 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 02             	movzbl (%edx),%eax
  800ae2:	0f b6 19             	movzbl (%ecx),%ebx
  800ae5:	38 d8                	cmp    %bl,%al
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f2                	cmp    %esi,%edx
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b14:	eb 07                	jmp    800b1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	38 08                	cmp    %cl,(%eax)
  800b18:	74 07                	je     800b21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	39 d0                	cmp    %edx,%eax
  800b1f:	72 f5                	jb     800b16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	eb 03                	jmp    800b34 <strtol+0x11>
		s++;
  800b31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	0f b6 0a             	movzbl (%edx),%ecx
  800b37:	80 f9 09             	cmp    $0x9,%cl
  800b3a:	74 f5                	je     800b31 <strtol+0xe>
  800b3c:	80 f9 20             	cmp    $0x20,%cl
  800b3f:	74 f0                	je     800b31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b41:	80 f9 2b             	cmp    $0x2b,%cl
  800b44:	75 0a                	jne    800b50 <strtol+0x2d>
		s++;
  800b46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4e:	eb 11                	jmp    800b61 <strtol+0x3e>
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b55:	80 f9 2d             	cmp    $0x2d,%cl
  800b58:	75 07                	jne    800b61 <strtol+0x3e>
		s++, neg = 1;
  800b5a:	8d 52 01             	lea    0x1(%edx),%edx
  800b5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b66:	75 15                	jne    800b7d <strtol+0x5a>
  800b68:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6b:	75 10                	jne    800b7d <strtol+0x5a>
  800b6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b71:	75 0a                	jne    800b7d <strtol+0x5a>
		s += 2, base = 16;
  800b73:	83 c2 02             	add    $0x2,%edx
  800b76:	b8 10 00 00 00       	mov    $0x10,%eax
  800b7b:	eb 10                	jmp    800b8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 0c                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b83:	80 3a 30             	cmpb   $0x30,(%edx)
  800b86:	75 05                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
  800b88:	83 c2 01             	add    $0x1,%edx
  800b8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b95:	0f b6 0a             	movzbl (%edx),%ecx
  800b98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b9b:	89 f0                	mov    %esi,%eax
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	77 08                	ja     800ba9 <strtol+0x86>
			dig = *s - '0';
  800ba1:	0f be c9             	movsbl %cl,%ecx
  800ba4:	83 e9 30             	sub    $0x30,%ecx
  800ba7:	eb 20                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	3c 19                	cmp    $0x19,%al
  800bb0:	77 08                	ja     800bba <strtol+0x97>
			dig = *s - 'a' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 57             	sub    $0x57,%ecx
  800bb8:	eb 0f                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	3c 19                	cmp    $0x19,%al
  800bc1:	77 16                	ja     800bd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bc3:	0f be c9             	movsbl %cl,%ecx
  800bc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bcc:	7d 0f                	jge    800bdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bce:	83 c2 01             	add    $0x1,%edx
  800bd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bd7:	eb bc                	jmp    800b95 <strtol+0x72>
  800bd9:	89 d8                	mov    %ebx,%eax
  800bdb:	eb 02                	jmp    800bdf <strtol+0xbc>
  800bdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be3:	74 05                	je     800bea <strtol+0xc7>
		*endptr = (char *) s;
  800be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bea:	f7 d8                	neg    %eax
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 44 c3             	cmove  %ebx,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	b8 03 00 00 00       	mov    $0x3,%eax
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 cb                	mov    %ecx,%ebx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	89 ce                	mov    %ecx,%esi
  800c4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 28                	jle    800c7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c60:	00 
  800c61:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800c68:	00 
  800c69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c70:	00 
  800c71:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800c78:	e8 c9 12 00 00       	call   801f46 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	83 c4 2c             	add    $0x2c,%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800d0a:	e8 37 12 00 00       	call   801f46 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b8 05 00 00 00       	mov    $0x5,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 75 18             	mov    0x18(%ebp),%esi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 28                	jle    800d62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d45:	00 
  800d46:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d55:	00 
  800d56:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800d5d:	e8 e4 11 00 00       	call   801f46 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d62:	83 c4 2c             	add    $0x2c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800db0:	e8 91 11 00 00       	call   801f46 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 28                	jle    800e08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800deb:	00 
  800dec:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800df3:	00 
  800df4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfb:	00 
  800dfc:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e03:	e8 3e 11 00 00       	call   801f46 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e08:	83 c4 2c             	add    $0x2c,%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 de                	mov    %ebx,%esi
  800e2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800e56:	e8 eb 10 00 00       	call   801f46 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5b:	83 c4 2c             	add    $0x2c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 df                	mov    %ebx,%edi
  800e7e:	89 de                	mov    %ebx,%esi
  800e80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 28                	jle    800eae <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800ea9:	e8 98 10 00 00       	call   801f46 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eae:	83 c4 2c             	add    $0x2c,%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	be 00 00 00 00       	mov    $0x0,%esi
  800ec1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	89 cb                	mov    %ecx,%ebx
  800ef1:	89 cf                	mov    %ecx,%edi
  800ef3:	89 ce                	mov    %ecx,%esi
  800ef5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 28                	jle    800f23 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eff:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 3f 27 80 	movl   $0x80273f,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  800f1e:	e8 23 10 00 00       	call   801f46 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f23:	83 c4 2c             	add    $0x2c,%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	53                   	push   %ebx
  800f2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800f38:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  800f3a:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f42:	83 39 01             	cmpl   $0x1,(%ecx)
  800f45:	7e 0f                	jle    800f56 <argstart+0x2b>
  800f47:	85 d2                	test   %edx,%edx
  800f49:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4e:	bb 11 24 80 00       	mov    $0x802411,%ebx
  800f53:	0f 44 da             	cmove  %edx,%ebx
  800f56:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  800f59:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800f60:	5b                   	pop    %ebx
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <argnext>:

int
argnext(struct Argstate *args)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	83 ec 14             	sub    $0x14,%esp
  800f6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800f6d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800f74:	8b 43 08             	mov    0x8(%ebx),%eax
  800f77:	85 c0                	test   %eax,%eax
  800f79:	74 71                	je     800fec <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  800f7b:	80 38 00             	cmpb   $0x0,(%eax)
  800f7e:	75 50                	jne    800fd0 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800f80:	8b 0b                	mov    (%ebx),%ecx
  800f82:	83 39 01             	cmpl   $0x1,(%ecx)
  800f85:	74 57                	je     800fde <argnext+0x7b>
		    || args->argv[1][0] != '-'
  800f87:	8b 53 04             	mov    0x4(%ebx),%edx
  800f8a:	8b 42 04             	mov    0x4(%edx),%eax
  800f8d:	80 38 2d             	cmpb   $0x2d,(%eax)
  800f90:	75 4c                	jne    800fde <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  800f92:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800f96:	74 46                	je     800fde <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800f98:	83 c0 01             	add    $0x1,%eax
  800f9b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f9e:	8b 01                	mov    (%ecx),%eax
  800fa0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fab:	8d 42 08             	lea    0x8(%edx),%eax
  800fae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb2:	83 c2 04             	add    $0x4,%edx
  800fb5:	89 14 24             	mov    %edx,(%esp)
  800fb8:	e8 87 fa ff ff       	call   800a44 <memmove>
		(*args->argc)--;
  800fbd:	8b 03                	mov    (%ebx),%eax
  800fbf:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800fc2:	8b 43 08             	mov    0x8(%ebx),%eax
  800fc5:	80 38 2d             	cmpb   $0x2d,(%eax)
  800fc8:	75 06                	jne    800fd0 <argnext+0x6d>
  800fca:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800fce:	74 0e                	je     800fde <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800fd0:	8b 53 08             	mov    0x8(%ebx),%edx
  800fd3:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800fd6:	83 c2 01             	add    $0x1,%edx
  800fd9:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800fdc:	eb 13                	jmp    800ff1 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  800fde:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fea:	eb 05                	jmp    800ff1 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ff1:	83 c4 14             	add    $0x14,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 14             	sub    $0x14,%esp
  800ffe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801001:	8b 43 08             	mov    0x8(%ebx),%eax
  801004:	85 c0                	test   %eax,%eax
  801006:	74 5a                	je     801062 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801008:	80 38 00             	cmpb   $0x0,(%eax)
  80100b:	74 0c                	je     801019 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80100d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801010:	c7 43 08 11 24 80 00 	movl   $0x802411,0x8(%ebx)
  801017:	eb 44                	jmp    80105d <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801019:	8b 03                	mov    (%ebx),%eax
  80101b:	83 38 01             	cmpl   $0x1,(%eax)
  80101e:	7e 2f                	jle    80104f <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801020:	8b 53 04             	mov    0x4(%ebx),%edx
  801023:	8b 4a 04             	mov    0x4(%edx),%ecx
  801026:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801029:	8b 00                	mov    (%eax),%eax
  80102b:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801032:	89 44 24 08          	mov    %eax,0x8(%esp)
  801036:	8d 42 08             	lea    0x8(%edx),%eax
  801039:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103d:	83 c2 04             	add    $0x4,%edx
  801040:	89 14 24             	mov    %edx,(%esp)
  801043:	e8 fc f9 ff ff       	call   800a44 <memmove>
		(*args->argc)--;
  801048:	8b 03                	mov    (%ebx),%eax
  80104a:	83 28 01             	subl   $0x1,(%eax)
  80104d:	eb 0e                	jmp    80105d <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  80104f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801056:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80105d:	8b 43 0c             	mov    0xc(%ebx),%eax
  801060:	eb 05                	jmp    801067 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801067:	83 c4 14             	add    $0x14,%esp
  80106a:	5b                   	pop    %ebx
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 18             	sub    $0x18,%esp
  801073:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801076:	8b 51 0c             	mov    0xc(%ecx),%edx
  801079:	89 d0                	mov    %edx,%eax
  80107b:	85 d2                	test   %edx,%edx
  80107d:	75 08                	jne    801087 <argvalue+0x1a>
  80107f:	89 0c 24             	mov    %ecx,(%esp)
  801082:	e8 70 ff ff ff       	call   800ff7 <argnextvalue>
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    
  801089:	66 90                	xchg   %ax,%ax
  80108b:	66 90                	xchg   %ax,%ax
  80108d:	66 90                	xchg   %ax,%ax
  80108f:	90                   	nop

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	c1 ea 16             	shr    $0x16,%edx
  8010c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ce:	f6 c2 01             	test   $0x1,%dl
  8010d1:	74 11                	je     8010e4 <fd_alloc+0x2d>
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	75 09                	jne    8010ed <fd_alloc+0x36>
			*fd_store = fd;
  8010e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	eb 17                	jmp    801104 <fd_alloc+0x4d>
  8010ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f7:	75 c9                	jne    8010c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110c:	83 f8 1f             	cmp    $0x1f,%eax
  80110f:	77 36                	ja     801147 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801111:	c1 e0 0c             	shl    $0xc,%eax
  801114:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 16             	shr    $0x16,%edx
  80111e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 24                	je     80114e <fd_lookup+0x48>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 0c             	shr    $0xc,%edx
  80112f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 1a                	je     801155 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 02                	mov    %eax,(%edx)
	return 0;
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 13                	jmp    80115a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 0c                	jmp    80115a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801153:	eb 05                	jmp    80115a <fd_lookup+0x54>
  801155:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 18             	sub    $0x18,%esp
  801162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801165:	ba e8 27 80 00       	mov    $0x8027e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80116a:	eb 13                	jmp    80117f <dev_lookup+0x23>
  80116c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80116f:	39 08                	cmp    %ecx,(%eax)
  801171:	75 0c                	jne    80117f <dev_lookup+0x23>
			*dev = devtab[i];
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	89 01                	mov    %eax,(%ecx)
			return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
  80117d:	eb 30                	jmp    8011af <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117f:	8b 02                	mov    (%edx),%eax
  801181:	85 c0                	test   %eax,%eax
  801183:	75 e7                	jne    80116c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801185:	a1 04 40 80 00       	mov    0x804004,%eax
  80118a:	8b 40 48             	mov    0x48(%eax),%eax
  80118d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801191:	89 44 24 04          	mov    %eax,0x4(%esp)
  801195:	c7 04 24 6c 27 80 00 	movl   $0x80276c,(%esp)
  80119c:	e8 90 f0 ff ff       	call   800231 <cprintf>
	*dev = 0;
  8011a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 20             	sub    $0x20,%esp
  8011b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011cc:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 2f ff ff ff       	call   801106 <fd_lookup>
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 05                	js     8011e0 <fd_close+0x2f>
	    || fd != fd2)
  8011db:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011de:	74 0c                	je     8011ec <fd_close+0x3b>
		return (must_exist ? r : 0);
  8011e0:	84 db                	test   %bl,%bl
  8011e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e7:	0f 44 c2             	cmove  %edx,%eax
  8011ea:	eb 3f                	jmp    80122b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f3:	8b 06                	mov    (%esi),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 5f ff ff ff       	call   80115c <dev_lookup>
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 16                	js     801219 <fd_close+0x68>
		if (dev->dev_close)
  801203:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801206:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801209:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80120e:	85 c0                	test   %eax,%eax
  801210:	74 07                	je     801219 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801212:	89 34 24             	mov    %esi,(%esp)
  801215:	ff d0                	call   *%eax
  801217:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801224:	e8 41 fb ff ff       	call   800d6a <sys_page_unmap>
	return r;
  801229:	89 d8                	mov    %ebx,%eax
}
  80122b:	83 c4 20             	add    $0x20,%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5e                   	pop    %esi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 bc fe ff ff       	call   801106 <fd_lookup>
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	85 d2                	test   %edx,%edx
  80124e:	78 13                	js     801263 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801250:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801257:	00 
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 4e ff ff ff       	call   8011b1 <fd_close>
}
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <close_all>:

void
close_all(void)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801271:	89 1c 24             	mov    %ebx,(%esp)
  801274:	e8 b9 ff ff ff       	call   801232 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801279:	83 c3 01             	add    $0x1,%ebx
  80127c:	83 fb 20             	cmp    $0x20,%ebx
  80127f:	75 f0                	jne    801271 <close_all+0xc>
		close(i);
}
  801281:	83 c4 14             	add    $0x14,%esp
  801284:	5b                   	pop    %ebx
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801290:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	e8 64 fe ff ff       	call   801106 <fd_lookup>
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	85 d2                	test   %edx,%edx
  8012a6:	0f 88 e1 00 00 00    	js     80138d <dup+0x106>
		return r;
	close(newfdnum);
  8012ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012af:	89 04 24             	mov    %eax,(%esp)
  8012b2:	e8 7b ff ff ff       	call   801232 <close>

	newfd = INDEX2FD(newfdnum);
  8012b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ba:	c1 e3 0c             	shl    $0xc,%ebx
  8012bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 d2 fd ff ff       	call   8010a0 <fd2data>
  8012ce:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8012d0:	89 1c 24             	mov    %ebx,(%esp)
  8012d3:	e8 c8 fd ff ff       	call   8010a0 <fd2data>
  8012d8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012da:	89 f0                	mov    %esi,%eax
  8012dc:	c1 e8 16             	shr    $0x16,%eax
  8012df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e6:	a8 01                	test   $0x1,%al
  8012e8:	74 43                	je     80132d <dup+0xa6>
  8012ea:	89 f0                	mov    %esi,%eax
  8012ec:	c1 e8 0c             	shr    $0xc,%eax
  8012ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 32                	je     80132d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801302:	25 07 0e 00 00       	and    $0xe07,%eax
  801307:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80130f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801316:	00 
  801317:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801322:	e8 f0 f9 ff ff       	call   800d17 <sys_page_map>
  801327:	89 c6                	mov    %eax,%esi
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 3e                	js     80136b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801330:	89 c2                	mov    %eax,%edx
  801332:	c1 ea 0c             	shr    $0xc,%edx
  801335:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801342:	89 54 24 10          	mov    %edx,0x10(%esp)
  801346:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80134a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801351:	00 
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135d:	e8 b5 f9 ff ff       	call   800d17 <sys_page_map>
  801362:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801367:	85 f6                	test   %esi,%esi
  801369:	79 22                	jns    80138d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80136f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801376:	e8 ef f9 ff ff       	call   800d6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80137f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801386:	e8 df f9 ff ff       	call   800d6a <sys_page_unmap>
	return r;
  80138b:	89 f0                	mov    %esi,%eax
}
  80138d:	83 c4 3c             	add    $0x3c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 24             	sub    $0x24,%esp
  80139c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	89 1c 24             	mov    %ebx,(%esp)
  8013a9:	e8 58 fd ff ff       	call   801106 <fd_lookup>
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	78 6d                	js     801421 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	8b 00                	mov    (%eax),%eax
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 94 fd ff ff       	call   80115c <dev_lookup>
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 55                	js     801421 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 50 08             	mov    0x8(%eax),%edx
  8013d2:	83 e2 03             	and    $0x3,%edx
  8013d5:	83 fa 01             	cmp    $0x1,%edx
  8013d8:	75 23                	jne    8013fd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013da:	a1 04 40 80 00       	mov    0x804004,%eax
  8013df:	8b 40 48             	mov    0x48(%eax),%eax
  8013e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ea:	c7 04 24 ad 27 80 00 	movl   $0x8027ad,(%esp)
  8013f1:	e8 3b ee ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8013f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fb:	eb 24                	jmp    801421 <read+0x8c>
	}
	if (!dev->dev_read)
  8013fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801400:	8b 52 08             	mov    0x8(%edx),%edx
  801403:	85 d2                	test   %edx,%edx
  801405:	74 15                	je     80141c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801407:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80140a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801411:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801415:	89 04 24             	mov    %eax,(%esp)
  801418:	ff d2                	call   *%edx
  80141a:	eb 05                	jmp    801421 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80141c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801421:	83 c4 24             	add    $0x24,%esp
  801424:	5b                   	pop    %ebx
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 1c             	sub    $0x1c,%esp
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
  801433:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143b:	eb 23                	jmp    801460 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143d:	89 f0                	mov    %esi,%eax
  80143f:	29 d8                	sub    %ebx,%eax
  801441:	89 44 24 08          	mov    %eax,0x8(%esp)
  801445:	89 d8                	mov    %ebx,%eax
  801447:	03 45 0c             	add    0xc(%ebp),%eax
  80144a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144e:	89 3c 24             	mov    %edi,(%esp)
  801451:	e8 3f ff ff ff       	call   801395 <read>
		if (m < 0)
  801456:	85 c0                	test   %eax,%eax
  801458:	78 10                	js     80146a <readn+0x43>
			return m;
		if (m == 0)
  80145a:	85 c0                	test   %eax,%eax
  80145c:	74 0a                	je     801468 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145e:	01 c3                	add    %eax,%ebx
  801460:	39 f3                	cmp    %esi,%ebx
  801462:	72 d9                	jb     80143d <readn+0x16>
  801464:	89 d8                	mov    %ebx,%eax
  801466:	eb 02                	jmp    80146a <readn+0x43>
  801468:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80146a:	83 c4 1c             	add    $0x1c,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	53                   	push   %ebx
  801476:	83 ec 24             	sub    $0x24,%esp
  801479:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801483:	89 1c 24             	mov    %ebx,(%esp)
  801486:	e8 7b fc ff ff       	call   801106 <fd_lookup>
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	85 d2                	test   %edx,%edx
  80148f:	78 68                	js     8014f9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	8b 00                	mov    (%eax),%eax
  80149d:	89 04 24             	mov    %eax,(%esp)
  8014a0:	e8 b7 fc ff ff       	call   80115c <dev_lookup>
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 50                	js     8014f9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b0:	75 23                	jne    8014d5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c2:	c7 04 24 c9 27 80 00 	movl   $0x8027c9,(%esp)
  8014c9:	e8 63 ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb 24                	jmp    8014f9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014db:	85 d2                	test   %edx,%edx
  8014dd:	74 15                	je     8014f4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ed:	89 04 24             	mov    %eax,(%esp)
  8014f0:	ff d2                	call   *%edx
  8014f2:	eb 05                	jmp    8014f9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014f9:	83 c4 24             	add    $0x24,%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    

008014ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801505:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 ef fb ff ff       	call   801106 <fd_lookup>
  801517:	85 c0                	test   %eax,%eax
  801519:	78 0e                	js     801529 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80151b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80151e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801521:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 24             	sub    $0x24,%esp
  801532:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801535:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153c:	89 1c 24             	mov    %ebx,(%esp)
  80153f:	e8 c2 fb ff ff       	call   801106 <fd_lookup>
  801544:	89 c2                	mov    %eax,%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	78 61                	js     8015ab <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	8b 00                	mov    (%eax),%eax
  801556:	89 04 24             	mov    %eax,(%esp)
  801559:	e8 fe fb ff ff       	call   80115c <dev_lookup>
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 49                	js     8015ab <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801569:	75 23                	jne    80158e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801577:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157b:	c7 04 24 8c 27 80 00 	movl   $0x80278c,(%esp)
  801582:	e8 aa ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801587:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158c:	eb 1d                	jmp    8015ab <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80158e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801591:	8b 52 18             	mov    0x18(%edx),%edx
  801594:	85 d2                	test   %edx,%edx
  801596:	74 0e                	je     8015a6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801598:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	ff d2                	call   *%edx
  8015a4:	eb 05                	jmp    8015ab <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ab:	83 c4 24             	add    $0x24,%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 24             	sub    $0x24,%esp
  8015b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 39 fb ff ff       	call   801106 <fd_lookup>
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	78 52                	js     801625 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	8b 00                	mov    (%eax),%eax
  8015df:	89 04 24             	mov    %eax,(%esp)
  8015e2:	e8 75 fb ff ff       	call   80115c <dev_lookup>
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 3a                	js     801625 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f2:	74 2c                	je     801620 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015fe:	00 00 00 
	stat->st_isdir = 0;
  801601:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801608:	00 00 00 
	stat->st_dev = dev;
  80160b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801615:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801618:	89 14 24             	mov    %edx,(%esp)
  80161b:	ff 50 14             	call   *0x14(%eax)
  80161e:	eb 05                	jmp    801625 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801620:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801625:	83 c4 24             	add    $0x24,%esp
  801628:	5b                   	pop    %ebx
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801633:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80163a:	00 
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	89 04 24             	mov    %eax,(%esp)
  801641:	e8 fb 01 00 00       	call   801841 <open>
  801646:	89 c3                	mov    %eax,%ebx
  801648:	85 db                	test   %ebx,%ebx
  80164a:	78 1b                	js     801667 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80164c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 56 ff ff ff       	call   8015b1 <fstat>
  80165b:	89 c6                	mov    %eax,%esi
	close(fd);
  80165d:	89 1c 24             	mov    %ebx,(%esp)
  801660:	e8 cd fb ff ff       	call   801232 <close>
	return r;
  801665:	89 f0                	mov    %esi,%eax
}
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	5b                   	pop    %ebx
  80166b:	5e                   	pop    %esi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 10             	sub    $0x10,%esp
  801676:	89 c6                	mov    %eax,%esi
  801678:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801681:	75 11                	jne    801694 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801683:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80168a:	e8 5e 0a 00 00       	call   8020ed <ipc_find_env>
  80168f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801694:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80169b:	00 
  80169c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016a3:	00 
  8016a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8016ad:	89 04 24             	mov    %eax,(%esp)
  8016b0:	e8 89 09 00 00       	call   80203e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016bc:	00 
  8016bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c8:	e8 d3 08 00 00       	call   801fa0 <ipc_recv>
}
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5e                   	pop    %esi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8016f7:	e8 72 ff ff ff       	call   80166e <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	8b 40 0c             	mov    0xc(%eax),%eax
  80170a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 06 00 00 00       	mov    $0x6,%eax
  801719:	e8 50 ff ff ff       	call   80166e <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
  80172d:	8b 40 0c             	mov    0xc(%eax),%eax
  801730:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801735:	ba 00 00 00 00       	mov    $0x0,%edx
  80173a:	b8 05 00 00 00       	mov    $0x5,%eax
  80173f:	e8 2a ff ff ff       	call   80166e <fsipc>
  801744:	89 c2                	mov    %eax,%edx
  801746:	85 d2                	test   %edx,%edx
  801748:	78 2b                	js     801775 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80174a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801751:	00 
  801752:	89 1c 24             	mov    %ebx,(%esp)
  801755:	e8 4d f1 ff ff       	call   8008a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80175a:	a1 80 50 80 00       	mov    0x805080,%eax
  80175f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801765:	a1 84 50 80 00       	mov    0x805084,%eax
  80176a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801770:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801775:	83 c4 14             	add    $0x14,%esp
  801778:	5b                   	pop    %ebx
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801781:	c7 44 24 08 f8 27 80 	movl   $0x8027f8,0x8(%esp)
  801788:	00 
  801789:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801790:	00 
  801791:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  801798:	e8 a9 07 00 00       	call   801f46 <_panic>

0080179d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 10             	sub    $0x10,%esp
  8017a5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017be:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c3:	e8 a6 fe ff ff       	call   80166e <fsipc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 6a                	js     801838 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8017ce:	39 c6                	cmp    %eax,%esi
  8017d0:	73 24                	jae    8017f6 <devfile_read+0x59>
  8017d2:	c7 44 24 0c 21 28 80 	movl   $0x802821,0xc(%esp)
  8017d9:	00 
  8017da:	c7 44 24 08 28 28 80 	movl   $0x802828,0x8(%esp)
  8017e1:	00 
  8017e2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017e9:	00 
  8017ea:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  8017f1:	e8 50 07 00 00       	call   801f46 <_panic>
	assert(r <= PGSIZE);
  8017f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fb:	7e 24                	jle    801821 <devfile_read+0x84>
  8017fd:	c7 44 24 0c 3d 28 80 	movl   $0x80283d,0xc(%esp)
  801804:	00 
  801805:	c7 44 24 08 28 28 80 	movl   $0x802828,0x8(%esp)
  80180c:	00 
  80180d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801814:	00 
  801815:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  80181c:	e8 25 07 00 00       	call   801f46 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801821:	89 44 24 08          	mov    %eax,0x8(%esp)
  801825:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80182c:	00 
  80182d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801830:	89 04 24             	mov    %eax,(%esp)
  801833:	e8 0c f2 ff ff       	call   800a44 <memmove>
	return r;
}
  801838:	89 d8                	mov    %ebx,%eax
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	53                   	push   %ebx
  801845:	83 ec 24             	sub    $0x24,%esp
  801848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80184b:	89 1c 24             	mov    %ebx,(%esp)
  80184e:	e8 1d f0 ff ff       	call   800870 <strlen>
  801853:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801858:	7f 60                	jg     8018ba <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	89 04 24             	mov    %eax,(%esp)
  801860:	e8 52 f8 ff ff       	call   8010b7 <fd_alloc>
  801865:	89 c2                	mov    %eax,%edx
  801867:	85 d2                	test   %edx,%edx
  801869:	78 54                	js     8018bf <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80186b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80186f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801876:	e8 2c f0 ff ff       	call   8008a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80187b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801883:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801886:	b8 01 00 00 00       	mov    $0x1,%eax
  80188b:	e8 de fd ff ff       	call   80166e <fsipc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	85 c0                	test   %eax,%eax
  801894:	79 17                	jns    8018ad <open+0x6c>
		fd_close(fd, 0);
  801896:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80189d:	00 
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 08 f9 ff ff       	call   8011b1 <fd_close>
		return r;
  8018a9:	89 d8                	mov    %ebx,%eax
  8018ab:	eb 12                	jmp    8018bf <open+0x7e>
	}

	return fd2num(fd);
  8018ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b0:	89 04 24             	mov    %eax,(%esp)
  8018b3:	e8 d8 f7 ff ff       	call   801090 <fd2num>
  8018b8:	eb 05                	jmp    8018bf <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ba:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018bf:	83 c4 24             	add    $0x24,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d5:	e8 94 fd ff ff       	call   80166e <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 14             	sub    $0x14,%esp
  8018e3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8018e5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018e9:	7e 31                	jle    80191c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018eb:	8b 40 04             	mov    0x4(%eax),%eax
  8018ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f2:	8d 43 10             	lea    0x10(%ebx),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 03                	mov    (%ebx),%eax
  8018fb:	89 04 24             	mov    %eax,(%esp)
  8018fe:	e8 6f fb ff ff       	call   801472 <write>
		if (result > 0)
  801903:	85 c0                	test   %eax,%eax
  801905:	7e 03                	jle    80190a <writebuf+0x2e>
			b->result += result;
  801907:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80190a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80190d:	74 0d                	je     80191c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  80190f:	85 c0                	test   %eax,%eax
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	0f 4f c2             	cmovg  %edx,%eax
  801919:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80191c:	83 c4 14             	add    $0x14,%esp
  80191f:	5b                   	pop    %ebx
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <putch>:

static void
putch(int ch, void *thunk)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	83 ec 04             	sub    $0x4,%esp
  801929:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80192c:	8b 53 04             	mov    0x4(%ebx),%edx
  80192f:	8d 42 01             	lea    0x1(%edx),%eax
  801932:	89 43 04             	mov    %eax,0x4(%ebx)
  801935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801938:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80193c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801941:	75 0e                	jne    801951 <putch+0x2f>
		writebuf(b);
  801943:	89 d8                	mov    %ebx,%eax
  801945:	e8 92 ff ff ff       	call   8018dc <writebuf>
		b->idx = 0;
  80194a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801951:	83 c4 04             	add    $0x4,%esp
  801954:	5b                   	pop    %ebx
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801969:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801970:	00 00 00 
	b.result = 0;
  801973:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80197a:	00 00 00 
	b.error = 1;
  80197d:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801984:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801987:	8b 45 10             	mov    0x10(%ebp),%eax
  80198a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80198e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801991:	89 44 24 08          	mov    %eax,0x8(%esp)
  801995:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	c7 04 24 22 19 80 00 	movl   $0x801922,(%esp)
  8019a6:	e8 d9 e9 ff ff       	call   800384 <vprintfmt>
	if (b.idx > 0)
  8019ab:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019b2:	7e 0b                	jle    8019bf <vfprintf+0x68>
		writebuf(&b);
  8019b4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ba:	e8 1d ff ff ff       	call   8018dc <writebuf>

	return (b.result ? b.result : b.error);
  8019bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019d6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 68 ff ff ff       	call   801957 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <printf>:

int
printf(const char *fmt, ...)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a0c:	e8 46 ff ff ff       	call   801957 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 10             	sub    $0x10,%esp
  801a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 77 f6 ff ff       	call   8010a0 <fd2data>
  801a29:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a2b:	c7 44 24 04 49 28 80 	movl   $0x802849,0x4(%esp)
  801a32:	00 
  801a33:	89 1c 24             	mov    %ebx,(%esp)
  801a36:	e8 6c ee ff ff       	call   8008a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3b:	8b 46 04             	mov    0x4(%esi),%eax
  801a3e:	2b 06                	sub    (%esi),%eax
  801a40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a4d:	00 00 00 
	stat->st_dev = &devpipe;
  801a50:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a57:	30 80 00 
	return 0;
}
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 14             	sub    $0x14,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7b:	e8 ea f2 ff ff       	call   800d6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 18 f6 ff ff       	call   8010a0 <fd2data>
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a93:	e8 d2 f2 ff ff       	call   800d6a <sys_page_unmap>
}
  801a98:	83 c4 14             	add    $0x14,%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    

00801a9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 2c             	sub    $0x2c,%esp
  801aa7:	89 c6                	mov    %eax,%esi
  801aa9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ab4:	89 34 24             	mov    %esi,(%esp)
  801ab7:	e8 69 06 00 00       	call   802125 <pageref>
  801abc:	89 c7                	mov    %eax,%edi
  801abe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac1:	89 04 24             	mov    %eax,(%esp)
  801ac4:	e8 5c 06 00 00       	call   802125 <pageref>
  801ac9:	39 c7                	cmp    %eax,%edi
  801acb:	0f 94 c2             	sete   %dl
  801ace:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801ad1:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801ad7:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801ada:	39 fb                	cmp    %edi,%ebx
  801adc:	74 21                	je     801aff <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ade:	84 d2                	test   %dl,%dl
  801ae0:	74 ca                	je     801aac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae2:	8b 51 58             	mov    0x58(%ecx),%edx
  801ae5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ae9:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af1:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  801af8:	e8 34 e7 ff ff       	call   800231 <cprintf>
  801afd:	eb ad                	jmp    801aac <_pipeisclosed+0xe>
	}
}
  801aff:	83 c4 2c             	add    $0x2c,%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 1c             	sub    $0x1c,%esp
  801b10:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b13:	89 34 24             	mov    %esi,(%esp)
  801b16:	e8 85 f5 ff ff       	call   8010a0 <fd2data>
  801b1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1d:	bf 00 00 00 00       	mov    $0x0,%edi
  801b22:	eb 45                	jmp    801b69 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b24:	89 da                	mov    %ebx,%edx
  801b26:	89 f0                	mov    %esi,%eax
  801b28:	e8 71 ff ff ff       	call   801a9e <_pipeisclosed>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	75 41                	jne    801b72 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b31:	e8 6e f1 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b36:	8b 43 04             	mov    0x4(%ebx),%eax
  801b39:	8b 0b                	mov    (%ebx),%ecx
  801b3b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3e:	39 d0                	cmp    %edx,%eax
  801b40:	73 e2                	jae    801b24 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b45:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b49:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b4c:	99                   	cltd   
  801b4d:	c1 ea 1b             	shr    $0x1b,%edx
  801b50:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801b53:	83 e1 1f             	and    $0x1f,%ecx
  801b56:	29 d1                	sub    %edx,%ecx
  801b58:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801b5c:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801b60:	83 c0 01             	add    $0x1,%eax
  801b63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b66:	83 c7 01             	add    $0x1,%edi
  801b69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6c:	75 c8                	jne    801b36 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6e:	89 f8                	mov    %edi,%eax
  801b70:	eb 05                	jmp    801b77 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b77:	83 c4 1c             	add    $0x1c,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5f                   	pop    %edi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 1c             	sub    $0x1c,%esp
  801b88:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8b:	89 3c 24             	mov    %edi,(%esp)
  801b8e:	e8 0d f5 ff ff       	call   8010a0 <fd2data>
  801b93:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b95:	be 00 00 00 00       	mov    $0x0,%esi
  801b9a:	eb 3d                	jmp    801bd9 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9c:	85 f6                	test   %esi,%esi
  801b9e:	74 04                	je     801ba4 <devpipe_read+0x25>
				return i;
  801ba0:	89 f0                	mov    %esi,%eax
  801ba2:	eb 43                	jmp    801be7 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba4:	89 da                	mov    %ebx,%edx
  801ba6:	89 f8                	mov    %edi,%eax
  801ba8:	e8 f1 fe ff ff       	call   801a9e <_pipeisclosed>
  801bad:	85 c0                	test   %eax,%eax
  801baf:	75 31                	jne    801be2 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb1:	e8 ee f0 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb6:	8b 03                	mov    (%ebx),%eax
  801bb8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bbb:	74 df                	je     801b9c <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bbd:	99                   	cltd   
  801bbe:	c1 ea 1b             	shr    $0x1b,%edx
  801bc1:	01 d0                	add    %edx,%eax
  801bc3:	83 e0 1f             	and    $0x1f,%eax
  801bc6:	29 d0                	sub    %edx,%eax
  801bc8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bd3:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd6:	83 c6 01             	add    $0x1,%esi
  801bd9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bdc:	75 d8                	jne    801bb6 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bde:	89 f0                	mov    %esi,%eax
  801be0:	eb 05                	jmp    801be7 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be7:	83 c4 1c             	add    $0x1c,%esp
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfa:	89 04 24             	mov    %eax,(%esp)
  801bfd:	e8 b5 f4 ff ff       	call   8010b7 <fd_alloc>
  801c02:	89 c2                	mov    %eax,%edx
  801c04:	85 d2                	test   %edx,%edx
  801c06:	0f 88 4d 01 00 00    	js     801d59 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c13:	00 
  801c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c22:	e8 9c f0 ff ff       	call   800cc3 <sys_page_alloc>
  801c27:	89 c2                	mov    %eax,%edx
  801c29:	85 d2                	test   %edx,%edx
  801c2b:	0f 88 28 01 00 00    	js     801d59 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 7b f4 ff ff       	call   8010b7 <fd_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 fe 00 00 00    	js     801d44 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c4d:	00 
  801c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5c:	e8 62 f0 ff ff       	call   800cc3 <sys_page_alloc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 d9 00 00 00    	js     801d44 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 2a f4 ff ff       	call   8010a0 <fd2data>
  801c76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c78:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c7f:	00 
  801c80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8b:	e8 33 f0 ff ff       	call   800cc3 <sys_page_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	85 c0                	test   %eax,%eax
  801c94:	0f 88 97 00 00 00    	js     801d31 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9d:	89 04 24             	mov    %eax,(%esp)
  801ca0:	e8 fb f3 ff ff       	call   8010a0 <fd2data>
  801ca5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801cac:	00 
  801cad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cb8:	00 
  801cb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc4:	e8 4e f0 ff ff       	call   800d17 <sys_page_map>
  801cc9:	89 c3                	mov    %eax,%ebx
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 52                	js     801d21 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ced:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 8c f3 ff ff       	call   801090 <fd2num>
  801d04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d07:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0c:	89 04 24             	mov    %eax,(%esp)
  801d0f:	e8 7c f3 ff ff       	call   801090 <fd2num>
  801d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d17:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1f:	eb 38                	jmp    801d59 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801d21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d2c:	e8 39 f0 ff ff       	call   800d6a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d3f:	e8 26 f0 ff ff       	call   800d6a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d52:	e8 13 f0 ff ff       	call   800d6a <sys_page_unmap>
  801d57:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801d59:	83 c4 30             	add    $0x30,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	89 04 24             	mov    %eax,(%esp)
  801d73:	e8 8e f3 ff ff       	call   801106 <fd_lookup>
  801d78:	89 c2                	mov    %eax,%edx
  801d7a:	85 d2                	test   %edx,%edx
  801d7c:	78 15                	js     801d93 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	89 04 24             	mov    %eax,(%esp)
  801d84:	e8 17 f3 ff ff       	call   8010a0 <fd2data>
	return _pipeisclosed(fd, p);
  801d89:	89 c2                	mov    %eax,%edx
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	e8 0b fd ff ff       	call   801a9e <_pipeisclosed>
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    
  801d95:	66 90                	xchg   %ax,%ax
  801d97:	66 90                	xchg   %ax,%ax
  801d99:	66 90                	xchg   %ax,%ax
  801d9b:	66 90                	xchg   %ax,%ax
  801d9d:	66 90                	xchg   %ax,%ax
  801d9f:	90                   	nop

00801da0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801db0:	c7 44 24 04 68 28 80 	movl   $0x802868,0x4(%esp)
  801db7:	00 
  801db8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbb:	89 04 24             	mov    %eax,(%esp)
  801dbe:	e8 e4 ea ff ff       	call   8008a7 <strcpy>
	return 0;
}
  801dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de1:	eb 31                	jmp    801e14 <devcons_write+0x4a>
		m = n - tot;
  801de3:	8b 75 10             	mov    0x10(%ebp),%esi
  801de6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801de8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801deb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801df7:	03 45 0c             	add    0xc(%ebp),%eax
  801dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfe:	89 3c 24             	mov    %edi,(%esp)
  801e01:	e8 3e ec ff ff       	call   800a44 <memmove>
		sys_cputs(buf, m);
  801e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0a:	89 3c 24             	mov    %edi,(%esp)
  801e0d:	e8 e4 ed ff ff       	call   800bf6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e12:	01 f3                	add    %esi,%ebx
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e19:	72 c8                	jb     801de3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e1b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5f                   	pop    %edi
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    

00801e26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e35:	75 07                	jne    801e3e <devcons_read+0x18>
  801e37:	eb 2a                	jmp    801e63 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e39:	e8 66 ee ff ff       	call   800ca4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e3e:	66 90                	xchg   %ax,%ax
  801e40:	e8 cf ed ff ff       	call   800c14 <sys_cgetc>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	74 f0                	je     801e39 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 16                	js     801e63 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4d:	83 f8 04             	cmp    $0x4,%eax
  801e50:	74 0c                	je     801e5e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e55:	88 02                	mov    %al,(%edx)
	return 1;
  801e57:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5c:	eb 05                	jmp    801e63 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e78:	00 
  801e79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 72 ed ff ff       	call   800bf6 <sys_cputs>
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <getchar>:

int
getchar(void)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e8c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801e93:	00 
  801e94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea2:	e8 ee f4 ff ff       	call   801395 <read>
	if (r < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 0f                	js     801eba <getchar+0x34>
		return r;
	if (r < 1)
  801eab:	85 c0                	test   %eax,%eax
  801ead:	7e 06                	jle    801eb5 <getchar+0x2f>
		return -E_EOF;
	return c;
  801eaf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb3:	eb 05                	jmp    801eba <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

00801ebc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	89 04 24             	mov    %eax,(%esp)
  801ecf:	e8 32 f2 ff ff       	call   801106 <fd_lookup>
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 11                	js     801ee9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee1:	39 10                	cmp    %edx,(%eax)
  801ee3:	0f 94 c0             	sete   %al
  801ee6:	0f b6 c0             	movzbl %al,%eax
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <opencons>:

int
opencons(void)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef4:	89 04 24             	mov    %eax,(%esp)
  801ef7:	e8 bb f1 ff ff       	call   8010b7 <fd_alloc>
		return r;
  801efc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 40                	js     801f42 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f09:	00 
  801f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f18:	e8 a6 ed ff ff       	call   800cc3 <sys_page_alloc>
		return r;
  801f1d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 1f                	js     801f42 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f38:	89 04 24             	mov    %eax,(%esp)
  801f3b:	e8 50 f1 ff ff       	call   801090 <fd2num>
  801f40:	89 c2                	mov    %eax,%edx
}
  801f42:	89 d0                	mov    %edx,%eax
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	56                   	push   %esi
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801f4e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f51:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f57:	e8 29 ed ff ff       	call   800c85 <sys_getenvid>
  801f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f63:	8b 55 08             	mov    0x8(%ebp),%edx
  801f66:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f6a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f72:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  801f79:	e8 b3 e2 ff ff       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f82:	8b 45 10             	mov    0x10(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 43 e2 ff ff       	call   8001d0 <vcprintf>
	cprintf("\n");
  801f8d:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801f94:	e8 98 e2 ff ff       	call   800231 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f99:	cc                   	int3   
  801f9a:	eb fd                	jmp    801f99 <_panic+0x53>
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	83 ec 10             	sub    $0x10,%esp
  801fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  801fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	75 0e                	jne    801fc3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801fb5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801fbc:	e8 18 ef ff ff       	call   800ed9 <sys_ipc_recv>
  801fc1:	eb 08                	jmp    801fcb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801fc3:	89 04 24             	mov    %eax,(%esp)
  801fc6:	e8 0e ef ff ff       	call   800ed9 <sys_ipc_recv>
	if(r == 0){
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
  801fd0:	75 1e                	jne    801ff0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801fd2:	85 f6                	test   %esi,%esi
  801fd4:	74 0a                	je     801fe0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801fd6:	a1 04 40 80 00       	mov    0x804004,%eax
  801fdb:	8b 40 74             	mov    0x74(%eax),%eax
  801fde:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	74 2c                	je     802010 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801fe4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe9:	8b 40 78             	mov    0x78(%eax),%eax
  801fec:	89 03                	mov    %eax,(%ebx)
  801fee:	eb 20                	jmp    802010 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801ff0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff4:	c7 44 24 08 98 28 80 	movl   $0x802898,0x8(%esp)
  801ffb:	00 
  801ffc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802003:	00 
  802004:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  80200b:	e8 36 ff ff ff       	call   801f46 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802010:	a1 04 40 80 00       	mov    0x804004,%eax
  802015:	8b 50 70             	mov    0x70(%eax),%edx
  802018:	85 d2                	test   %edx,%edx
  80201a:	75 13                	jne    80202f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80201c:	8b 40 48             	mov    0x48(%eax),%eax
  80201f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802023:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  80202a:	e8 02 e2 ff ff       	call   800231 <cprintf>
	return thisenv->env_ipc_value;
  80202f:	a1 04 40 80 00       	mov    0x804004,%eax
  802034:	8b 40 70             	mov    0x70(%eax),%eax
}
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	5b                   	pop    %ebx
  80203b:	5e                   	pop    %esi
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80204d:	85 f6                	test   %esi,%esi
  80204f:	75 22                	jne    802073 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802051:	8b 45 14             	mov    0x14(%ebp),%eax
  802054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802058:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80205f:	ee 
  802060:	8b 45 0c             	mov    0xc(%ebp),%eax
  802063:	89 44 24 04          	mov    %eax,0x4(%esp)
  802067:	89 3c 24             	mov    %edi,(%esp)
  80206a:	e8 47 ee ff ff       	call   800eb6 <sys_ipc_try_send>
  80206f:	89 c3                	mov    %eax,%ebx
  802071:	eb 1c                	jmp    80208f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802073:	8b 45 14             	mov    0x14(%ebp),%eax
  802076:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80207e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802081:	89 44 24 04          	mov    %eax,0x4(%esp)
  802085:	89 3c 24             	mov    %edi,(%esp)
  802088:	e8 29 ee ff ff       	call   800eb6 <sys_ipc_try_send>
  80208d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80208f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802092:	74 3e                	je     8020d2 <ipc_send+0x94>
  802094:	89 d8                	mov    %ebx,%eax
  802096:	c1 e8 1f             	shr    $0x1f,%eax
  802099:	84 c0                	test   %al,%al
  80209b:	74 35                	je     8020d2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80209d:	e8 e3 eb ff ff       	call   800c85 <sys_getenvid>
  8020a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a6:	c7 04 24 1e 29 80 00 	movl   $0x80291e,(%esp)
  8020ad:	e8 7f e1 ff ff       	call   800231 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8020b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020b6:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  8020bd:	00 
  8020be:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8020c5:	00 
  8020c6:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8020cd:	e8 74 fe ff ff       	call   801f46 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8020d2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8020d5:	75 0e                	jne    8020e5 <ipc_send+0xa7>
			sys_yield();
  8020d7:	e8 c8 eb ff ff       	call   800ca4 <sys_yield>
		else break;
	}
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	e9 68 ff ff ff       	jmp    80204d <ipc_send+0xf>
	
}
  8020e5:	83 c4 1c             	add    $0x1c,%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802101:	8b 52 50             	mov    0x50(%edx),%edx
  802104:	39 ca                	cmp    %ecx,%edx
  802106:	75 0d                	jne    802115 <ipc_find_env+0x28>
			return envs[i].env_id;
  802108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802110:	8b 40 40             	mov    0x40(%eax),%eax
  802113:	eb 0e                	jmp    802123 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211d:	75 d9                	jne    8020f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211f:	66 b8 00 00          	mov    $0x0,%ax
}
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	c1 e8 16             	shr    $0x16,%eax
  802130:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213c:	f6 c1 01             	test   $0x1,%cl
  80213f:	74 1d                	je     80215e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802141:	c1 ea 0c             	shr    $0xc,%edx
  802144:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214b:	f6 c2 01             	test   $0x1,%dl
  80214e:	74 0e                	je     80215e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802150:	c1 ea 0c             	shr    $0xc,%edx
  802153:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215a:	ef 
  80215b:	0f b7 c0             	movzwl %ax,%eax
}
  80215e:	5d                   	pop    %ebp
  80215f:	c3                   	ret    

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	8b 44 24 28          	mov    0x28(%esp),%eax
  80216a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80216e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802172:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802176:	85 c0                	test   %eax,%eax
  802178:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80217c:	89 ea                	mov    %ebp,%edx
  80217e:	89 0c 24             	mov    %ecx,(%esp)
  802181:	75 2d                	jne    8021b0 <__udivdi3+0x50>
  802183:	39 e9                	cmp    %ebp,%ecx
  802185:	77 61                	ja     8021e8 <__udivdi3+0x88>
  802187:	85 c9                	test   %ecx,%ecx
  802189:	89 ce                	mov    %ecx,%esi
  80218b:	75 0b                	jne    802198 <__udivdi3+0x38>
  80218d:	b8 01 00 00 00       	mov    $0x1,%eax
  802192:	31 d2                	xor    %edx,%edx
  802194:	f7 f1                	div    %ecx
  802196:	89 c6                	mov    %eax,%esi
  802198:	31 d2                	xor    %edx,%edx
  80219a:	89 e8                	mov    %ebp,%eax
  80219c:	f7 f6                	div    %esi
  80219e:	89 c5                	mov    %eax,%ebp
  8021a0:	89 f8                	mov    %edi,%eax
  8021a2:	f7 f6                	div    %esi
  8021a4:	89 ea                	mov    %ebp,%edx
  8021a6:	83 c4 0c             	add    $0xc,%esp
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	39 e8                	cmp    %ebp,%eax
  8021b2:	77 24                	ja     8021d8 <__udivdi3+0x78>
  8021b4:	0f bd e8             	bsr    %eax,%ebp
  8021b7:	83 f5 1f             	xor    $0x1f,%ebp
  8021ba:	75 3c                	jne    8021f8 <__udivdi3+0x98>
  8021bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021c0:	39 34 24             	cmp    %esi,(%esp)
  8021c3:	0f 86 9f 00 00 00    	jbe    802268 <__udivdi3+0x108>
  8021c9:	39 d0                	cmp    %edx,%eax
  8021cb:	0f 82 97 00 00 00    	jb     802268 <__udivdi3+0x108>
  8021d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	31 c0                	xor    %eax,%eax
  8021dc:	83 c4 0c             	add    $0xc,%esp
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	89 f8                	mov    %edi,%eax
  8021ea:	f7 f1                	div    %ecx
  8021ec:	31 d2                	xor    %edx,%edx
  8021ee:	83 c4 0c             	add    $0xc,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 e9                	mov    %ebp,%ecx
  8021fa:	8b 3c 24             	mov    (%esp),%edi
  8021fd:	d3 e0                	shl    %cl,%eax
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	b8 20 00 00 00       	mov    $0x20,%eax
  802206:	29 e8                	sub    %ebp,%eax
  802208:	89 c1                	mov    %eax,%ecx
  80220a:	d3 ef                	shr    %cl,%edi
  80220c:	89 e9                	mov    %ebp,%ecx
  80220e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802212:	8b 3c 24             	mov    (%esp),%edi
  802215:	09 74 24 08          	or     %esi,0x8(%esp)
  802219:	89 d6                	mov    %edx,%esi
  80221b:	d3 e7                	shl    %cl,%edi
  80221d:	89 c1                	mov    %eax,%ecx
  80221f:	89 3c 24             	mov    %edi,(%esp)
  802222:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802226:	d3 ee                	shr    %cl,%esi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	d3 e2                	shl    %cl,%edx
  80222c:	89 c1                	mov    %eax,%ecx
  80222e:	d3 ef                	shr    %cl,%edi
  802230:	09 d7                	or     %edx,%edi
  802232:	89 f2                	mov    %esi,%edx
  802234:	89 f8                	mov    %edi,%eax
  802236:	f7 74 24 08          	divl   0x8(%esp)
  80223a:	89 d6                	mov    %edx,%esi
  80223c:	89 c7                	mov    %eax,%edi
  80223e:	f7 24 24             	mull   (%esp)
  802241:	39 d6                	cmp    %edx,%esi
  802243:	89 14 24             	mov    %edx,(%esp)
  802246:	72 30                	jb     802278 <__udivdi3+0x118>
  802248:	8b 54 24 04          	mov    0x4(%esp),%edx
  80224c:	89 e9                	mov    %ebp,%ecx
  80224e:	d3 e2                	shl    %cl,%edx
  802250:	39 c2                	cmp    %eax,%edx
  802252:	73 05                	jae    802259 <__udivdi3+0xf9>
  802254:	3b 34 24             	cmp    (%esp),%esi
  802257:	74 1f                	je     802278 <__udivdi3+0x118>
  802259:	89 f8                	mov    %edi,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	e9 7a ff ff ff       	jmp    8021dc <__udivdi3+0x7c>
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	31 d2                	xor    %edx,%edx
  80226a:	b8 01 00 00 00       	mov    $0x1,%eax
  80226f:	e9 68 ff ff ff       	jmp    8021dc <__udivdi3+0x7c>
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	8d 47 ff             	lea    -0x1(%edi),%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	83 c4 0c             	add    $0xc,%esp
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 14             	sub    $0x14,%esp
  802296:	8b 44 24 28          	mov    0x28(%esp),%eax
  80229a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80229e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8022a2:	89 c7                	mov    %eax,%edi
  8022a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8022ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8022b0:	89 34 24             	mov    %esi,(%esp)
  8022b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	89 c2                	mov    %eax,%edx
  8022bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022bf:	75 17                	jne    8022d8 <__umoddi3+0x48>
  8022c1:	39 fe                	cmp    %edi,%esi
  8022c3:	76 4b                	jbe    802310 <__umoddi3+0x80>
  8022c5:	89 c8                	mov    %ecx,%eax
  8022c7:	89 fa                	mov    %edi,%edx
  8022c9:	f7 f6                	div    %esi
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	83 c4 14             	add    $0x14,%esp
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	39 f8                	cmp    %edi,%eax
  8022da:	77 54                	ja     802330 <__umoddi3+0xa0>
  8022dc:	0f bd e8             	bsr    %eax,%ebp
  8022df:	83 f5 1f             	xor    $0x1f,%ebp
  8022e2:	75 5c                	jne    802340 <__umoddi3+0xb0>
  8022e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8022e8:	39 3c 24             	cmp    %edi,(%esp)
  8022eb:	0f 87 e7 00 00 00    	ja     8023d8 <__umoddi3+0x148>
  8022f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022f5:	29 f1                	sub    %esi,%ecx
  8022f7:	19 c7                	sbb    %eax,%edi
  8022f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802301:	8b 44 24 08          	mov    0x8(%esp),%eax
  802305:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802309:	83 c4 14             	add    $0x14,%esp
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    
  802310:	85 f6                	test   %esi,%esi
  802312:	89 f5                	mov    %esi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f6                	div    %esi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	8b 44 24 04          	mov    0x4(%esp),%eax
  802325:	31 d2                	xor    %edx,%edx
  802327:	f7 f5                	div    %ebp
  802329:	89 c8                	mov    %ecx,%eax
  80232b:	f7 f5                	div    %ebp
  80232d:	eb 9c                	jmp    8022cb <__umoddi3+0x3b>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 fa                	mov    %edi,%edx
  802334:	83 c4 14             	add    $0x14,%esp
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 04 24             	mov    (%esp),%eax
  802343:	be 20 00 00 00       	mov    $0x20,%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ee                	sub    %ebp,%esi
  80234c:	d3 e2                	shl    %cl,%edx
  80234e:	89 f1                	mov    %esi,%ecx
  802350:	d3 e8                	shr    %cl,%eax
  802352:	89 e9                	mov    %ebp,%ecx
  802354:	89 44 24 04          	mov    %eax,0x4(%esp)
  802358:	8b 04 24             	mov    (%esp),%eax
  80235b:	09 54 24 04          	or     %edx,0x4(%esp)
  80235f:	89 fa                	mov    %edi,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 f1                	mov    %esi,%ecx
  802365:	89 44 24 08          	mov    %eax,0x8(%esp)
  802369:	8b 44 24 10          	mov    0x10(%esp),%eax
  80236d:	d3 ea                	shr    %cl,%edx
  80236f:	89 e9                	mov    %ebp,%ecx
  802371:	d3 e7                	shl    %cl,%edi
  802373:	89 f1                	mov    %esi,%ecx
  802375:	d3 e8                	shr    %cl,%eax
  802377:	89 e9                	mov    %ebp,%ecx
  802379:	09 f8                	or     %edi,%eax
  80237b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80237f:	f7 74 24 04          	divl   0x4(%esp)
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802389:	89 d7                	mov    %edx,%edi
  80238b:	f7 64 24 08          	mull   0x8(%esp)
  80238f:	39 d7                	cmp    %edx,%edi
  802391:	89 c1                	mov    %eax,%ecx
  802393:	89 14 24             	mov    %edx,(%esp)
  802396:	72 2c                	jb     8023c4 <__umoddi3+0x134>
  802398:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80239c:	72 22                	jb     8023c0 <__umoddi3+0x130>
  80239e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023a2:	29 c8                	sub    %ecx,%eax
  8023a4:	19 d7                	sbb    %edx,%edi
  8023a6:	89 e9                	mov    %ebp,%ecx
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	d3 e8                	shr    %cl,%eax
  8023ac:	89 f1                	mov    %esi,%ecx
  8023ae:	d3 e2                	shl    %cl,%edx
  8023b0:	89 e9                	mov    %ebp,%ecx
  8023b2:	d3 ef                	shr    %cl,%edi
  8023b4:	09 d0                	or     %edx,%eax
  8023b6:	89 fa                	mov    %edi,%edx
  8023b8:	83 c4 14             	add    $0x14,%esp
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
  8023bf:	90                   	nop
  8023c0:	39 d7                	cmp    %edx,%edi
  8023c2:	75 da                	jne    80239e <__umoddi3+0x10e>
  8023c4:	8b 14 24             	mov    (%esp),%edx
  8023c7:	89 c1                	mov    %eax,%ecx
  8023c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8023cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8023d1:	eb cb                	jmp    80239e <__umoddi3+0x10e>
  8023d3:	90                   	nop
  8023d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8023dc:	0f 82 0f ff ff ff    	jb     8022f1 <__umoddi3+0x61>
  8023e2:	e9 1a ff ff ff       	jmp    802301 <__umoddi3+0x71>
