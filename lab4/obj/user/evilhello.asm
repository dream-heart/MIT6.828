
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 65 00 00 00       	call   8000b3 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800062:	e8 db 00 00 00       	call   800142 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0a 00 00 00       	call   80009f <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ac:	e8 3f 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7e 28                	jle    80013a <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800112:	89 44 24 10          	mov    %eax,0x10(%esp)
  800116:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800135:	e8 5b 02 00 00       	call   800395 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013a:	83 c4 2c             	add    $0x2c,%esp
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	57                   	push   %edi
  800146:	56                   	push   %esi
  800147:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800148:	ba 00 00 00 00       	mov    $0x0,%edx
  80014d:	b8 02 00 00 00       	mov    $0x2,%eax
  800152:	89 d1                	mov    %edx,%ecx
  800154:	89 d3                	mov    %edx,%ebx
  800156:	89 d7                	mov    %edx,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015c:	5b                   	pop    %ebx
  80015d:	5e                   	pop    %esi
  80015e:	5f                   	pop    %edi
  80015f:	5d                   	pop    %ebp
  800160:	c3                   	ret    

00800161 <sys_yield>:

void
sys_yield(void)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800171:	89 d1                	mov    %edx,%ecx
  800173:	89 d3                	mov    %edx,%ebx
  800175:	89 d7                	mov    %edx,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800189:	be 00 00 00 00       	mov    $0x0,%esi
  80018e:	b8 04 00 00 00       	mov    $0x4,%eax
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019c:	89 f7                	mov    %esi,%edi
  80019e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	7e 28                	jle    8001cc <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a8:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001af:	00 
  8001b0:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001b7:	00 
  8001b8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bf:	00 
  8001c0:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001c7:	e8 c9 01 00 00       	call   800395 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cc:	83 c4 2c             	add    $0x2c,%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ee:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f3:	85 c0                	test   %eax,%eax
  8001f5:	7e 28                	jle    80021f <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fb:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800202:	00 
  800203:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800212:	00 
  800213:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80021a:	e8 76 01 00 00       	call   800395 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021f:	83 c4 2c             	add    $0x2c,%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5f                   	pop    %edi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	b8 06 00 00 00       	mov    $0x6,%eax
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7e 28                	jle    800272 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800255:	00 
  800256:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80025d:	00 
  80025e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800265:	00 
  800266:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  80026d:	e8 23 01 00 00       	call   800395 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800272:	83 c4 2c             	add    $0x2c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800283:	bb 00 00 00 00       	mov    $0x0,%ebx
  800288:	b8 08 00 00 00       	mov    $0x8,%eax
  80028d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	89 df                	mov    %ebx,%edi
  800295:	89 de                	mov    %ebx,%esi
  800297:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800299:	85 c0                	test   %eax,%eax
  80029b:	7e 28                	jle    8002c5 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8002b0:	00 
  8002b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b8:	00 
  8002b9:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002c0:	e8 d0 00 00 00       	call   800395 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c5:	83 c4 2c             	add    $0x2c,%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002db:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 df                	mov    %ebx,%edi
  8002e8:	89 de                	mov    %ebx,%esi
  8002ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7e 28                	jle    800318 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f4:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fb:	00 
  8002fc:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800303:	00 
  800304:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030b:	00 
  80030c:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800313:	e8 7d 00 00 00       	call   800395 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800318:	83 c4 2c             	add    $0x2c,%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	be 00 00 00 00       	mov    $0x0,%esi
  80032b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800339:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800351:	b8 0c 00 00 00       	mov    $0xc,%eax
  800356:	8b 55 08             	mov    0x8(%ebp),%edx
  800359:	89 cb                	mov    %ecx,%ebx
  80035b:	89 cf                	mov    %ecx,%edi
  80035d:	89 ce                	mov    %ecx,%esi
  80035f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800361:	85 c0                	test   %eax,%eax
  800363:	7e 28                	jle    80038d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800365:	89 44 24 10          	mov    %eax,0x10(%esp)
  800369:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800370:	00 
  800371:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800378:	00 
  800379:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800380:	00 
  800381:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800388:	e8 08 00 00 00       	call   800395 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038d:	83 c4 2c             	add    $0x2c,%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80039d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003a6:	e8 97 fd ff ff       	call   800142 <sys_getenvid>
  8003ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ae:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c1:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8003c8:	e8 c1 00 00 00       	call   80048e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 51 00 00 00       	call   80042d <vcprintf>
	cprintf("\n");
  8003dc:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  8003e3:	e8 a6 00 00 00       	call   80048e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e8:	cc                   	int3   
  8003e9:	eb fd                	jmp    8003e8 <_panic+0x53>

008003eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 14             	sub    $0x14,%esp
  8003f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f5:	8b 13                	mov    (%ebx),%edx
  8003f7:	8d 42 01             	lea    0x1(%edx),%eax
  8003fa:	89 03                	mov    %eax,(%ebx)
  8003fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800403:	3d ff 00 00 00       	cmp    $0xff,%eax
  800408:	75 19                	jne    800423 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80040a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800411:	00 
  800412:	8d 43 08             	lea    0x8(%ebx),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	e8 96 fc ff ff       	call   8000b3 <sys_cputs>
		b->idx = 0;
  80041d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800423:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800427:	83 c4 14             	add    $0x14,%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800436:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043d:	00 00 00 
	b.cnt = 0;
  800440:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800447:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 44 24 08          	mov    %eax,0x8(%esp)
  800458:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800462:	c7 04 24 eb 03 80 00 	movl   $0x8003eb,(%esp)
  800469:	e8 76 01 00 00       	call   8005e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80046e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	e8 2d fc ff ff       	call   8000b3 <sys_cputs>

	return b.cnt;
}
  800486:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800494:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	8b 45 08             	mov    0x8(%ebp),%eax
  80049e:	89 04 24             	mov    %eax,(%esp)
  8004a1:	e8 87 ff ff ff       	call   80042d <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    
	...

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
  80051f:	e8 3c 09 00 00       	call   800e60 <__udivdi3>
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
  80057f:	e8 0c 0a 00 00       	call   800f90 <__umoddi3>
  800584:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800588:	0f be 80 7e 11 80 00 	movsbl 0x80117e(%eax),%eax
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
  80072b:	c7 44 24 08 96 11 80 	movl   $0x801196,0x8(%esp)
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
  80074b:	c7 44 24 08 9f 11 80 	movl   $0x80119f,0x8(%esp)
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
  80077b:	b8 8f 11 80 00       	mov    $0x80118f,%eax
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
	...

00800e60 <__udivdi3>:
  800e60:	83 ec 1c             	sub    $0x1c,%esp
  800e63:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e67:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800e6b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e6f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e73:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e77:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e85:	89 cd                	mov    %ecx,%ebp
  800e87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8b:	75 33                	jne    800ec0 <__udivdi3+0x60>
  800e8d:	39 f1                	cmp    %esi,%ecx
  800e8f:	77 57                	ja     800ee8 <__udivdi3+0x88>
  800e91:	85 c9                	test   %ecx,%ecx
  800e93:	75 0b                	jne    800ea0 <__udivdi3+0x40>
  800e95:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9a:	31 d2                	xor    %edx,%edx
  800e9c:	f7 f1                	div    %ecx
  800e9e:	89 c1                	mov    %eax,%ecx
  800ea0:	89 f0                	mov    %esi,%eax
  800ea2:	31 d2                	xor    %edx,%edx
  800ea4:	f7 f1                	div    %ecx
  800ea6:	89 c6                	mov    %eax,%esi
  800ea8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eac:	f7 f1                	div    %ecx
  800eae:	89 f2                	mov    %esi,%edx
  800eb0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800eb4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800eb8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	c3                   	ret    
  800ec0:	31 d2                	xor    %edx,%edx
  800ec2:	31 c0                	xor    %eax,%eax
  800ec4:	39 f7                	cmp    %esi,%edi
  800ec6:	77 e8                	ja     800eb0 <__udivdi3+0x50>
  800ec8:	0f bd cf             	bsr    %edi,%ecx
  800ecb:	83 f1 1f             	xor    $0x1f,%ecx
  800ece:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ed2:	75 2c                	jne    800f00 <__udivdi3+0xa0>
  800ed4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800ed8:	76 04                	jbe    800ede <__udivdi3+0x7e>
  800eda:	39 f7                	cmp    %esi,%edi
  800edc:	73 d2                	jae    800eb0 <__udivdi3+0x50>
  800ede:	31 d2                	xor    %edx,%edx
  800ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee5:	eb c9                	jmp    800eb0 <__udivdi3+0x50>
  800ee7:	90                   	nop
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	f7 f1                	div    %ecx
  800eec:	31 d2                	xor    %edx,%edx
  800eee:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ef2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ef6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	c3                   	ret    
  800efe:	66 90                	xchg   %ax,%ax
  800f00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f05:	b8 20 00 00 00       	mov    $0x20,%eax
  800f0a:	89 ea                	mov    %ebp,%edx
  800f0c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f10:	d3 e7                	shl    %cl,%edi
  800f12:	89 c1                	mov    %eax,%ecx
  800f14:	d3 ea                	shr    %cl,%edx
  800f16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f1b:	09 fa                	or     %edi,%edx
  800f1d:	89 f7                	mov    %esi,%edi
  800f1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f29:	d3 e5                	shl    %cl,%ebp
  800f2b:	89 c1                	mov    %eax,%ecx
  800f2d:	d3 ef                	shr    %cl,%edi
  800f2f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f34:	d3 e2                	shl    %cl,%edx
  800f36:	89 c1                	mov    %eax,%ecx
  800f38:	d3 ee                	shr    %cl,%esi
  800f3a:	09 d6                	or     %edx,%esi
  800f3c:	89 fa                	mov    %edi,%edx
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	f7 74 24 0c          	divl   0xc(%esp)
  800f44:	89 d7                	mov    %edx,%edi
  800f46:	89 c6                	mov    %eax,%esi
  800f48:	f7 e5                	mul    %ebp
  800f4a:	39 d7                	cmp    %edx,%edi
  800f4c:	72 22                	jb     800f70 <__udivdi3+0x110>
  800f4e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800f52:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f57:	d3 e5                	shl    %cl,%ebp
  800f59:	39 c5                	cmp    %eax,%ebp
  800f5b:	73 04                	jae    800f61 <__udivdi3+0x101>
  800f5d:	39 d7                	cmp    %edx,%edi
  800f5f:	74 0f                	je     800f70 <__udivdi3+0x110>
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	e9 46 ff ff ff       	jmp    800eb0 <__udivdi3+0x50>
  800f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f70:	8d 46 ff             	lea    -0x1(%esi),%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f79:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f7d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f81:	83 c4 1c             	add    $0x1c,%esp
  800f84:	c3                   	ret    
	...

00800f90 <__umoddi3>:
  800f90:	83 ec 1c             	sub    $0x1c,%esp
  800f93:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f97:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f9b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f9f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fa3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fa7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fab:	85 ed                	test   %ebp,%ebp
  800fad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb5:	89 cf                	mov    %ecx,%edi
  800fb7:	89 04 24             	mov    %eax,(%esp)
  800fba:	89 f2                	mov    %esi,%edx
  800fbc:	75 1a                	jne    800fd8 <__umoddi3+0x48>
  800fbe:	39 f1                	cmp    %esi,%ecx
  800fc0:	76 4e                	jbe    801010 <__umoddi3+0x80>
  800fc2:	f7 f1                	div    %ecx
  800fc4:	89 d0                	mov    %edx,%eax
  800fc6:	31 d2                	xor    %edx,%edx
  800fc8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fcc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fd0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fd4:	83 c4 1c             	add    $0x1c,%esp
  800fd7:	c3                   	ret    
  800fd8:	39 f5                	cmp    %esi,%ebp
  800fda:	77 54                	ja     801030 <__umoddi3+0xa0>
  800fdc:	0f bd c5             	bsr    %ebp,%eax
  800fdf:	83 f0 1f             	xor    $0x1f,%eax
  800fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe6:	75 60                	jne    801048 <__umoddi3+0xb8>
  800fe8:	3b 0c 24             	cmp    (%esp),%ecx
  800feb:	0f 87 07 01 00 00    	ja     8010f8 <__umoddi3+0x168>
  800ff1:	89 f2                	mov    %esi,%edx
  800ff3:	8b 34 24             	mov    (%esp),%esi
  800ff6:	29 ce                	sub    %ecx,%esi
  800ff8:	19 ea                	sbb    %ebp,%edx
  800ffa:	89 34 24             	mov    %esi,(%esp)
  800ffd:	8b 04 24             	mov    (%esp),%eax
  801000:	8b 74 24 10          	mov    0x10(%esp),%esi
  801004:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801008:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80100c:	83 c4 1c             	add    $0x1c,%esp
  80100f:	c3                   	ret    
  801010:	85 c9                	test   %ecx,%ecx
  801012:	75 0b                	jne    80101f <__umoddi3+0x8f>
  801014:	b8 01 00 00 00       	mov    $0x1,%eax
  801019:	31 d2                	xor    %edx,%edx
  80101b:	f7 f1                	div    %ecx
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	89 f0                	mov    %esi,%eax
  801021:	31 d2                	xor    %edx,%edx
  801023:	f7 f1                	div    %ecx
  801025:	8b 04 24             	mov    (%esp),%eax
  801028:	f7 f1                	div    %ecx
  80102a:	eb 98                	jmp    800fc4 <__umoddi3+0x34>
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	89 f2                	mov    %esi,%edx
  801032:	8b 74 24 10          	mov    0x10(%esp),%esi
  801036:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80103a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	c3                   	ret    
  801042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801048:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80104d:	89 e8                	mov    %ebp,%eax
  80104f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801054:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801058:	89 fa                	mov    %edi,%edx
  80105a:	d3 e0                	shl    %cl,%eax
  80105c:	89 e9                	mov    %ebp,%ecx
  80105e:	d3 ea                	shr    %cl,%edx
  801060:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801065:	09 c2                	or     %eax,%edx
  801067:	8b 44 24 08          	mov    0x8(%esp),%eax
  80106b:	89 14 24             	mov    %edx,(%esp)
  80106e:	89 f2                	mov    %esi,%edx
  801070:	d3 e7                	shl    %cl,%edi
  801072:	89 e9                	mov    %ebp,%ecx
  801074:	d3 ea                	shr    %cl,%edx
  801076:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	d3 e6                	shl    %cl,%esi
  801081:	89 e9                	mov    %ebp,%ecx
  801083:	d3 e8                	shr    %cl,%eax
  801085:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80108a:	09 f0                	or     %esi,%eax
  80108c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801090:	f7 34 24             	divl   (%esp)
  801093:	d3 e6                	shl    %cl,%esi
  801095:	89 74 24 08          	mov    %esi,0x8(%esp)
  801099:	89 d6                	mov    %edx,%esi
  80109b:	f7 e7                	mul    %edi
  80109d:	39 d6                	cmp    %edx,%esi
  80109f:	89 c1                	mov    %eax,%ecx
  8010a1:	89 d7                	mov    %edx,%edi
  8010a3:	72 3f                	jb     8010e4 <__umoddi3+0x154>
  8010a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010a9:	72 35                	jb     8010e0 <__umoddi3+0x150>
  8010ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010af:	29 c8                	sub    %ecx,%eax
  8010b1:	19 fe                	sbb    %edi,%esi
  8010b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010b8:	89 f2                	mov    %esi,%edx
  8010ba:	d3 e8                	shr    %cl,%eax
  8010bc:	89 e9                	mov    %ebp,%ecx
  8010be:	d3 e2                	shl    %cl,%edx
  8010c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010c5:	09 d0                	or     %edx,%eax
  8010c7:	89 f2                	mov    %esi,%edx
  8010c9:	d3 ea                	shr    %cl,%edx
  8010cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010d7:	83 c4 1c             	add    $0x1c,%esp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	39 d6                	cmp    %edx,%esi
  8010e2:	75 c7                	jne    8010ab <__umoddi3+0x11b>
  8010e4:	89 d7                	mov    %edx,%edi
  8010e6:	89 c1                	mov    %eax,%ecx
  8010e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8010ec:	1b 3c 24             	sbb    (%esp),%edi
  8010ef:	eb ba                	jmp    8010ab <__umoddi3+0x11b>
  8010f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	39 f5                	cmp    %esi,%ebp
  8010fa:	0f 82 f1 fe ff ff    	jb     800ff1 <__umoddi3+0x61>
  801100:	e9 f8 fe ff ff       	jmp    800ffd <__umoddi3+0x6d>
