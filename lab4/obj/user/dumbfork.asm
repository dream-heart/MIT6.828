
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 0f 02 00 00       	call   800240 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 dd 0d 00 00       	call   800e33 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 13 80 	movl   $0x801300,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  800075:	e8 29 02 00 00       	call   8002a3 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 e9 0d 00 00       	call   800e87 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 13 80 	movl   $0x801323,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  8000bd:	e8 e1 01 00 00       	call   8002a3 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 da 0a 00 00       	call   800bb4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 ec 0d 00 00       	call   800eda <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 13 80 	movl   $0x801334,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  80010d:	e8 91 01 00 00       	call   8002a3 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 47 13 80 	movl   $0x801347,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  80014d:	e8 51 01 00 00       	call   8002a3 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 19                	jne    80016f <dumbfork+0x56>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 9a 0c 00 00       	call   800df5 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016d:	eb 6e                	jmp    8001dd <dumbfork+0xc4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800176:	eb 13                	jmp    80018b <dumbfork+0x72>
		duppage(envid, addr);
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 b0 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800184:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80018b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80018e:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800193:	72 e3                	jb     800178 <dumbfork+0x5f>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 8b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001a9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b0:	00 
  8001b1:	89 34 24             	mov    %esi,(%esp)
  8001b4:	e8 74 0d 00 00       	call   800f2d <sys_env_set_status>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <dumbfork+0xc4>
		panic("sys_env_set_status: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 57 13 80 	movl   $0x801357,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 13 13 80 00 	movl   $0x801313,(%esp)
  8001d8:	e8 c6 00 00 00       	call   8002a3 <_panic>

	return envid;
}
  8001dd:	89 f0                	mov    %esi,%eax
  8001df:	83 c4 20             	add    $0x20,%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	57                   	push   %edi
  8001ea:	56                   	push   %esi
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001ef:	e8 25 ff ff ff       	call   800119 <dumbfork>
  8001f4:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001f6:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001fb:	bf 75 13 80 00       	mov    $0x801375,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800200:	eb 26                	jmp    800228 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800202:	85 db                	test   %ebx,%ebx
  800204:	b8 6e 13 80 00       	mov    $0x80136e,%eax
  800209:	0f 44 c7             	cmove  %edi,%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	c7 04 24 7b 13 80 00 	movl   $0x80137b,(%esp)
  80021b:	e8 7c 01 00 00       	call   80039c <cprintf>
		sys_yield();
  800220:	e8 ef 0b 00 00       	call   800e14 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800225:	83 c6 01             	add    $0x1,%esi
  800228:	83 fb 01             	cmp    $0x1,%ebx
  80022b:	19 c0                	sbb    %eax,%eax
  80022d:	83 e0 0a             	and    $0xa,%eax
  800230:	83 c0 0a             	add    $0xa,%eax
  800233:	39 c6                	cmp    %eax,%esi
  800235:	7c cb                	jl     800202 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800237:	83 c4 1c             	add    $0x1c,%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    
	...

00800240 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 18             	sub    $0x18,%esp
  800246:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800249:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80024c:	8b 75 08             	mov    0x8(%ebp),%esi
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800252:	e8 9e 0b 00 00       	call   800df5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800257:	25 ff 03 00 00       	and    $0x3ff,%eax
  80025c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80025f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800264:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800269:	85 f6                	test   %esi,%esi
  80026b:	7e 07                	jle    800274 <libmain+0x34>
		binaryname = argv[0];
  80026d:	8b 03                	mov    (%ebx),%eax
  80026f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800274:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800278:	89 34 24             	mov    %esi,(%esp)
  80027b:	e8 66 ff ff ff       	call   8001e6 <umain>

	// exit gracefully
	exit();
  800280:	e8 0a 00 00 00       	call   80028f <exit>
}
  800285:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800288:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80028b:	89 ec                	mov    %ebp,%esp
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800295:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80029c:	e8 02 0b 00 00       	call   800da3 <sys_env_destroy>
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ae:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002b4:	e8 3c 0b 00 00       	call   800df5 <sys_getenvid>
  8002b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  8002d6:	e8 c1 00 00 00       	call   80039c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002df:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	e8 51 00 00 00       	call   80033b <vcprintf>
	cprintf("\n");
  8002ea:	c7 04 24 8b 13 80 00 	movl   $0x80138b,(%esp)
  8002f1:	e8 a6 00 00 00       	call   80039c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f6:	cc                   	int3   
  8002f7:	eb fd                	jmp    8002f6 <_panic+0x53>

008002f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 14             	sub    $0x14,%esp
  800300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800303:	8b 13                	mov    (%ebx),%edx
  800305:	8d 42 01             	lea    0x1(%edx),%eax
  800308:	89 03                	mov    %eax,(%ebx)
  80030a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800311:	3d ff 00 00 00       	cmp    $0xff,%eax
  800316:	75 19                	jne    800331 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800318:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031f:	00 
  800320:	8d 43 08             	lea    0x8(%ebx),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	e8 3b 0a 00 00       	call   800d66 <sys_cputs>
		b->idx = 0;
  80032b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800331:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800335:	83 c4 14             	add    $0x14,%esp
  800338:	5b                   	pop    %ebx
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800344:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034b:	00 00 00 
	b.cnt = 0;
  80034e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800355:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	89 44 24 08          	mov    %eax,0x8(%esp)
  800366:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800370:	c7 04 24 f9 02 80 00 	movl   $0x8002f9,(%esp)
  800377:	e8 78 01 00 00       	call   8004f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800382:	89 44 24 04          	mov    %eax,0x4(%esp)
  800386:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 d2 09 00 00       	call   800d66 <sys_cputs>

	return b.cnt;
}
  800394:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 87 ff ff ff       	call   80033b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    
	...

008003c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 3c             	sub    $0x3c,%esp
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	89 d7                	mov    %edx,%edi
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d7:	89 c3                	mov    %eax,%ebx
  8003d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8003dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003ed:	39 d9                	cmp    %ebx,%ecx
  8003ef:	72 05                	jb     8003f6 <printnum+0x36>
  8003f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8003f4:	77 69                	ja     80045f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003fd:	83 ee 01             	sub    $0x1,%esi
  800400:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 44 24 08          	mov    0x8(%esp),%eax
  80040c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800410:	89 c3                	mov    %eax,%ebx
  800412:	89 d6                	mov    %edx,%esi
  800414:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800417:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80041a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80041e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	e8 1c 0c 00 00       	call   801050 <__udivdi3>
  800434:	89 d9                	mov    %ebx,%ecx
  800436:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80043a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	89 54 24 04          	mov    %edx,0x4(%esp)
  800445:	89 fa                	mov    %edi,%edx
  800447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044a:	e8 71 ff ff ff       	call   8003c0 <printnum>
  80044f:	eb 1b                	jmp    80046c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800455:	8b 45 18             	mov    0x18(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	ff d3                	call   *%ebx
  80045d:	eb 03                	jmp    800462 <printnum+0xa2>
  80045f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800462:	83 ee 01             	sub    $0x1,%esi
  800465:	85 f6                	test   %esi,%esi
  800467:	7f e8                	jg     800451 <printnum+0x91>
  800469:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800470:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800474:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800477:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80047a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80048b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048f:	e8 ec 0c 00 00       	call   801180 <__umoddi3>
  800494:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800498:	0f be 80 bc 13 80 00 	movsbl 0x8013bc(%eax),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a5:	ff d0                	call   *%eax
}
  8004a7:	83 c4 3c             	add    $0x3c,%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8004be:	73 0a                	jae    8004ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	88 02                	mov    %al,(%edx)
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	e8 02 00 00 00       	call   8004f4 <vprintfmt>
	va_end(ap);
}
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 3c             	sub    $0x3c,%esp
  8004fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800500:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800503:	8b 7d 10             	mov    0x10(%ebp),%edi
  800506:	eb 11                	jmp    800519 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800508:	85 c0                	test   %eax,%eax
  80050a:	0f 84 48 04 00 00    	je     800958 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800519:	83 c7 01             	add    $0x1,%edi
  80051c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800520:	83 f8 25             	cmp    $0x25,%eax
  800523:	75 e3                	jne    800508 <vprintfmt+0x14>
  800525:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800529:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800530:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800537:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80053e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800543:	eb 1f                	jmp    800564 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800548:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80054c:	eb 16                	jmp    800564 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800551:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800555:	eb 0d                	jmp    800564 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800557:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8d 47 01             	lea    0x1(%edi),%eax
  800567:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056a:	0f b6 17             	movzbl (%edi),%edx
  80056d:	0f b6 c2             	movzbl %dl,%eax
  800570:	83 ea 23             	sub    $0x23,%edx
  800573:	80 fa 55             	cmp    $0x55,%dl
  800576:	0f 87 bf 03 00 00    	ja     80093b <vprintfmt+0x447>
  80057c:	0f b6 d2             	movzbl %dl,%edx
  80057f:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800591:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800594:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800598:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80059b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80059e:	83 f9 09             	cmp    $0x9,%ecx
  8005a1:	77 3c                	ja     8005df <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a6:	eb e9                	jmp    800591 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005bc:	eb 27                	jmp    8005e5 <vprintfmt+0xf1>
  8005be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c2             	cmovns %edx,%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d1:	eb 91                	jmp    800564 <vprintfmt+0x70>
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005dd:	eb 85                	jmp    800564 <vprintfmt+0x70>
  8005df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e9:	0f 89 75 ff ff ff    	jns    800564 <vprintfmt+0x70>
  8005ef:	e9 63 ff ff ff       	jmp    800557 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fa:	e9 65 ff ff ff       	jmp    800564 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800602:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 04 24             	mov    %eax,(%esp)
  80060f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800614:	e9 00 ff ff ff       	jmp    800519 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	99                   	cltd   
  800623:	31 d0                	xor    %edx,%eax
  800625:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800627:	83 f8 09             	cmp    $0x9,%eax
  80062a:	7f 0b                	jg     800637 <vprintfmt+0x143>
  80062c:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800633:	85 d2                	test   %edx,%edx
  800635:	75 20                	jne    800657 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800637:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063b:	c7 44 24 08 d4 13 80 	movl   $0x8013d4,0x8(%esp)
  800642:	00 
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	89 34 24             	mov    %esi,(%esp)
  80064a:	e8 7d fe ff ff       	call   8004cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800652:	e9 c2 fe ff ff       	jmp    800519 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	c7 44 24 08 dd 13 80 	movl   $0x8013dd,0x8(%esp)
  800662:	00 
  800663:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800667:	89 34 24             	mov    %esi,(%esp)
  80066a:	e8 5d fe ff ff       	call   8004cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800672:	e9 a2 fe ff ff       	jmp    800519 <vprintfmt+0x25>
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80067d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800680:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800687:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800689:	85 ff                	test   %edi,%edi
  80068b:	b8 cd 13 80 00       	mov    $0x8013cd,%eax
  800690:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800693:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800697:	0f 84 92 00 00 00    	je     80072f <vprintfmt+0x23b>
  80069d:	85 c9                	test   %ecx,%ecx
  80069f:	0f 8e 98 00 00 00    	jle    80073d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a9:	89 3c 24             	mov    %edi,(%esp)
  8006ac:	e8 47 03 00 00       	call   8009f8 <strnlen>
  8006b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b4:	29 c1                	sub    %eax,%ecx
  8006b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8006b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	eb 0f                	jmp    8006d6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ce:	89 04 24             	mov    %eax,(%esp)
  8006d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	83 ef 01             	sub    $0x1,%edi
  8006d6:	85 ff                	test   %edi,%edi
  8006d8:	7f ed                	jg     8006c7 <vprintfmt+0x1d3>
  8006da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	0f 49 c1             	cmovns %ecx,%eax
  8006ea:	29 c1                	sub    %eax,%ecx
  8006ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f5:	89 cb                	mov    %ecx,%ebx
  8006f7:	eb 50                	jmp    800749 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fd:	74 1e                	je     80071d <vprintfmt+0x229>
  8006ff:	0f be d2             	movsbl %dl,%edx
  800702:	83 ea 20             	sub    $0x20,%edx
  800705:	83 fa 5e             	cmp    $0x5e,%edx
  800708:	76 13                	jbe    80071d <vprintfmt+0x229>
					putch('?', putdat);
  80070a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800718:	ff 55 08             	call   *0x8(%ebp)
  80071b:	eb 0d                	jmp    80072a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800720:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072a:	83 eb 01             	sub    $0x1,%ebx
  80072d:	eb 1a                	jmp    800749 <vprintfmt+0x255>
  80072f:	89 75 08             	mov    %esi,0x8(%ebp)
  800732:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800735:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800738:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073b:	eb 0c                	jmp    800749 <vprintfmt+0x255>
  80073d:	89 75 08             	mov    %esi,0x8(%ebp)
  800740:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800743:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800746:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800749:	83 c7 01             	add    $0x1,%edi
  80074c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800750:	0f be c2             	movsbl %dl,%eax
  800753:	85 c0                	test   %eax,%eax
  800755:	74 25                	je     80077c <vprintfmt+0x288>
  800757:	85 f6                	test   %esi,%esi
  800759:	78 9e                	js     8006f9 <vprintfmt+0x205>
  80075b:	83 ee 01             	sub    $0x1,%esi
  80075e:	79 99                	jns    8006f9 <vprintfmt+0x205>
  800760:	89 df                	mov    %ebx,%edi
  800762:	8b 75 08             	mov    0x8(%ebp),%esi
  800765:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800775:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800777:	83 ef 01             	sub    $0x1,%edi
  80077a:	eb 08                	jmp    800784 <vprintfmt+0x290>
  80077c:	89 df                	mov    %ebx,%edi
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800784:	85 ff                	test   %edi,%edi
  800786:	7f e2                	jg     80076a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078b:	e9 89 fd ff ff       	jmp    800519 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800790:	83 f9 01             	cmp    $0x1,%ecx
  800793:	7e 19                	jle    8007ae <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 50 04             	mov    0x4(%eax),%edx
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 40 08             	lea    0x8(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ac:	eb 38                	jmp    8007e6 <vprintfmt+0x2f2>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1b                	je     8007cd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	89 c1                	mov    %eax,%ecx
  8007bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 40 04             	lea    0x4(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cb:	eb 19                	jmp    8007e6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ec:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f5:	0f 89 04 01 00 00    	jns    8008ff <vprintfmt+0x40b>
				putch('-', putdat);
  8007fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800806:	ff d6                	call   *%esi
				num = -(long long) num;
  800808:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80080e:	f7 da                	neg    %edx
  800810:	83 d1 00             	adc    $0x0,%ecx
  800813:	f7 d9                	neg    %ecx
  800815:	e9 e5 00 00 00       	jmp    8008ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081a:	83 f9 01             	cmp    $0x1,%ecx
  80081d:	7e 10                	jle    80082f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8b 48 04             	mov    0x4(%eax),%ecx
  800827:	8d 40 08             	lea    0x8(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
  80082d:	eb 26                	jmp    800855 <vprintfmt+0x361>
	else if (lflag)
  80082f:	85 c9                	test   %ecx,%ecx
  800831:	74 12                	je     800845 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
  800843:	eb 10                	jmp    800855 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084f:	8d 40 04             	lea    0x4(%eax),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800855:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80085a:	e9 a0 00 00 00       	jmp    8008ff <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80085f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800863:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80086a:	ff d6                	call   *%esi
			putch('X', putdat);
  80086c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800870:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800877:	ff d6                	call   *%esi
			putch('X', putdat);
  800879:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800884:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800889:	e9 8b fc ff ff       	jmp    800519 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80088e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800892:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800899:	ff d6                	call   *%esi
			putch('x', putdat);
  80089b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 10                	mov    (%eax),%edx
  8008ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8008b2:	8d 40 04             	lea    0x4(%eax),%eax
  8008b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8008bd:	eb 40                	jmp    8008ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008bf:	83 f9 01             	cmp    $0x1,%ecx
  8008c2:	7e 10                	jle    8008d4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8b 10                	mov    (%eax),%edx
  8008c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008cc:	8d 40 08             	lea    0x8(%eax),%eax
  8008cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d2:	eb 26                	jmp    8008fa <vprintfmt+0x406>
	else if (lflag)
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 12                	je     8008ea <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8b 10                	mov    (%eax),%edx
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e2:	8d 40 04             	lea    0x4(%eax),%eax
  8008e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008e8:	eb 10                	jmp    8008fa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8b 10                	mov    (%eax),%edx
  8008ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f4:	8d 40 04             	lea    0x4(%eax),%eax
  8008f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008fa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800903:	89 44 24 10          	mov    %eax,0x10(%esp)
  800907:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800912:	89 14 24             	mov    %edx,(%esp)
  800915:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800919:	89 da                	mov    %ebx,%edx
  80091b:	89 f0                	mov    %esi,%eax
  80091d:	e8 9e fa ff ff       	call   8003c0 <printnum>
			break;
  800922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800925:	e9 ef fb ff ff       	jmp    800519 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800936:	e9 de fb ff ff       	jmp    800519 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80093b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800946:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800948:	eb 03                	jmp    80094d <vprintfmt+0x459>
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800951:	75 f7                	jne    80094a <vprintfmt+0x456>
  800953:	e9 c1 fb ff ff       	jmp    800519 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800958:	83 c4 3c             	add    $0x3c,%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 28             	sub    $0x28,%esp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80096c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800973:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800976:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80097d:	85 c0                	test   %eax,%eax
  80097f:	74 30                	je     8009b1 <vsnprintf+0x51>
  800981:	85 d2                	test   %edx,%edx
  800983:	7e 2c                	jle    8009b1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098c:	8b 45 10             	mov    0x10(%ebp),%eax
  80098f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800993:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099a:	c7 04 24 af 04 80 00 	movl   $0x8004af,(%esp)
  8009a1:	e8 4e fb ff ff       	call   8004f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009af:	eb 05                	jmp    8009b6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 82 ff ff ff       	call   800960 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 03                	jmp    8009f0 <strlen+0x10>
		n++;
  8009ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f4:	75 f7                	jne    8009ed <strlen+0xd>
		n++;
	return n;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	eb 03                	jmp    800a0b <strnlen+0x13>
		n++;
  800a08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0b:	39 d0                	cmp    %edx,%eax
  800a0d:	74 06                	je     800a15 <strnlen+0x1d>
  800a0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a13:	75 f3                	jne    800a08 <strnlen+0x10>
		n++;
	return n;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a21:	89 c2                	mov    %eax,%edx
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a30:	84 db                	test   %bl,%bl
  800a32:	75 ef                	jne    800a23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a34:	5b                   	pop    %ebx
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a41:	89 1c 24             	mov    %ebx,(%esp)
  800a44:	e8 97 ff ff ff       	call   8009e0 <strlen>
	strcpy(dst + len, src);
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a50:	01 d8                	add    %ebx,%eax
  800a52:	89 04 24             	mov    %eax,(%esp)
  800a55:	e8 bd ff ff ff       	call   800a17 <strcpy>
	return dst;
}
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	83 c4 08             	add    $0x8,%esp
  800a5f:	5b                   	pop    %ebx
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a72:	89 f2                	mov    %esi,%edx
  800a74:	eb 0f                	jmp    800a85 <strncpy+0x23>
		*dst++ = *src;
  800a76:	83 c2 01             	add    $0x1,%edx
  800a79:	0f b6 01             	movzbl (%ecx),%eax
  800a7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a85:	39 da                	cmp    %ebx,%edx
  800a87:	75 ed                	jne    800a76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a89:	89 f0                	mov    %esi,%eax
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 75 08             	mov    0x8(%ebp),%esi
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a9d:	89 f0                	mov    %esi,%eax
  800a9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa3:	85 c9                	test   %ecx,%ecx
  800aa5:	75 0b                	jne    800ab2 <strlcpy+0x23>
  800aa7:	eb 1d                	jmp    800ac6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
  800aaf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab2:	39 d8                	cmp    %ebx,%eax
  800ab4:	74 0b                	je     800ac1 <strlcpy+0x32>
  800ab6:	0f b6 0a             	movzbl (%edx),%ecx
  800ab9:	84 c9                	test   %cl,%cl
  800abb:	75 ec                	jne    800aa9 <strlcpy+0x1a>
  800abd:	89 c2                	mov    %eax,%edx
  800abf:	eb 02                	jmp    800ac3 <strlcpy+0x34>
  800ac1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ac3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ac6:	29 f0                	sub    %esi,%eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad5:	eb 06                	jmp    800add <strcmp+0x11>
		p++, q++;
  800ad7:	83 c1 01             	add    $0x1,%ecx
  800ada:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800add:	0f b6 01             	movzbl (%ecx),%eax
  800ae0:	84 c0                	test   %al,%al
  800ae2:	74 04                	je     800ae8 <strcmp+0x1c>
  800ae4:	3a 02                	cmp    (%edx),%al
  800ae6:	74 ef                	je     800ad7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae8:	0f b6 c0             	movzbl %al,%eax
  800aeb:	0f b6 12             	movzbl (%edx),%edx
  800aee:	29 d0                	sub    %edx,%eax
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	53                   	push   %ebx
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b01:	eb 06                	jmp    800b09 <strncmp+0x17>
		n--, p++, q++;
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b09:	39 d8                	cmp    %ebx,%eax
  800b0b:	74 15                	je     800b22 <strncmp+0x30>
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	84 c9                	test   %cl,%cl
  800b12:	74 04                	je     800b18 <strncmp+0x26>
  800b14:	3a 0a                	cmp    (%edx),%cl
  800b16:	74 eb                	je     800b03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b18:	0f b6 00             	movzbl (%eax),%eax
  800b1b:	0f b6 12             	movzbl (%edx),%edx
  800b1e:	29 d0                	sub    %edx,%eax
  800b20:	eb 05                	jmp    800b27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b34:	eb 07                	jmp    800b3d <strchr+0x13>
		if (*s == c)
  800b36:	38 ca                	cmp    %cl,%dl
  800b38:	74 0f                	je     800b49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	0f b6 10             	movzbl (%eax),%edx
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 f2                	jne    800b36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	eb 07                	jmp    800b5e <strfind+0x13>
		if (*s == c)
  800b57:	38 ca                	cmp    %cl,%dl
  800b59:	74 0a                	je     800b65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b5b:	83 c0 01             	add    $0x1,%eax
  800b5e:	0f b6 10             	movzbl (%eax),%edx
  800b61:	84 d2                	test   %dl,%dl
  800b63:	75 f2                	jne    800b57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	74 36                	je     800bad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7d:	75 28                	jne    800ba7 <memset+0x40>
  800b7f:	f6 c1 03             	test   $0x3,%cl
  800b82:	75 23                	jne    800ba7 <memset+0x40>
		c &= 0xFF;
  800b84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	c1 e3 08             	shl    $0x8,%ebx
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	c1 e6 18             	shl    $0x18,%esi
  800b92:	89 d0                	mov    %edx,%eax
  800b94:	c1 e0 10             	shl    $0x10,%eax
  800b97:	09 f0                	or     %esi,%eax
  800b99:	09 c2                	or     %eax,%edx
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba2:	fc                   	cld    
  800ba3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba5:	eb 06                	jmp    800bad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc2:	39 c6                	cmp    %eax,%esi
  800bc4:	73 35                	jae    800bfb <memmove+0x47>
  800bc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 2e                	jae    800bfb <memmove+0x47>
		s += n;
		d += n;
  800bcd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bda:	75 13                	jne    800bef <memmove+0x3b>
  800bdc:	f6 c1 03             	test   $0x3,%cl
  800bdf:	75 0e                	jne    800bef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be1:	83 ef 04             	sub    $0x4,%edi
  800be4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bea:	fd                   	std    
  800beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bed:	eb 09                	jmp    800bf8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bef:	83 ef 01             	sub    $0x1,%edi
  800bf2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf5:	fd                   	std    
  800bf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf8:	fc                   	cld    
  800bf9:	eb 1d                	jmp    800c18 <memmove+0x64>
  800bfb:	89 f2                	mov    %esi,%edx
  800bfd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bff:	f6 c2 03             	test   $0x3,%dl
  800c02:	75 0f                	jne    800c13 <memmove+0x5f>
  800c04:	f6 c1 03             	test   $0x3,%cl
  800c07:	75 0a                	jne    800c13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0c:	89 c7                	mov    %eax,%edi
  800c0e:	fc                   	cld    
  800c0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c11:	eb 05                	jmp    800c18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c13:	89 c7                	mov    %eax,%edi
  800c15:	fc                   	cld    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c22:	8b 45 10             	mov    0x10(%ebp),%eax
  800c25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	89 04 24             	mov    %eax,(%esp)
  800c36:	e8 79 ff ff ff       	call   800bb4 <memmove>
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4d:	eb 1a                	jmp    800c69 <memcmp+0x2c>
		if (*s1 != *s2)
  800c4f:	0f b6 02             	movzbl (%edx),%eax
  800c52:	0f b6 19             	movzbl (%ecx),%ebx
  800c55:	38 d8                	cmp    %bl,%al
  800c57:	74 0a                	je     800c63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c59:	0f b6 c0             	movzbl %al,%eax
  800c5c:	0f b6 db             	movzbl %bl,%ebx
  800c5f:	29 d8                	sub    %ebx,%eax
  800c61:	eb 0f                	jmp    800c72 <memcmp+0x35>
		s1++, s2++;
  800c63:	83 c2 01             	add    $0x1,%edx
  800c66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c69:	39 f2                	cmp    %esi,%edx
  800c6b:	75 e2                	jne    800c4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7f:	89 c2                	mov    %eax,%edx
  800c81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c84:	eb 07                	jmp    800c8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c86:	38 08                	cmp    %cl,(%eax)
  800c88:	74 07                	je     800c91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	39 d0                	cmp    %edx,%eax
  800c8f:	72 f5                	jb     800c86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9f:	eb 03                	jmp    800ca4 <strtol+0x11>
		s++;
  800ca1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	0f b6 0a             	movzbl (%edx),%ecx
  800ca7:	80 f9 09             	cmp    $0x9,%cl
  800caa:	74 f5                	je     800ca1 <strtol+0xe>
  800cac:	80 f9 20             	cmp    $0x20,%cl
  800caf:	74 f0                	je     800ca1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb1:	80 f9 2b             	cmp    $0x2b,%cl
  800cb4:	75 0a                	jne    800cc0 <strtol+0x2d>
		s++;
  800cb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbe:	eb 11                	jmp    800cd1 <strtol+0x3e>
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc5:	80 f9 2d             	cmp    $0x2d,%cl
  800cc8:	75 07                	jne    800cd1 <strtol+0x3e>
		s++, neg = 1;
  800cca:	8d 52 01             	lea    0x1(%edx),%edx
  800ccd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800cd6:	75 15                	jne    800ced <strtol+0x5a>
  800cd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800cdb:	75 10                	jne    800ced <strtol+0x5a>
  800cdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce1:	75 0a                	jne    800ced <strtol+0x5a>
		s += 2, base = 16;
  800ce3:	83 c2 02             	add    $0x2,%edx
  800ce6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ceb:	eb 10                	jmp    800cfd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ced:	85 c0                	test   %eax,%eax
  800cef:	75 0c                	jne    800cfd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf6:	75 05                	jne    800cfd <strtol+0x6a>
		s++, base = 8;
  800cf8:	83 c2 01             	add    $0x1,%edx
  800cfb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d05:	0f b6 0a             	movzbl (%edx),%ecx
  800d08:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	3c 09                	cmp    $0x9,%al
  800d0f:	77 08                	ja     800d19 <strtol+0x86>
			dig = *s - '0';
  800d11:	0f be c9             	movsbl %cl,%ecx
  800d14:	83 e9 30             	sub    $0x30,%ecx
  800d17:	eb 20                	jmp    800d39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800d19:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800d1c:	89 f0                	mov    %esi,%eax
  800d1e:	3c 19                	cmp    $0x19,%al
  800d20:	77 08                	ja     800d2a <strtol+0x97>
			dig = *s - 'a' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 57             	sub    $0x57,%ecx
  800d28:	eb 0f                	jmp    800d39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800d2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800d2d:	89 f0                	mov    %esi,%eax
  800d2f:	3c 19                	cmp    $0x19,%al
  800d31:	77 16                	ja     800d49 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800d33:	0f be c9             	movsbl %cl,%ecx
  800d36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800d3c:	7d 0f                	jge    800d4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800d3e:	83 c2 01             	add    $0x1,%edx
  800d41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800d45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800d47:	eb bc                	jmp    800d05 <strtol+0x72>
  800d49:	89 d8                	mov    %ebx,%eax
  800d4b:	eb 02                	jmp    800d4f <strtol+0xbc>
  800d4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800d4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d53:	74 05                	je     800d5a <strtol+0xc7>
		*endptr = (char *) s;
  800d55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800d5a:	f7 d8                	neg    %eax
  800d5c:	85 ff                	test   %edi,%edi
  800d5e:	0f 44 c3             	cmove  %ebx,%eax
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	89 c7                	mov    %eax,%edi
  800d7b:	89 c6                	mov    %eax,%esi
  800d7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d94:	89 d1                	mov    %edx,%ecx
  800d96:	89 d3                	mov    %edx,%ebx
  800d98:	89 d7                	mov    %edx,%edi
  800d9a:	89 d6                	mov    %edx,%esi
  800d9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db1:	b8 03 00 00 00       	mov    $0x3,%eax
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 cb                	mov    %ecx,%ebx
  800dbb:	89 cf                	mov    %ecx,%edi
  800dbd:	89 ce                	mov    %ecx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 28                	jle    800ded <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de0:	00 
  800de1:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800de8:	e8 b6 f4 ff ff       	call   8002a3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ded:	83 c4 2c             	add    $0x2c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 02 00 00 00       	mov    $0x2,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_yield>:

void
sys_yield(void)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e24:	89 d1                	mov    %edx,%ecx
  800e26:	89 d3                	mov    %edx,%ebx
  800e28:	89 d7                	mov    %edx,%edi
  800e2a:	89 d6                	mov    %edx,%esi
  800e2c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	be 00 00 00 00       	mov    $0x0,%esi
  800e41:	b8 04 00 00 00       	mov    $0x4,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4f:	89 f7                	mov    %esi,%edi
  800e51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7e 28                	jle    800e7f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e62:	00 
  800e63:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800e7a:	e8 24 f4 ff ff       	call   8002a3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7f:	83 c4 2c             	add    $0x2c,%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	b8 05 00 00 00       	mov    $0x5,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 28                	jle    800ed2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec5:	00 
  800ec6:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800ecd:	e8 d1 f3 ff ff       	call   8002a3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ed2:	83 c4 2c             	add    $0x2c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee8:	b8 06 00 00 00       	mov    $0x6,%eax
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	89 df                	mov    %ebx,%edi
  800ef5:	89 de                	mov    %ebx,%esi
  800ef7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800f20:	e8 7e f3 ff ff       	call   8002a3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f25:	83 c4 2c             	add    $0x2c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
  800f46:	89 df                	mov    %ebx,%edi
  800f48:	89 de                	mov    %ebx,%esi
  800f4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	7e 28                	jle    800f78 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f54:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800f63:	00 
  800f64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6b:	00 
  800f6c:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800f73:	e8 2b f3 ff ff       	call   8002a3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f78:	83 c4 2c             	add    $0x2c,%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	89 df                	mov    %ebx,%edi
  800f9b:	89 de                	mov    %ebx,%esi
  800f9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	7e 28                	jle    800fcb <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fae:	00 
  800faf:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbe:	00 
  800fbf:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  800fc6:	e8 d8 f2 ff ff       	call   8002a3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fcb:	83 c4 2c             	add    $0x2c,%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	be 00 00 00 00       	mov    $0x0,%esi
  800fde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801004:	b8 0c 00 00 00       	mov    $0xc,%eax
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	89 cb                	mov    %ecx,%ebx
  80100e:	89 cf                	mov    %ecx,%edi
  801010:	89 ce                	mov    %ecx,%esi
  801012:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801014:	85 c0                	test   %eax,%eax
  801016:	7e 28                	jle    801040 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801018:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801023:	00 
  801024:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 25 16 80 00 	movl   $0x801625,(%esp)
  80103b:	e8 63 f2 ff ff       	call   8002a3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801040:	83 c4 2c             	add    $0x2c,%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
	...

00801050 <__udivdi3>:
  801050:	83 ec 1c             	sub    $0x1c,%esp
  801053:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801057:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80105b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80105f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801063:	89 74 24 10          	mov    %esi,0x10(%esp)
  801067:	8b 74 24 24          	mov    0x24(%esp),%esi
  80106b:	85 ff                	test   %edi,%edi
  80106d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801071:	89 44 24 08          	mov    %eax,0x8(%esp)
  801075:	89 cd                	mov    %ecx,%ebp
  801077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107b:	75 33                	jne    8010b0 <__udivdi3+0x60>
  80107d:	39 f1                	cmp    %esi,%ecx
  80107f:	77 57                	ja     8010d8 <__udivdi3+0x88>
  801081:	85 c9                	test   %ecx,%ecx
  801083:	75 0b                	jne    801090 <__udivdi3+0x40>
  801085:	b8 01 00 00 00       	mov    $0x1,%eax
  80108a:	31 d2                	xor    %edx,%edx
  80108c:	f7 f1                	div    %ecx
  80108e:	89 c1                	mov    %eax,%ecx
  801090:	89 f0                	mov    %esi,%eax
  801092:	31 d2                	xor    %edx,%edx
  801094:	f7 f1                	div    %ecx
  801096:	89 c6                	mov    %eax,%esi
  801098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80109c:	f7 f1                	div    %ecx
  80109e:	89 f2                	mov    %esi,%edx
  8010a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ac:	83 c4 1c             	add    $0x1c,%esp
  8010af:	c3                   	ret    
  8010b0:	31 d2                	xor    %edx,%edx
  8010b2:	31 c0                	xor    %eax,%eax
  8010b4:	39 f7                	cmp    %esi,%edi
  8010b6:	77 e8                	ja     8010a0 <__udivdi3+0x50>
  8010b8:	0f bd cf             	bsr    %edi,%ecx
  8010bb:	83 f1 1f             	xor    $0x1f,%ecx
  8010be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010c2:	75 2c                	jne    8010f0 <__udivdi3+0xa0>
  8010c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010c8:	76 04                	jbe    8010ce <__udivdi3+0x7e>
  8010ca:	39 f7                	cmp    %esi,%edi
  8010cc:	73 d2                	jae    8010a0 <__udivdi3+0x50>
  8010ce:	31 d2                	xor    %edx,%edx
  8010d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d5:	eb c9                	jmp    8010a0 <__udivdi3+0x50>
  8010d7:	90                   	nop
  8010d8:	89 f2                	mov    %esi,%edx
  8010da:	f7 f1                	div    %ecx
  8010dc:	31 d2                	xor    %edx,%edx
  8010de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ea:	83 c4 1c             	add    $0x1c,%esp
  8010ed:	c3                   	ret    
  8010ee:	66 90                	xchg   %ax,%ax
  8010f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010fa:	89 ea                	mov    %ebp,%edx
  8010fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801100:	d3 e7                	shl    %cl,%edi
  801102:	89 c1                	mov    %eax,%ecx
  801104:	d3 ea                	shr    %cl,%edx
  801106:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110b:	09 fa                	or     %edi,%edx
  80110d:	89 f7                	mov    %esi,%edi
  80110f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801113:	89 f2                	mov    %esi,%edx
  801115:	8b 74 24 08          	mov    0x8(%esp),%esi
  801119:	d3 e5                	shl    %cl,%ebp
  80111b:	89 c1                	mov    %eax,%ecx
  80111d:	d3 ef                	shr    %cl,%edi
  80111f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801124:	d3 e2                	shl    %cl,%edx
  801126:	89 c1                	mov    %eax,%ecx
  801128:	d3 ee                	shr    %cl,%esi
  80112a:	09 d6                	or     %edx,%esi
  80112c:	89 fa                	mov    %edi,%edx
  80112e:	89 f0                	mov    %esi,%eax
  801130:	f7 74 24 0c          	divl   0xc(%esp)
  801134:	89 d7                	mov    %edx,%edi
  801136:	89 c6                	mov    %eax,%esi
  801138:	f7 e5                	mul    %ebp
  80113a:	39 d7                	cmp    %edx,%edi
  80113c:	72 22                	jb     801160 <__udivdi3+0x110>
  80113e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801142:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801147:	d3 e5                	shl    %cl,%ebp
  801149:	39 c5                	cmp    %eax,%ebp
  80114b:	73 04                	jae    801151 <__udivdi3+0x101>
  80114d:	39 d7                	cmp    %edx,%edi
  80114f:	74 0f                	je     801160 <__udivdi3+0x110>
  801151:	89 f0                	mov    %esi,%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	e9 46 ff ff ff       	jmp    8010a0 <__udivdi3+0x50>
  80115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801160:	8d 46 ff             	lea    -0x1(%esi),%eax
  801163:	31 d2                	xor    %edx,%edx
  801165:	8b 74 24 10          	mov    0x10(%esp),%esi
  801169:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80116d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801171:	83 c4 1c             	add    $0x1c,%esp
  801174:	c3                   	ret    
	...

00801180 <__umoddi3>:
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801187:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80118b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80118f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801193:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801197:	8b 74 24 24          	mov    0x24(%esp),%esi
  80119b:	85 ed                	test   %ebp,%ebp
  80119d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a5:	89 cf                	mov    %ecx,%edi
  8011a7:	89 04 24             	mov    %eax,(%esp)
  8011aa:	89 f2                	mov    %esi,%edx
  8011ac:	75 1a                	jne    8011c8 <__umoddi3+0x48>
  8011ae:	39 f1                	cmp    %esi,%ecx
  8011b0:	76 4e                	jbe    801200 <__umoddi3+0x80>
  8011b2:	f7 f1                	div    %ecx
  8011b4:	89 d0                	mov    %edx,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c4:	83 c4 1c             	add    $0x1c,%esp
  8011c7:	c3                   	ret    
  8011c8:	39 f5                	cmp    %esi,%ebp
  8011ca:	77 54                	ja     801220 <__umoddi3+0xa0>
  8011cc:	0f bd c5             	bsr    %ebp,%eax
  8011cf:	83 f0 1f             	xor    $0x1f,%eax
  8011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d6:	75 60                	jne    801238 <__umoddi3+0xb8>
  8011d8:	3b 0c 24             	cmp    (%esp),%ecx
  8011db:	0f 87 07 01 00 00    	ja     8012e8 <__umoddi3+0x168>
  8011e1:	89 f2                	mov    %esi,%edx
  8011e3:	8b 34 24             	mov    (%esp),%esi
  8011e6:	29 ce                	sub    %ecx,%esi
  8011e8:	19 ea                	sbb    %ebp,%edx
  8011ea:	89 34 24             	mov    %esi,(%esp)
  8011ed:	8b 04 24             	mov    (%esp),%eax
  8011f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fc:	83 c4 1c             	add    $0x1c,%esp
  8011ff:	c3                   	ret    
  801200:	85 c9                	test   %ecx,%ecx
  801202:	75 0b                	jne    80120f <__umoddi3+0x8f>
  801204:	b8 01 00 00 00       	mov    $0x1,%eax
  801209:	31 d2                	xor    %edx,%edx
  80120b:	f7 f1                	div    %ecx
  80120d:	89 c1                	mov    %eax,%ecx
  80120f:	89 f0                	mov    %esi,%eax
  801211:	31 d2                	xor    %edx,%edx
  801213:	f7 f1                	div    %ecx
  801215:	8b 04 24             	mov    (%esp),%eax
  801218:	f7 f1                	div    %ecx
  80121a:	eb 98                	jmp    8011b4 <__umoddi3+0x34>
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 f2                	mov    %esi,%edx
  801222:	8b 74 24 10          	mov    0x10(%esp),%esi
  801226:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80122a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122e:	83 c4 1c             	add    $0x1c,%esp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123d:	89 e8                	mov    %ebp,%eax
  80123f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801244:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801248:	89 fa                	mov    %edi,%edx
  80124a:	d3 e0                	shl    %cl,%eax
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	d3 ea                	shr    %cl,%edx
  801250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801255:	09 c2                	or     %eax,%edx
  801257:	8b 44 24 08          	mov    0x8(%esp),%eax
  80125b:	89 14 24             	mov    %edx,(%esp)
  80125e:	89 f2                	mov    %esi,%edx
  801260:	d3 e7                	shl    %cl,%edi
  801262:	89 e9                	mov    %ebp,%ecx
  801264:	d3 ea                	shr    %cl,%edx
  801266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80126f:	d3 e6                	shl    %cl,%esi
  801271:	89 e9                	mov    %ebp,%ecx
  801273:	d3 e8                	shr    %cl,%eax
  801275:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80127a:	09 f0                	or     %esi,%eax
  80127c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801280:	f7 34 24             	divl   (%esp)
  801283:	d3 e6                	shl    %cl,%esi
  801285:	89 74 24 08          	mov    %esi,0x8(%esp)
  801289:	89 d6                	mov    %edx,%esi
  80128b:	f7 e7                	mul    %edi
  80128d:	39 d6                	cmp    %edx,%esi
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	89 d7                	mov    %edx,%edi
  801293:	72 3f                	jb     8012d4 <__umoddi3+0x154>
  801295:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801299:	72 35                	jb     8012d0 <__umoddi3+0x150>
  80129b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80129f:	29 c8                	sub    %ecx,%eax
  8012a1:	19 fe                	sbb    %edi,%esi
  8012a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	d3 e8                	shr    %cl,%eax
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 e2                	shl    %cl,%edx
  8012b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012b5:	09 d0                	or     %edx,%eax
  8012b7:	89 f2                	mov    %esi,%edx
  8012b9:	d3 ea                	shr    %cl,%edx
  8012bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012c7:	83 c4 1c             	add    $0x1c,%esp
  8012ca:	c3                   	ret    
  8012cb:	90                   	nop
  8012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	39 d6                	cmp    %edx,%esi
  8012d2:	75 c7                	jne    80129b <__umoddi3+0x11b>
  8012d4:	89 d7                	mov    %edx,%edi
  8012d6:	89 c1                	mov    %eax,%ecx
  8012d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012dc:	1b 3c 24             	sbb    (%esp),%edi
  8012df:	eb ba                	jmp    80129b <__umoddi3+0x11b>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	39 f5                	cmp    %esi,%ebp
  8012ea:	0f 82 f1 fe ff ff    	jb     8011e1 <__umoddi3+0x61>
  8012f0:	e9 f8 fe ff ff       	jmp    8011ed <__umoddi3+0x6d>
