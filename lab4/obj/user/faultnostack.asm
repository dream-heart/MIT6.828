
obj/user/faultnostack:     file format elf32-i386


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
	...

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
	...

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
	...

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
  800153:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  80016a:	e8 e1 02 00 00       	call   800450 <_panic>

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
  800212:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800229:	e8 22 02 00 00       	call   800450 <_panic>

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
  800270:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800287:	e8 c4 01 00 00       	call   800450 <_panic>

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
  8002ce:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  8002e5:	e8 66 01 00 00       	call   800450 <_panic>

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
  80032c:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800343:	e8 08 01 00 00       	call   800450 <_panic>

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
  80038a:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  8003a1:	e8 aa 00 00 00       	call   800450 <_panic>

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
  80041b:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 e7 11 80 00 	movl   $0x8011e7,(%esp)
  800432:	e8 19 00 00 00       	call   800450 <_panic>

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
	...

00800450 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800458:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800461:	e8 16 fd ff ff       	call   80017c <sys_getenvid>
  800466:	8b 55 0c             	mov    0xc(%ebp),%edx
  800469:	89 54 24 10          	mov    %edx,0x10(%esp)
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
  800470:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800474:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  800483:	e8 c3 00 00 00       	call   80054b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800488:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048c:	8b 45 10             	mov    0x10(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 53 00 00 00       	call   8004ea <vcprintf>
	cprintf("\n");
  800497:	c7 04 24 1b 12 80 00 	movl   $0x80121b,(%esp)
  80049e:	e8 a8 00 00 00       	call   80054b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a3:	cc                   	int3   
  8004a4:	eb fd                	jmp    8004a3 <_panic+0x53>
	...

008004a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 14             	sub    $0x14,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b2:	8b 03                	mov    (%ebx),%eax
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bb:	83 c0 01             	add    $0x1,%eax
  8004be:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c5:	75 19                	jne    8004e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ce:	00 
  8004cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	e8 e6 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e4:	83 c4 14             	add    $0x14,%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fa:	00 00 00 
	b.cnt = 0;
  8004fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800504:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 44 24 08          	mov    %eax,0x8(%esp)
  800515:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 a8 04 80 00 	movl   $0x8004a8,(%esp)
  800526:	e8 92 01 00 00       	call   8006bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	e8 7d fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800543:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800551:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 87 ff ff ff       	call   8004ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    
	...

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 3c             	sub    $0x3c,%esp
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	89 d7                	mov    %edx,%edi
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800584:	8b 45 0c             	mov    0xc(%ebp),%eax
  800587:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80058d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800590:	85 c0                	test   %eax,%eax
  800592:	75 08                	jne    80059c <printnum+0x2c>
  800594:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800597:	39 45 10             	cmp    %eax,0x10(%ebp)
  80059a:	77 59                	ja     8005f5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005a0:	83 eb 01             	sub    $0x1,%ebx
  8005a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ae:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005b2:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005b6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005bd:	00 
  8005be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c1:	89 04 24             	mov    %eax,(%esp)
  8005c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cb:	e8 30 09 00 00       	call   800f00 <__udivdi3>
  8005d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005df:	89 fa                	mov    %edi,%edx
  8005e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e4:	e8 87 ff ff ff       	call   800570 <printnum>
  8005e9:	eb 11                	jmp    8005fc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ef:	89 34 24             	mov    %esi,(%esp)
  8005f2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f5:	83 eb 01             	sub    $0x1,%ebx
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f ef                	jg     8005eb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800600:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800604:	8b 45 10             	mov    0x10(%ebp),%eax
  800607:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800612:	00 
  800613:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800620:	e8 0b 0a 00 00       	call   801030 <__umoddi3>
  800625:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800629:	0f be 80 1d 12 80 00 	movsbl 0x80121d(%eax),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800636:	83 c4 3c             	add    $0x3c,%esp
  800639:	5b                   	pop    %ebx
  80063a:	5e                   	pop    %esi
  80063b:	5f                   	pop    %edi
  80063c:	5d                   	pop    %ebp
  80063d:	c3                   	ret    

0080063e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800641:	83 fa 01             	cmp    $0x1,%edx
  800644:	7e 0e                	jle    800654 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800646:	8b 10                	mov    (%eax),%edx
  800648:	8d 4a 08             	lea    0x8(%edx),%ecx
  80064b:	89 08                	mov    %ecx,(%eax)
  80064d:	8b 02                	mov    (%edx),%eax
  80064f:	8b 52 04             	mov    0x4(%edx),%edx
  800652:	eb 22                	jmp    800676 <getuint+0x38>
	else if (lflag)
  800654:	85 d2                	test   %edx,%edx
  800656:	74 10                	je     800668 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065d:	89 08                	mov    %ecx,(%eax)
  80065f:	8b 02                	mov    (%edx),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
  800666:	eb 0e                	jmp    800676 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80067e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800682:	8b 10                	mov    (%eax),%edx
  800684:	3b 50 04             	cmp    0x4(%eax),%edx
  800687:	73 0a                	jae    800693 <sprintputch+0x1b>
		*b->buf++ = ch;
  800689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068c:	88 0a                	mov    %cl,(%edx)
  80068e:	83 c2 01             	add    $0x1,%edx
  800691:	89 10                	mov    %edx,(%eax)
}
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80069e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	e8 02 00 00 00       	call   8006bd <vprintfmt>
	va_end(ap);
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 4c             	sub    $0x4c,%esp
  8006c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8006cc:	eb 12                	jmp    8006e0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	0f 84 bf 03 00 00    	je     800a95 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	0f b6 06             	movzbl (%esi),%eax
  8006e3:	83 c6 01             	add    $0x1,%esi
  8006e6:	83 f8 25             	cmp    $0x25,%eax
  8006e9:	75 e3                	jne    8006ce <vprintfmt+0x11>
  8006eb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006f6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
  800707:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070a:	eb 2b                	jmp    800737 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800713:	eb 22                	jmp    800737 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800715:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800718:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80071c:	eb 19                	jmp    800737 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800721:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800728:	eb 0d                	jmp    800737 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80072a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800730:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	0f b6 16             	movzbl (%esi),%edx
  80073a:	0f b6 c2             	movzbl %dl,%eax
  80073d:	8d 7e 01             	lea    0x1(%esi),%edi
  800740:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800743:	83 ea 23             	sub    $0x23,%edx
  800746:	80 fa 55             	cmp    $0x55,%dl
  800749:	0f 87 28 03 00 00    	ja     800a77 <vprintfmt+0x3ba>
  80074f:	0f b6 d2             	movzbl %dl,%edx
  800752:	ff 24 95 e0 12 80 00 	jmp    *0x8012e0(,%edx,4)
  800759:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800763:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800768:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80076b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80076f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800772:	8d 50 d0             	lea    -0x30(%eax),%edx
  800775:	83 fa 09             	cmp    $0x9,%edx
  800778:	77 2f                	ja     8007a9 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80077a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80077d:	eb e9                	jmp    800768 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800790:	eb 1a                	jmp    8007ac <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800795:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800799:	79 9c                	jns    800737 <vprintfmt+0x7a>
  80079b:	eb 81                	jmp    80071e <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007a0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007a7:	eb 8e                	jmp    800737 <vprintfmt+0x7a>
  8007a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  8007ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b0:	79 85                	jns    800737 <vprintfmt+0x7a>
  8007b2:	e9 73 ff ff ff       	jmp    80072a <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007bd:	e9 75 ff ff ff       	jmp    800737 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007da:	e9 01 ff ff ff       	jmp    8006e0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	c1 fa 1f             	sar    $0x1f,%edx
  8007ef:	31 d0                	xor    %edx,%eax
  8007f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007f3:	83 f8 09             	cmp    $0x9,%eax
  8007f6:	7f 0b                	jg     800803 <vprintfmt+0x146>
  8007f8:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  8007ff:	85 d2                	test   %edx,%edx
  800801:	75 23                	jne    800826 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	c7 44 24 08 35 12 80 	movl   $0x801235,0x8(%esp)
  80080e:	00 
  80080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800813:	8b 7d 08             	mov    0x8(%ebp),%edi
  800816:	89 3c 24             	mov    %edi,(%esp)
  800819:	e8 77 fe ff ff       	call   800695 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800821:	e9 ba fe ff ff       	jmp    8006e0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800826:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80082a:	c7 44 24 08 3e 12 80 	movl   $0x80123e,0x8(%esp)
  800831:	00 
  800832:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800836:	8b 7d 08             	mov    0x8(%ebp),%edi
  800839:	89 3c 24             	mov    %edi,(%esp)
  80083c:	e8 54 fe ff ff       	call   800695 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800841:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800844:	e9 97 fe ff ff       	jmp    8006e0 <vprintfmt+0x23>
  800849:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80084c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80084f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8d 50 04             	lea    0x4(%eax),%edx
  800858:	89 55 14             	mov    %edx,0x14(%ebp)
  80085b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80085d:	85 f6                	test   %esi,%esi
  80085f:	ba 2e 12 80 00       	mov    $0x80122e,%edx
  800864:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800867:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80086b:	0f 8e 8c 00 00 00    	jle    8008fd <vprintfmt+0x240>
  800871:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800875:	0f 84 82 00 00 00    	je     8008fd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80087b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80087f:	89 34 24             	mov    %esi,(%esp)
  800882:	e8 b1 02 00 00       	call   800b38 <strnlen>
  800887:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088a:	29 c2                	sub    %eax,%edx
  80088c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80088f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800893:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800896:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800899:	89 de                	mov    %ebx,%esi
  80089b:	89 d3                	mov    %edx,%ebx
  80089d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089f:	eb 0d                	jmp    8008ae <vprintfmt+0x1f1>
					putch(padc, putdat);
  8008a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a5:	89 3c 24             	mov    %edi,(%esp)
  8008a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ab:	83 eb 01             	sub    $0x1,%ebx
  8008ae:	85 db                	test   %ebx,%ebx
  8008b0:	7f ef                	jg     8008a1 <vprintfmt+0x1e4>
  8008b2:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008b5:	89 f3                	mov    %esi,%ebx
  8008b7:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8008ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  8008c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ca:	29 c2                	sub    %eax,%edx
  8008cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008cf:	eb 2c                	jmp    8008fd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d5:	74 18                	je     8008ef <vprintfmt+0x232>
  8008d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008da:	83 fa 5e             	cmp    $0x5e,%edx
  8008dd:	76 10                	jbe    8008ef <vprintfmt+0x232>
					putch('?', putdat);
  8008df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ea:	ff 55 08             	call   *0x8(%ebp)
  8008ed:	eb 0a                	jmp    8008f9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8008ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fd:	0f be 06             	movsbl (%esi),%eax
  800900:	83 c6 01             	add    $0x1,%esi
  800903:	85 c0                	test   %eax,%eax
  800905:	74 25                	je     80092c <vprintfmt+0x26f>
  800907:	85 ff                	test   %edi,%edi
  800909:	78 c6                	js     8008d1 <vprintfmt+0x214>
  80090b:	83 ef 01             	sub    $0x1,%edi
  80090e:	79 c1                	jns    8008d1 <vprintfmt+0x214>
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	89 de                	mov    %ebx,%esi
  800915:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800918:	eb 1a                	jmp    800934 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80091a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800925:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800927:	83 eb 01             	sub    $0x1,%ebx
  80092a:	eb 08                	jmp    800934 <vprintfmt+0x277>
  80092c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092f:	89 de                	mov    %ebx,%esi
  800931:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800934:	85 db                	test   %ebx,%ebx
  800936:	7f e2                	jg     80091a <vprintfmt+0x25d>
  800938:	89 7d 08             	mov    %edi,0x8(%ebp)
  80093b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800940:	e9 9b fd ff ff       	jmp    8006e0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800945:	83 f9 01             	cmp    $0x1,%ecx
  800948:	7e 10                	jle    80095a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8d 50 08             	lea    0x8(%eax),%edx
  800950:	89 55 14             	mov    %edx,0x14(%ebp)
  800953:	8b 30                	mov    (%eax),%esi
  800955:	8b 78 04             	mov    0x4(%eax),%edi
  800958:	eb 26                	jmp    800980 <vprintfmt+0x2c3>
	else if (lflag)
  80095a:	85 c9                	test   %ecx,%ecx
  80095c:	74 12                	je     800970 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80095e:	8b 45 14             	mov    0x14(%ebp),%eax
  800961:	8d 50 04             	lea    0x4(%eax),%edx
  800964:	89 55 14             	mov    %edx,0x14(%ebp)
  800967:	8b 30                	mov    (%eax),%esi
  800969:	89 f7                	mov    %esi,%edi
  80096b:	c1 ff 1f             	sar    $0x1f,%edi
  80096e:	eb 10                	jmp    800980 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800970:	8b 45 14             	mov    0x14(%ebp),%eax
  800973:	8d 50 04             	lea    0x4(%eax),%edx
  800976:	89 55 14             	mov    %edx,0x14(%ebp)
  800979:	8b 30                	mov    (%eax),%esi
  80097b:	89 f7                	mov    %esi,%edi
  80097d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800980:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800985:	85 ff                	test   %edi,%edi
  800987:	0f 89 ac 00 00 00    	jns    800a39 <vprintfmt+0x37c>
				putch('-', putdat);
  80098d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800991:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800998:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80099b:	f7 de                	neg    %esi
  80099d:	83 d7 00             	adc    $0x0,%edi
  8009a0:	f7 df                	neg    %edi
			}
			base = 10;
  8009a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009a7:	e9 8d 00 00 00       	jmp    800a39 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ac:	89 ca                	mov    %ecx,%edx
  8009ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b1:	e8 88 fc ff ff       	call   80063e <getuint>
  8009b6:	89 c6                	mov    %eax,%esi
  8009b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8009ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009bf:	eb 78                	jmp    800a39 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c5:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009cc:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009da:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009e8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009ee:	e9 ed fc ff ff       	jmp    8006e0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8009f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009fe:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a05:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a0c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a12:	8d 50 04             	lea    0x4(%eax),%edx
  800a15:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a18:	8b 30                	mov    (%eax),%esi
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a1f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a24:	eb 13                	jmp    800a39 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a26:	89 ca                	mov    %ecx,%edx
  800a28:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2b:	e8 0e fc ff ff       	call   80063e <getuint>
  800a30:	89 c6                	mov    %eax,%esi
  800a32:	89 d7                	mov    %edx,%edi
			base = 16;
  800a34:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a39:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4c:	89 34 24             	mov    %esi,(%esp)
  800a4f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a53:	89 da                	mov    %ebx,%edx
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	e8 13 fb ff ff       	call   800570 <printnum>
			break;
  800a5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a60:	e9 7b fc ff ff       	jmp    8006e0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a69:	89 04 24             	mov    %eax,(%esp)
  800a6c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a72:	e9 69 fc ff ff       	jmp    8006e0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a82:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a85:	eb 03                	jmp    800a8a <vprintfmt+0x3cd>
  800a87:	83 ee 01             	sub    $0x1,%esi
  800a8a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a8e:	75 f7                	jne    800a87 <vprintfmt+0x3ca>
  800a90:	e9 4b fc ff ff       	jmp    8006e0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a95:	83 c4 4c             	add    $0x4c,%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 28             	sub    $0x28,%esp
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	74 30                	je     800aee <vsnprintf+0x51>
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	7e 2c                	jle    800aee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ac9:	8b 45 10             	mov    0x10(%ebp),%eax
  800acc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad7:	c7 04 24 78 06 80 00 	movl   $0x800678,(%esp)
  800ade:	e8 da fb ff ff       	call   8006bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aec:	eb 05                	jmp    800af3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800afb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800afe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 82 ff ff ff       	call   800a9d <vsnprintf>
	va_end(ap);

	return rc;
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    
  800b1d:	00 00                	add    %al,(%eax)
	...

00800b20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	eb 03                	jmp    800b30 <strlen+0x10>
		n++;
  800b2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b34:	75 f7                	jne    800b2d <strlen+0xd>
		n++;
	return n;
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	eb 03                	jmp    800b4b <strnlen+0x13>
		n++;
  800b48:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4b:	39 d0                	cmp    %edx,%eax
  800b4d:	74 06                	je     800b55 <strnlen+0x1d>
  800b4f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b53:	75 f3                	jne    800b48 <strnlen+0x10>
		n++;
	return n;
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b6a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b6d:	83 c2 01             	add    $0x1,%edx
  800b70:	84 c9                	test   %cl,%cl
  800b72:	75 f2                	jne    800b66 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b74:	5b                   	pop    %ebx
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 08             	sub    $0x8,%esp
  800b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b81:	89 1c 24             	mov    %ebx,(%esp)
  800b84:	e8 97 ff ff ff       	call   800b20 <strlen>
	strcpy(dst + len, src);
  800b89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b90:	01 d8                	add    %ebx,%eax
  800b92:	89 04 24             	mov    %eax,(%esp)
  800b95:	e8 bd ff ff ff       	call   800b57 <strcpy>
	return dst;
}
  800b9a:	89 d8                	mov    %ebx,%eax
  800b9c:	83 c4 08             	add    $0x8,%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb5:	eb 0f                	jmp    800bc6 <strncpy+0x24>
		*dst++ = *src;
  800bb7:	0f b6 1a             	movzbl (%edx),%ebx
  800bba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bbd:	80 3a 01             	cmpb   $0x1,(%edx)
  800bc0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc3:	83 c1 01             	add    $0x1,%ecx
  800bc6:	39 f1                	cmp    %esi,%ecx
  800bc8:	75 ed                	jne    800bb7 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bdc:	89 f0                	mov    %esi,%eax
  800bde:	85 d2                	test   %edx,%edx
  800be0:	75 0a                	jne    800bec <strlcpy+0x1e>
  800be2:	eb 1d                	jmp    800c01 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800be4:	88 18                	mov    %bl,(%eax)
  800be6:	83 c0 01             	add    $0x1,%eax
  800be9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bec:	83 ea 01             	sub    $0x1,%edx
  800bef:	74 0b                	je     800bfc <strlcpy+0x2e>
  800bf1:	0f b6 19             	movzbl (%ecx),%ebx
  800bf4:	84 db                	test   %bl,%bl
  800bf6:	75 ec                	jne    800be4 <strlcpy+0x16>
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	eb 02                	jmp    800bfe <strlcpy+0x30>
  800bfc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bfe:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c01:	29 f0                	sub    %esi,%eax
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c10:	eb 06                	jmp    800c18 <strcmp+0x11>
		p++, q++;
  800c12:	83 c1 01             	add    $0x1,%ecx
  800c15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c18:	0f b6 01             	movzbl (%ecx),%eax
  800c1b:	84 c0                	test   %al,%al
  800c1d:	74 04                	je     800c23 <strcmp+0x1c>
  800c1f:	3a 02                	cmp    (%edx),%al
  800c21:	74 ef                	je     800c12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c23:	0f b6 c0             	movzbl %al,%eax
  800c26:	0f b6 12             	movzbl (%edx),%edx
  800c29:	29 d0                	sub    %edx,%eax
}
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c3a:	eb 09                	jmp    800c45 <strncmp+0x18>
		n--, p++, q++;
  800c3c:	83 ea 01             	sub    $0x1,%edx
  800c3f:	83 c0 01             	add    $0x1,%eax
  800c42:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c45:	85 d2                	test   %edx,%edx
  800c47:	74 15                	je     800c5e <strncmp+0x31>
  800c49:	0f b6 18             	movzbl (%eax),%ebx
  800c4c:	84 db                	test   %bl,%bl
  800c4e:	74 04                	je     800c54 <strncmp+0x27>
  800c50:	3a 19                	cmp    (%ecx),%bl
  800c52:	74 e8                	je     800c3c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	0f b6 11             	movzbl (%ecx),%edx
  800c5a:	29 d0                	sub    %edx,%eax
  800c5c:	eb 05                	jmp    800c63 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c70:	eb 07                	jmp    800c79 <strchr+0x13>
		if (*s == c)
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	74 0f                	je     800c85 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	0f b6 10             	movzbl (%eax),%edx
  800c7c:	84 d2                	test   %dl,%dl
  800c7e:	75 f2                	jne    800c72 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c91:	eb 07                	jmp    800c9a <strfind+0x13>
		if (*s == c)
  800c93:	38 ca                	cmp    %cl,%dl
  800c95:	74 0a                	je     800ca1 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	0f b6 10             	movzbl (%eax),%edx
  800c9d:	84 d2                	test   %dl,%dl
  800c9f:	75 f2                	jne    800c93 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800caf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cbb:	85 c9                	test   %ecx,%ecx
  800cbd:	74 30                	je     800cef <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc5:	75 25                	jne    800cec <memset+0x49>
  800cc7:	f6 c1 03             	test   $0x3,%cl
  800cca:	75 20                	jne    800cec <memset+0x49>
		c &= 0xFF;
  800ccc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ccf:	89 d3                	mov    %edx,%ebx
  800cd1:	c1 e3 08             	shl    $0x8,%ebx
  800cd4:	89 d6                	mov    %edx,%esi
  800cd6:	c1 e6 18             	shl    $0x18,%esi
  800cd9:	89 d0                	mov    %edx,%eax
  800cdb:	c1 e0 10             	shl    $0x10,%eax
  800cde:	09 f0                	or     %esi,%eax
  800ce0:	09 d0                	or     %edx,%eax
  800ce2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ce4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ce7:	fc                   	cld    
  800ce8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cea:	eb 03                	jmp    800cef <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cec:	fc                   	cld    
  800ced:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfa:	89 ec                	mov    %ebp,%esp
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d07:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d13:	39 c6                	cmp    %eax,%esi
  800d15:	73 36                	jae    800d4d <memmove+0x4f>
  800d17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d1a:	39 d0                	cmp    %edx,%eax
  800d1c:	73 2f                	jae    800d4d <memmove+0x4f>
		s += n;
		d += n;
  800d1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d21:	f6 c2 03             	test   $0x3,%dl
  800d24:	75 1b                	jne    800d41 <memmove+0x43>
  800d26:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d2c:	75 13                	jne    800d41 <memmove+0x43>
  800d2e:	f6 c1 03             	test   $0x3,%cl
  800d31:	75 0e                	jne    800d41 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d33:	83 ef 04             	sub    $0x4,%edi
  800d36:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d39:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d3c:	fd                   	std    
  800d3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3f:	eb 09                	jmp    800d4a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d41:	83 ef 01             	sub    $0x1,%edi
  800d44:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d47:	fd                   	std    
  800d48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d4a:	fc                   	cld    
  800d4b:	eb 20                	jmp    800d6d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d53:	75 13                	jne    800d68 <memmove+0x6a>
  800d55:	a8 03                	test   $0x3,%al
  800d57:	75 0f                	jne    800d68 <memmove+0x6a>
  800d59:	f6 c1 03             	test   $0x3,%cl
  800d5c:	75 0a                	jne    800d68 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d5e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d61:	89 c7                	mov    %eax,%edi
  800d63:	fc                   	cld    
  800d64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d66:	eb 05                	jmp    800d6d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d68:	89 c7                	mov    %eax,%edi
  800d6a:	fc                   	cld    
  800d6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d73:	89 ec                	mov    %ebp,%esp
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	89 04 24             	mov    %eax,(%esp)
  800d91:	e8 68 ff ff ff       	call   800cfe <memmove>
}
  800d96:	c9                   	leave  
  800d97:	c3                   	ret    

00800d98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dac:	eb 1a                	jmp    800dc8 <memcmp+0x30>
		if (*s1 != *s2)
  800dae:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800db2:	83 c2 01             	add    $0x1,%edx
  800db5:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800dba:	38 c8                	cmp    %cl,%al
  800dbc:	74 0a                	je     800dc8 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800dbe:	0f b6 c0             	movzbl %al,%eax
  800dc1:	0f b6 c9             	movzbl %cl,%ecx
  800dc4:	29 c8                	sub    %ecx,%eax
  800dc6:	eb 09                	jmp    800dd1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc8:	39 da                	cmp    %ebx,%edx
  800dca:	75 e2                	jne    800dae <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de4:	eb 07                	jmp    800ded <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de6:	38 08                	cmp    %cl,(%eax)
  800de8:	74 07                	je     800df1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	39 d0                	cmp    %edx,%eax
  800def:	72 f5                	jb     800de6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dff:	eb 03                	jmp    800e04 <strtol+0x11>
		s++;
  800e01:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e04:	0f b6 02             	movzbl (%edx),%eax
  800e07:	3c 20                	cmp    $0x20,%al
  800e09:	74 f6                	je     800e01 <strtol+0xe>
  800e0b:	3c 09                	cmp    $0x9,%al
  800e0d:	74 f2                	je     800e01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e0f:	3c 2b                	cmp    $0x2b,%al
  800e11:	75 0a                	jne    800e1d <strtol+0x2a>
		s++;
  800e13:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e16:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1b:	eb 10                	jmp    800e2d <strtol+0x3a>
  800e1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e22:	3c 2d                	cmp    $0x2d,%al
  800e24:	75 07                	jne    800e2d <strtol+0x3a>
		s++, neg = 1;
  800e26:	8d 52 01             	lea    0x1(%edx),%edx
  800e29:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2d:	85 db                	test   %ebx,%ebx
  800e2f:	0f 94 c0             	sete   %al
  800e32:	74 05                	je     800e39 <strtol+0x46>
  800e34:	83 fb 10             	cmp    $0x10,%ebx
  800e37:	75 15                	jne    800e4e <strtol+0x5b>
  800e39:	80 3a 30             	cmpb   $0x30,(%edx)
  800e3c:	75 10                	jne    800e4e <strtol+0x5b>
  800e3e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e42:	75 0a                	jne    800e4e <strtol+0x5b>
		s += 2, base = 16;
  800e44:	83 c2 02             	add    $0x2,%edx
  800e47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e4c:	eb 13                	jmp    800e61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e4e:	84 c0                	test   %al,%al
  800e50:	74 0f                	je     800e61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e52:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e57:	80 3a 30             	cmpb   $0x30,(%edx)
  800e5a:	75 05                	jne    800e61 <strtol+0x6e>
		s++, base = 8;
  800e5c:	83 c2 01             	add    $0x1,%edx
  800e5f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e68:	0f b6 0a             	movzbl (%edx),%ecx
  800e6b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e6e:	80 fb 09             	cmp    $0x9,%bl
  800e71:	77 08                	ja     800e7b <strtol+0x88>
			dig = *s - '0';
  800e73:	0f be c9             	movsbl %cl,%ecx
  800e76:	83 e9 30             	sub    $0x30,%ecx
  800e79:	eb 1e                	jmp    800e99 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e7b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e7e:	80 fb 19             	cmp    $0x19,%bl
  800e81:	77 08                	ja     800e8b <strtol+0x98>
			dig = *s - 'a' + 10;
  800e83:	0f be c9             	movsbl %cl,%ecx
  800e86:	83 e9 57             	sub    $0x57,%ecx
  800e89:	eb 0e                	jmp    800e99 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e8b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e8e:	80 fb 19             	cmp    $0x19,%bl
  800e91:	77 14                	ja     800ea7 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800e93:	0f be c9             	movsbl %cl,%ecx
  800e96:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e99:	39 f1                	cmp    %esi,%ecx
  800e9b:	7d 0e                	jge    800eab <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800e9d:	83 c2 01             	add    $0x1,%edx
  800ea0:	0f af c6             	imul   %esi,%eax
  800ea3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ea5:	eb c1                	jmp    800e68 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ea7:	89 c1                	mov    %eax,%ecx
  800ea9:	eb 02                	jmp    800ead <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800eab:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ead:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb1:	74 05                	je     800eb8 <strtol+0xc5>
		*endptr = (char *) s;
  800eb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800eb8:	89 ca                	mov    %ecx,%edx
  800eba:	f7 da                	neg    %edx
  800ebc:	85 ff                	test   %edi,%edi
  800ebe:	0f 45 c2             	cmovne %edx,%eax
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    
	...

00800ec8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ece:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ed5:	75 1c                	jne    800ef3 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800ed7:	c7 44 24 08 68 14 80 	movl   $0x801468,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800ee6:	00 
  800ee7:	c7 04 24 8c 14 80 00 	movl   $0x80148c,(%esp)
  800eee:	e8 5d f5 ff ff       	call   800450 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    
  800efd:	00 00                	add    %al,(%eax)
	...

00800f00 <__udivdi3>:
  800f00:	83 ec 1c             	sub    $0x1c,%esp
  800f03:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f07:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f0b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f0f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f13:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f17:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f1b:	85 ff                	test   %edi,%edi
  800f1d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f25:	89 cd                	mov    %ecx,%ebp
  800f27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2b:	75 33                	jne    800f60 <__udivdi3+0x60>
  800f2d:	39 f1                	cmp    %esi,%ecx
  800f2f:	77 57                	ja     800f88 <__udivdi3+0x88>
  800f31:	85 c9                	test   %ecx,%ecx
  800f33:	75 0b                	jne    800f40 <__udivdi3+0x40>
  800f35:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3a:	31 d2                	xor    %edx,%edx
  800f3c:	f7 f1                	div    %ecx
  800f3e:	89 c1                	mov    %eax,%ecx
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	31 d2                	xor    %edx,%edx
  800f44:	f7 f1                	div    %ecx
  800f46:	89 c6                	mov    %eax,%esi
  800f48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f4c:	f7 f1                	div    %ecx
  800f4e:	89 f2                	mov    %esi,%edx
  800f50:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f54:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f58:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f5c:	83 c4 1c             	add    $0x1c,%esp
  800f5f:	c3                   	ret    
  800f60:	31 d2                	xor    %edx,%edx
  800f62:	31 c0                	xor    %eax,%eax
  800f64:	39 f7                	cmp    %esi,%edi
  800f66:	77 e8                	ja     800f50 <__udivdi3+0x50>
  800f68:	0f bd cf             	bsr    %edi,%ecx
  800f6b:	83 f1 1f             	xor    $0x1f,%ecx
  800f6e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f72:	75 2c                	jne    800fa0 <__udivdi3+0xa0>
  800f74:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800f78:	76 04                	jbe    800f7e <__udivdi3+0x7e>
  800f7a:	39 f7                	cmp    %esi,%edi
  800f7c:	73 d2                	jae    800f50 <__udivdi3+0x50>
  800f7e:	31 d2                	xor    %edx,%edx
  800f80:	b8 01 00 00 00       	mov    $0x1,%eax
  800f85:	eb c9                	jmp    800f50 <__udivdi3+0x50>
  800f87:	90                   	nop
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	f7 f1                	div    %ecx
  800f8c:	31 d2                	xor    %edx,%edx
  800f8e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f92:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f96:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	c3                   	ret    
  800f9e:	66 90                	xchg   %ax,%ax
  800fa0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fa5:	b8 20 00 00 00       	mov    $0x20,%eax
  800faa:	89 ea                	mov    %ebp,%edx
  800fac:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fb0:	d3 e7                	shl    %cl,%edi
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	d3 ea                	shr    %cl,%edx
  800fb6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbb:	09 fa                	or     %edi,%edx
  800fbd:	89 f7                	mov    %esi,%edi
  800fbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fc9:	d3 e5                	shl    %cl,%ebp
  800fcb:	89 c1                	mov    %eax,%ecx
  800fcd:	d3 ef                	shr    %cl,%edi
  800fcf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd4:	d3 e2                	shl    %cl,%edx
  800fd6:	89 c1                	mov    %eax,%ecx
  800fd8:	d3 ee                	shr    %cl,%esi
  800fda:	09 d6                	or     %edx,%esi
  800fdc:	89 fa                	mov    %edi,%edx
  800fde:	89 f0                	mov    %esi,%eax
  800fe0:	f7 74 24 0c          	divl   0xc(%esp)
  800fe4:	89 d7                	mov    %edx,%edi
  800fe6:	89 c6                	mov    %eax,%esi
  800fe8:	f7 e5                	mul    %ebp
  800fea:	39 d7                	cmp    %edx,%edi
  800fec:	72 22                	jb     801010 <__udivdi3+0x110>
  800fee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800ff2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff7:	d3 e5                	shl    %cl,%ebp
  800ff9:	39 c5                	cmp    %eax,%ebp
  800ffb:	73 04                	jae    801001 <__udivdi3+0x101>
  800ffd:	39 d7                	cmp    %edx,%edi
  800fff:	74 0f                	je     801010 <__udivdi3+0x110>
  801001:	89 f0                	mov    %esi,%eax
  801003:	31 d2                	xor    %edx,%edx
  801005:	e9 46 ff ff ff       	jmp    800f50 <__udivdi3+0x50>
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	8d 46 ff             	lea    -0x1(%esi),%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	8b 74 24 10          	mov    0x10(%esp),%esi
  801019:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80101d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801021:	83 c4 1c             	add    $0x1c,%esp
  801024:	c3                   	ret    
	...

00801030 <__umoddi3>:
  801030:	83 ec 1c             	sub    $0x1c,%esp
  801033:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801037:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80103b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80103f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801043:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801047:	8b 74 24 24          	mov    0x24(%esp),%esi
  80104b:	85 ed                	test   %ebp,%ebp
  80104d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801051:	89 44 24 08          	mov    %eax,0x8(%esp)
  801055:	89 cf                	mov    %ecx,%edi
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	89 f2                	mov    %esi,%edx
  80105c:	75 1a                	jne    801078 <__umoddi3+0x48>
  80105e:	39 f1                	cmp    %esi,%ecx
  801060:	76 4e                	jbe    8010b0 <__umoddi3+0x80>
  801062:	f7 f1                	div    %ecx
  801064:	89 d0                	mov    %edx,%eax
  801066:	31 d2                	xor    %edx,%edx
  801068:	8b 74 24 10          	mov    0x10(%esp),%esi
  80106c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801070:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801074:	83 c4 1c             	add    $0x1c,%esp
  801077:	c3                   	ret    
  801078:	39 f5                	cmp    %esi,%ebp
  80107a:	77 54                	ja     8010d0 <__umoddi3+0xa0>
  80107c:	0f bd c5             	bsr    %ebp,%eax
  80107f:	83 f0 1f             	xor    $0x1f,%eax
  801082:	89 44 24 04          	mov    %eax,0x4(%esp)
  801086:	75 60                	jne    8010e8 <__umoddi3+0xb8>
  801088:	3b 0c 24             	cmp    (%esp),%ecx
  80108b:	0f 87 07 01 00 00    	ja     801198 <__umoddi3+0x168>
  801091:	89 f2                	mov    %esi,%edx
  801093:	8b 34 24             	mov    (%esp),%esi
  801096:	29 ce                	sub    %ecx,%esi
  801098:	19 ea                	sbb    %ebp,%edx
  80109a:	89 34 24             	mov    %esi,(%esp)
  80109d:	8b 04 24             	mov    (%esp),%eax
  8010a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ac:	83 c4 1c             	add    $0x1c,%esp
  8010af:	c3                   	ret    
  8010b0:	85 c9                	test   %ecx,%ecx
  8010b2:	75 0b                	jne    8010bf <__umoddi3+0x8f>
  8010b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b9:	31 d2                	xor    %edx,%edx
  8010bb:	f7 f1                	div    %ecx
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	89 f0                	mov    %esi,%eax
  8010c1:	31 d2                	xor    %edx,%edx
  8010c3:	f7 f1                	div    %ecx
  8010c5:	8b 04 24             	mov    (%esp),%eax
  8010c8:	f7 f1                	div    %ecx
  8010ca:	eb 98                	jmp    801064 <__umoddi3+0x34>
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	89 f2                	mov    %esi,%edx
  8010d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010de:	83 c4 1c             	add    $0x1c,%esp
  8010e1:	c3                   	ret    
  8010e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ed:	89 e8                	mov    %ebp,%eax
  8010ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8010f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	d3 e0                	shl    %cl,%eax
  8010fc:	89 e9                	mov    %ebp,%ecx
  8010fe:	d3 ea                	shr    %cl,%edx
  801100:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801105:	09 c2                	or     %eax,%edx
  801107:	8b 44 24 08          	mov    0x8(%esp),%eax
  80110b:	89 14 24             	mov    %edx,(%esp)
  80110e:	89 f2                	mov    %esi,%edx
  801110:	d3 e7                	shl    %cl,%edi
  801112:	89 e9                	mov    %ebp,%ecx
  801114:	d3 ea                	shr    %cl,%edx
  801116:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111f:	d3 e6                	shl    %cl,%esi
  801121:	89 e9                	mov    %ebp,%ecx
  801123:	d3 e8                	shr    %cl,%eax
  801125:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112a:	09 f0                	or     %esi,%eax
  80112c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801130:	f7 34 24             	divl   (%esp)
  801133:	d3 e6                	shl    %cl,%esi
  801135:	89 74 24 08          	mov    %esi,0x8(%esp)
  801139:	89 d6                	mov    %edx,%esi
  80113b:	f7 e7                	mul    %edi
  80113d:	39 d6                	cmp    %edx,%esi
  80113f:	89 c1                	mov    %eax,%ecx
  801141:	89 d7                	mov    %edx,%edi
  801143:	72 3f                	jb     801184 <__umoddi3+0x154>
  801145:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801149:	72 35                	jb     801180 <__umoddi3+0x150>
  80114b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80114f:	29 c8                	sub    %ecx,%eax
  801151:	19 fe                	sbb    %edi,%esi
  801153:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801158:	89 f2                	mov    %esi,%edx
  80115a:	d3 e8                	shr    %cl,%eax
  80115c:	89 e9                	mov    %ebp,%ecx
  80115e:	d3 e2                	shl    %cl,%edx
  801160:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801165:	09 d0                	or     %edx,%eax
  801167:	89 f2                	mov    %esi,%edx
  801169:	d3 ea                	shr    %cl,%edx
  80116b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80116f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801173:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801177:	83 c4 1c             	add    $0x1c,%esp
  80117a:	c3                   	ret    
  80117b:	90                   	nop
  80117c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801180:	39 d6                	cmp    %edx,%esi
  801182:	75 c7                	jne    80114b <__umoddi3+0x11b>
  801184:	89 d7                	mov    %edx,%edi
  801186:	89 c1                	mov    %eax,%ecx
  801188:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80118c:	1b 3c 24             	sbb    (%esp),%edi
  80118f:	eb ba                	jmp    80114b <__umoddi3+0x11b>
  801191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801198:	39 f5                	cmp    %esi,%ebp
  80119a:	0f 82 f1 fe ff ff    	jb     801091 <__umoddi3+0x61>
  8011a0:	e9 f8 fe ff ff       	jmp    80109d <__umoddi3+0x6d>
