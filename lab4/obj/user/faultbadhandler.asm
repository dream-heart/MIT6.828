
obj/user/faultbadhandler：     文件格式 elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 a2 01 00 00       	call   8001f8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 07 03 00 00       	call   800371 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
  800076:	66 90                	xchg   %ax,%ax

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80008a:	e8 09 01 00 00       	call   800198 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
  8000c7:	90                   	nop

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 61 00 00 00       	call   80013b <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 c3                	mov    %eax,%ebx
  8000f8:	89 c7                	mov    %eax,%edi
  8000fa:	89 c6                	mov    %eax,%esi
  8000fc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800101:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800104:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_cgetc>:

int
sys_cgetc(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 01 00 00 00       	mov    $0x1,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800131:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800134:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800137:	89 ec                	mov    %ebp,%esp
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 38             	sub    $0x38,%esp
  800141:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800144:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800147:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014f:	b8 03 00 00 00       	mov    $0x3,%eax
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	89 cb                	mov    %ecx,%ebx
  800159:	89 cf                	mov    %ecx,%edi
  80015b:	89 ce                	mov    %ecx,%esi
  80015d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80015f:	85 c0                	test   %eax,%eax
  800161:	7e 28                	jle    80018b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800163:	89 44 24 10          	mov    %eax,0x10(%esp)
  800167:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80016e:	00 
  80016f:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  800186:	e8 d5 02 00 00       	call   800460 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80018b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 d3                	mov    %edx,%ebx
  8001b5:	89 d7                	mov    %edx,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_yield>:

void
sys_yield(void)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 d3                	mov    %edx,%ebx
  8001e5:	89 d7                	mov    %edx,%edi
  8001e7:	89 d6                	mov    %edx,%esi
  8001e9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 38             	sub    $0x38,%esp
  8001fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800201:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800204:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	be 00 00 00 00       	mov    $0x0,%esi
  80020c:	b8 04 00 00 00       	mov    $0x4,%eax
  800211:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	89 f7                	mov    %esi,%edi
  80021c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 28                	jle    80024a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	89 44 24 10          	mov    %eax,0x10(%esp)
  800226:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80022d:	00 
  80022e:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  800235:	00 
  800236:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023d:	00 
  80023e:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  800245:	e8 16 02 00 00       	call   800460 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80024a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80024d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800250:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800253:	89 ec                	mov    %ebp,%esp
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 38             	sub    $0x38,%esp
  80025d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800260:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800263:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	b8 05 00 00 00       	mov    $0x5,%eax
  80026b:	8b 75 18             	mov    0x18(%ebp),%esi
  80026e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800271:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 28                	jle    8002a8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	89 44 24 10          	mov    %eax,0x10(%esp)
  800284:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80028b:	00 
  80028c:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  8002a3:	e8 b8 01 00 00       	call   800460 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b1:	89 ec                	mov    %ebp,%esp
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 38             	sub    $0x38,%esp
  8002bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 28                	jle    800306 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002e9:	00 
  8002ea:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f9:	00 
  8002fa:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  800301:	e8 5a 01 00 00       	call   800460 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800309:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80030c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80030f:	89 ec                	mov    %ebp,%esp
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 38             	sub    $0x38,%esp
  800319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80031c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80031f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 08 00 00 00       	mov    $0x8,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  80035f:	e8 fc 00 00 00       	call   800460 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800364:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800367:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80036a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80036d:	89 ec                	mov    %ebp,%esp
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 38             	sub    $0x38,%esp
  800377:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80037a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80037d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	bb 00 00 00 00       	mov    $0x0,%ebx
  800385:	b8 09 00 00 00       	mov    $0x9,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	89 df                	mov    %ebx,%edi
  800392:	89 de                	mov    %ebx,%esi
  800394:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800396:	85 c0                	test   %eax,%eax
  800398:	7e 28                	jle    8003c2 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003a5:	00 
  8003a6:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b5:	00 
  8003b6:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  8003bd:	e8 9e 00 00 00       	call   800460 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cb:	89 ec                	mov    %ebp,%esp
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 0c             	sub    $0xc,%esp
  8003d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	be 00 00 00 00       	mov    $0x0,%esi
  8003e3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003ff:	89 ec                	mov    %ebp,%esp
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 38             	sub    $0x38,%esp
  800409:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80040c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80040f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	b8 0c 00 00 00       	mov    $0xc,%eax
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	89 cb                	mov    %ecx,%ebx
  800421:	89 cf                	mov    %ecx,%edi
  800423:	89 ce                	mov    %ecx,%esi
  800425:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800427:	85 c0                	test   %eax,%eax
  800429:	7e 28                	jle    800453 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80042b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800436:	00 
  800437:	c7 44 24 08 8a 11 80 	movl   $0x80118a,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 a7 11 80 00 	movl   $0x8011a7,(%esp)
  80044e:	e8 0d 00 00 00       	call   800460 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800453:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800456:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800459:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80045c:	89 ec                	mov    %ebp,%esp
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800471:	e8 22 fd ff ff       	call   800198 <sys_getenvid>
  800476:	8b 55 0c             	mov    0xc(%ebp),%edx
  800479:	89 54 24 10          	mov    %edx,0x10(%esp)
  80047d:	8b 55 08             	mov    0x8(%ebp),%edx
  800480:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  800493:	e8 c3 00 00 00       	call   80055b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800498:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049c:	8b 45 10             	mov    0x10(%ebp),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	e8 53 00 00 00       	call   8004fa <vcprintf>
	cprintf("\n");
  8004a7:	c7 04 24 dc 11 80 00 	movl   $0x8011dc,(%esp)
  8004ae:	e8 a8 00 00 00       	call   80055b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b3:	cc                   	int3   
  8004b4:	eb fd                	jmp    8004b3 <_panic+0x53>
  8004b6:	66 90                	xchg   %ax,%ax

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
  8004c2:	8b 03                	mov    (%ebx),%eax
  8004c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004cb:	83 c0 01             	add    $0x1,%eax
  8004ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d5:	75 19                	jne    8004f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004de:	00 
  8004df:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	e8 f2 fb ff ff       	call   8000dc <sys_cputs>
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
  800536:	e8 92 01 00 00       	call   8006cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 89 fb ff ff       	call   8000dc <sys_cputs>

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
  800591:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	75 08                	jne    8005ac <printnum+0x2c>
  8005a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005aa:	77 59                	ja     800605 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005b0:	83 eb 01             	sub    $0x1,%ebx
  8005b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005be:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005c2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005c6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005cd:	00 
  8005ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	e8 00 09 00 00       	call   800ee0 <__udivdi3>
  8005e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	89 fa                	mov    %edi,%edx
  8005f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f4:	e8 87 ff ff ff       	call   800580 <printnum>
  8005f9:	eb 11                	jmp    80060c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ff:	89 34 24             	mov    %esi,(%esp)
  800602:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800605:	83 eb 01             	sub    $0x1,%ebx
  800608:	85 db                	test   %ebx,%ebx
  80060a:	7f ef                	jg     8005fb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800610:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800622:	00 
  800623:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	e8 db 09 00 00       	call   801010 <__umoddi3>
  800635:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800639:	0f be 80 de 11 80 00 	movsbl 0x8011de(%eax),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800646:	83 c4 3c             	add    $0x3c,%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800651:	83 fa 01             	cmp    $0x1,%edx
  800654:	7e 0e                	jle    800664 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800656:	8b 10                	mov    (%eax),%edx
  800658:	8d 4a 08             	lea    0x8(%edx),%ecx
  80065b:	89 08                	mov    %ecx,(%eax)
  80065d:	8b 02                	mov    (%edx),%eax
  80065f:	8b 52 04             	mov    0x4(%edx),%edx
  800662:	eb 22                	jmp    800686 <getuint+0x38>
	else if (lflag)
  800664:	85 d2                	test   %edx,%edx
  800666:	74 10                	je     800678 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
  800676:	eb 0e                	jmp    800686 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800678:	8b 10                	mov    (%eax),%edx
  80067a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067d:	89 08                	mov    %ecx,(%eax)
  80067f:	8b 02                	mov    (%edx),%eax
  800681:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800686:	5d                   	pop    %ebp
  800687:	c3                   	ret    

00800688 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80068e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800692:	8b 10                	mov    (%eax),%edx
  800694:	3b 50 04             	cmp    0x4(%eax),%edx
  800697:	73 0a                	jae    8006a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  800699:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069c:	88 0a                	mov    %cl,(%edx)
  80069e:	83 c2 01             	add    $0x1,%edx
  8006a1:	89 10                	mov    %edx,(%eax)
}
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	89 04 24             	mov    %eax,(%esp)
  8006c6:	e8 02 00 00 00       	call   8006cd <vprintfmt>
	va_end(ap);
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	57                   	push   %edi
  8006d1:	56                   	push   %esi
  8006d2:	53                   	push   %ebx
  8006d3:	83 ec 4c             	sub    $0x4c,%esp
  8006d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8006dc:	eb 12                	jmp    8006f0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	0f 84 bf 03 00 00    	je     800aa5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f0:	0f b6 06             	movzbl (%esi),%eax
  8006f3:	83 c6 01             	add    $0x1,%esi
  8006f6:	83 f8 25             	cmp    $0x25,%eax
  8006f9:	75 e3                	jne    8006de <vprintfmt+0x11>
  8006fb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ff:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800706:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80070b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80071a:	eb 2b                	jmp    800747 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80071f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800723:	eb 22                	jmp    800747 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800728:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80072c:	eb 19                	jmp    800747 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800731:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800738:	eb 0d                	jmp    800747 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80073a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80073d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800740:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	0f b6 16             	movzbl (%esi),%edx
  80074a:	0f b6 c2             	movzbl %dl,%eax
  80074d:	8d 7e 01             	lea    0x1(%esi),%edi
  800750:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800753:	83 ea 23             	sub    $0x23,%edx
  800756:	80 fa 55             	cmp    $0x55,%dl
  800759:	0f 87 28 03 00 00    	ja     800a87 <vprintfmt+0x3ba>
  80075f:	0f b6 d2             	movzbl %dl,%edx
  800762:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  800769:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800773:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800778:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80077b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80077f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800782:	8d 50 d0             	lea    -0x30(%eax),%edx
  800785:	83 fa 09             	cmp    $0x9,%edx
  800788:	77 2f                	ja     8007b9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078d:	eb e9                	jmp    800778 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a0:	eb 1a                	jmp    8007bc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a9:	79 9c                	jns    800747 <vprintfmt+0x7a>
  8007ab:	eb 81                	jmp    80072e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007b0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007b7:	eb 8e                	jmp    800747 <vprintfmt+0x7a>
  8007b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c0:	79 85                	jns    800747 <vprintfmt+0x7a>
  8007c2:	e9 73 ff ff ff       	jmp    80073a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007cd:	e9 75 ff ff ff       	jmp    800747 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	8b 00                	mov    (%eax),%eax
  8007e1:	89 04 24             	mov    %eax,(%esp)
  8007e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ea:	e9 01 ff ff ff       	jmp    8006f0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	c1 fa 1f             	sar    $0x1f,%edx
  8007ff:	31 d0                	xor    %edx,%eax
  800801:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800803:	83 f8 09             	cmp    $0x9,%eax
  800806:	7f 0b                	jg     800813 <vprintfmt+0x146>
  800808:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  80080f:	85 d2                	test   %edx,%edx
  800811:	75 23                	jne    800836 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	c7 44 24 08 f6 11 80 	movl   $0x8011f6,0x8(%esp)
  80081e:	00 
  80081f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800823:	8b 7d 08             	mov    0x8(%ebp),%edi
  800826:	89 3c 24             	mov    %edi,(%esp)
  800829:	e8 77 fe ff ff       	call   8006a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800831:	e9 ba fe ff ff       	jmp    8006f0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800836:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80083a:	c7 44 24 08 ff 11 80 	movl   $0x8011ff,0x8(%esp)
  800841:	00 
  800842:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800846:	8b 7d 08             	mov    0x8(%ebp),%edi
  800849:	89 3c 24             	mov    %edi,(%esp)
  80084c:	e8 54 fe ff ff       	call   8006a5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800854:	e9 97 fe ff ff       	jmp    8006f0 <vprintfmt+0x23>
  800859:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80085c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80085f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80086d:	85 f6                	test   %esi,%esi
  80086f:	ba ef 11 80 00       	mov    $0x8011ef,%edx
  800874:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800877:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80087b:	0f 8e 8c 00 00 00    	jle    80090d <vprintfmt+0x240>
  800881:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800885:	0f 84 82 00 00 00    	je     80090d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80088f:	89 34 24             	mov    %esi,(%esp)
  800892:	e8 b1 02 00 00       	call   800b48 <strnlen>
  800897:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80089a:	29 c2                	sub    %eax,%edx
  80089c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80089f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8008a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008a9:	89 de                	mov    %ebx,%esi
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008af:	eb 0d                	jmp    8008be <vprintfmt+0x1f1>
					putch(padc, putdat);
  8008b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b5:	89 3c 24             	mov    %edi,(%esp)
  8008b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bb:	83 eb 01             	sub    $0x1,%ebx
  8008be:	85 db                	test   %ebx,%ebx
  8008c0:	7f ef                	jg     8008b1 <vprintfmt+0x1e4>
  8008c2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008c5:	89 f3                	mov    %esi,%ebx
  8008c7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8008d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008da:	29 c2                	sub    %eax,%edx
  8008dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008df:	eb 2c                	jmp    80090d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008e5:	74 18                	je     8008ff <vprintfmt+0x232>
  8008e7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008ea:	83 fa 5e             	cmp    $0x5e,%edx
  8008ed:	76 10                	jbe    8008ff <vprintfmt+0x232>
					putch('?', putdat);
  8008ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008fa:	ff 55 08             	call   *0x8(%ebp)
  8008fd:	eb 0a                	jmp    800909 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8008ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800909:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090d:	0f be 06             	movsbl (%esi),%eax
  800910:	83 c6 01             	add    $0x1,%esi
  800913:	85 c0                	test   %eax,%eax
  800915:	74 25                	je     80093c <vprintfmt+0x26f>
  800917:	85 ff                	test   %edi,%edi
  800919:	78 c6                	js     8008e1 <vprintfmt+0x214>
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	79 c1                	jns    8008e1 <vprintfmt+0x214>
  800920:	8b 7d 08             	mov    0x8(%ebp),%edi
  800923:	89 de                	mov    %ebx,%esi
  800925:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800928:	eb 1a                	jmp    800944 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80092a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800935:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800937:	83 eb 01             	sub    $0x1,%ebx
  80093a:	eb 08                	jmp    800944 <vprintfmt+0x277>
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	89 de                	mov    %ebx,%esi
  800941:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800944:	85 db                	test   %ebx,%ebx
  800946:	7f e2                	jg     80092a <vprintfmt+0x25d>
  800948:	89 7d 08             	mov    %edi,0x8(%ebp)
  80094b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800950:	e9 9b fd ff ff       	jmp    8006f0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800955:	83 f9 01             	cmp    $0x1,%ecx
  800958:	7e 10                	jle    80096a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80095a:	8b 45 14             	mov    0x14(%ebp),%eax
  80095d:	8d 50 08             	lea    0x8(%eax),%edx
  800960:	89 55 14             	mov    %edx,0x14(%ebp)
  800963:	8b 30                	mov    (%eax),%esi
  800965:	8b 78 04             	mov    0x4(%eax),%edi
  800968:	eb 26                	jmp    800990 <vprintfmt+0x2c3>
	else if (lflag)
  80096a:	85 c9                	test   %ecx,%ecx
  80096c:	74 12                	je     800980 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 30                	mov    (%eax),%esi
  800979:	89 f7                	mov    %esi,%edi
  80097b:	c1 ff 1f             	sar    $0x1f,%edi
  80097e:	eb 10                	jmp    800990 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800980:	8b 45 14             	mov    0x14(%ebp),%eax
  800983:	8d 50 04             	lea    0x4(%eax),%edx
  800986:	89 55 14             	mov    %edx,0x14(%ebp)
  800989:	8b 30                	mov    (%eax),%esi
  80098b:	89 f7                	mov    %esi,%edi
  80098d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800990:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800995:	85 ff                	test   %edi,%edi
  800997:	0f 89 ac 00 00 00    	jns    800a49 <vprintfmt+0x37c>
				putch('-', putdat);
  80099d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009a8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009ab:	f7 de                	neg    %esi
  8009ad:	83 d7 00             	adc    $0x0,%edi
  8009b0:	f7 df                	neg    %edi
			}
			base = 10;
  8009b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b7:	e9 8d 00 00 00       	jmp    800a49 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009bc:	89 ca                	mov    %ecx,%edx
  8009be:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c1:	e8 88 fc ff ff       	call   80064e <getuint>
  8009c6:	89 c6                	mov    %eax,%esi
  8009c8:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009cf:	eb 78                	jmp    800a49 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009dc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009ea:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009fe:	e9 ed fc ff ff       	jmp    8006f0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a07:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a0e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a15:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a1c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a22:	8d 50 04             	lea    0x4(%eax),%edx
  800a25:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a28:	8b 30                	mov    (%eax),%esi
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a2f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a34:	eb 13                	jmp    800a49 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a36:	89 ca                	mov    %ecx,%edx
  800a38:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3b:	e8 0e fc ff ff       	call   80064e <getuint>
  800a40:	89 c6                	mov    %eax,%esi
  800a42:	89 d7                	mov    %edx,%edi
			base = 16;
  800a44:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a49:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a4d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a54:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5c:	89 34 24             	mov    %esi,(%esp)
  800a5f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a63:	89 da                	mov    %ebx,%edx
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	e8 13 fb ff ff       	call   800580 <printnum>
			break;
  800a6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a70:	e9 7b fc ff ff       	jmp    8006f0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a79:	89 04 24             	mov    %eax,(%esp)
  800a7c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a82:	e9 69 fc ff ff       	jmp    8006f0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a8b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a92:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a95:	eb 03                	jmp    800a9a <vprintfmt+0x3cd>
  800a97:	83 ee 01             	sub    $0x1,%esi
  800a9a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a9e:	75 f7                	jne    800a97 <vprintfmt+0x3ca>
  800aa0:	e9 4b fc ff ff       	jmp    8006f0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800aa5:	83 c4 4c             	add    $0x4c,%esp
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	83 ec 28             	sub    $0x28,%esp
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800abc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ac0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aca:	85 c0                	test   %eax,%eax
  800acc:	74 30                	je     800afe <vsnprintf+0x51>
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	7e 2c                	jle    800afe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad9:	8b 45 10             	mov    0x10(%ebp),%eax
  800adc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae7:	c7 04 24 88 06 80 00 	movl   $0x800688,(%esp)
  800aee:	e8 da fb ff ff       	call   8006cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800afc:	eb 05                	jmp    800b03 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800afe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b0b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 82 ff ff ff       	call   800aad <vsnprintf>
	va_end(ap);

	return rc;
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    
  800b2d:	66 90                	xchg   %ax,%ax
  800b2f:	90                   	nop

00800b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	eb 03                	jmp    800b40 <strlen+0x10>
		n++;
  800b3d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b44:	75 f7                	jne    800b3d <strlen+0xd>
		n++;
	return n;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
  800b56:	eb 03                	jmp    800b5b <strnlen+0x13>
		n++;
  800b58:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b5b:	39 d0                	cmp    %edx,%eax
  800b5d:	74 06                	je     800b65 <strnlen+0x1d>
  800b5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b63:	75 f3                	jne    800b58 <strnlen+0x10>
		n++;
	return n;
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b7a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b7d:	83 c2 01             	add    $0x1,%edx
  800b80:	84 c9                	test   %cl,%cl
  800b82:	75 f2                	jne    800b76 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b84:	5b                   	pop    %ebx
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b91:	89 1c 24             	mov    %ebx,(%esp)
  800b94:	e8 97 ff ff ff       	call   800b30 <strlen>
	strcpy(dst + len, src);
  800b99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba0:	01 d8                	add    %ebx,%eax
  800ba2:	89 04 24             	mov    %eax,(%esp)
  800ba5:	e8 bd ff ff ff       	call   800b67 <strcpy>
	return dst;
}
  800baa:	89 d8                	mov    %ebx,%eax
  800bac:	83 c4 08             	add    $0x8,%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc5:	eb 0f                	jmp    800bd6 <strncpy+0x24>
		*dst++ = *src;
  800bc7:	0f b6 1a             	movzbl (%edx),%ebx
  800bca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bcd:	80 3a 01             	cmpb   $0x1,(%edx)
  800bd0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd3:	83 c1 01             	add    $0x1,%ecx
  800bd6:	39 f1                	cmp    %esi,%ecx
  800bd8:	75 ed                	jne    800bc7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 75 08             	mov    0x8(%ebp),%esi
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	85 d2                	test   %edx,%edx
  800bf0:	75 0a                	jne    800bfc <strlcpy+0x1e>
  800bf2:	eb 1d                	jmp    800c11 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bf4:	88 18                	mov    %bl,(%eax)
  800bf6:	83 c0 01             	add    $0x1,%eax
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bfc:	83 ea 01             	sub    $0x1,%edx
  800bff:	74 0b                	je     800c0c <strlcpy+0x2e>
  800c01:	0f b6 19             	movzbl (%ecx),%ebx
  800c04:	84 db                	test   %bl,%bl
  800c06:	75 ec                	jne    800bf4 <strlcpy+0x16>
  800c08:	89 c2                	mov    %eax,%edx
  800c0a:	eb 02                	jmp    800c0e <strlcpy+0x30>
  800c0c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c0e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c11:	29 f0                	sub    %esi,%eax
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c20:	eb 06                	jmp    800c28 <strcmp+0x11>
		p++, q++;
  800c22:	83 c1 01             	add    $0x1,%ecx
  800c25:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c28:	0f b6 01             	movzbl (%ecx),%eax
  800c2b:	84 c0                	test   %al,%al
  800c2d:	74 04                	je     800c33 <strcmp+0x1c>
  800c2f:	3a 02                	cmp    (%edx),%al
  800c31:	74 ef                	je     800c22 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c33:	0f b6 c0             	movzbl %al,%eax
  800c36:	0f b6 12             	movzbl (%edx),%edx
  800c39:	29 d0                	sub    %edx,%eax
}
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	53                   	push   %ebx
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c4a:	eb 09                	jmp    800c55 <strncmp+0x18>
		n--, p++, q++;
  800c4c:	83 ea 01             	sub    $0x1,%edx
  800c4f:	83 c0 01             	add    $0x1,%eax
  800c52:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c55:	85 d2                	test   %edx,%edx
  800c57:	74 15                	je     800c6e <strncmp+0x31>
  800c59:	0f b6 18             	movzbl (%eax),%ebx
  800c5c:	84 db                	test   %bl,%bl
  800c5e:	74 04                	je     800c64 <strncmp+0x27>
  800c60:	3a 19                	cmp    (%ecx),%bl
  800c62:	74 e8                	je     800c4c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c64:	0f b6 00             	movzbl (%eax),%eax
  800c67:	0f b6 11             	movzbl (%ecx),%edx
  800c6a:	29 d0                	sub    %edx,%eax
  800c6c:	eb 05                	jmp    800c73 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c80:	eb 07                	jmp    800c89 <strchr+0x13>
		if (*s == c)
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	74 0f                	je     800c95 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c86:	83 c0 01             	add    $0x1,%eax
  800c89:	0f b6 10             	movzbl (%eax),%edx
  800c8c:	84 d2                	test   %dl,%dl
  800c8e:	75 f2                	jne    800c82 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca1:	eb 07                	jmp    800caa <strfind+0x13>
		if (*s == c)
  800ca3:	38 ca                	cmp    %cl,%dl
  800ca5:	74 0a                	je     800cb1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	0f b6 10             	movzbl (%eax),%edx
  800cad:	84 d2                	test   %dl,%dl
  800caf:	75 f2                	jne    800ca3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cc2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ccb:	85 c9                	test   %ecx,%ecx
  800ccd:	74 30                	je     800cff <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cd5:	75 25                	jne    800cfc <memset+0x49>
  800cd7:	f6 c1 03             	test   $0x3,%cl
  800cda:	75 20                	jne    800cfc <memset+0x49>
		c &= 0xFF;
  800cdc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cdf:	89 d3                	mov    %edx,%ebx
  800ce1:	c1 e3 08             	shl    $0x8,%ebx
  800ce4:	89 d6                	mov    %edx,%esi
  800ce6:	c1 e6 18             	shl    $0x18,%esi
  800ce9:	89 d0                	mov    %edx,%eax
  800ceb:	c1 e0 10             	shl    $0x10,%eax
  800cee:	09 f0                	or     %esi,%eax
  800cf0:	09 d0                	or     %edx,%eax
  800cf2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cf4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cf7:	fc                   	cld    
  800cf8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cfa:	eb 03                	jmp    800cff <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cfc:	fc                   	cld    
  800cfd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0a:	89 ec                	mov    %ebp,%esp
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
  800d14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d17:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d23:	39 c6                	cmp    %eax,%esi
  800d25:	73 36                	jae    800d5d <memmove+0x4f>
  800d27:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d2a:	39 d0                	cmp    %edx,%eax
  800d2c:	73 2f                	jae    800d5d <memmove+0x4f>
		s += n;
		d += n;
  800d2e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d31:	f6 c2 03             	test   $0x3,%dl
  800d34:	75 1b                	jne    800d51 <memmove+0x43>
  800d36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d3c:	75 13                	jne    800d51 <memmove+0x43>
  800d3e:	f6 c1 03             	test   $0x3,%cl
  800d41:	75 0e                	jne    800d51 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d43:	83 ef 04             	sub    $0x4,%edi
  800d46:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d49:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d4c:	fd                   	std    
  800d4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d4f:	eb 09                	jmp    800d5a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d51:	83 ef 01             	sub    $0x1,%edi
  800d54:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d57:	fd                   	std    
  800d58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d5a:	fc                   	cld    
  800d5b:	eb 20                	jmp    800d7d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d63:	75 13                	jne    800d78 <memmove+0x6a>
  800d65:	a8 03                	test   $0x3,%al
  800d67:	75 0f                	jne    800d78 <memmove+0x6a>
  800d69:	f6 c1 03             	test   $0x3,%cl
  800d6c:	75 0a                	jne    800d78 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d6e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d71:	89 c7                	mov    %eax,%edi
  800d73:	fc                   	cld    
  800d74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d76:	eb 05                	jmp    800d7d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d78:	89 c7                	mov    %eax,%edi
  800d7a:	fc                   	cld    
  800d7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d80:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d83:	89 ec                	mov    %ebp,%esp
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	89 04 24             	mov    %eax,(%esp)
  800da1:	e8 68 ff ff ff       	call   800d0e <memmove>
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbc:	eb 1a                	jmp    800dd8 <memcmp+0x30>
		if (*s1 != *s2)
  800dbe:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800dc2:	83 c2 01             	add    $0x1,%edx
  800dc5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800dca:	38 c8                	cmp    %cl,%al
  800dcc:	74 0a                	je     800dd8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800dce:	0f b6 c0             	movzbl %al,%eax
  800dd1:	0f b6 c9             	movzbl %cl,%ecx
  800dd4:	29 c8                	sub    %ecx,%eax
  800dd6:	eb 09                	jmp    800de1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd8:	39 da                	cmp    %ebx,%edx
  800dda:	75 e2                	jne    800dbe <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
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
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
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
  800e14:	0f b6 02             	movzbl (%edx),%eax
  800e17:	3c 20                	cmp    $0x20,%al
  800e19:	74 f6                	je     800e11 <strtol+0xe>
  800e1b:	3c 09                	cmp    $0x9,%al
  800e1d:	74 f2                	je     800e11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e1f:	3c 2b                	cmp    $0x2b,%al
  800e21:	75 0a                	jne    800e2d <strtol+0x2a>
		s++;
  800e23:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e26:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2b:	eb 10                	jmp    800e3d <strtol+0x3a>
  800e2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e32:	3c 2d                	cmp    $0x2d,%al
  800e34:	75 07                	jne    800e3d <strtol+0x3a>
		s++, neg = 1;
  800e36:	8d 52 01             	lea    0x1(%edx),%edx
  800e39:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e3d:	85 db                	test   %ebx,%ebx
  800e3f:	0f 94 c0             	sete   %al
  800e42:	74 05                	je     800e49 <strtol+0x46>
  800e44:	83 fb 10             	cmp    $0x10,%ebx
  800e47:	75 15                	jne    800e5e <strtol+0x5b>
  800e49:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4c:	75 10                	jne    800e5e <strtol+0x5b>
  800e4e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e52:	75 0a                	jne    800e5e <strtol+0x5b>
		s += 2, base = 16;
  800e54:	83 c2 02             	add    $0x2,%edx
  800e57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e5c:	eb 13                	jmp    800e71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e5e:	84 c0                	test   %al,%al
  800e60:	74 0f                	je     800e71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e67:	80 3a 30             	cmpb   $0x30,(%edx)
  800e6a:	75 05                	jne    800e71 <strtol+0x6e>
		s++, base = 8;
  800e6c:	83 c2 01             	add    $0x1,%edx
  800e6f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e78:	0f b6 0a             	movzbl (%edx),%ecx
  800e7b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e7e:	80 fb 09             	cmp    $0x9,%bl
  800e81:	77 08                	ja     800e8b <strtol+0x88>
			dig = *s - '0';
  800e83:	0f be c9             	movsbl %cl,%ecx
  800e86:	83 e9 30             	sub    $0x30,%ecx
  800e89:	eb 1e                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e8b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e8e:	80 fb 19             	cmp    $0x19,%bl
  800e91:	77 08                	ja     800e9b <strtol+0x98>
			dig = *s - 'a' + 10;
  800e93:	0f be c9             	movsbl %cl,%ecx
  800e96:	83 e9 57             	sub    $0x57,%ecx
  800e99:	eb 0e                	jmp    800ea9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e9b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e9e:	80 fb 19             	cmp    $0x19,%bl
  800ea1:	77 14                	ja     800eb7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ea3:	0f be c9             	movsbl %cl,%ecx
  800ea6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ea9:	39 f1                	cmp    %esi,%ecx
  800eab:	7d 0e                	jge    800ebb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800ead:	83 c2 01             	add    $0x1,%edx
  800eb0:	0f af c6             	imul   %esi,%eax
  800eb3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800eb5:	eb c1                	jmp    800e78 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	eb 02                	jmp    800ebd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ebb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ebd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec1:	74 05                	je     800ec8 <strtol+0xc5>
		*endptr = (char *) s;
  800ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ec6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ec8:	89 ca                	mov    %ecx,%edx
  800eca:	f7 da                	neg    %edx
  800ecc:	85 ff                	test   %edi,%edi
  800ece:	0f 45 c2             	cmovne %edx,%eax
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
  800ed6:	66 90                	xchg   %ax,%ax
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__udivdi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	83 ec 0c             	sub    $0xc,%esp
  800ee6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800eee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ef2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800efc:	89 ea                	mov    %ebp,%edx
  800efe:	89 0c 24             	mov    %ecx,(%esp)
  800f01:	75 2d                	jne    800f30 <__udivdi3+0x50>
  800f03:	39 e9                	cmp    %ebp,%ecx
  800f05:	77 61                	ja     800f68 <__udivdi3+0x88>
  800f07:	85 c9                	test   %ecx,%ecx
  800f09:	89 ce                	mov    %ecx,%esi
  800f0b:	75 0b                	jne    800f18 <__udivdi3+0x38>
  800f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f12:	31 d2                	xor    %edx,%edx
  800f14:	f7 f1                	div    %ecx
  800f16:	89 c6                	mov    %eax,%esi
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	89 e8                	mov    %ebp,%eax
  800f1c:	f7 f6                	div    %esi
  800f1e:	89 c5                	mov    %eax,%ebp
  800f20:	89 f8                	mov    %edi,%eax
  800f22:	f7 f6                	div    %esi
  800f24:	89 ea                	mov    %ebp,%edx
  800f26:	83 c4 0c             	add    $0xc,%esp
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	39 e8                	cmp    %ebp,%eax
  800f32:	77 24                	ja     800f58 <__udivdi3+0x78>
  800f34:	0f bd e8             	bsr    %eax,%ebp
  800f37:	83 f5 1f             	xor    $0x1f,%ebp
  800f3a:	75 3c                	jne    800f78 <__udivdi3+0x98>
  800f3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f40:	39 34 24             	cmp    %esi,(%esp)
  800f43:	0f 86 9f 00 00 00    	jbe    800fe8 <__udivdi3+0x108>
  800f49:	39 d0                	cmp    %edx,%eax
  800f4b:	0f 82 97 00 00 00    	jb     800fe8 <__udivdi3+0x108>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	31 c0                	xor    %eax,%eax
  800f5c:	83 c4 0c             	add    $0xc,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	89 f8                	mov    %edi,%eax
  800f6a:	f7 f1                	div    %ecx
  800f6c:	31 d2                	xor    %edx,%edx
  800f6e:	83 c4 0c             	add    $0xc,%esp
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	8b 3c 24             	mov    (%esp),%edi
  800f7d:	d3 e0                	shl    %cl,%eax
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	b8 20 00 00 00       	mov    $0x20,%eax
  800f86:	29 e8                	sub    %ebp,%eax
  800f88:	89 c1                	mov    %eax,%ecx
  800f8a:	d3 ef                	shr    %cl,%edi
  800f8c:	89 e9                	mov    %ebp,%ecx
  800f8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f92:	8b 3c 24             	mov    (%esp),%edi
  800f95:	09 74 24 08          	or     %esi,0x8(%esp)
  800f99:	89 d6                	mov    %edx,%esi
  800f9b:	d3 e7                	shl    %cl,%edi
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	89 3c 24             	mov    %edi,(%esp)
  800fa2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fa6:	d3 ee                	shr    %cl,%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	d3 e2                	shl    %cl,%edx
  800fac:	89 c1                	mov    %eax,%ecx
  800fae:	d3 ef                	shr    %cl,%edi
  800fb0:	09 d7                	or     %edx,%edi
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	f7 74 24 08          	divl   0x8(%esp)
  800fba:	89 d6                	mov    %edx,%esi
  800fbc:	89 c7                	mov    %eax,%edi
  800fbe:	f7 24 24             	mull   (%esp)
  800fc1:	39 d6                	cmp    %edx,%esi
  800fc3:	89 14 24             	mov    %edx,(%esp)
  800fc6:	72 30                	jb     800ff8 <__udivdi3+0x118>
  800fc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	d3 e2                	shl    %cl,%edx
  800fd0:	39 c2                	cmp    %eax,%edx
  800fd2:	73 05                	jae    800fd9 <__udivdi3+0xf9>
  800fd4:	3b 34 24             	cmp    (%esp),%esi
  800fd7:	74 1f                	je     800ff8 <__udivdi3+0x118>
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	e9 7a ff ff ff       	jmp    800f5c <__udivdi3+0x7c>
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	b8 01 00 00 00       	mov    $0x1,%eax
  800fef:	e9 68 ff ff ff       	jmp    800f5c <__udivdi3+0x7c>
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	83 c4 0c             	add    $0xc,%esp
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    
  801004:	66 90                	xchg   %ax,%ax
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	83 ec 14             	sub    $0x14,%esp
  801016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80101a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80101e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801022:	89 c7                	mov    %eax,%edi
  801024:	89 44 24 04          	mov    %eax,0x4(%esp)
  801028:	8b 44 24 30          	mov    0x30(%esp),%eax
  80102c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801030:	89 34 24             	mov    %esi,(%esp)
  801033:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801037:	85 c0                	test   %eax,%eax
  801039:	89 c2                	mov    %eax,%edx
  80103b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80103f:	75 17                	jne    801058 <__umoddi3+0x48>
  801041:	39 fe                	cmp    %edi,%esi
  801043:	76 4b                	jbe    801090 <__umoddi3+0x80>
  801045:	89 c8                	mov    %ecx,%eax
  801047:	89 fa                	mov    %edi,%edx
  801049:	f7 f6                	div    %esi
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	31 d2                	xor    %edx,%edx
  80104f:	83 c4 14             	add    $0x14,%esp
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
  801056:	66 90                	xchg   %ax,%ax
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	77 54                	ja     8010b0 <__umoddi3+0xa0>
  80105c:	0f bd e8             	bsr    %eax,%ebp
  80105f:	83 f5 1f             	xor    $0x1f,%ebp
  801062:	75 5c                	jne    8010c0 <__umoddi3+0xb0>
  801064:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801068:	39 3c 24             	cmp    %edi,(%esp)
  80106b:	0f 87 e7 00 00 00    	ja     801158 <__umoddi3+0x148>
  801071:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801075:	29 f1                	sub    %esi,%ecx
  801077:	19 c7                	sbb    %eax,%edi
  801079:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80107d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801081:	8b 44 24 08          	mov    0x8(%esp),%eax
  801085:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801089:	83 c4 14             	add    $0x14,%esp
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    
  801090:	85 f6                	test   %esi,%esi
  801092:	89 f5                	mov    %esi,%ebp
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f6                	div    %esi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010a5:	31 d2                	xor    %edx,%edx
  8010a7:	f7 f5                	div    %ebp
  8010a9:	89 c8                	mov    %ecx,%eax
  8010ab:	f7 f5                	div    %ebp
  8010ad:	eb 9c                	jmp    80104b <__umoddi3+0x3b>
  8010af:	90                   	nop
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 fa                	mov    %edi,%edx
  8010b4:	83 c4 14             	add    $0x14,%esp
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
  8010bb:	90                   	nop
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	8b 04 24             	mov    (%esp),%eax
  8010c3:	be 20 00 00 00       	mov    $0x20,%esi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	29 ee                	sub    %ebp,%esi
  8010cc:	d3 e2                	shl    %cl,%edx
  8010ce:	89 f1                	mov    %esi,%ecx
  8010d0:	d3 e8                	shr    %cl,%eax
  8010d2:	89 e9                	mov    %ebp,%ecx
  8010d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d8:	8b 04 24             	mov    (%esp),%eax
  8010db:	09 54 24 04          	or     %edx,0x4(%esp)
  8010df:	89 fa                	mov    %edi,%edx
  8010e1:	d3 e0                	shl    %cl,%eax
  8010e3:	89 f1                	mov    %esi,%ecx
  8010e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010ed:	d3 ea                	shr    %cl,%edx
  8010ef:	89 e9                	mov    %ebp,%ecx
  8010f1:	d3 e7                	shl    %cl,%edi
  8010f3:	89 f1                	mov    %esi,%ecx
  8010f5:	d3 e8                	shr    %cl,%eax
  8010f7:	89 e9                	mov    %ebp,%ecx
  8010f9:	09 f8                	or     %edi,%eax
  8010fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010ff:	f7 74 24 04          	divl   0x4(%esp)
  801103:	d3 e7                	shl    %cl,%edi
  801105:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801109:	89 d7                	mov    %edx,%edi
  80110b:	f7 64 24 08          	mull   0x8(%esp)
  80110f:	39 d7                	cmp    %edx,%edi
  801111:	89 c1                	mov    %eax,%ecx
  801113:	89 14 24             	mov    %edx,(%esp)
  801116:	72 2c                	jb     801144 <__umoddi3+0x134>
  801118:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80111c:	72 22                	jb     801140 <__umoddi3+0x130>
  80111e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801122:	29 c8                	sub    %ecx,%eax
  801124:	19 d7                	sbb    %edx,%edi
  801126:	89 e9                	mov    %ebp,%ecx
  801128:	89 fa                	mov    %edi,%edx
  80112a:	d3 e8                	shr    %cl,%eax
  80112c:	89 f1                	mov    %esi,%ecx
  80112e:	d3 e2                	shl    %cl,%edx
  801130:	89 e9                	mov    %ebp,%ecx
  801132:	d3 ef                	shr    %cl,%edi
  801134:	09 d0                	or     %edx,%eax
  801136:	89 fa                	mov    %edi,%edx
  801138:	83 c4 14             	add    $0x14,%esp
  80113b:	5e                   	pop    %esi
  80113c:	5f                   	pop    %edi
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    
  80113f:	90                   	nop
  801140:	39 d7                	cmp    %edx,%edi
  801142:	75 da                	jne    80111e <__umoddi3+0x10e>
  801144:	8b 14 24             	mov    (%esp),%edx
  801147:	89 c1                	mov    %eax,%ecx
  801149:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80114d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801151:	eb cb                	jmp    80111e <__umoddi3+0x10e>
  801153:	90                   	nop
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80115c:	0f 82 0f ff ff ff    	jb     801071 <__umoddi3+0x61>
  801162:	e9 1a ff ff ff       	jmp    801081 <__umoddi3+0x71>
