
obj/user/init.debug：     文件格式 elf32-i386


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
  80002c:	e8 d5 03 00 00       	call   800406 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80004b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	eb 0c                	jmp    800063 <sum+0x23>
		tot ^= i * s[i];
  800057:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80005b:	0f af ca             	imul   %edx,%ecx
  80005e:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800060:	83 c2 01             	add    $0x1,%edx
  800063:	39 da                	cmp    %ebx,%edx
  800065:	7c f0                	jl     800057 <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800067:	5b                   	pop    %ebx
  800068:	5e                   	pop    %esi
  800069:	5d                   	pop    %ebp
  80006a:	c3                   	ret    

0080006b <umain>:

void
umain(int argc, char **argv)
{
  80006b:	55                   	push   %ebp
  80006c:	89 e5                	mov    %esp,%ebp
  80006e:	57                   	push   %edi
  80006f:	56                   	push   %esi
  800070:	53                   	push   %ebx
  800071:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800077:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80007a:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  800081:	e8 d5 04 00 00       	call   80055b <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800086:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008d:	00 
  80008e:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800095:	e8 a6 ff ff ff       	call   800040 <sum>
  80009a:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009f:	74 1a                	je     8000bb <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a1:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000a8:	00 
  8000a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ad:	c7 04 24 68 29 80 00 	movl   $0x802968,(%esp)
  8000b4:	e8 a2 04 00 00       	call   80055b <cprintf>
  8000b9:	eb 0c                	jmp    8000c7 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000bb:	c7 04 24 af 28 80 00 	movl   $0x8028af,(%esp)
  8000c2:	e8 94 04 00 00       	call   80055b <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c7:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000ce:	00 
  8000cf:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000d6:	e8 65 ff ff ff       	call   800040 <sum>
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	74 12                	je     8000f1 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e3:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  8000ea:	e8 6c 04 00 00       	call   80055b <cprintf>
  8000ef:	eb 0c                	jmp    8000fd <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000f1:	c7 04 24 c6 28 80 00 	movl   $0x8028c6,(%esp)
  8000f8:	e8 5e 04 00 00       	call   80055b <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000fd:	c7 44 24 04 dc 28 80 	movl   $0x8028dc,0x4(%esp)
  800104:	00 
  800105:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010b:	89 04 24             	mov    %eax,(%esp)
  80010e:	e8 e4 0a 00 00       	call   800bf7 <strcat>
	for (i = 0; i < argc; i++) {
  800113:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800118:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80011e:	eb 32                	jmp    800152 <umain+0xe7>
		strcat(args, " '");
  800120:	c7 44 24 04 e8 28 80 	movl   $0x8028e8,0x4(%esp)
  800127:	00 
  800128:	89 34 24             	mov    %esi,(%esp)
  80012b:	e8 c7 0a 00 00       	call   800bf7 <strcat>
		strcat(args, argv[i]);
  800130:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800133:	89 44 24 04          	mov    %eax,0x4(%esp)
  800137:	89 34 24             	mov    %esi,(%esp)
  80013a:	e8 b8 0a 00 00       	call   800bf7 <strcat>
		strcat(args, "'");
  80013f:	c7 44 24 04 e9 28 80 	movl   $0x8028e9,0x4(%esp)
  800146:	00 
  800147:	89 34 24             	mov    %esi,(%esp)
  80014a:	e8 a8 0a 00 00       	call   800bf7 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80014f:	83 c3 01             	add    $0x1,%ebx
  800152:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800155:	7c c9                	jl     800120 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800157:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  800168:	e8 ee 03 00 00       	call   80055b <cprintf>

	cprintf("init: running sh\n");
  80016d:	c7 04 24 ef 28 80 00 	movl   $0x8028ef,(%esp)
  800174:	e8 e2 03 00 00       	call   80055b <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800180:	e8 7d 12 00 00       	call   801402 <close>
	if ((r = opencons()) < 0)
  800185:	e8 21 02 00 00       	call   8003ab <opencons>
  80018a:	85 c0                	test   %eax,%eax
  80018c:	79 20                	jns    8001ae <umain+0x143>
		panic("opencons: %e", r);
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	c7 44 24 08 01 29 80 	movl   $0x802901,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 0e 29 80 00 	movl   $0x80290e,(%esp)
  8001a9:	e8 b4 02 00 00       	call   800462 <_panic>
	if (r != 0)
  8001ae:	85 c0                	test   %eax,%eax
  8001b0:	74 20                	je     8001d2 <umain+0x167>
		panic("first opencons used fd %d", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 1a 29 80 	movl   $0x80291a,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 0e 29 80 00 	movl   $0x80290e,(%esp)
  8001cd:	e8 90 02 00 00       	call   800462 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e1:	e8 71 12 00 00       	call   801457 <dup>
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	79 20                	jns    80020a <umain+0x19f>
		panic("dup: %e", r);
  8001ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ee:	c7 44 24 08 34 29 80 	movl   $0x802934,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 0e 29 80 00 	movl   $0x80290e,(%esp)
  800205:	e8 58 02 00 00       	call   800462 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  80020a:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  800211:	e8 45 03 00 00       	call   80055b <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800216:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80021d:	00 
  80021e:	c7 44 24 04 50 29 80 	movl   $0x802950,0x4(%esp)
  800225:	00 
  800226:	c7 04 24 4f 29 80 00 	movl   $0x80294f,(%esp)
  80022d:	e8 b5 1d 00 00       	call   801fe7 <spawnl>
		if (r < 0) {
  800232:	85 c0                	test   %eax,%eax
  800234:	79 12                	jns    800248 <umain+0x1dd>
			cprintf("init: spawn sh: %e\n", r);
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	c7 04 24 53 29 80 00 	movl   $0x802953,(%esp)
  800241:	e8 15 03 00 00       	call   80055b <cprintf>
			continue;
  800246:	eb c2                	jmp    80020a <umain+0x19f>
		}
		wait(r);
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 90 21 00 00       	call   8023e0 <wait>
  800250:	eb b8                	jmp    80020a <umain+0x19f>
  800252:	66 90                	xchg   %ax,%ax
  800254:	66 90                	xchg   %ax,%ax
  800256:	66 90                	xchg   %ax,%ax
  800258:	66 90                	xchg   %ax,%ax
  80025a:	66 90                	xchg   %ax,%ax
  80025c:	66 90                	xchg   %ax,%ax
  80025e:	66 90                	xchg   %ax,%ax

00800260 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800270:	c7 44 24 04 d3 29 80 	movl   $0x8029d3,0x4(%esp)
  800277:	00 
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 54 09 00 00       	call   800bd7 <strcpy>
	return 0;
}
  800283:	b8 00 00 00 00       	mov    $0x0,%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80029b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002a1:	eb 31                	jmp    8002d4 <devcons_write+0x4a>
		m = n - tot;
  8002a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8002a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8002a8:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8002ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8002b0:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8002b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002b7:	03 45 0c             	add    0xc(%ebp),%eax
  8002ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002be:	89 3c 24             	mov    %edi,(%esp)
  8002c1:	e8 ae 0a 00 00       	call   800d74 <memmove>
		sys_cputs(buf, m);
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	89 3c 24             	mov    %edi,(%esp)
  8002cd:	e8 54 0c 00 00       	call   800f26 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002d2:	01 f3                	add    %esi,%ebx
  8002d4:	89 d8                	mov    %ebx,%eax
  8002d6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002d9:	72 c8                	jb     8002a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002db:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8002f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002f5:	75 07                	jne    8002fe <devcons_read+0x18>
  8002f7:	eb 2a                	jmp    800323 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002f9:	e8 d6 0c 00 00       	call   800fd4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002fe:	66 90                	xchg   %ax,%ax
  800300:	e8 3f 0c 00 00       	call   800f44 <sys_cgetc>
  800305:	85 c0                	test   %eax,%eax
  800307:	74 f0                	je     8002f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800309:	85 c0                	test   %eax,%eax
  80030b:	78 16                	js     800323 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80030d:	83 f8 04             	cmp    $0x4,%eax
  800310:	74 0c                	je     80031e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800312:	8b 55 0c             	mov    0xc(%ebp),%edx
  800315:	88 02                	mov    %al,(%edx)
	return 1;
  800317:	b8 01 00 00 00       	mov    $0x1,%eax
  80031c:	eb 05                	jmp    800323 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800331:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 04 24             	mov    %eax,(%esp)
  80033f:	e8 e2 0b 00 00       	call   800f26 <sys_cputs>
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <getchar>:

int
getchar(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80034c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800353:	00 
  800354:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800362:	e8 fe 11 00 00       	call   801565 <read>
	if (r < 0)
  800367:	85 c0                	test   %eax,%eax
  800369:	78 0f                	js     80037a <getchar+0x34>
		return r;
	if (r < 1)
  80036b:	85 c0                	test   %eax,%eax
  80036d:	7e 06                	jle    800375 <getchar+0x2f>
		return -E_EOF;
	return c;
  80036f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800373:	eb 05                	jmp    80037a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800375:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 42 0f 00 00       	call   8012d6 <fd_lookup>
  800394:	85 c0                	test   %eax,%eax
  800396:	78 11                	js     8003a9 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80039b:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003a1:	39 10                	cmp    %edx,(%eax)
  8003a3:	0f 94 c0             	sete   %al
  8003a6:	0f b6 c0             	movzbl %al,%eax
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <opencons>:

int
opencons(void)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 cb 0e 00 00       	call   801287 <fd_alloc>
		return r;
  8003bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	78 40                	js     800402 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003c2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003c9:	00 
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003d8:	e8 16 0c 00 00       	call   800ff3 <sys_page_alloc>
		return r;
  8003dd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	78 1f                	js     800402 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003e3:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 60 0e 00 00       	call   801260 <fd2num>
  800400:	89 c2                	mov    %eax,%edx
}
  800402:	89 d0                	mov    %edx,%eax
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	56                   	push   %esi
  80040a:	53                   	push   %ebx
  80040b:	83 ec 10             	sub    $0x10,%esp
  80040e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800411:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800414:	e8 9c 0b 00 00       	call   800fb5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800419:	25 ff 03 00 00       	and    $0x3ff,%eax
  80041e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800421:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800426:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80042b:	85 db                	test   %ebx,%ebx
  80042d:	7e 07                	jle    800436 <libmain+0x30>
		binaryname = argv[0];
  80042f:	8b 06                	mov    (%esi),%eax
  800431:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  800436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043a:	89 1c 24             	mov    %ebx,(%esp)
  80043d:	e8 29 fc ff ff       	call   80006b <umain>

	// exit gracefully
	exit();
  800442:	e8 07 00 00 00       	call   80044e <exit>
}
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	5b                   	pop    %ebx
  80044b:	5e                   	pop    %esi
  80044c:	5d                   	pop    %ebp
  80044d:	c3                   	ret    

0080044e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800454:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045b:	e8 03 0b 00 00       	call   800f63 <sys_env_destroy>
}
  800460:	c9                   	leave  
  800461:	c3                   	ret    

00800462 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80046a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046d:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  800473:	e8 3d 0b 00 00       	call   800fb5 <sys_getenvid>
  800478:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80047f:	8b 55 08             	mov    0x8(%ebp),%edx
  800482:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800486:	89 74 24 08          	mov    %esi,0x8(%esp)
  80048a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048e:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  800495:	e8 c1 00 00 00       	call   80055b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a1:	89 04 24             	mov    %eax,(%esp)
  8004a4:	e8 51 00 00 00       	call   8004fa <vcprintf>
	cprintf("\n");
  8004a9:	c7 04 24 de 2e 80 00 	movl   $0x802ede,(%esp)
  8004b0:	e8 a6 00 00 00       	call   80055b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b5:	cc                   	int3   
  8004b6:	eb fd                	jmp    8004b5 <_panic+0x53>

008004b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	53                   	push   %ebx
  8004bc:	83 ec 14             	sub    $0x14,%esp
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c2:	8b 13                	mov    (%ebx),%edx
  8004c4:	8d 42 01             	lea    0x1(%edx),%eax
  8004c7:	89 03                	mov    %eax,(%ebx)
  8004c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d5:	75 19                	jne    8004f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004de:	00 
  8004df:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	e8 3c 0a 00 00       	call   800f26 <sys_cputs>
		b->idx = 0;
  8004ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f4:	83 c4 14             	add    $0x14,%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800503:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050a:	00 00 00 
	b.cnt = 0;
  80050d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800514:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	89 44 24 08          	mov    %eax,0x8(%esp)
  800525:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  800536:	e8 79 01 00 00       	call   8006b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 d3 09 00 00       	call   800f26 <sys_cputs>

	return b.cnt;
}
  800553:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800559:	c9                   	leave  
  80055a:	c3                   	ret    

0080055b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800561:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800564:	89 44 24 04          	mov    %eax,0x4(%esp)
  800568:	8b 45 08             	mov    0x8(%ebp),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 87 ff ff ff       	call   8004fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800573:	c9                   	leave  
  800574:	c3                   	ret    
  800575:	66 90                	xchg   %ax,%ax
  800577:	66 90                	xchg   %ax,%ax
  800579:	66 90                	xchg   %ax,%ax
  80057b:	66 90                	xchg   %ax,%ax
  80057d:	66 90                	xchg   %ax,%ax
  80057f:	90                   	nop

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 3c             	sub    $0x3c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d7                	mov    %edx,%edi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 c3                	mov    %eax,%ebx
  800599:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80059c:	8b 45 10             	mov    0x10(%ebp),%eax
  80059f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ad:	39 d9                	cmp    %ebx,%ecx
  8005af:	72 05                	jb     8005b6 <printnum+0x36>
  8005b1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005b4:	77 69                	ja     80061f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005b9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005bd:	83 ee 01             	sub    $0x1,%esi
  8005c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8005cc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8005d0:	89 c3                	mov    %eax,%ebx
  8005d2:	89 d6                	mov    %edx,%esi
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005da:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	e8 0c 20 00 00       	call   802600 <__udivdi3>
  8005f4:	89 d9                	mov    %ebx,%ecx
  8005f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	89 fa                	mov    %edi,%edx
  800607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060a:	e8 71 ff ff ff       	call   800580 <printnum>
  80060f:	eb 1b                	jmp    80062c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	8b 45 18             	mov    0x18(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff d3                	call   *%ebx
  80061d:	eb 03                	jmp    800622 <printnum+0xa2>
  80061f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800622:	83 ee 01             	sub    $0x1,%esi
  800625:	85 f6                	test   %esi,%esi
  800627:	7f e8                	jg     800611 <printnum+0x91>
  800629:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80062c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800630:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800642:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	e8 dc 20 00 00       	call   802730 <__umoddi3>
  800654:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800658:	0f be 80 0f 2a 80 00 	movsbl 0x802a0f(%eax),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800665:	ff d0                	call   *%eax
}
  800667:	83 c4 3c             	add    $0x3c,%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800675:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	3b 50 04             	cmp    0x4(%eax),%edx
  80067e:	73 0a                	jae    80068a <sprintputch+0x1b>
		*b->buf++ = ch;
  800680:	8d 4a 01             	lea    0x1(%edx),%ecx
  800683:	89 08                	mov    %ecx,(%eax)
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	88 02                	mov    %al,(%edx)
}
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800695:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800699:	8b 45 10             	mov    0x10(%ebp),%eax
  80069c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	e8 02 00 00 00       	call   8006b4 <vprintfmt>
	va_end(ap);
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 3c             	sub    $0x3c,%esp
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006c6:	eb 11                	jmp    8006d9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	0f 84 48 04 00 00    	je     800b18 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d9:	83 c7 01             	add    $0x1,%edi
  8006dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e0:	83 f8 25             	cmp    $0x25,%eax
  8006e3:	75 e3                	jne    8006c8 <vprintfmt+0x14>
  8006e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	eb 1f                	jmp    800724 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800708:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80070c:	eb 16                	jmp    800724 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800711:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800715:	eb 0d                	jmp    800724 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800717:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80071d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8d 47 01             	lea    0x1(%edi),%eax
  800727:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072a:	0f b6 17             	movzbl (%edi),%edx
  80072d:	0f b6 c2             	movzbl %dl,%eax
  800730:	83 ea 23             	sub    $0x23,%edx
  800733:	80 fa 55             	cmp    $0x55,%dl
  800736:	0f 87 bf 03 00 00    	ja     800afb <vprintfmt+0x447>
  80073c:	0f b6 d2             	movzbl %dl,%edx
  80073f:	ff 24 95 60 2b 80 00 	jmp    *0x802b60(,%edx,4)
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800749:	ba 00 00 00 00       	mov    $0x0,%edx
  80074e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800751:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800754:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800758:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80075b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80075e:	83 f9 09             	cmp    $0x9,%ecx
  800761:	77 3c                	ja     80079f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800763:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800766:	eb e9                	jmp    800751 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80077c:	eb 27                	jmp    8007a5 <vprintfmt+0xf1>
  80077e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	0f 49 c2             	cmovns %edx,%eax
  80078b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800791:	eb 91                	jmp    800724 <vprintfmt+0x70>
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800796:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80079d:	eb 85                	jmp    800724 <vprintfmt+0x70>
  80079f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a9:	0f 89 75 ff ff ff    	jns    800724 <vprintfmt+0x70>
  8007af:	e9 63 ff ff ff       	jmp    800717 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ba:	e9 65 ff ff ff       	jmp    800724 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ca:	8b 00                	mov    (%eax),%eax
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007d4:	e9 00 ff ff ff       	jmp    8006d9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007dc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	99                   	cltd   
  8007e3:	31 d0                	xor    %edx,%eax
  8007e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007e7:	83 f8 0f             	cmp    $0xf,%eax
  8007ea:	7f 0b                	jg     8007f7 <vprintfmt+0x143>
  8007ec:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	75 20                	jne    800817 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8007f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fb:	c7 44 24 08 27 2a 80 	movl   $0x802a27,0x8(%esp)
  800802:	00 
  800803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800807:	89 34 24             	mov    %esi,(%esp)
  80080a:	e8 7d fe ff ff       	call   80068c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800812:	e9 c2 fe ff ff       	jmp    8006d9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800817:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081b:	c7 44 24 08 1a 2e 80 	movl   $0x802e1a,0x8(%esp)
  800822:	00 
  800823:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800827:	89 34 24             	mov    %esi,(%esp)
  80082a:	e8 5d fe ff ff       	call   80068c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800832:	e9 a2 fe ff ff       	jmp    8006d9 <vprintfmt+0x25>
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80083d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800840:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800843:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800847:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800849:	85 ff                	test   %edi,%edi
  80084b:	b8 20 2a 80 00       	mov    $0x802a20,%eax
  800850:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800853:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800857:	0f 84 92 00 00 00    	je     8008ef <vprintfmt+0x23b>
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	0f 8e 98 00 00 00    	jle    8008fd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800865:	89 54 24 04          	mov    %edx,0x4(%esp)
  800869:	89 3c 24             	mov    %edi,(%esp)
  80086c:	e8 47 03 00 00       	call   800bb8 <strnlen>
  800871:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800874:	29 c1                	sub    %eax,%ecx
  800876:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800879:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80087d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800880:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800883:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800885:	eb 0f                	jmp    800896 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800893:	83 ef 01             	sub    $0x1,%edi
  800896:	85 ff                	test   %edi,%edi
  800898:	7f ed                	jg     800887 <vprintfmt+0x1d3>
  80089a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80089d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008a0:	85 c9                	test   %ecx,%ecx
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a7:	0f 49 c1             	cmovns %ecx,%eax
  8008aa:	29 c1                	sub    %eax,%ecx
  8008ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8008af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b5:	89 cb                	mov    %ecx,%ebx
  8008b7:	eb 50                	jmp    800909 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008bd:	74 1e                	je     8008dd <vprintfmt+0x229>
  8008bf:	0f be d2             	movsbl %dl,%edx
  8008c2:	83 ea 20             	sub    $0x20,%edx
  8008c5:	83 fa 5e             	cmp    $0x5e,%edx
  8008c8:	76 13                	jbe    8008dd <vprintfmt+0x229>
					putch('?', putdat);
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008d8:	ff 55 08             	call   *0x8(%ebp)
  8008db:	eb 0d                	jmp    8008ea <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ea:	83 eb 01             	sub    $0x1,%ebx
  8008ed:	eb 1a                	jmp    800909 <vprintfmt+0x255>
  8008ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8008f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008fb:	eb 0c                	jmp    800909 <vprintfmt+0x255>
  8008fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800900:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800903:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800906:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800909:	83 c7 01             	add    $0x1,%edi
  80090c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800910:	0f be c2             	movsbl %dl,%eax
  800913:	85 c0                	test   %eax,%eax
  800915:	74 25                	je     80093c <vprintfmt+0x288>
  800917:	85 f6                	test   %esi,%esi
  800919:	78 9e                	js     8008b9 <vprintfmt+0x205>
  80091b:	83 ee 01             	sub    $0x1,%esi
  80091e:	79 99                	jns    8008b9 <vprintfmt+0x205>
  800920:	89 df                	mov    %ebx,%edi
  800922:	8b 75 08             	mov    0x8(%ebp),%esi
  800925:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800928:	eb 1a                	jmp    800944 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800935:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800937:	83 ef 01             	sub    $0x1,%edi
  80093a:	eb 08                	jmp    800944 <vprintfmt+0x290>
  80093c:	89 df                	mov    %ebx,%edi
  80093e:	8b 75 08             	mov    0x8(%ebp),%esi
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800944:	85 ff                	test   %edi,%edi
  800946:	7f e2                	jg     80092a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094b:	e9 89 fd ff ff       	jmp    8006d9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800950:	83 f9 01             	cmp    $0x1,%ecx
  800953:	7e 19                	jle    80096e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 50 04             	mov    0x4(%eax),%edx
  80095b:	8b 00                	mov    (%eax),%eax
  80095d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8d 40 08             	lea    0x8(%eax),%eax
  800969:	89 45 14             	mov    %eax,0x14(%ebp)
  80096c:	eb 38                	jmp    8009a6 <vprintfmt+0x2f2>
	else if (lflag)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 1b                	je     80098d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8b 00                	mov    (%eax),%eax
  800977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	c1 f9 1f             	sar    $0x1f,%ecx
  80097f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
  80098b:	eb 19                	jmp    8009a6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8b 00                	mov    (%eax),%eax
  800992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800995:	89 c1                	mov    %eax,%ecx
  800997:	c1 f9 1f             	sar    $0x1f,%ecx
  80099a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 40 04             	lea    0x4(%eax),%eax
  8009a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ac:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b5:	0f 89 04 01 00 00    	jns    800abf <vprintfmt+0x40b>
				putch('-', putdat);
  8009bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009ce:	f7 da                	neg    %edx
  8009d0:	83 d1 00             	adc    $0x0,%ecx
  8009d3:	f7 d9                	neg    %ecx
  8009d5:	e9 e5 00 00 00       	jmp    800abf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009da:	83 f9 01             	cmp    $0x1,%ecx
  8009dd:	7e 10                	jle    8009ef <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8009df:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e2:	8b 10                	mov    (%eax),%edx
  8009e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8009e7:	8d 40 08             	lea    0x8(%eax),%eax
  8009ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ed:	eb 26                	jmp    800a15 <vprintfmt+0x361>
	else if (lflag)
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	74 12                	je     800a05 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	8b 10                	mov    (%eax),%edx
  8009f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009fd:	8d 40 04             	lea    0x4(%eax),%eax
  800a00:	89 45 14             	mov    %eax,0x14(%ebp)
  800a03:	eb 10                	jmp    800a15 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	8b 10                	mov    (%eax),%edx
  800a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0f:	8d 40 04             	lea    0x4(%eax),%eax
  800a12:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a15:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800a1a:	e9 a0 00 00 00       	jmp    800abf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a23:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a2a:	ff d6                	call   *%esi
			putch('X', putdat);
  800a2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a30:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a37:	ff d6                	call   *%esi
			putch('X', putdat);
  800a39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a44:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a49:	e9 8b fc ff ff       	jmp    8006d9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800a4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a52:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a59:	ff d6                	call   *%esi
			putch('x', putdat);
  800a5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a66:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a68:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6b:	8b 10                	mov    (%eax),%edx
  800a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800a72:	8d 40 04             	lea    0x4(%eax),%eax
  800a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a78:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800a7d:	eb 40                	jmp    800abf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7f:	83 f9 01             	cmp    $0x1,%ecx
  800a82:	7e 10                	jle    800a94 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8b 10                	mov    (%eax),%edx
  800a89:	8b 48 04             	mov    0x4(%eax),%ecx
  800a8c:	8d 40 08             	lea    0x8(%eax),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a92:	eb 26                	jmp    800aba <vprintfmt+0x406>
	else if (lflag)
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 12                	je     800aaa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8b 10                	mov    (%eax),%edx
  800a9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa2:	8d 40 04             	lea    0x4(%eax),%eax
  800aa5:	89 45 14             	mov    %eax,0x14(%ebp)
  800aa8:	eb 10                	jmp    800aba <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8b 10                	mov    (%eax),%edx
  800aaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab4:	8d 40 04             	lea    0x4(%eax),%eax
  800ab7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aba:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800abf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ac3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ace:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ad2:	89 14 24             	mov    %edx,(%esp)
  800ad5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ad9:	89 da                	mov    %ebx,%edx
  800adb:	89 f0                	mov    %esi,%eax
  800add:	e8 9e fa ff ff       	call   800580 <printnum>
			break;
  800ae2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae5:	e9 ef fb ff ff       	jmp    8006d9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aee:	89 04 24             	mov    %eax,(%esp)
  800af1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800af6:	e9 de fb ff ff       	jmp    8006d9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800afb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b06:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b08:	eb 03                	jmp    800b0d <vprintfmt+0x459>
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b11:	75 f7                	jne    800b0a <vprintfmt+0x456>
  800b13:	e9 c1 fb ff ff       	jmp    8006d9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800b18:	83 c4 3c             	add    $0x3c,%esp
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 28             	sub    $0x28,%esp
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	74 30                	je     800b71 <vsnprintf+0x51>
  800b41:	85 d2                	test   %edx,%edx
  800b43:	7e 2c                	jle    800b71 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b53:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5a:	c7 04 24 6f 06 80 00 	movl   $0x80066f,(%esp)
  800b61:	e8 4e fb ff ff       	call   8006b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b69:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b6f:	eb 05                	jmp    800b76 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b7e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b85:	8b 45 10             	mov    0x10(%ebp),%eax
  800b88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	89 04 24             	mov    %eax,(%esp)
  800b99:	e8 82 ff ff ff       	call   800b20 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	eb 03                	jmp    800bb0 <strlen+0x10>
		n++;
  800bad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb4:	75 f7                	jne    800bad <strlen+0xd>
		n++;
	return n;
}
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	eb 03                	jmp    800bcb <strnlen+0x13>
		n++;
  800bc8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bcb:	39 d0                	cmp    %edx,%eax
  800bcd:	74 06                	je     800bd5 <strnlen+0x1d>
  800bcf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bd3:	75 f3                	jne    800bc8 <strnlen+0x10>
		n++;
	return n;
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	53                   	push   %ebx
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	83 c1 01             	add    $0x1,%ecx
  800be9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bed:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bf0:	84 db                	test   %bl,%bl
  800bf2:	75 ef                	jne    800be3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 08             	sub    $0x8,%esp
  800bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c01:	89 1c 24             	mov    %ebx,(%esp)
  800c04:	e8 97 ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c10:	01 d8                	add    %ebx,%eax
  800c12:	89 04 24             	mov    %eax,(%esp)
  800c15:	e8 bd ff ff ff       	call   800bd7 <strcpy>
	return dst;
}
  800c1a:	89 d8                	mov    %ebx,%eax
  800c1c:	83 c4 08             	add    $0x8,%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	89 f3                	mov    %esi,%ebx
  800c2f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c32:	89 f2                	mov    %esi,%edx
  800c34:	eb 0f                	jmp    800c45 <strncpy+0x23>
		*dst++ = *src;
  800c36:	83 c2 01             	add    $0x1,%edx
  800c39:	0f b6 01             	movzbl (%ecx),%eax
  800c3c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c3f:	80 39 01             	cmpb   $0x1,(%ecx)
  800c42:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c45:	39 da                	cmp    %ebx,%edx
  800c47:	75 ed                	jne    800c36 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c49:	89 f0                	mov    %esi,%eax
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	8b 75 08             	mov    0x8(%ebp),%esi
  800c57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c63:	85 c9                	test   %ecx,%ecx
  800c65:	75 0b                	jne    800c72 <strlcpy+0x23>
  800c67:	eb 1d                	jmp    800c86 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c69:	83 c0 01             	add    $0x1,%eax
  800c6c:	83 c2 01             	add    $0x1,%edx
  800c6f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c72:	39 d8                	cmp    %ebx,%eax
  800c74:	74 0b                	je     800c81 <strlcpy+0x32>
  800c76:	0f b6 0a             	movzbl (%edx),%ecx
  800c79:	84 c9                	test   %cl,%cl
  800c7b:	75 ec                	jne    800c69 <strlcpy+0x1a>
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	eb 02                	jmp    800c83 <strlcpy+0x34>
  800c81:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c83:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c86:	29 f0                	sub    %esi,%eax
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c95:	eb 06                	jmp    800c9d <strcmp+0x11>
		p++, q++;
  800c97:	83 c1 01             	add    $0x1,%ecx
  800c9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c9d:	0f b6 01             	movzbl (%ecx),%eax
  800ca0:	84 c0                	test   %al,%al
  800ca2:	74 04                	je     800ca8 <strcmp+0x1c>
  800ca4:	3a 02                	cmp    (%edx),%al
  800ca6:	74 ef                	je     800c97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca8:	0f b6 c0             	movzbl %al,%eax
  800cab:	0f b6 12             	movzbl (%edx),%edx
  800cae:	29 d0                	sub    %edx,%eax
}
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	53                   	push   %ebx
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 c3                	mov    %eax,%ebx
  800cbe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cc1:	eb 06                	jmp    800cc9 <strncmp+0x17>
		n--, p++, q++;
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cc9:	39 d8                	cmp    %ebx,%eax
  800ccb:	74 15                	je     800ce2 <strncmp+0x30>
  800ccd:	0f b6 08             	movzbl (%eax),%ecx
  800cd0:	84 c9                	test   %cl,%cl
  800cd2:	74 04                	je     800cd8 <strncmp+0x26>
  800cd4:	3a 0a                	cmp    (%edx),%cl
  800cd6:	74 eb                	je     800cc3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd8:	0f b6 00             	movzbl (%eax),%eax
  800cdb:	0f b6 12             	movzbl (%edx),%edx
  800cde:	29 d0                	sub    %edx,%eax
  800ce0:	eb 05                	jmp    800ce7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf4:	eb 07                	jmp    800cfd <strchr+0x13>
		if (*s == c)
  800cf6:	38 ca                	cmp    %cl,%dl
  800cf8:	74 0f                	je     800d09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	0f b6 10             	movzbl (%eax),%edx
  800d00:	84 d2                	test   %dl,%dl
  800d02:	75 f2                	jne    800cf6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d15:	eb 07                	jmp    800d1e <strfind+0x13>
		if (*s == c)
  800d17:	38 ca                	cmp    %cl,%dl
  800d19:	74 0a                	je     800d25 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d1b:	83 c0 01             	add    $0x1,%eax
  800d1e:	0f b6 10             	movzbl (%eax),%edx
  800d21:	84 d2                	test   %dl,%dl
  800d23:	75 f2                	jne    800d17 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d33:	85 c9                	test   %ecx,%ecx
  800d35:	74 36                	je     800d6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d3d:	75 28                	jne    800d67 <memset+0x40>
  800d3f:	f6 c1 03             	test   $0x3,%cl
  800d42:	75 23                	jne    800d67 <memset+0x40>
		c &= 0xFF;
  800d44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d48:	89 d3                	mov    %edx,%ebx
  800d4a:	c1 e3 08             	shl    $0x8,%ebx
  800d4d:	89 d6                	mov    %edx,%esi
  800d4f:	c1 e6 18             	shl    $0x18,%esi
  800d52:	89 d0                	mov    %edx,%eax
  800d54:	c1 e0 10             	shl    $0x10,%eax
  800d57:	09 f0                	or     %esi,%eax
  800d59:	09 c2                	or     %eax,%edx
  800d5b:	89 d0                	mov    %edx,%eax
  800d5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d5f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d62:	fc                   	cld    
  800d63:	f3 ab                	rep stos %eax,%es:(%edi)
  800d65:	eb 06                	jmp    800d6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6a:	fc                   	cld    
  800d6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d6d:	89 f8                	mov    %edi,%eax
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d82:	39 c6                	cmp    %eax,%esi
  800d84:	73 35                	jae    800dbb <memmove+0x47>
  800d86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d89:	39 d0                	cmp    %edx,%eax
  800d8b:	73 2e                	jae    800dbb <memmove+0x47>
		s += n;
		d += n;
  800d8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d90:	89 d6                	mov    %edx,%esi
  800d92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d9a:	75 13                	jne    800daf <memmove+0x3b>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 0e                	jne    800daf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800da1:	83 ef 04             	sub    $0x4,%edi
  800da4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800da7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800daa:	fd                   	std    
  800dab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dad:	eb 09                	jmp    800db8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800daf:	83 ef 01             	sub    $0x1,%edi
  800db2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800db5:	fd                   	std    
  800db6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800db8:	fc                   	cld    
  800db9:	eb 1d                	jmp    800dd8 <memmove+0x64>
  800dbb:	89 f2                	mov    %esi,%edx
  800dbd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dbf:	f6 c2 03             	test   $0x3,%dl
  800dc2:	75 0f                	jne    800dd3 <memmove+0x5f>
  800dc4:	f6 c1 03             	test   $0x3,%cl
  800dc7:	75 0a                	jne    800dd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dc9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dcc:	89 c7                	mov    %eax,%edi
  800dce:	fc                   	cld    
  800dcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd1:	eb 05                	jmp    800dd8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dd3:	89 c7                	mov    %eax,%edi
  800dd5:	fc                   	cld    
  800dd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de2:	8b 45 10             	mov    0x10(%ebp),%eax
  800de5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	89 04 24             	mov    %eax,(%esp)
  800df6:	e8 79 ff ff ff       	call   800d74 <memmove>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0d:	eb 1a                	jmp    800e29 <memcmp+0x2c>
		if (*s1 != *s2)
  800e0f:	0f b6 02             	movzbl (%edx),%eax
  800e12:	0f b6 19             	movzbl (%ecx),%ebx
  800e15:	38 d8                	cmp    %bl,%al
  800e17:	74 0a                	je     800e23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e19:	0f b6 c0             	movzbl %al,%eax
  800e1c:	0f b6 db             	movzbl %bl,%ebx
  800e1f:	29 d8                	sub    %ebx,%eax
  800e21:	eb 0f                	jmp    800e32 <memcmp+0x35>
		s1++, s2++;
  800e23:	83 c2 01             	add    $0x1,%edx
  800e26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e29:	39 f2                	cmp    %esi,%edx
  800e2b:	75 e2                	jne    800e0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e44:	eb 07                	jmp    800e4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e46:	38 08                	cmp    %cl,(%eax)
  800e48:	74 07                	je     800e51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e4a:	83 c0 01             	add    $0x1,%eax
  800e4d:	39 d0                	cmp    %edx,%eax
  800e4f:	72 f5                	jb     800e46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5f:	eb 03                	jmp    800e64 <strtol+0x11>
		s++;
  800e61:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e64:	0f b6 0a             	movzbl (%edx),%ecx
  800e67:	80 f9 09             	cmp    $0x9,%cl
  800e6a:	74 f5                	je     800e61 <strtol+0xe>
  800e6c:	80 f9 20             	cmp    $0x20,%cl
  800e6f:	74 f0                	je     800e61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e71:	80 f9 2b             	cmp    $0x2b,%cl
  800e74:	75 0a                	jne    800e80 <strtol+0x2d>
		s++;
  800e76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e79:	bf 00 00 00 00       	mov    $0x0,%edi
  800e7e:	eb 11                	jmp    800e91 <strtol+0x3e>
  800e80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e85:	80 f9 2d             	cmp    $0x2d,%cl
  800e88:	75 07                	jne    800e91 <strtol+0x3e>
		s++, neg = 1;
  800e8a:	8d 52 01             	lea    0x1(%edx),%edx
  800e8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e96:	75 15                	jne    800ead <strtol+0x5a>
  800e98:	80 3a 30             	cmpb   $0x30,(%edx)
  800e9b:	75 10                	jne    800ead <strtol+0x5a>
  800e9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ea1:	75 0a                	jne    800ead <strtol+0x5a>
		s += 2, base = 16;
  800ea3:	83 c2 02             	add    $0x2,%edx
  800ea6:	b8 10 00 00 00       	mov    $0x10,%eax
  800eab:	eb 10                	jmp    800ebd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	75 0c                	jne    800ebd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eb1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800eb6:	75 05                	jne    800ebd <strtol+0x6a>
		s++, base = 8;
  800eb8:	83 c2 01             	add    $0x1,%edx
  800ebb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ec5:	0f b6 0a             	movzbl (%edx),%ecx
  800ec8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	3c 09                	cmp    $0x9,%al
  800ecf:	77 08                	ja     800ed9 <strtol+0x86>
			dig = *s - '0';
  800ed1:	0f be c9             	movsbl %cl,%ecx
  800ed4:	83 e9 30             	sub    $0x30,%ecx
  800ed7:	eb 20                	jmp    800ef9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ed9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800edc:	89 f0                	mov    %esi,%eax
  800ede:	3c 19                	cmp    $0x19,%al
  800ee0:	77 08                	ja     800eea <strtol+0x97>
			dig = *s - 'a' + 10;
  800ee2:	0f be c9             	movsbl %cl,%ecx
  800ee5:	83 e9 57             	sub    $0x57,%ecx
  800ee8:	eb 0f                	jmp    800ef9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800eea:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	3c 19                	cmp    $0x19,%al
  800ef1:	77 16                	ja     800f09 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ef3:	0f be c9             	movsbl %cl,%ecx
  800ef6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ef9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800efc:	7d 0f                	jge    800f0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800efe:	83 c2 01             	add    $0x1,%edx
  800f01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800f05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800f07:	eb bc                	jmp    800ec5 <strtol+0x72>
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	eb 02                	jmp    800f0f <strtol+0xbc>
  800f0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800f0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f13:	74 05                	je     800f1a <strtol+0xc7>
		*endptr = (char *) s;
  800f15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800f1a:	f7 d8                	neg    %eax
  800f1c:	85 ff                	test   %edi,%edi
  800f1e:	0f 44 c3             	cmove  %ebx,%eax
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	89 c7                	mov    %eax,%edi
  800f3b:	89 c6                	mov    %eax,%esi
  800f3d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f54:	89 d1                	mov    %edx,%ecx
  800f56:	89 d3                	mov    %edx,%ebx
  800f58:	89 d7                	mov    %edx,%edi
  800f5a:	89 d6                	mov    %edx,%esi
  800f5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f71:	b8 03 00 00 00       	mov    $0x3,%eax
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 cb                	mov    %ecx,%ebx
  800f7b:	89 cf                	mov    %ecx,%edi
  800f7d:	89 ce                	mov    %ecx,%esi
  800f7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	7e 28                	jle    800fad <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f89:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f90:	00 
  800f91:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  800fa8:	e8 b5 f4 ff ff       	call   800462 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fad:	83 c4 2c             	add    $0x2c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 d3                	mov    %edx,%ebx
  800fc9:	89 d7                	mov    %edx,%edi
  800fcb:	89 d6                	mov    %edx,%esi
  800fcd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_yield>:

void
sys_yield(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fe4:	89 d1                	mov    %edx,%ecx
  800fe6:	89 d3                	mov    %edx,%ebx
  800fe8:	89 d7                	mov    %edx,%edi
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	be 00 00 00 00       	mov    $0x0,%esi
  801001:	b8 04 00 00 00       	mov    $0x4,%eax
  801006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100f:	89 f7                	mov    %esi,%edi
  801011:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	7e 28                	jle    80103f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801017:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801022:	00 
  801023:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80102a:	00 
  80102b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801032:	00 
  801033:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80103a:	e8 23 f4 ff ff       	call   800462 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80103f:	83 c4 2c             	add    $0x2c,%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801050:	b8 05 00 00 00       	mov    $0x5,%eax
  801055:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80105e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801061:	8b 75 18             	mov    0x18(%ebp),%esi
  801064:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801066:	85 c0                	test   %eax,%eax
  801068:	7e 28                	jle    801092 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801075:	00 
  801076:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80107d:	00 
  80107e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801085:	00 
  801086:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80108d:	e8 d0 f3 ff ff       	call   800462 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801092:	83 c4 2c             	add    $0x2c,%esp
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	89 df                	mov    %ebx,%edi
  8010b5:	89 de                	mov    %ebx,%esi
  8010b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	7e 28                	jle    8010e5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010c8:	00 
  8010c9:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d8:	00 
  8010d9:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  8010e0:	e8 7d f3 ff ff       	call   800462 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010e5:	83 c4 2c             	add    $0x2c,%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	89 df                	mov    %ebx,%edi
  801108:	89 de                	mov    %ebx,%esi
  80110a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110c:	85 c0                	test   %eax,%eax
  80110e:	7e 28                	jle    801138 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801110:	89 44 24 10          	mov    %eax,0x10(%esp)
  801114:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80111b:	00 
  80111c:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801123:	00 
  801124:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112b:	00 
  80112c:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801133:	e8 2a f3 ff ff       	call   800462 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801138:	83 c4 2c             	add    $0x2c,%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114e:	b8 09 00 00 00       	mov    $0x9,%eax
  801153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801156:	8b 55 08             	mov    0x8(%ebp),%edx
  801159:	89 df                	mov    %ebx,%edi
  80115b:	89 de                	mov    %ebx,%esi
  80115d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80115f:	85 c0                	test   %eax,%eax
  801161:	7e 28                	jle    80118b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801163:	89 44 24 10          	mov    %eax,0x10(%esp)
  801167:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80116e:	00 
  80116f:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801176:	00 
  801177:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80117e:	00 
  80117f:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801186:	e8 d7 f2 ff ff       	call   800462 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80118b:	83 c4 2c             	add    $0x2c,%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 df                	mov    %ebx,%edi
  8011ae:	89 de                	mov    %ebx,%esi
  8011b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	7e 28                	jle    8011de <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ba:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d1:	00 
  8011d2:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  8011d9:	e8 84 f2 ff ff       	call   800462 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011de:	83 c4 2c             	add    $0x2c,%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ec:	be 00 00 00 00       	mov    $0x0,%esi
  8011f1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  801202:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	53                   	push   %ebx
  80120f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801212:	b9 00 00 00 00       	mov    $0x0,%ecx
  801217:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121c:	8b 55 08             	mov    0x8(%ebp),%edx
  80121f:	89 cb                	mov    %ecx,%ebx
  801221:	89 cf                	mov    %ecx,%edi
  801223:	89 ce                	mov    %ecx,%esi
  801225:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	7e 28                	jle    801253 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80122f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801236:	00 
  801237:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801246:	00 
  801247:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80124e:	e8 0f f2 ff ff       	call   800462 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801253:	83 c4 2c             	add    $0x2c,%esp
  801256:	5b                   	pop    %ebx
  801257:	5e                   	pop    %esi
  801258:	5f                   	pop    %edi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    
  80125b:	66 90                	xchg   %ax,%ax
  80125d:	66 90                	xchg   %ax,%ax
  80125f:	90                   	nop

00801260 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	05 00 00 00 30       	add    $0x30000000,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80127b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801280:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 16             	shr    $0x16,%edx
  801297:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 11                	je     8012b4 <fd_alloc+0x2d>
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	c1 ea 0c             	shr    $0xc,%edx
  8012a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	75 09                	jne    8012bd <fd_alloc+0x36>
			*fd_store = fd;
  8012b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bb:	eb 17                	jmp    8012d4 <fd_alloc+0x4d>
  8012bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c7:	75 c9                	jne    801292 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012dc:	83 f8 1f             	cmp    $0x1f,%eax
  8012df:	77 36                	ja     801317 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e1:	c1 e0 0c             	shl    $0xc,%eax
  8012e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 ea 16             	shr    $0x16,%edx
  8012ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f5:	f6 c2 01             	test   $0x1,%dl
  8012f8:	74 24                	je     80131e <fd_lookup+0x48>
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	c1 ea 0c             	shr    $0xc,%edx
  8012ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801306:	f6 c2 01             	test   $0x1,%dl
  801309:	74 1a                	je     801325 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130e:	89 02                	mov    %eax,(%edx)
	return 0;
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	eb 13                	jmp    80132a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131c:	eb 0c                	jmp    80132a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801323:	eb 05                	jmp    80132a <fd_lookup+0x54>
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 18             	sub    $0x18,%esp
  801332:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801335:	ba c8 2d 80 00       	mov    $0x802dc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80133a:	eb 13                	jmp    80134f <dev_lookup+0x23>
  80133c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80133f:	39 08                	cmp    %ecx,(%eax)
  801341:	75 0c                	jne    80134f <dev_lookup+0x23>
			*dev = devtab[i];
  801343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801346:	89 01                	mov    %eax,(%ecx)
			return 0;
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
  80134d:	eb 30                	jmp    80137f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80134f:	8b 02                	mov    (%edx),%eax
  801351:	85 c0                	test   %eax,%eax
  801353:	75 e7                	jne    80133c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801355:	a1 90 67 80 00       	mov    0x806790,%eax
  80135a:	8b 40 48             	mov    0x48(%eax),%eax
  80135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	c7 04 24 4c 2d 80 00 	movl   $0x802d4c,(%esp)
  80136c:	e8 ea f1 ff ff       	call   80055b <cprintf>
	*dev = 0;
  801371:	8b 45 0c             	mov    0xc(%ebp),%eax
  801374:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80137a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	83 ec 20             	sub    $0x20,%esp
  801389:	8b 75 08             	mov    0x8(%ebp),%esi
  80138c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801396:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80139c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139f:	89 04 24             	mov    %eax,(%esp)
  8013a2:	e8 2f ff ff ff       	call   8012d6 <fd_lookup>
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 05                	js     8013b0 <fd_close+0x2f>
	    || fd != fd2)
  8013ab:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ae:	74 0c                	je     8013bc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8013b0:	84 db                	test   %bl,%bl
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	0f 44 c2             	cmove  %edx,%eax
  8013ba:	eb 3f                	jmp    8013fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c3:	8b 06                	mov    (%esi),%eax
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	e8 5f ff ff ff       	call   80132c <dev_lookup>
  8013cd:	89 c3                	mov    %eax,%ebx
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 16                	js     8013e9 <fd_close+0x68>
		if (dev->dev_close)
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	74 07                	je     8013e9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8013e2:	89 34 24             	mov    %esi,(%esp)
  8013e5:	ff d0                	call   *%eax
  8013e7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f4:	e8 a1 fc ff ff       	call   80109a <sys_page_unmap>
	return r;
  8013f9:	89 d8                	mov    %ebx,%eax
}
  8013fb:	83 c4 20             	add    $0x20,%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 bc fe ff ff       	call   8012d6 <fd_lookup>
  80141a:	89 c2                	mov    %eax,%edx
  80141c:	85 d2                	test   %edx,%edx
  80141e:	78 13                	js     801433 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801420:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801427:	00 
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 4e ff ff ff       	call   801381 <fd_close>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <close_all>:

void
close_all(void)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801441:	89 1c 24             	mov    %ebx,(%esp)
  801444:	e8 b9 ff ff ff       	call   801402 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801449:	83 c3 01             	add    $0x1,%ebx
  80144c:	83 fb 20             	cmp    $0x20,%ebx
  80144f:	75 f0                	jne    801441 <close_all+0xc>
		close(i);
}
  801451:	83 c4 14             	add    $0x14,%esp
  801454:	5b                   	pop    %ebx
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	57                   	push   %edi
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	89 04 24             	mov    %eax,(%esp)
  80146d:	e8 64 fe ff ff       	call   8012d6 <fd_lookup>
  801472:	89 c2                	mov    %eax,%edx
  801474:	85 d2                	test   %edx,%edx
  801476:	0f 88 e1 00 00 00    	js     80155d <dup+0x106>
		return r;
	close(newfdnum);
  80147c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	e8 7b ff ff ff       	call   801402 <close>

	newfd = INDEX2FD(newfdnum);
  801487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148a:	c1 e3 0c             	shl    $0xc,%ebx
  80148d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801496:	89 04 24             	mov    %eax,(%esp)
  801499:	e8 d2 fd ff ff       	call   801270 <fd2data>
  80149e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8014a0:	89 1c 24             	mov    %ebx,(%esp)
  8014a3:	e8 c8 fd ff ff       	call   801270 <fd2data>
  8014a8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	c1 e8 16             	shr    $0x16,%eax
  8014af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b6:	a8 01                	test   $0x1,%al
  8014b8:	74 43                	je     8014fd <dup+0xa6>
  8014ba:	89 f0                	mov    %esi,%eax
  8014bc:	c1 e8 0c             	shr    $0xc,%eax
  8014bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	74 32                	je     8014fd <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014e6:	00 
  8014e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f2:	e8 50 fb ff ff       	call   801047 <sys_page_map>
  8014f7:	89 c6                	mov    %eax,%esi
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 3e                	js     80153b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 0c             	shr    $0xc,%edx
  801505:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801512:	89 54 24 10          	mov    %edx,0x10(%esp)
  801516:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80151a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801521:	00 
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152d:	e8 15 fb ff ff       	call   801047 <sys_page_map>
  801532:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801534:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801537:	85 f6                	test   %esi,%esi
  801539:	79 22                	jns    80155d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801546:	e8 4f fb ff ff       	call   80109a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80154b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80154f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801556:	e8 3f fb ff ff       	call   80109a <sys_page_unmap>
	return r;
  80155b:	89 f0                	mov    %esi,%eax
}
  80155d:	83 c4 3c             	add    $0x3c,%esp
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	53                   	push   %ebx
  801569:	83 ec 24             	sub    $0x24,%esp
  80156c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	89 1c 24             	mov    %ebx,(%esp)
  801579:	e8 58 fd ff ff       	call   8012d6 <fd_lookup>
  80157e:	89 c2                	mov    %eax,%edx
  801580:	85 d2                	test   %edx,%edx
  801582:	78 6d                	js     8015f1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158e:	8b 00                	mov    (%eax),%eax
  801590:	89 04 24             	mov    %eax,(%esp)
  801593:	e8 94 fd ff ff       	call   80132c <dev_lookup>
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 55                	js     8015f1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	8b 50 08             	mov    0x8(%eax),%edx
  8015a2:	83 e2 03             	and    $0x3,%edx
  8015a5:	83 fa 01             	cmp    $0x1,%edx
  8015a8:	75 23                	jne    8015cd <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015aa:	a1 90 67 80 00       	mov    0x806790,%eax
  8015af:	8b 40 48             	mov    0x48(%eax),%eax
  8015b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ba:	c7 04 24 8d 2d 80 00 	movl   $0x802d8d,(%esp)
  8015c1:	e8 95 ef ff ff       	call   80055b <cprintf>
		return -E_INVAL;
  8015c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cb:	eb 24                	jmp    8015f1 <read+0x8c>
	}
	if (!dev->dev_read)
  8015cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d0:	8b 52 08             	mov    0x8(%edx),%edx
  8015d3:	85 d2                	test   %edx,%edx
  8015d5:	74 15                	je     8015ec <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015e5:	89 04 24             	mov    %eax,(%esp)
  8015e8:	ff d2                	call   *%edx
  8015ea:	eb 05                	jmp    8015f1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015f1:	83 c4 24             	add    $0x24,%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 1c             	sub    $0x1c,%esp
  801600:	8b 7d 08             	mov    0x8(%ebp),%edi
  801603:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801606:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160b:	eb 23                	jmp    801630 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160d:	89 f0                	mov    %esi,%eax
  80160f:	29 d8                	sub    %ebx,%eax
  801611:	89 44 24 08          	mov    %eax,0x8(%esp)
  801615:	89 d8                	mov    %ebx,%eax
  801617:	03 45 0c             	add    0xc(%ebp),%eax
  80161a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161e:	89 3c 24             	mov    %edi,(%esp)
  801621:	e8 3f ff ff ff       	call   801565 <read>
		if (m < 0)
  801626:	85 c0                	test   %eax,%eax
  801628:	78 10                	js     80163a <readn+0x43>
			return m;
		if (m == 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	74 0a                	je     801638 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162e:	01 c3                	add    %eax,%ebx
  801630:	39 f3                	cmp    %esi,%ebx
  801632:	72 d9                	jb     80160d <readn+0x16>
  801634:	89 d8                	mov    %ebx,%eax
  801636:	eb 02                	jmp    80163a <readn+0x43>
  801638:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80163a:	83 c4 1c             	add    $0x1c,%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5e                   	pop    %esi
  80163f:	5f                   	pop    %edi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	83 ec 24             	sub    $0x24,%esp
  801649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 7b fc ff ff       	call   8012d6 <fd_lookup>
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	85 d2                	test   %edx,%edx
  80165f:	78 68                	js     8016c9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	89 44 24 04          	mov    %eax,0x4(%esp)
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	8b 00                	mov    (%eax),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	e8 b7 fc ff ff       	call   80132c <dev_lookup>
  801675:	85 c0                	test   %eax,%eax
  801677:	78 50                	js     8016c9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801680:	75 23                	jne    8016a5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801682:	a1 90 67 80 00       	mov    0x806790,%eax
  801687:	8b 40 48             	mov    0x48(%eax),%eax
  80168a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80168e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801692:	c7 04 24 a9 2d 80 00 	movl   $0x802da9,(%esp)
  801699:	e8 bd ee ff ff       	call   80055b <cprintf>
		return -E_INVAL;
  80169e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a3:	eb 24                	jmp    8016c9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 15                	je     8016c4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	ff d2                	call   *%edx
  8016c2:	eb 05                	jmp    8016c9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016c9:	83 c4 24             	add    $0x24,%esp
  8016cc:	5b                   	pop    %ebx
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	89 04 24             	mov    %eax,(%esp)
  8016e2:	e8 ef fb ff ff       	call   8012d6 <fd_lookup>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 0e                	js     8016f9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 24             	sub    $0x24,%esp
  801702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170c:	89 1c 24             	mov    %ebx,(%esp)
  80170f:	e8 c2 fb ff ff       	call   8012d6 <fd_lookup>
  801714:	89 c2                	mov    %eax,%edx
  801716:	85 d2                	test   %edx,%edx
  801718:	78 61                	js     80177b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	8b 00                	mov    (%eax),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	e8 fe fb ff ff       	call   80132c <dev_lookup>
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 49                	js     80177b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801739:	75 23                	jne    80175e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80173b:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801740:	8b 40 48             	mov    0x48(%eax),%eax
  801743:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174b:	c7 04 24 6c 2d 80 00 	movl   $0x802d6c,(%esp)
  801752:	e8 04 ee ff ff       	call   80055b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175c:	eb 1d                	jmp    80177b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80175e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801761:	8b 52 18             	mov    0x18(%edx),%edx
  801764:	85 d2                	test   %edx,%edx
  801766:	74 0e                	je     801776 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	ff d2                	call   *%edx
  801774:	eb 05                	jmp    80177b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801776:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80177b:	83 c4 24             	add    $0x24,%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 24             	sub    $0x24,%esp
  801788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 39 fb ff ff       	call   8012d6 <fd_lookup>
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	85 d2                	test   %edx,%edx
  8017a1:	78 52                	js     8017f5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	8b 00                	mov    (%eax),%eax
  8017af:	89 04 24             	mov    %eax,(%esp)
  8017b2:	e8 75 fb ff ff       	call   80132c <dev_lookup>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 3a                	js     8017f5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  8017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c2:	74 2c                	je     8017f0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ce:	00 00 00 
	stat->st_isdir = 0;
  8017d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d8:	00 00 00 
	stat->st_dev = dev;
  8017db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e8:	89 14 24             	mov    %edx,(%esp)
  8017eb:	ff 50 14             	call   *0x14(%eax)
  8017ee:	eb 05                	jmp    8017f5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017f5:	83 c4 24             	add    $0x24,%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801803:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80180a:	00 
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 fb 01 00 00       	call   801a11 <open>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	85 db                	test   %ebx,%ebx
  80181a:	78 1b                	js     801837 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80181c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	89 1c 24             	mov    %ebx,(%esp)
  801826:	e8 56 ff ff ff       	call   801781 <fstat>
  80182b:	89 c6                	mov    %eax,%esi
	close(fd);
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 cd fb ff ff       	call   801402 <close>
	return r;
  801835:	89 f0                	mov    %esi,%eax
}
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 10             	sub    $0x10,%esp
  801846:	89 c6                	mov    %eax,%esi
  801848:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80184a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801851:	75 11                	jne    801864 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801853:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80185a:	e8 2e 0d 00 00       	call   80258d <ipc_find_env>
  80185f:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801864:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80186b:	00 
  80186c:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801873:	00 
  801874:	89 74 24 04          	mov    %esi,0x4(%esp)
  801878:	a1 00 50 80 00       	mov    0x805000,%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 59 0c 00 00       	call   8024de <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801885:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188c:	00 
  80188d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801891:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801898:	e8 a3 0b 00 00       	call   802440 <ipc_recv>
}
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8018b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b8:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c7:	e8 72 ff ff ff       	call   80183e <fsipc>
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018da:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e9:	e8 50 ff ff ff       	call   80183e <fsipc>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	53                   	push   %ebx
  8018f4:	83 ec 14             	sub    $0x14,%esp
  8018f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801900:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801905:	ba 00 00 00 00       	mov    $0x0,%edx
  80190a:	b8 05 00 00 00       	mov    $0x5,%eax
  80190f:	e8 2a ff ff ff       	call   80183e <fsipc>
  801914:	89 c2                	mov    %eax,%edx
  801916:	85 d2                	test   %edx,%edx
  801918:	78 2b                	js     801945 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80191a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801921:	00 
  801922:	89 1c 24             	mov    %ebx,(%esp)
  801925:	e8 ad f2 ff ff       	call   800bd7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80192a:	a1 80 70 80 00       	mov    0x807080,%eax
  80192f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801935:	a1 84 70 80 00       	mov    0x807084,%eax
  80193a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	83 c4 14             	add    $0x14,%esp
  801948:	5b                   	pop    %ebx
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801951:	c7 44 24 08 d8 2d 80 	movl   $0x802dd8,0x8(%esp)
  801958:	00 
  801959:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801960:	00 
  801961:	c7 04 24 f6 2d 80 00 	movl   $0x802df6,(%esp)
  801968:	e8 f5 ea ff ff       	call   800462 <_panic>

0080196d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	83 ec 10             	sub    $0x10,%esp
  801975:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	8b 40 0c             	mov    0xc(%eax),%eax
  80197e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801983:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801989:	ba 00 00 00 00       	mov    $0x0,%edx
  80198e:	b8 03 00 00 00       	mov    $0x3,%eax
  801993:	e8 a6 fe ff ff       	call   80183e <fsipc>
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 6a                	js     801a08 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80199e:	39 c6                	cmp    %eax,%esi
  8019a0:	73 24                	jae    8019c6 <devfile_read+0x59>
  8019a2:	c7 44 24 0c 01 2e 80 	movl   $0x802e01,0xc(%esp)
  8019a9:	00 
  8019aa:	c7 44 24 08 08 2e 80 	movl   $0x802e08,0x8(%esp)
  8019b1:	00 
  8019b2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019b9:	00 
  8019ba:	c7 04 24 f6 2d 80 00 	movl   $0x802df6,(%esp)
  8019c1:	e8 9c ea ff ff       	call   800462 <_panic>
	assert(r <= PGSIZE);
  8019c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019cb:	7e 24                	jle    8019f1 <devfile_read+0x84>
  8019cd:	c7 44 24 0c 1d 2e 80 	movl   $0x802e1d,0xc(%esp)
  8019d4:	00 
  8019d5:	c7 44 24 08 08 2e 80 	movl   $0x802e08,0x8(%esp)
  8019dc:	00 
  8019dd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019e4:	00 
  8019e5:	c7 04 24 f6 2d 80 00 	movl   $0x802df6,(%esp)
  8019ec:	e8 71 ea ff ff       	call   800462 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8019fc:	00 
  8019fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a00:	89 04 24             	mov    %eax,(%esp)
  801a03:	e8 6c f3 ff ff       	call   800d74 <memmove>
	return r;
}
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 24             	sub    $0x24,%esp
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1b:	89 1c 24             	mov    %ebx,(%esp)
  801a1e:	e8 7d f1 ff ff       	call   800ba0 <strlen>
  801a23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a28:	7f 60                	jg     801a8a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2d:	89 04 24             	mov    %eax,(%esp)
  801a30:	e8 52 f8 ff ff       	call   801287 <fd_alloc>
  801a35:	89 c2                	mov    %eax,%edx
  801a37:	85 d2                	test   %edx,%edx
  801a39:	78 54                	js     801a8f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3f:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801a46:	e8 8c f1 ff ff       	call   800bd7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4e:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a56:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5b:	e8 de fd ff ff       	call   80183e <fsipc>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	85 c0                	test   %eax,%eax
  801a64:	79 17                	jns    801a7d <open+0x6c>
		fd_close(fd, 0);
  801a66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a6d:	00 
  801a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a71:	89 04 24             	mov    %eax,(%esp)
  801a74:	e8 08 f9 ff ff       	call   801381 <fd_close>
		return r;
  801a79:	89 d8                	mov    %ebx,%eax
  801a7b:	eb 12                	jmp    801a8f <open+0x7e>
	}

	return fd2num(fd);
  801a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 d8 f7 ff ff       	call   801260 <fd2num>
  801a88:	eb 05                	jmp    801a8f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a8a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a8f:	83 c4 24             	add    $0x24,%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa0:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa5:	e8 94 fd ff ff       	call   80183e <fsipc>
}
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    
  801aac:	66 90                	xchg   %ax,%ax
  801aae:	66 90                	xchg   %ax,%ax

00801ab0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801abc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ac3:	00 
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	89 04 24             	mov    %eax,(%esp)
  801aca:	e8 42 ff ff ff       	call   801a11 <open>
  801acf:	89 c1                	mov    %eax,%ecx
  801ad1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 9e 04 00 00    	js     801f7d <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801adf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801ae6:	00 
  801ae7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	89 0c 24             	mov    %ecx,(%esp)
  801af4:	e8 fe fa ff ff       	call   8015f7 <readn>
  801af9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801afe:	75 0c                	jne    801b0c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801b00:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b07:	45 4c 46 
  801b0a:	74 36                	je     801b42 <spawn+0x92>
		close(fd);
  801b0c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	e8 e8 f8 ff ff       	call   801402 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b1a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801b21:	46 
  801b22:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2c:	c7 04 24 29 2e 80 00 	movl   $0x802e29,(%esp)
  801b33:	e8 23 ea ff ff       	call   80055b <cprintf>
		return -E_NOT_EXEC;
  801b38:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801b3d:	e9 9a 04 00 00       	jmp    801fdc <spawn+0x52c>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801b42:	b8 07 00 00 00       	mov    $0x7,%eax
  801b47:	cd 30                	int    $0x30
  801b49:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801b4f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 28 04 00 00    	js     801f85 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b5d:	89 c6                	mov    %eax,%esi
  801b5f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b65:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801b68:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b6e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b74:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b7b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b81:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b87:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801b8c:	be 00 00 00 00       	mov    $0x0,%esi
  801b91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b94:	eb 0f                	jmp    801ba5 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b96:	89 04 24             	mov    %eax,(%esp)
  801b99:	e8 02 f0 ff ff       	call   800ba0 <strlen>
  801b9e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ba2:	83 c3 01             	add    $0x1,%ebx
  801ba5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801bac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	75 e3                	jne    801b96 <spawn+0xe6>
  801bb3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801bb9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801bbf:	bf 00 10 40 00       	mov    $0x401000,%edi
  801bc4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	83 e2 fc             	and    $0xfffffffc,%edx
  801bcb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801bd2:	29 c2                	sub    %eax,%edx
  801bd4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801bda:	8d 42 f8             	lea    -0x8(%edx),%eax
  801bdd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801be2:	0f 86 ad 03 00 00    	jbe    801f95 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801be8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801bef:	00 
  801bf0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bf7:	00 
  801bf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bff:	e8 ef f3 ff ff       	call   800ff3 <sys_page_alloc>
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 d0 03 00 00    	js     801fdc <spawn+0x52c>
  801c0c:	be 00 00 00 00       	mov    $0x0,%esi
  801c11:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801c17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c1a:	eb 30                	jmp    801c4c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801c1c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c22:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801c28:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801c2b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	89 3c 24             	mov    %edi,(%esp)
  801c35:	e8 9d ef ff ff       	call   800bd7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c3a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  801c3d:	89 04 24             	mov    %eax,(%esp)
  801c40:	e8 5b ef ff ff       	call   800ba0 <strlen>
  801c45:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c49:	83 c6 01             	add    $0x1,%esi
  801c4c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801c52:	7f c8                	jg     801c1c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c54:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c5a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801c60:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c67:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c6d:	74 24                	je     801c93 <spawn+0x1e3>
  801c6f:	c7 44 24 0c a0 2e 80 	movl   $0x802ea0,0xc(%esp)
  801c76:	00 
  801c77:	c7 44 24 08 08 2e 80 	movl   $0x802e08,0x8(%esp)
  801c7e:	00 
  801c7f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801c86:	00 
  801c87:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801c8e:	e8 cf e7 ff ff       	call   800462 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c93:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801c99:	89 c8                	mov    %ecx,%eax
  801c9b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ca0:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ca3:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ca9:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801cac:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801cb2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801cb8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801cbf:	00 
  801cc0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801cc7:	ee 
  801cc8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cce:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cd9:	00 
  801cda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce1:	e8 61 f3 ff ff       	call   801047 <sys_page_map>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	0f 88 d6 02 00 00    	js     801fc6 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cf0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cf7:	00 
  801cf8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cff:	e8 96 f3 ff ff       	call   80109a <sys_page_unmap>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	85 c0                	test   %eax,%eax
  801d08:	0f 88 b8 02 00 00    	js     801fc6 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d0e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801d14:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d1b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d21:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801d28:	00 00 00 
  801d2b:	e9 b6 01 00 00       	jmp    801ee6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  801d30:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801d36:	83 38 01             	cmpl   $0x1,(%eax)
  801d39:	0f 85 99 01 00 00    	jne    801ed8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d3f:	89 c1                	mov    %eax,%ecx
  801d41:	8b 40 18             	mov    0x18(%eax),%eax
  801d44:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d47:	83 f8 01             	cmp    $0x1,%eax
  801d4a:	19 c0                	sbb    %eax,%eax
  801d4c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801d52:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  801d59:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	8b 51 04             	mov    0x4(%ecx),%edx
  801d65:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801d6b:	8b 49 10             	mov    0x10(%ecx),%ecx
  801d6e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801d74:	8b 50 14             	mov    0x14(%eax),%edx
  801d77:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d7d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d80:	89 f0                	mov    %esi,%eax
  801d82:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d87:	74 14                	je     801d9d <spawn+0x2ed>
		va -= i;
  801d89:	29 c6                	sub    %eax,%esi
		memsz += i;
  801d8b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801d91:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801d97:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da2:	e9 23 01 00 00       	jmp    801eca <spawn+0x41a>
		if (i >= filesz) {
  801da7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801dad:	77 2b                	ja     801dda <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801daf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801db5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dbd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801dc3:	89 04 24             	mov    %eax,(%esp)
  801dc6:	e8 28 f2 ff ff       	call   800ff3 <sys_page_alloc>
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	0f 89 eb 00 00 00    	jns    801ebe <spawn+0x40e>
  801dd3:	89 c3                	mov    %eax,%ebx
  801dd5:	e9 cc 01 00 00       	jmp    801fa6 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dda:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801de1:	00 
  801de2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801de9:	00 
  801dea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df1:	e8 fd f1 ff ff       	call   800ff3 <sys_page_alloc>
  801df6:	85 c0                	test   %eax,%eax
  801df8:	0f 88 9e 01 00 00    	js     801f9c <spawn+0x4ec>
  801dfe:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e04:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e10:	89 04 24             	mov    %eax,(%esp)
  801e13:	e8 b7 f8 ff ff       	call   8016cf <seek>
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	0f 88 80 01 00 00    	js     801fa0 <spawn+0x4f0>
  801e20:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e26:	29 fa                	sub    %edi,%edx
  801e28:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e2a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801e30:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801e35:	0f 47 c1             	cmova  %ecx,%eax
  801e38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e43:	00 
  801e44:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e4a:	89 04 24             	mov    %eax,(%esp)
  801e4d:	e8 a5 f7 ff ff       	call   8015f7 <readn>
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 4a 01 00 00    	js     801fa4 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e5a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e60:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e64:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e68:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e72:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e79:	00 
  801e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e81:	e8 c1 f1 ff ff       	call   801047 <sys_page_map>
  801e86:	85 c0                	test   %eax,%eax
  801e88:	79 20                	jns    801eaa <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  801e8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e8e:	c7 44 24 08 4f 2e 80 	movl   $0x802e4f,0x8(%esp)
  801e95:	00 
  801e96:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801e9d:	00 
  801e9e:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801ea5:	e8 b8 e5 ff ff       	call   800462 <_panic>
			sys_page_unmap(0, UTEMP);
  801eaa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801eb1:	00 
  801eb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb9:	e8 dc f1 ff ff       	call   80109a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ebe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ec4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801eca:	89 df                	mov    %ebx,%edi
  801ecc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801ed2:	0f 87 cf fe ff ff    	ja     801da7 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ed8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801edf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801ee6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801eed:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ef3:	0f 8c 37 fe ff ff    	jl     801d30 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ef9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 fb f4 ff ff       	call   801402 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f07:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f17:	89 04 24             	mov    %eax,(%esp)
  801f1a:	e8 21 f2 ff ff       	call   801140 <sys_env_set_trapframe>
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	79 20                	jns    801f43 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f27:	c7 44 24 08 6c 2e 80 	movl   $0x802e6c,0x8(%esp)
  801f2e:	00 
  801f2f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801f36:	00 
  801f37:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801f3e:	e8 1f e5 ff ff       	call   800462 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f43:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f4a:	00 
  801f4b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 94 f1 ff ff       	call   8010ed <sys_env_set_status>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	79 30                	jns    801f8d <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f61:	c7 44 24 08 86 2e 80 	movl   $0x802e86,0x8(%esp)
  801f68:	00 
  801f69:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801f70:	00 
  801f71:	c7 04 24 43 2e 80 00 	movl   $0x802e43,(%esp)
  801f78:	e8 e5 e4 ff ff       	call   800462 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801f7d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f83:	eb 57                	jmp    801fdc <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801f85:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f8b:	eb 4f                	jmp    801fdc <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801f8d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f93:	eb 47                	jmp    801fdc <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f95:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801f9a:	eb 40                	jmp    801fdc <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f9c:	89 c3                	mov    %eax,%ebx
  801f9e:	eb 06                	jmp    801fa6 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fa0:	89 c3                	mov    %eax,%ebx
  801fa2:	eb 02                	jmp    801fa6 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fa4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801fa6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fac:	89 04 24             	mov    %eax,(%esp)
  801faf:	e8 af ef ff ff       	call   800f63 <sys_env_destroy>
	close(fd);
  801fb4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801fba:	89 04 24             	mov    %eax,(%esp)
  801fbd:	e8 40 f4 ff ff       	call   801402 <close>
	return r;
  801fc2:	89 d8                	mov    %ebx,%eax
  801fc4:	eb 16                	jmp    801fdc <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801fc6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fcd:	00 
  801fce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd5:	e8 c0 f0 ff ff       	call   80109a <sys_page_unmap>
  801fda:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801fdc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801fe2:	5b                   	pop    %ebx
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fef:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ff2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ff7:	eb 03                	jmp    801ffc <spawnl+0x15>
		argc++;
  801ff9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ffc:	83 c0 04             	add    $0x4,%eax
  801fff:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802003:	75 f4                	jne    801ff9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802005:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  80200c:	83 e0 f0             	and    $0xfffffff0,%eax
  80200f:	29 c4                	sub    %eax,%esp
  802011:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802015:	c1 e8 02             	shr    $0x2,%eax
  802018:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80201f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802021:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802024:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80202b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802032:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
  802038:	eb 0a                	jmp    802044 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  80203a:	83 c0 01             	add    $0x1,%eax
  80203d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802041:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802044:	39 d0                	cmp    %edx,%eax
  802046:	75 f2                	jne    80203a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802048:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	89 04 24             	mov    %eax,(%esp)
  802052:	e8 59 fa ff ff       	call   801ab0 <spawn>
}
  802057:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205a:	5b                   	pop    %ebx
  80205b:	5e                   	pop    %esi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	56                   	push   %esi
  802062:	53                   	push   %ebx
  802063:	83 ec 10             	sub    $0x10,%esp
  802066:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	89 04 24             	mov    %eax,(%esp)
  80206f:	e8 fc f1 ff ff       	call   801270 <fd2data>
  802074:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802076:	c7 44 24 04 c6 2e 80 	movl   $0x802ec6,0x4(%esp)
  80207d:	00 
  80207e:	89 1c 24             	mov    %ebx,(%esp)
  802081:	e8 51 eb ff ff       	call   800bd7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802086:	8b 46 04             	mov    0x4(%esi),%eax
  802089:	2b 06                	sub    (%esi),%eax
  80208b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802091:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802098:	00 00 00 
	stat->st_dev = &devpipe;
  80209b:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  8020a2:	47 80 00 
	return 0;
}
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	53                   	push   %ebx
  8020b5:	83 ec 14             	sub    $0x14,%esp
  8020b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c6:	e8 cf ef ff ff       	call   80109a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020cb:	89 1c 24             	mov    %ebx,(%esp)
  8020ce:	e8 9d f1 ff ff       	call   801270 <fd2data>
  8020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020de:	e8 b7 ef ff ff       	call   80109a <sys_page_unmap>
}
  8020e3:	83 c4 14             	add    $0x14,%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	57                   	push   %edi
  8020ed:	56                   	push   %esi
  8020ee:	53                   	push   %ebx
  8020ef:	83 ec 2c             	sub    $0x2c,%esp
  8020f2:	89 c6                	mov    %eax,%esi
  8020f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020f7:	a1 90 67 80 00       	mov    0x806790,%eax
  8020fc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020ff:	89 34 24             	mov    %esi,(%esp)
  802102:	e8 be 04 00 00       	call   8025c5 <pageref>
  802107:	89 c7                	mov    %eax,%edi
  802109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80210c:	89 04 24             	mov    %eax,(%esp)
  80210f:	e8 b1 04 00 00       	call   8025c5 <pageref>
  802114:	39 c7                	cmp    %eax,%edi
  802116:	0f 94 c2             	sete   %dl
  802119:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80211c:	8b 0d 90 67 80 00    	mov    0x806790,%ecx
  802122:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802125:	39 fb                	cmp    %edi,%ebx
  802127:	74 21                	je     80214a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802129:	84 d2                	test   %dl,%dl
  80212b:	74 ca                	je     8020f7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80212d:	8b 51 58             	mov    0x58(%ecx),%edx
  802130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802134:	89 54 24 08          	mov    %edx,0x8(%esp)
  802138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80213c:	c7 04 24 cd 2e 80 00 	movl   $0x802ecd,(%esp)
  802143:	e8 13 e4 ff ff       	call   80055b <cprintf>
  802148:	eb ad                	jmp    8020f7 <_pipeisclosed+0xe>
	}
}
  80214a:	83 c4 2c             	add    $0x2c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    

00802152 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80215e:	89 34 24             	mov    %esi,(%esp)
  802161:	e8 0a f1 ff ff       	call   801270 <fd2data>
  802166:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802168:	bf 00 00 00 00       	mov    $0x0,%edi
  80216d:	eb 45                	jmp    8021b4 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80216f:	89 da                	mov    %ebx,%edx
  802171:	89 f0                	mov    %esi,%eax
  802173:	e8 71 ff ff ff       	call   8020e9 <_pipeisclosed>
  802178:	85 c0                	test   %eax,%eax
  80217a:	75 41                	jne    8021bd <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80217c:	e8 53 ee ff ff       	call   800fd4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802181:	8b 43 04             	mov    0x4(%ebx),%eax
  802184:	8b 0b                	mov    (%ebx),%ecx
  802186:	8d 51 20             	lea    0x20(%ecx),%edx
  802189:	39 d0                	cmp    %edx,%eax
  80218b:	73 e2                	jae    80216f <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80218d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802190:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802194:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802197:	99                   	cltd   
  802198:	c1 ea 1b             	shr    $0x1b,%edx
  80219b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80219e:	83 e1 1f             	and    $0x1f,%ecx
  8021a1:	29 d1                	sub    %edx,%ecx
  8021a3:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8021a7:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8021ab:	83 c0 01             	add    $0x1,%eax
  8021ae:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b1:	83 c7 01             	add    $0x1,%edi
  8021b4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021b7:	75 c8                	jne    802181 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021b9:	89 f8                	mov    %edi,%eax
  8021bb:	eb 05                	jmp    8021c2 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021c2:	83 c4 1c             	add    $0x1c,%esp
  8021c5:	5b                   	pop    %ebx
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    

008021ca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	57                   	push   %edi
  8021ce:	56                   	push   %esi
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 1c             	sub    $0x1c,%esp
  8021d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021d6:	89 3c 24             	mov    %edi,(%esp)
  8021d9:	e8 92 f0 ff ff       	call   801270 <fd2data>
  8021de:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e0:	be 00 00 00 00       	mov    $0x0,%esi
  8021e5:	eb 3d                	jmp    802224 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	74 04                	je     8021ef <devpipe_read+0x25>
				return i;
  8021eb:	89 f0                	mov    %esi,%eax
  8021ed:	eb 43                	jmp    802232 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021ef:	89 da                	mov    %ebx,%edx
  8021f1:	89 f8                	mov    %edi,%eax
  8021f3:	e8 f1 fe ff ff       	call   8020e9 <_pipeisclosed>
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	75 31                	jne    80222d <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021fc:	e8 d3 ed ff ff       	call   800fd4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802201:	8b 03                	mov    (%ebx),%eax
  802203:	3b 43 04             	cmp    0x4(%ebx),%eax
  802206:	74 df                	je     8021e7 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802208:	99                   	cltd   
  802209:	c1 ea 1b             	shr    $0x1b,%edx
  80220c:	01 d0                	add    %edx,%eax
  80220e:	83 e0 1f             	and    $0x1f,%eax
  802211:	29 d0                	sub    %edx,%eax
  802213:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80221e:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802221:	83 c6 01             	add    $0x1,%esi
  802224:	3b 75 10             	cmp    0x10(%ebp),%esi
  802227:	75 d8                	jne    802201 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802229:	89 f0                	mov    %esi,%eax
  80222b:	eb 05                	jmp    802232 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802232:	83 c4 1c             	add    $0x1c,%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	56                   	push   %esi
  80223e:	53                   	push   %ebx
  80223f:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802245:	89 04 24             	mov    %eax,(%esp)
  802248:	e8 3a f0 ff ff       	call   801287 <fd_alloc>
  80224d:	89 c2                	mov    %eax,%edx
  80224f:	85 d2                	test   %edx,%edx
  802251:	0f 88 4d 01 00 00    	js     8023a4 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802257:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80225e:	00 
  80225f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802262:	89 44 24 04          	mov    %eax,0x4(%esp)
  802266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226d:	e8 81 ed ff ff       	call   800ff3 <sys_page_alloc>
  802272:	89 c2                	mov    %eax,%edx
  802274:	85 d2                	test   %edx,%edx
  802276:	0f 88 28 01 00 00    	js     8023a4 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80227c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80227f:	89 04 24             	mov    %eax,(%esp)
  802282:	e8 00 f0 ff ff       	call   801287 <fd_alloc>
  802287:	89 c3                	mov    %eax,%ebx
  802289:	85 c0                	test   %eax,%eax
  80228b:	0f 88 fe 00 00 00    	js     80238f <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802291:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802298:	00 
  802299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80229c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a7:	e8 47 ed ff ff       	call   800ff3 <sys_page_alloc>
  8022ac:	89 c3                	mov    %eax,%ebx
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	0f 88 d9 00 00 00    	js     80238f <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b9:	89 04 24             	mov    %eax,(%esp)
  8022bc:	e8 af ef ff ff       	call   801270 <fd2data>
  8022c1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022ca:	00 
  8022cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d6:	e8 18 ed ff ff       	call   800ff3 <sys_page_alloc>
  8022db:	89 c3                	mov    %eax,%ebx
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 97 00 00 00    	js     80237c <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e8:	89 04 24             	mov    %eax,(%esp)
  8022eb:	e8 80 ef ff ff       	call   801270 <fd2data>
  8022f0:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022f7:	00 
  8022f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802303:	00 
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80230f:	e8 33 ed ff ff       	call   801047 <sys_page_map>
  802314:	89 c3                	mov    %eax,%ebx
  802316:	85 c0                	test   %eax,%eax
  802318:	78 52                	js     80236c <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80231a:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802323:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802325:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802328:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80232f:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802338:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80233a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80233d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802344:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802347:	89 04 24             	mov    %eax,(%esp)
  80234a:	e8 11 ef ff ff       	call   801260 <fd2num>
  80234f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802352:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802357:	89 04 24             	mov    %eax,(%esp)
  80235a:	e8 01 ef ff ff       	call   801260 <fd2num>
  80235f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802362:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802365:	b8 00 00 00 00       	mov    $0x0,%eax
  80236a:	eb 38                	jmp    8023a4 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80236c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802370:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802377:	e8 1e ed ff ff       	call   80109a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80237c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80237f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802383:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80238a:	e8 0b ed ff ff       	call   80109a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80238f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802392:	89 44 24 04          	mov    %eax,0x4(%esp)
  802396:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80239d:	e8 f8 ec ff ff       	call   80109a <sys_page_unmap>
  8023a2:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8023a4:	83 c4 30             	add    $0x30,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bb:	89 04 24             	mov    %eax,(%esp)
  8023be:	e8 13 ef ff ff       	call   8012d6 <fd_lookup>
  8023c3:	89 c2                	mov    %eax,%edx
  8023c5:	85 d2                	test   %edx,%edx
  8023c7:	78 15                	js     8023de <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023cc:	89 04 24             	mov    %eax,(%esp)
  8023cf:	e8 9c ee ff ff       	call   801270 <fd2data>
	return _pipeisclosed(fd, p);
  8023d4:	89 c2                	mov    %eax,%edx
  8023d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d9:	e8 0b fd ff ff       	call   8020e9 <_pipeisclosed>
}
  8023de:	c9                   	leave  
  8023df:	c3                   	ret    

008023e0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	56                   	push   %esi
  8023e4:	53                   	push   %ebx
  8023e5:	83 ec 10             	sub    $0x10,%esp
  8023e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8023eb:	85 f6                	test   %esi,%esi
  8023ed:	75 24                	jne    802413 <wait+0x33>
  8023ef:	c7 44 24 0c e5 2e 80 	movl   $0x802ee5,0xc(%esp)
  8023f6:	00 
  8023f7:	c7 44 24 08 08 2e 80 	movl   $0x802e08,0x8(%esp)
  8023fe:	00 
  8023ff:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802406:	00 
  802407:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  80240e:	e8 4f e0 ff ff       	call   800462 <_panic>
	e = &envs[ENVX(envid)];
  802413:	89 f3                	mov    %esi,%ebx
  802415:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80241b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80241e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802424:	eb 05                	jmp    80242b <wait+0x4b>
		sys_yield();
  802426:	e8 a9 eb ff ff       	call   800fd4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80242b:	8b 43 48             	mov    0x48(%ebx),%eax
  80242e:	39 f0                	cmp    %esi,%eax
  802430:	75 07                	jne    802439 <wait+0x59>
  802432:	8b 43 54             	mov    0x54(%ebx),%eax
  802435:	85 c0                	test   %eax,%eax
  802437:	75 ed                	jne    802426 <wait+0x46>
		sys_yield();
}
  802439:	83 c4 10             	add    $0x10,%esp
  80243c:	5b                   	pop    %ebx
  80243d:	5e                   	pop    %esi
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	56                   	push   %esi
  802444:	53                   	push   %ebx
  802445:	83 ec 10             	sub    $0x10,%esp
  802448:	8b 75 08             	mov    0x8(%ebp),%esi
  80244b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802451:	85 c0                	test   %eax,%eax
  802453:	75 0e                	jne    802463 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802455:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80245c:	e8 a8 ed ff ff       	call   801209 <sys_ipc_recv>
  802461:	eb 08                	jmp    80246b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  802463:	89 04 24             	mov    %eax,(%esp)
  802466:	e8 9e ed ff ff       	call   801209 <sys_ipc_recv>
	if(r == 0){
  80246b:	85 c0                	test   %eax,%eax
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	75 1e                	jne    802490 <ipc_recv+0x50>
		if( from_env_store != 0 )
  802472:	85 f6                	test   %esi,%esi
  802474:	74 0a                	je     802480 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  802476:	a1 90 67 80 00       	mov    0x806790,%eax
  80247b:	8b 40 74             	mov    0x74(%eax),%eax
  80247e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  802480:	85 db                	test   %ebx,%ebx
  802482:	74 2c                	je     8024b0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  802484:	a1 90 67 80 00       	mov    0x806790,%eax
  802489:	8b 40 78             	mov    0x78(%eax),%eax
  80248c:	89 03                	mov    %eax,(%ebx)
  80248e:	eb 20                	jmp    8024b0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  802490:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802494:	c7 44 24 08 fc 2e 80 	movl   $0x802efc,0x8(%esp)
  80249b:	00 
  80249c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8024a3:	00 
  8024a4:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  8024ab:	e8 b2 df ff ff       	call   800462 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8024b0:	a1 90 67 80 00       	mov    0x806790,%eax
  8024b5:	8b 50 70             	mov    0x70(%eax),%edx
  8024b8:	85 d2                	test   %edx,%edx
  8024ba:	75 13                	jne    8024cf <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8024bc:	8b 40 48             	mov    0x48(%eax),%eax
  8024bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c3:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  8024ca:	e8 8c e0 ff ff       	call   80055b <cprintf>
	return thisenv->env_ipc_value;
  8024cf:	a1 90 67 80 00       	mov    0x806790,%eax
  8024d4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024d7:	83 c4 10             	add    $0x10,%esp
  8024da:	5b                   	pop    %ebx
  8024db:	5e                   	pop    %esi
  8024dc:	5d                   	pop    %ebp
  8024dd:	c3                   	ret    

008024de <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024de:	55                   	push   %ebp
  8024df:	89 e5                	mov    %esp,%ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ea:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8024ed:	85 f6                	test   %esi,%esi
  8024ef:	75 22                	jne    802513 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8024f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8024f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024f8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8024ff:	ee 
  802500:	8b 45 0c             	mov    0xc(%ebp),%eax
  802503:	89 44 24 04          	mov    %eax,0x4(%esp)
  802507:	89 3c 24             	mov    %edi,(%esp)
  80250a:	e8 d7 ec ff ff       	call   8011e6 <sys_ipc_try_send>
  80250f:	89 c3                	mov    %eax,%ebx
  802511:	eb 1c                	jmp    80252f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802513:	8b 45 14             	mov    0x14(%ebp),%eax
  802516:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80251e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802521:	89 44 24 04          	mov    %eax,0x4(%esp)
  802525:	89 3c 24             	mov    %edi,(%esp)
  802528:	e8 b9 ec ff ff       	call   8011e6 <sys_ipc_try_send>
  80252d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80252f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802532:	74 3e                	je     802572 <ipc_send+0x94>
  802534:	89 d8                	mov    %ebx,%eax
  802536:	c1 e8 1f             	shr    $0x1f,%eax
  802539:	84 c0                	test   %al,%al
  80253b:	74 35                	je     802572 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80253d:	e8 73 ea ff ff       	call   800fb5 <sys_getenvid>
  802542:	89 44 24 04          	mov    %eax,0x4(%esp)
  802546:	c7 04 24 82 2f 80 00 	movl   $0x802f82,(%esp)
  80254d:	e8 09 e0 ff ff       	call   80055b <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802552:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802556:	c7 44 24 08 50 2f 80 	movl   $0x802f50,0x8(%esp)
  80255d:	00 
  80255e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802565:	00 
  802566:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  80256d:	e8 f0 de ff ff       	call   800462 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802572:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802575:	75 0e                	jne    802585 <ipc_send+0xa7>
			sys_yield();
  802577:	e8 58 ea ff ff       	call   800fd4 <sys_yield>
		else break;
	}
  80257c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802580:	e9 68 ff ff ff       	jmp    8024ed <ipc_send+0xf>
	
}
  802585:	83 c4 1c             	add    $0x1c,%esp
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802593:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802598:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80259b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025a1:	8b 52 50             	mov    0x50(%edx),%edx
  8025a4:	39 ca                	cmp    %ecx,%edx
  8025a6:	75 0d                	jne    8025b5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025ab:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8025b0:	8b 40 40             	mov    0x40(%eax),%eax
  8025b3:	eb 0e                	jmp    8025c3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025b5:	83 c0 01             	add    $0x1,%eax
  8025b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025bd:	75 d9                	jne    802598 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025bf:	66 b8 00 00          	mov    $0x0,%ax
}
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	c1 e8 16             	shr    $0x16,%eax
  8025d0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025dc:	f6 c1 01             	test   $0x1,%cl
  8025df:	74 1d                	je     8025fe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025e1:	c1 ea 0c             	shr    $0xc,%edx
  8025e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025eb:	f6 c2 01             	test   $0x1,%dl
  8025ee:	74 0e                	je     8025fe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025f0:	c1 ea 0c             	shr    $0xc,%edx
  8025f3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025fa:	ef 
  8025fb:	0f b7 c0             	movzwl %ax,%eax
}
  8025fe:	5d                   	pop    %ebp
  8025ff:	c3                   	ret    

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	57                   	push   %edi
  802602:	56                   	push   %esi
  802603:	83 ec 0c             	sub    $0xc,%esp
  802606:	8b 44 24 28          	mov    0x28(%esp),%eax
  80260a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80260e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802612:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802616:	85 c0                	test   %eax,%eax
  802618:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80261c:	89 ea                	mov    %ebp,%edx
  80261e:	89 0c 24             	mov    %ecx,(%esp)
  802621:	75 2d                	jne    802650 <__udivdi3+0x50>
  802623:	39 e9                	cmp    %ebp,%ecx
  802625:	77 61                	ja     802688 <__udivdi3+0x88>
  802627:	85 c9                	test   %ecx,%ecx
  802629:	89 ce                	mov    %ecx,%esi
  80262b:	75 0b                	jne    802638 <__udivdi3+0x38>
  80262d:	b8 01 00 00 00       	mov    $0x1,%eax
  802632:	31 d2                	xor    %edx,%edx
  802634:	f7 f1                	div    %ecx
  802636:	89 c6                	mov    %eax,%esi
  802638:	31 d2                	xor    %edx,%edx
  80263a:	89 e8                	mov    %ebp,%eax
  80263c:	f7 f6                	div    %esi
  80263e:	89 c5                	mov    %eax,%ebp
  802640:	89 f8                	mov    %edi,%eax
  802642:	f7 f6                	div    %esi
  802644:	89 ea                	mov    %ebp,%edx
  802646:	83 c4 0c             	add    $0xc,%esp
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	39 e8                	cmp    %ebp,%eax
  802652:	77 24                	ja     802678 <__udivdi3+0x78>
  802654:	0f bd e8             	bsr    %eax,%ebp
  802657:	83 f5 1f             	xor    $0x1f,%ebp
  80265a:	75 3c                	jne    802698 <__udivdi3+0x98>
  80265c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802660:	39 34 24             	cmp    %esi,(%esp)
  802663:	0f 86 9f 00 00 00    	jbe    802708 <__udivdi3+0x108>
  802669:	39 d0                	cmp    %edx,%eax
  80266b:	0f 82 97 00 00 00    	jb     802708 <__udivdi3+0x108>
  802671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802678:	31 d2                	xor    %edx,%edx
  80267a:	31 c0                	xor    %eax,%eax
  80267c:	83 c4 0c             	add    $0xc,%esp
  80267f:	5e                   	pop    %esi
  802680:	5f                   	pop    %edi
  802681:	5d                   	pop    %ebp
  802682:	c3                   	ret    
  802683:	90                   	nop
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	89 f8                	mov    %edi,%eax
  80268a:	f7 f1                	div    %ecx
  80268c:	31 d2                	xor    %edx,%edx
  80268e:	83 c4 0c             	add    $0xc,%esp
  802691:	5e                   	pop    %esi
  802692:	5f                   	pop    %edi
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    
  802695:	8d 76 00             	lea    0x0(%esi),%esi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	8b 3c 24             	mov    (%esp),%edi
  80269d:	d3 e0                	shl    %cl,%eax
  80269f:	89 c6                	mov    %eax,%esi
  8026a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8026a6:	29 e8                	sub    %ebp,%eax
  8026a8:	89 c1                	mov    %eax,%ecx
  8026aa:	d3 ef                	shr    %cl,%edi
  8026ac:	89 e9                	mov    %ebp,%ecx
  8026ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8026b2:	8b 3c 24             	mov    (%esp),%edi
  8026b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8026b9:	89 d6                	mov    %edx,%esi
  8026bb:	d3 e7                	shl    %cl,%edi
  8026bd:	89 c1                	mov    %eax,%ecx
  8026bf:	89 3c 24             	mov    %edi,(%esp)
  8026c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026c6:	d3 ee                	shr    %cl,%esi
  8026c8:	89 e9                	mov    %ebp,%ecx
  8026ca:	d3 e2                	shl    %cl,%edx
  8026cc:	89 c1                	mov    %eax,%ecx
  8026ce:	d3 ef                	shr    %cl,%edi
  8026d0:	09 d7                	or     %edx,%edi
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	89 f8                	mov    %edi,%eax
  8026d6:	f7 74 24 08          	divl   0x8(%esp)
  8026da:	89 d6                	mov    %edx,%esi
  8026dc:	89 c7                	mov    %eax,%edi
  8026de:	f7 24 24             	mull   (%esp)
  8026e1:	39 d6                	cmp    %edx,%esi
  8026e3:	89 14 24             	mov    %edx,(%esp)
  8026e6:	72 30                	jb     802718 <__udivdi3+0x118>
  8026e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026ec:	89 e9                	mov    %ebp,%ecx
  8026ee:	d3 e2                	shl    %cl,%edx
  8026f0:	39 c2                	cmp    %eax,%edx
  8026f2:	73 05                	jae    8026f9 <__udivdi3+0xf9>
  8026f4:	3b 34 24             	cmp    (%esp),%esi
  8026f7:	74 1f                	je     802718 <__udivdi3+0x118>
  8026f9:	89 f8                	mov    %edi,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	e9 7a ff ff ff       	jmp    80267c <__udivdi3+0x7c>
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	31 d2                	xor    %edx,%edx
  80270a:	b8 01 00 00 00       	mov    $0x1,%eax
  80270f:	e9 68 ff ff ff       	jmp    80267c <__udivdi3+0x7c>
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	8d 47 ff             	lea    -0x1(%edi),%eax
  80271b:	31 d2                	xor    %edx,%edx
  80271d:	83 c4 0c             	add    $0xc,%esp
  802720:	5e                   	pop    %esi
  802721:	5f                   	pop    %edi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    
  802724:	66 90                	xchg   %ax,%ax
  802726:	66 90                	xchg   %ax,%ax
  802728:	66 90                	xchg   %ax,%ax
  80272a:	66 90                	xchg   %ax,%ax
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	83 ec 14             	sub    $0x14,%esp
  802736:	8b 44 24 28          	mov    0x28(%esp),%eax
  80273a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80273e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802742:	89 c7                	mov    %eax,%edi
  802744:	89 44 24 04          	mov    %eax,0x4(%esp)
  802748:	8b 44 24 30          	mov    0x30(%esp),%eax
  80274c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802750:	89 34 24             	mov    %esi,(%esp)
  802753:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802757:	85 c0                	test   %eax,%eax
  802759:	89 c2                	mov    %eax,%edx
  80275b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80275f:	75 17                	jne    802778 <__umoddi3+0x48>
  802761:	39 fe                	cmp    %edi,%esi
  802763:	76 4b                	jbe    8027b0 <__umoddi3+0x80>
  802765:	89 c8                	mov    %ecx,%eax
  802767:	89 fa                	mov    %edi,%edx
  802769:	f7 f6                	div    %esi
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	31 d2                	xor    %edx,%edx
  80276f:	83 c4 14             	add    $0x14,%esp
  802772:	5e                   	pop    %esi
  802773:	5f                   	pop    %edi
  802774:	5d                   	pop    %ebp
  802775:	c3                   	ret    
  802776:	66 90                	xchg   %ax,%ax
  802778:	39 f8                	cmp    %edi,%eax
  80277a:	77 54                	ja     8027d0 <__umoddi3+0xa0>
  80277c:	0f bd e8             	bsr    %eax,%ebp
  80277f:	83 f5 1f             	xor    $0x1f,%ebp
  802782:	75 5c                	jne    8027e0 <__umoddi3+0xb0>
  802784:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802788:	39 3c 24             	cmp    %edi,(%esp)
  80278b:	0f 87 e7 00 00 00    	ja     802878 <__umoddi3+0x148>
  802791:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802795:	29 f1                	sub    %esi,%ecx
  802797:	19 c7                	sbb    %eax,%edi
  802799:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80279d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027a9:	83 c4 14             	add    $0x14,%esp
  8027ac:	5e                   	pop    %esi
  8027ad:	5f                   	pop    %edi
  8027ae:	5d                   	pop    %ebp
  8027af:	c3                   	ret    
  8027b0:	85 f6                	test   %esi,%esi
  8027b2:	89 f5                	mov    %esi,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x91>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f6                	div    %esi
  8027bf:	89 c5                	mov    %eax,%ebp
  8027c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027c5:	31 d2                	xor    %edx,%edx
  8027c7:	f7 f5                	div    %ebp
  8027c9:	89 c8                	mov    %ecx,%eax
  8027cb:	f7 f5                	div    %ebp
  8027cd:	eb 9c                	jmp    80276b <__umoddi3+0x3b>
  8027cf:	90                   	nop
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 fa                	mov    %edi,%edx
  8027d4:	83 c4 14             	add    $0x14,%esp
  8027d7:	5e                   	pop    %esi
  8027d8:	5f                   	pop    %edi
  8027d9:	5d                   	pop    %ebp
  8027da:	c3                   	ret    
  8027db:	90                   	nop
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	8b 04 24             	mov    (%esp),%eax
  8027e3:	be 20 00 00 00       	mov    $0x20,%esi
  8027e8:	89 e9                	mov    %ebp,%ecx
  8027ea:	29 ee                	sub    %ebp,%esi
  8027ec:	d3 e2                	shl    %cl,%edx
  8027ee:	89 f1                	mov    %esi,%ecx
  8027f0:	d3 e8                	shr    %cl,%eax
  8027f2:	89 e9                	mov    %ebp,%ecx
  8027f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027f8:	8b 04 24             	mov    (%esp),%eax
  8027fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8027ff:	89 fa                	mov    %edi,%edx
  802801:	d3 e0                	shl    %cl,%eax
  802803:	89 f1                	mov    %esi,%ecx
  802805:	89 44 24 08          	mov    %eax,0x8(%esp)
  802809:	8b 44 24 10          	mov    0x10(%esp),%eax
  80280d:	d3 ea                	shr    %cl,%edx
  80280f:	89 e9                	mov    %ebp,%ecx
  802811:	d3 e7                	shl    %cl,%edi
  802813:	89 f1                	mov    %esi,%ecx
  802815:	d3 e8                	shr    %cl,%eax
  802817:	89 e9                	mov    %ebp,%ecx
  802819:	09 f8                	or     %edi,%eax
  80281b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80281f:	f7 74 24 04          	divl   0x4(%esp)
  802823:	d3 e7                	shl    %cl,%edi
  802825:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802829:	89 d7                	mov    %edx,%edi
  80282b:	f7 64 24 08          	mull   0x8(%esp)
  80282f:	39 d7                	cmp    %edx,%edi
  802831:	89 c1                	mov    %eax,%ecx
  802833:	89 14 24             	mov    %edx,(%esp)
  802836:	72 2c                	jb     802864 <__umoddi3+0x134>
  802838:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80283c:	72 22                	jb     802860 <__umoddi3+0x130>
  80283e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802842:	29 c8                	sub    %ecx,%eax
  802844:	19 d7                	sbb    %edx,%edi
  802846:	89 e9                	mov    %ebp,%ecx
  802848:	89 fa                	mov    %edi,%edx
  80284a:	d3 e8                	shr    %cl,%eax
  80284c:	89 f1                	mov    %esi,%ecx
  80284e:	d3 e2                	shl    %cl,%edx
  802850:	89 e9                	mov    %ebp,%ecx
  802852:	d3 ef                	shr    %cl,%edi
  802854:	09 d0                	or     %edx,%eax
  802856:	89 fa                	mov    %edi,%edx
  802858:	83 c4 14             	add    $0x14,%esp
  80285b:	5e                   	pop    %esi
  80285c:	5f                   	pop    %edi
  80285d:	5d                   	pop    %ebp
  80285e:	c3                   	ret    
  80285f:	90                   	nop
  802860:	39 d7                	cmp    %edx,%edi
  802862:	75 da                	jne    80283e <__umoddi3+0x10e>
  802864:	8b 14 24             	mov    (%esp),%edx
  802867:	89 c1                	mov    %eax,%ecx
  802869:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80286d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802871:	eb cb                	jmp    80283e <__umoddi3+0x10e>
  802873:	90                   	nop
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80287c:	0f 82 0f ff ff ff    	jb     802791 <__umoddi3+0x61>
  802882:	e9 1a ff ff ff       	jmp    8027a1 <__umoddi3+0x71>
