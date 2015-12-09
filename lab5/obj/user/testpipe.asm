
obj/user/testpipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 e4 02 00 00       	call   800315 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 40 80 00 20 	movl   $0x802820,0x804004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e8 1e 00 00       	call   801f38 <pipe>
  800050:	89 c6                	mov    %eax,%esi
  800052:	85 c0                	test   %eax,%eax
  800054:	79 20                	jns    800076 <umain+0x43>
		panic("pipe: %e", i);
  800056:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005a:	c7 44 24 08 2c 28 80 	movl   $0x80282c,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  800071:	e8 fb 02 00 00       	call   800371 <_panic>

	if ((pid = fork()) < 0)
  800076:	e8 5a 12 00 00       	call   8012d5 <fork>
  80007b:	89 c3                	mov    %eax,%ebx
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <umain+0x6e>
		panic("fork: %e", i);
  800081:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800085:	c7 44 24 08 45 28 80 	movl   $0x802845,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  80009c:	e8 d0 02 00 00       	call   800371 <_panic>

	if (pid == 0) {
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	0f 85 d5 00 00 00    	jne    80017e <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000a9:	a1 04 50 80 00       	mov    0x805004,%eax
  8000ae:	8b 40 48             	mov    0x48(%eax),%eax
  8000b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bc:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  8000c3:	e8 a2 03 00 00       	call   80046a <cprintf>
		close(p[1]);
  8000c8:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cb:	89 04 24             	mov    %eax,(%esp)
  8000ce:	e8 df 15 00 00       	call   8016b2 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d3:	a1 04 50 80 00       	mov    0x805004,%eax
  8000d8:	8b 40 48             	mov    0x48(%eax),%eax
  8000db:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e6:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  8000ed:	e8 78 03 00 00       	call   80046a <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f2:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000f9:	00 
  8000fa:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800104:	89 04 24             	mov    %eax,(%esp)
  800107:	e8 9b 17 00 00       	call   8018a7 <readn>
  80010c:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	79 20                	jns    800132 <umain+0xff>
			panic("read: %e", i);
  800112:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800116:	c7 44 24 08 88 28 80 	movl   $0x802888,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  80012d:	e8 3f 02 00 00       	call   800371 <_panic>
		buf[i] = 0;
  800132:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800137:	a1 00 40 80 00       	mov    0x804000,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 51 0a 00 00       	call   800b9c <strcmp>
  80014b:	85 c0                	test   %eax,%eax
  80014d:	75 0e                	jne    80015d <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  80014f:	c7 04 24 91 28 80 00 	movl   $0x802891,(%esp)
  800156:	e8 0f 03 00 00       	call   80046a <cprintf>
  80015b:	eb 17                	jmp    800174 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800160:	89 44 24 08          	mov    %eax,0x8(%esp)
  800164:	89 74 24 04          	mov    %esi,0x4(%esp)
  800168:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  80016f:	e8 f6 02 00 00       	call   80046a <cprintf>
		exit();
  800174:	e8 e4 01 00 00       	call   80035d <exit>
  800179:	e9 ac 00 00 00       	jmp    80022a <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017e:	a1 04 50 80 00       	mov    0x805004,%eax
  800183:	8b 40 48             	mov    0x48(%eax),%eax
  800186:	8b 55 8c             	mov    -0x74(%ebp),%edx
  800189:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	c7 04 24 4e 28 80 00 	movl   $0x80284e,(%esp)
  800198:	e8 cd 02 00 00       	call   80046a <cprintf>
		close(p[0]);
  80019d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 0a 15 00 00       	call   8016b2 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a8:	a1 04 50 80 00       	mov    0x805004,%eax
  8001ad:	8b 40 48             	mov    0x48(%eax),%eax
  8001b0:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 c0 28 80 00 	movl   $0x8028c0,(%esp)
  8001c2:	e8 a3 02 00 00       	call   80046a <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c7:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 dc 08 00 00       	call   800ab0 <strlen>
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 06 17 00 00       	call   8018f2 <write>
  8001ec:	89 c6                	mov    %eax,%esi
  8001ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 b5 08 00 00       	call   800ab0 <strlen>
  8001fb:	39 c6                	cmp    %eax,%esi
  8001fd:	74 20                	je     80021f <umain+0x1ec>
			panic("write: %e", i);
  8001ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800203:	c7 44 24 08 dd 28 80 	movl   $0x8028dd,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800212:	00 
  800213:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  80021a:	e8 52 01 00 00       	call   800371 <_panic>
		close(p[1]);
  80021f:	8b 45 90             	mov    -0x70(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 88 14 00 00       	call   8016b2 <close>
	}
	wait(pid);
  80022a:	89 1c 24             	mov    %ebx,(%esp)
  80022d:	e8 ac 1e 00 00       	call   8020de <wait>

	binaryname = "pipewriteeof";
  800232:	c7 05 04 40 80 00 e7 	movl   $0x8028e7,0x804004
  800239:	28 80 00 
	if ((i = pipe(p)) < 0)
  80023c:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 f1 1c 00 00       	call   801f38 <pipe>
  800247:	89 c6                	mov    %eax,%esi
  800249:	85 c0                	test   %eax,%eax
  80024b:	79 20                	jns    80026d <umain+0x23a>
		panic("pipe: %e", i);
  80024d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800251:	c7 44 24 08 2c 28 80 	movl   $0x80282c,0x8(%esp)
  800258:	00 
  800259:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800260:	00 
  800261:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  800268:	e8 04 01 00 00       	call   800371 <_panic>

	if ((pid = fork()) < 0)
  80026d:	e8 63 10 00 00       	call   8012d5 <fork>
  800272:	89 c3                	mov    %eax,%ebx
  800274:	85 c0                	test   %eax,%eax
  800276:	79 20                	jns    800298 <umain+0x265>
		panic("fork: %e", i);
  800278:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027c:	c7 44 24 08 45 28 80 	movl   $0x802845,0x8(%esp)
  800283:	00 
  800284:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028b:	00 
  80028c:	c7 04 24 35 28 80 00 	movl   $0x802835,(%esp)
  800293:	e8 d9 00 00 00       	call   800371 <_panic>

	if (pid == 0) {
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 48                	jne    8002e4 <umain+0x2b1>
		close(p[0]);
  80029c:	8b 45 8c             	mov    -0x74(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 0b 14 00 00       	call   8016b2 <close>
		while (1) {
			cprintf(".");
  8002a7:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  8002ae:	e8 b7 01 00 00       	call   80046a <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002ba:	00 
  8002bb:	c7 44 24 04 f6 28 80 	movl   $0x8028f6,0x4(%esp)
  8002c2:	00 
  8002c3:	8b 55 90             	mov    -0x70(%ebp),%edx
  8002c6:	89 14 24             	mov    %edx,(%esp)
  8002c9:	e8 24 16 00 00       	call   8018f2 <write>
  8002ce:	83 f8 01             	cmp    $0x1,%eax
  8002d1:	74 d4                	je     8002a7 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d3:	c7 04 24 f8 28 80 00 	movl   $0x8028f8,(%esp)
  8002da:	e8 8b 01 00 00       	call   80046a <cprintf>
		exit();
  8002df:	e8 79 00 00 00       	call   80035d <exit>
	}
	close(p[0]);
  8002e4:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	e8 c3 13 00 00       	call   8016b2 <close>
	close(p[1]);
  8002ef:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	e8 b8 13 00 00       	call   8016b2 <close>
	wait(pid);
  8002fa:	89 1c 24             	mov    %ebx,(%esp)
  8002fd:	e8 dc 1d 00 00       	call   8020de <wait>

	cprintf("pipe tests passed\n");
  800302:	c7 04 24 15 29 80 00 	movl   $0x802915,(%esp)
  800309:	e8 5c 01 00 00       	call   80046a <cprintf>
}
  80030e:	83 ec 80             	sub    $0xffffff80,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 10             	sub    $0x10,%esp
  80031d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800320:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800323:	e8 9d 0b 00 00       	call   800ec5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800328:	25 ff 03 00 00       	and    $0x3ff,%eax
  80032d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800330:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800335:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80033a:	85 db                	test   %ebx,%ebx
  80033c:	7e 07                	jle    800345 <libmain+0x30>
		binaryname = argv[0];
  80033e:	8b 06                	mov    (%esi),%eax
  800340:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800345:	89 74 24 04          	mov    %esi,0x4(%esp)
  800349:	89 1c 24             	mov    %ebx,(%esp)
  80034c:	e8 e2 fc ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800351:	e8 07 00 00 00       	call   80035d <exit>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800363:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80036a:	e8 04 0b 00 00       	call   800e73 <sys_env_destroy>
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800379:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80037c:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800382:	e8 3e 0b 00 00       	call   800ec5 <sys_getenvid>
  800387:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800395:	89 74 24 08          	mov    %esi,0x8(%esp)
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	c7 04 24 78 29 80 00 	movl   $0x802978,(%esp)
  8003a4:	e8 c1 00 00 00       	call   80046a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 51 00 00 00       	call   800409 <vcprintf>
	cprintf("\n");
  8003b8:	c7 04 24 69 28 80 00 	movl   $0x802869,(%esp)
  8003bf:	e8 a6 00 00 00       	call   80046a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c4:	cc                   	int3   
  8003c5:	eb fd                	jmp    8003c4 <_panic+0x53>

008003c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 14             	sub    $0x14,%esp
  8003ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d1:	8b 13                	mov    (%ebx),%edx
  8003d3:	8d 42 01             	lea    0x1(%edx),%eax
  8003d6:	89 03                	mov    %eax,(%ebx)
  8003d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e4:	75 19                	jne    8003ff <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003e6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ed:	00 
  8003ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	e8 3d 0a 00 00       	call   800e36 <sys_cputs>
		b->idx = 0;
  8003f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800403:	83 c4 14             	add    $0x14,%esp
  800406:	5b                   	pop    %ebx
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800412:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800419:	00 00 00 
	b.cnt = 0;
  80041c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800423:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800426:	8b 45 0c             	mov    0xc(%ebp),%eax
  800429:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042d:	8b 45 08             	mov    0x8(%ebp),%eax
  800430:	89 44 24 08          	mov    %eax,0x8(%esp)
  800434:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043e:	c7 04 24 c7 03 80 00 	movl   $0x8003c7,(%esp)
  800445:	e8 7a 01 00 00       	call   8005c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045a:	89 04 24             	mov    %eax,(%esp)
  80045d:	e8 d4 09 00 00       	call   800e36 <sys_cputs>

	return b.cnt;
}
  800462:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800470:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800473:	89 44 24 04          	mov    %eax,0x4(%esp)
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	89 04 24             	mov    %eax,(%esp)
  80047d:	e8 87 ff ff ff       	call   800409 <vcprintf>
	va_end(ap);

	return cnt;
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    
  800484:	66 90                	xchg   %ax,%ax
  800486:	66 90                	xchg   %ax,%ax
  800488:	66 90                	xchg   %ax,%ax
  80048a:	66 90                	xchg   %ax,%ax
  80048c:	66 90                	xchg   %ax,%ax
  80048e:	66 90                	xchg   %ax,%ax

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004bd:	39 d9                	cmp    %ebx,%ecx
  8004bf:	72 05                	jb     8004c6 <printnum+0x36>
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	77 69                	ja     80052f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	89 d6                	mov    %edx,%esi
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 7c 20 00 00       	call   802580 <__udivdi3>
  800504:	89 d9                	mov    %ebx,%ecx
  800506:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 71 ff ff ff       	call   800490 <printnum>
  80051f:	eb 1b                	jmp    80053c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	8b 45 18             	mov    0x18(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d3                	call   *%ebx
  80052d:	eb 03                	jmp    800532 <printnum+0xa2>
  80052f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	85 f6                	test   %esi,%esi
  800537:	7f e8                	jg     800521 <printnum+0x91>
  800539:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 4c 21 00 00       	call   8026b0 <__umoddi3>
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	0f be 80 9b 29 80 00 	movsbl 0x80299b(%eax),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800575:	ff d0                	call   *%eax
}
  800577:	83 c4 3c             	add    $0x3c,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800585:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	3b 50 04             	cmp    0x4(%eax),%edx
  80058e:	73 0a                	jae    80059a <sprintputch+0x1b>
		*b->buf++ = ch;
  800590:	8d 4a 01             	lea    0x1(%edx),%ecx
  800593:	89 08                	mov    %ecx,(%eax)
  800595:	8b 45 08             	mov    0x8(%ebp),%eax
  800598:	88 02                	mov    %al,(%edx)
}
  80059a:	5d                   	pop    %ebp
  80059b:	c3                   	ret    

0080059c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	e8 02 00 00 00       	call   8005c4 <vprintfmt>
	va_end(ap);
}
  8005c2:	c9                   	leave  
  8005c3:	c3                   	ret    

008005c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	57                   	push   %edi
  8005c8:	56                   	push   %esi
  8005c9:	53                   	push   %ebx
  8005ca:	83 ec 3c             	sub    $0x3c,%esp
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005d6:	eb 11                	jmp    8005e9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	0f 84 48 04 00 00    	je     800a28 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005e9:	83 c7 01             	add    $0x1,%edi
  8005ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f0:	83 f8 25             	cmp    $0x25,%eax
  8005f3:	75 e3                	jne    8005d8 <vprintfmt+0x14>
  8005f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800600:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800607:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	eb 1f                	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800618:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80061c:	eb 16                	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800621:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800625:	eb 0d                	jmp    800634 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800627:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8d 47 01             	lea    0x1(%edi),%eax
  800637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063a:	0f b6 17             	movzbl (%edi),%edx
  80063d:	0f b6 c2             	movzbl %dl,%eax
  800640:	83 ea 23             	sub    $0x23,%edx
  800643:	80 fa 55             	cmp    $0x55,%dl
  800646:	0f 87 bf 03 00 00    	ja     800a0b <vprintfmt+0x447>
  80064c:	0f b6 d2             	movzbl %dl,%edx
  80064f:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
  80065e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800661:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800664:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800668:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80066b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80066e:	83 f9 09             	cmp    $0x9,%ecx
  800671:	77 3c                	ja     8006af <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800673:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800676:	eb e9                	jmp    800661 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068c:	eb 27                	jmp    8006b5 <vprintfmt+0xf1>
  80068e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	0f 49 c2             	cmovns %edx,%eax
  80069b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	eb 91                	jmp    800634 <vprintfmt+0x70>
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006ad:	eb 85                	jmp    800634 <vprintfmt+0x70>
  8006af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b9:	0f 89 75 ff ff ff    	jns    800634 <vprintfmt+0x70>
  8006bf:	e9 63 ff ff ff       	jmp    800627 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ca:	e9 65 ff ff ff       	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e4:	e9 00 ff ff ff       	jmp    8005e9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ec:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	99                   	cltd   
  8006f3:	31 d0                	xor    %edx,%eax
  8006f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f7:	83 f8 0f             	cmp    $0xf,%eax
  8006fa:	7f 0b                	jg     800707 <vprintfmt+0x143>
  8006fc:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800703:	85 d2                	test   %edx,%edx
  800705:	75 20                	jne    800727 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800707:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070b:	c7 44 24 08 b3 29 80 	movl   $0x8029b3,0x8(%esp)
  800712:	00 
  800713:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800717:	89 34 24             	mov    %esi,(%esp)
  80071a:	e8 7d fe ff ff       	call   80059c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800722:	e9 c2 fe ff ff       	jmp    8005e9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800727:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072b:	c7 44 24 08 5e 2f 80 	movl   $0x802f5e,0x8(%esp)
  800732:	00 
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	89 34 24             	mov    %esi,(%esp)
  80073a:	e8 5d fe ff ff       	call   80059c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	e9 a2 fe ff ff       	jmp    8005e9 <vprintfmt+0x25>
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800757:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800759:	85 ff                	test   %edi,%edi
  80075b:	b8 ac 29 80 00       	mov    $0x8029ac,%eax
  800760:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800763:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800767:	0f 84 92 00 00 00    	je     8007ff <vprintfmt+0x23b>
  80076d:	85 c9                	test   %ecx,%ecx
  80076f:	0f 8e 98 00 00 00    	jle    80080d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	89 3c 24             	mov    %edi,(%esp)
  80077c:	e8 47 03 00 00       	call   800ac8 <strnlen>
  800781:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800784:	29 c1                	sub    %eax,%ecx
  800786:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800789:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800790:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800793:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800795:	eb 0f                	jmp    8007a6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	85 ff                	test   %edi,%edi
  8007a8:	7f ed                	jg     800797 <vprintfmt+0x1d3>
  8007aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007b0:	85 c9                	test   %ecx,%ecx
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	0f 49 c1             	cmovns %ecx,%eax
  8007ba:	29 c1                	sub    %eax,%ecx
  8007bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c5:	89 cb                	mov    %ecx,%ebx
  8007c7:	eb 50                	jmp    800819 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007cd:	74 1e                	je     8007ed <vprintfmt+0x229>
  8007cf:	0f be d2             	movsbl %dl,%edx
  8007d2:	83 ea 20             	sub    $0x20,%edx
  8007d5:	83 fa 5e             	cmp    $0x5e,%edx
  8007d8:	76 13                	jbe    8007ed <vprintfmt+0x229>
					putch('?', putdat);
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
  8007eb:	eb 0d                	jmp    8007fa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fa:	83 eb 01             	sub    $0x1,%ebx
  8007fd:	eb 1a                	jmp    800819 <vprintfmt+0x255>
  8007ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800802:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800805:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800808:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80080b:	eb 0c                	jmp    800819 <vprintfmt+0x255>
  80080d:	89 75 08             	mov    %esi,0x8(%ebp)
  800810:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800813:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800816:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800819:	83 c7 01             	add    $0x1,%edi
  80081c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800820:	0f be c2             	movsbl %dl,%eax
  800823:	85 c0                	test   %eax,%eax
  800825:	74 25                	je     80084c <vprintfmt+0x288>
  800827:	85 f6                	test   %esi,%esi
  800829:	78 9e                	js     8007c9 <vprintfmt+0x205>
  80082b:	83 ee 01             	sub    $0x1,%esi
  80082e:	79 99                	jns    8007c9 <vprintfmt+0x205>
  800830:	89 df                	mov    %ebx,%edi
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800838:	eb 1a                	jmp    800854 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80083a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800845:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800847:	83 ef 01             	sub    $0x1,%edi
  80084a:	eb 08                	jmp    800854 <vprintfmt+0x290>
  80084c:	89 df                	mov    %ebx,%edi
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800854:	85 ff                	test   %edi,%edi
  800856:	7f e2                	jg     80083a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085b:	e9 89 fd ff ff       	jmp    8005e9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800860:	83 f9 01             	cmp    $0x1,%ecx
  800863:	7e 19                	jle    80087e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 50 04             	mov    0x4(%eax),%edx
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800870:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
  80087c:	eb 38                	jmp    8008b6 <vprintfmt+0x2f2>
	else if (lflag)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 1b                	je     80089d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8b 00                	mov    (%eax),%eax
  800887:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088a:	89 c1                	mov    %eax,%ecx
  80088c:	c1 f9 1f             	sar    $0x1f,%ecx
  80088f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8d 40 04             	lea    0x4(%eax),%eax
  800898:	89 45 14             	mov    %eax,0x14(%ebp)
  80089b:	eb 19                	jmp    8008b6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 00                	mov    (%eax),%eax
  8008a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a5:	89 c1                	mov    %eax,%ecx
  8008a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c5:	0f 89 04 01 00 00    	jns    8009cf <vprintfmt+0x40b>
				putch('-', putdat);
  8008cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008de:	f7 da                	neg    %edx
  8008e0:	83 d1 00             	adc    $0x0,%ecx
  8008e3:	f7 d9                	neg    %ecx
  8008e5:	e9 e5 00 00 00       	jmp    8009cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ea:	83 f9 01             	cmp    $0x1,%ecx
  8008ed:	7e 10                	jle    8008ff <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f7:	8d 40 08             	lea    0x8(%eax),%eax
  8008fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8008fd:	eb 26                	jmp    800925 <vprintfmt+0x361>
	else if (lflag)
  8008ff:	85 c9                	test   %ecx,%ecx
  800901:	74 12                	je     800915 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 10                	mov    (%eax),%edx
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090d:	8d 40 04             	lea    0x4(%eax),%eax
  800910:	89 45 14             	mov    %eax,0x14(%ebp)
  800913:	eb 10                	jmp    800925 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 10                	mov    (%eax),%edx
  80091a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091f:	8d 40 04             	lea    0x4(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800925:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80092a:	e9 a0 00 00 00       	jmp    8009cf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80092f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800933:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80093a:	ff d6                	call   *%esi
			putch('X', putdat);
  80093c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800940:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800947:	ff d6                	call   *%esi
			putch('X', putdat);
  800949:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800954:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800959:	e9 8b fc ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80095e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800962:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800969:	ff d6                	call   *%esi
			putch('x', putdat);
  80096b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800976:	ff d6                	call   *%esi
			num = (unsigned long long)
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80098d:	eb 40                	jmp    8009cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80098f:	83 f9 01             	cmp    $0x1,%ecx
  800992:	7e 10                	jle    8009a4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8b 10                	mov    (%eax),%edx
  800999:	8b 48 04             	mov    0x4(%eax),%ecx
  80099c:	8d 40 08             	lea    0x8(%eax),%eax
  80099f:	89 45 14             	mov    %eax,0x14(%ebp)
  8009a2:	eb 26                	jmp    8009ca <vprintfmt+0x406>
	else if (lflag)
  8009a4:	85 c9                	test   %ecx,%ecx
  8009a6:	74 12                	je     8009ba <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009b2:	8d 40 04             	lea    0x4(%eax),%eax
  8009b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b8:	eb 10                	jmp    8009ca <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8b 10                	mov    (%eax),%edx
  8009bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c4:	8d 40 04             	lea    0x4(%eax),%eax
  8009c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009ca:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e2:	89 14 24             	mov    %edx,(%esp)
  8009e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e9:	89 da                	mov    %ebx,%edx
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	e8 9e fa ff ff       	call   800490 <printnum>
			break;
  8009f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009f5:	e9 ef fb ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fe:	89 04 24             	mov    %eax,(%esp)
  800a01:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a06:	e9 de fb ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a16:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a18:	eb 03                	jmp    800a1d <vprintfmt+0x459>
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a21:	75 f7                	jne    800a1a <vprintfmt+0x456>
  800a23:	e9 c1 fb ff ff       	jmp    8005e9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a28:	83 c4 3c             	add    $0x3c,%esp
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 28             	sub    $0x28,%esp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a3f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a43:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 30                	je     800a81 <vsnprintf+0x51>
  800a51:	85 d2                	test   %edx,%edx
  800a53:	7e 2c                	jle    800a81 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a55:	8b 45 14             	mov    0x14(%ebp),%eax
  800a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	c7 04 24 7f 05 80 00 	movl   $0x80057f,(%esp)
  800a71:	e8 4e fb ff ff       	call   8005c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a79:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a7f:	eb 05                	jmp    800a86 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a95:	8b 45 10             	mov    0x10(%ebp),%eax
  800a98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 82 ff ff ff       	call   800a30 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 03                	jmp    800ac0 <strlen+0x10>
		n++;
  800abd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac4:	75 f7                	jne    800abd <strlen+0xd>
		n++;
	return n;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	eb 03                	jmp    800adb <strnlen+0x13>
		n++;
  800ad8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adb:	39 d0                	cmp    %edx,%eax
  800add:	74 06                	je     800ae5 <strnlen+0x1d>
  800adf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ae3:	75 f3                	jne    800ad8 <strnlen+0x10>
		n++;
	return n;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800afd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b00:	84 db                	test   %bl,%bl
  800b02:	75 ef                	jne    800af3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b11:	89 1c 24             	mov    %ebx,(%esp)
  800b14:	e8 97 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b20:	01 d8                	add    %ebx,%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 bd ff ff ff       	call   800ae7 <strcpy>
	return dst;
}
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	83 c4 08             	add    $0x8,%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b42:	89 f2                	mov    %esi,%edx
  800b44:	eb 0f                	jmp    800b55 <strncpy+0x23>
		*dst++ = *src;
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b55:	39 da                	cmp    %ebx,%edx
  800b57:	75 ed                	jne    800b46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b59:	89 f0                	mov    %esi,%eax
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 75 08             	mov    0x8(%ebp),%esi
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	75 0b                	jne    800b82 <strlcpy+0x23>
  800b77:	eb 1d                	jmp    800b96 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b79:	83 c0 01             	add    $0x1,%eax
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b82:	39 d8                	cmp    %ebx,%eax
  800b84:	74 0b                	je     800b91 <strlcpy+0x32>
  800b86:	0f b6 0a             	movzbl (%edx),%ecx
  800b89:	84 c9                	test   %cl,%cl
  800b8b:	75 ec                	jne    800b79 <strlcpy+0x1a>
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	eb 02                	jmp    800b93 <strlcpy+0x34>
  800b91:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b93:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b96:	29 f0                	sub    %esi,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba5:	eb 06                	jmp    800bad <strcmp+0x11>
		p++, q++;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bad:	0f b6 01             	movzbl (%ecx),%eax
  800bb0:	84 c0                	test   %al,%al
  800bb2:	74 04                	je     800bb8 <strcmp+0x1c>
  800bb4:	3a 02                	cmp    (%edx),%al
  800bb6:	74 ef                	je     800ba7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb8:	0f b6 c0             	movzbl %al,%eax
  800bbb:	0f b6 12             	movzbl (%edx),%edx
  800bbe:	29 d0                	sub    %edx,%eax
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bd1:	eb 06                	jmp    800bd9 <strncmp+0x17>
		n--, p++, q++;
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd9:	39 d8                	cmp    %ebx,%eax
  800bdb:	74 15                	je     800bf2 <strncmp+0x30>
  800bdd:	0f b6 08             	movzbl (%eax),%ecx
  800be0:	84 c9                	test   %cl,%cl
  800be2:	74 04                	je     800be8 <strncmp+0x26>
  800be4:	3a 0a                	cmp    (%edx),%cl
  800be6:	74 eb                	je     800bd3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 00             	movzbl (%eax),%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
  800bf0:	eb 05                	jmp    800bf7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c04:	eb 07                	jmp    800c0d <strchr+0x13>
		if (*s == c)
  800c06:	38 ca                	cmp    %cl,%dl
  800c08:	74 0f                	je     800c19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 f2                	jne    800c06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	eb 07                	jmp    800c2e <strfind+0x13>
		if (*s == c)
  800c27:	38 ca                	cmp    %cl,%dl
  800c29:	74 0a                	je     800c35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	0f b6 10             	movzbl (%eax),%edx
  800c31:	84 d2                	test   %dl,%dl
  800c33:	75 f2                	jne    800c27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c43:	85 c9                	test   %ecx,%ecx
  800c45:	74 36                	je     800c7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4d:	75 28                	jne    800c77 <memset+0x40>
  800c4f:	f6 c1 03             	test   $0x3,%cl
  800c52:	75 23                	jne    800c77 <memset+0x40>
		c &= 0xFF;
  800c54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	c1 e3 08             	shl    $0x8,%ebx
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	c1 e6 18             	shl    $0x18,%esi
  800c62:	89 d0                	mov    %edx,%eax
  800c64:	c1 e0 10             	shl    $0x10,%eax
  800c67:	09 f0                	or     %esi,%eax
  800c69:	09 c2                	or     %eax,%edx
  800c6b:	89 d0                	mov    %edx,%eax
  800c6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c72:	fc                   	cld    
  800c73:	f3 ab                	rep stos %eax,%es:(%edi)
  800c75:	eb 06                	jmp    800c7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	fc                   	cld    
  800c7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c92:	39 c6                	cmp    %eax,%esi
  800c94:	73 35                	jae    800ccb <memmove+0x47>
  800c96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 2e                	jae    800ccb <memmove+0x47>
		s += n;
		d += n;
  800c9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800caa:	75 13                	jne    800cbf <memmove+0x3b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 0e                	jne    800cbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cb1:	83 ef 04             	sub    $0x4,%edi
  800cb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cba:	fd                   	std    
  800cbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbd:	eb 09                	jmp    800cc8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cbf:	83 ef 01             	sub    $0x1,%edi
  800cc2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cc5:	fd                   	std    
  800cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc8:	fc                   	cld    
  800cc9:	eb 1d                	jmp    800ce8 <memmove+0x64>
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ccf:	f6 c2 03             	test   $0x3,%dl
  800cd2:	75 0f                	jne    800ce3 <memmove+0x5f>
  800cd4:	f6 c1 03             	test   $0x3,%cl
  800cd7:	75 0a                	jne    800ce3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	fc                   	cld    
  800cdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce1:	eb 05                	jmp    800ce8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce3:	89 c7                	mov    %eax,%edi
  800ce5:	fc                   	cld    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	89 04 24             	mov    %eax,(%esp)
  800d06:	e8 79 ff ff ff       	call   800c84 <memmove>
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1d:	eb 1a                	jmp    800d39 <memcmp+0x2c>
		if (*s1 != *s2)
  800d1f:	0f b6 02             	movzbl (%edx),%eax
  800d22:	0f b6 19             	movzbl (%ecx),%ebx
  800d25:	38 d8                	cmp    %bl,%al
  800d27:	74 0a                	je     800d33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d29:	0f b6 c0             	movzbl %al,%eax
  800d2c:	0f b6 db             	movzbl %bl,%ebx
  800d2f:	29 d8                	sub    %ebx,%eax
  800d31:	eb 0f                	jmp    800d42 <memcmp+0x35>
		s1++, s2++;
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d39:	39 f2                	cmp    %esi,%edx
  800d3b:	75 e2                	jne    800d1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d54:	eb 07                	jmp    800d5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	38 08                	cmp    %cl,(%eax)
  800d58:	74 07                	je     800d61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	39 d0                	cmp    %edx,%eax
  800d5f:	72 f5                	jb     800d56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6f:	eb 03                	jmp    800d74 <strtol+0x11>
		s++;
  800d71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d74:	0f b6 0a             	movzbl (%edx),%ecx
  800d77:	80 f9 09             	cmp    $0x9,%cl
  800d7a:	74 f5                	je     800d71 <strtol+0xe>
  800d7c:	80 f9 20             	cmp    $0x20,%cl
  800d7f:	74 f0                	je     800d71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d81:	80 f9 2b             	cmp    $0x2b,%cl
  800d84:	75 0a                	jne    800d90 <strtol+0x2d>
		s++;
  800d86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d89:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8e:	eb 11                	jmp    800da1 <strtol+0x3e>
  800d90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d95:	80 f9 2d             	cmp    $0x2d,%cl
  800d98:	75 07                	jne    800da1 <strtol+0x3e>
		s++, neg = 1;
  800d9a:	8d 52 01             	lea    0x1(%edx),%edx
  800d9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800da6:	75 15                	jne    800dbd <strtol+0x5a>
  800da8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dab:	75 10                	jne    800dbd <strtol+0x5a>
  800dad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800db1:	75 0a                	jne    800dbd <strtol+0x5a>
		s += 2, base = 16;
  800db3:	83 c2 02             	add    $0x2,%edx
  800db6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dbb:	eb 10                	jmp    800dcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 0c                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc6:	75 05                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
  800dc8:	83 c2 01             	add    $0x1,%edx
  800dcb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd5:	0f b6 0a             	movzbl (%edx),%ecx
  800dd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	3c 09                	cmp    $0x9,%al
  800ddf:	77 08                	ja     800de9 <strtol+0x86>
			dig = *s - '0';
  800de1:	0f be c9             	movsbl %cl,%ecx
  800de4:	83 e9 30             	sub    $0x30,%ecx
  800de7:	eb 20                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800de9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	3c 19                	cmp    $0x19,%al
  800df0:	77 08                	ja     800dfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800df2:	0f be c9             	movsbl %cl,%ecx
  800df5:	83 e9 57             	sub    $0x57,%ecx
  800df8:	eb 0f                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	3c 19                	cmp    $0x19,%al
  800e01:	77 16                	ja     800e19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e03:	0f be c9             	movsbl %cl,%ecx
  800e06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e0c:	7d 0f                	jge    800e1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e0e:	83 c2 01             	add    $0x1,%edx
  800e11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e17:	eb bc                	jmp    800dd5 <strtol+0x72>
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	eb 02                	jmp    800e1f <strtol+0xbc>
  800e1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e23:	74 05                	je     800e2a <strtol+0xc7>
		*endptr = (char *) s;
  800e25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e2a:	f7 d8                	neg    %eax
  800e2c:	85 ff                	test   %edi,%edi
  800e2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	89 c7                	mov    %eax,%edi
  800e4b:	89 c6                	mov    %eax,%esi
  800e4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e64:	89 d1                	mov    %edx,%ecx
  800e66:	89 d3                	mov    %edx,%ebx
  800e68:	89 d7                	mov    %edx,%edi
  800e6a:	89 d6                	mov    %edx,%esi
  800e6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e81:	b8 03 00 00 00       	mov    $0x3,%eax
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 cb                	mov    %ecx,%ebx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	89 ce                	mov    %ecx,%esi
  800e8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7e 28                	jle    800ebd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb0:	00 
  800eb1:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800eb8:	e8 b4 f4 ff ff       	call   800371 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ebd:	83 c4 2c             	add    $0x2c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	89 d3                	mov    %edx,%ebx
  800ed9:	89 d7                	mov    %edx,%edi
  800edb:	89 d6                	mov    %edx,%esi
  800edd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <sys_yield>:

void
sys_yield(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eea:	ba 00 00 00 00       	mov    $0x0,%edx
  800eef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef4:	89 d1                	mov    %edx,%ecx
  800ef6:	89 d3                	mov    %edx,%ebx
  800ef8:	89 d7                	mov    %edx,%edi
  800efa:	89 d6                	mov    %edx,%esi
  800efc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	be 00 00 00 00       	mov    $0x0,%esi
  800f11:	b8 04 00 00 00       	mov    $0x4,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	89 f7                	mov    %esi,%edi
  800f21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f23:	85 c0                	test   %eax,%eax
  800f25:	7e 28                	jle    800f4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f32:	00 
  800f33:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f42:	00 
  800f43:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800f4a:	e8 22 f4 ff ff       	call   800371 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f4f:	83 c4 2c             	add    $0x2c,%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f60:	b8 05 00 00 00       	mov    $0x5,%eax
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f71:	8b 75 18             	mov    0x18(%ebp),%esi
  800f74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 28                	jle    800fa2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f85:	00 
  800f86:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800f9d:	e8 cf f3 ff ff       	call   800371 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fa2:	83 c4 2c             	add    $0x2c,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	89 de                	mov    %ebx,%esi
  800fc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 28                	jle    800ff5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  800ff0:	e8 7c f3 ff ff       	call   800371 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ff5:	83 c4 2c             	add    $0x2c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100b:	b8 08 00 00 00       	mov    $0x8,%eax
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	89 df                	mov    %ebx,%edi
  801018:	89 de                	mov    %ebx,%esi
  80101a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	7e 28                	jle    801048 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801020:	89 44 24 10          	mov    %eax,0x10(%esp)
  801024:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80102b:	00 
  80102c:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  801033:	00 
  801034:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801043:	e8 29 f3 ff ff       	call   800371 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801048:	83 c4 2c             	add    $0x2c,%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105e:	b8 09 00 00 00       	mov    $0x9,%eax
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	89 df                	mov    %ebx,%edi
  80106b:	89 de                	mov    %ebx,%esi
  80106d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106f:	85 c0                	test   %eax,%eax
  801071:	7e 28                	jle    80109b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801073:	89 44 24 10          	mov    %eax,0x10(%esp)
  801077:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80107e:	00 
  80107f:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  801086:	00 
  801087:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80108e:	00 
  80108f:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801096:	e8 d6 f2 ff ff       	call   800371 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80109b:	83 c4 2c             	add    $0x2c,%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	89 df                	mov    %ebx,%edi
  8010be:	89 de                	mov    %ebx,%esi
  8010c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	7e 28                	jle    8010ee <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ca:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010d1:	00 
  8010d2:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  8010d9:	00 
  8010da:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e1:	00 
  8010e2:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  8010e9:	e8 83 f2 ff ff       	call   800371 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ee:	83 c4 2c             	add    $0x2c,%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fc:	be 00 00 00 00       	mov    $0x0,%esi
  801101:	b8 0c 00 00 00       	mov    $0xc,%eax
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801112:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	b9 00 00 00 00       	mov    $0x0,%ecx
  801127:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112c:	8b 55 08             	mov    0x8(%ebp),%edx
  80112f:	89 cb                	mov    %ecx,%ebx
  801131:	89 cf                	mov    %ecx,%edi
  801133:	89 ce                	mov    %ecx,%esi
  801135:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801137:	85 c0                	test   %eax,%eax
  801139:	7e 28                	jle    801163 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801146:	00 
  801147:	c7 44 24 08 9f 2c 80 	movl   $0x802c9f,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  80115e:	e8 0e f2 ff ff       	call   800371 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801163:	83 c4 2c             	add    $0x2c,%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 20             	sub    $0x20,%esp
  801173:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801176:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801178:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80117c:	75 3f                	jne    8011bd <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80117e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801182:	c7 04 24 ca 2c 80 00 	movl   $0x802cca,(%esp)
  801189:	e8 dc f2 ff ff       	call   80046a <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80118e:	8b 43 28             	mov    0x28(%ebx),%eax
  801191:	89 44 24 04          	mov    %eax,0x4(%esp)
  801195:	c7 04 24 da 2c 80 00 	movl   $0x802cda,(%esp)
  80119c:	e8 c9 f2 ff ff       	call   80046a <cprintf>

		 panic("The err is not right of the pgfault\n ");
  8011a1:	c7 44 24 08 20 2d 80 	movl   $0x802d20,0x8(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8011b0:	00 
  8011b1:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  8011b8:	e8 b4 f1 ff ff       	call   800371 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
  8011c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  8011c9:	f6 c4 08             	test   $0x8,%ah
  8011cc:	75 1c                	jne    8011ea <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  8011ce:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  8011d5:	00 
  8011d6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8011dd:	00 
  8011de:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  8011e5:	e8 87 f1 ff ff       	call   800371 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  8011ea:	e8 d6 fc ff ff       	call   800ec5 <sys_getenvid>
  8011ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011fe:	00 
  8011ff:	89 04 24             	mov    %eax,(%esp)
  801202:	e8 fc fc ff ff       	call   800f03 <sys_page_alloc>
  801207:	85 c0                	test   %eax,%eax
  801209:	79 1c                	jns    801227 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  80120b:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801222:	e8 4a f1 ff ff       	call   800371 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801227:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80122d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801234:	00 
  801235:	89 74 24 04          	mov    %esi,0x4(%esp)
  801239:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801240:	e8 a7 fa ff ff       	call   800cec <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801245:	e8 7b fc ff ff       	call   800ec5 <sys_getenvid>
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	e8 74 fc ff ff       	call   800ec5 <sys_getenvid>
  801251:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801258:	00 
  801259:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80125d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801261:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801268:	00 
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 e6 fc ff ff       	call   800f57 <sys_page_map>
  801271:	85 c0                	test   %eax,%eax
  801273:	79 20                	jns    801295 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801275:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801279:	c7 44 24 08 90 2d 80 	movl   $0x802d90,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801290:	e8 dc f0 ff ff       	call   800371 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801295:	e8 2b fc ff ff       	call   800ec5 <sys_getenvid>
  80129a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012a1:	00 
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 00 fd ff ff       	call   800faa <sys_page_unmap>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	79 20                	jns    8012ce <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8012ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b2:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8012b9:	00 
  8012ba:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8012c1:	00 
  8012c2:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  8012c9:	e8 a3 f0 ff ff       	call   800371 <_panic>
	return;
}
  8012ce:	83 c4 20             	add    $0x20,%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	57                   	push   %edi
  8012d9:	56                   	push   %esi
  8012da:	53                   	push   %ebx
  8012db:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  8012de:	c7 04 24 6b 11 80 00 	movl   $0x80116b,(%esp)
  8012e5:	e8 fc 0f 00 00       	call   8022e6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8012ea:	b8 07 00 00 00       	mov    $0x7,%eax
  8012ef:	cd 30                	int    $0x30
  8012f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012f4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	79 20                	jns    80131b <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  8012fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ff:	c7 44 24 08 f4 2d 80 	movl   $0x802df4,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801316:	e8 56 f0 ff ff       	call   800371 <_panic>
	if(childEid == 0){
  80131b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80131f:	75 1c                	jne    80133d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801321:	e8 9f fb ff ff       	call   800ec5 <sys_getenvid>
  801326:	25 ff 03 00 00       	and    $0x3ff,%eax
  80132b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80132e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801333:	a3 04 50 80 00       	mov    %eax,0x805004
		return childEid;
  801338:	e9 a0 01 00 00       	jmp    8014dd <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80133d:	c7 44 24 04 7c 23 80 	movl   $0x80237c,0x4(%esp)
  801344:	00 
  801345:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 53 fd ff ff       	call   8010a3 <sys_env_set_pgfault_upcall>
  801350:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801352:	85 c0                	test   %eax,%eax
  801354:	79 20                	jns    801376 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801356:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135a:	c7 44 24 08 28 2e 80 	movl   $0x802e28,0x8(%esp)
  801361:	00 
  801362:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801369:	00 
  80136a:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801371:	e8 fb ef ff ff       	call   800371 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801376:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
  801380:	b9 00 00 00 00       	mov    $0x0,%ecx
  801385:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801388:	89 c2                	mov    %eax,%edx
  80138a:	c1 ea 16             	shr    $0x16,%edx
  80138d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801394:	f6 c2 01             	test   $0x1,%dl
  801397:	0f 84 f7 00 00 00    	je     801494 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  80139d:	c1 e8 0c             	shr    $0xc,%eax
  8013a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8013a7:	f6 c2 04             	test   $0x4,%dl
  8013aa:	0f 84 e4 00 00 00    	je     801494 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8013b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8013b7:	a8 01                	test   $0x1,%al
  8013b9:	0f 84 d5 00 00 00    	je     801494 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8013bf:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8013c5:	75 20                	jne    8013e7 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8013c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013ce:	00 
  8013cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013d6:	ee 
  8013d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 21 fb ff ff       	call   800f03 <sys_page_alloc>
  8013e2:	e9 84 00 00 00       	jmp    80146b <fork+0x196>
  8013e7:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  8013ed:	89 f8                	mov    %edi,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  8013f9:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  8013fe:	83 f8 01             	cmp    $0x1,%eax
  801401:	19 db                	sbb    %ebx,%ebx
  801403:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801409:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80140f:	e8 b1 fa ff ff       	call   800ec5 <sys_getenvid>
  801414:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801418:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80141c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80141f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801423:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 28 fb ff ff       	call   800f57 <sys_page_map>
  80142f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801432:	85 c0                	test   %eax,%eax
  801434:	78 35                	js     80146b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801436:	e8 8a fa ff ff       	call   800ec5 <sys_getenvid>
  80143b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80143e:	e8 82 fa ff ff       	call   800ec5 <sys_getenvid>
  801443:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801447:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80144b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80144e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	e8 f9 fa ff ff       	call   800f57 <sys_page_map>
  80145e:	85 c0                	test   %eax,%eax
  801460:	bf 00 00 00 00       	mov    $0x0,%edi
  801465:	0f 4f c7             	cmovg  %edi,%eax
  801468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80146b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80146f:	79 23                	jns    801494 <fork+0x1bf>
  801471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801474:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801478:	c7 44 24 08 68 2e 80 	movl   $0x802e68,0x8(%esp)
  80147f:	00 
  801480:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801487:	00 
  801488:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  80148f:	e8 dd ee ff ff       	call   800371 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801494:	89 f1                	mov    %esi,%ecx
  801496:	89 f0                	mov    %esi,%eax
  801498:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80149e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8014a4:	0f 85 de fe ff ff    	jne    801388 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8014aa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014b1:	00 
  8014b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014b5:	89 04 24             	mov    %eax,(%esp)
  8014b8:	e8 40 fb ff ff       	call   800ffd <sys_env_set_status>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	79 1c                	jns    8014dd <fork+0x208>
		panic("sys_env_set_status");
  8014c1:	c7 44 24 08 f6 2c 80 	movl   $0x802cf6,0x8(%esp)
  8014c8:	00 
  8014c9:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8014d0:	00 
  8014d1:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  8014d8:	e8 94 ee ff ff       	call   800371 <_panic>
	return childEid;
}
  8014dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014e0:	83 c4 2c             	add    $0x2c,%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <sfork>:

// Challenge!
int
sfork(void)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014ee:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  8014f5:	00 
  8014f6:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8014fd:	00 
  8014fe:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  801505:	e8 67 ee ff ff       	call   800371 <_panic>
  80150a:	66 90                	xchg   %ax,%ax
  80150c:	66 90                	xchg   %ax,%ax
  80150e:	66 90                	xchg   %ax,%ax

00801510 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	05 00 00 00 30       	add    $0x30000000,%eax
  80151b:	c1 e8 0c             	shr    $0xc,%eax
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80152b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801530:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801542:	89 c2                	mov    %eax,%edx
  801544:	c1 ea 16             	shr    $0x16,%edx
  801547:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80154e:	f6 c2 01             	test   $0x1,%dl
  801551:	74 11                	je     801564 <fd_alloc+0x2d>
  801553:	89 c2                	mov    %eax,%edx
  801555:	c1 ea 0c             	shr    $0xc,%edx
  801558:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155f:	f6 c2 01             	test   $0x1,%dl
  801562:	75 09                	jne    80156d <fd_alloc+0x36>
			*fd_store = fd;
  801564:	89 01                	mov    %eax,(%ecx)
			return 0;
  801566:	b8 00 00 00 00       	mov    $0x0,%eax
  80156b:	eb 17                	jmp    801584 <fd_alloc+0x4d>
  80156d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801572:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801577:	75 c9                	jne    801542 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801579:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80157f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    

00801586 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80158c:	83 f8 1f             	cmp    $0x1f,%eax
  80158f:	77 36                	ja     8015c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801591:	c1 e0 0c             	shl    $0xc,%eax
  801594:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801599:	89 c2                	mov    %eax,%edx
  80159b:	c1 ea 16             	shr    $0x16,%edx
  80159e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015a5:	f6 c2 01             	test   $0x1,%dl
  8015a8:	74 24                	je     8015ce <fd_lookup+0x48>
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	c1 ea 0c             	shr    $0xc,%edx
  8015af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015b6:	f6 c2 01             	test   $0x1,%dl
  8015b9:	74 1a                	je     8015d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015be:	89 02                	mov    %eax,(%edx)
	return 0;
  8015c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c5:	eb 13                	jmp    8015da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cc:	eb 0c                	jmp    8015da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d3:	eb 05                	jmp    8015da <fd_lookup+0x54>
  8015d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 18             	sub    $0x18,%esp
  8015e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015e5:	ba 0c 2f 80 00       	mov    $0x802f0c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015ea:	eb 13                	jmp    8015ff <dev_lookup+0x23>
  8015ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015ef:	39 08                	cmp    %ecx,(%eax)
  8015f1:	75 0c                	jne    8015ff <dev_lookup+0x23>
			*dev = devtab[i];
  8015f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fd:	eb 30                	jmp    80162f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015ff:	8b 02                	mov    (%edx),%eax
  801601:	85 c0                	test   %eax,%eax
  801603:	75 e7                	jne    8015ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801605:	a1 04 50 80 00       	mov    0x805004,%eax
  80160a:	8b 40 48             	mov    0x48(%eax),%eax
  80160d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801611:	89 44 24 04          	mov    %eax,0x4(%esp)
  801615:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  80161c:	e8 49 ee ff ff       	call   80046a <cprintf>
	*dev = 0;
  801621:	8b 45 0c             	mov    0xc(%ebp),%eax
  801624:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80162a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 20             	sub    $0x20,%esp
  801639:	8b 75 08             	mov    0x8(%ebp),%esi
  80163c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80163f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801642:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801646:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80164c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80164f:	89 04 24             	mov    %eax,(%esp)
  801652:	e8 2f ff ff ff       	call   801586 <fd_lookup>
  801657:	85 c0                	test   %eax,%eax
  801659:	78 05                	js     801660 <fd_close+0x2f>
	    || fd != fd2)
  80165b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80165e:	74 0c                	je     80166c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801660:	84 db                	test   %bl,%bl
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
  801667:	0f 44 c2             	cmove  %edx,%eax
  80166a:	eb 3f                	jmp    8016ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80166c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801673:	8b 06                	mov    (%esi),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 5f ff ff ff       	call   8015dc <dev_lookup>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 16                	js     801699 <fd_close+0x68>
		if (dev->dev_close)
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801689:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80168e:	85 c0                	test   %eax,%eax
  801690:	74 07                	je     801699 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801692:	89 34 24             	mov    %esi,(%esp)
  801695:	ff d0                	call   *%eax
  801697:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801699:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a4:	e8 01 f9 ff ff       	call   800faa <sys_page_unmap>
	return r;
  8016a9:	89 d8                	mov    %ebx,%eax
}
  8016ab:	83 c4 20             	add    $0x20,%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	89 04 24             	mov    %eax,(%esp)
  8016c5:	e8 bc fe ff ff       	call   801586 <fd_lookup>
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	85 d2                	test   %edx,%edx
  8016ce:	78 13                	js     8016e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8016d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016d7:	00 
  8016d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016db:	89 04 24             	mov    %eax,(%esp)
  8016de:	e8 4e ff ff ff       	call   801631 <fd_close>
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <close_all>:

void
close_all(void)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 b9 ff ff ff       	call   8016b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f9:	83 c3 01             	add    $0x1,%ebx
  8016fc:	83 fb 20             	cmp    $0x20,%ebx
  8016ff:	75 f0                	jne    8016f1 <close_all+0xc>
		close(i);
}
  801701:	83 c4 14             	add    $0x14,%esp
  801704:	5b                   	pop    %ebx
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	57                   	push   %edi
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801710:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	e8 64 fe ff ff       	call   801586 <fd_lookup>
  801722:	89 c2                	mov    %eax,%edx
  801724:	85 d2                	test   %edx,%edx
  801726:	0f 88 e1 00 00 00    	js     80180d <dup+0x106>
		return r;
	close(newfdnum);
  80172c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172f:	89 04 24             	mov    %eax,(%esp)
  801732:	e8 7b ff ff ff       	call   8016b2 <close>

	newfd = INDEX2FD(newfdnum);
  801737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80173a:	c1 e3 0c             	shl    $0xc,%ebx
  80173d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801743:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801746:	89 04 24             	mov    %eax,(%esp)
  801749:	e8 d2 fd ff ff       	call   801520 <fd2data>
  80174e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 c8 fd ff ff       	call   801520 <fd2data>
  801758:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80175a:	89 f0                	mov    %esi,%eax
  80175c:	c1 e8 16             	shr    $0x16,%eax
  80175f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801766:	a8 01                	test   $0x1,%al
  801768:	74 43                	je     8017ad <dup+0xa6>
  80176a:	89 f0                	mov    %esi,%eax
  80176c:	c1 e8 0c             	shr    $0xc,%eax
  80176f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801776:	f6 c2 01             	test   $0x1,%dl
  801779:	74 32                	je     8017ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80177b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801782:	25 07 0e 00 00       	and    $0xe07,%eax
  801787:	89 44 24 10          	mov    %eax,0x10(%esp)
  80178b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80178f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801796:	00 
  801797:	89 74 24 04          	mov    %esi,0x4(%esp)
  80179b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a2:	e8 b0 f7 ff ff       	call   800f57 <sys_page_map>
  8017a7:	89 c6                	mov    %eax,%esi
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 3e                	js     8017eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	c1 ea 0c             	shr    $0xc,%edx
  8017b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017d1:	00 
  8017d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017dd:	e8 75 f7 ff ff       	call   800f57 <sys_page_map>
  8017e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017e7:	85 f6                	test   %esi,%esi
  8017e9:	79 22                	jns    80180d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f6:	e8 af f7 ff ff       	call   800faa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801806:	e8 9f f7 ff ff       	call   800faa <sys_page_unmap>
	return r;
  80180b:	89 f0                	mov    %esi,%eax
}
  80180d:	83 c4 3c             	add    $0x3c,%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5f                   	pop    %edi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	53                   	push   %ebx
  801819:	83 ec 24             	sub    $0x24,%esp
  80181c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801822:	89 44 24 04          	mov    %eax,0x4(%esp)
  801826:	89 1c 24             	mov    %ebx,(%esp)
  801829:	e8 58 fd ff ff       	call   801586 <fd_lookup>
  80182e:	89 c2                	mov    %eax,%edx
  801830:	85 d2                	test   %edx,%edx
  801832:	78 6d                	js     8018a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801834:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183e:	8b 00                	mov    (%eax),%eax
  801840:	89 04 24             	mov    %eax,(%esp)
  801843:	e8 94 fd ff ff       	call   8015dc <dev_lookup>
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 55                	js     8018a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	8b 50 08             	mov    0x8(%eax),%edx
  801852:	83 e2 03             	and    $0x3,%edx
  801855:	83 fa 01             	cmp    $0x1,%edx
  801858:	75 23                	jne    80187d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80185a:	a1 04 50 80 00       	mov    0x805004,%eax
  80185f:	8b 40 48             	mov    0x48(%eax),%eax
  801862:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186a:	c7 04 24 d1 2e 80 00 	movl   $0x802ed1,(%esp)
  801871:	e8 f4 eb ff ff       	call   80046a <cprintf>
		return -E_INVAL;
  801876:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187b:	eb 24                	jmp    8018a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	8b 52 08             	mov    0x8(%edx),%edx
  801883:	85 d2                	test   %edx,%edx
  801885:	74 15                	je     80189c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801887:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80188a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80188e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801891:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801895:	89 04 24             	mov    %eax,(%esp)
  801898:	ff d2                	call   *%edx
  80189a:	eb 05                	jmp    8018a1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80189c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8018a1:	83 c4 24             	add    $0x24,%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 1c             	sub    $0x1c,%esp
  8018b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018bb:	eb 23                	jmp    8018e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018bd:	89 f0                	mov    %esi,%eax
  8018bf:	29 d8                	sub    %ebx,%eax
  8018c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c5:	89 d8                	mov    %ebx,%eax
  8018c7:	03 45 0c             	add    0xc(%ebp),%eax
  8018ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ce:	89 3c 24             	mov    %edi,(%esp)
  8018d1:	e8 3f ff ff ff       	call   801815 <read>
		if (m < 0)
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 10                	js     8018ea <readn+0x43>
			return m;
		if (m == 0)
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	74 0a                	je     8018e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018de:	01 c3                	add    %eax,%ebx
  8018e0:	39 f3                	cmp    %esi,%ebx
  8018e2:	72 d9                	jb     8018bd <readn+0x16>
  8018e4:	89 d8                	mov    %ebx,%eax
  8018e6:	eb 02                	jmp    8018ea <readn+0x43>
  8018e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018ea:	83 c4 1c             	add    $0x1c,%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5f                   	pop    %edi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 24             	sub    $0x24,%esp
  8018f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	89 1c 24             	mov    %ebx,(%esp)
  801906:	e8 7b fc ff ff       	call   801586 <fd_lookup>
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	85 d2                	test   %edx,%edx
  80190f:	78 68                	js     801979 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	8b 00                	mov    (%eax),%eax
  80191d:	89 04 24             	mov    %eax,(%esp)
  801920:	e8 b7 fc ff ff       	call   8015dc <dev_lookup>
  801925:	85 c0                	test   %eax,%eax
  801927:	78 50                	js     801979 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801929:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801930:	75 23                	jne    801955 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801932:	a1 04 50 80 00       	mov    0x805004,%eax
  801937:	8b 40 48             	mov    0x48(%eax),%eax
  80193a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80193e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801942:	c7 04 24 ed 2e 80 00 	movl   $0x802eed,(%esp)
  801949:	e8 1c eb ff ff       	call   80046a <cprintf>
		return -E_INVAL;
  80194e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801953:	eb 24                	jmp    801979 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801955:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801958:	8b 52 0c             	mov    0xc(%edx),%edx
  80195b:	85 d2                	test   %edx,%edx
  80195d:	74 15                	je     801974 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80195f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801962:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801966:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801969:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80196d:	89 04 24             	mov    %eax,(%esp)
  801970:	ff d2                	call   *%edx
  801972:	eb 05                	jmp    801979 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801974:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801979:	83 c4 24             	add    $0x24,%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <seek>:

int
seek(int fdnum, off_t offset)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801985:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 ef fb ff ff       	call   801586 <fd_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 0e                	js     8019a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80199b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80199e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	53                   	push   %ebx
  8019af:	83 ec 24             	sub    $0x24,%esp
  8019b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bc:	89 1c 24             	mov    %ebx,(%esp)
  8019bf:	e8 c2 fb ff ff       	call   801586 <fd_lookup>
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	85 d2                	test   %edx,%edx
  8019c8:	78 61                	js     801a2b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d4:	8b 00                	mov    (%eax),%eax
  8019d6:	89 04 24             	mov    %eax,(%esp)
  8019d9:	e8 fe fb ff ff       	call   8015dc <dev_lookup>
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 49                	js     801a2b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019e9:	75 23                	jne    801a0e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019eb:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019f0:	8b 40 48             	mov    0x48(%eax),%eax
  8019f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  801a02:	e8 63 ea ff ff       	call   80046a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a0c:	eb 1d                	jmp    801a2b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a11:	8b 52 18             	mov    0x18(%edx),%edx
  801a14:	85 d2                	test   %edx,%edx
  801a16:	74 0e                	je     801a26 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	ff d2                	call   *%edx
  801a24:	eb 05                	jmp    801a2b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a26:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a2b:	83 c4 24             	add    $0x24,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 24             	sub    $0x24,%esp
  801a38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	e8 39 fb ff ff       	call   801586 <fd_lookup>
  801a4d:	89 c2                	mov    %eax,%edx
  801a4f:	85 d2                	test   %edx,%edx
  801a51:	78 52                	js     801aa5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5d:	8b 00                	mov    (%eax),%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 75 fb ff ff       	call   8015dc <dev_lookup>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 3a                	js     801aa5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a72:	74 2c                	je     801aa0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a74:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a77:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a7e:	00 00 00 
	stat->st_isdir = 0;
  801a81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a88:	00 00 00 
	stat->st_dev = dev;
  801a8b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a95:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a98:	89 14 24             	mov    %edx,(%esp)
  801a9b:	ff 50 14             	call   *0x14(%eax)
  801a9e:	eb 05                	jmp    801aa5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801aa0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801aa5:	83 c4 24             	add    $0x24,%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ab3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aba:	00 
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	89 04 24             	mov    %eax,(%esp)
  801ac1:	e8 fb 01 00 00       	call   801cc1 <open>
  801ac6:	89 c3                	mov    %eax,%ebx
  801ac8:	85 db                	test   %ebx,%ebx
  801aca:	78 1b                	js     801ae7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad3:	89 1c 24             	mov    %ebx,(%esp)
  801ad6:	e8 56 ff ff ff       	call   801a31 <fstat>
  801adb:	89 c6                	mov    %eax,%esi
	close(fd);
  801add:	89 1c 24             	mov    %ebx,(%esp)
  801ae0:	e8 cd fb ff ff       	call   8016b2 <close>
	return r;
  801ae5:	89 f0                	mov    %esi,%eax
}
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	83 ec 10             	sub    $0x10,%esp
  801af6:	89 c6                	mov    %eax,%esi
  801af8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801afa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801b01:	75 11                	jne    801b14 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b0a:	e8 fe 09 00 00       	call   80250d <ipc_find_env>
  801b0f:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b14:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b1b:	00 
  801b1c:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b23:	00 
  801b24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b28:	a1 00 50 80 00       	mov    0x805000,%eax
  801b2d:	89 04 24             	mov    %eax,(%esp)
  801b30:	e8 29 09 00 00       	call   80245e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b3c:	00 
  801b3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b48:	e8 73 08 00 00       	call   8023c0 <ipc_recv>
}
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b60:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b68:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b72:	b8 02 00 00 00       	mov    $0x2,%eax
  801b77:	e8 72 ff ff ff       	call   801aee <fsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b94:	b8 06 00 00 00       	mov    $0x6,%eax
  801b99:	e8 50 ff ff ff       	call   801aee <fsipc>
}
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 14             	sub    $0x14,%esp
  801ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801baa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bad:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bba:	b8 05 00 00 00       	mov    $0x5,%eax
  801bbf:	e8 2a ff ff ff       	call   801aee <fsipc>
  801bc4:	89 c2                	mov    %eax,%edx
  801bc6:	85 d2                	test   %edx,%edx
  801bc8:	78 2b                	js     801bf5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bca:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bd1:	00 
  801bd2:	89 1c 24             	mov    %ebx,(%esp)
  801bd5:	e8 0d ef ff ff       	call   800ae7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bda:	a1 80 60 80 00       	mov    0x806080,%eax
  801bdf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801be5:	a1 84 60 80 00       	mov    0x806084,%eax
  801bea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf5:	83 c4 14             	add    $0x14,%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801c01:	c7 44 24 08 1c 2f 80 	movl   $0x802f1c,0x8(%esp)
  801c08:	00 
  801c09:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801c10:	00 
  801c11:	c7 04 24 3a 2f 80 00 	movl   $0x802f3a,(%esp)
  801c18:	e8 54 e7 ff ff       	call   800371 <_panic>

00801c1d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 10             	sub    $0x10,%esp
  801c25:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c2e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c33:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c39:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3e:	b8 03 00 00 00       	mov    $0x3,%eax
  801c43:	e8 a6 fe ff ff       	call   801aee <fsipc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 6a                	js     801cb8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c4e:	39 c6                	cmp    %eax,%esi
  801c50:	73 24                	jae    801c76 <devfile_read+0x59>
  801c52:	c7 44 24 0c 45 2f 80 	movl   $0x802f45,0xc(%esp)
  801c59:	00 
  801c5a:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  801c61:	00 
  801c62:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c69:	00 
  801c6a:	c7 04 24 3a 2f 80 00 	movl   $0x802f3a,(%esp)
  801c71:	e8 fb e6 ff ff       	call   800371 <_panic>
	assert(r <= PGSIZE);
  801c76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c7b:	7e 24                	jle    801ca1 <devfile_read+0x84>
  801c7d:	c7 44 24 0c 61 2f 80 	movl   $0x802f61,0xc(%esp)
  801c84:	00 
  801c85:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  801c8c:	00 
  801c8d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c94:	00 
  801c95:	c7 04 24 3a 2f 80 00 	movl   $0x802f3a,(%esp)
  801c9c:	e8 d0 e6 ff ff       	call   800371 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ca1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cac:	00 
  801cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	e8 cc ef ff ff       	call   800c84 <memmove>
	return r;
}
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 24             	sub    $0x24,%esp
  801cc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ccb:	89 1c 24             	mov    %ebx,(%esp)
  801cce:	e8 dd ed ff ff       	call   800ab0 <strlen>
  801cd3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cd8:	7f 60                	jg     801d3a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 52 f8 ff ff       	call   801537 <fd_alloc>
  801ce5:	89 c2                	mov    %eax,%edx
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	78 54                	js     801d3f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ceb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cef:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cf6:	e8 ec ed ff ff       	call   800ae7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfe:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	e8 de fd ff ff       	call   801aee <fsipc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	85 c0                	test   %eax,%eax
  801d14:	79 17                	jns    801d2d <open+0x6c>
		fd_close(fd, 0);
  801d16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d1d:	00 
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 08 f9 ff ff       	call   801631 <fd_close>
		return r;
  801d29:	89 d8                	mov    %ebx,%eax
  801d2b:	eb 12                	jmp    801d3f <open+0x7e>
	}

	return fd2num(fd);
  801d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d30:	89 04 24             	mov    %eax,(%esp)
  801d33:	e8 d8 f7 ff ff       	call   801510 <fd2num>
  801d38:	eb 05                	jmp    801d3f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d3f:	83 c4 24             	add    $0x24,%esp
  801d42:	5b                   	pop    %ebx
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    

00801d45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d50:	b8 08 00 00 00       	mov    $0x8,%eax
  801d55:	e8 94 fd ff ff       	call   801aee <fsipc>
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 10             	sub    $0x10,%esp
  801d64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6a:	89 04 24             	mov    %eax,(%esp)
  801d6d:	e8 ae f7 ff ff       	call   801520 <fd2data>
  801d72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d74:	c7 44 24 04 6d 2f 80 	movl   $0x802f6d,0x4(%esp)
  801d7b:	00 
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 63 ed ff ff       	call   800ae7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d84:	8b 46 04             	mov    0x4(%esi),%eax
  801d87:	2b 06                	sub    (%esi),%eax
  801d89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d96:	00 00 00 
	stat->st_dev = &devpipe;
  801d99:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  801da0:	40 80 00 
	return 0;
}
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	53                   	push   %ebx
  801db3:	83 ec 14             	sub    $0x14,%esp
  801db6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801db9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc4:	e8 e1 f1 ff ff       	call   800faa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dc9:	89 1c 24             	mov    %ebx,(%esp)
  801dcc:	e8 4f f7 ff ff       	call   801520 <fd2data>
  801dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddc:	e8 c9 f1 ff ff       	call   800faa <sys_page_unmap>
}
  801de1:	83 c4 14             	add    $0x14,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	57                   	push   %edi
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	83 ec 2c             	sub    $0x2c,%esp
  801df0:	89 c6                	mov    %eax,%esi
  801df2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801df5:	a1 04 50 80 00       	mov    0x805004,%eax
  801dfa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801dfd:	89 34 24             	mov    %esi,(%esp)
  801e00:	e8 40 07 00 00       	call   802545 <pageref>
  801e05:	89 c7                	mov    %eax,%edi
  801e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e0a:	89 04 24             	mov    %eax,(%esp)
  801e0d:	e8 33 07 00 00       	call   802545 <pageref>
  801e12:	39 c7                	cmp    %eax,%edi
  801e14:	0f 94 c2             	sete   %dl
  801e17:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e1a:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  801e20:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e23:	39 fb                	cmp    %edi,%ebx
  801e25:	74 21                	je     801e48 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e27:	84 d2                	test   %dl,%dl
  801e29:	74 ca                	je     801df5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e2b:	8b 51 58             	mov    0x58(%ecx),%edx
  801e2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e32:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e3a:	c7 04 24 74 2f 80 00 	movl   $0x802f74,(%esp)
  801e41:	e8 24 e6 ff ff       	call   80046a <cprintf>
  801e46:	eb ad                	jmp    801df5 <_pipeisclosed+0xe>
	}
}
  801e48:	83 c4 2c             	add    $0x2c,%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5f                   	pop    %edi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	57                   	push   %edi
  801e54:	56                   	push   %esi
  801e55:	53                   	push   %ebx
  801e56:	83 ec 1c             	sub    $0x1c,%esp
  801e59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e5c:	89 34 24             	mov    %esi,(%esp)
  801e5f:	e8 bc f6 ff ff       	call   801520 <fd2data>
  801e64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	bf 00 00 00 00       	mov    $0x0,%edi
  801e6b:	eb 45                	jmp    801eb2 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e6d:	89 da                	mov    %ebx,%edx
  801e6f:	89 f0                	mov    %esi,%eax
  801e71:	e8 71 ff ff ff       	call   801de7 <_pipeisclosed>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	75 41                	jne    801ebb <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e7a:	e8 65 f0 ff ff       	call   800ee4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801e82:	8b 0b                	mov    (%ebx),%ecx
  801e84:	8d 51 20             	lea    0x20(%ecx),%edx
  801e87:	39 d0                	cmp    %edx,%eax
  801e89:	73 e2                	jae    801e6d <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e95:	99                   	cltd   
  801e96:	c1 ea 1b             	shr    $0x1b,%edx
  801e99:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e9c:	83 e1 1f             	and    $0x1f,%ecx
  801e9f:	29 d1                	sub    %edx,%ecx
  801ea1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ea5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ea9:	83 c0 01             	add    $0x1,%eax
  801eac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaf:	83 c7 01             	add    $0x1,%edi
  801eb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eb5:	75 c8                	jne    801e7f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801eb7:	89 f8                	mov    %edi,%eax
  801eb9:	eb 05                	jmp    801ec0 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ec0:	83 c4 1c             	add    $0x1c,%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	83 ec 1c             	sub    $0x1c,%esp
  801ed1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ed4:	89 3c 24             	mov    %edi,(%esp)
  801ed7:	e8 44 f6 ff ff       	call   801520 <fd2data>
  801edc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ede:	be 00 00 00 00       	mov    $0x0,%esi
  801ee3:	eb 3d                	jmp    801f22 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ee5:	85 f6                	test   %esi,%esi
  801ee7:	74 04                	je     801eed <devpipe_read+0x25>
				return i;
  801ee9:	89 f0                	mov    %esi,%eax
  801eeb:	eb 43                	jmp    801f30 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801eed:	89 da                	mov    %ebx,%edx
  801eef:	89 f8                	mov    %edi,%eax
  801ef1:	e8 f1 fe ff ff       	call   801de7 <_pipeisclosed>
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	75 31                	jne    801f2b <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801efa:	e8 e5 ef ff ff       	call   800ee4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eff:	8b 03                	mov    (%ebx),%eax
  801f01:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f04:	74 df                	je     801ee5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f06:	99                   	cltd   
  801f07:	c1 ea 1b             	shr    $0x1b,%edx
  801f0a:	01 d0                	add    %edx,%eax
  801f0c:	83 e0 1f             	and    $0x1f,%eax
  801f0f:	29 d0                	sub    %edx,%eax
  801f11:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f19:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f1c:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1f:	83 c6 01             	add    $0x1,%esi
  801f22:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f25:	75 d8                	jne    801eff <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f27:	89 f0                	mov    %esi,%eax
  801f29:	eb 05                	jmp    801f30 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 ec f5 ff ff       	call   801537 <fd_alloc>
  801f4b:	89 c2                	mov    %eax,%edx
  801f4d:	85 d2                	test   %edx,%edx
  801f4f:	0f 88 4d 01 00 00    	js     8020a2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f55:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f5c:	00 
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6b:	e8 93 ef ff ff       	call   800f03 <sys_page_alloc>
  801f70:	89 c2                	mov    %eax,%edx
  801f72:	85 d2                	test   %edx,%edx
  801f74:	0f 88 28 01 00 00    	js     8020a2 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7d:	89 04 24             	mov    %eax,(%esp)
  801f80:	e8 b2 f5 ff ff       	call   801537 <fd_alloc>
  801f85:	89 c3                	mov    %eax,%ebx
  801f87:	85 c0                	test   %eax,%eax
  801f89:	0f 88 fe 00 00 00    	js     80208d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f96:	00 
  801f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa5:	e8 59 ef ff ff       	call   800f03 <sys_page_alloc>
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	0f 88 d9 00 00 00    	js     80208d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb7:	89 04 24             	mov    %eax,(%esp)
  801fba:	e8 61 f5 ff ff       	call   801520 <fd2data>
  801fbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc8:	00 
  801fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd4:	e8 2a ef ff ff       	call   800f03 <sys_page_alloc>
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	0f 88 97 00 00 00    	js     80207a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe6:	89 04 24             	mov    %eax,(%esp)
  801fe9:	e8 32 f5 ff ff       	call   801520 <fd2data>
  801fee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ff5:	00 
  801ff6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802001:	00 
  802002:	89 74 24 04          	mov    %esi,0x4(%esp)
  802006:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200d:	e8 45 ef ff ff       	call   800f57 <sys_page_map>
  802012:	89 c3                	mov    %eax,%ebx
  802014:	85 c0                	test   %eax,%eax
  802016:	78 52                	js     80206a <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802018:	8b 15 24 40 80 00    	mov    0x804024,%edx
  80201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802021:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802023:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802026:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80202d:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802036:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802038:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80203b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 c3 f4 ff ff       	call   801510 <fd2num>
  80204d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802050:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802052:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 b3 f4 ff ff       	call   801510 <fd2num>
  80205d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802060:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
  802068:	eb 38                	jmp    8020a2 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80206a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802075:	e8 30 ef ff ff       	call   800faa <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80207a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802088:	e8 1d ef ff ff       	call   800faa <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802090:	89 44 24 04          	mov    %eax,0x4(%esp)
  802094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209b:	e8 0a ef ff ff       	call   800faa <sys_page_unmap>
  8020a0:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8020a2:	83 c4 30             	add    $0x30,%esp
  8020a5:	5b                   	pop    %ebx
  8020a6:	5e                   	pop    %esi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b9:	89 04 24             	mov    %eax,(%esp)
  8020bc:	e8 c5 f4 ff ff       	call   801586 <fd_lookup>
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	85 d2                	test   %edx,%edx
  8020c5:	78 15                	js     8020dc <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 4e f4 ff ff       	call   801520 <fd2data>
	return _pipeisclosed(fd, p);
  8020d2:	89 c2                	mov    %eax,%edx
  8020d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d7:	e8 0b fd ff ff       	call   801de7 <_pipeisclosed>
}
  8020dc:	c9                   	leave  
  8020dd:	c3                   	ret    

008020de <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	56                   	push   %esi
  8020e2:	53                   	push   %ebx
  8020e3:	83 ec 10             	sub    $0x10,%esp
  8020e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8020e9:	85 f6                	test   %esi,%esi
  8020eb:	75 24                	jne    802111 <wait+0x33>
  8020ed:	c7 44 24 0c 8c 2f 80 	movl   $0x802f8c,0xc(%esp)
  8020f4:	00 
  8020f5:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  8020fc:	00 
  8020fd:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802104:	00 
  802105:	c7 04 24 97 2f 80 00 	movl   $0x802f97,(%esp)
  80210c:	e8 60 e2 ff ff       	call   800371 <_panic>
	e = &envs[ENVX(envid)];
  802111:	89 f3                	mov    %esi,%ebx
  802113:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802119:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80211c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802122:	eb 05                	jmp    802129 <wait+0x4b>
		sys_yield();
  802124:	e8 bb ed ff ff       	call   800ee4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802129:	8b 43 48             	mov    0x48(%ebx),%eax
  80212c:	39 f0                	cmp    %esi,%eax
  80212e:	75 07                	jne    802137 <wait+0x59>
  802130:	8b 43 54             	mov    0x54(%ebx),%eax
  802133:	85 c0                	test   %eax,%eax
  802135:	75 ed                	jne    802124 <wait+0x46>
		sys_yield();
}
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	5b                   	pop    %ebx
  80213b:	5e                   	pop    %esi
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    
  80213e:	66 90                	xchg   %ax,%ax

00802140 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    

0080214a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802150:	c7 44 24 04 a2 2f 80 	movl   $0x802fa2,0x4(%esp)
  802157:	00 
  802158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 84 e9 ff ff       	call   800ae7 <strcpy>
	return 0;
}
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	c9                   	leave  
  802169:	c3                   	ret    

0080216a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	57                   	push   %edi
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
  802170:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802176:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802181:	eb 31                	jmp    8021b4 <devcons_write+0x4a>
		m = n - tot;
  802183:	8b 75 10             	mov    0x10(%ebp),%esi
  802186:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802188:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80218b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802190:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802193:	89 74 24 08          	mov    %esi,0x8(%esp)
  802197:	03 45 0c             	add    0xc(%ebp),%eax
  80219a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219e:	89 3c 24             	mov    %edi,(%esp)
  8021a1:	e8 de ea ff ff       	call   800c84 <memmove>
		sys_cputs(buf, m);
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	89 3c 24             	mov    %edi,(%esp)
  8021ad:	e8 84 ec ff ff       	call   800e36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b2:	01 f3                	add    %esi,%ebx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021b9:	72 c8                	jb     802183 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5f                   	pop    %edi
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8021cc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8021d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d5:	75 07                	jne    8021de <devcons_read+0x18>
  8021d7:	eb 2a                	jmp    802203 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d9:	e8 06 ed ff ff       	call   800ee4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	e8 6f ec ff ff       	call   800e54 <sys_cgetc>
  8021e5:	85 c0                	test   %eax,%eax
  8021e7:	74 f0                	je     8021d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 16                	js     802203 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ed:	83 f8 04             	cmp    $0x4,%eax
  8021f0:	74 0c                	je     8021fe <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8021f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f5:	88 02                	mov    %al,(%edx)
	return 1;
  8021f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fc:	eb 05                	jmp    802203 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802211:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802218:	00 
  802219:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	e8 12 ec ff ff       	call   800e36 <sys_cputs>
}
  802224:	c9                   	leave  
  802225:	c3                   	ret    

00802226 <getchar>:

int
getchar(void)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80222c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802233:	00 
  802234:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802242:	e8 ce f5 ff ff       	call   801815 <read>
	if (r < 0)
  802247:	85 c0                	test   %eax,%eax
  802249:	78 0f                	js     80225a <getchar+0x34>
		return r;
	if (r < 1)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	7e 06                	jle    802255 <getchar+0x2f>
		return -E_EOF;
	return c;
  80224f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802253:	eb 05                	jmp    80225a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802255:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802265:	89 44 24 04          	mov    %eax,0x4(%esp)
  802269:	8b 45 08             	mov    0x8(%ebp),%eax
  80226c:	89 04 24             	mov    %eax,(%esp)
  80226f:	e8 12 f3 ff ff       	call   801586 <fd_lookup>
  802274:	85 c0                	test   %eax,%eax
  802276:	78 11                	js     802289 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802281:	39 10                	cmp    %edx,(%eax)
  802283:	0f 94 c0             	sete   %al
  802286:	0f b6 c0             	movzbl %al,%eax
}
  802289:	c9                   	leave  
  80228a:	c3                   	ret    

0080228b <opencons>:

int
opencons(void)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802294:	89 04 24             	mov    %eax,(%esp)
  802297:	e8 9b f2 ff ff       	call   801537 <fd_alloc>
		return r;
  80229c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	78 40                	js     8022e2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022a9:	00 
  8022aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b8:	e8 46 ec ff ff       	call   800f03 <sys_page_alloc>
		return r;
  8022bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 1f                	js     8022e2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c3:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022d8:	89 04 24             	mov    %eax,(%esp)
  8022db:	e8 30 f2 ff ff       	call   801510 <fd2num>
  8022e0:	89 c2                	mov    %eax,%edx
}
  8022e2:	89 d0                	mov    %edx,%eax
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    

008022e6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022ec:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022f3:	75 44                	jne    802339 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8022f5:	a1 04 50 80 00       	mov    0x805004,%eax
  8022fa:	8b 40 48             	mov    0x48(%eax),%eax
  8022fd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802304:	00 
  802305:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80230c:	ee 
  80230d:	89 04 24             	mov    %eax,(%esp)
  802310:	e8 ee eb ff ff       	call   800f03 <sys_page_alloc>
		if( r < 0)
  802315:	85 c0                	test   %eax,%eax
  802317:	79 20                	jns    802339 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  802319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231d:	c7 44 24 08 b0 2f 80 	movl   $0x802fb0,0x8(%esp)
  802324:	00 
  802325:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80232c:	00 
  80232d:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  802334:	e8 38 e0 ff ff       	call   800371 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802339:	8b 45 08             	mov    0x8(%ebp),%eax
  80233c:	a3 00 70 80 00       	mov    %eax,0x807000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  802341:	e8 7f eb ff ff       	call   800ec5 <sys_getenvid>
  802346:	c7 44 24 04 7c 23 80 	movl   $0x80237c,0x4(%esp)
  80234d:	00 
  80234e:	89 04 24             	mov    %eax,(%esp)
  802351:	e8 4d ed ff ff       	call   8010a3 <sys_env_set_pgfault_upcall>
  802356:	85 c0                	test   %eax,%eax
  802358:	79 20                	jns    80237a <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80235a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80235e:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  802365:	00 
  802366:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80236d:	00 
  80236e:	c7 04 24 0c 30 80 00 	movl   $0x80300c,(%esp)
  802375:	e8 f7 df ff ff       	call   800371 <_panic>


}
  80237a:	c9                   	leave  
  80237b:	c3                   	ret    

0080237c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80237c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80237d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802382:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802384:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  802387:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  80238b:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  80238f:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  802393:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  802396:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  802399:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  80239c:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8023a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8023a4:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8023a8:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8023ac:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8023b0:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8023b4:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8023b8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  8023b9:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  8023ba:	c3                   	ret    
  8023bb:	66 90                	xchg   %ax,%ax
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

008023c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	56                   	push   %esi
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 10             	sub    $0x10,%esp
  8023c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8023cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	75 0e                	jne    8023e3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8023d5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8023dc:	e8 38 ed ff ff       	call   801119 <sys_ipc_recv>
  8023e1:	eb 08                	jmp    8023eb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8023e3:	89 04 24             	mov    %eax,(%esp)
  8023e6:	e8 2e ed ff ff       	call   801119 <sys_ipc_recv>
	if(r == 0){
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	75 1e                	jne    802410 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8023f2:	85 f6                	test   %esi,%esi
  8023f4:	74 0a                	je     802400 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8023f6:	a1 04 50 80 00       	mov    0x805004,%eax
  8023fb:	8b 40 74             	mov    0x74(%eax),%eax
  8023fe:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802400:	85 db                	test   %ebx,%ebx
  802402:	74 2c                	je     802430 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802404:	a1 04 50 80 00       	mov    0x805004,%eax
  802409:	8b 40 78             	mov    0x78(%eax),%eax
  80240c:	89 03                	mov    %eax,(%ebx)
  80240e:	eb 20                	jmp    802430 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802414:	c7 44 24 08 1c 30 80 	movl   $0x80301c,0x8(%esp)
  80241b:	00 
  80241c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802423:	00 
  802424:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  80242b:	e8 41 df ff ff       	call   800371 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802430:	a1 04 50 80 00       	mov    0x805004,%eax
  802435:	8b 50 70             	mov    0x70(%eax),%edx
  802438:	85 d2                	test   %edx,%edx
  80243a:	75 13                	jne    80244f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80243c:	8b 40 48             	mov    0x48(%eax),%eax
  80243f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802443:	c7 04 24 4c 30 80 00 	movl   $0x80304c,(%esp)
  80244a:	e8 1b e0 ff ff       	call   80046a <cprintf>
	return thisenv->env_ipc_value;
  80244f:	a1 04 50 80 00       	mov    0x805004,%eax
  802454:	8b 40 70             	mov    0x70(%eax),%eax
}
  802457:	83 c4 10             	add    $0x10,%esp
  80245a:	5b                   	pop    %ebx
  80245b:	5e                   	pop    %esi
  80245c:	5d                   	pop    %ebp
  80245d:	c3                   	ret    

0080245e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 7d 08             	mov    0x8(%ebp),%edi
  80246a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80246d:	85 f6                	test   %esi,%esi
  80246f:	75 22                	jne    802493 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802471:	8b 45 14             	mov    0x14(%ebp),%eax
  802474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802478:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80247f:	ee 
  802480:	8b 45 0c             	mov    0xc(%ebp),%eax
  802483:	89 44 24 04          	mov    %eax,0x4(%esp)
  802487:	89 3c 24             	mov    %edi,(%esp)
  80248a:	e8 67 ec ff ff       	call   8010f6 <sys_ipc_try_send>
  80248f:	89 c3                	mov    %eax,%ebx
  802491:	eb 1c                	jmp    8024af <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802493:	8b 45 14             	mov    0x14(%ebp),%eax
  802496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80249e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a5:	89 3c 24             	mov    %edi,(%esp)
  8024a8:	e8 49 ec ff ff       	call   8010f6 <sys_ipc_try_send>
  8024ad:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8024af:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8024b2:	74 3e                	je     8024f2 <ipc_send+0x94>
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	c1 e8 1f             	shr    $0x1f,%eax
  8024b9:	84 c0                	test   %al,%al
  8024bb:	74 35                	je     8024f2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  8024bd:	e8 03 ea ff ff       	call   800ec5 <sys_getenvid>
  8024c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c6:	c7 04 24 a2 30 80 00 	movl   $0x8030a2,(%esp)
  8024cd:	e8 98 df ff ff       	call   80046a <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8024d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024d6:	c7 44 24 08 70 30 80 	movl   $0x803070,0x8(%esp)
  8024dd:	00 
  8024de:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8024e5:	00 
  8024e6:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  8024ed:	e8 7f de ff ff       	call   800371 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8024f2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8024f5:	75 0e                	jne    802505 <ipc_send+0xa7>
			sys_yield();
  8024f7:	e8 e8 e9 ff ff       	call   800ee4 <sys_yield>
		else break;
	}
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	e9 68 ff ff ff       	jmp    80246d <ipc_send+0xf>
	
}
  802505:	83 c4 1c             	add    $0x1c,%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802518:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80251b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802521:	8b 52 50             	mov    0x50(%edx),%edx
  802524:	39 ca                	cmp    %ecx,%edx
  802526:	75 0d                	jne    802535 <ipc_find_env+0x28>
			return envs[i].env_id;
  802528:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80252b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802530:	8b 40 40             	mov    0x40(%eax),%eax
  802533:	eb 0e                	jmp    802543 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802535:	83 c0 01             	add    $0x1,%eax
  802538:	3d 00 04 00 00       	cmp    $0x400,%eax
  80253d:	75 d9                	jne    802518 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80253f:	66 b8 00 00          	mov    $0x0,%ax
}
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    

00802545 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802545:	55                   	push   %ebp
  802546:	89 e5                	mov    %esp,%ebp
  802548:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	c1 e8 16             	shr    $0x16,%eax
  802550:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802557:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255c:	f6 c1 01             	test   $0x1,%cl
  80255f:	74 1d                	je     80257e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802561:	c1 ea 0c             	shr    $0xc,%edx
  802564:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80256b:	f6 c2 01             	test   $0x1,%dl
  80256e:	74 0e                	je     80257e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802570:	c1 ea 0c             	shr    $0xc,%edx
  802573:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80257a:	ef 
  80257b:	0f b7 c0             	movzwl %ax,%eax
}
  80257e:	5d                   	pop    %ebp
  80257f:	c3                   	ret    

00802580 <__udivdi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	83 ec 0c             	sub    $0xc,%esp
  802586:	8b 44 24 28          	mov    0x28(%esp),%eax
  80258a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80258e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802592:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802596:	85 c0                	test   %eax,%eax
  802598:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80259c:	89 ea                	mov    %ebp,%edx
  80259e:	89 0c 24             	mov    %ecx,(%esp)
  8025a1:	75 2d                	jne    8025d0 <__udivdi3+0x50>
  8025a3:	39 e9                	cmp    %ebp,%ecx
  8025a5:	77 61                	ja     802608 <__udivdi3+0x88>
  8025a7:	85 c9                	test   %ecx,%ecx
  8025a9:	89 ce                	mov    %ecx,%esi
  8025ab:	75 0b                	jne    8025b8 <__udivdi3+0x38>
  8025ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b2:	31 d2                	xor    %edx,%edx
  8025b4:	f7 f1                	div    %ecx
  8025b6:	89 c6                	mov    %eax,%esi
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	89 e8                	mov    %ebp,%eax
  8025bc:	f7 f6                	div    %esi
  8025be:	89 c5                	mov    %eax,%ebp
  8025c0:	89 f8                	mov    %edi,%eax
  8025c2:	f7 f6                	div    %esi
  8025c4:	89 ea                	mov    %ebp,%edx
  8025c6:	83 c4 0c             	add    $0xc,%esp
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	39 e8                	cmp    %ebp,%eax
  8025d2:	77 24                	ja     8025f8 <__udivdi3+0x78>
  8025d4:	0f bd e8             	bsr    %eax,%ebp
  8025d7:	83 f5 1f             	xor    $0x1f,%ebp
  8025da:	75 3c                	jne    802618 <__udivdi3+0x98>
  8025dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025e0:	39 34 24             	cmp    %esi,(%esp)
  8025e3:	0f 86 9f 00 00 00    	jbe    802688 <__udivdi3+0x108>
  8025e9:	39 d0                	cmp    %edx,%eax
  8025eb:	0f 82 97 00 00 00    	jb     802688 <__udivdi3+0x108>
  8025f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	31 d2                	xor    %edx,%edx
  8025fa:	31 c0                	xor    %eax,%eax
  8025fc:	83 c4 0c             	add    $0xc,%esp
  8025ff:	5e                   	pop    %esi
  802600:	5f                   	pop    %edi
  802601:	5d                   	pop    %ebp
  802602:	c3                   	ret    
  802603:	90                   	nop
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	89 f8                	mov    %edi,%eax
  80260a:	f7 f1                	div    %ecx
  80260c:	31 d2                	xor    %edx,%edx
  80260e:	83 c4 0c             	add    $0xc,%esp
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	8b 3c 24             	mov    (%esp),%edi
  80261d:	d3 e0                	shl    %cl,%eax
  80261f:	89 c6                	mov    %eax,%esi
  802621:	b8 20 00 00 00       	mov    $0x20,%eax
  802626:	29 e8                	sub    %ebp,%eax
  802628:	89 c1                	mov    %eax,%ecx
  80262a:	d3 ef                	shr    %cl,%edi
  80262c:	89 e9                	mov    %ebp,%ecx
  80262e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802632:	8b 3c 24             	mov    (%esp),%edi
  802635:	09 74 24 08          	or     %esi,0x8(%esp)
  802639:	89 d6                	mov    %edx,%esi
  80263b:	d3 e7                	shl    %cl,%edi
  80263d:	89 c1                	mov    %eax,%ecx
  80263f:	89 3c 24             	mov    %edi,(%esp)
  802642:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802646:	d3 ee                	shr    %cl,%esi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	d3 e2                	shl    %cl,%edx
  80264c:	89 c1                	mov    %eax,%ecx
  80264e:	d3 ef                	shr    %cl,%edi
  802650:	09 d7                	or     %edx,%edi
  802652:	89 f2                	mov    %esi,%edx
  802654:	89 f8                	mov    %edi,%eax
  802656:	f7 74 24 08          	divl   0x8(%esp)
  80265a:	89 d6                	mov    %edx,%esi
  80265c:	89 c7                	mov    %eax,%edi
  80265e:	f7 24 24             	mull   (%esp)
  802661:	39 d6                	cmp    %edx,%esi
  802663:	89 14 24             	mov    %edx,(%esp)
  802666:	72 30                	jb     802698 <__udivdi3+0x118>
  802668:	8b 54 24 04          	mov    0x4(%esp),%edx
  80266c:	89 e9                	mov    %ebp,%ecx
  80266e:	d3 e2                	shl    %cl,%edx
  802670:	39 c2                	cmp    %eax,%edx
  802672:	73 05                	jae    802679 <__udivdi3+0xf9>
  802674:	3b 34 24             	cmp    (%esp),%esi
  802677:	74 1f                	je     802698 <__udivdi3+0x118>
  802679:	89 f8                	mov    %edi,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	e9 7a ff ff ff       	jmp    8025fc <__udivdi3+0x7c>
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 d2                	xor    %edx,%edx
  80268a:	b8 01 00 00 00       	mov    $0x1,%eax
  80268f:	e9 68 ff ff ff       	jmp    8025fc <__udivdi3+0x7c>
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	8d 47 ff             	lea    -0x1(%edi),%eax
  80269b:	31 d2                	xor    %edx,%edx
  80269d:	83 c4 0c             	add    $0xc,%esp
  8026a0:	5e                   	pop    %esi
  8026a1:	5f                   	pop    %edi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__umoddi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	83 ec 14             	sub    $0x14,%esp
  8026b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8026ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8026be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8026c2:	89 c7                	mov    %eax,%edi
  8026c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8026d0:	89 34 24             	mov    %esi,(%esp)
  8026d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026d7:	85 c0                	test   %eax,%eax
  8026d9:	89 c2                	mov    %eax,%edx
  8026db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026df:	75 17                	jne    8026f8 <__umoddi3+0x48>
  8026e1:	39 fe                	cmp    %edi,%esi
  8026e3:	76 4b                	jbe    802730 <__umoddi3+0x80>
  8026e5:	89 c8                	mov    %ecx,%eax
  8026e7:	89 fa                	mov    %edi,%edx
  8026e9:	f7 f6                	div    %esi
  8026eb:	89 d0                	mov    %edx,%eax
  8026ed:	31 d2                	xor    %edx,%edx
  8026ef:	83 c4 14             	add    $0x14,%esp
  8026f2:	5e                   	pop    %esi
  8026f3:	5f                   	pop    %edi
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    
  8026f6:	66 90                	xchg   %ax,%ax
  8026f8:	39 f8                	cmp    %edi,%eax
  8026fa:	77 54                	ja     802750 <__umoddi3+0xa0>
  8026fc:	0f bd e8             	bsr    %eax,%ebp
  8026ff:	83 f5 1f             	xor    $0x1f,%ebp
  802702:	75 5c                	jne    802760 <__umoddi3+0xb0>
  802704:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802708:	39 3c 24             	cmp    %edi,(%esp)
  80270b:	0f 87 e7 00 00 00    	ja     8027f8 <__umoddi3+0x148>
  802711:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802715:	29 f1                	sub    %esi,%ecx
  802717:	19 c7                	sbb    %eax,%edi
  802719:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80271d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802721:	8b 44 24 08          	mov    0x8(%esp),%eax
  802725:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802729:	83 c4 14             	add    $0x14,%esp
  80272c:	5e                   	pop    %esi
  80272d:	5f                   	pop    %edi
  80272e:	5d                   	pop    %ebp
  80272f:	c3                   	ret    
  802730:	85 f6                	test   %esi,%esi
  802732:	89 f5                	mov    %esi,%ebp
  802734:	75 0b                	jne    802741 <__umoddi3+0x91>
  802736:	b8 01 00 00 00       	mov    $0x1,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	f7 f6                	div    %esi
  80273f:	89 c5                	mov    %eax,%ebp
  802741:	8b 44 24 04          	mov    0x4(%esp),%eax
  802745:	31 d2                	xor    %edx,%edx
  802747:	f7 f5                	div    %ebp
  802749:	89 c8                	mov    %ecx,%eax
  80274b:	f7 f5                	div    %ebp
  80274d:	eb 9c                	jmp    8026eb <__umoddi3+0x3b>
  80274f:	90                   	nop
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 fa                	mov    %edi,%edx
  802754:	83 c4 14             	add    $0x14,%esp
  802757:	5e                   	pop    %esi
  802758:	5f                   	pop    %edi
  802759:	5d                   	pop    %ebp
  80275a:	c3                   	ret    
  80275b:	90                   	nop
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	8b 04 24             	mov    (%esp),%eax
  802763:	be 20 00 00 00       	mov    $0x20,%esi
  802768:	89 e9                	mov    %ebp,%ecx
  80276a:	29 ee                	sub    %ebp,%esi
  80276c:	d3 e2                	shl    %cl,%edx
  80276e:	89 f1                	mov    %esi,%ecx
  802770:	d3 e8                	shr    %cl,%eax
  802772:	89 e9                	mov    %ebp,%ecx
  802774:	89 44 24 04          	mov    %eax,0x4(%esp)
  802778:	8b 04 24             	mov    (%esp),%eax
  80277b:	09 54 24 04          	or     %edx,0x4(%esp)
  80277f:	89 fa                	mov    %edi,%edx
  802781:	d3 e0                	shl    %cl,%eax
  802783:	89 f1                	mov    %esi,%ecx
  802785:	89 44 24 08          	mov    %eax,0x8(%esp)
  802789:	8b 44 24 10          	mov    0x10(%esp),%eax
  80278d:	d3 ea                	shr    %cl,%edx
  80278f:	89 e9                	mov    %ebp,%ecx
  802791:	d3 e7                	shl    %cl,%edi
  802793:	89 f1                	mov    %esi,%ecx
  802795:	d3 e8                	shr    %cl,%eax
  802797:	89 e9                	mov    %ebp,%ecx
  802799:	09 f8                	or     %edi,%eax
  80279b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80279f:	f7 74 24 04          	divl   0x4(%esp)
  8027a3:	d3 e7                	shl    %cl,%edi
  8027a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027a9:	89 d7                	mov    %edx,%edi
  8027ab:	f7 64 24 08          	mull   0x8(%esp)
  8027af:	39 d7                	cmp    %edx,%edi
  8027b1:	89 c1                	mov    %eax,%ecx
  8027b3:	89 14 24             	mov    %edx,(%esp)
  8027b6:	72 2c                	jb     8027e4 <__umoddi3+0x134>
  8027b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8027bc:	72 22                	jb     8027e0 <__umoddi3+0x130>
  8027be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027c2:	29 c8                	sub    %ecx,%eax
  8027c4:	19 d7                	sbb    %edx,%edi
  8027c6:	89 e9                	mov    %ebp,%ecx
  8027c8:	89 fa                	mov    %edi,%edx
  8027ca:	d3 e8                	shr    %cl,%eax
  8027cc:	89 f1                	mov    %esi,%ecx
  8027ce:	d3 e2                	shl    %cl,%edx
  8027d0:	89 e9                	mov    %ebp,%ecx
  8027d2:	d3 ef                	shr    %cl,%edi
  8027d4:	09 d0                	or     %edx,%eax
  8027d6:	89 fa                	mov    %edi,%edx
  8027d8:	83 c4 14             	add    $0x14,%esp
  8027db:	5e                   	pop    %esi
  8027dc:	5f                   	pop    %edi
  8027dd:	5d                   	pop    %ebp
  8027de:	c3                   	ret    
  8027df:	90                   	nop
  8027e0:	39 d7                	cmp    %edx,%edi
  8027e2:	75 da                	jne    8027be <__umoddi3+0x10e>
  8027e4:	8b 14 24             	mov    (%esp),%edx
  8027e7:	89 c1                	mov    %eax,%ecx
  8027e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8027ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8027f1:	eb cb                	jmp    8027be <__umoddi3+0x10e>
  8027f3:	90                   	nop
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8027fc:	0f 82 0f ff ff ff    	jb     802711 <__umoddi3+0x61>
  802802:	e9 1a ff ff ff       	jmp    802721 <__umoddi3+0x71>
