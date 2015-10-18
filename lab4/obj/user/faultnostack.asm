
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 44 04 80 	movl   $0x800444,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 07 03 00 00       	call   800355 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
  80005a:	66 90                	xchg   %ax,%ax

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80006e:	e8 09 01 00 00       	call   80017c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
  8000ab:	90                   	nop

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 61 00 00 00       	call   80011f <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 38             	sub    $0x38,%esp
  800125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80016a:	e8 15 03 00 00       	call   800484 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c5:	89 d1                	mov    %edx,%ecx
  8001c7:	89 d3                	mov    %edx,%ebx
  8001c9:	89 d7                	mov    %edx,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 38             	sub    $0x38,%esp
  8001e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001eb:	be 00 00 00 00       	mov    $0x0,%esi
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 f7                	mov    %esi,%edi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 28                	jle    80022e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800211:	00 
  800212:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800229:	e8 56 02 00 00       	call   800484 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 38             	sub    $0x38,%esp
  800241:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800244:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800247:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	b8 05 00 00 00       	mov    $0x5,%eax
  80024f:	8b 75 18             	mov    0x18(%ebp),%esi
  800252:	8b 7d 14             	mov    0x14(%ebp),%edi
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 28                	jle    80028c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	89 44 24 10          	mov    %eax,0x10(%esp)
  800268:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026f:	00 
  800270:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800287:	e8 f8 01 00 00       	call   800484 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800295:	89 ec                	mov    %ebp,%esp
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 38             	sub    $0x38,%esp
  80029f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 28                	jle    8002ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8002e5:	e8 9a 01 00 00       	call   800484 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f3:	89 ec                	mov    %ebp,%esp
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 38             	sub    $0x38,%esp
  8002fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800300:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800303:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 08 00 00 00       	mov    $0x8,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 28                	jle    800348 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	89 44 24 10          	mov    %eax,0x10(%esp)
  800324:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032b:	00 
  80032c:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800343:	e8 3c 01 00 00       	call   800484 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800351:	89 ec                	mov    %ebp,%esp
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 38             	sub    $0x38,%esp
  80035b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	bb 00 00 00 00       	mov    $0x0,%ebx
  800369:	b8 09 00 00 00       	mov    $0x9,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 df                	mov    %ebx,%edi
  800376:	89 de                	mov    %ebx,%esi
  800378:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7e 28                	jle    8003a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8003a1:	e8 de 00 00 00       	call   800484 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
  8003c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003e3:	89 ec                	mov    %ebp,%esp
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 38             	sub    $0x38,%esp
  8003ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	89 cb                	mov    %ecx,%ebx
  800405:	89 cf                	mov    %ecx,%edi
  800407:	89 ce                	mov    %ecx,%esi
  800409:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040b:	85 c0                	test   %eax,%eax
  80040d:	7e 28                	jle    800437 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800413:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80041a:	00 
  80041b:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800432:	e8 4d 00 00 00       	call   800484 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800437:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800440:	89 ec                	mov    %ebp,%esp
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800444:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800445:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80044a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80044c:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  80044f:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  800453:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  800457:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  80045b:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  80045e:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  800461:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  800464:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  800468:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  80046c:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  800470:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  800474:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  800478:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  80047c:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  800480:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  800481:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800482:	c3                   	ret    
  800483:	90                   	nop

00800484 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80048c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80048f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800495:	e8 e2 fc ff ff       	call   80017c <sys_getenvid>
  80049a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b0:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  8004b7:	e8 c3 00 00 00       	call   80057f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	e8 53 00 00 00       	call   80051e <vcprintf>
	cprintf("\n");
  8004cb:	c7 04 24 7b 12 80 00 	movl   $0x80127b,(%esp)
  8004d2:	e8 a8 00 00 00       	call   80057f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004d7:	cc                   	int3   
  8004d8:	eb fd                	jmp    8004d7 <_panic+0x53>
  8004da:	66 90                	xchg   %ax,%ax

008004dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	53                   	push   %ebx
  8004e0:	83 ec 14             	sub    $0x14,%esp
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004e6:	8b 03                	mov    (%ebx),%eax
  8004e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004ef:	83 c0 01             	add    $0x1,%eax
  8004f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004f9:	75 19                	jne    800514 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800502:	00 
  800503:	8d 43 08             	lea    0x8(%ebx),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	e8 b2 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  80050e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800514:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800518:	83 c4 14             	add    $0x14,%esp
  80051b:	5b                   	pop    %ebx
  80051c:	5d                   	pop    %ebp
  80051d:	c3                   	ret    

0080051e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800527:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80052e:	00 00 00 
	b.cnt = 0;
  800531:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800538:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80053b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	89 44 24 08          	mov    %eax,0x8(%esp)
  800549:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800553:	c7 04 24 dc 04 80 00 	movl   $0x8004dc,(%esp)
  80055a:	e8 8e 01 00 00       	call   8006ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80055f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	e8 49 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800577:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80057d:	c9                   	leave  
  80057e:	c3                   	ret    

0080057f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800585:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 87 ff ff ff       	call   80051e <vcprintf>
	va_end(ap);

	return cnt;
}
  800597:	c9                   	leave  
  800598:	c3                   	ret    
  800599:	66 90                	xchg   %ax,%ax
  80059b:	66 90                	xchg   %ax,%ax
  80059d:	66 90                	xchg   %ax,%ax
  80059f:	90                   	nop

008005a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 3c             	sub    $0x3c,%esp
  8005a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ac:	89 d7                	mov    %edx,%edi
  8005ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 08                	jne    8005cc <printnum+0x2c>
  8005c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ca:	77 59                	ja     800625 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005d0:	83 eb 01             	sub    $0x1,%ebx
  8005d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005e2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ed:	00 
  8005ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f1:	89 04 24             	mov    %eax,(%esp)
  8005f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fb:	e8 90 09 00 00       	call   800f90 <__udivdi3>
  800600:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800604:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800608:	89 04 24             	mov    %eax,(%esp)
  80060b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060f:	89 fa                	mov    %edi,%edx
  800611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800614:	e8 87 ff ff ff       	call   8005a0 <printnum>
  800619:	eb 11                	jmp    80062c <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80061b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800625:	83 eb 01             	sub    $0x1,%ebx
  800628:	85 db                	test   %ebx,%ebx
  80062a:	7f ef                	jg     80061b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80062c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800630:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800634:	8b 45 10             	mov    0x10(%ebp),%eax
  800637:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800642:	00 
  800643:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800650:	e8 6b 0a 00 00       	call   8010c0 <__umoddi3>
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	0f be 80 7d 12 80 00 	movsbl 0x80127d(%eax),%eax
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800666:	83 c4 3c             	add    $0x3c,%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800671:	83 fa 01             	cmp    $0x1,%edx
  800674:	7e 0e                	jle    800684 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800676:	8b 10                	mov    (%eax),%edx
  800678:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067b:	89 08                	mov    %ecx,(%eax)
  80067d:	8b 02                	mov    (%edx),%eax
  80067f:	8b 52 04             	mov    0x4(%edx),%edx
  800682:	eb 22                	jmp    8006a6 <getuint+0x38>
	else if (lflag)
  800684:	85 d2                	test   %edx,%edx
  800686:	74 10                	je     800698 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	ba 00 00 00 00       	mov    $0x0,%edx
  800696:	eb 0e                	jmp    8006a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069d:	89 08                	mov    %ecx,(%eax)
  80069f:	8b 02                	mov    (%edx),%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    

008006a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006ae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b7:	73 0a                	jae    8006c3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bc:	88 0a                	mov    %cl,(%edx)
  8006be:	83 c2 01             	add    $0x1,%edx
  8006c1:	89 10                	mov    %edx,(%eax)
}
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	e8 02 00 00 00       	call   8006ed <vprintfmt>
	va_end(ap);
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	57                   	push   %edi
  8006f1:	56                   	push   %esi
  8006f2:	53                   	push   %ebx
  8006f3:	83 ec 4c             	sub    $0x4c,%esp
  8006f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8006fc:	eb 12                	jmp    800710 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006fe:	85 c0                	test   %eax,%eax
  800700:	0f 84 bf 03 00 00    	je     800ac5 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800710:	0f b6 06             	movzbl (%esi),%eax
  800713:	83 c6 01             	add    $0x1,%esi
  800716:	83 f8 25             	cmp    $0x25,%eax
  800719:	75 e3                	jne    8006fe <vprintfmt+0x11>
  80071b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80071f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800726:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80072b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80073a:	eb 2b                	jmp    800767 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80073f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800743:	eb 22                	jmp    800767 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800748:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80074c:	eb 19                	jmp    800767 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800751:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800758:	eb 0d                	jmp    800767 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80075a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80075d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800760:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	0f b6 16             	movzbl (%esi),%edx
  80076a:	0f b6 c2             	movzbl %dl,%eax
  80076d:	8d 7e 01             	lea    0x1(%esi),%edi
  800770:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800773:	83 ea 23             	sub    $0x23,%edx
  800776:	80 fa 55             	cmp    $0x55,%dl
  800779:	0f 87 28 03 00 00    	ja     800aa7 <vprintfmt+0x3ba>
  80077f:	0f b6 d2             	movzbl %dl,%edx
  800782:	ff 24 95 40 13 80 00 	jmp    *0x801340(,%edx,4)
  800789:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800793:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800798:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80079b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80079f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007a2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007a5:	83 fa 09             	cmp    $0x9,%edx
  8007a8:	77 2f                	ja     8007d9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007aa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007ad:	eb e9                	jmp    800798 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007c0:	eb 1a                	jmp    8007dc <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c9:	79 9c                	jns    800767 <vprintfmt+0x7a>
  8007cb:	eb 81                	jmp    80074e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007d0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007d7:	eb 8e                	jmp    800767 <vprintfmt+0x7a>
  8007d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e0:	79 85                	jns    800767 <vprintfmt+0x7a>
  8007e2:	e9 73 ff ff ff       	jmp    80075a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ed:	e9 75 ff ff ff       	jmp    800767 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 04 24             	mov    %eax,(%esp)
  800804:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800807:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80080a:	e9 01 ff ff ff       	jmp    800710 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 c2                	mov    %eax,%edx
  80081c:	c1 fa 1f             	sar    $0x1f,%edx
  80081f:	31 d0                	xor    %edx,%eax
  800821:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800823:	83 f8 09             	cmp    $0x9,%eax
  800826:	7f 0b                	jg     800833 <vprintfmt+0x146>
  800828:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  80082f:	85 d2                	test   %edx,%edx
  800831:	75 23                	jne    800856 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800837:	c7 44 24 08 95 12 80 	movl   $0x801295,0x8(%esp)
  80083e:	00 
  80083f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	89 3c 24             	mov    %edi,(%esp)
  800849:	e8 77 fe ff ff       	call   8006c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800851:	e9 ba fe ff ff       	jmp    800710 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800856:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80085a:	c7 44 24 08 9e 12 80 	movl   $0x80129e,0x8(%esp)
  800861:	00 
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	8b 7d 08             	mov    0x8(%ebp),%edi
  800869:	89 3c 24             	mov    %edi,(%esp)
  80086c:	e8 54 fe ff ff       	call   8006c5 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800871:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800874:	e9 97 fe ff ff       	jmp    800710 <vprintfmt+0x23>
  800879:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80087c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80087f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8d 50 04             	lea    0x4(%eax),%edx
  800888:	89 55 14             	mov    %edx,0x14(%ebp)
  80088b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80088d:	85 f6                	test   %esi,%esi
  80088f:	ba 8e 12 80 00       	mov    $0x80128e,%edx
  800894:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800897:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80089b:	0f 8e 8c 00 00 00    	jle    80092d <vprintfmt+0x240>
  8008a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8008a5:	0f 84 82 00 00 00    	je     80092d <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008af:	89 34 24             	mov    %esi,(%esp)
  8008b2:	e8 b1 02 00 00       	call   800b68 <strnlen>
  8008b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008ba:	29 c2                	sub    %eax,%edx
  8008bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8008bf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8008c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8008c6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8008c9:	89 de                	mov    %ebx,%esi
  8008cb:	89 d3                	mov    %edx,%ebx
  8008cd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cf:	eb 0d                	jmp    8008de <vprintfmt+0x1f1>
					putch(padc, putdat);
  8008d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d5:	89 3c 24             	mov    %edi,(%esp)
  8008d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008db:	83 eb 01             	sub    $0x1,%ebx
  8008de:	85 db                	test   %ebx,%ebx
  8008e0:	7f ef                	jg     8008d1 <vprintfmt+0x1e4>
  8008e2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008e5:	89 f3                	mov    %esi,%ebx
  8008e7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8008f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008fa:	29 c2                	sub    %eax,%edx
  8008fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008ff:	eb 2c                	jmp    80092d <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800901:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800905:	74 18                	je     80091f <vprintfmt+0x232>
  800907:	8d 50 e0             	lea    -0x20(%eax),%edx
  80090a:	83 fa 5e             	cmp    $0x5e,%edx
  80090d:	76 10                	jbe    80091f <vprintfmt+0x232>
					putch('?', putdat);
  80090f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800913:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80091a:	ff 55 08             	call   *0x8(%ebp)
  80091d:	eb 0a                	jmp    800929 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  80091f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800929:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80092d:	0f be 06             	movsbl (%esi),%eax
  800930:	83 c6 01             	add    $0x1,%esi
  800933:	85 c0                	test   %eax,%eax
  800935:	74 25                	je     80095c <vprintfmt+0x26f>
  800937:	85 ff                	test   %edi,%edi
  800939:	78 c6                	js     800901 <vprintfmt+0x214>
  80093b:	83 ef 01             	sub    $0x1,%edi
  80093e:	79 c1                	jns    800901 <vprintfmt+0x214>
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	89 de                	mov    %ebx,%esi
  800945:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800948:	eb 1a                	jmp    800964 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800955:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800957:	83 eb 01             	sub    $0x1,%ebx
  80095a:	eb 08                	jmp    800964 <vprintfmt+0x277>
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	89 de                	mov    %ebx,%esi
  800961:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800964:	85 db                	test   %ebx,%ebx
  800966:	7f e2                	jg     80094a <vprintfmt+0x25d>
  800968:	89 7d 08             	mov    %edi,0x8(%ebp)
  80096b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800970:	e9 9b fd ff ff       	jmp    800710 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800975:	83 f9 01             	cmp    $0x1,%ecx
  800978:	7e 10                	jle    80098a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80097a:	8b 45 14             	mov    0x14(%ebp),%eax
  80097d:	8d 50 08             	lea    0x8(%eax),%edx
  800980:	89 55 14             	mov    %edx,0x14(%ebp)
  800983:	8b 30                	mov    (%eax),%esi
  800985:	8b 78 04             	mov    0x4(%eax),%edi
  800988:	eb 26                	jmp    8009b0 <vprintfmt+0x2c3>
	else if (lflag)
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 12                	je     8009a0 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	8d 50 04             	lea    0x4(%eax),%edx
  800994:	89 55 14             	mov    %edx,0x14(%ebp)
  800997:	8b 30                	mov    (%eax),%esi
  800999:	89 f7                	mov    %esi,%edi
  80099b:	c1 ff 1f             	sar    $0x1f,%edi
  80099e:	eb 10                	jmp    8009b0 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  8009a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a3:	8d 50 04             	lea    0x4(%eax),%edx
  8009a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a9:	8b 30                	mov    (%eax),%esi
  8009ab:	89 f7                	mov    %esi,%edi
  8009ad:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b5:	85 ff                	test   %edi,%edi
  8009b7:	0f 89 ac 00 00 00    	jns    800a69 <vprintfmt+0x37c>
				putch('-', putdat);
  8009bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c8:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009cb:	f7 de                	neg    %esi
  8009cd:	83 d7 00             	adc    $0x0,%edi
  8009d0:	f7 df                	neg    %edi
			}
			base = 10;
  8009d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d7:	e9 8d 00 00 00       	jmp    800a69 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009dc:	89 ca                	mov    %ecx,%edx
  8009de:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e1:	e8 88 fc ff ff       	call   80066e <getuint>
  8009e6:	89 c6                	mov    %eax,%esi
  8009e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009ef:	eb 78                	jmp    800a69 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009fc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a03:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a0a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800a0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a11:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a18:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a1e:	e9 ed fc ff ff       	jmp    800710 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800a23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a27:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a2e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a35:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a42:	8d 50 04             	lea    0x4(%eax),%edx
  800a45:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a48:	8b 30                	mov    (%eax),%esi
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a54:	eb 13                	jmp    800a69 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a56:	89 ca                	mov    %ecx,%edx
  800a58:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5b:	e8 0e fc ff ff       	call   80066e <getuint>
  800a60:	89 c6                	mov    %eax,%esi
  800a62:	89 d7                	mov    %edx,%edi
			base = 16;
  800a64:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a69:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a6d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a74:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7c:	89 34 24             	mov    %esi,(%esp)
  800a7f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a83:	89 da                	mov    %ebx,%edx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	e8 13 fb ff ff       	call   8005a0 <printnum>
			break;
  800a8d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a90:	e9 7b fc ff ff       	jmp    800710 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a95:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aa2:	e9 69 fc ff ff       	jmp    800710 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aab:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ab2:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab5:	eb 03                	jmp    800aba <vprintfmt+0x3cd>
  800ab7:	83 ee 01             	sub    $0x1,%esi
  800aba:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800abe:	75 f7                	jne    800ab7 <vprintfmt+0x3ca>
  800ac0:	e9 4b fc ff ff       	jmp    800710 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ac5:	83 c4 4c             	add    $0x4c,%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	83 ec 28             	sub    $0x28,%esp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800adc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ae0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ae3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aea:	85 c0                	test   %eax,%eax
  800aec:	74 30                	je     800b1e <vsnprintf+0x51>
  800aee:	85 d2                	test   %edx,%edx
  800af0:	7e 2c                	jle    800b1e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af2:	8b 45 14             	mov    0x14(%ebp),%eax
  800af5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
  800afc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b00:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b07:	c7 04 24 a8 06 80 00 	movl   $0x8006a8,(%esp)
  800b0e:	e8 da fb ff ff       	call   8006ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b16:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b1c:	eb 05                	jmp    800b23 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b32:	8b 45 10             	mov    0x10(%ebp),%eax
  800b35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	89 04 24             	mov    %eax,(%esp)
  800b46:	e8 82 ff ff ff       	call   800acd <vsnprintf>
	va_end(ap);

	return rc;
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    
  800b4d:	66 90                	xchg   %ax,%ax
  800b4f:	90                   	nop

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
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
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
  800b8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b9a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b9d:	83 c2 01             	add    $0x1,%edx
  800ba0:	84 c9                	test   %cl,%cl
  800ba2:	75 f2                	jne    800b96 <strcpy+0xf>
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
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be5:	eb 0f                	jmp    800bf6 <strncpy+0x24>
		*dst++ = *src;
  800be7:	0f b6 1a             	movzbl (%edx),%ebx
  800bea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bed:	80 3a 01             	cmpb   $0x1,(%edx)
  800bf0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf3:	83 c1 01             	add    $0x1,%ecx
  800bf6:	39 f1                	cmp    %esi,%ecx
  800bf8:	75 ed                	jne    800be7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	8b 75 08             	mov    0x8(%ebp),%esi
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c0c:	89 f0                	mov    %esi,%eax
  800c0e:	85 d2                	test   %edx,%edx
  800c10:	75 0a                	jne    800c1c <strlcpy+0x1e>
  800c12:	eb 1d                	jmp    800c31 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c14:	88 18                	mov    %bl,(%eax)
  800c16:	83 c0 01             	add    $0x1,%eax
  800c19:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c1c:	83 ea 01             	sub    $0x1,%edx
  800c1f:	74 0b                	je     800c2c <strlcpy+0x2e>
  800c21:	0f b6 19             	movzbl (%ecx),%ebx
  800c24:	84 db                	test   %bl,%bl
  800c26:	75 ec                	jne    800c14 <strlcpy+0x16>
  800c28:	89 c2                	mov    %eax,%edx
  800c2a:	eb 02                	jmp    800c2e <strlcpy+0x30>
  800c2c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c2e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c31:	29 f0                	sub    %esi,%eax
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c40:	eb 06                	jmp    800c48 <strcmp+0x11>
		p++, q++;
  800c42:	83 c1 01             	add    $0x1,%ecx
  800c45:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c48:	0f b6 01             	movzbl (%ecx),%eax
  800c4b:	84 c0                	test   %al,%al
  800c4d:	74 04                	je     800c53 <strcmp+0x1c>
  800c4f:	3a 02                	cmp    (%edx),%al
  800c51:	74 ef                	je     800c42 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c53:	0f b6 c0             	movzbl %al,%eax
  800c56:	0f b6 12             	movzbl (%edx),%edx
  800c59:	29 d0                	sub    %edx,%eax
}
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	53                   	push   %ebx
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c6a:	eb 09                	jmp    800c75 <strncmp+0x18>
		n--, p++, q++;
  800c6c:	83 ea 01             	sub    $0x1,%edx
  800c6f:	83 c0 01             	add    $0x1,%eax
  800c72:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c75:	85 d2                	test   %edx,%edx
  800c77:	74 15                	je     800c8e <strncmp+0x31>
  800c79:	0f b6 18             	movzbl (%eax),%ebx
  800c7c:	84 db                	test   %bl,%bl
  800c7e:	74 04                	je     800c84 <strncmp+0x27>
  800c80:	3a 19                	cmp    (%ecx),%bl
  800c82:	74 e8                	je     800c6c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	0f b6 11             	movzbl (%ecx),%edx
  800c8a:	29 d0                	sub    %edx,%eax
  800c8c:	eb 05                	jmp    800c93 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca0:	eb 07                	jmp    800ca9 <strchr+0x13>
		if (*s == c)
  800ca2:	38 ca                	cmp    %cl,%dl
  800ca4:	74 0f                	je     800cb5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca6:	83 c0 01             	add    $0x1,%eax
  800ca9:	0f b6 10             	movzbl (%eax),%edx
  800cac:	84 d2                	test   %dl,%dl
  800cae:	75 f2                	jne    800ca2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc1:	eb 07                	jmp    800cca <strfind+0x13>
		if (*s == c)
  800cc3:	38 ca                	cmp    %cl,%dl
  800cc5:	74 0a                	je     800cd1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	0f b6 10             	movzbl (%eax),%edx
  800ccd:	84 d2                	test   %dl,%dl
  800ccf:	75 f2                	jne    800cc3 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ceb:	85 c9                	test   %ecx,%ecx
  800ced:	74 30                	je     800d1f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cf5:	75 25                	jne    800d1c <memset+0x49>
  800cf7:	f6 c1 03             	test   $0x3,%cl
  800cfa:	75 20                	jne    800d1c <memset+0x49>
		c &= 0xFF;
  800cfc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cff:	89 d3                	mov    %edx,%ebx
  800d01:	c1 e3 08             	shl    $0x8,%ebx
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	c1 e6 18             	shl    $0x18,%esi
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	c1 e0 10             	shl    $0x10,%eax
  800d0e:	09 f0                	or     %esi,%eax
  800d10:	09 d0                	or     %edx,%eax
  800d12:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d14:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d17:	fc                   	cld    
  800d18:	f3 ab                	rep stos %eax,%es:(%edi)
  800d1a:	eb 03                	jmp    800d1f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d1c:	fc                   	cld    
  800d1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2a:	89 ec                	mov    %ebp,%esp
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 08             	sub    $0x8,%esp
  800d34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d43:	39 c6                	cmp    %eax,%esi
  800d45:	73 36                	jae    800d7d <memmove+0x4f>
  800d47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	73 2f                	jae    800d7d <memmove+0x4f>
		s += n;
		d += n;
  800d4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d51:	f6 c2 03             	test   $0x3,%dl
  800d54:	75 1b                	jne    800d71 <memmove+0x43>
  800d56:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d5c:	75 13                	jne    800d71 <memmove+0x43>
  800d5e:	f6 c1 03             	test   $0x3,%cl
  800d61:	75 0e                	jne    800d71 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d63:	83 ef 04             	sub    $0x4,%edi
  800d66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d69:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d6c:	fd                   	std    
  800d6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6f:	eb 09                	jmp    800d7a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d71:	83 ef 01             	sub    $0x1,%edi
  800d74:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d77:	fd                   	std    
  800d78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d7a:	fc                   	cld    
  800d7b:	eb 20                	jmp    800d9d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d83:	75 13                	jne    800d98 <memmove+0x6a>
  800d85:	a8 03                	test   $0x3,%al
  800d87:	75 0f                	jne    800d98 <memmove+0x6a>
  800d89:	f6 c1 03             	test   $0x3,%cl
  800d8c:	75 0a                	jne    800d98 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d8e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d91:	89 c7                	mov    %eax,%edi
  800d93:	fc                   	cld    
  800d94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d96:	eb 05                	jmp    800d9d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d98:	89 c7                	mov    %eax,%edi
  800d9a:	fc                   	cld    
  800d9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d9d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da3:	89 ec                	mov    %ebp,%esp
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dad:	8b 45 10             	mov    0x10(%ebp),%eax
  800db0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	89 04 24             	mov    %eax,(%esp)
  800dc1:	e8 68 ff ff ff       	call   800d2e <memmove>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddc:	eb 1a                	jmp    800df8 <memcmp+0x30>
		if (*s1 != *s2)
  800dde:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800de2:	83 c2 01             	add    $0x1,%edx
  800de5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800dea:	38 c8                	cmp    %cl,%al
  800dec:	74 0a                	je     800df8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800dee:	0f b6 c0             	movzbl %al,%eax
  800df1:	0f b6 c9             	movzbl %cl,%ecx
  800df4:	29 c8                	sub    %ecx,%eax
  800df6:	eb 09                	jmp    800e01 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df8:	39 da                	cmp    %ebx,%edx
  800dfa:	75 e2                	jne    800dde <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e14:	eb 07                	jmp    800e1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e16:	38 08                	cmp    %cl,(%eax)
  800e18:	74 07                	je     800e21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e1a:	83 c0 01             	add    $0x1,%eax
  800e1d:	39 d0                	cmp    %edx,%eax
  800e1f:	72 f5                	jb     800e16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	57                   	push   %edi
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2f:	eb 03                	jmp    800e34 <strtol+0x11>
		s++;
  800e31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e34:	0f b6 02             	movzbl (%edx),%eax
  800e37:	3c 20                	cmp    $0x20,%al
  800e39:	74 f6                	je     800e31 <strtol+0xe>
  800e3b:	3c 09                	cmp    $0x9,%al
  800e3d:	74 f2                	je     800e31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e3f:	3c 2b                	cmp    $0x2b,%al
  800e41:	75 0a                	jne    800e4d <strtol+0x2a>
		s++;
  800e43:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e46:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4b:	eb 10                	jmp    800e5d <strtol+0x3a>
  800e4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e52:	3c 2d                	cmp    $0x2d,%al
  800e54:	75 07                	jne    800e5d <strtol+0x3a>
		s++, neg = 1;
  800e56:	8d 52 01             	lea    0x1(%edx),%edx
  800e59:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5d:	85 db                	test   %ebx,%ebx
  800e5f:	0f 94 c0             	sete   %al
  800e62:	74 05                	je     800e69 <strtol+0x46>
  800e64:	83 fb 10             	cmp    $0x10,%ebx
  800e67:	75 15                	jne    800e7e <strtol+0x5b>
  800e69:	80 3a 30             	cmpb   $0x30,(%edx)
  800e6c:	75 10                	jne    800e7e <strtol+0x5b>
  800e6e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e72:	75 0a                	jne    800e7e <strtol+0x5b>
		s += 2, base = 16;
  800e74:	83 c2 02             	add    $0x2,%edx
  800e77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e7c:	eb 13                	jmp    800e91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e7e:	84 c0                	test   %al,%al
  800e80:	74 0f                	je     800e91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e82:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e87:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8a:	75 05                	jne    800e91 <strtol+0x6e>
		s++, base = 8;
  800e8c:	83 c2 01             	add    $0x1,%edx
  800e8f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 0a             	movzbl (%edx),%ecx
  800e9b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e9e:	80 fb 09             	cmp    $0x9,%bl
  800ea1:	77 08                	ja     800eab <strtol+0x88>
			dig = *s - '0';
  800ea3:	0f be c9             	movsbl %cl,%ecx
  800ea6:	83 e9 30             	sub    $0x30,%ecx
  800ea9:	eb 1e                	jmp    800ec9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800eab:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800eae:	80 fb 19             	cmp    $0x19,%bl
  800eb1:	77 08                	ja     800ebb <strtol+0x98>
			dig = *s - 'a' + 10;
  800eb3:	0f be c9             	movsbl %cl,%ecx
  800eb6:	83 e9 57             	sub    $0x57,%ecx
  800eb9:	eb 0e                	jmp    800ec9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800ebb:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ebe:	80 fb 19             	cmp    $0x19,%bl
  800ec1:	77 14                	ja     800ed7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800ec3:	0f be c9             	movsbl %cl,%ecx
  800ec6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ec9:	39 f1                	cmp    %esi,%ecx
  800ecb:	7d 0e                	jge    800edb <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800ecd:	83 c2 01             	add    $0x1,%edx
  800ed0:	0f af c6             	imul   %esi,%eax
  800ed3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ed5:	eb c1                	jmp    800e98 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	eb 02                	jmp    800edd <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800edb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800edd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee1:	74 05                	je     800ee8 <strtol+0xc5>
		*endptr = (char *) s;
  800ee3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee8:	89 ca                	mov    %ecx,%edx
  800eea:	f7 da                	neg    %edx
  800eec:	85 ff                	test   %edi,%edi
  800eee:	0f 45 c2             	cmovne %edx,%eax
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    
  800ef6:	66 90                	xchg   %ax,%ax

00800ef8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800efe:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f05:	75 44                	jne    800f4b <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  800f07:	a1 04 20 80 00       	mov    0x802004,%eax
  800f0c:	8b 40 48             	mov    0x48(%eax),%eax
  800f0f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f1e:	ee 
  800f1f:	89 04 24             	mov    %eax,(%esp)
  800f22:	e8 b5 f2 ff ff       	call   8001dc <sys_page_alloc>
		if( r < 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 20                	jns    800f4b <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  800f2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2f:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 24 15 80 00 	movl   $0x801524,(%esp)
  800f46:	e8 39 f5 ff ff       	call   800484 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  800f53:	e8 24 f2 ff ff       	call   80017c <sys_getenvid>
  800f58:	c7 44 24 04 44 04 80 	movl   $0x800444,0x4(%esp)
  800f5f:	00 
  800f60:	89 04 24             	mov    %eax,(%esp)
  800f63:	e8 ed f3 ff ff       	call   800355 <sys_env_set_pgfault_upcall>
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 20                	jns    800f8c <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  800f6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f70:	c7 44 24 08 f8 14 80 	movl   $0x8014f8,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 24 15 80 00 	movl   $0x801524,(%esp)
  800f87:	e8 f8 f4 ff ff       	call   800484 <_panic>


}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
  800f8e:	66 90                	xchg   %ax,%ax

00800f90 <__udivdi3>:
  800f90:	55                   	push   %ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f9a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f9e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800fa2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fac:	89 ea                	mov    %ebp,%edx
  800fae:	89 0c 24             	mov    %ecx,(%esp)
  800fb1:	75 2d                	jne    800fe0 <__udivdi3+0x50>
  800fb3:	39 e9                	cmp    %ebp,%ecx
  800fb5:	77 61                	ja     801018 <__udivdi3+0x88>
  800fb7:	85 c9                	test   %ecx,%ecx
  800fb9:	89 ce                	mov    %ecx,%esi
  800fbb:	75 0b                	jne    800fc8 <__udivdi3+0x38>
  800fbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc2:	31 d2                	xor    %edx,%edx
  800fc4:	f7 f1                	div    %ecx
  800fc6:	89 c6                	mov    %eax,%esi
  800fc8:	31 d2                	xor    %edx,%edx
  800fca:	89 e8                	mov    %ebp,%eax
  800fcc:	f7 f6                	div    %esi
  800fce:	89 c5                	mov    %eax,%ebp
  800fd0:	89 f8                	mov    %edi,%eax
  800fd2:	f7 f6                	div    %esi
  800fd4:	89 ea                	mov    %ebp,%edx
  800fd6:	83 c4 0c             	add    $0xc,%esp
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
  800fe0:	39 e8                	cmp    %ebp,%eax
  800fe2:	77 24                	ja     801008 <__udivdi3+0x78>
  800fe4:	0f bd e8             	bsr    %eax,%ebp
  800fe7:	83 f5 1f             	xor    $0x1f,%ebp
  800fea:	75 3c                	jne    801028 <__udivdi3+0x98>
  800fec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff0:	39 34 24             	cmp    %esi,(%esp)
  800ff3:	0f 86 9f 00 00 00    	jbe    801098 <__udivdi3+0x108>
  800ff9:	39 d0                	cmp    %edx,%eax
  800ffb:	0f 82 97 00 00 00    	jb     801098 <__udivdi3+0x108>
  801001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801008:	31 d2                	xor    %edx,%edx
  80100a:	31 c0                	xor    %eax,%eax
  80100c:	83 c4 0c             	add    $0xc,%esp
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    
  801013:	90                   	nop
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	89 f8                	mov    %edi,%eax
  80101a:	f7 f1                	div    %ecx
  80101c:	31 d2                	xor    %edx,%edx
  80101e:	83 c4 0c             	add    $0xc,%esp
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	8b 3c 24             	mov    (%esp),%edi
  80102d:	d3 e0                	shl    %cl,%eax
  80102f:	89 c6                	mov    %eax,%esi
  801031:	b8 20 00 00 00       	mov    $0x20,%eax
  801036:	29 e8                	sub    %ebp,%eax
  801038:	89 c1                	mov    %eax,%ecx
  80103a:	d3 ef                	shr    %cl,%edi
  80103c:	89 e9                	mov    %ebp,%ecx
  80103e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801042:	8b 3c 24             	mov    (%esp),%edi
  801045:	09 74 24 08          	or     %esi,0x8(%esp)
  801049:	89 d6                	mov    %edx,%esi
  80104b:	d3 e7                	shl    %cl,%edi
  80104d:	89 c1                	mov    %eax,%ecx
  80104f:	89 3c 24             	mov    %edi,(%esp)
  801052:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801056:	d3 ee                	shr    %cl,%esi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	d3 e2                	shl    %cl,%edx
  80105c:	89 c1                	mov    %eax,%ecx
  80105e:	d3 ef                	shr    %cl,%edi
  801060:	09 d7                	or     %edx,%edi
  801062:	89 f2                	mov    %esi,%edx
  801064:	89 f8                	mov    %edi,%eax
  801066:	f7 74 24 08          	divl   0x8(%esp)
  80106a:	89 d6                	mov    %edx,%esi
  80106c:	89 c7                	mov    %eax,%edi
  80106e:	f7 24 24             	mull   (%esp)
  801071:	39 d6                	cmp    %edx,%esi
  801073:	89 14 24             	mov    %edx,(%esp)
  801076:	72 30                	jb     8010a8 <__udivdi3+0x118>
  801078:	8b 54 24 04          	mov    0x4(%esp),%edx
  80107c:	89 e9                	mov    %ebp,%ecx
  80107e:	d3 e2                	shl    %cl,%edx
  801080:	39 c2                	cmp    %eax,%edx
  801082:	73 05                	jae    801089 <__udivdi3+0xf9>
  801084:	3b 34 24             	cmp    (%esp),%esi
  801087:	74 1f                	je     8010a8 <__udivdi3+0x118>
  801089:	89 f8                	mov    %edi,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	e9 7a ff ff ff       	jmp    80100c <__udivdi3+0x7c>
  801092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801098:	31 d2                	xor    %edx,%edx
  80109a:	b8 01 00 00 00       	mov    $0x1,%eax
  80109f:	e9 68 ff ff ff       	jmp    80100c <__udivdi3+0x7c>
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	83 c4 0c             	add    $0xc,%esp
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    
  8010b4:	66 90                	xchg   %ax,%ax
  8010b6:	66 90                	xchg   %ax,%ax
  8010b8:	66 90                	xchg   %ax,%ax
  8010ba:	66 90                	xchg   %ax,%ax
  8010bc:	66 90                	xchg   %ax,%ax
  8010be:	66 90                	xchg   %ax,%ax

008010c0 <__umoddi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	83 ec 14             	sub    $0x14,%esp
  8010c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8010d2:	89 c7                	mov    %eax,%edi
  8010d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010e0:	89 34 24             	mov    %esi,(%esp)
  8010e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	75 17                	jne    801108 <__umoddi3+0x48>
  8010f1:	39 fe                	cmp    %edi,%esi
  8010f3:	76 4b                	jbe    801140 <__umoddi3+0x80>
  8010f5:	89 c8                	mov    %ecx,%eax
  8010f7:	89 fa                	mov    %edi,%edx
  8010f9:	f7 f6                	div    %esi
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	31 d2                	xor    %edx,%edx
  8010ff:	83 c4 14             	add    $0x14,%esp
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    
  801106:	66 90                	xchg   %ax,%ax
  801108:	39 f8                	cmp    %edi,%eax
  80110a:	77 54                	ja     801160 <__umoddi3+0xa0>
  80110c:	0f bd e8             	bsr    %eax,%ebp
  80110f:	83 f5 1f             	xor    $0x1f,%ebp
  801112:	75 5c                	jne    801170 <__umoddi3+0xb0>
  801114:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801118:	39 3c 24             	cmp    %edi,(%esp)
  80111b:	0f 87 e7 00 00 00    	ja     801208 <__umoddi3+0x148>
  801121:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801125:	29 f1                	sub    %esi,%ecx
  801127:	19 c7                	sbb    %eax,%edi
  801129:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80112d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801131:	8b 44 24 08          	mov    0x8(%esp),%eax
  801135:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801139:	83 c4 14             	add    $0x14,%esp
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    
  801140:	85 f6                	test   %esi,%esi
  801142:	89 f5                	mov    %esi,%ebp
  801144:	75 0b                	jne    801151 <__umoddi3+0x91>
  801146:	b8 01 00 00 00       	mov    $0x1,%eax
  80114b:	31 d2                	xor    %edx,%edx
  80114d:	f7 f6                	div    %esi
  80114f:	89 c5                	mov    %eax,%ebp
  801151:	8b 44 24 04          	mov    0x4(%esp),%eax
  801155:	31 d2                	xor    %edx,%edx
  801157:	f7 f5                	div    %ebp
  801159:	89 c8                	mov    %ecx,%eax
  80115b:	f7 f5                	div    %ebp
  80115d:	eb 9c                	jmp    8010fb <__umoddi3+0x3b>
  80115f:	90                   	nop
  801160:	89 c8                	mov    %ecx,%eax
  801162:	89 fa                	mov    %edi,%edx
  801164:	83 c4 14             	add    $0x14,%esp
  801167:	5e                   	pop    %esi
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    
  80116b:	90                   	nop
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	8b 04 24             	mov    (%esp),%eax
  801173:	be 20 00 00 00       	mov    $0x20,%esi
  801178:	89 e9                	mov    %ebp,%ecx
  80117a:	29 ee                	sub    %ebp,%esi
  80117c:	d3 e2                	shl    %cl,%edx
  80117e:	89 f1                	mov    %esi,%ecx
  801180:	d3 e8                	shr    %cl,%eax
  801182:	89 e9                	mov    %ebp,%ecx
  801184:	89 44 24 04          	mov    %eax,0x4(%esp)
  801188:	8b 04 24             	mov    (%esp),%eax
  80118b:	09 54 24 04          	or     %edx,0x4(%esp)
  80118f:	89 fa                	mov    %edi,%edx
  801191:	d3 e0                	shl    %cl,%eax
  801193:	89 f1                	mov    %esi,%ecx
  801195:	89 44 24 08          	mov    %eax,0x8(%esp)
  801199:	8b 44 24 10          	mov    0x10(%esp),%eax
  80119d:	d3 ea                	shr    %cl,%edx
  80119f:	89 e9                	mov    %ebp,%ecx
  8011a1:	d3 e7                	shl    %cl,%edi
  8011a3:	89 f1                	mov    %esi,%ecx
  8011a5:	d3 e8                	shr    %cl,%eax
  8011a7:	89 e9                	mov    %ebp,%ecx
  8011a9:	09 f8                	or     %edi,%eax
  8011ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8011af:	f7 74 24 04          	divl   0x4(%esp)
  8011b3:	d3 e7                	shl    %cl,%edi
  8011b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b9:	89 d7                	mov    %edx,%edi
  8011bb:	f7 64 24 08          	mull   0x8(%esp)
  8011bf:	39 d7                	cmp    %edx,%edi
  8011c1:	89 c1                	mov    %eax,%ecx
  8011c3:	89 14 24             	mov    %edx,(%esp)
  8011c6:	72 2c                	jb     8011f4 <__umoddi3+0x134>
  8011c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011cc:	72 22                	jb     8011f0 <__umoddi3+0x130>
  8011ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011d2:	29 c8                	sub    %ecx,%eax
  8011d4:	19 d7                	sbb    %edx,%edi
  8011d6:	89 e9                	mov    %ebp,%ecx
  8011d8:	89 fa                	mov    %edi,%edx
  8011da:	d3 e8                	shr    %cl,%eax
  8011dc:	89 f1                	mov    %esi,%ecx
  8011de:	d3 e2                	shl    %cl,%edx
  8011e0:	89 e9                	mov    %ebp,%ecx
  8011e2:	d3 ef                	shr    %cl,%edi
  8011e4:	09 d0                	or     %edx,%eax
  8011e6:	89 fa                	mov    %edi,%edx
  8011e8:	83 c4 14             	add    $0x14,%esp
  8011eb:	5e                   	pop    %esi
  8011ec:	5f                   	pop    %edi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    
  8011ef:	90                   	nop
  8011f0:	39 d7                	cmp    %edx,%edi
  8011f2:	75 da                	jne    8011ce <__umoddi3+0x10e>
  8011f4:	8b 14 24             	mov    (%esp),%edx
  8011f7:	89 c1                	mov    %eax,%ecx
  8011f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8011fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801201:	eb cb                	jmp    8011ce <__umoddi3+0x10e>
  801203:	90                   	nop
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80120c:	0f 82 0f ff ff ff    	jb     801121 <__umoddi3+0x61>
  801212:	e9 1a ff ff ff       	jmp    801131 <__umoddi3+0x71>
