
obj/user/dumbfork：     文件格式 elf32-i386


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
  80002c:	e8 1d 02 00 00       	call   80024e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80004e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800055:	00 
  800056:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80005a:	89 34 24             	mov    %esi,(%esp)
  80005d:	e8 c1 0d 00 00       	call   800e23 <sys_page_alloc>
  800062:	85 c0                	test   %eax,%eax
  800064:	79 20                	jns    800086 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800066:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80006a:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  800071:	00 
  800072:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800079:	00 
  80007a:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  800081:	e8 11 02 00 00       	call   800297 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800086:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80008d:	00 
  80008e:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800095:	00 
  800096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009d:	00 
  80009e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a2:	89 34 24             	mov    %esi,(%esp)
  8000a5:	e8 cd 0d 00 00       	call   800e77 <sys_page_map>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 20                	jns    8000ce <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b2:	c7 44 24 08 03 13 80 	movl   $0x801303,0x8(%esp)
  8000b9:	00 
  8000ba:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c1:	00 
  8000c2:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  8000c9:	e8 c9 01 00 00       	call   800297 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000d5:	00 
  8000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000da:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e1:	e8 be 0a 00 00       	call   800ba4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000e6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 d0 0d 00 00       	call   800eca <sys_page_unmap>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 14 13 80 	movl   $0x801314,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  800119:	e8 79 01 00 00       	call   800297 <_panic>
}
  80011e:	83 c4 20             	add    $0x20,%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <dumbfork>:

envid_t
dumbfork(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80012d:	b8 07 00 00 00       	mov    $0x7,%eax
  800132:	cd 30                	int    $0x30
  800134:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	79 20                	jns    80015a <dumbfork+0x35>
		panic("sys_exofork: %e", envid);
  80013a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013e:	c7 44 24 08 27 13 80 	movl   $0x801327,0x8(%esp)
  800145:	00 
  800146:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80014d:	00 
  80014e:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  800155:	e8 3d 01 00 00       	call   800297 <_panic>
  80015a:	89 c3                	mov    %eax,%ebx
	if (envid == 0) {
  80015c:	85 c0                	test   %eax,%eax
  80015e:	75 1e                	jne    80017e <dumbfork+0x59>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800160:	e8 80 0c 00 00       	call   800de5 <sys_getenvid>
  800165:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800172:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800177:	b8 00 00 00 00       	mov    $0x0,%eax
  80017c:	eb 71                	jmp    8001ef <dumbfork+0xca>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800185:	eb 13                	jmp    80019a <dumbfork+0x75>
		duppage(envid, addr);
  800187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80018b:	89 1c 24             	mov    %ebx,(%esp)
  80018e:	e8 ad fe ff ff       	call   800040 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800193:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80019a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80019d:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8001a3:	72 e2                	jb     800187 <dumbfork+0x62>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 87 fe ff ff       	call   800040 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001c0:	00 
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 54 0d 00 00       	call   800f1d <sys_env_set_status>
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	79 20                	jns    8001ed <dumbfork+0xc8>
		panic("sys_env_set_status: %e", r);
  8001cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d1:	c7 44 24 08 37 13 80 	movl   $0x801337,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001e0:	00 
  8001e1:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  8001e8:	e8 aa 00 00 00       	call   800297 <_panic>

	return envid;
  8001ed:	89 f0                	mov    %esi,%eax
}
  8001ef:	83 c4 20             	add    $0x20,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5d                   	pop    %ebp
  8001f5:	c3                   	ret    

008001f6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fe:	e8 22 ff ff ff       	call   800125 <dumbfork>
  800203:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020a:	eb 28                	jmp    800234 <umain+0x3e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020c:	b8 55 13 80 00       	mov    $0x801355,%eax
  800211:	eb 05                	jmp    800218 <umain+0x22>
  800213:	b8 4e 13 80 00       	mov    $0x80134e,%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800220:	c7 04 24 5b 13 80 00 	movl   $0x80135b,(%esp)
  800227:	e8 64 01 00 00       	call   800390 <cprintf>
		sys_yield();
  80022c:	e8 d3 0b 00 00       	call   800e04 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800231:	83 c3 01             	add    $0x1,%ebx
  800234:	85 f6                	test   %esi,%esi
  800236:	75 0a                	jne    800242 <umain+0x4c>
  800238:	83 fb 13             	cmp    $0x13,%ebx
  80023b:	7e cf                	jle    80020c <umain+0x16>
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	eb 05                	jmp    800247 <umain+0x51>
  800242:	83 fb 09             	cmp    $0x9,%ebx
  800245:	7e cc                	jle    800213 <umain+0x1d>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80025a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800261:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7e 08                	jle    800270 <libmain+0x22>
		binaryname = argv[0];
  800268:	8b 0a                	mov    (%edx),%ecx
  80026a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800270:	89 54 24 04          	mov    %edx,0x4(%esp)
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 7a ff ff ff       	call   8001f6 <umain>

	// exit gracefully
	exit();
  80027c:	e8 02 00 00 00       	call   800283 <exit>
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800290:	e8 fe 0a 00 00       	call   800d93 <sys_env_destroy>
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80029f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002a8:	e8 38 0b 00 00       	call   800de5 <sys_getenvid>
  8002ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c3:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  8002ca:	e8 c1 00 00 00       	call   800390 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	e8 51 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002de:	c7 04 24 6b 13 80 00 	movl   $0x80136b,(%esp)
  8002e5:	e8 a6 00 00 00       	call   800390 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ea:	cc                   	int3   
  8002eb:	eb fd                	jmp    8002ea <_panic+0x53>

008002ed <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 14             	sub    $0x14,%esp
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f7:	8b 13                	mov    (%ebx),%edx
  8002f9:	8d 42 01             	lea    0x1(%edx),%eax
  8002fc:	89 03                	mov    %eax,(%ebx)
  8002fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800301:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800305:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030a:	75 19                	jne    800325 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80030c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800313:	00 
  800314:	8d 43 08             	lea    0x8(%ebx),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	e8 37 0a 00 00       	call   800d56 <sys_cputs>
		b->idx = 0;
  80031f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800325:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 ed 02 80 00 	movl   $0x8002ed,(%esp)
  80036b:	e8 74 01 00 00       	call   8004e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800370:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	e8 ce 09 00 00       	call   800d56 <sys_cputs>

	return b.cnt;
}
  800388:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800396:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 87 ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    
  8003aa:	66 90                	xchg   %ax,%ax
  8003ac:	66 90                	xchg   %ax,%ax
  8003ae:	66 90                	xchg   %ax,%ax

008003b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	57                   	push   %edi
  8003b4:	56                   	push   %esi
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 3c             	sub    $0x3c,%esp
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	89 d7                	mov    %edx,%edi
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c7:	89 c3                	mov    %eax,%ebx
  8003c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003dd:	39 d9                	cmp    %ebx,%ecx
  8003df:	72 05                	jb     8003e6 <printnum+0x36>
  8003e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003e4:	77 69                	ja     80044f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003ed:	83 ee 01             	sub    $0x1,%esi
  8003f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8003fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800400:	89 c3                	mov    %eax,%ebx
  800402:	89 d6                	mov    %edx,%esi
  800404:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800407:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80040a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80040e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80041b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041f:	e8 1c 0c 00 00       	call   801040 <__udivdi3>
  800424:	89 d9                	mov    %ebx,%ecx
  800426:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80042a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	89 54 24 04          	mov    %edx,0x4(%esp)
  800435:	89 fa                	mov    %edi,%edx
  800437:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043a:	e8 71 ff ff ff       	call   8003b0 <printnum>
  80043f:	eb 1b                	jmp    80045c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800441:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800445:	8b 45 18             	mov    0x18(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	ff d3                	call   *%ebx
  80044d:	eb 03                	jmp    800452 <printnum+0xa2>
  80044f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800452:	83 ee 01             	sub    $0x1,%esi
  800455:	85 f6                	test   %esi,%esi
  800457:	7f e8                	jg     800441 <printnum+0x91>
  800459:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80045c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800460:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800464:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800467:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80046a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800472:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047f:	e8 ec 0c 00 00       	call   801170 <__umoddi3>
  800484:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800488:	0f be 80 9c 13 80 00 	movsbl 0x80139c(%eax),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800495:	ff d0                	call   *%eax
}
  800497:	83 c4 3c             	add    $0x3c,%esp
  80049a:	5b                   	pop    %ebx
  80049b:	5e                   	pop    %esi
  80049c:	5f                   	pop    %edi
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    

0080049f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ae:	73 0a                	jae    8004ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b8:	88 02                	mov    %al,(%edx)
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	e8 02 00 00 00       	call   8004e4 <vprintfmt>
	va_end(ap);
}
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	53                   	push   %ebx
  8004ea:	83 ec 3c             	sub    $0x3c,%esp
  8004ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f6:	eb 11                	jmp    800509 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	0f 84 48 04 00 00    	je     800948 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	83 c7 01             	add    $0x1,%edi
  80050c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800510:	83 f8 25             	cmp    $0x25,%eax
  800513:	75 e3                	jne    8004f8 <vprintfmt+0x14>
  800515:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800519:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800520:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800527:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	eb 1f                	jmp    800554 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800538:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053c:	eb 16                	jmp    800554 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800541:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800545:	eb 0d                	jmp    800554 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800547:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80054a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8d 47 01             	lea    0x1(%edi),%eax
  800557:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055a:	0f b6 17             	movzbl (%edi),%edx
  80055d:	0f b6 c2             	movzbl %dl,%eax
  800560:	83 ea 23             	sub    $0x23,%edx
  800563:	80 fa 55             	cmp    $0x55,%dl
  800566:	0f 87 bf 03 00 00    	ja     80092b <vprintfmt+0x447>
  80056c:	0f b6 d2             	movzbl %dl,%edx
  80056f:	ff 24 95 60 14 80 00 	jmp    *0x801460(,%edx,4)
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800581:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800584:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800588:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80058b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80058e:	83 f9 09             	cmp    $0x9,%ecx
  800591:	77 3c                	ja     8005cf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800593:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800596:	eb e9                	jmp    800581 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 40 04             	lea    0x4(%eax),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ac:	eb 27                	jmp    8005d5 <vprintfmt+0xf1>
  8005ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b8:	0f 49 c2             	cmovns %edx,%eax
  8005bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	eb 91                	jmp    800554 <vprintfmt+0x70>
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005cd:	eb 85                	jmp    800554 <vprintfmt+0x70>
  8005cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	0f 89 75 ff ff ff    	jns    800554 <vprintfmt+0x70>
  8005df:	e9 63 ff ff ff       	jmp    800547 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ea:	e9 65 ff ff ff       	jmp    800554 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800604:	e9 00 ff ff ff       	jmp    800509 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	99                   	cltd   
  800613:	31 d0                	xor    %edx,%eax
  800615:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800617:	83 f8 09             	cmp    $0x9,%eax
  80061a:	7f 0b                	jg     800627 <vprintfmt+0x143>
  80061c:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800623:	85 d2                	test   %edx,%edx
  800625:	75 20                	jne    800647 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800627:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80062b:	c7 44 24 08 b4 13 80 	movl   $0x8013b4,0x8(%esp)
  800632:	00 
  800633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	e8 7d fe ff ff       	call   8004bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800642:	e9 c2 fe ff ff       	jmp    800509 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800647:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064b:	c7 44 24 08 bd 13 80 	movl   $0x8013bd,0x8(%esp)
  800652:	00 
  800653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800657:	89 34 24             	mov    %esi,(%esp)
  80065a:	e8 5d fe ff ff       	call   8004bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	e9 a2 fe ff ff       	jmp    800509 <vprintfmt+0x25>
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80066d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800670:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800673:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800677:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800679:	85 ff                	test   %edi,%edi
  80067b:	b8 ad 13 80 00       	mov    $0x8013ad,%eax
  800680:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800683:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800687:	0f 84 92 00 00 00    	je     80071f <vprintfmt+0x23b>
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	0f 8e 98 00 00 00    	jle    80072d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	89 54 24 04          	mov    %edx,0x4(%esp)
  800699:	89 3c 24             	mov    %edi,(%esp)
  80069c:	e8 47 03 00 00       	call   8009e8 <strnlen>
  8006a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006a4:	29 c1                	sub    %eax,%ecx
  8006a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8006a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b5:	eb 0f                	jmp    8006c6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8006b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006be:	89 04 24             	mov    %eax,(%esp)
  8006c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	85 ff                	test   %edi,%edi
  8006c8:	7f ed                	jg     8006b7 <vprintfmt+0x1d3>
  8006ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d0:	85 c9                	test   %ecx,%ecx
  8006d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d7:	0f 49 c1             	cmovns %ecx,%eax
  8006da:	29 c1                	sub    %eax,%ecx
  8006dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e5:	89 cb                	mov    %ecx,%ebx
  8006e7:	eb 50                	jmp    800739 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ed:	74 1e                	je     80070d <vprintfmt+0x229>
  8006ef:	0f be d2             	movsbl %dl,%edx
  8006f2:	83 ea 20             	sub    $0x20,%edx
  8006f5:	83 fa 5e             	cmp    $0x5e,%edx
  8006f8:	76 13                	jbe    80070d <vprintfmt+0x229>
					putch('?', putdat);
  8006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800701:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800708:	ff 55 08             	call   *0x8(%ebp)
  80070b:	eb 0d                	jmp    80071a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80070d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800710:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	83 eb 01             	sub    $0x1,%ebx
  80071d:	eb 1a                	jmp    800739 <vprintfmt+0x255>
  80071f:	89 75 08             	mov    %esi,0x8(%ebp)
  800722:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800725:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800728:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80072b:	eb 0c                	jmp    800739 <vprintfmt+0x255>
  80072d:	89 75 08             	mov    %esi,0x8(%ebp)
  800730:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800733:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800736:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800739:	83 c7 01             	add    $0x1,%edi
  80073c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800740:	0f be c2             	movsbl %dl,%eax
  800743:	85 c0                	test   %eax,%eax
  800745:	74 25                	je     80076c <vprintfmt+0x288>
  800747:	85 f6                	test   %esi,%esi
  800749:	78 9e                	js     8006e9 <vprintfmt+0x205>
  80074b:	83 ee 01             	sub    $0x1,%esi
  80074e:	79 99                	jns    8006e9 <vprintfmt+0x205>
  800750:	89 df                	mov    %ebx,%edi
  800752:	8b 75 08             	mov    0x8(%ebp),%esi
  800755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800758:	eb 1a                	jmp    800774 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800765:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800767:	83 ef 01             	sub    $0x1,%edi
  80076a:	eb 08                	jmp    800774 <vprintfmt+0x290>
  80076c:	89 df                	mov    %ebx,%edi
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800774:	85 ff                	test   %edi,%edi
  800776:	7f e2                	jg     80075a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077b:	e9 89 fd ff ff       	jmp    800509 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7e 19                	jle    80079e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 50 04             	mov    0x4(%eax),%edx
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 08             	lea    0x8(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	eb 38                	jmp    8007d6 <vprintfmt+0x2f2>
	else if (lflag)
  80079e:	85 c9                	test   %ecx,%ecx
  8007a0:	74 1b                	je     8007bd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007aa:	89 c1                	mov    %eax,%ecx
  8007ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8007af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bb:	eb 19                	jmp    8007d6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007dc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e5:	0f 89 04 01 00 00    	jns    8008ef <vprintfmt+0x40b>
				putch('-', putdat);
  8007eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007fe:	f7 da                	neg    %edx
  800800:	83 d1 00             	adc    $0x0,%ecx
  800803:	f7 d9                	neg    %ecx
  800805:	e9 e5 00 00 00       	jmp    8008ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080a:	83 f9 01             	cmp    $0x1,%ecx
  80080d:	7e 10                	jle    80081f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8b 10                	mov    (%eax),%edx
  800814:	8b 48 04             	mov    0x4(%eax),%ecx
  800817:	8d 40 08             	lea    0x8(%eax),%eax
  80081a:	89 45 14             	mov    %eax,0x14(%ebp)
  80081d:	eb 26                	jmp    800845 <vprintfmt+0x361>
	else if (lflag)
  80081f:	85 c9                	test   %ecx,%ecx
  800821:	74 12                	je     800835 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082d:	8d 40 04             	lea    0x4(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)
  800833:	eb 10                	jmp    800845 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800845:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80084a:	e9 a0 00 00 00       	jmp    8008ef <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80084f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800853:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80085a:	ff d6                	call   *%esi
			putch('X', putdat);
  80085c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800860:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800867:	ff d6                	call   *%esi
			putch('X', putdat);
  800869:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800874:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800879:	e9 8b fc ff ff       	jmp    800509 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80087e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800882:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800889:	ff d6                	call   *%esi
			putch('x', putdat);
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800896:	ff d6                	call   *%esi
			num = (unsigned long long)
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8b 10                	mov    (%eax),%edx
  80089d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8008a2:	8d 40 04             	lea    0x4(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8008ad:	eb 40                	jmp    8008ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008af:	83 f9 01             	cmp    $0x1,%ecx
  8008b2:	7e 10                	jle    8008c4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8b 10                	mov    (%eax),%edx
  8008b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008bc:	8d 40 08             	lea    0x8(%eax),%eax
  8008bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c2:	eb 26                	jmp    8008ea <vprintfmt+0x406>
	else if (lflag)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 12                	je     8008da <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8b 10                	mov    (%eax),%edx
  8008cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d2:	8d 40 04             	lea    0x4(%eax),%eax
  8008d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d8:	eb 10                	jmp    8008ea <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e4:	8d 40 04             	lea    0x4(%eax),%eax
  8008e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800902:	89 14 24             	mov    %edx,(%esp)
  800905:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800909:	89 da                	mov    %ebx,%edx
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	e8 9e fa ff ff       	call   8003b0 <printnum>
			break;
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800915:	e9 ef fb ff ff       	jmp    800509 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800926:	e9 de fb ff ff       	jmp    800509 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800936:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800938:	eb 03                	jmp    80093d <vprintfmt+0x459>
  80093a:	83 ef 01             	sub    $0x1,%edi
  80093d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800941:	75 f7                	jne    80093a <vprintfmt+0x456>
  800943:	e9 c1 fb ff ff       	jmp    800509 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800948:	83 c4 3c             	add    $0x3c,%esp
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 28             	sub    $0x28,%esp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800963:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800966:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096d:	85 c0                	test   %eax,%eax
  80096f:	74 30                	je     8009a1 <vsnprintf+0x51>
  800971:	85 d2                	test   %edx,%edx
  800973:	7e 2c                	jle    8009a1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	8b 45 10             	mov    0x10(%ebp),%eax
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098a:	c7 04 24 9f 04 80 00 	movl   $0x80049f,(%esp)
  800991:	e8 4e fb ff ff       	call   8004e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800996:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800999:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099f:	eb 05                	jmp    8009a6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 82 ff ff ff       	call   800950 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 03                	jmp    8009e0 <strlen+0x10>
		n++;
  8009dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e4:	75 f7                	jne    8009dd <strlen+0xd>
		n++;
	return n;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 03                	jmp    8009fb <strnlen+0x13>
		n++;
  8009f8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	74 06                	je     800a05 <strnlen+0x1d>
  8009ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a03:	75 f3                	jne    8009f8 <strnlen+0x10>
		n++;
	return n;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a20:	84 db                	test   %bl,%bl
  800a22:	75 ef                	jne    800a13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a31:	89 1c 24             	mov    %ebx,(%esp)
  800a34:	e8 97 ff ff ff       	call   8009d0 <strlen>
	strcpy(dst + len, src);
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a40:	01 d8                	add    %ebx,%eax
  800a42:	89 04 24             	mov    %eax,(%esp)
  800a45:	e8 bd ff ff ff       	call   800a07 <strcpy>
	return dst;
}
  800a4a:	89 d8                	mov    %ebx,%eax
  800a4c:	83 c4 08             	add    $0x8,%esp
  800a4f:	5b                   	pop    %ebx
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a62:	89 f2                	mov    %esi,%edx
  800a64:	eb 0f                	jmp    800a75 <strncpy+0x23>
		*dst++ = *src;
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	0f b6 01             	movzbl (%ecx),%eax
  800a6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a72:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a75:	39 da                	cmp    %ebx,%edx
  800a77:	75 ed                	jne    800a66 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a79:	89 f0                	mov    %esi,%eax
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a8d:	89 f0                	mov    %esi,%eax
  800a8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	75 0b                	jne    800aa2 <strlcpy+0x23>
  800a97:	eb 1d                	jmp    800ab6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a99:	83 c0 01             	add    $0x1,%eax
  800a9c:	83 c2 01             	add    $0x1,%edx
  800a9f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa2:	39 d8                	cmp    %ebx,%eax
  800aa4:	74 0b                	je     800ab1 <strlcpy+0x32>
  800aa6:	0f b6 0a             	movzbl (%edx),%ecx
  800aa9:	84 c9                	test   %cl,%cl
  800aab:	75 ec                	jne    800a99 <strlcpy+0x1a>
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	eb 02                	jmp    800ab3 <strlcpy+0x34>
  800ab1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ab3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ab6:	29 f0                	sub    %esi,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ac5:	eb 06                	jmp    800acd <strcmp+0x11>
		p++, q++;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800acd:	0f b6 01             	movzbl (%ecx),%eax
  800ad0:	84 c0                	test   %al,%al
  800ad2:	74 04                	je     800ad8 <strcmp+0x1c>
  800ad4:	3a 02                	cmp    (%edx),%al
  800ad6:	74 ef                	je     800ac7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	0f b6 c0             	movzbl %al,%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	53                   	push   %ebx
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800af1:	eb 06                	jmp    800af9 <strncmp+0x17>
		n--, p++, q++;
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af9:	39 d8                	cmp    %ebx,%eax
  800afb:	74 15                	je     800b12 <strncmp+0x30>
  800afd:	0f b6 08             	movzbl (%eax),%ecx
  800b00:	84 c9                	test   %cl,%cl
  800b02:	74 04                	je     800b08 <strncmp+0x26>
  800b04:	3a 0a                	cmp    (%edx),%cl
  800b06:	74 eb                	je     800af3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b08:	0f b6 00             	movzbl (%eax),%eax
  800b0b:	0f b6 12             	movzbl (%edx),%edx
  800b0e:	29 d0                	sub    %edx,%eax
  800b10:	eb 05                	jmp    800b17 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b24:	eb 07                	jmp    800b2d <strchr+0x13>
		if (*s == c)
  800b26:	38 ca                	cmp    %cl,%dl
  800b28:	74 0f                	je     800b39 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	0f b6 10             	movzbl (%eax),%edx
  800b30:	84 d2                	test   %dl,%dl
  800b32:	75 f2                	jne    800b26 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b45:	eb 07                	jmp    800b4e <strfind+0x13>
		if (*s == c)
  800b47:	38 ca                	cmp    %cl,%dl
  800b49:	74 0a                	je     800b55 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4b:	83 c0 01             	add    $0x1,%eax
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	84 d2                	test   %dl,%dl
  800b53:	75 f2                	jne    800b47 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b63:	85 c9                	test   %ecx,%ecx
  800b65:	74 36                	je     800b9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6d:	75 28                	jne    800b97 <memset+0x40>
  800b6f:	f6 c1 03             	test   $0x3,%cl
  800b72:	75 23                	jne    800b97 <memset+0x40>
		c &= 0xFF;
  800b74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	c1 e3 08             	shl    $0x8,%ebx
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	c1 e6 18             	shl    $0x18,%esi
  800b82:	89 d0                	mov    %edx,%eax
  800b84:	c1 e0 10             	shl    $0x10,%eax
  800b87:	09 f0                	or     %esi,%eax
  800b89:	09 c2                	or     %eax,%edx
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b92:	fc                   	cld    
  800b93:	f3 ab                	rep stos %eax,%es:(%edi)
  800b95:	eb 06                	jmp    800b9d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9a:	fc                   	cld    
  800b9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9d:	89 f8                	mov    %edi,%eax
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb2:	39 c6                	cmp    %eax,%esi
  800bb4:	73 35                	jae    800beb <memmove+0x47>
  800bb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	73 2e                	jae    800beb <memmove+0x47>
		s += n;
		d += n;
  800bbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bca:	75 13                	jne    800bdf <memmove+0x3b>
  800bcc:	f6 c1 03             	test   $0x3,%cl
  800bcf:	75 0e                	jne    800bdf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd1:	83 ef 04             	sub    $0x4,%edi
  800bd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bda:	fd                   	std    
  800bdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdd:	eb 09                	jmp    800be8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bdf:	83 ef 01             	sub    $0x1,%edi
  800be2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be5:	fd                   	std    
  800be6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be8:	fc                   	cld    
  800be9:	eb 1d                	jmp    800c08 <memmove+0x64>
  800beb:	89 f2                	mov    %esi,%edx
  800bed:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bef:	f6 c2 03             	test   $0x3,%dl
  800bf2:	75 0f                	jne    800c03 <memmove+0x5f>
  800bf4:	f6 c1 03             	test   $0x3,%cl
  800bf7:	75 0a                	jne    800c03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	fc                   	cld    
  800bff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c01:	eb 05                	jmp    800c08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	fc                   	cld    
  800c06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c12:	8b 45 10             	mov    0x10(%ebp),%eax
  800c15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	89 04 24             	mov    %eax,(%esp)
  800c26:	e8 79 ff ff ff       	call   800ba4 <memmove>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3d:	eb 1a                	jmp    800c59 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3f:	0f b6 02             	movzbl (%edx),%eax
  800c42:	0f b6 19             	movzbl (%ecx),%ebx
  800c45:	38 d8                	cmp    %bl,%al
  800c47:	74 0a                	je     800c53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c49:	0f b6 c0             	movzbl %al,%eax
  800c4c:	0f b6 db             	movzbl %bl,%ebx
  800c4f:	29 d8                	sub    %ebx,%eax
  800c51:	eb 0f                	jmp    800c62 <memcmp+0x35>
		s1++, s2++;
  800c53:	83 c2 01             	add    $0x1,%edx
  800c56:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c59:	39 f2                	cmp    %esi,%edx
  800c5b:	75 e2                	jne    800c3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6f:	89 c2                	mov    %eax,%edx
  800c71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c74:	eb 07                	jmp    800c7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c76:	38 08                	cmp    %cl,(%eax)
  800c78:	74 07                	je     800c81 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	39 d0                	cmp    %edx,%eax
  800c7f:	72 f5                	jb     800c76 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8f:	eb 03                	jmp    800c94 <strtol+0x11>
		s++;
  800c91:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c94:	0f b6 0a             	movzbl (%edx),%ecx
  800c97:	80 f9 09             	cmp    $0x9,%cl
  800c9a:	74 f5                	je     800c91 <strtol+0xe>
  800c9c:	80 f9 20             	cmp    $0x20,%cl
  800c9f:	74 f0                	je     800c91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca1:	80 f9 2b             	cmp    $0x2b,%cl
  800ca4:	75 0a                	jne    800cb0 <strtol+0x2d>
		s++;
  800ca6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cae:	eb 11                	jmp    800cc1 <strtol+0x3e>
  800cb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb5:	80 f9 2d             	cmp    $0x2d,%cl
  800cb8:	75 07                	jne    800cc1 <strtol+0x3e>
		s++, neg = 1;
  800cba:	8d 52 01             	lea    0x1(%edx),%edx
  800cbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800cc6:	75 15                	jne    800cdd <strtol+0x5a>
  800cc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800ccb:	75 10                	jne    800cdd <strtol+0x5a>
  800ccd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd1:	75 0a                	jne    800cdd <strtol+0x5a>
		s += 2, base = 16;
  800cd3:	83 c2 02             	add    $0x2,%edx
  800cd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800cdb:	eb 10                	jmp    800ced <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	75 0c                	jne    800ced <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ce6:	75 05                	jne    800ced <strtol+0x6a>
		s++, base = 8;
  800ce8:	83 c2 01             	add    $0x1,%edx
  800ceb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf5:	0f b6 0a             	movzbl (%edx),%ecx
  800cf8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800cfb:	89 f0                	mov    %esi,%eax
  800cfd:	3c 09                	cmp    $0x9,%al
  800cff:	77 08                	ja     800d09 <strtol+0x86>
			dig = *s - '0';
  800d01:	0f be c9             	movsbl %cl,%ecx
  800d04:	83 e9 30             	sub    $0x30,%ecx
  800d07:	eb 20                	jmp    800d29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d0c:	89 f0                	mov    %esi,%eax
  800d0e:	3c 19                	cmp    $0x19,%al
  800d10:	77 08                	ja     800d1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 57             	sub    $0x57,%ecx
  800d18:	eb 0f                	jmp    800d29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800d1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d1d:	89 f0                	mov    %esi,%eax
  800d1f:	3c 19                	cmp    $0x19,%al
  800d21:	77 16                	ja     800d39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d23:	0f be c9             	movsbl %cl,%ecx
  800d26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d2c:	7d 0f                	jge    800d3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800d2e:	83 c2 01             	add    $0x1,%edx
  800d31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d37:	eb bc                	jmp    800cf5 <strtol+0x72>
  800d39:	89 d8                	mov    %ebx,%eax
  800d3b:	eb 02                	jmp    800d3f <strtol+0xbc>
  800d3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d43:	74 05                	je     800d4a <strtol+0xc7>
		*endptr = (char *) s;
  800d45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d4a:	f7 d8                	neg    %eax
  800d4c:	85 ff                	test   %edi,%edi
  800d4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	89 c7                	mov    %eax,%edi
  800d6b:	89 c6                	mov    %eax,%esi
  800d6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da1:	b8 03 00 00 00       	mov    $0x3,%eax
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 cb                	mov    %ecx,%ebx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	89 ce                	mov    %ecx,%esi
  800daf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 28                	jle    800ddd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd0:	00 
  800dd1:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800dd8:	e8 ba f4 ff ff       	call   800297 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ddd:	83 c4 2c             	add    $0x2c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 02 00 00 00       	mov    $0x2,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_yield>:

void
sys_yield(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e14:	89 d1                	mov    %edx,%ecx
  800e16:	89 d3                	mov    %edx,%ebx
  800e18:	89 d7                	mov    %edx,%edi
  800e1a:	89 d6                	mov    %edx,%esi
  800e1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	be 00 00 00 00       	mov    $0x0,%esi
  800e31:	b8 04 00 00 00       	mov    $0x4,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	89 f7                	mov    %esi,%edi
  800e41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 28                	jle    800e6f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e52:	00 
  800e53:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e62:	00 
  800e63:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800e6a:	e8 28 f4 ff ff       	call   800297 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e6f:	83 c4 2c             	add    $0x2c,%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	b8 05 00 00 00       	mov    $0x5,%eax
  800e85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e91:	8b 75 18             	mov    0x18(%ebp),%esi
  800e94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 28                	jle    800ec2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800ead:	00 
  800eae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb5:	00 
  800eb6:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800ebd:	e8 d5 f3 ff ff       	call   800297 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec2:	83 c4 2c             	add    $0x2c,%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed8:	b8 06 00 00 00       	mov    $0x6,%eax
  800edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	89 df                	mov    %ebx,%edi
  800ee5:	89 de                	mov    %ebx,%esi
  800ee7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 28                	jle    800f15 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800f10:	e8 82 f3 ff ff       	call   800297 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f15:	83 c4 2c             	add    $0x2c,%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	89 df                	mov    %ebx,%edi
  800f38:	89 de                	mov    %ebx,%esi
  800f3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	7e 28                	jle    800f68 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f44:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800f53:	00 
  800f54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5b:	00 
  800f5c:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800f63:	e8 2f f3 ff ff       	call   800297 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f68:	83 c4 2c             	add    $0x2c,%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 df                	mov    %ebx,%edi
  800f8b:	89 de                	mov    %ebx,%esi
  800f8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	7e 28                	jle    800fbb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f97:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  800fa6:	00 
  800fa7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fae:	00 
  800faf:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  800fb6:	e8 dc f2 ff ff       	call   800297 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fbb:	83 c4 2c             	add    $0x2c,%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc9:	be 00 00 00 00       	mov    $0x0,%esi
  800fce:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fdf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	89 cb                	mov    %ecx,%ebx
  800ffe:	89 cf                	mov    %ecx,%edi
  801000:	89 ce                	mov    %ecx,%esi
  801002:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	7e 28                	jle    801030 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801008:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801013:	00 
  801014:	c7 44 24 08 e8 15 80 	movl   $0x8015e8,0x8(%esp)
  80101b:	00 
  80101c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801023:	00 
  801024:	c7 04 24 05 16 80 00 	movl   $0x801605,(%esp)
  80102b:	e8 67 f2 ff ff       	call   800297 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801030:	83 c4 2c             	add    $0x2c,%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    
  801038:	66 90                	xchg   %ax,%ax
  80103a:	66 90                	xchg   %ax,%ax
  80103c:	66 90                	xchg   %ax,%ax
  80103e:	66 90                	xchg   %ax,%ax

00801040 <__udivdi3>:
  801040:	55                   	push   %ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	8b 44 24 28          	mov    0x28(%esp),%eax
  80104a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80104e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801052:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801056:	85 c0                	test   %eax,%eax
  801058:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80105c:	89 ea                	mov    %ebp,%edx
  80105e:	89 0c 24             	mov    %ecx,(%esp)
  801061:	75 2d                	jne    801090 <__udivdi3+0x50>
  801063:	39 e9                	cmp    %ebp,%ecx
  801065:	77 61                	ja     8010c8 <__udivdi3+0x88>
  801067:	85 c9                	test   %ecx,%ecx
  801069:	89 ce                	mov    %ecx,%esi
  80106b:	75 0b                	jne    801078 <__udivdi3+0x38>
  80106d:	b8 01 00 00 00       	mov    $0x1,%eax
  801072:	31 d2                	xor    %edx,%edx
  801074:	f7 f1                	div    %ecx
  801076:	89 c6                	mov    %eax,%esi
  801078:	31 d2                	xor    %edx,%edx
  80107a:	89 e8                	mov    %ebp,%eax
  80107c:	f7 f6                	div    %esi
  80107e:	89 c5                	mov    %eax,%ebp
  801080:	89 f8                	mov    %edi,%eax
  801082:	f7 f6                	div    %esi
  801084:	89 ea                	mov    %ebp,%edx
  801086:	83 c4 0c             	add    $0xc,%esp
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	39 e8                	cmp    %ebp,%eax
  801092:	77 24                	ja     8010b8 <__udivdi3+0x78>
  801094:	0f bd e8             	bsr    %eax,%ebp
  801097:	83 f5 1f             	xor    $0x1f,%ebp
  80109a:	75 3c                	jne    8010d8 <__udivdi3+0x98>
  80109c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010a0:	39 34 24             	cmp    %esi,(%esp)
  8010a3:	0f 86 9f 00 00 00    	jbe    801148 <__udivdi3+0x108>
  8010a9:	39 d0                	cmp    %edx,%eax
  8010ab:	0f 82 97 00 00 00    	jb     801148 <__udivdi3+0x108>
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	31 d2                	xor    %edx,%edx
  8010ba:	31 c0                	xor    %eax,%eax
  8010bc:	83 c4 0c             	add    $0xc,%esp
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	89 f8                	mov    %edi,%eax
  8010ca:	f7 f1                	div    %ecx
  8010cc:	31 d2                	xor    %edx,%edx
  8010ce:	83 c4 0c             	add    $0xc,%esp
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    
  8010d5:	8d 76 00             	lea    0x0(%esi),%esi
  8010d8:	89 e9                	mov    %ebp,%ecx
  8010da:	8b 3c 24             	mov    (%esp),%edi
  8010dd:	d3 e0                	shl    %cl,%eax
  8010df:	89 c6                	mov    %eax,%esi
  8010e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8010e6:	29 e8                	sub    %ebp,%eax
  8010e8:	89 c1                	mov    %eax,%ecx
  8010ea:	d3 ef                	shr    %cl,%edi
  8010ec:	89 e9                	mov    %ebp,%ecx
  8010ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010f2:	8b 3c 24             	mov    (%esp),%edi
  8010f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8010f9:	89 d6                	mov    %edx,%esi
  8010fb:	d3 e7                	shl    %cl,%edi
  8010fd:	89 c1                	mov    %eax,%ecx
  8010ff:	89 3c 24             	mov    %edi,(%esp)
  801102:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801106:	d3 ee                	shr    %cl,%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	d3 e2                	shl    %cl,%edx
  80110c:	89 c1                	mov    %eax,%ecx
  80110e:	d3 ef                	shr    %cl,%edi
  801110:	09 d7                	or     %edx,%edi
  801112:	89 f2                	mov    %esi,%edx
  801114:	89 f8                	mov    %edi,%eax
  801116:	f7 74 24 08          	divl   0x8(%esp)
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	89 c7                	mov    %eax,%edi
  80111e:	f7 24 24             	mull   (%esp)
  801121:	39 d6                	cmp    %edx,%esi
  801123:	89 14 24             	mov    %edx,(%esp)
  801126:	72 30                	jb     801158 <__udivdi3+0x118>
  801128:	8b 54 24 04          	mov    0x4(%esp),%edx
  80112c:	89 e9                	mov    %ebp,%ecx
  80112e:	d3 e2                	shl    %cl,%edx
  801130:	39 c2                	cmp    %eax,%edx
  801132:	73 05                	jae    801139 <__udivdi3+0xf9>
  801134:	3b 34 24             	cmp    (%esp),%esi
  801137:	74 1f                	je     801158 <__udivdi3+0x118>
  801139:	89 f8                	mov    %edi,%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	e9 7a ff ff ff       	jmp    8010bc <__udivdi3+0x7c>
  801142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801148:	31 d2                	xor    %edx,%edx
  80114a:	b8 01 00 00 00       	mov    $0x1,%eax
  80114f:	e9 68 ff ff ff       	jmp    8010bc <__udivdi3+0x7c>
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	8d 47 ff             	lea    -0x1(%edi),%eax
  80115b:	31 d2                	xor    %edx,%edx
  80115d:	83 c4 0c             	add    $0xc,%esp
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    
  801164:	66 90                	xchg   %ax,%ax
  801166:	66 90                	xchg   %ax,%ax
  801168:	66 90                	xchg   %ax,%ax
  80116a:	66 90                	xchg   %ax,%ax
  80116c:	66 90                	xchg   %ax,%ax
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__umoddi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	83 ec 14             	sub    $0x14,%esp
  801176:	8b 44 24 28          	mov    0x28(%esp),%eax
  80117a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80117e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801182:	89 c7                	mov    %eax,%edi
  801184:	89 44 24 04          	mov    %eax,0x4(%esp)
  801188:	8b 44 24 30          	mov    0x30(%esp),%eax
  80118c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801190:	89 34 24             	mov    %esi,(%esp)
  801193:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801197:	85 c0                	test   %eax,%eax
  801199:	89 c2                	mov    %eax,%edx
  80119b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80119f:	75 17                	jne    8011b8 <__umoddi3+0x48>
  8011a1:	39 fe                	cmp    %edi,%esi
  8011a3:	76 4b                	jbe    8011f0 <__umoddi3+0x80>
  8011a5:	89 c8                	mov    %ecx,%eax
  8011a7:	89 fa                	mov    %edi,%edx
  8011a9:	f7 f6                	div    %esi
  8011ab:	89 d0                	mov    %edx,%eax
  8011ad:	31 d2                	xor    %edx,%edx
  8011af:	83 c4 14             	add    $0x14,%esp
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    
  8011b6:	66 90                	xchg   %ax,%ax
  8011b8:	39 f8                	cmp    %edi,%eax
  8011ba:	77 54                	ja     801210 <__umoddi3+0xa0>
  8011bc:	0f bd e8             	bsr    %eax,%ebp
  8011bf:	83 f5 1f             	xor    $0x1f,%ebp
  8011c2:	75 5c                	jne    801220 <__umoddi3+0xb0>
  8011c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011c8:	39 3c 24             	cmp    %edi,(%esp)
  8011cb:	0f 87 e7 00 00 00    	ja     8012b8 <__umoddi3+0x148>
  8011d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8011d5:	29 f1                	sub    %esi,%ecx
  8011d7:	19 c7                	sbb    %eax,%edi
  8011d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011e9:	83 c4 14             	add    $0x14,%esp
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    
  8011f0:	85 f6                	test   %esi,%esi
  8011f2:	89 f5                	mov    %esi,%ebp
  8011f4:	75 0b                	jne    801201 <__umoddi3+0x91>
  8011f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011fb:	31 d2                	xor    %edx,%edx
  8011fd:	f7 f6                	div    %esi
  8011ff:	89 c5                	mov    %eax,%ebp
  801201:	8b 44 24 04          	mov    0x4(%esp),%eax
  801205:	31 d2                	xor    %edx,%edx
  801207:	f7 f5                	div    %ebp
  801209:	89 c8                	mov    %ecx,%eax
  80120b:	f7 f5                	div    %ebp
  80120d:	eb 9c                	jmp    8011ab <__umoddi3+0x3b>
  80120f:	90                   	nop
  801210:	89 c8                	mov    %ecx,%eax
  801212:	89 fa                	mov    %edi,%edx
  801214:	83 c4 14             	add    $0x14,%esp
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
  80121b:	90                   	nop
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	8b 04 24             	mov    (%esp),%eax
  801223:	be 20 00 00 00       	mov    $0x20,%esi
  801228:	89 e9                	mov    %ebp,%ecx
  80122a:	29 ee                	sub    %ebp,%esi
  80122c:	d3 e2                	shl    %cl,%edx
  80122e:	89 f1                	mov    %esi,%ecx
  801230:	d3 e8                	shr    %cl,%eax
  801232:	89 e9                	mov    %ebp,%ecx
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	8b 04 24             	mov    (%esp),%eax
  80123b:	09 54 24 04          	or     %edx,0x4(%esp)
  80123f:	89 fa                	mov    %edi,%edx
  801241:	d3 e0                	shl    %cl,%eax
  801243:	89 f1                	mov    %esi,%ecx
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	8b 44 24 10          	mov    0x10(%esp),%eax
  80124d:	d3 ea                	shr    %cl,%edx
  80124f:	89 e9                	mov    %ebp,%ecx
  801251:	d3 e7                	shl    %cl,%edi
  801253:	89 f1                	mov    %esi,%ecx
  801255:	d3 e8                	shr    %cl,%eax
  801257:	89 e9                	mov    %ebp,%ecx
  801259:	09 f8                	or     %edi,%eax
  80125b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80125f:	f7 74 24 04          	divl   0x4(%esp)
  801263:	d3 e7                	shl    %cl,%edi
  801265:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801269:	89 d7                	mov    %edx,%edi
  80126b:	f7 64 24 08          	mull   0x8(%esp)
  80126f:	39 d7                	cmp    %edx,%edi
  801271:	89 c1                	mov    %eax,%ecx
  801273:	89 14 24             	mov    %edx,(%esp)
  801276:	72 2c                	jb     8012a4 <__umoddi3+0x134>
  801278:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80127c:	72 22                	jb     8012a0 <__umoddi3+0x130>
  80127e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801282:	29 c8                	sub    %ecx,%eax
  801284:	19 d7                	sbb    %edx,%edi
  801286:	89 e9                	mov    %ebp,%ecx
  801288:	89 fa                	mov    %edi,%edx
  80128a:	d3 e8                	shr    %cl,%eax
  80128c:	89 f1                	mov    %esi,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	89 e9                	mov    %ebp,%ecx
  801292:	d3 ef                	shr    %cl,%edi
  801294:	09 d0                	or     %edx,%eax
  801296:	89 fa                	mov    %edi,%edx
  801298:	83 c4 14             	add    $0x14,%esp
  80129b:	5e                   	pop    %esi
  80129c:	5f                   	pop    %edi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    
  80129f:	90                   	nop
  8012a0:	39 d7                	cmp    %edx,%edi
  8012a2:	75 da                	jne    80127e <__umoddi3+0x10e>
  8012a4:	8b 14 24             	mov    (%esp),%edx
  8012a7:	89 c1                	mov    %eax,%ecx
  8012a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8012ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8012b1:	eb cb                	jmp    80127e <__umoddi3+0x10e>
  8012b3:	90                   	nop
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8012bc:	0f 82 0f ff ff ff    	jb     8011d1 <__umoddi3+0x61>
  8012c2:	e9 1a ff ff ff       	jmp    8011e1 <__umoddi3+0x71>
