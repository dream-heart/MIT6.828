
obj/user/softint:     file format elf32-i386


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
	...

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
	...

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
  80004e:	e8 db 00 00 00       	call   80012e <sys_getenvid>
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
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800098:	e8 3f 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 28                	jle    800126 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800102:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800109:	00 
  80010a:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  800111:	00 
  800112:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800119:	00 
  80011a:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800121:	e8 5b 02 00 00       	call   800381 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	83 c4 2c             	add    $0x2c,%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_yield>:

void
sys_yield(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	be 00 00 00 00       	mov    $0x0,%esi
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
  800185:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800188:	89 f7                	mov    %esi,%edi
  80018a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018c:	85 c0                	test   %eax,%eax
  80018e:	7e 28                	jle    8001b8 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800190:	89 44 24 10          	mov    %eax,0x10(%esp)
  800194:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019b:	00 
  80019c:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8001b3:	e8 c9 01 00 00       	call   800381 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b8:	83 c4 2c             	add    $0x2c,%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001da:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001df:	85 c0                	test   %eax,%eax
  8001e1:	7e 28                	jle    80020b <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e7:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ee:	00 
  8001ef:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8001f6:	00 
  8001f7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fe:	00 
  8001ff:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800206:	e8 76 01 00 00       	call   800381 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020b:	83 c4 2c             	add    $0x2c,%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	57                   	push   %edi
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800221:	b8 06 00 00 00       	mov    $0x6,%eax
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	8b 55 08             	mov    0x8(%ebp),%edx
  80022c:	89 df                	mov    %ebx,%edi
  80022e:	89 de                	mov    %ebx,%esi
  800230:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800232:	85 c0                	test   %eax,%eax
  800234:	7e 28                	jle    80025e <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800236:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800241:	00 
  800242:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  800249:	00 
  80024a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800251:	00 
  800252:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800259:	e8 23 01 00 00       	call   800381 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025e:	83 c4 2c             	add    $0x2c,%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	57                   	push   %edi
  80026a:	56                   	push   %esi
  80026b:	53                   	push   %ebx
  80026c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800274:	b8 08 00 00 00       	mov    $0x8,%eax
  800279:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  80027f:	89 df                	mov    %ebx,%edi
  800281:	89 de                	mov    %ebx,%esi
  800283:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800285:	85 c0                	test   %eax,%eax
  800287:	7e 28                	jle    8002b1 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800289:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800294:	00 
  800295:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  80029c:	00 
  80029d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a4:	00 
  8002a5:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8002ac:	e8 d0 00 00 00       	call   800381 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b1:	83 c4 2c             	add    $0x2c,%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	57                   	push   %edi
  8002bd:	56                   	push   %esi
  8002be:	53                   	push   %ebx
  8002bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c7:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 df                	mov    %ebx,%edi
  8002d4:	89 de                	mov    %ebx,%esi
  8002d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	7e 28                	jle    800304 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e7:	00 
  8002e8:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8002ef:	00 
  8002f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f7:	00 
  8002f8:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8002ff:	e8 7d 00 00 00       	call   800381 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800304:	83 c4 2c             	add    $0x2c,%esp
  800307:	5b                   	pop    %ebx
  800308:	5e                   	pop    %esi
  800309:	5f                   	pop    %edi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800312:	be 00 00 00 00       	mov    $0x0,%esi
  800317:	b8 0b 00 00 00       	mov    $0xb,%eax
  80031c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
  800322:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800325:	8b 7d 14             	mov    0x14(%ebp),%edi
  800328:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800338:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	89 cb                	mov    %ecx,%ebx
  800347:	89 cf                	mov    %ecx,%edi
  800349:	89 ce                	mov    %ecx,%esi
  80034b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034d:	85 c0                	test   %eax,%eax
  80034f:	7e 28                	jle    800379 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800351:	89 44 24 10          	mov    %eax,0x10(%esp)
  800355:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80035c:	00 
  80035d:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  800364:	00 
  800365:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036c:	00 
  80036d:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800374:	e8 08 00 00 00       	call   800381 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800379:	83 c4 2c             	add    $0x2c,%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800389:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800392:	e8 97 fd ff ff       	call   80012e <sys_getenvid>
  800397:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80039e:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ad:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  8003b4:	e8 c1 00 00 00       	call   80047a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 51 00 00 00       	call   800419 <vcprintf>
	cprintf("\n");
  8003c8:	c7 04 24 5c 11 80 00 	movl   $0x80115c,(%esp)
  8003cf:	e8 a6 00 00 00       	call   80047a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d4:	cc                   	int3   
  8003d5:	eb fd                	jmp    8003d4 <_panic+0x53>

008003d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	53                   	push   %ebx
  8003db:	83 ec 14             	sub    $0x14,%esp
  8003de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e1:	8b 13                	mov    (%ebx),%edx
  8003e3:	8d 42 01             	lea    0x1(%edx),%eax
  8003e6:	89 03                	mov    %eax,(%ebx)
  8003e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f4:	75 19                	jne    80040f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003fd:	00 
  8003fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 96 fc ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800409:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80040f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800413:	83 c4 14             	add    $0x14,%esp
  800416:	5b                   	pop    %ebx
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800422:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800429:	00 00 00 
	b.cnt = 0;
  80042c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800433:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
  800439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 44 24 08          	mov    %eax,0x8(%esp)
  800444:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80044a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044e:	c7 04 24 d7 03 80 00 	movl   $0x8003d7,(%esp)
  800455:	e8 7a 01 00 00       	call   8005d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80045a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80046a:	89 04 24             	mov    %eax,(%esp)
  80046d:	e8 2d fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  800472:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800480:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800483:	89 44 24 04          	mov    %eax,0x4(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 04 24             	mov    %eax,(%esp)
  80048d:	e8 87 ff ff ff       	call   800419 <vcprintf>
	va_end(ap);

	return cnt;
}
  800492:	c9                   	leave  
  800493:	c3                   	ret    
	...

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004cd:	39 d9                	cmp    %ebx,%ecx
  8004cf:	72 05                	jb     8004d6 <printnum+0x36>
  8004d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004d4:	77 69                	ja     80053f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	e8 3c 09 00 00       	call   800e50 <__udivdi3>
  800514:	89 d9                	mov    %ebx,%ecx
  800516:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80051a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	89 54 24 04          	mov    %edx,0x4(%esp)
  800525:	89 fa                	mov    %edi,%edx
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	e8 71 ff ff ff       	call   8004a0 <printnum>
  80052f:	eb 1b                	jmp    80054c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800531:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800535:	8b 45 18             	mov    0x18(%ebp),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff d3                	call   *%ebx
  80053d:	eb 03                	jmp    800542 <printnum+0xa2>
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	7f e8                	jg     800531 <printnum+0x91>
  800549:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80054c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800550:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80055a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 0c 0a 00 00       	call   800f80 <__umoddi3>
  800574:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800578:	0f be 80 5e 11 80 00 	movsbl 0x80115e(%eax),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800585:	ff d0                	call   *%eax
}
  800587:	83 c4 3c             	add    $0x3c,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5e                   	pop    %esi
  80058c:	5f                   	pop    %edi
  80058d:	5d                   	pop    %ebp
  80058e:	c3                   	ret    

0080058f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800595:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	3b 50 04             	cmp    0x4(%eax),%edx
  80059e:	73 0a                	jae    8005aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8005a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005a3:	89 08                	mov    %ecx,(%eax)
  8005a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a8:	88 02                	mov    %al,(%edx)
}
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	e8 02 00 00 00       	call   8005d4 <vprintfmt>
	va_end(ap);
}
  8005d2:	c9                   	leave  
  8005d3:	c3                   	ret    

008005d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	57                   	push   %edi
  8005d8:	56                   	push   %esi
  8005d9:	53                   	push   %ebx
  8005da:	83 ec 3c             	sub    $0x3c,%esp
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005e6:	eb 11                	jmp    8005f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	0f 84 48 04 00 00    	je     800a38 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	83 f8 25             	cmp    $0x25,%eax
  800603:	75 e3                	jne    8005e8 <vprintfmt+0x14>
  800605:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800609:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800610:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800617:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	eb 1f                	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800628:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80062c:	eb 16                	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800631:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800635:	eb 0d                	jmp    800644 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800637:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8d 47 01             	lea    0x1(%edi),%eax
  800647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80064a:	0f b6 17             	movzbl (%edi),%edx
  80064d:	0f b6 c2             	movzbl %dl,%eax
  800650:	83 ea 23             	sub    $0x23,%edx
  800653:	80 fa 55             	cmp    $0x55,%dl
  800656:	0f 87 bf 03 00 00    	ja     800a1b <vprintfmt+0x447>
  80065c:	0f b6 d2             	movzbl %dl,%edx
  80065f:	ff 24 95 20 12 80 00 	jmp    *0x801220(,%edx,4)
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
  80066e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800671:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800674:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800678:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80067b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80067e:	83 f9 09             	cmp    $0x9,%ecx
  800681:	77 3c                	ja     8006bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800683:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800686:	eb e9                	jmp    800671 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069c:	eb 27                	jmp    8006c5 <vprintfmt+0xf1>
  80069e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a8:	0f 49 c2             	cmovns %edx,%eax
  8006ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b1:	eb 91                	jmp    800644 <vprintfmt+0x70>
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006bd:	eb 85                	jmp    800644 <vprintfmt+0x70>
  8006bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	0f 89 75 ff ff ff    	jns    800644 <vprintfmt+0x70>
  8006cf:	e9 63 ff ff ff       	jmp    800637 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006da:	e9 65 ff ff ff       	jmp    800644 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f4:	e9 00 ff ff ff       	jmp    8005f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	99                   	cltd   
  800703:	31 d0                	xor    %edx,%eax
  800705:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800707:	83 f8 09             	cmp    $0x9,%eax
  80070a:	7f 0b                	jg     800717 <vprintfmt+0x143>
  80070c:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	75 20                	jne    800737 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800717:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071b:	c7 44 24 08 76 11 80 	movl   $0x801176,0x8(%esp)
  800722:	00 
  800723:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800727:	89 34 24             	mov    %esi,(%esp)
  80072a:	e8 7d fe ff ff       	call   8005ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800732:	e9 c2 fe ff ff       	jmp    8005f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800737:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073b:	c7 44 24 08 7f 11 80 	movl   $0x80117f,0x8(%esp)
  800742:	00 
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	89 34 24             	mov    %esi,(%esp)
  80074a:	e8 5d fe ff ff       	call   8005ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800752:	e9 a2 fe ff ff       	jmp    8005f9 <vprintfmt+0x25>
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80075d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800760:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800767:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800769:	85 ff                	test   %edi,%edi
  80076b:	b8 6f 11 80 00       	mov    $0x80116f,%eax
  800770:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800773:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800777:	0f 84 92 00 00 00    	je     80080f <vprintfmt+0x23b>
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	0f 8e 98 00 00 00    	jle    80081d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800785:	89 54 24 04          	mov    %edx,0x4(%esp)
  800789:	89 3c 24             	mov    %edi,(%esp)
  80078c:	e8 47 03 00 00       	call   800ad8 <strnlen>
  800791:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800794:	29 c1                	sub    %eax,%ecx
  800796:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800799:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80079d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a5:	eb 0f                	jmp    8007b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	83 ef 01             	sub    $0x1,%edi
  8007b6:	85 ff                	test   %edi,%edi
  8007b8:	7f ed                	jg     8007a7 <vprintfmt+0x1d3>
  8007ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	0f 49 c1             	cmovns %ecx,%eax
  8007ca:	29 c1                	sub    %eax,%ecx
  8007cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007d5:	89 cb                	mov    %ecx,%ebx
  8007d7:	eb 50                	jmp    800829 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007dd:	74 1e                	je     8007fd <vprintfmt+0x229>
  8007df:	0f be d2             	movsbl %dl,%edx
  8007e2:	83 ea 20             	sub    $0x20,%edx
  8007e5:	83 fa 5e             	cmp    $0x5e,%edx
  8007e8:	76 13                	jbe    8007fd <vprintfmt+0x229>
					putch('?', putdat);
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f8:	ff 55 08             	call   *0x8(%ebp)
  8007fb:	eb 0d                	jmp    80080a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8007fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800800:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080a:	83 eb 01             	sub    $0x1,%ebx
  80080d:	eb 1a                	jmp    800829 <vprintfmt+0x255>
  80080f:	89 75 08             	mov    %esi,0x8(%ebp)
  800812:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800815:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800818:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80081b:	eb 0c                	jmp    800829 <vprintfmt+0x255>
  80081d:	89 75 08             	mov    %esi,0x8(%ebp)
  800820:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800823:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800826:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800829:	83 c7 01             	add    $0x1,%edi
  80082c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800830:	0f be c2             	movsbl %dl,%eax
  800833:	85 c0                	test   %eax,%eax
  800835:	74 25                	je     80085c <vprintfmt+0x288>
  800837:	85 f6                	test   %esi,%esi
  800839:	78 9e                	js     8007d9 <vprintfmt+0x205>
  80083b:	83 ee 01             	sub    $0x1,%esi
  80083e:	79 99                	jns    8007d9 <vprintfmt+0x205>
  800840:	89 df                	mov    %ebx,%edi
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800848:	eb 1a                	jmp    800864 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80084a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800855:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800857:	83 ef 01             	sub    $0x1,%edi
  80085a:	eb 08                	jmp    800864 <vprintfmt+0x290>
  80085c:	89 df                	mov    %ebx,%edi
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800864:	85 ff                	test   %edi,%edi
  800866:	7f e2                	jg     80084a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086b:	e9 89 fd ff ff       	jmp    8005f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800870:	83 f9 01             	cmp    $0x1,%ecx
  800873:	7e 19                	jle    80088e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 50 04             	mov    0x4(%eax),%edx
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800880:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 40 08             	lea    0x8(%eax),%eax
  800889:	89 45 14             	mov    %eax,0x14(%ebp)
  80088c:	eb 38                	jmp    8008c6 <vprintfmt+0x2f2>
	else if (lflag)
  80088e:	85 c9                	test   %ecx,%ecx
  800890:	74 1b                	je     8008ad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8b 00                	mov    (%eax),%eax
  800897:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089a:	89 c1                	mov    %eax,%ecx
  80089c:	c1 f9 1f             	sar    $0x1f,%ecx
  80089f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8d 40 04             	lea    0x4(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ab:	eb 19                	jmp    8008c6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8b 00                	mov    (%eax),%eax
  8008b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b5:	89 c1                	mov    %eax,%ecx
  8008b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008cc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d5:	0f 89 04 01 00 00    	jns    8009df <vprintfmt+0x40b>
				putch('-', putdat);
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008ee:	f7 da                	neg    %edx
  8008f0:	83 d1 00             	adc    $0x0,%ecx
  8008f3:	f7 d9                	neg    %ecx
  8008f5:	e9 e5 00 00 00       	jmp    8009df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008fa:	83 f9 01             	cmp    $0x1,%ecx
  8008fd:	7e 10                	jle    80090f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8b 10                	mov    (%eax),%edx
  800904:	8b 48 04             	mov    0x4(%eax),%ecx
  800907:	8d 40 08             	lea    0x8(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
  80090d:	eb 26                	jmp    800935 <vprintfmt+0x361>
	else if (lflag)
  80090f:	85 c9                	test   %ecx,%ecx
  800911:	74 12                	je     800925 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8b 10                	mov    (%eax),%edx
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091d:	8d 40 04             	lea    0x4(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
  800923:	eb 10                	jmp    800935 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800935:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80093a:	e9 a0 00 00 00       	jmp    8009df <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80093f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800943:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80094a:	ff d6                	call   *%esi
			putch('X', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800957:	ff d6                	call   *%esi
			putch('X', putdat);
  800959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800964:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800969:	e9 8b fc ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80096e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800972:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800979:	ff d6                	call   *%esi
			putch('x', putdat);
  80097b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800986:	ff d6                	call   *%esi
			num = (unsigned long long)
  800988:	8b 45 14             	mov    0x14(%ebp),%eax
  80098b:	8b 10                	mov    (%eax),%edx
  80098d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800992:	8d 40 04             	lea    0x4(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800998:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80099d:	eb 40                	jmp    8009df <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099f:	83 f9 01             	cmp    $0x1,%ecx
  8009a2:	7e 10                	jle    8009b4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8b 10                	mov    (%eax),%edx
  8009a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ac:	8d 40 08             	lea    0x8(%eax),%eax
  8009af:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b2:	eb 26                	jmp    8009da <vprintfmt+0x406>
	else if (lflag)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 12                	je     8009ca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8b 10                	mov    (%eax),%edx
  8009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c2:	8d 40 04             	lea    0x4(%eax),%eax
  8009c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c8:	eb 10                	jmp    8009da <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cd:	8b 10                	mov    (%eax),%edx
  8009cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d4:	8d 40 04             	lea    0x4(%eax),%eax
  8009d7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009da:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009df:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009f2:	89 14 24             	mov    %edx,(%esp)
  8009f5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009f9:	89 da                	mov    %ebx,%edx
  8009fb:	89 f0                	mov    %esi,%eax
  8009fd:	e8 9e fa ff ff       	call   8004a0 <printnum>
			break;
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 ef fb ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	89 04 24             	mov    %eax,(%esp)
  800a11:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a16:	e9 de fb ff ff       	jmp    8005f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a26:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	eb 03                	jmp    800a2d <vprintfmt+0x459>
  800a2a:	83 ef 01             	sub    $0x1,%edi
  800a2d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a31:	75 f7                	jne    800a2a <vprintfmt+0x456>
  800a33:	e9 c1 fb ff ff       	jmp    8005f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a38:	83 c4 3c             	add    $0x3c,%esp
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 28             	sub    $0x28,%esp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a53:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	74 30                	je     800a91 <vsnprintf+0x51>
  800a61:	85 d2                	test   %edx,%edx
  800a63:	7e 2c                	jle    800a91 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a65:	8b 45 14             	mov    0x14(%ebp),%eax
  800a68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a73:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	c7 04 24 8f 05 80 00 	movl   $0x80058f,(%esp)
  800a81:	e8 4e fb ff ff       	call   8005d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a89:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8f:	eb 05                	jmp    800a96 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa5:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	89 04 24             	mov    %eax,(%esp)
  800ab9:	e8 82 ff ff ff       	call   800a40 <vsnprintf>
	va_end(ap);

	return rc;
}
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	eb 03                	jmp    800ad0 <strlen+0x10>
		n++;
  800acd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad4:	75 f7                	jne    800acd <strlen+0xd>
		n++;
	return n;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	eb 03                	jmp    800aeb <strnlen+0x13>
		n++;
  800ae8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1d>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f3                	jne    800ae8 <strnlen+0x10>
		n++;
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b0d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b10:	84 db                	test   %bl,%bl
  800b12:	75 ef                	jne    800b03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b14:	5b                   	pop    %ebx
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b21:	89 1c 24             	mov    %ebx,(%esp)
  800b24:	e8 97 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b30:	01 d8                	add    %ebx,%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 bd ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	83 c4 08             	add    $0x8,%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b52:	89 f2                	mov    %esi,%edx
  800b54:	eb 0f                	jmp    800b65 <strncpy+0x23>
		*dst++ = *src;
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	0f b6 01             	movzbl (%ecx),%eax
  800b5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b5f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b62:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b65:	39 da                	cmp    %ebx,%edx
  800b67:	75 ed                	jne    800b56 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 75 08             	mov    0x8(%ebp),%esi
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	85 c9                	test   %ecx,%ecx
  800b85:	75 0b                	jne    800b92 <strlcpy+0x23>
  800b87:	eb 1d                	jmp    800ba6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b89:	83 c0 01             	add    $0x1,%eax
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b92:	39 d8                	cmp    %ebx,%eax
  800b94:	74 0b                	je     800ba1 <strlcpy+0x32>
  800b96:	0f b6 0a             	movzbl (%edx),%ecx
  800b99:	84 c9                	test   %cl,%cl
  800b9b:	75 ec                	jne    800b89 <strlcpy+0x1a>
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 02                	jmp    800ba3 <strlcpy+0x34>
  800ba1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ba3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ba6:	29 f0                	sub    %esi,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb5:	eb 06                	jmp    800bbd <strcmp+0x11>
		p++, q++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
  800bba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bbd:	0f b6 01             	movzbl (%ecx),%eax
  800bc0:	84 c0                	test   %al,%al
  800bc2:	74 04                	je     800bc8 <strcmp+0x1c>
  800bc4:	3a 02                	cmp    (%edx),%al
  800bc6:	74 ef                	je     800bb7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc8:	0f b6 c0             	movzbl %al,%eax
  800bcb:	0f b6 12             	movzbl (%edx),%edx
  800bce:	29 d0                	sub    %edx,%eax
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdc:	89 c3                	mov    %eax,%ebx
  800bde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800be1:	eb 06                	jmp    800be9 <strncmp+0x17>
		n--, p++, q++;
  800be3:	83 c0 01             	add    $0x1,%eax
  800be6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800be9:	39 d8                	cmp    %ebx,%eax
  800beb:	74 15                	je     800c02 <strncmp+0x30>
  800bed:	0f b6 08             	movzbl (%eax),%ecx
  800bf0:	84 c9                	test   %cl,%cl
  800bf2:	74 04                	je     800bf8 <strncmp+0x26>
  800bf4:	3a 0a                	cmp    (%edx),%cl
  800bf6:	74 eb                	je     800be3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf8:	0f b6 00             	movzbl (%eax),%eax
  800bfb:	0f b6 12             	movzbl (%edx),%edx
  800bfe:	29 d0                	sub    %edx,%eax
  800c00:	eb 05                	jmp    800c07 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c14:	eb 07                	jmp    800c1d <strchr+0x13>
		if (*s == c)
  800c16:	38 ca                	cmp    %cl,%dl
  800c18:	74 0f                	je     800c29 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f2                	jne    800c16 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	eb 07                	jmp    800c3e <strfind+0x13>
		if (*s == c)
  800c37:	38 ca                	cmp    %cl,%dl
  800c39:	74 0a                	je     800c45 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	0f b6 10             	movzbl (%eax),%edx
  800c41:	84 d2                	test   %dl,%dl
  800c43:	75 f2                	jne    800c37 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c53:	85 c9                	test   %ecx,%ecx
  800c55:	74 36                	je     800c8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c57:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5d:	75 28                	jne    800c87 <memset+0x40>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 23                	jne    800c87 <memset+0x40>
		c &= 0xFF;
  800c64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	c1 e3 08             	shl    $0x8,%ebx
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	c1 e6 18             	shl    $0x18,%esi
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	c1 e0 10             	shl    $0x10,%eax
  800c77:	09 f0                	or     %esi,%eax
  800c79:	09 c2                	or     %eax,%edx
  800c7b:	89 d0                	mov    %edx,%eax
  800c7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c82:	fc                   	cld    
  800c83:	f3 ab                	rep stos %eax,%es:(%edi)
  800c85:	eb 06                	jmp    800c8d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	fc                   	cld    
  800c8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c8d:	89 f8                	mov    %edi,%eax
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca2:	39 c6                	cmp    %eax,%esi
  800ca4:	73 35                	jae    800cdb <memmove+0x47>
  800ca6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	73 2e                	jae    800cdb <memmove+0x47>
		s += n;
		d += n;
  800cad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cba:	75 13                	jne    800ccf <memmove+0x3b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0e                	jne    800ccf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc1:	83 ef 04             	sub    $0x4,%edi
  800cc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cca:	fd                   	std    
  800ccb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccd:	eb 09                	jmp    800cd8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ccf:	83 ef 01             	sub    $0x1,%edi
  800cd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cd5:	fd                   	std    
  800cd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd8:	fc                   	cld    
  800cd9:	eb 1d                	jmp    800cf8 <memmove+0x64>
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdf:	f6 c2 03             	test   $0x3,%dl
  800ce2:	75 0f                	jne    800cf3 <memmove+0x5f>
  800ce4:	f6 c1 03             	test   $0x3,%cl
  800ce7:	75 0a                	jne    800cf3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ce9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	fc                   	cld    
  800cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf1:	eb 05                	jmp    800cf8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf3:	89 c7                	mov    %eax,%edi
  800cf5:	fc                   	cld    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d02:	8b 45 10             	mov    0x10(%ebp),%eax
  800d05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	89 04 24             	mov    %eax,(%esp)
  800d16:	e8 79 ff ff ff       	call   800c94 <memmove>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2d:	eb 1a                	jmp    800d49 <memcmp+0x2c>
		if (*s1 != *s2)
  800d2f:	0f b6 02             	movzbl (%edx),%eax
  800d32:	0f b6 19             	movzbl (%ecx),%ebx
  800d35:	38 d8                	cmp    %bl,%al
  800d37:	74 0a                	je     800d43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 db             	movzbl %bl,%ebx
  800d3f:	29 d8                	sub    %ebx,%eax
  800d41:	eb 0f                	jmp    800d52 <memcmp+0x35>
		s1++, s2++;
  800d43:	83 c2 01             	add    $0x1,%edx
  800d46:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d49:	39 f2                	cmp    %esi,%edx
  800d4b:	75 e2                	jne    800d2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d64:	eb 07                	jmp    800d6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d66:	38 08                	cmp    %cl,(%eax)
  800d68:	74 07                	je     800d71 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	39 d0                	cmp    %edx,%eax
  800d6f:	72 f5                	jb     800d66 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7f:	eb 03                	jmp    800d84 <strtol+0x11>
		s++;
  800d81:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d84:	0f b6 0a             	movzbl (%edx),%ecx
  800d87:	80 f9 09             	cmp    $0x9,%cl
  800d8a:	74 f5                	je     800d81 <strtol+0xe>
  800d8c:	80 f9 20             	cmp    $0x20,%cl
  800d8f:	74 f0                	je     800d81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d91:	80 f9 2b             	cmp    $0x2b,%cl
  800d94:	75 0a                	jne    800da0 <strtol+0x2d>
		s++;
  800d96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d99:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9e:	eb 11                	jmp    800db1 <strtol+0x3e>
  800da0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800da5:	80 f9 2d             	cmp    $0x2d,%cl
  800da8:	75 07                	jne    800db1 <strtol+0x3e>
		s++, neg = 1;
  800daa:	8d 52 01             	lea    0x1(%edx),%edx
  800dad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800db6:	75 15                	jne    800dcd <strtol+0x5a>
  800db8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dbb:	75 10                	jne    800dcd <strtol+0x5a>
  800dbd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dc1:	75 0a                	jne    800dcd <strtol+0x5a>
		s += 2, base = 16;
  800dc3:	83 c2 02             	add    $0x2,%edx
  800dc6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dcb:	eb 10                	jmp    800ddd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	75 0c                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd6:	75 05                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
  800dd8:	83 c2 01             	add    $0x1,%edx
  800ddb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de5:	0f b6 0a             	movzbl (%edx),%ecx
  800de8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	3c 09                	cmp    $0x9,%al
  800def:	77 08                	ja     800df9 <strtol+0x86>
			dig = *s - '0';
  800df1:	0f be c9             	movsbl %cl,%ecx
  800df4:	83 e9 30             	sub    $0x30,%ecx
  800df7:	eb 20                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800df9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	3c 19                	cmp    $0x19,%al
  800e00:	77 08                	ja     800e0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e02:	0f be c9             	movsbl %cl,%ecx
  800e05:	83 e9 57             	sub    $0x57,%ecx
  800e08:	eb 0f                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	3c 19                	cmp    $0x19,%al
  800e11:	77 16                	ja     800e29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e13:	0f be c9             	movsbl %cl,%ecx
  800e16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e1c:	7d 0f                	jge    800e2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e1e:	83 c2 01             	add    $0x1,%edx
  800e21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e27:	eb bc                	jmp    800de5 <strtol+0x72>
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	eb 02                	jmp    800e2f <strtol+0xbc>
  800e2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e33:	74 05                	je     800e3a <strtol+0xc7>
		*endptr = (char *) s;
  800e35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e3a:	f7 d8                	neg    %eax
  800e3c:	85 ff                	test   %edi,%edi
  800e3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    
	...

00800e50 <__udivdi3>:
  800e50:	83 ec 1c             	sub    $0x1c,%esp
  800e53:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800e5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e63:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e6b:	85 ff                	test   %edi,%edi
  800e6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e75:	89 cd                	mov    %ecx,%ebp
  800e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7b:	75 33                	jne    800eb0 <__udivdi3+0x60>
  800e7d:	39 f1                	cmp    %esi,%ecx
  800e7f:	77 57                	ja     800ed8 <__udivdi3+0x88>
  800e81:	85 c9                	test   %ecx,%ecx
  800e83:	75 0b                	jne    800e90 <__udivdi3+0x40>
  800e85:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8a:	31 d2                	xor    %edx,%edx
  800e8c:	f7 f1                	div    %ecx
  800e8e:	89 c1                	mov    %eax,%ecx
  800e90:	89 f0                	mov    %esi,%eax
  800e92:	31 d2                	xor    %edx,%edx
  800e94:	f7 f1                	div    %ecx
  800e96:	89 c6                	mov    %eax,%esi
  800e98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9c:	f7 f1                	div    %ecx
  800e9e:	89 f2                	mov    %esi,%edx
  800ea0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ea4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ea8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800eac:	83 c4 1c             	add    $0x1c,%esp
  800eaf:	c3                   	ret    
  800eb0:	31 d2                	xor    %edx,%edx
  800eb2:	31 c0                	xor    %eax,%eax
  800eb4:	39 f7                	cmp    %esi,%edi
  800eb6:	77 e8                	ja     800ea0 <__udivdi3+0x50>
  800eb8:	0f bd cf             	bsr    %edi,%ecx
  800ebb:	83 f1 1f             	xor    $0x1f,%ecx
  800ebe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ec2:	75 2c                	jne    800ef0 <__udivdi3+0xa0>
  800ec4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800ec8:	76 04                	jbe    800ece <__udivdi3+0x7e>
  800eca:	39 f7                	cmp    %esi,%edi
  800ecc:	73 d2                	jae    800ea0 <__udivdi3+0x50>
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed5:	eb c9                	jmp    800ea0 <__udivdi3+0x50>
  800ed7:	90                   	nop
  800ed8:	89 f2                	mov    %esi,%edx
  800eda:	f7 f1                	div    %ecx
  800edc:	31 d2                	xor    %edx,%edx
  800ede:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ee2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ee6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ef5:	b8 20 00 00 00       	mov    $0x20,%eax
  800efa:	89 ea                	mov    %ebp,%edx
  800efc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f00:	d3 e7                	shl    %cl,%edi
  800f02:	89 c1                	mov    %eax,%ecx
  800f04:	d3 ea                	shr    %cl,%edx
  800f06:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f0b:	09 fa                	or     %edi,%edx
  800f0d:	89 f7                	mov    %esi,%edi
  800f0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f19:	d3 e5                	shl    %cl,%ebp
  800f1b:	89 c1                	mov    %eax,%ecx
  800f1d:	d3 ef                	shr    %cl,%edi
  800f1f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f24:	d3 e2                	shl    %cl,%edx
  800f26:	89 c1                	mov    %eax,%ecx
  800f28:	d3 ee                	shr    %cl,%esi
  800f2a:	09 d6                	or     %edx,%esi
  800f2c:	89 fa                	mov    %edi,%edx
  800f2e:	89 f0                	mov    %esi,%eax
  800f30:	f7 74 24 0c          	divl   0xc(%esp)
  800f34:	89 d7                	mov    %edx,%edi
  800f36:	89 c6                	mov    %eax,%esi
  800f38:	f7 e5                	mul    %ebp
  800f3a:	39 d7                	cmp    %edx,%edi
  800f3c:	72 22                	jb     800f60 <__udivdi3+0x110>
  800f3e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f42:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f47:	d3 e5                	shl    %cl,%ebp
  800f49:	39 c5                	cmp    %eax,%ebp
  800f4b:	73 04                	jae    800f51 <__udivdi3+0x101>
  800f4d:	39 d7                	cmp    %edx,%edi
  800f4f:	74 0f                	je     800f60 <__udivdi3+0x110>
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	e9 46 ff ff ff       	jmp    800ea0 <__udivdi3+0x50>
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f69:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f6d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	c3                   	ret    
	...

00800f80 <__umoddi3>:
  800f80:	83 ec 1c             	sub    $0x1c,%esp
  800f83:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f87:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f8b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f8f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f93:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f97:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f9b:	85 ed                	test   %ebp,%ebp
  800f9d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa5:	89 cf                	mov    %ecx,%edi
  800fa7:	89 04 24             	mov    %eax,(%esp)
  800faa:	89 f2                	mov    %esi,%edx
  800fac:	75 1a                	jne    800fc8 <__umoddi3+0x48>
  800fae:	39 f1                	cmp    %esi,%ecx
  800fb0:	76 4e                	jbe    801000 <__umoddi3+0x80>
  800fb2:	f7 f1                	div    %ecx
  800fb4:	89 d0                	mov    %edx,%eax
  800fb6:	31 d2                	xor    %edx,%edx
  800fb8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fbc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fc4:	83 c4 1c             	add    $0x1c,%esp
  800fc7:	c3                   	ret    
  800fc8:	39 f5                	cmp    %esi,%ebp
  800fca:	77 54                	ja     801020 <__umoddi3+0xa0>
  800fcc:	0f bd c5             	bsr    %ebp,%eax
  800fcf:	83 f0 1f             	xor    $0x1f,%eax
  800fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd6:	75 60                	jne    801038 <__umoddi3+0xb8>
  800fd8:	3b 0c 24             	cmp    (%esp),%ecx
  800fdb:	0f 87 07 01 00 00    	ja     8010e8 <__umoddi3+0x168>
  800fe1:	89 f2                	mov    %esi,%edx
  800fe3:	8b 34 24             	mov    (%esp),%esi
  800fe6:	29 ce                	sub    %ecx,%esi
  800fe8:	19 ea                	sbb    %ebp,%edx
  800fea:	89 34 24             	mov    %esi,(%esp)
  800fed:	8b 04 24             	mov    (%esp),%eax
  800ff0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ffc:	83 c4 1c             	add    $0x1c,%esp
  800fff:	c3                   	ret    
  801000:	85 c9                	test   %ecx,%ecx
  801002:	75 0b                	jne    80100f <__umoddi3+0x8f>
  801004:	b8 01 00 00 00       	mov    $0x1,%eax
  801009:	31 d2                	xor    %edx,%edx
  80100b:	f7 f1                	div    %ecx
  80100d:	89 c1                	mov    %eax,%ecx
  80100f:	89 f0                	mov    %esi,%eax
  801011:	31 d2                	xor    %edx,%edx
  801013:	f7 f1                	div    %ecx
  801015:	8b 04 24             	mov    (%esp),%eax
  801018:	f7 f1                	div    %ecx
  80101a:	eb 98                	jmp    800fb4 <__umoddi3+0x34>
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	89 f2                	mov    %esi,%edx
  801022:	8b 74 24 10          	mov    0x10(%esp),%esi
  801026:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80102a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	c3                   	ret    
  801032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801038:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80103d:	89 e8                	mov    %ebp,%eax
  80103f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801044:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801048:	89 fa                	mov    %edi,%edx
  80104a:	d3 e0                	shl    %cl,%eax
  80104c:	89 e9                	mov    %ebp,%ecx
  80104e:	d3 ea                	shr    %cl,%edx
  801050:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801055:	09 c2                	or     %eax,%edx
  801057:	8b 44 24 08          	mov    0x8(%esp),%eax
  80105b:	89 14 24             	mov    %edx,(%esp)
  80105e:	89 f2                	mov    %esi,%edx
  801060:	d3 e7                	shl    %cl,%edi
  801062:	89 e9                	mov    %ebp,%ecx
  801064:	d3 ea                	shr    %cl,%edx
  801066:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80106b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106f:	d3 e6                	shl    %cl,%esi
  801071:	89 e9                	mov    %ebp,%ecx
  801073:	d3 e8                	shr    %cl,%eax
  801075:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80107a:	09 f0                	or     %esi,%eax
  80107c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801080:	f7 34 24             	divl   (%esp)
  801083:	d3 e6                	shl    %cl,%esi
  801085:	89 74 24 08          	mov    %esi,0x8(%esp)
  801089:	89 d6                	mov    %edx,%esi
  80108b:	f7 e7                	mul    %edi
  80108d:	39 d6                	cmp    %edx,%esi
  80108f:	89 c1                	mov    %eax,%ecx
  801091:	89 d7                	mov    %edx,%edi
  801093:	72 3f                	jb     8010d4 <__umoddi3+0x154>
  801095:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801099:	72 35                	jb     8010d0 <__umoddi3+0x150>
  80109b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80109f:	29 c8                	sub    %ecx,%eax
  8010a1:	19 fe                	sbb    %edi,%esi
  8010a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010a8:	89 f2                	mov    %esi,%edx
  8010aa:	d3 e8                	shr    %cl,%eax
  8010ac:	89 e9                	mov    %ebp,%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010b5:	09 d0                	or     %edx,%eax
  8010b7:	89 f2                	mov    %esi,%edx
  8010b9:	d3 ea                	shr    %cl,%edx
  8010bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c7:	83 c4 1c             	add    $0x1c,%esp
  8010ca:	c3                   	ret    
  8010cb:	90                   	nop
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	39 d6                	cmp    %edx,%esi
  8010d2:	75 c7                	jne    80109b <__umoddi3+0x11b>
  8010d4:	89 d7                	mov    %edx,%edi
  8010d6:	89 c1                	mov    %eax,%ecx
  8010d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8010dc:	1b 3c 24             	sbb    (%esp),%edi
  8010df:	eb ba                	jmp    80109b <__umoddi3+0x11b>
  8010e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	39 f5                	cmp    %esi,%ebp
  8010ea:	0f 82 f1 fe ff ff    	jb     800fe1 <__umoddi3+0x61>
  8010f0:	e9 f8 fe ff ff       	jmp    800fed <__umoddi3+0x6d>
