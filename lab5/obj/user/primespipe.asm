
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 8c 02 00 00       	call   8002bd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004c:	00 
  80004d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800051:	89 1c 24             	mov    %ebx,(%esp)
  800054:	e8 ee 17 00 00       	call   801847 <readn>
  800059:	83 f8 04             	cmp    $0x4,%eax
  80005c:	74 2e                	je     80008c <primeproc+0x59>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005e:	85 c0                	test   %eax,%eax
  800060:	ba 00 00 00 00       	mov    $0x0,%edx
  800065:	0f 4e d0             	cmovle %eax,%edx
  800068:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800070:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  800087:	e8 8d 02 00 00       	call   800319 <_panic>

	cprintf("%d\n", p);
  80008c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80008f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800093:	c7 04 24 a1 27 80 00 	movl   $0x8027a1,(%esp)
  80009a:	e8 73 03 00 00       	call   800412 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80009f:	89 3c 24             	mov    %edi,(%esp)
  8000a2:	e8 31 1e 00 00       	call   801ed8 <pipe>
  8000a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <primeproc+0x9b>
		panic("pipe: %e", i);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 a5 27 80 	movl   $0x8027a5,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  8000c9:	e8 4b 02 00 00       	call   800319 <_panic>
	if ((id = fork()) < 0)
  8000ce:	e8 a2 11 00 00       	call   801275 <fork>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	79 20                	jns    8000f7 <primeproc+0xc4>
		panic("fork: %e", id);
  8000d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000db:	c7 44 24 08 ae 27 80 	movl   $0x8027ae,0x8(%esp)
  8000e2:	00 
  8000e3:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  8000f2:	e8 22 02 00 00       	call   800319 <_panic>
	if (id == 0) {
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	75 1b                	jne    800116 <primeproc+0xe3>
		close(fd);
  8000fb:	89 1c 24             	mov    %ebx,(%esp)
  8000fe:	e8 4f 15 00 00       	call   801652 <close>
		close(pfd[1]);
  800103:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 44 15 00 00       	call   801652 <close>
		fd = pfd[0];
  80010e:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800111:	e9 2f ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  800116:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800119:	89 04 24             	mov    %eax,(%esp)
  80011c:	e8 31 15 00 00       	call   801652 <close>
	wfd = pfd[1];
  800121:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800124:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800127:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80012e:	00 
  80012f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800133:	89 1c 24             	mov    %ebx,(%esp)
  800136:	e8 0c 17 00 00       	call   801847 <readn>
  80013b:	83 f8 04             	cmp    $0x4,%eax
  80013e:	74 39                	je     800179 <primeproc+0x146>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800140:	85 c0                	test   %eax,%eax
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	0f 4e d0             	cmovle %eax,%edx
  80014a:	89 54 24 18          	mov    %edx,0x18(%esp)
  80014e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800152:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800156:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015d:	c7 44 24 08 b7 27 80 	movl   $0x8027b7,0x8(%esp)
  800164:	00 
  800165:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80016c:	00 
  80016d:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  800174:	e8 a0 01 00 00       	call   800319 <_panic>
		if (i%p)
  800179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80017c:	99                   	cltd   
  80017d:	f7 7d e0             	idivl  -0x20(%ebp)
  800180:	85 d2                	test   %edx,%edx
  800182:	74 a3                	je     800127 <primeproc+0xf4>
			if ((r=write(wfd, &i, 4)) != 4)
  800184:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80018b:	00 
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	89 3c 24             	mov    %edi,(%esp)
  800193:	e8 fa 16 00 00       	call   801892 <write>
  800198:	83 f8 04             	cmp    $0x4,%eax
  80019b:	74 8a                	je     800127 <primeproc+0xf4>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80019d:	85 c0                	test   %eax,%eax
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	0f 4e d0             	cmovle %eax,%edx
  8001a7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 d3 27 80 	movl   $0x8027d3,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  8001cd:	e8 47 01 00 00       	call   800319 <_panic>

008001d2 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001d9:	c7 05 00 30 80 00 ed 	movl   $0x8027ed,0x803000
  8001e0:	27 80 00 

	if ((i=pipe(p)) < 0)
  8001e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001e6:	89 04 24             	mov    %eax,(%esp)
  8001e9:	e8 ea 1c 00 00       	call   801ed8 <pipe>
  8001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	79 20                	jns    800215 <umain+0x43>
		panic("pipe: %e", i);
  8001f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f9:	c7 44 24 08 a5 27 80 	movl   $0x8027a5,0x8(%esp)
  800200:	00 
  800201:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800208:	00 
  800209:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  800210:	e8 04 01 00 00       	call   800319 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800215:	e8 5b 10 00 00       	call   801275 <fork>
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 20                	jns    80023e <umain+0x6c>
		panic("fork: %e", id);
  80021e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800222:	c7 44 24 08 ae 27 80 	movl   $0x8027ae,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800231:	00 
  800232:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  800239:	e8 db 00 00 00       	call   800319 <_panic>

	if (id == 0) {
  80023e:	85 c0                	test   %eax,%eax
  800240:	75 16                	jne    800258 <umain+0x86>
		close(p[1]);
  800242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 05 14 00 00       	call   801652 <close>
		primeproc(p[0]);
  80024d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 db fd ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  800258:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 ef 13 00 00       	call   801652 <close>

	// feed all the integers through
	for (i=2;; i++)
  800263:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  80026a:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  80026d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800274:	00 
  800275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 0e 16 00 00       	call   801892 <write>
  800284:	83 f8 04             	cmp    $0x4,%eax
  800287:	74 2e                	je     8002b7 <umain+0xe5>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800289:	85 c0                	test   %eax,%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	0f 4e d0             	cmovle %eax,%edx
  800293:	89 54 24 10          	mov    %edx,0x10(%esp)
  800297:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029b:	c7 44 24 08 f8 27 80 	movl   $0x8027f8,0x8(%esp)
  8002a2:	00 
  8002a3:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002aa:	00 
  8002ab:	c7 04 24 8f 27 80 00 	movl   $0x80278f,(%esp)
  8002b2:	e8 62 00 00 00       	call   800319 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002bb:	eb b0                	jmp    80026d <umain+0x9b>

008002bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 10             	sub    $0x10,%esp
  8002c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8002cb:	e8 95 0b 00 00       	call   800e65 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002dd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e2:	85 db                	test   %ebx,%ebx
  8002e4:	7e 07                	jle    8002ed <libmain+0x30>
		binaryname = argv[0];
  8002e6:	8b 06                	mov    (%esi),%eax
  8002e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f1:	89 1c 24             	mov    %ebx,(%esp)
  8002f4:	e8 d9 fe ff ff       	call   8001d2 <umain>

	// exit gracefully
	exit();
  8002f9:	e8 07 00 00 00       	call   800305 <exit>
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80030b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800312:	e8 fc 0a 00 00       	call   800e13 <sys_env_destroy>
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800324:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80032a:	e8 36 0b 00 00       	call   800e65 <sys_getenvid>
  80032f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800332:	89 54 24 10          	mov    %edx,0x10(%esp)
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800341:	89 44 24 04          	mov    %eax,0x4(%esp)
  800345:	c7 04 24 1c 28 80 00 	movl   $0x80281c,(%esp)
  80034c:	e8 c1 00 00 00       	call   800412 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	8b 45 10             	mov    0x10(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	e8 51 00 00 00       	call   8003b1 <vcprintf>
	cprintf("\n");
  800360:	c7 04 24 a3 27 80 00 	movl   $0x8027a3,(%esp)
  800367:	e8 a6 00 00 00       	call   800412 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036c:	cc                   	int3   
  80036d:	eb fd                	jmp    80036c <_panic+0x53>

0080036f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	53                   	push   %ebx
  800373:	83 ec 14             	sub    $0x14,%esp
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800379:	8b 13                	mov    (%ebx),%edx
  80037b:	8d 42 01             	lea    0x1(%edx),%eax
  80037e:	89 03                	mov    %eax,(%ebx)
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800387:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038c:	75 19                	jne    8003a7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80038e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800395:	00 
  800396:	8d 43 08             	lea    0x8(%ebx),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 35 0a 00 00       	call   800dd6 <sys_cputs>
		b->idx = 0;
  8003a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ab:	83 c4 14             	add    $0x14,%esp
  8003ae:	5b                   	pop    %ebx
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c1:	00 00 00 
	b.cnt = 0;
  8003c4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e6:	c7 04 24 6f 03 80 00 	movl   $0x80036f,(%esp)
  8003ed:	e8 72 01 00 00       	call   800564 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	e8 cc 09 00 00       	call   800dd6 <sys_cputs>

	return b.cnt;
}
  80040a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800418:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	e8 87 ff ff ff       	call   8003b1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    
  80042c:	66 90                	xchg   %ax,%ax
  80042e:	66 90                	xchg   %ax,%ax

00800430 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 3c             	sub    $0x3c,%esp
  800439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043c:	89 d7                	mov    %edx,%edi
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 c3                	mov    %eax,%ebx
  800449:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80044c:	8b 45 10             	mov    0x10(%ebp),%eax
  80044f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800452:	b9 00 00 00 00       	mov    $0x0,%ecx
  800457:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045d:	39 d9                	cmp    %ebx,%ecx
  80045f:	72 05                	jb     800466 <printnum+0x36>
  800461:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800464:	77 69                	ja     8004cf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800466:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800469:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80046d:	83 ee 01             	sub    $0x1,%esi
  800470:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800474:	89 44 24 08          	mov    %eax,0x8(%esp)
  800478:	8b 44 24 08          	mov    0x8(%esp),%eax
  80047c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800480:	89 c3                	mov    %eax,%ebx
  800482:	89 d6                	mov    %edx,%esi
  800484:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800487:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80048a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80048e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 04 24             	mov    %eax,(%esp)
  800498:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	e8 1c 20 00 00       	call   8024c0 <__udivdi3>
  8004a4:	89 d9                	mov    %ebx,%ecx
  8004a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b5:	89 fa                	mov    %edi,%edx
  8004b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ba:	e8 71 ff ff ff       	call   800430 <printnum>
  8004bf:	eb 1b                	jmp    8004dc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff d3                	call   *%ebx
  8004cd:	eb 03                	jmp    8004d2 <printnum+0xa2>
  8004cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d2:	83 ee 01             	sub    $0x1,%esi
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	7f e8                	jg     8004c1 <printnum+0x91>
  8004d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 ec 20 00 00       	call   8025f0 <__umoddi3>
  800504:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800508:	0f be 80 3f 28 80 00 	movsbl 0x80283f(%eax),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800515:	ff d0                	call   *%eax
}
  800517:	83 c4 3c             	add    $0x3c,%esp
  80051a:	5b                   	pop    %ebx
  80051b:	5e                   	pop    %esi
  80051c:	5f                   	pop    %edi
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800525:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800529:	8b 10                	mov    (%eax),%edx
  80052b:	3b 50 04             	cmp    0x4(%eax),%edx
  80052e:	73 0a                	jae    80053a <sprintputch+0x1b>
		*b->buf++ = ch;
  800530:	8d 4a 01             	lea    0x1(%edx),%ecx
  800533:	89 08                	mov    %ecx,(%eax)
  800535:	8b 45 08             	mov    0x8(%ebp),%eax
  800538:	88 02                	mov    %al,(%edx)
}
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800542:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800549:	8b 45 10             	mov    0x10(%ebp),%eax
  80054c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800550:	8b 45 0c             	mov    0xc(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
  800557:	8b 45 08             	mov    0x8(%ebp),%eax
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	e8 02 00 00 00       	call   800564 <vprintfmt>
	va_end(ap);
}
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	57                   	push   %edi
  800568:	56                   	push   %esi
  800569:	53                   	push   %ebx
  80056a:	83 ec 3c             	sub    $0x3c,%esp
  80056d:	8b 75 08             	mov    0x8(%ebp),%esi
  800570:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800573:	8b 7d 10             	mov    0x10(%ebp),%edi
  800576:	eb 11                	jmp    800589 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800578:	85 c0                	test   %eax,%eax
  80057a:	0f 84 48 04 00 00    	je     8009c8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	89 04 24             	mov    %eax,(%esp)
  800587:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800589:	83 c7 01             	add    $0x1,%edi
  80058c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800590:	83 f8 25             	cmp    $0x25,%eax
  800593:	75 e3                	jne    800578 <vprintfmt+0x14>
  800595:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800599:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	eb 1f                	jmp    8005d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8005bc:	eb 16                	jmp    8005d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c5:	eb 0d                	jmp    8005d4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8d 47 01             	lea    0x1(%edi),%eax
  8005d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005da:	0f b6 17             	movzbl (%edi),%edx
  8005dd:	0f b6 c2             	movzbl %dl,%eax
  8005e0:	83 ea 23             	sub    $0x23,%edx
  8005e3:	80 fa 55             	cmp    $0x55,%dl
  8005e6:	0f 87 bf 03 00 00    	ja     8009ab <vprintfmt+0x447>
  8005ec:	0f b6 d2             	movzbl %dl,%edx
  8005ef:	ff 24 95 80 29 80 00 	jmp    *0x802980(,%edx,4)
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800601:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800604:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800608:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80060b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80060e:	83 f9 09             	cmp    $0x9,%ecx
  800611:	77 3c                	ja     80064f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800613:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800616:	eb e9                	jmp    800601 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80062c:	eb 27                	jmp    800655 <vprintfmt+0xf1>
  80062e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	b8 00 00 00 00       	mov    $0x0,%eax
  800638:	0f 49 c2             	cmovns %edx,%eax
  80063b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	eb 91                	jmp    8005d4 <vprintfmt+0x70>
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800646:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80064d:	eb 85                	jmp    8005d4 <vprintfmt+0x70>
  80064f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800652:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800655:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800659:	0f 89 75 ff ff ff    	jns    8005d4 <vprintfmt+0x70>
  80065f:	e9 63 ff ff ff       	jmp    8005c7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800664:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066a:	e9 65 ff ff ff       	jmp    8005d4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800672:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800684:	e9 00 ff ff ff       	jmp    800589 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800690:	8b 00                	mov    (%eax),%eax
  800692:	99                   	cltd   
  800693:	31 d0                	xor    %edx,%eax
  800695:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800697:	83 f8 0f             	cmp    $0xf,%eax
  80069a:	7f 0b                	jg     8006a7 <vprintfmt+0x143>
  80069c:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	75 20                	jne    8006c7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8006a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ab:	c7 44 24 08 57 28 80 	movl   $0x802857,0x8(%esp)
  8006b2:	00 
  8006b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b7:	89 34 24             	mov    %esi,(%esp)
  8006ba:	e8 7d fe ff ff       	call   80053c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c2:	e9 c2 fe ff ff       	jmp    800589 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cb:	c7 44 24 08 fe 2d 80 	movl   $0x802dfe,0x8(%esp)
  8006d2:	00 
  8006d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d7:	89 34 24             	mov    %esi,(%esp)
  8006da:	e8 5d fe ff ff       	call   80053c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e2:	e9 a2 fe ff ff       	jmp    800589 <vprintfmt+0x25>
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f9:	85 ff                	test   %edi,%edi
  8006fb:	b8 50 28 80 00       	mov    $0x802850,%eax
  800700:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800703:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800707:	0f 84 92 00 00 00    	je     80079f <vprintfmt+0x23b>
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	0f 8e 98 00 00 00    	jle    8007ad <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800715:	89 54 24 04          	mov    %edx,0x4(%esp)
  800719:	89 3c 24             	mov    %edi,(%esp)
  80071c:	e8 47 03 00 00       	call   800a68 <strnlen>
  800721:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800724:	29 c1                	sub    %eax,%ecx
  800726:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800729:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80072d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800730:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800733:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800735:	eb 0f                	jmp    800746 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800743:	83 ef 01             	sub    $0x1,%edi
  800746:	85 ff                	test   %edi,%edi
  800748:	7f ed                	jg     800737 <vprintfmt+0x1d3>
  80074a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80074d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800750:	85 c9                	test   %ecx,%ecx
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	0f 49 c1             	cmovns %ecx,%eax
  80075a:	29 c1                	sub    %eax,%ecx
  80075c:	89 75 08             	mov    %esi,0x8(%ebp)
  80075f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800762:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800765:	89 cb                	mov    %ecx,%ebx
  800767:	eb 50                	jmp    8007b9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800769:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80076d:	74 1e                	je     80078d <vprintfmt+0x229>
  80076f:	0f be d2             	movsbl %dl,%edx
  800772:	83 ea 20             	sub    $0x20,%edx
  800775:	83 fa 5e             	cmp    $0x5e,%edx
  800778:	76 13                	jbe    80078d <vprintfmt+0x229>
					putch('?', putdat);
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800788:	ff 55 08             	call   *0x8(%ebp)
  80078b:	eb 0d                	jmp    80079a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	eb 1a                	jmp    8007b9 <vprintfmt+0x255>
  80079f:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ab:	eb 0c                	jmp    8007b9 <vprintfmt+0x255>
  8007ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007b9:	83 c7 01             	add    $0x1,%edi
  8007bc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007c0:	0f be c2             	movsbl %dl,%eax
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 25                	je     8007ec <vprintfmt+0x288>
  8007c7:	85 f6                	test   %esi,%esi
  8007c9:	78 9e                	js     800769 <vprintfmt+0x205>
  8007cb:	83 ee 01             	sub    $0x1,%esi
  8007ce:	79 99                	jns    800769 <vprintfmt+0x205>
  8007d0:	89 df                	mov    %ebx,%edi
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d8:	eb 1a                	jmp    8007f4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007e5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e7:	83 ef 01             	sub    $0x1,%edi
  8007ea:	eb 08                	jmp    8007f4 <vprintfmt+0x290>
  8007ec:	89 df                	mov    %ebx,%edi
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f4:	85 ff                	test   %edi,%edi
  8007f6:	7f e2                	jg     8007da <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fb:	e9 89 fd ff ff       	jmp    800589 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7e 19                	jle    80081e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 50 04             	mov    0x4(%eax),%edx
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800810:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8d 40 08             	lea    0x8(%eax),%eax
  800819:	89 45 14             	mov    %eax,0x14(%ebp)
  80081c:	eb 38                	jmp    800856 <vprintfmt+0x2f2>
	else if (lflag)
  80081e:	85 c9                	test   %ecx,%ecx
  800820:	74 1b                	je     80083d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 00                	mov    (%eax),%eax
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	89 c1                	mov    %eax,%ecx
  80082c:	c1 f9 1f             	sar    $0x1f,%ecx
  80082f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 40 04             	lea    0x4(%eax),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
  80083b:	eb 19                	jmp    800856 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 00                	mov    (%eax),%eax
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 c1                	mov    %eax,%ecx
  800847:	c1 f9 1f             	sar    $0x1f,%ecx
  80084a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800856:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800859:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80085c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800861:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800865:	0f 89 04 01 00 00    	jns    80096f <vprintfmt+0x40b>
				putch('-', putdat);
  80086b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800876:	ff d6                	call   *%esi
				num = -(long long) num;
  800878:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80087b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80087e:	f7 da                	neg    %edx
  800880:	83 d1 00             	adc    $0x0,%ecx
  800883:	f7 d9                	neg    %ecx
  800885:	e9 e5 00 00 00       	jmp    80096f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80088a:	83 f9 01             	cmp    $0x1,%ecx
  80088d:	7e 10                	jle    80089f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8b 10                	mov    (%eax),%edx
  800894:	8b 48 04             	mov    0x4(%eax),%ecx
  800897:	8d 40 08             	lea    0x8(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
  80089d:	eb 26                	jmp    8008c5 <vprintfmt+0x361>
	else if (lflag)
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	74 12                	je     8008b5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ad:	8d 40 04             	lea    0x4(%eax),%eax
  8008b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b3:	eb 10                	jmp    8008c5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8b 10                	mov    (%eax),%edx
  8008ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bf:	8d 40 04             	lea    0x4(%eax),%eax
  8008c2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8008c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8008ca:	e9 a0 00 00 00       	jmp    80096f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008da:	ff d6                	call   *%esi
			putch('X', putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008e7:	ff d6                	call   *%esi
			putch('X', putdat);
  8008e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ed:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008f4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008f9:	e9 8b fc ff ff       	jmp    800589 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8008fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800902:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800909:	ff d6                	call   *%esi
			putch('x', putdat);
  80090b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800916:	ff d6                	call   *%esi
			num = (unsigned long long)
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8b 10                	mov    (%eax),%edx
  80091d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800922:	8d 40 04             	lea    0x4(%eax),%eax
  800925:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800928:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80092d:	eb 40                	jmp    80096f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80092f:	83 f9 01             	cmp    $0x1,%ecx
  800932:	7e 10                	jle    800944 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	8b 10                	mov    (%eax),%edx
  800939:	8b 48 04             	mov    0x4(%eax),%ecx
  80093c:	8d 40 08             	lea    0x8(%eax),%eax
  80093f:	89 45 14             	mov    %eax,0x14(%ebp)
  800942:	eb 26                	jmp    80096a <vprintfmt+0x406>
	else if (lflag)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 12                	je     80095a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8b 10                	mov    (%eax),%edx
  80094d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800952:	8d 40 04             	lea    0x4(%eax),%eax
  800955:	89 45 14             	mov    %eax,0x14(%ebp)
  800958:	eb 10                	jmp    80096a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80095a:	8b 45 14             	mov    0x14(%ebp),%eax
  80095d:	8b 10                	mov    (%eax),%edx
  80095f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800964:	8d 40 04             	lea    0x4(%eax),%eax
  800967:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80096a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80096f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800973:	89 44 24 10          	mov    %eax,0x10(%esp)
  800977:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80097a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800982:	89 14 24             	mov    %edx,(%esp)
  800985:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800989:	89 da                	mov    %ebx,%edx
  80098b:	89 f0                	mov    %esi,%eax
  80098d:	e8 9e fa ff ff       	call   800430 <printnum>
			break;
  800992:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800995:	e9 ef fb ff ff       	jmp    800589 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80099a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009a6:	e9 de fb ff ff       	jmp    800589 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009af:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b8:	eb 03                	jmp    8009bd <vprintfmt+0x459>
  8009ba:	83 ef 01             	sub    $0x1,%edi
  8009bd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009c1:	75 f7                	jne    8009ba <vprintfmt+0x456>
  8009c3:	e9 c1 fb ff ff       	jmp    800589 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009c8:	83 c4 3c             	add    $0x3c,%esp
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5f                   	pop    %edi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 28             	sub    $0x28,%esp
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	74 30                	je     800a21 <vsnprintf+0x51>
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	7e 2c                	jle    800a21 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	c7 04 24 1f 05 80 00 	movl   $0x80051f,(%esp)
  800a11:	e8 4e fb ff ff       	call   800564 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a19:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1f:	eb 05                	jmp    800a26 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a31:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a35:	8b 45 10             	mov    0x10(%ebp),%eax
  800a38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 82 ff ff ff       	call   8009d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb 03                	jmp    800a60 <strlen+0x10>
		n++;
  800a5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a64:	75 f7                	jne    800a5d <strlen+0xd>
		n++;
	return n;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	eb 03                	jmp    800a7b <strnlen+0x13>
		n++;
  800a78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7b:	39 d0                	cmp    %edx,%eax
  800a7d:	74 06                	je     800a85 <strnlen+0x1d>
  800a7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a83:	75 f3                	jne    800a78 <strnlen+0x10>
		n++;
	return n;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	83 c2 01             	add    $0x1,%edx
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800aa0:	84 db                	test   %bl,%bl
  800aa2:	75 ef                	jne    800a93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab1:	89 1c 24             	mov    %ebx,(%esp)
  800ab4:	e8 97 ff ff ff       	call   800a50 <strlen>
	strcpy(dst + len, src);
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac0:	01 d8                	add    %ebx,%eax
  800ac2:	89 04 24             	mov    %eax,(%esp)
  800ac5:	e8 bd ff ff ff       	call   800a87 <strcpy>
	return dst;
}
  800aca:	89 d8                	mov    %ebx,%eax
  800acc:	83 c4 08             	add    $0x8,%esp
  800acf:	5b                   	pop    %ebx
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	8b 75 08             	mov    0x8(%ebp),%esi
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae2:	89 f2                	mov    %esi,%edx
  800ae4:	eb 0f                	jmp    800af5 <strncpy+0x23>
		*dst++ = *src;
  800ae6:	83 c2 01             	add    $0x1,%edx
  800ae9:	0f b6 01             	movzbl (%ecx),%eax
  800aec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aef:	80 39 01             	cmpb   $0x1,(%ecx)
  800af2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af5:	39 da                	cmp    %ebx,%edx
  800af7:	75 ed                	jne    800ae6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af9:	89 f0                	mov    %esi,%eax
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 75 08             	mov    0x8(%ebp),%esi
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b0d:	89 f0                	mov    %esi,%eax
  800b0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b13:	85 c9                	test   %ecx,%ecx
  800b15:	75 0b                	jne    800b22 <strlcpy+0x23>
  800b17:	eb 1d                	jmp    800b36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b19:	83 c0 01             	add    $0x1,%eax
  800b1c:	83 c2 01             	add    $0x1,%edx
  800b1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b22:	39 d8                	cmp    %ebx,%eax
  800b24:	74 0b                	je     800b31 <strlcpy+0x32>
  800b26:	0f b6 0a             	movzbl (%edx),%ecx
  800b29:	84 c9                	test   %cl,%cl
  800b2b:	75 ec                	jne    800b19 <strlcpy+0x1a>
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	eb 02                	jmp    800b33 <strlcpy+0x34>
  800b31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b36:	29 f0                	sub    %esi,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b45:	eb 06                	jmp    800b4d <strcmp+0x11>
		p++, q++;
  800b47:	83 c1 01             	add    $0x1,%ecx
  800b4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b4d:	0f b6 01             	movzbl (%ecx),%eax
  800b50:	84 c0                	test   %al,%al
  800b52:	74 04                	je     800b58 <strcmp+0x1c>
  800b54:	3a 02                	cmp    (%edx),%al
  800b56:	74 ef                	je     800b47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b58:	0f b6 c0             	movzbl %al,%eax
  800b5b:	0f b6 12             	movzbl (%edx),%edx
  800b5e:	29 d0                	sub    %edx,%eax
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b71:	eb 06                	jmp    800b79 <strncmp+0x17>
		n--, p++, q++;
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b79:	39 d8                	cmp    %ebx,%eax
  800b7b:	74 15                	je     800b92 <strncmp+0x30>
  800b7d:	0f b6 08             	movzbl (%eax),%ecx
  800b80:	84 c9                	test   %cl,%cl
  800b82:	74 04                	je     800b88 <strncmp+0x26>
  800b84:	3a 0a                	cmp    (%edx),%cl
  800b86:	74 eb                	je     800b73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b88:	0f b6 00             	movzbl (%eax),%eax
  800b8b:	0f b6 12             	movzbl (%edx),%edx
  800b8e:	29 d0                	sub    %edx,%eax
  800b90:	eb 05                	jmp    800b97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba4:	eb 07                	jmp    800bad <strchr+0x13>
		if (*s == c)
  800ba6:	38 ca                	cmp    %cl,%dl
  800ba8:	74 0f                	je     800bb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	0f b6 10             	movzbl (%eax),%edx
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 f2                	jne    800ba6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	eb 07                	jmp    800bce <strfind+0x13>
		if (*s == c)
  800bc7:	38 ca                	cmp    %cl,%dl
  800bc9:	74 0a                	je     800bd5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	0f b6 10             	movzbl (%eax),%edx
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	75 f2                	jne    800bc7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be3:	85 c9                	test   %ecx,%ecx
  800be5:	74 36                	je     800c1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bed:	75 28                	jne    800c17 <memset+0x40>
  800bef:	f6 c1 03             	test   $0x3,%cl
  800bf2:	75 23                	jne    800c17 <memset+0x40>
		c &= 0xFF;
  800bf4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	c1 e3 08             	shl    $0x8,%ebx
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	c1 e6 18             	shl    $0x18,%esi
  800c02:	89 d0                	mov    %edx,%eax
  800c04:	c1 e0 10             	shl    $0x10,%eax
  800c07:	09 f0                	or     %esi,%eax
  800c09:	09 c2                	or     %eax,%edx
  800c0b:	89 d0                	mov    %edx,%eax
  800c0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c12:	fc                   	cld    
  800c13:	f3 ab                	rep stos %eax,%es:(%edi)
  800c15:	eb 06                	jmp    800c1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	fc                   	cld    
  800c1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1d:	89 f8                	mov    %edi,%eax
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c32:	39 c6                	cmp    %eax,%esi
  800c34:	73 35                	jae    800c6b <memmove+0x47>
  800c36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c39:	39 d0                	cmp    %edx,%eax
  800c3b:	73 2e                	jae    800c6b <memmove+0x47>
		s += n;
		d += n;
  800c3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c40:	89 d6                	mov    %edx,%esi
  800c42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4a:	75 13                	jne    800c5f <memmove+0x3b>
  800c4c:	f6 c1 03             	test   $0x3,%cl
  800c4f:	75 0e                	jne    800c5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c51:	83 ef 04             	sub    $0x4,%edi
  800c54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c5a:	fd                   	std    
  800c5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5d:	eb 09                	jmp    800c68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5f:	83 ef 01             	sub    $0x1,%edi
  800c62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c65:	fd                   	std    
  800c66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c68:	fc                   	cld    
  800c69:	eb 1d                	jmp    800c88 <memmove+0x64>
  800c6b:	89 f2                	mov    %esi,%edx
  800c6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6f:	f6 c2 03             	test   $0x3,%dl
  800c72:	75 0f                	jne    800c83 <memmove+0x5f>
  800c74:	f6 c1 03             	test   $0x3,%cl
  800c77:	75 0a                	jne    800c83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	fc                   	cld    
  800c7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c81:	eb 05                	jmp    800c88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c83:	89 c7                	mov    %eax,%edi
  800c85:	fc                   	cld    
  800c86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c92:	8b 45 10             	mov    0x10(%ebp),%eax
  800c95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	e8 79 ff ff ff       	call   800c24 <memmove>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbd:	eb 1a                	jmp    800cd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800cbf:	0f b6 02             	movzbl (%edx),%eax
  800cc2:	0f b6 19             	movzbl (%ecx),%ebx
  800cc5:	38 d8                	cmp    %bl,%al
  800cc7:	74 0a                	je     800cd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cc9:	0f b6 c0             	movzbl %al,%eax
  800ccc:	0f b6 db             	movzbl %bl,%ebx
  800ccf:	29 d8                	sub    %ebx,%eax
  800cd1:	eb 0f                	jmp    800ce2 <memcmp+0x35>
		s1++, s2++;
  800cd3:	83 c2 01             	add    $0x1,%edx
  800cd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd9:	39 f2                	cmp    %esi,%edx
  800cdb:	75 e2                	jne    800cbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf4:	eb 07                	jmp    800cfd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf6:	38 08                	cmp    %cl,(%eax)
  800cf8:	74 07                	je     800d01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	39 d0                	cmp    %edx,%eax
  800cff:	72 f5                	jb     800cf6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0f:	eb 03                	jmp    800d14 <strtol+0x11>
		s++;
  800d11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d14:	0f b6 0a             	movzbl (%edx),%ecx
  800d17:	80 f9 09             	cmp    $0x9,%cl
  800d1a:	74 f5                	je     800d11 <strtol+0xe>
  800d1c:	80 f9 20             	cmp    $0x20,%cl
  800d1f:	74 f0                	je     800d11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d21:	80 f9 2b             	cmp    $0x2b,%cl
  800d24:	75 0a                	jne    800d30 <strtol+0x2d>
		s++;
  800d26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d29:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2e:	eb 11                	jmp    800d41 <strtol+0x3e>
  800d30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d35:	80 f9 2d             	cmp    $0x2d,%cl
  800d38:	75 07                	jne    800d41 <strtol+0x3e>
		s++, neg = 1;
  800d3a:	8d 52 01             	lea    0x1(%edx),%edx
  800d3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800d46:	75 15                	jne    800d5d <strtol+0x5a>
  800d48:	80 3a 30             	cmpb   $0x30,(%edx)
  800d4b:	75 10                	jne    800d5d <strtol+0x5a>
  800d4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d51:	75 0a                	jne    800d5d <strtol+0x5a>
		s += 2, base = 16;
  800d53:	83 c2 02             	add    $0x2,%edx
  800d56:	b8 10 00 00 00       	mov    $0x10,%eax
  800d5b:	eb 10                	jmp    800d6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	75 0c                	jne    800d6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d63:	80 3a 30             	cmpb   $0x30,(%edx)
  800d66:	75 05                	jne    800d6d <strtol+0x6a>
		s++, base = 8;
  800d68:	83 c2 01             	add    $0x1,%edx
  800d6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d75:	0f b6 0a             	movzbl (%edx),%ecx
  800d78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d7b:	89 f0                	mov    %esi,%eax
  800d7d:	3c 09                	cmp    $0x9,%al
  800d7f:	77 08                	ja     800d89 <strtol+0x86>
			dig = *s - '0';
  800d81:	0f be c9             	movsbl %cl,%ecx
  800d84:	83 e9 30             	sub    $0x30,%ecx
  800d87:	eb 20                	jmp    800da9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d8c:	89 f0                	mov    %esi,%eax
  800d8e:	3c 19                	cmp    $0x19,%al
  800d90:	77 08                	ja     800d9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800d92:	0f be c9             	movsbl %cl,%ecx
  800d95:	83 e9 57             	sub    $0x57,%ecx
  800d98:	eb 0f                	jmp    800da9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800d9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	3c 19                	cmp    $0x19,%al
  800da1:	77 16                	ja     800db9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800da3:	0f be c9             	movsbl %cl,%ecx
  800da6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800dac:	7d 0f                	jge    800dbd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800dae:	83 c2 01             	add    $0x1,%edx
  800db1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800db5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800db7:	eb bc                	jmp    800d75 <strtol+0x72>
  800db9:	89 d8                	mov    %ebx,%eax
  800dbb:	eb 02                	jmp    800dbf <strtol+0xbc>
  800dbd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800dbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc3:	74 05                	je     800dca <strtol+0xc7>
		*endptr = (char *) s;
  800dc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800dca:	f7 d8                	neg    %eax
  800dcc:	85 ff                	test   %edi,%edi
  800dce:	0f 44 c3             	cmove  %ebx,%eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	89 c7                	mov    %eax,%edi
  800deb:	89 c6                	mov    %eax,%esi
  800ded:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800dff:	b8 01 00 00 00       	mov    $0x1,%eax
  800e04:	89 d1                	mov    %edx,%ecx
  800e06:	89 d3                	mov    %edx,%ebx
  800e08:	89 d7                	mov    %edx,%edi
  800e0a:	89 d6                	mov    %edx,%esi
  800e0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e21:	b8 03 00 00 00       	mov    $0x3,%eax
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 cb                	mov    %ecx,%ebx
  800e2b:	89 cf                	mov    %ecx,%edi
  800e2d:	89 ce                	mov    %ecx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800e58:	e8 bc f4 ff ff       	call   800319 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e70:	b8 02 00 00 00       	mov    $0x2,%eax
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 d3                	mov    %edx,%ebx
  800e79:	89 d7                	mov    %edx,%edi
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_yield>:

void
sys_yield(void)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e94:	89 d1                	mov    %edx,%ecx
  800e96:	89 d3                	mov    %edx,%ebx
  800e98:	89 d7                	mov    %edx,%edi
  800e9a:	89 d6                	mov    %edx,%esi
  800e9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebf:	89 f7                	mov    %esi,%edi
  800ec1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	7e 28                	jle    800eef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed2:	00 
  800ed3:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800eda:	00 
  800edb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee2:	00 
  800ee3:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800eea:	e8 2a f4 ff ff       	call   800319 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eef:	83 c4 2c             	add    $0x2c,%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	b8 05 00 00 00       	mov    $0x5,%eax
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f11:	8b 75 18             	mov    0x18(%ebp),%esi
  800f14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7e 28                	jle    800f42 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f25:	00 
  800f26:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f3d:	e8 d7 f3 ff ff       	call   800319 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f42:	83 c4 2c             	add    $0x2c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f58:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	89 df                	mov    %ebx,%edi
  800f65:	89 de                	mov    %ebx,%esi
  800f67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800f90:	e8 84 f3 ff ff       	call   800319 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f95:	83 c4 2c             	add    $0x2c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fab:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb6:	89 df                	mov    %ebx,%edi
  800fb8:	89 de                	mov    %ebx,%esi
  800fba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	7e 28                	jle    800fe8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  800fe3:	e8 31 f3 ff ff       	call   800319 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe8:	83 c4 2c             	add    $0x2c,%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffe:	b8 09 00 00 00       	mov    $0x9,%eax
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 df                	mov    %ebx,%edi
  80100b:	89 de                	mov    %ebx,%esi
  80100d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100f:	85 c0                	test   %eax,%eax
  801011:	7e 28                	jle    80103b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801013:	89 44 24 10          	mov    %eax,0x10(%esp)
  801017:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80101e:	00 
  80101f:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  801026:	00 
  801027:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102e:	00 
  80102f:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801036:	e8 de f2 ff ff       	call   800319 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80103b:	83 c4 2c             	add    $0x2c,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801051:	b8 0a 00 00 00       	mov    $0xa,%eax
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	89 df                	mov    %ebx,%edi
  80105e:	89 de                	mov    %ebx,%esi
  801060:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	7e 28                	jle    80108e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801066:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801071:	00 
  801072:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  801079:	00 
  80107a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801081:	00 
  801082:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801089:	e8 8b f2 ff ff       	call   800319 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80108e:	83 c4 2c             	add    $0x2c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109c:	be 00 00 00 00       	mov    $0x0,%esi
  8010a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cf:	89 cb                	mov    %ecx,%ebx
  8010d1:	89 cf                	mov    %ecx,%edi
  8010d3:	89 ce                	mov    %ecx,%esi
  8010d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	7e 28                	jle    801103 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 08 3f 2b 80 	movl   $0x802b3f,0x8(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f6:	00 
  8010f7:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  8010fe:	e8 16 f2 ff ff       	call   800319 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801103:	83 c4 2c             	add    $0x2c,%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	56                   	push   %esi
  80110f:	53                   	push   %ebx
  801110:	83 ec 20             	sub    $0x20,%esp
  801113:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801116:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801118:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80111c:	75 3f                	jne    80115d <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80111e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801122:	c7 04 24 6a 2b 80 00 	movl   $0x802b6a,(%esp)
  801129:	e8 e4 f2 ff ff       	call   800412 <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80112e:	8b 43 28             	mov    0x28(%ebx),%eax
  801131:	89 44 24 04          	mov    %eax,0x4(%esp)
  801135:	c7 04 24 7a 2b 80 00 	movl   $0x802b7a,(%esp)
  80113c:	e8 d1 f2 ff ff       	call   800412 <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801141:	c7 44 24 08 c0 2b 80 	movl   $0x802bc0,0x8(%esp)
  801148:	00 
  801149:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801158:	e8 bc f1 ff ff       	call   800319 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80115d:	89 f0                	mov    %esi,%eax
  80115f:	c1 e8 0c             	shr    $0xc,%eax
  801162:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801169:	f6 c4 08             	test   $0x8,%ah
  80116c:	75 1c                	jne    80118a <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80116e:	c7 44 24 08 e8 2b 80 	movl   $0x802be8,0x8(%esp)
  801175:	00 
  801176:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80117d:	00 
  80117e:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801185:	e8 8f f1 ff ff       	call   800319 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80118a:	e8 d6 fc ff ff       	call   800e65 <sys_getenvid>
  80118f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801196:	00 
  801197:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80119e:	00 
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 fc fc ff ff       	call   800ea3 <sys_page_alloc>
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	79 1c                	jns    8011c7 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  8011ab:	c7 44 24 08 08 2c 80 	movl   $0x802c08,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  8011c2:	e8 52 f1 ff ff       	call   800319 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8011c7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8011cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011d4:	00 
  8011d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011e0:	e8 a7 fa ff ff       	call   800c8c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8011e5:	e8 7b fc ff ff       	call   800e65 <sys_getenvid>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	e8 74 fc ff ff       	call   800e65 <sys_getenvid>
  8011f1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011f8:	00 
  8011f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801201:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801208:	00 
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 e6 fc ff ff       	call   800ef7 <sys_page_map>
  801211:	85 c0                	test   %eax,%eax
  801213:	79 20                	jns    801235 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801215:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801219:	c7 44 24 08 30 2c 80 	movl   $0x802c30,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801230:	e8 e4 f0 ff ff       	call   800319 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801235:	e8 2b fc ff ff       	call   800e65 <sys_getenvid>
  80123a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801241:	00 
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 00 fd ff ff       	call   800f4a <sys_page_unmap>
  80124a:	85 c0                	test   %eax,%eax
  80124c:	79 20                	jns    80126e <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  80124e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801252:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  801259:	00 
  80125a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801261:	00 
  801262:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801269:	e8 ab f0 ff ff       	call   800319 <_panic>
	return;
}
  80126e:	83 c4 20             	add    $0x20,%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80127e:	c7 04 24 0b 11 80 00 	movl   $0x80110b,(%esp)
  801285:	e8 9c 0f 00 00       	call   802226 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80128a:	b8 07 00 00 00       	mov    $0x7,%eax
  80128f:	cd 30                	int    $0x30
  801291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801294:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801297:	85 c0                	test   %eax,%eax
  801299:	79 20                	jns    8012bb <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80129b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129f:	c7 44 24 08 94 2c 80 	movl   $0x802c94,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  8012b6:	e8 5e f0 ff ff       	call   800319 <_panic>
	if(childEid == 0){
  8012bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012bf:	75 1c                	jne    8012dd <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012c1:	e8 9f fb ff ff       	call   800e65 <sys_getenvid>
  8012c6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d3:	a3 04 40 80 00       	mov    %eax,0x804004
		return childEid;
  8012d8:	e9 a0 01 00 00       	jmp    80147d <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  8012dd:	c7 44 24 04 bc 22 80 	movl   $0x8022bc,0x4(%esp)
  8012e4:	00 
  8012e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	e8 53 fd ff ff       	call   801043 <sys_env_set_pgfault_upcall>
  8012f0:	89 c7                	mov    %eax,%edi
	if(r < 0)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	79 20                	jns    801316 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  8012f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fa:	c7 44 24 08 c8 2c 80 	movl   $0x802cc8,0x8(%esp)
  801301:	00 
  801302:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801309:	00 
  80130a:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801311:	e8 03 f0 ff ff       	call   800319 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801316:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
  801320:	b9 00 00 00 00       	mov    $0x0,%ecx
  801325:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801328:	89 c2                	mov    %eax,%edx
  80132a:	c1 ea 16             	shr    $0x16,%edx
  80132d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801334:	f6 c2 01             	test   $0x1,%dl
  801337:	0f 84 f7 00 00 00    	je     801434 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801347:	f6 c2 04             	test   $0x4,%dl
  80134a:	0f 84 e4 00 00 00    	je     801434 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801350:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801357:	a8 01                	test   $0x1,%al
  801359:	0f 84 d5 00 00 00    	je     801434 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  80135f:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801365:	75 20                	jne    801387 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801367:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801376:	ee 
  801377:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137a:	89 04 24             	mov    %eax,(%esp)
  80137d:	e8 21 fb ff ff       	call   800ea3 <sys_page_alloc>
  801382:	e9 84 00 00 00       	jmp    80140b <fork+0x196>
  801387:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80138d:	89 f8                	mov    %edi,%eax
  80138f:	c1 e8 0c             	shr    $0xc,%eax
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801399:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80139e:	83 f8 01             	cmp    $0x1,%eax
  8013a1:	19 db                	sbb    %ebx,%ebx
  8013a3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8013a9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  8013af:	e8 b1 fa ff ff       	call   800e65 <sys_getenvid>
  8013b4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013b8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 28 fb ff ff       	call   800ef7 <sys_page_map>
  8013cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 35                	js     80140b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  8013d6:	e8 8a fa ff ff       	call   800e65 <sys_getenvid>
  8013db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013de:	e8 82 fa ff ff       	call   800e65 <sys_getenvid>
  8013e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8013ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 f9 fa ff ff       	call   800ef7 <sys_page_map>
  8013fe:	85 c0                	test   %eax,%eax
  801400:	bf 00 00 00 00       	mov    $0x0,%edi
  801405:	0f 4f c7             	cmovg  %edi,%eax
  801408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80140b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80140f:	79 23                	jns    801434 <fork+0x1bf>
  801411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801414:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801418:	c7 44 24 08 08 2d 80 	movl   $0x802d08,0x8(%esp)
  80141f:	00 
  801420:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801427:	00 
  801428:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  80142f:	e8 e5 ee ff ff       	call   800319 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801434:	89 f1                	mov    %esi,%ecx
  801436:	89 f0                	mov    %esi,%eax
  801438:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80143e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801444:	0f 85 de fe ff ff    	jne    801328 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  80144a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801451:	00 
  801452:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 40 fb ff ff       	call   800f9d <sys_env_set_status>
  80145d:	85 c0                	test   %eax,%eax
  80145f:	79 1c                	jns    80147d <fork+0x208>
		panic("sys_env_set_status");
  801461:	c7 44 24 08 96 2b 80 	movl   $0x802b96,0x8(%esp)
  801468:	00 
  801469:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801470:	00 
  801471:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  801478:	e8 9c ee ff ff       	call   800319 <_panic>
	return childEid;
}
  80147d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801480:	83 c4 2c             	add    $0x2c,%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <sfork>:

// Challenge!
int
sfork(void)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80148e:	c7 44 24 08 a9 2b 80 	movl   $0x802ba9,0x8(%esp)
  801495:	00 
  801496:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  8014a5:	e8 6f ee ff ff       	call   800319 <_panic>
  8014aa:	66 90                	xchg   %ax,%ax
  8014ac:	66 90                	xchg   %ax,%ax
  8014ae:	66 90                	xchg   %ax,%ax

008014b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8014cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	c1 ea 16             	shr    $0x16,%edx
  8014e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ee:	f6 c2 01             	test   $0x1,%dl
  8014f1:	74 11                	je     801504 <fd_alloc+0x2d>
  8014f3:	89 c2                	mov    %eax,%edx
  8014f5:	c1 ea 0c             	shr    $0xc,%edx
  8014f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ff:	f6 c2 01             	test   $0x1,%dl
  801502:	75 09                	jne    80150d <fd_alloc+0x36>
			*fd_store = fd;
  801504:	89 01                	mov    %eax,(%ecx)
			return 0;
  801506:	b8 00 00 00 00       	mov    $0x0,%eax
  80150b:	eb 17                	jmp    801524 <fd_alloc+0x4d>
  80150d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801512:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801517:	75 c9                	jne    8014e2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801519:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80151f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80152c:	83 f8 1f             	cmp    $0x1f,%eax
  80152f:	77 36                	ja     801567 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801531:	c1 e0 0c             	shl    $0xc,%eax
  801534:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801539:	89 c2                	mov    %eax,%edx
  80153b:	c1 ea 16             	shr    $0x16,%edx
  80153e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801545:	f6 c2 01             	test   $0x1,%dl
  801548:	74 24                	je     80156e <fd_lookup+0x48>
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	c1 ea 0c             	shr    $0xc,%edx
  80154f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801556:	f6 c2 01             	test   $0x1,%dl
  801559:	74 1a                	je     801575 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80155b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155e:	89 02                	mov    %eax,(%edx)
	return 0;
  801560:	b8 00 00 00 00       	mov    $0x0,%eax
  801565:	eb 13                	jmp    80157a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801567:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156c:	eb 0c                	jmp    80157a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801573:	eb 05                	jmp    80157a <fd_lookup+0x54>
  801575:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 18             	sub    $0x18,%esp
  801582:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801585:	ba ac 2d 80 00       	mov    $0x802dac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80158a:	eb 13                	jmp    80159f <dev_lookup+0x23>
  80158c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80158f:	39 08                	cmp    %ecx,(%eax)
  801591:	75 0c                	jne    80159f <dev_lookup+0x23>
			*dev = devtab[i];
  801593:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801596:	89 01                	mov    %eax,(%ecx)
			return 0;
  801598:	b8 00 00 00 00       	mov    $0x0,%eax
  80159d:	eb 30                	jmp    8015cf <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80159f:	8b 02                	mov    (%edx),%eax
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	75 e7                	jne    80158c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b5:	c7 04 24 30 2d 80 00 	movl   $0x802d30,(%esp)
  8015bc:	e8 51 ee ff ff       	call   800412 <cprintf>
	*dev = 0;
  8015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 20             	sub    $0x20,%esp
  8015d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015ec:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ef:	89 04 24             	mov    %eax,(%esp)
  8015f2:	e8 2f ff ff ff       	call   801526 <fd_lookup>
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 05                	js     801600 <fd_close+0x2f>
	    || fd != fd2)
  8015fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015fe:	74 0c                	je     80160c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801600:	84 db                	test   %bl,%bl
  801602:	ba 00 00 00 00       	mov    $0x0,%edx
  801607:	0f 44 c2             	cmove  %edx,%eax
  80160a:	eb 3f                	jmp    80164b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80160c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801613:	8b 06                	mov    (%esi),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 5f ff ff ff       	call   80157c <dev_lookup>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 16                	js     801639 <fd_close+0x68>
		if (dev->dev_close)
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801629:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 07                	je     801639 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801632:	89 34 24             	mov    %esi,(%esp)
  801635:	ff d0                	call   *%eax
  801637:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 01 f9 ff ff       	call   800f4a <sys_page_unmap>
	return r;
  801649:	89 d8                	mov    %ebx,%eax
}
  80164b:	83 c4 20             	add    $0x20,%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 bc fe ff ff       	call   801526 <fd_lookup>
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	85 d2                	test   %edx,%edx
  80166e:	78 13                	js     801683 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801670:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801677:	00 
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 4e ff ff ff       	call   8015d1 <fd_close>
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <close_all>:

void
close_all(void)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80168c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801691:	89 1c 24             	mov    %ebx,(%esp)
  801694:	e8 b9 ff ff ff       	call   801652 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801699:	83 c3 01             	add    $0x1,%ebx
  80169c:	83 fb 20             	cmp    $0x20,%ebx
  80169f:	75 f0                	jne    801691 <close_all+0xc>
		close(i);
}
  8016a1:	83 c4 14             	add    $0x14,%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	57                   	push   %edi
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 64 fe ff ff       	call   801526 <fd_lookup>
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	85 d2                	test   %edx,%edx
  8016c6:	0f 88 e1 00 00 00    	js     8017ad <dup+0x106>
		return r;
	close(newfdnum);
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	e8 7b ff ff ff       	call   801652 <close>

	newfd = INDEX2FD(newfdnum);
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016da:	c1 e3 0c             	shl    $0xc,%ebx
  8016dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e6:	89 04 24             	mov    %eax,(%esp)
  8016e9:	e8 d2 fd ff ff       	call   8014c0 <fd2data>
  8016ee:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8016f0:	89 1c 24             	mov    %ebx,(%esp)
  8016f3:	e8 c8 fd ff ff       	call   8014c0 <fd2data>
  8016f8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016fa:	89 f0                	mov    %esi,%eax
  8016fc:	c1 e8 16             	shr    $0x16,%eax
  8016ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801706:	a8 01                	test   $0x1,%al
  801708:	74 43                	je     80174d <dup+0xa6>
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	c1 e8 0c             	shr    $0xc,%eax
  80170f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801716:	f6 c2 01             	test   $0x1,%dl
  801719:	74 32                	je     80174d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80171b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801722:	25 07 0e 00 00       	and    $0xe07,%eax
  801727:	89 44 24 10          	mov    %eax,0x10(%esp)
  80172b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80172f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801736:	00 
  801737:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801742:	e8 b0 f7 ff ff       	call   800ef7 <sys_page_map>
  801747:	89 c6                	mov    %eax,%esi
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 3e                	js     80178b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80174d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801750:	89 c2                	mov    %eax,%edx
  801752:	c1 ea 0c             	shr    $0xc,%edx
  801755:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80175c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801762:	89 54 24 10          	mov    %edx,0x10(%esp)
  801766:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80176a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801771:	00 
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177d:	e8 75 f7 ff ff       	call   800ef7 <sys_page_map>
  801782:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801784:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801787:	85 f6                	test   %esi,%esi
  801789:	79 22                	jns    8017ad <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80178b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80178f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801796:	e8 af f7 ff ff       	call   800f4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80179b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a6:	e8 9f f7 ff ff       	call   800f4a <sys_page_unmap>
	return r;
  8017ab:	89 f0                	mov    %esi,%eax
}
  8017ad:	83 c4 3c             	add    $0x3c,%esp
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5f                   	pop    %edi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 24             	sub    $0x24,%esp
  8017bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	89 1c 24             	mov    %ebx,(%esp)
  8017c9:	e8 58 fd ff ff       	call   801526 <fd_lookup>
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	85 d2                	test   %edx,%edx
  8017d2:	78 6d                	js     801841 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017de:	8b 00                	mov    (%eax),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 94 fd ff ff       	call   80157c <dev_lookup>
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 55                	js     801841 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	8b 50 08             	mov    0x8(%eax),%edx
  8017f2:	83 e2 03             	and    $0x3,%edx
  8017f5:	83 fa 01             	cmp    $0x1,%edx
  8017f8:	75 23                	jne    80181d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ff:	8b 40 48             	mov    0x48(%eax),%eax
  801802:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801806:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180a:	c7 04 24 71 2d 80 00 	movl   $0x802d71,(%esp)
  801811:	e8 fc eb ff ff       	call   800412 <cprintf>
		return -E_INVAL;
  801816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80181b:	eb 24                	jmp    801841 <read+0x8c>
	}
	if (!dev->dev_read)
  80181d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801820:	8b 52 08             	mov    0x8(%edx),%edx
  801823:	85 d2                	test   %edx,%edx
  801825:	74 15                	je     80183c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801827:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80182a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80182e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801831:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	ff d2                	call   *%edx
  80183a:	eb 05                	jmp    801841 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80183c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801841:	83 c4 24             	add    $0x24,%esp
  801844:	5b                   	pop    %ebx
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 1c             	sub    $0x1c,%esp
  801850:	8b 7d 08             	mov    0x8(%ebp),%edi
  801853:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801856:	bb 00 00 00 00       	mov    $0x0,%ebx
  80185b:	eb 23                	jmp    801880 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80185d:	89 f0                	mov    %esi,%eax
  80185f:	29 d8                	sub    %ebx,%eax
  801861:	89 44 24 08          	mov    %eax,0x8(%esp)
  801865:	89 d8                	mov    %ebx,%eax
  801867:	03 45 0c             	add    0xc(%ebp),%eax
  80186a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186e:	89 3c 24             	mov    %edi,(%esp)
  801871:	e8 3f ff ff ff       	call   8017b5 <read>
		if (m < 0)
  801876:	85 c0                	test   %eax,%eax
  801878:	78 10                	js     80188a <readn+0x43>
			return m;
		if (m == 0)
  80187a:	85 c0                	test   %eax,%eax
  80187c:	74 0a                	je     801888 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80187e:	01 c3                	add    %eax,%ebx
  801880:	39 f3                	cmp    %esi,%ebx
  801882:	72 d9                	jb     80185d <readn+0x16>
  801884:	89 d8                	mov    %ebx,%eax
  801886:	eb 02                	jmp    80188a <readn+0x43>
  801888:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80188a:	83 c4 1c             	add    $0x1c,%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5f                   	pop    %edi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 24             	sub    $0x24,%esp
  801899:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	89 1c 24             	mov    %ebx,(%esp)
  8018a6:	e8 7b fc ff ff       	call   801526 <fd_lookup>
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	85 d2                	test   %edx,%edx
  8018af:	78 68                	js     801919 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bb:	8b 00                	mov    (%eax),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 b7 fc ff ff       	call   80157c <dev_lookup>
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	78 50                	js     801919 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d0:	75 23                	jne    8018f5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d7:	8b 40 48             	mov    0x48(%eax),%eax
  8018da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	c7 04 24 8d 2d 80 00 	movl   $0x802d8d,(%esp)
  8018e9:	e8 24 eb ff ff       	call   800412 <cprintf>
		return -E_INVAL;
  8018ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f3:	eb 24                	jmp    801919 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018fb:	85 d2                	test   %edx,%edx
  8018fd:	74 15                	je     801914 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801902:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801906:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801909:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	ff d2                	call   *%edx
  801912:	eb 05                	jmp    801919 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801914:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801919:	83 c4 24             	add    $0x24,%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <seek>:

int
seek(int fdnum, off_t offset)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801925:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 ef fb ff ff       	call   801526 <fd_lookup>
  801937:	85 c0                	test   %eax,%eax
  801939:	78 0e                	js     801949 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80193b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80193e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801941:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	83 ec 24             	sub    $0x24,%esp
  801952:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801955:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195c:	89 1c 24             	mov    %ebx,(%esp)
  80195f:	e8 c2 fb ff ff       	call   801526 <fd_lookup>
  801964:	89 c2                	mov    %eax,%edx
  801966:	85 d2                	test   %edx,%edx
  801968:	78 61                	js     8019cb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801974:	8b 00                	mov    (%eax),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 fe fb ff ff       	call   80157c <dev_lookup>
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 49                	js     8019cb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801989:	75 23                	jne    8019ae <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80198b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801990:	8b 40 48             	mov    0x48(%eax),%eax
  801993:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	c7 04 24 50 2d 80 00 	movl   $0x802d50,(%esp)
  8019a2:	e8 6b ea ff ff       	call   800412 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ac:	eb 1d                	jmp    8019cb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b1:	8b 52 18             	mov    0x18(%edx),%edx
  8019b4:	85 d2                	test   %edx,%edx
  8019b6:	74 0e                	je     8019c6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	ff d2                	call   *%edx
  8019c4:	eb 05                	jmp    8019cb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019cb:	83 c4 24             	add    $0x24,%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 24             	sub    $0x24,%esp
  8019d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e5:	89 04 24             	mov    %eax,(%esp)
  8019e8:	e8 39 fb ff ff       	call   801526 <fd_lookup>
  8019ed:	89 c2                	mov    %eax,%edx
  8019ef:	85 d2                	test   %edx,%edx
  8019f1:	78 52                	js     801a45 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fd:	8b 00                	mov    (%eax),%eax
  8019ff:	89 04 24             	mov    %eax,(%esp)
  801a02:	e8 75 fb ff ff       	call   80157c <dev_lookup>
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 3a                	js     801a45 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a12:	74 2c                	je     801a40 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a14:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a17:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a1e:	00 00 00 
	stat->st_isdir = 0;
  801a21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a28:	00 00 00 
	stat->st_dev = dev;
  801a2b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a35:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a38:	89 14 24             	mov    %edx,(%esp)
  801a3b:	ff 50 14             	call   *0x14(%eax)
  801a3e:	eb 05                	jmp    801a45 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a40:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a45:	83 c4 24             	add    $0x24,%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5a:	00 
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	e8 fb 01 00 00       	call   801c61 <open>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	78 1b                	js     801a87 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a73:	89 1c 24             	mov    %ebx,(%esp)
  801a76:	e8 56 ff ff ff       	call   8019d1 <fstat>
  801a7b:	89 c6                	mov    %eax,%esi
	close(fd);
  801a7d:	89 1c 24             	mov    %ebx,(%esp)
  801a80:	e8 cd fb ff ff       	call   801652 <close>
	return r;
  801a85:	89 f0                	mov    %esi,%eax
}
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	56                   	push   %esi
  801a92:	53                   	push   %ebx
  801a93:	83 ec 10             	sub    $0x10,%esp
  801a96:	89 c6                	mov    %eax,%esi
  801a98:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a9a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801aa1:	75 11                	jne    801ab4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aaa:	e8 9e 09 00 00       	call   80244d <ipc_find_env>
  801aaf:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ab4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801abb:	00 
  801abc:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ac3:	00 
  801ac4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ac8:	a1 00 40 80 00       	mov    0x804000,%eax
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	e8 c9 08 00 00       	call   80239e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ad5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801adc:	00 
  801add:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae8:	e8 13 08 00 00       	call   802300 <ipc_recv>
}
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8b 40 0c             	mov    0xc(%eax),%eax
  801b00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b08:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 02 00 00 00       	mov    $0x2,%eax
  801b17:	e8 72 ff ff ff       	call   801a8e <fsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b24:	8b 45 08             	mov    0x8(%ebp),%eax
  801b27:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b34:	b8 06 00 00 00       	mov    $0x6,%eax
  801b39:	e8 50 ff ff ff       	call   801a8e <fsipc>
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	53                   	push   %ebx
  801b44:	83 ec 14             	sub    $0x14,%esp
  801b47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b50:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b5f:	e8 2a ff ff ff       	call   801a8e <fsipc>
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	85 d2                	test   %edx,%edx
  801b68:	78 2b                	js     801b95 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b6a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b71:	00 
  801b72:	89 1c 24             	mov    %ebx,(%esp)
  801b75:	e8 0d ef ff ff       	call   800a87 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b7a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b85:	a1 84 50 80 00       	mov    0x805084,%eax
  801b8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b95:	83 c4 14             	add    $0x14,%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801ba1:	c7 44 24 08 bc 2d 80 	movl   $0x802dbc,0x8(%esp)
  801ba8:	00 
  801ba9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801bb0:	00 
  801bb1:	c7 04 24 da 2d 80 00 	movl   $0x802dda,(%esp)
  801bb8:	e8 5c e7 ff ff       	call   800319 <_panic>

00801bbd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 10             	sub    $0x10,%esp
  801bc5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	8b 40 0c             	mov    0xc(%eax),%eax
  801bce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bd3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bde:	b8 03 00 00 00       	mov    $0x3,%eax
  801be3:	e8 a6 fe ff ff       	call   801a8e <fsipc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 6a                	js     801c58 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bee:	39 c6                	cmp    %eax,%esi
  801bf0:	73 24                	jae    801c16 <devfile_read+0x59>
  801bf2:	c7 44 24 0c e5 2d 80 	movl   $0x802de5,0xc(%esp)
  801bf9:	00 
  801bfa:	c7 44 24 08 ec 2d 80 	movl   $0x802dec,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 da 2d 80 00 	movl   $0x802dda,(%esp)
  801c11:	e8 03 e7 ff ff       	call   800319 <_panic>
	assert(r <= PGSIZE);
  801c16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1b:	7e 24                	jle    801c41 <devfile_read+0x84>
  801c1d:	c7 44 24 0c 01 2e 80 	movl   $0x802e01,0xc(%esp)
  801c24:	00 
  801c25:	c7 44 24 08 ec 2d 80 	movl   $0x802dec,0x8(%esp)
  801c2c:	00 
  801c2d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c34:	00 
  801c35:	c7 04 24 da 2d 80 00 	movl   $0x802dda,(%esp)
  801c3c:	e8 d8 e6 ff ff       	call   800319 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c45:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c4c:	00 
  801c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c50:	89 04 24             	mov    %eax,(%esp)
  801c53:	e8 cc ef ff ff       	call   800c24 <memmove>
	return r;
}
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	53                   	push   %ebx
  801c65:	83 ec 24             	sub    $0x24,%esp
  801c68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c6b:	89 1c 24             	mov    %ebx,(%esp)
  801c6e:	e8 dd ed ff ff       	call   800a50 <strlen>
  801c73:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c78:	7f 60                	jg     801cda <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	89 04 24             	mov    %eax,(%esp)
  801c80:	e8 52 f8 ff ff       	call   8014d7 <fd_alloc>
  801c85:	89 c2                	mov    %eax,%edx
  801c87:	85 d2                	test   %edx,%edx
  801c89:	78 54                	js     801cdf <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8f:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c96:	e8 ec ed ff ff       	call   800a87 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	e8 de fd ff ff       	call   801a8e <fsipc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	79 17                	jns    801ccd <open+0x6c>
		fd_close(fd, 0);
  801cb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cbd:	00 
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	89 04 24             	mov    %eax,(%esp)
  801cc4:	e8 08 f9 ff ff       	call   8015d1 <fd_close>
		return r;
  801cc9:	89 d8                	mov    %ebx,%eax
  801ccb:	eb 12                	jmp    801cdf <open+0x7e>
	}

	return fd2num(fd);
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	89 04 24             	mov    %eax,(%esp)
  801cd3:	e8 d8 f7 ff ff       	call   8014b0 <fd2num>
  801cd8:	eb 05                	jmp    801cdf <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cda:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cdf:	83 c4 24             	add    $0x24,%esp
  801ce2:	5b                   	pop    %ebx
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf0:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf5:	e8 94 fd ff ff       	call   801a8e <fsipc>
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 10             	sub    $0x10,%esp
  801d04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 ae f7 ff ff       	call   8014c0 <fd2data>
  801d12:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d14:	c7 44 24 04 0d 2e 80 	movl   $0x802e0d,0x4(%esp)
  801d1b:	00 
  801d1c:	89 1c 24             	mov    %ebx,(%esp)
  801d1f:	e8 63 ed ff ff       	call   800a87 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d24:	8b 46 04             	mov    0x4(%esi),%eax
  801d27:	2b 06                	sub    (%esi),%eax
  801d29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d36:	00 00 00 
	stat->st_dev = &devpipe;
  801d39:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d40:	30 80 00 
	return 0;
}
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	53                   	push   %ebx
  801d53:	83 ec 14             	sub    $0x14,%esp
  801d56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d59:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d64:	e8 e1 f1 ff ff       	call   800f4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d69:	89 1c 24             	mov    %ebx,(%esp)
  801d6c:	e8 4f f7 ff ff       	call   8014c0 <fd2data>
  801d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7c:	e8 c9 f1 ff ff       	call   800f4a <sys_page_unmap>
}
  801d81:	83 c4 14             	add    $0x14,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	57                   	push   %edi
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	83 ec 2c             	sub    $0x2c,%esp
  801d90:	89 c6                	mov    %eax,%esi
  801d92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d95:	a1 04 40 80 00       	mov    0x804004,%eax
  801d9a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d9d:	89 34 24             	mov    %esi,(%esp)
  801da0:	e8 e0 06 00 00       	call   802485 <pageref>
  801da5:	89 c7                	mov    %eax,%edi
  801da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801daa:	89 04 24             	mov    %eax,(%esp)
  801dad:	e8 d3 06 00 00       	call   802485 <pageref>
  801db2:	39 c7                	cmp    %eax,%edi
  801db4:	0f 94 c2             	sete   %dl
  801db7:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801dba:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801dc0:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801dc3:	39 fb                	cmp    %edi,%ebx
  801dc5:	74 21                	je     801de8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dc7:	84 d2                	test   %dl,%dl
  801dc9:	74 ca                	je     801d95 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dcb:	8b 51 58             	mov    0x58(%ecx),%edx
  801dce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dda:	c7 04 24 14 2e 80 00 	movl   $0x802e14,(%esp)
  801de1:	e8 2c e6 ff ff       	call   800412 <cprintf>
  801de6:	eb ad                	jmp    801d95 <_pipeisclosed+0xe>
	}
}
  801de8:	83 c4 2c             	add    $0x2c,%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	57                   	push   %edi
  801df4:	56                   	push   %esi
  801df5:	53                   	push   %ebx
  801df6:	83 ec 1c             	sub    $0x1c,%esp
  801df9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dfc:	89 34 24             	mov    %esi,(%esp)
  801dff:	e8 bc f6 ff ff       	call   8014c0 <fd2data>
  801e04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e06:	bf 00 00 00 00       	mov    $0x0,%edi
  801e0b:	eb 45                	jmp    801e52 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e0d:	89 da                	mov    %ebx,%edx
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	e8 71 ff ff ff       	call   801d87 <_pipeisclosed>
  801e16:	85 c0                	test   %eax,%eax
  801e18:	75 41                	jne    801e5b <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e1a:	e8 65 f0 ff ff       	call   800e84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e1f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e22:	8b 0b                	mov    (%ebx),%ecx
  801e24:	8d 51 20             	lea    0x20(%ecx),%edx
  801e27:	39 d0                	cmp    %edx,%eax
  801e29:	73 e2                	jae    801e0d <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e2e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e32:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e35:	99                   	cltd   
  801e36:	c1 ea 1b             	shr    $0x1b,%edx
  801e39:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e3c:	83 e1 1f             	and    $0x1f,%ecx
  801e3f:	29 d1                	sub    %edx,%ecx
  801e41:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e45:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801e49:	83 c0 01             	add    $0x1,%eax
  801e4c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e4f:	83 c7 01             	add    $0x1,%edi
  801e52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e55:	75 c8                	jne    801e1f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e57:	89 f8                	mov    %edi,%eax
  801e59:	eb 05                	jmp    801e60 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e60:	83 c4 1c             	add    $0x1c,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	57                   	push   %edi
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 1c             	sub    $0x1c,%esp
  801e71:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e74:	89 3c 24             	mov    %edi,(%esp)
  801e77:	e8 44 f6 ff ff       	call   8014c0 <fd2data>
  801e7c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7e:	be 00 00 00 00       	mov    $0x0,%esi
  801e83:	eb 3d                	jmp    801ec2 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e85:	85 f6                	test   %esi,%esi
  801e87:	74 04                	je     801e8d <devpipe_read+0x25>
				return i;
  801e89:	89 f0                	mov    %esi,%eax
  801e8b:	eb 43                	jmp    801ed0 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e8d:	89 da                	mov    %ebx,%edx
  801e8f:	89 f8                	mov    %edi,%eax
  801e91:	e8 f1 fe ff ff       	call   801d87 <_pipeisclosed>
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 31                	jne    801ecb <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e9a:	e8 e5 ef ff ff       	call   800e84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e9f:	8b 03                	mov    (%ebx),%eax
  801ea1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ea4:	74 df                	je     801e85 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ea6:	99                   	cltd   
  801ea7:	c1 ea 1b             	shr    $0x1b,%edx
  801eaa:	01 d0                	add    %edx,%eax
  801eac:	83 e0 1f             	and    $0x1f,%eax
  801eaf:	29 d0                	sub    %edx,%eax
  801eb1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eb9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ebc:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebf:	83 c6 01             	add    $0x1,%esi
  801ec2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec5:	75 d8                	jne    801e9f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ec7:	89 f0                	mov    %esi,%eax
  801ec9:	eb 05                	jmp    801ed0 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ed0:	83 c4 1c             	add    $0x1c,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee3:	89 04 24             	mov    %eax,(%esp)
  801ee6:	e8 ec f5 ff ff       	call   8014d7 <fd_alloc>
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	85 d2                	test   %edx,%edx
  801eef:	0f 88 4d 01 00 00    	js     802042 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801efc:	00 
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0b:	e8 93 ef ff ff       	call   800ea3 <sys_page_alloc>
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	85 d2                	test   %edx,%edx
  801f14:	0f 88 28 01 00 00    	js     802042 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 b2 f5 ff ff       	call   8014d7 <fd_alloc>
  801f25:	89 c3                	mov    %eax,%ebx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 fe 00 00 00    	js     80202d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f36:	00 
  801f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f45:	e8 59 ef ff ff       	call   800ea3 <sys_page_alloc>
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	0f 88 d9 00 00 00    	js     80202d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f57:	89 04 24             	mov    %eax,(%esp)
  801f5a:	e8 61 f5 ff ff       	call   8014c0 <fd2data>
  801f5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f61:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f68:	00 
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f74:	e8 2a ef ff ff       	call   800ea3 <sys_page_alloc>
  801f79:	89 c3                	mov    %eax,%ebx
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	0f 88 97 00 00 00    	js     80201a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 32 f5 ff ff       	call   8014c0 <fd2data>
  801f8e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f95:	00 
  801f96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fa1:	00 
  801fa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fad:	e8 45 ef ff ff       	call   800ef7 <sys_page_map>
  801fb2:	89 c3                	mov    %eax,%ebx
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	78 52                	js     80200a <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fb8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fcd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fdb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 c3 f4 ff ff       	call   8014b0 <fd2num>
  801fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 b3 f4 ff ff       	call   8014b0 <fd2num>
  801ffd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802000:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
  802008:	eb 38                	jmp    802042 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80200a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802015:	e8 30 ef ff ff       	call   800f4a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80201a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802028:	e8 1d ef ff ff       	call   800f4a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80202d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203b:	e8 0a ef ff ff       	call   800f4a <sys_page_unmap>
  802040:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802042:	83 c4 30             	add    $0x30,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	89 04 24             	mov    %eax,(%esp)
  80205c:	e8 c5 f4 ff ff       	call   801526 <fd_lookup>
  802061:	89 c2                	mov    %eax,%edx
  802063:	85 d2                	test   %edx,%edx
  802065:	78 15                	js     80207c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206a:	89 04 24             	mov    %eax,(%esp)
  80206d:	e8 4e f4 ff ff       	call   8014c0 <fd2data>
	return _pipeisclosed(fd, p);
  802072:	89 c2                	mov    %eax,%edx
  802074:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802077:	e8 0b fd ff ff       	call   801d87 <_pipeisclosed>
}
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax

00802080 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    

0080208a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802090:	c7 44 24 04 27 2e 80 	movl   $0x802e27,0x4(%esp)
  802097:	00 
  802098:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 e4 e9 ff ff       	call   800a87 <strcpy>
	return 0;
}
  8020a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	57                   	push   %edi
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
  8020b0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c1:	eb 31                	jmp    8020f4 <devcons_write+0x4a>
		m = n - tot;
  8020c3:	8b 75 10             	mov    0x10(%ebp),%esi
  8020c6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020c8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020cb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020d0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020d3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020d7:	03 45 0c             	add    0xc(%ebp),%eax
  8020da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020de:	89 3c 24             	mov    %edi,(%esp)
  8020e1:	e8 3e eb ff ff       	call   800c24 <memmove>
		sys_cputs(buf, m);
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	89 3c 24             	mov    %edi,(%esp)
  8020ed:	e8 e4 ec ff ff       	call   800dd6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f2:	01 f3                	add    %esi,%ebx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f9:	72 c8                	jb     8020c3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020fb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5f                   	pop    %edi
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80210c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802111:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802115:	75 07                	jne    80211e <devcons_read+0x18>
  802117:	eb 2a                	jmp    802143 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802119:	e8 66 ed ff ff       	call   800e84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80211e:	66 90                	xchg   %ax,%ax
  802120:	e8 cf ec ff ff       	call   800df4 <sys_cgetc>
  802125:	85 c0                	test   %eax,%eax
  802127:	74 f0                	je     802119 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 16                	js     802143 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80212d:	83 f8 04             	cmp    $0x4,%eax
  802130:	74 0c                	je     80213e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802132:	8b 55 0c             	mov    0xc(%ebp),%edx
  802135:	88 02                	mov    %al,(%edx)
	return 1;
  802137:	b8 01 00 00 00       	mov    $0x1,%eax
  80213c:	eb 05                	jmp    802143 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80213e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802143:	c9                   	leave  
  802144:	c3                   	ret    

00802145 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802151:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802158:	00 
  802159:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 72 ec ff ff       	call   800dd6 <sys_cputs>
}
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <getchar>:

int
getchar(void)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80216c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802173:	00 
  802174:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802182:	e8 2e f6 ff ff       	call   8017b5 <read>
	if (r < 0)
  802187:	85 c0                	test   %eax,%eax
  802189:	78 0f                	js     80219a <getchar+0x34>
		return r;
	if (r < 1)
  80218b:	85 c0                	test   %eax,%eax
  80218d:	7e 06                	jle    802195 <getchar+0x2f>
		return -E_EOF;
	return c;
  80218f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802193:	eb 05                	jmp    80219a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802195:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 72 f3 ff ff       	call   801526 <fd_lookup>
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 11                	js     8021c9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c1:	39 10                	cmp    %edx,(%eax)
  8021c3:	0f 94 c0             	sete   %al
  8021c6:	0f b6 c0             	movzbl %al,%eax
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <opencons>:

int
opencons(void)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d4:	89 04 24             	mov    %eax,(%esp)
  8021d7:	e8 fb f2 ff ff       	call   8014d7 <fd_alloc>
		return r;
  8021dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 40                	js     802222 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e9:	00 
  8021ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f8:	e8 a6 ec ff ff       	call   800ea3 <sys_page_alloc>
		return r;
  8021fd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 1f                	js     802222 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802203:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80220e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802211:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802218:	89 04 24             	mov    %eax,(%esp)
  80221b:	e8 90 f2 ff ff       	call   8014b0 <fd2num>
  802220:	89 c2                	mov    %eax,%edx
}
  802222:	89 d0                	mov    %edx,%eax
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80222c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802233:	75 44                	jne    802279 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  802235:	a1 04 40 80 00       	mov    0x804004,%eax
  80223a:	8b 40 48             	mov    0x48(%eax),%eax
  80223d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802244:	00 
  802245:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80224c:	ee 
  80224d:	89 04 24             	mov    %eax,(%esp)
  802250:	e8 4e ec ff ff       	call   800ea3 <sys_page_alloc>
		if( r < 0)
  802255:	85 c0                	test   %eax,%eax
  802257:	79 20                	jns    802279 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	c7 44 24 08 34 2e 80 	movl   $0x802e34,0x8(%esp)
  802264:	00 
  802265:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80226c:	00 
  80226d:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  802274:	e8 a0 e0 ff ff       	call   800319 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802279:	8b 45 08             	mov    0x8(%ebp),%eax
  80227c:	a3 00 60 80 00       	mov    %eax,0x806000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  802281:	e8 df eb ff ff       	call   800e65 <sys_getenvid>
  802286:	c7 44 24 04 bc 22 80 	movl   $0x8022bc,0x4(%esp)
  80228d:	00 
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 ad ed ff ff       	call   801043 <sys_env_set_pgfault_upcall>
  802296:	85 c0                	test   %eax,%eax
  802298:	79 20                	jns    8022ba <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80229a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229e:	c7 44 24 08 64 2e 80 	movl   $0x802e64,0x8(%esp)
  8022a5:	00 
  8022a6:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8022ad:	00 
  8022ae:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  8022b5:	e8 5f e0 ff ff       	call   800319 <_panic>


}
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    

008022bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022bd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022c4:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8022c7:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8022cb:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8022cf:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8022d3:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8022d6:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8022d9:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8022dc:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8022e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8022e4:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8022e8:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8022ec:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8022f0:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8022f4:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8022f8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  8022f9:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  8022fa:	c3                   	ret    
  8022fb:	66 90                	xchg   %ax,%ax
  8022fd:	66 90                	xchg   %ax,%ax
  8022ff:	90                   	nop

00802300 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	56                   	push   %esi
  802304:	53                   	push   %ebx
  802305:	83 ec 10             	sub    $0x10,%esp
  802308:	8b 75 08             	mov    0x8(%ebp),%esi
  80230b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802311:	85 c0                	test   %eax,%eax
  802313:	75 0e                	jne    802323 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802315:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80231c:	e8 98 ed ff ff       	call   8010b9 <sys_ipc_recv>
  802321:	eb 08                	jmp    80232b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802323:	89 04 24             	mov    %eax,(%esp)
  802326:	e8 8e ed ff ff       	call   8010b9 <sys_ipc_recv>
	if(r == 0){
  80232b:	85 c0                	test   %eax,%eax
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	75 1e                	jne    802350 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802332:	85 f6                	test   %esi,%esi
  802334:	74 0a                	je     802340 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802336:	a1 04 40 80 00       	mov    0x804004,%eax
  80233b:	8b 40 74             	mov    0x74(%eax),%eax
  80233e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802340:	85 db                	test   %ebx,%ebx
  802342:	74 2c                	je     802370 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802344:	a1 04 40 80 00       	mov    0x804004,%eax
  802349:	8b 40 78             	mov    0x78(%eax),%eax
  80234c:	89 03                	mov    %eax,(%ebx)
  80234e:	eb 20                	jmp    802370 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802350:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802354:	c7 44 24 08 a0 2e 80 	movl   $0x802ea0,0x8(%esp)
  80235b:	00 
  80235c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802363:	00 
  802364:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  80236b:	e8 a9 df ff ff       	call   800319 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802370:	a1 04 40 80 00       	mov    0x804004,%eax
  802375:	8b 50 70             	mov    0x70(%eax),%edx
  802378:	85 d2                	test   %edx,%edx
  80237a:	75 13                	jne    80238f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80237c:	8b 40 48             	mov    0x48(%eax),%eax
  80237f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802383:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  80238a:	e8 83 e0 ff ff       	call   800412 <cprintf>
	return thisenv->env_ipc_value;
  80238f:	a1 04 40 80 00       	mov    0x804004,%eax
  802394:	8b 40 70             	mov    0x70(%eax),%eax
}
  802397:	83 c4 10             	add    $0x10,%esp
  80239a:	5b                   	pop    %ebx
  80239b:	5e                   	pop    %esi
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    

0080239e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023aa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8023ad:	85 f6                	test   %esi,%esi
  8023af:	75 22                	jne    8023d3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8023b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8023b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023b8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8023bf:	ee 
  8023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c7:	89 3c 24             	mov    %edi,(%esp)
  8023ca:	e8 c7 ec ff ff       	call   801096 <sys_ipc_try_send>
  8023cf:	89 c3                	mov    %eax,%ebx
  8023d1:	eb 1c                	jmp    8023ef <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8023d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023da:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e5:	89 3c 24             	mov    %edi,(%esp)
  8023e8:	e8 a9 ec ff ff       	call   801096 <sys_ipc_try_send>
  8023ed:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8023ef:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8023f2:	74 3e                	je     802432 <ipc_send+0x94>
  8023f4:	89 d8                	mov    %ebx,%eax
  8023f6:	c1 e8 1f             	shr    $0x1f,%eax
  8023f9:	84 c0                	test   %al,%al
  8023fb:	74 35                	je     802432 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  8023fd:	e8 63 ea ff ff       	call   800e65 <sys_getenvid>
  802402:	89 44 24 04          	mov    %eax,0x4(%esp)
  802406:	c7 04 24 26 2f 80 00 	movl   $0x802f26,(%esp)
  80240d:	e8 00 e0 ff ff       	call   800412 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802412:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802416:	c7 44 24 08 f4 2e 80 	movl   $0x802ef4,0x8(%esp)
  80241d:	00 
  80241e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802425:	00 
  802426:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  80242d:	e8 e7 de ff ff       	call   800319 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802432:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802435:	75 0e                	jne    802445 <ipc_send+0xa7>
			sys_yield();
  802437:	e8 48 ea ff ff       	call   800e84 <sys_yield>
		else break;
	}
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	e9 68 ff ff ff       	jmp    8023ad <ipc_send+0xf>
	
}
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    

0080244d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80244d:	55                   	push   %ebp
  80244e:	89 e5                	mov    %esp,%ebp
  802450:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802453:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802458:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80245b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802461:	8b 52 50             	mov    0x50(%edx),%edx
  802464:	39 ca                	cmp    %ecx,%edx
  802466:	75 0d                	jne    802475 <ipc_find_env+0x28>
			return envs[i].env_id;
  802468:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80246b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802470:	8b 40 40             	mov    0x40(%eax),%eax
  802473:	eb 0e                	jmp    802483 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802475:	83 c0 01             	add    $0x1,%eax
  802478:	3d 00 04 00 00       	cmp    $0x400,%eax
  80247d:	75 d9                	jne    802458 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80247f:	66 b8 00 00          	mov    $0x0,%ax
}
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    

00802485 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248b:	89 d0                	mov    %edx,%eax
  80248d:	c1 e8 16             	shr    $0x16,%eax
  802490:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802497:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249c:	f6 c1 01             	test   $0x1,%cl
  80249f:	74 1d                	je     8024be <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024a1:	c1 ea 0c             	shr    $0xc,%edx
  8024a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024ab:	f6 c2 01             	test   $0x1,%dl
  8024ae:	74 0e                	je     8024be <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024b0:	c1 ea 0c             	shr    $0xc,%edx
  8024b3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ba:	ef 
  8024bb:	0f b7 c0             	movzwl %ax,%eax
}
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	83 ec 0c             	sub    $0xc,%esp
  8024c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8024ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8024ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8024d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024dc:	89 ea                	mov    %ebp,%edx
  8024de:	89 0c 24             	mov    %ecx,(%esp)
  8024e1:	75 2d                	jne    802510 <__udivdi3+0x50>
  8024e3:	39 e9                	cmp    %ebp,%ecx
  8024e5:	77 61                	ja     802548 <__udivdi3+0x88>
  8024e7:	85 c9                	test   %ecx,%ecx
  8024e9:	89 ce                	mov    %ecx,%esi
  8024eb:	75 0b                	jne    8024f8 <__udivdi3+0x38>
  8024ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f2:	31 d2                	xor    %edx,%edx
  8024f4:	f7 f1                	div    %ecx
  8024f6:	89 c6                	mov    %eax,%esi
  8024f8:	31 d2                	xor    %edx,%edx
  8024fa:	89 e8                	mov    %ebp,%eax
  8024fc:	f7 f6                	div    %esi
  8024fe:	89 c5                	mov    %eax,%ebp
  802500:	89 f8                	mov    %edi,%eax
  802502:	f7 f6                	div    %esi
  802504:	89 ea                	mov    %ebp,%edx
  802506:	83 c4 0c             	add    $0xc,%esp
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    
  80250d:	8d 76 00             	lea    0x0(%esi),%esi
  802510:	39 e8                	cmp    %ebp,%eax
  802512:	77 24                	ja     802538 <__udivdi3+0x78>
  802514:	0f bd e8             	bsr    %eax,%ebp
  802517:	83 f5 1f             	xor    $0x1f,%ebp
  80251a:	75 3c                	jne    802558 <__udivdi3+0x98>
  80251c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802520:	39 34 24             	cmp    %esi,(%esp)
  802523:	0f 86 9f 00 00 00    	jbe    8025c8 <__udivdi3+0x108>
  802529:	39 d0                	cmp    %edx,%eax
  80252b:	0f 82 97 00 00 00    	jb     8025c8 <__udivdi3+0x108>
  802531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802538:	31 d2                	xor    %edx,%edx
  80253a:	31 c0                	xor    %eax,%eax
  80253c:	83 c4 0c             	add    $0xc,%esp
  80253f:	5e                   	pop    %esi
  802540:	5f                   	pop    %edi
  802541:	5d                   	pop    %ebp
  802542:	c3                   	ret    
  802543:	90                   	nop
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	89 f8                	mov    %edi,%eax
  80254a:	f7 f1                	div    %ecx
  80254c:	31 d2                	xor    %edx,%edx
  80254e:	83 c4 0c             	add    $0xc,%esp
  802551:	5e                   	pop    %esi
  802552:	5f                   	pop    %edi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    
  802555:	8d 76 00             	lea    0x0(%esi),%esi
  802558:	89 e9                	mov    %ebp,%ecx
  80255a:	8b 3c 24             	mov    (%esp),%edi
  80255d:	d3 e0                	shl    %cl,%eax
  80255f:	89 c6                	mov    %eax,%esi
  802561:	b8 20 00 00 00       	mov    $0x20,%eax
  802566:	29 e8                	sub    %ebp,%eax
  802568:	89 c1                	mov    %eax,%ecx
  80256a:	d3 ef                	shr    %cl,%edi
  80256c:	89 e9                	mov    %ebp,%ecx
  80256e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802572:	8b 3c 24             	mov    (%esp),%edi
  802575:	09 74 24 08          	or     %esi,0x8(%esp)
  802579:	89 d6                	mov    %edx,%esi
  80257b:	d3 e7                	shl    %cl,%edi
  80257d:	89 c1                	mov    %eax,%ecx
  80257f:	89 3c 24             	mov    %edi,(%esp)
  802582:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802586:	d3 ee                	shr    %cl,%esi
  802588:	89 e9                	mov    %ebp,%ecx
  80258a:	d3 e2                	shl    %cl,%edx
  80258c:	89 c1                	mov    %eax,%ecx
  80258e:	d3 ef                	shr    %cl,%edi
  802590:	09 d7                	or     %edx,%edi
  802592:	89 f2                	mov    %esi,%edx
  802594:	89 f8                	mov    %edi,%eax
  802596:	f7 74 24 08          	divl   0x8(%esp)
  80259a:	89 d6                	mov    %edx,%esi
  80259c:	89 c7                	mov    %eax,%edi
  80259e:	f7 24 24             	mull   (%esp)
  8025a1:	39 d6                	cmp    %edx,%esi
  8025a3:	89 14 24             	mov    %edx,(%esp)
  8025a6:	72 30                	jb     8025d8 <__udivdi3+0x118>
  8025a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025ac:	89 e9                	mov    %ebp,%ecx
  8025ae:	d3 e2                	shl    %cl,%edx
  8025b0:	39 c2                	cmp    %eax,%edx
  8025b2:	73 05                	jae    8025b9 <__udivdi3+0xf9>
  8025b4:	3b 34 24             	cmp    (%esp),%esi
  8025b7:	74 1f                	je     8025d8 <__udivdi3+0x118>
  8025b9:	89 f8                	mov    %edi,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	e9 7a ff ff ff       	jmp    80253c <__udivdi3+0x7c>
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cf:	e9 68 ff ff ff       	jmp    80253c <__udivdi3+0x7c>
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	83 c4 0c             	add    $0xc,%esp
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	83 ec 14             	sub    $0x14,%esp
  8025f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8025fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8025fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802602:	89 c7                	mov    %eax,%edi
  802604:	89 44 24 04          	mov    %eax,0x4(%esp)
  802608:	8b 44 24 30          	mov    0x30(%esp),%eax
  80260c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802610:	89 34 24             	mov    %esi,(%esp)
  802613:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802617:	85 c0                	test   %eax,%eax
  802619:	89 c2                	mov    %eax,%edx
  80261b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80261f:	75 17                	jne    802638 <__umoddi3+0x48>
  802621:	39 fe                	cmp    %edi,%esi
  802623:	76 4b                	jbe    802670 <__umoddi3+0x80>
  802625:	89 c8                	mov    %ecx,%eax
  802627:	89 fa                	mov    %edi,%edx
  802629:	f7 f6                	div    %esi
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	31 d2                	xor    %edx,%edx
  80262f:	83 c4 14             	add    $0x14,%esp
  802632:	5e                   	pop    %esi
  802633:	5f                   	pop    %edi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    
  802636:	66 90                	xchg   %ax,%ax
  802638:	39 f8                	cmp    %edi,%eax
  80263a:	77 54                	ja     802690 <__umoddi3+0xa0>
  80263c:	0f bd e8             	bsr    %eax,%ebp
  80263f:	83 f5 1f             	xor    $0x1f,%ebp
  802642:	75 5c                	jne    8026a0 <__umoddi3+0xb0>
  802644:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802648:	39 3c 24             	cmp    %edi,(%esp)
  80264b:	0f 87 e7 00 00 00    	ja     802738 <__umoddi3+0x148>
  802651:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802655:	29 f1                	sub    %esi,%ecx
  802657:	19 c7                	sbb    %eax,%edi
  802659:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802661:	8b 44 24 08          	mov    0x8(%esp),%eax
  802665:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802669:	83 c4 14             	add    $0x14,%esp
  80266c:	5e                   	pop    %esi
  80266d:	5f                   	pop    %edi
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    
  802670:	85 f6                	test   %esi,%esi
  802672:	89 f5                	mov    %esi,%ebp
  802674:	75 0b                	jne    802681 <__umoddi3+0x91>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f6                	div    %esi
  80267f:	89 c5                	mov    %eax,%ebp
  802681:	8b 44 24 04          	mov    0x4(%esp),%eax
  802685:	31 d2                	xor    %edx,%edx
  802687:	f7 f5                	div    %ebp
  802689:	89 c8                	mov    %ecx,%eax
  80268b:	f7 f5                	div    %ebp
  80268d:	eb 9c                	jmp    80262b <__umoddi3+0x3b>
  80268f:	90                   	nop
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 fa                	mov    %edi,%edx
  802694:	83 c4 14             	add    $0x14,%esp
  802697:	5e                   	pop    %esi
  802698:	5f                   	pop    %edi
  802699:	5d                   	pop    %ebp
  80269a:	c3                   	ret    
  80269b:	90                   	nop
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	8b 04 24             	mov    (%esp),%eax
  8026a3:	be 20 00 00 00       	mov    $0x20,%esi
  8026a8:	89 e9                	mov    %ebp,%ecx
  8026aa:	29 ee                	sub    %ebp,%esi
  8026ac:	d3 e2                	shl    %cl,%edx
  8026ae:	89 f1                	mov    %esi,%ecx
  8026b0:	d3 e8                	shr    %cl,%eax
  8026b2:	89 e9                	mov    %ebp,%ecx
  8026b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b8:	8b 04 24             	mov    (%esp),%eax
  8026bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	d3 e0                	shl    %cl,%eax
  8026c3:	89 f1                	mov    %esi,%ecx
  8026c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8026cd:	d3 ea                	shr    %cl,%edx
  8026cf:	89 e9                	mov    %ebp,%ecx
  8026d1:	d3 e7                	shl    %cl,%edi
  8026d3:	89 f1                	mov    %esi,%ecx
  8026d5:	d3 e8                	shr    %cl,%eax
  8026d7:	89 e9                	mov    %ebp,%ecx
  8026d9:	09 f8                	or     %edi,%eax
  8026db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8026df:	f7 74 24 04          	divl   0x4(%esp)
  8026e3:	d3 e7                	shl    %cl,%edi
  8026e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026e9:	89 d7                	mov    %edx,%edi
  8026eb:	f7 64 24 08          	mull   0x8(%esp)
  8026ef:	39 d7                	cmp    %edx,%edi
  8026f1:	89 c1                	mov    %eax,%ecx
  8026f3:	89 14 24             	mov    %edx,(%esp)
  8026f6:	72 2c                	jb     802724 <__umoddi3+0x134>
  8026f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8026fc:	72 22                	jb     802720 <__umoddi3+0x130>
  8026fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802702:	29 c8                	sub    %ecx,%eax
  802704:	19 d7                	sbb    %edx,%edi
  802706:	89 e9                	mov    %ebp,%ecx
  802708:	89 fa                	mov    %edi,%edx
  80270a:	d3 e8                	shr    %cl,%eax
  80270c:	89 f1                	mov    %esi,%ecx
  80270e:	d3 e2                	shl    %cl,%edx
  802710:	89 e9                	mov    %ebp,%ecx
  802712:	d3 ef                	shr    %cl,%edi
  802714:	09 d0                	or     %edx,%eax
  802716:	89 fa                	mov    %edi,%edx
  802718:	83 c4 14             	add    $0x14,%esp
  80271b:	5e                   	pop    %esi
  80271c:	5f                   	pop    %edi
  80271d:	5d                   	pop    %ebp
  80271e:	c3                   	ret    
  80271f:	90                   	nop
  802720:	39 d7                	cmp    %edx,%edi
  802722:	75 da                	jne    8026fe <__umoddi3+0x10e>
  802724:	8b 14 24             	mov    (%esp),%edx
  802727:	89 c1                	mov    %eax,%ecx
  802729:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80272d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802731:	eb cb                	jmp    8026fe <__umoddi3+0x10e>
  802733:	90                   	nop
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80273c:	0f 82 0f ff ff ff    	jb     802651 <__umoddi3+0x61>
  802742:	e9 1a ff ff ff       	jmp    802661 <__umoddi3+0x71>
