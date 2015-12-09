
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 95 09 00 00       	call   8009c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  80004f:	85 db                	test   %ebx,%ebx
  800051:	75 28                	jne    80007b <_gettoken+0x3b>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800053:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  800058:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80005f:	0f 8e 33 01 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("GETTOKEN NULL\n");
  800065:	c7 04 24 60 36 80 00 	movl   $0x803660,(%esp)
  80006c:	e8 aa 0a 00 00       	call   800b1b <cprintf>
		return 0;
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
  800076:	e9 1d 01 00 00       	jmp    800198 <_gettoken+0x158>
	}

	if (debug > 1)
  80007b:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800082:	7e 10                	jle    800094 <_gettoken+0x54>
		cprintf("GETTOKEN: %s\n", s);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	c7 04 24 6f 36 80 00 	movl   $0x80366f,(%esp)
  80008f:	e8 87 0a 00 00       	call   800b1b <cprintf>

	*p1 = 0;
  800094:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  80009a:	8b 45 10             	mov    0x10(%ebp),%eax
  80009d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  8000a3:	eb 07                	jmp    8000ac <_gettoken+0x6c>
		*s++ = 0;
  8000a5:	83 c3 01             	add    $0x1,%ebx
  8000a8:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000ac:	0f be 03             	movsbl (%ebx),%eax
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	c7 04 24 7d 36 80 00 	movl   $0x80367d,(%esp)
  8000ba:	e8 db 12 00 00       	call   80139a <strchr>
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	75 e2                	jne    8000a5 <_gettoken+0x65>
  8000c3:	89 df                	mov    %ebx,%edi
		*s++ = 0;
	if (*s == 0) {
  8000c5:	0f b6 03             	movzbl (%ebx),%eax
  8000c8:	84 c0                	test   %al,%al
  8000ca:	75 28                	jne    8000f4 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000cc:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000d1:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000d8:	0f 8e ba 00 00 00    	jle    800198 <_gettoken+0x158>
			cprintf("EOL\n");
  8000de:	c7 04 24 82 36 80 00 	movl   $0x803682,(%esp)
  8000e5:	e8 31 0a 00 00       	call   800b1b <cprintf>
		return 0;
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	e9 a4 00 00 00       	jmp    800198 <_gettoken+0x158>
	}
	if (strchr(SYMBOLS, *s)) {
  8000f4:	0f be c0             	movsbl %al,%eax
  8000f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fb:	c7 04 24 93 36 80 00 	movl   $0x803693,(%esp)
  800102:	e8 93 12 00 00       	call   80139a <strchr>
  800107:	85 c0                	test   %eax,%eax
  800109:	74 2f                	je     80013a <_gettoken+0xfa>
		t = *s;
  80010b:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  80010e:	89 3e                	mov    %edi,(%esi)
		*s++ = 0;
  800110:	c6 07 00             	movb   $0x0,(%edi)
  800113:	83 c7 01             	add    $0x1,%edi
  800116:	8b 45 10             	mov    0x10(%ebp),%eax
  800119:	89 38                	mov    %edi,(%eax)
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  80011b:	89 d8                	mov    %ebx,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  80011d:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800124:	7e 72                	jle    800198 <_gettoken+0x158>
			cprintf("TOK %c\n", t);
  800126:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012a:	c7 04 24 87 36 80 00 	movl   $0x803687,(%esp)
  800131:	e8 e5 09 00 00       	call   800b1b <cprintf>
		return t;
  800136:	89 d8                	mov    %ebx,%eax
  800138:	eb 5e                	jmp    800198 <_gettoken+0x158>
	}
	*p1 = s;
  80013a:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013c:	eb 03                	jmp    800141 <_gettoken+0x101>
		s++;
  80013e:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800141:	0f b6 03             	movzbl (%ebx),%eax
  800144:	84 c0                	test   %al,%al
  800146:	74 17                	je     80015f <_gettoken+0x11f>
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 8f 36 80 00 	movl   $0x80368f,(%esp)
  800156:	e8 3f 12 00 00       	call   80139a <strchr>
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 df                	je     80013e <_gettoken+0xfe>
		s++;
	*p2 = s;
  80015f:	8b 45 10             	mov    0x10(%ebp),%eax
  800162:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800164:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800169:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800170:	7e 26                	jle    800198 <_gettoken+0x158>
		t = **p2;
  800172:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	8b 06                	mov    (%esi),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 9b 36 80 00 	movl   $0x80369b,(%esp)
  800185:	e8 91 09 00 00       	call   800b1b <cprintf>
		**p2 = t;
  80018a:	8b 45 10             	mov    0x10(%ebp),%eax
  80018d:	8b 00                	mov    (%eax),%eax
  80018f:	89 fa                	mov    %edi,%edx
  800191:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800193:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800198:	83 c4 1c             	add    $0x1c,%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	74 24                	je     8001d1 <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  8001ad:	c7 44 24 08 0c 60 80 	movl   $0x80600c,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 10 60 80 	movl   $0x806010,0x4(%esp)
  8001bc:	00 
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 7b fe ff ff       	call   800040 <_gettoken>
  8001c5:	a3 08 60 80 00       	mov    %eax,0x806008
		return 0;
  8001ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cf:	eb 3c                	jmp    80020d <gettoken+0x6d>
	}
	c = nc;
  8001d1:	a1 08 60 80 00       	mov    0x806008,%eax
  8001d6:	a3 04 60 80 00       	mov    %eax,0x806004
	*p1 = np1;
  8001db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001de:	8b 15 10 60 80 00    	mov    0x806010,%edx
  8001e4:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e6:	c7 44 24 08 0c 60 80 	movl   $0x80600c,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 10 60 80 	movl   $0x806010,0x4(%esp)
  8001f5:	00 
  8001f6:	a1 0c 60 80 00       	mov    0x80600c,%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 3d fe ff ff       	call   800040 <_gettoken>
  800203:	a3 08 60 80 00       	mov    %eax,0x806008
	return c;
  800208:	a1 04 60 80 00       	mov    0x806004,%eax
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  80021b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800222:	00 
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 72 ff ff ff       	call   8001a0 <gettoken>

again:
	argc = 0;
  80022e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800233:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 5a ff ff ff       	call   8001a0 <gettoken>
  800246:	83 f8 3e             	cmp    $0x3e,%eax
  800249:	0f 84 95 00 00 00    	je     8002e4 <runcmd+0xd5>
  80024f:	83 f8 3e             	cmp    $0x3e,%eax
  800252:	7f 13                	jg     800267 <runcmd+0x58>
  800254:	85 c0                	test   %eax,%eax
  800256:	0f 84 16 02 00 00    	je     800472 <runcmd+0x263>
  80025c:	83 f8 3c             	cmp    $0x3c,%eax
  80025f:	90                   	nop
  800260:	74 3d                	je     80029f <runcmd+0x90>
  800262:	e9 eb 01 00 00       	jmp    800452 <runcmd+0x243>
  800267:	83 f8 77             	cmp    $0x77,%eax
  80026a:	74 0f                	je     80027b <runcmd+0x6c>
  80026c:	83 f8 7c             	cmp    $0x7c,%eax
  80026f:	90                   	nop
  800270:	0f 84 ef 00 00 00    	je     800365 <runcmd+0x156>
  800276:	e9 d7 01 00 00       	jmp    800452 <runcmd+0x243>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80027b:	83 fe 10             	cmp    $0x10,%esi
  80027e:	66 90                	xchg   %ax,%ax
  800280:	75 11                	jne    800293 <runcmd+0x84>
				cprintf("too many arguments\n");
  800282:	c7 04 24 a5 36 80 00 	movl   $0x8036a5,(%esp)
  800289:	e8 8d 08 00 00       	call   800b1b <cprintf>
				exit();
  80028e:	e8 7b 07 00 00       	call   800a0e <exit>
			}
			argv[argc++] = t;
  800293:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800296:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80029a:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80029d:	eb 97                	jmp    800236 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80029f:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  8002a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ad:	e8 ee fe ff ff       	call   8001a0 <gettoken>
  8002b2:	83 f8 77             	cmp    $0x77,%eax
  8002b5:	74 11                	je     8002c8 <runcmd+0xb9>
				cprintf("syntax error: < not followed by word\n");
  8002b7:	c7 04 24 00 38 80 00 	movl   $0x803800,(%esp)
  8002be:	e8 58 08 00 00       	call   800b1b <cprintf>
				exit();
  8002c3:	e8 46 07 00 00       	call   800a0e <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002c8:	c7 44 24 08 b9 36 80 	movl   $0x8036b9,0x8(%esp)
  8002cf:	00 
  8002d0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8002d7:	00 
  8002d8:	c7 04 24 d7 36 80 00 	movl   $0x8036d7,(%esp)
  8002df:	e8 3e 07 00 00       	call   800a22 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ef:	e8 ac fe ff ff       	call   8001a0 <gettoken>
  8002f4:	83 f8 77             	cmp    $0x77,%eax
  8002f7:	74 11                	je     80030a <runcmd+0xfb>
				cprintf("syntax error: > not followed by word\n");
  8002f9:	c7 04 24 28 38 80 00 	movl   $0x803828,(%esp)
  800300:	e8 16 08 00 00       	call   800b1b <cprintf>
				exit();
  800305:	e8 04 07 00 00       	call   800a0e <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80030a:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800311:	00 
  800312:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	e8 a4 22 00 00       	call   8025c1 <open>
  80031d:	89 c7                	mov    %eax,%edi
  80031f:	85 c0                	test   %eax,%eax
  800321:	79 1c                	jns    80033f <runcmd+0x130>
				cprintf("open %s for write: %e", t, fd);
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 e1 36 80 00 	movl   $0x8036e1,(%esp)
  800335:	e8 e1 07 00 00       	call   800b1b <cprintf>
				exit();
  80033a:	e8 cf 06 00 00       	call   800a0e <exit>
			}
			if (fd != 1) {
  80033f:	83 ff 01             	cmp    $0x1,%edi
  800342:	0f 84 ee fe ff ff    	je     800236 <runcmd+0x27>
				dup(fd, 1);
  800348:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034f:	00 
  800350:	89 3c 24             	mov    %edi,(%esp)
  800353:	e8 af 1c 00 00       	call   802007 <dup>
				close(fd);
  800358:	89 3c 24             	mov    %edi,(%esp)
  80035b:	e8 52 1c 00 00       	call   801fb2 <close>
  800360:	e9 d1 fe ff ff       	jmp    800236 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800365:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 b7 2b 00 00       	call   802f2a <pipe>
  800373:	85 c0                	test   %eax,%eax
  800375:	79 15                	jns    80038c <runcmd+0x17d>
				cprintf("pipe: %e", r);
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	c7 04 24 f7 36 80 00 	movl   $0x8036f7,(%esp)
  800382:	e8 94 07 00 00       	call   800b1b <cprintf>
				exit();
  800387:	e8 82 06 00 00       	call   800a0e <exit>
			}
			if (debug)
  80038c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800393:	74 20                	je     8003b5 <runcmd+0x1a6>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800395:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80039b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039f:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	c7 04 24 00 37 80 00 	movl   $0x803700,(%esp)
  8003b0:	e8 66 07 00 00       	call   800b1b <cprintf>
			if ((r = fork()) < 0) {
  8003b5:	e8 bb 16 00 00       	call   801a75 <fork>
  8003ba:	89 c7                	mov    %eax,%edi
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	79 15                	jns    8003d5 <runcmd+0x1c6>
				cprintf("fork: %e", r);
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 0d 37 80 00 	movl   $0x80370d,(%esp)
  8003cb:	e8 4b 07 00 00       	call   800b1b <cprintf>
				exit();
  8003d0:	e8 39 06 00 00       	call   800a0e <exit>
			}
			if (r == 0) {
  8003d5:	85 ff                	test   %edi,%edi
  8003d7:	75 40                	jne    800419 <runcmd+0x20a>
				if (p[0] != 0) {
  8003d9:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	74 1e                	je     800401 <runcmd+0x1f2>
					dup(p[0], 0);
  8003e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ea:	00 
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	e8 14 1c 00 00       	call   802007 <dup>
					close(p[0]);
  8003f3:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003f9:	89 04 24             	mov    %eax,(%esp)
  8003fc:	e8 b1 1b 00 00       	call   801fb2 <close>
				}
				close(p[1]);
  800401:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	e8 a3 1b 00 00       	call   801fb2 <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  80040f:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  800414:	e9 1d fe ff ff       	jmp    800236 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800419:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80041f:	83 f8 01             	cmp    $0x1,%eax
  800422:	74 1e                	je     800442 <runcmd+0x233>
					dup(p[1], 1);
  800424:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80042b:	00 
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 d3 1b 00 00       	call   802007 <dup>
					close(p[1]);
  800434:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	e8 70 1b 00 00       	call   801fb2 <close>
				}
				close(p[0]);
  800442:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 62 1b 00 00       	call   801fb2 <close>
				goto runit;
  800450:	eb 25                	jmp    800477 <runcmd+0x268>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800456:	c7 44 24 08 16 37 80 	movl   $0x803716,0x8(%esp)
  80045d:	00 
  80045e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800465:	00 
  800466:	c7 04 24 d7 36 80 00 	movl   $0x8036d7,(%esp)
  80046d:	e8 b0 05 00 00       	call   800a22 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800472:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800477:	85 f6                	test   %esi,%esi
  800479:	75 1e                	jne    800499 <runcmd+0x28a>
		if (debug)
  80047b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800482:	0f 84 85 01 00 00    	je     80060d <runcmd+0x3fe>
			cprintf("EMPTY COMMAND\n");
  800488:	c7 04 24 32 37 80 00 	movl   $0x803732,(%esp)
  80048f:	e8 87 06 00 00       	call   800b1b <cprintf>
  800494:	e9 74 01 00 00       	jmp    80060d <runcmd+0x3fe>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  800499:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80049c:	80 38 2f             	cmpb   $0x2f,(%eax)
  80049f:	74 22                	je     8004c3 <runcmd+0x2b4>
		argv0buf[0] = '/';
  8004a1:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004b2:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	e8 c7 0d 00 00       	call   801287 <strcpy>
		argv[0] = argv0buf;
  8004c0:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004c3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004ca:	00 

	// Print the command.
	if (debug) {
  8004cb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004d2:	74 43                	je     800517 <runcmd+0x308>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004d4:	a1 24 64 80 00       	mov    0x806424,%eax
  8004d9:	8b 40 48             	mov    0x48(%eax),%eax
  8004dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e0:	c7 04 24 41 37 80 00 	movl   $0x803741,(%esp)
  8004e7:	e8 2f 06 00 00       	call   800b1b <cprintf>
  8004ec:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004ef:	eb 10                	jmp    800501 <runcmd+0x2f2>
			cprintf(" %s", argv[i]);
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	c7 04 24 cc 37 80 00 	movl   $0x8037cc,(%esp)
  8004fc:	e8 1a 06 00 00       	call   800b1b <cprintf>
  800501:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800504:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	75 e6                	jne    8004f1 <runcmd+0x2e2>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80050b:	c7 04 24 80 36 80 00 	movl   $0x803680,(%esp)
  800512:	e8 04 06 00 00       	call   800b1b <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800517:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80051a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 77 22 00 00       	call   8027a0 <spawn>
  800529:	89 c3                	mov    %eax,%ebx
  80052b:	85 c0                	test   %eax,%eax
  80052d:	0f 89 c3 00 00 00    	jns    8005f6 <runcmd+0x3e7>
		cprintf("spawn %s: %e\n", argv[0], r);
  800533:	89 44 24 08          	mov    %eax,0x8(%esp)
  800537:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80053a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053e:	c7 04 24 4f 37 80 00 	movl   $0x80374f,(%esp)
  800545:	e8 d1 05 00 00       	call   800b1b <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80054a:	e8 96 1a 00 00       	call   801fe5 <close_all>
  80054f:	eb 4c                	jmp    80059d <runcmd+0x38e>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800551:	a1 24 64 80 00       	mov    0x806424,%eax
  800556:	8b 40 48             	mov    0x48(%eax),%eax
  800559:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80055d:	8b 55 a8             	mov    -0x58(%ebp),%edx
  800560:	89 54 24 08          	mov    %edx,0x8(%esp)
  800564:	89 44 24 04          	mov    %eax,0x4(%esp)
  800568:	c7 04 24 5d 37 80 00 	movl   $0x80375d,(%esp)
  80056f:	e8 a7 05 00 00       	call   800b1b <cprintf>
		wait(r);
  800574:	89 1c 24             	mov    %ebx,(%esp)
  800577:	e8 54 2b 00 00       	call   8030d0 <wait>
		if (debug)
  80057c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800583:	74 18                	je     80059d <runcmd+0x38e>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800585:	a1 24 64 80 00       	mov    0x806424,%eax
  80058a:	8b 40 48             	mov    0x48(%eax),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	c7 04 24 72 37 80 00 	movl   $0x803772,(%esp)
  800598:	e8 7e 05 00 00       	call   800b1b <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80059d:	85 ff                	test   %edi,%edi
  80059f:	74 4e                	je     8005ef <runcmd+0x3e0>
		if (debug)
  8005a1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005a8:	74 1c                	je     8005c6 <runcmd+0x3b7>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005aa:	a1 24 64 80 00       	mov    0x806424,%eax
  8005af:	8b 40 48             	mov    0x48(%eax),%eax
  8005b2:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	c7 04 24 88 37 80 00 	movl   $0x803788,(%esp)
  8005c1:	e8 55 05 00 00       	call   800b1b <cprintf>
		wait(pipe_child);
  8005c6:	89 3c 24             	mov    %edi,(%esp)
  8005c9:	e8 02 2b 00 00       	call   8030d0 <wait>
		if (debug)
  8005ce:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005d5:	74 18                	je     8005ef <runcmd+0x3e0>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005d7:	a1 24 64 80 00       	mov    0x806424,%eax
  8005dc:	8b 40 48             	mov    0x48(%eax),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	c7 04 24 72 37 80 00 	movl   $0x803772,(%esp)
  8005ea:	e8 2c 05 00 00       	call   800b1b <cprintf>
	}

	// Done!
	exit();
  8005ef:	e8 1a 04 00 00       	call   800a0e <exit>
  8005f4:	eb 17                	jmp    80060d <runcmd+0x3fe>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  8005f6:	e8 ea 19 00 00       	call   801fe5 <close_all>
	if (r >= 0) {
		if (debug)
  8005fb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800602:	0f 84 6c ff ff ff    	je     800574 <runcmd+0x365>
  800608:	e9 44 ff ff ff       	jmp    800551 <runcmd+0x342>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  80060d:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800613:	5b                   	pop    %ebx
  800614:	5e                   	pop    %esi
  800615:	5f                   	pop    %edi
  800616:	5d                   	pop    %ebp
  800617:	c3                   	ret    

00800618 <usage>:
}


void
usage(void)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80061e:	c7 04 24 50 38 80 00 	movl   $0x803850,(%esp)
  800625:	e8 f1 04 00 00       	call   800b1b <cprintf>
	exit();
  80062a:	e8 df 03 00 00       	call   800a0e <exit>
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <umain>:

void
umain(int argc, char **argv)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	57                   	push   %edi
  800635:	56                   	push   %esi
  800636:	53                   	push   %ebx
  800637:	83 ec 3c             	sub    $0x3c,%esp
  80063a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80063d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800640:	89 44 24 08          	mov    %eax,0x8(%esp)
  800644:	89 74 24 04          	mov    %esi,0x4(%esp)
  800648:	8d 45 08             	lea    0x8(%ebp),%eax
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	e8 57 16 00 00       	call   801caa <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800653:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80065a:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80065f:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800662:	eb 2f                	jmp    800693 <umain+0x62>
		switch (r) {
  800664:	83 f8 69             	cmp    $0x69,%eax
  800667:	74 0c                	je     800675 <umain+0x44>
  800669:	83 f8 78             	cmp    $0x78,%eax
  80066c:	74 1e                	je     80068c <umain+0x5b>
  80066e:	83 f8 64             	cmp    $0x64,%eax
  800671:	75 12                	jne    800685 <umain+0x54>
  800673:	eb 07                	jmp    80067c <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800675:	bf 01 00 00 00       	mov    $0x1,%edi
  80067a:	eb 17                	jmp    800693 <umain+0x62>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80067c:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  800683:	eb 0e                	jmp    800693 <umain+0x62>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800685:	e8 8e ff ff ff       	call   800618 <usage>
  80068a:	eb 07                	jmp    800693 <umain+0x62>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80068c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800693:	89 1c 24             	mov    %ebx,(%esp)
  800696:	e8 47 16 00 00       	call   801ce2 <argnext>
  80069b:	85 c0                	test   %eax,%eax
  80069d:	79 c5                	jns    800664 <umain+0x33>
  80069f:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006a1:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006a5:	7e 05                	jle    8006ac <umain+0x7b>
		usage();
  8006a7:	e8 6c ff ff ff       	call   800618 <usage>
	if (argc == 2) {
  8006ac:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006b0:	75 72                	jne    800724 <umain+0xf3>
		close(0);
  8006b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b9:	e8 f4 18 00 00       	call   801fb2 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006c5:	00 
  8006c6:	8b 46 04             	mov    0x4(%esi),%eax
  8006c9:	89 04 24             	mov    %eax,(%esp)
  8006cc:	e8 f0 1e 00 00       	call   8025c1 <open>
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	79 27                	jns    8006fc <umain+0xcb>
			panic("open %s: %e", argv[1], r);
  8006d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d9:	8b 46 04             	mov    0x4(%esi),%eax
  8006dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e0:	c7 44 24 08 a8 37 80 	movl   $0x8037a8,0x8(%esp)
  8006e7:	00 
  8006e8:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  8006ef:	00 
  8006f0:	c7 04 24 d7 36 80 00 	movl   $0x8036d7,(%esp)
  8006f7:	e8 26 03 00 00       	call   800a22 <_panic>
		assert(r == 0);
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 24                	je     800724 <umain+0xf3>
  800700:	c7 44 24 0c b4 37 80 	movl   $0x8037b4,0xc(%esp)
  800707:	00 
  800708:	c7 44 24 08 bb 37 80 	movl   $0x8037bb,0x8(%esp)
  80070f:	00 
  800710:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  800717:	00 
  800718:	c7 04 24 d7 36 80 00 	movl   $0x8036d7,(%esp)
  80071f:	e8 fe 02 00 00       	call   800a22 <_panic>
	}
	if (interactive == '?')
  800724:	83 fb 3f             	cmp    $0x3f,%ebx
  800727:	75 0e                	jne    800737 <umain+0x106>
		interactive = iscons(0);
  800729:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800730:	e8 07 02 00 00       	call   80093c <iscons>
  800735:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800737:	85 ff                	test   %edi,%edi
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	ba a5 37 80 00       	mov    $0x8037a5,%edx
  800743:	0f 45 c2             	cmovne %edx,%eax
  800746:	89 04 24             	mov    %eax,(%esp)
  800749:	e8 12 0a 00 00       	call   801160 <readline>
  80074e:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800750:	85 c0                	test   %eax,%eax
  800752:	75 1a                	jne    80076e <umain+0x13d>
			if (debug)
  800754:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80075b:	74 0c                	je     800769 <umain+0x138>
				cprintf("EXITING\n");
  80075d:	c7 04 24 d0 37 80 00 	movl   $0x8037d0,(%esp)
  800764:	e8 b2 03 00 00       	call   800b1b <cprintf>
			exit();	// end of file
  800769:	e8 a0 02 00 00       	call   800a0e <exit>
		}
		if (debug)
  80076e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800775:	74 10                	je     800787 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800777:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077b:	c7 04 24 d9 37 80 00 	movl   $0x8037d9,(%esp)
  800782:	e8 94 03 00 00       	call   800b1b <cprintf>
		if (buf[0] == '#')
  800787:	80 3b 23             	cmpb   $0x23,(%ebx)
  80078a:	74 ab                	je     800737 <umain+0x106>
			continue;
		if (echocmds)
  80078c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800790:	74 10                	je     8007a2 <umain+0x171>
			printf("# %s\n", buf);
  800792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800796:	c7 04 24 e3 37 80 00 	movl   $0x8037e3,(%esp)
  80079d:	e8 cf 1f 00 00       	call   802771 <printf>
		if (debug)
  8007a2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007a9:	74 0c                	je     8007b7 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007ab:	c7 04 24 e9 37 80 00 	movl   $0x8037e9,(%esp)
  8007b2:	e8 64 03 00 00       	call   800b1b <cprintf>
		if ((r = fork()) < 0)
  8007b7:	e8 b9 12 00 00       	call   801a75 <fork>
  8007bc:	89 c6                	mov    %eax,%esi
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	79 20                	jns    8007e2 <umain+0x1b1>
			panic("fork: %e", r);
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	c7 44 24 08 0d 37 80 	movl   $0x80370d,0x8(%esp)
  8007cd:	00 
  8007ce:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  8007d5:	00 
  8007d6:	c7 04 24 d7 36 80 00 	movl   $0x8036d7,(%esp)
  8007dd:	e8 40 02 00 00       	call   800a22 <_panic>
		if (debug)
  8007e2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007e9:	74 10                	je     8007fb <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ef:	c7 04 24 f6 37 80 00 	movl   $0x8037f6,(%esp)
  8007f6:	e8 20 03 00 00       	call   800b1b <cprintf>
		if (r == 0) {
  8007fb:	85 f6                	test   %esi,%esi
  8007fd:	75 12                	jne    800811 <umain+0x1e0>
			runcmd(buf);
  8007ff:	89 1c 24             	mov    %ebx,(%esp)
  800802:	e8 08 fa ff ff       	call   80020f <runcmd>
			exit();
  800807:	e8 02 02 00 00       	call   800a0e <exit>
  80080c:	e9 26 ff ff ff       	jmp    800737 <umain+0x106>
		} else
			wait(r);
  800811:	89 34 24             	mov    %esi,(%esp)
  800814:	e8 b7 28 00 00       	call   8030d0 <wait>
  800819:	e9 19 ff ff ff       	jmp    800737 <umain+0x106>
  80081e:	66 90                	xchg   %ax,%ax

00800820 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800830:	c7 44 24 04 71 38 80 	movl   $0x803871,0x4(%esp)
  800837:	00 
  800838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 44 0a 00 00       	call   801287 <strcpy>
	return 0;
}
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800856:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80085b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800861:	eb 31                	jmp    800894 <devcons_write+0x4a>
		m = n - tot;
  800863:	8b 75 10             	mov    0x10(%ebp),%esi
  800866:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800868:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80086b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800870:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800873:	89 74 24 08          	mov    %esi,0x8(%esp)
  800877:	03 45 0c             	add    0xc(%ebp),%eax
  80087a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087e:	89 3c 24             	mov    %edi,(%esp)
  800881:	e8 9e 0b 00 00       	call   801424 <memmove>
		sys_cputs(buf, m);
  800886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80088a:	89 3c 24             	mov    %edi,(%esp)
  80088d:	e8 44 0d 00 00       	call   8015d6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800892:	01 f3                	add    %esi,%ebx
  800894:	89 d8                	mov    %ebx,%eax
  800896:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800899:	72 c8                	jb     800863 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80089b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8008b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008b5:	75 07                	jne    8008be <devcons_read+0x18>
  8008b7:	eb 2a                	jmp    8008e3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008b9:	e8 c6 0d 00 00       	call   801684 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008be:	66 90                	xchg   %ax,%ax
  8008c0:	e8 2f 0d 00 00       	call   8015f4 <sys_cgetc>
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 f0                	je     8008b9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 16                	js     8008e3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008cd:	83 f8 04             	cmp    $0x4,%eax
  8008d0:	74 0c                	je     8008de <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	88 02                	mov    %al,(%edx)
	return 1;
  8008d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8008dc:	eb 05                	jmp    8008e3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008f8:	00 
  8008f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	e8 d2 0c 00 00       	call   8015d6 <sys_cputs>
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <getchar>:

int
getchar(void)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800913:	00 
  800914:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800922:	e8 ee 17 00 00       	call   802115 <read>
	if (r < 0)
  800927:	85 c0                	test   %eax,%eax
  800929:	78 0f                	js     80093a <getchar+0x34>
		return r;
	if (r < 1)
  80092b:	85 c0                	test   %eax,%eax
  80092d:	7e 06                	jle    800935 <getchar+0x2f>
		return -E_EOF;
	return c;
  80092f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800933:	eb 05                	jmp    80093a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800935:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 32 15 00 00       	call   801e86 <fd_lookup>
  800954:	85 c0                	test   %eax,%eax
  800956:	78 11                	js     800969 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095b:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800961:	39 10                	cmp    %edx,(%eax)
  800963:	0f 94 c0             	sete   %al
  800966:	0f b6 c0             	movzbl %al,%eax
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <opencons>:

int
opencons(void)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800971:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 bb 14 00 00       	call   801e37 <fd_alloc>
		return r;
  80097c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 40                	js     8009c2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800982:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800989:	00 
  80098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800991:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800998:	e8 06 0d 00 00       	call   8016a3 <sys_page_alloc>
		return r;
  80099d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	78 1f                	js     8009c2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009a3:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	e8 50 14 00 00       	call   801e10 <fd2num>
  8009c0:	89 c2                	mov    %eax,%edx
}
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 10             	sub    $0x10,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  8009d4:	e8 8c 0c 00 00       	call   801665 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8009d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009e6:	a3 24 64 80 00       	mov    %eax,0x806424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	7e 07                	jle    8009f6 <libmain+0x30>
		binaryname = argv[0];
  8009ef:	8b 06                	mov    (%esi),%eax
  8009f1:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  8009f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fa:	89 1c 24             	mov    %ebx,(%esp)
  8009fd:	e8 2f fc ff ff       	call   800631 <umain>

	// exit gracefully
	exit();
  800a02:	e8 07 00 00 00       	call   800a0e <exit>
}
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800a14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a1b:	e8 f3 0b 00 00       	call   801613 <sys_env_destroy>
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a2a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a2d:	8b 35 1c 50 80 00    	mov    0x80501c,%esi
  800a33:	e8 2d 0c 00 00       	call   801665 <sys_getenvid>
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a46:	89 74 24 08          	mov    %esi,0x8(%esp)
  800a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4e:	c7 04 24 88 38 80 00 	movl   $0x803888,(%esp)
  800a55:	e8 c1 00 00 00       	call   800b1b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a61:	89 04 24             	mov    %eax,(%esp)
  800a64:	e8 51 00 00 00       	call   800aba <vcprintf>
	cprintf("\n");
  800a69:	c7 04 24 80 36 80 00 	movl   $0x803680,(%esp)
  800a70:	e8 a6 00 00 00       	call   800b1b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a75:	cc                   	int3   
  800a76:	eb fd                	jmp    800a75 <_panic+0x53>

00800a78 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	53                   	push   %ebx
  800a7c:	83 ec 14             	sub    $0x14,%esp
  800a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a82:	8b 13                	mov    (%ebx),%edx
  800a84:	8d 42 01             	lea    0x1(%edx),%eax
  800a87:	89 03                	mov    %eax,(%ebx)
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a90:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a95:	75 19                	jne    800ab0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800a97:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a9e:	00 
  800a9f:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa2:	89 04 24             	mov    %eax,(%esp)
  800aa5:	e8 2c 0b 00 00       	call   8015d6 <sys_cputs>
		b->idx = 0;
  800aaa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ab0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ab4:	83 c4 14             	add    $0x14,%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ac3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aca:	00 00 00 
	b.cnt = 0;
  800acd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ad4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	c7 04 24 78 0a 80 00 	movl   $0x800a78,(%esp)
  800af6:	e8 79 01 00 00       	call   800c74 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800afb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b05:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b0b:	89 04 24             	mov    %eax,(%esp)
  800b0e:	e8 c3 0a 00 00       	call   8015d6 <sys_cputs>

	return b.cnt;
}
  800b13:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b21:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 87 ff ff ff       	call   800aba <vcprintf>
	va_end(ap);

	return cnt;
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    
  800b35:	66 90                	xchg   %ax,%ax
  800b37:	66 90                	xchg   %ax,%ax
  800b39:	66 90                	xchg   %ax,%ax
  800b3b:	66 90                	xchg   %ax,%ax
  800b3d:	66 90                	xchg   %ax,%ax
  800b3f:	90                   	nop

00800b40 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 3c             	sub    $0x3c,%esp
  800b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b6d:	39 d9                	cmp    %ebx,%ecx
  800b6f:	72 05                	jb     800b76 <printnum+0x36>
  800b71:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800b74:	77 69                	ja     800bdf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b76:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800b79:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b7d:	83 ee 01             	sub    $0x1,%esi
  800b80:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b84:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b88:	8b 44 24 08          	mov    0x8(%esp),%eax
  800b8c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b9a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba5:	89 04 24             	mov    %eax,(%esp)
  800ba8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baf:	e8 1c 28 00 00       	call   8033d0 <__udivdi3>
  800bb4:	89 d9                	mov    %ebx,%ecx
  800bb6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800bba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bbe:	89 04 24             	mov    %eax,(%esp)
  800bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc5:	89 fa                	mov    %edi,%edx
  800bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bca:	e8 71 ff ff ff       	call   800b40 <printnum>
  800bcf:	eb 1b                	jmp    800bec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bd1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd5:	8b 45 18             	mov    0x18(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	ff d3                	call   *%ebx
  800bdd:	eb 03                	jmp    800be2 <printnum+0xa2>
  800bdf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800be2:	83 ee 01             	sub    $0x1,%esi
  800be5:	85 f6                	test   %esi,%esi
  800be7:	7f e8                	jg     800bd1 <printnum+0x91>
  800be9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c05:	89 04 24             	mov    %eax,(%esp)
  800c08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0f:	e8 ec 28 00 00       	call   803500 <__umoddi3>
  800c14:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c18:	0f be 80 ab 38 80 00 	movsbl 0x8038ab(%eax),%eax
  800c1f:	89 04 24             	mov    %eax,(%esp)
  800c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c25:	ff d0                	call   *%eax
}
  800c27:	83 c4 3c             	add    $0x3c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c35:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c39:	8b 10                	mov    (%eax),%edx
  800c3b:	3b 50 04             	cmp    0x4(%eax),%edx
  800c3e:	73 0a                	jae    800c4a <sprintputch+0x1b>
		*b->buf++ = ch;
  800c40:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c43:	89 08                	mov    %ecx,(%eax)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	88 02                	mov    %al,(%edx)
}
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c52:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c59:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	e8 02 00 00 00       	call   800c74 <vprintfmt>
	va_end(ap);
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 3c             	sub    $0x3c,%esp
  800c7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c83:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c86:	eb 11                	jmp    800c99 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	0f 84 48 04 00 00    	je     8010d8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800c90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c99:	83 c7 01             	add    $0x1,%edi
  800c9c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ca0:	83 f8 25             	cmp    $0x25,%eax
  800ca3:	75 e3                	jne    800c88 <vprintfmt+0x14>
  800ca5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800ca9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800cb0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800cb7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800cbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc3:	eb 1f                	jmp    800ce4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cc8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800ccc:	eb 16                	jmp    800ce4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cd1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cd5:	eb 0d                	jmp    800ce4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cda:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cdd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce4:	8d 47 01             	lea    0x1(%edi),%eax
  800ce7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cea:	0f b6 17             	movzbl (%edi),%edx
  800ced:	0f b6 c2             	movzbl %dl,%eax
  800cf0:	83 ea 23             	sub    $0x23,%edx
  800cf3:	80 fa 55             	cmp    $0x55,%dl
  800cf6:	0f 87 bf 03 00 00    	ja     8010bb <vprintfmt+0x447>
  800cfc:	0f b6 d2             	movzbl %dl,%edx
  800cff:	ff 24 95 e0 39 80 00 	jmp    *0x8039e0(,%edx,4)
  800d06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d11:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800d14:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800d18:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800d1b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800d1e:	83 f9 09             	cmp    $0x9,%ecx
  800d21:	77 3c                	ja     800d5f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d23:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d26:	eb e9                	jmp    800d11 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d28:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2b:	8b 00                	mov    (%eax),%eax
  800d2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800d30:	8b 45 14             	mov    0x14(%ebp),%eax
  800d33:	8d 40 04             	lea    0x4(%eax),%eax
  800d36:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d3c:	eb 27                	jmp    800d65 <vprintfmt+0xf1>
  800d3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800d41:	85 d2                	test   %edx,%edx
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
  800d48:	0f 49 c2             	cmovns %edx,%eax
  800d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d51:	eb 91                	jmp    800ce4 <vprintfmt+0x70>
  800d53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d56:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d5d:	eb 85                	jmp    800ce4 <vprintfmt+0x70>
  800d5f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d62:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d69:	0f 89 75 ff ff ff    	jns    800ce4 <vprintfmt+0x70>
  800d6f:	e9 63 ff ff ff       	jmp    800cd7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d74:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d7a:	e9 65 ff ff ff       	jmp    800ce4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d7f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d82:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800d86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8a:	8b 00                	mov    (%eax),%eax
  800d8c:	89 04 24             	mov    %eax,(%esp)
  800d8f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d94:	e9 00 ff ff ff       	jmp    800c99 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d99:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d9c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800da0:	8b 00                	mov    (%eax),%eax
  800da2:	99                   	cltd   
  800da3:	31 d0                	xor    %edx,%eax
  800da5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800da7:	83 f8 0f             	cmp    $0xf,%eax
  800daa:	7f 0b                	jg     800db7 <vprintfmt+0x143>
  800dac:	8b 14 85 40 3b 80 00 	mov    0x803b40(,%eax,4),%edx
  800db3:	85 d2                	test   %edx,%edx
  800db5:	75 20                	jne    800dd7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800db7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbb:	c7 44 24 08 c3 38 80 	movl   $0x8038c3,0x8(%esp)
  800dc2:	00 
  800dc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dc7:	89 34 24             	mov    %esi,(%esp)
  800dca:	e8 7d fe ff ff       	call   800c4c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dcf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800dd2:	e9 c2 fe ff ff       	jmp    800c99 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800dd7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ddb:	c7 44 24 08 cd 37 80 	movl   $0x8037cd,0x8(%esp)
  800de2:	00 
  800de3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800de7:	89 34 24             	mov    %esi,(%esp)
  800dea:	e8 5d fe ff ff       	call   800c4c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800def:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800df2:	e9 a2 fe ff ff       	jmp    800c99 <vprintfmt+0x25>
  800df7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800dfd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e00:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e03:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800e07:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800e09:	85 ff                	test   %edi,%edi
  800e0b:	b8 bc 38 80 00       	mov    $0x8038bc,%eax
  800e10:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800e13:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800e17:	0f 84 92 00 00 00    	je     800eaf <vprintfmt+0x23b>
  800e1d:	85 c9                	test   %ecx,%ecx
  800e1f:	0f 8e 98 00 00 00    	jle    800ebd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e25:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e29:	89 3c 24             	mov    %edi,(%esp)
  800e2c:	e8 37 04 00 00       	call   801268 <strnlen>
  800e31:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e34:	29 c1                	sub    %eax,%ecx
  800e36:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800e39:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e40:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e43:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e45:	eb 0f                	jmp    800e56 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800e47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4e:	89 04 24             	mov    %eax,(%esp)
  800e51:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e53:	83 ef 01             	sub    $0x1,%edi
  800e56:	85 ff                	test   %edi,%edi
  800e58:	7f ed                	jg     800e47 <vprintfmt+0x1d3>
  800e5a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e5d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e60:	85 c9                	test   %ecx,%ecx
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	0f 49 c1             	cmovns %ecx,%eax
  800e6a:	29 c1                	sub    %eax,%ecx
  800e6c:	89 75 08             	mov    %esi,0x8(%ebp)
  800e6f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e72:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e75:	89 cb                	mov    %ecx,%ebx
  800e77:	eb 50                	jmp    800ec9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e79:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e7d:	74 1e                	je     800e9d <vprintfmt+0x229>
  800e7f:	0f be d2             	movsbl %dl,%edx
  800e82:	83 ea 20             	sub    $0x20,%edx
  800e85:	83 fa 5e             	cmp    $0x5e,%edx
  800e88:	76 13                	jbe    800e9d <vprintfmt+0x229>
					putch('?', putdat);
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e91:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e98:	ff 55 08             	call   *0x8(%ebp)
  800e9b:	eb 0d                	jmp    800eaa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800eaa:	83 eb 01             	sub    $0x1,%ebx
  800ead:	eb 1a                	jmp    800ec9 <vprintfmt+0x255>
  800eaf:	89 75 08             	mov    %esi,0x8(%ebp)
  800eb2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800eb5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800eb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ebb:	eb 0c                	jmp    800ec9 <vprintfmt+0x255>
  800ebd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ec0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ec3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ec6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ec9:	83 c7 01             	add    $0x1,%edi
  800ecc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800ed0:	0f be c2             	movsbl %dl,%eax
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	74 25                	je     800efc <vprintfmt+0x288>
  800ed7:	85 f6                	test   %esi,%esi
  800ed9:	78 9e                	js     800e79 <vprintfmt+0x205>
  800edb:	83 ee 01             	sub    $0x1,%esi
  800ede:	79 99                	jns    800e79 <vprintfmt+0x205>
  800ee0:	89 df                	mov    %ebx,%edi
  800ee2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee8:	eb 1a                	jmp    800f04 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800eea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ef5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ef7:	83 ef 01             	sub    $0x1,%edi
  800efa:	eb 08                	jmp    800f04 <vprintfmt+0x290>
  800efc:	89 df                	mov    %ebx,%edi
  800efe:	8b 75 08             	mov    0x8(%ebp),%esi
  800f01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f04:	85 ff                	test   %edi,%edi
  800f06:	7f e2                	jg     800eea <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f0b:	e9 89 fd ff ff       	jmp    800c99 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f10:	83 f9 01             	cmp    $0x1,%ecx
  800f13:	7e 19                	jle    800f2e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800f15:	8b 45 14             	mov    0x14(%ebp),%eax
  800f18:	8b 50 04             	mov    0x4(%eax),%edx
  800f1b:	8b 00                	mov    (%eax),%eax
  800f1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f20:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800f23:	8b 45 14             	mov    0x14(%ebp),%eax
  800f26:	8d 40 08             	lea    0x8(%eax),%eax
  800f29:	89 45 14             	mov    %eax,0x14(%ebp)
  800f2c:	eb 38                	jmp    800f66 <vprintfmt+0x2f2>
	else if (lflag)
  800f2e:	85 c9                	test   %ecx,%ecx
  800f30:	74 1b                	je     800f4d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800f32:	8b 45 14             	mov    0x14(%ebp),%eax
  800f35:	8b 00                	mov    (%eax),%eax
  800f37:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f3a:	89 c1                	mov    %eax,%ecx
  800f3c:	c1 f9 1f             	sar    $0x1f,%ecx
  800f3f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f42:	8b 45 14             	mov    0x14(%ebp),%eax
  800f45:	8d 40 04             	lea    0x4(%eax),%eax
  800f48:	89 45 14             	mov    %eax,0x14(%ebp)
  800f4b:	eb 19                	jmp    800f66 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  800f4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f50:	8b 00                	mov    (%eax),%eax
  800f52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f55:	89 c1                	mov    %eax,%ecx
  800f57:	c1 f9 1f             	sar    $0x1f,%ecx
  800f5a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f60:	8d 40 04             	lea    0x4(%eax),%eax
  800f63:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f66:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f69:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f6c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f71:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f75:	0f 89 04 01 00 00    	jns    80107f <vprintfmt+0x40b>
				putch('-', putdat);
  800f7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f7f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f86:	ff d6                	call   *%esi
				num = -(long long) num;
  800f88:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f8b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f8e:	f7 da                	neg    %edx
  800f90:	83 d1 00             	adc    $0x0,%ecx
  800f93:	f7 d9                	neg    %ecx
  800f95:	e9 e5 00 00 00       	jmp    80107f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800f9a:	83 f9 01             	cmp    $0x1,%ecx
  800f9d:	7e 10                	jle    800faf <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  800f9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa2:	8b 10                	mov    (%eax),%edx
  800fa4:	8b 48 04             	mov    0x4(%eax),%ecx
  800fa7:	8d 40 08             	lea    0x8(%eax),%eax
  800faa:	89 45 14             	mov    %eax,0x14(%ebp)
  800fad:	eb 26                	jmp    800fd5 <vprintfmt+0x361>
	else if (lflag)
  800faf:	85 c9                	test   %ecx,%ecx
  800fb1:	74 12                	je     800fc5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800fb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb6:	8b 10                	mov    (%eax),%edx
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	8d 40 04             	lea    0x4(%eax),%eax
  800fc0:	89 45 14             	mov    %eax,0x14(%ebp)
  800fc3:	eb 10                	jmp    800fd5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800fc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc8:	8b 10                	mov    (%eax),%edx
  800fca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcf:	8d 40 04             	lea    0x4(%eax),%eax
  800fd2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800fd5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800fda:	e9 a0 00 00 00       	jmp    80107f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800fdf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fe3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800fea:	ff d6                	call   *%esi
			putch('X', putdat);
  800fec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800ff7:	ff d6                	call   *%esi
			putch('X', putdat);
  800ff9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ffd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801004:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801006:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801009:	e9 8b fc ff ff       	jmp    800c99 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80100e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801012:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801019:	ff d6                	call   *%esi
			putch('x', putdat);
  80101b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80101f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801026:	ff d6                	call   *%esi
			num = (unsigned long long)
  801028:	8b 45 14             	mov    0x14(%ebp),%eax
  80102b:	8b 10                	mov    (%eax),%edx
  80102d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  801032:	8d 40 04             	lea    0x4(%eax),%eax
  801035:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801038:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80103d:	eb 40                	jmp    80107f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80103f:	83 f9 01             	cmp    $0x1,%ecx
  801042:	7e 10                	jle    801054 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  801044:	8b 45 14             	mov    0x14(%ebp),%eax
  801047:	8b 10                	mov    (%eax),%edx
  801049:	8b 48 04             	mov    0x4(%eax),%ecx
  80104c:	8d 40 08             	lea    0x8(%eax),%eax
  80104f:	89 45 14             	mov    %eax,0x14(%ebp)
  801052:	eb 26                	jmp    80107a <vprintfmt+0x406>
	else if (lflag)
  801054:	85 c9                	test   %ecx,%ecx
  801056:	74 12                	je     80106a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  801058:	8b 45 14             	mov    0x14(%ebp),%eax
  80105b:	8b 10                	mov    (%eax),%edx
  80105d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801062:	8d 40 04             	lea    0x4(%eax),%eax
  801065:	89 45 14             	mov    %eax,0x14(%ebp)
  801068:	eb 10                	jmp    80107a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  80106a:	8b 45 14             	mov    0x14(%ebp),%eax
  80106d:	8b 10                	mov    (%eax),%edx
  80106f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801074:	8d 40 04             	lea    0x4(%eax),%eax
  801077:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80107a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80107f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801083:	89 44 24 10          	mov    %eax,0x10(%esp)
  801087:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80108a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801092:	89 14 24             	mov    %edx,(%esp)
  801095:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801099:	89 da                	mov    %ebx,%edx
  80109b:	89 f0                	mov    %esi,%eax
  80109d:	e8 9e fa ff ff       	call   800b40 <printnum>
			break;
  8010a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010a5:	e9 ef fb ff ff       	jmp    800c99 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8010aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010ae:	89 04 24             	mov    %eax,(%esp)
  8010b1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8010b6:	e9 de fb ff ff       	jmp    800c99 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8010bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8010c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010c8:	eb 03                	jmp    8010cd <vprintfmt+0x459>
  8010ca:	83 ef 01             	sub    $0x1,%edi
  8010cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8010d1:	75 f7                	jne    8010ca <vprintfmt+0x456>
  8010d3:	e9 c1 fb ff ff       	jmp    800c99 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8010d8:	83 c4 3c             	add    $0x3c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 28             	sub    $0x28,%esp
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8010ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	74 30                	je     801131 <vsnprintf+0x51>
  801101:	85 d2                	test   %edx,%edx
  801103:	7e 2c                	jle    801131 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801105:	8b 45 14             	mov    0x14(%ebp),%eax
  801108:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110c:	8b 45 10             	mov    0x10(%ebp),%eax
  80110f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801113:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801116:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111a:	c7 04 24 2f 0c 80 00 	movl   $0x800c2f,(%esp)
  801121:	e8 4e fb ff ff       	call   800c74 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801126:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801129:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80112c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112f:	eb 05                	jmp    801136 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80113e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801145:	8b 45 10             	mov    0x10(%ebp),%eax
  801148:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	89 04 24             	mov    %eax,(%esp)
  801159:	e8 82 ff ff ff       	call   8010e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 1c             	sub    $0x1c,%esp
  801169:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 18                	je     801188 <readline+0x28>
		fprintf(1, "%s", prompt);
  801170:	89 44 24 08          	mov    %eax,0x8(%esp)
  801174:	c7 44 24 04 cd 37 80 	movl   $0x8037cd,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801183:	e8 c8 15 00 00       	call   802750 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  801188:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80118f:	e8 a8 f7 ff ff       	call   80093c <iscons>
  801194:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801196:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80119b:	e8 66 f7 ff ff       	call   800906 <getchar>
  8011a0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	79 25                	jns    8011cb <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8011ab:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8011ae:	0f 84 88 00 00 00    	je     80123c <readline+0xdc>
				cprintf("read error: %e\n", c);
  8011b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b8:	c7 04 24 9f 3b 80 00 	movl   $0x803b9f,(%esp)
  8011bf:	e8 57 f9 ff ff       	call   800b1b <cprintf>
			return NULL;
  8011c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c9:	eb 71                	jmp    80123c <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8011cb:	83 f8 7f             	cmp    $0x7f,%eax
  8011ce:	74 05                	je     8011d5 <readline+0x75>
  8011d0:	83 f8 08             	cmp    $0x8,%eax
  8011d3:	75 19                	jne    8011ee <readline+0x8e>
  8011d5:	85 f6                	test   %esi,%esi
  8011d7:	7e 15                	jle    8011ee <readline+0x8e>
			if (echoing)
  8011d9:	85 ff                	test   %edi,%edi
  8011db:	74 0c                	je     8011e9 <readline+0x89>
				cputchar('\b');
  8011dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011e4:	e8 fc f6 ff ff       	call   8008e5 <cputchar>
			i--;
  8011e9:	83 ee 01             	sub    $0x1,%esi
  8011ec:	eb ad                	jmp    80119b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8011ee:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8011f4:	7f 1c                	jg     801212 <readline+0xb2>
  8011f6:	83 fb 1f             	cmp    $0x1f,%ebx
  8011f9:	7e 17                	jle    801212 <readline+0xb2>
			if (echoing)
  8011fb:	85 ff                	test   %edi,%edi
  8011fd:	74 08                	je     801207 <readline+0xa7>
				cputchar(c);
  8011ff:	89 1c 24             	mov    %ebx,(%esp)
  801202:	e8 de f6 ff ff       	call   8008e5 <cputchar>
			buf[i++] = c;
  801207:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  80120d:	8d 76 01             	lea    0x1(%esi),%esi
  801210:	eb 89                	jmp    80119b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801212:	83 fb 0d             	cmp    $0xd,%ebx
  801215:	74 09                	je     801220 <readline+0xc0>
  801217:	83 fb 0a             	cmp    $0xa,%ebx
  80121a:	0f 85 7b ff ff ff    	jne    80119b <readline+0x3b>
			if (echoing)
  801220:	85 ff                	test   %edi,%edi
  801222:	74 0c                	je     801230 <readline+0xd0>
				cputchar('\n');
  801224:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80122b:	e8 b5 f6 ff ff       	call   8008e5 <cputchar>
			buf[i] = 0;
  801230:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  801237:	b8 20 60 80 00       	mov    $0x806020,%eax
		}
	}
}
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    
  801244:	66 90                	xchg   %ax,%ax
  801246:	66 90                	xchg   %ax,%ax
  801248:	66 90                	xchg   %ax,%ax
  80124a:	66 90                	xchg   %ax,%ax
  80124c:	66 90                	xchg   %ax,%ax
  80124e:	66 90                	xchg   %ax,%ax

00801250 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
  80125b:	eb 03                	jmp    801260 <strlen+0x10>
		n++;
  80125d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801260:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801264:	75 f7                	jne    80125d <strlen+0xd>
		n++;
	return n;
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	eb 03                	jmp    80127b <strnlen+0x13>
		n++;
  801278:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80127b:	39 d0                	cmp    %edx,%eax
  80127d:	74 06                	je     801285 <strnlen+0x1d>
  80127f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801283:	75 f3                	jne    801278 <strnlen+0x10>
		n++;
	return n;
}
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	53                   	push   %ebx
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801291:	89 c2                	mov    %eax,%edx
  801293:	83 c2 01             	add    $0x1,%edx
  801296:	83 c1 01             	add    $0x1,%ecx
  801299:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80129d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8012a0:	84 db                	test   %bl,%bl
  8012a2:	75 ef                	jne    801293 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8012a4:	5b                   	pop    %ebx
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8012b1:	89 1c 24             	mov    %ebx,(%esp)
  8012b4:	e8 97 ff ff ff       	call   801250 <strlen>
	strcpy(dst + len, src);
  8012b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c0:	01 d8                	add    %ebx,%eax
  8012c2:	89 04 24             	mov    %eax,(%esp)
  8012c5:	e8 bd ff ff ff       	call   801287 <strcpy>
	return dst;
}
  8012ca:	89 d8                	mov    %ebx,%eax
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012dd:	89 f3                	mov    %esi,%ebx
  8012df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	eb 0f                	jmp    8012f5 <strncpy+0x23>
		*dst++ = *src;
  8012e6:	83 c2 01             	add    $0x1,%edx
  8012e9:	0f b6 01             	movzbl (%ecx),%eax
  8012ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8012ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8012f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012f5:	39 da                	cmp    %ebx,%edx
  8012f7:	75 ed                	jne    8012e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8012f9:	89 f0                	mov    %esi,%eax
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	8b 75 08             	mov    0x8(%ebp),%esi
  801307:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80130d:	89 f0                	mov    %esi,%eax
  80130f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801313:	85 c9                	test   %ecx,%ecx
  801315:	75 0b                	jne    801322 <strlcpy+0x23>
  801317:	eb 1d                	jmp    801336 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801319:	83 c0 01             	add    $0x1,%eax
  80131c:	83 c2 01             	add    $0x1,%edx
  80131f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801322:	39 d8                	cmp    %ebx,%eax
  801324:	74 0b                	je     801331 <strlcpy+0x32>
  801326:	0f b6 0a             	movzbl (%edx),%ecx
  801329:	84 c9                	test   %cl,%cl
  80132b:	75 ec                	jne    801319 <strlcpy+0x1a>
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	eb 02                	jmp    801333 <strlcpy+0x34>
  801331:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801333:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801336:	29 f0                	sub    %esi,%eax
}
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801345:	eb 06                	jmp    80134d <strcmp+0x11>
		p++, q++;
  801347:	83 c1 01             	add    $0x1,%ecx
  80134a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80134d:	0f b6 01             	movzbl (%ecx),%eax
  801350:	84 c0                	test   %al,%al
  801352:	74 04                	je     801358 <strcmp+0x1c>
  801354:	3a 02                	cmp    (%edx),%al
  801356:	74 ef                	je     801347 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801358:	0f b6 c0             	movzbl %al,%eax
  80135b:	0f b6 12             	movzbl (%edx),%edx
  80135e:	29 d0                	sub    %edx,%eax
}
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	53                   	push   %ebx
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136c:	89 c3                	mov    %eax,%ebx
  80136e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801371:	eb 06                	jmp    801379 <strncmp+0x17>
		n--, p++, q++;
  801373:	83 c0 01             	add    $0x1,%eax
  801376:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801379:	39 d8                	cmp    %ebx,%eax
  80137b:	74 15                	je     801392 <strncmp+0x30>
  80137d:	0f b6 08             	movzbl (%eax),%ecx
  801380:	84 c9                	test   %cl,%cl
  801382:	74 04                	je     801388 <strncmp+0x26>
  801384:	3a 0a                	cmp    (%edx),%cl
  801386:	74 eb                	je     801373 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801388:	0f b6 00             	movzbl (%eax),%eax
  80138b:	0f b6 12             	movzbl (%edx),%edx
  80138e:	29 d0                	sub    %edx,%eax
  801390:	eb 05                	jmp    801397 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801392:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801397:	5b                   	pop    %ebx
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8013a4:	eb 07                	jmp    8013ad <strchr+0x13>
		if (*s == c)
  8013a6:	38 ca                	cmp    %cl,%dl
  8013a8:	74 0f                	je     8013b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8013aa:	83 c0 01             	add    $0x1,%eax
  8013ad:	0f b6 10             	movzbl (%eax),%edx
  8013b0:	84 d2                	test   %dl,%dl
  8013b2:	75 f2                	jne    8013a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8013b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8013c5:	eb 07                	jmp    8013ce <strfind+0x13>
		if (*s == c)
  8013c7:	38 ca                	cmp    %cl,%dl
  8013c9:	74 0a                	je     8013d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8013cb:	83 c0 01             	add    $0x1,%eax
  8013ce:	0f b6 10             	movzbl (%eax),%edx
  8013d1:	84 d2                	test   %dl,%dl
  8013d3:	75 f2                	jne    8013c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	57                   	push   %edi
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8013e3:	85 c9                	test   %ecx,%ecx
  8013e5:	74 36                	je     80141d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8013e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013ed:	75 28                	jne    801417 <memset+0x40>
  8013ef:	f6 c1 03             	test   $0x3,%cl
  8013f2:	75 23                	jne    801417 <memset+0x40>
		c &= 0xFF;
  8013f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013f8:	89 d3                	mov    %edx,%ebx
  8013fa:	c1 e3 08             	shl    $0x8,%ebx
  8013fd:	89 d6                	mov    %edx,%esi
  8013ff:	c1 e6 18             	shl    $0x18,%esi
  801402:	89 d0                	mov    %edx,%eax
  801404:	c1 e0 10             	shl    $0x10,%eax
  801407:	09 f0                	or     %esi,%eax
  801409:	09 c2                	or     %eax,%edx
  80140b:	89 d0                	mov    %edx,%eax
  80140d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80140f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801412:	fc                   	cld    
  801413:	f3 ab                	rep stos %eax,%es:(%edi)
  801415:	eb 06                	jmp    80141d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141a:	fc                   	cld    
  80141b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80141d:	89 f8                	mov    %edi,%eax
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	57                   	push   %edi
  801428:	56                   	push   %esi
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80142f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801432:	39 c6                	cmp    %eax,%esi
  801434:	73 35                	jae    80146b <memmove+0x47>
  801436:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801439:	39 d0                	cmp    %edx,%eax
  80143b:	73 2e                	jae    80146b <memmove+0x47>
		s += n;
		d += n;
  80143d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801440:	89 d6                	mov    %edx,%esi
  801442:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801444:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80144a:	75 13                	jne    80145f <memmove+0x3b>
  80144c:	f6 c1 03             	test   $0x3,%cl
  80144f:	75 0e                	jne    80145f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801451:	83 ef 04             	sub    $0x4,%edi
  801454:	8d 72 fc             	lea    -0x4(%edx),%esi
  801457:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80145a:	fd                   	std    
  80145b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80145d:	eb 09                	jmp    801468 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80145f:	83 ef 01             	sub    $0x1,%edi
  801462:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801465:	fd                   	std    
  801466:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801468:	fc                   	cld    
  801469:	eb 1d                	jmp    801488 <memmove+0x64>
  80146b:	89 f2                	mov    %esi,%edx
  80146d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80146f:	f6 c2 03             	test   $0x3,%dl
  801472:	75 0f                	jne    801483 <memmove+0x5f>
  801474:	f6 c1 03             	test   $0x3,%cl
  801477:	75 0a                	jne    801483 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801479:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80147c:	89 c7                	mov    %eax,%edi
  80147e:	fc                   	cld    
  80147f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801481:	eb 05                	jmp    801488 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801483:	89 c7                	mov    %eax,%edi
  801485:	fc                   	cld    
  801486:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801492:	8b 45 10             	mov    0x10(%ebp),%eax
  801495:	89 44 24 08          	mov    %eax,0x8(%esp)
  801499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	89 04 24             	mov    %eax,(%esp)
  8014a6:	e8 79 ff ff ff       	call   801424 <memmove>
}
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
  8014b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b8:	89 d6                	mov    %edx,%esi
  8014ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8014bd:	eb 1a                	jmp    8014d9 <memcmp+0x2c>
		if (*s1 != *s2)
  8014bf:	0f b6 02             	movzbl (%edx),%eax
  8014c2:	0f b6 19             	movzbl (%ecx),%ebx
  8014c5:	38 d8                	cmp    %bl,%al
  8014c7:	74 0a                	je     8014d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8014c9:	0f b6 c0             	movzbl %al,%eax
  8014cc:	0f b6 db             	movzbl %bl,%ebx
  8014cf:	29 d8                	sub    %ebx,%eax
  8014d1:	eb 0f                	jmp    8014e2 <memcmp+0x35>
		s1++, s2++;
  8014d3:	83 c2 01             	add    $0x1,%edx
  8014d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8014d9:	39 f2                	cmp    %esi,%edx
  8014db:	75 e2                	jne    8014bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8014dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e2:	5b                   	pop    %ebx
  8014e3:	5e                   	pop    %esi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    

008014e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014f4:	eb 07                	jmp    8014fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014f6:	38 08                	cmp    %cl,(%eax)
  8014f8:	74 07                	je     801501 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014fa:	83 c0 01             	add    $0x1,%eax
  8014fd:	39 d0                	cmp    %edx,%eax
  8014ff:	72 f5                	jb     8014f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	57                   	push   %edi
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	8b 55 08             	mov    0x8(%ebp),%edx
  80150c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80150f:	eb 03                	jmp    801514 <strtol+0x11>
		s++;
  801511:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801514:	0f b6 0a             	movzbl (%edx),%ecx
  801517:	80 f9 09             	cmp    $0x9,%cl
  80151a:	74 f5                	je     801511 <strtol+0xe>
  80151c:	80 f9 20             	cmp    $0x20,%cl
  80151f:	74 f0                	je     801511 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801521:	80 f9 2b             	cmp    $0x2b,%cl
  801524:	75 0a                	jne    801530 <strtol+0x2d>
		s++;
  801526:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801529:	bf 00 00 00 00       	mov    $0x0,%edi
  80152e:	eb 11                	jmp    801541 <strtol+0x3e>
  801530:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801535:	80 f9 2d             	cmp    $0x2d,%cl
  801538:	75 07                	jne    801541 <strtol+0x3e>
		s++, neg = 1;
  80153a:	8d 52 01             	lea    0x1(%edx),%edx
  80153d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801541:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801546:	75 15                	jne    80155d <strtol+0x5a>
  801548:	80 3a 30             	cmpb   $0x30,(%edx)
  80154b:	75 10                	jne    80155d <strtol+0x5a>
  80154d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801551:	75 0a                	jne    80155d <strtol+0x5a>
		s += 2, base = 16;
  801553:	83 c2 02             	add    $0x2,%edx
  801556:	b8 10 00 00 00       	mov    $0x10,%eax
  80155b:	eb 10                	jmp    80156d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80155d:	85 c0                	test   %eax,%eax
  80155f:	75 0c                	jne    80156d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801561:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801563:	80 3a 30             	cmpb   $0x30,(%edx)
  801566:	75 05                	jne    80156d <strtol+0x6a>
		s++, base = 8;
  801568:	83 c2 01             	add    $0x1,%edx
  80156b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80156d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801572:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801575:	0f b6 0a             	movzbl (%edx),%ecx
  801578:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80157b:	89 f0                	mov    %esi,%eax
  80157d:	3c 09                	cmp    $0x9,%al
  80157f:	77 08                	ja     801589 <strtol+0x86>
			dig = *s - '0';
  801581:	0f be c9             	movsbl %cl,%ecx
  801584:	83 e9 30             	sub    $0x30,%ecx
  801587:	eb 20                	jmp    8015a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801589:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80158c:	89 f0                	mov    %esi,%eax
  80158e:	3c 19                	cmp    $0x19,%al
  801590:	77 08                	ja     80159a <strtol+0x97>
			dig = *s - 'a' + 10;
  801592:	0f be c9             	movsbl %cl,%ecx
  801595:	83 e9 57             	sub    $0x57,%ecx
  801598:	eb 0f                	jmp    8015a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80159a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80159d:	89 f0                	mov    %esi,%eax
  80159f:	3c 19                	cmp    $0x19,%al
  8015a1:	77 16                	ja     8015b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8015a3:	0f be c9             	movsbl %cl,%ecx
  8015a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8015a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8015ac:	7d 0f                	jge    8015bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8015ae:	83 c2 01             	add    $0x1,%edx
  8015b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8015b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8015b7:	eb bc                	jmp    801575 <strtol+0x72>
  8015b9:	89 d8                	mov    %ebx,%eax
  8015bb:	eb 02                	jmp    8015bf <strtol+0xbc>
  8015bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8015bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015c3:	74 05                	je     8015ca <strtol+0xc7>
		*endptr = (char *) s;
  8015c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8015ca:	f7 d8                	neg    %eax
  8015cc:	85 ff                	test   %edi,%edi
  8015ce:	0f 44 c3             	cmove  %ebx,%eax
}
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	89 c7                	mov    %eax,%edi
  8015eb:	89 c6                	mov    %eax,%esi
  8015ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801604:	89 d1                	mov    %edx,%ecx
  801606:	89 d3                	mov    %edx,%ebx
  801608:	89 d7                	mov    %edx,%edi
  80160a:	89 d6                	mov    %edx,%esi
  80160c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	57                   	push   %edi
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80161c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801621:	b8 03 00 00 00       	mov    $0x3,%eax
  801626:	8b 55 08             	mov    0x8(%ebp),%edx
  801629:	89 cb                	mov    %ecx,%ebx
  80162b:	89 cf                	mov    %ecx,%edi
  80162d:	89 ce                	mov    %ecx,%esi
  80162f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801631:	85 c0                	test   %eax,%eax
  801633:	7e 28                	jle    80165d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801635:	89 44 24 10          	mov    %eax,0x10(%esp)
  801639:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801640:	00 
  801641:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  801648:	00 
  801649:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801650:	00 
  801651:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  801658:	e8 c5 f3 ff ff       	call   800a22 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80165d:	83 c4 2c             	add    $0x2c,%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5f                   	pop    %edi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	57                   	push   %edi
  801669:	56                   	push   %esi
  80166a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80166b:	ba 00 00 00 00       	mov    $0x0,%edx
  801670:	b8 02 00 00 00       	mov    $0x2,%eax
  801675:	89 d1                	mov    %edx,%ecx
  801677:	89 d3                	mov    %edx,%ebx
  801679:	89 d7                	mov    %edx,%edi
  80167b:	89 d6                	mov    %edx,%esi
  80167d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <sys_yield>:

void
sys_yield(void)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801694:	89 d1                	mov    %edx,%ecx
  801696:	89 d3                	mov    %edx,%ebx
  801698:	89 d7                	mov    %edx,%edi
  80169a:	89 d6                	mov    %edx,%esi
  80169c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80169e:	5b                   	pop    %ebx
  80169f:	5e                   	pop    %esi
  8016a0:	5f                   	pop    %edi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	57                   	push   %edi
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ac:	be 00 00 00 00       	mov    $0x0,%esi
  8016b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8016b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016bf:	89 f7                	mov    %esi,%edi
  8016c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	7e 28                	jle    8016ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8016d2:	00 
  8016d3:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  8016da:	00 
  8016db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016e2:	00 
  8016e3:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  8016ea:	e8 33 f3 ff ff       	call   800a22 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8016ef:	83 c4 2c             	add    $0x2c,%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5f                   	pop    %edi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	57                   	push   %edi
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801700:	b8 05 00 00 00       	mov    $0x5,%eax
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	8b 55 08             	mov    0x8(%ebp),%edx
  80170b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801711:	8b 75 18             	mov    0x18(%ebp),%esi
  801714:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801716:	85 c0                	test   %eax,%eax
  801718:	7e 28                	jle    801742 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80171a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80171e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801725:	00 
  801726:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  80172d:	00 
  80172e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801735:	00 
  801736:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  80173d:	e8 e0 f2 ff ff       	call   800a22 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801742:	83 c4 2c             	add    $0x2c,%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801753:	bb 00 00 00 00       	mov    $0x0,%ebx
  801758:	b8 06 00 00 00       	mov    $0x6,%eax
  80175d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	89 df                	mov    %ebx,%edi
  801765:	89 de                	mov    %ebx,%esi
  801767:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801769:	85 c0                	test   %eax,%eax
  80176b:	7e 28                	jle    801795 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80176d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801771:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801778:	00 
  801779:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  801780:	00 
  801781:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801788:	00 
  801789:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  801790:	e8 8d f2 ff ff       	call   800a22 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801795:	83 c4 2c             	add    $0x2c,%esp
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	57                   	push   %edi
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8017b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b6:	89 df                	mov    %ebx,%edi
  8017b8:	89 de                	mov    %ebx,%esi
  8017ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	7e 28                	jle    8017e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8017cb:	00 
  8017cc:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  8017d3:	00 
  8017d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017db:	00 
  8017dc:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  8017e3:	e8 3a f2 ff ff       	call   800a22 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8017e8:	83 c4 2c             	add    $0x2c,%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	5f                   	pop    %edi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	57                   	push   %edi
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017fe:	b8 09 00 00 00       	mov    $0x9,%eax
  801803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801806:	8b 55 08             	mov    0x8(%ebp),%edx
  801809:	89 df                	mov    %ebx,%edi
  80180b:	89 de                	mov    %ebx,%esi
  80180d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80180f:	85 c0                	test   %eax,%eax
  801811:	7e 28                	jle    80183b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801813:	89 44 24 10          	mov    %eax,0x10(%esp)
  801817:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80181e:	00 
  80181f:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  801826:	00 
  801827:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80182e:	00 
  80182f:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  801836:	e8 e7 f1 ff ff       	call   800a22 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80183b:	83 c4 2c             	add    $0x2c,%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80184c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801851:	b8 0a 00 00 00       	mov    $0xa,%eax
  801856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801859:	8b 55 08             	mov    0x8(%ebp),%edx
  80185c:	89 df                	mov    %ebx,%edi
  80185e:	89 de                	mov    %ebx,%esi
  801860:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801862:	85 c0                	test   %eax,%eax
  801864:	7e 28                	jle    80188e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801866:	89 44 24 10          	mov    %eax,0x10(%esp)
  80186a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801871:	00 
  801872:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  801879:	00 
  80187a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801881:	00 
  801882:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  801889:	e8 94 f1 ff ff       	call   800a22 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80188e:	83 c4 2c             	add    $0x2c,%esp
  801891:	5b                   	pop    %ebx
  801892:	5e                   	pop    %esi
  801893:	5f                   	pop    %edi
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	57                   	push   %edi
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80189c:	be 00 00 00 00       	mov    $0x0,%esi
  8018a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8018a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8018b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5f                   	pop    %edi
  8018b7:	5d                   	pop    %ebp
  8018b8:	c3                   	ret    

008018b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	57                   	push   %edi
  8018bd:	56                   	push   %esi
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8018cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cf:	89 cb                	mov    %ecx,%ebx
  8018d1:	89 cf                	mov    %ecx,%edi
  8018d3:	89 ce                	mov    %ecx,%esi
  8018d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	7e 28                	jle    801903 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8018e6:	00 
  8018e7:	c7 44 24 08 af 3b 80 	movl   $0x803baf,0x8(%esp)
  8018ee:	00 
  8018ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018f6:	00 
  8018f7:	c7 04 24 cc 3b 80 00 	movl   $0x803bcc,(%esp)
  8018fe:	e8 1f f1 ff ff       	call   800a22 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801903:	83 c4 2c             	add    $0x2c,%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	83 ec 20             	sub    $0x20,%esp
  801913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  801916:	8b 33                	mov    (%ebx),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB : Your code here.
if( (err & FEC_WR) == 0){
  801918:	f6 43 04 02          	testb  $0x2,0x4(%ebx)
  80191c:	75 3f                	jne    80195d <pgfault+0x52>
		//cprintf(	" The eid = %x\n", sys_getenvid());
		//cprintf("The err is %d\n", err);
		cprintf("The va is 0x%x\n", (int)addr );
  80191e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801922:	c7 04 24 da 3b 80 00 	movl   $0x803bda,(%esp)
  801929:	e8 ed f1 ff ff       	call   800b1b <cprintf>
		cprintf("The Eip is 0x%x\n", utf->utf_eip);
  80192e:	8b 43 28             	mov    0x28(%ebx),%eax
  801931:	89 44 24 04          	mov    %eax,0x4(%esp)
  801935:	c7 04 24 ea 3b 80 00 	movl   $0x803bea,(%esp)
  80193c:	e8 da f1 ff ff       	call   800b1b <cprintf>

		 panic("The err is not right of the pgfault\n ");
  801941:	c7 44 24 08 30 3c 80 	movl   $0x803c30,0x8(%esp)
  801948:	00 
  801949:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801950:	00 
  801951:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801958:	e8 c5 f0 ff ff       	call   800a22 <_panic>
	}

	pte_t PTE =uvpt[PGNUM(addr)];
  80195d:	89 f0                	mov    %esi,%eax
  80195f:	c1 e8 0c             	shr    $0xc,%eax
  801962:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax

	if( (PTE & PTE_COW) == 0)
  801969:	f6 c4 08             	test   $0x8,%ah
  80196c:	75 1c                	jne    80198a <pgfault+0x7f>
		panic("The pgfault perm is not right\n");
  80196e:	c7 44 24 08 58 3c 80 	movl   $0x803c58,0x8(%esp)
  801975:	00 
  801976:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80197d:	00 
  80197e:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801985:	e8 98 f0 ff ff       	call   800a22 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB : Your code here.

	if(sys_page_alloc(sys_getenvid(), (void*)PFTEMP, PTE_U|PTE_W|PTE_P) <0 )
  80198a:	e8 d6 fc ff ff       	call   801665 <sys_getenvid>
  80198f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801996:	00 
  801997:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80199e:	00 
  80199f:	89 04 24             	mov    %eax,(%esp)
  8019a2:	e8 fc fc ff ff       	call   8016a3 <sys_page_alloc>
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	79 1c                	jns    8019c7 <pgfault+0xbc>
		panic("pgfault sys_page_alloc is not right\n");
  8019ab:	c7 44 24 08 78 3c 80 	movl   $0x803c78,0x8(%esp)
  8019b2:	00 
  8019b3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8019ba:	00 
  8019bb:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  8019c2:	e8 5b f0 ff ff       	call   800a22 <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8019c7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy((void*)PFTEMP, addr, PGSIZE);
  8019cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8019d4:	00 
  8019d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8019e0:	e8 a7 fa ff ff       	call   80148c <memcpy>

	if((r = sys_page_map(sys_getenvid(), (void*)PFTEMP, sys_getenvid(), addr, PTE_U|PTE_W|PTE_P)) < 0)
  8019e5:	e8 7b fc ff ff       	call   801665 <sys_getenvid>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	e8 74 fc ff ff       	call   801665 <sys_getenvid>
  8019f1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019f8:	00 
  8019f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a01:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a08:	00 
  801a09:	89 04 24             	mov    %eax,(%esp)
  801a0c:	e8 e6 fc ff ff       	call   8016f7 <sys_page_map>
  801a11:	85 c0                	test   %eax,%eax
  801a13:	79 20                	jns    801a35 <pgfault+0x12a>
		panic("The sys_page_map is not right, the errno is %d\n", r);
  801a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a19:	c7 44 24 08 a0 3c 80 	movl   $0x803ca0,0x8(%esp)
  801a20:	00 
  801a21:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  801a28:	00 
  801a29:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801a30:	e8 ed ef ff ff       	call   800a22 <_panic>
	if( (r = sys_page_unmap(sys_getenvid(), (void*)PFTEMP)) <0 )
  801a35:	e8 2b fc ff ff       	call   801665 <sys_getenvid>
  801a3a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a41:	00 
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 00 fd ff ff       	call   80174a <sys_page_unmap>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 20                	jns    801a6e <pgfault+0x163>
		panic("The sys_page_unmap is not right, the errno is %d\n",r);
  801a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a52:	c7 44 24 08 d0 3c 80 	movl   $0x803cd0,0x8(%esp)
  801a59:	00 
  801a5a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801a61:	00 
  801a62:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801a69:	e8 b4 ef ff ff       	call   800a22 <_panic>
	return;
}
  801a6e:	83 c4 20             	add    $0x20,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	57                   	push   %edi
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 2c             	sub    $0x2c,%esp
	// LAB : Your code here.
	extern void*  _pgfault_upcall();
	//build the experition stack for the parent env
	set_pgfault_handler(pgfault);
  801a7e:	c7 04 24 0b 19 80 00 	movl   $0x80190b,(%esp)
  801a85:	e8 a6 16 00 00       	call   803130 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801a8a:	b8 07 00 00 00       	mov    $0x7,%eax
  801a8f:	cd 30                	int    $0x30
  801a91:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a94:	89 45 e0             	mov    %eax,-0x20(%ebp)

	int childEid = sys_exofork();
	if(childEid < 0)
  801a97:	85 c0                	test   %eax,%eax
  801a99:	79 20                	jns    801abb <fork+0x46>
		panic("sys_exofork() is not right, and the errno is  %d\n",childEid);
  801a9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9f:	c7 44 24 08 04 3d 80 	movl   $0x803d04,0x8(%esp)
  801aa6:	00 
  801aa7:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  801aae:	00 
  801aaf:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801ab6:	e8 67 ef ff ff       	call   800a22 <_panic>
	if(childEid == 0){
  801abb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801abf:	75 1c                	jne    801add <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801ac1:	e8 9f fb ff ff       	call   801665 <sys_getenvid>
  801ac6:	25 ff 03 00 00       	and    $0x3ff,%eax
  801acb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ace:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad3:	a3 24 64 80 00       	mov    %eax,0x806424
		return childEid;
  801ad8:	e9 a0 01 00 00       	jmp    801c7d <fork+0x208>
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
  801add:	c7 44 24 04 c6 31 80 	movl   $0x8031c6,0x4(%esp)
  801ae4:	00 
  801ae5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 53 fd ff ff       	call   801843 <sys_env_set_pgfault_upcall>
  801af0:	89 c7                	mov    %eax,%edi
	if(r < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	79 20                	jns    801b16 <fork+0xa1>
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
  801af6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801afa:	c7 44 24 08 38 3d 80 	movl   $0x803d38,0x8(%esp)
  801b01:	00 
  801b02:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801b09:	00 
  801b0a:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801b11:	e8 0c ef ff ff       	call   800a22 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return childEid;
	}

	int r = sys_env_set_pgfault_upcall(childEid,  _pgfault_upcall);
	if(r < 0)
  801b16:	be 00 10 00 00       	mov    $0x1000,%esi
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b25:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	c1 ea 16             	shr    $0x16,%edx
  801b2d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b34:	f6 c2 01             	test   $0x1,%dl
  801b37:	0f 84 f7 00 00 00    	je     801c34 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801b3d:	c1 e8 0c             	shr    $0xc,%eax
  801b40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
  801b47:	f6 c2 04             	test   $0x4,%dl
  801b4a:	0f 84 e4 00 00 00    	je     801c34 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
  801b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if ( ( 	(uvpd[PDX(pn*PGSIZE)] & PTE_P) != 0) &&
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_U) != 0) &&
  801b57:	a8 01                	test   $0x1,%al
  801b59:	0f 84 d5 00 00 00    	je     801c34 <fork+0x1bf>
				( (uvpt[PGNUM(pn*PGSIZE)] & PTE_P) != 0))
		{
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
  801b5f:	81 f9 00 f0 bf ee    	cmp    $0xeebff000,%ecx
  801b65:	75 20                	jne    801b87 <fork+0x112>
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
  801b67:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b76:	ee 
  801b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 21 fb ff ff       	call   8016a3 <sys_page_alloc>
  801b82:	e9 84 00 00 00       	jmp    801c0b <fork+0x196>
  801b87:	8d be 00 f0 ff ff    	lea    -0x1000(%esi),%edi
duppage(envid_t envid, unsigned pn)
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	c1 e8 0c             	shr    $0xc,%eax
  801b92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int perm = PTE_U|PTE_P;
	if((PTE & PTE_W) || (PTE & PTE_COW))
  801b99:	25 02 08 00 00       	and    $0x802,%eax
{
	int r;
	

	pte_t  PTE= uvpt[PGNUM(pn*PGSIZE)];
	int perm = PTE_U|PTE_P;
  801b9e:	83 f8 01             	cmp    $0x1,%eax
  801ba1:	19 db                	sbb    %ebx,%ebx
  801ba3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801ba9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	if((PTE & PTE_W) || (PTE & PTE_COW))
		perm |= PTE_COW;
	
	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE), perm)) 
  801baf:	e8 b1 fa ff ff       	call   801665 <sys_getenvid>
  801bb4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801bb8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bbc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801bbf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bc3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 28 fb ff ff       	call   8016f7 <sys_page_map>
  801bcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	78 35                	js     801c0b <fork+0x196>
						<0)  
		return r;

	if( (	r =sys_page_map(sys_getenvid(), (void*)(pn*PGSIZE), sys_getenvid(), (void*)(pn*PGSIZE), perm)) 
  801bd6:	e8 8a fa ff ff       	call   801665 <sys_getenvid>
  801bdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bde:	e8 82 fa ff ff       	call   801665 <sys_getenvid>
  801be3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801be7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801beb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801bee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bf6:	89 04 24             	mov    %eax,(%esp)
  801bf9:	e8 f9 fa ff ff       	call   8016f7 <sys_page_map>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	bf 00 00 00 00       	mov    $0x0,%edi
  801c05:	0f 4f c7             	cmovg  %edi,%eax
  801c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		//build experition stack for the child env
			if(pn*PGSIZE == UXSTACKTOP -PGSIZE)
				sys_page_alloc(childEid, (void*) (pn*PGSIZE), PTE_U| PTE_W | PTE_P);
			else
				r = duppage(childEid, pn);
			if(r <0)
  801c0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801c0f:	79 23                	jns    801c34 <fork+0x1bf>
  801c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				panic("fork() is wrong, and the errno is %d\n", r) ;
  801c14:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c18:	c7 44 24 08 78 3d 80 	movl   $0x803d78,0x8(%esp)
  801c1f:	00 
  801c20:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801c27:	00 
  801c28:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801c2f:	e8 ee ed ff ff       	call   800a22 <_panic>
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);
	

	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
  801c34:	89 f1                	mov    %esi,%ecx
  801c36:	89 f0                	mov    %esi,%eax
  801c38:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c3e:	81 fe 00 10 c0 ee    	cmp    $0xeec01000,%esi
  801c44:	0f 85 de fe ff ff    	jne    801b28 <fork+0xb3>
				r = duppage(childEid, pn);
			if(r <0)
				panic("fork() is wrong, and the errno is %d\n", r) ;
		}
	}
	if (sys_env_set_status(childEid, ENV_RUNNABLE) < 0)
  801c4a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801c51:	00 
  801c52:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 40 fb ff ff       	call   80179d <sys_env_set_status>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	79 1c                	jns    801c7d <fork+0x208>
		panic("sys_env_set_status");
  801c61:	c7 44 24 08 06 3c 80 	movl   $0x803c06,0x8(%esp)
  801c68:	00 
  801c69:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801c70:	00 
  801c71:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801c78:	e8 a5 ed ff ff       	call   800a22 <_panic>
	return childEid;
}
  801c7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c80:	83 c4 2c             	add    $0x2c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    

00801c88 <sfork>:

// Challenge!
int
sfork(void)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801c8e:	c7 44 24 08 19 3c 80 	movl   $0x803c19,0x8(%esp)
  801c95:	00 
  801c96:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c9d:	00 
  801c9e:	c7 04 24 fb 3b 80 00 	movl   $0x803bfb,(%esp)
  801ca5:	e8 78 ed ff ff       	call   800a22 <_panic>

00801caa <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	53                   	push   %ebx
  801cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb4:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801cb7:	89 08                	mov    %ecx,(%eax)
	args->argv = (const char **) argv;
  801cb9:	89 50 04             	mov    %edx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc1:	83 39 01             	cmpl   $0x1,(%ecx)
  801cc4:	7e 0f                	jle    801cd5 <argstart+0x2b>
  801cc6:	85 d2                	test   %edx,%edx
  801cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccd:	bb 81 36 80 00       	mov    $0x803681,%ebx
  801cd2:	0f 44 da             	cmove  %edx,%ebx
  801cd5:	89 58 08             	mov    %ebx,0x8(%eax)
	args->argvalue = 0;
  801cd8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801cdf:	5b                   	pop    %ebx
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <argnext>:

int
argnext(struct Argstate *args)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 14             	sub    $0x14,%esp
  801ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801cec:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801cf3:	8b 43 08             	mov    0x8(%ebx),%eax
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	74 71                	je     801d6b <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  801cfa:	80 38 00             	cmpb   $0x0,(%eax)
  801cfd:	75 50                	jne    801d4f <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801cff:	8b 0b                	mov    (%ebx),%ecx
  801d01:	83 39 01             	cmpl   $0x1,(%ecx)
  801d04:	74 57                	je     801d5d <argnext+0x7b>
		    || args->argv[1][0] != '-'
  801d06:	8b 53 04             	mov    0x4(%ebx),%edx
  801d09:	8b 42 04             	mov    0x4(%edx),%eax
  801d0c:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d0f:	75 4c                	jne    801d5d <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801d11:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d15:	74 46                	je     801d5d <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801d17:	83 c0 01             	add    $0x1,%eax
  801d1a:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d1d:	8b 01                	mov    (%ecx),%eax
  801d1f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d2a:	8d 42 08             	lea    0x8(%edx),%eax
  801d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d31:	83 c2 04             	add    $0x4,%edx
  801d34:	89 14 24             	mov    %edx,(%esp)
  801d37:	e8 e8 f6 ff ff       	call   801424 <memmove>
		(*args->argc)--;
  801d3c:	8b 03                	mov    (%ebx),%eax
  801d3e:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d41:	8b 43 08             	mov    0x8(%ebx),%eax
  801d44:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d47:	75 06                	jne    801d4f <argnext+0x6d>
  801d49:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d4d:	74 0e                	je     801d5d <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d4f:	8b 53 08             	mov    0x8(%ebx),%edx
  801d52:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801d55:	83 c2 01             	add    $0x1,%edx
  801d58:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801d5b:	eb 13                	jmp    801d70 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  801d5d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801d69:	eb 05                	jmp    801d70 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801d70:	83 c4 14             	add    $0x14,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	53                   	push   %ebx
  801d7a:	83 ec 14             	sub    $0x14,%esp
  801d7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801d80:	8b 43 08             	mov    0x8(%ebx),%eax
  801d83:	85 c0                	test   %eax,%eax
  801d85:	74 5a                	je     801de1 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801d87:	80 38 00             	cmpb   $0x0,(%eax)
  801d8a:	74 0c                	je     801d98 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801d8c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801d8f:	c7 43 08 81 36 80 00 	movl   $0x803681,0x8(%ebx)
  801d96:	eb 44                	jmp    801ddc <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  801d98:	8b 03                	mov    (%ebx),%eax
  801d9a:	83 38 01             	cmpl   $0x1,(%eax)
  801d9d:	7e 2f                	jle    801dce <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801d9f:	8b 53 04             	mov    0x4(%ebx),%edx
  801da2:	8b 4a 04             	mov    0x4(%edx),%ecx
  801da5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801da8:	8b 00                	mov    (%eax),%eax
  801daa:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801db1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db5:	8d 42 08             	lea    0x8(%edx),%eax
  801db8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dbc:	83 c2 04             	add    $0x4,%edx
  801dbf:	89 14 24             	mov    %edx,(%esp)
  801dc2:	e8 5d f6 ff ff       	call   801424 <memmove>
		(*args->argc)--;
  801dc7:	8b 03                	mov    (%ebx),%eax
  801dc9:	83 28 01             	subl   $0x1,(%eax)
  801dcc:	eb 0e                	jmp    801ddc <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  801dce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801dd5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801ddc:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ddf:	eb 05                	jmp    801de6 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801de1:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801de6:	83 c4 14             	add    $0x14,%esp
  801de9:	5b                   	pop    %ebx
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 18             	sub    $0x18,%esp
  801df2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801df5:	8b 51 0c             	mov    0xc(%ecx),%edx
  801df8:	89 d0                	mov    %edx,%eax
  801dfa:	85 d2                	test   %edx,%edx
  801dfc:	75 08                	jne    801e06 <argvalue+0x1a>
  801dfe:	89 0c 24             	mov    %ecx,(%esp)
  801e01:	e8 70 ff ff ff       	call   801d76 <argnextvalue>
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    
  801e08:	66 90                	xchg   %ax,%ax
  801e0a:	66 90                	xchg   %ax,%ax
  801e0c:	66 90                	xchg   %ax,%ax
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	05 00 00 00 30       	add    $0x30000000,%eax
  801e1b:	c1 e8 0c             	shr    $0xc,%eax
}
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801e2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801e30:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    

00801e37 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e42:	89 c2                	mov    %eax,%edx
  801e44:	c1 ea 16             	shr    $0x16,%edx
  801e47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e4e:	f6 c2 01             	test   $0x1,%dl
  801e51:	74 11                	je     801e64 <fd_alloc+0x2d>
  801e53:	89 c2                	mov    %eax,%edx
  801e55:	c1 ea 0c             	shr    $0xc,%edx
  801e58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e5f:	f6 c2 01             	test   $0x1,%dl
  801e62:	75 09                	jne    801e6d <fd_alloc+0x36>
			*fd_store = fd;
  801e64:	89 01                	mov    %eax,(%ecx)
			return 0;
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6b:	eb 17                	jmp    801e84 <fd_alloc+0x4d>
  801e6d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801e72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e77:	75 c9                	jne    801e42 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801e7f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801e8c:	83 f8 1f             	cmp    $0x1f,%eax
  801e8f:	77 36                	ja     801ec7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e91:	c1 e0 0c             	shl    $0xc,%eax
  801e94:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	c1 ea 16             	shr    $0x16,%edx
  801e9e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ea5:	f6 c2 01             	test   $0x1,%dl
  801ea8:	74 24                	je     801ece <fd_lookup+0x48>
  801eaa:	89 c2                	mov    %eax,%edx
  801eac:	c1 ea 0c             	shr    $0xc,%edx
  801eaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801eb6:	f6 c2 01             	test   $0x1,%dl
  801eb9:	74 1a                	je     801ed5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebe:	89 02                	mov    %eax,(%edx)
	return 0;
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec5:	eb 13                	jmp    801eda <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ec7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ecc:	eb 0c                	jmp    801eda <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ed3:	eb 05                	jmp    801eda <fd_lookup+0x54>
  801ed5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801eda:	5d                   	pop    %ebp
  801edb:	c3                   	ret    

00801edc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 18             	sub    $0x18,%esp
  801ee2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee5:	ba 1c 3e 80 00       	mov    $0x803e1c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801eea:	eb 13                	jmp    801eff <dev_lookup+0x23>
  801eec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801eef:	39 08                	cmp    %ecx,(%eax)
  801ef1:	75 0c                	jne    801eff <dev_lookup+0x23>
			*dev = devtab[i];
  801ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef6:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  801efd:	eb 30                	jmp    801f2f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801eff:	8b 02                	mov    (%edx),%eax
  801f01:	85 c0                	test   %eax,%eax
  801f03:	75 e7                	jne    801eec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f05:	a1 24 64 80 00       	mov    0x806424,%eax
  801f0a:	8b 40 48             	mov    0x48(%eax),%eax
  801f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f15:	c7 04 24 a0 3d 80 00 	movl   $0x803da0,(%esp)
  801f1c:	e8 fa eb ff ff       	call   800b1b <cprintf>
	*dev = 0;
  801f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
  801f36:	83 ec 20             	sub    $0x20,%esp
  801f39:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f42:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801f46:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801f4c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 2f ff ff ff       	call   801e86 <fd_lookup>
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 05                	js     801f60 <fd_close+0x2f>
	    || fd != fd2)
  801f5b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801f5e:	74 0c                	je     801f6c <fd_close+0x3b>
		return (must_exist ? r : 0);
  801f60:	84 db                	test   %bl,%bl
  801f62:	ba 00 00 00 00       	mov    $0x0,%edx
  801f67:	0f 44 c2             	cmove  %edx,%eax
  801f6a:	eb 3f                	jmp    801fab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f73:	8b 06                	mov    (%esi),%eax
  801f75:	89 04 24             	mov    %eax,(%esp)
  801f78:	e8 5f ff ff ff       	call   801edc <dev_lookup>
  801f7d:	89 c3                	mov    %eax,%ebx
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 16                	js     801f99 <fd_close+0x68>
		if (dev->dev_close)
  801f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f86:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801f89:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	74 07                	je     801f99 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  801f92:	89 34 24             	mov    %esi,(%esp)
  801f95:	ff d0                	call   *%eax
  801f97:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa4:	e8 a1 f7 ff ff       	call   80174a <sys_page_unmap>
	return r;
  801fa9:	89 d8                	mov    %ebx,%eax
}
  801fab:	83 c4 20             	add    $0x20,%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	89 04 24             	mov    %eax,(%esp)
  801fc5:	e8 bc fe ff ff       	call   801e86 <fd_lookup>
  801fca:	89 c2                	mov    %eax,%edx
  801fcc:	85 d2                	test   %edx,%edx
  801fce:	78 13                	js     801fe3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801fd0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd7:	00 
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	89 04 24             	mov    %eax,(%esp)
  801fde:	e8 4e ff ff ff       	call   801f31 <fd_close>
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <close_all>:

void
close_all(void)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801fec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ff1:	89 1c 24             	mov    %ebx,(%esp)
  801ff4:	e8 b9 ff ff ff       	call   801fb2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801ff9:	83 c3 01             	add    $0x1,%ebx
  801ffc:	83 fb 20             	cmp    $0x20,%ebx
  801fff:	75 f0                	jne    801ff1 <close_all+0xc>
		close(i);
}
  802001:	83 c4 14             	add    $0x14,%esp
  802004:	5b                   	pop    %ebx
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    

00802007 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	57                   	push   %edi
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802010:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802013:	89 44 24 04          	mov    %eax,0x4(%esp)
  802017:	8b 45 08             	mov    0x8(%ebp),%eax
  80201a:	89 04 24             	mov    %eax,(%esp)
  80201d:	e8 64 fe ff ff       	call   801e86 <fd_lookup>
  802022:	89 c2                	mov    %eax,%edx
  802024:	85 d2                	test   %edx,%edx
  802026:	0f 88 e1 00 00 00    	js     80210d <dup+0x106>
		return r;
	close(newfdnum);
  80202c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202f:	89 04 24             	mov    %eax,(%esp)
  802032:	e8 7b ff ff ff       	call   801fb2 <close>

	newfd = INDEX2FD(newfdnum);
  802037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80203a:	c1 e3 0c             	shl    $0xc,%ebx
  80203d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802046:	89 04 24             	mov    %eax,(%esp)
  802049:	e8 d2 fd ff ff       	call   801e20 <fd2data>
  80204e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  802050:	89 1c 24             	mov    %ebx,(%esp)
  802053:	e8 c8 fd ff ff       	call   801e20 <fd2data>
  802058:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80205a:	89 f0                	mov    %esi,%eax
  80205c:	c1 e8 16             	shr    $0x16,%eax
  80205f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802066:	a8 01                	test   $0x1,%al
  802068:	74 43                	je     8020ad <dup+0xa6>
  80206a:	89 f0                	mov    %esi,%eax
  80206c:	c1 e8 0c             	shr    $0xc,%eax
  80206f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802076:	f6 c2 01             	test   $0x1,%dl
  802079:	74 32                	je     8020ad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80207b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802082:	25 07 0e 00 00       	and    $0xe07,%eax
  802087:	89 44 24 10          	mov    %eax,0x10(%esp)
  80208b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80208f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802096:	00 
  802097:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a2:	e8 50 f6 ff ff       	call   8016f7 <sys_page_map>
  8020a7:	89 c6                	mov    %eax,%esi
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 3e                	js     8020eb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b0:	89 c2                	mov    %eax,%edx
  8020b2:	c1 ea 0c             	shr    $0xc,%edx
  8020b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8020c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8020c6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020d1:	00 
  8020d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020dd:	e8 15 f6 ff ff       	call   8016f7 <sys_page_map>
  8020e2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	79 22                	jns    80210d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8020eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f6:	e8 4f f6 ff ff       	call   80174a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8020fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802106:	e8 3f f6 ff ff       	call   80174a <sys_page_unmap>
	return r;
  80210b:	89 f0                	mov    %esi,%eax
}
  80210d:	83 c4 3c             	add    $0x3c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	53                   	push   %ebx
  802119:	83 ec 24             	sub    $0x24,%esp
  80211c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80211f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802122:	89 44 24 04          	mov    %eax,0x4(%esp)
  802126:	89 1c 24             	mov    %ebx,(%esp)
  802129:	e8 58 fd ff ff       	call   801e86 <fd_lookup>
  80212e:	89 c2                	mov    %eax,%edx
  802130:	85 d2                	test   %edx,%edx
  802132:	78 6d                	js     8021a1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213e:	8b 00                	mov    (%eax),%eax
  802140:	89 04 24             	mov    %eax,(%esp)
  802143:	e8 94 fd ff ff       	call   801edc <dev_lookup>
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 55                	js     8021a1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80214c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214f:	8b 50 08             	mov    0x8(%eax),%edx
  802152:	83 e2 03             	and    $0x3,%edx
  802155:	83 fa 01             	cmp    $0x1,%edx
  802158:	75 23                	jne    80217d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80215a:	a1 24 64 80 00       	mov    0x806424,%eax
  80215f:	8b 40 48             	mov    0x48(%eax),%eax
  802162:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216a:	c7 04 24 e1 3d 80 00 	movl   $0x803de1,(%esp)
  802171:	e8 a5 e9 ff ff       	call   800b1b <cprintf>
		return -E_INVAL;
  802176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80217b:	eb 24                	jmp    8021a1 <read+0x8c>
	}
	if (!dev->dev_read)
  80217d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802180:	8b 52 08             	mov    0x8(%edx),%edx
  802183:	85 d2                	test   %edx,%edx
  802185:	74 15                	je     80219c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802187:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80218a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802191:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	ff d2                	call   *%edx
  80219a:	eb 05                	jmp    8021a1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80219c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8021a1:	83 c4 24             	add    $0x24,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	57                   	push   %edi
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 1c             	sub    $0x1c,%esp
  8021b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021bb:	eb 23                	jmp    8021e0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021bd:	89 f0                	mov    %esi,%eax
  8021bf:	29 d8                	sub    %ebx,%eax
  8021c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c5:	89 d8                	mov    %ebx,%eax
  8021c7:	03 45 0c             	add    0xc(%ebp),%eax
  8021ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ce:	89 3c 24             	mov    %edi,(%esp)
  8021d1:	e8 3f ff ff ff       	call   802115 <read>
		if (m < 0)
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	78 10                	js     8021ea <readn+0x43>
			return m;
		if (m == 0)
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	74 0a                	je     8021e8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021de:	01 c3                	add    %eax,%ebx
  8021e0:	39 f3                	cmp    %esi,%ebx
  8021e2:	72 d9                	jb     8021bd <readn+0x16>
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	eb 02                	jmp    8021ea <readn+0x43>
  8021e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    

008021f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	53                   	push   %ebx
  8021f6:	83 ec 24             	sub    $0x24,%esp
  8021f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802203:	89 1c 24             	mov    %ebx,(%esp)
  802206:	e8 7b fc ff ff       	call   801e86 <fd_lookup>
  80220b:	89 c2                	mov    %eax,%edx
  80220d:	85 d2                	test   %edx,%edx
  80220f:	78 68                	js     802279 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	89 44 24 04          	mov    %eax,0x4(%esp)
  802218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80221b:	8b 00                	mov    (%eax),%eax
  80221d:	89 04 24             	mov    %eax,(%esp)
  802220:	e8 b7 fc ff ff       	call   801edc <dev_lookup>
  802225:	85 c0                	test   %eax,%eax
  802227:	78 50                	js     802279 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80222c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802230:	75 23                	jne    802255 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802232:	a1 24 64 80 00       	mov    0x806424,%eax
  802237:	8b 40 48             	mov    0x48(%eax),%eax
  80223a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802242:	c7 04 24 fd 3d 80 00 	movl   $0x803dfd,(%esp)
  802249:	e8 cd e8 ff ff       	call   800b1b <cprintf>
		return -E_INVAL;
  80224e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802253:	eb 24                	jmp    802279 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802255:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802258:	8b 52 0c             	mov    0xc(%edx),%edx
  80225b:	85 d2                	test   %edx,%edx
  80225d:	74 15                	je     802274 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80225f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802262:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802269:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80226d:	89 04 24             	mov    %eax,(%esp)
  802270:	ff d2                	call   *%edx
  802272:	eb 05                	jmp    802279 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802274:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802279:	83 c4 24             	add    $0x24,%esp
  80227c:	5b                   	pop    %ebx
  80227d:	5d                   	pop    %ebp
  80227e:	c3                   	ret    

0080227f <seek>:

int
seek(int fdnum, off_t offset)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802285:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	89 04 24             	mov    %eax,(%esp)
  802292:	e8 ef fb ff ff       	call   801e86 <fd_lookup>
  802297:	85 c0                	test   %eax,%eax
  802299:	78 0e                	js     8022a9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80229b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80229e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    

008022ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	53                   	push   %ebx
  8022af:	83 ec 24             	sub    $0x24,%esp
  8022b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022bc:	89 1c 24             	mov    %ebx,(%esp)
  8022bf:	e8 c2 fb ff ff       	call   801e86 <fd_lookup>
  8022c4:	89 c2                	mov    %eax,%edx
  8022c6:	85 d2                	test   %edx,%edx
  8022c8:	78 61                	js     80232b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d4:	8b 00                	mov    (%eax),%eax
  8022d6:	89 04 24             	mov    %eax,(%esp)
  8022d9:	e8 fe fb ff ff       	call   801edc <dev_lookup>
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	78 49                	js     80232b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022e9:	75 23                	jne    80230e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8022eb:	a1 24 64 80 00       	mov    0x806424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8022f0:	8b 40 48             	mov    0x48(%eax),%eax
  8022f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022fb:	c7 04 24 c0 3d 80 00 	movl   $0x803dc0,(%esp)
  802302:	e8 14 e8 ff ff       	call   800b1b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80230c:	eb 1d                	jmp    80232b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80230e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802311:	8b 52 18             	mov    0x18(%edx),%edx
  802314:	85 d2                	test   %edx,%edx
  802316:	74 0e                	je     802326 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80231b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80231f:	89 04 24             	mov    %eax,(%esp)
  802322:	ff d2                	call   *%edx
  802324:	eb 05                	jmp    80232b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802326:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80232b:	83 c4 24             	add    $0x24,%esp
  80232e:	5b                   	pop    %ebx
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    

00802331 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	53                   	push   %ebx
  802335:	83 ec 24             	sub    $0x24,%esp
  802338:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80233b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80233e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
  802345:	89 04 24             	mov    %eax,(%esp)
  802348:	e8 39 fb ff ff       	call   801e86 <fd_lookup>
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	85 d2                	test   %edx,%edx
  802351:	78 52                	js     8023a5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802353:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80235d:	8b 00                	mov    (%eax),%eax
  80235f:	89 04 24             	mov    %eax,(%esp)
  802362:	e8 75 fb ff ff       	call   801edc <dev_lookup>
  802367:	85 c0                	test   %eax,%eax
  802369:	78 3a                	js     8023a5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80236b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802372:	74 2c                	je     8023a0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802374:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802377:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80237e:	00 00 00 
	stat->st_isdir = 0;
  802381:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802388:	00 00 00 
	stat->st_dev = dev;
  80238b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802395:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802398:	89 14 24             	mov    %edx,(%esp)
  80239b:	ff 50 14             	call   *0x14(%eax)
  80239e:	eb 05                	jmp    8023a5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8023a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8023a5:	83 c4 24             	add    $0x24,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	56                   	push   %esi
  8023af:	53                   	push   %ebx
  8023b0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8023b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8023ba:	00 
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	89 04 24             	mov    %eax,(%esp)
  8023c1:	e8 fb 01 00 00       	call   8025c1 <open>
  8023c6:	89 c3                	mov    %eax,%ebx
  8023c8:	85 db                	test   %ebx,%ebx
  8023ca:	78 1b                	js     8023e7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8023cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d3:	89 1c 24             	mov    %ebx,(%esp)
  8023d6:	e8 56 ff ff ff       	call   802331 <fstat>
  8023db:	89 c6                	mov    %eax,%esi
	close(fd);
  8023dd:	89 1c 24             	mov    %ebx,(%esp)
  8023e0:	e8 cd fb ff ff       	call   801fb2 <close>
	return r;
  8023e5:	89 f0                	mov    %esi,%eax
}
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	5b                   	pop    %ebx
  8023eb:	5e                   	pop    %esi
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	56                   	push   %esi
  8023f2:	53                   	push   %ebx
  8023f3:	83 ec 10             	sub    $0x10,%esp
  8023f6:	89 c6                	mov    %eax,%esi
  8023f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8023fa:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  802401:	75 11                	jne    802414 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80240a:	e8 4e 0f 00 00       	call   80335d <ipc_find_env>
  80240f:	a3 20 64 80 00       	mov    %eax,0x806420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802414:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80241b:	00 
  80241c:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802423:	00 
  802424:	89 74 24 04          	mov    %esi,0x4(%esp)
  802428:	a1 20 64 80 00       	mov    0x806420,%eax
  80242d:	89 04 24             	mov    %eax,(%esp)
  802430:	e8 79 0e 00 00       	call   8032ae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802435:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80243c:	00 
  80243d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802448:	e8 c3 0d 00 00       	call   803210 <ipc_recv>
}
  80244d:	83 c4 10             	add    $0x10,%esp
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80245a:	8b 45 08             	mov    0x8(%ebp),%eax
  80245d:	8b 40 0c             	mov    0xc(%eax),%eax
  802460:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  802465:	8b 45 0c             	mov    0xc(%ebp),%eax
  802468:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80246d:	ba 00 00 00 00       	mov    $0x0,%edx
  802472:	b8 02 00 00 00       	mov    $0x2,%eax
  802477:	e8 72 ff ff ff       	call   8023ee <fsipc>
}
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802484:	8b 45 08             	mov    0x8(%ebp),%eax
  802487:	8b 40 0c             	mov    0xc(%eax),%eax
  80248a:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80248f:	ba 00 00 00 00       	mov    $0x0,%edx
  802494:	b8 06 00 00 00       	mov    $0x6,%eax
  802499:	e8 50 ff ff ff       	call   8023ee <fsipc>
}
  80249e:	c9                   	leave  
  80249f:	c3                   	ret    

008024a0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 14             	sub    $0x14,%esp
  8024a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8024aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8024b0:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8024b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8024bf:	e8 2a ff ff ff       	call   8023ee <fsipc>
  8024c4:	89 c2                	mov    %eax,%edx
  8024c6:	85 d2                	test   %edx,%edx
  8024c8:	78 2b                	js     8024f5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024ca:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8024d1:	00 
  8024d2:	89 1c 24             	mov    %ebx,(%esp)
  8024d5:	e8 ad ed ff ff       	call   801287 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024da:	a1 80 70 80 00       	mov    0x807080,%eax
  8024df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8024e5:	a1 84 70 80 00       	mov    0x807084,%eax
  8024ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8024f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f5:	83 c4 14             	add    $0x14,%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    

008024fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802501:	c7 44 24 08 2c 3e 80 	movl   $0x803e2c,0x8(%esp)
  802508:	00 
  802509:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  802510:	00 
  802511:	c7 04 24 4a 3e 80 00 	movl   $0x803e4a,(%esp)
  802518:	e8 05 e5 ff ff       	call   800a22 <_panic>

0080251d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	56                   	push   %esi
  802521:	53                   	push   %ebx
  802522:	83 ec 10             	sub    $0x10,%esp
  802525:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802528:	8b 45 08             	mov    0x8(%ebp),%eax
  80252b:	8b 40 0c             	mov    0xc(%eax),%eax
  80252e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  802533:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802539:	ba 00 00 00 00       	mov    $0x0,%edx
  80253e:	b8 03 00 00 00       	mov    $0x3,%eax
  802543:	e8 a6 fe ff ff       	call   8023ee <fsipc>
  802548:	89 c3                	mov    %eax,%ebx
  80254a:	85 c0                	test   %eax,%eax
  80254c:	78 6a                	js     8025b8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80254e:	39 c6                	cmp    %eax,%esi
  802550:	73 24                	jae    802576 <devfile_read+0x59>
  802552:	c7 44 24 0c 55 3e 80 	movl   $0x803e55,0xc(%esp)
  802559:	00 
  80255a:	c7 44 24 08 bb 37 80 	movl   $0x8037bb,0x8(%esp)
  802561:	00 
  802562:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802569:	00 
  80256a:	c7 04 24 4a 3e 80 00 	movl   $0x803e4a,(%esp)
  802571:	e8 ac e4 ff ff       	call   800a22 <_panic>
	assert(r <= PGSIZE);
  802576:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80257b:	7e 24                	jle    8025a1 <devfile_read+0x84>
  80257d:	c7 44 24 0c 5c 3e 80 	movl   $0x803e5c,0xc(%esp)
  802584:	00 
  802585:	c7 44 24 08 bb 37 80 	movl   $0x8037bb,0x8(%esp)
  80258c:	00 
  80258d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802594:	00 
  802595:	c7 04 24 4a 3e 80 00 	movl   $0x803e4a,(%esp)
  80259c:	e8 81 e4 ff ff       	call   800a22 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8025a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025a5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8025ac:	00 
  8025ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025b0:	89 04 24             	mov    %eax,(%esp)
  8025b3:	e8 6c ee ff ff       	call   801424 <memmove>
	return r;
}
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	53                   	push   %ebx
  8025c5:	83 ec 24             	sub    $0x24,%esp
  8025c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8025cb:	89 1c 24             	mov    %ebx,(%esp)
  8025ce:	e8 7d ec ff ff       	call   801250 <strlen>
  8025d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025d8:	7f 60                	jg     80263a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8025da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025dd:	89 04 24             	mov    %eax,(%esp)
  8025e0:	e8 52 f8 ff ff       	call   801e37 <fd_alloc>
  8025e5:	89 c2                	mov    %eax,%edx
  8025e7:	85 d2                	test   %edx,%edx
  8025e9:	78 54                	js     80263f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8025eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025ef:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8025f6:	e8 8c ec ff ff       	call   801287 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fe:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802603:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	e8 de fd ff ff       	call   8023ee <fsipc>
  802610:	89 c3                	mov    %eax,%ebx
  802612:	85 c0                	test   %eax,%eax
  802614:	79 17                	jns    80262d <open+0x6c>
		fd_close(fd, 0);
  802616:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80261d:	00 
  80261e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802621:	89 04 24             	mov    %eax,(%esp)
  802624:	e8 08 f9 ff ff       	call   801f31 <fd_close>
		return r;
  802629:	89 d8                	mov    %ebx,%eax
  80262b:	eb 12                	jmp    80263f <open+0x7e>
	}

	return fd2num(fd);
  80262d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802630:	89 04 24             	mov    %eax,(%esp)
  802633:	e8 d8 f7 ff ff       	call   801e10 <fd2num>
  802638:	eb 05                	jmp    80263f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80263a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80263f:	83 c4 24             	add    $0x24,%esp
  802642:	5b                   	pop    %ebx
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    

00802645 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802645:	55                   	push   %ebp
  802646:	89 e5                	mov    %esp,%ebp
  802648:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80264b:	ba 00 00 00 00       	mov    $0x0,%edx
  802650:	b8 08 00 00 00       	mov    $0x8,%eax
  802655:	e8 94 fd ff ff       	call   8023ee <fsipc>
}
  80265a:	c9                   	leave  
  80265b:	c3                   	ret    

0080265c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	53                   	push   %ebx
  802660:	83 ec 14             	sub    $0x14,%esp
  802663:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  802665:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802669:	7e 31                	jle    80269c <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80266b:	8b 40 04             	mov    0x4(%eax),%eax
  80266e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802672:	8d 43 10             	lea    0x10(%ebx),%eax
  802675:	89 44 24 04          	mov    %eax,0x4(%esp)
  802679:	8b 03                	mov    (%ebx),%eax
  80267b:	89 04 24             	mov    %eax,(%esp)
  80267e:	e8 6f fb ff ff       	call   8021f2 <write>
		if (result > 0)
  802683:	85 c0                	test   %eax,%eax
  802685:	7e 03                	jle    80268a <writebuf+0x2e>
			b->result += result;
  802687:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80268a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80268d:	74 0d                	je     80269c <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  80268f:	85 c0                	test   %eax,%eax
  802691:	ba 00 00 00 00       	mov    $0x0,%edx
  802696:	0f 4f c2             	cmovg  %edx,%eax
  802699:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80269c:	83 c4 14             	add    $0x14,%esp
  80269f:	5b                   	pop    %ebx
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    

008026a2 <putch>:

static void
putch(int ch, void *thunk)
{
  8026a2:	55                   	push   %ebp
  8026a3:	89 e5                	mov    %esp,%ebp
  8026a5:	53                   	push   %ebx
  8026a6:	83 ec 04             	sub    $0x4,%esp
  8026a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8026ac:	8b 53 04             	mov    0x4(%ebx),%edx
  8026af:	8d 42 01             	lea    0x1(%edx),%eax
  8026b2:	89 43 04             	mov    %eax,0x4(%ebx)
  8026b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026b8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8026bc:	3d 00 01 00 00       	cmp    $0x100,%eax
  8026c1:	75 0e                	jne    8026d1 <putch+0x2f>
		writebuf(b);
  8026c3:	89 d8                	mov    %ebx,%eax
  8026c5:	e8 92 ff ff ff       	call   80265c <writebuf>
		b->idx = 0;
  8026ca:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8026d1:	83 c4 04             	add    $0x4,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5d                   	pop    %ebp
  8026d6:	c3                   	ret    

008026d7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026d7:	55                   	push   %ebp
  8026d8:	89 e5                	mov    %esp,%ebp
  8026da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8026e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8026e9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8026f0:	00 00 00 
	b.result = 0;
  8026f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8026fa:	00 00 00 
	b.error = 1;
  8026fd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802704:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802707:	8b 45 10             	mov    0x10(%ebp),%eax
  80270a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80270e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802711:	89 44 24 08          	mov    %eax,0x8(%esp)
  802715:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80271b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80271f:	c7 04 24 a2 26 80 00 	movl   $0x8026a2,(%esp)
  802726:	e8 49 e5 ff ff       	call   800c74 <vprintfmt>
	if (b.idx > 0)
  80272b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802732:	7e 0b                	jle    80273f <vfprintf+0x68>
		writebuf(&b);
  802734:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80273a:	e8 1d ff ff ff       	call   80265c <writebuf>

	return (b.result ? b.result : b.error);
  80273f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802745:	85 c0                	test   %eax,%eax
  802747:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80274e:	c9                   	leave  
  80274f:	c3                   	ret    

00802750 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
  802753:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802756:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80275d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802760:	89 44 24 04          	mov    %eax,0x4(%esp)
  802764:	8b 45 08             	mov    0x8(%ebp),%eax
  802767:	89 04 24             	mov    %eax,(%esp)
  80276a:	e8 68 ff ff ff       	call   8026d7 <vfprintf>
	va_end(ap);

	return cnt;
}
  80276f:	c9                   	leave  
  802770:	c3                   	ret    

00802771 <printf>:

int
printf(const char *fmt, ...)
{
  802771:	55                   	push   %ebp
  802772:	89 e5                	mov    %esp,%ebp
  802774:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802777:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80277a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80277e:	8b 45 08             	mov    0x8(%ebp),%eax
  802781:	89 44 24 04          	mov    %eax,0x4(%esp)
  802785:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80278c:	e8 46 ff ff ff       	call   8026d7 <vfprintf>
	va_end(ap);

	return cnt;
}
  802791:	c9                   	leave  
  802792:	c3                   	ret    
  802793:	66 90                	xchg   %ax,%ax
  802795:	66 90                	xchg   %ax,%ax
  802797:	66 90                	xchg   %ax,%ax
  802799:	66 90                	xchg   %ax,%ax
  80279b:	66 90                	xchg   %ax,%ax
  80279d:	66 90                	xchg   %ax,%ax
  80279f:	90                   	nop

008027a0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8027a0:	55                   	push   %ebp
  8027a1:	89 e5                	mov    %esp,%ebp
  8027a3:	57                   	push   %edi
  8027a4:	56                   	push   %esi
  8027a5:	53                   	push   %ebx
  8027a6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8027ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8027b3:	00 
  8027b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b7:	89 04 24             	mov    %eax,(%esp)
  8027ba:	e8 02 fe ff ff       	call   8025c1 <open>
  8027bf:	89 c1                	mov    %eax,%ecx
  8027c1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8027c7:	85 c0                	test   %eax,%eax
  8027c9:	0f 88 9e 04 00 00    	js     802c6d <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8027cf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8027d6:	00 
  8027d7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8027dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e1:	89 0c 24             	mov    %ecx,(%esp)
  8027e4:	e8 be f9 ff ff       	call   8021a7 <readn>
  8027e9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8027ee:	75 0c                	jne    8027fc <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  8027f0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8027f7:	45 4c 46 
  8027fa:	74 36                	je     802832 <spawn+0x92>
		close(fd);
  8027fc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802802:	89 04 24             	mov    %eax,(%esp)
  802805:	e8 a8 f7 ff ff       	call   801fb2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80280a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802811:	46 
  802812:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281c:	c7 04 24 68 3e 80 00 	movl   $0x803e68,(%esp)
  802823:	e8 f3 e2 ff ff       	call   800b1b <cprintf>
		return -E_NOT_EXEC;
  802828:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80282d:	e9 9a 04 00 00       	jmp    802ccc <spawn+0x52c>
  802832:	b8 07 00 00 00       	mov    $0x7,%eax
  802837:	cd 30                	int    $0x30
  802839:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80283f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802845:	85 c0                	test   %eax,%eax
  802847:	0f 88 28 04 00 00    	js     802c75 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80284d:	89 c6                	mov    %eax,%esi
  80284f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802855:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802858:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80285e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802864:	b9 11 00 00 00       	mov    $0x11,%ecx
  802869:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80286b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802871:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802877:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80287c:	be 00 00 00 00       	mov    $0x0,%esi
  802881:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802884:	eb 0f                	jmp    802895 <spawn+0xf5>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802886:	89 04 24             	mov    %eax,(%esp)
  802889:	e8 c2 e9 ff ff       	call   801250 <strlen>
  80288e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802892:	83 c3 01             	add    $0x1,%ebx
  802895:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80289c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80289f:	85 c0                	test   %eax,%eax
  8028a1:	75 e3                	jne    802886 <spawn+0xe6>
  8028a3:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8028a9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8028af:	bf 00 10 40 00       	mov    $0x401000,%edi
  8028b4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8028b6:	89 fa                	mov    %edi,%edx
  8028b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8028bb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8028c2:	29 c2                	sub    %eax,%edx
  8028c4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8028ca:	8d 42 f8             	lea    -0x8(%edx),%eax
  8028cd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8028d2:	0f 86 ad 03 00 00    	jbe    802c85 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8028d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028df:	00 
  8028e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028e7:	00 
  8028e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028ef:	e8 af ed ff ff       	call   8016a3 <sys_page_alloc>
  8028f4:	85 c0                	test   %eax,%eax
  8028f6:	0f 88 d0 03 00 00    	js     802ccc <spawn+0x52c>
  8028fc:	be 00 00 00 00       	mov    $0x0,%esi
  802901:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802907:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80290a:	eb 30                	jmp    80293c <spawn+0x19c>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80290c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802912:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802918:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80291b:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80291e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802922:	89 3c 24             	mov    %edi,(%esp)
  802925:	e8 5d e9 ff ff       	call   801287 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80292a:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
  80292d:	89 04 24             	mov    %eax,(%esp)
  802930:	e8 1b e9 ff ff       	call   801250 <strlen>
  802935:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802939:	83 c6 01             	add    $0x1,%esi
  80293c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802942:	7f c8                	jg     80290c <spawn+0x16c>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802944:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80294a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802950:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802957:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80295d:	74 24                	je     802983 <spawn+0x1e3>
  80295f:	c7 44 24 0c dc 3e 80 	movl   $0x803edc,0xc(%esp)
  802966:	00 
  802967:	c7 44 24 08 bb 37 80 	movl   $0x8037bb,0x8(%esp)
  80296e:	00 
  80296f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802976:	00 
  802977:	c7 04 24 82 3e 80 00 	movl   $0x803e82,(%esp)
  80297e:	e8 9f e0 ff ff       	call   800a22 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802983:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802989:	89 c8                	mov    %ecx,%eax
  80298b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802990:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  802993:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802999:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80299c:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8029a2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8029a8:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8029af:	00 
  8029b0:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8029b7:	ee 
  8029b8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029c2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029c9:	00 
  8029ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029d1:	e8 21 ed ff ff       	call   8016f7 <sys_page_map>
  8029d6:	89 c3                	mov    %eax,%ebx
  8029d8:	85 c0                	test   %eax,%eax
  8029da:	0f 88 d6 02 00 00    	js     802cb6 <spawn+0x516>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8029e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029e7:	00 
  8029e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029ef:	e8 56 ed ff ff       	call   80174a <sys_page_unmap>
  8029f4:	89 c3                	mov    %eax,%ebx
  8029f6:	85 c0                	test   %eax,%eax
  8029f8:	0f 88 b8 02 00 00    	js     802cb6 <spawn+0x516>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8029fe:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802a04:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802a0b:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802a11:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802a18:	00 00 00 
  802a1b:	e9 b6 01 00 00       	jmp    802bd6 <spawn+0x436>
		if (ph->p_type != ELF_PROG_LOAD)
  802a20:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802a26:	83 38 01             	cmpl   $0x1,(%eax)
  802a29:	0f 85 99 01 00 00    	jne    802bc8 <spawn+0x428>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802a2f:	89 c1                	mov    %eax,%ecx
  802a31:	8b 40 18             	mov    0x18(%eax),%eax
  802a34:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802a37:	83 f8 01             	cmp    $0x1,%eax
  802a3a:	19 c0                	sbb    %eax,%eax
  802a3c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802a42:	83 a5 90 fd ff ff fe 	andl   $0xfffffffe,-0x270(%ebp)
  802a49:	83 85 90 fd ff ff 07 	addl   $0x7,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a50:	89 c8                	mov    %ecx,%eax
  802a52:	8b 51 04             	mov    0x4(%ecx),%edx
  802a55:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  802a5b:	8b 49 10             	mov    0x10(%ecx),%ecx
  802a5e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  802a64:	8b 50 14             	mov    0x14(%eax),%edx
  802a67:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802a6d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802a70:	89 f0                	mov    %esi,%eax
  802a72:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a77:	74 14                	je     802a8d <spawn+0x2ed>
		va -= i;
  802a79:	29 c6                	sub    %eax,%esi
		memsz += i;
  802a7b:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  802a81:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802a87:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a92:	e9 23 01 00 00       	jmp    802bba <spawn+0x41a>
		if (i >= filesz) {
  802a97:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802a9d:	77 2b                	ja     802aca <spawn+0x32a>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802a9f:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  802aa9:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aad:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ab3:	89 04 24             	mov    %eax,(%esp)
  802ab6:	e8 e8 eb ff ff       	call   8016a3 <sys_page_alloc>
  802abb:	85 c0                	test   %eax,%eax
  802abd:	0f 89 eb 00 00 00    	jns    802bae <spawn+0x40e>
  802ac3:	89 c3                	mov    %eax,%ebx
  802ac5:	e9 cc 01 00 00       	jmp    802c96 <spawn+0x4f6>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802aca:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802ad1:	00 
  802ad2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ad9:	00 
  802ada:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ae1:	e8 bd eb ff ff       	call   8016a3 <sys_page_alloc>
  802ae6:	85 c0                	test   %eax,%eax
  802ae8:	0f 88 9e 01 00 00    	js     802c8c <spawn+0x4ec>
  802aee:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802af4:	01 f8                	add    %edi,%eax
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802af6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802afa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b00:	89 04 24             	mov    %eax,(%esp)
  802b03:	e8 77 f7 ff ff       	call   80227f <seek>
  802b08:	85 c0                	test   %eax,%eax
  802b0a:	0f 88 80 01 00 00    	js     802c90 <spawn+0x4f0>
  802b10:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802b16:	29 fa                	sub    %edi,%edx
  802b18:	89 d0                	mov    %edx,%eax
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b1a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802b20:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802b25:	0f 47 c1             	cmova  %ecx,%eax
  802b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b2c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b33:	00 
  802b34:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b3a:	89 04 24             	mov    %eax,(%esp)
  802b3d:	e8 65 f6 ff ff       	call   8021a7 <readn>
  802b42:	85 c0                	test   %eax,%eax
  802b44:	0f 88 4a 01 00 00    	js     802c94 <spawn+0x4f4>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b4a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802b50:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b54:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802b58:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b62:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b69:	00 
  802b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b71:	e8 81 eb ff ff       	call   8016f7 <sys_page_map>
  802b76:	85 c0                	test   %eax,%eax
  802b78:	79 20                	jns    802b9a <spawn+0x3fa>
				panic("spawn: sys_page_map data: %e", r);
  802b7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b7e:	c7 44 24 08 8e 3e 80 	movl   $0x803e8e,0x8(%esp)
  802b85:	00 
  802b86:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  802b8d:	00 
  802b8e:	c7 04 24 82 3e 80 00 	movl   $0x803e82,(%esp)
  802b95:	e8 88 de ff ff       	call   800a22 <_panic>
			sys_page_unmap(0, UTEMP);
  802b9a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ba1:	00 
  802ba2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ba9:	e8 9c eb ff ff       	call   80174a <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802bae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802bb4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802bba:	89 df                	mov    %ebx,%edi
  802bbc:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802bc2:	0f 87 cf fe ff ff    	ja     802a97 <spawn+0x2f7>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802bc8:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802bcf:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802bd6:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802bdd:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802be3:	0f 8c 37 fe ff ff    	jl     802a20 <spawn+0x280>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802be9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802bef:	89 04 24             	mov    %eax,(%esp)
  802bf2:	e8 bb f3 ff ff       	call   801fb2 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802bf7:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c01:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c07:	89 04 24             	mov    %eax,(%esp)
  802c0a:	e8 e1 eb ff ff       	call   8017f0 <sys_env_set_trapframe>
  802c0f:	85 c0                	test   %eax,%eax
  802c11:	79 20                	jns    802c33 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  802c13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c17:	c7 44 24 08 ab 3e 80 	movl   $0x803eab,0x8(%esp)
  802c1e:	00 
  802c1f:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  802c26:	00 
  802c27:	c7 04 24 82 3e 80 00 	movl   $0x803e82,(%esp)
  802c2e:	e8 ef dd ff ff       	call   800a22 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802c33:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802c3a:	00 
  802c3b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c41:	89 04 24             	mov    %eax,(%esp)
  802c44:	e8 54 eb ff ff       	call   80179d <sys_env_set_status>
  802c49:	85 c0                	test   %eax,%eax
  802c4b:	79 30                	jns    802c7d <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  802c4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c51:	c7 44 24 08 c5 3e 80 	movl   $0x803ec5,0x8(%esp)
  802c58:	00 
  802c59:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802c60:	00 
  802c61:	c7 04 24 82 3e 80 00 	movl   $0x803e82,(%esp)
  802c68:	e8 b5 dd ff ff       	call   800a22 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802c6d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c73:	eb 57                	jmp    802ccc <spawn+0x52c>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802c75:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c7b:	eb 4f                	jmp    802ccc <spawn+0x52c>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802c7d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c83:	eb 47                	jmp    802ccc <spawn+0x52c>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802c85:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802c8a:	eb 40                	jmp    802ccc <spawn+0x52c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802c8c:	89 c3                	mov    %eax,%ebx
  802c8e:	eb 06                	jmp    802c96 <spawn+0x4f6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802c90:	89 c3                	mov    %eax,%ebx
  802c92:	eb 02                	jmp    802c96 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802c94:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802c96:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c9c:	89 04 24             	mov    %eax,(%esp)
  802c9f:	e8 6f e9 ff ff       	call   801613 <sys_env_destroy>
	close(fd);
  802ca4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802caa:	89 04 24             	mov    %eax,(%esp)
  802cad:	e8 00 f3 ff ff       	call   801fb2 <close>
	return r;
  802cb2:	89 d8                	mov    %ebx,%eax
  802cb4:	eb 16                	jmp    802ccc <spawn+0x52c>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802cb6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802cbd:	00 
  802cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cc5:	e8 80 ea ff ff       	call   80174a <sys_page_unmap>
  802cca:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802ccc:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  802cd2:	5b                   	pop    %ebx
  802cd3:	5e                   	pop    %esi
  802cd4:	5f                   	pop    %edi
  802cd5:	5d                   	pop    %ebp
  802cd6:	c3                   	ret    

00802cd7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802cd7:	55                   	push   %ebp
  802cd8:	89 e5                	mov    %esp,%ebp
  802cda:	56                   	push   %esi
  802cdb:	53                   	push   %ebx
  802cdc:	83 ec 10             	sub    $0x10,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802cdf:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802ce2:	ba 00 00 00 00       	mov    $0x0,%edx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ce7:	eb 03                	jmp    802cec <spawnl+0x15>
		argc++;
  802ce9:	83 c2 01             	add    $0x1,%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802cec:	83 c0 04             	add    $0x4,%eax
  802cef:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802cf3:	75 f4                	jne    802ce9 <spawnl+0x12>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802cf5:	8d 04 95 1a 00 00 00 	lea    0x1a(,%edx,4),%eax
  802cfc:	83 e0 f0             	and    $0xfffffff0,%eax
  802cff:	29 c4                	sub    %eax,%esp
  802d01:	8d 44 24 0b          	lea    0xb(%esp),%eax
  802d05:	c1 e8 02             	shr    $0x2,%eax
  802d08:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802d0f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d14:	89 0c 85 00 00 00 00 	mov    %ecx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802d1b:	c7 44 96 04 00 00 00 	movl   $0x0,0x4(%esi,%edx,4)
  802d22:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d23:	b8 00 00 00 00       	mov    $0x0,%eax
  802d28:	eb 0a                	jmp    802d34 <spawnl+0x5d>
		argv[i+1] = va_arg(vl, const char *);
  802d2a:	83 c0 01             	add    $0x1,%eax
  802d2d:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802d31:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802d34:	39 d0                	cmp    %edx,%eax
  802d36:	75 f2                	jne    802d2a <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802d38:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d3f:	89 04 24             	mov    %eax,(%esp)
  802d42:	e8 59 fa ff ff       	call   8027a0 <spawn>
}
  802d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d4a:	5b                   	pop    %ebx
  802d4b:	5e                   	pop    %esi
  802d4c:	5d                   	pop    %ebp
  802d4d:	c3                   	ret    

00802d4e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802d4e:	55                   	push   %ebp
  802d4f:	89 e5                	mov    %esp,%ebp
  802d51:	56                   	push   %esi
  802d52:	53                   	push   %ebx
  802d53:	83 ec 10             	sub    $0x10,%esp
  802d56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802d59:	8b 45 08             	mov    0x8(%ebp),%eax
  802d5c:	89 04 24             	mov    %eax,(%esp)
  802d5f:	e8 bc f0 ff ff       	call   801e20 <fd2data>
  802d64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802d66:	c7 44 24 04 02 3f 80 	movl   $0x803f02,0x4(%esp)
  802d6d:	00 
  802d6e:	89 1c 24             	mov    %ebx,(%esp)
  802d71:	e8 11 e5 ff ff       	call   801287 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802d76:	8b 46 04             	mov    0x4(%esi),%eax
  802d79:	2b 06                	sub    (%esi),%eax
  802d7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802d81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d88:	00 00 00 
	stat->st_dev = &devpipe;
  802d8b:	c7 83 88 00 00 00 3c 	movl   $0x80503c,0x88(%ebx)
  802d92:	50 80 00 
	return 0;
}
  802d95:	b8 00 00 00 00       	mov    $0x0,%eax
  802d9a:	83 c4 10             	add    $0x10,%esp
  802d9d:	5b                   	pop    %ebx
  802d9e:	5e                   	pop    %esi
  802d9f:	5d                   	pop    %ebp
  802da0:	c3                   	ret    

00802da1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802da1:	55                   	push   %ebp
  802da2:	89 e5                	mov    %esp,%ebp
  802da4:	53                   	push   %ebx
  802da5:	83 ec 14             	sub    $0x14,%esp
  802da8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802dab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802db6:	e8 8f e9 ff ff       	call   80174a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802dbb:	89 1c 24             	mov    %ebx,(%esp)
  802dbe:	e8 5d f0 ff ff       	call   801e20 <fd2data>
  802dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dce:	e8 77 e9 ff ff       	call   80174a <sys_page_unmap>
}
  802dd3:	83 c4 14             	add    $0x14,%esp
  802dd6:	5b                   	pop    %ebx
  802dd7:	5d                   	pop    %ebp
  802dd8:	c3                   	ret    

00802dd9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802dd9:	55                   	push   %ebp
  802dda:	89 e5                	mov    %esp,%ebp
  802ddc:	57                   	push   %edi
  802ddd:	56                   	push   %esi
  802dde:	53                   	push   %ebx
  802ddf:	83 ec 2c             	sub    $0x2c,%esp
  802de2:	89 c6                	mov    %eax,%esi
  802de4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802de7:	a1 24 64 80 00       	mov    0x806424,%eax
  802dec:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802def:	89 34 24             	mov    %esi,(%esp)
  802df2:	e8 9e 05 00 00       	call   803395 <pageref>
  802df7:	89 c7                	mov    %eax,%edi
  802df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802dfc:	89 04 24             	mov    %eax,(%esp)
  802dff:	e8 91 05 00 00       	call   803395 <pageref>
  802e04:	39 c7                	cmp    %eax,%edi
  802e06:	0f 94 c2             	sete   %dl
  802e09:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802e0c:	8b 0d 24 64 80 00    	mov    0x806424,%ecx
  802e12:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802e15:	39 fb                	cmp    %edi,%ebx
  802e17:	74 21                	je     802e3a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802e19:	84 d2                	test   %dl,%dl
  802e1b:	74 ca                	je     802de7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e1d:	8b 51 58             	mov    0x58(%ecx),%edx
  802e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e24:	89 54 24 08          	mov    %edx,0x8(%esp)
  802e28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e2c:	c7 04 24 09 3f 80 00 	movl   $0x803f09,(%esp)
  802e33:	e8 e3 dc ff ff       	call   800b1b <cprintf>
  802e38:	eb ad                	jmp    802de7 <_pipeisclosed+0xe>
	}
}
  802e3a:	83 c4 2c             	add    $0x2c,%esp
  802e3d:	5b                   	pop    %ebx
  802e3e:	5e                   	pop    %esi
  802e3f:	5f                   	pop    %edi
  802e40:	5d                   	pop    %ebp
  802e41:	c3                   	ret    

00802e42 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802e42:	55                   	push   %ebp
  802e43:	89 e5                	mov    %esp,%ebp
  802e45:	57                   	push   %edi
  802e46:	56                   	push   %esi
  802e47:	53                   	push   %ebx
  802e48:	83 ec 1c             	sub    $0x1c,%esp
  802e4b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802e4e:	89 34 24             	mov    %esi,(%esp)
  802e51:	e8 ca ef ff ff       	call   801e20 <fd2data>
  802e56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e58:	bf 00 00 00 00       	mov    $0x0,%edi
  802e5d:	eb 45                	jmp    802ea4 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802e5f:	89 da                	mov    %ebx,%edx
  802e61:	89 f0                	mov    %esi,%eax
  802e63:	e8 71 ff ff ff       	call   802dd9 <_pipeisclosed>
  802e68:	85 c0                	test   %eax,%eax
  802e6a:	75 41                	jne    802ead <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802e6c:	e8 13 e8 ff ff       	call   801684 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802e71:	8b 43 04             	mov    0x4(%ebx),%eax
  802e74:	8b 0b                	mov    (%ebx),%ecx
  802e76:	8d 51 20             	lea    0x20(%ecx),%edx
  802e79:	39 d0                	cmp    %edx,%eax
  802e7b:	73 e2                	jae    802e5f <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e80:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802e84:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802e87:	99                   	cltd   
  802e88:	c1 ea 1b             	shr    $0x1b,%edx
  802e8b:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802e8e:	83 e1 1f             	and    $0x1f,%ecx
  802e91:	29 d1                	sub    %edx,%ecx
  802e93:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802e97:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802e9b:	83 c0 01             	add    $0x1,%eax
  802e9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ea1:	83 c7 01             	add    $0x1,%edi
  802ea4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ea7:	75 c8                	jne    802e71 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ea9:	89 f8                	mov    %edi,%eax
  802eab:	eb 05                	jmp    802eb2 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802ead:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802eb2:	83 c4 1c             	add    $0x1c,%esp
  802eb5:	5b                   	pop    %ebx
  802eb6:	5e                   	pop    %esi
  802eb7:	5f                   	pop    %edi
  802eb8:	5d                   	pop    %ebp
  802eb9:	c3                   	ret    

00802eba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802eba:	55                   	push   %ebp
  802ebb:	89 e5                	mov    %esp,%ebp
  802ebd:	57                   	push   %edi
  802ebe:	56                   	push   %esi
  802ebf:	53                   	push   %ebx
  802ec0:	83 ec 1c             	sub    $0x1c,%esp
  802ec3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802ec6:	89 3c 24             	mov    %edi,(%esp)
  802ec9:	e8 52 ef ff ff       	call   801e20 <fd2data>
  802ece:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ed0:	be 00 00 00 00       	mov    $0x0,%esi
  802ed5:	eb 3d                	jmp    802f14 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802ed7:	85 f6                	test   %esi,%esi
  802ed9:	74 04                	je     802edf <devpipe_read+0x25>
				return i;
  802edb:	89 f0                	mov    %esi,%eax
  802edd:	eb 43                	jmp    802f22 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802edf:	89 da                	mov    %ebx,%edx
  802ee1:	89 f8                	mov    %edi,%eax
  802ee3:	e8 f1 fe ff ff       	call   802dd9 <_pipeisclosed>
  802ee8:	85 c0                	test   %eax,%eax
  802eea:	75 31                	jne    802f1d <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802eec:	e8 93 e7 ff ff       	call   801684 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802ef1:	8b 03                	mov    (%ebx),%eax
  802ef3:	3b 43 04             	cmp    0x4(%ebx),%eax
  802ef6:	74 df                	je     802ed7 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802ef8:	99                   	cltd   
  802ef9:	c1 ea 1b             	shr    $0x1b,%edx
  802efc:	01 d0                	add    %edx,%eax
  802efe:	83 e0 1f             	and    $0x1f,%eax
  802f01:	29 d0                	sub    %edx,%eax
  802f03:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f0b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802f0e:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f11:	83 c6 01             	add    $0x1,%esi
  802f14:	3b 75 10             	cmp    0x10(%ebp),%esi
  802f17:	75 d8                	jne    802ef1 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f19:	89 f0                	mov    %esi,%eax
  802f1b:	eb 05                	jmp    802f22 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f1d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f22:	83 c4 1c             	add    $0x1c,%esp
  802f25:	5b                   	pop    %ebx
  802f26:	5e                   	pop    %esi
  802f27:	5f                   	pop    %edi
  802f28:	5d                   	pop    %ebp
  802f29:	c3                   	ret    

00802f2a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802f2a:	55                   	push   %ebp
  802f2b:	89 e5                	mov    %esp,%ebp
  802f2d:	56                   	push   %esi
  802f2e:	53                   	push   %ebx
  802f2f:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f35:	89 04 24             	mov    %eax,(%esp)
  802f38:	e8 fa ee ff ff       	call   801e37 <fd_alloc>
  802f3d:	89 c2                	mov    %eax,%edx
  802f3f:	85 d2                	test   %edx,%edx
  802f41:	0f 88 4d 01 00 00    	js     803094 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f47:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f4e:	00 
  802f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f5d:	e8 41 e7 ff ff       	call   8016a3 <sys_page_alloc>
  802f62:	89 c2                	mov    %eax,%edx
  802f64:	85 d2                	test   %edx,%edx
  802f66:	0f 88 28 01 00 00    	js     803094 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f6f:	89 04 24             	mov    %eax,(%esp)
  802f72:	e8 c0 ee ff ff       	call   801e37 <fd_alloc>
  802f77:	89 c3                	mov    %eax,%ebx
  802f79:	85 c0                	test   %eax,%eax
  802f7b:	0f 88 fe 00 00 00    	js     80307f <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f81:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f88:	00 
  802f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f97:	e8 07 e7 ff ff       	call   8016a3 <sys_page_alloc>
  802f9c:	89 c3                	mov    %eax,%ebx
  802f9e:	85 c0                	test   %eax,%eax
  802fa0:	0f 88 d9 00 00 00    	js     80307f <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fa9:	89 04 24             	mov    %eax,(%esp)
  802fac:	e8 6f ee ff ff       	call   801e20 <fd2data>
  802fb1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fb3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802fba:	00 
  802fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fc6:	e8 d8 e6 ff ff       	call   8016a3 <sys_page_alloc>
  802fcb:	89 c3                	mov    %eax,%ebx
  802fcd:	85 c0                	test   %eax,%eax
  802fcf:	0f 88 97 00 00 00    	js     80306c <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fd8:	89 04 24             	mov    %eax,(%esp)
  802fdb:	e8 40 ee ff ff       	call   801e20 <fd2data>
  802fe0:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802fe7:	00 
  802fe8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802ff3:	00 
  802ff4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ff8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fff:	e8 f3 e6 ff ff       	call   8016f7 <sys_page_map>
  803004:	89 c3                	mov    %eax,%ebx
  803006:	85 c0                	test   %eax,%eax
  803008:	78 52                	js     80305c <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80300a:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  803010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803013:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803018:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80301f:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  803025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803028:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80302a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80302d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803037:	89 04 24             	mov    %eax,(%esp)
  80303a:	e8 d1 ed ff ff       	call   801e10 <fd2num>
  80303f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803042:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803044:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803047:	89 04 24             	mov    %eax,(%esp)
  80304a:	e8 c1 ed ff ff       	call   801e10 <fd2num>
  80304f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803052:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803055:	b8 00 00 00 00       	mov    $0x0,%eax
  80305a:	eb 38                	jmp    803094 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80305c:	89 74 24 04          	mov    %esi,0x4(%esp)
  803060:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803067:	e8 de e6 ff ff       	call   80174a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80306c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80306f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80307a:	e8 cb e6 ff ff       	call   80174a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80307f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803082:	89 44 24 04          	mov    %eax,0x4(%esp)
  803086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80308d:	e8 b8 e6 ff ff       	call   80174a <sys_page_unmap>
  803092:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  803094:	83 c4 30             	add    $0x30,%esp
  803097:	5b                   	pop    %ebx
  803098:	5e                   	pop    %esi
  803099:	5d                   	pop    %ebp
  80309a:	c3                   	ret    

0080309b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80309b:	55                   	push   %ebp
  80309c:	89 e5                	mov    %esp,%ebp
  80309e:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ab:	89 04 24             	mov    %eax,(%esp)
  8030ae:	e8 d3 ed ff ff       	call   801e86 <fd_lookup>
  8030b3:	89 c2                	mov    %eax,%edx
  8030b5:	85 d2                	test   %edx,%edx
  8030b7:	78 15                	js     8030ce <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8030b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030bc:	89 04 24             	mov    %eax,(%esp)
  8030bf:	e8 5c ed ff ff       	call   801e20 <fd2data>
	return _pipeisclosed(fd, p);
  8030c4:	89 c2                	mov    %eax,%edx
  8030c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030c9:	e8 0b fd ff ff       	call   802dd9 <_pipeisclosed>
}
  8030ce:	c9                   	leave  
  8030cf:	c3                   	ret    

008030d0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
  8030d3:	56                   	push   %esi
  8030d4:	53                   	push   %ebx
  8030d5:	83 ec 10             	sub    $0x10,%esp
  8030d8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8030db:	85 f6                	test   %esi,%esi
  8030dd:	75 24                	jne    803103 <wait+0x33>
  8030df:	c7 44 24 0c 21 3f 80 	movl   $0x803f21,0xc(%esp)
  8030e6:	00 
  8030e7:	c7 44 24 08 bb 37 80 	movl   $0x8037bb,0x8(%esp)
  8030ee:	00 
  8030ef:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8030f6:	00 
  8030f7:	c7 04 24 2c 3f 80 00 	movl   $0x803f2c,(%esp)
  8030fe:	e8 1f d9 ff ff       	call   800a22 <_panic>
	e = &envs[ENVX(envid)];
  803103:	89 f3                	mov    %esi,%ebx
  803105:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80310b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80310e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803114:	eb 05                	jmp    80311b <wait+0x4b>
		sys_yield();
  803116:	e8 69 e5 ff ff       	call   801684 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80311b:	8b 43 48             	mov    0x48(%ebx),%eax
  80311e:	39 f0                	cmp    %esi,%eax
  803120:	75 07                	jne    803129 <wait+0x59>
  803122:	8b 43 54             	mov    0x54(%ebx),%eax
  803125:	85 c0                	test   %eax,%eax
  803127:	75 ed                	jne    803116 <wait+0x46>
		sys_yield();
}
  803129:	83 c4 10             	add    $0x10,%esp
  80312c:	5b                   	pop    %ebx
  80312d:	5e                   	pop    %esi
  80312e:	5d                   	pop    %ebp
  80312f:	c3                   	ret    

00803130 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803130:	55                   	push   %ebp
  803131:	89 e5                	mov    %esp,%ebp
  803133:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  803136:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  80313d:	75 44                	jne    803183 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80313f:	a1 24 64 80 00       	mov    0x806424,%eax
  803144:	8b 40 48             	mov    0x48(%eax),%eax
  803147:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80314e:	00 
  80314f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  803156:	ee 
  803157:	89 04 24             	mov    %eax,(%esp)
  80315a:	e8 44 e5 ff ff       	call   8016a3 <sys_page_alloc>
		if( r < 0)
  80315f:	85 c0                	test   %eax,%eax
  803161:	79 20                	jns    803183 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  803163:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803167:	c7 44 24 08 38 3f 80 	movl   $0x803f38,0x8(%esp)
  80316e:	00 
  80316f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  803176:	00 
  803177:	c7 04 24 94 3f 80 00 	movl   $0x803f94,(%esp)
  80317e:	e8 9f d8 ff ff       	call   800a22 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803183:	8b 45 08             	mov    0x8(%ebp),%eax
  803186:	a3 00 80 80 00       	mov    %eax,0x808000
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  80318b:	e8 d5 e4 ff ff       	call   801665 <sys_getenvid>
  803190:	c7 44 24 04 c6 31 80 	movl   $0x8031c6,0x4(%esp)
  803197:	00 
  803198:	89 04 24             	mov    %eax,(%esp)
  80319b:	e8 a3 e6 ff ff       	call   801843 <sys_env_set_pgfault_upcall>
  8031a0:	85 c0                	test   %eax,%eax
  8031a2:	79 20                	jns    8031c4 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  8031a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8031a8:	c7 44 24 08 68 3f 80 	movl   $0x803f68,0x8(%esp)
  8031af:	00 
  8031b0:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8031b7:	00 
  8031b8:	c7 04 24 94 3f 80 00 	movl   $0x803f94,(%esp)
  8031bf:	e8 5e d8 ff ff       	call   800a22 <_panic>


}
  8031c4:	c9                   	leave  
  8031c5:	c3                   	ret    

008031c6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8031c6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8031c7:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8031cc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8031ce:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8031d1:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8031d5:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8031d9:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8031dd:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8031e0:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8031e3:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8031e6:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8031ea:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8031ee:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8031f2:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8031f6:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8031fa:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  8031fe:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  803202:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  803203:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  803204:	c3                   	ret    
  803205:	66 90                	xchg   %ax,%ax
  803207:	66 90                	xchg   %ax,%ax
  803209:	66 90                	xchg   %ax,%ax
  80320b:	66 90                	xchg   %ax,%ax
  80320d:	66 90                	xchg   %ax,%ax
  80320f:	90                   	nop

00803210 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803210:	55                   	push   %ebp
  803211:	89 e5                	mov    %esp,%ebp
  803213:	56                   	push   %esi
  803214:	53                   	push   %ebx
  803215:	83 ec 10             	sub    $0x10,%esp
  803218:	8b 75 08             	mov    0x8(%ebp),%esi
  80321b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80321e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  803221:	85 c0                	test   %eax,%eax
  803223:	75 0e                	jne    803233 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  803225:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80322c:	e8 88 e6 ff ff       	call   8018b9 <sys_ipc_recv>
  803231:	eb 08                	jmp    80323b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  803233:	89 04 24             	mov    %eax,(%esp)
  803236:	e8 7e e6 ff ff       	call   8018b9 <sys_ipc_recv>
	if(r == 0){
  80323b:	85 c0                	test   %eax,%eax
  80323d:	8d 76 00             	lea    0x0(%esi),%esi
  803240:	75 1e                	jne    803260 <ipc_recv+0x50>
		if( from_env_store != 0 )
  803242:	85 f6                	test   %esi,%esi
  803244:	74 0a                	je     803250 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  803246:	a1 24 64 80 00       	mov    0x806424,%eax
  80324b:	8b 40 74             	mov    0x74(%eax),%eax
  80324e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  803250:	85 db                	test   %ebx,%ebx
  803252:	74 2c                	je     803280 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  803254:	a1 24 64 80 00       	mov    0x806424,%eax
  803259:	8b 40 78             	mov    0x78(%eax),%eax
  80325c:	89 03                	mov    %eax,(%ebx)
  80325e:	eb 20                	jmp    803280 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  803260:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803264:	c7 44 24 08 a4 3f 80 	movl   $0x803fa4,0x8(%esp)
  80326b:	00 
  80326c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  803273:	00 
  803274:	c7 04 24 20 40 80 00 	movl   $0x804020,(%esp)
  80327b:	e8 a2 d7 ff ff       	call   800a22 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  803280:	a1 24 64 80 00       	mov    0x806424,%eax
  803285:	8b 50 70             	mov    0x70(%eax),%edx
  803288:	85 d2                	test   %edx,%edx
  80328a:	75 13                	jne    80329f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80328c:	8b 40 48             	mov    0x48(%eax),%eax
  80328f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803293:	c7 04 24 d4 3f 80 00 	movl   $0x803fd4,(%esp)
  80329a:	e8 7c d8 ff ff       	call   800b1b <cprintf>
	return thisenv->env_ipc_value;
  80329f:	a1 24 64 80 00       	mov    0x806424,%eax
  8032a4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8032a7:	83 c4 10             	add    $0x10,%esp
  8032aa:	5b                   	pop    %ebx
  8032ab:	5e                   	pop    %esi
  8032ac:	5d                   	pop    %ebp
  8032ad:	c3                   	ret    

008032ae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8032ae:	55                   	push   %ebp
  8032af:	89 e5                	mov    %esp,%ebp
  8032b1:	57                   	push   %edi
  8032b2:	56                   	push   %esi
  8032b3:	53                   	push   %ebx
  8032b4:	83 ec 1c             	sub    $0x1c,%esp
  8032b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8032ba:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  8032bd:	85 f6                	test   %esi,%esi
  8032bf:	75 22                	jne    8032e3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  8032c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8032c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032c8:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8032cf:	ee 
  8032d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032d7:	89 3c 24             	mov    %edi,(%esp)
  8032da:	e8 b7 e5 ff ff       	call   801896 <sys_ipc_try_send>
  8032df:	89 c3                	mov    %eax,%ebx
  8032e1:	eb 1c                	jmp    8032ff <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8032e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8032e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8032ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032f5:	89 3c 24             	mov    %edi,(%esp)
  8032f8:	e8 99 e5 ff ff       	call   801896 <sys_ipc_try_send>
  8032fd:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8032ff:	83 fb f9             	cmp    $0xfffffff9,%ebx
  803302:	74 3e                	je     803342 <ipc_send+0x94>
  803304:	89 d8                	mov    %ebx,%eax
  803306:	c1 e8 1f             	shr    $0x1f,%eax
  803309:	84 c0                	test   %al,%al
  80330b:	74 35                	je     803342 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80330d:	e8 53 e3 ff ff       	call   801665 <sys_getenvid>
  803312:	89 44 24 04          	mov    %eax,0x4(%esp)
  803316:	c7 04 24 2a 40 80 00 	movl   $0x80402a,(%esp)
  80331d:	e8 f9 d7 ff ff       	call   800b1b <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  803322:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  803326:	c7 44 24 08 f8 3f 80 	movl   $0x803ff8,0x8(%esp)
  80332d:	00 
  80332e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  803335:	00 
  803336:	c7 04 24 20 40 80 00 	movl   $0x804020,(%esp)
  80333d:	e8 e0 d6 ff ff       	call   800a22 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  803342:	83 fb f9             	cmp    $0xfffffff9,%ebx
  803345:	75 0e                	jne    803355 <ipc_send+0xa7>
			sys_yield();
  803347:	e8 38 e3 ff ff       	call   801684 <sys_yield>
		else break;
	}
  80334c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803350:	e9 68 ff ff ff       	jmp    8032bd <ipc_send+0xf>
	
}
  803355:	83 c4 1c             	add    $0x1c,%esp
  803358:	5b                   	pop    %ebx
  803359:	5e                   	pop    %esi
  80335a:	5f                   	pop    %edi
  80335b:	5d                   	pop    %ebp
  80335c:	c3                   	ret    

0080335d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80335d:	55                   	push   %ebp
  80335e:	89 e5                	mov    %esp,%ebp
  803360:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803363:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803368:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80336b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803371:	8b 52 50             	mov    0x50(%edx),%edx
  803374:	39 ca                	cmp    %ecx,%edx
  803376:	75 0d                	jne    803385 <ipc_find_env+0x28>
			return envs[i].env_id;
  803378:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80337b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803380:	8b 40 40             	mov    0x40(%eax),%eax
  803383:	eb 0e                	jmp    803393 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803385:	83 c0 01             	add    $0x1,%eax
  803388:	3d 00 04 00 00       	cmp    $0x400,%eax
  80338d:	75 d9                	jne    803368 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80338f:	66 b8 00 00          	mov    $0x0,%ax
}
  803393:	5d                   	pop    %ebp
  803394:	c3                   	ret    

00803395 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803395:	55                   	push   %ebp
  803396:	89 e5                	mov    %esp,%ebp
  803398:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80339b:	89 d0                	mov    %edx,%eax
  80339d:	c1 e8 16             	shr    $0x16,%eax
  8033a0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8033a7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033ac:	f6 c1 01             	test   $0x1,%cl
  8033af:	74 1d                	je     8033ce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8033b1:	c1 ea 0c             	shr    $0xc,%edx
  8033b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8033bb:	f6 c2 01             	test   $0x1,%dl
  8033be:	74 0e                	je     8033ce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8033c0:	c1 ea 0c             	shr    $0xc,%edx
  8033c3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8033ca:	ef 
  8033cb:	0f b7 c0             	movzwl %ax,%eax
}
  8033ce:	5d                   	pop    %ebp
  8033cf:	c3                   	ret    

008033d0 <__udivdi3>:
  8033d0:	55                   	push   %ebp
  8033d1:	57                   	push   %edi
  8033d2:	56                   	push   %esi
  8033d3:	83 ec 0c             	sub    $0xc,%esp
  8033d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8033da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8033de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8033e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8033e6:	85 c0                	test   %eax,%eax
  8033e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8033ec:	89 ea                	mov    %ebp,%edx
  8033ee:	89 0c 24             	mov    %ecx,(%esp)
  8033f1:	75 2d                	jne    803420 <__udivdi3+0x50>
  8033f3:	39 e9                	cmp    %ebp,%ecx
  8033f5:	77 61                	ja     803458 <__udivdi3+0x88>
  8033f7:	85 c9                	test   %ecx,%ecx
  8033f9:	89 ce                	mov    %ecx,%esi
  8033fb:	75 0b                	jne    803408 <__udivdi3+0x38>
  8033fd:	b8 01 00 00 00       	mov    $0x1,%eax
  803402:	31 d2                	xor    %edx,%edx
  803404:	f7 f1                	div    %ecx
  803406:	89 c6                	mov    %eax,%esi
  803408:	31 d2                	xor    %edx,%edx
  80340a:	89 e8                	mov    %ebp,%eax
  80340c:	f7 f6                	div    %esi
  80340e:	89 c5                	mov    %eax,%ebp
  803410:	89 f8                	mov    %edi,%eax
  803412:	f7 f6                	div    %esi
  803414:	89 ea                	mov    %ebp,%edx
  803416:	83 c4 0c             	add    $0xc,%esp
  803419:	5e                   	pop    %esi
  80341a:	5f                   	pop    %edi
  80341b:	5d                   	pop    %ebp
  80341c:	c3                   	ret    
  80341d:	8d 76 00             	lea    0x0(%esi),%esi
  803420:	39 e8                	cmp    %ebp,%eax
  803422:	77 24                	ja     803448 <__udivdi3+0x78>
  803424:	0f bd e8             	bsr    %eax,%ebp
  803427:	83 f5 1f             	xor    $0x1f,%ebp
  80342a:	75 3c                	jne    803468 <__udivdi3+0x98>
  80342c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803430:	39 34 24             	cmp    %esi,(%esp)
  803433:	0f 86 9f 00 00 00    	jbe    8034d8 <__udivdi3+0x108>
  803439:	39 d0                	cmp    %edx,%eax
  80343b:	0f 82 97 00 00 00    	jb     8034d8 <__udivdi3+0x108>
  803441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803448:	31 d2                	xor    %edx,%edx
  80344a:	31 c0                	xor    %eax,%eax
  80344c:	83 c4 0c             	add    $0xc,%esp
  80344f:	5e                   	pop    %esi
  803450:	5f                   	pop    %edi
  803451:	5d                   	pop    %ebp
  803452:	c3                   	ret    
  803453:	90                   	nop
  803454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803458:	89 f8                	mov    %edi,%eax
  80345a:	f7 f1                	div    %ecx
  80345c:	31 d2                	xor    %edx,%edx
  80345e:	83 c4 0c             	add    $0xc,%esp
  803461:	5e                   	pop    %esi
  803462:	5f                   	pop    %edi
  803463:	5d                   	pop    %ebp
  803464:	c3                   	ret    
  803465:	8d 76 00             	lea    0x0(%esi),%esi
  803468:	89 e9                	mov    %ebp,%ecx
  80346a:	8b 3c 24             	mov    (%esp),%edi
  80346d:	d3 e0                	shl    %cl,%eax
  80346f:	89 c6                	mov    %eax,%esi
  803471:	b8 20 00 00 00       	mov    $0x20,%eax
  803476:	29 e8                	sub    %ebp,%eax
  803478:	89 c1                	mov    %eax,%ecx
  80347a:	d3 ef                	shr    %cl,%edi
  80347c:	89 e9                	mov    %ebp,%ecx
  80347e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803482:	8b 3c 24             	mov    (%esp),%edi
  803485:	09 74 24 08          	or     %esi,0x8(%esp)
  803489:	89 d6                	mov    %edx,%esi
  80348b:	d3 e7                	shl    %cl,%edi
  80348d:	89 c1                	mov    %eax,%ecx
  80348f:	89 3c 24             	mov    %edi,(%esp)
  803492:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803496:	d3 ee                	shr    %cl,%esi
  803498:	89 e9                	mov    %ebp,%ecx
  80349a:	d3 e2                	shl    %cl,%edx
  80349c:	89 c1                	mov    %eax,%ecx
  80349e:	d3 ef                	shr    %cl,%edi
  8034a0:	09 d7                	or     %edx,%edi
  8034a2:	89 f2                	mov    %esi,%edx
  8034a4:	89 f8                	mov    %edi,%eax
  8034a6:	f7 74 24 08          	divl   0x8(%esp)
  8034aa:	89 d6                	mov    %edx,%esi
  8034ac:	89 c7                	mov    %eax,%edi
  8034ae:	f7 24 24             	mull   (%esp)
  8034b1:	39 d6                	cmp    %edx,%esi
  8034b3:	89 14 24             	mov    %edx,(%esp)
  8034b6:	72 30                	jb     8034e8 <__udivdi3+0x118>
  8034b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8034bc:	89 e9                	mov    %ebp,%ecx
  8034be:	d3 e2                	shl    %cl,%edx
  8034c0:	39 c2                	cmp    %eax,%edx
  8034c2:	73 05                	jae    8034c9 <__udivdi3+0xf9>
  8034c4:	3b 34 24             	cmp    (%esp),%esi
  8034c7:	74 1f                	je     8034e8 <__udivdi3+0x118>
  8034c9:	89 f8                	mov    %edi,%eax
  8034cb:	31 d2                	xor    %edx,%edx
  8034cd:	e9 7a ff ff ff       	jmp    80344c <__udivdi3+0x7c>
  8034d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8034d8:	31 d2                	xor    %edx,%edx
  8034da:	b8 01 00 00 00       	mov    $0x1,%eax
  8034df:	e9 68 ff ff ff       	jmp    80344c <__udivdi3+0x7c>
  8034e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8034e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8034eb:	31 d2                	xor    %edx,%edx
  8034ed:	83 c4 0c             	add    $0xc,%esp
  8034f0:	5e                   	pop    %esi
  8034f1:	5f                   	pop    %edi
  8034f2:	5d                   	pop    %ebp
  8034f3:	c3                   	ret    
  8034f4:	66 90                	xchg   %ax,%ax
  8034f6:	66 90                	xchg   %ax,%ax
  8034f8:	66 90                	xchg   %ax,%ax
  8034fa:	66 90                	xchg   %ax,%ax
  8034fc:	66 90                	xchg   %ax,%ax
  8034fe:	66 90                	xchg   %ax,%ax

00803500 <__umoddi3>:
  803500:	55                   	push   %ebp
  803501:	57                   	push   %edi
  803502:	56                   	push   %esi
  803503:	83 ec 14             	sub    $0x14,%esp
  803506:	8b 44 24 28          	mov    0x28(%esp),%eax
  80350a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80350e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803512:	89 c7                	mov    %eax,%edi
  803514:	89 44 24 04          	mov    %eax,0x4(%esp)
  803518:	8b 44 24 30          	mov    0x30(%esp),%eax
  80351c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803520:	89 34 24             	mov    %esi,(%esp)
  803523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803527:	85 c0                	test   %eax,%eax
  803529:	89 c2                	mov    %eax,%edx
  80352b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80352f:	75 17                	jne    803548 <__umoddi3+0x48>
  803531:	39 fe                	cmp    %edi,%esi
  803533:	76 4b                	jbe    803580 <__umoddi3+0x80>
  803535:	89 c8                	mov    %ecx,%eax
  803537:	89 fa                	mov    %edi,%edx
  803539:	f7 f6                	div    %esi
  80353b:	89 d0                	mov    %edx,%eax
  80353d:	31 d2                	xor    %edx,%edx
  80353f:	83 c4 14             	add    $0x14,%esp
  803542:	5e                   	pop    %esi
  803543:	5f                   	pop    %edi
  803544:	5d                   	pop    %ebp
  803545:	c3                   	ret    
  803546:	66 90                	xchg   %ax,%ax
  803548:	39 f8                	cmp    %edi,%eax
  80354a:	77 54                	ja     8035a0 <__umoddi3+0xa0>
  80354c:	0f bd e8             	bsr    %eax,%ebp
  80354f:	83 f5 1f             	xor    $0x1f,%ebp
  803552:	75 5c                	jne    8035b0 <__umoddi3+0xb0>
  803554:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803558:	39 3c 24             	cmp    %edi,(%esp)
  80355b:	0f 87 e7 00 00 00    	ja     803648 <__umoddi3+0x148>
  803561:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803565:	29 f1                	sub    %esi,%ecx
  803567:	19 c7                	sbb    %eax,%edi
  803569:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80356d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803571:	8b 44 24 08          	mov    0x8(%esp),%eax
  803575:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803579:	83 c4 14             	add    $0x14,%esp
  80357c:	5e                   	pop    %esi
  80357d:	5f                   	pop    %edi
  80357e:	5d                   	pop    %ebp
  80357f:	c3                   	ret    
  803580:	85 f6                	test   %esi,%esi
  803582:	89 f5                	mov    %esi,%ebp
  803584:	75 0b                	jne    803591 <__umoddi3+0x91>
  803586:	b8 01 00 00 00       	mov    $0x1,%eax
  80358b:	31 d2                	xor    %edx,%edx
  80358d:	f7 f6                	div    %esi
  80358f:	89 c5                	mov    %eax,%ebp
  803591:	8b 44 24 04          	mov    0x4(%esp),%eax
  803595:	31 d2                	xor    %edx,%edx
  803597:	f7 f5                	div    %ebp
  803599:	89 c8                	mov    %ecx,%eax
  80359b:	f7 f5                	div    %ebp
  80359d:	eb 9c                	jmp    80353b <__umoddi3+0x3b>
  80359f:	90                   	nop
  8035a0:	89 c8                	mov    %ecx,%eax
  8035a2:	89 fa                	mov    %edi,%edx
  8035a4:	83 c4 14             	add    $0x14,%esp
  8035a7:	5e                   	pop    %esi
  8035a8:	5f                   	pop    %edi
  8035a9:	5d                   	pop    %ebp
  8035aa:	c3                   	ret    
  8035ab:	90                   	nop
  8035ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035b0:	8b 04 24             	mov    (%esp),%eax
  8035b3:	be 20 00 00 00       	mov    $0x20,%esi
  8035b8:	89 e9                	mov    %ebp,%ecx
  8035ba:	29 ee                	sub    %ebp,%esi
  8035bc:	d3 e2                	shl    %cl,%edx
  8035be:	89 f1                	mov    %esi,%ecx
  8035c0:	d3 e8                	shr    %cl,%eax
  8035c2:	89 e9                	mov    %ebp,%ecx
  8035c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035c8:	8b 04 24             	mov    (%esp),%eax
  8035cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8035cf:	89 fa                	mov    %edi,%edx
  8035d1:	d3 e0                	shl    %cl,%eax
  8035d3:	89 f1                	mov    %esi,%ecx
  8035d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8035dd:	d3 ea                	shr    %cl,%edx
  8035df:	89 e9                	mov    %ebp,%ecx
  8035e1:	d3 e7                	shl    %cl,%edi
  8035e3:	89 f1                	mov    %esi,%ecx
  8035e5:	d3 e8                	shr    %cl,%eax
  8035e7:	89 e9                	mov    %ebp,%ecx
  8035e9:	09 f8                	or     %edi,%eax
  8035eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8035ef:	f7 74 24 04          	divl   0x4(%esp)
  8035f3:	d3 e7                	shl    %cl,%edi
  8035f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8035f9:	89 d7                	mov    %edx,%edi
  8035fb:	f7 64 24 08          	mull   0x8(%esp)
  8035ff:	39 d7                	cmp    %edx,%edi
  803601:	89 c1                	mov    %eax,%ecx
  803603:	89 14 24             	mov    %edx,(%esp)
  803606:	72 2c                	jb     803634 <__umoddi3+0x134>
  803608:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80360c:	72 22                	jb     803630 <__umoddi3+0x130>
  80360e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803612:	29 c8                	sub    %ecx,%eax
  803614:	19 d7                	sbb    %edx,%edi
  803616:	89 e9                	mov    %ebp,%ecx
  803618:	89 fa                	mov    %edi,%edx
  80361a:	d3 e8                	shr    %cl,%eax
  80361c:	89 f1                	mov    %esi,%ecx
  80361e:	d3 e2                	shl    %cl,%edx
  803620:	89 e9                	mov    %ebp,%ecx
  803622:	d3 ef                	shr    %cl,%edi
  803624:	09 d0                	or     %edx,%eax
  803626:	89 fa                	mov    %edi,%edx
  803628:	83 c4 14             	add    $0x14,%esp
  80362b:	5e                   	pop    %esi
  80362c:	5f                   	pop    %edi
  80362d:	5d                   	pop    %ebp
  80362e:	c3                   	ret    
  80362f:	90                   	nop
  803630:	39 d7                	cmp    %edx,%edi
  803632:	75 da                	jne    80360e <__umoddi3+0x10e>
  803634:	8b 14 24             	mov    (%esp),%edx
  803637:	89 c1                	mov    %eax,%ecx
  803639:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80363d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803641:	eb cb                	jmp    80360e <__umoddi3+0x10e>
  803643:	90                   	nop
  803644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803648:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80364c:	0f 82 0f ff ff ff    	jb     803561 <__umoddi3+0x61>
  803652:	e9 1a ff ff ff       	jmp    803571 <__umoddi3+0x71>
