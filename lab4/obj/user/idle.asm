
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 60 	movl   $0x801160,0x802000
  800041:	11 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 53 01 00 00       	call   80019c <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80005e:	e8 09 01 00 00       	call   80016c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800084:	89 34 24             	mov    %esi,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800094:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800097:	89 ec                	mov    %ebp,%esp
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 61 00 00 00       	call   80010f <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800105:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800108:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 38             	sub    $0x38,%esp
  800115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 28                	jle    80015f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800142:	00 
  800143:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  80014a:	00 
  80014b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800152:	00 
  800153:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  80015a:	e8 d5 02 00 00       	call   800434 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800162:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800165:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800178:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_yield>:

void
sys_yield(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 d3                	mov    %edx,%ebx
  8001b9:	89 d7                	mov    %edx,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 38             	sub    $0x38,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	89 f7                	mov    %esi,%edi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 28                	jle    80021e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800219:	e8 16 02 00 00       	call   800434 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 38             	sub    $0x38,%esp
  800231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	b8 05 00 00 00       	mov    $0x5,%eax
  80023f:	8b 75 18             	mov    0x18(%ebp),%esi
  800242:	8b 7d 14             	mov    0x14(%ebp),%edi
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 28                	jle    80027c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	89 44 24 10          	mov    %eax,0x10(%esp)
  800258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025f:	00 
  800260:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  800267:	00 
  800268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026f:	00 
  800270:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800277:	e8 b8 01 00 00       	call   800434 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 38             	sub    $0x38,%esp
  80028f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  8002d5:	e8 5a 01 00 00       	call   800434 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 38             	sub    $0x38,%esp
  8002ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 28                	jle    800338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	89 44 24 10          	mov    %eax,0x10(%esp)
  800314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031b:	00 
  80031c:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800333:	e8 fc 00 00 00       	call   800434 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 38             	sub    $0x38,%esp
  80034b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	b8 09 00 00 00       	mov    $0x9,%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 df                	mov    %ebx,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800391:	e8 9e 00 00 00       	call   800434 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039f:	89 ec                	mov    %ebp,%esp
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 0c             	sub    $0xc,%esp
  8003a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b2:	be 00 00 00 00       	mov    $0x0,%esi
  8003b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d3:	89 ec                	mov    %ebp,%esp
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 38             	sub    $0x38,%esp
  8003dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	89 cb                	mov    %ecx,%ebx
  8003f5:	89 cf                	mov    %ecx,%edi
  8003f7:	89 ce                	mov    %ecx,%esi
  8003f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	7e 28                	jle    800427 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800403:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040a:	00 
  80040b:	c7 44 24 08 6f 11 80 	movl   $0x80116f,0x8(%esp)
  800412:	00 
  800413:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041a:	00 
  80041b:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  800422:	e8 0d 00 00 00       	call   800434 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800427:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800430:	89 ec                	mov    %ebp,%esp
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	56                   	push   %esi
  800438:	53                   	push   %ebx
  800439:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80043c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80043f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800445:	e8 22 fd ff ff       	call   80016c <sys_getenvid>
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800451:	8b 55 08             	mov    0x8(%ebp),%edx
  800454:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800458:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  800467:	e8 c3 00 00 00       	call   80052f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800470:	8b 45 10             	mov    0x10(%ebp),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	e8 53 00 00 00       	call   8004ce <vcprintf>
	cprintf("\n");
  80047b:	c7 04 24 c0 11 80 00 	movl   $0x8011c0,(%esp)
  800482:	e8 a8 00 00 00       	call   80052f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800487:	cc                   	int3   
  800488:	eb fd                	jmp    800487 <_panic+0x53>
	...

0080048c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	53                   	push   %ebx
  800490:	83 ec 14             	sub    $0x14,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800496:	8b 03                	mov    (%ebx),%eax
  800498:	8b 55 08             	mov    0x8(%ebp),%edx
  80049b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80049f:	83 c0 01             	add    $0x1,%eax
  8004a2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a9:	75 19                	jne    8004c4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004ab:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b2:	00 
  8004b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b6:	89 04 24             	mov    %eax,(%esp)
  8004b9:	e8 f2 fb ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8004be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004c8:	83 c4 14             	add    $0x14,%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004de:	00 00 00 
	b.cnt = 0;
  8004e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800503:	c7 04 24 8c 04 80 00 	movl   $0x80048c,(%esp)
  80050a:	e8 8e 01 00 00       	call   80069d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80050f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800515:	89 44 24 04          	mov    %eax,0x4(%esp)
  800519:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 89 fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800527:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800535:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800538:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 87 ff ff ff       	call   8004ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800547:	c9                   	leave  
  800548:	c3                   	ret    
  800549:	00 00                	add    %al,(%eax)
  80054b:	00 00                	add    %al,(%eax)
  80054d:	00 00                	add    %al,(%eax)
	...

00800550 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 3c             	sub    $0x3c,%esp
  800559:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055c:	89 d7                	mov    %edx,%edi
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80056d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800570:	85 c0                	test   %eax,%eax
  800572:	75 08                	jne    80057c <printnum+0x2c>
  800574:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800577:	39 45 10             	cmp    %eax,0x10(%ebp)
  80057a:	77 59                	ja     8005d5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80057c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800587:	8b 45 10             	mov    0x10(%ebp),%eax
  80058a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800592:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800596:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80059d:	00 
  80059e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a1:	89 04 24             	mov    %eax,(%esp)
  8005a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	e8 00 09 00 00       	call   800eb0 <__udivdi3>
  8005b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bf:	89 fa                	mov    %edi,%edx
  8005c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c4:	e8 87 ff ff ff       	call   800550 <printnum>
  8005c9:	eb 11                	jmp    8005dc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005cf:	89 34 24             	mov    %esi,(%esp)
  8005d2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005d5:	83 eb 01             	sub    $0x1,%ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f ef                	jg     8005cb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f2:	00 
  8005f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f6:	89 04 24             	mov    %eax,(%esp)
  8005f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800600:	e8 db 09 00 00       	call   800fe0 <__umoddi3>
  800605:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800609:	0f be 80 c2 11 80 00 	movsbl 0x8011c2(%eax),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800616:	83 c4 3c             	add    $0x3c,%esp
  800619:	5b                   	pop    %ebx
  80061a:	5e                   	pop    %esi
  80061b:	5f                   	pop    %edi
  80061c:	5d                   	pop    %ebp
  80061d:	c3                   	ret    

0080061e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800621:	83 fa 01             	cmp    $0x1,%edx
  800624:	7e 0e                	jle    800634 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8d 4a 08             	lea    0x8(%edx),%ecx
  80062b:	89 08                	mov    %ecx,(%eax)
  80062d:	8b 02                	mov    (%edx),%eax
  80062f:	8b 52 04             	mov    0x4(%edx),%edx
  800632:	eb 22                	jmp    800656 <getuint+0x38>
	else if (lflag)
  800634:	85 d2                	test   %edx,%edx
  800636:	74 10                	je     800648 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80063d:	89 08                	mov    %ecx,(%eax)
  80063f:	8b 02                	mov    (%edx),%eax
  800641:	ba 00 00 00 00       	mov    $0x0,%edx
  800646:	eb 0e                	jmp    800656 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064d:	89 08                	mov    %ecx,(%eax)
  80064f:	8b 02                	mov    (%edx),%eax
  800651:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80065e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800662:	8b 10                	mov    (%eax),%edx
  800664:	3b 50 04             	cmp    0x4(%eax),%edx
  800667:	73 0a                	jae    800673 <sprintputch+0x1b>
		*b->buf++ = ch;
  800669:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80066c:	88 0a                	mov    %cl,(%edx)
  80066e:	83 c2 01             	add    $0x1,%edx
  800671:	89 10                	mov    %edx,(%eax)
}
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80067e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800682:	8b 45 10             	mov    0x10(%ebp),%eax
  800685:	89 44 24 08          	mov    %eax,0x8(%esp)
  800689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	e8 02 00 00 00       	call   80069d <vprintfmt>
	va_end(ap);
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	57                   	push   %edi
  8006a1:	56                   	push   %esi
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 4c             	sub    $0x4c,%esp
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	8b 75 10             	mov    0x10(%ebp),%esi
  8006ac:	eb 12                	jmp    8006c0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	0f 84 bf 03 00 00    	je     800a75 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	89 04 24             	mov    %eax,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c0:	0f b6 06             	movzbl (%esi),%eax
  8006c3:	83 c6 01             	add    $0x1,%esi
  8006c6:	83 f8 25             	cmp    $0x25,%eax
  8006c9:	75 e3                	jne    8006ae <vprintfmt+0x11>
  8006cb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006cf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006d6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006db:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ea:	eb 2b                	jmp    800717 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ef:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006f3:	eb 22                	jmp    800717 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006f8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006fc:	eb 19                	jmp    800717 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800701:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800708:	eb 0d                	jmp    800717 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80070a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80070d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800710:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	0f b6 16             	movzbl (%esi),%edx
  80071a:	0f b6 c2             	movzbl %dl,%eax
  80071d:	8d 7e 01             	lea    0x1(%esi),%edi
  800720:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800723:	83 ea 23             	sub    $0x23,%edx
  800726:	80 fa 55             	cmp    $0x55,%dl
  800729:	0f 87 28 03 00 00    	ja     800a57 <vprintfmt+0x3ba>
  80072f:	0f b6 d2             	movzbl %dl,%edx
  800732:	ff 24 95 80 12 80 00 	jmp    *0x801280(,%edx,4)
  800739:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800743:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800748:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800752:	8d 50 d0             	lea    -0x30(%eax),%edx
  800755:	83 fa 09             	cmp    $0x9,%edx
  800758:	77 2f                	ja     800789 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075d:	eb e9                	jmp    800748 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800770:	eb 1a                	jmp    80078c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800775:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800779:	79 9c                	jns    800717 <vprintfmt+0x7a>
  80077b:	eb 81                	jmp    8006fe <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800780:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800787:	eb 8e                	jmp    800717 <vprintfmt+0x7a>
  800789:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80078c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800790:	79 85                	jns    800717 <vprintfmt+0x7a>
  800792:	e9 73 ff ff ff       	jmp    80070a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800797:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80079d:	e9 75 ff ff ff       	jmp    800717 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 04             	lea    0x4(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 04 24             	mov    %eax,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ba:	e9 01 ff ff ff       	jmp    8006c0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	c1 fa 1f             	sar    $0x1f,%edx
  8007cf:	31 d0                	xor    %edx,%eax
  8007d1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007d3:	83 f8 09             	cmp    $0x9,%eax
  8007d6:	7f 0b                	jg     8007e3 <vprintfmt+0x146>
  8007d8:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	75 23                	jne    800806 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8007e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e7:	c7 44 24 08 da 11 80 	movl   $0x8011da,0x8(%esp)
  8007ee:	00 
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f6:	89 3c 24             	mov    %edi,(%esp)
  8007f9:	e8 77 fe ff ff       	call   800675 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800801:	e9 ba fe ff ff       	jmp    8006c0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800806:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080a:	c7 44 24 08 e3 11 80 	movl   $0x8011e3,0x8(%esp)
  800811:	00 
  800812:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800816:	8b 7d 08             	mov    0x8(%ebp),%edi
  800819:	89 3c 24             	mov    %edi,(%esp)
  80081c:	e8 54 fe ff ff       	call   800675 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800821:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800824:	e9 97 fe ff ff       	jmp    8006c0 <vprintfmt+0x23>
  800829:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80082c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)
  80083b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80083d:	85 f6                	test   %esi,%esi
  80083f:	ba d3 11 80 00       	mov    $0x8011d3,%edx
  800844:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800847:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80084b:	0f 8e 8c 00 00 00    	jle    8008dd <vprintfmt+0x240>
  800851:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800855:	0f 84 82 00 00 00    	je     8008dd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80085b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80085f:	89 34 24             	mov    %esi,(%esp)
  800862:	e8 b1 02 00 00       	call   800b18 <strnlen>
  800867:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80086a:	29 c2                	sub    %eax,%edx
  80086c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80086f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800873:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800876:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800879:	89 de                	mov    %ebx,%esi
  80087b:	89 d3                	mov    %edx,%ebx
  80087d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	eb 0d                	jmp    80088e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800881:	89 74 24 04          	mov    %esi,0x4(%esp)
  800885:	89 3c 24             	mov    %edi,(%esp)
  800888:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088b:	83 eb 01             	sub    $0x1,%ebx
  80088e:	85 db                	test   %ebx,%ebx
  800890:	7f ef                	jg     800881 <vprintfmt+0x1e4>
  800892:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800895:	89 f3                	mov    %esi,%ebx
  800897:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80089a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8008a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008aa:	29 c2                	sub    %eax,%edx
  8008ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008af:	eb 2c                	jmp    8008dd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008b5:	74 18                	je     8008cf <vprintfmt+0x232>
  8008b7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008ba:	83 fa 5e             	cmp    $0x5e,%edx
  8008bd:	76 10                	jbe    8008cf <vprintfmt+0x232>
					putch('?', putdat);
  8008bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ca:	ff 55 08             	call   *0x8(%ebp)
  8008cd:	eb 0a                	jmp    8008d9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8008cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008dd:	0f be 06             	movsbl (%esi),%eax
  8008e0:	83 c6 01             	add    $0x1,%esi
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	74 25                	je     80090c <vprintfmt+0x26f>
  8008e7:	85 ff                	test   %edi,%edi
  8008e9:	78 c6                	js     8008b1 <vprintfmt+0x214>
  8008eb:	83 ef 01             	sub    $0x1,%edi
  8008ee:	79 c1                	jns    8008b1 <vprintfmt+0x214>
  8008f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f3:	89 de                	mov    %ebx,%esi
  8008f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f8:	eb 1a                	jmp    800914 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800905:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800907:	83 eb 01             	sub    $0x1,%ebx
  80090a:	eb 08                	jmp    800914 <vprintfmt+0x277>
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	89 de                	mov    %ebx,%esi
  800911:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800914:	85 db                	test   %ebx,%ebx
  800916:	7f e2                	jg     8008fa <vprintfmt+0x25d>
  800918:	89 7d 08             	mov    %edi,0x8(%ebp)
  80091b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800920:	e9 9b fd ff ff       	jmp    8006c0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800925:	83 f9 01             	cmp    $0x1,%ecx
  800928:	7e 10                	jle    80093a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 08             	lea    0x8(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 30                	mov    (%eax),%esi
  800935:	8b 78 04             	mov    0x4(%eax),%edi
  800938:	eb 26                	jmp    800960 <vprintfmt+0x2c3>
	else if (lflag)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 12                	je     800950 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)
  800947:	8b 30                	mov    (%eax),%esi
  800949:	89 f7                	mov    %esi,%edi
  80094b:	c1 ff 1f             	sar    $0x1f,%edi
  80094e:	eb 10                	jmp    800960 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800950:	8b 45 14             	mov    0x14(%ebp),%eax
  800953:	8d 50 04             	lea    0x4(%eax),%edx
  800956:	89 55 14             	mov    %edx,0x14(%ebp)
  800959:	8b 30                	mov    (%eax),%esi
  80095b:	89 f7                	mov    %esi,%edi
  80095d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800960:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800965:	85 ff                	test   %edi,%edi
  800967:	0f 89 ac 00 00 00    	jns    800a19 <vprintfmt+0x37c>
				putch('-', putdat);
  80096d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800971:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800978:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80097b:	f7 de                	neg    %esi
  80097d:	83 d7 00             	adc    $0x0,%edi
  800980:	f7 df                	neg    %edi
			}
			base = 10;
  800982:	b8 0a 00 00 00       	mov    $0xa,%eax
  800987:	e9 8d 00 00 00       	jmp    800a19 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80098c:	89 ca                	mov    %ecx,%edx
  80098e:	8d 45 14             	lea    0x14(%ebp),%eax
  800991:	e8 88 fc ff ff       	call   80061e <getuint>
  800996:	89 c6                	mov    %eax,%esi
  800998:	89 d7                	mov    %edx,%edi
			base = 10;
  80099a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80099f:	eb 78                	jmp    800a19 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009ac:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009ba:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009c8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009ce:	e9 ed fc ff ff       	jmp    8006c0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8009d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009de:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ec:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f2:	8d 50 04             	lea    0x4(%eax),%edx
  8009f5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009f8:	8b 30                	mov    (%eax),%esi
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a04:	eb 13                	jmp    800a19 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a06:	89 ca                	mov    %ecx,%edx
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	e8 0e fc ff ff       	call   80061e <getuint>
  800a10:	89 c6                	mov    %eax,%esi
  800a12:	89 d7                	mov    %edx,%edi
			base = 16;
  800a14:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a19:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2c:	89 34 24             	mov    %esi,(%esp)
  800a2f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a33:	89 da                	mov    %ebx,%edx
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	e8 13 fb ff ff       	call   800550 <printnum>
			break;
  800a3d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a40:	e9 7b fc ff ff       	jmp    8006c0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a49:	89 04 24             	mov    %eax,(%esp)
  800a4c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a52:	e9 69 fc ff ff       	jmp    8006c0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a62:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a65:	eb 03                	jmp    800a6a <vprintfmt+0x3cd>
  800a67:	83 ee 01             	sub    $0x1,%esi
  800a6a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a6e:	75 f7                	jne    800a67 <vprintfmt+0x3ca>
  800a70:	e9 4b fc ff ff       	jmp    8006c0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a75:	83 c4 4c             	add    $0x4c,%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	83 ec 28             	sub    $0x28,%esp
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a8c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a90:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	74 30                	je     800ace <vsnprintf+0x51>
  800a9e:	85 d2                	test   %edx,%edx
  800aa0:	7e 2c                	jle    800ace <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  800aac:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab7:	c7 04 24 58 06 80 00 	movl   $0x800658,(%esp)
  800abe:	e8 da fb ff ff       	call   80069d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acc:	eb 05                	jmp    800ad3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ace:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    

00800ad5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800adb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ade:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 82 ff ff ff       	call   800a7d <vsnprintf>
	va_end(ap);

	return rc;
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    
  800afd:	00 00                	add    %al,(%eax)
	...

00800b00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	eb 03                	jmp    800b10 <strlen+0x10>
		n++;
  800b0d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b14:	75 f7                	jne    800b0d <strlen+0xd>
		n++;
	return n;
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	eb 03                	jmp    800b2b <strnlen+0x13>
		n++;
  800b28:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	74 06                	je     800b35 <strnlen+0x1d>
  800b2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b33:	75 f3                	jne    800b28 <strnlen+0x10>
		n++;
	return n;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b4a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b4d:	83 c2 01             	add    $0x1,%edx
  800b50:	84 c9                	test   %cl,%cl
  800b52:	75 f2                	jne    800b46 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b54:	5b                   	pop    %ebx
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b61:	89 1c 24             	mov    %ebx,(%esp)
  800b64:	e8 97 ff ff ff       	call   800b00 <strlen>
	strcpy(dst + len, src);
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b70:	01 d8                	add    %ebx,%eax
  800b72:	89 04 24             	mov    %eax,(%esp)
  800b75:	e8 bd ff ff ff       	call   800b37 <strcpy>
	return dst;
}
  800b7a:	89 d8                	mov    %ebx,%eax
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b95:	eb 0f                	jmp    800ba6 <strncpy+0x24>
		*dst++ = *src;
  800b97:	0f b6 1a             	movzbl (%edx),%ebx
  800b9a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9d:	80 3a 01             	cmpb   $0x1,(%edx)
  800ba0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba3:	83 c1 01             	add    $0x1,%ecx
  800ba6:	39 f1                	cmp    %esi,%ecx
  800ba8:	75 ed                	jne    800b97 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	85 d2                	test   %edx,%edx
  800bc0:	75 0a                	jne    800bcc <strlcpy+0x1e>
  800bc2:	eb 1d                	jmp    800be1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc4:	88 18                	mov    %bl,(%eax)
  800bc6:	83 c0 01             	add    $0x1,%eax
  800bc9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bcc:	83 ea 01             	sub    $0x1,%edx
  800bcf:	74 0b                	je     800bdc <strlcpy+0x2e>
  800bd1:	0f b6 19             	movzbl (%ecx),%ebx
  800bd4:	84 db                	test   %bl,%bl
  800bd6:	75 ec                	jne    800bc4 <strlcpy+0x16>
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	eb 02                	jmp    800bde <strlcpy+0x30>
  800bdc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bde:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800be1:	29 f0                	sub    %esi,%eax
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf0:	eb 06                	jmp    800bf8 <strcmp+0x11>
		p++, q++;
  800bf2:	83 c1 01             	add    $0x1,%ecx
  800bf5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf8:	0f b6 01             	movzbl (%ecx),%eax
  800bfb:	84 c0                	test   %al,%al
  800bfd:	74 04                	je     800c03 <strcmp+0x1c>
  800bff:	3a 02                	cmp    (%edx),%al
  800c01:	74 ef                	je     800bf2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c03:	0f b6 c0             	movzbl %al,%eax
  800c06:	0f b6 12             	movzbl (%edx),%edx
  800c09:	29 d0                	sub    %edx,%eax
}
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	53                   	push   %ebx
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c1a:	eb 09                	jmp    800c25 <strncmp+0x18>
		n--, p++, q++;
  800c1c:	83 ea 01             	sub    $0x1,%edx
  800c1f:	83 c0 01             	add    $0x1,%eax
  800c22:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c25:	85 d2                	test   %edx,%edx
  800c27:	74 15                	je     800c3e <strncmp+0x31>
  800c29:	0f b6 18             	movzbl (%eax),%ebx
  800c2c:	84 db                	test   %bl,%bl
  800c2e:	74 04                	je     800c34 <strncmp+0x27>
  800c30:	3a 19                	cmp    (%ecx),%bl
  800c32:	74 e8                	je     800c1c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c34:	0f b6 00             	movzbl (%eax),%eax
  800c37:	0f b6 11             	movzbl (%ecx),%edx
  800c3a:	29 d0                	sub    %edx,%eax
  800c3c:	eb 05                	jmp    800c43 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c43:	5b                   	pop    %ebx
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c50:	eb 07                	jmp    800c59 <strchr+0x13>
		if (*s == c)
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	74 0f                	je     800c65 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c56:	83 c0 01             	add    $0x1,%eax
  800c59:	0f b6 10             	movzbl (%eax),%edx
  800c5c:	84 d2                	test   %dl,%dl
  800c5e:	75 f2                	jne    800c52 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c71:	eb 07                	jmp    800c7a <strfind+0x13>
		if (*s == c)
  800c73:	38 ca                	cmp    %cl,%dl
  800c75:	74 0a                	je     800c81 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
  800c7d:	84 d2                	test   %dl,%dl
  800c7f:	75 f2                	jne    800c73 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c92:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c9b:	85 c9                	test   %ecx,%ecx
  800c9d:	74 30                	je     800ccf <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca5:	75 25                	jne    800ccc <memset+0x49>
  800ca7:	f6 c1 03             	test   $0x3,%cl
  800caa:	75 20                	jne    800ccc <memset+0x49>
		c &= 0xFF;
  800cac:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800caf:	89 d3                	mov    %edx,%ebx
  800cb1:	c1 e3 08             	shl    $0x8,%ebx
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	c1 e6 18             	shl    $0x18,%esi
  800cb9:	89 d0                	mov    %edx,%eax
  800cbb:	c1 e0 10             	shl    $0x10,%eax
  800cbe:	09 f0                	or     %esi,%eax
  800cc0:	09 d0                	or     %edx,%eax
  800cc2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cc4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cc7:	fc                   	cld    
  800cc8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cca:	eb 03                	jmp    800ccf <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ccc:	fc                   	cld    
  800ccd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccf:	89 f8                	mov    %edi,%eax
  800cd1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cda:	89 ec                	mov    %ebp,%esp
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 08             	sub    $0x8,%esp
  800ce4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cf3:	39 c6                	cmp    %eax,%esi
  800cf5:	73 36                	jae    800d2d <memmove+0x4f>
  800cf7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cfa:	39 d0                	cmp    %edx,%eax
  800cfc:	73 2f                	jae    800d2d <memmove+0x4f>
		s += n;
		d += n;
  800cfe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d01:	f6 c2 03             	test   $0x3,%dl
  800d04:	75 1b                	jne    800d21 <memmove+0x43>
  800d06:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d0c:	75 13                	jne    800d21 <memmove+0x43>
  800d0e:	f6 c1 03             	test   $0x3,%cl
  800d11:	75 0e                	jne    800d21 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d13:	83 ef 04             	sub    $0x4,%edi
  800d16:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d19:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d1c:	fd                   	std    
  800d1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d1f:	eb 09                	jmp    800d2a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d21:	83 ef 01             	sub    $0x1,%edi
  800d24:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d27:	fd                   	std    
  800d28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d2a:	fc                   	cld    
  800d2b:	eb 20                	jmp    800d4d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d2d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d33:	75 13                	jne    800d48 <memmove+0x6a>
  800d35:	a8 03                	test   $0x3,%al
  800d37:	75 0f                	jne    800d48 <memmove+0x6a>
  800d39:	f6 c1 03             	test   $0x3,%cl
  800d3c:	75 0a                	jne    800d48 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d3e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d41:	89 c7                	mov    %eax,%edi
  800d43:	fc                   	cld    
  800d44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d46:	eb 05                	jmp    800d4d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d48:	89 c7                	mov    %eax,%edi
  800d4a:	fc                   	cld    
  800d4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d4d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d50:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d53:	89 ec                	mov    %ebp,%esp
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	89 04 24             	mov    %eax,(%esp)
  800d71:	e8 68 ff ff ff       	call   800cde <memmove>
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	eb 1a                	jmp    800da8 <memcmp+0x30>
		if (*s1 != *s2)
  800d8e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800d92:	83 c2 01             	add    $0x1,%edx
  800d95:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800d9a:	38 c8                	cmp    %cl,%al
  800d9c:	74 0a                	je     800da8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800d9e:	0f b6 c0             	movzbl %al,%eax
  800da1:	0f b6 c9             	movzbl %cl,%ecx
  800da4:	29 c8                	sub    %ecx,%eax
  800da6:	eb 09                	jmp    800db1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da8:	39 da                	cmp    %ebx,%edx
  800daa:	75 e2                	jne    800d8e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dc4:	eb 07                	jmp    800dcd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dc6:	38 08                	cmp    %cl,(%eax)
  800dc8:	74 07                	je     800dd1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dca:	83 c0 01             	add    $0x1,%eax
  800dcd:	39 d0                	cmp    %edx,%eax
  800dcf:	72 f5                	jb     800dc6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ddf:	eb 03                	jmp    800de4 <strtol+0x11>
		s++;
  800de1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800de4:	0f b6 02             	movzbl (%edx),%eax
  800de7:	3c 20                	cmp    $0x20,%al
  800de9:	74 f6                	je     800de1 <strtol+0xe>
  800deb:	3c 09                	cmp    $0x9,%al
  800ded:	74 f2                	je     800de1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800def:	3c 2b                	cmp    $0x2b,%al
  800df1:	75 0a                	jne    800dfd <strtol+0x2a>
		s++;
  800df3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800df6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfb:	eb 10                	jmp    800e0d <strtol+0x3a>
  800dfd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e02:	3c 2d                	cmp    $0x2d,%al
  800e04:	75 07                	jne    800e0d <strtol+0x3a>
		s++, neg = 1;
  800e06:	8d 52 01             	lea    0x1(%edx),%edx
  800e09:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e0d:	85 db                	test   %ebx,%ebx
  800e0f:	0f 94 c0             	sete   %al
  800e12:	74 05                	je     800e19 <strtol+0x46>
  800e14:	83 fb 10             	cmp    $0x10,%ebx
  800e17:	75 15                	jne    800e2e <strtol+0x5b>
  800e19:	80 3a 30             	cmpb   $0x30,(%edx)
  800e1c:	75 10                	jne    800e2e <strtol+0x5b>
  800e1e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e22:	75 0a                	jne    800e2e <strtol+0x5b>
		s += 2, base = 16;
  800e24:	83 c2 02             	add    $0x2,%edx
  800e27:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e2c:	eb 13                	jmp    800e41 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e2e:	84 c0                	test   %al,%al
  800e30:	74 0f                	je     800e41 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e32:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e37:	80 3a 30             	cmpb   $0x30,(%edx)
  800e3a:	75 05                	jne    800e41 <strtol+0x6e>
		s++, base = 8;
  800e3c:	83 c2 01             	add    $0x1,%edx
  800e3f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e48:	0f b6 0a             	movzbl (%edx),%ecx
  800e4b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e4e:	80 fb 09             	cmp    $0x9,%bl
  800e51:	77 08                	ja     800e5b <strtol+0x88>
			dig = *s - '0';
  800e53:	0f be c9             	movsbl %cl,%ecx
  800e56:	83 e9 30             	sub    $0x30,%ecx
  800e59:	eb 1e                	jmp    800e79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e5b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e5e:	80 fb 19             	cmp    $0x19,%bl
  800e61:	77 08                	ja     800e6b <strtol+0x98>
			dig = *s - 'a' + 10;
  800e63:	0f be c9             	movsbl %cl,%ecx
  800e66:	83 e9 57             	sub    $0x57,%ecx
  800e69:	eb 0e                	jmp    800e79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e6b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e6e:	80 fb 19             	cmp    $0x19,%bl
  800e71:	77 14                	ja     800e87 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800e73:	0f be c9             	movsbl %cl,%ecx
  800e76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e79:	39 f1                	cmp    %esi,%ecx
  800e7b:	7d 0e                	jge    800e8b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800e7d:	83 c2 01             	add    $0x1,%edx
  800e80:	0f af c6             	imul   %esi,%eax
  800e83:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e85:	eb c1                	jmp    800e48 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e87:	89 c1                	mov    %eax,%ecx
  800e89:	eb 02                	jmp    800e8d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e8b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e91:	74 05                	je     800e98 <strtol+0xc5>
		*endptr = (char *) s;
  800e93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e96:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e98:	89 ca                	mov    %ecx,%edx
  800e9a:	f7 da                	neg    %edx
  800e9c:	85 ff                	test   %edi,%edi
  800e9e:	0f 45 c2             	cmovne %edx,%eax
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
	...

00800eb0 <__udivdi3>:
  800eb0:	83 ec 1c             	sub    $0x1c,%esp
  800eb3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800eb7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800ebb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800ebf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ec3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ec7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ecb:	85 ff                	test   %edi,%edi
  800ecd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed5:	89 cd                	mov    %ecx,%ebp
  800ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800edb:	75 33                	jne    800f10 <__udivdi3+0x60>
  800edd:	39 f1                	cmp    %esi,%ecx
  800edf:	77 57                	ja     800f38 <__udivdi3+0x88>
  800ee1:	85 c9                	test   %ecx,%ecx
  800ee3:	75 0b                	jne    800ef0 <__udivdi3+0x40>
  800ee5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eea:	31 d2                	xor    %edx,%edx
  800eec:	f7 f1                	div    %ecx
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	31 d2                	xor    %edx,%edx
  800ef4:	f7 f1                	div    %ecx
  800ef6:	89 c6                	mov    %eax,%esi
  800ef8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800efc:	f7 f1                	div    %ecx
  800efe:	89 f2                	mov    %esi,%edx
  800f00:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f0c:	83 c4 1c             	add    $0x1c,%esp
  800f0f:	c3                   	ret    
  800f10:	31 d2                	xor    %edx,%edx
  800f12:	31 c0                	xor    %eax,%eax
  800f14:	39 f7                	cmp    %esi,%edi
  800f16:	77 e8                	ja     800f00 <__udivdi3+0x50>
  800f18:	0f bd cf             	bsr    %edi,%ecx
  800f1b:	83 f1 1f             	xor    $0x1f,%ecx
  800f1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f22:	75 2c                	jne    800f50 <__udivdi3+0xa0>
  800f24:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f28:	76 04                	jbe    800f2e <__udivdi3+0x7e>
  800f2a:	39 f7                	cmp    %esi,%edi
  800f2c:	73 d2                	jae    800f00 <__udivdi3+0x50>
  800f2e:	31 d2                	xor    %edx,%edx
  800f30:	b8 01 00 00 00       	mov    $0x1,%eax
  800f35:	eb c9                	jmp    800f00 <__udivdi3+0x50>
  800f37:	90                   	nop
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	f7 f1                	div    %ecx
  800f3c:	31 d2                	xor    %edx,%edx
  800f3e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f42:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f46:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	c3                   	ret    
  800f4e:	66 90                	xchg   %ax,%ax
  800f50:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f55:	b8 20 00 00 00       	mov    $0x20,%eax
  800f5a:	89 ea                	mov    %ebp,%edx
  800f5c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f60:	d3 e7                	shl    %cl,%edi
  800f62:	89 c1                	mov    %eax,%ecx
  800f64:	d3 ea                	shr    %cl,%edx
  800f66:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f6b:	09 fa                	or     %edi,%edx
  800f6d:	89 f7                	mov    %esi,%edi
  800f6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f79:	d3 e5                	shl    %cl,%ebp
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	d3 ef                	shr    %cl,%edi
  800f7f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f84:	d3 e2                	shl    %cl,%edx
  800f86:	89 c1                	mov    %eax,%ecx
  800f88:	d3 ee                	shr    %cl,%esi
  800f8a:	09 d6                	or     %edx,%esi
  800f8c:	89 fa                	mov    %edi,%edx
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	f7 74 24 0c          	divl   0xc(%esp)
  800f94:	89 d7                	mov    %edx,%edi
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	f7 e5                	mul    %ebp
  800f9a:	39 d7                	cmp    %edx,%edi
  800f9c:	72 22                	jb     800fc0 <__udivdi3+0x110>
  800f9e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800fa2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fa7:	d3 e5                	shl    %cl,%ebp
  800fa9:	39 c5                	cmp    %eax,%ebp
  800fab:	73 04                	jae    800fb1 <__udivdi3+0x101>
  800fad:	39 d7                	cmp    %edx,%edi
  800faf:	74 0f                	je     800fc0 <__udivdi3+0x110>
  800fb1:	89 f0                	mov    %esi,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	e9 46 ff ff ff       	jmp    800f00 <__udivdi3+0x50>
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fcd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	c3                   	ret    
	...

00800fe0 <__umoddi3>:
  800fe0:	83 ec 1c             	sub    $0x1c,%esp
  800fe3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fe7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800feb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800fef:	89 74 24 10          	mov    %esi,0x10(%esp)
  800ff3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ff7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ffb:	85 ed                	test   %ebp,%ebp
  800ffd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801001:	89 44 24 08          	mov    %eax,0x8(%esp)
  801005:	89 cf                	mov    %ecx,%edi
  801007:	89 04 24             	mov    %eax,(%esp)
  80100a:	89 f2                	mov    %esi,%edx
  80100c:	75 1a                	jne    801028 <__umoddi3+0x48>
  80100e:	39 f1                	cmp    %esi,%ecx
  801010:	76 4e                	jbe    801060 <__umoddi3+0x80>
  801012:	f7 f1                	div    %ecx
  801014:	89 d0                	mov    %edx,%eax
  801016:	31 d2                	xor    %edx,%edx
  801018:	8b 74 24 10          	mov    0x10(%esp),%esi
  80101c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801020:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801024:	83 c4 1c             	add    $0x1c,%esp
  801027:	c3                   	ret    
  801028:	39 f5                	cmp    %esi,%ebp
  80102a:	77 54                	ja     801080 <__umoddi3+0xa0>
  80102c:	0f bd c5             	bsr    %ebp,%eax
  80102f:	83 f0 1f             	xor    $0x1f,%eax
  801032:	89 44 24 04          	mov    %eax,0x4(%esp)
  801036:	75 60                	jne    801098 <__umoddi3+0xb8>
  801038:	3b 0c 24             	cmp    (%esp),%ecx
  80103b:	0f 87 07 01 00 00    	ja     801148 <__umoddi3+0x168>
  801041:	89 f2                	mov    %esi,%edx
  801043:	8b 34 24             	mov    (%esp),%esi
  801046:	29 ce                	sub    %ecx,%esi
  801048:	19 ea                	sbb    %ebp,%edx
  80104a:	89 34 24             	mov    %esi,(%esp)
  80104d:	8b 04 24             	mov    (%esp),%eax
  801050:	8b 74 24 10          	mov    0x10(%esp),%esi
  801054:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801058:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80105c:	83 c4 1c             	add    $0x1c,%esp
  80105f:	c3                   	ret    
  801060:	85 c9                	test   %ecx,%ecx
  801062:	75 0b                	jne    80106f <__umoddi3+0x8f>
  801064:	b8 01 00 00 00       	mov    $0x1,%eax
  801069:	31 d2                	xor    %edx,%edx
  80106b:	f7 f1                	div    %ecx
  80106d:	89 c1                	mov    %eax,%ecx
  80106f:	89 f0                	mov    %esi,%eax
  801071:	31 d2                	xor    %edx,%edx
  801073:	f7 f1                	div    %ecx
  801075:	8b 04 24             	mov    (%esp),%eax
  801078:	f7 f1                	div    %ecx
  80107a:	eb 98                	jmp    801014 <__umoddi3+0x34>
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	89 f2                	mov    %esi,%edx
  801082:	8b 74 24 10          	mov    0x10(%esp),%esi
  801086:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80108a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80108e:	83 c4 1c             	add    $0x1c,%esp
  801091:	c3                   	ret    
  801092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801098:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109d:	89 e8                	mov    %ebp,%eax
  80109f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8010a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8010a8:	89 fa                	mov    %edi,%edx
  8010aa:	d3 e0                	shl    %cl,%eax
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	d3 ea                	shr    %cl,%edx
  8010b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010b5:	09 c2                	or     %eax,%edx
  8010b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010bb:	89 14 24             	mov    %edx,(%esp)
  8010be:	89 f2                	mov    %esi,%edx
  8010c0:	d3 e7                	shl    %cl,%edi
  8010c2:	89 e9                	mov    %ebp,%ecx
  8010c4:	d3 ea                	shr    %cl,%edx
  8010c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	d3 e6                	shl    %cl,%esi
  8010d1:	89 e9                	mov    %ebp,%ecx
  8010d3:	d3 e8                	shr    %cl,%eax
  8010d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010da:	09 f0                	or     %esi,%eax
  8010dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010e0:	f7 34 24             	divl   (%esp)
  8010e3:	d3 e6                	shl    %cl,%esi
  8010e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010e9:	89 d6                	mov    %edx,%esi
  8010eb:	f7 e7                	mul    %edi
  8010ed:	39 d6                	cmp    %edx,%esi
  8010ef:	89 c1                	mov    %eax,%ecx
  8010f1:	89 d7                	mov    %edx,%edi
  8010f3:	72 3f                	jb     801134 <__umoddi3+0x154>
  8010f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010f9:	72 35                	jb     801130 <__umoddi3+0x150>
  8010fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010ff:	29 c8                	sub    %ecx,%eax
  801101:	19 fe                	sbb    %edi,%esi
  801103:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801108:	89 f2                	mov    %esi,%edx
  80110a:	d3 e8                	shr    %cl,%eax
  80110c:	89 e9                	mov    %ebp,%ecx
  80110e:	d3 e2                	shl    %cl,%edx
  801110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801115:	09 d0                	or     %edx,%eax
  801117:	89 f2                	mov    %esi,%edx
  801119:	d3 ea                	shr    %cl,%edx
  80111b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80111f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801123:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801127:	83 c4 1c             	add    $0x1c,%esp
  80112a:	c3                   	ret    
  80112b:	90                   	nop
  80112c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801130:	39 d6                	cmp    %edx,%esi
  801132:	75 c7                	jne    8010fb <__umoddi3+0x11b>
  801134:	89 d7                	mov    %edx,%edi
  801136:	89 c1                	mov    %eax,%ecx
  801138:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80113c:	1b 3c 24             	sbb    (%esp),%edi
  80113f:	eb ba                	jmp    8010fb <__umoddi3+0x11b>
  801141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801148:	39 f5                	cmp    %esi,%ebp
  80114a:	0f 82 f1 fe ff ff    	jb     801041 <__umoddi3+0x61>
  801150:	e9 f8 fe ff ff       	jmp    80104d <__umoddi3+0x6d>
