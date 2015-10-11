
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
  800039:	c7 44 24 04 97 03 80 	movl   $0x800397,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 82 02 00 00       	call   8002cf <sys_env_set_pgfault_upcall>
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
  80005c:	56                   	push   %esi
  80005d:	53                   	push   %ebx
  80005e:	83 ec 10             	sub    $0x10,%esp
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800067:	e8 d8 00 00 00       	call   800144 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	89 74 24 04          	mov    %esi,0x4(%esp)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 07 00 00 00       	call   8000a1 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 3f 00 00 00       	call   8000f2 <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	89 c3                	mov    %eax,%ebx
  8000c8:	89 c7                	mov    %eax,%edi
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000de:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e3:	89 d1                	mov    %edx,%ecx
  8000e5:	89 d3                	mov    %edx,%ebx
  8000e7:	89 d7                	mov    %edx,%edi
  8000e9:	89 d6                	mov    %edx,%esi
  8000eb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800100:	b8 03 00 00 00       	mov    $0x3,%eax
  800105:	8b 55 08             	mov    0x8(%ebp),%edx
  800108:	89 cb                	mov    %ecx,%ebx
  80010a:	89 cf                	mov    %ecx,%edi
  80010c:	89 ce                	mov    %ecx,%esi
  80010e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800110:	85 c0                	test   %eax,%eax
  800112:	7e 28                	jle    80013c <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	89 44 24 10          	mov    %eax,0x10(%esp)
  800118:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011f:	00 
  800120:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800137:	e8 66 02 00 00       	call   8003a2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	83 c4 2c             	add    $0x2c,%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 02 00 00 00       	mov    $0x2,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_yield>:

void
sys_yield(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 d3                	mov    %edx,%ebx
  800177:	89 d7                	mov    %edx,%edi
  800179:	89 d6                	mov    %edx,%esi
  80017b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	be 00 00 00 00       	mov    $0x0,%esi
  800190:	b8 04 00 00 00       	mov    $0x4,%eax
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019e:	89 f7                	mov    %esi,%edi
  8001a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7e 28                	jle    8001ce <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001aa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8001c9:	e8 d4 01 00 00       	call   8003a2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ce:	83 c4 2c             	add    $0x2c,%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f5:	85 c0                	test   %eax,%eax
  8001f7:	7e 28                	jle    800221 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800204:	00 
  800205:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80020c:	00 
  80020d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800214:	00 
  800215:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80021c:	e8 81 01 00 00       	call   8003a2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800221:	83 c4 2c             	add    $0x2c,%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 06 00 00 00       	mov    $0x6,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 28                	jle    800274 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800250:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800257:	00 
  800258:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80025f:	00 
  800260:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800267:	00 
  800268:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80026f:	e8 2e 01 00 00       	call   8003a2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800274:	83 c4 2c             	add    $0x2c,%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5f                   	pop    %edi
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	b8 08 00 00 00       	mov    $0x8,%eax
  80028f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800292:	8b 55 08             	mov    0x8(%ebp),%edx
  800295:	89 df                	mov    %ebx,%edi
  800297:	89 de                	mov    %ebx,%esi
  800299:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7e 28                	jle    8002c7 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a3:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002aa:	00 
  8002ab:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002c2:	e8 db 00 00 00       	call   8003a2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c7:	83 c4 2c             	add    $0x2c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 df                	mov    %ebx,%edi
  8002ea:	89 de                	mov    %ebx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 28                	jle    80031a <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800315:	e8 88 00 00 00       	call   8003a2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031a:	83 c4 2c             	add    $0x2c,%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800328:	be 00 00 00 00       	mov    $0x0,%esi
  80032d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800353:	b8 0c 00 00 00       	mov    $0xc,%eax
  800358:	8b 55 08             	mov    0x8(%ebp),%edx
  80035b:	89 cb                	mov    %ecx,%ebx
  80035d:	89 cf                	mov    %ecx,%edi
  80035f:	89 ce                	mov    %ecx,%esi
  800361:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800363:	85 c0                	test   %eax,%eax
  800365:	7e 28                	jle    80038f <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800367:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800372:	00 
  800373:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80037a:	00 
  80037b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800382:	00 
  800383:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80038a:	e8 13 00 00 00       	call   8003a2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038f:	83 c4 2c             	add    $0x2c,%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800397:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800398:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80039d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80039f:	83 c4 04             	add    $0x4,%esp

008003a2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ad:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003b3:	e8 8c fd ff ff       	call   800144 <sys_getenvid>
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ce:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  8003d5:	e8 c1 00 00 00       	call   80049b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003de:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e1:	89 04 24             	mov    %eax,(%esp)
  8003e4:	e8 51 00 00 00       	call   80043a <vcprintf>
	cprintf("\n");
  8003e9:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  8003f0:	e8 a6 00 00 00       	call   80049b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003f5:	cc                   	int3   
  8003f6:	eb fd                	jmp    8003f5 <_panic+0x53>

008003f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 14             	sub    $0x14,%esp
  8003ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800402:	8b 13                	mov    (%ebx),%edx
  800404:	8d 42 01             	lea    0x1(%edx),%eax
  800407:	89 03                	mov    %eax,(%ebx)
  800409:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800410:	3d ff 00 00 00       	cmp    $0xff,%eax
  800415:	75 19                	jne    800430 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800417:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80041e:	00 
  80041f:	8d 43 08             	lea    0x8(%ebx),%eax
  800422:	89 04 24             	mov    %eax,(%esp)
  800425:	e8 8b fc ff ff       	call   8000b5 <sys_cputs>
		b->idx = 0;
  80042a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800430:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800434:	83 c4 14             	add    $0x14,%esp
  800437:	5b                   	pop    %ebx
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800443:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80044a:	00 00 00 
	b.cnt = 0;
  80044d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800454:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	89 44 24 08          	mov    %eax,0x8(%esp)
  800465:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	c7 04 24 f8 03 80 00 	movl   $0x8003f8,(%esp)
  800476:	e8 79 01 00 00       	call   8005f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80047b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800481:	89 44 24 04          	mov    %eax,0x4(%esp)
  800485:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	e8 22 fc ff ff       	call   8000b5 <sys_cputs>

	return b.cnt;
}
  800493:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800499:	c9                   	leave  
  80049a:	c3                   	ret    

0080049b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	e8 87 ff ff ff       	call   80043a <vcprintf>
	va_end(ap);

	return cnt;
}
  8004b3:	c9                   	leave  
  8004b4:	c3                   	ret    
  8004b5:	66 90                	xchg   %ax,%ax
  8004b7:	66 90                	xchg   %ax,%ax
  8004b9:	66 90                	xchg   %ax,%ax
  8004bb:	66 90                	xchg   %ax,%ax
  8004bd:	66 90                	xchg   %ax,%ax
  8004bf:	90                   	nop

008004c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
  8004c6:	83 ec 3c             	sub    $0x3c,%esp
  8004c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cc:	89 d7                	mov    %edx,%edi
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 c3                	mov    %eax,%ebx
  8004d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004ed:	39 d9                	cmp    %ebx,%ecx
  8004ef:	72 05                	jb     8004f6 <printnum+0x36>
  8004f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004f4:	77 69                	ja     80055f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800504:	89 44 24 08          	mov    %eax,0x8(%esp)
  800508:	8b 44 24 08          	mov    0x8(%esp),%eax
  80050c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800510:	89 c3                	mov    %eax,%ebx
  800512:	89 d6                	mov    %edx,%esi
  800514:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800517:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80051e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800522:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800525:	89 04 24             	mov    %eax,(%esp)
  800528:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	e8 6c 09 00 00       	call   800ea0 <__udivdi3>
  800534:	89 d9                	mov    %ebx,%ecx
  800536:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80053a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 fa                	mov    %edi,%edx
  800547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054a:	e8 71 ff ff ff       	call   8004c0 <printnum>
  80054f:	eb 1b                	jmp    80056c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	8b 45 18             	mov    0x18(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff d3                	call   *%ebx
  80055d:	eb 03                	jmp    800562 <printnum+0xa2>
  80055f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800562:	83 ee 01             	sub    $0x1,%esi
  800565:	85 f6                	test   %esi,%esi
  800567:	7f e8                	jg     800551 <printnum+0x91>
  800569:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800570:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800574:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800577:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800582:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	e8 3c 0a 00 00       	call   800fd0 <__umoddi3>
  800594:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800598:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a5:	ff d0                	call   *%eax
}
  8005a7:	83 c4 3c             	add    $0x3c,%esp
  8005aa:	5b                   	pop    %ebx
  8005ab:	5e                   	pop    %esi
  8005ac:	5f                   	pop    %edi
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    

008005af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
  8005b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005be:	73 0a                	jae    8005ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8005c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005c3:	89 08                	mov    %ecx,(%eax)
  8005c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c8:	88 02                	mov    %al,(%edx)
}
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    

008005cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005cc:	55                   	push   %ebp
  8005cd:	89 e5                	mov    %esp,%ebp
  8005cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 02 00 00 00       	call   8005f4 <vprintfmt>
	va_end(ap);
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	57                   	push   %edi
  8005f8:	56                   	push   %esi
  8005f9:	53                   	push   %ebx
  8005fa:	83 ec 3c             	sub    $0x3c,%esp
  8005fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800603:	8b 7d 10             	mov    0x10(%ebp),%edi
  800606:	eb 11                	jmp    800619 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800608:	85 c0                	test   %eax,%eax
  80060a:	0f 84 48 04 00 00    	je     800a58 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800619:	83 c7 01             	add    $0x1,%edi
  80061c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800620:	83 f8 25             	cmp    $0x25,%eax
  800623:	75 e3                	jne    800608 <vprintfmt+0x14>
  800625:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800629:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800630:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800637:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800643:	eb 1f                	jmp    800664 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800648:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80064c:	eb 16                	jmp    800664 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800651:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800655:	eb 0d                	jmp    800664 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800657:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80065a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8d 47 01             	lea    0x1(%edi),%eax
  800667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066a:	0f b6 17             	movzbl (%edi),%edx
  80066d:	0f b6 c2             	movzbl %dl,%eax
  800670:	83 ea 23             	sub    $0x23,%edx
  800673:	80 fa 55             	cmp    $0x55,%dl
  800676:	0f 87 bf 03 00 00    	ja     800a3b <vprintfmt+0x447>
  80067c:	0f b6 d2             	movzbl %dl,%edx
  80067f:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
  80068e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800691:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800694:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800698:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80069b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80069e:	83 f9 09             	cmp    $0x9,%ecx
  8006a1:	77 3c                	ja     8006df <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a6:	eb e9                	jmp    800691 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006bc:	eb 27                	jmp    8006e5 <vprintfmt+0xf1>
  8006be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c1:	85 d2                	test   %edx,%edx
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	0f 49 c2             	cmovns %edx,%eax
  8006cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	eb 91                	jmp    800664 <vprintfmt+0x70>
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006dd:	eb 85                	jmp    800664 <vprintfmt+0x70>
  8006df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e9:	0f 89 75 ff ff ff    	jns    800664 <vprintfmt+0x70>
  8006ef:	e9 63 ff ff ff       	jmp    800657 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006fa:	e9 65 ff ff ff       	jmp    800664 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800702:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800714:	e9 00 ff ff ff       	jmp    800619 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80071c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800720:	8b 00                	mov    (%eax),%eax
  800722:	99                   	cltd   
  800723:	31 d0                	xor    %edx,%eax
  800725:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800727:	83 f8 09             	cmp    $0x9,%eax
  80072a:	7f 0b                	jg     800737 <vprintfmt+0x143>
  80072c:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800733:	85 d2                	test   %edx,%edx
  800735:	75 20                	jne    800757 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800737:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073b:	c7 44 24 08 b5 11 80 	movl   $0x8011b5,0x8(%esp)
  800742:	00 
  800743:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800747:	89 34 24             	mov    %esi,(%esp)
  80074a:	e8 7d fe ff ff       	call   8005cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800752:	e9 c2 fe ff ff       	jmp    800619 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800757:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075b:	c7 44 24 08 be 11 80 	movl   $0x8011be,0x8(%esp)
  800762:	00 
  800763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800767:	89 34 24             	mov    %esi,(%esp)
  80076a:	e8 5d fe ff ff       	call   8005cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	e9 a2 fe ff ff       	jmp    800619 <vprintfmt+0x25>
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80077d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800780:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800783:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800787:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800789:	85 ff                	test   %edi,%edi
  80078b:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  800790:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800793:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800797:	0f 84 92 00 00 00    	je     80082f <vprintfmt+0x23b>
  80079d:	85 c9                	test   %ecx,%ecx
  80079f:	0f 8e 98 00 00 00    	jle    80083d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a9:	89 3c 24             	mov    %edi,(%esp)
  8007ac:	e8 47 03 00 00       	call   800af8 <strnlen>
  8007b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007b4:	29 c1                	sub    %eax,%ecx
  8007b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c5:	eb 0f                	jmp    8007d6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d3:	83 ef 01             	sub    $0x1,%edi
  8007d6:	85 ff                	test   %edi,%edi
  8007d8:	7f ed                	jg     8007c7 <vprintfmt+0x1d3>
  8007da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e0:	85 c9                	test   %ecx,%ecx
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	0f 49 c1             	cmovns %ecx,%eax
  8007ea:	29 c1                	sub    %eax,%ecx
  8007ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007f5:	89 cb                	mov    %ecx,%ebx
  8007f7:	eb 50                	jmp    800849 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007fd:	74 1e                	je     80081d <vprintfmt+0x229>
  8007ff:	0f be d2             	movsbl %dl,%edx
  800802:	83 ea 20             	sub    $0x20,%edx
  800805:	83 fa 5e             	cmp    $0x5e,%edx
  800808:	76 13                	jbe    80081d <vprintfmt+0x229>
					putch('?', putdat);
  80080a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800818:	ff 55 08             	call   *0x8(%ebp)
  80081b:	eb 0d                	jmp    80082a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082a:	83 eb 01             	sub    $0x1,%ebx
  80082d:	eb 1a                	jmp    800849 <vprintfmt+0x255>
  80082f:	89 75 08             	mov    %esi,0x8(%ebp)
  800832:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800835:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800838:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80083b:	eb 0c                	jmp    800849 <vprintfmt+0x255>
  80083d:	89 75 08             	mov    %esi,0x8(%ebp)
  800840:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800843:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800846:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800849:	83 c7 01             	add    $0x1,%edi
  80084c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800850:	0f be c2             	movsbl %dl,%eax
  800853:	85 c0                	test   %eax,%eax
  800855:	74 25                	je     80087c <vprintfmt+0x288>
  800857:	85 f6                	test   %esi,%esi
  800859:	78 9e                	js     8007f9 <vprintfmt+0x205>
  80085b:	83 ee 01             	sub    $0x1,%esi
  80085e:	79 99                	jns    8007f9 <vprintfmt+0x205>
  800860:	89 df                	mov    %ebx,%edi
  800862:	8b 75 08             	mov    0x8(%ebp),%esi
  800865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800868:	eb 1a                	jmp    800884 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	eb 08                	jmp    800884 <vprintfmt+0x290>
  80087c:	89 df                	mov    %ebx,%edi
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800884:	85 ff                	test   %edi,%edi
  800886:	7f e2                	jg     80086a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800888:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088b:	e9 89 fd ff ff       	jmp    800619 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800890:	83 f9 01             	cmp    $0x1,%ecx
  800893:	7e 19                	jle    8008ae <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8b 50 04             	mov    0x4(%eax),%edx
  80089b:	8b 00                	mov    (%eax),%eax
  80089d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 40 08             	lea    0x8(%eax),%eax
  8008a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ac:	eb 38                	jmp    8008e6 <vprintfmt+0x2f2>
	else if (lflag)
  8008ae:	85 c9                	test   %ecx,%ecx
  8008b0:	74 1b                	je     8008cd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ba:	89 c1                	mov    %eax,%ecx
  8008bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8d 40 04             	lea    0x4(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008cb:	eb 19                	jmp    8008e6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 00                	mov    (%eax),%eax
  8008d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d5:	89 c1                	mov    %eax,%ecx
  8008d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8d 40 04             	lea    0x4(%eax),%eax
  8008e3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ec:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f5:	0f 89 04 01 00 00    	jns    8009ff <vprintfmt+0x40b>
				putch('-', putdat);
  8008fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800906:	ff d6                	call   *%esi
				num = -(long long) num;
  800908:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80090b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80090e:	f7 da                	neg    %edx
  800910:	83 d1 00             	adc    $0x0,%ecx
  800913:	f7 d9                	neg    %ecx
  800915:	e9 e5 00 00 00       	jmp    8009ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80091a:	83 f9 01             	cmp    $0x1,%ecx
  80091d:	7e 10                	jle    80092f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8b 10                	mov    (%eax),%edx
  800924:	8b 48 04             	mov    0x4(%eax),%ecx
  800927:	8d 40 08             	lea    0x8(%eax),%eax
  80092a:	89 45 14             	mov    %eax,0x14(%ebp)
  80092d:	eb 26                	jmp    800955 <vprintfmt+0x361>
	else if (lflag)
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	74 12                	je     800945 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	8d 40 04             	lea    0x4(%eax),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
  800943:	eb 10                	jmp    800955 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8b 10                	mov    (%eax),%edx
  80094a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094f:	8d 40 04             	lea    0x4(%eax),%eax
  800952:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800955:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80095a:	e9 a0 00 00 00       	jmp    8009ff <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80095f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800963:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80096a:	ff d6                	call   *%esi
			putch('X', putdat);
  80096c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800970:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800977:	ff d6                	call   *%esi
			putch('X', putdat);
  800979:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800984:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800986:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800989:	e9 8b fc ff ff       	jmp    800619 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80098e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800992:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800999:	ff d6                	call   *%esi
			putch('x', putdat);
  80099b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009a6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009b2:	8d 40 04             	lea    0x4(%eax),%eax
  8009b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009bd:	eb 40                	jmp    8009ff <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009bf:	83 f9 01             	cmp    $0x1,%ecx
  8009c2:	7e 10                	jle    8009d4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8b 10                	mov    (%eax),%edx
  8009c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009cc:	8d 40 08             	lea    0x8(%eax),%eax
  8009cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8009d2:	eb 26                	jmp    8009fa <vprintfmt+0x406>
	else if (lflag)
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 12                	je     8009ea <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8b 10                	mov    (%eax),%edx
  8009dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e2:	8d 40 04             	lea    0x4(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009e8:	eb 10                	jmp    8009fa <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ed:	8b 10                	mov    (%eax),%edx
  8009ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f4:	8d 40 04             	lea    0x4(%eax),%eax
  8009f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009fa:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a12:	89 14 24             	mov    %edx,(%esp)
  800a15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a19:	89 da                	mov    %ebx,%edx
  800a1b:	89 f0                	mov    %esi,%eax
  800a1d:	e8 9e fa ff ff       	call   8004c0 <printnum>
			break;
  800a22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a25:	e9 ef fb ff ff       	jmp    800619 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	89 04 24             	mov    %eax,(%esp)
  800a31:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a36:	e9 de fb ff ff       	jmp    800619 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a48:	eb 03                	jmp    800a4d <vprintfmt+0x459>
  800a4a:	83 ef 01             	sub    $0x1,%edi
  800a4d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a51:	75 f7                	jne    800a4a <vprintfmt+0x456>
  800a53:	e9 c1 fb ff ff       	jmp    800619 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a58:	83 c4 3c             	add    $0x3c,%esp
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 28             	sub    $0x28,%esp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a6f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a73:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	74 30                	je     800ab1 <vsnprintf+0x51>
  800a81:	85 d2                	test   %edx,%edx
  800a83:	7e 2c                	jle    800ab1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9a:	c7 04 24 af 05 80 00 	movl   $0x8005af,(%esp)
  800aa1:	e8 4e fb ff ff       	call   8005f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aaf:	eb 05                	jmp    800ab6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ab1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800abe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ac1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ac5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	89 04 24             	mov    %eax,(%esp)
  800ad9:	e8 82 ff ff ff       	call   800a60 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	eb 03                	jmp    800af0 <strlen+0x10>
		n++;
  800aed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800af0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800af4:	75 f7                	jne    800aed <strlen+0xd>
		n++;
	return n;
}
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	eb 03                	jmp    800b0b <strnlen+0x13>
		n++;
  800b08:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0b:	39 d0                	cmp    %edx,%eax
  800b0d:	74 06                	je     800b15 <strnlen+0x1d>
  800b0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b13:	75 f3                	jne    800b08 <strnlen+0x10>
		n++;
	return n;
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b2d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b30:	84 db                	test   %bl,%bl
  800b32:	75 ef                	jne    800b23 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b34:	5b                   	pop    %ebx
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b41:	89 1c 24             	mov    %ebx,(%esp)
  800b44:	e8 97 ff ff ff       	call   800ae0 <strlen>
	strcpy(dst + len, src);
  800b49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b50:	01 d8                	add    %ebx,%eax
  800b52:	89 04 24             	mov    %eax,(%esp)
  800b55:	e8 bd ff ff ff       	call   800b17 <strcpy>
	return dst;
}
  800b5a:	89 d8                	mov    %ebx,%eax
  800b5c:	83 c4 08             	add    $0x8,%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b72:	89 f2                	mov    %esi,%edx
  800b74:	eb 0f                	jmp    800b85 <strncpy+0x23>
		*dst++ = *src;
  800b76:	83 c2 01             	add    $0x1,%edx
  800b79:	0f b6 01             	movzbl (%ecx),%eax
  800b7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b85:	39 da                	cmp    %ebx,%edx
  800b87:	75 ed                	jne    800b76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 75 08             	mov    0x8(%ebp),%esi
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	75 0b                	jne    800bb2 <strlcpy+0x23>
  800ba7:	eb 1d                	jmp    800bc6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ba9:	83 c0 01             	add    $0x1,%eax
  800bac:	83 c2 01             	add    $0x1,%edx
  800baf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb2:	39 d8                	cmp    %ebx,%eax
  800bb4:	74 0b                	je     800bc1 <strlcpy+0x32>
  800bb6:	0f b6 0a             	movzbl (%edx),%ecx
  800bb9:	84 c9                	test   %cl,%cl
  800bbb:	75 ec                	jne    800ba9 <strlcpy+0x1a>
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	eb 02                	jmp    800bc3 <strlcpy+0x34>
  800bc1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bc3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bc6:	29 f0                	sub    %esi,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd5:	eb 06                	jmp    800bdd <strcmp+0x11>
		p++, q++;
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdd:	0f b6 01             	movzbl (%ecx),%eax
  800be0:	84 c0                	test   %al,%al
  800be2:	74 04                	je     800be8 <strcmp+0x1c>
  800be4:	3a 02                	cmp    (%edx),%al
  800be6:	74 ef                	je     800bd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 c0             	movzbl %al,%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
}
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	53                   	push   %ebx
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfc:	89 c3                	mov    %eax,%ebx
  800bfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c01:	eb 06                	jmp    800c09 <strncmp+0x17>
		n--, p++, q++;
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c09:	39 d8                	cmp    %ebx,%eax
  800c0b:	74 15                	je     800c22 <strncmp+0x30>
  800c0d:	0f b6 08             	movzbl (%eax),%ecx
  800c10:	84 c9                	test   %cl,%cl
  800c12:	74 04                	je     800c18 <strncmp+0x26>
  800c14:	3a 0a                	cmp    (%edx),%cl
  800c16:	74 eb                	je     800c03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c18:	0f b6 00             	movzbl (%eax),%eax
  800c1b:	0f b6 12             	movzbl (%edx),%edx
  800c1e:	29 d0                	sub    %edx,%eax
  800c20:	eb 05                	jmp    800c27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c34:	eb 07                	jmp    800c3d <strchr+0x13>
		if (*s == c)
  800c36:	38 ca                	cmp    %cl,%dl
  800c38:	74 0f                	je     800c49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 f2                	jne    800c36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c55:	eb 07                	jmp    800c5e <strfind+0x13>
		if (*s == c)
  800c57:	38 ca                	cmp    %cl,%dl
  800c59:	74 0a                	je     800c65 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c5b:	83 c0 01             	add    $0x1,%eax
  800c5e:	0f b6 10             	movzbl (%eax),%edx
  800c61:	84 d2                	test   %dl,%dl
  800c63:	75 f2                	jne    800c57 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c73:	85 c9                	test   %ecx,%ecx
  800c75:	74 36                	je     800cad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7d:	75 28                	jne    800ca7 <memset+0x40>
  800c7f:	f6 c1 03             	test   $0x3,%cl
  800c82:	75 23                	jne    800ca7 <memset+0x40>
		c &= 0xFF;
  800c84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	c1 e3 08             	shl    $0x8,%ebx
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	c1 e6 18             	shl    $0x18,%esi
  800c92:	89 d0                	mov    %edx,%eax
  800c94:	c1 e0 10             	shl    $0x10,%eax
  800c97:	09 f0                	or     %esi,%eax
  800c99:	09 c2                	or     %eax,%edx
  800c9b:	89 d0                	mov    %edx,%eax
  800c9d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c9f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ca2:	fc                   	cld    
  800ca3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ca5:	eb 06                	jmp    800cad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	fc                   	cld    
  800cab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cad:	89 f8                	mov    %edi,%eax
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc2:	39 c6                	cmp    %eax,%esi
  800cc4:	73 35                	jae    800cfb <memmove+0x47>
  800cc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc9:	39 d0                	cmp    %edx,%eax
  800ccb:	73 2e                	jae    800cfb <memmove+0x47>
		s += n;
		d += n;
  800ccd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cda:	75 13                	jne    800cef <memmove+0x3b>
  800cdc:	f6 c1 03             	test   $0x3,%cl
  800cdf:	75 0e                	jne    800cef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ce1:	83 ef 04             	sub    $0x4,%edi
  800ce4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cea:	fd                   	std    
  800ceb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ced:	eb 09                	jmp    800cf8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cef:	83 ef 01             	sub    $0x1,%edi
  800cf2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cf5:	fd                   	std    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf8:	fc                   	cld    
  800cf9:	eb 1d                	jmp    800d18 <memmove+0x64>
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cff:	f6 c2 03             	test   $0x3,%dl
  800d02:	75 0f                	jne    800d13 <memmove+0x5f>
  800d04:	f6 c1 03             	test   $0x3,%cl
  800d07:	75 0a                	jne    800d13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d09:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	fc                   	cld    
  800d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d11:	eb 05                	jmp    800d18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	fc                   	cld    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d22:	8b 45 10             	mov    0x10(%ebp),%eax
  800d25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	89 04 24             	mov    %eax,(%esp)
  800d36:	e8 79 ff ff ff       	call   800cb4 <memmove>
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	89 d6                	mov    %edx,%esi
  800d4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d4d:	eb 1a                	jmp    800d69 <memcmp+0x2c>
		if (*s1 != *s2)
  800d4f:	0f b6 02             	movzbl (%edx),%eax
  800d52:	0f b6 19             	movzbl (%ecx),%ebx
  800d55:	38 d8                	cmp    %bl,%al
  800d57:	74 0a                	je     800d63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d59:	0f b6 c0             	movzbl %al,%eax
  800d5c:	0f b6 db             	movzbl %bl,%ebx
  800d5f:	29 d8                	sub    %ebx,%eax
  800d61:	eb 0f                	jmp    800d72 <memcmp+0x35>
		s1++, s2++;
  800d63:	83 c2 01             	add    $0x1,%edx
  800d66:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d69:	39 f2                	cmp    %esi,%edx
  800d6b:	75 e2                	jne    800d4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d7f:	89 c2                	mov    %eax,%edx
  800d81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d84:	eb 07                	jmp    800d8d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d86:	38 08                	cmp    %cl,(%eax)
  800d88:	74 07                	je     800d91 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d8a:	83 c0 01             	add    $0x1,%eax
  800d8d:	39 d0                	cmp    %edx,%eax
  800d8f:	72 f5                	jb     800d86 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9f:	eb 03                	jmp    800da4 <strtol+0x11>
		s++;
  800da1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da4:	0f b6 0a             	movzbl (%edx),%ecx
  800da7:	80 f9 09             	cmp    $0x9,%cl
  800daa:	74 f5                	je     800da1 <strtol+0xe>
  800dac:	80 f9 20             	cmp    $0x20,%cl
  800daf:	74 f0                	je     800da1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800db1:	80 f9 2b             	cmp    $0x2b,%cl
  800db4:	75 0a                	jne    800dc0 <strtol+0x2d>
		s++;
  800db6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800db9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dbe:	eb 11                	jmp    800dd1 <strtol+0x3e>
  800dc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dc5:	80 f9 2d             	cmp    $0x2d,%cl
  800dc8:	75 07                	jne    800dd1 <strtol+0x3e>
		s++, neg = 1;
  800dca:	8d 52 01             	lea    0x1(%edx),%edx
  800dcd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dd1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800dd6:	75 15                	jne    800ded <strtol+0x5a>
  800dd8:	80 3a 30             	cmpb   $0x30,(%edx)
  800ddb:	75 10                	jne    800ded <strtol+0x5a>
  800ddd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800de1:	75 0a                	jne    800ded <strtol+0x5a>
		s += 2, base = 16;
  800de3:	83 c2 02             	add    $0x2,%edx
  800de6:	b8 10 00 00 00       	mov    $0x10,%eax
  800deb:	eb 10                	jmp    800dfd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ded:	85 c0                	test   %eax,%eax
  800def:	75 0c                	jne    800dfd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800df1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df3:	80 3a 30             	cmpb   $0x30,(%edx)
  800df6:	75 05                	jne    800dfd <strtol+0x6a>
		s++, base = 8;
  800df8:	83 c2 01             	add    $0x1,%edx
  800dfb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e05:	0f b6 0a             	movzbl (%edx),%ecx
  800e08:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e0b:	89 f0                	mov    %esi,%eax
  800e0d:	3c 09                	cmp    $0x9,%al
  800e0f:	77 08                	ja     800e19 <strtol+0x86>
			dig = *s - '0';
  800e11:	0f be c9             	movsbl %cl,%ecx
  800e14:	83 e9 30             	sub    $0x30,%ecx
  800e17:	eb 20                	jmp    800e39 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e19:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e1c:	89 f0                	mov    %esi,%eax
  800e1e:	3c 19                	cmp    $0x19,%al
  800e20:	77 08                	ja     800e2a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e22:	0f be c9             	movsbl %cl,%ecx
  800e25:	83 e9 57             	sub    $0x57,%ecx
  800e28:	eb 0f                	jmp    800e39 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e2a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e2d:	89 f0                	mov    %esi,%eax
  800e2f:	3c 19                	cmp    $0x19,%al
  800e31:	77 16                	ja     800e49 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e33:	0f be c9             	movsbl %cl,%ecx
  800e36:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e39:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e3c:	7d 0f                	jge    800e4d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e45:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e47:	eb bc                	jmp    800e05 <strtol+0x72>
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	eb 02                	jmp    800e4f <strtol+0xbc>
  800e4d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e53:	74 05                	je     800e5a <strtol+0xc7>
		*endptr = (char *) s;
  800e55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e58:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e5a:	f7 d8                	neg    %eax
  800e5c:	85 ff                	test   %edi,%edi
  800e5e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e6c:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e73:	75 1c                	jne    800e91 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800e75:	c7 44 24 08 e8 13 80 	movl   $0x8013e8,0x8(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800e84:	00 
  800e85:	c7 04 24 0c 14 80 00 	movl   $0x80140c,(%esp)
  800e8c:	e8 11 f5 ff ff       	call   8003a2 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    
  800e9b:	66 90                	xchg   %ax,%ax
  800e9d:	66 90                	xchg   %ax,%ax
  800e9f:	90                   	nop

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
