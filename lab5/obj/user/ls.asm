
obj/user/ls.debug：     文件格式 elf32-i386


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
  80002c:	e8 fa 02 00 00       	call   80032b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80004e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800055:	74 23                	je     80007a <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800057:	89 f0                	mov    %esi,%eax
  800059:	3c 01                	cmp    $0x1,%al
  80005b:	19 c0                	sbb    %eax,%eax
  80005d:	83 e0 c9             	and    $0xffffffc9,%eax
  800060:	83 c0 64             	add    $0x64,%eax
  800063:	89 44 24 08          	mov    %eax,0x8(%esp)
  800067:	8b 45 10             	mov    0x10(%ebp),%eax
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 02 26 80 00 	movl   $0x802602,(%esp)
  800075:	e8 c7 1b 00 00       	call   801c41 <printf>
	if(prefix) {
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	74 38                	je     8000b6 <ls1+0x76>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80007e:	b8 68 26 80 00       	mov    $0x802668,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800083:	80 3b 00             	cmpb   $0x0,(%ebx)
  800086:	74 1a                	je     8000a2 <ls1+0x62>
  800088:	89 1c 24             	mov    %ebx,(%esp)
  80008b:	e8 30 0a 00 00       	call   800ac0 <strlen>
  800090:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
			sep = "/";
  800095:	b8 00 26 80 00       	mov    $0x802600,%eax
  80009a:	ba 68 26 80 00       	mov    $0x802668,%edx
  80009f:	0f 44 c2             	cmove  %edx,%eax
		else
			sep = "";
		printf("%s%s", prefix, sep);
  8000a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	c7 04 24 0b 26 80 00 	movl   $0x80260b,(%esp)
  8000b1:	e8 8b 1b 00 00       	call   801c41 <printf>
	}
	printf("%s", name);
  8000b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 ba 2a 80 00 	movl   $0x802aba,(%esp)
  8000c4:	e8 78 1b 00 00       	call   801c41 <printf>
	if(flag['F'] && isdir)
  8000c9:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000d0:	74 12                	je     8000e4 <ls1+0xa4>
  8000d2:	89 f0                	mov    %esi,%eax
  8000d4:	84 c0                	test   %al,%al
  8000d6:	74 0c                	je     8000e4 <ls1+0xa4>
		printf("/");
  8000d8:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  8000df:	e8 5d 1b 00 00       	call   801c41 <printf>
	printf("\n");
  8000e4:	c7 04 24 67 26 80 00 	movl   $0x802667,(%esp)
  8000eb:	e8 51 1b 00 00       	call   801c41 <printf>
}
  8000f0:	83 c4 10             	add    $0x10,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  800103:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800106:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010d:	00 
  80010e:	89 3c 24             	mov    %edi,(%esp)
  800111:	e8 7b 19 00 00       	call   801a91 <open>
  800116:	89 c3                	mov    %eax,%ebx
  800118:	85 c0                	test   %eax,%eax
  80011a:	78 08                	js     800124 <lsdir+0x2d>
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80011c:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800122:	eb 57                	jmp    80017b <lsdir+0x84>
{
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
  800124:	89 44 24 10          	mov    %eax,0x10(%esp)
  800128:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80012c:	c7 44 24 08 10 26 80 	movl   $0x802610,0x8(%esp)
  800133:	00 
  800134:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80013b:	00 
  80013c:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  800143:	e8 3f 02 00 00       	call   800387 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800148:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80014f:	74 2a                	je     80017b <lsdir+0x84>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800151:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800155:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800166:	0f 94 c0             	sete   %al
  800169:	0f b6 c0             	movzbl %al,%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 c5 fe ff ff       	call   800040 <ls1>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80017b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  800182:	00 
  800183:	89 74 24 04          	mov    %esi,0x4(%esp)
  800187:	89 1c 24             	mov    %ebx,(%esp)
  80018a:	e8 e8 14 00 00       	call   801677 <readn>
  80018f:	3d 00 01 00 00       	cmp    $0x100,%eax
  800194:	74 b2                	je     800148 <lsdir+0x51>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  800196:	85 c0                	test   %eax,%eax
  800198:	7e 20                	jle    8001ba <lsdir+0xc3>
		panic("short read in directory %s", path);
  80019a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80019e:	c7 44 24 08 26 26 80 	movl   $0x802626,0x8(%esp)
  8001a5:	00 
  8001a6:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001ad:	00 
  8001ae:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  8001b5:	e8 cd 01 00 00       	call   800387 <_panic>
	if (n < 0)
  8001ba:	85 c0                	test   %eax,%eax
  8001bc:	79 24                	jns    8001e2 <lsdir+0xeb>
		panic("error reading directory %s: %e", path, n);
  8001be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001c6:	c7 44 24 08 6c 26 80 	movl   $0x80266c,0x8(%esp)
  8001cd:	00 
  8001ce:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d5:	00 
  8001d6:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  8001dd:	e8 a5 01 00 00       	call   800387 <_panic>
}
  8001e2:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	53                   	push   %ebx
  8001f1:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001fa:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	89 1c 24             	mov    %ebx,(%esp)
  800207:	e8 6f 16 00 00       	call   80187b <stat>
  80020c:	85 c0                	test   %eax,%eax
  80020e:	79 24                	jns    800234 <ls+0x47>
		panic("stat %s: %e", path, r);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800218:	c7 44 24 08 41 26 80 	movl   $0x802641,0x8(%esp)
  80021f:	00 
  800220:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800227:	00 
  800228:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  80022f:	e8 53 01 00 00       	call   800387 <_panic>
	if (st.st_isdir && !flag['d'])
  800234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800237:	85 c0                	test   %eax,%eax
  800239:	74 1a                	je     800255 <ls+0x68>
  80023b:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800242:	75 11                	jne    800255 <ls+0x68>
		lsdir(path, prefix);
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	89 1c 24             	mov    %ebx,(%esp)
  80024e:	e8 a4 fe ff ff       	call   8000f7 <lsdir>
  800253:	eb 23                	jmp    800278 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800255:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800259:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800260:	85 c0                	test   %eax,%eax
  800262:	0f 95 c0             	setne  %al
  800265:	0f b6 c0             	movzbl %al,%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800273:	e8 c8 fd ff ff       	call   800040 <ls1>
}
  800278:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <usage>:
	printf("\n");
}

void
usage(void)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800287:	c7 04 24 4d 26 80 00 	movl   $0x80264d,(%esp)
  80028e:	e8 ae 19 00 00       	call   801c41 <printf>
	exit();
  800293:	e8 db 00 00 00       	call   800373 <exit>
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <umain>:

void
umain(int argc, char **argv)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 20             	sub    $0x20,%esp
  8002a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a5:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b0:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 c0 0e 00 00       	call   80117b <argstart>
	while ((i = argnext(&args)) >= 0)
  8002bb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002be:	eb 1e                	jmp    8002de <umain+0x44>
		switch (i) {
  8002c0:	83 f8 64             	cmp    $0x64,%eax
  8002c3:	74 0a                	je     8002cf <umain+0x35>
  8002c5:	83 f8 6c             	cmp    $0x6c,%eax
  8002c8:	74 05                	je     8002cf <umain+0x35>
  8002ca:	83 f8 46             	cmp    $0x46,%eax
  8002cd:	75 0a                	jne    8002d9 <umain+0x3f>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002cf:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  8002d6:	01 
			break;
  8002d7:	eb 05                	jmp    8002de <umain+0x44>
		default:
			usage();
  8002d9:	e8 a3 ff ff ff       	call   800281 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002de:	89 1c 24             	mov    %ebx,(%esp)
  8002e1:	e8 cd 0e 00 00       	call   8011b3 <argnext>
  8002e6:	85 c0                	test   %eax,%eax
  8002e8:	79 d6                	jns    8002c0 <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002ea:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ee:	74 07                	je     8002f7 <umain+0x5d>
  8002f0:	bb 01 00 00 00       	mov    $0x1,%ebx
  8002f5:	eb 28                	jmp    80031f <umain+0x85>
		ls("/", "");
  8002f7:	c7 44 24 04 68 26 80 	movl   $0x802668,0x4(%esp)
  8002fe:	00 
  8002ff:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  800306:	e8 e2 fe ff ff       	call   8001ed <ls>
  80030b:	eb 17                	jmp    800324 <umain+0x8a>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  80030d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	e8 d1 fe ff ff       	call   8001ed <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031c:	83 c3 01             	add    $0x1,%ebx
  80031f:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800322:	7c e9                	jl     80030d <umain+0x73>
			ls(argv[i], argv[i]);
	}
}
  800324:	83 c4 20             	add    $0x20,%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 10             	sub    $0x10,%esp
  800333:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800336:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800339:	e8 97 0b 00 00       	call   800ed5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80033e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800343:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800346:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80034b:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800350:	85 db                	test   %ebx,%ebx
  800352:	7e 07                	jle    80035b <libmain+0x30>
		binaryname = argv[0];
  800354:	8b 06                	mov    (%esi),%eax
  800356:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80035b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80035f:	89 1c 24             	mov    %ebx,(%esp)
  800362:	e8 33 ff ff ff       	call   80029a <umain>

	// exit gracefully
	exit();
  800367:	e8 07 00 00 00       	call   800373 <exit>
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800380:	e8 fe 0a 00 00       	call   800e83 <sys_env_destroy>
}
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80038f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800392:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800398:	e8 38 0b 00 00       	call   800ed5 <sys_getenvid>
  80039d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ab:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b3:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  8003ba:	e8 c1 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	e8 51 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003ce:	c7 04 24 67 26 80 00 	movl   $0x802667,(%esp)
  8003d5:	e8 a6 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003da:	cc                   	int3   
  8003db:	eb fd                	jmp    8003da <_panic+0x53>

008003dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	53                   	push   %ebx
  8003e1:	83 ec 14             	sub    $0x14,%esp
  8003e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e7:	8b 13                	mov    (%ebx),%edx
  8003e9:	8d 42 01             	lea    0x1(%edx),%eax
  8003ec:	89 03                	mov    %eax,(%ebx)
  8003ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fa:	75 19                	jne    800415 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003fc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800403:	00 
  800404:	8d 43 08             	lea    0x8(%ebx),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 37 0a 00 00       	call   800e46 <sys_cputs>
		b->idx = 0;
  80040f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800415:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 dd 03 80 00 	movl   $0x8003dd,(%esp)
  80045b:	e8 74 01 00 00       	call   8005d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 ce 09 00 00       	call   800e46 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
  80049a:	66 90                	xchg   %ax,%ax
  80049c:	66 90                	xchg   %ax,%ax
  80049e:	66 90                	xchg   %ax,%ax

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004cd:	39 d9                	cmp    %ebx,%ecx
  8004cf:	72 05                	jb     8004d6 <printnum+0x36>
  8004d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004d4:	77 69                	ja     80053f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 4c 1e 00 00       	call   802360 <__udivdi3>
  800514:	89 d9                	mov    %ebx,%ecx
  800516:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80051a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	89 fa                	mov    %edi,%edx
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	e8 71 ff ff ff       	call   8004a0 <printnum>
  80052f:	eb 1b                	jmp    80054c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800531:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800535:	8b 45 18             	mov    0x18(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff d3                	call   *%ebx
  80053d:	eb 03                	jmp    800542 <printnum+0xa2>
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	7f e8                	jg     800531 <printnum+0x91>
  800549:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80054c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800550:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 1c 1f 00 00       	call   802490 <__umoddi3>
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	0f be 80 bb 26 80 00 	movsbl 0x8026bb(%eax),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800585:	ff d0                	call   *%eax
}
  800587:	83 c4 3c             	add    $0x3c,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800595:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	3b 50 04             	cmp    0x4(%eax),%edx
  80059e:	73 0a                	jae    8005aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8005a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005a3:	89 08                	mov    %ecx,(%eax)
  8005a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a8:	88 02                	mov    %al,(%edx)
}
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	e8 02 00 00 00       	call   8005d4 <vprintfmt>
	va_end(ap);
}
  8005d2:	c9                   	leave  
  8005d3:	c3                   	ret    

008005d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	57                   	push   %edi
  8005d8:	56                   	push   %esi
  8005d9:	53                   	push   %ebx
  8005da:	83 ec 3c             	sub    $0x3c,%esp
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005e6:	eb 11                	jmp    8005f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	0f 84 48 04 00 00    	je     800a38 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	83 f8 25             	cmp    $0x25,%eax
  800603:	75 e3                	jne    8005e8 <vprintfmt+0x14>
  800605:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800609:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800610:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800617:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	eb 1f                	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800628:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80062c:	eb 16                	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800631:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800635:	eb 0d                	jmp    800644 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800637:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8d 47 01             	lea    0x1(%edi),%eax
  800647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80064a:	0f b6 17             	movzbl (%edi),%edx
  80064d:	0f b6 c2             	movzbl %dl,%eax
  800650:	83 ea 23             	sub    $0x23,%edx
  800653:	80 fa 55             	cmp    $0x55,%dl
  800656:	0f 87 bf 03 00 00    	ja     800a1b <vprintfmt+0x447>
  80065c:	0f b6 d2             	movzbl %dl,%edx
  80065f:	ff 24 95 00 28 80 00 	jmp    *0x802800(,%edx,4)
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
  80066e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800671:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800674:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800678:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80067b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80067e:	83 f9 09             	cmp    $0x9,%ecx
  800681:	77 3c                	ja     8006bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800683:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800686:	eb e9                	jmp    800671 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069c:	eb 27                	jmp    8006c5 <vprintfmt+0xf1>
  80069e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a8:	0f 49 c2             	cmovns %edx,%eax
  8006ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b1:	eb 91                	jmp    800644 <vprintfmt+0x70>
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006bd:	eb 85                	jmp    800644 <vprintfmt+0x70>
  8006bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	0f 89 75 ff ff ff    	jns    800644 <vprintfmt+0x70>
  8006cf:	e9 63 ff ff ff       	jmp    800637 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006da:	e9 65 ff ff ff       	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f4:	e9 00 ff ff ff       	jmp    8005f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	99                   	cltd   
  800703:	31 d0                	xor    %edx,%eax
  800705:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800707:	83 f8 0f             	cmp    $0xf,%eax
  80070a:	7f 0b                	jg     800717 <vprintfmt+0x143>
  80070c:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	75 20                	jne    800737 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800717:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071b:	c7 44 24 08 d3 26 80 	movl   $0x8026d3,0x8(%esp)
  800722:	00 
  800723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800727:	89 34 24             	mov    %esi,(%esp)
  80072a:	e8 7d fe ff ff       	call   8005ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800732:	e9 c2 fe ff ff       	jmp    8005f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800737:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073b:	c7 44 24 08 ba 2a 80 	movl   $0x802aba,0x8(%esp)
  800742:	00 
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	89 34 24             	mov    %esi,(%esp)
  80074a:	e8 5d fe ff ff       	call   8005ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800752:	e9 a2 fe ff ff       	jmp    8005f9 <vprintfmt+0x25>
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800760:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800767:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800769:	85 ff                	test   %edi,%edi
  80076b:	b8 cc 26 80 00       	mov    $0x8026cc,%eax
  800770:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800773:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800777:	0f 84 92 00 00 00    	je     80080f <vprintfmt+0x23b>
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	0f 8e 98 00 00 00    	jle    80081d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800785:	89 54 24 04          	mov    %edx,0x4(%esp)
  800789:	89 3c 24             	mov    %edi,(%esp)
  80078c:	e8 47 03 00 00       	call   800ad8 <strnlen>
  800791:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800794:	29 c1                	sub    %eax,%ecx
  800796:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800799:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80079d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a5:	eb 0f                	jmp    8007b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	83 ef 01             	sub    $0x1,%edi
  8007b6:	85 ff                	test   %edi,%edi
  8007b8:	7f ed                	jg     8007a7 <vprintfmt+0x1d3>
  8007ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	0f 49 c1             	cmovns %ecx,%eax
  8007ca:	29 c1                	sub    %eax,%ecx
  8007cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007d5:	89 cb                	mov    %ecx,%ebx
  8007d7:	eb 50                	jmp    800829 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007dd:	74 1e                	je     8007fd <vprintfmt+0x229>
  8007df:	0f be d2             	movsbl %dl,%edx
  8007e2:	83 ea 20             	sub    $0x20,%edx
  8007e5:	83 fa 5e             	cmp    $0x5e,%edx
  8007e8:	76 13                	jbe    8007fd <vprintfmt+0x229>
					putch('?', putdat);
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f8:	ff 55 08             	call   *0x8(%ebp)
  8007fb:	eb 0d                	jmp    80080a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8007fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800800:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080a:	83 eb 01             	sub    $0x1,%ebx
  80080d:	eb 1a                	jmp    800829 <vprintfmt+0x255>
  80080f:	89 75 08             	mov    %esi,0x8(%ebp)
  800812:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800815:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800818:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80081b:	eb 0c                	jmp    800829 <vprintfmt+0x255>
  80081d:	89 75 08             	mov    %esi,0x8(%ebp)
  800820:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800823:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800826:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800829:	83 c7 01             	add    $0x1,%edi
  80082c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800830:	0f be c2             	movsbl %dl,%eax
  800833:	85 c0                	test   %eax,%eax
  800835:	74 25                	je     80085c <vprintfmt+0x288>
  800837:	85 f6                	test   %esi,%esi
  800839:	78 9e                	js     8007d9 <vprintfmt+0x205>
  80083b:	83 ee 01             	sub    $0x1,%esi
  80083e:	79 99                	jns    8007d9 <vprintfmt+0x205>
  800840:	89 df                	mov    %ebx,%edi
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800848:	eb 1a                	jmp    800864 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80084a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800855:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800857:	83 ef 01             	sub    $0x1,%edi
  80085a:	eb 08                	jmp    800864 <vprintfmt+0x290>
  80085c:	89 df                	mov    %ebx,%edi
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800864:	85 ff                	test   %edi,%edi
  800866:	7f e2                	jg     80084a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086b:	e9 89 fd ff ff       	jmp    8005f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800870:	83 f9 01             	cmp    $0x1,%ecx
  800873:	7e 19                	jle    80088e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 50 04             	mov    0x4(%eax),%edx
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800880:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 40 08             	lea    0x8(%eax),%eax
  800889:	89 45 14             	mov    %eax,0x14(%ebp)
  80088c:	eb 38                	jmp    8008c6 <vprintfmt+0x2f2>
	else if (lflag)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 1b                	je     8008ad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8b 00                	mov    (%eax),%eax
  800897:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089a:	89 c1                	mov    %eax,%ecx
  80089c:	c1 f9 1f             	sar    $0x1f,%ecx
  80089f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8d 40 04             	lea    0x4(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ab:	eb 19                	jmp    8008c6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8b 00                	mov    (%eax),%eax
  8008b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b5:	89 c1                	mov    %eax,%ecx
  8008b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008cc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d5:	0f 89 04 01 00 00    	jns    8009df <vprintfmt+0x40b>
				putch('-', putdat);
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008ee:	f7 da                	neg    %edx
  8008f0:	83 d1 00             	adc    $0x0,%ecx
  8008f3:	f7 d9                	neg    %ecx
  8008f5:	e9 e5 00 00 00       	jmp    8009df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008fa:	83 f9 01             	cmp    $0x1,%ecx
  8008fd:	7e 10                	jle    80090f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8b 10                	mov    (%eax),%edx
  800904:	8b 48 04             	mov    0x4(%eax),%ecx
  800907:	8d 40 08             	lea    0x8(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
  80090d:	eb 26                	jmp    800935 <vprintfmt+0x361>
	else if (lflag)
  80090f:	85 c9                	test   %ecx,%ecx
  800911:	74 12                	je     800925 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8b 10                	mov    (%eax),%edx
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091d:	8d 40 04             	lea    0x4(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
  800923:	eb 10                	jmp    800935 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800935:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80093a:	e9 a0 00 00 00       	jmp    8009df <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80093f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800943:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80094a:	ff d6                	call   *%esi
			putch('X', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800957:	ff d6                	call   *%esi
			putch('X', putdat);
  800959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800964:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800969:	e9 8b fc ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80096e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800972:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800979:	ff d6                	call   *%esi
			putch('x', putdat);
  80097b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800986:	ff d6                	call   *%esi
			num = (unsigned long long)
  800988:	8b 45 14             	mov    0x14(%ebp),%eax
  80098b:	8b 10                	mov    (%eax),%edx
  80098d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800992:	8d 40 04             	lea    0x4(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800998:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80099d:	eb 40                	jmp    8009df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099f:	83 f9 01             	cmp    $0x1,%ecx
  8009a2:	7e 10                	jle    8009b4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8b 10                	mov    (%eax),%edx
  8009a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ac:	8d 40 08             	lea    0x8(%eax),%eax
  8009af:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b2:	eb 26                	jmp    8009da <vprintfmt+0x406>
	else if (lflag)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 12                	je     8009ca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8b 10                	mov    (%eax),%edx
  8009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c2:	8d 40 04             	lea    0x4(%eax),%eax
  8009c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c8:	eb 10                	jmp    8009da <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cd:	8b 10                	mov    (%eax),%edx
  8009cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d4:	8d 40 04             	lea    0x4(%eax),%eax
  8009d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009da:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009f2:	89 14 24             	mov    %edx,(%esp)
  8009f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f9:	89 da                	mov    %ebx,%edx
  8009fb:	89 f0                	mov    %esi,%eax
  8009fd:	e8 9e fa ff ff       	call   8004a0 <printnum>
			break;
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 ef fb ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	89 04 24             	mov    %eax,(%esp)
  800a11:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a16:	e9 de fb ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a26:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	eb 03                	jmp    800a2d <vprintfmt+0x459>
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a31:	75 f7                	jne    800a2a <vprintfmt+0x456>
  800a33:	e9 c1 fb ff ff       	jmp    8005f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a38:	83 c4 3c             	add    $0x3c,%esp
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 28             	sub    $0x28,%esp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a53:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	74 30                	je     800a91 <vsnprintf+0x51>
  800a61:	85 d2                	test   %edx,%edx
  800a63:	7e 2c                	jle    800a91 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a65:	8b 45 14             	mov    0x14(%ebp),%eax
  800a68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a73:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	c7 04 24 8f 05 80 00 	movl   $0x80058f,(%esp)
  800a81:	e8 4e fb ff ff       	call   8005d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a89:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8f:	eb 05                	jmp    800a96 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa5:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	89 04 24             	mov    %eax,(%esp)
  800ab9:	e8 82 ff ff ff       	call   800a40 <vsnprintf>
	va_end(ap);

	return rc;
}
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	eb 03                	jmp    800ad0 <strlen+0x10>
		n++;
  800acd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad4:	75 f7                	jne    800acd <strlen+0xd>
		n++;
	return n;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	eb 03                	jmp    800aeb <strnlen+0x13>
		n++;
  800ae8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1d>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f3                	jne    800ae8 <strnlen+0x10>
		n++;
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b0d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b10:	84 db                	test   %bl,%bl
  800b12:	75 ef                	jne    800b03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b14:	5b                   	pop    %ebx
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b21:	89 1c 24             	mov    %ebx,(%esp)
  800b24:	e8 97 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b30:	01 d8                	add    %ebx,%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 bd ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	83 c4 08             	add    $0x8,%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b52:	89 f2                	mov    %esi,%edx
  800b54:	eb 0f                	jmp    800b65 <strncpy+0x23>
		*dst++ = *src;
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	0f b6 01             	movzbl (%ecx),%eax
  800b5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b5f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b62:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b65:	39 da                	cmp    %ebx,%edx
  800b67:	75 ed                	jne    800b56 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 75 08             	mov    0x8(%ebp),%esi
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	85 c9                	test   %ecx,%ecx
  800b85:	75 0b                	jne    800b92 <strlcpy+0x23>
  800b87:	eb 1d                	jmp    800ba6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b89:	83 c0 01             	add    $0x1,%eax
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b92:	39 d8                	cmp    %ebx,%eax
  800b94:	74 0b                	je     800ba1 <strlcpy+0x32>
  800b96:	0f b6 0a             	movzbl (%edx),%ecx
  800b99:	84 c9                	test   %cl,%cl
  800b9b:	75 ec                	jne    800b89 <strlcpy+0x1a>
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 02                	jmp    800ba3 <strlcpy+0x34>
  800ba1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ba3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ba6:	29 f0                	sub    %esi,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb5:	eb 06                	jmp    800bbd <strcmp+0x11>
		p++, q++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
  800bba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbd:	0f b6 01             	movzbl (%ecx),%eax
  800bc0:	84 c0                	test   %al,%al
  800bc2:	74 04                	je     800bc8 <strcmp+0x1c>
  800bc4:	3a 02                	cmp    (%edx),%al
  800bc6:	74 ef                	je     800bb7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc8:	0f b6 c0             	movzbl %al,%eax
  800bcb:	0f b6 12             	movzbl (%edx),%edx
  800bce:	29 d0                	sub    %edx,%eax
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdc:	89 c3                	mov    %eax,%ebx
  800bde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800be1:	eb 06                	jmp    800be9 <strncmp+0x17>
		n--, p++, q++;
  800be3:	83 c0 01             	add    $0x1,%eax
  800be6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800be9:	39 d8                	cmp    %ebx,%eax
  800beb:	74 15                	je     800c02 <strncmp+0x30>
  800bed:	0f b6 08             	movzbl (%eax),%ecx
  800bf0:	84 c9                	test   %cl,%cl
  800bf2:	74 04                	je     800bf8 <strncmp+0x26>
  800bf4:	3a 0a                	cmp    (%edx),%cl
  800bf6:	74 eb                	je     800be3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf8:	0f b6 00             	movzbl (%eax),%eax
  800bfb:	0f b6 12             	movzbl (%edx),%edx
  800bfe:	29 d0                	sub    %edx,%eax
  800c00:	eb 05                	jmp    800c07 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c14:	eb 07                	jmp    800c1d <strchr+0x13>
		if (*s == c)
  800c16:	38 ca                	cmp    %cl,%dl
  800c18:	74 0f                	je     800c29 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f2                	jne    800c16 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	eb 07                	jmp    800c3e <strfind+0x13>
		if (*s == c)
  800c37:	38 ca                	cmp    %cl,%dl
  800c39:	74 0a                	je     800c45 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	0f b6 10             	movzbl (%eax),%edx
  800c41:	84 d2                	test   %dl,%dl
  800c43:	75 f2                	jne    800c37 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c53:	85 c9                	test   %ecx,%ecx
  800c55:	74 36                	je     800c8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c57:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5d:	75 28                	jne    800c87 <memset+0x40>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 23                	jne    800c87 <memset+0x40>
		c &= 0xFF;
  800c64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	c1 e3 08             	shl    $0x8,%ebx
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	c1 e6 18             	shl    $0x18,%esi
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	c1 e0 10             	shl    $0x10,%eax
  800c77:	09 f0                	or     %esi,%eax
  800c79:	09 c2                	or     %eax,%edx
  800c7b:	89 d0                	mov    %edx,%eax
  800c7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c82:	fc                   	cld    
  800c83:	f3 ab                	rep stos %eax,%es:(%edi)
  800c85:	eb 06                	jmp    800c8d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	fc                   	cld    
  800c8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c8d:	89 f8                	mov    %edi,%eax
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca2:	39 c6                	cmp    %eax,%esi
  800ca4:	73 35                	jae    800cdb <memmove+0x47>
  800ca6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	73 2e                	jae    800cdb <memmove+0x47>
		s += n;
		d += n;
  800cad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cba:	75 13                	jne    800ccf <memmove+0x3b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0e                	jne    800ccf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc1:	83 ef 04             	sub    $0x4,%edi
  800cc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cca:	fd                   	std    
  800ccb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccd:	eb 09                	jmp    800cd8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ccf:	83 ef 01             	sub    $0x1,%edi
  800cd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd5:	fd                   	std    
  800cd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd8:	fc                   	cld    
  800cd9:	eb 1d                	jmp    800cf8 <memmove+0x64>
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdf:	f6 c2 03             	test   $0x3,%dl
  800ce2:	75 0f                	jne    800cf3 <memmove+0x5f>
  800ce4:	f6 c1 03             	test   $0x3,%cl
  800ce7:	75 0a                	jne    800cf3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ce9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	fc                   	cld    
  800cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf1:	eb 05                	jmp    800cf8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf3:	89 c7                	mov    %eax,%edi
  800cf5:	fc                   	cld    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d02:	8b 45 10             	mov    0x10(%ebp),%eax
  800d05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	89 04 24             	mov    %eax,(%esp)
  800d16:	e8 79 ff ff ff       	call   800c94 <memmove>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2d:	eb 1a                	jmp    800d49 <memcmp+0x2c>
		if (*s1 != *s2)
  800d2f:	0f b6 02             	movzbl (%edx),%eax
  800d32:	0f b6 19             	movzbl (%ecx),%ebx
  800d35:	38 d8                	cmp    %bl,%al
  800d37:	74 0a                	je     800d43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 db             	movzbl %bl,%ebx
  800d3f:	29 d8                	sub    %ebx,%eax
  800d41:	eb 0f                	jmp    800d52 <memcmp+0x35>
		s1++, s2++;
  800d43:	83 c2 01             	add    $0x1,%edx
  800d46:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d49:	39 f2                	cmp    %esi,%edx
  800d4b:	75 e2                	jne    800d2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d64:	eb 07                	jmp    800d6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d66:	38 08                	cmp    %cl,(%eax)
  800d68:	74 07                	je     800d71 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	39 d0                	cmp    %edx,%eax
  800d6f:	72 f5                	jb     800d66 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7f:	eb 03                	jmp    800d84 <strtol+0x11>
		s++;
  800d81:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d84:	0f b6 0a             	movzbl (%edx),%ecx
  800d87:	80 f9 09             	cmp    $0x9,%cl
  800d8a:	74 f5                	je     800d81 <strtol+0xe>
  800d8c:	80 f9 20             	cmp    $0x20,%cl
  800d8f:	74 f0                	je     800d81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d91:	80 f9 2b             	cmp    $0x2b,%cl
  800d94:	75 0a                	jne    800da0 <strtol+0x2d>
		s++;
  800d96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d99:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9e:	eb 11                	jmp    800db1 <strtol+0x3e>
  800da0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800da5:	80 f9 2d             	cmp    $0x2d,%cl
  800da8:	75 07                	jne    800db1 <strtol+0x3e>
		s++, neg = 1;
  800daa:	8d 52 01             	lea    0x1(%edx),%edx
  800dad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800db6:	75 15                	jne    800dcd <strtol+0x5a>
  800db8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dbb:	75 10                	jne    800dcd <strtol+0x5a>
  800dbd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dc1:	75 0a                	jne    800dcd <strtol+0x5a>
		s += 2, base = 16;
  800dc3:	83 c2 02             	add    $0x2,%edx
  800dc6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dcb:	eb 10                	jmp    800ddd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	75 0c                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd6:	75 05                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
  800dd8:	83 c2 01             	add    $0x1,%edx
  800ddb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de5:	0f b6 0a             	movzbl (%edx),%ecx
  800de8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	3c 09                	cmp    $0x9,%al
  800def:	77 08                	ja     800df9 <strtol+0x86>
			dig = *s - '0';
  800df1:	0f be c9             	movsbl %cl,%ecx
  800df4:	83 e9 30             	sub    $0x30,%ecx
  800df7:	eb 20                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800df9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	3c 19                	cmp    $0x19,%al
  800e00:	77 08                	ja     800e0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e02:	0f be c9             	movsbl %cl,%ecx
  800e05:	83 e9 57             	sub    $0x57,%ecx
  800e08:	eb 0f                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	3c 19                	cmp    $0x19,%al
  800e11:	77 16                	ja     800e29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e13:	0f be c9             	movsbl %cl,%ecx
  800e16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e1c:	7d 0f                	jge    800e2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e1e:	83 c2 01             	add    $0x1,%edx
  800e21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e27:	eb bc                	jmp    800de5 <strtol+0x72>
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	eb 02                	jmp    800e2f <strtol+0xbc>
  800e2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e33:	74 05                	je     800e3a <strtol+0xc7>
		*endptr = (char *) s;
  800e35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e3a:	f7 d8                	neg    %eax
  800e3c:	85 ff                	test   %edi,%edi
  800e3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	89 c7                	mov    %eax,%edi
  800e5b:	89 c6                	mov    %eax,%esi
  800e5d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800e74:	89 d1                	mov    %edx,%ecx
  800e76:	89 d3                	mov    %edx,%ebx
  800e78:	89 d7                	mov    %edx,%edi
  800e7a:	89 d6                	mov    %edx,%esi
  800e7c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e91:	b8 03 00 00 00       	mov    $0x3,%eax
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	89 cb                	mov    %ecx,%ebx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	89 ce                	mov    %ecx,%esi
  800e9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800ec8:	e8 ba f4 ff ff       	call   800387 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ecd:	83 c4 2c             	add    $0x2c,%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ee5:	89 d1                	mov    %edx,%ecx
  800ee7:	89 d3                	mov    %edx,%ebx
  800ee9:	89 d7                	mov    %edx,%edi
  800eeb:	89 d6                	mov    %edx,%esi
  800eed:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_yield>:

void
sys_yield(void)
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
  800eff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f04:	89 d1                	mov    %edx,%ecx
  800f06:	89 d3                	mov    %edx,%ebx
  800f08:	89 d7                	mov    %edx,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
  800f21:	b8 04 00 00 00       	mov    $0x4,%eax
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	89 f7                	mov    %esi,%edi
  800f31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f33:	85 c0                	test   %eax,%eax
  800f35:	7e 28                	jle    800f5f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f42:	00 
  800f43:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800f5a:	e8 28 f4 ff ff       	call   800387 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f5f:	83 c4 2c             	add    $0x2c,%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f70:	b8 05 00 00 00       	mov    $0x5,%eax
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f81:	8b 75 18             	mov    0x18(%ebp),%esi
  800f84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f86:	85 c0                	test   %eax,%eax
  800f88:	7e 28                	jle    800fb2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f95:	00 
  800f96:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800fad:	e8 d5 f3 ff ff       	call   800387 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fb2:	83 c4 2c             	add    $0x2c,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd3:	89 df                	mov    %ebx,%edi
  800fd5:	89 de                	mov    %ebx,%esi
  800fd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	7e 28                	jle    801005 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff8:	00 
  800ff9:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  801000:	e8 82 f3 ff ff       	call   800387 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801005:	83 c4 2c             	add    $0x2c,%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101b:	b8 08 00 00 00       	mov    $0x8,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 df                	mov    %ebx,%edi
  801028:	89 de                	mov    %ebx,%esi
  80102a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 28                	jle    801058 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	89 44 24 10          	mov    %eax,0x10(%esp)
  801034:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80103b:	00 
  80103c:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  801043:	00 
  801044:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80104b:	00 
  80104c:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  801053:	e8 2f f3 ff ff       	call   800387 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801058:	83 c4 2c             	add    $0x2c,%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801069:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106e:	b8 09 00 00 00       	mov    $0x9,%eax
  801073:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	89 df                	mov    %ebx,%edi
  80107b:	89 de                	mov    %ebx,%esi
  80107d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107f:	85 c0                	test   %eax,%eax
  801081:	7e 28                	jle    8010ab <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801083:	89 44 24 10          	mov    %eax,0x10(%esp)
  801087:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80108e:	00 
  80108f:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  801096:	00 
  801097:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109e:	00 
  80109f:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  8010a6:	e8 dc f2 ff ff       	call   800387 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010ab:	83 c4 2c             	add    $0x2c,%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	89 df                	mov    %ebx,%edi
  8010ce:	89 de                	mov    %ebx,%esi
  8010d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	7e 28                	jle    8010fe <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010da:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  8010e9:	00 
  8010ea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f1:	00 
  8010f2:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  8010f9:	e8 89 f2 ff ff       	call   800387 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010fe:	83 c4 2c             	add    $0x2c,%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110c:	be 00 00 00 00       	mov    $0x0,%esi
  801111:	b8 0c 00 00 00       	mov    $0xc,%eax
  801116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801119:	8b 55 08             	mov    0x8(%ebp),%edx
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80111f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801122:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801132:	b9 00 00 00 00       	mov    $0x0,%ecx
  801137:	b8 0d 00 00 00       	mov    $0xd,%eax
  80113c:	8b 55 08             	mov    0x8(%ebp),%edx
  80113f:	89 cb                	mov    %ecx,%ebx
  801141:	89 cf                	mov    %ecx,%edi
  801143:	89 ce                	mov    %ecx,%esi
  801145:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801147:	85 c0                	test   %eax,%eax
  801149:	7e 28                	jle    801173 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801156:	00 
  801157:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  80116e:	e8 14 f2 ff ff       	call   800387 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801173:	83 c4 2c             	add    $0x2c,%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	53                   	push   %ebx
  80117f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801182:	8b 55 0c             	mov    0xc(%ebp),%edx
  801185:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801188:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  80118a:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	83 39 01             	cmpl   $0x1,(%ecx)
  801195:	7e 0f                	jle    8011a6 <argstart+0x2b>
  801197:	85 d2                	test   %edx,%edx
  801199:	ba 00 00 00 00       	mov    $0x0,%edx
  80119e:	bb 68 26 80 00       	mov    $0x802668,%ebx
  8011a3:	0f 44 da             	cmove  %edx,%ebx
  8011a6:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  8011a9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8011b0:	5b                   	pop    %ebx
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <argnext>:

int
argnext(struct Argstate *args)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 14             	sub    $0x14,%esp
  8011ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8011bd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8011c4:	8b 43 08             	mov    0x8(%ebx),%eax
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	74 71                	je     80123c <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  8011cb:	80 38 00             	cmpb   $0x0,(%eax)
  8011ce:	75 50                	jne    801220 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8011d0:	8b 0b                	mov    (%ebx),%ecx
  8011d2:	83 39 01             	cmpl   $0x1,(%ecx)
  8011d5:	74 57                	je     80122e <argnext+0x7b>
		    || args->argv[1][0] != '-'
  8011d7:	8b 53 04             	mov    0x4(%ebx),%edx
  8011da:	8b 42 04             	mov    0x4(%edx),%eax
  8011dd:	80 38 2d             	cmpb   $0x2d,(%eax)
  8011e0:	75 4c                	jne    80122e <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  8011e2:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8011e6:	74 46                	je     80122e <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8011e8:	83 c0 01             	add    $0x1,%eax
  8011eb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011ee:	8b 01                	mov    (%ecx),%eax
  8011f0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8011f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fb:	8d 42 08             	lea    0x8(%edx),%eax
  8011fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801202:	83 c2 04             	add    $0x4,%edx
  801205:	89 14 24             	mov    %edx,(%esp)
  801208:	e8 87 fa ff ff       	call   800c94 <memmove>
		(*args->argc)--;
  80120d:	8b 03                	mov    (%ebx),%eax
  80120f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801212:	8b 43 08             	mov    0x8(%ebx),%eax
  801215:	80 38 2d             	cmpb   $0x2d,(%eax)
  801218:	75 06                	jne    801220 <argnext+0x6d>
  80121a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80121e:	74 0e                	je     80122e <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801220:	8b 53 08             	mov    0x8(%ebx),%edx
  801223:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801226:	83 c2 01             	add    $0x1,%edx
  801229:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80122c:	eb 13                	jmp    801241 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  80122e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80123a:	eb 05                	jmp    801241 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80123c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801241:	83 c4 14             	add    $0x14,%esp
  801244:	5b                   	pop    %ebx
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	53                   	push   %ebx
  80124b:	83 ec 14             	sub    $0x14,%esp
  80124e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801251:	8b 43 08             	mov    0x8(%ebx),%eax
  801254:	85 c0                	test   %eax,%eax
  801256:	74 5a                	je     8012b2 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801258:	80 38 00             	cmpb   $0x0,(%eax)
  80125b:	74 0c                	je     801269 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80125d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801260:	c7 43 08 68 26 80 00 	movl   $0x802668,0x8(%ebx)
  801267:	eb 44                	jmp    8012ad <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801269:	8b 03                	mov    (%ebx),%eax
  80126b:	83 38 01             	cmpl   $0x1,(%eax)
  80126e:	7e 2f                	jle    80129f <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801270:	8b 53 04             	mov    0x4(%ebx),%edx
  801273:	8b 4a 04             	mov    0x4(%edx),%ecx
  801276:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801279:	8b 00                	mov    (%eax),%eax
  80127b:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801282:	89 44 24 08          	mov    %eax,0x8(%esp)
  801286:	8d 42 08             	lea    0x8(%edx),%eax
  801289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128d:	83 c2 04             	add    $0x4,%edx
  801290:	89 14 24             	mov    %edx,(%esp)
  801293:	e8 fc f9 ff ff       	call   800c94 <memmove>
		(*args->argc)--;
  801298:	8b 03                	mov    (%ebx),%eax
  80129a:	83 28 01             	subl   $0x1,(%eax)
  80129d:	eb 0e                	jmp    8012ad <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  80129f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8012a6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8012ad:	8b 43 0c             	mov    0xc(%ebx),%eax
  8012b0:	eb 05                	jmp    8012b7 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8012b7:	83 c4 14             	add    $0x14,%esp
  8012ba:	5b                   	pop    %ebx
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 18             	sub    $0x18,%esp
  8012c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8012c6:	8b 51 0c             	mov    0xc(%ecx),%edx
  8012c9:	89 d0                	mov    %edx,%eax
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	75 08                	jne    8012d7 <argvalue+0x1a>
  8012cf:	89 0c 24             	mov    %ecx,(%esp)
  8012d2:	e8 70 ff ff ff       	call   801247 <argnextvalue>
}
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    
  8012d9:	66 90                	xchg   %ax,%ax
  8012db:	66 90                	xchg   %ax,%ax
  8012dd:	66 90                	xchg   %ax,%ax
  8012df:	90                   	nop

008012e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8012fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801300:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801312:	89 c2                	mov    %eax,%edx
  801314:	c1 ea 16             	shr    $0x16,%edx
  801317:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131e:	f6 c2 01             	test   $0x1,%dl
  801321:	74 11                	je     801334 <fd_alloc+0x2d>
  801323:	89 c2                	mov    %eax,%edx
  801325:	c1 ea 0c             	shr    $0xc,%edx
  801328:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132f:	f6 c2 01             	test   $0x1,%dl
  801332:	75 09                	jne    80133d <fd_alloc+0x36>
			*fd_store = fd;
  801334:	89 01                	mov    %eax,(%ecx)
			return 0;
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
  80133b:	eb 17                	jmp    801354 <fd_alloc+0x4d>
  80133d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801342:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801347:	75 c9                	jne    801312 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801349:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80134f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80135c:	83 f8 1f             	cmp    $0x1f,%eax
  80135f:	77 36                	ja     801397 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801361:	c1 e0 0c             	shl    $0xc,%eax
  801364:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801369:	89 c2                	mov    %eax,%edx
  80136b:	c1 ea 16             	shr    $0x16,%edx
  80136e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801375:	f6 c2 01             	test   $0x1,%dl
  801378:	74 24                	je     80139e <fd_lookup+0x48>
  80137a:	89 c2                	mov    %eax,%edx
  80137c:	c1 ea 0c             	shr    $0xc,%edx
  80137f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801386:	f6 c2 01             	test   $0x1,%dl
  801389:	74 1a                	je     8013a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80138b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138e:	89 02                	mov    %eax,(%edx)
	return 0;
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	eb 13                	jmp    8013aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb 0c                	jmp    8013aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb 05                	jmp    8013aa <fd_lookup+0x54>
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 18             	sub    $0x18,%esp
  8013b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b5:	ba 68 2a 80 00       	mov    $0x802a68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ba:	eb 13                	jmp    8013cf <dev_lookup+0x23>
  8013bc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013bf:	39 08                	cmp    %ecx,(%eax)
  8013c1:	75 0c                	jne    8013cf <dev_lookup+0x23>
			*dev = devtab[i];
  8013c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cd:	eb 30                	jmp    8013ff <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013cf:	8b 02                	mov    (%edx),%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	75 e7                	jne    8013bc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d5:	a1 20 44 80 00       	mov    0x804420,%eax
  8013da:	8b 40 48             	mov    0x48(%eax),%eax
  8013dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8013ec:	e8 8f f0 ff ff       	call   800480 <cprintf>
	*dev = 0;
  8013f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	83 ec 20             	sub    $0x20,%esp
  801409:	8b 75 08             	mov    0x8(%ebp),%esi
  80140c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801416:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 2f ff ff ff       	call   801356 <fd_lookup>
  801427:	85 c0                	test   %eax,%eax
  801429:	78 05                	js     801430 <fd_close+0x2f>
	    || fd != fd2)
  80142b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80142e:	74 0c                	je     80143c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801430:	84 db                	test   %bl,%bl
  801432:	ba 00 00 00 00       	mov    $0x0,%edx
  801437:	0f 44 c2             	cmove  %edx,%eax
  80143a:	eb 3f                	jmp    80147b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80143c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	8b 06                	mov    (%esi),%eax
  801445:	89 04 24             	mov    %eax,(%esp)
  801448:	e8 5f ff ff ff       	call   8013ac <dev_lookup>
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 16                	js     801469 <fd_close+0x68>
		if (dev->dev_close)
  801453:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801456:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801459:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80145e:	85 c0                	test   %eax,%eax
  801460:	74 07                	je     801469 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801462:	89 34 24             	mov    %esi,(%esp)
  801465:	ff d0                	call   *%eax
  801467:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801469:	89 74 24 04          	mov    %esi,0x4(%esp)
  80146d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801474:	e8 41 fb ff ff       	call   800fba <sys_page_unmap>
	return r;
  801479:	89 d8                	mov    %ebx,%eax
}
  80147b:	83 c4 20             	add    $0x20,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    

00801482 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	89 04 24             	mov    %eax,(%esp)
  801495:	e8 bc fe ff ff       	call   801356 <fd_lookup>
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	78 13                	js     8014b3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8014a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a7:	00 
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	89 04 24             	mov    %eax,(%esp)
  8014ae:	e8 4e ff ff ff       	call   801401 <fd_close>
}
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <close_all>:

void
close_all(void)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c1:	89 1c 24             	mov    %ebx,(%esp)
  8014c4:	e8 b9 ff ff ff       	call   801482 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c9:	83 c3 01             	add    $0x1,%ebx
  8014cc:	83 fb 20             	cmp    $0x20,%ebx
  8014cf:	75 f0                	jne    8014c1 <close_all+0xc>
		close(i);
}
  8014d1:	83 c4 14             	add    $0x14,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	57                   	push   %edi
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	89 04 24             	mov    %eax,(%esp)
  8014ed:	e8 64 fe ff ff       	call   801356 <fd_lookup>
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	0f 88 e1 00 00 00    	js     8015dd <dup+0x106>
		return r;
	close(newfdnum);
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 7b ff ff ff       	call   801482 <close>

	newfd = INDEX2FD(newfdnum);
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150a:	c1 e3 0c             	shl    $0xc,%ebx
  80150d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801516:	89 04 24             	mov    %eax,(%esp)
  801519:	e8 d2 fd ff ff       	call   8012f0 <fd2data>
  80151e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801520:	89 1c 24             	mov    %ebx,(%esp)
  801523:	e8 c8 fd ff ff       	call   8012f0 <fd2data>
  801528:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80152a:	89 f0                	mov    %esi,%eax
  80152c:	c1 e8 16             	shr    $0x16,%eax
  80152f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801536:	a8 01                	test   $0x1,%al
  801538:	74 43                	je     80157d <dup+0xa6>
  80153a:	89 f0                	mov    %esi,%eax
  80153c:	c1 e8 0c             	shr    $0xc,%eax
  80153f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801546:	f6 c2 01             	test   $0x1,%dl
  801549:	74 32                	je     80157d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801552:	25 07 0e 00 00       	and    $0xe07,%eax
  801557:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80155f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801566:	00 
  801567:	89 74 24 04          	mov    %esi,0x4(%esp)
  80156b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801572:	e8 f0 f9 ff ff       	call   800f67 <sys_page_map>
  801577:	89 c6                	mov    %eax,%esi
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 3e                	js     8015bb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801580:	89 c2                	mov    %eax,%edx
  801582:	c1 ea 0c             	shr    $0xc,%edx
  801585:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801592:	89 54 24 10          	mov    %edx,0x10(%esp)
  801596:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80159a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a1:	00 
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ad:	e8 b5 f9 ff ff       	call   800f67 <sys_page_map>
  8015b2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b7:	85 f6                	test   %esi,%esi
  8015b9:	79 22                	jns    8015dd <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c6:	e8 ef f9 ff ff       	call   800fba <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d6:	e8 df f9 ff ff       	call   800fba <sys_page_unmap>
	return r;
  8015db:	89 f0                	mov    %esi,%eax
}
  8015dd:	83 c4 3c             	add    $0x3c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 24             	sub    $0x24,%esp
  8015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 58 fd ff ff       	call   801356 <fd_lookup>
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	85 d2                	test   %edx,%edx
  801602:	78 6d                	js     801671 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	8b 00                	mov    (%eax),%eax
  801610:	89 04 24             	mov    %eax,(%esp)
  801613:	e8 94 fd ff ff       	call   8013ac <dev_lookup>
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 55                	js     801671 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	8b 50 08             	mov    0x8(%eax),%edx
  801622:	83 e2 03             	and    $0x3,%edx
  801625:	83 fa 01             	cmp    $0x1,%edx
  801628:	75 23                	jne    80164d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80162a:	a1 20 44 80 00       	mov    0x804420,%eax
  80162f:	8b 40 48             	mov    0x48(%eax),%eax
  801632:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	c7 04 24 2d 2a 80 00 	movl   $0x802a2d,(%esp)
  801641:	e8 3a ee ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  801646:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164b:	eb 24                	jmp    801671 <read+0x8c>
	}
	if (!dev->dev_read)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 08             	mov    0x8(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 15                	je     80166c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801657:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80165a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80165e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801661:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	ff d2                	call   *%edx
  80166a:	eb 05                	jmp    801671 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80166c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801671:	83 c4 24             	add    $0x24,%esp
  801674:	5b                   	pop    %ebx
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 1c             	sub    $0x1c,%esp
  801680:	8b 7d 08             	mov    0x8(%ebp),%edi
  801683:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168b:	eb 23                	jmp    8016b0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80168d:	89 f0                	mov    %esi,%eax
  80168f:	29 d8                	sub    %ebx,%eax
  801691:	89 44 24 08          	mov    %eax,0x8(%esp)
  801695:	89 d8                	mov    %ebx,%eax
  801697:	03 45 0c             	add    0xc(%ebp),%eax
  80169a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169e:	89 3c 24             	mov    %edi,(%esp)
  8016a1:	e8 3f ff ff ff       	call   8015e5 <read>
		if (m < 0)
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 10                	js     8016ba <readn+0x43>
			return m;
		if (m == 0)
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	74 0a                	je     8016b8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ae:	01 c3                	add    %eax,%ebx
  8016b0:	39 f3                	cmp    %esi,%ebx
  8016b2:	72 d9                	jb     80168d <readn+0x16>
  8016b4:	89 d8                	mov    %ebx,%eax
  8016b6:	eb 02                	jmp    8016ba <readn+0x43>
  8016b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ba:	83 c4 1c             	add    $0x1c,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5f                   	pop    %edi
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 24             	sub    $0x24,%esp
  8016c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	e8 7b fc ff ff       	call   801356 <fd_lookup>
  8016db:	89 c2                	mov    %eax,%edx
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	78 68                	js     801749 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	8b 00                	mov    (%eax),%eax
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	e8 b7 fc ff ff       	call   8013ac <dev_lookup>
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 50                	js     801749 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801700:	75 23                	jne    801725 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801702:	a1 20 44 80 00       	mov    0x804420,%eax
  801707:	8b 40 48             	mov    0x48(%eax),%eax
  80170a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80170e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801712:	c7 04 24 49 2a 80 00 	movl   $0x802a49,(%esp)
  801719:	e8 62 ed ff ff       	call   800480 <cprintf>
		return -E_INVAL;
  80171e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801723:	eb 24                	jmp    801749 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801725:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801728:	8b 52 0c             	mov    0xc(%edx),%edx
  80172b:	85 d2                	test   %edx,%edx
  80172d:	74 15                	je     801744 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80172f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801732:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	ff d2                	call   *%edx
  801742:	eb 05                	jmp    801749 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801744:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801749:	83 c4 24             	add    $0x24,%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <seek>:

int
seek(int fdnum, off_t offset)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801755:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	89 04 24             	mov    %eax,(%esp)
  801762:	e8 ef fb ff ff       	call   801356 <fd_lookup>
  801767:	85 c0                	test   %eax,%eax
  801769:	78 0e                	js     801779 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80176b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80176e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801771:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 24             	sub    $0x24,%esp
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801785:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	89 1c 24             	mov    %ebx,(%esp)
  80178f:	e8 c2 fb ff ff       	call   801356 <fd_lookup>
  801794:	89 c2                	mov    %eax,%edx
  801796:	85 d2                	test   %edx,%edx
  801798:	78 61                	js     8017fb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	8b 00                	mov    (%eax),%eax
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 fe fb ff ff       	call   8013ac <dev_lookup>
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 49                	js     8017fb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b9:	75 23                	jne    8017de <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017bb:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c0:	8b 40 48             	mov    0x48(%eax),%eax
  8017c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	c7 04 24 0c 2a 80 00 	movl   $0x802a0c,(%esp)
  8017d2:	e8 a9 ec ff ff       	call   800480 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017dc:	eb 1d                	jmp    8017fb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8017de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e1:	8b 52 18             	mov    0x18(%edx),%edx
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	74 0e                	je     8017f6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	ff d2                	call   *%edx
  8017f4:	eb 05                	jmp    8017fb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017fb:	83 c4 24             	add    $0x24,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 24             	sub    $0x24,%esp
  801808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	89 04 24             	mov    %eax,(%esp)
  801818:	e8 39 fb ff ff       	call   801356 <fd_lookup>
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 d2                	test   %edx,%edx
  801821:	78 52                	js     801875 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182d:	8b 00                	mov    (%eax),%eax
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	e8 75 fb ff ff       	call   8013ac <dev_lookup>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 3a                	js     801875 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801842:	74 2c                	je     801870 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801844:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801847:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80184e:	00 00 00 
	stat->st_isdir = 0;
  801851:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801858:	00 00 00 
	stat->st_dev = dev;
  80185b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801861:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801865:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801868:	89 14 24             	mov    %edx,(%esp)
  80186b:	ff 50 14             	call   *0x14(%eax)
  80186e:	eb 05                	jmp    801875 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801870:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801875:	83 c4 24             	add    $0x24,%esp
  801878:	5b                   	pop    %ebx
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801883:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80188a:	00 
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	89 04 24             	mov    %eax,(%esp)
  801891:	e8 fb 01 00 00       	call   801a91 <open>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	85 db                	test   %ebx,%ebx
  80189a:	78 1b                	js     8018b7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80189c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	89 1c 24             	mov    %ebx,(%esp)
  8018a6:	e8 56 ff ff ff       	call   801801 <fstat>
  8018ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8018ad:	89 1c 24             	mov    %ebx,(%esp)
  8018b0:	e8 cd fb ff ff       	call   801482 <close>
	return r;
  8018b5:	89 f0                	mov    %esi,%eax
}
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 10             	sub    $0x10,%esp
  8018c6:	89 c6                	mov    %eax,%esi
  8018c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d1:	75 11                	jne    8018e4 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018da:	e8 0e 0a 00 00       	call   8022ed <ipc_find_env>
  8018df:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018eb:	00 
  8018ec:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018f3:	00 
  8018f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 39 09 00 00       	call   80223e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801905:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190c:	00 
  80190d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801918:	e8 83 08 00 00       	call   8021a0 <ipc_recv>
}
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	b8 02 00 00 00       	mov    $0x2,%eax
  801947:	e8 72 ff ff ff       	call   8018be <fsipc>
}
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	8b 40 0c             	mov    0xc(%eax),%eax
  80195a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 06 00 00 00       	mov    $0x6,%eax
  801969:	e8 50 ff ff ff       	call   8018be <fsipc>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	53                   	push   %ebx
  801974:	83 ec 14             	sub    $0x14,%esp
  801977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	8b 40 0c             	mov    0xc(%eax),%eax
  801980:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801985:	ba 00 00 00 00       	mov    $0x0,%edx
  80198a:	b8 05 00 00 00       	mov    $0x5,%eax
  80198f:	e8 2a ff ff ff       	call   8018be <fsipc>
  801994:	89 c2                	mov    %eax,%edx
  801996:	85 d2                	test   %edx,%edx
  801998:	78 2b                	js     8019c5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80199a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019a1:	00 
  8019a2:	89 1c 24             	mov    %ebx,(%esp)
  8019a5:	e8 4d f1 ff ff       	call   800af7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8019af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c5:	83 c4 14             	add    $0x14,%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8019d1:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  8019d8:	00 
  8019d9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8019e0:	00 
  8019e1:	c7 04 24 96 2a 80 00 	movl   $0x802a96,(%esp)
  8019e8:	e8 9a e9 ff ff       	call   800387 <_panic>

008019ed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 10             	sub    $0x10,%esp
  8019f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a03:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a13:	e8 a6 fe ff ff       	call   8018be <fsipc>
  801a18:	89 c3                	mov    %eax,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 6a                	js     801a88 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a1e:	39 c6                	cmp    %eax,%esi
  801a20:	73 24                	jae    801a46 <devfile_read+0x59>
  801a22:	c7 44 24 0c a1 2a 80 	movl   $0x802aa1,0xc(%esp)
  801a29:	00 
  801a2a:	c7 44 24 08 a8 2a 80 	movl   $0x802aa8,0x8(%esp)
  801a31:	00 
  801a32:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a39:	00 
  801a3a:	c7 04 24 96 2a 80 00 	movl   $0x802a96,(%esp)
  801a41:	e8 41 e9 ff ff       	call   800387 <_panic>
	assert(r <= PGSIZE);
  801a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4b:	7e 24                	jle    801a71 <devfile_read+0x84>
  801a4d:	c7 44 24 0c bd 2a 80 	movl   $0x802abd,0xc(%esp)
  801a54:	00 
  801a55:	c7 44 24 08 a8 2a 80 	movl   $0x802aa8,0x8(%esp)
  801a5c:	00 
  801a5d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a64:	00 
  801a65:	c7 04 24 96 2a 80 00 	movl   $0x802a96,(%esp)
  801a6c:	e8 16 e9 ff ff       	call   800387 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a75:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a7c:	00 
  801a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 0c f2 ff ff       	call   800c94 <memmove>
	return r;
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 24             	sub    $0x24,%esp
  801a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a9b:	89 1c 24             	mov    %ebx,(%esp)
  801a9e:	e8 1d f0 ff ff       	call   800ac0 <strlen>
  801aa3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa8:	7f 60                	jg     801b0a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 52 f8 ff ff       	call   801307 <fd_alloc>
  801ab5:	89 c2                	mov    %eax,%edx
  801ab7:	85 d2                	test   %edx,%edx
  801ab9:	78 54                	js     801b0f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801abf:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ac6:	e8 2c f0 ff ff       	call   800af7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad6:	b8 01 00 00 00       	mov    $0x1,%eax
  801adb:	e8 de fd ff ff       	call   8018be <fsipc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	79 17                	jns    801afd <open+0x6c>
		fd_close(fd, 0);
  801ae6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aed:	00 
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 08 f9 ff ff       	call   801401 <fd_close>
		return r;
  801af9:	89 d8                	mov    %ebx,%eax
  801afb:	eb 12                	jmp    801b0f <open+0x7e>
	}

	return fd2num(fd);
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	89 04 24             	mov    %eax,(%esp)
  801b03:	e8 d8 f7 ff ff       	call   8012e0 <fd2num>
  801b08:	eb 05                	jmp    801b0f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0f:	83 c4 24             	add    $0x24,%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b20:	b8 08 00 00 00       	mov    $0x8,%eax
  801b25:	e8 94 fd ff ff       	call   8018be <fsipc>
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 14             	sub    $0x14,%esp
  801b33:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801b35:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801b39:	7e 31                	jle    801b6c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801b3b:	8b 40 04             	mov    0x4(%eax),%eax
  801b3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b42:	8d 43 10             	lea    0x10(%ebx),%eax
  801b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b49:	8b 03                	mov    (%ebx),%eax
  801b4b:	89 04 24             	mov    %eax,(%esp)
  801b4e:	e8 6f fb ff ff       	call   8016c2 <write>
		if (result > 0)
  801b53:	85 c0                	test   %eax,%eax
  801b55:	7e 03                	jle    801b5a <writebuf+0x2e>
			b->result += result;
  801b57:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b5a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b5d:	74 0d                	je     801b6c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
  801b66:	0f 4f c2             	cmovg  %edx,%eax
  801b69:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801b6c:	83 c4 14             	add    $0x14,%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <putch>:

static void
putch(int ch, void *thunk)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b7c:	8b 53 04             	mov    0x4(%ebx),%edx
  801b7f:	8d 42 01             	lea    0x1(%edx),%eax
  801b82:	89 43 04             	mov    %eax,0x4(%ebx)
  801b85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b88:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801b8c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b91:	75 0e                	jne    801ba1 <putch+0x2f>
		writebuf(b);
  801b93:	89 d8                	mov    %ebx,%eax
  801b95:	e8 92 ff ff ff       	call   801b2c <writebuf>
		b->idx = 0;
  801b9a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ba1:	83 c4 04             	add    $0x4,%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801bb9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801bc0:	00 00 00 
	b.result = 0;
  801bc3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bca:	00 00 00 
	b.error = 1;
  801bcd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801bd4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bef:	c7 04 24 72 1b 80 00 	movl   $0x801b72,(%esp)
  801bf6:	e8 d9 e9 ff ff       	call   8005d4 <vprintfmt>
	if (b.idx > 0)
  801bfb:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c02:	7e 0b                	jle    801c0f <vfprintf+0x68>
		writebuf(&b);
  801c04:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c0a:	e8 1d ff ff ff       	call   801b2c <writebuf>

	return (b.result ? b.result : b.error);
  801c0f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c26:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801c29:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	89 04 24             	mov    %eax,(%esp)
  801c3a:	e8 68 ff ff ff       	call   801ba7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <printf>:

int
printf(const char *fmt, ...)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c5c:	e8 46 ff ff ff       	call   801ba7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 10             	sub    $0x10,%esp
  801c6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	89 04 24             	mov    %eax,(%esp)
  801c74:	e8 77 f6 ff ff       	call   8012f0 <fd2data>
  801c79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c7b:	c7 44 24 04 c9 2a 80 	movl   $0x802ac9,0x4(%esp)
  801c82:	00 
  801c83:	89 1c 24             	mov    %ebx,(%esp)
  801c86:	e8 6c ee ff ff       	call   800af7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c8b:	8b 46 04             	mov    0x4(%esi),%eax
  801c8e:	2b 06                	sub    (%esi),%eax
  801c90:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c96:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c9d:	00 00 00 
	stat->st_dev = &devpipe;
  801ca0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ca7:	30 80 00 
	return 0;
}
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	53                   	push   %ebx
  801cba:	83 ec 14             	sub    $0x14,%esp
  801cbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccb:	e8 ea f2 ff ff       	call   800fba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd0:	89 1c 24             	mov    %ebx,(%esp)
  801cd3:	e8 18 f6 ff ff       	call   8012f0 <fd2data>
  801cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce3:	e8 d2 f2 ff ff       	call   800fba <sys_page_unmap>
}
  801ce8:	83 c4 14             	add    $0x14,%esp
  801ceb:	5b                   	pop    %ebx
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 2c             	sub    $0x2c,%esp
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cfc:	a1 20 44 80 00       	mov    0x804420,%eax
  801d01:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d04:	89 34 24             	mov    %esi,(%esp)
  801d07:	e8 19 06 00 00       	call   802325 <pageref>
  801d0c:	89 c7                	mov    %eax,%edi
  801d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 0c 06 00 00       	call   802325 <pageref>
  801d19:	39 c7                	cmp    %eax,%edi
  801d1b:	0f 94 c2             	sete   %dl
  801d1e:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801d21:	8b 0d 20 44 80 00    	mov    0x804420,%ecx
  801d27:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801d2a:	39 fb                	cmp    %edi,%ebx
  801d2c:	74 21                	je     801d4f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d2e:	84 d2                	test   %dl,%dl
  801d30:	74 ca                	je     801cfc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d32:	8b 51 58             	mov    0x58(%ecx),%edx
  801d35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d39:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d41:	c7 04 24 d0 2a 80 00 	movl   $0x802ad0,(%esp)
  801d48:	e8 33 e7 ff ff       	call   800480 <cprintf>
  801d4d:	eb ad                	jmp    801cfc <_pipeisclosed+0xe>
	}
}
  801d4f:	83 c4 2c             	add    $0x2c,%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	57                   	push   %edi
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	83 ec 1c             	sub    $0x1c,%esp
  801d60:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d63:	89 34 24             	mov    %esi,(%esp)
  801d66:	e8 85 f5 ff ff       	call   8012f0 <fd2data>
  801d6b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d72:	eb 45                	jmp    801db9 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d74:	89 da                	mov    %ebx,%edx
  801d76:	89 f0                	mov    %esi,%eax
  801d78:	e8 71 ff ff ff       	call   801cee <_pipeisclosed>
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	75 41                	jne    801dc2 <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d81:	e8 6e f1 ff ff       	call   800ef4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d86:	8b 43 04             	mov    0x4(%ebx),%eax
  801d89:	8b 0b                	mov    (%ebx),%ecx
  801d8b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d8e:	39 d0                	cmp    %edx,%eax
  801d90:	73 e2                	jae    801d74 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d95:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d99:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d9c:	99                   	cltd   
  801d9d:	c1 ea 1b             	shr    $0x1b,%edx
  801da0:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801da3:	83 e1 1f             	and    $0x1f,%ecx
  801da6:	29 d1                	sub    %edx,%ecx
  801da8:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801dac:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801db0:	83 c0 01             	add    $0x1,%eax
  801db3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db6:	83 c7 01             	add    $0x1,%edi
  801db9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dbc:	75 c8                	jne    801d86 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dbe:	89 f8                	mov    %edi,%eax
  801dc0:	eb 05                	jmp    801dc7 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dc7:	83 c4 1c             	add    $0x1c,%esp
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	57                   	push   %edi
  801dd3:	56                   	push   %esi
  801dd4:	53                   	push   %ebx
  801dd5:	83 ec 1c             	sub    $0x1c,%esp
  801dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ddb:	89 3c 24             	mov    %edi,(%esp)
  801dde:	e8 0d f5 ff ff       	call   8012f0 <fd2data>
  801de3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de5:	be 00 00 00 00       	mov    $0x0,%esi
  801dea:	eb 3d                	jmp    801e29 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dec:	85 f6                	test   %esi,%esi
  801dee:	74 04                	je     801df4 <devpipe_read+0x25>
				return i;
  801df0:	89 f0                	mov    %esi,%eax
  801df2:	eb 43                	jmp    801e37 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801df4:	89 da                	mov    %ebx,%edx
  801df6:	89 f8                	mov    %edi,%eax
  801df8:	e8 f1 fe ff ff       	call   801cee <_pipeisclosed>
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	75 31                	jne    801e32 <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e01:	e8 ee f0 ff ff       	call   800ef4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e06:	8b 03                	mov    (%ebx),%eax
  801e08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e0b:	74 df                	je     801dec <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e0d:	99                   	cltd   
  801e0e:	c1 ea 1b             	shr    $0x1b,%edx
  801e11:	01 d0                	add    %edx,%eax
  801e13:	83 e0 1f             	and    $0x1f,%eax
  801e16:	29 d0                	sub    %edx,%eax
  801e18:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e20:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e23:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e26:	83 c6 01             	add    $0x1,%esi
  801e29:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2c:	75 d8                	jne    801e06 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e2e:	89 f0                	mov    %esi,%eax
  801e30:	eb 05                	jmp    801e37 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e37:	83 c4 1c             	add    $0x1c,%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4a:	89 04 24             	mov    %eax,(%esp)
  801e4d:	e8 b5 f4 ff ff       	call   801307 <fd_alloc>
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	85 d2                	test   %edx,%edx
  801e56:	0f 88 4d 01 00 00    	js     801fa9 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e63:	00 
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e72:	e8 9c f0 ff ff       	call   800f13 <sys_page_alloc>
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	85 d2                	test   %edx,%edx
  801e7b:	0f 88 28 01 00 00    	js     801fa9 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 7b f4 ff ff       	call   801307 <fd_alloc>
  801e8c:	89 c3                	mov    %eax,%ebx
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	0f 88 fe 00 00 00    	js     801f94 <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e96:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e9d:	00 
  801e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eac:	e8 62 f0 ff ff       	call   800f13 <sys_page_alloc>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	0f 88 d9 00 00 00    	js     801f94 <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	89 04 24             	mov    %eax,(%esp)
  801ec1:	e8 2a f4 ff ff       	call   8012f0 <fd2data>
  801ec6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ecf:	00 
  801ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edb:	e8 33 f0 ff ff       	call   800f13 <sys_page_alloc>
  801ee0:	89 c3                	mov    %eax,%ebx
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	0f 88 97 00 00 00    	js     801f81 <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eed:	89 04 24             	mov    %eax,(%esp)
  801ef0:	e8 fb f3 ff ff       	call   8012f0 <fd2data>
  801ef5:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801efc:	00 
  801efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f01:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f08:	00 
  801f09:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f14:	e8 4e f0 ff ff       	call   800f67 <sys_page_map>
  801f19:	89 c3                	mov    %eax,%ebx
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 52                	js     801f71 <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f1f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4c:	89 04 24             	mov    %eax,(%esp)
  801f4f:	e8 8c f3 ff ff       	call   8012e0 <fd2num>
  801f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f57:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 7c f3 ff ff       	call   8012e0 <fd2num>
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f67:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6f:	eb 38                	jmp    801fa9 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  801f71:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7c:	e8 39 f0 ff ff       	call   800fba <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8f:	e8 26 f0 ff ff       	call   800fba <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa2:	e8 13 f0 ff ff       	call   800fba <sys_page_unmap>
  801fa7:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801fa9:	83 c4 30             	add    $0x30,%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	89 04 24             	mov    %eax,(%esp)
  801fc3:	e8 8e f3 ff ff       	call   801356 <fd_lookup>
  801fc8:	89 c2                	mov    %eax,%edx
  801fca:	85 d2                	test   %edx,%edx
  801fcc:	78 15                	js     801fe3 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd1:	89 04 24             	mov    %eax,(%esp)
  801fd4:	e8 17 f3 ff ff       	call   8012f0 <fd2data>
	return _pipeisclosed(fd, p);
  801fd9:	89 c2                	mov    %eax,%edx
  801fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fde:	e8 0b fd ff ff       	call   801cee <_pipeisclosed>
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    
  801fe5:	66 90                	xchg   %ax,%ax
  801fe7:	66 90                	xchg   %ax,%ax
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802000:	c7 44 24 04 e8 2a 80 	movl   $0x802ae8,0x4(%esp)
  802007:	00 
  802008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 e4 ea ff ff       	call   800af7 <strcpy>
	return 0;
}
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802026:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80202b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802031:	eb 31                	jmp    802064 <devcons_write+0x4a>
		m = n - tot;
  802033:	8b 75 10             	mov    0x10(%ebp),%esi
  802036:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802038:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80203b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802040:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802043:	89 74 24 08          	mov    %esi,0x8(%esp)
  802047:	03 45 0c             	add    0xc(%ebp),%eax
  80204a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204e:	89 3c 24             	mov    %edi,(%esp)
  802051:	e8 3e ec ff ff       	call   800c94 <memmove>
		sys_cputs(buf, m);
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	89 3c 24             	mov    %edi,(%esp)
  80205d:	e8 e4 ed ff ff       	call   800e46 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802062:	01 f3                	add    %esi,%ebx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802069:	72 c8                	jb     802033 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80206b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80207c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802081:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802085:	75 07                	jne    80208e <devcons_read+0x18>
  802087:	eb 2a                	jmp    8020b3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802089:	e8 66 ee ff ff       	call   800ef4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80208e:	66 90                	xchg   %ax,%ax
  802090:	e8 cf ed ff ff       	call   800e64 <sys_cgetc>
  802095:	85 c0                	test   %eax,%eax
  802097:	74 f0                	je     802089 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802099:	85 c0                	test   %eax,%eax
  80209b:	78 16                	js     8020b3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80209d:	83 f8 04             	cmp    $0x4,%eax
  8020a0:	74 0c                	je     8020ae <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8020a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a5:	88 02                	mov    %al,(%edx)
	return 1;
  8020a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ac:	eb 05                	jmp    8020b3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020be:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020c8:	00 
  8020c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cc:	89 04 24             	mov    %eax,(%esp)
  8020cf:	e8 72 ed ff ff       	call   800e46 <sys_cputs>
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <getchar>:

int
getchar(void)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020dc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020e3:	00 
  8020e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f2:	e8 ee f4 ff ff       	call   8015e5 <read>
	if (r < 0)
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 0f                	js     80210a <getchar+0x34>
		return r;
	if (r < 1)
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	7e 06                	jle    802105 <getchar+0x2f>
		return -E_EOF;
	return c;
  8020ff:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802103:	eb 05                	jmp    80210a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802105:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802115:	89 44 24 04          	mov    %eax,0x4(%esp)
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	89 04 24             	mov    %eax,(%esp)
  80211f:	e8 32 f2 ff ff       	call   801356 <fd_lookup>
  802124:	85 c0                	test   %eax,%eax
  802126:	78 11                	js     802139 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802131:	39 10                	cmp    %edx,(%eax)
  802133:	0f 94 c0             	sete   %al
  802136:	0f b6 c0             	movzbl %al,%eax
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    

0080213b <opencons>:

int
opencons(void)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802141:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802144:	89 04 24             	mov    %eax,(%esp)
  802147:	e8 bb f1 ff ff       	call   801307 <fd_alloc>
		return r;
  80214c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 40                	js     802192 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802152:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802159:	00 
  80215a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802168:	e8 a6 ed ff ff       	call   800f13 <sys_page_alloc>
		return r;
  80216d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 1f                	js     802192 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802173:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802188:	89 04 24             	mov    %eax,(%esp)
  80218b:	e8 50 f1 ff ff       	call   8012e0 <fd2num>
  802190:	89 c2                	mov    %eax,%edx
}
  802192:	89 d0                	mov    %edx,%eax
  802194:	c9                   	leave  
  802195:	c3                   	ret    
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	56                   	push   %esi
  8021a4:	53                   	push   %ebx
  8021a5:	83 ec 10             	sub    $0x10,%esp
  8021a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	75 0e                	jne    8021c3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8021b5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8021bc:	e8 68 ef ff ff       	call   801129 <sys_ipc_recv>
  8021c1:	eb 08                	jmp    8021cb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8021c3:	89 04 24             	mov    %eax,(%esp)
  8021c6:	e8 5e ef ff ff       	call   801129 <sys_ipc_recv>
	if(r == 0){
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	75 1e                	jne    8021f0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8021d2:	85 f6                	test   %esi,%esi
  8021d4:	74 0a                	je     8021e0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8021d6:	a1 20 44 80 00       	mov    0x804420,%eax
  8021db:	8b 40 74             	mov    0x74(%eax),%eax
  8021de:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  8021e0:	85 db                	test   %ebx,%ebx
  8021e2:	74 2c                	je     802210 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  8021e4:	a1 20 44 80 00       	mov    0x804420,%eax
  8021e9:	8b 40 78             	mov    0x78(%eax),%eax
  8021ec:	89 03                	mov    %eax,(%ebx)
  8021ee:	eb 20                	jmp    802210 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8021f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f4:	c7 44 24 08 f4 2a 80 	movl   $0x802af4,0x8(%esp)
  8021fb:	00 
  8021fc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  802203:	00 
  802204:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  80220b:	e8 77 e1 ff ff       	call   800387 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  802210:	a1 20 44 80 00       	mov    0x804420,%eax
  802215:	8b 50 70             	mov    0x70(%eax),%edx
  802218:	85 d2                	test   %edx,%edx
  80221a:	75 13                	jne    80222f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80221c:	8b 40 48             	mov    0x48(%eax),%eax
  80221f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802223:	c7 04 24 24 2b 80 00 	movl   $0x802b24,(%esp)
  80222a:	e8 51 e2 ff ff       	call   800480 <cprintf>
	return thisenv->env_ipc_value;
  80222f:	a1 20 44 80 00       	mov    0x804420,%eax
  802234:	8b 40 70             	mov    0x70(%eax),%eax
}
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	5b                   	pop    %ebx
  80223b:	5e                   	pop    %esi
  80223c:	5d                   	pop    %ebp
  80223d:	c3                   	ret    

0080223e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80223e:	55                   	push   %ebp
  80223f:	89 e5                	mov    %esp,%ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 7d 08             	mov    0x8(%ebp),%edi
  80224a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80224d:	85 f6                	test   %esi,%esi
  80224f:	75 22                	jne    802273 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802251:	8b 45 14             	mov    0x14(%ebp),%eax
  802254:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802258:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80225f:	ee 
  802260:	8b 45 0c             	mov    0xc(%ebp),%eax
  802263:	89 44 24 04          	mov    %eax,0x4(%esp)
  802267:	89 3c 24             	mov    %edi,(%esp)
  80226a:	e8 97 ee ff ff       	call   801106 <sys_ipc_try_send>
  80226f:	89 c3                	mov    %eax,%ebx
  802271:	eb 1c                	jmp    80228f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802273:	8b 45 14             	mov    0x14(%ebp),%eax
  802276:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80227e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802281:	89 44 24 04          	mov    %eax,0x4(%esp)
  802285:	89 3c 24             	mov    %edi,(%esp)
  802288:	e8 79 ee ff ff       	call   801106 <sys_ipc_try_send>
  80228d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80228f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802292:	74 3e                	je     8022d2 <ipc_send+0x94>
  802294:	89 d8                	mov    %ebx,%eax
  802296:	c1 e8 1f             	shr    $0x1f,%eax
  802299:	84 c0                	test   %al,%al
  80229b:	74 35                	je     8022d2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80229d:	e8 33 ec ff ff       	call   800ed5 <sys_getenvid>
  8022a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a6:	c7 04 24 7a 2b 80 00 	movl   $0x802b7a,(%esp)
  8022ad:	e8 ce e1 ff ff       	call   800480 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8022b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022b6:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  8022bd:	00 
  8022be:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8022c5:	00 
  8022c6:	c7 04 24 70 2b 80 00 	movl   $0x802b70,(%esp)
  8022cd:	e8 b5 e0 ff ff       	call   800387 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8022d2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8022d5:	75 0e                	jne    8022e5 <ipc_send+0xa7>
			sys_yield();
  8022d7:	e8 18 ec ff ff       	call   800ef4 <sys_yield>
		else break;
	}
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	e9 68 ff ff ff       	jmp    80224d <ipc_send+0xf>
	
}
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    

008022ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802301:	8b 52 50             	mov    0x50(%edx),%edx
  802304:	39 ca                	cmp    %ecx,%edx
  802306:	75 0d                	jne    802315 <ipc_find_env+0x28>
			return envs[i].env_id;
  802308:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80230b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802310:	8b 40 40             	mov    0x40(%eax),%eax
  802313:	eb 0e                	jmp    802323 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802315:	83 c0 01             	add    $0x1,%eax
  802318:	3d 00 04 00 00       	cmp    $0x400,%eax
  80231d:	75 d9                	jne    8022f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80231f:	66 b8 00 00          	mov    $0x0,%ax
}
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    

00802325 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	c1 e8 16             	shr    $0x16,%eax
  802330:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802337:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80233c:	f6 c1 01             	test   $0x1,%cl
  80233f:	74 1d                	je     80235e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802341:	c1 ea 0c             	shr    $0xc,%edx
  802344:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80234b:	f6 c2 01             	test   $0x1,%dl
  80234e:	74 0e                	je     80235e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802350:	c1 ea 0c             	shr    $0xc,%edx
  802353:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80235a:	ef 
  80235b:	0f b7 c0             	movzwl %ax,%eax
}
  80235e:	5d                   	pop    %ebp
  80235f:	c3                   	ret    

00802360 <__udivdi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 0c             	sub    $0xc,%esp
  802366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80236a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80236e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802372:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802376:	85 c0                	test   %eax,%eax
  802378:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80237c:	89 ea                	mov    %ebp,%edx
  80237e:	89 0c 24             	mov    %ecx,(%esp)
  802381:	75 2d                	jne    8023b0 <__udivdi3+0x50>
  802383:	39 e9                	cmp    %ebp,%ecx
  802385:	77 61                	ja     8023e8 <__udivdi3+0x88>
  802387:	85 c9                	test   %ecx,%ecx
  802389:	89 ce                	mov    %ecx,%esi
  80238b:	75 0b                	jne    802398 <__udivdi3+0x38>
  80238d:	b8 01 00 00 00       	mov    $0x1,%eax
  802392:	31 d2                	xor    %edx,%edx
  802394:	f7 f1                	div    %ecx
  802396:	89 c6                	mov    %eax,%esi
  802398:	31 d2                	xor    %edx,%edx
  80239a:	89 e8                	mov    %ebp,%eax
  80239c:	f7 f6                	div    %esi
  80239e:	89 c5                	mov    %eax,%ebp
  8023a0:	89 f8                	mov    %edi,%eax
  8023a2:	f7 f6                	div    %esi
  8023a4:	89 ea                	mov    %ebp,%edx
  8023a6:	83 c4 0c             	add    $0xc,%esp
  8023a9:	5e                   	pop    %esi
  8023aa:	5f                   	pop    %edi
  8023ab:	5d                   	pop    %ebp
  8023ac:	c3                   	ret    
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	39 e8                	cmp    %ebp,%eax
  8023b2:	77 24                	ja     8023d8 <__udivdi3+0x78>
  8023b4:	0f bd e8             	bsr    %eax,%ebp
  8023b7:	83 f5 1f             	xor    $0x1f,%ebp
  8023ba:	75 3c                	jne    8023f8 <__udivdi3+0x98>
  8023bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023c0:	39 34 24             	cmp    %esi,(%esp)
  8023c3:	0f 86 9f 00 00 00    	jbe    802468 <__udivdi3+0x108>
  8023c9:	39 d0                	cmp    %edx,%eax
  8023cb:	0f 82 97 00 00 00    	jb     802468 <__udivdi3+0x108>
  8023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	31 c0                	xor    %eax,%eax
  8023dc:	83 c4 0c             	add    $0xc,%esp
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	89 f8                	mov    %edi,%eax
  8023ea:	f7 f1                	div    %ecx
  8023ec:	31 d2                	xor    %edx,%edx
  8023ee:	83 c4 0c             	add    $0xc,%esp
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	8b 3c 24             	mov    (%esp),%edi
  8023fd:	d3 e0                	shl    %cl,%eax
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	b8 20 00 00 00       	mov    $0x20,%eax
  802406:	29 e8                	sub    %ebp,%eax
  802408:	89 c1                	mov    %eax,%ecx
  80240a:	d3 ef                	shr    %cl,%edi
  80240c:	89 e9                	mov    %ebp,%ecx
  80240e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802412:	8b 3c 24             	mov    (%esp),%edi
  802415:	09 74 24 08          	or     %esi,0x8(%esp)
  802419:	89 d6                	mov    %edx,%esi
  80241b:	d3 e7                	shl    %cl,%edi
  80241d:	89 c1                	mov    %eax,%ecx
  80241f:	89 3c 24             	mov    %edi,(%esp)
  802422:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802426:	d3 ee                	shr    %cl,%esi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	d3 e2                	shl    %cl,%edx
  80242c:	89 c1                	mov    %eax,%ecx
  80242e:	d3 ef                	shr    %cl,%edi
  802430:	09 d7                	or     %edx,%edi
  802432:	89 f2                	mov    %esi,%edx
  802434:	89 f8                	mov    %edi,%eax
  802436:	f7 74 24 08          	divl   0x8(%esp)
  80243a:	89 d6                	mov    %edx,%esi
  80243c:	89 c7                	mov    %eax,%edi
  80243e:	f7 24 24             	mull   (%esp)
  802441:	39 d6                	cmp    %edx,%esi
  802443:	89 14 24             	mov    %edx,(%esp)
  802446:	72 30                	jb     802478 <__udivdi3+0x118>
  802448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80244c:	89 e9                	mov    %ebp,%ecx
  80244e:	d3 e2                	shl    %cl,%edx
  802450:	39 c2                	cmp    %eax,%edx
  802452:	73 05                	jae    802459 <__udivdi3+0xf9>
  802454:	3b 34 24             	cmp    (%esp),%esi
  802457:	74 1f                	je     802478 <__udivdi3+0x118>
  802459:	89 f8                	mov    %edi,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	e9 7a ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	31 d2                	xor    %edx,%edx
  80246a:	b8 01 00 00 00       	mov    $0x1,%eax
  80246f:	e9 68 ff ff ff       	jmp    8023dc <__udivdi3+0x7c>
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	8d 47 ff             	lea    -0x1(%edi),%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	83 c4 0c             	add    $0xc,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	66 90                	xchg   %ax,%ax
  802486:	66 90                	xchg   %ax,%ax
  802488:	66 90                	xchg   %ax,%ax
  80248a:	66 90                	xchg   %ax,%ax
  80248c:	66 90                	xchg   %ax,%ax
  80248e:	66 90                	xchg   %ax,%ax

00802490 <__umoddi3>:
  802490:	55                   	push   %ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	83 ec 14             	sub    $0x14,%esp
  802496:	8b 44 24 28          	mov    0x28(%esp),%eax
  80249a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80249e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8024a2:	89 c7                	mov    %eax,%edi
  8024a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8024b0:	89 34 24             	mov    %esi,(%esp)
  8024b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024bf:	75 17                	jne    8024d8 <__umoddi3+0x48>
  8024c1:	39 fe                	cmp    %edi,%esi
  8024c3:	76 4b                	jbe    802510 <__umoddi3+0x80>
  8024c5:	89 c8                	mov    %ecx,%eax
  8024c7:	89 fa                	mov    %edi,%edx
  8024c9:	f7 f6                	div    %esi
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	31 d2                	xor    %edx,%edx
  8024cf:	83 c4 14             	add    $0x14,%esp
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	5d                   	pop    %ebp
  8024d5:	c3                   	ret    
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	39 f8                	cmp    %edi,%eax
  8024da:	77 54                	ja     802530 <__umoddi3+0xa0>
  8024dc:	0f bd e8             	bsr    %eax,%ebp
  8024df:	83 f5 1f             	xor    $0x1f,%ebp
  8024e2:	75 5c                	jne    802540 <__umoddi3+0xb0>
  8024e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8024e8:	39 3c 24             	cmp    %edi,(%esp)
  8024eb:	0f 87 e7 00 00 00    	ja     8025d8 <__umoddi3+0x148>
  8024f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024f5:	29 f1                	sub    %esi,%ecx
  8024f7:	19 c7                	sbb    %eax,%edi
  8024f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802501:	8b 44 24 08          	mov    0x8(%esp),%eax
  802505:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802509:	83 c4 14             	add    $0x14,%esp
  80250c:	5e                   	pop    %esi
  80250d:	5f                   	pop    %edi
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    
  802510:	85 f6                	test   %esi,%esi
  802512:	89 f5                	mov    %esi,%ebp
  802514:	75 0b                	jne    802521 <__umoddi3+0x91>
  802516:	b8 01 00 00 00       	mov    $0x1,%eax
  80251b:	31 d2                	xor    %edx,%edx
  80251d:	f7 f6                	div    %esi
  80251f:	89 c5                	mov    %eax,%ebp
  802521:	8b 44 24 04          	mov    0x4(%esp),%eax
  802525:	31 d2                	xor    %edx,%edx
  802527:	f7 f5                	div    %ebp
  802529:	89 c8                	mov    %ecx,%eax
  80252b:	f7 f5                	div    %ebp
  80252d:	eb 9c                	jmp    8024cb <__umoddi3+0x3b>
  80252f:	90                   	nop
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 fa                	mov    %edi,%edx
  802534:	83 c4 14             	add    $0x14,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
  80253c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802540:	8b 04 24             	mov    (%esp),%eax
  802543:	be 20 00 00 00       	mov    $0x20,%esi
  802548:	89 e9                	mov    %ebp,%ecx
  80254a:	29 ee                	sub    %ebp,%esi
  80254c:	d3 e2                	shl    %cl,%edx
  80254e:	89 f1                	mov    %esi,%ecx
  802550:	d3 e8                	shr    %cl,%eax
  802552:	89 e9                	mov    %ebp,%ecx
  802554:	89 44 24 04          	mov    %eax,0x4(%esp)
  802558:	8b 04 24             	mov    (%esp),%eax
  80255b:	09 54 24 04          	or     %edx,0x4(%esp)
  80255f:	89 fa                	mov    %edi,%edx
  802561:	d3 e0                	shl    %cl,%eax
  802563:	89 f1                	mov    %esi,%ecx
  802565:	89 44 24 08          	mov    %eax,0x8(%esp)
  802569:	8b 44 24 10          	mov    0x10(%esp),%eax
  80256d:	d3 ea                	shr    %cl,%edx
  80256f:	89 e9                	mov    %ebp,%ecx
  802571:	d3 e7                	shl    %cl,%edi
  802573:	89 f1                	mov    %esi,%ecx
  802575:	d3 e8                	shr    %cl,%eax
  802577:	89 e9                	mov    %ebp,%ecx
  802579:	09 f8                	or     %edi,%eax
  80257b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80257f:	f7 74 24 04          	divl   0x4(%esp)
  802583:	d3 e7                	shl    %cl,%edi
  802585:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802589:	89 d7                	mov    %edx,%edi
  80258b:	f7 64 24 08          	mull   0x8(%esp)
  80258f:	39 d7                	cmp    %edx,%edi
  802591:	89 c1                	mov    %eax,%ecx
  802593:	89 14 24             	mov    %edx,(%esp)
  802596:	72 2c                	jb     8025c4 <__umoddi3+0x134>
  802598:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80259c:	72 22                	jb     8025c0 <__umoddi3+0x130>
  80259e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025a2:	29 c8                	sub    %ecx,%eax
  8025a4:	19 d7                	sbb    %edx,%edi
  8025a6:	89 e9                	mov    %ebp,%ecx
  8025a8:	89 fa                	mov    %edi,%edx
  8025aa:	d3 e8                	shr    %cl,%eax
  8025ac:	89 f1                	mov    %esi,%ecx
  8025ae:	d3 e2                	shl    %cl,%edx
  8025b0:	89 e9                	mov    %ebp,%ecx
  8025b2:	d3 ef                	shr    %cl,%edi
  8025b4:	09 d0                	or     %edx,%eax
  8025b6:	89 fa                	mov    %edi,%edx
  8025b8:	83 c4 14             	add    $0x14,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	39 d7                	cmp    %edx,%edi
  8025c2:	75 da                	jne    80259e <__umoddi3+0x10e>
  8025c4:	8b 14 24             	mov    (%esp),%edx
  8025c7:	89 c1                	mov    %eax,%ecx
  8025c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8025cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8025d1:	eb cb                	jmp    80259e <__umoddi3+0x10e>
  8025d3:	90                   	nop
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8025dc:	0f 82 0f ff ff ff    	jb     8024f1 <__umoddi3+0x61>
  8025e2:	e9 1a ff ff ff       	jmp    802501 <__umoddi3+0x71>
