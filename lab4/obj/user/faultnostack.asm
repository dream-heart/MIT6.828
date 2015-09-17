
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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 84 03 80 	movl   $0x800384,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 6f 02 00 00       	call   8002bc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	83 ec 18             	sub    $0x18,%esp
  80005f:	8b 45 08             	mov    0x8(%ebp),%eax
  800062:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800065:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80006c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 c0                	test   %eax,%eax
  800071:	7e 08                	jle    80007b <libmain+0x22>
		binaryname = argv[0];
  800073:	8b 0a                	mov    (%edx),%ecx
  800075:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 02 00 00 00       	call   80008e <exit>
}
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009b:	e8 3f 00 00 00       	call   8000df <sys_env_destroy>
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 28                	jle    800129 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	89 44 24 10          	mov    %eax,0x10(%esp)
  800105:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010c:	00 
  80010d:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011c:	00 
  80011d:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800124:	e8 66 02 00 00       	call   80038f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800129:	83 c4 2c             	add    $0x2c,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 02 00 00 00       	mov    $0x2,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_yield>:

void
sys_yield(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	be 00 00 00 00       	mov    $0x0,%esi
  80017d:	b8 04 00 00 00       	mov    $0x4,%eax
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	89 f7                	mov    %esi,%edi
  80018d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 28                	jle    8001bb <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800193:	89 44 24 10          	mov    %eax,0x10(%esp)
  800197:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019e:	00 
  80019f:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001a6:	00 
  8001a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ae:	00 
  8001af:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001b6:	e8 d4 01 00 00       	call   80038f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bb:	83 c4 2c             	add    $0x2c,%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    

008001c3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	57                   	push   %edi
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7e 28                	jle    80020e <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ea:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800201:	00 
  800202:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800209:	e8 81 01 00 00       	call   80038f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020e:	83 c4 2c             	add    $0x2c,%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	57                   	push   %edi
  80021a:	56                   	push   %esi
  80021b:	53                   	push   %ebx
  80021c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800224:	b8 06 00 00 00       	mov    $0x6,%eax
  800229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	89 df                	mov    %ebx,%edi
  800231:	89 de                	mov    %ebx,%esi
  800233:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800235:	85 c0                	test   %eax,%eax
  800237:	7e 28                	jle    800261 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800239:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023d:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800244:	00 
  800245:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80024c:	00 
  80024d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800254:	00 
  800255:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80025c:	e8 2e 01 00 00       	call   80038f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800261:	83 c4 2c             	add    $0x2c,%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	b8 08 00 00 00       	mov    $0x8,%eax
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7e 28                	jle    8002b4 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800290:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800297:	00 
  800298:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80029f:	00 
  8002a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a7:	00 
  8002a8:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002af:	e8 db 00 00 00       	call   80038f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b4:	83 c4 2c             	add    $0x2c,%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ca:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d5:	89 df                	mov    %ebx,%edi
  8002d7:	89 de                	mov    %ebx,%esi
  8002d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	7e 28                	jle    800307 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002ea:	00 
  8002eb:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8002f2:	00 
  8002f3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fa:	00 
  8002fb:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800302:	e8 88 00 00 00       	call   80038f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800307:	83 c4 2c             	add    $0x2c,%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800315:	be 00 00 00 00       	mov    $0x0,%esi
  80031a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80031f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800328:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800340:	b8 0c 00 00 00       	mov    $0xc,%eax
  800345:	8b 55 08             	mov    0x8(%ebp),%edx
  800348:	89 cb                	mov    %ecx,%ebx
  80034a:	89 cf                	mov    %ecx,%edi
  80034c:	89 ce                	mov    %ecx,%esi
  80034e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 28                	jle    80037c <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	89 44 24 10          	mov    %eax,0x10(%esp)
  800358:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80035f:	00 
  800360:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800367:	00 
  800368:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036f:	00 
  800370:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800377:	e8 13 00 00 00       	call   80038f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037c:	83 c4 2c             	add    $0x2c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800384:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800385:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80038a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80038c:	83 c4 04             	add    $0x4,%esp

0080038f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003a0:	e8 8c fd ff ff       	call   800131 <sys_getenvid>
  8003a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bb:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8003c2:	e8 c1 00 00 00       	call   800488 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ce:	89 04 24             	mov    %eax,(%esp)
  8003d1:	e8 51 00 00 00       	call   800427 <vcprintf>
	cprintf("\n");
  8003d6:	c7 04 24 7b 11 80 00 	movl   $0x80117b,(%esp)
  8003dd:	e8 a6 00 00 00       	call   800488 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e2:	cc                   	int3   
  8003e3:	eb fd                	jmp    8003e2 <_panic+0x53>

008003e5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 14             	sub    $0x14,%esp
  8003ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ef:	8b 13                	mov    (%ebx),%edx
  8003f1:	8d 42 01             	lea    0x1(%edx),%eax
  8003f4:	89 03                	mov    %eax,(%ebx)
  8003f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800402:	75 19                	jne    80041d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800404:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040b:	00 
  80040c:	8d 43 08             	lea    0x8(%ebx),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	e8 8b fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800417:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800421:	83 c4 14             	add    $0x14,%esp
  800424:	5b                   	pop    %ebx
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800430:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800437:	00 00 00 
	b.cnt = 0;
  80043a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800441:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800452:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	c7 04 24 e5 03 80 00 	movl   $0x8003e5,(%esp)
  800463:	e8 7c 01 00 00       	call   8005e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800468:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800472:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 22 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800480:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 87 ff ff ff       	call   800427 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
  8004a2:	66 90                	xchg   %ax,%ax
  8004a4:	66 90                	xchg   %ax,%ax
  8004a6:	66 90                	xchg   %ax,%ax
  8004a8:	66 90                	xchg   %ax,%ax
  8004aa:	66 90                	xchg   %ax,%ax
  8004ac:	66 90                	xchg   %ax,%ax
  8004ae:	66 90                	xchg   %ax,%ax

008004b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 3c             	sub    $0x3c,%esp
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	89 d7                	mov    %edx,%edi
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	89 c3                	mov    %eax,%ebx
  8004c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004dd:	39 d9                	cmp    %ebx,%ecx
  8004df:	72 05                	jb     8004e6 <printnum+0x36>
  8004e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004e4:	77 69                	ja     80054f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004e9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004ed:	83 ee 01             	sub    $0x1,%esi
  8004f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800500:	89 c3                	mov    %eax,%ebx
  800502:	89 d6                	mov    %edx,%esi
  800504:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800507:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80050a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80050e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800512:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800515:	89 04 24             	mov    %eax,(%esp)
  800518:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	e8 6c 09 00 00       	call   800e90 <__udivdi3>
  800524:	89 d9                	mov    %ebx,%ecx
  800526:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80052a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	89 54 24 04          	mov    %edx,0x4(%esp)
  800535:	89 fa                	mov    %edi,%edx
  800537:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053a:	e8 71 ff ff ff       	call   8004b0 <printnum>
  80053f:	eb 1b                	jmp    80055c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800541:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800545:	8b 45 18             	mov    0x18(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	ff d3                	call   *%ebx
  80054d:	eb 03                	jmp    800552 <printnum+0xa2>
  80054f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800552:	83 ee 01             	sub    $0x1,%esi
  800555:	85 f6                	test   %esi,%esi
  800557:	7f e8                	jg     800541 <printnum+0x91>
  800559:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80055c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800560:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800572:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	e8 3c 0a 00 00       	call   800fc0 <__umoddi3>
  800584:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800588:	0f be 80 7d 11 80 00 	movsbl 0x80117d(%eax),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800595:	ff d0                	call   *%eax
}
  800597:	83 c4 3c             	add    $0x3c,%esp
  80059a:	5b                   	pop    %ebx
  80059b:	5e                   	pop    %esi
  80059c:	5f                   	pop    %edi
  80059d:	5d                   	pop    %ebp
  80059e:	c3                   	ret    

0080059f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059f:	55                   	push   %ebp
  8005a0:	89 e5                	mov    %esp,%ebp
  8005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 0a                	jae    8005ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b3:	89 08                	mov    %ecx,(%eax)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	88 02                	mov    %al,(%edx)
}
  8005ba:	5d                   	pop    %ebp
  8005bb:	c3                   	ret    

008005bc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 02 00 00 00       	call   8005e4 <vprintfmt>
	va_end(ap);
}
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	57                   	push   %edi
  8005e8:	56                   	push   %esi
  8005e9:	53                   	push   %ebx
  8005ea:	83 ec 3c             	sub    $0x3c,%esp
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005f6:	eb 11                	jmp    800609 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	0f 84 48 04 00 00    	je     800a48 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800609:	83 c7 01             	add    $0x1,%edi
  80060c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800610:	83 f8 25             	cmp    $0x25,%eax
  800613:	75 e3                	jne    8005f8 <vprintfmt+0x14>
  800615:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800619:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800620:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800627:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800633:	eb 1f                	jmp    800654 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800638:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80063c:	eb 16                	jmp    800654 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800641:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800645:	eb 0d                	jmp    800654 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800647:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80064a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800654:	8d 47 01             	lea    0x1(%edi),%eax
  800657:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80065a:	0f b6 17             	movzbl (%edi),%edx
  80065d:	0f b6 c2             	movzbl %dl,%eax
  800660:	83 ea 23             	sub    $0x23,%edx
  800663:	80 fa 55             	cmp    $0x55,%dl
  800666:	0f 87 bf 03 00 00    	ja     800a2b <vprintfmt+0x447>
  80066c:	0f b6 d2             	movzbl %dl,%edx
  80066f:	ff 24 95 40 12 80 00 	jmp    *0x801240(,%edx,4)
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800681:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800684:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800688:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80068b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80068e:	83 f9 09             	cmp    $0x9,%ecx
  800691:	77 3c                	ja     8006cf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800693:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800696:	eb e9                	jmp    800681 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ac:	eb 27                	jmp    8006d5 <vprintfmt+0xf1>
  8006ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006b1:	85 d2                	test   %edx,%edx
  8006b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b8:	0f 49 c2             	cmovns %edx,%eax
  8006bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c1:	eb 91                	jmp    800654 <vprintfmt+0x70>
  8006c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006cd:	eb 85                	jmp    800654 <vprintfmt+0x70>
  8006cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006d2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	0f 89 75 ff ff ff    	jns    800654 <vprintfmt+0x70>
  8006df:	e9 63 ff ff ff       	jmp    800647 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006e4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ea:	e9 65 ff ff ff       	jmp    800654 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006f2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800704:	e9 00 ff ff ff       	jmp    800609 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80070c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	99                   	cltd   
  800713:	31 d0                	xor    %edx,%eax
  800715:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800717:	83 f8 09             	cmp    $0x9,%eax
  80071a:	7f 0b                	jg     800727 <vprintfmt+0x143>
  80071c:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  800723:	85 d2                	test   %edx,%edx
  800725:	75 20                	jne    800747 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800727:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072b:	c7 44 24 08 95 11 80 	movl   $0x801195,0x8(%esp)
  800732:	00 
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	89 34 24             	mov    %esi,(%esp)
  80073a:	e8 7d fe ff ff       	call   8005bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800742:	e9 c2 fe ff ff       	jmp    800609 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800747:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074b:	c7 44 24 08 9e 11 80 	movl   $0x80119e,0x8(%esp)
  800752:	00 
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	89 34 24             	mov    %esi,(%esp)
  80075a:	e8 5d fe ff ff       	call   8005bc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800762:	e9 a2 fe ff ff       	jmp    800609 <vprintfmt+0x25>
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80076d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800770:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800773:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800777:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800779:	85 ff                	test   %edi,%edi
  80077b:	b8 8e 11 80 00       	mov    $0x80118e,%eax
  800780:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800783:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800787:	0f 84 92 00 00 00    	je     80081f <vprintfmt+0x23b>
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	0f 8e 98 00 00 00    	jle    80082d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	89 3c 24             	mov    %edi,(%esp)
  80079c:	e8 47 03 00 00       	call   800ae8 <strnlen>
  8007a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007a4:	29 c1                	sub    %eax,%ecx
  8007a6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b5:	eb 0f                	jmp    8007c6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c3:	83 ef 01             	sub    $0x1,%edi
  8007c6:	85 ff                	test   %edi,%edi
  8007c8:	7f ed                	jg     8007b7 <vprintfmt+0x1d3>
  8007ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007d0:	85 c9                	test   %ecx,%ecx
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	0f 49 c1             	cmovns %ecx,%eax
  8007da:	29 c1                	sub    %eax,%ecx
  8007dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007e5:	89 cb                	mov    %ecx,%ebx
  8007e7:	eb 50                	jmp    800839 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ed:	74 1e                	je     80080d <vprintfmt+0x229>
  8007ef:	0f be d2             	movsbl %dl,%edx
  8007f2:	83 ea 20             	sub    $0x20,%edx
  8007f5:	83 fa 5e             	cmp    $0x5e,%edx
  8007f8:	76 13                	jbe    80080d <vprintfmt+0x229>
					putch('?', putdat);
  8007fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800808:	ff 55 08             	call   *0x8(%ebp)
  80080b:	eb 0d                	jmp    80081a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081a:	83 eb 01             	sub    $0x1,%ebx
  80081d:	eb 1a                	jmp    800839 <vprintfmt+0x255>
  80081f:	89 75 08             	mov    %esi,0x8(%ebp)
  800822:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800825:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800828:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80082b:	eb 0c                	jmp    800839 <vprintfmt+0x255>
  80082d:	89 75 08             	mov    %esi,0x8(%ebp)
  800830:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800833:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800836:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800839:	83 c7 01             	add    $0x1,%edi
  80083c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800840:	0f be c2             	movsbl %dl,%eax
  800843:	85 c0                	test   %eax,%eax
  800845:	74 25                	je     80086c <vprintfmt+0x288>
  800847:	85 f6                	test   %esi,%esi
  800849:	78 9e                	js     8007e9 <vprintfmt+0x205>
  80084b:	83 ee 01             	sub    $0x1,%esi
  80084e:	79 99                	jns    8007e9 <vprintfmt+0x205>
  800850:	89 df                	mov    %ebx,%edi
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800858:	eb 1a                	jmp    800874 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800865:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800867:	83 ef 01             	sub    $0x1,%edi
  80086a:	eb 08                	jmp    800874 <vprintfmt+0x290>
  80086c:	89 df                	mov    %ebx,%edi
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800874:	85 ff                	test   %edi,%edi
  800876:	7f e2                	jg     80085a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087b:	e9 89 fd ff ff       	jmp    800609 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800880:	83 f9 01             	cmp    $0x1,%ecx
  800883:	7e 19                	jle    80089e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8b 50 04             	mov    0x4(%eax),%edx
  80088b:	8b 00                	mov    (%eax),%eax
  80088d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800890:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8d 40 08             	lea    0x8(%eax),%eax
  800899:	89 45 14             	mov    %eax,0x14(%ebp)
  80089c:	eb 38                	jmp    8008d6 <vprintfmt+0x2f2>
	else if (lflag)
  80089e:	85 c9                	test   %ecx,%ecx
  8008a0:	74 1b                	je     8008bd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008aa:	89 c1                	mov    %eax,%ecx
  8008ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8008af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 40 04             	lea    0x4(%eax),%eax
  8008b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bb:	eb 19                	jmp    8008d6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c5:	89 c1                	mov    %eax,%ecx
  8008c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 40 04             	lea    0x4(%eax),%eax
  8008d3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008dc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008e5:	0f 89 04 01 00 00    	jns    8009ef <vprintfmt+0x40b>
				putch('-', putdat);
  8008eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ef:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008fe:	f7 da                	neg    %edx
  800900:	83 d1 00             	adc    $0x0,%ecx
  800903:	f7 d9                	neg    %ecx
  800905:	e9 e5 00 00 00       	jmp    8009ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80090a:	83 f9 01             	cmp    $0x1,%ecx
  80090d:	7e 10                	jle    80091f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	8b 48 04             	mov    0x4(%eax),%ecx
  800917:	8d 40 08             	lea    0x8(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
  80091d:	eb 26                	jmp    800945 <vprintfmt+0x361>
	else if (lflag)
  80091f:	85 c9                	test   %ecx,%ecx
  800921:	74 12                	je     800935 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 10                	mov    (%eax),%edx
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092d:	8d 40 04             	lea    0x4(%eax),%eax
  800930:	89 45 14             	mov    %eax,0x14(%ebp)
  800933:	eb 10                	jmp    800945 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800935:	8b 45 14             	mov    0x14(%ebp),%eax
  800938:	8b 10                	mov    (%eax),%edx
  80093a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093f:	8d 40 04             	lea    0x4(%eax),%eax
  800942:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800945:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80094a:	e9 a0 00 00 00       	jmp    8009ef <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80094f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800953:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80095a:	ff d6                	call   *%esi
			putch('X', putdat);
  80095c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800960:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800967:	ff d6                	call   *%esi
			putch('X', putdat);
  800969:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800974:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800976:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800979:	e9 8b fc ff ff       	jmp    800609 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80097e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800982:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800989:	ff d6                	call   *%esi
			putch('x', putdat);
  80098b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800996:	ff d6                	call   *%esi
			num = (unsigned long long)
  800998:	8b 45 14             	mov    0x14(%ebp),%eax
  80099b:	8b 10                	mov    (%eax),%edx
  80099d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009a2:	8d 40 04             	lea    0x4(%eax),%eax
  8009a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009ad:	eb 40                	jmp    8009ef <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009af:	83 f9 01             	cmp    $0x1,%ecx
  8009b2:	7e 10                	jle    8009c4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8b 10                	mov    (%eax),%edx
  8009b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009bc:	8d 40 08             	lea    0x8(%eax),%eax
  8009bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c2:	eb 26                	jmp    8009ea <vprintfmt+0x406>
	else if (lflag)
  8009c4:	85 c9                	test   %ecx,%ecx
  8009c6:	74 12                	je     8009da <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cb:	8b 10                	mov    (%eax),%edx
  8009cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d2:	8d 40 04             	lea    0x4(%eax),%eax
  8009d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009d8:	eb 10                	jmp    8009ea <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009da:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dd:	8b 10                	mov    (%eax),%edx
  8009df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e4:	8d 40 04             	lea    0x4(%eax),%eax
  8009e7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a02:	89 14 24             	mov    %edx,(%esp)
  800a05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a09:	89 da                	mov    %ebx,%edx
  800a0b:	89 f0                	mov    %esi,%eax
  800a0d:	e8 9e fa ff ff       	call   8004b0 <printnum>
			break;
  800a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a15:	e9 ef fb ff ff       	jmp    800609 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a26:	e9 de fb ff ff       	jmp    800609 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a36:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a38:	eb 03                	jmp    800a3d <vprintfmt+0x459>
  800a3a:	83 ef 01             	sub    $0x1,%edi
  800a3d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a41:	75 f7                	jne    800a3a <vprintfmt+0x456>
  800a43:	e9 c1 fb ff ff       	jmp    800609 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a48:	83 c4 3c             	add    $0x3c,%esp
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 28             	sub    $0x28,%esp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a5f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a63:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	74 30                	je     800aa1 <vsnprintf+0x51>
  800a71:	85 d2                	test   %edx,%edx
  800a73:	7e 2c                	jle    800aa1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a75:	8b 45 14             	mov    0x14(%ebp),%eax
  800a78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	c7 04 24 9f 05 80 00 	movl   $0x80059f,(%esp)
  800a91:	e8 4e fb ff ff       	call   8005e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a96:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a99:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a9f:	eb 05                	jmp    800aa6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800aa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ab1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	e8 82 ff ff ff       	call   800a50 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	eb 03                	jmp    800ae0 <strlen+0x10>
		n++;
  800add:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae4:	75 f7                	jne    800add <strlen+0xd>
		n++;
	return n;
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	eb 03                	jmp    800afb <strnlen+0x13>
		n++;
  800af8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800afb:	39 d0                	cmp    %edx,%eax
  800afd:	74 06                	je     800b05 <strnlen+0x1d>
  800aff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b03:	75 f3                	jne    800af8 <strnlen+0x10>
		n++;
	return n;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b20:	84 db                	test   %bl,%bl
  800b22:	75 ef                	jne    800b13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b31:	89 1c 24             	mov    %ebx,(%esp)
  800b34:	e8 97 ff ff ff       	call   800ad0 <strlen>
	strcpy(dst + len, src);
  800b39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b40:	01 d8                	add    %ebx,%eax
  800b42:	89 04 24             	mov    %eax,(%esp)
  800b45:	e8 bd ff ff ff       	call   800b07 <strcpy>
	return dst;
}
  800b4a:	89 d8                	mov    %ebx,%eax
  800b4c:	83 c4 08             	add    $0x8,%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 f3                	mov    %esi,%ebx
  800b5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b62:	89 f2                	mov    %esi,%edx
  800b64:	eb 0f                	jmp    800b75 <strncpy+0x23>
		*dst++ = *src;
  800b66:	83 c2 01             	add    $0x1,%edx
  800b69:	0f b6 01             	movzbl (%ecx),%eax
  800b6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b72:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b75:	39 da                	cmp    %ebx,%edx
  800b77:	75 ed                	jne    800b66 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 75 08             	mov    0x8(%ebp),%esi
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b93:	85 c9                	test   %ecx,%ecx
  800b95:	75 0b                	jne    800ba2 <strlcpy+0x23>
  800b97:	eb 1d                	jmp    800bb6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b99:	83 c0 01             	add    $0x1,%eax
  800b9c:	83 c2 01             	add    $0x1,%edx
  800b9f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba2:	39 d8                	cmp    %ebx,%eax
  800ba4:	74 0b                	je     800bb1 <strlcpy+0x32>
  800ba6:	0f b6 0a             	movzbl (%edx),%ecx
  800ba9:	84 c9                	test   %cl,%cl
  800bab:	75 ec                	jne    800b99 <strlcpy+0x1a>
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	eb 02                	jmp    800bb3 <strlcpy+0x34>
  800bb1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bb3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bb6:	29 f0                	sub    %esi,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bc5:	eb 06                	jmp    800bcd <strcmp+0x11>
		p++, q++;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bcd:	0f b6 01             	movzbl (%ecx),%eax
  800bd0:	84 c0                	test   %al,%al
  800bd2:	74 04                	je     800bd8 <strcmp+0x1c>
  800bd4:	3a 02                	cmp    (%edx),%al
  800bd6:	74 ef                	je     800bc7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd8:	0f b6 c0             	movzbl %al,%eax
  800bdb:	0f b6 12             	movzbl (%edx),%edx
  800bde:	29 d0                	sub    %edx,%eax
}
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	53                   	push   %ebx
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bf1:	eb 06                	jmp    800bf9 <strncmp+0x17>
		n--, p++, q++;
  800bf3:	83 c0 01             	add    $0x1,%eax
  800bf6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bf9:	39 d8                	cmp    %ebx,%eax
  800bfb:	74 15                	je     800c12 <strncmp+0x30>
  800bfd:	0f b6 08             	movzbl (%eax),%ecx
  800c00:	84 c9                	test   %cl,%cl
  800c02:	74 04                	je     800c08 <strncmp+0x26>
  800c04:	3a 0a                	cmp    (%edx),%cl
  800c06:	74 eb                	je     800bf3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 00             	movzbl (%eax),%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
  800c10:	eb 05                	jmp    800c17 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c24:	eb 07                	jmp    800c2d <strchr+0x13>
		if (*s == c)
  800c26:	38 ca                	cmp    %cl,%dl
  800c28:	74 0f                	je     800c39 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	84 d2                	test   %dl,%dl
  800c32:	75 f2                	jne    800c26 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	eb 07                	jmp    800c4e <strfind+0x13>
		if (*s == c)
  800c47:	38 ca                	cmp    %cl,%dl
  800c49:	74 0a                	je     800c55 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c4b:	83 c0 01             	add    $0x1,%eax
  800c4e:	0f b6 10             	movzbl (%eax),%edx
  800c51:	84 d2                	test   %dl,%dl
  800c53:	75 f2                	jne    800c47 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c63:	85 c9                	test   %ecx,%ecx
  800c65:	74 36                	je     800c9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6d:	75 28                	jne    800c97 <memset+0x40>
  800c6f:	f6 c1 03             	test   $0x3,%cl
  800c72:	75 23                	jne    800c97 <memset+0x40>
		c &= 0xFF;
  800c74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	c1 e3 08             	shl    $0x8,%ebx
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	c1 e6 18             	shl    $0x18,%esi
  800c82:	89 d0                	mov    %edx,%eax
  800c84:	c1 e0 10             	shl    $0x10,%eax
  800c87:	09 f0                	or     %esi,%eax
  800c89:	09 c2                	or     %eax,%edx
  800c8b:	89 d0                	mov    %edx,%eax
  800c8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c8f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c92:	fc                   	cld    
  800c93:	f3 ab                	rep stos %eax,%es:(%edi)
  800c95:	eb 06                	jmp    800c9d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9a:	fc                   	cld    
  800c9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c9d:	89 f8                	mov    %edi,%eax
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800caf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cb2:	39 c6                	cmp    %eax,%esi
  800cb4:	73 35                	jae    800ceb <memmove+0x47>
  800cb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cb9:	39 d0                	cmp    %edx,%eax
  800cbb:	73 2e                	jae    800ceb <memmove+0x47>
		s += n;
		d += n;
  800cbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cca:	75 13                	jne    800cdf <memmove+0x3b>
  800ccc:	f6 c1 03             	test   $0x3,%cl
  800ccf:	75 0e                	jne    800cdf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cd1:	83 ef 04             	sub    $0x4,%edi
  800cd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cd7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cda:	fd                   	std    
  800cdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdd:	eb 09                	jmp    800ce8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cdf:	83 ef 01             	sub    $0x1,%edi
  800ce2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ce5:	fd                   	std    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce8:	fc                   	cld    
  800ce9:	eb 1d                	jmp    800d08 <memmove+0x64>
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cef:	f6 c2 03             	test   $0x3,%dl
  800cf2:	75 0f                	jne    800d03 <memmove+0x5f>
  800cf4:	f6 c1 03             	test   $0x3,%cl
  800cf7:	75 0a                	jne    800d03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cf9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	fc                   	cld    
  800cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d01:	eb 05                	jmp    800d08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d03:	89 c7                	mov    %eax,%edi
  800d05:	fc                   	cld    
  800d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d12:	8b 45 10             	mov    0x10(%ebp),%eax
  800d15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	89 04 24             	mov    %eax,(%esp)
  800d26:	e8 79 ff ff ff       	call   800ca4 <memmove>
}
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    

00800d2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3d:	eb 1a                	jmp    800d59 <memcmp+0x2c>
		if (*s1 != *s2)
  800d3f:	0f b6 02             	movzbl (%edx),%eax
  800d42:	0f b6 19             	movzbl (%ecx),%ebx
  800d45:	38 d8                	cmp    %bl,%al
  800d47:	74 0a                	je     800d53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d49:	0f b6 c0             	movzbl %al,%eax
  800d4c:	0f b6 db             	movzbl %bl,%ebx
  800d4f:	29 d8                	sub    %ebx,%eax
  800d51:	eb 0f                	jmp    800d62 <memcmp+0x35>
		s1++, s2++;
  800d53:	83 c2 01             	add    $0x1,%edx
  800d56:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d59:	39 f2                	cmp    %esi,%edx
  800d5b:	75 e2                	jne    800d3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d74:	eb 07                	jmp    800d7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d76:	38 08                	cmp    %cl,(%eax)
  800d78:	74 07                	je     800d81 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d7a:	83 c0 01             	add    $0x1,%eax
  800d7d:	39 d0                	cmp    %edx,%eax
  800d7f:	72 f5                	jb     800d76 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8f:	eb 03                	jmp    800d94 <strtol+0x11>
		s++;
  800d91:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d94:	0f b6 0a             	movzbl (%edx),%ecx
  800d97:	80 f9 09             	cmp    $0x9,%cl
  800d9a:	74 f5                	je     800d91 <strtol+0xe>
  800d9c:	80 f9 20             	cmp    $0x20,%cl
  800d9f:	74 f0                	je     800d91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da1:	80 f9 2b             	cmp    $0x2b,%cl
  800da4:	75 0a                	jne    800db0 <strtol+0x2d>
		s++;
  800da6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dae:	eb 11                	jmp    800dc1 <strtol+0x3e>
  800db0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800db5:	80 f9 2d             	cmp    $0x2d,%cl
  800db8:	75 07                	jne    800dc1 <strtol+0x3e>
		s++, neg = 1;
  800dba:	8d 52 01             	lea    0x1(%edx),%edx
  800dbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800dc6:	75 15                	jne    800ddd <strtol+0x5a>
  800dc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dcb:	75 10                	jne    800ddd <strtol+0x5a>
  800dcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dd1:	75 0a                	jne    800ddd <strtol+0x5a>
		s += 2, base = 16;
  800dd3:	83 c2 02             	add    $0x2,%edx
  800dd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ddb:	eb 10                	jmp    800ded <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	75 0c                	jne    800ded <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800de1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de3:	80 3a 30             	cmpb   $0x30,(%edx)
  800de6:	75 05                	jne    800ded <strtol+0x6a>
		s++, base = 8;
  800de8:	83 c2 01             	add    $0x1,%edx
  800deb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df5:	0f b6 0a             	movzbl (%edx),%ecx
  800df8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	3c 09                	cmp    $0x9,%al
  800dff:	77 08                	ja     800e09 <strtol+0x86>
			dig = *s - '0';
  800e01:	0f be c9             	movsbl %cl,%ecx
  800e04:	83 e9 30             	sub    $0x30,%ecx
  800e07:	eb 20                	jmp    800e29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	3c 19                	cmp    $0x19,%al
  800e10:	77 08                	ja     800e1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e12:	0f be c9             	movsbl %cl,%ecx
  800e15:	83 e9 57             	sub    $0x57,%ecx
  800e18:	eb 0f                	jmp    800e29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	3c 19                	cmp    $0x19,%al
  800e21:	77 16                	ja     800e39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e23:	0f be c9             	movsbl %cl,%ecx
  800e26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e2c:	7d 0f                	jge    800e3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e2e:	83 c2 01             	add    $0x1,%edx
  800e31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e37:	eb bc                	jmp    800df5 <strtol+0x72>
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	eb 02                	jmp    800e3f <strtol+0xbc>
  800e3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e43:	74 05                	je     800e4a <strtol+0xc7>
		*endptr = (char *) s;
  800e45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e4a:	f7 d8                	neg    %eax
  800e4c:	85 ff                	test   %edi,%edi
  800e4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e5c:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e63:	75 1c                	jne    800e81 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800e65:	c7 44 24 08 c8 13 80 	movl   $0x8013c8,0x8(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800e74:	00 
  800e75:	c7 04 24 ec 13 80 00 	movl   $0x8013ec,(%esp)
  800e7c:	e8 0e f5 ff ff       	call   80038f <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    
  800e8b:	66 90                	xchg   %ax,%ax
  800e8d:	66 90                	xchg   %ax,%ax
  800e8f:	90                   	nop

00800e90 <__udivdi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e9a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e9e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ea2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eac:	89 ea                	mov    %ebp,%edx
  800eae:	89 0c 24             	mov    %ecx,(%esp)
  800eb1:	75 2d                	jne    800ee0 <__udivdi3+0x50>
  800eb3:	39 e9                	cmp    %ebp,%ecx
  800eb5:	77 61                	ja     800f18 <__udivdi3+0x88>
  800eb7:	85 c9                	test   %ecx,%ecx
  800eb9:	89 ce                	mov    %ecx,%esi
  800ebb:	75 0b                	jne    800ec8 <__udivdi3+0x38>
  800ebd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec2:	31 d2                	xor    %edx,%edx
  800ec4:	f7 f1                	div    %ecx
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	89 e8                	mov    %ebp,%eax
  800ecc:	f7 f6                	div    %esi
  800ece:	89 c5                	mov    %eax,%ebp
  800ed0:	89 f8                	mov    %edi,%eax
  800ed2:	f7 f6                	div    %esi
  800ed4:	89 ea                	mov    %ebp,%edx
  800ed6:	83 c4 0c             	add    $0xc,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
  800ee0:	39 e8                	cmp    %ebp,%eax
  800ee2:	77 24                	ja     800f08 <__udivdi3+0x78>
  800ee4:	0f bd e8             	bsr    %eax,%ebp
  800ee7:	83 f5 1f             	xor    $0x1f,%ebp
  800eea:	75 3c                	jne    800f28 <__udivdi3+0x98>
  800eec:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ef0:	39 34 24             	cmp    %esi,(%esp)
  800ef3:	0f 86 9f 00 00 00    	jbe    800f98 <__udivdi3+0x108>
  800ef9:	39 d0                	cmp    %edx,%eax
  800efb:	0f 82 97 00 00 00    	jb     800f98 <__udivdi3+0x108>
  800f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	31 c0                	xor    %eax,%eax
  800f0c:	83 c4 0c             	add    $0xc,%esp
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    
  800f13:	90                   	nop
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	89 f8                	mov    %edi,%eax
  800f1a:	f7 f1                	div    %ecx
  800f1c:	31 d2                	xor    %edx,%edx
  800f1e:	83 c4 0c             	add    $0xc,%esp
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	8b 3c 24             	mov    (%esp),%edi
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	b8 20 00 00 00       	mov    $0x20,%eax
  800f36:	29 e8                	sub    %ebp,%eax
  800f38:	89 c1                	mov    %eax,%ecx
  800f3a:	d3 ef                	shr    %cl,%edi
  800f3c:	89 e9                	mov    %ebp,%ecx
  800f3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f42:	8b 3c 24             	mov    (%esp),%edi
  800f45:	09 74 24 08          	or     %esi,0x8(%esp)
  800f49:	89 d6                	mov    %edx,%esi
  800f4b:	d3 e7                	shl    %cl,%edi
  800f4d:	89 c1                	mov    %eax,%ecx
  800f4f:	89 3c 24             	mov    %edi,(%esp)
  800f52:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f56:	d3 ee                	shr    %cl,%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	d3 e2                	shl    %cl,%edx
  800f5c:	89 c1                	mov    %eax,%ecx
  800f5e:	d3 ef                	shr    %cl,%edi
  800f60:	09 d7                	or     %edx,%edi
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	89 f8                	mov    %edi,%eax
  800f66:	f7 74 24 08          	divl   0x8(%esp)
  800f6a:	89 d6                	mov    %edx,%esi
  800f6c:	89 c7                	mov    %eax,%edi
  800f6e:	f7 24 24             	mull   (%esp)
  800f71:	39 d6                	cmp    %edx,%esi
  800f73:	89 14 24             	mov    %edx,(%esp)
  800f76:	72 30                	jb     800fa8 <__udivdi3+0x118>
  800f78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f7c:	89 e9                	mov    %ebp,%ecx
  800f7e:	d3 e2                	shl    %cl,%edx
  800f80:	39 c2                	cmp    %eax,%edx
  800f82:	73 05                	jae    800f89 <__udivdi3+0xf9>
  800f84:	3b 34 24             	cmp    (%esp),%esi
  800f87:	74 1f                	je     800fa8 <__udivdi3+0x118>
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	e9 7a ff ff ff       	jmp    800f0c <__udivdi3+0x7c>
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9f:	e9 68 ff ff ff       	jmp    800f0c <__udivdi3+0x7c>
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 0c             	add    $0xc,%esp
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    
  800fb4:	66 90                	xchg   %ax,%ax
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	83 ec 14             	sub    $0x14,%esp
  800fc6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fd2:	89 c7                	mov    %eax,%edi
  800fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fdc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe0:	89 34 24             	mov    %esi,(%esp)
  800fe3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	89 c2                	mov    %eax,%edx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	75 17                	jne    801008 <__umoddi3+0x48>
  800ff1:	39 fe                	cmp    %edi,%esi
  800ff3:	76 4b                	jbe    801040 <__umoddi3+0x80>
  800ff5:	89 c8                	mov    %ecx,%eax
  800ff7:	89 fa                	mov    %edi,%edx
  800ff9:	f7 f6                	div    %esi
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	31 d2                	xor    %edx,%edx
  800fff:	83 c4 14             	add    $0x14,%esp
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	66 90                	xchg   %ax,%ax
  801008:	39 f8                	cmp    %edi,%eax
  80100a:	77 54                	ja     801060 <__umoddi3+0xa0>
  80100c:	0f bd e8             	bsr    %eax,%ebp
  80100f:	83 f5 1f             	xor    $0x1f,%ebp
  801012:	75 5c                	jne    801070 <__umoddi3+0xb0>
  801014:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801018:	39 3c 24             	cmp    %edi,(%esp)
  80101b:	0f 87 e7 00 00 00    	ja     801108 <__umoddi3+0x148>
  801021:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801025:	29 f1                	sub    %esi,%ecx
  801027:	19 c7                	sbb    %eax,%edi
  801029:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80102d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801031:	8b 44 24 08          	mov    0x8(%esp),%eax
  801035:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801039:	83 c4 14             	add    $0x14,%esp
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    
  801040:	85 f6                	test   %esi,%esi
  801042:	89 f5                	mov    %esi,%ebp
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f6                	div    %esi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	8b 44 24 04          	mov    0x4(%esp),%eax
  801055:	31 d2                	xor    %edx,%edx
  801057:	f7 f5                	div    %ebp
  801059:	89 c8                	mov    %ecx,%eax
  80105b:	f7 f5                	div    %ebp
  80105d:	eb 9c                	jmp    800ffb <__umoddi3+0x3b>
  80105f:	90                   	nop
  801060:	89 c8                	mov    %ecx,%eax
  801062:	89 fa                	mov    %edi,%edx
  801064:	83 c4 14             	add    $0x14,%esp
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    
  80106b:	90                   	nop
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	8b 04 24             	mov    (%esp),%eax
  801073:	be 20 00 00 00       	mov    $0x20,%esi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	29 ee                	sub    %ebp,%esi
  80107c:	d3 e2                	shl    %cl,%edx
  80107e:	89 f1                	mov    %esi,%ecx
  801080:	d3 e8                	shr    %cl,%eax
  801082:	89 e9                	mov    %ebp,%ecx
  801084:	89 44 24 04          	mov    %eax,0x4(%esp)
  801088:	8b 04 24             	mov    (%esp),%eax
  80108b:	09 54 24 04          	or     %edx,0x4(%esp)
  80108f:	89 fa                	mov    %edi,%edx
  801091:	d3 e0                	shl    %cl,%eax
  801093:	89 f1                	mov    %esi,%ecx
  801095:	89 44 24 08          	mov    %eax,0x8(%esp)
  801099:	8b 44 24 10          	mov    0x10(%esp),%eax
  80109d:	d3 ea                	shr    %cl,%edx
  80109f:	89 e9                	mov    %ebp,%ecx
  8010a1:	d3 e7                	shl    %cl,%edi
  8010a3:	89 f1                	mov    %esi,%ecx
  8010a5:	d3 e8                	shr    %cl,%eax
  8010a7:	89 e9                	mov    %ebp,%ecx
  8010a9:	09 f8                	or     %edi,%eax
  8010ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010af:	f7 74 24 04          	divl   0x4(%esp)
  8010b3:	d3 e7                	shl    %cl,%edi
  8010b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010b9:	89 d7                	mov    %edx,%edi
  8010bb:	f7 64 24 08          	mull   0x8(%esp)
  8010bf:	39 d7                	cmp    %edx,%edi
  8010c1:	89 c1                	mov    %eax,%ecx
  8010c3:	89 14 24             	mov    %edx,(%esp)
  8010c6:	72 2c                	jb     8010f4 <__umoddi3+0x134>
  8010c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010cc:	72 22                	jb     8010f0 <__umoddi3+0x130>
  8010ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010d2:	29 c8                	sub    %ecx,%eax
  8010d4:	19 d7                	sbb    %edx,%edi
  8010d6:	89 e9                	mov    %ebp,%ecx
  8010d8:	89 fa                	mov    %edi,%edx
  8010da:	d3 e8                	shr    %cl,%eax
  8010dc:	89 f1                	mov    %esi,%ecx
  8010de:	d3 e2                	shl    %cl,%edx
  8010e0:	89 e9                	mov    %ebp,%ecx
  8010e2:	d3 ef                	shr    %cl,%edi
  8010e4:	09 d0                	or     %edx,%eax
  8010e6:	89 fa                	mov    %edi,%edx
  8010e8:	83 c4 14             	add    $0x14,%esp
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    
  8010ef:	90                   	nop
  8010f0:	39 d7                	cmp    %edx,%edi
  8010f2:	75 da                	jne    8010ce <__umoddi3+0x10e>
  8010f4:	8b 14 24             	mov    (%esp),%edx
  8010f7:	89 c1                	mov    %eax,%ecx
  8010f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801101:	eb cb                	jmp    8010ce <__umoddi3+0x10e>
  801103:	90                   	nop
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80110c:	0f 82 0f ff ff ff    	jb     801021 <__umoddi3+0x61>
  801112:	e9 1a ff ff ff       	jmp    801031 <__umoddi3+0x71>
