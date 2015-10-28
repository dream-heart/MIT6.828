
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
  800051:	e8 de 0d 00 00       	call   800e34 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  800075:	e8 2a 02 00 00       	call   8002a4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 f5 0d 00 00       	call   800e93 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 83 13 80 	movl   $0x801383,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  8000bd:	e8 e2 01 00 00       	call   8002a4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 74 0a 00 00       	call   800b4e <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 03 0e 00 00       	call   800ef1 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 94 13 80 	movl   $0x801394,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  80010d:	e8 92 01 00 00       	call   8002a4 <_panic>
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
  800136:	c7 44 24 08 a7 13 80 	movl   $0x8013a7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  80014d:	e8 52 01 00 00       	call   8002a4 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 19                	jne    80016f <dumbfork+0x56>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 79 0c 00 00       	call   800dd4 <sys_getenvid>
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
  8001b4:	e8 96 0d 00 00       	call   800f4f <sys_env_set_status>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	79 20                	jns    8001dd <dumbfork+0xc4>
		panic("sys_env_set_status: %e", r);
  8001bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c1:	c7 44 24 08 b7 13 80 	movl   $0x8013b7,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  8001d8:	e8 c7 00 00 00       	call   8002a4 <_panic>

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
  8001fb:	bf d5 13 80 00       	mov    $0x8013d5,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800200:	eb 26                	jmp    800228 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800202:	85 db                	test   %ebx,%ebx
  800204:	b8 ce 13 80 00       	mov    $0x8013ce,%eax
  800209:	0f 44 c7             	cmove  %edi,%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	c7 04 24 db 13 80 00 	movl   $0x8013db,(%esp)
  80021b:	e8 7f 01 00 00       	call   80039f <cprintf>
		sys_yield();
  800220:	e8 df 0b 00 00       	call   800e04 <sys_yield>

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
  800252:	e8 7d 0b 00 00       	call   800dd4 <sys_getenvid>
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
  800280:	e8 0b 00 00 00       	call   800290 <exit>
}
  800285:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800288:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80028b:	89 ec                	mov    %ebp,%esp
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
	...

00800290 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80029d:	e8 d5 0a 00 00       	call   800d77 <sys_env_destroy>
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002af:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002b5:	e8 1a 0b 00 00       	call   800dd4 <sys_getenvid>
  8002ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  8002d7:	e8 c3 00 00 00       	call   80039f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	e8 53 00 00 00       	call   80033e <vcprintf>
	cprintf("\n");
  8002eb:	c7 04 24 eb 13 80 00 	movl   $0x8013eb,(%esp)
  8002f2:	e8 a8 00 00 00       	call   80039f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f7:	cc                   	int3   
  8002f8:	eb fd                	jmp    8002f7 <_panic+0x53>
	...

008002fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	53                   	push   %ebx
  800300:	83 ec 14             	sub    $0x14,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800306:	8b 03                	mov    (%ebx),%eax
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030f:	83 c0 01             	add    $0x1,%eax
  800312:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800314:	3d ff 00 00 00       	cmp    $0xff,%eax
  800319:	75 19                	jne    800334 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80031b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800322:	00 
  800323:	8d 43 08             	lea    0x8(%ebx),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	e8 ea 09 00 00       	call   800d18 <sys_cputs>
		b->idx = 0;
  80032e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800334:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800338:	83 c4 14             	add    $0x14,%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800347:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034e:	00 00 00 
	b.cnt = 0;
  800351:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800358:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80035b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	89 44 24 08          	mov    %eax,0x8(%esp)
  800369:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800373:	c7 04 24 fc 02 80 00 	movl   $0x8002fc,(%esp)
  80037a:	e8 8e 01 00 00       	call   80050d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 81 09 00 00       	call   800d18 <sys_cputs>

	return b.cnt;
}
  800397:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 87 ff ff ff       	call   80033e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    
  8003b9:	00 00                	add    %al,(%eax)
  8003bb:	00 00                	add    %al,(%eax)
  8003bd:	00 00                	add    %al,(%eax)
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
  8003d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	75 08                	jne    8003ec <printnum+0x2c>
  8003e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ea:	77 59                	ja     800445 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003f0:	83 eb 01             	sub    $0x1,%ebx
  8003f3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800402:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800406:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040d:	00 
  80040e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041b:	e8 80 0c 00 00       	call   8010a0 <__udivdi3>
  800420:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800424:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80042f:	89 fa                	mov    %edi,%edx
  800431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800434:	e8 87 ff ff ff       	call   8003c0 <printnum>
  800439:	eb 11                	jmp    80044c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043f:	89 34 24             	mov    %esi,(%esp)
  800442:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800445:	83 eb 01             	sub    $0x1,%ebx
  800448:	85 db                	test   %ebx,%ebx
  80044a:	7f ef                	jg     80043b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800450:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800454:	8b 45 10             	mov    0x10(%ebp),%eax
  800457:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800462:	00 
  800463:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800470:	e8 5b 0d 00 00       	call   8011d0 <__umoddi3>
  800475:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800479:	0f be 80 1c 14 80 00 	movsbl 0x80141c(%eax),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800486:	83 c4 3c             	add    $0x3c,%esp
  800489:	5b                   	pop    %ebx
  80048a:	5e                   	pop    %esi
  80048b:	5f                   	pop    %edi
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    

0080048e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800491:	83 fa 01             	cmp    $0x1,%edx
  800494:	7e 0e                	jle    8004a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	8b 52 04             	mov    0x4(%edx),%edx
  8004a2:	eb 22                	jmp    8004c6 <getuint+0x38>
	else if (lflag)
  8004a4:	85 d2                	test   %edx,%edx
  8004a6:	74 10                	je     8004b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b6:	eb 0e                	jmp    8004c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d7:	73 0a                	jae    8004e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004dc:	88 0a                	mov    %cl,(%edx)
  8004de:	83 c2 01             	add    $0x1,%edx
  8004e1:	89 10                	mov    %edx,(%eax)
}
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    

008004e5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	e8 02 00 00 00       	call   80050d <vprintfmt>
	va_end(ap);
}
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 4c             	sub    $0x4c,%esp
  800516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800519:	8b 75 10             	mov    0x10(%ebp),%esi
  80051c:	eb 12                	jmp    800530 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051e:	85 c0                	test   %eax,%eax
  800520:	0f 84 bf 03 00 00    	je     8008e5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800526:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800530:	0f b6 06             	movzbl (%esi),%eax
  800533:	83 c6 01             	add    $0x1,%esi
  800536:	83 f8 25             	cmp    $0x25,%eax
  800539:	75 e3                	jne    80051e <vprintfmt+0x11>
  80053b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80053f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800546:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80054b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800552:	b9 00 00 00 00       	mov    $0x0,%ecx
  800557:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055a:	eb 2b                	jmp    800587 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800563:	eb 22                	jmp    800587 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80056c:	eb 19                	jmp    800587 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800571:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800578:	eb 0d                	jmp    800587 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80057a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800580:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	0f b6 16             	movzbl (%esi),%edx
  80058a:	0f b6 c2             	movzbl %dl,%eax
  80058d:	8d 7e 01             	lea    0x1(%esi),%edi
  800590:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800593:	83 ea 23             	sub    $0x23,%edx
  800596:	80 fa 55             	cmp    $0x55,%dl
  800599:	0f 87 28 03 00 00    	ja     8008c7 <vprintfmt+0x3ba>
  80059f:	0f b6 d2             	movzbl %dl,%edx
  8005a2:	ff 24 95 e0 14 80 00 	jmp    *0x8014e0(,%edx,4)
  8005a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ac:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005b3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005bb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005bf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005c2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005c5:	83 fa 09             	cmp    $0x9,%edx
  8005c8:	77 2f                	ja     8005f9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ca:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cd:	eb e9                	jmp    8005b8 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e0:	eb 1a                	jmp    8005fc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8005e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e9:	79 9c                	jns    800587 <vprintfmt+0x7a>
  8005eb:	eb 81                	jmp    80056e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005f7:	eb 8e                	jmp    800587 <vprintfmt+0x7a>
  8005f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8005fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800600:	79 85                	jns    800587 <vprintfmt+0x7a>
  800602:	e9 73 ff ff ff       	jmp    80057a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800607:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80060d:	e9 75 ff ff ff       	jmp    800587 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062a:	e9 01 ff ff ff       	jmp    800530 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	c1 fa 1f             	sar    $0x1f,%edx
  80063f:	31 d0                	xor    %edx,%eax
  800641:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800643:	83 f8 09             	cmp    $0x9,%eax
  800646:	7f 0b                	jg     800653 <vprintfmt+0x146>
  800648:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  80064f:	85 d2                	test   %edx,%edx
  800651:	75 23                	jne    800676 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800653:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800657:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  80065e:	00 
  80065f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800663:	8b 7d 08             	mov    0x8(%ebp),%edi
  800666:	89 3c 24             	mov    %edi,(%esp)
  800669:	e8 77 fe ff ff       	call   8004e5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800671:	e9 ba fe ff ff       	jmp    800530 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800676:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80067a:	c7 44 24 08 3d 14 80 	movl   $0x80143d,0x8(%esp)
  800681:	00 
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	89 3c 24             	mov    %edi,(%esp)
  80068c:	e8 54 fe ff ff       	call   8004e5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800694:	e9 97 fe ff ff       	jmp    800530 <vprintfmt+0x23>
  800699:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80069c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006ad:	85 f6                	test   %esi,%esi
  8006af:	ba 2d 14 80 00       	mov    $0x80142d,%edx
  8006b4:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8006b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006bb:	0f 8e 8c 00 00 00    	jle    80074d <vprintfmt+0x240>
  8006c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006c5:	0f 84 82 00 00 00    	je     80074d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cf:	89 34 24             	mov    %esi,(%esp)
  8006d2:	e8 b1 02 00 00       	call   800988 <strnlen>
  8006d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006da:	29 c2                	sub    %eax,%edx
  8006dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006df:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006e3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006e6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006e9:	89 de                	mov    %ebx,%esi
  8006eb:	89 d3                	mov    %edx,%ebx
  8006ed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ef:	eb 0d                	jmp    8006fe <vprintfmt+0x1f1>
					putch(padc, putdat);
  8006f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f5:	89 3c 24             	mov    %edi,(%esp)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fb:	83 eb 01             	sub    $0x1,%ebx
  8006fe:	85 db                	test   %ebx,%ebx
  800700:	7f ef                	jg     8006f1 <vprintfmt+0x1e4>
  800702:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800705:	89 f3                	mov    %esi,%ebx
  800707:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80070a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071a:	29 c2                	sub    %eax,%edx
  80071c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80071f:	eb 2c                	jmp    80074d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800721:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800725:	74 18                	je     80073f <vprintfmt+0x232>
  800727:	8d 50 e0             	lea    -0x20(%eax),%edx
  80072a:	83 fa 5e             	cmp    $0x5e,%edx
  80072d:	76 10                	jbe    80073f <vprintfmt+0x232>
					putch('?', putdat);
  80072f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800733:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80073a:	ff 55 08             	call   *0x8(%ebp)
  80073d:	eb 0a                	jmp    800749 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80073f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800749:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80074d:	0f be 06             	movsbl (%esi),%eax
  800750:	83 c6 01             	add    $0x1,%esi
  800753:	85 c0                	test   %eax,%eax
  800755:	74 25                	je     80077c <vprintfmt+0x26f>
  800757:	85 ff                	test   %edi,%edi
  800759:	78 c6                	js     800721 <vprintfmt+0x214>
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	79 c1                	jns    800721 <vprintfmt+0x214>
  800760:	8b 7d 08             	mov    0x8(%ebp),%edi
  800763:	89 de                	mov    %ebx,%esi
  800765:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800768:	eb 1a                	jmp    800784 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800775:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800777:	83 eb 01             	sub    $0x1,%ebx
  80077a:	eb 08                	jmp    800784 <vprintfmt+0x277>
  80077c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077f:	89 de                	mov    %ebx,%esi
  800781:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800784:	85 db                	test   %ebx,%ebx
  800786:	7f e2                	jg     80076a <vprintfmt+0x25d>
  800788:	89 7d 08             	mov    %edi,0x8(%ebp)
  80078b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800790:	e9 9b fd ff ff       	jmp    800530 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800795:	83 f9 01             	cmp    $0x1,%ecx
  800798:	7e 10                	jle    8007aa <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 08             	lea    0x8(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 30                	mov    (%eax),%esi
  8007a5:	8b 78 04             	mov    0x4(%eax),%edi
  8007a8:	eb 26                	jmp    8007d0 <vprintfmt+0x2c3>
	else if (lflag)
  8007aa:	85 c9                	test   %ecx,%ecx
  8007ac:	74 12                	je     8007c0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 30                	mov    (%eax),%esi
  8007b9:	89 f7                	mov    %esi,%edi
  8007bb:	c1 ff 1f             	sar    $0x1f,%edi
  8007be:	eb 10                	jmp    8007d0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 50 04             	lea    0x4(%eax),%edx
  8007c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c9:	8b 30                	mov    (%eax),%esi
  8007cb:	89 f7                	mov    %esi,%edi
  8007cd:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007d5:	85 ff                	test   %edi,%edi
  8007d7:	0f 89 ac 00 00 00    	jns    800889 <vprintfmt+0x37c>
				putch('-', putdat);
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007eb:	f7 de                	neg    %esi
  8007ed:	83 d7 00             	adc    $0x0,%edi
  8007f0:	f7 df                	neg    %edi
			}
			base = 10;
  8007f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f7:	e9 8d 00 00 00       	jmp    800889 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007fc:	89 ca                	mov    %ecx,%edx
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	e8 88 fc ff ff       	call   80048e <getuint>
  800806:	89 c6                	mov    %eax,%esi
  800808:	89 d7                	mov    %edx,%edi
			base = 10;
  80080a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80080f:	eb 78                	jmp    800889 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800811:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800815:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80081c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80081f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800823:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80082a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80082d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800831:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800838:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80083e:	e9 ed fc ff ff       	jmp    800530 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800851:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800855:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80085c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800868:	8b 30                	mov    (%eax),%esi
  80086a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800874:	eb 13                	jmp    800889 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800876:	89 ca                	mov    %ecx,%edx
  800878:	8d 45 14             	lea    0x14(%ebp),%eax
  80087b:	e8 0e fc ff ff       	call   80048e <getuint>
  800880:	89 c6                	mov    %eax,%esi
  800882:	89 d7                	mov    %edx,%edi
			base = 16;
  800884:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800889:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80088d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800891:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800894:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800898:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089c:	89 34 24             	mov    %esi,(%esp)
  80089f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a3:	89 da                	mov    %ebx,%edx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	e8 13 fb ff ff       	call   8003c0 <printnum>
			break;
  8008ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008b0:	e9 7b fc ff ff       	jmp    800530 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b9:	89 04 24             	mov    %eax,(%esp)
  8008bc:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c2:	e9 69 fc ff ff       	jmp    800530 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008d2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x3cd>
  8008d7:	83 ee 01             	sub    $0x1,%esi
  8008da:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x3ca>
  8008e0:	e9 4b fc ff ff       	jmp    800530 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008e5:	83 c4 4c             	add    $0x4c,%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 28             	sub    $0x28,%esp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800900:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090a:	85 c0                	test   %eax,%eax
  80090c:	74 30                	je     80093e <vsnprintf+0x51>
  80090e:	85 d2                	test   %edx,%edx
  800910:	7e 2c                	jle    80093e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800919:	8b 45 10             	mov    0x10(%ebp),%eax
  80091c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800920:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800923:	89 44 24 04          	mov    %eax,0x4(%esp)
  800927:	c7 04 24 c8 04 80 00 	movl   $0x8004c8,(%esp)
  80092e:	e8 da fb ff ff       	call   80050d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800933:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800936:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093c:	eb 05                	jmp    800943 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800952:	8b 45 10             	mov    0x10(%ebp),%eax
  800955:	89 44 24 08          	mov    %eax,0x8(%esp)
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	89 04 24             	mov    %eax,(%esp)
  800966:	e8 82 ff ff ff       	call   8008ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    
  80096d:	00 00                	add    %al,(%eax)
	...

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 03                	jmp    800980 <strlen+0x10>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	75 f7                	jne    80097d <strlen+0xd>
		n++;
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	eb 03                	jmp    80099b <strnlen+0x13>
		n++;
  800998:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	74 06                	je     8009a5 <strnlen+0x1d>
  80099f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009a3:	75 f3                	jne    800998 <strnlen+0x10>
		n++;
	return n;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ba:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009bd:	83 c2 01             	add    $0x1,%edx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	75 f2                	jne    8009b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d1:	89 1c 24             	mov    %ebx,(%esp)
  8009d4:	e8 97 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e0:	01 d8                	add    %ebx,%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 bd ff ff ff       	call   8009a7 <strcpy>
	return dst;
}
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	83 c4 08             	add    $0x8,%esp
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a05:	eb 0f                	jmp    800a16 <strncpy+0x24>
		*dst++ = *src;
  800a07:	0f b6 1a             	movzbl (%edx),%ebx
  800a0a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a10:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	39 f1                	cmp    %esi,%ecx
  800a18:	75 ed                	jne    800a07 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 08             	mov    0x8(%ebp),%esi
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2c:	89 f0                	mov    %esi,%eax
  800a2e:	85 d2                	test   %edx,%edx
  800a30:	75 0a                	jne    800a3c <strlcpy+0x1e>
  800a32:	eb 1d                	jmp    800a51 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a34:	88 18                	mov    %bl,(%eax)
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3c:	83 ea 01             	sub    $0x1,%edx
  800a3f:	74 0b                	je     800a4c <strlcpy+0x2e>
  800a41:	0f b6 19             	movzbl (%ecx),%ebx
  800a44:	84 db                	test   %bl,%bl
  800a46:	75 ec                	jne    800a34 <strlcpy+0x16>
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	eb 02                	jmp    800a4e <strlcpy+0x30>
  800a4c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a4e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a51:	29 f0                	sub    %esi,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a60:	eb 06                	jmp    800a68 <strcmp+0x11>
		p++, q++;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	84 c0                	test   %al,%al
  800a6d:	74 04                	je     800a73 <strcmp+0x1c>
  800a6f:	3a 02                	cmp    (%edx),%al
  800a71:	74 ef                	je     800a62 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a73:	0f b6 c0             	movzbl %al,%eax
  800a76:	0f b6 12             	movzbl (%edx),%edx
  800a79:	29 d0                	sub    %edx,%eax
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a87:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a8a:	eb 09                	jmp    800a95 <strncmp+0x18>
		n--, p++, q++;
  800a8c:	83 ea 01             	sub    $0x1,%edx
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a95:	85 d2                	test   %edx,%edx
  800a97:	74 15                	je     800aae <strncmp+0x31>
  800a99:	0f b6 18             	movzbl (%eax),%ebx
  800a9c:	84 db                	test   %bl,%bl
  800a9e:	74 04                	je     800aa4 <strncmp+0x27>
  800aa0:	3a 19                	cmp    (%ecx),%bl
  800aa2:	74 e8                	je     800a8c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa4:	0f b6 00             	movzbl (%eax),%eax
  800aa7:	0f b6 11             	movzbl (%ecx),%edx
  800aaa:	29 d0                	sub    %edx,%eax
  800aac:	eb 05                	jmp    800ab3 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac0:	eb 07                	jmp    800ac9 <strchr+0x13>
		if (*s == c)
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	74 0f                	je     800ad5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	84 d2                	test   %dl,%dl
  800ace:	75 f2                	jne    800ac2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae1:	eb 07                	jmp    800aea <strfind+0x13>
		if (*s == c)
  800ae3:	38 ca                	cmp    %cl,%dl
  800ae5:	74 0a                	je     800af1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	0f b6 10             	movzbl (%eax),%edx
  800aed:	84 d2                	test   %dl,%dl
  800aef:	75 f2                	jne    800ae3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800afc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	74 30                	je     800b3f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b15:	75 25                	jne    800b3c <memset+0x49>
  800b17:	f6 c1 03             	test   $0x3,%cl
  800b1a:	75 20                	jne    800b3c <memset+0x49>
		c &= 0xFF;
  800b1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	c1 e3 08             	shl    $0x8,%ebx
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	c1 e6 18             	shl    $0x18,%esi
  800b29:	89 d0                	mov    %edx,%eax
  800b2b:	c1 e0 10             	shl    $0x10,%eax
  800b2e:	09 f0                	or     %esi,%eax
  800b30:	09 d0                	or     %edx,%eax
  800b32:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b34:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b37:	fc                   	cld    
  800b38:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3a:	eb 03                	jmp    800b3f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3c:	fc                   	cld    
  800b3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3f:	89 f8                	mov    %edi,%eax
  800b41:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b44:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b47:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b4a:	89 ec                	mov    %ebp,%esp
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b57:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b63:	39 c6                	cmp    %eax,%esi
  800b65:	73 36                	jae    800b9d <memmove+0x4f>
  800b67:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6a:	39 d0                	cmp    %edx,%eax
  800b6c:	73 2f                	jae    800b9d <memmove+0x4f>
		s += n;
		d += n;
  800b6e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b71:	f6 c2 03             	test   $0x3,%dl
  800b74:	75 1b                	jne    800b91 <memmove+0x43>
  800b76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7c:	75 13                	jne    800b91 <memmove+0x43>
  800b7e:	f6 c1 03             	test   $0x3,%cl
  800b81:	75 0e                	jne    800b91 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b83:	83 ef 04             	sub    $0x4,%edi
  800b86:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b89:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8c:	fd                   	std    
  800b8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8f:	eb 09                	jmp    800b9a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b91:	83 ef 01             	sub    $0x1,%edi
  800b94:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b97:	fd                   	std    
  800b98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9a:	fc                   	cld    
  800b9b:	eb 20                	jmp    800bbd <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba3:	75 13                	jne    800bb8 <memmove+0x6a>
  800ba5:	a8 03                	test   $0x3,%al
  800ba7:	75 0f                	jne    800bb8 <memmove+0x6a>
  800ba9:	f6 c1 03             	test   $0x3,%cl
  800bac:	75 0a                	jne    800bb8 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bb1:	89 c7                	mov    %eax,%edi
  800bb3:	fc                   	cld    
  800bb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb6:	eb 05                	jmp    800bbd <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	fc                   	cld    
  800bbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc3:	89 ec                	mov    %ebp,%esp
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bcd:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	89 04 24             	mov    %eax,(%esp)
  800be1:	e8 68 ff ff ff       	call   800b4e <memmove>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	eb 1a                	jmp    800c18 <memcmp+0x30>
		if (*s1 != *s2)
  800bfe:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800c02:	83 c2 01             	add    $0x1,%edx
  800c05:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800c0a:	38 c8                	cmp    %cl,%al
  800c0c:	74 0a                	je     800c18 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800c0e:	0f b6 c0             	movzbl %al,%eax
  800c11:	0f b6 c9             	movzbl %cl,%ecx
  800c14:	29 c8                	sub    %ecx,%eax
  800c16:	eb 09                	jmp    800c21 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c18:	39 da                	cmp    %ebx,%edx
  800c1a:	75 e2                	jne    800bfe <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c34:	eb 07                	jmp    800c3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c36:	38 08                	cmp    %cl,(%eax)
  800c38:	74 07                	je     800c41 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	72 f5                	jb     800c36 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4f:	eb 03                	jmp    800c54 <strtol+0x11>
		s++;
  800c51:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c54:	0f b6 02             	movzbl (%edx),%eax
  800c57:	3c 20                	cmp    $0x20,%al
  800c59:	74 f6                	je     800c51 <strtol+0xe>
  800c5b:	3c 09                	cmp    $0x9,%al
  800c5d:	74 f2                	je     800c51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5f:	3c 2b                	cmp    $0x2b,%al
  800c61:	75 0a                	jne    800c6d <strtol+0x2a>
		s++;
  800c63:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c66:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6b:	eb 10                	jmp    800c7d <strtol+0x3a>
  800c6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c72:	3c 2d                	cmp    $0x2d,%al
  800c74:	75 07                	jne    800c7d <strtol+0x3a>
		s++, neg = 1;
  800c76:	8d 52 01             	lea    0x1(%edx),%edx
  800c79:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7d:	85 db                	test   %ebx,%ebx
  800c7f:	0f 94 c0             	sete   %al
  800c82:	74 05                	je     800c89 <strtol+0x46>
  800c84:	83 fb 10             	cmp    $0x10,%ebx
  800c87:	75 15                	jne    800c9e <strtol+0x5b>
  800c89:	80 3a 30             	cmpb   $0x30,(%edx)
  800c8c:	75 10                	jne    800c9e <strtol+0x5b>
  800c8e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c92:	75 0a                	jne    800c9e <strtol+0x5b>
		s += 2, base = 16;
  800c94:	83 c2 02             	add    $0x2,%edx
  800c97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9c:	eb 13                	jmp    800cb1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c9e:	84 c0                	test   %al,%al
  800ca0:	74 0f                	je     800cb1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca7:	80 3a 30             	cmpb   $0x30,(%edx)
  800caa:	75 05                	jne    800cb1 <strtol+0x6e>
		s++, base = 8;
  800cac:	83 c2 01             	add    $0x1,%edx
  800caf:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb8:	0f b6 0a             	movzbl (%edx),%ecx
  800cbb:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cbe:	80 fb 09             	cmp    $0x9,%bl
  800cc1:	77 08                	ja     800ccb <strtol+0x88>
			dig = *s - '0';
  800cc3:	0f be c9             	movsbl %cl,%ecx
  800cc6:	83 e9 30             	sub    $0x30,%ecx
  800cc9:	eb 1e                	jmp    800ce9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ccb:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cce:	80 fb 19             	cmp    $0x19,%bl
  800cd1:	77 08                	ja     800cdb <strtol+0x98>
			dig = *s - 'a' + 10;
  800cd3:	0f be c9             	movsbl %cl,%ecx
  800cd6:	83 e9 57             	sub    $0x57,%ecx
  800cd9:	eb 0e                	jmp    800ce9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800cdb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cde:	80 fb 19             	cmp    $0x19,%bl
  800ce1:	77 14                	ja     800cf7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ce3:	0f be c9             	movsbl %cl,%ecx
  800ce6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ce9:	39 f1                	cmp    %esi,%ecx
  800ceb:	7d 0e                	jge    800cfb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800ced:	83 c2 01             	add    $0x1,%edx
  800cf0:	0f af c6             	imul   %esi,%eax
  800cf3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cf5:	eb c1                	jmp    800cb8 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cf7:	89 c1                	mov    %eax,%ecx
  800cf9:	eb 02                	jmp    800cfd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cfb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d01:	74 05                	je     800d08 <strtol+0xc5>
		*endptr = (char *) s;
  800d03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d06:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d08:	89 ca                	mov    %ecx,%edx
  800d0a:	f7 da                	neg    %edx
  800d0c:	85 ff                	test   %edi,%edi
  800d0e:	0f 45 c2             	cmovne %edx,%eax
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
	...

00800d18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d24:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	89 c3                	mov    %eax,%ebx
  800d34:	89 c7                	mov    %eax,%edi
  800d36:	89 c6                	mov    %eax,%esi
  800d38:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d43:	89 ec                	mov    %ebp,%esp
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d50:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d53:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5b:	b8 01 00 00 00       	mov    $0x1,%eax
  800d60:	89 d1                	mov    %edx,%ecx
  800d62:	89 d3                	mov    %edx,%ebx
  800d64:	89 d7                	mov    %edx,%edi
  800d66:	89 d6                	mov    %edx,%esi
  800d68:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d73:	89 ec                	mov    %ebp,%esp
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 38             	sub    $0x38,%esp
  800d7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 cb                	mov    %ecx,%ebx
  800d95:	89 cf                	mov    %ecx,%edi
  800d97:	89 ce                	mov    %ecx,%esi
  800d99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 28                	jle    800dc7 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800daa:	00 
  800dab:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800db2:	00 
  800db3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dba:	00 
  800dbb:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800dc2:	e8 dd f4 ff ff       	call   8002a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dc7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dcd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd0:	89 ec                	mov    %ebp,%esp
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ddd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	ba 00 00 00 00       	mov    $0x0,%edx
  800de8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 d3                	mov    %edx,%ebx
  800df1:	89 d7                	mov    %edx,%edi
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e00:	89 ec                	mov    %ebp,%esp
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_yield>:

void
sys_yield(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1d:	89 d1                	mov    %edx,%ecx
  800e1f:	89 d3                	mov    %edx,%ebx
  800e21:	89 d7                	mov    %edx,%edi
  800e23:	89 d6                	mov    %edx,%esi
  800e25:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e30:	89 ec                	mov    %ebp,%esp
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 38             	sub    $0x38,%esp
  800e3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	be 00 00 00 00       	mov    $0x0,%esi
  800e48:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	89 f7                	mov    %esi,%edi
  800e58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7e 28                	jle    800e86 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e62:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e69:	00 
  800e6a:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800e71:	00 
  800e72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e79:	00 
  800e7a:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800e81:	e8 1e f4 ff ff       	call   8002a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8f:	89 ec                	mov    %ebp,%esp
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 38             	sub    $0x38,%esp
  800e99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ea7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eaa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	7e 28                	jle    800ee4 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed7:	00 
  800ed8:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800edf:	e8 c0 f3 ff ff       	call   8002a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eed:	89 ec                	mov    %ebp,%esp
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 38             	sub    $0x38,%esp
  800ef7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	89 df                	mov    %ebx,%edi
  800f12:	89 de                	mov    %ebx,%esi
  800f14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7e 28                	jle    800f42 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f25:	00 
  800f26:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f35:	00 
  800f36:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800f3d:	e8 62 f3 ff ff       	call   8002a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f42:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f45:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f48:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4b:	89 ec                	mov    %ebp,%esp
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 38             	sub    $0x38,%esp
  800f55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f63:	b8 08 00 00 00       	mov    $0x8,%eax
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	89 df                	mov    %ebx,%edi
  800f70:	89 de                	mov    %ebx,%esi
  800f72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	7e 28                	jle    800fa0 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f83:	00 
  800f84:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800f9b:	e8 04 f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fa0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa9:	89 ec                	mov    %ebp,%esp
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 38             	sub    $0x38,%esp
  800fb3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 df                	mov    %ebx,%edi
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 28                	jle    800ffe <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fda:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  800ff9:	e8 a6 f2 ff ff       	call   8002a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ffe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801001:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801004:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801007:	89 ec                	mov    %ebp,%esp
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801014:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801017:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101a:	be 00 00 00 00       	mov    $0x0,%esi
  80101f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801024:	8b 7d 14             	mov    0x14(%ebp),%edi
  801027:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80102a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801032:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801035:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801038:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80103b:	89 ec                	mov    %ebp,%esp
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	83 ec 38             	sub    $0x38,%esp
  801045:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801048:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80104b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801053:	b8 0c 00 00 00       	mov    $0xc,%eax
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	89 cb                	mov    %ecx,%ebx
  80105d:	89 cf                	mov    %ecx,%edi
  80105f:	89 ce                	mov    %ecx,%esi
  801061:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801063:	85 c0                	test   %eax,%eax
  801065:	7e 28                	jle    80108f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801067:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801072:	00 
  801073:	c7 44 24 08 68 16 80 	movl   $0x801668,0x8(%esp)
  80107a:	00 
  80107b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801082:	00 
  801083:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  80108a:	e8 15 f2 ff ff       	call   8002a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80108f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801092:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801095:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801098:	89 ec                	mov    %ebp,%esp
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    
  80109c:	00 00                	add    %al,(%eax)
	...

008010a0 <__udivdi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ff                	test   %edi,%edi
  8010bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cd                	mov    %ecx,%ebp
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	75 33                	jne    801100 <__udivdi3+0x60>
  8010cd:	39 f1                	cmp    %esi,%ecx
  8010cf:	77 57                	ja     801128 <__udivdi3+0x88>
  8010d1:	85 c9                	test   %ecx,%ecx
  8010d3:	75 0b                	jne    8010e0 <__udivdi3+0x40>
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	31 d2                	xor    %edx,%edx
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 c1                	mov    %eax,%ecx
  8010e0:	89 f0                	mov    %esi,%eax
  8010e2:	31 d2                	xor    %edx,%edx
  8010e4:	f7 f1                	div    %ecx
  8010e6:	89 c6                	mov    %eax,%esi
  8010e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 f2                	mov    %esi,%edx
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	31 d2                	xor    %edx,%edx
  801102:	31 c0                	xor    %eax,%eax
  801104:	39 f7                	cmp    %esi,%edi
  801106:	77 e8                	ja     8010f0 <__udivdi3+0x50>
  801108:	0f bd cf             	bsr    %edi,%ecx
  80110b:	83 f1 1f             	xor    $0x1f,%ecx
  80110e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801112:	75 2c                	jne    801140 <__udivdi3+0xa0>
  801114:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801118:	76 04                	jbe    80111e <__udivdi3+0x7e>
  80111a:	39 f7                	cmp    %esi,%edi
  80111c:	73 d2                	jae    8010f0 <__udivdi3+0x50>
  80111e:	31 d2                	xor    %edx,%edx
  801120:	b8 01 00 00 00       	mov    $0x1,%eax
  801125:	eb c9                	jmp    8010f0 <__udivdi3+0x50>
  801127:	90                   	nop
  801128:	89 f2                	mov    %esi,%edx
  80112a:	f7 f1                	div    %ecx
  80112c:	31 d2                	xor    %edx,%edx
  80112e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801132:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801136:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113a:	83 c4 1c             	add    $0x1c,%esp
  80113d:	c3                   	ret    
  80113e:	66 90                	xchg   %ax,%ax
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	b8 20 00 00 00       	mov    $0x20,%eax
  80114a:	89 ea                	mov    %ebp,%edx
  80114c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 c1                	mov    %eax,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	09 fa                	or     %edi,%edx
  80115d:	89 f7                	mov    %esi,%edi
  80115f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801163:	89 f2                	mov    %esi,%edx
  801165:	8b 74 24 08          	mov    0x8(%esp),%esi
  801169:	d3 e5                	shl    %cl,%ebp
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	d3 ef                	shr    %cl,%edi
  80116f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	89 c1                	mov    %eax,%ecx
  801178:	d3 ee                	shr    %cl,%esi
  80117a:	09 d6                	or     %edx,%esi
  80117c:	89 fa                	mov    %edi,%edx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	f7 74 24 0c          	divl   0xc(%esp)
  801184:	89 d7                	mov    %edx,%edi
  801186:	89 c6                	mov    %eax,%esi
  801188:	f7 e5                	mul    %ebp
  80118a:	39 d7                	cmp    %edx,%edi
  80118c:	72 22                	jb     8011b0 <__udivdi3+0x110>
  80118e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801192:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801197:	d3 e5                	shl    %cl,%ebp
  801199:	39 c5                	cmp    %eax,%ebp
  80119b:	73 04                	jae    8011a1 <__udivdi3+0x101>
  80119d:	39 d7                	cmp    %edx,%edi
  80119f:	74 0f                	je     8011b0 <__udivdi3+0x110>
  8011a1:	89 f0                	mov    %esi,%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	e9 46 ff ff ff       	jmp    8010f0 <__udivdi3+0x50>
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	c3                   	ret    
	...

008011d0 <__umoddi3>:
  8011d0:	83 ec 1c             	sub    $0x1c,%esp
  8011d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011eb:	85 ed                	test   %ebp,%ebp
  8011ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f5:	89 cf                	mov    %ecx,%edi
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	89 f2                	mov    %esi,%edx
  8011fc:	75 1a                	jne    801218 <__umoddi3+0x48>
  8011fe:	39 f1                	cmp    %esi,%ecx
  801200:	76 4e                	jbe    801250 <__umoddi3+0x80>
  801202:	f7 f1                	div    %ecx
  801204:	89 d0                	mov    %edx,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801210:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801214:	83 c4 1c             	add    $0x1c,%esp
  801217:	c3                   	ret    
  801218:	39 f5                	cmp    %esi,%ebp
  80121a:	77 54                	ja     801270 <__umoddi3+0xa0>
  80121c:	0f bd c5             	bsr    %ebp,%eax
  80121f:	83 f0 1f             	xor    $0x1f,%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	75 60                	jne    801288 <__umoddi3+0xb8>
  801228:	3b 0c 24             	cmp    (%esp),%ecx
  80122b:	0f 87 07 01 00 00    	ja     801338 <__umoddi3+0x168>
  801231:	89 f2                	mov    %esi,%edx
  801233:	8b 34 24             	mov    (%esp),%esi
  801236:	29 ce                	sub    %ecx,%esi
  801238:	19 ea                	sbb    %ebp,%edx
  80123a:	89 34 24             	mov    %esi,(%esp)
  80123d:	8b 04 24             	mov    (%esp),%eax
  801240:	8b 74 24 10          	mov    0x10(%esp),%esi
  801244:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801248:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	c3                   	ret    
  801250:	85 c9                	test   %ecx,%ecx
  801252:	75 0b                	jne    80125f <__umoddi3+0x8f>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f1                	div    %ecx
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 f0                	mov    %esi,%eax
  801261:	31 d2                	xor    %edx,%edx
  801263:	f7 f1                	div    %ecx
  801265:	8b 04 24             	mov    (%esp),%eax
  801268:	f7 f1                	div    %ecx
  80126a:	eb 98                	jmp    801204 <__umoddi3+0x34>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 f2                	mov    %esi,%edx
  801272:	8b 74 24 10          	mov    0x10(%esp),%esi
  801276:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	c3                   	ret    
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128d:	89 e8                	mov    %ebp,%eax
  80128f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801294:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 e0                	shl    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 ea                	shr    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 c2                	or     %eax,%edx
  8012a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ab:	89 14 24             	mov    %edx,(%esp)
  8012ae:	89 f2                	mov    %esi,%edx
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 e9                	mov    %ebp,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	d3 e6                	shl    %cl,%esi
  8012c1:	89 e9                	mov    %ebp,%ecx
  8012c3:	d3 e8                	shr    %cl,%eax
  8012c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ca:	09 f0                	or     %esi,%eax
  8012cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012d0:	f7 34 24             	divl   (%esp)
  8012d3:	d3 e6                	shl    %cl,%esi
  8012d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d9:	89 d6                	mov    %edx,%esi
  8012db:	f7 e7                	mul    %edi
  8012dd:	39 d6                	cmp    %edx,%esi
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 d7                	mov    %edx,%edi
  8012e3:	72 3f                	jb     801324 <__umoddi3+0x154>
  8012e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012e9:	72 35                	jb     801320 <__umoddi3+0x150>
  8012eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ef:	29 c8                	sub    %ecx,%eax
  8012f1:	19 fe                	sbb    %edi,%esi
  8012f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	d3 e8                	shr    %cl,%eax
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801305:	09 d0                	or     %edx,%eax
  801307:	89 f2                	mov    %esi,%edx
  801309:	d3 ea                	shr    %cl,%edx
  80130b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80130f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801313:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	c3                   	ret    
  80131b:	90                   	nop
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 d6                	cmp    %edx,%esi
  801322:	75 c7                	jne    8012eb <__umoddi3+0x11b>
  801324:	89 d7                	mov    %edx,%edi
  801326:	89 c1                	mov    %eax,%ecx
  801328:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80132c:	1b 3c 24             	sbb    (%esp),%edi
  80132f:	eb ba                	jmp    8012eb <__umoddi3+0x11b>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 f5                	cmp    %esi,%ebp
  80133a:	0f 82 f1 fe ff ff    	jb     801231 <__umoddi3+0x61>
  801340:	e9 f8 fe ff ff       	jmp    80123d <__umoddi3+0x6d>
