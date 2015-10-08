
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 52 01 00 00       	call   8001a8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 8b 02 00 00       	call   8002f5 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80008a:	e8 db 00 00 00       	call   80016a <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0a 00 00 00       	call   8000c7 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d4:	e8 3f 00 00 00       	call   800118 <sys_env_destroy>
}
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 c3                	mov    %eax,%ebx
  8000ee:	89 c7                	mov    %eax,%edi
  8000f0:	89 c6                	mov    %eax,%esi
  8000f2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800104:	b8 01 00 00 00       	mov    $0x1,%eax
  800109:	89 d1                	mov    %edx,%ecx
  80010b:	89 d3                	mov    %edx,%ebx
  80010d:	89 d7                	mov    %edx,%edi
  80010f:	89 d6                	mov    %edx,%esi
  800111:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800121:	b9 00 00 00 00       	mov    $0x0,%ecx
  800126:	b8 03 00 00 00       	mov    $0x3,%eax
  80012b:	8b 55 08             	mov    0x8(%ebp),%edx
  80012e:	89 cb                	mov    %ecx,%ebx
  800130:	89 cf                	mov    %ecx,%edi
  800132:	89 ce                	mov    %ecx,%esi
  800134:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	7e 28                	jle    800162 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800145:	00 
  800146:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80015d:	e8 5b 02 00 00       	call   8003bd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800162:	83 c4 2c             	add    $0x2c,%esp
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 02 00 00 00       	mov    $0x2,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_yield>:

void
sys_yield(void)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018f:	ba 00 00 00 00       	mov    $0x0,%edx
  800194:	b8 0a 00 00 00       	mov    $0xa,%eax
  800199:	89 d1                	mov    %edx,%ecx
  80019b:	89 d3                	mov    %edx,%ebx
  80019d:	89 d7                	mov    %edx,%edi
  80019f:	89 d6                	mov    %edx,%esi
  8001a1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a3:	5b                   	pop    %ebx
  8001a4:	5e                   	pop    %esi
  8001a5:	5f                   	pop    %edi
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b1:	be 00 00 00 00       	mov    $0x0,%esi
  8001b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	89 f7                	mov    %esi,%edi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 28                	jle    8001f4 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8001ef:	e8 c9 01 00 00       	call   8003bd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001f4:	83 c4 2c             	add    $0x2c,%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800205:	b8 05 00 00 00       	mov    $0x5,%eax
  80020a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800213:	8b 7d 14             	mov    0x14(%ebp),%edi
  800216:	8b 75 18             	mov    0x18(%ebp),%esi
  800219:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021b:	85 c0                	test   %eax,%eax
  80021d:	7e 28                	jle    800247 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800223:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80022a:	00 
  80022b:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800232:	00 
  800233:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023a:	00 
  80023b:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800242:	e8 76 01 00 00       	call   8003bd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800247:	83 c4 2c             	add    $0x2c,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025d:	b8 06 00 00 00       	mov    $0x6,%eax
  800262:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	89 df                	mov    %ebx,%edi
  80026a:	89 de                	mov    %ebx,%esi
  80026c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80026e:	85 c0                	test   %eax,%eax
  800270:	7e 28                	jle    80029a <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800272:	89 44 24 10          	mov    %eax,0x10(%esp)
  800276:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80027d:	00 
  80027e:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800285:	00 
  800286:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80028d:	00 
  80028e:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800295:	e8 23 01 00 00       	call   8003bd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80029a:	83 c4 2c             	add    $0x2c,%esp
  80029d:	5b                   	pop    %ebx
  80029e:	5e                   	pop    %esi
  80029f:	5f                   	pop    %edi
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bb:	89 df                	mov    %ebx,%edi
  8002bd:	89 de                	mov    %ebx,%esi
  8002bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7e 28                	jle    8002ed <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002d0:	00 
  8002d1:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8002d8:	00 
  8002d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e0:	00 
  8002e1:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002e8:	e8 d0 00 00 00       	call   8003bd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ed:	83 c4 2c             	add    $0x2c,%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800316:	7e 28                	jle    800340 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031c:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800323:	00 
  800324:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80032b:	00 
  80032c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800333:	00 
  800334:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  80033b:	e8 7d 00 00 00       	call   8003bd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800340:	83 c4 2c             	add    $0x2c,%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034e:	be 00 00 00 00       	mov    $0x0,%esi
  800353:	b8 0b 00 00 00       	mov    $0xb,%eax
  800358:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035b:	8b 55 08             	mov    0x8(%ebp),%edx
  80035e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800361:	8b 7d 14             	mov    0x14(%ebp),%edi
  800364:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
  800371:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800374:	b9 00 00 00 00       	mov    $0x0,%ecx
  800379:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	89 cb                	mov    %ecx,%ebx
  800383:	89 cf                	mov    %ecx,%edi
  800385:	89 ce                	mov    %ecx,%esi
  800387:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800389:	85 c0                	test   %eax,%eax
  80038b:	7e 28                	jle    8003b5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800391:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800398:	00 
  800399:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8003a0:	00 
  8003a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003a8:	00 
  8003a9:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8003b0:	e8 08 00 00 00       	call   8003bd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003b5:	83 c4 2c             	add    $0x2c,%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5e                   	pop    %esi
  8003ba:	5f                   	pop    %edi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003c8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003ce:	e8 97 fd ff ff       	call   80016a <sys_getenvid>
  8003d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003da:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e9:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  8003f0:	e8 c1 00 00 00       	call   8004b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	e8 51 00 00 00       	call   800455 <vcprintf>
	cprintf("\n");
  800404:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  80040b:	e8 a6 00 00 00       	call   8004b6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800410:	cc                   	int3   
  800411:	eb fd                	jmp    800410 <_panic+0x53>

00800413 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	53                   	push   %ebx
  800417:	83 ec 14             	sub    $0x14,%esp
  80041a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80041d:	8b 13                	mov    (%ebx),%edx
  80041f:	8d 42 01             	lea    0x1(%edx),%eax
  800422:	89 03                	mov    %eax,(%ebx)
  800424:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800427:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80042b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800430:	75 19                	jne    80044b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800432:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800439:	00 
  80043a:	8d 43 08             	lea    0x8(%ebx),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 96 fc ff ff       	call   8000db <sys_cputs>
		b->idx = 0;
  800445:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80044b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80044f:	83 c4 14             	add    $0x14,%esp
  800452:	5b                   	pop    %ebx
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80045e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800465:	00 00 00 
	b.cnt = 0;
  800468:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80046f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800480:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048a:	c7 04 24 13 04 80 00 	movl   $0x800413,(%esp)
  800491:	e8 6e 01 00 00       	call   800604 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800496:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 2d fc ff ff       	call   8000db <sys_cputs>

	return b.cnt;
}
  8004ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004b4:	c9                   	leave  
  8004b5:	c3                   	ret    

008004b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	e8 87 ff ff ff       	call   800455 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

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
  8005a8:	0f be 80 9e 11 80 00 	movsbl 0x80119e(%eax),%eax
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
  80068f:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
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
  80073c:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800743:	85 d2                	test   %edx,%edx
  800745:	75 20                	jne    800767 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800747:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074b:	c7 44 24 08 b6 11 80 	movl   $0x8011b6,0x8(%esp)
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
  80076b:	c7 44 24 08 bf 11 80 	movl   $0x8011bf,0x8(%esp)
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
  80079b:	b8 af 11 80 00       	mov    $0x8011af,%eax
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
	...

00800e80 <__udivdi3>:
  800e80:	83 ec 1c             	sub    $0x1c,%esp
  800e83:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e87:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800e8b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e8f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e93:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e97:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e9b:	85 ff                	test   %edi,%edi
  800e9d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800ea1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea5:	89 cd                	mov    %ecx,%ebp
  800ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eab:	75 33                	jne    800ee0 <__udivdi3+0x60>
  800ead:	39 f1                	cmp    %esi,%ecx
  800eaf:	77 57                	ja     800f08 <__udivdi3+0x88>
  800eb1:	85 c9                	test   %ecx,%ecx
  800eb3:	75 0b                	jne    800ec0 <__udivdi3+0x40>
  800eb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eba:	31 d2                	xor    %edx,%edx
  800ebc:	f7 f1                	div    %ecx
  800ebe:	89 c1                	mov    %eax,%ecx
  800ec0:	89 f0                	mov    %esi,%eax
  800ec2:	31 d2                	xor    %edx,%edx
  800ec4:	f7 f1                	div    %ecx
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecc:	f7 f1                	div    %ecx
  800ece:	89 f2                	mov    %esi,%edx
  800ed0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ed4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ed8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800edc:	83 c4 1c             	add    $0x1c,%esp
  800edf:	c3                   	ret    
  800ee0:	31 d2                	xor    %edx,%edx
  800ee2:	31 c0                	xor    %eax,%eax
  800ee4:	39 f7                	cmp    %esi,%edi
  800ee6:	77 e8                	ja     800ed0 <__udivdi3+0x50>
  800ee8:	0f bd cf             	bsr    %edi,%ecx
  800eeb:	83 f1 1f             	xor    $0x1f,%ecx
  800eee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ef2:	75 2c                	jne    800f20 <__udivdi3+0xa0>
  800ef4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800ef8:	76 04                	jbe    800efe <__udivdi3+0x7e>
  800efa:	39 f7                	cmp    %esi,%edi
  800efc:	73 d2                	jae    800ed0 <__udivdi3+0x50>
  800efe:	31 d2                	xor    %edx,%edx
  800f00:	b8 01 00 00 00       	mov    $0x1,%eax
  800f05:	eb c9                	jmp    800ed0 <__udivdi3+0x50>
  800f07:	90                   	nop
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	f7 f1                	div    %ecx
  800f0c:	31 d2                	xor    %edx,%edx
  800f0e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f12:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f16:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	c3                   	ret    
  800f1e:	66 90                	xchg   %ax,%ax
  800f20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f25:	b8 20 00 00 00       	mov    $0x20,%eax
  800f2a:	89 ea                	mov    %ebp,%edx
  800f2c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f30:	d3 e7                	shl    %cl,%edi
  800f32:	89 c1                	mov    %eax,%ecx
  800f34:	d3 ea                	shr    %cl,%edx
  800f36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f3b:	09 fa                	or     %edi,%edx
  800f3d:	89 f7                	mov    %esi,%edi
  800f3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f43:	89 f2                	mov    %esi,%edx
  800f45:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f49:	d3 e5                	shl    %cl,%ebp
  800f4b:	89 c1                	mov    %eax,%ecx
  800f4d:	d3 ef                	shr    %cl,%edi
  800f4f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f54:	d3 e2                	shl    %cl,%edx
  800f56:	89 c1                	mov    %eax,%ecx
  800f58:	d3 ee                	shr    %cl,%esi
  800f5a:	09 d6                	or     %edx,%esi
  800f5c:	89 fa                	mov    %edi,%edx
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	f7 74 24 0c          	divl   0xc(%esp)
  800f64:	89 d7                	mov    %edx,%edi
  800f66:	89 c6                	mov    %eax,%esi
  800f68:	f7 e5                	mul    %ebp
  800f6a:	39 d7                	cmp    %edx,%edi
  800f6c:	72 22                	jb     800f90 <__udivdi3+0x110>
  800f6e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f72:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f77:	d3 e5                	shl    %cl,%ebp
  800f79:	39 c5                	cmp    %eax,%ebp
  800f7b:	73 04                	jae    800f81 <__udivdi3+0x101>
  800f7d:	39 d7                	cmp    %edx,%edi
  800f7f:	74 0f                	je     800f90 <__udivdi3+0x110>
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	e9 46 ff ff ff       	jmp    800ed0 <__udivdi3+0x50>
  800f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f90:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f99:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f9d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fa1:	83 c4 1c             	add    $0x1c,%esp
  800fa4:	c3                   	ret    
	...

00800fb0 <__umoddi3>:
  800fb0:	83 ec 1c             	sub    $0x1c,%esp
  800fb3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fb7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800fbb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800fbf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fc3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fc7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fcb:	85 ed                	test   %ebp,%ebp
  800fcd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd5:	89 cf                	mov    %ecx,%edi
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	89 f2                	mov    %esi,%edx
  800fdc:	75 1a                	jne    800ff8 <__umoddi3+0x48>
  800fde:	39 f1                	cmp    %esi,%ecx
  800fe0:	76 4e                	jbe    801030 <__umoddi3+0x80>
  800fe2:	f7 f1                	div    %ecx
  800fe4:	89 d0                	mov    %edx,%eax
  800fe6:	31 d2                	xor    %edx,%edx
  800fe8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ff4:	83 c4 1c             	add    $0x1c,%esp
  800ff7:	c3                   	ret    
  800ff8:	39 f5                	cmp    %esi,%ebp
  800ffa:	77 54                	ja     801050 <__umoddi3+0xa0>
  800ffc:	0f bd c5             	bsr    %ebp,%eax
  800fff:	83 f0 1f             	xor    $0x1f,%eax
  801002:	89 44 24 04          	mov    %eax,0x4(%esp)
  801006:	75 60                	jne    801068 <__umoddi3+0xb8>
  801008:	3b 0c 24             	cmp    (%esp),%ecx
  80100b:	0f 87 07 01 00 00    	ja     801118 <__umoddi3+0x168>
  801011:	89 f2                	mov    %esi,%edx
  801013:	8b 34 24             	mov    (%esp),%esi
  801016:	29 ce                	sub    %ecx,%esi
  801018:	19 ea                	sbb    %ebp,%edx
  80101a:	89 34 24             	mov    %esi,(%esp)
  80101d:	8b 04 24             	mov    (%esp),%eax
  801020:	8b 74 24 10          	mov    0x10(%esp),%esi
  801024:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801028:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80102c:	83 c4 1c             	add    $0x1c,%esp
  80102f:	c3                   	ret    
  801030:	85 c9                	test   %ecx,%ecx
  801032:	75 0b                	jne    80103f <__umoddi3+0x8f>
  801034:	b8 01 00 00 00       	mov    $0x1,%eax
  801039:	31 d2                	xor    %edx,%edx
  80103b:	f7 f1                	div    %ecx
  80103d:	89 c1                	mov    %eax,%ecx
  80103f:	89 f0                	mov    %esi,%eax
  801041:	31 d2                	xor    %edx,%edx
  801043:	f7 f1                	div    %ecx
  801045:	8b 04 24             	mov    (%esp),%eax
  801048:	f7 f1                	div    %ecx
  80104a:	eb 98                	jmp    800fe4 <__umoddi3+0x34>
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	89 f2                	mov    %esi,%edx
  801052:	8b 74 24 10          	mov    0x10(%esp),%esi
  801056:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80105a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80105e:	83 c4 1c             	add    $0x1c,%esp
  801061:	c3                   	ret    
  801062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801068:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80106d:	89 e8                	mov    %ebp,%eax
  80106f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801074:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801078:	89 fa                	mov    %edi,%edx
  80107a:	d3 e0                	shl    %cl,%eax
  80107c:	89 e9                	mov    %ebp,%ecx
  80107e:	d3 ea                	shr    %cl,%edx
  801080:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801085:	09 c2                	or     %eax,%edx
  801087:	8b 44 24 08          	mov    0x8(%esp),%eax
  80108b:	89 14 24             	mov    %edx,(%esp)
  80108e:	89 f2                	mov    %esi,%edx
  801090:	d3 e7                	shl    %cl,%edi
  801092:	89 e9                	mov    %ebp,%ecx
  801094:	d3 ea                	shr    %cl,%edx
  801096:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109f:	d3 e6                	shl    %cl,%esi
  8010a1:	89 e9                	mov    %ebp,%ecx
  8010a3:	d3 e8                	shr    %cl,%eax
  8010a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010aa:	09 f0                	or     %esi,%eax
  8010ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010b0:	f7 34 24             	divl   (%esp)
  8010b3:	d3 e6                	shl    %cl,%esi
  8010b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010b9:	89 d6                	mov    %edx,%esi
  8010bb:	f7 e7                	mul    %edi
  8010bd:	39 d6                	cmp    %edx,%esi
  8010bf:	89 c1                	mov    %eax,%ecx
  8010c1:	89 d7                	mov    %edx,%edi
  8010c3:	72 3f                	jb     801104 <__umoddi3+0x154>
  8010c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010c9:	72 35                	jb     801100 <__umoddi3+0x150>
  8010cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010cf:	29 c8                	sub    %ecx,%eax
  8010d1:	19 fe                	sbb    %edi,%esi
  8010d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010d8:	89 f2                	mov    %esi,%edx
  8010da:	d3 e8                	shr    %cl,%eax
  8010dc:	89 e9                	mov    %ebp,%ecx
  8010de:	d3 e2                	shl    %cl,%edx
  8010e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010e5:	09 d0                	or     %edx,%eax
  8010e7:	89 f2                	mov    %esi,%edx
  8010e9:	d3 ea                	shr    %cl,%edx
  8010eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010f7:	83 c4 1c             	add    $0x1c,%esp
  8010fa:	c3                   	ret    
  8010fb:	90                   	nop
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	39 d6                	cmp    %edx,%esi
  801102:	75 c7                	jne    8010cb <__umoddi3+0x11b>
  801104:	89 d7                	mov    %edx,%edi
  801106:	89 c1                	mov    %eax,%ecx
  801108:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80110c:	1b 3c 24             	sbb    (%esp),%edi
  80110f:	eb ba                	jmp    8010cb <__umoddi3+0x11b>
  801111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801118:	39 f5                	cmp    %esi,%ebp
  80111a:	0f 82 f1 fe ff ff    	jb     801011 <__umoddi3+0x61>
  801120:	e9 f8 fe ff ff       	jmp    80101d <__umoddi3+0x6d>
