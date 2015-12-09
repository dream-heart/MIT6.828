
obj/user/testkbd.debug：     文件格式 elf32-i386


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
  80002c:	e8 95 02 00 00       	call   8002c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 40 0f 00 00       	call   800f84 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 5d 13 00 00       	call   8013b2 <close>
	if ((r = opencons()) < 0)
  800055:	e8 11 02 00 00       	call   80026b <opencons>
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4b>
		panic("opencons: %e", r);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 80 23 80 	movl   $0x802380,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 8d 23 80 00 	movl   $0x80238d,(%esp)
  800079:	e8 a4 02 00 00       	call   800322 <_panic>
	if (r != 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	74 20                	je     8000a2 <umain+0x6f>
		panic("first opencons used fd %d", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 9c 23 80 	movl   $0x80239c,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 8d 23 80 00 	movl   $0x80238d,(%esp)
  80009d:	e8 80 02 00 00       	call   800322 <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a9:	00 
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 51 13 00 00       	call   801407 <dup>
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	79 20                	jns    8000da <umain+0xa7>
		panic("dup: %e", r);
  8000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000be:	c7 44 24 08 b6 23 80 	movl   $0x8023b6,0x8(%esp)
  8000c5:	00 
  8000c6:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cd:	00 
  8000ce:	c7 04 24 8d 23 80 00 	movl   $0x80238d,(%esp)
  8000d5:	e8 48 02 00 00       	call   800322 <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000da:	c7 04 24 be 23 80 00 	movl   $0x8023be,(%esp)
  8000e1:	e8 7a 09 00 00       	call   800a60 <readline>
		if (buf != NULL)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	74 1a                	je     800104 <umain+0xd1>
			fprintf(1, "%s\n", buf);
  8000ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ee:	c7 44 24 04 cc 23 80 	movl   $0x8023cc,0x4(%esp)
  8000f5:	00 
  8000f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fd:	e8 4e 1a 00 00       	call   801b50 <fprintf>
  800102:	eb d6                	jmp    8000da <umain+0xa7>
		else
			fprintf(1, "(end of file received)\n");
  800104:	c7 44 24 04 d0 23 80 	movl   $0x8023d0,0x4(%esp)
  80010b:	00 
  80010c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800113:	e8 38 1a 00 00       	call   801b50 <fprintf>
  800118:	eb c0                	jmp    8000da <umain+0xa7>
  80011a:	66 90                	xchg   %ax,%ax
  80011c:	66 90                	xchg   %ax,%ax
  80011e:	66 90                	xchg   %ax,%ax

00800120 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800130:	c7 44 24 04 e8 23 80 	movl   $0x8023e8,0x4(%esp)
  800137:	00 
  800138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013b:	89 04 24             	mov    %eax,(%esp)
  80013e:	e8 44 0a 00 00       	call   800b87 <strcpy>
	return 0;
}
  800143:	b8 00 00 00 00       	mov    $0x0,%eax
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800156:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80015b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800161:	eb 31                	jmp    800194 <devcons_write+0x4a>
		m = n - tot;
  800163:	8b 75 10             	mov    0x10(%ebp),%esi
  800166:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800168:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80016b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800170:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800173:	89 74 24 08          	mov    %esi,0x8(%esp)
  800177:	03 45 0c             	add    0xc(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	89 3c 24             	mov    %edi,(%esp)
  800181:	e8 9e 0b 00 00       	call   800d24 <memmove>
		sys_cputs(buf, m);
  800186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018a:	89 3c 24             	mov    %edi,(%esp)
  80018d:	e8 44 0d 00 00       	call   800ed6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800192:	01 f3                	add    %esi,%ebx
  800194:	89 d8                	mov    %ebx,%eax
  800196:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800199:	72 c8                	jb     800163 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80019b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8001ac:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8001b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001b5:	75 07                	jne    8001be <devcons_read+0x18>
  8001b7:	eb 2a                	jmp    8001e3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001b9:	e8 c6 0d 00 00       	call   800f84 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001be:	66 90                	xchg   %ax,%ax
  8001c0:	e8 2f 0d 00 00       	call   800ef4 <sys_cgetc>
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	74 f0                	je     8001b9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	78 16                	js     8001e3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001cd:	83 f8 04             	cmp    $0x4,%eax
  8001d0:	74 0c                	je     8001de <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	88 02                	mov    %al,(%edx)
	return 1;
  8001d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8001dc:	eb 05                	jmp    8001e3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f8:	00 
  8001f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 d2 0c 00 00       	call   800ed6 <sys_cputs>
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <getchar>:

int
getchar(void)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80020c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800213:	00 
  800214:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800222:	e8 ee 12 00 00       	call   801515 <read>
	if (r < 0)
  800227:	85 c0                	test   %eax,%eax
  800229:	78 0f                	js     80023a <getchar+0x34>
		return r;
	if (r < 1)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 06                	jle    800235 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800233:	eb 05                	jmp    80023a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800235:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 32 10 00 00       	call   801286 <fd_lookup>
  800254:	85 c0                	test   %eax,%eax
  800256:	78 11                	js     800269 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025b:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800261:	39 10                	cmp    %edx,(%eax)
  800263:	0f 94 c0             	sete   %al
  800266:	0f b6 c0             	movzbl %al,%eax
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <opencons>:

int
opencons(void)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 bb 0f 00 00       	call   801237 <fd_alloc>
		return r;
  80027c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	78 40                	js     8002c2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800282:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800289:	00 
  80028a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800298:	e8 06 0d 00 00       	call   800fa3 <sys_page_alloc>
		return r;
  80029d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	78 1f                	js     8002c2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8002a3:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 50 0f 00 00       	call   801210 <fd2num>
  8002c0:	89 c2                	mov    %eax,%edx
}
  8002c2:	89 d0                	mov    %edx,%eax
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 10             	sub    $0x10,%esp
  8002ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8002d4:	e8 8c 0c 00 00       	call   800f65 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e6:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	7e 07                	jle    8002f6 <libmain+0x30>
		binaryname = argv[0];
  8002ef:	8b 06                	mov    (%esi),%eax
  8002f1:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002fa:	89 1c 24             	mov    %ebx,(%esp)
  8002fd:	e8 31 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800302:	e8 07 00 00 00       	call   80030e <exit>
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80031b:	e8 f3 0b 00 00       	call   800f13 <sys_env_destroy>
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80032a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032d:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  800333:	e8 2d 0c 00 00       	call   800f65 <sys_getenvid>
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800346:	89 74 24 08          	mov    %esi,0x8(%esp)
  80034a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034e:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800355:	e8 c1 00 00 00       	call   80041b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035e:	8b 45 10             	mov    0x10(%ebp),%eax
  800361:	89 04 24             	mov    %eax,(%esp)
  800364:	e8 51 00 00 00       	call   8003ba <vcprintf>
	cprintf("\n");
  800369:	c7 04 24 e6 23 80 00 	movl   $0x8023e6,(%esp)
  800370:	e8 a6 00 00 00       	call   80041b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800375:	cc                   	int3   
  800376:	eb fd                	jmp    800375 <_panic+0x53>

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 14             	sub    $0x14,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	75 19                	jne    8003b0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800397:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80039e:	00 
  80039f:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a2:	89 04 24             	mov    %eax,(%esp)
  8003a5:	e8 2c 0b 00 00       	call   800ed6 <sys_cputs>
		b->idx = 0;
  8003aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b4:	83 c4 14             	add    $0x14,%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ca:	00 00 00 
	b.cnt = 0;
  8003cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ef:	c7 04 24 78 03 80 00 	movl   $0x800378,(%esp)
  8003f6:	e8 79 01 00 00       	call   800574 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	e8 c3 0a 00 00       	call   800ed6 <sys_cputs>

	return b.cnt;
}
  800413:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800421:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800424:	89 44 24 04          	mov    %eax,0x4(%esp)
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	e8 87 ff ff ff       	call   8003ba <vcprintf>
	va_end(ap);

	return cnt;
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    
  800435:	66 90                	xchg   %ax,%ax
  800437:	66 90                	xchg   %ax,%ax
  800439:	66 90                	xchg   %ax,%ax
  80043b:	66 90                	xchg   %ax,%ax
  80043d:	66 90                	xchg   %ax,%ax
  80043f:	90                   	nop

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 c3                	mov    %eax,%ebx
  800459:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80046d:	39 d9                	cmp    %ebx,%ecx
  80046f:	72 05                	jb     800476 <printnum+0x36>
  800471:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800474:	77 69                	ja     8004df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800476:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800479:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80047d:	83 ee 01             	sub    $0x1,%esi
  800480:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	8b 44 24 08          	mov    0x8(%esp),%eax
  80048c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800490:	89 c3                	mov    %eax,%ebx
  800492:	89 d6                	mov    %edx,%esi
  800494:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800497:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80049a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80049e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004af:	e8 2c 1c 00 00       	call   8020e0 <__udivdi3>
  8004b4:	89 d9                	mov    %ebx,%ecx
  8004b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c5:	89 fa                	mov    %edi,%edx
  8004c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ca:	e8 71 ff ff ff       	call   800440 <printnum>
  8004cf:	eb 1b                	jmp    8004ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff d3                	call   *%ebx
  8004dd:	eb 03                	jmp    8004e2 <printnum+0xa2>
  8004df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e2:	83 ee 01             	sub    $0x1,%esi
  8004e5:	85 f6                	test   %esi,%esi
  8004e7:	7f e8                	jg     8004d1 <printnum+0x91>
  8004e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 fc 1c 00 00       	call   802210 <__umoddi3>
  800514:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800518:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800525:	ff d0                	call   *%eax
}
  800527:	83 c4 3c             	add    $0x3c,%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5f                   	pop    %edi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800535:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800539:	8b 10                	mov    (%eax),%edx
  80053b:	3b 50 04             	cmp    0x4(%eax),%edx
  80053e:	73 0a                	jae    80054a <sprintputch+0x1b>
		*b->buf++ = ch;
  800540:	8d 4a 01             	lea    0x1(%edx),%ecx
  800543:	89 08                	mov    %ecx,(%eax)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	88 02                	mov    %al,(%edx)
}
  80054a:	5d                   	pop    %ebp
  80054b:	c3                   	ret    

0080054c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800552:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800555:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800559:	8b 45 10             	mov    0x10(%ebp),%eax
  80055c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800560:	8b 45 0c             	mov    0xc(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	e8 02 00 00 00       	call   800574 <vprintfmt>
	va_end(ap);
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 3c             	sub    $0x3c,%esp
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	8b 7d 10             	mov    0x10(%ebp),%edi
  800586:	eb 11                	jmp    800599 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800588:	85 c0                	test   %eax,%eax
  80058a:	0f 84 48 04 00 00    	je     8009d8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a0:	83 f8 25             	cmp    $0x25,%eax
  8005a3:	75 e3                	jne    800588 <vprintfmt+0x14>
  8005a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c3:	eb 1f                	jmp    8005e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8005cc:	eb 16                	jmp    8005e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d5:	eb 0d                	jmp    8005e4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8d 47 01             	lea    0x1(%edi),%eax
  8005e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ea:	0f b6 17             	movzbl (%edi),%edx
  8005ed:	0f b6 c2             	movzbl %dl,%eax
  8005f0:	83 ea 23             	sub    $0x23,%edx
  8005f3:	80 fa 55             	cmp    $0x55,%dl
  8005f6:	0f 87 bf 03 00 00    	ja     8009bb <vprintfmt+0x447>
  8005fc:	0f b6 d2             	movzbl %dl,%edx
  8005ff:	ff 24 95 60 25 80 00 	jmp    *0x802560(,%edx,4)
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
  80060e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800611:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800614:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800618:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80061b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80061e:	83 f9 09             	cmp    $0x9,%ecx
  800621:	77 3c                	ja     80065f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800623:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800626:	eb e9                	jmp    800611 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 40 04             	lea    0x4(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80063c:	eb 27                	jmp    800665 <vprintfmt+0xf1>
  80063e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800641:	85 d2                	test   %edx,%edx
  800643:	b8 00 00 00 00       	mov    $0x0,%eax
  800648:	0f 49 c2             	cmovns %edx,%eax
  80064b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800651:	eb 91                	jmp    8005e4 <vprintfmt+0x70>
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800656:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80065d:	eb 85                	jmp    8005e4 <vprintfmt+0x70>
  80065f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800662:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800665:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800669:	0f 89 75 ff ff ff    	jns    8005e4 <vprintfmt+0x70>
  80066f:	e9 63 ff ff ff       	jmp    8005d7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800674:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067a:	e9 65 ff ff ff       	jmp    8005e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800682:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800694:	e9 00 ff ff ff       	jmp    800599 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	99                   	cltd   
  8006a3:	31 d0                	xor    %edx,%eax
  8006a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a7:	83 f8 0f             	cmp    $0xf,%eax
  8006aa:	7f 0b                	jg     8006b7 <vprintfmt+0x143>
  8006ac:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8006b3:	85 d2                	test   %edx,%edx
  8006b5:	75 20                	jne    8006d7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8006b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006bb:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
  8006c2:	00 
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	89 34 24             	mov    %esi,(%esp)
  8006ca:	e8 7d fe ff ff       	call   80054c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d2:	e9 c2 fe ff ff       	jmp    800599 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8006d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006db:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  8006e2:	00 
  8006e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e7:	89 34 24             	mov    %esi,(%esp)
  8006ea:	e8 5d fe ff ff       	call   80054c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f2:	e9 a2 fe ff ff       	jmp    800599 <vprintfmt+0x25>
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800700:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800703:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800707:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800709:	85 ff                	test   %edi,%edi
  80070b:	b8 34 24 80 00       	mov    $0x802434,%eax
  800710:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800713:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800717:	0f 84 92 00 00 00    	je     8007af <vprintfmt+0x23b>
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	0f 8e 98 00 00 00    	jle    8007bd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800725:	89 54 24 04          	mov    %edx,0x4(%esp)
  800729:	89 3c 24             	mov    %edi,(%esp)
  80072c:	e8 37 04 00 00       	call   800b68 <strnlen>
  800731:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800734:	29 c1                	sub    %eax,%ecx
  800736:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800739:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80073d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800740:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800743:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800745:	eb 0f                	jmp    800756 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074e:	89 04 24             	mov    %eax,(%esp)
  800751:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800753:	83 ef 01             	sub    $0x1,%edi
  800756:	85 ff                	test   %edi,%edi
  800758:	7f ed                	jg     800747 <vprintfmt+0x1d3>
  80075a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80075d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800760:	85 c9                	test   %ecx,%ecx
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	0f 49 c1             	cmovns %ecx,%eax
  80076a:	29 c1                	sub    %eax,%ecx
  80076c:	89 75 08             	mov    %esi,0x8(%ebp)
  80076f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800772:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800775:	89 cb                	mov    %ecx,%ebx
  800777:	eb 50                	jmp    8007c9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800779:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077d:	74 1e                	je     80079d <vprintfmt+0x229>
  80077f:	0f be d2             	movsbl %dl,%edx
  800782:	83 ea 20             	sub    $0x20,%edx
  800785:	83 fa 5e             	cmp    $0x5e,%edx
  800788:	76 13                	jbe    80079d <vprintfmt+0x229>
					putch('?', putdat);
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800798:	ff 55 08             	call   *0x8(%ebp)
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007aa:	83 eb 01             	sub    $0x1,%ebx
  8007ad:	eb 1a                	jmp    8007c9 <vprintfmt+0x255>
  8007af:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007bb:	eb 0c                	jmp    8007c9 <vprintfmt+0x255>
  8007bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007c9:	83 c7 01             	add    $0x1,%edi
  8007cc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007d0:	0f be c2             	movsbl %dl,%eax
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	74 25                	je     8007fc <vprintfmt+0x288>
  8007d7:	85 f6                	test   %esi,%esi
  8007d9:	78 9e                	js     800779 <vprintfmt+0x205>
  8007db:	83 ee 01             	sub    $0x1,%esi
  8007de:	79 99                	jns    800779 <vprintfmt+0x205>
  8007e0:	89 df                	mov    %ebx,%edi
  8007e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e8:	eb 1a                	jmp    800804 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007f5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f7:	83 ef 01             	sub    $0x1,%edi
  8007fa:	eb 08                	jmp    800804 <vprintfmt+0x290>
  8007fc:	89 df                	mov    %ebx,%edi
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800804:	85 ff                	test   %edi,%edi
  800806:	7f e2                	jg     8007ea <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800808:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080b:	e9 89 fd ff ff       	jmp    800599 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800810:	83 f9 01             	cmp    $0x1,%ecx
  800813:	7e 19                	jle    80082e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 50 04             	mov    0x4(%eax),%edx
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800820:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8d 40 08             	lea    0x8(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
  80082c:	eb 38                	jmp    800866 <vprintfmt+0x2f2>
	else if (lflag)
  80082e:	85 c9                	test   %ecx,%ecx
  800830:	74 1b                	je     80084d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 00                	mov    (%eax),%eax
  800837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083a:	89 c1                	mov    %eax,%ecx
  80083c:	c1 f9 1f             	sar    $0x1f,%ecx
  80083f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
  80084b:	eb 19                	jmp    800866 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 00                	mov    (%eax),%eax
  800852:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800855:	89 c1                	mov    %eax,%ecx
  800857:	c1 f9 1f             	sar    $0x1f,%ecx
  80085a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80085d:	8b 45 14             	mov    0x14(%ebp),%eax
  800860:	8d 40 04             	lea    0x4(%eax),%eax
  800863:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800866:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800869:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80086c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800871:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800875:	0f 89 04 01 00 00    	jns    80097f <vprintfmt+0x40b>
				putch('-', putdat);
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800886:	ff d6                	call   *%esi
				num = -(long long) num;
  800888:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80088b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80088e:	f7 da                	neg    %edx
  800890:	83 d1 00             	adc    $0x0,%ecx
  800893:	f7 d9                	neg    %ecx
  800895:	e9 e5 00 00 00       	jmp    80097f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089a:	83 f9 01             	cmp    $0x1,%ecx
  80089d:	7e 10                	jle    8008af <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8b 10                	mov    (%eax),%edx
  8008a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a7:	8d 40 08             	lea    0x8(%eax),%eax
  8008aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ad:	eb 26                	jmp    8008d5 <vprintfmt+0x361>
	else if (lflag)
  8008af:	85 c9                	test   %ecx,%ecx
  8008b1:	74 12                	je     8008c5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8b 10                	mov    (%eax),%edx
  8008b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bd:	8d 40 04             	lea    0x4(%eax),%eax
  8008c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c3:	eb 10                	jmp    8008d5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008cf:	8d 40 04             	lea    0x4(%eax),%eax
  8008d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8008d5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8008da:	e9 a0 00 00 00       	jmp    80097f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008ea:	ff d6                	call   *%esi
			putch('X', putdat);
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8008f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800904:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800909:	e9 8b fc ff ff       	jmp    800599 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800919:	ff d6                	call   *%esi
			putch('x', putdat);
  80091b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800926:	ff d6                	call   *%esi
			num = (unsigned long long)
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80093d:	eb 40                	jmp    80097f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80093f:	83 f9 01             	cmp    $0x1,%ecx
  800942:	7e 10                	jle    800954 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800944:	8b 45 14             	mov    0x14(%ebp),%eax
  800947:	8b 10                	mov    (%eax),%edx
  800949:	8b 48 04             	mov    0x4(%eax),%ecx
  80094c:	8d 40 08             	lea    0x8(%eax),%eax
  80094f:	89 45 14             	mov    %eax,0x14(%ebp)
  800952:	eb 26                	jmp    80097a <vprintfmt+0x406>
	else if (lflag)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 12                	je     80096a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800958:	8b 45 14             	mov    0x14(%ebp),%eax
  80095b:	8b 10                	mov    (%eax),%edx
  80095d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800962:	8d 40 04             	lea    0x4(%eax),%eax
  800965:	89 45 14             	mov    %eax,0x14(%ebp)
  800968:	eb 10                	jmp    80097a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8b 10                	mov    (%eax),%edx
  80096f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800974:	8d 40 04             	lea    0x4(%eax),%eax
  800977:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80097a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80097f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800983:	89 44 24 10          	mov    %eax,0x10(%esp)
  800987:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80098a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800992:	89 14 24             	mov    %edx,(%esp)
  800995:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800999:	89 da                	mov    %ebx,%edx
  80099b:	89 f0                	mov    %esi,%eax
  80099d:	e8 9e fa ff ff       	call   800440 <printnum>
			break;
  8009a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a5:	e9 ef fb ff ff       	jmp    800599 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ae:	89 04 24             	mov    %eax,(%esp)
  8009b1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b6:	e9 de fb ff ff       	jmp    800599 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c8:	eb 03                	jmp    8009cd <vprintfmt+0x459>
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009d1:	75 f7                	jne    8009ca <vprintfmt+0x456>
  8009d3:	e9 c1 fb ff ff       	jmp    800599 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8009d8:	83 c4 3c             	add    $0x3c,%esp
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 28             	sub    $0x28,%esp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	74 30                	je     800a31 <vsnprintf+0x51>
  800a01:	85 d2                	test   %edx,%edx
  800a03:	7e 2c                	jle    800a31 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a13:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1a:	c7 04 24 2f 05 80 00 	movl   $0x80052f,(%esp)
  800a21:	e8 4e fb ff ff       	call   800574 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a29:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2f:	eb 05                	jmp    800a36 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a45:	8b 45 10             	mov    0x10(%ebp),%eax
  800a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 82 ff ff ff       	call   8009e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	83 ec 1c             	sub    $0x1c,%esp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	74 18                	je     800a88 <readline+0x28>
		fprintf(1, "%s", prompt);
  800a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a74:	c7 44 24 04 2a 28 80 	movl   $0x80282a,0x4(%esp)
  800a7b:	00 
  800a7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a83:	e8 c8 10 00 00       	call   801b50 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  800a88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a8f:	e8 a8 f7 ff ff       	call   80023c <iscons>
  800a94:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800a96:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800a9b:	e8 66 f7 ff ff       	call   800206 <getchar>
  800aa0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	79 25                	jns    800acb <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800aab:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800aae:	0f 84 88 00 00 00    	je     800b3c <readline+0xdc>
				cprintf("read error: %e\n", c);
  800ab4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab8:	c7 04 24 1f 27 80 00 	movl   $0x80271f,(%esp)
  800abf:	e8 57 f9 ff ff       	call   80041b <cprintf>
			return NULL;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	eb 71                	jmp    800b3c <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800acb:	83 f8 7f             	cmp    $0x7f,%eax
  800ace:	74 05                	je     800ad5 <readline+0x75>
  800ad0:	83 f8 08             	cmp    $0x8,%eax
  800ad3:	75 19                	jne    800aee <readline+0x8e>
  800ad5:	85 f6                	test   %esi,%esi
  800ad7:	7e 15                	jle    800aee <readline+0x8e>
			if (echoing)
  800ad9:	85 ff                	test   %edi,%edi
  800adb:	74 0c                	je     800ae9 <readline+0x89>
				cputchar('\b');
  800add:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800ae4:	e8 fc f6 ff ff       	call   8001e5 <cputchar>
			i--;
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	eb ad                	jmp    800a9b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800aee:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800af4:	7f 1c                	jg     800b12 <readline+0xb2>
  800af6:	83 fb 1f             	cmp    $0x1f,%ebx
  800af9:	7e 17                	jle    800b12 <readline+0xb2>
			if (echoing)
  800afb:	85 ff                	test   %edi,%edi
  800afd:	74 08                	je     800b07 <readline+0xa7>
				cputchar(c);
  800aff:	89 1c 24             	mov    %ebx,(%esp)
  800b02:	e8 de f6 ff ff       	call   8001e5 <cputchar>
			buf[i++] = c;
  800b07:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800b0d:	8d 76 01             	lea    0x1(%esi),%esi
  800b10:	eb 89                	jmp    800a9b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800b12:	83 fb 0d             	cmp    $0xd,%ebx
  800b15:	74 09                	je     800b20 <readline+0xc0>
  800b17:	83 fb 0a             	cmp    $0xa,%ebx
  800b1a:	0f 85 7b ff ff ff    	jne    800a9b <readline+0x3b>
			if (echoing)
  800b20:	85 ff                	test   %edi,%edi
  800b22:	74 0c                	je     800b30 <readline+0xd0>
				cputchar('\n');
  800b24:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800b2b:	e8 b5 f6 ff ff       	call   8001e5 <cputchar>
			buf[i] = 0;
  800b30:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800b37:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800b3c:	83 c4 1c             	add    $0x1c,%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    
  800b44:	66 90                	xchg   %ax,%ax
  800b46:	66 90                	xchg   %ax,%ax
  800b48:	66 90                	xchg   %ax,%ax
  800b4a:	66 90                	xchg   %ax,%ax
  800b4c:	66 90                	xchg   %ax,%ax
  800b4e:	66 90                	xchg   %ax,%ax

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	eb 03                	jmp    800b60 <strlen+0x10>
		n++;
  800b5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b64:	75 f7                	jne    800b5d <strlen+0xd>
		n++;
	return n;
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb 03                	jmp    800b7b <strnlen+0x13>
		n++;
  800b78:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7b:	39 d0                	cmp    %edx,%eax
  800b7d:	74 06                	je     800b85 <strnlen+0x1d>
  800b7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b83:	75 f3                	jne    800b78 <strnlen+0x10>
		n++;
	return n;
}
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	53                   	push   %ebx
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	83 c1 01             	add    $0x1,%ecx
  800b99:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b9d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	75 ef                	jne    800b93 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb1:	89 1c 24             	mov    %ebx,(%esp)
  800bb4:	e8 97 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc0:	01 d8                	add    %ebx,%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 bd ff ff ff       	call   800b87 <strcpy>
	return dst;
}
  800bca:	89 d8                	mov    %ebx,%eax
  800bcc:	83 c4 08             	add    $0x8,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be2:	89 f2                	mov    %esi,%edx
  800be4:	eb 0f                	jmp    800bf5 <strncpy+0x23>
		*dst++ = *src;
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bef:	80 39 01             	cmpb   $0x1,(%ecx)
  800bf2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf5:	39 da                	cmp    %ebx,%edx
  800bf7:	75 ed                	jne    800be6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf9:	89 f0                	mov    %esi,%eax
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 75 08             	mov    0x8(%ebp),%esi
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c13:	85 c9                	test   %ecx,%ecx
  800c15:	75 0b                	jne    800c22 <strlcpy+0x23>
  800c17:	eb 1d                	jmp    800c36 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c22:	39 d8                	cmp    %ebx,%eax
  800c24:	74 0b                	je     800c31 <strlcpy+0x32>
  800c26:	0f b6 0a             	movzbl (%edx),%ecx
  800c29:	84 c9                	test   %cl,%cl
  800c2b:	75 ec                	jne    800c19 <strlcpy+0x1a>
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	eb 02                	jmp    800c33 <strlcpy+0x34>
  800c31:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c33:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c36:	29 f0                	sub    %esi,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c45:	eb 06                	jmp    800c4d <strcmp+0x11>
		p++, q++;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c4d:	0f b6 01             	movzbl (%ecx),%eax
  800c50:	84 c0                	test   %al,%al
  800c52:	74 04                	je     800c58 <strcmp+0x1c>
  800c54:	3a 02                	cmp    (%edx),%al
  800c56:	74 ef                	je     800c47 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	0f b6 12             	movzbl (%edx),%edx
  800c5e:	29 d0                	sub    %edx,%eax
}
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	53                   	push   %ebx
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c71:	eb 06                	jmp    800c79 <strncmp+0x17>
		n--, p++, q++;
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c79:	39 d8                	cmp    %ebx,%eax
  800c7b:	74 15                	je     800c92 <strncmp+0x30>
  800c7d:	0f b6 08             	movzbl (%eax),%ecx
  800c80:	84 c9                	test   %cl,%cl
  800c82:	74 04                	je     800c88 <strncmp+0x26>
  800c84:	3a 0a                	cmp    (%edx),%cl
  800c86:	74 eb                	je     800c73 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	0f b6 12             	movzbl (%edx),%edx
  800c8e:	29 d0                	sub    %edx,%eax
  800c90:	eb 05                	jmp    800c97 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca4:	eb 07                	jmp    800cad <strchr+0x13>
		if (*s == c)
  800ca6:	38 ca                	cmp    %cl,%dl
  800ca8:	74 0f                	je     800cb9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	0f b6 10             	movzbl (%eax),%edx
  800cb0:	84 d2                	test   %dl,%dl
  800cb2:	75 f2                	jne    800ca6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc5:	eb 07                	jmp    800cce <strfind+0x13>
		if (*s == c)
  800cc7:	38 ca                	cmp    %cl,%dl
  800cc9:	74 0a                	je     800cd5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ccb:	83 c0 01             	add    $0x1,%eax
  800cce:	0f b6 10             	movzbl (%eax),%edx
  800cd1:	84 d2                	test   %dl,%dl
  800cd3:	75 f2                	jne    800cc7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ce3:	85 c9                	test   %ecx,%ecx
  800ce5:	74 36                	je     800d1d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ce7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ced:	75 28                	jne    800d17 <memset+0x40>
  800cef:	f6 c1 03             	test   $0x3,%cl
  800cf2:	75 23                	jne    800d17 <memset+0x40>
		c &= 0xFF;
  800cf4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	c1 e3 08             	shl    $0x8,%ebx
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	c1 e6 18             	shl    $0x18,%esi
  800d02:	89 d0                	mov    %edx,%eax
  800d04:	c1 e0 10             	shl    $0x10,%eax
  800d07:	09 f0                	or     %esi,%eax
  800d09:	09 c2                	or     %eax,%edx
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d0f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d12:	fc                   	cld    
  800d13:	f3 ab                	rep stos %eax,%es:(%edi)
  800d15:	eb 06                	jmp    800d1d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	fc                   	cld    
  800d1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d1d:	89 f8                	mov    %edi,%eax
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d32:	39 c6                	cmp    %eax,%esi
  800d34:	73 35                	jae    800d6b <memmove+0x47>
  800d36:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d39:	39 d0                	cmp    %edx,%eax
  800d3b:	73 2e                	jae    800d6b <memmove+0x47>
		s += n;
		d += n;
  800d3d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d44:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4a:	75 13                	jne    800d5f <memmove+0x3b>
  800d4c:	f6 c1 03             	test   $0x3,%cl
  800d4f:	75 0e                	jne    800d5f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d51:	83 ef 04             	sub    $0x4,%edi
  800d54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d5a:	fd                   	std    
  800d5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d5d:	eb 09                	jmp    800d68 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d5f:	83 ef 01             	sub    $0x1,%edi
  800d62:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d65:	fd                   	std    
  800d66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d68:	fc                   	cld    
  800d69:	eb 1d                	jmp    800d88 <memmove+0x64>
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6f:	f6 c2 03             	test   $0x3,%dl
  800d72:	75 0f                	jne    800d83 <memmove+0x5f>
  800d74:	f6 c1 03             	test   $0x3,%cl
  800d77:	75 0a                	jne    800d83 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d79:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	fc                   	cld    
  800d7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d81:	eb 05                	jmp    800d88 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d83:	89 c7                	mov    %eax,%edi
  800d85:	fc                   	cld    
  800d86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d92:	8b 45 10             	mov    0x10(%ebp),%eax
  800d95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	89 04 24             	mov    %eax,(%esp)
  800da6:	e8 79 ff ff ff       	call   800d24 <memmove>
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	eb 1a                	jmp    800dd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800dbf:	0f b6 02             	movzbl (%edx),%eax
  800dc2:	0f b6 19             	movzbl (%ecx),%ebx
  800dc5:	38 d8                	cmp    %bl,%al
  800dc7:	74 0a                	je     800dd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dc9:	0f b6 c0             	movzbl %al,%eax
  800dcc:	0f b6 db             	movzbl %bl,%ebx
  800dcf:	29 d8                	sub    %ebx,%eax
  800dd1:	eb 0f                	jmp    800de2 <memcmp+0x35>
		s1++, s2++;
  800dd3:	83 c2 01             	add    $0x1,%edx
  800dd6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd9:	39 f2                	cmp    %esi,%edx
  800ddb:	75 e2                	jne    800dbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800def:	89 c2                	mov    %eax,%edx
  800df1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df4:	eb 07                	jmp    800dfd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df6:	38 08                	cmp    %cl,(%eax)
  800df8:	74 07                	je     800e01 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dfa:	83 c0 01             	add    $0x1,%eax
  800dfd:	39 d0                	cmp    %edx,%eax
  800dff:	72 f5                	jb     800df6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0f:	eb 03                	jmp    800e14 <strtol+0x11>
		s++;
  800e11:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e14:	0f b6 0a             	movzbl (%edx),%ecx
  800e17:	80 f9 09             	cmp    $0x9,%cl
  800e1a:	74 f5                	je     800e11 <strtol+0xe>
  800e1c:	80 f9 20             	cmp    $0x20,%cl
  800e1f:	74 f0                	je     800e11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e21:	80 f9 2b             	cmp    $0x2b,%cl
  800e24:	75 0a                	jne    800e30 <strtol+0x2d>
		s++;
  800e26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e29:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2e:	eb 11                	jmp    800e41 <strtol+0x3e>
  800e30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e35:	80 f9 2d             	cmp    $0x2d,%cl
  800e38:	75 07                	jne    800e41 <strtol+0x3e>
		s++, neg = 1;
  800e3a:	8d 52 01             	lea    0x1(%edx),%edx
  800e3d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e41:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e46:	75 15                	jne    800e5d <strtol+0x5a>
  800e48:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4b:	75 10                	jne    800e5d <strtol+0x5a>
  800e4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e51:	75 0a                	jne    800e5d <strtol+0x5a>
		s += 2, base = 16;
  800e53:	83 c2 02             	add    $0x2,%edx
  800e56:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5b:	eb 10                	jmp    800e6d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	75 0c                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e61:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e63:	80 3a 30             	cmpb   $0x30,(%edx)
  800e66:	75 05                	jne    800e6d <strtol+0x6a>
		s++, base = 8;
  800e68:	83 c2 01             	add    $0x1,%edx
  800e6b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e72:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e75:	0f b6 0a             	movzbl (%edx),%ecx
  800e78:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e7b:	89 f0                	mov    %esi,%eax
  800e7d:	3c 09                	cmp    $0x9,%al
  800e7f:	77 08                	ja     800e89 <strtol+0x86>
			dig = *s - '0';
  800e81:	0f be c9             	movsbl %cl,%ecx
  800e84:	83 e9 30             	sub    $0x30,%ecx
  800e87:	eb 20                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e89:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e8c:	89 f0                	mov    %esi,%eax
  800e8e:	3c 19                	cmp    $0x19,%al
  800e90:	77 08                	ja     800e9a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e92:	0f be c9             	movsbl %cl,%ecx
  800e95:	83 e9 57             	sub    $0x57,%ecx
  800e98:	eb 0f                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e9a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e9d:	89 f0                	mov    %esi,%eax
  800e9f:	3c 19                	cmp    $0x19,%al
  800ea1:	77 16                	ja     800eb9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ea3:	0f be c9             	movsbl %cl,%ecx
  800ea6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ea9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800eac:	7d 0f                	jge    800ebd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800eae:	83 c2 01             	add    $0x1,%edx
  800eb1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800eb5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800eb7:	eb bc                	jmp    800e75 <strtol+0x72>
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	eb 02                	jmp    800ebf <strtol+0xbc>
  800ebd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec3:	74 05                	je     800eca <strtol+0xc7>
		*endptr = (char *) s;
  800ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800eca:	f7 d8                	neg    %eax
  800ecc:	85 ff                	test   %edi,%edi
  800ece:	0f 44 c3             	cmove  %ebx,%eax
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	89 c7                	mov    %eax,%edi
  800eeb:	89 c6                	mov    %eax,%esi
  800eed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 01 00 00 00       	mov    $0x1,%eax
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 d3                	mov    %edx,%ebx
  800f08:	89 d7                	mov    %edx,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f21:	b8 03 00 00 00       	mov    $0x3,%eax
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 cb                	mov    %ecx,%ebx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	89 ce                	mov    %ecx,%esi
  800f2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  800f58:	e8 c5 f3 ff ff       	call   800322 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f5d:	83 c4 2c             	add    $0x2c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 02 00 00 00       	mov    $0x2,%eax
  800f75:	89 d1                	mov    %edx,%ecx
  800f77:	89 d3                	mov    %edx,%ebx
  800f79:	89 d7                	mov    %edx,%edi
  800f7b:	89 d6                	mov    %edx,%esi
  800f7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_yield>:

void
sys_yield(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 d3                	mov    %edx,%ebx
  800f98:	89 d7                	mov    %edx,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	be 00 00 00 00       	mov    $0x0,%esi
  800fb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	89 f7                	mov    %esi,%edi
  800fc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 28                	jle    800fef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  800fea:	e8 33 f3 ff ff       	call   800322 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fef:	83 c4 2c             	add    $0x2c,%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801000:	b8 05 00 00 00       	mov    $0x5,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801011:	8b 75 18             	mov    0x18(%ebp),%esi
  801014:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	7e 28                	jle    801042 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801025:	00 
  801026:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  80103d:	e8 e0 f2 ff ff       	call   800322 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801042:	83 c4 2c             	add    $0x2c,%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	b8 06 00 00 00       	mov    $0x6,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 df                	mov    %ebx,%edi
  801065:	89 de                	mov    %ebx,%esi
  801067:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7e 28                	jle    801095 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80106d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801071:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801078:	00 
  801079:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  801090:	e8 8d f2 ff ff       	call   800322 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801095:	83 c4 2c             	add    $0x2c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 df                	mov    %ebx,%edi
  8010b8:	89 de                	mov    %ebx,%esi
  8010ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 28                	jle    8010e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010db:	00 
  8010dc:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  8010e3:	e8 3a f2 ff ff       	call   800322 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e8:	83 c4 2c             	add    $0x2c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 df                	mov    %ebx,%edi
  80110b:	89 de                	mov    %ebx,%esi
  80110d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	7e 28                	jle    80113b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801113:	89 44 24 10          	mov    %eax,0x10(%esp)
  801117:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80111e:	00 
  80111f:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  801136:	e8 e7 f1 ff ff       	call   800322 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80113b:	83 c4 2c             	add    $0x2c,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 0a 00 00 00       	mov    $0xa,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	89 de                	mov    %ebx,%esi
  801160:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 28                	jle    80118e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801171:	00 
  801172:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  801179:	00 
  80117a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801181:	00 
  801182:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  801189:	e8 94 f1 ff ff       	call   800322 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80118e:	83 c4 2c             	add    $0x2c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	57                   	push   %edi
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119c:	be 00 00 00 00       	mov    $0x0,%esi
  8011a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cf:	89 cb                	mov    %ecx,%ebx
  8011d1:	89 cf                	mov    %ecx,%edi
  8011d3:	89 ce                	mov    %ecx,%esi
  8011d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7e 28                	jle    801203 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 08 2f 27 80 	movl   $0x80272f,0x8(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f6:	00 
  8011f7:	c7 04 24 4c 27 80 00 	movl   $0x80274c,(%esp)
  8011fe:	e8 1f f1 ff ff       	call   800322 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801203:	83 c4 2c             	add    $0x2c,%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    
  80120b:	66 90                	xchg   %ax,%ax
  80120d:	66 90                	xchg   %ax,%ax
  80120f:	90                   	nop

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80122b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801230:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801242:	89 c2                	mov    %eax,%edx
  801244:	c1 ea 16             	shr    $0x16,%edx
  801247:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124e:	f6 c2 01             	test   $0x1,%dl
  801251:	74 11                	je     801264 <fd_alloc+0x2d>
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 ea 0c             	shr    $0xc,%edx
  801258:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	75 09                	jne    80126d <fd_alloc+0x36>
			*fd_store = fd;
  801264:	89 01                	mov    %eax,(%ecx)
			return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 17                	jmp    801284 <fd_alloc+0x4d>
  80126d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801272:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801277:	75 c9                	jne    801242 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801279:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80127f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80128c:	83 f8 1f             	cmp    $0x1f,%eax
  80128f:	77 36                	ja     8012c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801291:	c1 e0 0c             	shl    $0xc,%eax
  801294:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801299:	89 c2                	mov    %eax,%edx
  80129b:	c1 ea 16             	shr    $0x16,%edx
  80129e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	74 24                	je     8012ce <fd_lookup+0x48>
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	c1 ea 0c             	shr    $0xc,%edx
  8012af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 1a                	je     8012d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	eb 13                	jmp    8012da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb 0c                	jmp    8012da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb 05                	jmp    8012da <fd_lookup+0x54>
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 18             	sub    $0x18,%esp
  8012e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e5:	ba d8 27 80 00       	mov    $0x8027d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ea:	eb 13                	jmp    8012ff <dev_lookup+0x23>
  8012ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012ef:	39 08                	cmp    %ecx,(%eax)
  8012f1:	75 0c                	jne    8012ff <dev_lookup+0x23>
			*dev = devtab[i];
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	eb 30                	jmp    80132f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ff:	8b 02                	mov    (%edx),%eax
  801301:	85 c0                	test   %eax,%eax
  801303:	75 e7                	jne    8012ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801305:	a1 04 44 80 00       	mov    0x804404,%eax
  80130a:	8b 40 48             	mov    0x48(%eax),%eax
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 44 24 04          	mov    %eax,0x4(%esp)
  801315:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  80131c:	e8 fa f0 ff ff       	call   80041b <cprintf>
	*dev = 0;
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 20             	sub    $0x20,%esp
  801339:	8b 75 08             	mov    0x8(%ebp),%esi
  80133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801346:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 2f ff ff ff       	call   801286 <fd_lookup>
  801357:	85 c0                	test   %eax,%eax
  801359:	78 05                	js     801360 <fd_close+0x2f>
	    || fd != fd2)
  80135b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135e:	74 0c                	je     80136c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801360:	84 db                	test   %bl,%bl
  801362:	ba 00 00 00 00       	mov    $0x0,%edx
  801367:	0f 44 c2             	cmove  %edx,%eax
  80136a:	eb 3f                	jmp    8013ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801373:	8b 06                	mov    (%esi),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	e8 5f ff ff ff       	call   8012dc <dev_lookup>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 16                	js     801399 <fd_close+0x68>
		if (dev->dev_close)
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80138e:	85 c0                	test   %eax,%eax
  801390:	74 07                	je     801399 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801392:	89 34 24             	mov    %esi,(%esp)
  801395:	ff d0                	call   *%eax
  801397:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801399:	89 74 24 04          	mov    %esi,0x4(%esp)
  80139d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a4:	e8 a1 fc ff ff       	call   80104a <sys_page_unmap>
	return r;
  8013a9:	89 d8                	mov    %ebx,%eax
}
  8013ab:	83 c4 20             	add    $0x20,%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	e8 bc fe ff ff       	call   801286 <fd_lookup>
  8013ca:	89 c2                	mov    %eax,%edx
  8013cc:	85 d2                	test   %edx,%edx
  8013ce:	78 13                	js     8013e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8013d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013d7:	00 
  8013d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 4e ff ff ff       	call   801331 <fd_close>
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <close_all>:

void
close_all(void)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f1:	89 1c 24             	mov    %ebx,(%esp)
  8013f4:	e8 b9 ff ff ff       	call   8013b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f9:	83 c3 01             	add    $0x1,%ebx
  8013fc:	83 fb 20             	cmp    $0x20,%ebx
  8013ff:	75 f0                	jne    8013f1 <close_all+0xc>
		close(i);
}
  801401:	83 c4 14             	add    $0x14,%esp
  801404:	5b                   	pop    %ebx
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801410:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	e8 64 fe ff ff       	call   801286 <fd_lookup>
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 d2                	test   %edx,%edx
  801426:	0f 88 e1 00 00 00    	js     80150d <dup+0x106>
		return r;
	close(newfdnum);
  80142c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 7b ff ff ff       	call   8013b2 <close>

	newfd = INDEX2FD(newfdnum);
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143a:	c1 e3 0c             	shl    $0xc,%ebx
  80143d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801443:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	e8 d2 fd ff ff       	call   801220 <fd2data>
  80144e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801450:	89 1c 24             	mov    %ebx,(%esp)
  801453:	e8 c8 fd ff ff       	call   801220 <fd2data>
  801458:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145a:	89 f0                	mov    %esi,%eax
  80145c:	c1 e8 16             	shr    $0x16,%eax
  80145f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801466:	a8 01                	test   $0x1,%al
  801468:	74 43                	je     8014ad <dup+0xa6>
  80146a:	89 f0                	mov    %esi,%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
  80146f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801476:	f6 c2 01             	test   $0x1,%dl
  801479:	74 32                	je     8014ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	25 07 0e 00 00       	and    $0xe07,%eax
  801487:	89 44 24 10          	mov    %eax,0x10(%esp)
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801496:	00 
  801497:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a2:	e8 50 fb ff ff       	call   800ff7 <sys_page_map>
  8014a7:	89 c6                	mov    %eax,%esi
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 3e                	js     8014eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	c1 ea 0c             	shr    $0xc,%edx
  8014b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014d1:	00 
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014dd:	e8 15 fb ff ff       	call   800ff7 <sys_page_map>
  8014e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8014e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e7:	85 f6                	test   %esi,%esi
  8014e9:	79 22                	jns    80150d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f6:	e8 4f fb ff ff       	call   80104a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801506:	e8 3f fb ff ff       	call   80104a <sys_page_unmap>
	return r;
  80150b:	89 f0                	mov    %esi,%eax
}
  80150d:	83 c4 3c             	add    $0x3c,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 24             	sub    $0x24,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	89 1c 24             	mov    %ebx,(%esp)
  801529:	e8 58 fd ff ff       	call   801286 <fd_lookup>
  80152e:	89 c2                	mov    %eax,%edx
  801530:	85 d2                	test   %edx,%edx
  801532:	78 6d                	js     8015a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	89 04 24             	mov    %eax,(%esp)
  801543:	e8 94 fd ff ff       	call   8012dc <dev_lookup>
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 55                	js     8015a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	8b 50 08             	mov    0x8(%eax),%edx
  801552:	83 e2 03             	and    $0x3,%edx
  801555:	83 fa 01             	cmp    $0x1,%edx
  801558:	75 23                	jne    80157d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155a:	a1 04 44 80 00       	mov    0x804404,%eax
  80155f:	8b 40 48             	mov    0x48(%eax),%eax
  801562:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	c7 04 24 9d 27 80 00 	movl   $0x80279d,(%esp)
  801571:	e8 a5 ee ff ff       	call   80041b <cprintf>
		return -E_INVAL;
  801576:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157b:	eb 24                	jmp    8015a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80157d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801580:	8b 52 08             	mov    0x8(%edx),%edx
  801583:	85 d2                	test   %edx,%edx
  801585:	74 15                	je     80159c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801587:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80158a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80158e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801591:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	ff d2                	call   *%edx
  80159a:	eb 05                	jmp    8015a1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015a1:	83 c4 24             	add    $0x24,%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    

008015a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 1c             	sub    $0x1c,%esp
  8015b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bb:	eb 23                	jmp    8015e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bd:	89 f0                	mov    %esi,%eax
  8015bf:	29 d8                	sub    %ebx,%eax
  8015c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	03 45 0c             	add    0xc(%ebp),%eax
  8015ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ce:	89 3c 24             	mov    %edi,(%esp)
  8015d1:	e8 3f ff ff ff       	call   801515 <read>
		if (m < 0)
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 10                	js     8015ea <readn+0x43>
			return m;
		if (m == 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 0a                	je     8015e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015de:	01 c3                	add    %eax,%ebx
  8015e0:	39 f3                	cmp    %esi,%ebx
  8015e2:	72 d9                	jb     8015bd <readn+0x16>
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	eb 02                	jmp    8015ea <readn+0x43>
  8015e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ea:	83 c4 1c             	add    $0x1c,%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 24             	sub    $0x24,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801603:	89 1c 24             	mov    %ebx,(%esp)
  801606:	e8 7b fc ff ff       	call   801286 <fd_lookup>
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 d2                	test   %edx,%edx
  80160f:	78 68                	js     801679 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	8b 00                	mov    (%eax),%eax
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	e8 b7 fc ff ff       	call   8012dc <dev_lookup>
  801625:	85 c0                	test   %eax,%eax
  801627:	78 50                	js     801679 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801630:	75 23                	jne    801655 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801632:	a1 04 44 80 00       	mov    0x804404,%eax
  801637:	8b 40 48             	mov    0x48(%eax),%eax
  80163a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80163e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801642:	c7 04 24 b9 27 80 00 	movl   $0x8027b9,(%esp)
  801649:	e8 cd ed ff ff       	call   80041b <cprintf>
		return -E_INVAL;
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801653:	eb 24                	jmp    801679 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801658:	8b 52 0c             	mov    0xc(%edx),%edx
  80165b:	85 d2                	test   %edx,%edx
  80165d:	74 15                	je     801674 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801662:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801669:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	ff d2                	call   *%edx
  801672:	eb 05                	jmp    801679 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801674:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801679:	83 c4 24             	add    $0x24,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <seek>:

int
seek(int fdnum, off_t offset)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801685:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 ef fb ff ff       	call   801286 <fd_lookup>
  801697:	85 c0                	test   %eax,%eax
  801699:	78 0e                	js     8016a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 24             	sub    $0x24,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 c2 fb ff ff       	call   801286 <fd_lookup>
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	78 61                	js     80172b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	8b 00                	mov    (%eax),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 fe fb ff ff       	call   8012dc <dev_lookup>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 49                	js     80172b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e9:	75 23                	jne    80170e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016eb:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016f0:	8b 40 48             	mov    0x48(%eax),%eax
  8016f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fb:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  801702:	e8 14 ed ff ff       	call   80041b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170c:	eb 1d                	jmp    80172b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80170e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801711:	8b 52 18             	mov    0x18(%edx),%edx
  801714:	85 d2                	test   %edx,%edx
  801716:	74 0e                	je     801726 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80171f:	89 04 24             	mov    %eax,(%esp)
  801722:	ff d2                	call   *%edx
  801724:	eb 05                	jmp    80172b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801726:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80172b:	83 c4 24             	add    $0x24,%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 24             	sub    $0x24,%esp
  801738:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 39 fb ff ff       	call   801286 <fd_lookup>
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	85 d2                	test   %edx,%edx
  801751:	78 52                	js     8017a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175d:	8b 00                	mov    (%eax),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 75 fb ff ff       	call   8012dc <dev_lookup>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 3a                	js     8017a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801772:	74 2c                	je     8017a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801774:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801777:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177e:	00 00 00 
	stat->st_isdir = 0;
  801781:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801788:	00 00 00 
	stat->st_dev = dev;
  80178b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801795:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801798:	89 14 24             	mov    %edx,(%esp)
  80179b:	ff 50 14             	call   *0x14(%eax)
  80179e:	eb 05                	jmp    8017a5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a5:	83 c4 24             	add    $0x24,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017ba:	00 
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	e8 fb 01 00 00       	call   8019c1 <open>
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	85 db                	test   %ebx,%ebx
  8017ca:	78 1b                	js     8017e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	89 1c 24             	mov    %ebx,(%esp)
  8017d6:	e8 56 ff ff ff       	call   801731 <fstat>
  8017db:	89 c6                	mov    %eax,%esi
	close(fd);
  8017dd:	89 1c 24             	mov    %ebx,(%esp)
  8017e0:	e8 cd fb ff ff       	call   8013b2 <close>
	return r;
  8017e5:	89 f0                	mov    %esi,%eax
}
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 10             	sub    $0x10,%esp
  8017f6:	89 c6                	mov    %eax,%esi
  8017f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fa:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801801:	75 11                	jne    801814 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801803:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80180a:	e8 5e 08 00 00       	call   80206d <ipc_find_env>
  80180f:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801814:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80181b:	00 
  80181c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801823:	00 
  801824:	89 74 24 04          	mov    %esi,0x4(%esp)
  801828:	a1 00 44 80 00       	mov    0x804400,%eax
  80182d:	89 04 24             	mov    %eax,(%esp)
  801830:	e8 89 07 00 00       	call   801fbe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801835:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183c:	00 
  80183d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801841:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801848:	e8 d3 06 00 00       	call   801f20 <ipc_recv>
}
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 02 00 00 00       	mov    $0x2,%eax
  801877:	e8 72 ff ff ff       	call   8017ee <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 06 00 00 00       	mov    $0x6,%eax
  801899:	e8 50 ff ff ff       	call   8017ee <fsipc>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 14             	sub    $0x14,%esp
  8018a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bf:	e8 2a ff ff ff       	call   8017ee <fsipc>
  8018c4:	89 c2                	mov    %eax,%edx
  8018c6:	85 d2                	test   %edx,%edx
  8018c8:	78 2b                	js     8018f5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018d1:	00 
  8018d2:	89 1c 24             	mov    %ebx,(%esp)
  8018d5:	e8 ad f2 ff ff       	call   800b87 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018da:	a1 80 50 80 00       	mov    0x805080,%eax
  8018df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f5:	83 c4 14             	add    $0x14,%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801901:	c7 44 24 08 e8 27 80 	movl   $0x8027e8,0x8(%esp)
  801908:	00 
  801909:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801910:	00 
  801911:	c7 04 24 06 28 80 00 	movl   $0x802806,(%esp)
  801918:	e8 05 ea ff ff       	call   800322 <_panic>

0080191d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 10             	sub    $0x10,%esp
  801925:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 40 0c             	mov    0xc(%eax),%eax
  80192e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801933:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 03 00 00 00       	mov    $0x3,%eax
  801943:	e8 a6 fe ff ff       	call   8017ee <fsipc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 6a                	js     8019b8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80194e:	39 c6                	cmp    %eax,%esi
  801950:	73 24                	jae    801976 <devfile_read+0x59>
  801952:	c7 44 24 0c 11 28 80 	movl   $0x802811,0xc(%esp)
  801959:	00 
  80195a:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  801961:	00 
  801962:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801969:	00 
  80196a:	c7 04 24 06 28 80 00 	movl   $0x802806,(%esp)
  801971:	e8 ac e9 ff ff       	call   800322 <_panic>
	assert(r <= PGSIZE);
  801976:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197b:	7e 24                	jle    8019a1 <devfile_read+0x84>
  80197d:	c7 44 24 0c 2d 28 80 	movl   $0x80282d,0xc(%esp)
  801984:	00 
  801985:	c7 44 24 08 18 28 80 	movl   $0x802818,0x8(%esp)
  80198c:	00 
  80198d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801994:	00 
  801995:	c7 04 24 06 28 80 00 	movl   $0x802806,(%esp)
  80199c:	e8 81 e9 ff ff       	call   800322 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ac:	00 
  8019ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b0:	89 04 24             	mov    %eax,(%esp)
  8019b3:	e8 6c f3 ff ff       	call   800d24 <memmove>
	return r;
}
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 24             	sub    $0x24,%esp
  8019c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019cb:	89 1c 24             	mov    %ebx,(%esp)
  8019ce:	e8 7d f1 ff ff       	call   800b50 <strlen>
  8019d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d8:	7f 60                	jg     801a3a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	e8 52 f8 ff ff       	call   801237 <fd_alloc>
  8019e5:	89 c2                	mov    %eax,%edx
  8019e7:	85 d2                	test   %edx,%edx
  8019e9:	78 54                	js     801a3f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019f6:	e8 8c f1 ff ff       	call   800b87 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a06:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0b:	e8 de fd ff ff       	call   8017ee <fsipc>
  801a10:	89 c3                	mov    %eax,%ebx
  801a12:	85 c0                	test   %eax,%eax
  801a14:	79 17                	jns    801a2d <open+0x6c>
		fd_close(fd, 0);
  801a16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a1d:	00 
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 08 f9 ff ff       	call   801331 <fd_close>
		return r;
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	eb 12                	jmp    801a3f <open+0x7e>
	}

	return fd2num(fd);
  801a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a30:	89 04 24             	mov    %eax,(%esp)
  801a33:	e8 d8 f7 ff ff       	call   801210 <fd2num>
  801a38:	eb 05                	jmp    801a3f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a3a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a3f:	83 c4 24             	add    $0x24,%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a50:	b8 08 00 00 00       	mov    $0x8,%eax
  801a55:	e8 94 fd ff ff       	call   8017ee <fsipc>
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 14             	sub    $0x14,%esp
  801a63:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a65:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a69:	7e 31                	jle    801a9c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a6b:	8b 40 04             	mov    0x4(%eax),%eax
  801a6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a72:	8d 43 10             	lea    0x10(%ebx),%eax
  801a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a79:	8b 03                	mov    (%ebx),%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 6f fb ff ff       	call   8015f2 <write>
		if (result > 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	7e 03                	jle    801a8a <writebuf+0x2e>
			b->result += result;
  801a87:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a8a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a8d:	74 0d                	je     801a9c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	ba 00 00 00 00       	mov    $0x0,%edx
  801a96:	0f 4f c2             	cmovg  %edx,%eax
  801a99:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a9c:	83 c4 14             	add    $0x14,%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <putch>:

static void
putch(int ch, void *thunk)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 04             	sub    $0x4,%esp
  801aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801aac:	8b 53 04             	mov    0x4(%ebx),%edx
  801aaf:	8d 42 01             	lea    0x1(%edx),%eax
  801ab2:	89 43 04             	mov    %eax,0x4(%ebx)
  801ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801abc:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ac1:	75 0e                	jne    801ad1 <putch+0x2f>
		writebuf(b);
  801ac3:	89 d8                	mov    %ebx,%eax
  801ac5:	e8 92 ff ff ff       	call   801a5c <writebuf>
		b->idx = 0;
  801aca:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ad1:	83 c4 04             	add    $0x4,%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801ae9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801af0:	00 00 00 
	b.result = 0;
  801af3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801afa:	00 00 00 
	b.error = 1;
  801afd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b04:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b07:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b15:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1f:	c7 04 24 a2 1a 80 00 	movl   $0x801aa2,(%esp)
  801b26:	e8 49 ea ff ff       	call   800574 <vprintfmt>
	if (b.idx > 0)
  801b2b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b32:	7e 0b                	jle    801b3f <vfprintf+0x68>
		writebuf(&b);
  801b34:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b3a:	e8 1d ff ff ff       	call   801a5c <writebuf>

	return (b.result ? b.result : b.error);
  801b3f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b45:	85 c0                	test   %eax,%eax
  801b47:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b56:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b59:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	89 04 24             	mov    %eax,(%esp)
  801b6a:	e8 68 ff ff ff       	call   801ad7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <printf>:

int
printf(const char *fmt, ...)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b77:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b8c:	e8 46 ff ff ff       	call   801ad7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 10             	sub    $0x10,%esp
  801b9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	89 04 24             	mov    %eax,(%esp)
  801ba4:	e8 77 f6 ff ff       	call   801220 <fd2data>
  801ba9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bab:	c7 44 24 04 39 28 80 	movl   $0x802839,0x4(%esp)
  801bb2:	00 
  801bb3:	89 1c 24             	mov    %ebx,(%esp)
  801bb6:	e8 cc ef ff ff       	call   800b87 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bbb:	8b 46 04             	mov    0x4(%esi),%eax
  801bbe:	2b 06                	sub    (%esi),%eax
  801bc0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bc6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bcd:	00 00 00 
	stat->st_dev = &devpipe;
  801bd0:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bd7:	30 80 00 
	return 0;
}
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 14             	sub    $0x14,%esp
  801bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfb:	e8 4a f4 ff ff       	call   80104a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c00:	89 1c 24             	mov    %ebx,(%esp)
  801c03:	e8 18 f6 ff ff       	call   801220 <fd2data>
  801c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c13:	e8 32 f4 ff ff       	call   80104a <sys_page_unmap>
}
  801c18:	83 c4 14             	add    $0x14,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 2c             	sub    $0x2c,%esp
  801c27:	89 c6                	mov    %eax,%esi
  801c29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c2c:	a1 04 44 80 00       	mov    0x804404,%eax
  801c31:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c34:	89 34 24             	mov    %esi,(%esp)
  801c37:	e8 69 04 00 00       	call   8020a5 <pageref>
  801c3c:	89 c7                	mov    %eax,%edi
  801c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c41:	89 04 24             	mov    %eax,(%esp)
  801c44:	e8 5c 04 00 00       	call   8020a5 <pageref>
  801c49:	39 c7                	cmp    %eax,%edi
  801c4b:	0f 94 c2             	sete   %dl
  801c4e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801c51:	8b 0d 04 44 80 00    	mov    0x804404,%ecx
  801c57:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801c5a:	39 fb                	cmp    %edi,%ebx
  801c5c:	74 21                	je     801c7f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c5e:	84 d2                	test   %dl,%dl
  801c60:	74 ca                	je     801c2c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c62:	8b 51 58             	mov    0x58(%ecx),%edx
  801c65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c69:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c71:	c7 04 24 40 28 80 00 	movl   $0x802840,(%esp)
  801c78:	e8 9e e7 ff ff       	call   80041b <cprintf>
  801c7d:	eb ad                	jmp    801c2c <_pipeisclosed+0xe>
	}
}
  801c7f:	83 c4 2c             	add    $0x2c,%esp
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5f                   	pop    %edi
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	57                   	push   %edi
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 1c             	sub    $0x1c,%esp
  801c90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c93:	89 34 24             	mov    %esi,(%esp)
  801c96:	e8 85 f5 ff ff       	call   801220 <fd2data>
  801c9b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9d:	bf 00 00 00 00       	mov    $0x0,%edi
  801ca2:	eb 45                	jmp    801ce9 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ca4:	89 da                	mov    %ebx,%edx
  801ca6:	89 f0                	mov    %esi,%eax
  801ca8:	e8 71 ff ff ff       	call   801c1e <_pipeisclosed>
  801cad:	85 c0                	test   %eax,%eax
  801caf:	75 41                	jne    801cf2 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cb1:	e8 ce f2 ff ff       	call   800f84 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb6:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb9:	8b 0b                	mov    (%ebx),%ecx
  801cbb:	8d 51 20             	lea    0x20(%ecx),%edx
  801cbe:	39 d0                	cmp    %edx,%eax
  801cc0:	73 e2                	jae    801ca4 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ccc:	99                   	cltd   
  801ccd:	c1 ea 1b             	shr    $0x1b,%edx
  801cd0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801cd3:	83 e1 1f             	and    $0x1f,%ecx
  801cd6:	29 d1                	sub    %edx,%ecx
  801cd8:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801cdc:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ce0:	83 c0 01             	add    $0x1,%eax
  801ce3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce6:	83 c7 01             	add    $0x1,%edi
  801ce9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cec:	75 c8                	jne    801cb6 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cee:	89 f8                	mov    %edi,%eax
  801cf0:	eb 05                	jmp    801cf7 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf7:	83 c4 1c             	add    $0x1c,%esp
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	57                   	push   %edi
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	83 ec 1c             	sub    $0x1c,%esp
  801d08:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d0b:	89 3c 24             	mov    %edi,(%esp)
  801d0e:	e8 0d f5 ff ff       	call   801220 <fd2data>
  801d13:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d15:	be 00 00 00 00       	mov    $0x0,%esi
  801d1a:	eb 3d                	jmp    801d59 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d1c:	85 f6                	test   %esi,%esi
  801d1e:	74 04                	je     801d24 <devpipe_read+0x25>
				return i;
  801d20:	89 f0                	mov    %esi,%eax
  801d22:	eb 43                	jmp    801d67 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d24:	89 da                	mov    %ebx,%edx
  801d26:	89 f8                	mov    %edi,%eax
  801d28:	e8 f1 fe ff ff       	call   801c1e <_pipeisclosed>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	75 31                	jne    801d62 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d31:	e8 4e f2 ff ff       	call   800f84 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d36:	8b 03                	mov    (%ebx),%eax
  801d38:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d3b:	74 df                	je     801d1c <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3d:	99                   	cltd   
  801d3e:	c1 ea 1b             	shr    $0x1b,%edx
  801d41:	01 d0                	add    %edx,%eax
  801d43:	83 e0 1f             	and    $0x1f,%eax
  801d46:	29 d0                	sub    %edx,%eax
  801d48:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d50:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d53:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d56:	83 c6 01             	add    $0x1,%esi
  801d59:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5c:	75 d8                	jne    801d36 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5e:	89 f0                	mov    %esi,%eax
  801d60:	eb 05                	jmp    801d67 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d67:	83 c4 1c             	add    $0x1c,%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    

00801d6f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7a:	89 04 24             	mov    %eax,(%esp)
  801d7d:	e8 b5 f4 ff ff       	call   801237 <fd_alloc>
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	85 d2                	test   %edx,%edx
  801d86:	0f 88 4d 01 00 00    	js     801ed9 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d93:	00 
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da2:	e8 fc f1 ff ff       	call   800fa3 <sys_page_alloc>
  801da7:	89 c2                	mov    %eax,%edx
  801da9:	85 d2                	test   %edx,%edx
  801dab:	0f 88 28 01 00 00    	js     801ed9 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801db1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 7b f4 ff ff       	call   801237 <fd_alloc>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 fe 00 00 00    	js     801ec4 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dcd:	00 
  801dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddc:	e8 c2 f1 ff ff       	call   800fa3 <sys_page_alloc>
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	85 c0                	test   %eax,%eax
  801de5:	0f 88 d9 00 00 00    	js     801ec4 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	89 04 24             	mov    %eax,(%esp)
  801df1:	e8 2a f4 ff ff       	call   801220 <fd2data>
  801df6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dff:	00 
  801e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0b:	e8 93 f1 ff ff       	call   800fa3 <sys_page_alloc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 97 00 00 00    	js     801eb1 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1d:	89 04 24             	mov    %eax,(%esp)
  801e20:	e8 fb f3 ff ff       	call   801220 <fd2data>
  801e25:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e2c:	00 
  801e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e31:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e38:	00 
  801e39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e44:	e8 ae f1 ff ff       	call   800ff7 <sys_page_map>
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 52                	js     801ea1 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e58:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e72:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 8c f3 ff ff       	call   801210 <fd2num>
  801e84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e87:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 7c f3 ff ff       	call   801210 <fd2num>
  801e94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e97:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9f:	eb 38                	jmp    801ed9 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801ea1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eac:	e8 99 f1 ff ff       	call   80104a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801eb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebf:	e8 86 f1 ff ff       	call   80104a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed2:	e8 73 f1 ff ff       	call   80104a <sys_page_unmap>
  801ed7:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801ed9:	83 c4 30             	add    $0x30,%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	89 04 24             	mov    %eax,(%esp)
  801ef3:	e8 8e f3 ff ff       	call   801286 <fd_lookup>
  801ef8:	89 c2                	mov    %eax,%edx
  801efa:	85 d2                	test   %edx,%edx
  801efc:	78 15                	js     801f13 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 17 f3 ff ff       	call   801220 <fd2data>
	return _pipeisclosed(fd, p);
  801f09:	89 c2                	mov    %eax,%edx
  801f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0e:	e8 0b fd ff ff       	call   801c1e <_pipeisclosed>
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    
  801f15:	66 90                	xchg   %ax,%ax
  801f17:	66 90                	xchg   %ax,%ax
  801f19:	66 90                	xchg   %ax,%ax
  801f1b:	66 90                	xchg   %ax,%ax
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

00801f20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	83 ec 10             	sub    $0x10,%esp
  801f28:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801f31:	85 c0                	test   %eax,%eax
  801f33:	75 0e                	jne    801f43 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801f35:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801f3c:	e8 78 f2 ff ff       	call   8011b9 <sys_ipc_recv>
  801f41:	eb 08                	jmp    801f4b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 6e f2 ff ff       	call   8011b9 <sys_ipc_recv>
	if(r == 0){
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi
  801f50:	75 1e                	jne    801f70 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801f52:	85 f6                	test   %esi,%esi
  801f54:	74 0a                	je     801f60 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801f56:	a1 04 44 80 00       	mov    0x804404,%eax
  801f5b:	8b 40 74             	mov    0x74(%eax),%eax
  801f5e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 2c                	je     801f90 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801f64:	a1 04 44 80 00       	mov    0x804404,%eax
  801f69:	8b 40 78             	mov    0x78(%eax),%eax
  801f6c:	89 03                	mov    %eax,(%ebx)
  801f6e:	eb 20                	jmp    801f90 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801f70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f74:	c7 44 24 08 58 28 80 	movl   $0x802858,0x8(%esp)
  801f7b:	00 
  801f7c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801f83:	00 
  801f84:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  801f8b:	e8 92 e3 ff ff       	call   800322 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801f90:	a1 04 44 80 00       	mov    0x804404,%eax
  801f95:	8b 50 70             	mov    0x70(%eax),%edx
  801f98:	85 d2                	test   %edx,%edx
  801f9a:	75 13                	jne    801faf <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  801f9c:	8b 40 48             	mov    0x48(%eax),%eax
  801f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa3:	c7 04 24 88 28 80 00 	movl   $0x802888,(%esp)
  801faa:	e8 6c e4 ff ff       	call   80041b <cprintf>
	return thisenv->env_ipc_value;
  801faf:	a1 04 44 80 00       	mov    0x804404,%eax
  801fb4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	5b                   	pop    %ebx
  801fbb:	5e                   	pop    %esi
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  801fcd:	85 f6                	test   %esi,%esi
  801fcf:	75 22                	jne    801ff3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801fd1:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801fdf:	ee 
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe7:	89 3c 24             	mov    %edi,(%esp)
  801fea:	e8 a7 f1 ff ff       	call   801196 <sys_ipc_try_send>
  801fef:	89 c3                	mov    %eax,%ebx
  801ff1:	eb 1c                	jmp    80200f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801ff3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffa:	89 74 24 08          	mov    %esi,0x8(%esp)
  801ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802001:	89 44 24 04          	mov    %eax,0x4(%esp)
  802005:	89 3c 24             	mov    %edi,(%esp)
  802008:	e8 89 f1 ff ff       	call   801196 <sys_ipc_try_send>
  80200d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80200f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802012:	74 3e                	je     802052 <ipc_send+0x94>
  802014:	89 d8                	mov    %ebx,%eax
  802016:	c1 e8 1f             	shr    $0x1f,%eax
  802019:	84 c0                	test   %al,%al
  80201b:	74 35                	je     802052 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80201d:	e8 43 ef ff ff       	call   800f65 <sys_getenvid>
  802022:	89 44 24 04          	mov    %eax,0x4(%esp)
  802026:	c7 04 24 de 28 80 00 	movl   $0x8028de,(%esp)
  80202d:	e8 e9 e3 ff ff       	call   80041b <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802032:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802036:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
  80203d:	00 
  80203e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  802045:	00 
  802046:	c7 04 24 d4 28 80 00 	movl   $0x8028d4,(%esp)
  80204d:	e8 d0 e2 ff ff       	call   800322 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  802052:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802055:	75 0e                	jne    802065 <ipc_send+0xa7>
			sys_yield();
  802057:	e8 28 ef ff ff       	call   800f84 <sys_yield>
		else break;
	}
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	e9 68 ff ff ff       	jmp    801fcd <ipc_send+0xf>
	
}
  802065:	83 c4 1c             	add    $0x1c,%esp
  802068:	5b                   	pop    %ebx
  802069:	5e                   	pop    %esi
  80206a:	5f                   	pop    %edi
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802078:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80207b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802081:	8b 52 50             	mov    0x50(%edx),%edx
  802084:	39 ca                	cmp    %ecx,%edx
  802086:	75 0d                	jne    802095 <ipc_find_env+0x28>
			return envs[i].env_id;
  802088:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80208b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802090:	8b 40 40             	mov    0x40(%eax),%eax
  802093:	eb 0e                	jmp    8020a3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802095:	83 c0 01             	add    $0x1,%eax
  802098:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209d:	75 d9                	jne    802078 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80209f:	66 b8 00 00          	mov    $0x0,%ax
}
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    

008020a5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	c1 e8 16             	shr    $0x16,%eax
  8020b0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bc:	f6 c1 01             	test   $0x1,%cl
  8020bf:	74 1d                	je     8020de <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c1:	c1 ea 0c             	shr    $0xc,%edx
  8020c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020cb:	f6 c2 01             	test   $0x1,%dl
  8020ce:	74 0e                	je     8020de <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d0:	c1 ea 0c             	shr    $0xc,%edx
  8020d3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020da:	ef 
  8020db:	0f b7 c0             	movzwl %ax,%eax
}
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8020ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8020ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8020f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020fc:	89 ea                	mov    %ebp,%edx
  8020fe:	89 0c 24             	mov    %ecx,(%esp)
  802101:	75 2d                	jne    802130 <__udivdi3+0x50>
  802103:	39 e9                	cmp    %ebp,%ecx
  802105:	77 61                	ja     802168 <__udivdi3+0x88>
  802107:	85 c9                	test   %ecx,%ecx
  802109:	89 ce                	mov    %ecx,%esi
  80210b:	75 0b                	jne    802118 <__udivdi3+0x38>
  80210d:	b8 01 00 00 00       	mov    $0x1,%eax
  802112:	31 d2                	xor    %edx,%edx
  802114:	f7 f1                	div    %ecx
  802116:	89 c6                	mov    %eax,%esi
  802118:	31 d2                	xor    %edx,%edx
  80211a:	89 e8                	mov    %ebp,%eax
  80211c:	f7 f6                	div    %esi
  80211e:	89 c5                	mov    %eax,%ebp
  802120:	89 f8                	mov    %edi,%eax
  802122:	f7 f6                	div    %esi
  802124:	89 ea                	mov    %ebp,%edx
  802126:	83 c4 0c             	add    $0xc,%esp
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    
  80212d:	8d 76 00             	lea    0x0(%esi),%esi
  802130:	39 e8                	cmp    %ebp,%eax
  802132:	77 24                	ja     802158 <__udivdi3+0x78>
  802134:	0f bd e8             	bsr    %eax,%ebp
  802137:	83 f5 1f             	xor    $0x1f,%ebp
  80213a:	75 3c                	jne    802178 <__udivdi3+0x98>
  80213c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802140:	39 34 24             	cmp    %esi,(%esp)
  802143:	0f 86 9f 00 00 00    	jbe    8021e8 <__udivdi3+0x108>
  802149:	39 d0                	cmp    %edx,%eax
  80214b:	0f 82 97 00 00 00    	jb     8021e8 <__udivdi3+0x108>
  802151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802158:	31 d2                	xor    %edx,%edx
  80215a:	31 c0                	xor    %eax,%eax
  80215c:	83 c4 0c             	add    $0xc,%esp
  80215f:	5e                   	pop    %esi
  802160:	5f                   	pop    %edi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    
  802163:	90                   	nop
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	89 f8                	mov    %edi,%eax
  80216a:	f7 f1                	div    %ecx
  80216c:	31 d2                	xor    %edx,%edx
  80216e:	83 c4 0c             	add    $0xc,%esp
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	8b 3c 24             	mov    (%esp),%edi
  80217d:	d3 e0                	shl    %cl,%eax
  80217f:	89 c6                	mov    %eax,%esi
  802181:	b8 20 00 00 00       	mov    $0x20,%eax
  802186:	29 e8                	sub    %ebp,%eax
  802188:	89 c1                	mov    %eax,%ecx
  80218a:	d3 ef                	shr    %cl,%edi
  80218c:	89 e9                	mov    %ebp,%ecx
  80218e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802192:	8b 3c 24             	mov    (%esp),%edi
  802195:	09 74 24 08          	or     %esi,0x8(%esp)
  802199:	89 d6                	mov    %edx,%esi
  80219b:	d3 e7                	shl    %cl,%edi
  80219d:	89 c1                	mov    %eax,%ecx
  80219f:	89 3c 24             	mov    %edi,(%esp)
  8021a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8021a6:	d3 ee                	shr    %cl,%esi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	d3 e2                	shl    %cl,%edx
  8021ac:	89 c1                	mov    %eax,%ecx
  8021ae:	d3 ef                	shr    %cl,%edi
  8021b0:	09 d7                	or     %edx,%edi
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	89 f8                	mov    %edi,%eax
  8021b6:	f7 74 24 08          	divl   0x8(%esp)
  8021ba:	89 d6                	mov    %edx,%esi
  8021bc:	89 c7                	mov    %eax,%edi
  8021be:	f7 24 24             	mull   (%esp)
  8021c1:	39 d6                	cmp    %edx,%esi
  8021c3:	89 14 24             	mov    %edx,(%esp)
  8021c6:	72 30                	jb     8021f8 <__udivdi3+0x118>
  8021c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021cc:	89 e9                	mov    %ebp,%ecx
  8021ce:	d3 e2                	shl    %cl,%edx
  8021d0:	39 c2                	cmp    %eax,%edx
  8021d2:	73 05                	jae    8021d9 <__udivdi3+0xf9>
  8021d4:	3b 34 24             	cmp    (%esp),%esi
  8021d7:	74 1f                	je     8021f8 <__udivdi3+0x118>
  8021d9:	89 f8                	mov    %edi,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	e9 7a ff ff ff       	jmp    80215c <__udivdi3+0x7c>
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ef:	e9 68 ff ff ff       	jmp    80215c <__udivdi3+0x7c>
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	83 c4 0c             	add    $0xc,%esp
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	83 ec 14             	sub    $0x14,%esp
  802216:	8b 44 24 28          	mov    0x28(%esp),%eax
  80221a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80221e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802222:	89 c7                	mov    %eax,%edi
  802224:	89 44 24 04          	mov    %eax,0x4(%esp)
  802228:	8b 44 24 30          	mov    0x30(%esp),%eax
  80222c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802230:	89 34 24             	mov    %esi,(%esp)
  802233:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802237:	85 c0                	test   %eax,%eax
  802239:	89 c2                	mov    %eax,%edx
  80223b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80223f:	75 17                	jne    802258 <__umoddi3+0x48>
  802241:	39 fe                	cmp    %edi,%esi
  802243:	76 4b                	jbe    802290 <__umoddi3+0x80>
  802245:	89 c8                	mov    %ecx,%eax
  802247:	89 fa                	mov    %edi,%edx
  802249:	f7 f6                	div    %esi
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	83 c4 14             	add    $0x14,%esp
  802252:	5e                   	pop    %esi
  802253:	5f                   	pop    %edi
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    
  802256:	66 90                	xchg   %ax,%ax
  802258:	39 f8                	cmp    %edi,%eax
  80225a:	77 54                	ja     8022b0 <__umoddi3+0xa0>
  80225c:	0f bd e8             	bsr    %eax,%ebp
  80225f:	83 f5 1f             	xor    $0x1f,%ebp
  802262:	75 5c                	jne    8022c0 <__umoddi3+0xb0>
  802264:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802268:	39 3c 24             	cmp    %edi,(%esp)
  80226b:	0f 87 e7 00 00 00    	ja     802358 <__umoddi3+0x148>
  802271:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802275:	29 f1                	sub    %esi,%ecx
  802277:	19 c7                	sbb    %eax,%edi
  802279:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802281:	8b 44 24 08          	mov    0x8(%esp),%eax
  802285:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802289:	83 c4 14             	add    $0x14,%esp
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    
  802290:	85 f6                	test   %esi,%esi
  802292:	89 f5                	mov    %esi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f6                	div    %esi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022a5:	31 d2                	xor    %edx,%edx
  8022a7:	f7 f5                	div    %ebp
  8022a9:	89 c8                	mov    %ecx,%eax
  8022ab:	f7 f5                	div    %ebp
  8022ad:	eb 9c                	jmp    80224b <__umoddi3+0x3b>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 fa                	mov    %edi,%edx
  8022b4:	83 c4 14             	add    $0x14,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 04 24             	mov    (%esp),%eax
  8022c3:	be 20 00 00 00       	mov    $0x20,%esi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ee                	sub    %ebp,%esi
  8022cc:	d3 e2                	shl    %cl,%edx
  8022ce:	89 f1                	mov    %esi,%ecx
  8022d0:	d3 e8                	shr    %cl,%eax
  8022d2:	89 e9                	mov    %ebp,%ecx
  8022d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d8:	8b 04 24             	mov    (%esp),%eax
  8022db:	09 54 24 04          	or     %edx,0x4(%esp)
  8022df:	89 fa                	mov    %edi,%edx
  8022e1:	d3 e0                	shl    %cl,%eax
  8022e3:	89 f1                	mov    %esi,%ecx
  8022e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022ed:	d3 ea                	shr    %cl,%edx
  8022ef:	89 e9                	mov    %ebp,%ecx
  8022f1:	d3 e7                	shl    %cl,%edi
  8022f3:	89 f1                	mov    %esi,%ecx
  8022f5:	d3 e8                	shr    %cl,%eax
  8022f7:	89 e9                	mov    %ebp,%ecx
  8022f9:	09 f8                	or     %edi,%eax
  8022fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8022ff:	f7 74 24 04          	divl   0x4(%esp)
  802303:	d3 e7                	shl    %cl,%edi
  802305:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802309:	89 d7                	mov    %edx,%edi
  80230b:	f7 64 24 08          	mull   0x8(%esp)
  80230f:	39 d7                	cmp    %edx,%edi
  802311:	89 c1                	mov    %eax,%ecx
  802313:	89 14 24             	mov    %edx,(%esp)
  802316:	72 2c                	jb     802344 <__umoddi3+0x134>
  802318:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80231c:	72 22                	jb     802340 <__umoddi3+0x130>
  80231e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802322:	29 c8                	sub    %ecx,%eax
  802324:	19 d7                	sbb    %edx,%edi
  802326:	89 e9                	mov    %ebp,%ecx
  802328:	89 fa                	mov    %edi,%edx
  80232a:	d3 e8                	shr    %cl,%eax
  80232c:	89 f1                	mov    %esi,%ecx
  80232e:	d3 e2                	shl    %cl,%edx
  802330:	89 e9                	mov    %ebp,%ecx
  802332:	d3 ef                	shr    %cl,%edi
  802334:	09 d0                	or     %edx,%eax
  802336:	89 fa                	mov    %edi,%edx
  802338:	83 c4 14             	add    $0x14,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
  802340:	39 d7                	cmp    %edx,%edi
  802342:	75 da                	jne    80231e <__umoddi3+0x10e>
  802344:	8b 14 24             	mov    (%esp),%edx
  802347:	89 c1                	mov    %eax,%ecx
  802349:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80234d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802351:	eb cb                	jmp    80231e <__umoddi3+0x10e>
  802353:	90                   	nop
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80235c:	0f 82 0f ff ff ff    	jb     802271 <__umoddi3+0x61>
  802362:	e9 1a ff ff ff       	jmp    802281 <__umoddi3+0x71>
