
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800066:	e8 09 01 00 00       	call   800174 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 61 00 00 00       	call   800117 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 38             	sub    $0x38,%esp
  80011d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  800162:	e8 d5 02 00 00       	call   80043c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80016d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80017d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800180:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 02 00 00 00       	mov    $0x2,%eax
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 d3                	mov    %edx,%ebx
  800191:	89 d7                	mov    %edx,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800197:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a0:	89 ec                	mov    %ebp,%esp
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_yield>:

void
sys_yield(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	89 d3                	mov    %edx,%ebx
  8001c1:	89 d7                	mov    %edx,%edi
  8001c3:	89 d6                	mov    %edx,%esi
  8001c5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d0:	89 ec                	mov    %ebp,%esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 38             	sub    $0x38,%esp
  8001da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	be 00 00 00 00       	mov    $0x0,%esi
  8001e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	89 f7                	mov    %esi,%edi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  800221:	e8 16 02 00 00       	call   80043c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800226:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800229:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80022c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 38             	sub    $0x38,%esp
  800239:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80023c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	b8 05 00 00 00       	mov    $0x5,%eax
  800247:	8b 75 18             	mov    0x18(%ebp),%esi
  80024a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 28                	jle    800284 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800260:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800267:	00 
  800268:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  80026f:	00 
  800270:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800277:	00 
  800278:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  80027f:	e8 b8 01 00 00       	call   80043c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800284:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800287:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80028a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80028d:	89 ec                	mov    %ebp,%esp
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 38             	sub    $0x38,%esp
  800297:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80029a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80029d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 df                	mov    %ebx,%edi
  8002b2:	89 de                	mov    %ebx,%esi
  8002b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 28                	jle    8002e2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002be:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  8002dd:	e8 5a 01 00 00       	call   80043c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002eb:	89 ec                	mov    %ebp,%esp
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 38             	sub    $0x38,%esp
  8002f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	b8 08 00 00 00       	mov    $0x8,%eax
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	89 df                	mov    %ebx,%edi
  800310:	89 de                	mov    %ebx,%esi
  800312:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7e 28                	jle    800340 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800323:	00 
  800324:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  80032b:	00 
  80032c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800333:	00 
  800334:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  80033b:	e8 fc 00 00 00       	call   80043c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800340:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800343:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800346:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800349:	89 ec                	mov    %ebp,%esp
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 38             	sub    $0x38,%esp
  800353:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800356:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800359:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800361:	b8 09 00 00 00       	mov    $0x9,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 df                	mov    %ebx,%edi
  80036e:	89 de                	mov    %ebx,%esi
  800370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  800399:	e8 9e 00 00 00       	call   80043c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a7:	89 ec                	mov    %ebp,%esp
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 0c             	sub    $0xc,%esp
  8003b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ba:	be 00 00 00 00       	mov    $0x0,%esi
  8003bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003db:	89 ec                	mov    %ebp,%esp
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 38             	sub    $0x38,%esp
  8003e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	89 cb                	mov    %ecx,%ebx
  8003fd:	89 cf                	mov    %ecx,%edi
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	7e 28                	jle    80042f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800412:	00 
  800413:	c7 44 24 08 98 11 80 	movl   $0x801198,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 b5 11 80 00 	movl   $0x8011b5,(%esp)
  80042a:	e8 0d 00 00 00       	call   80043c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800432:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800438:	89 ec                	mov    %ebp,%esp
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800444:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800447:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80044d:	e8 22 fd ff ff       	call   800174 <sys_getenvid>
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 54 24 10          	mov    %edx,0x10(%esp)
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800460:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 c4 11 80 00 	movl   $0x8011c4,(%esp)
  80046f:	e8 c3 00 00 00       	call   800537 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800474:	89 74 24 04          	mov    %esi,0x4(%esp)
  800478:	8b 45 10             	mov    0x10(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 53 00 00 00       	call   8004d6 <vcprintf>
	cprintf("\n");
  800483:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  80048a:	e8 a8 00 00 00       	call   800537 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048f:	cc                   	int3   
  800490:	eb fd                	jmp    80048f <_panic+0x53>
	...

00800494 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	53                   	push   %ebx
  800498:	83 ec 14             	sub    $0x14,%esp
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049e:	8b 03                	mov    (%ebx),%eax
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a7:	83 c0 01             	add    $0x1,%eax
  8004aa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b1:	75 19                	jne    8004cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ba:	00 
  8004bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	e8 f2 fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8004c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d0:	83 c4 14             	add    $0x14,%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e6:	00 00 00 
	b.cnt = 0;
  8004e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800501:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 94 04 80 00 	movl   $0x800494,(%esp)
  800512:	e8 96 01 00 00       	call   8006ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 89 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  80052f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	8b 45 08             	mov    0x8(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 87 ff ff ff       	call   8004d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    
	...

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 3c             	sub    $0x3c,%esp
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	89 d7                	mov    %edx,%edi
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80057d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800580:	85 c0                	test   %eax,%eax
  800582:	75 08                	jne    80058c <printnum+0x2c>
  800584:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800587:	39 45 10             	cmp    %eax,0x10(%ebp)
  80058a:	77 59                	ja     8005e5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800590:	83 eb 01             	sub    $0x1,%ebx
  800593:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800597:	8b 45 10             	mov    0x10(%ebp),%eax
  80059a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ad:	00 
  8005ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b1:	89 04 24             	mov    %eax,(%esp)
  8005b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bb:	e8 00 09 00 00       	call   800ec0 <__udivdi3>
  8005c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005cf:	89 fa                	mov    %edi,%edx
  8005d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d4:	e8 87 ff ff ff       	call   800560 <printnum>
  8005d9:	eb 11                	jmp    8005ec <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005df:	89 34 24             	mov    %esi,(%esp)
  8005e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e5:	83 eb 01             	sub    $0x1,%ebx
  8005e8:	85 db                	test   %ebx,%ebx
  8005ea:	7f ef                	jg     8005db <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800602:	00 
  800603:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800610:	e8 db 09 00 00       	call   800ff0 <__umoddi3>
  800615:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800619:	0f be 80 e8 11 80 00 	movsbl 0x8011e8(%eax),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800626:	83 c4 3c             	add    $0x3c,%esp
  800629:	5b                   	pop    %ebx
  80062a:	5e                   	pop    %esi
  80062b:	5f                   	pop    %edi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    

0080062e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800631:	83 fa 01             	cmp    $0x1,%edx
  800634:	7e 0e                	jle    800644 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800636:	8b 10                	mov    (%eax),%edx
  800638:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063b:	89 08                	mov    %ecx,(%eax)
  80063d:	8b 02                	mov    (%edx),%eax
  80063f:	8b 52 04             	mov    0x4(%edx),%edx
  800642:	eb 22                	jmp    800666 <getuint+0x38>
	else if (lflag)
  800644:	85 d2                	test   %edx,%edx
  800646:	74 10                	je     800658 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064d:	89 08                	mov    %ecx,(%eax)
  80064f:	8b 02                	mov    (%edx),%eax
  800651:	ba 00 00 00 00       	mov    $0x0,%edx
  800656:	eb 0e                	jmp    800666 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065d:	89 08                	mov    %ecx,(%eax)
  80065f:	8b 02                	mov    (%edx),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80066e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800672:	8b 10                	mov    (%eax),%edx
  800674:	3b 50 04             	cmp    0x4(%eax),%edx
  800677:	73 0a                	jae    800683 <sprintputch+0x1b>
		*b->buf++ = ch;
  800679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067c:	88 0a                	mov    %cl,(%edx)
  80067e:	83 c2 01             	add    $0x1,%edx
  800681:	89 10                	mov    %edx,(%eax)
}
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800692:	8b 45 10             	mov    0x10(%ebp),%eax
  800695:	89 44 24 08          	mov    %eax,0x8(%esp)
  800699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	e8 02 00 00 00       	call   8006ad <vprintfmt>
	va_end(ap);
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 4c             	sub    $0x4c,%esp
  8006b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b9:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bc:	eb 12                	jmp    8006d0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	0f 84 bf 03 00 00    	je     800a85 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	89 04 24             	mov    %eax,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d0:	0f b6 06             	movzbl (%esi),%eax
  8006d3:	83 c6 01             	add    $0x1,%esi
  8006d6:	83 f8 25             	cmp    $0x25,%eax
  8006d9:	75 e3                	jne    8006be <vprintfmt+0x11>
  8006db:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006eb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fa:	eb 2b                	jmp    800727 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800703:	eb 22                	jmp    800727 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800708:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80070c:	eb 19                	jmp    800727 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800711:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800718:	eb 0d                	jmp    800727 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80071a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80071d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800720:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	0f b6 16             	movzbl (%esi),%edx
  80072a:	0f b6 c2             	movzbl %dl,%eax
  80072d:	8d 7e 01             	lea    0x1(%esi),%edi
  800730:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800733:	83 ea 23             	sub    $0x23,%edx
  800736:	80 fa 55             	cmp    $0x55,%dl
  800739:	0f 87 28 03 00 00    	ja     800a67 <vprintfmt+0x3ba>
  80073f:	0f b6 d2             	movzbl %dl,%edx
  800742:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  800749:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800753:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800758:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80075b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80075f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800762:	8d 50 d0             	lea    -0x30(%eax),%edx
  800765:	83 fa 09             	cmp    $0x9,%edx
  800768:	77 2f                	ja     800799 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80076d:	eb e9                	jmp    800758 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 04             	lea    0x4(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800780:	eb 1a                	jmp    80079c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800785:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800789:	79 9c                	jns    800727 <vprintfmt+0x7a>
  80078b:	eb 81                	jmp    80070e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800790:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800797:	eb 8e                	jmp    800727 <vprintfmt+0x7a>
  800799:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80079c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a0:	79 85                	jns    800727 <vprintfmt+0x7a>
  8007a2:	e9 73 ff ff ff       	jmp    80071a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007a7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ad:	e9 75 ff ff ff       	jmp    800727 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 50 04             	lea    0x4(%eax),%edx
  8007b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 04 24             	mov    %eax,(%esp)
  8007c4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ca:	e9 01 ff ff ff       	jmp    8006d0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	c1 fa 1f             	sar    $0x1f,%edx
  8007df:	31 d0                	xor    %edx,%eax
  8007e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007e3:	83 f8 09             	cmp    $0x9,%eax
  8007e6:	7f 0b                	jg     8007f3 <vprintfmt+0x146>
  8007e8:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	75 23                	jne    800816 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8007f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f7:	c7 44 24 08 00 12 80 	movl   $0x801200,0x8(%esp)
  8007fe:	00 
  8007ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800803:	8b 7d 08             	mov    0x8(%ebp),%edi
  800806:	89 3c 24             	mov    %edi,(%esp)
  800809:	e8 77 fe ff ff       	call   800685 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800811:	e9 ba fe ff ff       	jmp    8006d0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800816:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081a:	c7 44 24 08 09 12 80 	movl   $0x801209,0x8(%esp)
  800821:	00 
  800822:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	89 3c 24             	mov    %edi,(%esp)
  80082c:	e8 54 fe ff ff       	call   800685 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800831:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800834:	e9 97 fe ff ff       	jmp    8006d0 <vprintfmt+0x23>
  800839:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80083c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80083f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)
  80084b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80084d:	85 f6                	test   %esi,%esi
  80084f:	ba f9 11 80 00       	mov    $0x8011f9,%edx
  800854:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800857:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80085b:	0f 8e 8c 00 00 00    	jle    8008ed <vprintfmt+0x240>
  800861:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800865:	0f 84 82 00 00 00    	je     8008ed <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80086f:	89 34 24             	mov    %esi,(%esp)
  800872:	e8 b1 02 00 00       	call   800b28 <strnlen>
  800877:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80087a:	29 c2                	sub    %eax,%edx
  80087c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80087f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800883:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800886:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800889:	89 de                	mov    %ebx,%esi
  80088b:	89 d3                	mov    %edx,%ebx
  80088d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	eb 0d                	jmp    80089e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800891:	89 74 24 04          	mov    %esi,0x4(%esp)
  800895:	89 3c 24             	mov    %edi,(%esp)
  800898:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089b:	83 eb 01             	sub    $0x1,%ebx
  80089e:	85 db                	test   %ebx,%ebx
  8008a0:	7f ef                	jg     800891 <vprintfmt+0x1e4>
  8008a2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008a5:	89 f3                	mov    %esi,%ebx
  8008a7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8008b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ba:	29 c2                	sub    %eax,%edx
  8008bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008bf:	eb 2c                	jmp    8008ed <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c5:	74 18                	je     8008df <vprintfmt+0x232>
  8008c7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008ca:	83 fa 5e             	cmp    $0x5e,%edx
  8008cd:	76 10                	jbe    8008df <vprintfmt+0x232>
					putch('?', putdat);
  8008cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008da:	ff 55 08             	call   *0x8(%ebp)
  8008dd:	eb 0a                	jmp    8008e9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8008df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008ed:	0f be 06             	movsbl (%esi),%eax
  8008f0:	83 c6 01             	add    $0x1,%esi
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	74 25                	je     80091c <vprintfmt+0x26f>
  8008f7:	85 ff                	test   %edi,%edi
  8008f9:	78 c6                	js     8008c1 <vprintfmt+0x214>
  8008fb:	83 ef 01             	sub    $0x1,%edi
  8008fe:	79 c1                	jns    8008c1 <vprintfmt+0x214>
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	89 de                	mov    %ebx,%esi
  800905:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800908:	eb 1a                	jmp    800924 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80090a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80090e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800915:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800917:	83 eb 01             	sub    $0x1,%ebx
  80091a:	eb 08                	jmp    800924 <vprintfmt+0x277>
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	89 de                	mov    %ebx,%esi
  800921:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800924:	85 db                	test   %ebx,%ebx
  800926:	7f e2                	jg     80090a <vprintfmt+0x25d>
  800928:	89 7d 08             	mov    %edi,0x8(%ebp)
  80092b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800930:	e9 9b fd ff ff       	jmp    8006d0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800935:	83 f9 01             	cmp    $0x1,%ecx
  800938:	7e 10                	jle    80094a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 08             	lea    0x8(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)
  800943:	8b 30                	mov    (%eax),%esi
  800945:	8b 78 04             	mov    0x4(%eax),%edi
  800948:	eb 26                	jmp    800970 <vprintfmt+0x2c3>
	else if (lflag)
  80094a:	85 c9                	test   %ecx,%ecx
  80094c:	74 12                	je     800960 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8d 50 04             	lea    0x4(%eax),%edx
  800954:	89 55 14             	mov    %edx,0x14(%ebp)
  800957:	8b 30                	mov    (%eax),%esi
  800959:	89 f7                	mov    %esi,%edi
  80095b:	c1 ff 1f             	sar    $0x1f,%edi
  80095e:	eb 10                	jmp    800970 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8d 50 04             	lea    0x4(%eax),%edx
  800966:	89 55 14             	mov    %edx,0x14(%ebp)
  800969:	8b 30                	mov    (%eax),%esi
  80096b:	89 f7                	mov    %esi,%edi
  80096d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800970:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800975:	85 ff                	test   %edi,%edi
  800977:	0f 89 ac 00 00 00    	jns    800a29 <vprintfmt+0x37c>
				putch('-', putdat);
  80097d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800981:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800988:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80098b:	f7 de                	neg    %esi
  80098d:	83 d7 00             	adc    $0x0,%edi
  800990:	f7 df                	neg    %edi
			}
			base = 10;
  800992:	b8 0a 00 00 00       	mov    $0xa,%eax
  800997:	e9 8d 00 00 00       	jmp    800a29 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80099c:	89 ca                	mov    %ecx,%edx
  80099e:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a1:	e8 88 fc ff ff       	call   80062e <getuint>
  8009a6:	89 c6                	mov    %eax,%esi
  8009a8:	89 d7                	mov    %edx,%edi
			base = 10;
  8009aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009af:	eb 78                	jmp    800a29 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009bc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009ca:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009d8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009db:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009de:	e9 ed fc ff ff       	jmp    8006d0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8009e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009fc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800a02:	8d 50 04             	lea    0x4(%eax),%edx
  800a05:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a08:	8b 30                	mov    (%eax),%esi
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a0f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a14:	eb 13                	jmp    800a29 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a16:	89 ca                	mov    %ecx,%edx
  800a18:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1b:	e8 0e fc ff ff       	call   80062e <getuint>
  800a20:	89 c6                	mov    %eax,%esi
  800a22:	89 d7                	mov    %edx,%edi
			base = 16;
  800a24:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a29:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3c:	89 34 24             	mov    %esi,(%esp)
  800a3f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a43:	89 da                	mov    %ebx,%edx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	e8 13 fb ff ff       	call   800560 <printnum>
			break;
  800a4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a50:	e9 7b fc ff ff       	jmp    8006d0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a59:	89 04 24             	mov    %eax,(%esp)
  800a5c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a62:	e9 69 fc ff ff       	jmp    8006d0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a72:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a75:	eb 03                	jmp    800a7a <vprintfmt+0x3cd>
  800a77:	83 ee 01             	sub    $0x1,%esi
  800a7a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a7e:	75 f7                	jne    800a77 <vprintfmt+0x3ca>
  800a80:	e9 4b fc ff ff       	jmp    8006d0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a85:	83 c4 4c             	add    $0x4c,%esp
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	83 ec 28             	sub    $0x28,%esp
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a99:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a9c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aa0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aa3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	74 30                	je     800ade <vsnprintf+0x51>
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	7e 2c                	jle    800ade <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab9:	8b 45 10             	mov    0x10(%ebp),%eax
  800abc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac7:	c7 04 24 68 06 80 00 	movl   $0x800668,(%esp)
  800ace:	e8 da fb ff ff       	call   8006ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adc:	eb 05                	jmp    800ae3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ade:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    

00800ae5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aeb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af2:	8b 45 10             	mov    0x10(%ebp),%eax
  800af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	89 04 24             	mov    %eax,(%esp)
  800b06:	e8 82 ff ff ff       	call   800a8d <vsnprintf>
	va_end(ap);

	return rc;
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	eb 03                	jmp    800b20 <strlen+0x10>
		n++;
  800b1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b24:	75 f7                	jne    800b1d <strlen+0xd>
		n++;
	return n;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	eb 03                	jmp    800b3b <strnlen+0x13>
		n++;
  800b38:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3b:	39 d0                	cmp    %edx,%eax
  800b3d:	74 06                	je     800b45 <strnlen+0x1d>
  800b3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b43:	75 f3                	jne    800b38 <strnlen+0x10>
		n++;
	return n;
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b5a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b5d:	83 c2 01             	add    $0x1,%edx
  800b60:	84 c9                	test   %cl,%cl
  800b62:	75 f2                	jne    800b56 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b64:	5b                   	pop    %ebx
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b71:	89 1c 24             	mov    %ebx,(%esp)
  800b74:	e8 97 ff ff ff       	call   800b10 <strlen>
	strcpy(dst + len, src);
  800b79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b80:	01 d8                	add    %ebx,%eax
  800b82:	89 04 24             	mov    %eax,(%esp)
  800b85:	e8 bd ff ff ff       	call   800b47 <strcpy>
	return dst;
}
  800b8a:	89 d8                	mov    %ebx,%eax
  800b8c:	83 c4 08             	add    $0x8,%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba5:	eb 0f                	jmp    800bb6 <strncpy+0x24>
		*dst++ = *src;
  800ba7:	0f b6 1a             	movzbl (%edx),%ebx
  800baa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bad:	80 3a 01             	cmpb   $0x1,(%edx)
  800bb0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	39 f1                	cmp    %esi,%ecx
  800bb8:	75 ed                	jne    800ba7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	75 0a                	jne    800bdc <strlcpy+0x1e>
  800bd2:	eb 1d                	jmp    800bf1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bd4:	88 18                	mov    %bl,(%eax)
  800bd6:	83 c0 01             	add    $0x1,%eax
  800bd9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bdc:	83 ea 01             	sub    $0x1,%edx
  800bdf:	74 0b                	je     800bec <strlcpy+0x2e>
  800be1:	0f b6 19             	movzbl (%ecx),%ebx
  800be4:	84 db                	test   %bl,%bl
  800be6:	75 ec                	jne    800bd4 <strlcpy+0x16>
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	eb 02                	jmp    800bee <strlcpy+0x30>
  800bec:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bee:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bf1:	29 f0                	sub    %esi,%eax
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c00:	eb 06                	jmp    800c08 <strcmp+0x11>
		p++, q++;
  800c02:	83 c1 01             	add    $0x1,%ecx
  800c05:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c08:	0f b6 01             	movzbl (%ecx),%eax
  800c0b:	84 c0                	test   %al,%al
  800c0d:	74 04                	je     800c13 <strcmp+0x1c>
  800c0f:	3a 02                	cmp    (%edx),%al
  800c11:	74 ef                	je     800c02 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c13:	0f b6 c0             	movzbl %al,%eax
  800c16:	0f b6 12             	movzbl (%edx),%edx
  800c19:	29 d0                	sub    %edx,%eax
}
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	53                   	push   %ebx
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c2a:	eb 09                	jmp    800c35 <strncmp+0x18>
		n--, p++, q++;
  800c2c:	83 ea 01             	sub    $0x1,%edx
  800c2f:	83 c0 01             	add    $0x1,%eax
  800c32:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c35:	85 d2                	test   %edx,%edx
  800c37:	74 15                	je     800c4e <strncmp+0x31>
  800c39:	0f b6 18             	movzbl (%eax),%ebx
  800c3c:	84 db                	test   %bl,%bl
  800c3e:	74 04                	je     800c44 <strncmp+0x27>
  800c40:	3a 19                	cmp    (%ecx),%bl
  800c42:	74 e8                	je     800c2c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c44:	0f b6 00             	movzbl (%eax),%eax
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	29 d0                	sub    %edx,%eax
  800c4c:	eb 05                	jmp    800c53 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c53:	5b                   	pop    %ebx
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c60:	eb 07                	jmp    800c69 <strchr+0x13>
		if (*s == c)
  800c62:	38 ca                	cmp    %cl,%dl
  800c64:	74 0f                	je     800c75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c66:	83 c0 01             	add    $0x1,%eax
  800c69:	0f b6 10             	movzbl (%eax),%edx
  800c6c:	84 d2                	test   %dl,%dl
  800c6e:	75 f2                	jne    800c62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c81:	eb 07                	jmp    800c8a <strfind+0x13>
		if (*s == c)
  800c83:	38 ca                	cmp    %cl,%dl
  800c85:	74 0a                	je     800c91 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c87:	83 c0 01             	add    $0x1,%eax
  800c8a:	0f b6 10             	movzbl (%eax),%edx
  800c8d:	84 d2                	test   %dl,%dl
  800c8f:	75 f2                	jne    800c83 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cab:	85 c9                	test   %ecx,%ecx
  800cad:	74 30                	je     800cdf <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb5:	75 25                	jne    800cdc <memset+0x49>
  800cb7:	f6 c1 03             	test   $0x3,%cl
  800cba:	75 20                	jne    800cdc <memset+0x49>
		c &= 0xFF;
  800cbc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cbf:	89 d3                	mov    %edx,%ebx
  800cc1:	c1 e3 08             	shl    $0x8,%ebx
  800cc4:	89 d6                	mov    %edx,%esi
  800cc6:	c1 e6 18             	shl    $0x18,%esi
  800cc9:	89 d0                	mov    %edx,%eax
  800ccb:	c1 e0 10             	shl    $0x10,%eax
  800cce:	09 f0                	or     %esi,%eax
  800cd0:	09 d0                	or     %edx,%eax
  800cd2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cd4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cd7:	fc                   	cld    
  800cd8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cda:	eb 03                	jmp    800cdf <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cdc:	fc                   	cld    
  800cdd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cea:	89 ec                	mov    %ebp,%esp
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
  800cf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d03:	39 c6                	cmp    %eax,%esi
  800d05:	73 36                	jae    800d3d <memmove+0x4f>
  800d07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d0a:	39 d0                	cmp    %edx,%eax
  800d0c:	73 2f                	jae    800d3d <memmove+0x4f>
		s += n;
		d += n;
  800d0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	f6 c2 03             	test   $0x3,%dl
  800d14:	75 1b                	jne    800d31 <memmove+0x43>
  800d16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1c:	75 13                	jne    800d31 <memmove+0x43>
  800d1e:	f6 c1 03             	test   $0x3,%cl
  800d21:	75 0e                	jne    800d31 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d23:	83 ef 04             	sub    $0x4,%edi
  800d26:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d29:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d2c:	fd                   	std    
  800d2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2f:	eb 09                	jmp    800d3a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d31:	83 ef 01             	sub    $0x1,%edi
  800d34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d37:	fd                   	std    
  800d38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d3a:	fc                   	cld    
  800d3b:	eb 20                	jmp    800d5d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d43:	75 13                	jne    800d58 <memmove+0x6a>
  800d45:	a8 03                	test   $0x3,%al
  800d47:	75 0f                	jne    800d58 <memmove+0x6a>
  800d49:	f6 c1 03             	test   $0x3,%cl
  800d4c:	75 0a                	jne    800d58 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d51:	89 c7                	mov    %eax,%edi
  800d53:	fc                   	cld    
  800d54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d56:	eb 05                	jmp    800d5d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d58:	89 c7                	mov    %eax,%edi
  800d5a:	fc                   	cld    
  800d5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d63:	89 ec                	mov    %ebp,%esp
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	89 04 24             	mov    %eax,(%esp)
  800d81:	e8 68 ff ff ff       	call   800cee <memmove>
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d97:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9c:	eb 1a                	jmp    800db8 <memcmp+0x30>
		if (*s1 != *s2)
  800d9e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800da2:	83 c2 01             	add    $0x1,%edx
  800da5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800daa:	38 c8                	cmp    %cl,%al
  800dac:	74 0a                	je     800db8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800dae:	0f b6 c0             	movzbl %al,%eax
  800db1:	0f b6 c9             	movzbl %cl,%ecx
  800db4:	29 c8                	sub    %ecx,%eax
  800db6:	eb 09                	jmp    800dc1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db8:	39 da                	cmp    %ebx,%edx
  800dba:	75 e2                	jne    800d9e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dd4:	eb 07                	jmp    800ddd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd6:	38 08                	cmp    %cl,(%eax)
  800dd8:	74 07                	je     800de1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dda:	83 c0 01             	add    $0x1,%eax
  800ddd:	39 d0                	cmp    %edx,%eax
  800ddf:	72 f5                	jb     800dd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800def:	eb 03                	jmp    800df4 <strtol+0x11>
		s++;
  800df1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800df4:	0f b6 02             	movzbl (%edx),%eax
  800df7:	3c 20                	cmp    $0x20,%al
  800df9:	74 f6                	je     800df1 <strtol+0xe>
  800dfb:	3c 09                	cmp    $0x9,%al
  800dfd:	74 f2                	je     800df1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dff:	3c 2b                	cmp    $0x2b,%al
  800e01:	75 0a                	jne    800e0d <strtol+0x2a>
		s++;
  800e03:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e06:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0b:	eb 10                	jmp    800e1d <strtol+0x3a>
  800e0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e12:	3c 2d                	cmp    $0x2d,%al
  800e14:	75 07                	jne    800e1d <strtol+0x3a>
		s++, neg = 1;
  800e16:	8d 52 01             	lea    0x1(%edx),%edx
  800e19:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e1d:	85 db                	test   %ebx,%ebx
  800e1f:	0f 94 c0             	sete   %al
  800e22:	74 05                	je     800e29 <strtol+0x46>
  800e24:	83 fb 10             	cmp    $0x10,%ebx
  800e27:	75 15                	jne    800e3e <strtol+0x5b>
  800e29:	80 3a 30             	cmpb   $0x30,(%edx)
  800e2c:	75 10                	jne    800e3e <strtol+0x5b>
  800e2e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e32:	75 0a                	jne    800e3e <strtol+0x5b>
		s += 2, base = 16;
  800e34:	83 c2 02             	add    $0x2,%edx
  800e37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e3c:	eb 13                	jmp    800e51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e3e:	84 c0                	test   %al,%al
  800e40:	74 0f                	je     800e51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e47:	80 3a 30             	cmpb   $0x30,(%edx)
  800e4a:	75 05                	jne    800e51 <strtol+0x6e>
		s++, base = 8;
  800e4c:	83 c2 01             	add    $0x1,%edx
  800e4f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e58:	0f b6 0a             	movzbl (%edx),%ecx
  800e5b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e5e:	80 fb 09             	cmp    $0x9,%bl
  800e61:	77 08                	ja     800e6b <strtol+0x88>
			dig = *s - '0';
  800e63:	0f be c9             	movsbl %cl,%ecx
  800e66:	83 e9 30             	sub    $0x30,%ecx
  800e69:	eb 1e                	jmp    800e89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e6b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e6e:	80 fb 19             	cmp    $0x19,%bl
  800e71:	77 08                	ja     800e7b <strtol+0x98>
			dig = *s - 'a' + 10;
  800e73:	0f be c9             	movsbl %cl,%ecx
  800e76:	83 e9 57             	sub    $0x57,%ecx
  800e79:	eb 0e                	jmp    800e89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e7b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e7e:	80 fb 19             	cmp    $0x19,%bl
  800e81:	77 14                	ja     800e97 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800e83:	0f be c9             	movsbl %cl,%ecx
  800e86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e89:	39 f1                	cmp    %esi,%ecx
  800e8b:	7d 0e                	jge    800e9b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800e8d:	83 c2 01             	add    $0x1,%edx
  800e90:	0f af c6             	imul   %esi,%eax
  800e93:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e95:	eb c1                	jmp    800e58 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e97:	89 c1                	mov    %eax,%ecx
  800e99:	eb 02                	jmp    800e9d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ea1:	74 05                	je     800ea8 <strtol+0xc5>
		*endptr = (char *) s;
  800ea3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ea8:	89 ca                	mov    %ecx,%edx
  800eaa:	f7 da                	neg    %edx
  800eac:	85 ff                	test   %edi,%edi
  800eae:	0f 45 c2             	cmovne %edx,%eax
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
	...

00800ec0 <__udivdi3>:
  800ec0:	83 ec 1c             	sub    $0x1c,%esp
  800ec3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800ec7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800ecb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800ecf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ed3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ed7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800edb:	85 ff                	test   %edi,%edi
  800edd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ee1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee5:	89 cd                	mov    %ecx,%ebp
  800ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eeb:	75 33                	jne    800f20 <__udivdi3+0x60>
  800eed:	39 f1                	cmp    %esi,%ecx
  800eef:	77 57                	ja     800f48 <__udivdi3+0x88>
  800ef1:	85 c9                	test   %ecx,%ecx
  800ef3:	75 0b                	jne    800f00 <__udivdi3+0x40>
  800ef5:	b8 01 00 00 00       	mov    $0x1,%eax
  800efa:	31 d2                	xor    %edx,%edx
  800efc:	f7 f1                	div    %ecx
  800efe:	89 c1                	mov    %eax,%ecx
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	31 d2                	xor    %edx,%edx
  800f04:	f7 f1                	div    %ecx
  800f06:	89 c6                	mov    %eax,%esi
  800f08:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f0c:	f7 f1                	div    %ecx
  800f0e:	89 f2                	mov    %esi,%edx
  800f10:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f14:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f1c:	83 c4 1c             	add    $0x1c,%esp
  800f1f:	c3                   	ret    
  800f20:	31 d2                	xor    %edx,%edx
  800f22:	31 c0                	xor    %eax,%eax
  800f24:	39 f7                	cmp    %esi,%edi
  800f26:	77 e8                	ja     800f10 <__udivdi3+0x50>
  800f28:	0f bd cf             	bsr    %edi,%ecx
  800f2b:	83 f1 1f             	xor    $0x1f,%ecx
  800f2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f32:	75 2c                	jne    800f60 <__udivdi3+0xa0>
  800f34:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f38:	76 04                	jbe    800f3e <__udivdi3+0x7e>
  800f3a:	39 f7                	cmp    %esi,%edi
  800f3c:	73 d2                	jae    800f10 <__udivdi3+0x50>
  800f3e:	31 d2                	xor    %edx,%edx
  800f40:	b8 01 00 00 00       	mov    $0x1,%eax
  800f45:	eb c9                	jmp    800f10 <__udivdi3+0x50>
  800f47:	90                   	nop
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	f7 f1                	div    %ecx
  800f4c:	31 d2                	xor    %edx,%edx
  800f4e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f52:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f56:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	c3                   	ret    
  800f5e:	66 90                	xchg   %ax,%ax
  800f60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f65:	b8 20 00 00 00       	mov    $0x20,%eax
  800f6a:	89 ea                	mov    %ebp,%edx
  800f6c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f70:	d3 e7                	shl    %cl,%edi
  800f72:	89 c1                	mov    %eax,%ecx
  800f74:	d3 ea                	shr    %cl,%edx
  800f76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f7b:	09 fa                	or     %edi,%edx
  800f7d:	89 f7                	mov    %esi,%edi
  800f7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f89:	d3 e5                	shl    %cl,%ebp
  800f8b:	89 c1                	mov    %eax,%ecx
  800f8d:	d3 ef                	shr    %cl,%edi
  800f8f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f94:	d3 e2                	shl    %cl,%edx
  800f96:	89 c1                	mov    %eax,%ecx
  800f98:	d3 ee                	shr    %cl,%esi
  800f9a:	09 d6                	or     %edx,%esi
  800f9c:	89 fa                	mov    %edi,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	f7 74 24 0c          	divl   0xc(%esp)
  800fa4:	89 d7                	mov    %edx,%edi
  800fa6:	89 c6                	mov    %eax,%esi
  800fa8:	f7 e5                	mul    %ebp
  800faa:	39 d7                	cmp    %edx,%edi
  800fac:	72 22                	jb     800fd0 <__udivdi3+0x110>
  800fae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800fb2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fb7:	d3 e5                	shl    %cl,%ebp
  800fb9:	39 c5                	cmp    %eax,%ebp
  800fbb:	73 04                	jae    800fc1 <__udivdi3+0x101>
  800fbd:	39 d7                	cmp    %edx,%edi
  800fbf:	74 0f                	je     800fd0 <__udivdi3+0x110>
  800fc1:	89 f0                	mov    %esi,%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	e9 46 ff ff ff       	jmp    800f10 <__udivdi3+0x50>
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fd9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fdd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fe1:	83 c4 1c             	add    $0x1c,%esp
  800fe4:	c3                   	ret    
	...

00800ff0 <__umoddi3>:
  800ff0:	83 ec 1c             	sub    $0x1c,%esp
  800ff3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ff7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800ffb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800fff:	89 74 24 10          	mov    %esi,0x10(%esp)
  801003:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801007:	8b 74 24 24          	mov    0x24(%esp),%esi
  80100b:	85 ed                	test   %ebp,%ebp
  80100d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801011:	89 44 24 08          	mov    %eax,0x8(%esp)
  801015:	89 cf                	mov    %ecx,%edi
  801017:	89 04 24             	mov    %eax,(%esp)
  80101a:	89 f2                	mov    %esi,%edx
  80101c:	75 1a                	jne    801038 <__umoddi3+0x48>
  80101e:	39 f1                	cmp    %esi,%ecx
  801020:	76 4e                	jbe    801070 <__umoddi3+0x80>
  801022:	f7 f1                	div    %ecx
  801024:	89 d0                	mov    %edx,%eax
  801026:	31 d2                	xor    %edx,%edx
  801028:	8b 74 24 10          	mov    0x10(%esp),%esi
  80102c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801030:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801034:	83 c4 1c             	add    $0x1c,%esp
  801037:	c3                   	ret    
  801038:	39 f5                	cmp    %esi,%ebp
  80103a:	77 54                	ja     801090 <__umoddi3+0xa0>
  80103c:	0f bd c5             	bsr    %ebp,%eax
  80103f:	83 f0 1f             	xor    $0x1f,%eax
  801042:	89 44 24 04          	mov    %eax,0x4(%esp)
  801046:	75 60                	jne    8010a8 <__umoddi3+0xb8>
  801048:	3b 0c 24             	cmp    (%esp),%ecx
  80104b:	0f 87 07 01 00 00    	ja     801158 <__umoddi3+0x168>
  801051:	89 f2                	mov    %esi,%edx
  801053:	8b 34 24             	mov    (%esp),%esi
  801056:	29 ce                	sub    %ecx,%esi
  801058:	19 ea                	sbb    %ebp,%edx
  80105a:	89 34 24             	mov    %esi,(%esp)
  80105d:	8b 04 24             	mov    (%esp),%eax
  801060:	8b 74 24 10          	mov    0x10(%esp),%esi
  801064:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801068:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80106c:	83 c4 1c             	add    $0x1c,%esp
  80106f:	c3                   	ret    
  801070:	85 c9                	test   %ecx,%ecx
  801072:	75 0b                	jne    80107f <__umoddi3+0x8f>
  801074:	b8 01 00 00 00       	mov    $0x1,%eax
  801079:	31 d2                	xor    %edx,%edx
  80107b:	f7 f1                	div    %ecx
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 f0                	mov    %esi,%eax
  801081:	31 d2                	xor    %edx,%edx
  801083:	f7 f1                	div    %ecx
  801085:	8b 04 24             	mov    (%esp),%eax
  801088:	f7 f1                	div    %ecx
  80108a:	eb 98                	jmp    801024 <__umoddi3+0x34>
  80108c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801090:	89 f2                	mov    %esi,%edx
  801092:	8b 74 24 10          	mov    0x10(%esp),%esi
  801096:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80109a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80109e:	83 c4 1c             	add    $0x1c,%esp
  8010a1:	c3                   	ret    
  8010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ad:	89 e8                	mov    %ebp,%eax
  8010af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8010b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8010b8:	89 fa                	mov    %edi,%edx
  8010ba:	d3 e0                	shl    %cl,%eax
  8010bc:	89 e9                	mov    %ebp,%ecx
  8010be:	d3 ea                	shr    %cl,%edx
  8010c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c5:	09 c2                	or     %eax,%edx
  8010c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010cb:	89 14 24             	mov    %edx,(%esp)
  8010ce:	89 f2                	mov    %esi,%edx
  8010d0:	d3 e7                	shl    %cl,%edi
  8010d2:	89 e9                	mov    %ebp,%ecx
  8010d4:	d3 ea                	shr    %cl,%edx
  8010d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010df:	d3 e6                	shl    %cl,%esi
  8010e1:	89 e9                	mov    %ebp,%ecx
  8010e3:	d3 e8                	shr    %cl,%eax
  8010e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ea:	09 f0                	or     %esi,%eax
  8010ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010f0:	f7 34 24             	divl   (%esp)
  8010f3:	d3 e6                	shl    %cl,%esi
  8010f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010f9:	89 d6                	mov    %edx,%esi
  8010fb:	f7 e7                	mul    %edi
  8010fd:	39 d6                	cmp    %edx,%esi
  8010ff:	89 c1                	mov    %eax,%ecx
  801101:	89 d7                	mov    %edx,%edi
  801103:	72 3f                	jb     801144 <__umoddi3+0x154>
  801105:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801109:	72 35                	jb     801140 <__umoddi3+0x150>
  80110b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80110f:	29 c8                	sub    %ecx,%eax
  801111:	19 fe                	sbb    %edi,%esi
  801113:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801118:	89 f2                	mov    %esi,%edx
  80111a:	d3 e8                	shr    %cl,%eax
  80111c:	89 e9                	mov    %ebp,%ecx
  80111e:	d3 e2                	shl    %cl,%edx
  801120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801125:	09 d0                	or     %edx,%eax
  801127:	89 f2                	mov    %esi,%edx
  801129:	d3 ea                	shr    %cl,%edx
  80112b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80112f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801133:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801137:	83 c4 1c             	add    $0x1c,%esp
  80113a:	c3                   	ret    
  80113b:	90                   	nop
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	39 d6                	cmp    %edx,%esi
  801142:	75 c7                	jne    80110b <__umoddi3+0x11b>
  801144:	89 d7                	mov    %edx,%edi
  801146:	89 c1                	mov    %eax,%ecx
  801148:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80114c:	1b 3c 24             	sbb    (%esp),%edi
  80114f:	eb ba                	jmp    80110b <__umoddi3+0x11b>
  801151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801158:	39 f5                	cmp    %esi,%ebp
  80115a:	0f 82 f1 fe ff ff    	jb     801051 <__umoddi3+0x61>
  801160:	e9 f8 fe ff ff       	jmp    80105d <__umoddi3+0x6d>
