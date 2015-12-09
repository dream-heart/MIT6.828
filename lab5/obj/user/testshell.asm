
obj/user/testshell.debug：     文件格式 elf32-i386


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
  80002c:	e8 15 05 00 00       	call   800546 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004c:	89 34 24             	mov    %esi,(%esp)
  80004f:	e8 5b 1b 00 00       	call   801baf <seek>
	seek(kfd, off);
  800054:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800058:	89 3c 24             	mov    %edi,(%esp)
  80005b:	e8 4f 1b 00 00       	call   801baf <seek>

	cprintf("shell produced incorrect output.\n");
  800060:	c7 04 24 60 2e 80 00 	movl   $0x802e60,(%esp)
  800067:	e8 2f 06 00 00       	call   80069b <cprintf>
	cprintf("expected:\n===\n");
  80006c:	c7 04 24 cb 2e 80 00 	movl   $0x802ecb,(%esp)
  800073:	e8 23 06 00 00       	call   80069b <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800078:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007b:	eb 0c                	jmp    800089 <wrong+0x56>
		sys_cputs(buf, n);
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	89 1c 24             	mov    %ebx,(%esp)
  800084:	e8 dd 0f 00 00       	call   801066 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800089:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800090:	00 
  800091:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800095:	89 3c 24             	mov    %edi,(%esp)
  800098:	e8 a8 19 00 00       	call   801a45 <read>
  80009d:	85 c0                	test   %eax,%eax
  80009f:	7f dc                	jg     80007d <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a1:	c7 04 24 da 2e 80 00 	movl   $0x802eda,(%esp)
  8000a8:	e8 ee 05 00 00       	call   80069b <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ad:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b0:	eb 0c                	jmp    8000be <wrong+0x8b>
		sys_cputs(buf, n);
  8000b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b6:	89 1c 24             	mov    %ebx,(%esp)
  8000b9:	e8 a8 0f 00 00       	call   801066 <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000be:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c5:	00 
  8000c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ca:	89 34 24             	mov    %esi,(%esp)
  8000cd:	e8 73 19 00 00       	call   801a45 <read>
  8000d2:	85 c0                	test   %eax,%eax
  8000d4:	7f dc                	jg     8000b2 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d6:	c7 04 24 d5 2e 80 00 	movl   $0x802ed5,(%esp)
  8000dd:	e8 b9 05 00 00       	call   80069b <cprintf>
	exit();
  8000e2:	e8 a7 04 00 00       	call   80058e <exit>
}
  8000e7:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 db 17 00 00       	call   8018e2 <close>
	close(1);
  800107:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010e:	e8 cf 17 00 00       	call   8018e2 <close>
	opencons();
  800113:	e8 d3 03 00 00       	call   8004eb <opencons>
	opencons();
  800118:	e8 ce 03 00 00       	call   8004eb <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800124:	00 
  800125:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  80012c:	e8 c0 1d 00 00       	call   801ef1 <open>
  800131:	89 c3                	mov    %eax,%ebx
  800133:	85 c0                	test   %eax,%eax
  800135:	79 20                	jns    800157 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	c7 44 24 08 f5 2e 80 	movl   $0x802ef5,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  800152:	e8 4b 04 00 00       	call   8005a2 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800157:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 b8 25 00 00       	call   80271a <pipe>
  800162:	85 c0                	test   %eax,%eax
  800164:	79 20                	jns    800186 <umain+0x94>
		panic("pipe: %e", wfd);
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	c7 44 24 08 1c 2f 80 	movl   $0x802f1c,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  800181:	e8 1c 04 00 00       	call   8005a2 <_panic>
	wfd = pfds[1];
  800186:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800189:	c7 04 24 84 2e 80 00 	movl   $0x802e84,(%esp)
  800190:	e8 06 05 00 00       	call   80069b <cprintf>
	if ((r = fork()) < 0)
  800195:	e8 6b 13 00 00       	call   801505 <fork>
  80019a:	85 c0                	test   %eax,%eax
  80019c:	79 20                	jns    8001be <umain+0xcc>
		panic("fork: %e", r);
  80019e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a2:	c7 44 24 08 25 2f 80 	movl   $0x802f25,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b1:	00 
  8001b2:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  8001b9:	e8 e4 03 00 00       	call   8005a2 <_panic>
	if (r == 0) {
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	0f 85 9f 00 00 00    	jne    800265 <umain+0x173>
		dup(rfd, 0);
  8001c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001cd:	00 
  8001ce:	89 1c 24             	mov    %ebx,(%esp)
  8001d1:	e8 61 17 00 00       	call   801937 <dup>
		dup(wfd, 1);
  8001d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001dd:	00 
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 51 17 00 00       	call   801937 <dup>
		close(rfd);
  8001e6:	89 1c 24             	mov    %ebx,(%esp)
  8001e9:	e8 f4 16 00 00       	call   8018e2 <close>
		close(wfd);
  8001ee:	89 34 24             	mov    %esi,(%esp)
  8001f1:	e8 ec 16 00 00       	call   8018e2 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 08 2e 2f 80 	movl   $0x802f2e,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 f2 2e 80 	movl   $0x802ef2,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 31 2f 80 00 	movl   $0x802f31,(%esp)
  800215:	e8 ad 22 00 00       	call   8024c7 <spawnl>
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	85 c0                	test   %eax,%eax
  80021e:	79 20                	jns    800240 <umain+0x14e>
			panic("spawn: %e", r);
  800220:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800224:	c7 44 24 08 35 2f 80 	movl   $0x802f35,0x8(%esp)
  80022b:	00 
  80022c:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800233:	00 
  800234:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  80023b:	e8 62 03 00 00       	call   8005a2 <_panic>
		close(0);
  800240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800247:	e8 96 16 00 00       	call   8018e2 <close>
		close(1);
  80024c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800253:	e8 8a 16 00 00       	call   8018e2 <close>
		wait(r);
  800258:	89 3c 24             	mov    %edi,(%esp)
  80025b:	e8 60 26 00 00       	call   8028c0 <wait>
		exit();
  800260:	e8 29 03 00 00       	call   80058e <exit>
	}
	close(rfd);
  800265:	89 1c 24             	mov    %ebx,(%esp)
  800268:	e8 75 16 00 00       	call   8018e2 <close>
	close(wfd);
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 6d 16 00 00       	call   8018e2 <close>

	rfd = pfds[0];
  800275:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800278:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  80027b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800282:	00 
  800283:	c7 04 24 3f 2f 80 00 	movl   $0x802f3f,(%esp)
  80028a:	e8 62 1c 00 00       	call   801ef1 <open>
  80028f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800292:	85 c0                	test   %eax,%eax
  800294:	79 20                	jns    8002b6 <umain+0x1c4>
		panic("open testshell.key for reading: %e", kfd);
  800296:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029a:	c7 44 24 08 a8 2e 80 	movl   $0x802ea8,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  8002b1:	e8 ec 02 00 00       	call   8005a2 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b6:	be 01 00 00 00       	mov    $0x1,%esi
  8002bb:	bf 00 00 00 00       	mov    $0x0,%edi
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c7:	00 
  8002c8:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	e8 6b 17 00 00       	call   801a45 <read>
  8002da:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e3:	00 
  8002e4:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	e8 4f 17 00 00       	call   801a45 <read>
		if (n1 < 0)
  8002f6:	85 db                	test   %ebx,%ebx
  8002f8:	79 20                	jns    80031a <umain+0x228>
			panic("reading testshell.out: %e", n1);
  8002fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002fe:	c7 44 24 08 4d 2f 80 	movl   $0x802f4d,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  800315:	e8 88 02 00 00       	call   8005a2 <_panic>
		if (n2 < 0)
  80031a:	85 c0                	test   %eax,%eax
  80031c:	79 20                	jns    80033e <umain+0x24c>
			panic("reading testshell.key: %e", n2);
  80031e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800322:	c7 44 24 08 67 2f 80 	movl   $0x802f67,0x8(%esp)
  800329:	00 
  80032a:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800331:	00 
  800332:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  800339:	e8 64 02 00 00       	call   8005a2 <_panic>
		if (n1 == 0 && n2 == 0)
  80033e:	89 c2                	mov    %eax,%edx
  800340:	09 da                	or     %ebx,%edx
  800342:	74 38                	je     80037c <umain+0x28a>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800344:	83 fb 01             	cmp    $0x1,%ebx
  800347:	75 0e                	jne    800357 <umain+0x265>
  800349:	83 f8 01             	cmp    $0x1,%eax
  80034c:	75 09                	jne    800357 <umain+0x265>
  80034e:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  800352:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800355:	74 16                	je     80036d <umain+0x27b>
			wrong(rfd, kfd, nloff);
  800357:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80035b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80035e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800362:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	e8 c6 fc ff ff       	call   800033 <wrong>
		if (c1 == '\n')
			nloff = off+1;
  80036d:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  800371:	0f 44 fe             	cmove  %esi,%edi
  800374:	83 c6 01             	add    $0x1,%esi
	}
  800377:	e9 44 ff ff ff       	jmp    8002c0 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 81 2f 80 00 	movl   $0x802f81,(%esp)
  800383:	e8 13 03 00 00       	call   80069b <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	66 90                	xchg   %ax,%ax
  800393:	66 90                	xchg   %ax,%ax
  800395:	66 90                	xchg   %ax,%ax
  800397:	66 90                	xchg   %ax,%ax
  800399:	66 90                	xchg   %ax,%ax
  80039b:	66 90                	xchg   %ax,%ax
  80039d:	66 90                	xchg   %ax,%ax
  80039f:	90                   	nop

008003a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003b0:	c7 44 24 04 96 2f 80 	movl   $0x802f96,0x4(%esp)
  8003b7:	00 
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 54 09 00 00       	call   800d17 <strcpy>
	return 0;
}
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003e1:	eb 31                	jmp    800414 <devcons_write+0x4a>
		m = n - tot;
  8003e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003e8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8003eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8003f0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003f7:	03 45 0c             	add    0xc(%ebp),%eax
  8003fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fe:	89 3c 24             	mov    %edi,(%esp)
  800401:	e8 ae 0a 00 00       	call   800eb4 <memmove>
		sys_cputs(buf, m);
  800406:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040a:	89 3c 24             	mov    %edi,(%esp)
  80040d:	e8 54 0c 00 00       	call   801066 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800412:	01 f3                	add    %esi,%ebx
  800414:	89 d8                	mov    %ebx,%eax
  800416:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800419:	72 c8                	jb     8003e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80041b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800421:	5b                   	pop    %ebx
  800422:	5e                   	pop    %esi
  800423:	5f                   	pop    %edi
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800431:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800435:	75 07                	jne    80043e <devcons_read+0x18>
  800437:	eb 2a                	jmp    800463 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800439:	e8 d6 0c 00 00       	call   801114 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80043e:	66 90                	xchg   %ax,%ax
  800440:	e8 3f 0c 00 00       	call   801084 <sys_cgetc>
  800445:	85 c0                	test   %eax,%eax
  800447:	74 f0                	je     800439 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800449:	85 c0                	test   %eax,%eax
  80044b:	78 16                	js     800463 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80044d:	83 f8 04             	cmp    $0x4,%eax
  800450:	74 0c                	je     80045e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	88 02                	mov    %al,(%edx)
	return 1;
  800457:	b8 01 00 00 00       	mov    $0x1,%eax
  80045c:	eb 05                	jmp    800463 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800471:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800478:	00 
  800479:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 e2 0b 00 00       	call   801066 <sys_cputs>
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <getchar>:

int
getchar(void)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80048c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800493:	00 
  800494:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004a2:	e8 9e 15 00 00       	call   801a45 <read>
	if (r < 0)
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	78 0f                	js     8004ba <getchar+0x34>
		return r;
	if (r < 1)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	7e 06                	jle    8004b5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8004af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004b3:	eb 05                	jmp    8004ba <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 e2 12 00 00       	call   8017b6 <fd_lookup>
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 11                	js     8004e9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004db:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004e1:	39 10                	cmp    %edx,(%eax)
  8004e3:	0f 94 c0             	sete   %al
  8004e6:	0f b6 c0             	movzbl %al,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <opencons>:

int
opencons(void)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 6b 12 00 00       	call   801767 <fd_alloc>
		return r;
  8004fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 40                	js     800542 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800502:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800509:	00 
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800518:	e8 16 0c 00 00       	call   801133 <sys_page_alloc>
		return r;
  80051d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 1f                	js     800542 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800523:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80052c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80052e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800531:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 00 12 00 00       	call   801740 <fd2num>
  800540:	89 c2                	mov    %eax,%edx
}
  800542:	89 d0                	mov    %edx,%eax
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 10             	sub    $0x10,%esp
  80054e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800551:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800554:	e8 9c 0b 00 00       	call   8010f5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800559:	25 ff 03 00 00       	and    $0x3ff,%eax
  80055e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800561:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800566:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7e 07                	jle    800576 <libmain+0x30>
		binaryname = argv[0];
  80056f:	8b 06                	mov    (%esi),%eax
  800571:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 70 fb ff ff       	call   8000f2 <umain>

	// exit gracefully
	exit();
  800582:	e8 07 00 00 00       	call   80058e <exit>
}
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5d                   	pop    %ebp
  80058d:	c3                   	ret    

0080058e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800594:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059b:	e8 03 0b 00 00       	call   8010a3 <sys_env_destroy>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	56                   	push   %esi
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ad:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8005b3:	e8 3d 0b 00 00       	call   8010f5 <sys_getenvid>
  8005b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8005ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ce:	c7 04 24 ac 2f 80 00 	movl   $0x802fac,(%esp)
  8005d5:	e8 c1 00 00 00       	call   80069b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005de:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e1:	89 04 24             	mov    %eax,(%esp)
  8005e4:	e8 51 00 00 00       	call   80063a <vcprintf>
	cprintf("\n");
  8005e9:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
  8005f0:	e8 a6 00 00 00       	call   80069b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f5:	cc                   	int3   
  8005f6:	eb fd                	jmp    8005f5 <_panic+0x53>

008005f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 14             	sub    $0x14,%esp
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800602:	8b 13                	mov    (%ebx),%edx
  800604:	8d 42 01             	lea    0x1(%edx),%eax
  800607:	89 03                	mov    %eax,(%ebx)
  800609:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80060c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800610:	3d ff 00 00 00       	cmp    $0xff,%eax
  800615:	75 19                	jne    800630 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800617:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80061e:	00 
  80061f:	8d 43 08             	lea    0x8(%ebx),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	e8 3c 0a 00 00       	call   801066 <sys_cputs>
		b->idx = 0;
  80062a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800630:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800634:	83 c4 14             	add    $0x14,%esp
  800637:	5b                   	pop    %ebx
  800638:	5d                   	pop    %ebp
  800639:	c3                   	ret    

0080063a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800643:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064a:	00 00 00 
	b.cnt = 0;
  80064d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800654:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	89 44 24 08          	mov    %eax,0x8(%esp)
  800665:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066f:	c7 04 24 f8 05 80 00 	movl   $0x8005f8,(%esp)
  800676:	e8 79 01 00 00       	call   8007f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80067b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800681:	89 44 24 04          	mov    %eax,0x4(%esp)
  800685:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	e8 d3 09 00 00       	call   801066 <sys_cputs>

	return b.cnt;
}
  800693:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800699:	c9                   	leave  
  80069a:	c3                   	ret    

0080069b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 87 ff ff ff       	call   80063a <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    
  8006b5:	66 90                	xchg   %ax,%ax
  8006b7:	66 90                	xchg   %ax,%ax
  8006b9:	66 90                	xchg   %ax,%ax
  8006bb:	66 90                	xchg   %ax,%ax
  8006bd:	66 90                	xchg   %ax,%ax
  8006bf:	90                   	nop

008006c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	83 ec 3c             	sub    $0x3c,%esp
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cc:	89 d7                	mov    %edx,%edi
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d7:	89 c3                	mov    %eax,%ebx
  8006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8006df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ed:	39 d9                	cmp    %ebx,%ecx
  8006ef:	72 05                	jb     8006f6 <printnum+0x36>
  8006f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8006f4:	77 69                	ja     80075f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006fd:	83 ee 01             	sub    $0x1,%esi
  800700:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800704:	89 44 24 08          	mov    %eax,0x8(%esp)
  800708:	8b 44 24 08          	mov    0x8(%esp),%eax
  80070c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800710:	89 c3                	mov    %eax,%ebx
  800712:	89 d6                	mov    %edx,%esi
  800714:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800717:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80071e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800722:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800725:	89 04 24             	mov    %eax,(%esp)
  800728:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	e8 8c 24 00 00       	call   802bc0 <__udivdi3>
  800734:	89 d9                	mov    %ebx,%ecx
  800736:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80073a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	89 54 24 04          	mov    %edx,0x4(%esp)
  800745:	89 fa                	mov    %edi,%edx
  800747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074a:	e8 71 ff ff ff       	call   8006c0 <printnum>
  80074f:	eb 1b                	jmp    80076c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800751:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800755:	8b 45 18             	mov    0x18(%ebp),%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	ff d3                	call   *%ebx
  80075d:	eb 03                	jmp    800762 <printnum+0xa2>
  80075f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800762:	83 ee 01             	sub    $0x1,%esi
  800765:	85 f6                	test   %esi,%esi
  800767:	7f e8                	jg     800751 <printnum+0x91>
  800769:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800774:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800777:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80077a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	e8 5c 25 00 00       	call   802cf0 <__umoddi3>
  800794:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800798:	0f be 80 cf 2f 80 00 	movsbl 0x802fcf(%eax),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a5:	ff d0                	call   *%eax
}
  8007a7:	83 c4 3c             	add    $0x3c,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b9:	8b 10                	mov    (%eax),%edx
  8007bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007be:	73 0a                	jae    8007ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8007c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	88 02                	mov    %al,(%edx)
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	89 04 24             	mov    %eax,(%esp)
  8007ed:	e8 02 00 00 00       	call   8007f4 <vprintfmt>
	va_end(ap);
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	57                   	push   %edi
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 3c             	sub    $0x3c,%esp
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800803:	8b 7d 10             	mov    0x10(%ebp),%edi
  800806:	eb 11                	jmp    800819 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800808:	85 c0                	test   %eax,%eax
  80080a:	0f 84 48 04 00 00    	je     800c58 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800819:	83 c7 01             	add    $0x1,%edi
  80081c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800820:	83 f8 25             	cmp    $0x25,%eax
  800823:	75 e3                	jne    800808 <vprintfmt+0x14>
  800825:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800829:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800830:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800837:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80083e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800843:	eb 1f                	jmp    800864 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800845:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800848:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80084c:	eb 16                	jmp    800864 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800851:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800855:	eb 0d                	jmp    800864 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800857:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80085a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80085d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8d 47 01             	lea    0x1(%edi),%eax
  800867:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086a:	0f b6 17             	movzbl (%edi),%edx
  80086d:	0f b6 c2             	movzbl %dl,%eax
  800870:	83 ea 23             	sub    $0x23,%edx
  800873:	80 fa 55             	cmp    $0x55,%dl
  800876:	0f 87 bf 03 00 00    	ja     800c3b <vprintfmt+0x447>
  80087c:	0f b6 d2             	movzbl %dl,%edx
  80087f:	ff 24 95 20 31 80 00 	jmp    *0x803120(,%edx,4)
  800886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
  80088e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800891:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800894:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800898:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80089b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80089e:	83 f9 09             	cmp    $0x9,%ecx
  8008a1:	77 3c                	ja     8008df <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a6:	eb e9                	jmp    800891 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 40 04             	lea    0x4(%eax),%eax
  8008b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bc:	eb 27                	jmp    8008e5 <vprintfmt+0xf1>
  8008be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	0f 49 c2             	cmovns %edx,%eax
  8008cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d1:	eb 91                	jmp    800864 <vprintfmt+0x70>
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008dd:	eb 85                	jmp    800864 <vprintfmt+0x70>
  8008df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008e2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e9:	0f 89 75 ff ff ff    	jns    800864 <vprintfmt+0x70>
  8008ef:	e9 63 ff ff ff       	jmp    800857 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fa:	e9 65 ff ff ff       	jmp    800864 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800902:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800906:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090a:	8b 00                	mov    (%eax),%eax
  80090c:	89 04 24             	mov    %eax,(%esp)
  80090f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800914:	e9 00 ff ff ff       	jmp    800819 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800920:	8b 00                	mov    (%eax),%eax
  800922:	99                   	cltd   
  800923:	31 d0                	xor    %edx,%eax
  800925:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800927:	83 f8 0f             	cmp    $0xf,%eax
  80092a:	7f 0b                	jg     800937 <vprintfmt+0x143>
  80092c:	8b 14 85 80 32 80 00 	mov    0x803280(,%eax,4),%edx
  800933:	85 d2                	test   %edx,%edx
  800935:	75 20                	jne    800957 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800937:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093b:	c7 44 24 08 e7 2f 80 	movl   $0x802fe7,0x8(%esp)
  800942:	00 
  800943:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800947:	89 34 24             	mov    %esi,(%esp)
  80094a:	e8 7d fe ff ff       	call   8007cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800952:	e9 c2 fe ff ff       	jmp    800819 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800957:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80095b:	c7 44 24 08 9e 35 80 	movl   $0x80359e,0x8(%esp)
  800962:	00 
  800963:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800967:	89 34 24             	mov    %esi,(%esp)
  80096a:	e8 5d fe ff ff       	call   8007cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800972:	e9 a2 fe ff ff       	jmp    800819 <vprintfmt+0x25>
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80097d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800980:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800983:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800987:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800989:	85 ff                	test   %edi,%edi
  80098b:	b8 e0 2f 80 00       	mov    $0x802fe0,%eax
  800990:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800993:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800997:	0f 84 92 00 00 00    	je     800a2f <vprintfmt+0x23b>
  80099d:	85 c9                	test   %ecx,%ecx
  80099f:	0f 8e 98 00 00 00    	jle    800a3d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a9:	89 3c 24             	mov    %edi,(%esp)
  8009ac:	e8 47 03 00 00       	call   800cf8 <strnlen>
  8009b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009b4:	29 c1                	sub    %eax,%ecx
  8009b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8009b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	eb 0f                	jmp    8009d6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8009c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d3:	83 ef 01             	sub    $0x1,%edi
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	7f ed                	jg     8009c7 <vprintfmt+0x1d3>
  8009da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	0f 49 c1             	cmovns %ecx,%eax
  8009ea:	29 c1                	sub    %eax,%ecx
  8009ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	eb 50                	jmp    800a49 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	74 1e                	je     800a1d <vprintfmt+0x229>
  8009ff:	0f be d2             	movsbl %dl,%edx
  800a02:	83 ea 20             	sub    $0x20,%edx
  800a05:	83 fa 5e             	cmp    $0x5e,%edx
  800a08:	76 13                	jbe    800a1d <vprintfmt+0x229>
					putch('?', putdat);
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a11:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a18:	ff 55 08             	call   *0x8(%ebp)
  800a1b:	eb 0d                	jmp    800a2a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2a:	83 eb 01             	sub    $0x1,%ebx
  800a2d:	eb 1a                	jmp    800a49 <vprintfmt+0x255>
  800a2f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a32:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a38:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3b:	eb 0c                	jmp    800a49 <vprintfmt+0x255>
  800a3d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a40:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a43:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a46:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a49:	83 c7 01             	add    $0x1,%edi
  800a4c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a50:	0f be c2             	movsbl %dl,%eax
  800a53:	85 c0                	test   %eax,%eax
  800a55:	74 25                	je     800a7c <vprintfmt+0x288>
  800a57:	85 f6                	test   %esi,%esi
  800a59:	78 9e                	js     8009f9 <vprintfmt+0x205>
  800a5b:	83 ee 01             	sub    $0x1,%esi
  800a5e:	79 99                	jns    8009f9 <vprintfmt+0x205>
  800a60:	89 df                	mov    %ebx,%edi
  800a62:	8b 75 08             	mov    0x8(%ebp),%esi
  800a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a68:	eb 1a                	jmp    800a84 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a75:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a77:	83 ef 01             	sub    $0x1,%edi
  800a7a:	eb 08                	jmp    800a84 <vprintfmt+0x290>
  800a7c:	89 df                	mov    %ebx,%edi
  800a7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a84:	85 ff                	test   %edi,%edi
  800a86:	7f e2                	jg     800a6a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a8b:	e9 89 fd ff ff       	jmp    800819 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a90:	83 f9 01             	cmp    $0x1,%ecx
  800a93:	7e 19                	jle    800aae <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8b 50 04             	mov    0x4(%eax),%edx
  800a9b:	8b 00                	mov    (%eax),%eax
  800a9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 40 08             	lea    0x8(%eax),%eax
  800aa9:	89 45 14             	mov    %eax,0x14(%ebp)
  800aac:	eb 38                	jmp    800ae6 <vprintfmt+0x2f2>
	else if (lflag)
  800aae:	85 c9                	test   %ecx,%ecx
  800ab0:	74 1b                	je     800acd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8b 00                	mov    (%eax),%eax
  800ab7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aba:	89 c1                	mov    %eax,%ecx
  800abc:	c1 f9 1f             	sar    $0x1f,%ecx
  800abf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac5:	8d 40 04             	lea    0x4(%eax),%eax
  800ac8:	89 45 14             	mov    %eax,0x14(%ebp)
  800acb:	eb 19                	jmp    800ae6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  800acd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad0:	8b 00                	mov    (%eax),%eax
  800ad2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad5:	89 c1                	mov    %eax,%ecx
  800ad7:	c1 f9 1f             	sar    $0x1f,%ecx
  800ada:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800add:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae0:	8d 40 04             	lea    0x4(%eax),%eax
  800ae3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ae6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ae9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aec:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800af1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800af5:	0f 89 04 01 00 00    	jns    800bff <vprintfmt+0x40b>
				putch('-', putdat);
  800afb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b06:	ff d6                	call   *%esi
				num = -(long long) num;
  800b08:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b0b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b0e:	f7 da                	neg    %edx
  800b10:	83 d1 00             	adc    $0x0,%ecx
  800b13:	f7 d9                	neg    %ecx
  800b15:	e9 e5 00 00 00       	jmp    800bff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1a:	83 f9 01             	cmp    $0x1,%ecx
  800b1d:	7e 10                	jle    800b2f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8b 10                	mov    (%eax),%edx
  800b24:	8b 48 04             	mov    0x4(%eax),%ecx
  800b27:	8d 40 08             	lea    0x8(%eax),%eax
  800b2a:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2d:	eb 26                	jmp    800b55 <vprintfmt+0x361>
	else if (lflag)
  800b2f:	85 c9                	test   %ecx,%ecx
  800b31:	74 12                	je     800b45 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	8b 10                	mov    (%eax),%edx
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8d 40 04             	lea    0x4(%eax),%eax
  800b40:	89 45 14             	mov    %eax,0x14(%ebp)
  800b43:	eb 10                	jmp    800b55 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8b 10                	mov    (%eax),%edx
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	8d 40 04             	lea    0x4(%eax),%eax
  800b52:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b55:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800b5a:	e9 a0 00 00 00       	jmp    800bff <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b63:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b6a:	ff d6                	call   *%esi
			putch('X', putdat);
  800b6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b70:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b77:	ff d6                	call   *%esi
			putch('X', putdat);
  800b79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b7d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b84:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b89:	e9 8b fc ff ff       	jmp    800819 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800b8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b92:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b99:	ff d6                	call   *%esi
			putch('x', putdat);
  800b9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ba6:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bab:	8b 10                	mov    (%eax),%edx
  800bad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800bb2:	8d 40 04             	lea    0x4(%eax),%eax
  800bb5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bb8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800bbd:	eb 40                	jmp    800bff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bbf:	83 f9 01             	cmp    $0x1,%ecx
  800bc2:	7e 10                	jle    800bd4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc7:	8b 10                	mov    (%eax),%edx
  800bc9:	8b 48 04             	mov    0x4(%eax),%ecx
  800bcc:	8d 40 08             	lea    0x8(%eax),%eax
  800bcf:	89 45 14             	mov    %eax,0x14(%ebp)
  800bd2:	eb 26                	jmp    800bfa <vprintfmt+0x406>
	else if (lflag)
  800bd4:	85 c9                	test   %ecx,%ecx
  800bd6:	74 12                	je     800bea <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800bd8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be2:	8d 40 04             	lea    0x4(%eax),%eax
  800be5:	89 45 14             	mov    %eax,0x14(%ebp)
  800be8:	eb 10                	jmp    800bfa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800bea:	8b 45 14             	mov    0x14(%ebp),%eax
  800bed:	8b 10                	mov    (%eax),%edx
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf4:	8d 40 04             	lea    0x4(%eax),%eax
  800bf7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bfa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c12:	89 14 24             	mov    %edx,(%esp)
  800c15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c19:	89 da                	mov    %ebx,%edx
  800c1b:	89 f0                	mov    %esi,%eax
  800c1d:	e8 9e fa ff ff       	call   8006c0 <printnum>
			break;
  800c22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c25:	e9 ef fb ff ff       	jmp    800819 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c36:	e9 de fb ff ff       	jmp    800819 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c3f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c48:	eb 03                	jmp    800c4d <vprintfmt+0x459>
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c51:	75 f7                	jne    800c4a <vprintfmt+0x456>
  800c53:	e9 c1 fb ff ff       	jmp    800819 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c58:	83 c4 3c             	add    $0x3c,%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 28             	sub    $0x28,%esp
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c6f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c73:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	74 30                	je     800cb1 <vsnprintf+0x51>
  800c81:	85 d2                	test   %edx,%edx
  800c83:	7e 2c                	jle    800cb1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c85:	8b 45 14             	mov    0x14(%ebp),%eax
  800c88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9a:	c7 04 24 af 07 80 00 	movl   $0x8007af,(%esp)
  800ca1:	e8 4e fb ff ff       	call   8007f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caf:	eb 05                	jmp    800cb6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb6:	c9                   	leave  
  800cb7:	c3                   	ret    

00800cb8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cbe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	89 04 24             	mov    %eax,(%esp)
  800cd9:	e8 82 ff ff ff       	call   800c60 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	eb 03                	jmp    800cf0 <strlen+0x10>
		n++;
  800ced:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cf4:	75 f7                	jne    800ced <strlen+0xd>
		n++;
	return n;
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb 03                	jmp    800d0b <strnlen+0x13>
		n++;
  800d08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0b:	39 d0                	cmp    %edx,%eax
  800d0d:	74 06                	je     800d15 <strnlen+0x1d>
  800d0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d13:	75 f3                	jne    800d08 <strnlen+0x10>
		n++;
	return n;
}
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	83 c2 01             	add    $0x1,%edx
  800d26:	83 c1 01             	add    $0x1,%ecx
  800d29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d30:	84 db                	test   %bl,%bl
  800d32:	75 ef                	jne    800d23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 08             	sub    $0x8,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d41:	89 1c 24             	mov    %ebx,(%esp)
  800d44:	e8 97 ff ff ff       	call   800ce0 <strlen>
	strcpy(dst + len, src);
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d50:	01 d8                	add    %ebx,%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 bd ff ff ff       	call   800d17 <strcpy>
	return dst;
}
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	83 c4 08             	add    $0x8,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	89 f3                	mov    %esi,%ebx
  800d6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d72:	89 f2                	mov    %esi,%edx
  800d74:	eb 0f                	jmp    800d85 <strncpy+0x23>
		*dst++ = *src;
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	0f b6 01             	movzbl (%ecx),%eax
  800d7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d85:	39 da                	cmp    %ebx,%edx
  800d87:	75 ed                	jne    800d76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 75 08             	mov    0x8(%ebp),%esi
  800d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800da3:	85 c9                	test   %ecx,%ecx
  800da5:	75 0b                	jne    800db2 <strlcpy+0x23>
  800da7:	eb 1d                	jmp    800dc6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800da9:	83 c0 01             	add    $0x1,%eax
  800dac:	83 c2 01             	add    $0x1,%edx
  800daf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db2:	39 d8                	cmp    %ebx,%eax
  800db4:	74 0b                	je     800dc1 <strlcpy+0x32>
  800db6:	0f b6 0a             	movzbl (%edx),%ecx
  800db9:	84 c9                	test   %cl,%cl
  800dbb:	75 ec                	jne    800da9 <strlcpy+0x1a>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	eb 02                	jmp    800dc3 <strlcpy+0x34>
  800dc1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dc3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800dc6:	29 f0                	sub    %esi,%eax
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dd5:	eb 06                	jmp    800ddd <strcmp+0x11>
		p++, q++;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ddd:	0f b6 01             	movzbl (%ecx),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 04                	je     800de8 <strcmp+0x1c>
  800de4:	3a 02                	cmp    (%edx),%al
  800de6:	74 ef                	je     800dd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800de8:	0f b6 c0             	movzbl %al,%eax
  800deb:	0f b6 12             	movzbl (%edx),%edx
  800dee:	29 d0                	sub    %edx,%eax
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e01:	eb 06                	jmp    800e09 <strncmp+0x17>
		n--, p++, q++;
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e09:	39 d8                	cmp    %ebx,%eax
  800e0b:	74 15                	je     800e22 <strncmp+0x30>
  800e0d:	0f b6 08             	movzbl (%eax),%ecx
  800e10:	84 c9                	test   %cl,%cl
  800e12:	74 04                	je     800e18 <strncmp+0x26>
  800e14:	3a 0a                	cmp    (%edx),%cl
  800e16:	74 eb                	je     800e03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	0f b6 12             	movzbl (%edx),%edx
  800e1e:	29 d0                	sub    %edx,%eax
  800e20:	eb 05                	jmp    800e27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e34:	eb 07                	jmp    800e3d <strchr+0x13>
		if (*s == c)
  800e36:	38 ca                	cmp    %cl,%dl
  800e38:	74 0f                	je     800e49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3a:	83 c0 01             	add    $0x1,%eax
  800e3d:	0f b6 10             	movzbl (%eax),%edx
  800e40:	84 d2                	test   %dl,%dl
  800e42:	75 f2                	jne    800e36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e55:	eb 07                	jmp    800e5e <strfind+0x13>
		if (*s == c)
  800e57:	38 ca                	cmp    %cl,%dl
  800e59:	74 0a                	je     800e65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5b:	83 c0 01             	add    $0x1,%eax
  800e5e:	0f b6 10             	movzbl (%eax),%edx
  800e61:	84 d2                	test   %dl,%dl
  800e63:	75 f2                	jne    800e57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e73:	85 c9                	test   %ecx,%ecx
  800e75:	74 36                	je     800ead <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e7d:	75 28                	jne    800ea7 <memset+0x40>
  800e7f:	f6 c1 03             	test   $0x3,%cl
  800e82:	75 23                	jne    800ea7 <memset+0x40>
		c &= 0xFF;
  800e84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	c1 e3 08             	shl    $0x8,%ebx
  800e8d:	89 d6                	mov    %edx,%esi
  800e8f:	c1 e6 18             	shl    $0x18,%esi
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	c1 e0 10             	shl    $0x10,%eax
  800e97:	09 f0                	or     %esi,%eax
  800e99:	09 c2                	or     %eax,%edx
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ea2:	fc                   	cld    
  800ea3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea5:	eb 06                	jmp    800ead <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec2:	39 c6                	cmp    %eax,%esi
  800ec4:	73 35                	jae    800efb <memmove+0x47>
  800ec6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec9:	39 d0                	cmp    %edx,%eax
  800ecb:	73 2e                	jae    800efb <memmove+0x47>
		s += n;
		d += n;
  800ecd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eda:	75 13                	jne    800eef <memmove+0x3b>
  800edc:	f6 c1 03             	test   $0x3,%cl
  800edf:	75 0e                	jne    800eef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee1:	83 ef 04             	sub    $0x4,%edi
  800ee4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eea:	fd                   	std    
  800eeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eed:	eb 09                	jmp    800ef8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 1d                	jmp    800f18 <memmove+0x64>
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eff:	f6 c2 03             	test   $0x3,%dl
  800f02:	75 0f                	jne    800f13 <memmove+0x5f>
  800f04:	f6 c1 03             	test   $0x3,%cl
  800f07:	75 0a                	jne    800f13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	fc                   	cld    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 05                	jmp    800f18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	fc                   	cld    
  800f16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f22:	8b 45 10             	mov    0x10(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	e8 79 ff ff ff       	call   800eb4 <memmove>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f48:	89 d6                	mov    %edx,%esi
  800f4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4d:	eb 1a                	jmp    800f69 <memcmp+0x2c>
		if (*s1 != *s2)
  800f4f:	0f b6 02             	movzbl (%edx),%eax
  800f52:	0f b6 19             	movzbl (%ecx),%ebx
  800f55:	38 d8                	cmp    %bl,%al
  800f57:	74 0a                	je     800f63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f59:	0f b6 c0             	movzbl %al,%eax
  800f5c:	0f b6 db             	movzbl %bl,%ebx
  800f5f:	29 d8                	sub    %ebx,%eax
  800f61:	eb 0f                	jmp    800f72 <memcmp+0x35>
		s1++, s2++;
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f69:	39 f2                	cmp    %esi,%edx
  800f6b:	75 e2                	jne    800f4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f7f:	89 c2                	mov    %eax,%edx
  800f81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f84:	eb 07                	jmp    800f8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f86:	38 08                	cmp    %cl,(%eax)
  800f88:	74 07                	je     800f91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	39 d0                	cmp    %edx,%eax
  800f8f:	72 f5                	jb     800f86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9f:	eb 03                	jmp    800fa4 <strtol+0x11>
		s++;
  800fa1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa4:	0f b6 0a             	movzbl (%edx),%ecx
  800fa7:	80 f9 09             	cmp    $0x9,%cl
  800faa:	74 f5                	je     800fa1 <strtol+0xe>
  800fac:	80 f9 20             	cmp    $0x20,%cl
  800faf:	74 f0                	je     800fa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb1:	80 f9 2b             	cmp    $0x2b,%cl
  800fb4:	75 0a                	jne    800fc0 <strtol+0x2d>
		s++;
  800fb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbe:	eb 11                	jmp    800fd1 <strtol+0x3e>
  800fc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fc5:	80 f9 2d             	cmp    $0x2d,%cl
  800fc8:	75 07                	jne    800fd1 <strtol+0x3e>
		s++, neg = 1;
  800fca:	8d 52 01             	lea    0x1(%edx),%edx
  800fcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fd6:	75 15                	jne    800fed <strtol+0x5a>
  800fd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800fdb:	75 10                	jne    800fed <strtol+0x5a>
  800fdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fe1:	75 0a                	jne    800fed <strtol+0x5a>
		s += 2, base = 16;
  800fe3:	83 c2 02             	add    $0x2,%edx
  800fe6:	b8 10 00 00 00       	mov    $0x10,%eax
  800feb:	eb 10                	jmp    800ffd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 0c                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ff1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff6:	75 05                	jne    800ffd <strtol+0x6a>
		s++, base = 8;
  800ff8:	83 c2 01             	add    $0x1,%edx
  800ffb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ffd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801002:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801005:	0f b6 0a             	movzbl (%edx),%ecx
  801008:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	3c 09                	cmp    $0x9,%al
  80100f:	77 08                	ja     801019 <strtol+0x86>
			dig = *s - '0';
  801011:	0f be c9             	movsbl %cl,%ecx
  801014:	83 e9 30             	sub    $0x30,%ecx
  801017:	eb 20                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801019:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	3c 19                	cmp    $0x19,%al
  801020:	77 08                	ja     80102a <strtol+0x97>
			dig = *s - 'a' + 10;
  801022:	0f be c9             	movsbl %cl,%ecx
  801025:	83 e9 57             	sub    $0x57,%ecx
  801028:	eb 0f                	jmp    801039 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80102a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	3c 19                	cmp    $0x19,%al
  801031:	77 16                	ja     801049 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801033:	0f be c9             	movsbl %cl,%ecx
  801036:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801039:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80103c:	7d 0f                	jge    80104d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80103e:	83 c2 01             	add    $0x1,%edx
  801041:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801045:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801047:	eb bc                	jmp    801005 <strtol+0x72>
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	eb 02                	jmp    80104f <strtol+0xbc>
  80104d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80104f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801053:	74 05                	je     80105a <strtol+0xc7>
		*endptr = (char *) s;
  801055:	8b 75 0c             	mov    0xc(%ebp),%esi
  801058:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80105a:	f7 d8                	neg    %eax
  80105c:	85 ff                	test   %edi,%edi
  80105e:	0f 44 c3             	cmove  %ebx,%eax
}
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 c3                	mov    %eax,%ebx
  801079:	89 c7                	mov    %eax,%edi
  80107b:	89 c6                	mov    %eax,%esi
  80107d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <sys_cgetc>:

int
sys_cgetc(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108a:	ba 00 00 00 00       	mov    $0x0,%edx
  80108f:	b8 01 00 00 00       	mov    $0x1,%eax
  801094:	89 d1                	mov    %edx,%ecx
  801096:	89 d3                	mov    %edx,%ebx
  801098:	89 d7                	mov    %edx,%edi
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	89 cb                	mov    %ecx,%ebx
  8010bb:	89 cf                	mov    %ecx,%edi
  8010bd:	89 ce                	mov    %ecx,%esi
  8010bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 28                	jle    8010ed <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010e0:	00 
  8010e1:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  8010e8:	e8 b5 f4 ff ff       	call   8005a2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ed:	83 c4 2c             	add    $0x2c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	b8 04 00 00 00       	mov    $0x4,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  80117a:	e8 23 f4 ff ff       	call   8005a2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801190:	b8 05 00 00 00       	mov    $0x5,%eax
  801195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  8011cd:	e8 d0 f3 ff ff       	call   8005a2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  801220:	e8 7d f3 ff ff       	call   8005a2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 08 00 00 00       	mov    $0x8,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  801273:	e8 2a f3 ff ff       	call   8005a2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128e:	b8 09 00 00 00       	mov    $0x9,%eax
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 df                	mov    %ebx,%edi
  80129b:	89 de                	mov    %ebx,%esi
  80129d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	7e 28                	jle    8012cb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  8012c6:	e8 d7 f2 ff ff       	call   8005a2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012cb:	83 c4 2c             	add    $0x2c,%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ec:	89 df                	mov    %ebx,%edi
  8012ee:	89 de                	mov    %ebx,%esi
  8012f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	7e 28                	jle    80131e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012fa:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801301:	00 
  801302:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  801319:	e8 84 f2 ff ff       	call   8005a2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80131e:	83 c4 2c             	add    $0x2c,%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132c:	be 00 00 00 00       	mov    $0x0,%esi
  801331:	b8 0c 00 00 00       	mov    $0xc,%eax
  801336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801339:	8b 55 08             	mov    0x8(%ebp),%edx
  80133c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801342:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801352:	b9 00 00 00 00       	mov    $0x0,%ecx
  801357:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135c:	8b 55 08             	mov    0x8(%ebp),%edx
  80135f:	89 cb                	mov    %ecx,%ebx
  801361:	89 cf                	mov    %ecx,%edi
  801363:	89 ce                	mov    %ecx,%esi
  801365:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801367:	85 c0                	test   %eax,%eax
  801369:	7e 28                	jle    801393 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801376:	00 
  801377:	c7 44 24 08 df 32 80 	movl   $0x8032df,0x8(%esp)
  80137e:	00 
  80137f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801386:	00 
  801387:	c7 04 24 fc 32 80 00 	movl   $0x8032fc,(%esp)
  80138e:	e8 0f f2 ff ff       	call   8005a2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801393:	83 c4 2c             	add    $0x2c,%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 20             	sub    $0x20,%esp
  8013a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  8013a6:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  8013a8:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  8013ac:	75 3f                	jne    8013ed <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  8013ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b2:	c7 04 24 0a 33 80 00 	movl   $0x80330a,(%esp)
  8013b9:	e8 dd f2 ff ff       	call   80069b <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  8013be:	8b 43 28             	mov    0x28(%ebx),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	c7 04 24 1a 33 80 00 	movl   $0x80331a,(%esp)
  8013cc:	e8 ca f2 ff ff       	call   80069b <cprintf>

		 panic("The err is not right of the pgfault\n ");
  8013d1:	c7 44 24 08 60 33 80 	movl   $0x803360,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  8013e8:	e8 b5 f1 ff ff       	call   8005a2 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  8013ed:	89 f0                	mov    %esi,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  8013f9:	f6 c4 08             	test   $0x8,%ah
  8013fc:	75 1c                	jne    80141a <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  8013fe:	c7 44 24 08 88 33 80 	movl   $0x803388,0x8(%esp)
  801405:	00 
  801406:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80140d:	00 
  80140e:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  801415:	e8 88 f1 ff ff       	call   8005a2 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80141a:	e8 d6 fc ff ff       	call   8010f5 <sys_getenvid>
  80141f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801426:	00 
  801427:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80142e:	00 
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 fc fc ff ff       	call   801133 <sys_page_alloc>
  801437:	85 c0                	test   %eax,%eax
  801439:	79 1c                	jns    801457 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  80143b:	c7 44 24 08 a8 33 80 	movl   $0x8033a8,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  801452:	e8 4b f1 ff ff       	call   8005a2 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  801457:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  80145d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801464:	00 
  801465:	89 74 24 04          	mov    %esi,0x4(%esp)
  801469:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801470:	e8 a7 fa ff ff       	call   800f1c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  801475:	e8 7b fc ff ff       	call   8010f5 <sys_getenvid>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	e8 74 fc ff ff       	call   8010f5 <sys_getenvid>
  801481:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801488:	00 
  801489:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80148d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801491:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801498:	00 
  801499:	89 04 24             	mov    %eax,(%esp)
  80149c:	e8 e6 fc ff ff       	call   801187 <sys_page_map>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	79 20                	jns    8014c5 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  8014a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a9:	c7 44 24 08 d0 33 80 	movl   $0x8033d0,0x8(%esp)
  8014b0:	00 
  8014b1:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8014b8:	00 
  8014b9:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  8014c0:	e8 dd f0 ff ff       	call   8005a2 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  8014c5:	e8 2b fc ff ff       	call   8010f5 <sys_getenvid>
  8014ca:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014d1:	00 
  8014d2:	89 04 24             	mov    %eax,(%esp)
  8014d5:	e8 00 fd ff ff       	call   8011da <sys_page_unmap>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	79 20                	jns    8014fe <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  8014de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e2:	c7 44 24 08 00 34 80 	movl   $0x803400,0x8(%esp)
  8014e9:	00 
  8014ea:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8014f1:	00 
  8014f2:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  8014f9:	e8 a4 f0 ff ff       	call   8005a2 <_panic>
	return;
}
  8014fe:	83 c4 20             	add    $0x20,%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	57                   	push   %edi
  801509:	56                   	push   %esi
  80150a:	53                   	push   %ebx
  80150b:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  80150e:	c7 04 24 9b 13 80 00 	movl   $0x80139b,(%esp)
  801515:	e8 06 14 00 00       	call   802920 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80151a:	b8 07 00 00 00       	mov    $0x7,%eax
  80151f:	cd 30                	int    $0x30
  801521:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801524:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801527:	85 c0                	test   %eax,%eax
  801529:	79 20                	jns    80154b <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  80152b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80152f:	c7 44 24 08 34 34 80 	movl   $0x803434,0x8(%esp)
  801536:	00 
  801537:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  80153e:	00 
  80153f:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  801546:	e8 57 f0 ff ff       	call   8005a2 <_panic>
	if(childEid == 0){
  80154b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154f:	75 1c                	jne    80156d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801551:	e8 9f fb ff ff       	call   8010f5 <sys_getenvid>
  801556:	25 ff 03 00 00       	and    $0x3ff,%eax
  80155b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80155e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801563:	a3 04 50 80 00       	mov    %eax,0x805004
		return childEid;
  801568:	e9 a0 01 00 00       	jmp    80170d <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  80156d:	c7 44 24 04 b6 29 80 	movl   $0x8029b6,0x4(%esp)
  801574:	00 
  801575:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801578:	89 04 24             	mov    %eax,(%esp)
  80157b:	e8 53 fd ff ff       	call   8012d3 <sys_env_set_pgfault_upcall>
  801580:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801582:	85 c0                	test   %eax,%eax
  801584:	79 20                	jns    8015a6 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80158a:	c7 44 24 08 68 34 80 	movl   $0x803468,0x8(%esp)
  801591:	00 
  801592:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801599:	00 
  80159a:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  8015a1:	e8 fc ef ff ff       	call   8005a2 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  8015a6:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8015ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	c1 ea 16             	shr    $0x16,%edx
  8015bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015c4:	f6 c2 01             	test   $0x1,%dl
  8015c7:	0f 84 f7 00 00 00    	je     8016c4 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8015cd:	c1 e8 0c             	shr    $0xc,%eax
  8015d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  8015d7:	f6 c2 04             	test   $0x4,%dl
  8015da:	0f 84 e4 00 00 00    	je     8016c4 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  8015e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  8015e7:	a8 01                	test   $0x1,%al
  8015e9:	0f 84 d5 00 00 00    	je     8016c4 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  8015ef:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  8015f5:	75 20                	jne    801617 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  8015f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015fe:	00 
  8015ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801606:	ee 
  801607:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80160a:	89 04 24             	mov    %eax,(%esp)
  80160d:	e8 21 fb ff ff       	call   801133 <sys_page_alloc>
  801612:	e9 84 00 00 00       	jmp    80169b <fork+0x196>
  801617:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  80161d:	89 f8                	mov    %edi,%eax
  80161f:	c1 e8 0c             	shr    $0xc,%eax
  801622:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801629:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  80162e:	83 f8 01             	cmp    $0x1,%eax
  801631:	19 db                	sbb    %ebx,%ebx
  801633:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801639:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  80163f:	e8 b1 fa ff ff       	call   8010f5 <sys_getenvid>
  801644:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801648:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80164c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80164f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801653:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 28 fb ff ff       	call   801187 <sys_page_map>
  80165f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801662:	85 c0                	test   %eax,%eax
  801664:	78 35                	js     80169b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801666:	e8 8a fa ff ff       	call   8010f5 <sys_getenvid>
  80166b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80166e:	e8 82 fa ff ff       	call   8010f5 <sys_getenvid>
  801673:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801677:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80167b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80167e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 f9 fa ff ff       	call   801187 <sys_page_map>
  80168e:	85 c0                	test   %eax,%eax
  801690:	bf 00 00 00 00       	mov    $0x0,%edi
  801695:	0f 4f c7             	cmovg  %edi,%eax
  801698:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  80169b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80169f:	79 23                	jns    8016c4 <fork+0x1bf>
  8016a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  8016a4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016a8:	c7 44 24 08 a8 34 80 	movl   $0x8034a8,0x8(%esp)
  8016af:	00 
  8016b0:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016b7:	00 
  8016b8:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  8016bf:	e8 de ee ff ff       	call   8005a2 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  8016c4:	89 f1                	mov    %esi,%ecx
  8016c6:	89 f0                	mov    %esi,%eax
  8016c8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8016ce:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  8016d4:	0f 85 de fe ff ff    	jne    8015b8 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  8016da:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016e1:	00 
  8016e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 40 fb ff ff       	call   80122d <sys_env_set_status>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	79 1c                	jns    80170d <fork+0x208>
		panic("sys_env_set_status");
  8016f1:	c7 44 24 08 36 33 80 	movl   $0x803336,0x8(%esp)
  8016f8:	00 
  8016f9:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801700:	00 
  801701:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  801708:	e8 95 ee ff ff       	call   8005a2 <_panic>
	return childEid;
}
  80170d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801710:	83 c4 2c             	add    $0x2c,%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5f                   	pop    %edi
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <sfork>:

// Challenge!
int
sfork(void)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80171e:	c7 44 24 08 49 33 80 	movl   $0x803349,0x8(%esp)
  801725:	00 
  801726:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80172d:	00 
  80172e:	c7 04 24 2b 33 80 00 	movl   $0x80332b,(%esp)
  801735:	e8 68 ee ff ff       	call   8005a2 <_panic>
  80173a:	66 90                	xchg   %ax,%ax
  80173c:	66 90                	xchg   %ax,%ax
  80173e:	66 90                	xchg   %ax,%ax

00801740 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	05 00 00 00 30       	add    $0x30000000,%eax
  80174b:	c1 e8 0c             	shr    $0xc,%eax
}
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80175b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801760:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801772:	89 c2                	mov    %eax,%edx
  801774:	c1 ea 16             	shr    $0x16,%edx
  801777:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80177e:	f6 c2 01             	test   $0x1,%dl
  801781:	74 11                	je     801794 <fd_alloc+0x2d>
  801783:	89 c2                	mov    %eax,%edx
  801785:	c1 ea 0c             	shr    $0xc,%edx
  801788:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80178f:	f6 c2 01             	test   $0x1,%dl
  801792:	75 09                	jne    80179d <fd_alloc+0x36>
			*fd_store = fd;
  801794:	89 01                	mov    %eax,(%ecx)
			return 0;
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
  80179b:	eb 17                	jmp    8017b4 <fd_alloc+0x4d>
  80179d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017a7:	75 c9                	jne    801772 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017a9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8017af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017bc:	83 f8 1f             	cmp    $0x1f,%eax
  8017bf:	77 36                	ja     8017f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017c1:	c1 e0 0c             	shl    $0xc,%eax
  8017c4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017c9:	89 c2                	mov    %eax,%edx
  8017cb:	c1 ea 16             	shr    $0x16,%edx
  8017ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017d5:	f6 c2 01             	test   $0x1,%dl
  8017d8:	74 24                	je     8017fe <fd_lookup+0x48>
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	c1 ea 0c             	shr    $0xc,%edx
  8017df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e6:	f6 c2 01             	test   $0x1,%dl
  8017e9:	74 1a                	je     801805 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8017f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f5:	eb 13                	jmp    80180a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fc:	eb 0c                	jmp    80180a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801803:	eb 05                	jmp    80180a <fd_lookup+0x54>
  801805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 18             	sub    $0x18,%esp
  801812:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801815:	ba 4c 35 80 00       	mov    $0x80354c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80181a:	eb 13                	jmp    80182f <dev_lookup+0x23>
  80181c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80181f:	39 08                	cmp    %ecx,(%eax)
  801821:	75 0c                	jne    80182f <dev_lookup+0x23>
			*dev = devtab[i];
  801823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801826:	89 01                	mov    %eax,(%ecx)
			return 0;
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
  80182d:	eb 30                	jmp    80185f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80182f:	8b 02                	mov    (%edx),%eax
  801831:	85 c0                	test   %eax,%eax
  801833:	75 e7                	jne    80181c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801835:	a1 04 50 80 00       	mov    0x805004,%eax
  80183a:	8b 40 48             	mov    0x48(%eax),%eax
  80183d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	c7 04 24 d0 34 80 00 	movl   $0x8034d0,(%esp)
  80184c:	e8 4a ee ff ff       	call   80069b <cprintf>
	*dev = 0;
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80185a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	83 ec 20             	sub    $0x20,%esp
  801869:	8b 75 08             	mov    0x8(%ebp),%esi
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80186f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801872:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801876:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80187c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 2f ff ff ff       	call   8017b6 <fd_lookup>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 05                	js     801890 <fd_close+0x2f>
	    || fd != fd2)
  80188b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80188e:	74 0c                	je     80189c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801890:	84 db                	test   %bl,%bl
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	0f 44 c2             	cmove  %edx,%eax
  80189a:	eb 3f                	jmp    8018db <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80189c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	8b 06                	mov    (%esi),%eax
  8018a5:	89 04 24             	mov    %eax,(%esp)
  8018a8:	e8 5f ff ff ff       	call   80180c <dev_lookup>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 16                	js     8018c9 <fd_close+0x68>
		if (dev->dev_close)
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018b9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	74 07                	je     8018c9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8018c2:	89 34 24             	mov    %esi,(%esp)
  8018c5:	ff d0                	call   *%eax
  8018c7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d4:	e8 01 f9 ff ff       	call   8011da <sys_page_unmap>
	return r;
  8018d9:	89 d8                	mov    %ebx,%eax
}
  8018db:	83 c4 20             	add    $0x20,%esp
  8018de:	5b                   	pop    %ebx
  8018df:	5e                   	pop    %esi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 bc fe ff ff       	call   8017b6 <fd_lookup>
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	85 d2                	test   %edx,%edx
  8018fe:	78 13                	js     801913 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801900:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801907:	00 
  801908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 4e ff ff ff       	call   801861 <fd_close>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <close_all>:

void
close_all(void)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	53                   	push   %ebx
  801919:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80191c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801921:	89 1c 24             	mov    %ebx,(%esp)
  801924:	e8 b9 ff ff ff       	call   8018e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801929:	83 c3 01             	add    $0x1,%ebx
  80192c:	83 fb 20             	cmp    $0x20,%ebx
  80192f:	75 f0                	jne    801921 <close_all+0xc>
		close(i);
}
  801931:	83 c4 14             	add    $0x14,%esp
  801934:	5b                   	pop    %ebx
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    

00801937 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	57                   	push   %edi
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801940:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801943:	89 44 24 04          	mov    %eax,0x4(%esp)
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	89 04 24             	mov    %eax,(%esp)
  80194d:	e8 64 fe ff ff       	call   8017b6 <fd_lookup>
  801952:	89 c2                	mov    %eax,%edx
  801954:	85 d2                	test   %edx,%edx
  801956:	0f 88 e1 00 00 00    	js     801a3d <dup+0x106>
		return r;
	close(newfdnum);
  80195c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 7b ff ff ff       	call   8018e2 <close>

	newfd = INDEX2FD(newfdnum);
  801967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196a:	c1 e3 0c             	shl    $0xc,%ebx
  80196d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 d2 fd ff ff       	call   801750 <fd2data>
  80197e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801980:	89 1c 24             	mov    %ebx,(%esp)
  801983:	e8 c8 fd ff ff       	call   801750 <fd2data>
  801988:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80198a:	89 f0                	mov    %esi,%eax
  80198c:	c1 e8 16             	shr    $0x16,%eax
  80198f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801996:	a8 01                	test   $0x1,%al
  801998:	74 43                	je     8019dd <dup+0xa6>
  80199a:	89 f0                	mov    %esi,%eax
  80199c:	c1 e8 0c             	shr    $0xc,%eax
  80199f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019a6:	f6 c2 01             	test   $0x1,%dl
  8019a9:	74 32                	je     8019dd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8019b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019c6:	00 
  8019c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d2:	e8 b0 f7 ff ff       	call   801187 <sys_page_map>
  8019d7:	89 c6                	mov    %eax,%esi
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 3e                	js     801a1b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	c1 ea 0c             	shr    $0xc,%edx
  8019e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8019fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a01:	00 
  801a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0d:	e8 75 f7 ff ff       	call   801187 <sys_page_map>
  801a12:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a17:	85 f6                	test   %esi,%esi
  801a19:	79 22                	jns    801a3d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a26:	e8 af f7 ff ff       	call   8011da <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a36:	e8 9f f7 ff ff       	call   8011da <sys_page_unmap>
	return r;
  801a3b:	89 f0                	mov    %esi,%eax
}
  801a3d:	83 c4 3c             	add    $0x3c,%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5f                   	pop    %edi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	53                   	push   %ebx
  801a49:	83 ec 24             	sub    $0x24,%esp
  801a4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a56:	89 1c 24             	mov    %ebx,(%esp)
  801a59:	e8 58 fd ff ff       	call   8017b6 <fd_lookup>
  801a5e:	89 c2                	mov    %eax,%edx
  801a60:	85 d2                	test   %edx,%edx
  801a62:	78 6d                	js     801ad1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6e:	8b 00                	mov    (%eax),%eax
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	e8 94 fd ff ff       	call   80180c <dev_lookup>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 55                	js     801ad1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7f:	8b 50 08             	mov    0x8(%eax),%edx
  801a82:	83 e2 03             	and    $0x3,%edx
  801a85:	83 fa 01             	cmp    $0x1,%edx
  801a88:	75 23                	jne    801aad <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a8a:	a1 04 50 80 00       	mov    0x805004,%eax
  801a8f:	8b 40 48             	mov    0x48(%eax),%eax
  801a92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9a:	c7 04 24 11 35 80 00 	movl   $0x803511,(%esp)
  801aa1:	e8 f5 eb ff ff       	call   80069b <cprintf>
		return -E_INVAL;
  801aa6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aab:	eb 24                	jmp    801ad1 <read+0x8c>
	}
	if (!dev->dev_read)
  801aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab0:	8b 52 08             	mov    0x8(%edx),%edx
  801ab3:	85 d2                	test   %edx,%edx
  801ab5:	74 15                	je     801acc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ab7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	ff d2                	call   *%edx
  801aca:	eb 05                	jmp    801ad1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801acc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801ad1:	83 c4 24             	add    $0x24,%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	57                   	push   %edi
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	83 ec 1c             	sub    $0x1c,%esp
  801ae0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ae6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aeb:	eb 23                	jmp    801b10 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801aed:	89 f0                	mov    %esi,%eax
  801aef:	29 d8                	sub    %ebx,%eax
  801af1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af5:	89 d8                	mov    %ebx,%eax
  801af7:	03 45 0c             	add    0xc(%ebp),%eax
  801afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afe:	89 3c 24             	mov    %edi,(%esp)
  801b01:	e8 3f ff ff ff       	call   801a45 <read>
		if (m < 0)
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 10                	js     801b1a <readn+0x43>
			return m;
		if (m == 0)
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	74 0a                	je     801b18 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b0e:	01 c3                	add    %eax,%ebx
  801b10:	39 f3                	cmp    %esi,%ebx
  801b12:	72 d9                	jb     801aed <readn+0x16>
  801b14:	89 d8                	mov    %ebx,%eax
  801b16:	eb 02                	jmp    801b1a <readn+0x43>
  801b18:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b1a:	83 c4 1c             	add    $0x1c,%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	53                   	push   %ebx
  801b26:	83 ec 24             	sub    $0x24,%esp
  801b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b33:	89 1c 24             	mov    %ebx,(%esp)
  801b36:	e8 7b fc ff ff       	call   8017b6 <fd_lookup>
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	85 d2                	test   %edx,%edx
  801b3f:	78 68                	js     801ba9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4b:	8b 00                	mov    (%eax),%eax
  801b4d:	89 04 24             	mov    %eax,(%esp)
  801b50:	e8 b7 fc ff ff       	call   80180c <dev_lookup>
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 50                	js     801ba9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b60:	75 23                	jne    801b85 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b62:	a1 04 50 80 00       	mov    0x805004,%eax
  801b67:	8b 40 48             	mov    0x48(%eax),%eax
  801b6a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b72:	c7 04 24 2d 35 80 00 	movl   $0x80352d,(%esp)
  801b79:	e8 1d eb ff ff       	call   80069b <cprintf>
		return -E_INVAL;
  801b7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b83:	eb 24                	jmp    801ba9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b88:	8b 52 0c             	mov    0xc(%edx),%edx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	74 15                	je     801ba4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b99:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	ff d2                	call   *%edx
  801ba2:	eb 05                	jmp    801ba9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ba4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ba9:	83 c4 24             	add    $0x24,%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <seek>:

int
seek(int fdnum, off_t offset)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 ef fb ff ff       	call   8017b6 <fd_lookup>
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 0e                	js     801bd9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 24             	sub    $0x24,%esp
  801be2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801be5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bec:	89 1c 24             	mov    %ebx,(%esp)
  801bef:	e8 c2 fb ff ff       	call   8017b6 <fd_lookup>
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	85 d2                	test   %edx,%edx
  801bf8:	78 61                	js     801c5b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c04:	8b 00                	mov    (%eax),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 fe fb ff ff       	call   80180c <dev_lookup>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 49                	js     801c5b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c15:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c19:	75 23                	jne    801c3e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c1b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c20:	8b 40 48             	mov    0x48(%eax),%eax
  801c23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2b:	c7 04 24 f0 34 80 00 	movl   $0x8034f0,(%esp)
  801c32:	e8 64 ea ff ff       	call   80069b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c3c:	eb 1d                	jmp    801c5b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c41:	8b 52 18             	mov    0x18(%edx),%edx
  801c44:	85 d2                	test   %edx,%edx
  801c46:	74 0e                	je     801c56 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c4f:	89 04 24             	mov    %eax,(%esp)
  801c52:	ff d2                	call   *%edx
  801c54:	eb 05                	jmp    801c5b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c56:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c5b:	83 c4 24             	add    $0x24,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	53                   	push   %ebx
  801c65:	83 ec 24             	sub    $0x24,%esp
  801c68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 39 fb ff ff       	call   8017b6 <fd_lookup>
  801c7d:	89 c2                	mov    %eax,%edx
  801c7f:	85 d2                	test   %edx,%edx
  801c81:	78 52                	js     801cd5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8d:	8b 00                	mov    (%eax),%eax
  801c8f:	89 04 24             	mov    %eax,(%esp)
  801c92:	e8 75 fb ff ff       	call   80180c <dev_lookup>
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 3a                	js     801cd5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ca2:	74 2c                	je     801cd0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ca4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ca7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cae:	00 00 00 
	stat->st_isdir = 0;
  801cb1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb8:	00 00 00 
	stat->st_dev = dev;
  801cbb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801cc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cc8:	89 14 24             	mov    %edx,(%esp)
  801ccb:	ff 50 14             	call   *0x14(%eax)
  801cce:	eb 05                	jmp    801cd5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801cd0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cd5:	83 c4 24             	add    $0x24,%esp
  801cd8:	5b                   	pop    %ebx
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ce3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cea:	00 
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 fb 01 00 00       	call   801ef1 <open>
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	85 db                	test   %ebx,%ebx
  801cfa:	78 1b                	js     801d17 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d03:	89 1c 24             	mov    %ebx,(%esp)
  801d06:	e8 56 ff ff ff       	call   801c61 <fstat>
  801d0b:	89 c6                	mov    %eax,%esi
	close(fd);
  801d0d:	89 1c 24             	mov    %ebx,(%esp)
  801d10:	e8 cd fb ff ff       	call   8018e2 <close>
	return r;
  801d15:	89 f0                	mov    %esi,%eax
}
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	5b                   	pop    %ebx
  801d1b:	5e                   	pop    %esi
  801d1c:	5d                   	pop    %ebp
  801d1d:	c3                   	ret    

00801d1e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	83 ec 10             	sub    $0x10,%esp
  801d26:	89 c6                	mov    %eax,%esi
  801d28:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d2a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d31:	75 11                	jne    801d44 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d3a:	e8 0e 0e 00 00       	call   802b4d <ipc_find_env>
  801d3f:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d44:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d4b:	00 
  801d4c:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d53:	00 
  801d54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d58:	a1 00 50 80 00       	mov    0x805000,%eax
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 39 0d 00 00       	call   802a9e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d6c:	00 
  801d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d78:	e8 83 0c 00 00       	call   802a00 <ipc_recv>
}
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d90:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d98:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801da2:	b8 02 00 00 00       	mov    $0x2,%eax
  801da7:	e8 72 ff ff ff       	call   801d1e <fsipc>
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	8b 40 0c             	mov    0xc(%eax),%eax
  801dba:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc4:	b8 06 00 00 00       	mov    $0x6,%eax
  801dc9:	e8 50 ff ff ff       	call   801d1e <fsipc>
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 14             	sub    $0x14,%esp
  801dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	8b 40 0c             	mov    0xc(%eax),%eax
  801de0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801de5:	ba 00 00 00 00       	mov    $0x0,%edx
  801dea:	b8 05 00 00 00       	mov    $0x5,%eax
  801def:	e8 2a ff ff ff       	call   801d1e <fsipc>
  801df4:	89 c2                	mov    %eax,%edx
  801df6:	85 d2                	test   %edx,%edx
  801df8:	78 2b                	js     801e25 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dfa:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e01:	00 
  801e02:	89 1c 24             	mov    %ebx,(%esp)
  801e05:	e8 0d ef ff ff       	call   800d17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e0a:	a1 80 60 80 00       	mov    0x806080,%eax
  801e0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e15:	a1 84 60 80 00       	mov    0x806084,%eax
  801e1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e25:	83 c4 14             	add    $0x14,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801e31:	c7 44 24 08 5c 35 80 	movl   $0x80355c,0x8(%esp)
  801e38:	00 
  801e39:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801e40:	00 
  801e41:	c7 04 24 7a 35 80 00 	movl   $0x80357a,(%esp)
  801e48:	e8 55 e7 ff ff       	call   8005a2 <_panic>

00801e4d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 10             	sub    $0x10,%esp
  801e55:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e63:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e69:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6e:	b8 03 00 00 00       	mov    $0x3,%eax
  801e73:	e8 a6 fe ff ff       	call   801d1e <fsipc>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 6a                	js     801ee8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e7e:	39 c6                	cmp    %eax,%esi
  801e80:	73 24                	jae    801ea6 <devfile_read+0x59>
  801e82:	c7 44 24 0c 85 35 80 	movl   $0x803585,0xc(%esp)
  801e89:	00 
  801e8a:	c7 44 24 08 8c 35 80 	movl   $0x80358c,0x8(%esp)
  801e91:	00 
  801e92:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e99:	00 
  801e9a:	c7 04 24 7a 35 80 00 	movl   $0x80357a,(%esp)
  801ea1:	e8 fc e6 ff ff       	call   8005a2 <_panic>
	assert(r <= PGSIZE);
  801ea6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801eab:	7e 24                	jle    801ed1 <devfile_read+0x84>
  801ead:	c7 44 24 0c a1 35 80 	movl   $0x8035a1,0xc(%esp)
  801eb4:	00 
  801eb5:	c7 44 24 08 8c 35 80 	movl   $0x80358c,0x8(%esp)
  801ebc:	00 
  801ebd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ec4:	00 
  801ec5:	c7 04 24 7a 35 80 00 	movl   $0x80357a,(%esp)
  801ecc:	e8 d1 e6 ff ff       	call   8005a2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801edc:	00 
  801edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee0:	89 04 24             	mov    %eax,(%esp)
  801ee3:	e8 cc ef ff ff       	call   800eb4 <memmove>
	return r;
}
  801ee8:	89 d8                	mov    %ebx,%eax
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 24             	sub    $0x24,%esp
  801ef8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801efb:	89 1c 24             	mov    %ebx,(%esp)
  801efe:	e8 dd ed ff ff       	call   800ce0 <strlen>
  801f03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f08:	7f 60                	jg     801f6a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 52 f8 ff ff       	call   801767 <fd_alloc>
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	85 d2                	test   %edx,%edx
  801f19:	78 54                	js     801f6f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f1f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f26:	e8 ec ed ff ff       	call   800d17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f36:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3b:	e8 de fd ff ff       	call   801d1e <fsipc>
  801f40:	89 c3                	mov    %eax,%ebx
  801f42:	85 c0                	test   %eax,%eax
  801f44:	79 17                	jns    801f5d <open+0x6c>
		fd_close(fd, 0);
  801f46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f4d:	00 
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 08 f9 ff ff       	call   801861 <fd_close>
		return r;
  801f59:	89 d8                	mov    %ebx,%eax
  801f5b:	eb 12                	jmp    801f6f <open+0x7e>
	}

	return fd2num(fd);
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	89 04 24             	mov    %eax,(%esp)
  801f63:	e8 d8 f7 ff ff       	call   801740 <fd2num>
  801f68:	eb 05                	jmp    801f6f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f6a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f6f:	83 c4 24             	add    $0x24,%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f80:	b8 08 00 00 00       	mov    $0x8,%eax
  801f85:	e8 94 fd ff ff       	call   801d1e <fsipc>
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	53                   	push   %ebx
  801f96:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fa3:	00 
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	89 04 24             	mov    %eax,(%esp)
  801faa:	e8 42 ff ff ff       	call   801ef1 <open>
  801faf:	89 c1                	mov    %eax,%ecx
  801fb1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	0f 88 9e 04 00 00    	js     80245d <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801fbf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801fc6:	00 
  801fc7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd1:	89 0c 24             	mov    %ecx,(%esp)
  801fd4:	e8 fe fa ff ff       	call   801ad7 <readn>
  801fd9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801fde:	75 0c                	jne    801fec <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801fe0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801fe7:	45 4c 46 
  801fea:	74 36                	je     802022 <spawn+0x92>
		close(fd);
  801fec:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ff2:	89 04 24             	mov    %eax,(%esp)
  801ff5:	e8 e8 f8 ff ff       	call   8018e2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ffa:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802001:	46 
  802002:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802008:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200c:	c7 04 24 ad 35 80 00 	movl   $0x8035ad,(%esp)
  802013:	e8 83 e6 ff ff       	call   80069b <cprintf>
		return -E_NOT_EXEC;
  802018:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80201d:	e9 9a 04 00 00       	jmp    8024bc <spawn+0x52c>
  802022:	b8 07 00 00 00       	mov    $0x7,%eax
  802027:	cd 30                	int    $0x30
  802029:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80202f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802035:	85 c0                	test   %eax,%eax
  802037:	0f 88 28 04 00 00    	js     802465 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80203d:	89 c6                	mov    %eax,%esi
  80203f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802045:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802048:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80204e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802054:	b9 11 00 00 00       	mov    $0x11,%ecx
  802059:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80205b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802061:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802067:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80206c:	be 00 00 00 00       	mov    $0x0,%esi
  802071:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802074:	eb 0f                	jmp    802085 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 62 ec ff ff       	call   800ce0 <strlen>
  80207e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802082:	83 c3 01             	add    $0x1,%ebx
  802085:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80208c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 e3                	jne    802076 <spawn+0xe6>
  802093:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802099:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80209f:	bf 00 10 40 00       	mov    $0x401000,%edi
  8020a4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8020a6:	89 fa                	mov    %edi,%edx
  8020a8:	83 e2 fc             	and    $0xfffffffc,%edx
  8020ab:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8020b2:	29 c2                	sub    %eax,%edx
  8020b4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8020ba:	8d 42 f8             	lea    -0x8(%edx),%eax
  8020bd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8020c2:	0f 86 ad 03 00 00    	jbe    802475 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020cf:	00 
  8020d0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020d7:	00 
  8020d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020df:	e8 4f f0 ff ff       	call   801133 <sys_page_alloc>
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	0f 88 d0 03 00 00    	js     8024bc <spawn+0x52c>
  8020ec:	be 00 00 00 00       	mov    $0x0,%esi
  8020f1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8020f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020fa:	eb 30                	jmp    80212c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8020fc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802102:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802108:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80210b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	89 3c 24             	mov    %edi,(%esp)
  802115:	e8 fd eb ff ff       	call   800d17 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80211a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80211d:	89 04 24             	mov    %eax,(%esp)
  802120:	e8 bb eb ff ff       	call   800ce0 <strlen>
  802125:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802129:	83 c6 01             	add    $0x1,%esi
  80212c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802132:	7f c8                	jg     8020fc <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802134:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80213a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802140:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802147:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80214d:	74 24                	je     802173 <spawn+0x1e3>
  80214f:	c7 44 24 0c 24 36 80 	movl   $0x803624,0xc(%esp)
  802156:	00 
  802157:	c7 44 24 08 8c 35 80 	movl   $0x80358c,0x8(%esp)
  80215e:	00 
  80215f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802166:	00 
  802167:	c7 04 24 c7 35 80 00 	movl   $0x8035c7,(%esp)
  80216e:	e8 2f e4 ff ff       	call   8005a2 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802173:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802179:	89 c8                	mov    %ecx,%eax
  80217b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802180:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  802183:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802189:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80218c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  802192:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802198:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80219f:	00 
  8021a0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8021a7:	ee 
  8021a8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021b9:	00 
  8021ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c1:	e8 c1 ef ff ff       	call   801187 <sys_page_map>
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	0f 88 d6 02 00 00    	js     8024a6 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8021d0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021d7:	00 
  8021d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021df:	e8 f6 ef ff ff       	call   8011da <sys_page_unmap>
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	0f 88 b8 02 00 00    	js     8024a6 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8021ee:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8021f4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8021fb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802201:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802208:	00 00 00 
  80220b:	e9 b6 01 00 00       	jmp    8023c6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802210:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802216:	83 38 01             	cmpl   $0x1,(%eax)
  802219:	0f 85 99 01 00 00    	jne    8023b8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	8b 40 18             	mov    0x18(%eax),%eax
  802224:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802227:	83 f8 01             	cmp    $0x1,%eax
  80222a:	19 c0                	sbb    %eax,%eax
  80222c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802232:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802239:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802240:	89 c8                	mov    %ecx,%eax
  802242:	8b 51 04             	mov    0x4(%ecx),%edx
  802245:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80224b:	8b 49 10             	mov    0x10(%ecx),%ecx
  80224e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  802254:	8b 50 14             	mov    0x14(%eax),%edx
  802257:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80225d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802260:	89 f0                	mov    %esi,%eax
  802262:	25 ff 0f 00 00       	and    $0xfff,%eax
  802267:	74 14                	je     80227d <spawn+0x2ed>
		va -= i;
  802269:	29 c6                	sub    %eax,%esi
		memsz += i;
  80226b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802271:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802277:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80227d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802282:	e9 23 01 00 00       	jmp    8023aa <spawn+0x41a>
		if (i >= filesz) {
  802287:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80228d:	77 2b                	ja     8022ba <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80228f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802295:	89 44 24 08          	mov    %eax,0x8(%esp)
  802299:	89 74 24 04          	mov    %esi,0x4(%esp)
  80229d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8022a3:	89 04 24             	mov    %eax,(%esp)
  8022a6:	e8 88 ee ff ff       	call   801133 <sys_page_alloc>
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	0f 89 eb 00 00 00    	jns    80239e <spawn+0x40e>
  8022b3:	89 c3                	mov    %eax,%ebx
  8022b5:	e9 cc 01 00 00       	jmp    802486 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022ba:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022c1:	00 
  8022c2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022c9:	00 
  8022ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d1:	e8 5d ee ff ff       	call   801133 <sys_page_alloc>
  8022d6:	85 c0                	test   %eax,%eax
  8022d8:	0f 88 9e 01 00 00    	js     80247c <spawn+0x4ec>
  8022de:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8022e4:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8022e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ea:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022f0:	89 04 24             	mov    %eax,(%esp)
  8022f3:	e8 b7 f8 ff ff       	call   801baf <seek>
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	0f 88 80 01 00 00    	js     802480 <spawn+0x4f0>
  802300:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802306:	29 fa                	sub    %edi,%edx
  802308:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80230a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802310:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802315:	0f 47 c1             	cmova  %ecx,%eax
  802318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80231c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802323:	00 
  802324:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80232a:	89 04 24             	mov    %eax,(%esp)
  80232d:	e8 a5 f7 ff ff       	call   801ad7 <readn>
  802332:	85 c0                	test   %eax,%eax
  802334:	0f 88 4a 01 00 00    	js     802484 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80233a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802340:	89 44 24 10          	mov    %eax,0x10(%esp)
  802344:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802348:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80234e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802352:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802359:	00 
  80235a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802361:	e8 21 ee ff ff       	call   801187 <sys_page_map>
  802366:	85 c0                	test   %eax,%eax
  802368:	79 20                	jns    80238a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  80236a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80236e:	c7 44 24 08 d3 35 80 	movl   $0x8035d3,0x8(%esp)
  802375:	00 
  802376:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80237d:	00 
  80237e:	c7 04 24 c7 35 80 00 	movl   $0x8035c7,(%esp)
  802385:	e8 18 e2 ff ff       	call   8005a2 <_panic>
			sys_page_unmap(0, UTEMP);
  80238a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802391:	00 
  802392:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802399:	e8 3c ee ff ff       	call   8011da <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80239e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8023a4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8023aa:	89 df                	mov    %ebx,%edi
  8023ac:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8023b2:	0f 87 cf fe ff ff    	ja     802287 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8023b8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8023bf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8023c6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8023cd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8023d3:	0f 8c 37 fe ff ff    	jl     802210 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8023d9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023df:	89 04 24             	mov    %eax,(%esp)
  8023e2:	e8 fb f4 ff ff       	call   8018e2 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8023e7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8023ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023f7:	89 04 24             	mov    %eax,(%esp)
  8023fa:	e8 81 ee ff ff       	call   801280 <sys_env_set_trapframe>
  8023ff:	85 c0                	test   %eax,%eax
  802401:	79 20                	jns    802423 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  802403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802407:	c7 44 24 08 f0 35 80 	movl   $0x8035f0,0x8(%esp)
  80240e:	00 
  80240f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802416:	00 
  802417:	c7 04 24 c7 35 80 00 	movl   $0x8035c7,(%esp)
  80241e:	e8 7f e1 ff ff       	call   8005a2 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802423:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80242a:	00 
  80242b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802431:	89 04 24             	mov    %eax,(%esp)
  802434:	e8 f4 ed ff ff       	call   80122d <sys_env_set_status>
  802439:	85 c0                	test   %eax,%eax
  80243b:	79 30                	jns    80246d <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  80243d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802441:	c7 44 24 08 0a 36 80 	movl   $0x80360a,0x8(%esp)
  802448:	00 
  802449:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802450:	00 
  802451:	c7 04 24 c7 35 80 00 	movl   $0x8035c7,(%esp)
  802458:	e8 45 e1 ff ff       	call   8005a2 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80245d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802463:	eb 57                	jmp    8024bc <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802465:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80246b:	eb 4f                	jmp    8024bc <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80246d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802473:	eb 47                	jmp    8024bc <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802475:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80247a:	eb 40                	jmp    8024bc <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80247c:	89 c3                	mov    %eax,%ebx
  80247e:	eb 06                	jmp    802486 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802480:	89 c3                	mov    %eax,%ebx
  802482:	eb 02                	jmp    802486 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802484:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802486:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80248c:	89 04 24             	mov    %eax,(%esp)
  80248f:	e8 0f ec ff ff       	call   8010a3 <sys_env_destroy>
	close(fd);
  802494:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80249a:	89 04 24             	mov    %eax,(%esp)
  80249d:	e8 40 f4 ff ff       	call   8018e2 <close>
	return r;
  8024a2:	89 d8                	mov    %ebx,%eax
  8024a4:	eb 16                	jmp    8024bc <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8024a6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8024ad:	00 
  8024ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b5:	e8 20 ed ff ff       	call   8011da <sys_page_unmap>
  8024ba:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8024bc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  8024c2:	5b                   	pop    %ebx
  8024c3:	5e                   	pop    %esi
  8024c4:	5f                   	pop    %edi
  8024c5:	5d                   	pop    %ebp
  8024c6:	c3                   	ret    

008024c7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8024c7:	55                   	push   %ebp
  8024c8:	89 e5                	mov    %esp,%ebp
  8024ca:	56                   	push   %esi
  8024cb:	53                   	push   %ebx
  8024cc:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8024cf:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8024d2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8024d7:	eb 03                	jmp    8024dc <spawnl+0x15>
		argc++;
  8024d9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8024dc:	83 c0 04             	add    $0x4,%eax
  8024df:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  8024e3:	75 f4                	jne    8024d9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8024e5:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  8024ec:	83 e0 f0             	and    $0xfffffff0,%eax
  8024ef:	29 c4                	sub    %eax,%esp
  8024f1:	8d 44 24 0b          	lea    0xb(%esp),%eax
  8024f5:	c1 e8 02             	shr    $0x2,%eax
  8024f8:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  8024ff:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802504:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80250b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802512:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
  802518:	eb 0a                	jmp    802524 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80251a:	83 c0 01             	add    $0x1,%eax
  80251d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802521:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802524:	39 d0                	cmp    %edx,%eax
  802526:	75 f2                	jne    80251a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802528:	89 74 24 04          	mov    %esi,0x4(%esp)
  80252c:	8b 45 08             	mov    0x8(%ebp),%eax
  80252f:	89 04 24             	mov    %eax,(%esp)
  802532:	e8 59 fa ff ff       	call   801f90 <spawn>
}
  802537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80253a:	5b                   	pop    %ebx
  80253b:	5e                   	pop    %esi
  80253c:	5d                   	pop    %ebp
  80253d:	c3                   	ret    

0080253e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	56                   	push   %esi
  802542:	53                   	push   %ebx
  802543:	83 ec 10             	sub    $0x10,%esp
  802546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802549:	8b 45 08             	mov    0x8(%ebp),%eax
  80254c:	89 04 24             	mov    %eax,(%esp)
  80254f:	e8 fc f1 ff ff       	call   801750 <fd2data>
  802554:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802556:	c7 44 24 04 4a 36 80 	movl   $0x80364a,0x4(%esp)
  80255d:	00 
  80255e:	89 1c 24             	mov    %ebx,(%esp)
  802561:	e8 b1 e7 ff ff       	call   800d17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802566:	8b 46 04             	mov    0x4(%esi),%eax
  802569:	2b 06                	sub    (%esi),%eax
  80256b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802578:	00 00 00 
	stat->st_dev = &devpipe;
  80257b:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802582:	40 80 00 
	return 0;
}
  802585:	b8 00 00 00 00       	mov    $0x0,%eax
  80258a:	83 c4 10             	add    $0x10,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    

00802591 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	53                   	push   %ebx
  802595:	83 ec 14             	sub    $0x14,%esp
  802598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80259b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80259f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a6:	e8 2f ec ff ff       	call   8011da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8025ab:	89 1c 24             	mov    %ebx,(%esp)
  8025ae:	e8 9d f1 ff ff       	call   801750 <fd2data>
  8025b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025be:	e8 17 ec ff ff       	call   8011da <sys_page_unmap>
}
  8025c3:	83 c4 14             	add    $0x14,%esp
  8025c6:	5b                   	pop    %ebx
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    

008025c9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8025c9:	55                   	push   %ebp
  8025ca:	89 e5                	mov    %esp,%ebp
  8025cc:	57                   	push   %edi
  8025cd:	56                   	push   %esi
  8025ce:	53                   	push   %ebx
  8025cf:	83 ec 2c             	sub    $0x2c,%esp
  8025d2:	89 c6                	mov    %eax,%esi
  8025d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8025d7:	a1 04 50 80 00       	mov    0x805004,%eax
  8025dc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8025df:	89 34 24             	mov    %esi,(%esp)
  8025e2:	e8 9e 05 00 00       	call   802b85 <pageref>
  8025e7:	89 c7                	mov    %eax,%edi
  8025e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ec:	89 04 24             	mov    %eax,(%esp)
  8025ef:	e8 91 05 00 00       	call   802b85 <pageref>
  8025f4:	39 c7                	cmp    %eax,%edi
  8025f6:	0f 94 c2             	sete   %dl
  8025f9:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  8025fc:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  802602:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802605:	39 fb                	cmp    %edi,%ebx
  802607:	74 21                	je     80262a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802609:	84 d2                	test   %dl,%dl
  80260b:	74 ca                	je     8025d7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80260d:	8b 51 58             	mov    0x58(%ecx),%edx
  802610:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802614:	89 54 24 08          	mov    %edx,0x8(%esp)
  802618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80261c:	c7 04 24 51 36 80 00 	movl   $0x803651,(%esp)
  802623:	e8 73 e0 ff ff       	call   80069b <cprintf>
  802628:	eb ad                	jmp    8025d7 <_pipeisclosed+0xe>
	}
}
  80262a:	83 c4 2c             	add    $0x2c,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    

00802632 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802632:	55                   	push   %ebp
  802633:	89 e5                	mov    %esp,%ebp
  802635:	57                   	push   %edi
  802636:	56                   	push   %esi
  802637:	53                   	push   %ebx
  802638:	83 ec 1c             	sub    $0x1c,%esp
  80263b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80263e:	89 34 24             	mov    %esi,(%esp)
  802641:	e8 0a f1 ff ff       	call   801750 <fd2data>
  802646:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802648:	bf 00 00 00 00       	mov    $0x0,%edi
  80264d:	eb 45                	jmp    802694 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80264f:	89 da                	mov    %ebx,%edx
  802651:	89 f0                	mov    %esi,%eax
  802653:	e8 71 ff ff ff       	call   8025c9 <_pipeisclosed>
  802658:	85 c0                	test   %eax,%eax
  80265a:	75 41                	jne    80269d <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80265c:	e8 b3 ea ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802661:	8b 43 04             	mov    0x4(%ebx),%eax
  802664:	8b 0b                	mov    (%ebx),%ecx
  802666:	8d 51 20             	lea    0x20(%ecx),%edx
  802669:	39 d0                	cmp    %edx,%eax
  80266b:	73 e2                	jae    80264f <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80266d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802670:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802674:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802677:	99                   	cltd   
  802678:	c1 ea 1b             	shr    $0x1b,%edx
  80267b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80267e:	83 e1 1f             	and    $0x1f,%ecx
  802681:	29 d1                	sub    %edx,%ecx
  802683:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802687:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80268b:	83 c0 01             	add    $0x1,%eax
  80268e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802691:	83 c7 01             	add    $0x1,%edi
  802694:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802697:	75 c8                	jne    802661 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802699:	89 f8                	mov    %edi,%eax
  80269b:	eb 05                	jmp    8026a2 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80269d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8026a2:	83 c4 1c             	add    $0x1c,%esp
  8026a5:	5b                   	pop    %ebx
  8026a6:	5e                   	pop    %esi
  8026a7:	5f                   	pop    %edi
  8026a8:	5d                   	pop    %ebp
  8026a9:	c3                   	ret    

008026aa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	57                   	push   %edi
  8026ae:	56                   	push   %esi
  8026af:	53                   	push   %ebx
  8026b0:	83 ec 1c             	sub    $0x1c,%esp
  8026b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8026b6:	89 3c 24             	mov    %edi,(%esp)
  8026b9:	e8 92 f0 ff ff       	call   801750 <fd2data>
  8026be:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026c0:	be 00 00 00 00       	mov    $0x0,%esi
  8026c5:	eb 3d                	jmp    802704 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8026c7:	85 f6                	test   %esi,%esi
  8026c9:	74 04                	je     8026cf <devpipe_read+0x25>
				return i;
  8026cb:	89 f0                	mov    %esi,%eax
  8026cd:	eb 43                	jmp    802712 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8026cf:	89 da                	mov    %ebx,%edx
  8026d1:	89 f8                	mov    %edi,%eax
  8026d3:	e8 f1 fe ff ff       	call   8025c9 <_pipeisclosed>
  8026d8:	85 c0                	test   %eax,%eax
  8026da:	75 31                	jne    80270d <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8026dc:	e8 33 ea ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8026e1:	8b 03                	mov    (%ebx),%eax
  8026e3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8026e6:	74 df                	je     8026c7 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8026e8:	99                   	cltd   
  8026e9:	c1 ea 1b             	shr    $0x1b,%edx
  8026ec:	01 d0                	add    %edx,%eax
  8026ee:	83 e0 1f             	and    $0x1f,%eax
  8026f1:	29 d0                	sub    %edx,%eax
  8026f3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8026f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026fb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8026fe:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802701:	83 c6 01             	add    $0x1,%esi
  802704:	3b 75 10             	cmp    0x10(%ebp),%esi
  802707:	75 d8                	jne    8026e1 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802709:	89 f0                	mov    %esi,%eax
  80270b:	eb 05                	jmp    802712 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80270d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802712:	83 c4 1c             	add    $0x1c,%esp
  802715:	5b                   	pop    %ebx
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	5d                   	pop    %ebp
  802719:	c3                   	ret    

0080271a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80271a:	55                   	push   %ebp
  80271b:	89 e5                	mov    %esp,%ebp
  80271d:	56                   	push   %esi
  80271e:	53                   	push   %ebx
  80271f:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802725:	89 04 24             	mov    %eax,(%esp)
  802728:	e8 3a f0 ff ff       	call   801767 <fd_alloc>
  80272d:	89 c2                	mov    %eax,%edx
  80272f:	85 d2                	test   %edx,%edx
  802731:	0f 88 4d 01 00 00    	js     802884 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802737:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80273e:	00 
  80273f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802742:	89 44 24 04          	mov    %eax,0x4(%esp)
  802746:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80274d:	e8 e1 e9 ff ff       	call   801133 <sys_page_alloc>
  802752:	89 c2                	mov    %eax,%edx
  802754:	85 d2                	test   %edx,%edx
  802756:	0f 88 28 01 00 00    	js     802884 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80275c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80275f:	89 04 24             	mov    %eax,(%esp)
  802762:	e8 00 f0 ff ff       	call   801767 <fd_alloc>
  802767:	89 c3                	mov    %eax,%ebx
  802769:	85 c0                	test   %eax,%eax
  80276b:	0f 88 fe 00 00 00    	js     80286f <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802771:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802778:	00 
  802779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80277c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802780:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802787:	e8 a7 e9 ff ff       	call   801133 <sys_page_alloc>
  80278c:	89 c3                	mov    %eax,%ebx
  80278e:	85 c0                	test   %eax,%eax
  802790:	0f 88 d9 00 00 00    	js     80286f <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802799:	89 04 24             	mov    %eax,(%esp)
  80279c:	e8 af ef ff ff       	call   801750 <fd2data>
  8027a1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027a3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027aa:	00 
  8027ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b6:	e8 78 e9 ff ff       	call   801133 <sys_page_alloc>
  8027bb:	89 c3                	mov    %eax,%ebx
  8027bd:	85 c0                	test   %eax,%eax
  8027bf:	0f 88 97 00 00 00    	js     80285c <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8027c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027c8:	89 04 24             	mov    %eax,(%esp)
  8027cb:	e8 80 ef ff ff       	call   801750 <fd2data>
  8027d0:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8027d7:	00 
  8027d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8027e3:	00 
  8027e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027ef:	e8 93 e9 ff ff       	call   801187 <sys_page_map>
  8027f4:	89 c3                	mov    %eax,%ebx
  8027f6:	85 c0                	test   %eax,%eax
  8027f8:	78 52                	js     80284c <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8027fa:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802803:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802808:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80280f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802818:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80281a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80281d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802827:	89 04 24             	mov    %eax,(%esp)
  80282a:	e8 11 ef ff ff       	call   801740 <fd2num>
  80282f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802832:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802834:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802837:	89 04 24             	mov    %eax,(%esp)
  80283a:	e8 01 ef ff ff       	call   801740 <fd2num>
  80283f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802842:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802845:	b8 00 00 00 00       	mov    $0x0,%eax
  80284a:	eb 38                	jmp    802884 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80284c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802850:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802857:	e8 7e e9 ff ff       	call   8011da <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80285c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80285f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802863:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80286a:	e8 6b e9 ff ff       	call   8011da <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80286f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802872:	89 44 24 04          	mov    %eax,0x4(%esp)
  802876:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80287d:	e8 58 e9 ff ff       	call   8011da <sys_page_unmap>
  802882:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802884:	83 c4 30             	add    $0x30,%esp
  802887:	5b                   	pop    %ebx
  802888:	5e                   	pop    %esi
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    

0080288b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80288b:	55                   	push   %ebp
  80288c:	89 e5                	mov    %esp,%ebp
  80288e:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802894:	89 44 24 04          	mov    %eax,0x4(%esp)
  802898:	8b 45 08             	mov    0x8(%ebp),%eax
  80289b:	89 04 24             	mov    %eax,(%esp)
  80289e:	e8 13 ef ff ff       	call   8017b6 <fd_lookup>
  8028a3:	89 c2                	mov    %eax,%edx
  8028a5:	85 d2                	test   %edx,%edx
  8028a7:	78 15                	js     8028be <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ac:	89 04 24             	mov    %eax,(%esp)
  8028af:	e8 9c ee ff ff       	call   801750 <fd2data>
	return _pipeisclosed(fd, p);
  8028b4:	89 c2                	mov    %eax,%edx
  8028b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b9:	e8 0b fd ff ff       	call   8025c9 <_pipeisclosed>
}
  8028be:	c9                   	leave  
  8028bf:	c3                   	ret    

008028c0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8028c0:	55                   	push   %ebp
  8028c1:	89 e5                	mov    %esp,%ebp
  8028c3:	56                   	push   %esi
  8028c4:	53                   	push   %ebx
  8028c5:	83 ec 10             	sub    $0x10,%esp
  8028c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8028cb:	85 f6                	test   %esi,%esi
  8028cd:	75 24                	jne    8028f3 <wait+0x33>
  8028cf:	c7 44 24 0c 69 36 80 	movl   $0x803669,0xc(%esp)
  8028d6:	00 
  8028d7:	c7 44 24 08 8c 35 80 	movl   $0x80358c,0x8(%esp)
  8028de:	00 
  8028df:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8028e6:	00 
  8028e7:	c7 04 24 74 36 80 00 	movl   $0x803674,(%esp)
  8028ee:	e8 af dc ff ff       	call   8005a2 <_panic>
	e = &envs[ENVX(envid)];
  8028f3:	89 f3                	mov    %esi,%ebx
  8028f5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8028fb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8028fe:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802904:	eb 05                	jmp    80290b <wait+0x4b>
		sys_yield();
  802906:	e8 09 e8 ff ff       	call   801114 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80290b:	8b 43 48             	mov    0x48(%ebx),%eax
  80290e:	39 f0                	cmp    %esi,%eax
  802910:	75 07                	jne    802919 <wait+0x59>
  802912:	8b 43 54             	mov    0x54(%ebx),%eax
  802915:	85 c0                	test   %eax,%eax
  802917:	75 ed                	jne    802906 <wait+0x46>
		sys_yield();
}
  802919:	83 c4 10             	add    $0x10,%esp
  80291c:	5b                   	pop    %ebx
  80291d:	5e                   	pop    %esi
  80291e:	5d                   	pop    %ebp
  80291f:	c3                   	ret    

00802920 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802920:	55                   	push   %ebp
  802921:	89 e5                	mov    %esp,%ebp
  802923:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802926:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80292d:	75 44                	jne    802973 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80292f:	a1 04 50 80 00       	mov    0x805004,%eax
  802934:	8b 40 48             	mov    0x48(%eax),%eax
  802937:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80293e:	00 
  80293f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802946:	ee 
  802947:	89 04 24             	mov    %eax,(%esp)
  80294a:	e8 e4 e7 ff ff       	call   801133 <sys_page_alloc>
		if( r < 0)
  80294f:	85 c0                	test   %eax,%eax
  802951:	79 20                	jns    802973 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  802953:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802957:	c7 44 24 08 80 36 80 	movl   $0x803680,0x8(%esp)
  80295e:	00 
  80295f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802966:	00 
  802967:	c7 04 24 dc 36 80 00 	movl   $0x8036dc,(%esp)
  80296e:	e8 2f dc ff ff       	call   8005a2 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802973:	8b 45 08             	mov    0x8(%ebp),%eax
  802976:	a3 00 70 80 00       	mov    %eax,0x807000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  80297b:	e8 75 e7 ff ff       	call   8010f5 <sys_getenvid>
  802980:	c7 44 24 04 b6 29 80 	movl   $0x8029b6,0x4(%esp)
  802987:	00 
  802988:	89 04 24             	mov    %eax,(%esp)
  80298b:	e8 43 e9 ff ff       	call   8012d3 <sys_env_set_pgfault_upcall>
  802990:	85 c0                	test   %eax,%eax
  802992:	79 20                	jns    8029b4 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  802994:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802998:	c7 44 24 08 b0 36 80 	movl   $0x8036b0,0x8(%esp)
  80299f:	00 
  8029a0:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8029a7:	00 
  8029a8:	c7 04 24 dc 36 80 00 	movl   $0x8036dc,(%esp)
  8029af:	e8 ee db ff ff       	call   8005a2 <_panic>


}
  8029b4:	c9                   	leave  
  8029b5:	c3                   	ret    

008029b6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029b6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029b7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8029bc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029be:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8029c1:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8029c5:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8029c9:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8029cd:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8029d0:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8029d3:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8029d6:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8029da:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8029de:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8029e2:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8029e6:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8029ea:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8029ee:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8029f2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  8029f3:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  8029f4:	c3                   	ret    
  8029f5:	66 90                	xchg   %ax,%ax
  8029f7:	66 90                	xchg   %ax,%ax
  8029f9:	66 90                	xchg   %ax,%ax
  8029fb:	66 90                	xchg   %ax,%ax
  8029fd:	66 90                	xchg   %ax,%ax
  8029ff:	90                   	nop

00802a00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a00:	55                   	push   %ebp
  802a01:	89 e5                	mov    %esp,%ebp
  802a03:	56                   	push   %esi
  802a04:	53                   	push   %ebx
  802a05:	83 ec 10             	sub    $0x10,%esp
  802a08:	8b 75 08             	mov    0x8(%ebp),%esi
  802a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802a11:	85 c0                	test   %eax,%eax
  802a13:	75 0e                	jne    802a23 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802a15:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802a1c:	e8 28 e9 ff ff       	call   801349 <sys_ipc_recv>
  802a21:	eb 08                	jmp    802a2b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802a23:	89 04 24             	mov    %eax,(%esp)
  802a26:	e8 1e e9 ff ff       	call   801349 <sys_ipc_recv>
	if(r == 0){
  802a2b:	85 c0                	test   %eax,%eax
  802a2d:	8d 76 00             	lea    0x0(%esi),%esi
  802a30:	75 1e                	jne    802a50 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802a32:	85 f6                	test   %esi,%esi
  802a34:	74 0a                	je     802a40 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802a36:	a1 04 50 80 00       	mov    0x805004,%eax
  802a3b:	8b 40 74             	mov    0x74(%eax),%eax
  802a3e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802a40:	85 db                	test   %ebx,%ebx
  802a42:	74 2c                	je     802a70 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802a44:	a1 04 50 80 00       	mov    0x805004,%eax
  802a49:	8b 40 78             	mov    0x78(%eax),%eax
  802a4c:	89 03                	mov    %eax,(%ebx)
  802a4e:	eb 20                	jmp    802a70 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802a50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a54:	c7 44 24 08 ec 36 80 	movl   $0x8036ec,0x8(%esp)
  802a5b:	00 
  802a5c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802a63:	00 
  802a64:	c7 04 24 68 37 80 00 	movl   $0x803768,(%esp)
  802a6b:	e8 32 db ff ff       	call   8005a2 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802a70:	a1 04 50 80 00       	mov    0x805004,%eax
  802a75:	8b 50 70             	mov    0x70(%eax),%edx
  802a78:	85 d2                	test   %edx,%edx
  802a7a:	75 13                	jne    802a8f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  802a7c:	8b 40 48             	mov    0x48(%eax),%eax
  802a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a83:	c7 04 24 1c 37 80 00 	movl   $0x80371c,(%esp)
  802a8a:	e8 0c dc ff ff       	call   80069b <cprintf>
	return thisenv->env_ipc_value;
  802a8f:	a1 04 50 80 00       	mov    0x805004,%eax
  802a94:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a97:	83 c4 10             	add    $0x10,%esp
  802a9a:	5b                   	pop    %ebx
  802a9b:	5e                   	pop    %esi
  802a9c:	5d                   	pop    %ebp
  802a9d:	c3                   	ret    

00802a9e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a9e:	55                   	push   %ebp
  802a9f:	89 e5                	mov    %esp,%ebp
  802aa1:	57                   	push   %edi
  802aa2:	56                   	push   %esi
  802aa3:	53                   	push   %ebx
  802aa4:	83 ec 1c             	sub    $0x1c,%esp
  802aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  802aaa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  802aad:	85 f6                	test   %esi,%esi
  802aaf:	75 22                	jne    802ad3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802ab1:	8b 45 14             	mov    0x14(%ebp),%eax
  802ab4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ab8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802abf:	ee 
  802ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ac7:	89 3c 24             	mov    %edi,(%esp)
  802aca:	e8 57 e8 ff ff       	call   801326 <sys_ipc_try_send>
  802acf:	89 c3                	mov    %eax,%ebx
  802ad1:	eb 1c                	jmp    802aef <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802ad3:	8b 45 14             	mov    0x14(%ebp),%eax
  802ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ada:	89 74 24 08          	mov    %esi,0x8(%esp)
  802ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ae5:	89 3c 24             	mov    %edi,(%esp)
  802ae8:	e8 39 e8 ff ff       	call   801326 <sys_ipc_try_send>
  802aed:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  802aef:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802af2:	74 3e                	je     802b32 <ipc_send+0x94>
  802af4:	89 d8                	mov    %ebx,%eax
  802af6:	c1 e8 1f             	shr    $0x1f,%eax
  802af9:	84 c0                	test   %al,%al
  802afb:	74 35                	je     802b32 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  802afd:	e8 f3 e5 ff ff       	call   8010f5 <sys_getenvid>
  802b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b06:	c7 04 24 72 37 80 00 	movl   $0x803772,(%esp)
  802b0d:	e8 89 db ff ff       	call   80069b <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802b12:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b16:	c7 44 24 08 40 37 80 	movl   $0x803740,0x8(%esp)
  802b1d:	00 
  802b1e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802b25:	00 
  802b26:	c7 04 24 68 37 80 00 	movl   $0x803768,(%esp)
  802b2d:	e8 70 da ff ff       	call   8005a2 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802b32:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802b35:	75 0e                	jne    802b45 <ipc_send+0xa7>
			sys_yield();
  802b37:	e8 d8 e5 ff ff       	call   801114 <sys_yield>
		else break;
	}
  802b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b40:	e9 68 ff ff ff       	jmp    802aad <ipc_send+0xf>
	
}
  802b45:	83 c4 1c             	add    $0x1c,%esp
  802b48:	5b                   	pop    %ebx
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    

00802b4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b4d:	55                   	push   %ebp
  802b4e:	89 e5                	mov    %esp,%ebp
  802b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b61:	8b 52 50             	mov    0x50(%edx),%edx
  802b64:	39 ca                	cmp    %ecx,%edx
  802b66:	75 0d                	jne    802b75 <ipc_find_env+0x28>
			return envs[i].env_id;
  802b68:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b6b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802b70:	8b 40 40             	mov    0x40(%eax),%eax
  802b73:	eb 0e                	jmp    802b83 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b75:	83 c0 01             	add    $0x1,%eax
  802b78:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b7d:	75 d9                	jne    802b58 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b7f:	66 b8 00 00          	mov    $0x0,%ax
}
  802b83:	5d                   	pop    %ebp
  802b84:	c3                   	ret    

00802b85 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b85:	55                   	push   %ebp
  802b86:	89 e5                	mov    %esp,%ebp
  802b88:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b8b:	89 d0                	mov    %edx,%eax
  802b8d:	c1 e8 16             	shr    $0x16,%eax
  802b90:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b97:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b9c:	f6 c1 01             	test   $0x1,%cl
  802b9f:	74 1d                	je     802bbe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ba1:	c1 ea 0c             	shr    $0xc,%edx
  802ba4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802bab:	f6 c2 01             	test   $0x1,%dl
  802bae:	74 0e                	je     802bbe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bb0:	c1 ea 0c             	shr    $0xc,%edx
  802bb3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802bba:	ef 
  802bbb:	0f b7 c0             	movzwl %ax,%eax
}
  802bbe:	5d                   	pop    %ebp
  802bbf:	c3                   	ret    

00802bc0 <__udivdi3>:
  802bc0:	55                   	push   %ebp
  802bc1:	57                   	push   %edi
  802bc2:	56                   	push   %esi
  802bc3:	83 ec 0c             	sub    $0xc,%esp
  802bc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802bca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  802bce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802bd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802bd6:	85 c0                	test   %eax,%eax
  802bd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802bdc:	89 ea                	mov    %ebp,%edx
  802bde:	89 0c 24             	mov    %ecx,(%esp)
  802be1:	75 2d                	jne    802c10 <__udivdi3+0x50>
  802be3:	39 e9                	cmp    %ebp,%ecx
  802be5:	77 61                	ja     802c48 <__udivdi3+0x88>
  802be7:	85 c9                	test   %ecx,%ecx
  802be9:	89 ce                	mov    %ecx,%esi
  802beb:	75 0b                	jne    802bf8 <__udivdi3+0x38>
  802bed:	b8 01 00 00 00       	mov    $0x1,%eax
  802bf2:	31 d2                	xor    %edx,%edx
  802bf4:	f7 f1                	div    %ecx
  802bf6:	89 c6                	mov    %eax,%esi
  802bf8:	31 d2                	xor    %edx,%edx
  802bfa:	89 e8                	mov    %ebp,%eax
  802bfc:	f7 f6                	div    %esi
  802bfe:	89 c5                	mov    %eax,%ebp
  802c00:	89 f8                	mov    %edi,%eax
  802c02:	f7 f6                	div    %esi
  802c04:	89 ea                	mov    %ebp,%edx
  802c06:	83 c4 0c             	add    $0xc,%esp
  802c09:	5e                   	pop    %esi
  802c0a:	5f                   	pop    %edi
  802c0b:	5d                   	pop    %ebp
  802c0c:	c3                   	ret    
  802c0d:	8d 76 00             	lea    0x0(%esi),%esi
  802c10:	39 e8                	cmp    %ebp,%eax
  802c12:	77 24                	ja     802c38 <__udivdi3+0x78>
  802c14:	0f bd e8             	bsr    %eax,%ebp
  802c17:	83 f5 1f             	xor    $0x1f,%ebp
  802c1a:	75 3c                	jne    802c58 <__udivdi3+0x98>
  802c1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802c20:	39 34 24             	cmp    %esi,(%esp)
  802c23:	0f 86 9f 00 00 00    	jbe    802cc8 <__udivdi3+0x108>
  802c29:	39 d0                	cmp    %edx,%eax
  802c2b:	0f 82 97 00 00 00    	jb     802cc8 <__udivdi3+0x108>
  802c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c38:	31 d2                	xor    %edx,%edx
  802c3a:	31 c0                	xor    %eax,%eax
  802c3c:	83 c4 0c             	add    $0xc,%esp
  802c3f:	5e                   	pop    %esi
  802c40:	5f                   	pop    %edi
  802c41:	5d                   	pop    %ebp
  802c42:	c3                   	ret    
  802c43:	90                   	nop
  802c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c48:	89 f8                	mov    %edi,%eax
  802c4a:	f7 f1                	div    %ecx
  802c4c:	31 d2                	xor    %edx,%edx
  802c4e:	83 c4 0c             	add    $0xc,%esp
  802c51:	5e                   	pop    %esi
  802c52:	5f                   	pop    %edi
  802c53:	5d                   	pop    %ebp
  802c54:	c3                   	ret    
  802c55:	8d 76 00             	lea    0x0(%esi),%esi
  802c58:	89 e9                	mov    %ebp,%ecx
  802c5a:	8b 3c 24             	mov    (%esp),%edi
  802c5d:	d3 e0                	shl    %cl,%eax
  802c5f:	89 c6                	mov    %eax,%esi
  802c61:	b8 20 00 00 00       	mov    $0x20,%eax
  802c66:	29 e8                	sub    %ebp,%eax
  802c68:	89 c1                	mov    %eax,%ecx
  802c6a:	d3 ef                	shr    %cl,%edi
  802c6c:	89 e9                	mov    %ebp,%ecx
  802c6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802c72:	8b 3c 24             	mov    (%esp),%edi
  802c75:	09 74 24 08          	or     %esi,0x8(%esp)
  802c79:	89 d6                	mov    %edx,%esi
  802c7b:	d3 e7                	shl    %cl,%edi
  802c7d:	89 c1                	mov    %eax,%ecx
  802c7f:	89 3c 24             	mov    %edi,(%esp)
  802c82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802c86:	d3 ee                	shr    %cl,%esi
  802c88:	89 e9                	mov    %ebp,%ecx
  802c8a:	d3 e2                	shl    %cl,%edx
  802c8c:	89 c1                	mov    %eax,%ecx
  802c8e:	d3 ef                	shr    %cl,%edi
  802c90:	09 d7                	or     %edx,%edi
  802c92:	89 f2                	mov    %esi,%edx
  802c94:	89 f8                	mov    %edi,%eax
  802c96:	f7 74 24 08          	divl   0x8(%esp)
  802c9a:	89 d6                	mov    %edx,%esi
  802c9c:	89 c7                	mov    %eax,%edi
  802c9e:	f7 24 24             	mull   (%esp)
  802ca1:	39 d6                	cmp    %edx,%esi
  802ca3:	89 14 24             	mov    %edx,(%esp)
  802ca6:	72 30                	jb     802cd8 <__udivdi3+0x118>
  802ca8:	8b 54 24 04          	mov    0x4(%esp),%edx
  802cac:	89 e9                	mov    %ebp,%ecx
  802cae:	d3 e2                	shl    %cl,%edx
  802cb0:	39 c2                	cmp    %eax,%edx
  802cb2:	73 05                	jae    802cb9 <__udivdi3+0xf9>
  802cb4:	3b 34 24             	cmp    (%esp),%esi
  802cb7:	74 1f                	je     802cd8 <__udivdi3+0x118>
  802cb9:	89 f8                	mov    %edi,%eax
  802cbb:	31 d2                	xor    %edx,%edx
  802cbd:	e9 7a ff ff ff       	jmp    802c3c <__udivdi3+0x7c>
  802cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802cc8:	31 d2                	xor    %edx,%edx
  802cca:	b8 01 00 00 00       	mov    $0x1,%eax
  802ccf:	e9 68 ff ff ff       	jmp    802c3c <__udivdi3+0x7c>
  802cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd8:	8d 47 ff             	lea    -0x1(%edi),%eax
  802cdb:	31 d2                	xor    %edx,%edx
  802cdd:	83 c4 0c             	add    $0xc,%esp
  802ce0:	5e                   	pop    %esi
  802ce1:	5f                   	pop    %edi
  802ce2:	5d                   	pop    %ebp
  802ce3:	c3                   	ret    
  802ce4:	66 90                	xchg   %ax,%ax
  802ce6:	66 90                	xchg   %ax,%ax
  802ce8:	66 90                	xchg   %ax,%ax
  802cea:	66 90                	xchg   %ax,%ax
  802cec:	66 90                	xchg   %ax,%ax
  802cee:	66 90                	xchg   %ax,%ax

00802cf0 <__umoddi3>:
  802cf0:	55                   	push   %ebp
  802cf1:	57                   	push   %edi
  802cf2:	56                   	push   %esi
  802cf3:	83 ec 14             	sub    $0x14,%esp
  802cf6:	8b 44 24 28          	mov    0x28(%esp),%eax
  802cfa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802cfe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802d02:	89 c7                	mov    %eax,%edi
  802d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d08:	8b 44 24 30          	mov    0x30(%esp),%eax
  802d0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802d10:	89 34 24             	mov    %esi,(%esp)
  802d13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d17:	85 c0                	test   %eax,%eax
  802d19:	89 c2                	mov    %eax,%edx
  802d1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d1f:	75 17                	jne    802d38 <__umoddi3+0x48>
  802d21:	39 fe                	cmp    %edi,%esi
  802d23:	76 4b                	jbe    802d70 <__umoddi3+0x80>
  802d25:	89 c8                	mov    %ecx,%eax
  802d27:	89 fa                	mov    %edi,%edx
  802d29:	f7 f6                	div    %esi
  802d2b:	89 d0                	mov    %edx,%eax
  802d2d:	31 d2                	xor    %edx,%edx
  802d2f:	83 c4 14             	add    $0x14,%esp
  802d32:	5e                   	pop    %esi
  802d33:	5f                   	pop    %edi
  802d34:	5d                   	pop    %ebp
  802d35:	c3                   	ret    
  802d36:	66 90                	xchg   %ax,%ax
  802d38:	39 f8                	cmp    %edi,%eax
  802d3a:	77 54                	ja     802d90 <__umoddi3+0xa0>
  802d3c:	0f bd e8             	bsr    %eax,%ebp
  802d3f:	83 f5 1f             	xor    $0x1f,%ebp
  802d42:	75 5c                	jne    802da0 <__umoddi3+0xb0>
  802d44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d48:	39 3c 24             	cmp    %edi,(%esp)
  802d4b:	0f 87 e7 00 00 00    	ja     802e38 <__umoddi3+0x148>
  802d51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802d55:	29 f1                	sub    %esi,%ecx
  802d57:	19 c7                	sbb    %eax,%edi
  802d59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802d61:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802d69:	83 c4 14             	add    $0x14,%esp
  802d6c:	5e                   	pop    %esi
  802d6d:	5f                   	pop    %edi
  802d6e:	5d                   	pop    %ebp
  802d6f:	c3                   	ret    
  802d70:	85 f6                	test   %esi,%esi
  802d72:	89 f5                	mov    %esi,%ebp
  802d74:	75 0b                	jne    802d81 <__umoddi3+0x91>
  802d76:	b8 01 00 00 00       	mov    $0x1,%eax
  802d7b:	31 d2                	xor    %edx,%edx
  802d7d:	f7 f6                	div    %esi
  802d7f:	89 c5                	mov    %eax,%ebp
  802d81:	8b 44 24 04          	mov    0x4(%esp),%eax
  802d85:	31 d2                	xor    %edx,%edx
  802d87:	f7 f5                	div    %ebp
  802d89:	89 c8                	mov    %ecx,%eax
  802d8b:	f7 f5                	div    %ebp
  802d8d:	eb 9c                	jmp    802d2b <__umoddi3+0x3b>
  802d8f:	90                   	nop
  802d90:	89 c8                	mov    %ecx,%eax
  802d92:	89 fa                	mov    %edi,%edx
  802d94:	83 c4 14             	add    $0x14,%esp
  802d97:	5e                   	pop    %esi
  802d98:	5f                   	pop    %edi
  802d99:	5d                   	pop    %ebp
  802d9a:	c3                   	ret    
  802d9b:	90                   	nop
  802d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802da0:	8b 04 24             	mov    (%esp),%eax
  802da3:	be 20 00 00 00       	mov    $0x20,%esi
  802da8:	89 e9                	mov    %ebp,%ecx
  802daa:	29 ee                	sub    %ebp,%esi
  802dac:	d3 e2                	shl    %cl,%edx
  802dae:	89 f1                	mov    %esi,%ecx
  802db0:	d3 e8                	shr    %cl,%eax
  802db2:	89 e9                	mov    %ebp,%ecx
  802db4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802db8:	8b 04 24             	mov    (%esp),%eax
  802dbb:	09 54 24 04          	or     %edx,0x4(%esp)
  802dbf:	89 fa                	mov    %edi,%edx
  802dc1:	d3 e0                	shl    %cl,%eax
  802dc3:	89 f1                	mov    %esi,%ecx
  802dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802dc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  802dcd:	d3 ea                	shr    %cl,%edx
  802dcf:	89 e9                	mov    %ebp,%ecx
  802dd1:	d3 e7                	shl    %cl,%edi
  802dd3:	89 f1                	mov    %esi,%ecx
  802dd5:	d3 e8                	shr    %cl,%eax
  802dd7:	89 e9                	mov    %ebp,%ecx
  802dd9:	09 f8                	or     %edi,%eax
  802ddb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  802ddf:	f7 74 24 04          	divl   0x4(%esp)
  802de3:	d3 e7                	shl    %cl,%edi
  802de5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802de9:	89 d7                	mov    %edx,%edi
  802deb:	f7 64 24 08          	mull   0x8(%esp)
  802def:	39 d7                	cmp    %edx,%edi
  802df1:	89 c1                	mov    %eax,%ecx
  802df3:	89 14 24             	mov    %edx,(%esp)
  802df6:	72 2c                	jb     802e24 <__umoddi3+0x134>
  802df8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  802dfc:	72 22                	jb     802e20 <__umoddi3+0x130>
  802dfe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e02:	29 c8                	sub    %ecx,%eax
  802e04:	19 d7                	sbb    %edx,%edi
  802e06:	89 e9                	mov    %ebp,%ecx
  802e08:	89 fa                	mov    %edi,%edx
  802e0a:	d3 e8                	shr    %cl,%eax
  802e0c:	89 f1                	mov    %esi,%ecx
  802e0e:	d3 e2                	shl    %cl,%edx
  802e10:	89 e9                	mov    %ebp,%ecx
  802e12:	d3 ef                	shr    %cl,%edi
  802e14:	09 d0                	or     %edx,%eax
  802e16:	89 fa                	mov    %edi,%edx
  802e18:	83 c4 14             	add    $0x14,%esp
  802e1b:	5e                   	pop    %esi
  802e1c:	5f                   	pop    %edi
  802e1d:	5d                   	pop    %ebp
  802e1e:	c3                   	ret    
  802e1f:	90                   	nop
  802e20:	39 d7                	cmp    %edx,%edi
  802e22:	75 da                	jne    802dfe <__umoddi3+0x10e>
  802e24:	8b 14 24             	mov    (%esp),%edx
  802e27:	89 c1                	mov    %eax,%ecx
  802e29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  802e2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802e31:	eb cb                	jmp    802dfe <__umoddi3+0x10e>
  802e33:	90                   	nop
  802e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  802e3c:	0f 82 0f ff ff ff    	jb     802d51 <__umoddi3+0x61>
  802e42:	e9 1a ff ff ff       	jmp    802d61 <__umoddi3+0x71>
