
obj/user/faultnostack.debug：     文件格式 elf32-i386


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
  800039:	c7 44 24 04 ea 03 80 	movl   $0x8003ea,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 d5 02 00 00       	call   800322 <sys_env_set_pgfault_upcall>
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
	// LAB : Your code here.
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
	//close_all();
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
  800120:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800137:	e8 ed 02 00 00       	call   800429 <_panic>

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
  80016e:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  8001b2:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8001c9:	e8 5b 02 00 00       	call   800429 <_panic>

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
  800205:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80020c:	00 
  80020d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800214:	00 
  800215:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80021c:	e8 08 02 00 00       	call   800429 <_panic>

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
  800258:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  80025f:	00 
  800260:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800267:	00 
  800268:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  80026f:	e8 b5 01 00 00       	call   800429 <_panic>

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
  8002ab:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8002c2:	e8 62 01 00 00       	call   800429 <_panic>

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

008002cf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  8002f0:	7e 28                	jle    80031a <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fd:	00 
  8002fe:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800305:	00 
  800306:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800315:	e8 0f 01 00 00       	call   800429 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80031a:	83 c4 2c             	add    $0x2c,%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800330:	b8 0a 00 00 00       	mov    $0xa,%eax
  800335:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	89 df                	mov    %ebx,%edi
  80033d:	89 de                	mov    %ebx,%esi
  80033f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7e 28                	jle    80036d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800345:	89 44 24 10          	mov    %eax,0x10(%esp)
  800349:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800350:	00 
  800351:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  800358:	00 
  800359:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800360:	00 
  800361:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  800368:	e8 bc 00 00 00       	call   800429 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036d:	83 c4 2c             	add    $0x2c,%esp
  800370:	5b                   	pop    %ebx
  800371:	5e                   	pop    %esi
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037b:	be 00 00 00 00       	mov    $0x0,%esi
  800380:	b8 0c 00 00 00       	mov    $0xc,%eax
  800385:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800388:	8b 55 08             	mov    0x8(%ebp),%edx
  80038b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800391:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800393:	5b                   	pop    %ebx
  800394:	5e                   	pop    %esi
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ae:	89 cb                	mov    %ecx,%ebx
  8003b0:	89 cf                	mov    %ecx,%edi
  8003b2:	89 ce                	mov    %ecx,%esi
  8003b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	7e 28                	jle    8003e2 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003be:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c5:	00 
  8003c6:	c7 44 24 08 2a 12 80 	movl   $0x80122a,0x8(%esp)
  8003cd:	00 
  8003ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d5:	00 
  8003d6:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8003dd:	e8 47 00 00 00       	call   800429 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e2:	83 c4 2c             	add    $0x2c,%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5f                   	pop    %edi
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003ea:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003eb:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003f0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003f2:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  8003f5:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8003f9:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8003fd:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  800401:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  800404:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  800407:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  80040a:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  80040e:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  800412:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  800416:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  80041a:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  80041e:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  800422:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  800426:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  800427:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  800428:	c3                   	ret    

00800429 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800431:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800434:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80043a:	e8 05 fd ff ff       	call   800144 <sys_getenvid>
  80043f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800442:	89 54 24 10          	mov    %edx,0x10(%esp)
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  80045c:	e8 c1 00 00 00       	call   800522 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800461:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 51 00 00 00       	call   8004c1 <vcprintf>
	cprintf("\n");
  800470:	c7 04 24 7b 12 80 00 	movl   $0x80127b,(%esp)
  800477:	e8 a6 00 00 00       	call   800522 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047c:	cc                   	int3   
  80047d:	eb fd                	jmp    80047c <_panic+0x53>

0080047f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	53                   	push   %ebx
  800483:	83 ec 14             	sub    $0x14,%esp
  800486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800489:	8b 13                	mov    (%ebx),%edx
  80048b:	8d 42 01             	lea    0x1(%edx),%eax
  80048e:	89 03                	mov    %eax,(%ebx)
  800490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800493:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800497:	3d ff 00 00 00       	cmp    $0xff,%eax
  80049c:	75 19                	jne    8004b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80049e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004a5:	00 
  8004a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8004a9:	89 04 24             	mov    %eax,(%esp)
  8004ac:	e8 04 fc ff ff       	call   8000b5 <sys_cputs>
		b->idx = 0;
  8004b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004bb:	83 c4 14             	add    $0x14,%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d1:	00 00 00 
	b.cnt = 0;
  8004d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f6:	c7 04 24 7f 04 80 00 	movl   $0x80047f,(%esp)
  8004fd:	e8 72 01 00 00       	call   800674 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800502:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	e8 9b fb ff ff       	call   8000b5 <sys_cputs>

	return b.cnt;
}
  80051a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800528:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	8b 45 08             	mov    0x8(%ebp),%eax
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	e8 87 ff ff ff       	call   8004c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    
  80053c:	66 90                	xchg   %ax,%ax
  80053e:	66 90                	xchg   %ax,%ax

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
  800551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800554:	8b 45 0c             	mov    0xc(%ebp),%eax
  800557:	89 c3                	mov    %eax,%ebx
  800559:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80055c:	8b 45 10             	mov    0x10(%ebp),%eax
  80055f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800562:	b9 00 00 00 00       	mov    $0x0,%ecx
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	39 d9                	cmp    %ebx,%ecx
  80056f:	72 05                	jb     800576 <printnum+0x36>
  800571:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800574:	77 69                	ja     8005df <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800576:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800579:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80057d:	83 ee 01             	sub    $0x1,%esi
  800580:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800584:	89 44 24 08          	mov    %eax,0x8(%esp)
  800588:	8b 44 24 08          	mov    0x8(%esp),%eax
  80058c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800590:	89 c3                	mov    %eax,%ebx
  800592:	89 d6                	mov    %edx,%esi
  800594:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800597:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80059e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8005a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	e8 cc 09 00 00       	call   800f80 <__udivdi3>
  8005b4:	89 d9                	mov    %ebx,%ecx
  8005b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c5:	89 fa                	mov    %edi,%edx
  8005c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ca:	e8 71 ff ff ff       	call   800540 <printnum>
  8005cf:	eb 1b                	jmp    8005ec <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d5:	8b 45 18             	mov    0x18(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff d3                	call   *%ebx
  8005dd:	eb 03                	jmp    8005e2 <printnum+0xa2>
  8005df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e2:	83 ee 01             	sub    $0x1,%esi
  8005e5:	85 f6                	test   %esi,%esi
  8005e7:	7f e8                	jg     8005d1 <printnum+0x91>
  8005e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800602:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	e8 9c 0a 00 00       	call   8010b0 <__umoddi3>
  800614:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800618:	0f be 80 7d 12 80 00 	movsbl 0x80127d(%eax),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800625:	ff d0                	call   *%eax
}
  800627:	83 c4 3c             	add    $0x3c,%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800635:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	3b 50 04             	cmp    0x4(%eax),%edx
  80063e:	73 0a                	jae    80064a <sprintputch+0x1b>
		*b->buf++ = ch;
  800640:	8d 4a 01             	lea    0x1(%edx),%ecx
  800643:	89 08                	mov    %ecx,(%eax)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	88 02                	mov    %al,(%edx)
}
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800655:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800659:	8b 45 10             	mov    0x10(%ebp),%eax
  80065c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	e8 02 00 00 00       	call   800674 <vprintfmt>
	va_end(ap);
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	57                   	push   %edi
  800678:	56                   	push   %esi
  800679:	53                   	push   %ebx
  80067a:	83 ec 3c             	sub    $0x3c,%esp
  80067d:	8b 75 08             	mov    0x8(%ebp),%esi
  800680:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800683:	8b 7d 10             	mov    0x10(%ebp),%edi
  800686:	eb 11                	jmp    800699 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800688:	85 c0                	test   %eax,%eax
  80068a:	0f 84 48 04 00 00    	je     800ad8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800699:	83 c7 01             	add    $0x1,%edi
  80069c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a0:	83 f8 25             	cmp    $0x25,%eax
  8006a3:	75 e3                	jne    800688 <vprintfmt+0x14>
  8006a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c3:	eb 1f                	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8006cc:	eb 16                	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8006d5:	eb 0d                	jmp    8006e4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8006d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8d 47 01             	lea    0x1(%edi),%eax
  8006e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ea:	0f b6 17             	movzbl (%edi),%edx
  8006ed:	0f b6 c2             	movzbl %dl,%eax
  8006f0:	83 ea 23             	sub    $0x23,%edx
  8006f3:	80 fa 55             	cmp    $0x55,%dl
  8006f6:	0f 87 bf 03 00 00    	ja     800abb <vprintfmt+0x447>
  8006fc:	0f b6 d2             	movzbl %dl,%edx
  8006ff:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  800706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800709:	ba 00 00 00 00       	mov    $0x0,%edx
  80070e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800711:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800714:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800718:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80071b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80071e:	83 f9 09             	cmp    $0x9,%ecx
  800721:	77 3c                	ja     80075f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800723:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800726:	eb e9                	jmp    800711 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 00                	mov    (%eax),%eax
  80072d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 40 04             	lea    0x4(%eax),%eax
  800736:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80073c:	eb 27                	jmp    800765 <vprintfmt+0xf1>
  80073e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800741:	85 d2                	test   %edx,%edx
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	0f 49 c2             	cmovns %edx,%eax
  80074b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800751:	eb 91                	jmp    8006e4 <vprintfmt+0x70>
  800753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800756:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80075d:	eb 85                	jmp    8006e4 <vprintfmt+0x70>
  80075f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800762:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800765:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800769:	0f 89 75 ff ff ff    	jns    8006e4 <vprintfmt+0x70>
  80076f:	e9 63 ff ff ff       	jmp    8006d7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800774:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80077a:	e9 65 ff ff ff       	jmp    8006e4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800782:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800794:	e9 00 ff ff ff       	jmp    800699 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80079c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	99                   	cltd   
  8007a3:	31 d0                	xor    %edx,%eax
  8007a5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007a7:	83 f8 0f             	cmp    $0xf,%eax
  8007aa:	7f 0b                	jg     8007b7 <vprintfmt+0x143>
  8007ac:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	75 20                	jne    8007d7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  8007b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bb:	c7 44 24 08 95 12 80 	movl   $0x801295,0x8(%esp)
  8007c2:	00 
  8007c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c7:	89 34 24             	mov    %esi,(%esp)
  8007ca:	e8 7d fe ff ff       	call   80064c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007d2:	e9 c2 fe ff ff       	jmp    800699 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8007d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007db:	c7 44 24 08 9e 12 80 	movl   $0x80129e,0x8(%esp)
  8007e2:	00 
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	89 34 24             	mov    %esi,(%esp)
  8007ea:	e8 5d fe ff ff       	call   80064c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f2:	e9 a2 fe ff ff       	jmp    800699 <vprintfmt+0x25>
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800800:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800803:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800807:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800809:	85 ff                	test   %edi,%edi
  80080b:	b8 8e 12 80 00       	mov    $0x80128e,%eax
  800810:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800813:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800817:	0f 84 92 00 00 00    	je     8008af <vprintfmt+0x23b>
  80081d:	85 c9                	test   %ecx,%ecx
  80081f:	0f 8e 98 00 00 00    	jle    8008bd <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800825:	89 54 24 04          	mov    %edx,0x4(%esp)
  800829:	89 3c 24             	mov    %edi,(%esp)
  80082c:	e8 47 03 00 00       	call   800b78 <strnlen>
  800831:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800834:	29 c1                	sub    %eax,%ecx
  800836:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800839:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80083d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800840:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800843:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800845:	eb 0f                	jmp    800856 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800847:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800853:	83 ef 01             	sub    $0x1,%edi
  800856:	85 ff                	test   %edi,%edi
  800858:	7f ed                	jg     800847 <vprintfmt+0x1d3>
  80085a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80085d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800860:	85 c9                	test   %ecx,%ecx
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
  800867:	0f 49 c1             	cmovns %ecx,%eax
  80086a:	29 c1                	sub    %eax,%ecx
  80086c:	89 75 08             	mov    %esi,0x8(%ebp)
  80086f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800872:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800875:	89 cb                	mov    %ecx,%ebx
  800877:	eb 50                	jmp    8008c9 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800879:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80087d:	74 1e                	je     80089d <vprintfmt+0x229>
  80087f:	0f be d2             	movsbl %dl,%edx
  800882:	83 ea 20             	sub    $0x20,%edx
  800885:	83 fa 5e             	cmp    $0x5e,%edx
  800888:	76 13                	jbe    80089d <vprintfmt+0x229>
					putch('?', putdat);
  80088a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800898:	ff 55 08             	call   *0x8(%ebp)
  80089b:	eb 0d                	jmp    8008aa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008aa:	83 eb 01             	sub    $0x1,%ebx
  8008ad:	eb 1a                	jmp    8008c9 <vprintfmt+0x255>
  8008af:	89 75 08             	mov    %esi,0x8(%ebp)
  8008b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008bb:	eb 0c                	jmp    8008c9 <vprintfmt+0x255>
  8008bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8008c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008c9:	83 c7 01             	add    $0x1,%edi
  8008cc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8008d0:	0f be c2             	movsbl %dl,%eax
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	74 25                	je     8008fc <vprintfmt+0x288>
  8008d7:	85 f6                	test   %esi,%esi
  8008d9:	78 9e                	js     800879 <vprintfmt+0x205>
  8008db:	83 ee 01             	sub    $0x1,%esi
  8008de:	79 99                	jns    800879 <vprintfmt+0x205>
  8008e0:	89 df                	mov    %ebx,%edi
  8008e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e8:	eb 1a                	jmp    800904 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008f5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008f7:	83 ef 01             	sub    $0x1,%edi
  8008fa:	eb 08                	jmp    800904 <vprintfmt+0x290>
  8008fc:	89 df                	mov    %ebx,%edi
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800904:	85 ff                	test   %edi,%edi
  800906:	7f e2                	jg     8008ea <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800908:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090b:	e9 89 fd ff ff       	jmp    800699 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800910:	83 f9 01             	cmp    $0x1,%ecx
  800913:	7e 19                	jle    80092e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 50 04             	mov    0x4(%eax),%edx
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800920:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 40 08             	lea    0x8(%eax),%eax
  800929:	89 45 14             	mov    %eax,0x14(%ebp)
  80092c:	eb 38                	jmp    800966 <vprintfmt+0x2f2>
	else if (lflag)
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	74 1b                	je     80094d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8b 00                	mov    (%eax),%eax
  800937:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80093a:	89 c1                	mov    %eax,%ecx
  80093c:	c1 f9 1f             	sar    $0x1f,%ecx
  80093f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 40 04             	lea    0x4(%eax),%eax
  800948:	89 45 14             	mov    %eax,0x14(%ebp)
  80094b:	eb 19                	jmp    800966 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8b 00                	mov    (%eax),%eax
  800952:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800955:	89 c1                	mov    %eax,%ecx
  800957:	c1 f9 1f             	sar    $0x1f,%ecx
  80095a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	8d 40 04             	lea    0x4(%eax),%eax
  800963:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800966:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800969:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80096c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800971:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800975:	0f 89 04 01 00 00    	jns    800a7f <vprintfmt+0x40b>
				putch('-', putdat);
  80097b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800986:	ff d6                	call   *%esi
				num = -(long long) num;
  800988:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80098b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80098e:	f7 da                	neg    %edx
  800990:	83 d1 00             	adc    $0x0,%ecx
  800993:	f7 d9                	neg    %ecx
  800995:	e9 e5 00 00 00       	jmp    800a7f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099a:	83 f9 01             	cmp    $0x1,%ecx
  80099d:	7e 10                	jle    8009af <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8b 10                	mov    (%eax),%edx
  8009a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8009a7:	8d 40 08             	lea    0x8(%eax),%eax
  8009aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ad:	eb 26                	jmp    8009d5 <vprintfmt+0x361>
	else if (lflag)
  8009af:	85 c9                	test   %ecx,%ecx
  8009b1:	74 12                	je     8009c5 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	8b 10                	mov    (%eax),%edx
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009bd:	8d 40 04             	lea    0x4(%eax),%eax
  8009c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c3:	eb 10                	jmp    8009d5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  8009c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c8:	8b 10                	mov    (%eax),%edx
  8009ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009cf:	8d 40 04             	lea    0x4(%eax),%eax
  8009d2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009d5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8009da:	e9 a0 00 00 00       	jmp    800a7f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8009df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009ea:	ff d6                	call   *%esi
			putch('X', putdat);
  8009ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009f7:	ff d6                	call   *%esi
			putch('X', putdat);
  8009f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a04:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a09:	e9 8b fc ff ff       	jmp    800699 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800a0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a12:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a26:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a28:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2b:	8b 10                	mov    (%eax),%edx
  800a2d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800a32:	8d 40 04             	lea    0x4(%eax),%eax
  800a35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a38:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800a3d:	eb 40                	jmp    800a7f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a3f:	83 f9 01             	cmp    $0x1,%ecx
  800a42:	7e 10                	jle    800a54 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8b 10                	mov    (%eax),%edx
  800a49:	8b 48 04             	mov    0x4(%eax),%ecx
  800a4c:	8d 40 08             	lea    0x8(%eax),%eax
  800a4f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a52:	eb 26                	jmp    800a7a <vprintfmt+0x406>
	else if (lflag)
  800a54:	85 c9                	test   %ecx,%ecx
  800a56:	74 12                	je     800a6a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8b 10                	mov    (%eax),%edx
  800a5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a62:	8d 40 04             	lea    0x4(%eax),%eax
  800a65:	89 45 14             	mov    %eax,0x14(%ebp)
  800a68:	eb 10                	jmp    800a7a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6d:	8b 10                	mov    (%eax),%edx
  800a6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a74:	8d 40 04             	lea    0x4(%eax),%eax
  800a77:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a7a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a7f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a92:	89 14 24             	mov    %edx,(%esp)
  800a95:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a99:	89 da                	mov    %ebx,%edx
  800a9b:	89 f0                	mov    %esi,%eax
  800a9d:	e8 9e fa ff ff       	call   800540 <printnum>
			break;
  800aa2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aa5:	e9 ef fb ff ff       	jmp    800699 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aae:	89 04 24             	mov    %eax,(%esp)
  800ab1:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ab6:	e9 de fb ff ff       	jmp    800699 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800abf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ac6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ac8:	eb 03                	jmp    800acd <vprintfmt+0x459>
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ad1:	75 f7                	jne    800aca <vprintfmt+0x456>
  800ad3:	e9 c1 fb ff ff       	jmp    800699 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800ad8:	83 c4 3c             	add    $0x3c,%esp
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	83 ec 28             	sub    $0x28,%esp
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800af3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800afd:	85 c0                	test   %eax,%eax
  800aff:	74 30                	je     800b31 <vsnprintf+0x51>
  800b01:	85 d2                	test   %edx,%edx
  800b03:	7e 2c                	jle    800b31 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b05:	8b 45 14             	mov    0x14(%ebp),%eax
  800b08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b13:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1a:	c7 04 24 2f 06 80 00 	movl   $0x80062f,(%esp)
  800b21:	e8 4e fb ff ff       	call   800674 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b29:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b2f:	eb 05                	jmp    800b36 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b3e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b45:	8b 45 10             	mov    0x10(%ebp),%eax
  800b48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	89 04 24             	mov    %eax,(%esp)
  800b59:	e8 82 ff ff ff       	call   800ae0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	eb 03                	jmp    800b70 <strlen+0x10>
		n++;
  800b6d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b74:	75 f7                	jne    800b6d <strlen+0xd>
		n++;
	return n;
}
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	eb 03                	jmp    800b8b <strnlen+0x13>
		n++;
  800b88:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8b:	39 d0                	cmp    %edx,%eax
  800b8d:	74 06                	je     800b95 <strnlen+0x1d>
  800b8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b93:	75 f3                	jne    800b88 <strnlen+0x10>
		n++;
	return n;
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba1:	89 c2                	mov    %eax,%edx
  800ba3:	83 c2 01             	add    $0x1,%edx
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bb0:	84 db                	test   %bl,%bl
  800bb2:	75 ef                	jne    800ba3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 08             	sub    $0x8,%esp
  800bbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc1:	89 1c 24             	mov    %ebx,(%esp)
  800bc4:	e8 97 ff ff ff       	call   800b60 <strlen>
	strcpy(dst + len, src);
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd0:	01 d8                	add    %ebx,%eax
  800bd2:	89 04 24             	mov    %eax,(%esp)
  800bd5:	e8 bd ff ff ff       	call   800b97 <strcpy>
	return dst;
}
  800bda:	89 d8                	mov    %ebx,%eax
  800bdc:	83 c4 08             	add    $0x8,%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf2:	89 f2                	mov    %esi,%edx
  800bf4:	eb 0f                	jmp    800c05 <strncpy+0x23>
		*dst++ = *src;
  800bf6:	83 c2 01             	add    $0x1,%edx
  800bf9:	0f b6 01             	movzbl (%ecx),%eax
  800bfc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bff:	80 39 01             	cmpb   $0x1,(%ecx)
  800c02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c05:	39 da                	cmp    %ebx,%edx
  800c07:	75 ed                	jne    800bf6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c09:	89 f0                	mov    %esi,%eax
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	8b 75 08             	mov    0x8(%ebp),%esi
  800c17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c1d:	89 f0                	mov    %esi,%eax
  800c1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c23:	85 c9                	test   %ecx,%ecx
  800c25:	75 0b                	jne    800c32 <strlcpy+0x23>
  800c27:	eb 1d                	jmp    800c46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c29:	83 c0 01             	add    $0x1,%eax
  800c2c:	83 c2 01             	add    $0x1,%edx
  800c2f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c32:	39 d8                	cmp    %ebx,%eax
  800c34:	74 0b                	je     800c41 <strlcpy+0x32>
  800c36:	0f b6 0a             	movzbl (%edx),%ecx
  800c39:	84 c9                	test   %cl,%cl
  800c3b:	75 ec                	jne    800c29 <strlcpy+0x1a>
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	eb 02                	jmp    800c43 <strlcpy+0x34>
  800c41:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c46:	29 f0                	sub    %esi,%eax
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c55:	eb 06                	jmp    800c5d <strcmp+0x11>
		p++, q++;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c5d:	0f b6 01             	movzbl (%ecx),%eax
  800c60:	84 c0                	test   %al,%al
  800c62:	74 04                	je     800c68 <strcmp+0x1c>
  800c64:	3a 02                	cmp    (%edx),%al
  800c66:	74 ef                	je     800c57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c68:	0f b6 c0             	movzbl %al,%eax
  800c6b:	0f b6 12             	movzbl (%edx),%edx
  800c6e:	29 d0                	sub    %edx,%eax
}
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	53                   	push   %ebx
  800c76:	8b 45 08             	mov    0x8(%ebp),%eax
  800c79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c81:	eb 06                	jmp    800c89 <strncmp+0x17>
		n--, p++, q++;
  800c83:	83 c0 01             	add    $0x1,%eax
  800c86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c89:	39 d8                	cmp    %ebx,%eax
  800c8b:	74 15                	je     800ca2 <strncmp+0x30>
  800c8d:	0f b6 08             	movzbl (%eax),%ecx
  800c90:	84 c9                	test   %cl,%cl
  800c92:	74 04                	je     800c98 <strncmp+0x26>
  800c94:	3a 0a                	cmp    (%edx),%cl
  800c96:	74 eb                	je     800c83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c98:	0f b6 00             	movzbl (%eax),%eax
  800c9b:	0f b6 12             	movzbl (%edx),%edx
  800c9e:	29 d0                	sub    %edx,%eax
  800ca0:	eb 05                	jmp    800ca7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb4:	eb 07                	jmp    800cbd <strchr+0x13>
		if (*s == c)
  800cb6:	38 ca                	cmp    %cl,%dl
  800cb8:	74 0f                	je     800cc9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	75 f2                	jne    800cb6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd5:	eb 07                	jmp    800cde <strfind+0x13>
		if (*s == c)
  800cd7:	38 ca                	cmp    %cl,%dl
  800cd9:	74 0a                	je     800ce5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cdb:	83 c0 01             	add    $0x1,%eax
  800cde:	0f b6 10             	movzbl (%eax),%edx
  800ce1:	84 d2                	test   %dl,%dl
  800ce3:	75 f2                	jne    800cd7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf3:	85 c9                	test   %ecx,%ecx
  800cf5:	74 36                	je     800d2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cf7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cfd:	75 28                	jne    800d27 <memset+0x40>
  800cff:	f6 c1 03             	test   $0x3,%cl
  800d02:	75 23                	jne    800d27 <memset+0x40>
		c &= 0xFF;
  800d04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d08:	89 d3                	mov    %edx,%ebx
  800d0a:	c1 e3 08             	shl    $0x8,%ebx
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	c1 e6 18             	shl    $0x18,%esi
  800d12:	89 d0                	mov    %edx,%eax
  800d14:	c1 e0 10             	shl    $0x10,%eax
  800d17:	09 f0                	or     %esi,%eax
  800d19:	09 c2                	or     %eax,%edx
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d1f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d22:	fc                   	cld    
  800d23:	f3 ab                	rep stos %eax,%es:(%edi)
  800d25:	eb 06                	jmp    800d2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2a:	fc                   	cld    
  800d2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2d:	89 f8                	mov    %edi,%eax
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d42:	39 c6                	cmp    %eax,%esi
  800d44:	73 35                	jae    800d7b <memmove+0x47>
  800d46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d49:	39 d0                	cmp    %edx,%eax
  800d4b:	73 2e                	jae    800d7b <memmove+0x47>
		s += n;
		d += n;
  800d4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d5a:	75 13                	jne    800d6f <memmove+0x3b>
  800d5c:	f6 c1 03             	test   $0x3,%cl
  800d5f:	75 0e                	jne    800d6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d61:	83 ef 04             	sub    $0x4,%edi
  800d64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d6a:	fd                   	std    
  800d6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6d:	eb 09                	jmp    800d78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d6f:	83 ef 01             	sub    $0x1,%edi
  800d72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d75:	fd                   	std    
  800d76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d78:	fc                   	cld    
  800d79:	eb 1d                	jmp    800d98 <memmove+0x64>
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7f:	f6 c2 03             	test   $0x3,%dl
  800d82:	75 0f                	jne    800d93 <memmove+0x5f>
  800d84:	f6 c1 03             	test   $0x3,%cl
  800d87:	75 0a                	jne    800d93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d89:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d8c:	89 c7                	mov    %eax,%edi
  800d8e:	fc                   	cld    
  800d8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d91:	eb 05                	jmp    800d98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d93:	89 c7                	mov    %eax,%edi
  800d95:	fc                   	cld    
  800d96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da2:	8b 45 10             	mov    0x10(%ebp),%eax
  800da5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	89 04 24             	mov    %eax,(%esp)
  800db6:	e8 79 ff ff ff       	call   800d34 <memmove>
}
  800dbb:	c9                   	leave  
  800dbc:	c3                   	ret    

00800dbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	89 d6                	mov    %edx,%esi
  800dca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcd:	eb 1a                	jmp    800de9 <memcmp+0x2c>
		if (*s1 != *s2)
  800dcf:	0f b6 02             	movzbl (%edx),%eax
  800dd2:	0f b6 19             	movzbl (%ecx),%ebx
  800dd5:	38 d8                	cmp    %bl,%al
  800dd7:	74 0a                	je     800de3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dd9:	0f b6 c0             	movzbl %al,%eax
  800ddc:	0f b6 db             	movzbl %bl,%ebx
  800ddf:	29 d8                	sub    %ebx,%eax
  800de1:	eb 0f                	jmp    800df2 <memcmp+0x35>
		s1++, s2++;
  800de3:	83 c2 01             	add    $0x1,%edx
  800de6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de9:	39 f2                	cmp    %esi,%edx
  800deb:	75 e2                	jne    800dcf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ded:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dff:	89 c2                	mov    %eax,%edx
  800e01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e04:	eb 07                	jmp    800e0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e06:	38 08                	cmp    %cl,(%eax)
  800e08:	74 07                	je     800e11 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e0a:	83 c0 01             	add    $0x1,%eax
  800e0d:	39 d0                	cmp    %edx,%eax
  800e0f:	72 f5                	jb     800e06 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1f:	eb 03                	jmp    800e24 <strtol+0x11>
		s++;
  800e21:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e24:	0f b6 0a             	movzbl (%edx),%ecx
  800e27:	80 f9 09             	cmp    $0x9,%cl
  800e2a:	74 f5                	je     800e21 <strtol+0xe>
  800e2c:	80 f9 20             	cmp    $0x20,%cl
  800e2f:	74 f0                	je     800e21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e31:	80 f9 2b             	cmp    $0x2b,%cl
  800e34:	75 0a                	jne    800e40 <strtol+0x2d>
		s++;
  800e36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e39:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3e:	eb 11                	jmp    800e51 <strtol+0x3e>
  800e40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e45:	80 f9 2d             	cmp    $0x2d,%cl
  800e48:	75 07                	jne    800e51 <strtol+0x3e>
		s++, neg = 1;
  800e4a:	8d 52 01             	lea    0x1(%edx),%edx
  800e4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e56:	75 15                	jne    800e6d <strtol+0x5a>
  800e58:	80 3a 30             	cmpb   $0x30,(%edx)
  800e5b:	75 10                	jne    800e6d <strtol+0x5a>
  800e5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e61:	75 0a                	jne    800e6d <strtol+0x5a>
		s += 2, base = 16;
  800e63:	83 c2 02             	add    $0x2,%edx
  800e66:	b8 10 00 00 00       	mov    $0x10,%eax
  800e6b:	eb 10                	jmp    800e7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	75 0c                	jne    800e7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e71:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e73:	80 3a 30             	cmpb   $0x30,(%edx)
  800e76:	75 05                	jne    800e7d <strtol+0x6a>
		s++, base = 8;
  800e78:	83 c2 01             	add    $0x1,%edx
  800e7b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e85:	0f b6 0a             	movzbl (%edx),%ecx
  800e88:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e8b:	89 f0                	mov    %esi,%eax
  800e8d:	3c 09                	cmp    $0x9,%al
  800e8f:	77 08                	ja     800e99 <strtol+0x86>
			dig = *s - '0';
  800e91:	0f be c9             	movsbl %cl,%ecx
  800e94:	83 e9 30             	sub    $0x30,%ecx
  800e97:	eb 20                	jmp    800eb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e99:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e9c:	89 f0                	mov    %esi,%eax
  800e9e:	3c 19                	cmp    $0x19,%al
  800ea0:	77 08                	ja     800eaa <strtol+0x97>
			dig = *s - 'a' + 10;
  800ea2:	0f be c9             	movsbl %cl,%ecx
  800ea5:	83 e9 57             	sub    $0x57,%ecx
  800ea8:	eb 0f                	jmp    800eb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800eaa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ead:	89 f0                	mov    %esi,%eax
  800eaf:	3c 19                	cmp    $0x19,%al
  800eb1:	77 16                	ja     800ec9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800eb3:	0f be c9             	movsbl %cl,%ecx
  800eb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ebc:	7d 0f                	jge    800ecd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800ebe:	83 c2 01             	add    $0x1,%edx
  800ec1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ec5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ec7:	eb bc                	jmp    800e85 <strtol+0x72>
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	eb 02                	jmp    800ecf <strtol+0xbc>
  800ecd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800ecf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed3:	74 05                	je     800eda <strtol+0xc7>
		*endptr = (char *) s;
  800ed5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800eda:	f7 d8                	neg    %eax
  800edc:	85 ff                	test   %edi,%edi
  800ede:	0f 44 c3             	cmove  %ebx,%eax
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eec:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ef3:	75 44                	jne    800f39 <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  800ef5:	a1 04 20 80 00       	mov    0x802004,%eax
  800efa:	8b 40 48             	mov    0x48(%eax),%eax
  800efd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f0c:	ee 
  800f0d:	89 04 24             	mov    %eax,(%esp)
  800f10:	e8 6d f2 ff ff       	call   800182 <sys_page_alloc>
		if( r < 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	79 20                	jns    800f39 <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  800f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1d:	c7 44 24 08 80 15 80 	movl   $0x801580,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 dc 15 80 00 	movl   $0x8015dc,(%esp)
  800f34:	e8 f0 f4 ff ff       	call   800429 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	a3 08 20 80 00       	mov    %eax,0x802008
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  800f41:	e8 fe f1 ff ff       	call   800144 <sys_getenvid>
  800f46:	c7 44 24 04 ea 03 80 	movl   $0x8003ea,0x4(%esp)
  800f4d:	00 
  800f4e:	89 04 24             	mov    %eax,(%esp)
  800f51:	e8 cc f3 ff ff       	call   800322 <sys_env_set_pgfault_upcall>
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 20                	jns    800f7a <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  800f5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5e:	c7 44 24 08 b0 15 80 	movl   $0x8015b0,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 dc 15 80 00 	movl   $0x8015dc,(%esp)
  800f75:	e8 af f4 ff ff       	call   800429 <_panic>


}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__udivdi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f96:	85 c0                	test   %eax,%eax
  800f98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f9c:	89 ea                	mov    %ebp,%edx
  800f9e:	89 0c 24             	mov    %ecx,(%esp)
  800fa1:	75 2d                	jne    800fd0 <__udivdi3+0x50>
  800fa3:	39 e9                	cmp    %ebp,%ecx
  800fa5:	77 61                	ja     801008 <__udivdi3+0x88>
  800fa7:	85 c9                	test   %ecx,%ecx
  800fa9:	89 ce                	mov    %ecx,%esi
  800fab:	75 0b                	jne    800fb8 <__udivdi3+0x38>
  800fad:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb2:	31 d2                	xor    %edx,%edx
  800fb4:	f7 f1                	div    %ecx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	89 e8                	mov    %ebp,%eax
  800fbc:	f7 f6                	div    %esi
  800fbe:	89 c5                	mov    %eax,%ebp
  800fc0:	89 f8                	mov    %edi,%eax
  800fc2:	f7 f6                	div    %esi
  800fc4:	89 ea                	mov    %ebp,%edx
  800fc6:	83 c4 0c             	add    $0xc,%esp
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	39 e8                	cmp    %ebp,%eax
  800fd2:	77 24                	ja     800ff8 <__udivdi3+0x78>
  800fd4:	0f bd e8             	bsr    %eax,%ebp
  800fd7:	83 f5 1f             	xor    $0x1f,%ebp
  800fda:	75 3c                	jne    801018 <__udivdi3+0x98>
  800fdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fe0:	39 34 24             	cmp    %esi,(%esp)
  800fe3:	0f 86 9f 00 00 00    	jbe    801088 <__udivdi3+0x108>
  800fe9:	39 d0                	cmp    %edx,%eax
  800feb:	0f 82 97 00 00 00    	jb     801088 <__udivdi3+0x108>
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	31 c0                	xor    %eax,%eax
  800ffc:	83 c4 0c             	add    $0xc,%esp
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	89 f8                	mov    %edi,%eax
  80100a:	f7 f1                	div    %ecx
  80100c:	31 d2                	xor    %edx,%edx
  80100e:	83 c4 0c             	add    $0xc,%esp
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
  801015:	8d 76 00             	lea    0x0(%esi),%esi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	8b 3c 24             	mov    (%esp),%edi
  80101d:	d3 e0                	shl    %cl,%eax
  80101f:	89 c6                	mov    %eax,%esi
  801021:	b8 20 00 00 00       	mov    $0x20,%eax
  801026:	29 e8                	sub    %ebp,%eax
  801028:	89 c1                	mov    %eax,%ecx
  80102a:	d3 ef                	shr    %cl,%edi
  80102c:	89 e9                	mov    %ebp,%ecx
  80102e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801032:	8b 3c 24             	mov    (%esp),%edi
  801035:	09 74 24 08          	or     %esi,0x8(%esp)
  801039:	89 d6                	mov    %edx,%esi
  80103b:	d3 e7                	shl    %cl,%edi
  80103d:	89 c1                	mov    %eax,%ecx
  80103f:	89 3c 24             	mov    %edi,(%esp)
  801042:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801046:	d3 ee                	shr    %cl,%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	d3 e2                	shl    %cl,%edx
  80104c:	89 c1                	mov    %eax,%ecx
  80104e:	d3 ef                	shr    %cl,%edi
  801050:	09 d7                	or     %edx,%edi
  801052:	89 f2                	mov    %esi,%edx
  801054:	89 f8                	mov    %edi,%eax
  801056:	f7 74 24 08          	divl   0x8(%esp)
  80105a:	89 d6                	mov    %edx,%esi
  80105c:	89 c7                	mov    %eax,%edi
  80105e:	f7 24 24             	mull   (%esp)
  801061:	39 d6                	cmp    %edx,%esi
  801063:	89 14 24             	mov    %edx,(%esp)
  801066:	72 30                	jb     801098 <__udivdi3+0x118>
  801068:	8b 54 24 04          	mov    0x4(%esp),%edx
  80106c:	89 e9                	mov    %ebp,%ecx
  80106e:	d3 e2                	shl    %cl,%edx
  801070:	39 c2                	cmp    %eax,%edx
  801072:	73 05                	jae    801079 <__udivdi3+0xf9>
  801074:	3b 34 24             	cmp    (%esp),%esi
  801077:	74 1f                	je     801098 <__udivdi3+0x118>
  801079:	89 f8                	mov    %edi,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	e9 7a ff ff ff       	jmp    800ffc <__udivdi3+0x7c>
  801082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801088:	31 d2                	xor    %edx,%edx
  80108a:	b8 01 00 00 00       	mov    $0x1,%eax
  80108f:	e9 68 ff ff ff       	jmp    800ffc <__udivdi3+0x7c>
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	8d 47 ff             	lea    -0x1(%edi),%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	83 c4 0c             	add    $0xc,%esp
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    
  8010a4:	66 90                	xchg   %ax,%ax
  8010a6:	66 90                	xchg   %ax,%ax
  8010a8:	66 90                	xchg   %ax,%ax
  8010aa:	66 90                	xchg   %ax,%ax
  8010ac:	66 90                	xchg   %ax,%ax
  8010ae:	66 90                	xchg   %ax,%ax

008010b0 <__umoddi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	83 ec 14             	sub    $0x14,%esp
  8010b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8010ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8010be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010d0:	89 34 24             	mov    %esi,(%esp)
  8010d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010df:	75 17                	jne    8010f8 <__umoddi3+0x48>
  8010e1:	39 fe                	cmp    %edi,%esi
  8010e3:	76 4b                	jbe    801130 <__umoddi3+0x80>
  8010e5:	89 c8                	mov    %ecx,%eax
  8010e7:	89 fa                	mov    %edi,%edx
  8010e9:	f7 f6                	div    %esi
  8010eb:	89 d0                	mov    %edx,%eax
  8010ed:	31 d2                	xor    %edx,%edx
  8010ef:	83 c4 14             	add    $0x14,%esp
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	39 f8                	cmp    %edi,%eax
  8010fa:	77 54                	ja     801150 <__umoddi3+0xa0>
  8010fc:	0f bd e8             	bsr    %eax,%ebp
  8010ff:	83 f5 1f             	xor    $0x1f,%ebp
  801102:	75 5c                	jne    801160 <__umoddi3+0xb0>
  801104:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801108:	39 3c 24             	cmp    %edi,(%esp)
  80110b:	0f 87 e7 00 00 00    	ja     8011f8 <__umoddi3+0x148>
  801111:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801115:	29 f1                	sub    %esi,%ecx
  801117:	19 c7                	sbb    %eax,%edi
  801119:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801121:	8b 44 24 08          	mov    0x8(%esp),%eax
  801125:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801129:	83 c4 14             	add    $0x14,%esp
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    
  801130:	85 f6                	test   %esi,%esi
  801132:	89 f5                	mov    %esi,%ebp
  801134:	75 0b                	jne    801141 <__umoddi3+0x91>
  801136:	b8 01 00 00 00       	mov    $0x1,%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	f7 f6                	div    %esi
  80113f:	89 c5                	mov    %eax,%ebp
  801141:	8b 44 24 04          	mov    0x4(%esp),%eax
  801145:	31 d2                	xor    %edx,%edx
  801147:	f7 f5                	div    %ebp
  801149:	89 c8                	mov    %ecx,%eax
  80114b:	f7 f5                	div    %ebp
  80114d:	eb 9c                	jmp    8010eb <__umoddi3+0x3b>
  80114f:	90                   	nop
  801150:	89 c8                	mov    %ecx,%eax
  801152:	89 fa                	mov    %edi,%edx
  801154:	83 c4 14             	add    $0x14,%esp
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    
  80115b:	90                   	nop
  80115c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801160:	8b 04 24             	mov    (%esp),%eax
  801163:	be 20 00 00 00       	mov    $0x20,%esi
  801168:	89 e9                	mov    %ebp,%ecx
  80116a:	29 ee                	sub    %ebp,%esi
  80116c:	d3 e2                	shl    %cl,%edx
  80116e:	89 f1                	mov    %esi,%ecx
  801170:	d3 e8                	shr    %cl,%eax
  801172:	89 e9                	mov    %ebp,%ecx
  801174:	89 44 24 04          	mov    %eax,0x4(%esp)
  801178:	8b 04 24             	mov    (%esp),%eax
  80117b:	09 54 24 04          	or     %edx,0x4(%esp)
  80117f:	89 fa                	mov    %edi,%edx
  801181:	d3 e0                	shl    %cl,%eax
  801183:	89 f1                	mov    %esi,%ecx
  801185:	89 44 24 08          	mov    %eax,0x8(%esp)
  801189:	8b 44 24 10          	mov    0x10(%esp),%eax
  80118d:	d3 ea                	shr    %cl,%edx
  80118f:	89 e9                	mov    %ebp,%ecx
  801191:	d3 e7                	shl    %cl,%edi
  801193:	89 f1                	mov    %esi,%ecx
  801195:	d3 e8                	shr    %cl,%eax
  801197:	89 e9                	mov    %ebp,%ecx
  801199:	09 f8                	or     %edi,%eax
  80119b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80119f:	f7 74 24 04          	divl   0x4(%esp)
  8011a3:	d3 e7                	shl    %cl,%edi
  8011a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a9:	89 d7                	mov    %edx,%edi
  8011ab:	f7 64 24 08          	mull   0x8(%esp)
  8011af:	39 d7                	cmp    %edx,%edi
  8011b1:	89 c1                	mov    %eax,%ecx
  8011b3:	89 14 24             	mov    %edx,(%esp)
  8011b6:	72 2c                	jb     8011e4 <__umoddi3+0x134>
  8011b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8011bc:	72 22                	jb     8011e0 <__umoddi3+0x130>
  8011be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8011c2:	29 c8                	sub    %ecx,%eax
  8011c4:	19 d7                	sbb    %edx,%edi
  8011c6:	89 e9                	mov    %ebp,%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 e8                	shr    %cl,%eax
  8011cc:	89 f1                	mov    %esi,%ecx
  8011ce:	d3 e2                	shl    %cl,%edx
  8011d0:	89 e9                	mov    %ebp,%ecx
  8011d2:	d3 ef                	shr    %cl,%edi
  8011d4:	09 d0                	or     %edx,%eax
  8011d6:	89 fa                	mov    %edi,%edx
  8011d8:	83 c4 14             	add    $0x14,%esp
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    
  8011df:	90                   	nop
  8011e0:	39 d7                	cmp    %edx,%edi
  8011e2:	75 da                	jne    8011be <__umoddi3+0x10e>
  8011e4:	8b 14 24             	mov    (%esp),%edx
  8011e7:	89 c1                	mov    %eax,%ecx
  8011e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8011ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8011f1:	eb cb                	jmp    8011be <__umoddi3+0x10e>
  8011f3:	90                   	nop
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8011fc:	0f 82 0f ff ff ff    	jb     801111 <__umoddi3+0x61>
  801202:	e9 1a ff ff ff       	jmp    801121 <__umoddi3+0x71>
