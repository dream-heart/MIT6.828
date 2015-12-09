
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800040:	00 
  800041:	a1 00 20 80 00       	mov    0x802000,%eax
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 5e 00 00 00       	call   8000ac <sys_cputs>
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
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  80005e:	e8 d8 00 00 00       	call   80013b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800080:	89 74 24 04          	mov    %esi,0x4(%esp)
  800084:	89 1c 24             	mov    %ebx,(%esp)
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 07 00 00 00       	call   800098 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 3f 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  80012e:	e8 ae 02 00 00       	call   8003e1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  8001c0:	e8 1c 02 00 00       	call   8003e1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  800213:	e8 c9 01 00 00       	call   8003e1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  800266:	e8 76 01 00 00       	call   8003e1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  8002b9:	e8 23 01 00 00       	call   8003e1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  80030c:	e8 d0 00 00 00       	call   8003e1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  80035f:	e8 7d 00 00 00       	call   8003e1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800364:	83 c4 2c             	add    $0x2c,%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800372:	be 00 00 00 00       	mov    $0x0,%esi
  800377:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800385:	8b 7d 14             	mov    0x14(%ebp),%edi
  800388:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	89 cb                	mov    %ecx,%ebx
  8003a7:	89 cf                	mov    %ecx,%edi
  8003a9:	89 ce                	mov    %ecx,%esi
  8003ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	7e 28                	jle    8003d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cc:	00 
  8003cd:	c7 04 24 75 11 80 00 	movl   $0x801175,(%esp)
  8003d4:	e8 08 00 00 00       	call   8003e1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d9:	83 c4 2c             	add    $0x2c,%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ec:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8003f2:	e8 44 fd ff ff       	call   80013b <sys_getenvid>
  8003f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800401:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800405:	89 74 24 08          	mov    %esi,0x8(%esp)
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	c7 04 24 84 11 80 00 	movl   $0x801184,(%esp)
  800414:	e8 c1 00 00 00       	call   8004da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800419:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041d:	8b 45 10             	mov    0x10(%ebp),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 51 00 00 00       	call   800479 <vcprintf>
	cprintf("\n");
  800428:	c7 04 24 4c 11 80 00 	movl   $0x80114c,(%esp)
  80042f:	e8 a6 00 00 00       	call   8004da <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800434:	cc                   	int3   
  800435:	eb fd                	jmp    800434 <_panic+0x53>

00800437 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	53                   	push   %ebx
  80043b:	83 ec 14             	sub    $0x14,%esp
  80043e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800441:	8b 13                	mov    (%ebx),%edx
  800443:	8d 42 01             	lea    0x1(%edx),%eax
  800446:	89 03                	mov    %eax,(%ebx)
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80044f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800454:	75 19                	jne    80046f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800456:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80045d:	00 
  80045e:	8d 43 08             	lea    0x8(%ebx),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	e8 43 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800469:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80046f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800473:	83 c4 14             	add    $0x14,%esp
  800476:	5b                   	pop    %ebx
  800477:	5d                   	pop    %ebp
  800478:	c3                   	ret    

00800479 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800482:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800489:	00 00 00 
	b.cnt = 0;
  80048c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800493:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800496:	8b 45 0c             	mov    0xc(%ebp),%eax
  800499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	c7 04 24 37 04 80 00 	movl   $0x800437,(%esp)
  8004b5:	e8 7a 01 00 00       	call   800634 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ba:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	e8 da fb ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8004d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d8:	c9                   	leave  
  8004d9:	c3                   	ret    

008004da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	e8 87 ff ff ff       	call   800479 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    
  8004f4:	66 90                	xchg   %ax,%ax
  8004f6:	66 90                	xchg   %ax,%ax
  8004f8:	66 90                	xchg   %ax,%ax
  8004fa:	66 90                	xchg   %ax,%ax
  8004fc:	66 90                	xchg   %ax,%ax
  8004fe:	66 90                	xchg   %ax,%ax

00800500 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 3c             	sub    $0x3c,%esp
  800509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050c:	89 d7                	mov    %edx,%edi
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	89 c3                	mov    %eax,%ebx
  800519:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80051c:	8b 45 10             	mov    0x10(%ebp),%eax
  80051f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052d:	39 d9                	cmp    %ebx,%ecx
  80052f:	72 05                	jb     800536 <printnum+0x36>
  800531:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800534:	77 69                	ja     80059f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800536:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800539:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80053d:	83 ee 01             	sub    $0x1,%esi
  800540:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800544:	89 44 24 08          	mov    %eax,0x8(%esp)
  800548:	8b 44 24 08          	mov    0x8(%esp),%eax
  80054c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800550:	89 c3                	mov    %eax,%ebx
  800552:	89 d6                	mov    %edx,%esi
  800554:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800557:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80055e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 3c 09 00 00       	call   800eb0 <__udivdi3>
  800574:	89 d9                	mov    %ebx,%ecx
  800576:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80057a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80057e:	89 04 24             	mov    %eax,(%esp)
  800581:	89 54 24 04          	mov    %edx,0x4(%esp)
  800585:	89 fa                	mov    %edi,%edx
  800587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058a:	e8 71 ff ff ff       	call   800500 <printnum>
  80058f:	eb 1b                	jmp    8005ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800595:	8b 45 18             	mov    0x18(%ebp),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	ff d3                	call   *%ebx
  80059d:	eb 03                	jmp    8005a2 <printnum+0xa2>
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a2:	83 ee 01             	sub    $0x1,%esi
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	7f e8                	jg     800591 <printnum+0x91>
  8005a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	e8 0c 0a 00 00       	call   800fe0 <__umoddi3>
  8005d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d8:	0f be 80 a7 11 80 00 	movsbl 0x8011a7(%eax),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	ff d0                	call   *%eax
}
  8005e7:	83 c4 3c             	add    $0x3c,%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005fe:	73 0a                	jae    80060a <sprintputch+0x1b>
		*b->buf++ = ch;
  800600:	8d 4a 01             	lea    0x1(%edx),%ecx
  800603:	89 08                	mov    %ecx,(%eax)
  800605:	8b 45 08             	mov    0x8(%ebp),%eax
  800608:	88 02                	mov    %al,(%edx)
}
  80060a:	5d                   	pop    %ebp
  80060b:	c3                   	ret    

0080060c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800615:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800619:	8b 45 10             	mov    0x10(%ebp),%eax
  80061c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800620:	8b 45 0c             	mov    0xc(%ebp),%eax
  800623:	89 44 24 04          	mov    %eax,0x4(%esp)
  800627:	8b 45 08             	mov    0x8(%ebp),%eax
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	e8 02 00 00 00       	call   800634 <vprintfmt>
	va_end(ap);
}
  800632:	c9                   	leave  
  800633:	c3                   	ret    

00800634 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	57                   	push   %edi
  800638:	56                   	push   %esi
  800639:	53                   	push   %ebx
  80063a:	83 ec 3c             	sub    $0x3c,%esp
  80063d:	8b 75 08             	mov    0x8(%ebp),%esi
  800640:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800643:	8b 7d 10             	mov    0x10(%ebp),%edi
  800646:	eb 11                	jmp    800659 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800648:	85 c0                	test   %eax,%eax
  80064a:	0f 84 48 04 00 00    	je     800a98 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800659:	83 c7 01             	add    $0x1,%edi
  80065c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800660:	83 f8 25             	cmp    $0x25,%eax
  800663:	75 e3                	jne    800648 <vprintfmt+0x14>
  800665:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800669:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800670:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800677:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	eb 1f                	jmp    8006a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800688:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80068c:	eb 16                	jmp    8006a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800691:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800695:	eb 0d                	jmp    8006a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800697:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8d 47 01             	lea    0x1(%edi),%eax
  8006a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006aa:	0f b6 17             	movzbl (%edi),%edx
  8006ad:	0f b6 c2             	movzbl %dl,%eax
  8006b0:	83 ea 23             	sub    $0x23,%edx
  8006b3:	80 fa 55             	cmp    $0x55,%dl
  8006b6:	0f 87 bf 03 00 00    	ja     800a7b <vprintfmt+0x447>
  8006bc:	0f b6 d2             	movzbl %dl,%edx
  8006bf:	ff 24 95 e0 12 80 00 	jmp    *0x8012e0(,%edx,4)
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006d1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006d4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006d8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8006db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006de:	83 f9 09             	cmp    $0x9,%ecx
  8006e1:	77 3c                	ja     80071f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006e6:	eb e9                	jmp    8006d1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 40 04             	lea    0x4(%eax),%eax
  8006f6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006fc:	eb 27                	jmp    800725 <vprintfmt+0xf1>
  8006fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800701:	85 d2                	test   %edx,%edx
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	0f 49 c2             	cmovns %edx,%eax
  80070b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800711:	eb 91                	jmp    8006a4 <vprintfmt+0x70>
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800716:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80071d:	eb 85                	jmp    8006a4 <vprintfmt+0x70>
  80071f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800722:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800725:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800729:	0f 89 75 ff ff ff    	jns    8006a4 <vprintfmt+0x70>
  80072f:	e9 63 ff ff ff       	jmp    800697 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800734:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80073a:	e9 65 ff ff ff       	jmp    8006a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800742:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800754:	e9 00 ff ff ff       	jmp    800659 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80075c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	99                   	cltd   
  800763:	31 d0                	xor    %edx,%eax
  800765:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800767:	83 f8 0f             	cmp    $0xf,%eax
  80076a:	7f 0b                	jg     800777 <vprintfmt+0x143>
  80076c:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800773:	85 d2                	test   %edx,%edx
  800775:	75 20                	jne    800797 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800777:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077b:	c7 44 24 08 bf 11 80 	movl   $0x8011bf,0x8(%esp)
  800782:	00 
  800783:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800787:	89 34 24             	mov    %esi,(%esp)
  80078a:	e8 7d fe ff ff       	call   80060c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800792:	e9 c2 fe ff ff       	jmp    800659 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800797:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079b:	c7 44 24 08 c8 11 80 	movl   $0x8011c8,0x8(%esp)
  8007a2:	00 
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 34 24             	mov    %esi,(%esp)
  8007aa:	e8 5d fe ff ff       	call   80060c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b2:	e9 a2 fe ff ff       	jmp    800659 <vprintfmt+0x25>
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007c3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007c9:	85 ff                	test   %edi,%edi
  8007cb:	b8 b8 11 80 00       	mov    $0x8011b8,%eax
  8007d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007d7:	0f 84 92 00 00 00    	je     80086f <vprintfmt+0x23b>
  8007dd:	85 c9                	test   %ecx,%ecx
  8007df:	0f 8e 98 00 00 00    	jle    80087d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e9:	89 3c 24             	mov    %edi,(%esp)
  8007ec:	e8 47 03 00 00       	call   800b38 <strnlen>
  8007f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007f4:	29 c1                	sub    %eax,%ecx
  8007f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800800:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800803:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800805:	eb 0f                	jmp    800816 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800807:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800813:	83 ef 01             	sub    $0x1,%edi
  800816:	85 ff                	test   %edi,%edi
  800818:	7f ed                	jg     800807 <vprintfmt+0x1d3>
  80081a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80081d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800820:	85 c9                	test   %ecx,%ecx
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	0f 49 c1             	cmovns %ecx,%eax
  80082a:	29 c1                	sub    %eax,%ecx
  80082c:	89 75 08             	mov    %esi,0x8(%ebp)
  80082f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800832:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800835:	89 cb                	mov    %ecx,%ebx
  800837:	eb 50                	jmp    800889 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800839:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80083d:	74 1e                	je     80085d <vprintfmt+0x229>
  80083f:	0f be d2             	movsbl %dl,%edx
  800842:	83 ea 20             	sub    $0x20,%edx
  800845:	83 fa 5e             	cmp    $0x5e,%edx
  800848:	76 13                	jbe    80085d <vprintfmt+0x229>
					putch('?', putdat);
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800858:	ff 55 08             	call   *0x8(%ebp)
  80085b:	eb 0d                	jmp    80086a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80086a:	83 eb 01             	sub    $0x1,%ebx
  80086d:	eb 1a                	jmp    800889 <vprintfmt+0x255>
  80086f:	89 75 08             	mov    %esi,0x8(%ebp)
  800872:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800875:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800878:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80087b:	eb 0c                	jmp    800889 <vprintfmt+0x255>
  80087d:	89 75 08             	mov    %esi,0x8(%ebp)
  800880:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800883:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800886:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800889:	83 c7 01             	add    $0x1,%edi
  80088c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800890:	0f be c2             	movsbl %dl,%eax
  800893:	85 c0                	test   %eax,%eax
  800895:	74 25                	je     8008bc <vprintfmt+0x288>
  800897:	85 f6                	test   %esi,%esi
  800899:	78 9e                	js     800839 <vprintfmt+0x205>
  80089b:	83 ee 01             	sub    $0x1,%esi
  80089e:	79 99                	jns    800839 <vprintfmt+0x205>
  8008a0:	89 df                	mov    %ebx,%edi
  8008a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a8:	eb 1a                	jmp    8008c4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008b7:	83 ef 01             	sub    $0x1,%edi
  8008ba:	eb 08                	jmp    8008c4 <vprintfmt+0x290>
  8008bc:	89 df                	mov    %ebx,%edi
  8008be:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c4:	85 ff                	test   %edi,%edi
  8008c6:	7f e2                	jg     8008aa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cb:	e9 89 fd ff ff       	jmp    800659 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d0:	83 f9 01             	cmp    $0x1,%ecx
  8008d3:	7e 19                	jle    8008ee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8b 50 04             	mov    0x4(%eax),%edx
  8008db:	8b 00                	mov    (%eax),%eax
  8008dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8d 40 08             	lea    0x8(%eax),%eax
  8008e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ec:	eb 38                	jmp    800926 <vprintfmt+0x2f2>
	else if (lflag)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 1b                	je     80090d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8b 00                	mov    (%eax),%eax
  8008f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008fa:	89 c1                	mov    %eax,%ecx
  8008fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 40 04             	lea    0x4(%eax),%eax
  800908:	89 45 14             	mov    %eax,0x14(%ebp)
  80090b:	eb 19                	jmp    800926 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8b 00                	mov    (%eax),%eax
  800912:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800915:	89 c1                	mov    %eax,%ecx
  800917:	c1 f9 1f             	sar    $0x1f,%ecx
  80091a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8d 40 04             	lea    0x4(%eax),%eax
  800923:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800926:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800929:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80092c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800931:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800935:	0f 89 04 01 00 00    	jns    800a3f <vprintfmt+0x40b>
				putch('-', putdat);
  80093b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800946:	ff d6                	call   *%esi
				num = -(long long) num;
  800948:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80094b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80094e:	f7 da                	neg    %edx
  800950:	83 d1 00             	adc    $0x0,%ecx
  800953:	f7 d9                	neg    %ecx
  800955:	e9 e5 00 00 00       	jmp    800a3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80095a:	83 f9 01             	cmp    $0x1,%ecx
  80095d:	7e 10                	jle    80096f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8b 10                	mov    (%eax),%edx
  800964:	8b 48 04             	mov    0x4(%eax),%ecx
  800967:	8d 40 08             	lea    0x8(%eax),%eax
  80096a:	89 45 14             	mov    %eax,0x14(%ebp)
  80096d:	eb 26                	jmp    800995 <vprintfmt+0x361>
	else if (lflag)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 12                	je     800985 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8b 10                	mov    (%eax),%edx
  800978:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097d:	8d 40 04             	lea    0x4(%eax),%eax
  800980:	89 45 14             	mov    %eax,0x14(%ebp)
  800983:	eb 10                	jmp    800995 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8b 10                	mov    (%eax),%edx
  80098a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098f:	8d 40 04             	lea    0x4(%eax),%eax
  800992:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800995:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80099a:	e9 a0 00 00 00       	jmp    800a3f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80099f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8009ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009b7:	ff d6                	call   *%esi
			putch('X', putdat);
  8009b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009c4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009c9:	e9 8b fc ff ff       	jmp    800659 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8009ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009df:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009e6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8b 10                	mov    (%eax),%edx
  8009ed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009f2:	8d 40 04             	lea    0x4(%eax),%eax
  8009f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009f8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009fd:	eb 40                	jmp    800a3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009ff:	83 f9 01             	cmp    $0x1,%ecx
  800a02:	7e 10                	jle    800a14 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800a04:	8b 45 14             	mov    0x14(%ebp),%eax
  800a07:	8b 10                	mov    (%eax),%edx
  800a09:	8b 48 04             	mov    0x4(%eax),%ecx
  800a0c:	8d 40 08             	lea    0x8(%eax),%eax
  800a0f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a12:	eb 26                	jmp    800a3a <vprintfmt+0x406>
	else if (lflag)
  800a14:	85 c9                	test   %ecx,%ecx
  800a16:	74 12                	je     800a2a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8b 10                	mov    (%eax),%edx
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	8d 40 04             	lea    0x4(%eax),%eax
  800a25:	89 45 14             	mov    %eax,0x14(%ebp)
  800a28:	eb 10                	jmp    800a3a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2d:	8b 10                	mov    (%eax),%edx
  800a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a34:	8d 40 04             	lea    0x4(%eax),%eax
  800a37:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a3a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a3f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a52:	89 14 24             	mov    %edx,(%esp)
  800a55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a59:	89 da                	mov    %ebx,%edx
  800a5b:	89 f0                	mov    %esi,%eax
  800a5d:	e8 9e fa ff ff       	call   800500 <printnum>
			break;
  800a62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a65:	e9 ef fb ff ff       	jmp    800659 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6e:	89 04 24             	mov    %eax,(%esp)
  800a71:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a76:	e9 de fb ff ff       	jmp    800659 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a88:	eb 03                	jmp    800a8d <vprintfmt+0x459>
  800a8a:	83 ef 01             	sub    $0x1,%edi
  800a8d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a91:	75 f7                	jne    800a8a <vprintfmt+0x456>
  800a93:	e9 c1 fb ff ff       	jmp    800659 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a98:	83 c4 3c             	add    $0x3c,%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 28             	sub    $0x28,%esp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aaf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abd:	85 c0                	test   %eax,%eax
  800abf:	74 30                	je     800af1 <vsnprintf+0x51>
  800ac1:	85 d2                	test   %edx,%edx
  800ac3:	7e 2c                	jle    800af1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800acc:	8b 45 10             	mov    0x10(%ebp),%eax
  800acf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ada:	c7 04 24 ef 05 80 00 	movl   $0x8005ef,(%esp)
  800ae1:	e8 4e fb ff ff       	call   800634 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aef:	eb 05                	jmp    800af6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800af1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800afe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b05:	8b 45 10             	mov    0x10(%ebp),%eax
  800b08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	89 04 24             	mov    %eax,(%esp)
  800b19:	e8 82 ff ff ff       	call   800aa0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

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
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
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
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b61:	89 c2                	mov    %eax,%edx
  800b63:	83 c2 01             	add    $0x1,%edx
  800b66:	83 c1 01             	add    $0x1,%ecx
  800b69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b70:	84 db                	test   %bl,%bl
  800b72:	75 ef                	jne    800b63 <strcpy+0xc>
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
  800ba7:	8b 75 08             	mov    0x8(%ebp),%esi
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb2:	89 f2                	mov    %esi,%edx
  800bb4:	eb 0f                	jmp    800bc5 <strncpy+0x23>
		*dst++ = *src;
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	0f b6 01             	movzbl (%ecx),%eax
  800bbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bbf:	80 39 01             	cmpb   $0x1,(%ecx)
  800bc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc5:	39 da                	cmp    %ebx,%edx
  800bc7:	75 ed                	jne    800bb6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc9:	89 f0                	mov    %esi,%eax
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bda:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bdd:	89 f0                	mov    %esi,%eax
  800bdf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800be3:	85 c9                	test   %ecx,%ecx
  800be5:	75 0b                	jne    800bf2 <strlcpy+0x23>
  800be7:	eb 1d                	jmp    800c06 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800be9:	83 c0 01             	add    $0x1,%eax
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf2:	39 d8                	cmp    %ebx,%eax
  800bf4:	74 0b                	je     800c01 <strlcpy+0x32>
  800bf6:	0f b6 0a             	movzbl (%edx),%ecx
  800bf9:	84 c9                	test   %cl,%cl
  800bfb:	75 ec                	jne    800be9 <strlcpy+0x1a>
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	eb 02                	jmp    800c03 <strlcpy+0x34>
  800c01:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c03:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c06:	29 f0                	sub    %esi,%eax
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c15:	eb 06                	jmp    800c1d <strcmp+0x11>
		p++, q++;
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c1d:	0f b6 01             	movzbl (%ecx),%eax
  800c20:	84 c0                	test   %al,%al
  800c22:	74 04                	je     800c28 <strcmp+0x1c>
  800c24:	3a 02                	cmp    (%edx),%al
  800c26:	74 ef                	je     800c17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c28:	0f b6 c0             	movzbl %al,%eax
  800c2b:	0f b6 12             	movzbl (%edx),%edx
  800c2e:	29 d0                	sub    %edx,%eax
}
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	53                   	push   %ebx
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3c:	89 c3                	mov    %eax,%ebx
  800c3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c41:	eb 06                	jmp    800c49 <strncmp+0x17>
		n--, p++, q++;
  800c43:	83 c0 01             	add    $0x1,%eax
  800c46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c49:	39 d8                	cmp    %ebx,%eax
  800c4b:	74 15                	je     800c62 <strncmp+0x30>
  800c4d:	0f b6 08             	movzbl (%eax),%ecx
  800c50:	84 c9                	test   %cl,%cl
  800c52:	74 04                	je     800c58 <strncmp+0x26>
  800c54:	3a 0a                	cmp    (%edx),%cl
  800c56:	74 eb                	je     800c43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c58:	0f b6 00             	movzbl (%eax),%eax
  800c5b:	0f b6 12             	movzbl (%edx),%edx
  800c5e:	29 d0                	sub    %edx,%eax
  800c60:	eb 05                	jmp    800c67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c67:	5b                   	pop    %ebx
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c74:	eb 07                	jmp    800c7d <strchr+0x13>
		if (*s == c)
  800c76:	38 ca                	cmp    %cl,%dl
  800c78:	74 0f                	je     800c89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	0f b6 10             	movzbl (%eax),%edx
  800c80:	84 d2                	test   %dl,%dl
  800c82:	75 f2                	jne    800c76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c95:	eb 07                	jmp    800c9e <strfind+0x13>
		if (*s == c)
  800c97:	38 ca                	cmp    %cl,%dl
  800c99:	74 0a                	je     800ca5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	0f b6 10             	movzbl (%eax),%edx
  800ca1:	84 d2                	test   %dl,%dl
  800ca3:	75 f2                	jne    800c97 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb3:	85 c9                	test   %ecx,%ecx
  800cb5:	74 36                	je     800ced <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cbd:	75 28                	jne    800ce7 <memset+0x40>
  800cbf:	f6 c1 03             	test   $0x3,%cl
  800cc2:	75 23                	jne    800ce7 <memset+0x40>
		c &= 0xFF;
  800cc4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc8:	89 d3                	mov    %edx,%ebx
  800cca:	c1 e3 08             	shl    $0x8,%ebx
  800ccd:	89 d6                	mov    %edx,%esi
  800ccf:	c1 e6 18             	shl    $0x18,%esi
  800cd2:	89 d0                	mov    %edx,%eax
  800cd4:	c1 e0 10             	shl    $0x10,%eax
  800cd7:	09 f0                	or     %esi,%eax
  800cd9:	09 c2                	or     %eax,%edx
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cdf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ce2:	fc                   	cld    
  800ce3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce5:	eb 06                	jmp    800ced <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	fc                   	cld    
  800ceb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ced:	89 f8                	mov    %edi,%eax
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d02:	39 c6                	cmp    %eax,%esi
  800d04:	73 35                	jae    800d3b <memmove+0x47>
  800d06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d09:	39 d0                	cmp    %edx,%eax
  800d0b:	73 2e                	jae    800d3b <memmove+0x47>
		s += n;
		d += n;
  800d0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d1a:	75 13                	jne    800d2f <memmove+0x3b>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 0e                	jne    800d2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d21:	83 ef 04             	sub    $0x4,%edi
  800d24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d2a:	fd                   	std    
  800d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2d:	eb 09                	jmp    800d38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d2f:	83 ef 01             	sub    $0x1,%edi
  800d32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d35:	fd                   	std    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d38:	fc                   	cld    
  800d39:	eb 1d                	jmp    800d58 <memmove+0x64>
  800d3b:	89 f2                	mov    %esi,%edx
  800d3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3f:	f6 c2 03             	test   $0x3,%dl
  800d42:	75 0f                	jne    800d53 <memmove+0x5f>
  800d44:	f6 c1 03             	test   $0x3,%cl
  800d47:	75 0a                	jne    800d53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d51:	eb 05                	jmp    800d58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	89 c7                	mov    %eax,%edi
  800d55:	fc                   	cld    
  800d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d62:	8b 45 10             	mov    0x10(%ebp),%eax
  800d65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	89 04 24             	mov    %eax,(%esp)
  800d76:	e8 79 ff ff ff       	call   800cf4 <memmove>
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d8d:	eb 1a                	jmp    800da9 <memcmp+0x2c>
		if (*s1 != *s2)
  800d8f:	0f b6 02             	movzbl (%edx),%eax
  800d92:	0f b6 19             	movzbl (%ecx),%ebx
  800d95:	38 d8                	cmp    %bl,%al
  800d97:	74 0a                	je     800da3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d99:	0f b6 c0             	movzbl %al,%eax
  800d9c:	0f b6 db             	movzbl %bl,%ebx
  800d9f:	29 d8                	sub    %ebx,%eax
  800da1:	eb 0f                	jmp    800db2 <memcmp+0x35>
		s1++, s2++;
  800da3:	83 c2 01             	add    $0x1,%edx
  800da6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da9:	39 f2                	cmp    %esi,%edx
  800dab:	75 e2                	jne    800d8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dc4:	eb 07                	jmp    800dcd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dc6:	38 08                	cmp    %cl,(%eax)
  800dc8:	74 07                	je     800dd1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dca:	83 c0 01             	add    $0x1,%eax
  800dcd:	39 d0                	cmp    %edx,%eax
  800dcf:	72 f5                	jb     800dc6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ddf:	eb 03                	jmp    800de4 <strtol+0x11>
		s++;
  800de1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800de4:	0f b6 0a             	movzbl (%edx),%ecx
  800de7:	80 f9 09             	cmp    $0x9,%cl
  800dea:	74 f5                	je     800de1 <strtol+0xe>
  800dec:	80 f9 20             	cmp    $0x20,%cl
  800def:	74 f0                	je     800de1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800df1:	80 f9 2b             	cmp    $0x2b,%cl
  800df4:	75 0a                	jne    800e00 <strtol+0x2d>
		s++;
  800df6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800df9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dfe:	eb 11                	jmp    800e11 <strtol+0x3e>
  800e00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e05:	80 f9 2d             	cmp    $0x2d,%cl
  800e08:	75 07                	jne    800e11 <strtol+0x3e>
		s++, neg = 1;
  800e0a:	8d 52 01             	lea    0x1(%edx),%edx
  800e0d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e11:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e16:	75 15                	jne    800e2d <strtol+0x5a>
  800e18:	80 3a 30             	cmpb   $0x30,(%edx)
  800e1b:	75 10                	jne    800e2d <strtol+0x5a>
  800e1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e21:	75 0a                	jne    800e2d <strtol+0x5a>
		s += 2, base = 16;
  800e23:	83 c2 02             	add    $0x2,%edx
  800e26:	b8 10 00 00 00       	mov    $0x10,%eax
  800e2b:	eb 10                	jmp    800e3d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	75 0c                	jne    800e3d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e31:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e33:	80 3a 30             	cmpb   $0x30,(%edx)
  800e36:	75 05                	jne    800e3d <strtol+0x6a>
		s++, base = 8;
  800e38:	83 c2 01             	add    $0x1,%edx
  800e3b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e42:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e45:	0f b6 0a             	movzbl (%edx),%ecx
  800e48:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e4b:	89 f0                	mov    %esi,%eax
  800e4d:	3c 09                	cmp    $0x9,%al
  800e4f:	77 08                	ja     800e59 <strtol+0x86>
			dig = *s - '0';
  800e51:	0f be c9             	movsbl %cl,%ecx
  800e54:	83 e9 30             	sub    $0x30,%ecx
  800e57:	eb 20                	jmp    800e79 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e59:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e5c:	89 f0                	mov    %esi,%eax
  800e5e:	3c 19                	cmp    $0x19,%al
  800e60:	77 08                	ja     800e6a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e62:	0f be c9             	movsbl %cl,%ecx
  800e65:	83 e9 57             	sub    $0x57,%ecx
  800e68:	eb 0f                	jmp    800e79 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e6a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	3c 19                	cmp    $0x19,%al
  800e71:	77 16                	ja     800e89 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e73:	0f be c9             	movsbl %cl,%ecx
  800e76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e7c:	7d 0f                	jge    800e8d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e7e:	83 c2 01             	add    $0x1,%edx
  800e81:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e85:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e87:	eb bc                	jmp    800e45 <strtol+0x72>
  800e89:	89 d8                	mov    %ebx,%eax
  800e8b:	eb 02                	jmp    800e8f <strtol+0xbc>
  800e8d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e93:	74 05                	je     800e9a <strtol+0xc7>
		*endptr = (char *) s;
  800e95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e98:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e9a:	f7 d8                	neg    %eax
  800e9c:	85 ff                	test   %edi,%edi
  800e9e:	0f 44 c3             	cmove  %ebx,%eax
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
  800ea6:	66 90                	xchg   %ax,%ax
  800ea8:	66 90                	xchg   %ax,%ax
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__udivdi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800ebe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800ec2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ecc:	89 ea                	mov    %ebp,%edx
  800ece:	89 0c 24             	mov    %ecx,(%esp)
  800ed1:	75 2d                	jne    800f00 <__udivdi3+0x50>
  800ed3:	39 e9                	cmp    %ebp,%ecx
  800ed5:	77 61                	ja     800f38 <__udivdi3+0x88>
  800ed7:	85 c9                	test   %ecx,%ecx
  800ed9:	89 ce                	mov    %ecx,%esi
  800edb:	75 0b                	jne    800ee8 <__udivdi3+0x38>
  800edd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee2:	31 d2                	xor    %edx,%edx
  800ee4:	f7 f1                	div    %ecx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	89 e8                	mov    %ebp,%eax
  800eec:	f7 f6                	div    %esi
  800eee:	89 c5                	mov    %eax,%ebp
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	f7 f6                	div    %esi
  800ef4:	89 ea                	mov    %ebp,%edx
  800ef6:	83 c4 0c             	add    $0xc,%esp
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	39 e8                	cmp    %ebp,%eax
  800f02:	77 24                	ja     800f28 <__udivdi3+0x78>
  800f04:	0f bd e8             	bsr    %eax,%ebp
  800f07:	83 f5 1f             	xor    $0x1f,%ebp
  800f0a:	75 3c                	jne    800f48 <__udivdi3+0x98>
  800f0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f10:	39 34 24             	cmp    %esi,(%esp)
  800f13:	0f 86 9f 00 00 00    	jbe    800fb8 <__udivdi3+0x108>
  800f19:	39 d0                	cmp    %edx,%eax
  800f1b:	0f 82 97 00 00 00    	jb     800fb8 <__udivdi3+0x108>
  800f21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	31 c0                	xor    %eax,%eax
  800f2c:	83 c4 0c             	add    $0xc,%esp
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    
  800f33:	90                   	nop
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	89 f8                	mov    %edi,%eax
  800f3a:	f7 f1                	div    %ecx
  800f3c:	31 d2                	xor    %edx,%edx
  800f3e:	83 c4 0c             	add    $0xc,%esp
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	8b 3c 24             	mov    (%esp),%edi
  800f4d:	d3 e0                	shl    %cl,%eax
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	b8 20 00 00 00       	mov    $0x20,%eax
  800f56:	29 e8                	sub    %ebp,%eax
  800f58:	89 c1                	mov    %eax,%ecx
  800f5a:	d3 ef                	shr    %cl,%edi
  800f5c:	89 e9                	mov    %ebp,%ecx
  800f5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f62:	8b 3c 24             	mov    (%esp),%edi
  800f65:	09 74 24 08          	or     %esi,0x8(%esp)
  800f69:	89 d6                	mov    %edx,%esi
  800f6b:	d3 e7                	shl    %cl,%edi
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	89 3c 24             	mov    %edi,(%esp)
  800f72:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f76:	d3 ee                	shr    %cl,%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	d3 e2                	shl    %cl,%edx
  800f7c:	89 c1                	mov    %eax,%ecx
  800f7e:	d3 ef                	shr    %cl,%edi
  800f80:	09 d7                	or     %edx,%edi
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	89 f8                	mov    %edi,%eax
  800f86:	f7 74 24 08          	divl   0x8(%esp)
  800f8a:	89 d6                	mov    %edx,%esi
  800f8c:	89 c7                	mov    %eax,%edi
  800f8e:	f7 24 24             	mull   (%esp)
  800f91:	39 d6                	cmp    %edx,%esi
  800f93:	89 14 24             	mov    %edx,(%esp)
  800f96:	72 30                	jb     800fc8 <__udivdi3+0x118>
  800f98:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f9c:	89 e9                	mov    %ebp,%ecx
  800f9e:	d3 e2                	shl    %cl,%edx
  800fa0:	39 c2                	cmp    %eax,%edx
  800fa2:	73 05                	jae    800fa9 <__udivdi3+0xf9>
  800fa4:	3b 34 24             	cmp    (%esp),%esi
  800fa7:	74 1f                	je     800fc8 <__udivdi3+0x118>
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	e9 7a ff ff ff       	jmp    800f2c <__udivdi3+0x7c>
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbf:	e9 68 ff ff ff       	jmp    800f2c <__udivdi3+0x7c>
  800fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	83 c4 0c             	add    $0xc,%esp
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    
  800fd4:	66 90                	xchg   %ax,%ax
  800fd6:	66 90                	xchg   %ax,%ax
  800fd8:	66 90                	xchg   %ax,%ax
  800fda:	66 90                	xchg   %ax,%ax
  800fdc:	66 90                	xchg   %ax,%ax
  800fde:	66 90                	xchg   %ax,%ax

00800fe0 <__umoddi3>:
  800fe0:	55                   	push   %ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	83 ec 14             	sub    $0x14,%esp
  800fe6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800ff2:	89 c7                	mov    %eax,%edi
  800ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ffc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801000:	89 34 24             	mov    %esi,(%esp)
  801003:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801007:	85 c0                	test   %eax,%eax
  801009:	89 c2                	mov    %eax,%edx
  80100b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80100f:	75 17                	jne    801028 <__umoddi3+0x48>
  801011:	39 fe                	cmp    %edi,%esi
  801013:	76 4b                	jbe    801060 <__umoddi3+0x80>
  801015:	89 c8                	mov    %ecx,%eax
  801017:	89 fa                	mov    %edi,%edx
  801019:	f7 f6                	div    %esi
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	83 c4 14             	add    $0x14,%esp
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
  801026:	66 90                	xchg   %ax,%ax
  801028:	39 f8                	cmp    %edi,%eax
  80102a:	77 54                	ja     801080 <__umoddi3+0xa0>
  80102c:	0f bd e8             	bsr    %eax,%ebp
  80102f:	83 f5 1f             	xor    $0x1f,%ebp
  801032:	75 5c                	jne    801090 <__umoddi3+0xb0>
  801034:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801038:	39 3c 24             	cmp    %edi,(%esp)
  80103b:	0f 87 e7 00 00 00    	ja     801128 <__umoddi3+0x148>
  801041:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801045:	29 f1                	sub    %esi,%ecx
  801047:	19 c7                	sbb    %eax,%edi
  801049:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801051:	8b 44 24 08          	mov    0x8(%esp),%eax
  801055:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801059:	83 c4 14             	add    $0x14,%esp
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    
  801060:	85 f6                	test   %esi,%esi
  801062:	89 f5                	mov    %esi,%ebp
  801064:	75 0b                	jne    801071 <__umoddi3+0x91>
  801066:	b8 01 00 00 00       	mov    $0x1,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f6                	div    %esi
  80106f:	89 c5                	mov    %eax,%ebp
  801071:	8b 44 24 04          	mov    0x4(%esp),%eax
  801075:	31 d2                	xor    %edx,%edx
  801077:	f7 f5                	div    %ebp
  801079:	89 c8                	mov    %ecx,%eax
  80107b:	f7 f5                	div    %ebp
  80107d:	eb 9c                	jmp    80101b <__umoddi3+0x3b>
  80107f:	90                   	nop
  801080:	89 c8                	mov    %ecx,%eax
  801082:	89 fa                	mov    %edi,%edx
  801084:	83 c4 14             	add    $0x14,%esp
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
  80108b:	90                   	nop
  80108c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801090:	8b 04 24             	mov    (%esp),%eax
  801093:	be 20 00 00 00       	mov    $0x20,%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	29 ee                	sub    %ebp,%esi
  80109c:	d3 e2                	shl    %cl,%edx
  80109e:	89 f1                	mov    %esi,%ecx
  8010a0:	d3 e8                	shr    %cl,%eax
  8010a2:	89 e9                	mov    %ebp,%ecx
  8010a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a8:	8b 04 24             	mov    (%esp),%eax
  8010ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8010af:	89 fa                	mov    %edi,%edx
  8010b1:	d3 e0                	shl    %cl,%eax
  8010b3:	89 f1                	mov    %esi,%ecx
  8010b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010bd:	d3 ea                	shr    %cl,%edx
  8010bf:	89 e9                	mov    %ebp,%ecx
  8010c1:	d3 e7                	shl    %cl,%edi
  8010c3:	89 f1                	mov    %esi,%ecx
  8010c5:	d3 e8                	shr    %cl,%eax
  8010c7:	89 e9                	mov    %ebp,%ecx
  8010c9:	09 f8                	or     %edi,%eax
  8010cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010cf:	f7 74 24 04          	divl   0x4(%esp)
  8010d3:	d3 e7                	shl    %cl,%edi
  8010d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010d9:	89 d7                	mov    %edx,%edi
  8010db:	f7 64 24 08          	mull   0x8(%esp)
  8010df:	39 d7                	cmp    %edx,%edi
  8010e1:	89 c1                	mov    %eax,%ecx
  8010e3:	89 14 24             	mov    %edx,(%esp)
  8010e6:	72 2c                	jb     801114 <__umoddi3+0x134>
  8010e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8010ec:	72 22                	jb     801110 <__umoddi3+0x130>
  8010ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010f2:	29 c8                	sub    %ecx,%eax
  8010f4:	19 d7                	sbb    %edx,%edi
  8010f6:	89 e9                	mov    %ebp,%ecx
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	d3 e8                	shr    %cl,%eax
  8010fc:	89 f1                	mov    %esi,%ecx
  8010fe:	d3 e2                	shl    %cl,%edx
  801100:	89 e9                	mov    %ebp,%ecx
  801102:	d3 ef                	shr    %cl,%edi
  801104:	09 d0                	or     %edx,%eax
  801106:	89 fa                	mov    %edi,%edx
  801108:	83 c4 14             	add    $0x14,%esp
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    
  80110f:	90                   	nop
  801110:	39 d7                	cmp    %edx,%edi
  801112:	75 da                	jne    8010ee <__umoddi3+0x10e>
  801114:	8b 14 24             	mov    (%esp),%edx
  801117:	89 c1                	mov    %eax,%ecx
  801119:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80111d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801121:	eb cb                	jmp    8010ee <__umoddi3+0x10e>
  801123:	90                   	nop
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80112c:	0f 82 0f ff ff ff    	jb     801041 <__umoddi3+0x61>
  801132:	e9 1a ff ff ff       	jmp    801051 <__umoddi3+0x71>
