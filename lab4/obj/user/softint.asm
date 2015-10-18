
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
  80003b:	90                   	nop

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80004e:	e8 09 01 00 00       	call   80015c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
  80008b:	90                   	nop

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 61 00 00 00       	call   8000ff <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cb:	89 ec                	mov    %ebp,%esp
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 38             	sub    $0x38,%esp
  800105:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800108:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 28                	jle    80014f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80014a:	e8 d5 02 00 00       	call   800424 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800152:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800158:	89 ec                	mov    %ebp,%esp
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800165:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800168:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800182:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800185:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_yield>:

void
sys_yield(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800195:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800198:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019b:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a5:	89 d1                	mov    %edx,%ecx
  8001a7:	89 d3                	mov    %edx,%ebx
  8001a9:	89 d7                	mov    %edx,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b8:	89 ec                	mov    %ebp,%esp
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 38             	sub    $0x38,%esp
  8001c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cb:	be 00 00 00 00       	mov    $0x0,%esi
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	8b 55 08             	mov    0x8(%ebp),%edx
  8001de:	89 f7                	mov    %esi,%edi
  8001e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7e 28                	jle    80020e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800201:	00 
  800202:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800209:	e8 16 02 00 00       	call   800424 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80020e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800211:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800214:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800217:	89 ec                	mov    %ebp,%esp
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 38             	sub    $0x38,%esp
  800221:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800224:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800227:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	b8 05 00 00 00       	mov    $0x5,%eax
  80022f:	8b 75 18             	mov    0x18(%ebp),%esi
  800232:	8b 7d 14             	mov    0x14(%ebp),%edi
  800235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 28                	jle    80026c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	89 44 24 10          	mov    %eax,0x10(%esp)
  800248:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80024f:	00 
  800250:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800257:	00 
  800258:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025f:	00 
  800260:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800267:	e8 b8 01 00 00       	call   800424 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80026c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80026f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800275:	89 ec                	mov    %ebp,%esp
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 38             	sub    $0x38,%esp
  80027f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800282:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800285:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 06 00 00 00       	mov    $0x6,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002c5:	e8 5a 01 00 00       	call   800424 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d3:	89 ec                	mov    %ebp,%esp
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 38             	sub    $0x38,%esp
  8002dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 df                	mov    %ebx,%edi
  8002f8:	89 de                	mov    %ebx,%esi
  8002fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	7e 28                	jle    800328 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	89 44 24 10          	mov    %eax,0x10(%esp)
  800304:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80030b:	00 
  80030c:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800313:	00 
  800314:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031b:	00 
  80031c:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800323:	e8 fc 00 00 00       	call   800424 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800328:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80032e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800331:	89 ec                	mov    %ebp,%esp
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 38             	sub    $0x38,%esp
  80033b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80033e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800341:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	b8 09 00 00 00       	mov    $0x9,%eax
  80034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	89 df                	mov    %ebx,%edi
  800356:	89 de                	mov    %ebx,%esi
  800358:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800381:	e8 9e 00 00 00       	call   800424 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800386:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800389:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80038c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038f:	89 ec                	mov    %ebp,%esp
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80039c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80039f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a2:	be 00 00 00 00       	mov    $0x0,%esi
  8003a7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c3:	89 ec                	mov    %ebp,%esp
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 38             	sub    $0x38,%esp
  8003cd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e3:	89 cb                	mov    %ecx,%ebx
  8003e5:	89 cf                	mov    %ecx,%edi
  8003e7:	89 ce                	mov    %ecx,%esi
  8003e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	7e 28                	jle    800417 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800402:	00 
  800403:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040a:	00 
  80040b:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800412:	e8 0d 00 00 00       	call   800424 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800417:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80041a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80041d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800420:	89 ec                	mov    %ebp,%esp
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80042c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800435:	e8 22 fd ff ff       	call   80015c <sys_getenvid>
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800441:	8b 55 08             	mov    0x8(%ebp),%edx
  800444:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  800457:	e8 c3 00 00 00       	call   80051f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80045c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800460:	8b 45 10             	mov    0x10(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 53 00 00 00       	call   8004be <vcprintf>
	cprintf("\n");
  80046b:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  800472:	e8 a8 00 00 00       	call   80051f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800477:	cc                   	int3   
  800478:	eb fd                	jmp    800477 <_panic+0x53>
  80047a:	66 90                	xchg   %ax,%ax

0080047c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	53                   	push   %ebx
  800480:	83 ec 14             	sub    $0x14,%esp
  800483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800486:	8b 03                	mov    (%ebx),%eax
  800488:	8b 55 08             	mov    0x8(%ebp),%edx
  80048b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80048f:	83 c0 01             	add    $0x1,%eax
  800492:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800494:	3d ff 00 00 00       	cmp    $0xff,%eax
  800499:	75 19                	jne    8004b4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80049b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004a2:	00 
  8004a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 f2 fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004b8:	83 c4 14             	add    $0x14,%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ce:	00 00 00 
	b.cnt = 0;
  8004d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f3:	c7 04 24 7c 04 80 00 	movl   $0x80047c,(%esp)
  8004fa:	e8 8e 01 00 00       	call   80068d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ff:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 89 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800517:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800525:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 87 ff ff ff       	call   8004be <vcprintf>
	va_end(ap);

	return cnt;
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    
  800539:	66 90                	xchg   %ax,%ax
  80053b:	66 90                	xchg   %ax,%ax
  80053d:	66 90                	xchg   %ax,%ax
  80053f:	90                   	nop

00800540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 3c             	sub    $0x3c,%esp
  800549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054c:	89 d7                	mov    %edx,%edi
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800554:	8b 45 0c             	mov    0xc(%ebp),%eax
  800557:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80055d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800560:	85 c0                	test   %eax,%eax
  800562:	75 08                	jne    80056c <printnum+0x2c>
  800564:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800567:	39 45 10             	cmp    %eax,0x10(%ebp)
  80056a:	77 59                	ja     8005c5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80056c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800570:	83 eb 01             	sub    $0x1,%ebx
  800573:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800577:	8b 45 10             	mov    0x10(%ebp),%eax
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800582:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800586:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80058d:	00 
  80058e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800591:	89 04 24             	mov    %eax,(%esp)
  800594:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	e8 00 09 00 00       	call   800ea0 <__udivdi3>
  8005a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005af:	89 fa                	mov    %edi,%edx
  8005b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b4:	e8 87 ff ff ff       	call   800540 <printnum>
  8005b9:	eb 11                	jmp    8005cc <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c5:	83 eb 01             	sub    $0x1,%ebx
  8005c8:	85 db                	test   %ebx,%ebx
  8005ca:	7f ef                	jg     8005bb <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005e2:	00 
  8005e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f0:	e8 db 09 00 00       	call   800fd0 <__umoddi3>
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	0f be 80 9e 11 80 00 	movsbl 0x80119e(%eax),%eax
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800606:	83 c4 3c             	add    $0x3c,%esp
  800609:	5b                   	pop    %ebx
  80060a:	5e                   	pop    %esi
  80060b:	5f                   	pop    %edi
  80060c:	5d                   	pop    %ebp
  80060d:	c3                   	ret    

0080060e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800611:	83 fa 01             	cmp    $0x1,%edx
  800614:	7e 0e                	jle    800624 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8d 4a 08             	lea    0x8(%edx),%ecx
  80061b:	89 08                	mov    %ecx,(%eax)
  80061d:	8b 02                	mov    (%edx),%eax
  80061f:	8b 52 04             	mov    0x4(%edx),%edx
  800622:	eb 22                	jmp    800646 <getuint+0x38>
	else if (lflag)
  800624:	85 d2                	test   %edx,%edx
  800626:	74 10                	je     800638 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062d:	89 08                	mov    %ecx,(%eax)
  80062f:	8b 02                	mov    (%edx),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
  800636:	eb 0e                	jmp    800646 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80063d:	89 08                	mov    %ecx,(%eax)
  80063f:	8b 02                	mov    (%edx),%eax
  800641:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80064e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800652:	8b 10                	mov    (%eax),%edx
  800654:	3b 50 04             	cmp    0x4(%eax),%edx
  800657:	73 0a                	jae    800663 <sprintputch+0x1b>
		*b->buf++ = ch;
  800659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065c:	88 0a                	mov    %cl,(%edx)
  80065e:	83 c2 01             	add    $0x1,%edx
  800661:	89 10                	mov    %edx,(%eax)
}
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80066e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800672:	8b 45 10             	mov    0x10(%ebp),%eax
  800675:	89 44 24 08          	mov    %eax,0x8(%esp)
  800679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	e8 02 00 00 00       	call   80068d <vprintfmt>
	va_end(ap);
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	57                   	push   %edi
  800691:	56                   	push   %esi
  800692:	53                   	push   %ebx
  800693:	83 ec 4c             	sub    $0x4c,%esp
  800696:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800699:	8b 75 10             	mov    0x10(%ebp),%esi
  80069c:	eb 12                	jmp    8006b0 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	0f 84 bf 03 00 00    	je     800a65 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b0:	0f b6 06             	movzbl (%esi),%eax
  8006b3:	83 c6 01             	add    $0x1,%esi
  8006b6:	83 f8 25             	cmp    $0x25,%eax
  8006b9:	75 e3                	jne    80069e <vprintfmt+0x11>
  8006bb:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006c6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006cb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006da:	eb 2b                	jmp    800707 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006e3:	eb 22                	jmp    800707 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006ec:	eb 19                	jmp    800707 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8006f8:	eb 0d                	jmp    800707 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800700:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	0f b6 16             	movzbl (%esi),%edx
  80070a:	0f b6 c2             	movzbl %dl,%eax
  80070d:	8d 7e 01             	lea    0x1(%esi),%edi
  800710:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800713:	83 ea 23             	sub    $0x23,%edx
  800716:	80 fa 55             	cmp    $0x55,%dl
  800719:	0f 87 28 03 00 00    	ja     800a47 <vprintfmt+0x3ba>
  80071f:	0f b6 d2             	movzbl %dl,%edx
  800722:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  800729:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800733:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800738:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80073b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80073f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800742:	8d 50 d0             	lea    -0x30(%eax),%edx
  800745:	83 fa 09             	cmp    $0x9,%edx
  800748:	77 2f                	ja     800779 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80074a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80074d:	eb e9                	jmp    800738 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 04             	lea    0x4(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800760:	eb 1a                	jmp    80077c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800762:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800765:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800769:	79 9c                	jns    800707 <vprintfmt+0x7a>
  80076b:	eb 81                	jmp    8006ee <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800770:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800777:	eb 8e                	jmp    800707 <vprintfmt+0x7a>
  800779:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80077c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800780:	79 85                	jns    800707 <vprintfmt+0x7a>
  800782:	e9 73 ff ff ff       	jmp    8006fa <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800787:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078d:	e9 75 ff ff ff       	jmp    800707 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
  80079b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007aa:	e9 01 ff ff ff       	jmp    8006b0 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	89 c2                	mov    %eax,%edx
  8007bc:	c1 fa 1f             	sar    $0x1f,%edx
  8007bf:	31 d0                	xor    %edx,%eax
  8007c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c3:	83 f8 09             	cmp    $0x9,%eax
  8007c6:	7f 0b                	jg     8007d3 <vprintfmt+0x146>
  8007c8:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	75 23                	jne    8007f6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8007d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d7:	c7 44 24 08 b6 11 80 	movl   $0x8011b6,0x8(%esp)
  8007de:	00 
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e6:	89 3c 24             	mov    %edi,(%esp)
  8007e9:	e8 77 fe ff ff       	call   800665 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007f1:	e9 ba fe ff ff       	jmp    8006b0 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007fa:	c7 44 24 08 bf 11 80 	movl   $0x8011bf,0x8(%esp)
  800801:	00 
  800802:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800806:	8b 7d 08             	mov    0x8(%ebp),%edi
  800809:	89 3c 24             	mov    %edi,(%esp)
  80080c:	e8 54 fe ff ff       	call   800665 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800814:	e9 97 fe ff ff       	jmp    8006b0 <vprintfmt+0x23>
  800819:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80081c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 04             	lea    0x4(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)
  80082b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80082d:	85 f6                	test   %esi,%esi
  80082f:	ba af 11 80 00       	mov    $0x8011af,%edx
  800834:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800837:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80083b:	0f 8e 8c 00 00 00    	jle    8008cd <vprintfmt+0x240>
  800841:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800845:	0f 84 82 00 00 00    	je     8008cd <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  80084b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084f:	89 34 24             	mov    %esi,(%esp)
  800852:	e8 b1 02 00 00       	call   800b08 <strnlen>
  800857:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80085a:	29 c2                	sub    %eax,%edx
  80085c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80085f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800863:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800866:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800869:	89 de                	mov    %ebx,%esi
  80086b:	89 d3                	mov    %edx,%ebx
  80086d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	eb 0d                	jmp    80087e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800871:	89 74 24 04          	mov    %esi,0x4(%esp)
  800875:	89 3c 24             	mov    %edi,(%esp)
  800878:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087b:	83 eb 01             	sub    $0x1,%ebx
  80087e:	85 db                	test   %ebx,%ebx
  800880:	7f ef                	jg     800871 <vprintfmt+0x1e4>
  800882:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800885:	89 f3                	mov    %esi,%ebx
  800887:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80088a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800897:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80089a:	29 c2                	sub    %eax,%edx
  80089c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80089f:	eb 2c                	jmp    8008cd <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008a5:	74 18                	je     8008bf <vprintfmt+0x232>
  8008a7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008aa:	83 fa 5e             	cmp    $0x5e,%edx
  8008ad:	76 10                	jbe    8008bf <vprintfmt+0x232>
					putch('?', putdat);
  8008af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ba:	ff 55 08             	call   *0x8(%ebp)
  8008bd:	eb 0a                	jmp    8008c9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  8008bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008cd:	0f be 06             	movsbl (%esi),%eax
  8008d0:	83 c6 01             	add    $0x1,%esi
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	74 25                	je     8008fc <vprintfmt+0x26f>
  8008d7:	85 ff                	test   %edi,%edi
  8008d9:	78 c6                	js     8008a1 <vprintfmt+0x214>
  8008db:	83 ef 01             	sub    $0x1,%edi
  8008de:	79 c1                	jns    8008a1 <vprintfmt+0x214>
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	89 de                	mov    %ebx,%esi
  8008e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008e8:	eb 1a                	jmp    800904 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f7:	83 eb 01             	sub    $0x1,%ebx
  8008fa:	eb 08                	jmp    800904 <vprintfmt+0x277>
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	89 de                	mov    %ebx,%esi
  800901:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800904:	85 db                	test   %ebx,%ebx
  800906:	7f e2                	jg     8008ea <vprintfmt+0x25d>
  800908:	89 7d 08             	mov    %edi,0x8(%ebp)
  80090b:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800910:	e9 9b fd ff ff       	jmp    8006b0 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800915:	83 f9 01             	cmp    $0x1,%ecx
  800918:	7e 10                	jle    80092a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 08             	lea    0x8(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)
  800923:	8b 30                	mov    (%eax),%esi
  800925:	8b 78 04             	mov    0x4(%eax),%edi
  800928:	eb 26                	jmp    800950 <vprintfmt+0x2c3>
	else if (lflag)
  80092a:	85 c9                	test   %ecx,%ecx
  80092c:	74 12                	je     800940 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	89 f7                	mov    %esi,%edi
  80093b:	c1 ff 1f             	sar    $0x1f,%edi
  80093e:	eb 10                	jmp    800950 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800940:	8b 45 14             	mov    0x14(%ebp),%eax
  800943:	8d 50 04             	lea    0x4(%eax),%edx
  800946:	89 55 14             	mov    %edx,0x14(%ebp)
  800949:	8b 30                	mov    (%eax),%esi
  80094b:	89 f7                	mov    %esi,%edi
  80094d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800950:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800955:	85 ff                	test   %edi,%edi
  800957:	0f 89 ac 00 00 00    	jns    800a09 <vprintfmt+0x37c>
				putch('-', putdat);
  80095d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800961:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800968:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80096b:	f7 de                	neg    %esi
  80096d:	83 d7 00             	adc    $0x0,%edi
  800970:	f7 df                	neg    %edi
			}
			base = 10;
  800972:	b8 0a 00 00 00       	mov    $0xa,%eax
  800977:	e9 8d 00 00 00       	jmp    800a09 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80097c:	89 ca                	mov    %ecx,%edx
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
  800981:	e8 88 fc ff ff       	call   80060e <getuint>
  800986:	89 c6                	mov    %eax,%esi
  800988:	89 d7                	mov    %edx,%edi
			base = 10;
  80098a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80098f:	eb 78                	jmp    800a09 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800991:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800995:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80099c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80099f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009aa:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8009ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b1:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009b8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009be:	e9 ed fc ff ff       	jmp    8006b0 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8009c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ce:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009dc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009df:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e2:	8d 50 04             	lea    0x4(%eax),%edx
  8009e5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009e8:	8b 30                	mov    (%eax),%esi
  8009ea:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009f4:	eb 13                	jmp    800a09 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009f6:	89 ca                	mov    %ecx,%edx
  8009f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fb:	e8 0e fc ff ff       	call   80060e <getuint>
  800a00:	89 c6                	mov    %eax,%esi
  800a02:	89 d7                	mov    %edx,%edi
			base = 16;
  800a04:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a09:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a0d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1c:	89 34 24             	mov    %esi,(%esp)
  800a1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a23:	89 da                	mov    %ebx,%edx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	e8 13 fb ff ff       	call   800540 <printnum>
			break;
  800a2d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a30:	e9 7b fc ff ff       	jmp    8006b0 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a35:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a39:	89 04 24             	mov    %eax,(%esp)
  800a3c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a3f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a42:	e9 69 fc ff ff       	jmp    8006b0 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a52:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a55:	eb 03                	jmp    800a5a <vprintfmt+0x3cd>
  800a57:	83 ee 01             	sub    $0x1,%esi
  800a5a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a5e:	75 f7                	jne    800a57 <vprintfmt+0x3ca>
  800a60:	e9 4b fc ff ff       	jmp    8006b0 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a65:	83 c4 4c             	add    $0x4c,%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 28             	sub    $0x28,%esp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a7c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a80:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a8a:	85 c0                	test   %eax,%eax
  800a8c:	74 30                	je     800abe <vsnprintf+0x51>
  800a8e:	85 d2                	test   %edx,%edx
  800a90:	7e 2c                	jle    800abe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a92:	8b 45 14             	mov    0x14(%ebp),%eax
  800a95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a99:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa7:	c7 04 24 48 06 80 00 	movl   $0x800648,(%esp)
  800aae:	e8 da fb ff ff       	call   80068d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800abc:	eb 05                	jmp    800ac3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800abe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800acb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ace:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 82 ff ff ff       	call   800a6d <vsnprintf>
	va_end(ap);

	return rc;
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    
  800aed:	66 90                	xchg   %ax,%ax
  800aef:	90                   	nop

00800af0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	eb 03                	jmp    800b00 <strlen+0x10>
		n++;
  800afd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b04:	75 f7                	jne    800afd <strlen+0xd>
		n++;
	return n;
}
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb 03                	jmp    800b1b <strnlen+0x13>
		n++;
  800b18:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b1b:	39 d0                	cmp    %edx,%eax
  800b1d:	74 06                	je     800b25 <strnlen+0x1d>
  800b1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b23:	75 f3                	jne    800b18 <strnlen+0x10>
		n++;
	return n;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b3a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b3d:	83 c2 01             	add    $0x1,%edx
  800b40:	84 c9                	test   %cl,%cl
  800b42:	75 f2                	jne    800b36 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 08             	sub    $0x8,%esp
  800b4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b51:	89 1c 24             	mov    %ebx,(%esp)
  800b54:	e8 97 ff ff ff       	call   800af0 <strlen>
	strcpy(dst + len, src);
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b60:	01 d8                	add    %ebx,%eax
  800b62:	89 04 24             	mov    %eax,(%esp)
  800b65:	e8 bd ff ff ff       	call   800b27 <strcpy>
	return dst;
}
  800b6a:	89 d8                	mov    %ebx,%eax
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b85:	eb 0f                	jmp    800b96 <strncpy+0x24>
		*dst++ = *src;
  800b87:	0f b6 1a             	movzbl (%edx),%ebx
  800b8a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b8d:	80 3a 01             	cmpb   $0x1,(%edx)
  800b90:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	39 f1                	cmp    %esi,%ecx
  800b98:	75 ed                	jne    800b87 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba9:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	85 d2                	test   %edx,%edx
  800bb0:	75 0a                	jne    800bbc <strlcpy+0x1e>
  800bb2:	eb 1d                	jmp    800bd1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bb4:	88 18                	mov    %bl,(%eax)
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bbc:	83 ea 01             	sub    $0x1,%edx
  800bbf:	74 0b                	je     800bcc <strlcpy+0x2e>
  800bc1:	0f b6 19             	movzbl (%ecx),%ebx
  800bc4:	84 db                	test   %bl,%bl
  800bc6:	75 ec                	jne    800bb4 <strlcpy+0x16>
  800bc8:	89 c2                	mov    %eax,%edx
  800bca:	eb 02                	jmp    800bce <strlcpy+0x30>
  800bcc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bce:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bd1:	29 f0                	sub    %esi,%eax
}
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800be0:	eb 06                	jmp    800be8 <strcmp+0x11>
		p++, q++;
  800be2:	83 c1 01             	add    $0x1,%ecx
  800be5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be8:	0f b6 01             	movzbl (%ecx),%eax
  800beb:	84 c0                	test   %al,%al
  800bed:	74 04                	je     800bf3 <strcmp+0x1c>
  800bef:	3a 02                	cmp    (%edx),%al
  800bf1:	74 ef                	je     800be2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf3:	0f b6 c0             	movzbl %al,%eax
  800bf6:	0f b6 12             	movzbl (%edx),%edx
  800bf9:	29 d0                	sub    %edx,%eax
}
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c0a:	eb 09                	jmp    800c15 <strncmp+0x18>
		n--, p++, q++;
  800c0c:	83 ea 01             	sub    $0x1,%edx
  800c0f:	83 c0 01             	add    $0x1,%eax
  800c12:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c15:	85 d2                	test   %edx,%edx
  800c17:	74 15                	je     800c2e <strncmp+0x31>
  800c19:	0f b6 18             	movzbl (%eax),%ebx
  800c1c:	84 db                	test   %bl,%bl
  800c1e:	74 04                	je     800c24 <strncmp+0x27>
  800c20:	3a 19                	cmp    (%ecx),%bl
  800c22:	74 e8                	je     800c0c <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c24:	0f b6 00             	movzbl (%eax),%eax
  800c27:	0f b6 11             	movzbl (%ecx),%edx
  800c2a:	29 d0                	sub    %edx,%eax
  800c2c:	eb 05                	jmp    800c33 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c40:	eb 07                	jmp    800c49 <strchr+0x13>
		if (*s == c)
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	74 0f                	je     800c55 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c46:	83 c0 01             	add    $0x1,%eax
  800c49:	0f b6 10             	movzbl (%eax),%edx
  800c4c:	84 d2                	test   %dl,%dl
  800c4e:	75 f2                	jne    800c42 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c61:	eb 07                	jmp    800c6a <strfind+0x13>
		if (*s == c)
  800c63:	38 ca                	cmp    %cl,%dl
  800c65:	74 0a                	je     800c71 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c67:	83 c0 01             	add    $0x1,%eax
  800c6a:	0f b6 10             	movzbl (%eax),%edx
  800c6d:	84 d2                	test   %dl,%dl
  800c6f:	75 f2                	jne    800c63 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c82:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8b:	85 c9                	test   %ecx,%ecx
  800c8d:	74 30                	je     800cbf <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c95:	75 25                	jne    800cbc <memset+0x49>
  800c97:	f6 c1 03             	test   $0x3,%cl
  800c9a:	75 20                	jne    800cbc <memset+0x49>
		c &= 0xFF;
  800c9c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c9f:	89 d3                	mov    %edx,%ebx
  800ca1:	c1 e3 08             	shl    $0x8,%ebx
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	c1 e6 18             	shl    $0x18,%esi
  800ca9:	89 d0                	mov    %edx,%eax
  800cab:	c1 e0 10             	shl    $0x10,%eax
  800cae:	09 f0                	or     %esi,%eax
  800cb0:	09 d0                	or     %edx,%eax
  800cb2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cb4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cb7:	fc                   	cld    
  800cb8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cba:	eb 03                	jmp    800cbf <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cbc:	fc                   	cld    
  800cbd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cca:	89 ec                	mov    %ebp,%esp
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 08             	sub    $0x8,%esp
  800cd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce3:	39 c6                	cmp    %eax,%esi
  800ce5:	73 36                	jae    800d1d <memmove+0x4f>
  800ce7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	73 2f                	jae    800d1d <memmove+0x4f>
		s += n;
		d += n;
  800cee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf1:	f6 c2 03             	test   $0x3,%dl
  800cf4:	75 1b                	jne    800d11 <memmove+0x43>
  800cf6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cfc:	75 13                	jne    800d11 <memmove+0x43>
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 0e                	jne    800d11 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d03:	83 ef 04             	sub    $0x4,%edi
  800d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d09:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d0c:	fd                   	std    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb 09                	jmp    800d1a <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d11:	83 ef 01             	sub    $0x1,%edi
  800d14:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d17:	fd                   	std    
  800d18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d1a:	fc                   	cld    
  800d1b:	eb 20                	jmp    800d3d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d23:	75 13                	jne    800d38 <memmove+0x6a>
  800d25:	a8 03                	test   $0x3,%al
  800d27:	75 0f                	jne    800d38 <memmove+0x6a>
  800d29:	f6 c1 03             	test   $0x3,%cl
  800d2c:	75 0a                	jne    800d38 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d31:	89 c7                	mov    %eax,%edi
  800d33:	fc                   	cld    
  800d34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d36:	eb 05                	jmp    800d3d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d38:	89 c7                	mov    %eax,%edi
  800d3a:	fc                   	cld    
  800d3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d3d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d40:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d43:	89 ec                	mov    %ebp,%esp
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	89 04 24             	mov    %eax,(%esp)
  800d61:	e8 68 ff ff ff       	call   800cce <memmove>
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	eb 1a                	jmp    800d98 <memcmp+0x30>
		if (*s1 != *s2)
  800d7e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800d82:	83 c2 01             	add    $0x1,%edx
  800d85:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800d8a:	38 c8                	cmp    %cl,%al
  800d8c:	74 0a                	je     800d98 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800d8e:	0f b6 c0             	movzbl %al,%eax
  800d91:	0f b6 c9             	movzbl %cl,%ecx
  800d94:	29 c8                	sub    %ecx,%eax
  800d96:	eb 09                	jmp    800da1 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d98:	39 da                	cmp    %ebx,%edx
  800d9a:	75 e2                	jne    800d7e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800db4:	eb 07                	jmp    800dbd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db6:	38 08                	cmp    %cl,(%eax)
  800db8:	74 07                	je     800dc1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dba:	83 c0 01             	add    $0x1,%eax
  800dbd:	39 d0                	cmp    %edx,%eax
  800dbf:	72 f5                	jb     800db6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dcf:	eb 03                	jmp    800dd4 <strtol+0x11>
		s++;
  800dd1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd4:	0f b6 02             	movzbl (%edx),%eax
  800dd7:	3c 20                	cmp    $0x20,%al
  800dd9:	74 f6                	je     800dd1 <strtol+0xe>
  800ddb:	3c 09                	cmp    $0x9,%al
  800ddd:	74 f2                	je     800dd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ddf:	3c 2b                	cmp    $0x2b,%al
  800de1:	75 0a                	jne    800ded <strtol+0x2a>
		s++;
  800de3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi
  800deb:	eb 10                	jmp    800dfd <strtol+0x3a>
  800ded:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800df2:	3c 2d                	cmp    $0x2d,%al
  800df4:	75 07                	jne    800dfd <strtol+0x3a>
		s++, neg = 1;
  800df6:	8d 52 01             	lea    0x1(%edx),%edx
  800df9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dfd:	85 db                	test   %ebx,%ebx
  800dff:	0f 94 c0             	sete   %al
  800e02:	74 05                	je     800e09 <strtol+0x46>
  800e04:	83 fb 10             	cmp    $0x10,%ebx
  800e07:	75 15                	jne    800e1e <strtol+0x5b>
  800e09:	80 3a 30             	cmpb   $0x30,(%edx)
  800e0c:	75 10                	jne    800e1e <strtol+0x5b>
  800e0e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e12:	75 0a                	jne    800e1e <strtol+0x5b>
		s += 2, base = 16;
  800e14:	83 c2 02             	add    $0x2,%edx
  800e17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e1c:	eb 13                	jmp    800e31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e1e:	84 c0                	test   %al,%al
  800e20:	74 0f                	je     800e31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e27:	80 3a 30             	cmpb   $0x30,(%edx)
  800e2a:	75 05                	jne    800e31 <strtol+0x6e>
		s++, base = 8;
  800e2c:	83 c2 01             	add    $0x1,%edx
  800e2f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e38:	0f b6 0a             	movzbl (%edx),%ecx
  800e3b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e3e:	80 fb 09             	cmp    $0x9,%bl
  800e41:	77 08                	ja     800e4b <strtol+0x88>
			dig = *s - '0';
  800e43:	0f be c9             	movsbl %cl,%ecx
  800e46:	83 e9 30             	sub    $0x30,%ecx
  800e49:	eb 1e                	jmp    800e69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e4b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800e4e:	80 fb 19             	cmp    $0x19,%bl
  800e51:	77 08                	ja     800e5b <strtol+0x98>
			dig = *s - 'a' + 10;
  800e53:	0f be c9             	movsbl %cl,%ecx
  800e56:	83 e9 57             	sub    $0x57,%ecx
  800e59:	eb 0e                	jmp    800e69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e5b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800e5e:	80 fb 19             	cmp    $0x19,%bl
  800e61:	77 14                	ja     800e77 <strtol+0xb4>
			dig = *s - 'A' + 10;
  800e63:	0f be c9             	movsbl %cl,%ecx
  800e66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e69:	39 f1                	cmp    %esi,%ecx
  800e6b:	7d 0e                	jge    800e7b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  800e6d:	83 c2 01             	add    $0x1,%edx
  800e70:	0f af c6             	imul   %esi,%eax
  800e73:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800e75:	eb c1                	jmp    800e38 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	eb 02                	jmp    800e7d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e7b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e81:	74 05                	je     800e88 <strtol+0xc5>
		*endptr = (char *) s;
  800e83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e86:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e88:	89 ca                	mov    %ecx,%edx
  800e8a:	f7 da                	neg    %edx
  800e8c:	85 ff                	test   %edi,%edi
  800e8e:	0f 45 c2             	cmovne %edx,%eax
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	66 90                	xchg   %ax,%ax
  800e9a:	66 90                	xchg   %ax,%ax
  800e9c:	66 90                	xchg   %ax,%ax
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <__udivdi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eaa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800eae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800eb2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ebc:	89 ea                	mov    %ebp,%edx
  800ebe:	89 0c 24             	mov    %ecx,(%esp)
  800ec1:	75 2d                	jne    800ef0 <__udivdi3+0x50>
  800ec3:	39 e9                	cmp    %ebp,%ecx
  800ec5:	77 61                	ja     800f28 <__udivdi3+0x88>
  800ec7:	85 c9                	test   %ecx,%ecx
  800ec9:	89 ce                	mov    %ecx,%esi
  800ecb:	75 0b                	jne    800ed8 <__udivdi3+0x38>
  800ecd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed2:	31 d2                	xor    %edx,%edx
  800ed4:	f7 f1                	div    %ecx
  800ed6:	89 c6                	mov    %eax,%esi
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	89 e8                	mov    %ebp,%eax
  800edc:	f7 f6                	div    %esi
  800ede:	89 c5                	mov    %eax,%ebp
  800ee0:	89 f8                	mov    %edi,%eax
  800ee2:	f7 f6                	div    %esi
  800ee4:	89 ea                	mov    %ebp,%edx
  800ee6:	83 c4 0c             	add    $0xc,%esp
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
  800ef0:	39 e8                	cmp    %ebp,%eax
  800ef2:	77 24                	ja     800f18 <__udivdi3+0x78>
  800ef4:	0f bd e8             	bsr    %eax,%ebp
  800ef7:	83 f5 1f             	xor    $0x1f,%ebp
  800efa:	75 3c                	jne    800f38 <__udivdi3+0x98>
  800efc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f00:	39 34 24             	cmp    %esi,(%esp)
  800f03:	0f 86 9f 00 00 00    	jbe    800fa8 <__udivdi3+0x108>
  800f09:	39 d0                	cmp    %edx,%eax
  800f0b:	0f 82 97 00 00 00    	jb     800fa8 <__udivdi3+0x108>
  800f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	31 c0                	xor    %eax,%eax
  800f1c:	83 c4 0c             	add    $0xc,%esp
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    
  800f23:	90                   	nop
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	89 f8                	mov    %edi,%eax
  800f2a:	f7 f1                	div    %ecx
  800f2c:	31 d2                	xor    %edx,%edx
  800f2e:	83 c4 0c             	add    $0xc,%esp
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 e9                	mov    %ebp,%ecx
  800f3a:	8b 3c 24             	mov    (%esp),%edi
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	b8 20 00 00 00       	mov    $0x20,%eax
  800f46:	29 e8                	sub    %ebp,%eax
  800f48:	89 c1                	mov    %eax,%ecx
  800f4a:	d3 ef                	shr    %cl,%edi
  800f4c:	89 e9                	mov    %ebp,%ecx
  800f4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f52:	8b 3c 24             	mov    (%esp),%edi
  800f55:	09 74 24 08          	or     %esi,0x8(%esp)
  800f59:	89 d6                	mov    %edx,%esi
  800f5b:	d3 e7                	shl    %cl,%edi
  800f5d:	89 c1                	mov    %eax,%ecx
  800f5f:	89 3c 24             	mov    %edi,(%esp)
  800f62:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f66:	d3 ee                	shr    %cl,%esi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	d3 e2                	shl    %cl,%edx
  800f6c:	89 c1                	mov    %eax,%ecx
  800f6e:	d3 ef                	shr    %cl,%edi
  800f70:	09 d7                	or     %edx,%edi
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	f7 74 24 08          	divl   0x8(%esp)
  800f7a:	89 d6                	mov    %edx,%esi
  800f7c:	89 c7                	mov    %eax,%edi
  800f7e:	f7 24 24             	mull   (%esp)
  800f81:	39 d6                	cmp    %edx,%esi
  800f83:	89 14 24             	mov    %edx,(%esp)
  800f86:	72 30                	jb     800fb8 <__udivdi3+0x118>
  800f88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f8c:	89 e9                	mov    %ebp,%ecx
  800f8e:	d3 e2                	shl    %cl,%edx
  800f90:	39 c2                	cmp    %eax,%edx
  800f92:	73 05                	jae    800f99 <__udivdi3+0xf9>
  800f94:	3b 34 24             	cmp    (%esp),%esi
  800f97:	74 1f                	je     800fb8 <__udivdi3+0x118>
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	e9 7a ff ff ff       	jmp    800f1c <__udivdi3+0x7c>
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	31 d2                	xor    %edx,%edx
  800faa:	b8 01 00 00 00       	mov    $0x1,%eax
  800faf:	e9 68 ff ff ff       	jmp    800f1c <__udivdi3+0x7c>
  800fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 0c             	add    $0xc,%esp
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    
  800fc4:	66 90                	xchg   %ax,%ax
  800fc6:	66 90                	xchg   %ax,%ax
  800fc8:	66 90                	xchg   %ax,%ax
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	66 90                	xchg   %ax,%ax
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__umoddi3>:
  800fd0:	55                   	push   %ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	83 ec 14             	sub    $0x14,%esp
  800fd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fda:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fde:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fe2:	89 c7                	mov    %eax,%edi
  800fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ff0:	89 34 24             	mov    %esi,(%esp)
  800ff3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fff:	75 17                	jne    801018 <__umoddi3+0x48>
  801001:	39 fe                	cmp    %edi,%esi
  801003:	76 4b                	jbe    801050 <__umoddi3+0x80>
  801005:	89 c8                	mov    %ecx,%eax
  801007:	89 fa                	mov    %edi,%edx
  801009:	f7 f6                	div    %esi
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	31 d2                	xor    %edx,%edx
  80100f:	83 c4 14             	add    $0x14,%esp
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	66 90                	xchg   %ax,%ax
  801018:	39 f8                	cmp    %edi,%eax
  80101a:	77 54                	ja     801070 <__umoddi3+0xa0>
  80101c:	0f bd e8             	bsr    %eax,%ebp
  80101f:	83 f5 1f             	xor    $0x1f,%ebp
  801022:	75 5c                	jne    801080 <__umoddi3+0xb0>
  801024:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801028:	39 3c 24             	cmp    %edi,(%esp)
  80102b:	0f 87 e7 00 00 00    	ja     801118 <__umoddi3+0x148>
  801031:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801035:	29 f1                	sub    %esi,%ecx
  801037:	19 c7                	sbb    %eax,%edi
  801039:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801041:	8b 44 24 08          	mov    0x8(%esp),%eax
  801045:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801049:	83 c4 14             	add    $0x14,%esp
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    
  801050:	85 f6                	test   %esi,%esi
  801052:	89 f5                	mov    %esi,%ebp
  801054:	75 0b                	jne    801061 <__umoddi3+0x91>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f6                	div    %esi
  80105f:	89 c5                	mov    %eax,%ebp
  801061:	8b 44 24 04          	mov    0x4(%esp),%eax
  801065:	31 d2                	xor    %edx,%edx
  801067:	f7 f5                	div    %ebp
  801069:	89 c8                	mov    %ecx,%eax
  80106b:	f7 f5                	div    %ebp
  80106d:	eb 9c                	jmp    80100b <__umoddi3+0x3b>
  80106f:	90                   	nop
  801070:	89 c8                	mov    %ecx,%eax
  801072:	89 fa                	mov    %edi,%edx
  801074:	83 c4 14             	add    $0x14,%esp
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    
  80107b:	90                   	nop
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	8b 04 24             	mov    (%esp),%eax
  801083:	be 20 00 00 00       	mov    $0x20,%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	29 ee                	sub    %ebp,%esi
  80108c:	d3 e2                	shl    %cl,%edx
  80108e:	89 f1                	mov    %esi,%ecx
  801090:	d3 e8                	shr    %cl,%eax
  801092:	89 e9                	mov    %ebp,%ecx
  801094:	89 44 24 04          	mov    %eax,0x4(%esp)
  801098:	8b 04 24             	mov    (%esp),%eax
  80109b:	09 54 24 04          	or     %edx,0x4(%esp)
  80109f:	89 fa                	mov    %edi,%edx
  8010a1:	d3 e0                	shl    %cl,%eax
  8010a3:	89 f1                	mov    %esi,%ecx
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010ad:	d3 ea                	shr    %cl,%edx
  8010af:	89 e9                	mov    %ebp,%ecx
  8010b1:	d3 e7                	shl    %cl,%edi
  8010b3:	89 f1                	mov    %esi,%ecx
  8010b5:	d3 e8                	shr    %cl,%eax
  8010b7:	89 e9                	mov    %ebp,%ecx
  8010b9:	09 f8                	or     %edi,%eax
  8010bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010bf:	f7 74 24 04          	divl   0x4(%esp)
  8010c3:	d3 e7                	shl    %cl,%edi
  8010c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c9:	89 d7                	mov    %edx,%edi
  8010cb:	f7 64 24 08          	mull   0x8(%esp)
  8010cf:	39 d7                	cmp    %edx,%edi
  8010d1:	89 c1                	mov    %eax,%ecx
  8010d3:	89 14 24             	mov    %edx,(%esp)
  8010d6:	72 2c                	jb     801104 <__umoddi3+0x134>
  8010d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010dc:	72 22                	jb     801100 <__umoddi3+0x130>
  8010de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010e2:	29 c8                	sub    %ecx,%eax
  8010e4:	19 d7                	sbb    %edx,%edi
  8010e6:	89 e9                	mov    %ebp,%ecx
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	d3 e8                	shr    %cl,%eax
  8010ec:	89 f1                	mov    %esi,%ecx
  8010ee:	d3 e2                	shl    %cl,%edx
  8010f0:	89 e9                	mov    %ebp,%ecx
  8010f2:	d3 ef                	shr    %cl,%edi
  8010f4:	09 d0                	or     %edx,%eax
  8010f6:	89 fa                	mov    %edi,%edx
  8010f8:	83 c4 14             	add    $0x14,%esp
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    
  8010ff:	90                   	nop
  801100:	39 d7                	cmp    %edx,%edi
  801102:	75 da                	jne    8010de <__umoddi3+0x10e>
  801104:	8b 14 24             	mov    (%esp),%edx
  801107:	89 c1                	mov    %eax,%ecx
  801109:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80110d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801111:	eb cb                	jmp    8010de <__umoddi3+0x10e>
  801113:	90                   	nop
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80111c:	0f 82 0f ff ff ff    	jb     801031 <__umoddi3+0x61>
  801122:	e9 1a ff ff ff       	jmp    801041 <__umoddi3+0x71>
