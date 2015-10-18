
obj/user/faultevilhandler：     文件格式 elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 49 01 00 00       	call   80019e <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800055:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005c:	f0 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 82 02 00 00       	call   8002eb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	83 ec 10             	sub    $0x10,%esp
  80007d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800080:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800083:	e8 d8 00 00 00       	call   800160 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800090:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 db                	test   %ebx,%ebx
  80009c:	7e 07                	jle    8000a5 <libmain+0x30>
		binaryname = argv[0];
  80009e:	8b 06                	mov    (%esi),%eax
  8000a0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 07 00 00 00       	call   8000bd <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 3f 00 00 00       	call   80010e <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000df:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e2:	89 c3                	mov    %eax,%ebx
  8000e4:	89 c7                	mov    %eax,%edi
  8000e6:	89 c6                	mov    %eax,%esi
  8000e8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ff:	89 d1                	mov    %edx,%ecx
  800101:	89 d3                	mov    %edx,%ebx
  800103:	89 d7                	mov    %edx,%edi
  800105:	89 d6                	mov    %edx,%esi
  800107:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	57                   	push   %edi
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
  800114:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800117:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011c:	b8 03 00 00 00       	mov    $0x3,%eax
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 cb                	mov    %ecx,%ebx
  800126:	89 cf                	mov    %ecx,%edi
  800128:	89 ce                	mov    %ecx,%esi
  80012a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012c:	85 c0                	test   %eax,%eax
  80012e:	7e 28                	jle    800158 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013b:	00 
  80013c:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800153:	e8 5b 02 00 00       	call   8003b3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800158:	83 c4 2c             	add    $0x2c,%esp
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800166:	ba 00 00 00 00       	mov    $0x0,%edx
  80016b:	b8 02 00 00 00       	mov    $0x2,%eax
  800170:	89 d1                	mov    %edx,%ecx
  800172:	89 d3                	mov    %edx,%ebx
  800174:	89 d7                	mov    %edx,%edi
  800176:	89 d6                	mov    %edx,%esi
  800178:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5f                   	pop    %edi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_yield>:

void
sys_yield(void)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800185:	ba 00 00 00 00       	mov    $0x0,%edx
  80018a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018f:	89 d1                	mov    %edx,%ecx
  800191:	89 d3                	mov    %edx,%ebx
  800193:	89 d7                	mov    %edx,%edi
  800195:	89 d6                	mov    %edx,%esi
  800197:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	be 00 00 00 00       	mov    $0x0,%esi
  8001ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	89 f7                	mov    %esi,%edi
  8001bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7e 28                	jle    8001ea <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001cd:	00 
  8001ce:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001d5:	00 
  8001d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001e5:	e8 c9 01 00 00       	call   8003b3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ea:	83 c4 2c             	add    $0x2c,%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fb:	b8 05 00 00 00       	mov    $0x5,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800209:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020c:	8b 75 18             	mov    0x18(%ebp),%esi
  80020f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800211:	85 c0                	test   %eax,%eax
  800213:	7e 28                	jle    80023d <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800215:	89 44 24 10          	mov    %eax,0x10(%esp)
  800219:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800220:	00 
  800221:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800228:	00 
  800229:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800230:	00 
  800231:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800238:	e8 76 01 00 00       	call   8003b3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80023d:	83 c4 2c             	add    $0x2c,%esp
  800240:	5b                   	pop    %ebx
  800241:	5e                   	pop    %esi
  800242:	5f                   	pop    %edi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    

00800245 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	b8 06 00 00 00       	mov    $0x6,%eax
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	89 df                	mov    %ebx,%edi
  800260:	89 de                	mov    %ebx,%esi
  800262:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7e 28                	jle    800290 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800268:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800273:	00 
  800274:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80027b:	00 
  80027c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800283:	00 
  800284:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80028b:	e8 23 01 00 00       	call   8003b3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800290:	83 c4 2c             	add    $0x2c,%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	89 df                	mov    %ebx,%edi
  8002b3:	89 de                	mov    %ebx,%esi
  8002b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	7e 28                	jle    8002e3 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002bf:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c6:	00 
  8002c7:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8002ce:	00 
  8002cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d6:	00 
  8002d7:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002de:	e8 d0 00 00 00       	call   8003b3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e3:	83 c4 2c             	add    $0x2c,%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	89 df                	mov    %ebx,%edi
  800306:	89 de                	mov    %ebx,%esi
  800308:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030a:	85 c0                	test   %eax,%eax
  80030c:	7e 28                	jle    800336 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80030e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800312:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800319:	00 
  80031a:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800321:	00 
  800322:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800329:	00 
  80032a:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800331:	e8 7d 00 00 00       	call   8003b3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800336:	83 c4 2c             	add    $0x2c,%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	be 00 00 00 00       	mov    $0x0,%esi
  800349:	b8 0b 00 00 00       	mov    $0xb,%eax
  80034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800357:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
  800367:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
  800377:	89 cb                	mov    %ecx,%ebx
  800379:	89 cf                	mov    %ecx,%edi
  80037b:	89 ce                	mov    %ecx,%esi
  80037d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037f:	85 c0                	test   %eax,%eax
  800381:	7e 28                	jle    8003ab <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800383:	89 44 24 10          	mov    %eax,0x10(%esp)
  800387:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80038e:	00 
  80038f:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800396:	00 
  800397:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80039e:	00 
  80039f:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8003a6:	e8 08 00 00 00       	call   8003b3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ab:	83 c4 2c             	add    $0x2c,%esp
  8003ae:	5b                   	pop    %ebx
  8003af:	5e                   	pop    %esi
  8003b0:	5f                   	pop    %edi
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003be:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003c4:	e8 97 fd ff ff       	call   800160 <sys_getenvid>
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8003e6:	e8 c1 00 00 00       	call   8004ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	89 04 24             	mov    %eax,(%esp)
  8003f5:	e8 51 00 00 00       	call   80044b <vcprintf>
	cprintf("\n");
  8003fa:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  800401:	e8 a6 00 00 00       	call   8004ac <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800406:	cc                   	int3   
  800407:	eb fd                	jmp    800406 <_panic+0x53>

00800409 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	53                   	push   %ebx
  80040d:	83 ec 14             	sub    $0x14,%esp
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800413:	8b 13                	mov    (%ebx),%edx
  800415:	8d 42 01             	lea    0x1(%edx),%eax
  800418:	89 03                	mov    %eax,(%ebx)
  80041a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800421:	3d ff 00 00 00       	cmp    $0xff,%eax
  800426:	75 19                	jne    800441 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800428:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80042f:	00 
  800430:	8d 43 08             	lea    0x8(%ebx),%eax
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	e8 96 fc ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  80043b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800441:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800445:	83 c4 14             	add    $0x14,%esp
  800448:	5b                   	pop    %ebx
  800449:	5d                   	pop    %ebp
  80044a:	c3                   	ret    

0080044b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800454:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80045b:	00 00 00 
	b.cnt = 0;
  80045e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800465:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800468:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 09 04 80 00 	movl   $0x800409,(%esp)
  800487:	e8 78 01 00 00       	call   800604 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80048c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800492:	89 44 24 04          	mov    %eax,0x4(%esp)
  800496:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 2d fc ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  8004a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004aa:	c9                   	leave  
  8004ab:	c3                   	ret    

008004ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	e8 87 ff ff ff       	call   80044b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004c4:	c9                   	leave  
  8004c5:	c3                   	ret    
  8004c6:	66 90                	xchg   %ax,%ax
  8004c8:	66 90                	xchg   %ax,%ax
  8004ca:	66 90                	xchg   %ax,%ax
  8004cc:	66 90                	xchg   %ax,%ax
  8004ce:	66 90                	xchg   %ax,%ax

008004d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	57                   	push   %edi
  8004d4:	56                   	push   %esi
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 3c             	sub    $0x3c,%esp
  8004d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004dc:	89 d7                	mov    %edx,%edi
  8004de:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 c3                	mov    %eax,%ebx
  8004e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fd:	39 d9                	cmp    %ebx,%ecx
  8004ff:	72 05                	jb     800506 <printnum+0x36>
  800501:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800504:	77 69                	ja     80056f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800506:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800509:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800514:	89 44 24 08          	mov    %eax,0x8(%esp)
  800518:	8b 44 24 08          	mov    0x8(%esp),%eax
  80051c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800520:	89 c3                	mov    %eax,%ebx
  800522:	89 d6                	mov    %edx,%esi
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80052e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	e8 3c 09 00 00       	call   800e80 <__udivdi3>
  800544:	89 d9                	mov    %ebx,%ecx
  800546:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80054a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	89 54 24 04          	mov    %edx,0x4(%esp)
  800555:	89 fa                	mov    %edi,%edx
  800557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055a:	e8 71 ff ff ff       	call   8004d0 <printnum>
  80055f:	eb 1b                	jmp    80057c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800565:	8b 45 18             	mov    0x18(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff d3                	call   *%ebx
  80056d:	eb 03                	jmp    800572 <printnum+0xa2>
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800572:	83 ee 01             	sub    $0x1,%esi
  800575:	85 f6                	test   %esi,%esi
  800577:	7f e8                	jg     800561 <printnum+0x91>
  800579:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80057c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800580:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800584:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800587:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800592:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800595:	89 04 24             	mov    %eax,(%esp)
  800598:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80059b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059f:	e8 0c 0a 00 00       	call   800fb0 <__umoddi3>
  8005a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a8:	0f be 80 7e 11 80 00 	movsbl 0x80117e(%eax),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	ff d0                	call   *%eax
}
  8005b7:	83 c4 3c             	add    $0x3c,%esp
  8005ba:	5b                   	pop    %ebx
  8005bb:	5e                   	pop    %esi
  8005bc:	5f                   	pop    %edi
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ce:	73 0a                	jae    8005da <sprintputch+0x1b>
		*b->buf++ = ch;
  8005d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005d3:	89 08                	mov    %ecx,(%eax)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	88 02                	mov    %al,(%edx)
}
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    

008005dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 02 00 00 00       	call   800604 <vprintfmt>
	va_end(ap);
}
  800602:	c9                   	leave  
  800603:	c3                   	ret    

00800604 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	57                   	push   %edi
  800608:	56                   	push   %esi
  800609:	53                   	push   %ebx
  80060a:	83 ec 3c             	sub    $0x3c,%esp
  80060d:	8b 75 08             	mov    0x8(%ebp),%esi
  800610:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800613:	8b 7d 10             	mov    0x10(%ebp),%edi
  800616:	eb 11                	jmp    800629 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800618:	85 c0                	test   %eax,%eax
  80061a:	0f 84 48 04 00 00    	je     800a68 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800630:	83 f8 25             	cmp    $0x25,%eax
  800633:	75 e3                	jne    800618 <vprintfmt+0x14>
  800635:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800639:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800640:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800647:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	eb 1f                	jmp    800674 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800658:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800661:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800667:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8d 47 01             	lea    0x1(%edi),%eax
  800677:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80067a:	0f b6 17             	movzbl (%edi),%edx
  80067d:	0f b6 c2             	movzbl %dl,%eax
  800680:	83 ea 23             	sub    $0x23,%edx
  800683:	80 fa 55             	cmp    $0x55,%dl
  800686:	0f 87 bf 03 00 00    	ja     800a4b <vprintfmt+0x447>
  80068c:	0f b6 d2             	movzbl %dl,%edx
  80068f:	ff 24 95 40 12 80 00 	jmp    *0x801240(,%edx,4)
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
  80069e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8006ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006ae:	83 f9 09             	cmp    $0x9,%ecx
  8006b1:	77 3c                	ja     8006ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b6:	eb e9                	jmp    8006a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006cc:	eb 27                	jmp    8006f5 <vprintfmt+0xf1>
  8006ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	0f 49 c2             	cmovns %edx,%eax
  8006db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e1:	eb 91                	jmp    800674 <vprintfmt+0x70>
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006ed:	eb 85                	jmp    800674 <vprintfmt+0x70>
  8006ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f9:	0f 89 75 ff ff ff    	jns    800674 <vprintfmt+0x70>
  8006ff:	e9 63 ff ff ff       	jmp    800667 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800704:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80070a:	e9 65 ff ff ff       	jmp    800674 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800712:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800724:	e9 00 ff ff ff       	jmp    800629 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800730:	8b 00                	mov    (%eax),%eax
  800732:	99                   	cltd   
  800733:	31 d0                	xor    %edx,%eax
  800735:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800737:	83 f8 09             	cmp    $0x9,%eax
  80073a:	7f 0b                	jg     800747 <vprintfmt+0x143>
  80073c:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	75 20                	jne    800767 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800747:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074b:	c7 44 24 08 96 11 80 	movl   $0x801196,0x8(%esp)
  800752:	00 
  800753:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800757:	89 34 24             	mov    %esi,(%esp)
  80075a:	e8 7d fe ff ff       	call   8005dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800762:	e9 c2 fe ff ff       	jmp    800629 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800767:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076b:	c7 44 24 08 9f 11 80 	movl   $0x80119f,0x8(%esp)
  800772:	00 
  800773:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800777:	89 34 24             	mov    %esi,(%esp)
  80077a:	e8 5d fe ff ff       	call   8005dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800782:	e9 a2 fe ff ff       	jmp    800629 <vprintfmt+0x25>
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80078d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800790:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800793:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800797:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800799:	85 ff                	test   %edi,%edi
  80079b:	b8 8f 11 80 00       	mov    $0x80118f,%eax
  8007a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a7:	0f 84 92 00 00 00    	je     80083f <vprintfmt+0x23b>
  8007ad:	85 c9                	test   %ecx,%ecx
  8007af:	0f 8e 98 00 00 00    	jle    80084d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	e8 47 03 00 00       	call   800b08 <strnlen>
  8007c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c4:	29 c1                	sub    %eax,%ecx
  8007c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d5:	eb 0f                	jmp    8007e6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007de:	89 04 24             	mov    %eax,(%esp)
  8007e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e3:	83 ef 01             	sub    $0x1,%edi
  8007e6:	85 ff                	test   %edi,%edi
  8007e8:	7f ed                	jg     8007d7 <vprintfmt+0x1d3>
  8007ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	0f 49 c1             	cmovns %ecx,%eax
  8007fa:	29 c1                	sub    %eax,%ecx
  8007fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800802:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800805:	89 cb                	mov    %ecx,%ebx
  800807:	eb 50                	jmp    800859 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800809:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80080d:	74 1e                	je     80082d <vprintfmt+0x229>
  80080f:	0f be d2             	movsbl %dl,%edx
  800812:	83 ea 20             	sub    $0x20,%edx
  800815:	83 fa 5e             	cmp    $0x5e,%edx
  800818:	76 13                	jbe    80082d <vprintfmt+0x229>
					putch('?', putdat);
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800828:	ff 55 08             	call   *0x8(%ebp)
  80082b:	eb 0d                	jmp    80083a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083a:	83 eb 01             	sub    $0x1,%ebx
  80083d:	eb 1a                	jmp    800859 <vprintfmt+0x255>
  80083f:	89 75 08             	mov    %esi,0x8(%ebp)
  800842:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800845:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800848:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084b:	eb 0c                	jmp    800859 <vprintfmt+0x255>
  80084d:	89 75 08             	mov    %esi,0x8(%ebp)
  800850:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800853:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800856:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800859:	83 c7 01             	add    $0x1,%edi
  80085c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800860:	0f be c2             	movsbl %dl,%eax
  800863:	85 c0                	test   %eax,%eax
  800865:	74 25                	je     80088c <vprintfmt+0x288>
  800867:	85 f6                	test   %esi,%esi
  800869:	78 9e                	js     800809 <vprintfmt+0x205>
  80086b:	83 ee 01             	sub    $0x1,%esi
  80086e:	79 99                	jns    800809 <vprintfmt+0x205>
  800870:	89 df                	mov    %ebx,%edi
  800872:	8b 75 08             	mov    0x8(%ebp),%esi
  800875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800878:	eb 1a                	jmp    800894 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800885:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800887:	83 ef 01             	sub    $0x1,%edi
  80088a:	eb 08                	jmp    800894 <vprintfmt+0x290>
  80088c:	89 df                	mov    %ebx,%edi
  80088e:	8b 75 08             	mov    0x8(%ebp),%esi
  800891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800894:	85 ff                	test   %edi,%edi
  800896:	7f e2                	jg     80087a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089b:	e9 89 fd ff ff       	jmp    800629 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008a0:	83 f9 01             	cmp    $0x1,%ecx
  8008a3:	7e 19                	jle    8008be <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8b 50 04             	mov    0x4(%eax),%edx
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 40 08             	lea    0x8(%eax),%eax
  8008b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bc:	eb 38                	jmp    8008f6 <vprintfmt+0x2f2>
	else if (lflag)
  8008be:	85 c9                	test   %ecx,%ecx
  8008c0:	74 1b                	je     8008dd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8b 00                	mov    (%eax),%eax
  8008c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ca:	89 c1                	mov    %eax,%ecx
  8008cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008db:	eb 19                	jmp    8008f6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e0:	8b 00                	mov    (%eax),%eax
  8008e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e5:	89 c1                	mov    %eax,%ecx
  8008e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8d 40 04             	lea    0x4(%eax),%eax
  8008f3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008fc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800901:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800905:	0f 89 04 01 00 00    	jns    800a0f <vprintfmt+0x40b>
				putch('-', putdat);
  80090b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800916:	ff d6                	call   *%esi
				num = -(long long) num;
  800918:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80091b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80091e:	f7 da                	neg    %edx
  800920:	83 d1 00             	adc    $0x0,%ecx
  800923:	f7 d9                	neg    %ecx
  800925:	e9 e5 00 00 00       	jmp    800a0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80092a:	83 f9 01             	cmp    $0x1,%ecx
  80092d:	7e 10                	jle    80093f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8b 10                	mov    (%eax),%edx
  800934:	8b 48 04             	mov    0x4(%eax),%ecx
  800937:	8d 40 08             	lea    0x8(%eax),%eax
  80093a:	89 45 14             	mov    %eax,0x14(%ebp)
  80093d:	eb 26                	jmp    800965 <vprintfmt+0x361>
	else if (lflag)
  80093f:	85 c9                	test   %ecx,%ecx
  800941:	74 12                	je     800955 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	8b 10                	mov    (%eax),%edx
  800948:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094d:	8d 40 04             	lea    0x4(%eax),%eax
  800950:	89 45 14             	mov    %eax,0x14(%ebp)
  800953:	eb 10                	jmp    800965 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 10                	mov    (%eax),%edx
  80095a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095f:	8d 40 04             	lea    0x4(%eax),%eax
  800962:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800965:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80096a:	e9 a0 00 00 00       	jmp    800a0f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80096f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800973:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80097a:	ff d6                	call   *%esi
			putch('X', putdat);
  80097c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800980:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800987:	ff d6                	call   *%esi
			putch('X', putdat);
  800989:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800994:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800999:	e9 8b fc ff ff       	jmp    800629 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80099e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009af:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8b 10                	mov    (%eax),%edx
  8009bd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009c2:	8d 40 04             	lea    0x4(%eax),%eax
  8009c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009c8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009cd:	eb 40                	jmp    800a0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009cf:	83 f9 01             	cmp    $0x1,%ecx
  8009d2:	7e 10                	jle    8009e4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	8b 10                	mov    (%eax),%edx
  8009d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009dc:	8d 40 08             	lea    0x8(%eax),%eax
  8009df:	89 45 14             	mov    %eax,0x14(%ebp)
  8009e2:	eb 26                	jmp    800a0a <vprintfmt+0x406>
	else if (lflag)
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 12                	je     8009fa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8b 10                	mov    (%eax),%edx
  8009ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009f2:	8d 40 04             	lea    0x4(%eax),%eax
  8009f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009f8:	eb 10                	jmp    800a0a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fd:	8b 10                	mov    (%eax),%edx
  8009ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a04:	8d 40 04             	lea    0x4(%eax),%eax
  800a07:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a0a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a0f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a22:	89 14 24             	mov    %edx,(%esp)
  800a25:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a29:	89 da                	mov    %ebx,%edx
  800a2b:	89 f0                	mov    %esi,%eax
  800a2d:	e8 9e fa ff ff       	call   8004d0 <printnum>
			break;
  800a32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a35:	e9 ef fb ff ff       	jmp    800629 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a46:	e9 de fb ff ff       	jmp    800629 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a56:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a58:	eb 03                	jmp    800a5d <vprintfmt+0x459>
  800a5a:	83 ef 01             	sub    $0x1,%edi
  800a5d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a61:	75 f7                	jne    800a5a <vprintfmt+0x456>
  800a63:	e9 c1 fb ff ff       	jmp    800629 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a68:	83 c4 3c             	add    $0x3c,%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	83 ec 28             	sub    $0x28,%esp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a7f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a83:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	74 30                	je     800ac1 <vsnprintf+0x51>
  800a91:	85 d2                	test   %edx,%edx
  800a93:	7e 2c                	jle    800ac1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaa:	c7 04 24 bf 05 80 00 	movl   $0x8005bf,(%esp)
  800ab1:	e8 4e fb ff ff       	call   800604 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800abf:	eb 05                	jmp    800ac6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ac1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ace:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	e8 82 ff ff ff       	call   800a70 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

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
  800b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
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
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b3d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b40:	84 db                	test   %bl,%bl
  800b42:	75 ef                	jne    800b33 <strcpy+0xc>
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
  800b77:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b82:	89 f2                	mov    %esi,%edx
  800b84:	eb 0f                	jmp    800b95 <strncpy+0x23>
		*dst++ = *src;
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	0f b6 01             	movzbl (%ecx),%eax
  800b8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b92:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b95:	39 da                	cmp    %ebx,%edx
  800b97:	75 ed                	jne    800b86 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b99:	89 f0                	mov    %esi,%eax
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bad:	89 f0                	mov    %esi,%eax
  800baf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bb3:	85 c9                	test   %ecx,%ecx
  800bb5:	75 0b                	jne    800bc2 <strlcpy+0x23>
  800bb7:	eb 1d                	jmp    800bd6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bb9:	83 c0 01             	add    $0x1,%eax
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bc2:	39 d8                	cmp    %ebx,%eax
  800bc4:	74 0b                	je     800bd1 <strlcpy+0x32>
  800bc6:	0f b6 0a             	movzbl (%edx),%ecx
  800bc9:	84 c9                	test   %cl,%cl
  800bcb:	75 ec                	jne    800bb9 <strlcpy+0x1a>
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	eb 02                	jmp    800bd3 <strlcpy+0x34>
  800bd1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bd3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bd6:	29 f0                	sub    %esi,%eax
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800be5:	eb 06                	jmp    800bed <strcmp+0x11>
		p++, q++;
  800be7:	83 c1 01             	add    $0x1,%ecx
  800bea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bed:	0f b6 01             	movzbl (%ecx),%eax
  800bf0:	84 c0                	test   %al,%al
  800bf2:	74 04                	je     800bf8 <strcmp+0x1c>
  800bf4:	3a 02                	cmp    (%edx),%al
  800bf6:	74 ef                	je     800be7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf8:	0f b6 c0             	movzbl %al,%eax
  800bfb:	0f b6 12             	movzbl (%edx),%edx
  800bfe:	29 d0                	sub    %edx,%eax
}
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	53                   	push   %ebx
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0c:	89 c3                	mov    %eax,%ebx
  800c0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c11:	eb 06                	jmp    800c19 <strncmp+0x17>
		n--, p++, q++;
  800c13:	83 c0 01             	add    $0x1,%eax
  800c16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c19:	39 d8                	cmp    %ebx,%eax
  800c1b:	74 15                	je     800c32 <strncmp+0x30>
  800c1d:	0f b6 08             	movzbl (%eax),%ecx
  800c20:	84 c9                	test   %cl,%cl
  800c22:	74 04                	je     800c28 <strncmp+0x26>
  800c24:	3a 0a                	cmp    (%edx),%cl
  800c26:	74 eb                	je     800c13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c28:	0f b6 00             	movzbl (%eax),%eax
  800c2b:	0f b6 12             	movzbl (%edx),%edx
  800c2e:	29 d0                	sub    %edx,%eax
  800c30:	eb 05                	jmp    800c37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c44:	eb 07                	jmp    800c4d <strchr+0x13>
		if (*s == c)
  800c46:	38 ca                	cmp    %cl,%dl
  800c48:	74 0f                	je     800c59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	75 f2                	jne    800c46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c65:	eb 07                	jmp    800c6e <strfind+0x13>
		if (*s == c)
  800c67:	38 ca                	cmp    %cl,%dl
  800c69:	74 0a                	je     800c75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c6b:	83 c0 01             	add    $0x1,%eax
  800c6e:	0f b6 10             	movzbl (%eax),%edx
  800c71:	84 d2                	test   %dl,%dl
  800c73:	75 f2                	jne    800c67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c83:	85 c9                	test   %ecx,%ecx
  800c85:	74 36                	je     800cbd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c8d:	75 28                	jne    800cb7 <memset+0x40>
  800c8f:	f6 c1 03             	test   $0x3,%cl
  800c92:	75 23                	jne    800cb7 <memset+0x40>
		c &= 0xFF;
  800c94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	c1 e3 08             	shl    $0x8,%ebx
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	c1 e6 18             	shl    $0x18,%esi
  800ca2:	89 d0                	mov    %edx,%eax
  800ca4:	c1 e0 10             	shl    $0x10,%eax
  800ca7:	09 f0                	or     %esi,%eax
  800ca9:	09 c2                	or     %eax,%edx
  800cab:	89 d0                	mov    %edx,%eax
  800cad:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800caf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cb2:	fc                   	cld    
  800cb3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cb5:	eb 06                	jmp    800cbd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cba:	fc                   	cld    
  800cbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cbd:	89 f8                	mov    %edi,%eax
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cd2:	39 c6                	cmp    %eax,%esi
  800cd4:	73 35                	jae    800d0b <memmove+0x47>
  800cd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cd9:	39 d0                	cmp    %edx,%eax
  800cdb:	73 2e                	jae    800d0b <memmove+0x47>
		s += n;
		d += n;
  800cdd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cea:	75 13                	jne    800cff <memmove+0x3b>
  800cec:	f6 c1 03             	test   $0x3,%cl
  800cef:	75 0e                	jne    800cff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cf1:	83 ef 04             	sub    $0x4,%edi
  800cf4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cfa:	fd                   	std    
  800cfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cfd:	eb 09                	jmp    800d08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cff:	83 ef 01             	sub    $0x1,%edi
  800d02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d05:	fd                   	std    
  800d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d08:	fc                   	cld    
  800d09:	eb 1d                	jmp    800d28 <memmove+0x64>
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0f:	f6 c2 03             	test   $0x3,%dl
  800d12:	75 0f                	jne    800d23 <memmove+0x5f>
  800d14:	f6 c1 03             	test   $0x3,%cl
  800d17:	75 0a                	jne    800d23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	fc                   	cld    
  800d1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d21:	eb 05                	jmp    800d28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d23:	89 c7                	mov    %eax,%edi
  800d25:	fc                   	cld    
  800d26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d32:	8b 45 10             	mov    0x10(%ebp),%eax
  800d35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	89 04 24             	mov    %eax,(%esp)
  800d46:	e8 79 ff ff ff       	call   800cc4 <memmove>
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	89 d6                	mov    %edx,%esi
  800d5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5d:	eb 1a                	jmp    800d79 <memcmp+0x2c>
		if (*s1 != *s2)
  800d5f:	0f b6 02             	movzbl (%edx),%eax
  800d62:	0f b6 19             	movzbl (%ecx),%ebx
  800d65:	38 d8                	cmp    %bl,%al
  800d67:	74 0a                	je     800d73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d69:	0f b6 c0             	movzbl %al,%eax
  800d6c:	0f b6 db             	movzbl %bl,%ebx
  800d6f:	29 d8                	sub    %ebx,%eax
  800d71:	eb 0f                	jmp    800d82 <memcmp+0x35>
		s1++, s2++;
  800d73:	83 c2 01             	add    $0x1,%edx
  800d76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d79:	39 f2                	cmp    %esi,%edx
  800d7b:	75 e2                	jne    800d5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d94:	eb 07                	jmp    800d9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d96:	38 08                	cmp    %cl,(%eax)
  800d98:	74 07                	je     800da1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d9a:	83 c0 01             	add    $0x1,%eax
  800d9d:	39 d0                	cmp    %edx,%eax
  800d9f:	72 f5                	jb     800d96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800daf:	eb 03                	jmp    800db4 <strtol+0x11>
		s++;
  800db1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db4:	0f b6 0a             	movzbl (%edx),%ecx
  800db7:	80 f9 09             	cmp    $0x9,%cl
  800dba:	74 f5                	je     800db1 <strtol+0xe>
  800dbc:	80 f9 20             	cmp    $0x20,%cl
  800dbf:	74 f0                	je     800db1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc1:	80 f9 2b             	cmp    $0x2b,%cl
  800dc4:	75 0a                	jne    800dd0 <strtol+0x2d>
		s++;
  800dc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dce:	eb 11                	jmp    800de1 <strtol+0x3e>
  800dd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dd5:	80 f9 2d             	cmp    $0x2d,%cl
  800dd8:	75 07                	jne    800de1 <strtol+0x3e>
		s++, neg = 1;
  800dda:	8d 52 01             	lea    0x1(%edx),%edx
  800ddd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800de6:	75 15                	jne    800dfd <strtol+0x5a>
  800de8:	80 3a 30             	cmpb   $0x30,(%edx)
  800deb:	75 10                	jne    800dfd <strtol+0x5a>
  800ded:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800df1:	75 0a                	jne    800dfd <strtol+0x5a>
		s += 2, base = 16;
  800df3:	83 c2 02             	add    $0x2,%edx
  800df6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dfb:	eb 10                	jmp    800e0d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	75 0c                	jne    800e0d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e01:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e03:	80 3a 30             	cmpb   $0x30,(%edx)
  800e06:	75 05                	jne    800e0d <strtol+0x6a>
		s++, base = 8;
  800e08:	83 c2 01             	add    $0x1,%edx
  800e0b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e12:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e15:	0f b6 0a             	movzbl (%edx),%ecx
  800e18:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e1b:	89 f0                	mov    %esi,%eax
  800e1d:	3c 09                	cmp    $0x9,%al
  800e1f:	77 08                	ja     800e29 <strtol+0x86>
			dig = *s - '0';
  800e21:	0f be c9             	movsbl %cl,%ecx
  800e24:	83 e9 30             	sub    $0x30,%ecx
  800e27:	eb 20                	jmp    800e49 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e29:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e2c:	89 f0                	mov    %esi,%eax
  800e2e:	3c 19                	cmp    $0x19,%al
  800e30:	77 08                	ja     800e3a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e32:	0f be c9             	movsbl %cl,%ecx
  800e35:	83 e9 57             	sub    $0x57,%ecx
  800e38:	eb 0f                	jmp    800e49 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e3a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e3d:	89 f0                	mov    %esi,%eax
  800e3f:	3c 19                	cmp    $0x19,%al
  800e41:	77 16                	ja     800e59 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e43:	0f be c9             	movsbl %cl,%ecx
  800e46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e4c:	7d 0f                	jge    800e5d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e55:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e57:	eb bc                	jmp    800e15 <strtol+0x72>
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	eb 02                	jmp    800e5f <strtol+0xbc>
  800e5d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e63:	74 05                	je     800e6a <strtol+0xc7>
		*endptr = (char *) s;
  800e65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e68:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e6a:	f7 d8                	neg    %eax
  800e6c:	85 ff                	test   %edi,%edi
  800e6e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e96:	85 c0                	test   %eax,%eax
  800e98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e9c:	89 ea                	mov    %ebp,%edx
  800e9e:	89 0c 24             	mov    %ecx,(%esp)
  800ea1:	75 2d                	jne    800ed0 <__udivdi3+0x50>
  800ea3:	39 e9                	cmp    %ebp,%ecx
  800ea5:	77 61                	ja     800f08 <__udivdi3+0x88>
  800ea7:	85 c9                	test   %ecx,%ecx
  800ea9:	89 ce                	mov    %ecx,%esi
  800eab:	75 0b                	jne    800eb8 <__udivdi3+0x38>
  800ead:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb2:	31 d2                	xor    %edx,%edx
  800eb4:	f7 f1                	div    %ecx
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	31 d2                	xor    %edx,%edx
  800eba:	89 e8                	mov    %ebp,%eax
  800ebc:	f7 f6                	div    %esi
  800ebe:	89 c5                	mov    %eax,%ebp
  800ec0:	89 f8                	mov    %edi,%eax
  800ec2:	f7 f6                	div    %esi
  800ec4:	89 ea                	mov    %ebp,%edx
  800ec6:	83 c4 0c             	add    $0xc,%esp
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	39 e8                	cmp    %ebp,%eax
  800ed2:	77 24                	ja     800ef8 <__udivdi3+0x78>
  800ed4:	0f bd e8             	bsr    %eax,%ebp
  800ed7:	83 f5 1f             	xor    $0x1f,%ebp
  800eda:	75 3c                	jne    800f18 <__udivdi3+0x98>
  800edc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ee0:	39 34 24             	cmp    %esi,(%esp)
  800ee3:	0f 86 9f 00 00 00    	jbe    800f88 <__udivdi3+0x108>
  800ee9:	39 d0                	cmp    %edx,%eax
  800eeb:	0f 82 97 00 00 00    	jb     800f88 <__udivdi3+0x108>
  800ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	31 c0                	xor    %eax,%eax
  800efc:	83 c4 0c             	add    $0xc,%esp
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
  800f03:	90                   	nop
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	89 f8                	mov    %edi,%eax
  800f0a:	f7 f1                	div    %ecx
  800f0c:	31 d2                	xor    %edx,%edx
  800f0e:	83 c4 0c             	add    $0xc,%esp
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	8b 3c 24             	mov    (%esp),%edi
  800f1d:	d3 e0                	shl    %cl,%eax
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	b8 20 00 00 00       	mov    $0x20,%eax
  800f26:	29 e8                	sub    %ebp,%eax
  800f28:	89 c1                	mov    %eax,%ecx
  800f2a:	d3 ef                	shr    %cl,%edi
  800f2c:	89 e9                	mov    %ebp,%ecx
  800f2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f32:	8b 3c 24             	mov    (%esp),%edi
  800f35:	09 74 24 08          	or     %esi,0x8(%esp)
  800f39:	89 d6                	mov    %edx,%esi
  800f3b:	d3 e7                	shl    %cl,%edi
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	89 3c 24             	mov    %edi,(%esp)
  800f42:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f46:	d3 ee                	shr    %cl,%esi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	d3 e2                	shl    %cl,%edx
  800f4c:	89 c1                	mov    %eax,%ecx
  800f4e:	d3 ef                	shr    %cl,%edi
  800f50:	09 d7                	or     %edx,%edi
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	89 f8                	mov    %edi,%eax
  800f56:	f7 74 24 08          	divl   0x8(%esp)
  800f5a:	89 d6                	mov    %edx,%esi
  800f5c:	89 c7                	mov    %eax,%edi
  800f5e:	f7 24 24             	mull   (%esp)
  800f61:	39 d6                	cmp    %edx,%esi
  800f63:	89 14 24             	mov    %edx,(%esp)
  800f66:	72 30                	jb     800f98 <__udivdi3+0x118>
  800f68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f6c:	89 e9                	mov    %ebp,%ecx
  800f6e:	d3 e2                	shl    %cl,%edx
  800f70:	39 c2                	cmp    %eax,%edx
  800f72:	73 05                	jae    800f79 <__udivdi3+0xf9>
  800f74:	3b 34 24             	cmp    (%esp),%esi
  800f77:	74 1f                	je     800f98 <__udivdi3+0x118>
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	e9 7a ff ff ff       	jmp    800efc <__udivdi3+0x7c>
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8f:	e9 68 ff ff ff       	jmp    800efc <__udivdi3+0x7c>
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 0c             	add    $0xc,%esp
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    
  800fa4:	66 90                	xchg   %ax,%ax
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	66 90                	xchg   %ax,%ax
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__umoddi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	83 ec 14             	sub    $0x14,%esp
  800fb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fbe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fc2:	89 c7                	mov    %eax,%edi
  800fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd0:	89 34 24             	mov    %esi,(%esp)
  800fd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	89 c2                	mov    %eax,%edx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	75 17                	jne    800ff8 <__umoddi3+0x48>
  800fe1:	39 fe                	cmp    %edi,%esi
  800fe3:	76 4b                	jbe    801030 <__umoddi3+0x80>
  800fe5:	89 c8                	mov    %ecx,%eax
  800fe7:	89 fa                	mov    %edi,%edx
  800fe9:	f7 f6                	div    %esi
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	31 d2                	xor    %edx,%edx
  800fef:	83 c4 14             	add    $0x14,%esp
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	39 f8                	cmp    %edi,%eax
  800ffa:	77 54                	ja     801050 <__umoddi3+0xa0>
  800ffc:	0f bd e8             	bsr    %eax,%ebp
  800fff:	83 f5 1f             	xor    $0x1f,%ebp
  801002:	75 5c                	jne    801060 <__umoddi3+0xb0>
  801004:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801008:	39 3c 24             	cmp    %edi,(%esp)
  80100b:	0f 87 e7 00 00 00    	ja     8010f8 <__umoddi3+0x148>
  801011:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801015:	29 f1                	sub    %esi,%ecx
  801017:	19 c7                	sbb    %eax,%edi
  801019:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801021:	8b 44 24 08          	mov    0x8(%esp),%eax
  801025:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801029:	83 c4 14             	add    $0x14,%esp
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    
  801030:	85 f6                	test   %esi,%esi
  801032:	89 f5                	mov    %esi,%ebp
  801034:	75 0b                	jne    801041 <__umoddi3+0x91>
  801036:	b8 01 00 00 00       	mov    $0x1,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	f7 f6                	div    %esi
  80103f:	89 c5                	mov    %eax,%ebp
  801041:	8b 44 24 04          	mov    0x4(%esp),%eax
  801045:	31 d2                	xor    %edx,%edx
  801047:	f7 f5                	div    %ebp
  801049:	89 c8                	mov    %ecx,%eax
  80104b:	f7 f5                	div    %ebp
  80104d:	eb 9c                	jmp    800feb <__umoddi3+0x3b>
  80104f:	90                   	nop
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 fa                	mov    %edi,%edx
  801054:	83 c4 14             	add    $0x14,%esp
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    
  80105b:	90                   	nop
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	8b 04 24             	mov    (%esp),%eax
  801063:	be 20 00 00 00       	mov    $0x20,%esi
  801068:	89 e9                	mov    %ebp,%ecx
  80106a:	29 ee                	sub    %ebp,%esi
  80106c:	d3 e2                	shl    %cl,%edx
  80106e:	89 f1                	mov    %esi,%ecx
  801070:	d3 e8                	shr    %cl,%eax
  801072:	89 e9                	mov    %ebp,%ecx
  801074:	89 44 24 04          	mov    %eax,0x4(%esp)
  801078:	8b 04 24             	mov    (%esp),%eax
  80107b:	09 54 24 04          	or     %edx,0x4(%esp)
  80107f:	89 fa                	mov    %edi,%edx
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 f1                	mov    %esi,%ecx
  801085:	89 44 24 08          	mov    %eax,0x8(%esp)
  801089:	8b 44 24 10          	mov    0x10(%esp),%eax
  80108d:	d3 ea                	shr    %cl,%edx
  80108f:	89 e9                	mov    %ebp,%ecx
  801091:	d3 e7                	shl    %cl,%edi
  801093:	89 f1                	mov    %esi,%ecx
  801095:	d3 e8                	shr    %cl,%eax
  801097:	89 e9                	mov    %ebp,%ecx
  801099:	09 f8                	or     %edi,%eax
  80109b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80109f:	f7 74 24 04          	divl   0x4(%esp)
  8010a3:	d3 e7                	shl    %cl,%edi
  8010a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	f7 64 24 08          	mull   0x8(%esp)
  8010af:	39 d7                	cmp    %edx,%edi
  8010b1:	89 c1                	mov    %eax,%ecx
  8010b3:	89 14 24             	mov    %edx,(%esp)
  8010b6:	72 2c                	jb     8010e4 <__umoddi3+0x134>
  8010b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010bc:	72 22                	jb     8010e0 <__umoddi3+0x130>
  8010be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010c2:	29 c8                	sub    %ecx,%eax
  8010c4:	19 d7                	sbb    %edx,%edi
  8010c6:	89 e9                	mov    %ebp,%ecx
  8010c8:	89 fa                	mov    %edi,%edx
  8010ca:	d3 e8                	shr    %cl,%eax
  8010cc:	89 f1                	mov    %esi,%ecx
  8010ce:	d3 e2                	shl    %cl,%edx
  8010d0:	89 e9                	mov    %ebp,%ecx
  8010d2:	d3 ef                	shr    %cl,%edi
  8010d4:	09 d0                	or     %edx,%eax
  8010d6:	89 fa                	mov    %edi,%edx
  8010d8:	83 c4 14             	add    $0x14,%esp
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    
  8010df:	90                   	nop
  8010e0:	39 d7                	cmp    %edx,%edi
  8010e2:	75 da                	jne    8010be <__umoddi3+0x10e>
  8010e4:	8b 14 24             	mov    (%esp),%edx
  8010e7:	89 c1                	mov    %eax,%ecx
  8010e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010f1:	eb cb                	jmp    8010be <__umoddi3+0x10e>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010fc:	0f 82 0f ff ff ff    	jb     801011 <__umoddi3+0x61>
  801102:	e9 1a ff ff ff       	jmp    801021 <__umoddi3+0x71>
