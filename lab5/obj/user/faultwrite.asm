
obj/user/faultwrite.debug：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800050:	e8 d8 00 00 00       	call   80012d <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800097:	e8 3f 00 00 00       	call   8000db <sys_env_destroy>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 28                	jle    800125 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800101:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800110:	00 
  800111:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800118:	00 
  800119:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800120:	e8 ae 02 00 00       	call   8003d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800125:	83 c4 2c             	add    $0x2c,%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_yield>:

void
sys_yield(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	be 00 00 00 00       	mov    $0x0,%esi
  800179:	b8 04 00 00 00       	mov    $0x4,%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800187:	89 f7                	mov    %esi,%edi
  800189:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018b:	85 c0                	test   %eax,%eax
  80018d:	7e 28                	jle    8001b7 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800193:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019a:	00 
  80019b:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001a2:	00 
  8001a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001aa:	00 
  8001ab:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8001b2:	e8 1c 02 00 00       	call   8003d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b7:	83 c4 2c             	add    $0x2c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    

008001bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	57                   	push   %edi
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7e 28                	jle    80020a <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800205:	e8 c9 01 00 00       	call   8003d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020a:	83 c4 2c             	add    $0x2c,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7e 28                	jle    80025d <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	89 44 24 10          	mov    %eax,0x10(%esp)
  800239:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800240:	00 
  800241:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800248:	00 
  800249:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800250:	00 
  800251:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800258:	e8 76 01 00 00       	call   8003d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025d:	83 c4 2c             	add    $0x2c,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 28                	jle    8002b0 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800293:	00 
  800294:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  80029b:	00 
  80029c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a3:	00 
  8002a4:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002ab:	e8 23 01 00 00       	call   8003d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b0:	83 c4 2c             	add    $0x2c,%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 df                	mov    %ebx,%edi
  8002d3:	89 de                	mov    %ebx,%esi
  8002d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 28                	jle    800303 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002df:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f6:	00 
  8002f7:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8002fe:	e8 d0 00 00 00       	call   8003d3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800303:	83 c4 2c             	add    $0x2c,%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	bb 00 00 00 00       	mov    $0x0,%ebx
  800319:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 df                	mov    %ebx,%edi
  800326:	89 de                	mov    %ebx,%esi
  800328:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	7e 28                	jle    800356 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800332:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800339:	00 
  80033a:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  800341:	00 
  800342:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  800351:	e8 7d 00 00 00       	call   8003d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800356:	83 c4 2c             	add    $0x2c,%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	be 00 00 00 00       	mov    $0x0,%esi
  800369:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800377:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	57                   	push   %edi
  800385:	56                   	push   %esi
  800386:	53                   	push   %ebx
  800387:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	89 cb                	mov    %ecx,%ebx
  800399:	89 cf                	mov    %ecx,%edi
  80039b:	89 ce                	mov    %ecx,%esi
  80039d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	7e 28                	jle    8003cb <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ae:	00 
  8003af:	c7 44 24 08 4a 11 80 	movl   $0x80114a,0x8(%esp)
  8003b6:	00 
  8003b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003be:	00 
  8003bf:	c7 04 24 67 11 80 00 	movl   $0x801167,(%esp)
  8003c6:	e8 08 00 00 00       	call   8003d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003cb:	83 c4 2c             	add    $0x2c,%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003de:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003e4:	e8 44 fd ff ff       	call   80012d <sys_getenvid>
  8003e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  800406:	e8 c1 00 00 00       	call   8004cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80040b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040f:	8b 45 10             	mov    0x10(%ebp),%eax
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	e8 51 00 00 00       	call   80046b <vcprintf>
	cprintf("\n");
  80041a:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800421:	e8 a6 00 00 00       	call   8004cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800426:	cc                   	int3   
  800427:	eb fd                	jmp    800426 <_panic+0x53>

00800429 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	53                   	push   %ebx
  80042d:	83 ec 14             	sub    $0x14,%esp
  800430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800433:	8b 13                	mov    (%ebx),%edx
  800435:	8d 42 01             	lea    0x1(%edx),%eax
  800438:	89 03                	mov    %eax,(%ebx)
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800441:	3d ff 00 00 00       	cmp    $0xff,%eax
  800446:	75 19                	jne    800461 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800448:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80044f:	00 
  800450:	8d 43 08             	lea    0x8(%ebx),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	e8 43 fc ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80045b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800461:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800465:	83 c4 14             	add    $0x14,%esp
  800468:	5b                   	pop    %ebx
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800474:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047b:	00 00 00 
	b.cnt = 0;
  80047e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800485:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048f:	8b 45 08             	mov    0x8(%ebp),%eax
  800492:	89 44 24 08          	mov    %eax,0x8(%esp)
  800496:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	c7 04 24 29 04 80 00 	movl   $0x800429,(%esp)
  8004a7:	e8 78 01 00 00       	call   800624 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	e8 da fb ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8004c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 87 ff ff ff       	call   80046b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    
  8004e6:	66 90                	xchg   %ax,%ax
  8004e8:	66 90                	xchg   %ax,%ax
  8004ea:	66 90                	xchg   %ax,%ax
  8004ec:	66 90                	xchg   %ax,%ax
  8004ee:	66 90                	xchg   %ax,%ax

008004f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 3c             	sub    $0x3c,%esp
  8004f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fc:	89 d7                	mov    %edx,%edi
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 c3                	mov    %eax,%ebx
  800509:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80050c:	8b 45 10             	mov    0x10(%ebp),%eax
  80050f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051d:	39 d9                	cmp    %ebx,%ecx
  80051f:	72 05                	jb     800526 <printnum+0x36>
  800521:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800524:	77 69                	ja     80058f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800526:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800529:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80052d:	83 ee 01             	sub    $0x1,%esi
  800530:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800534:	89 44 24 08          	mov    %eax,0x8(%esp)
  800538:	8b 44 24 08          	mov    0x8(%esp),%eax
  80053c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800540:	89 c3                	mov    %eax,%ebx
  800542:	89 d6                	mov    %edx,%esi
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80054e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 3c 09 00 00       	call   800ea0 <__udivdi3>
  800564:	89 d9                	mov    %ebx,%ecx
  800566:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80056a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	89 54 24 04          	mov    %edx,0x4(%esp)
  800575:	89 fa                	mov    %edi,%edx
  800577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057a:	e8 71 ff ff ff       	call   8004f0 <printnum>
  80057f:	eb 1b                	jmp    80059c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800581:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800585:	8b 45 18             	mov    0x18(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	ff d3                	call   *%ebx
  80058d:	eb 03                	jmp    800592 <printnum+0xa2>
  80058f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800592:	83 ee 01             	sub    $0x1,%esi
  800595:	85 f6                	test   %esi,%esi
  800597:	7f e8                	jg     800581 <printnum+0x91>
  800599:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80059c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	e8 0c 0a 00 00       	call   800fd0 <__umoddi3>
  8005c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c8:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d5:	ff d0                	call   *%eax
}
  8005d7:	83 c4 3c             	add    $0x3c,%esp
  8005da:	5b                   	pop    %ebx
  8005db:	5e                   	pop    %esi
  8005dc:	5f                   	pop    %edi
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ee:	73 0a                	jae    8005fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8005f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005f3:	89 08                	mov    %ecx,(%eax)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	88 02                	mov    %al,(%edx)
}
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    

008005fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800605:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800609:	8b 45 10             	mov    0x10(%ebp),%eax
  80060c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 02 00 00 00       	call   800624 <vprintfmt>
	va_end(ap);
}
  800622:	c9                   	leave  
  800623:	c3                   	ret    

00800624 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	57                   	push   %edi
  800628:	56                   	push   %esi
  800629:	53                   	push   %ebx
  80062a:	83 ec 3c             	sub    $0x3c,%esp
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	8b 7d 10             	mov    0x10(%ebp),%edi
  800636:	eb 11                	jmp    800649 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800638:	85 c0                	test   %eax,%eax
  80063a:	0f 84 48 04 00 00    	je     800a88 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800649:	83 c7 01             	add    $0x1,%edi
  80064c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800650:	83 f8 25             	cmp    $0x25,%eax
  800653:	75 e3                	jne    800638 <vprintfmt+0x14>
  800655:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800659:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800660:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800667:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	eb 1f                	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800678:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800681:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800685:	eb 0d                	jmp    800694 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800687:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80068a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8d 47 01             	lea    0x1(%edi),%eax
  800697:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069a:	0f b6 17             	movzbl (%edi),%edx
  80069d:	0f b6 c2             	movzbl %dl,%eax
  8006a0:	83 ea 23             	sub    $0x23,%edx
  8006a3:	80 fa 55             	cmp    $0x55,%dl
  8006a6:	0f 87 bf 03 00 00    	ja     800a6b <vprintfmt+0x447>
  8006ac:	0f b6 d2             	movzbl %dl,%edx
  8006af:	ff 24 95 e0 12 80 00 	jmp    *0x8012e0(,%edx,4)
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006c4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006c8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8006cb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006ce:	83 f9 09             	cmp    $0x9,%ecx
  8006d1:	77 3c                	ja     80070f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d6:	eb e9                	jmp    8006c1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ec:	eb 27                	jmp    800715 <vprintfmt+0xf1>
  8006ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	0f 49 c2             	cmovns %edx,%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800701:	eb 91                	jmp    800694 <vprintfmt+0x70>
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800706:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80070d:	eb 85                	jmp    800694 <vprintfmt+0x70>
  80070f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800712:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800715:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800719:	0f 89 75 ff ff ff    	jns    800694 <vprintfmt+0x70>
  80071f:	e9 63 ff ff ff       	jmp    800687 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800724:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80072a:	e9 65 ff ff ff       	jmp    800694 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800732:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800744:	e9 00 ff ff ff       	jmp    800649 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80074c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800750:	8b 00                	mov    (%eax),%eax
  800752:	99                   	cltd   
  800753:	31 d0                	xor    %edx,%eax
  800755:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800757:	83 f8 0f             	cmp    $0xf,%eax
  80075a:	7f 0b                	jg     800767 <vprintfmt+0x143>
  80075c:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	75 20                	jne    800787 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800767:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076b:	c7 44 24 08 b5 11 80 	movl   $0x8011b5,0x8(%esp)
  800772:	00 
  800773:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800777:	89 34 24             	mov    %esi,(%esp)
  80077a:	e8 7d fe ff ff       	call   8005fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800782:	e9 c2 fe ff ff       	jmp    800649 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800787:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078b:	c7 44 24 08 be 11 80 	movl   $0x8011be,0x8(%esp)
  800792:	00 
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	89 34 24             	mov    %esi,(%esp)
  80079a:	e8 5d fe ff ff       	call   8005fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a2:	e9 a2 fe ff ff       	jmp    800649 <vprintfmt+0x25>
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007b9:	85 ff                	test   %edi,%edi
  8007bb:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  8007c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007c7:	0f 84 92 00 00 00    	je     80085f <vprintfmt+0x23b>
  8007cd:	85 c9                	test   %ecx,%ecx
  8007cf:	0f 8e 98 00 00 00    	jle    80086d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d9:	89 3c 24             	mov    %edi,(%esp)
  8007dc:	e8 47 03 00 00       	call   800b28 <strnlen>
  8007e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e4:	29 c1                	sub    %eax,%ecx
  8007e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f5:	eb 0f                	jmp    800806 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007fe:	89 04 24             	mov    %eax,(%esp)
  800801:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800803:	83 ef 01             	sub    $0x1,%edi
  800806:	85 ff                	test   %edi,%edi
  800808:	7f ed                	jg     8007f7 <vprintfmt+0x1d3>
  80080a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80080d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800810:	85 c9                	test   %ecx,%ecx
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	0f 49 c1             	cmovns %ecx,%eax
  80081a:	29 c1                	sub    %eax,%ecx
  80081c:	89 75 08             	mov    %esi,0x8(%ebp)
  80081f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800822:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800825:	89 cb                	mov    %ecx,%ebx
  800827:	eb 50                	jmp    800879 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800829:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80082d:	74 1e                	je     80084d <vprintfmt+0x229>
  80082f:	0f be d2             	movsbl %dl,%edx
  800832:	83 ea 20             	sub    $0x20,%edx
  800835:	83 fa 5e             	cmp    $0x5e,%edx
  800838:	76 13                	jbe    80084d <vprintfmt+0x229>
					putch('?', putdat);
  80083a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800848:	ff 55 08             	call   *0x8(%ebp)
  80084b:	eb 0d                	jmp    80085a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80085a:	83 eb 01             	sub    $0x1,%ebx
  80085d:	eb 1a                	jmp    800879 <vprintfmt+0x255>
  80085f:	89 75 08             	mov    %esi,0x8(%ebp)
  800862:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800865:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800868:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80086b:	eb 0c                	jmp    800879 <vprintfmt+0x255>
  80086d:	89 75 08             	mov    %esi,0x8(%ebp)
  800870:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800873:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800876:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800879:	83 c7 01             	add    $0x1,%edi
  80087c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800880:	0f be c2             	movsbl %dl,%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	74 25                	je     8008ac <vprintfmt+0x288>
  800887:	85 f6                	test   %esi,%esi
  800889:	78 9e                	js     800829 <vprintfmt+0x205>
  80088b:	83 ee 01             	sub    $0x1,%esi
  80088e:	79 99                	jns    800829 <vprintfmt+0x205>
  800890:	89 df                	mov    %ebx,%edi
  800892:	8b 75 08             	mov    0x8(%ebp),%esi
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800898:	eb 1a                	jmp    8008b4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80089a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008a7:	83 ef 01             	sub    $0x1,%edi
  8008aa:	eb 08                	jmp    8008b4 <vprintfmt+0x290>
  8008ac:	89 df                	mov    %ebx,%edi
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b4:	85 ff                	test   %edi,%edi
  8008b6:	7f e2                	jg     80089a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008bb:	e9 89 fd ff ff       	jmp    800649 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008c0:	83 f9 01             	cmp    $0x1,%ecx
  8008c3:	7e 19                	jle    8008de <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 50 04             	mov    0x4(%eax),%edx
  8008cb:	8b 00                	mov    (%eax),%eax
  8008cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8d 40 08             	lea    0x8(%eax),%eax
  8008d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008dc:	eb 38                	jmp    800916 <vprintfmt+0x2f2>
	else if (lflag)
  8008de:	85 c9                	test   %ecx,%ecx
  8008e0:	74 1b                	je     8008fd <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 00                	mov    (%eax),%eax
  8008e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ea:	89 c1                	mov    %eax,%ecx
  8008ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8008ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 40 04             	lea    0x4(%eax),%eax
  8008f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008fb:	eb 19                	jmp    800916 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 00                	mov    (%eax),%eax
  800902:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800905:	89 c1                	mov    %eax,%ecx
  800907:	c1 f9 1f             	sar    $0x1f,%ecx
  80090a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 40 04             	lea    0x4(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800916:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800919:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80091c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800921:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800925:	0f 89 04 01 00 00    	jns    800a2f <vprintfmt+0x40b>
				putch('-', putdat);
  80092b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800936:	ff d6                	call   *%esi
				num = -(long long) num;
  800938:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80093b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80093e:	f7 da                	neg    %edx
  800940:	83 d1 00             	adc    $0x0,%ecx
  800943:	f7 d9                	neg    %ecx
  800945:	e9 e5 00 00 00       	jmp    800a2f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80094a:	83 f9 01             	cmp    $0x1,%ecx
  80094d:	7e 10                	jle    80095f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8b 48 04             	mov    0x4(%eax),%ecx
  800957:	8d 40 08             	lea    0x8(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
  80095d:	eb 26                	jmp    800985 <vprintfmt+0x361>
	else if (lflag)
  80095f:	85 c9                	test   %ecx,%ecx
  800961:	74 12                	je     800975 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 10                	mov    (%eax),%edx
  800968:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096d:	8d 40 04             	lea    0x4(%eax),%eax
  800970:	89 45 14             	mov    %eax,0x14(%ebp)
  800973:	eb 10                	jmp    800985 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8b 10                	mov    (%eax),%edx
  80097a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097f:	8d 40 04             	lea    0x4(%eax),%eax
  800982:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800985:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80098a:	e9 a0 00 00 00       	jmp    800a2f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80098f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800993:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80099a:	ff d6                	call   *%esi
			putch('X', putdat);
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009a7:	ff d6                	call   *%esi
			putch('X', putdat);
  8009a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ad:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009b4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009b9:	e9 8b fc ff ff       	jmp    800649 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8009be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009cf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009d6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8b 10                	mov    (%eax),%edx
  8009dd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009e2:	8d 40 04             	lea    0x4(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009e8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009ed:	eb 40                	jmp    800a2f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009ef:	83 f9 01             	cmp    $0x1,%ecx
  8009f2:	7e 10                	jle    800a04 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f7:	8b 10                	mov    (%eax),%edx
  8009f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009fc:	8d 40 08             	lea    0x8(%eax),%eax
  8009ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800a02:	eb 26                	jmp    800a2a <vprintfmt+0x406>
	else if (lflag)
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	74 12                	je     800a1a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800a08:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0b:	8b 10                	mov    (%eax),%edx
  800a0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a12:	8d 40 04             	lea    0x4(%eax),%eax
  800a15:	89 45 14             	mov    %eax,0x14(%ebp)
  800a18:	eb 10                	jmp    800a2a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1d:	8b 10                	mov    (%eax),%edx
  800a1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a24:	8d 40 04             	lea    0x4(%eax),%eax
  800a27:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a2a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a2f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a37:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a42:	89 14 24             	mov    %edx,(%esp)
  800a45:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a49:	89 da                	mov    %ebx,%edx
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	e8 9e fa ff ff       	call   8004f0 <printnum>
			break;
  800a52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a55:	e9 ef fb ff ff       	jmp    800649 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5e:	89 04 24             	mov    %eax,(%esp)
  800a61:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a66:	e9 de fb ff ff       	jmp    800649 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a76:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a78:	eb 03                	jmp    800a7d <vprintfmt+0x459>
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a81:	75 f7                	jne    800a7a <vprintfmt+0x456>
  800a83:	e9 c1 fb ff ff       	jmp    800649 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a88:	83 c4 3c             	add    $0x3c,%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 28             	sub    $0x28,%esp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a9f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aa3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	74 30                	je     800ae1 <vsnprintf+0x51>
  800ab1:	85 d2                	test   %edx,%edx
  800ab3:	7e 2c                	jle    800ae1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	c7 04 24 df 05 80 00 	movl   $0x8005df,(%esp)
  800ad1:	e8 4e fb ff ff       	call   800624 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adf:	eb 05                	jmp    800ae6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af5:	8b 45 10             	mov    0x10(%ebp),%eax
  800af8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 82 ff ff ff       	call   800a90 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	eb 03                	jmp    800b20 <strlen+0x10>
		n++;
  800b1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b24:	75 f7                	jne    800b1d <strlen+0xd>
		n++;
	return n;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	eb 03                	jmp    800b3b <strnlen+0x13>
		n++;
  800b38:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3b:	39 d0                	cmp    %edx,%eax
  800b3d:	74 06                	je     800b45 <strnlen+0x1d>
  800b3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b43:	75 f3                	jne    800b38 <strnlen+0x10>
		n++;
	return n;
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b51:	89 c2                	mov    %eax,%edx
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	83 c1 01             	add    $0x1,%ecx
  800b59:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b5d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b60:	84 db                	test   %bl,%bl
  800b62:	75 ef                	jne    800b53 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b64:	5b                   	pop    %ebx
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b71:	89 1c 24             	mov    %ebx,(%esp)
  800b74:	e8 97 ff ff ff       	call   800b10 <strlen>
	strcpy(dst + len, src);
  800b79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b80:	01 d8                	add    %ebx,%eax
  800b82:	89 04 24             	mov    %eax,(%esp)
  800b85:	e8 bd ff ff ff       	call   800b47 <strcpy>
	return dst;
}
  800b8a:	89 d8                	mov    %ebx,%eax
  800b8c:	83 c4 08             	add    $0x8,%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	8b 75 08             	mov    0x8(%ebp),%esi
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba2:	89 f2                	mov    %esi,%edx
  800ba4:	eb 0f                	jmp    800bb5 <strncpy+0x23>
		*dst++ = *src;
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	0f b6 01             	movzbl (%ecx),%eax
  800bac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800baf:	80 39 01             	cmpb   $0x1,(%ecx)
  800bb2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb5:	39 da                	cmp    %ebx,%edx
  800bb7:	75 ed                	jne    800ba6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bb9:	89 f0                	mov    %esi,%eax
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bd3:	85 c9                	test   %ecx,%ecx
  800bd5:	75 0b                	jne    800be2 <strlcpy+0x23>
  800bd7:	eb 1d                	jmp    800bf6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800be2:	39 d8                	cmp    %ebx,%eax
  800be4:	74 0b                	je     800bf1 <strlcpy+0x32>
  800be6:	0f b6 0a             	movzbl (%edx),%ecx
  800be9:	84 c9                	test   %cl,%cl
  800beb:	75 ec                	jne    800bd9 <strlcpy+0x1a>
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	eb 02                	jmp    800bf3 <strlcpy+0x34>
  800bf1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800bf3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bf6:	29 f0                	sub    %esi,%eax
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c05:	eb 06                	jmp    800c0d <strcmp+0x11>
		p++, q++;
  800c07:	83 c1 01             	add    $0x1,%ecx
  800c0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c0d:	0f b6 01             	movzbl (%ecx),%eax
  800c10:	84 c0                	test   %al,%al
  800c12:	74 04                	je     800c18 <strcmp+0x1c>
  800c14:	3a 02                	cmp    (%edx),%al
  800c16:	74 ef                	je     800c07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c18:	0f b6 c0             	movzbl %al,%eax
  800c1b:	0f b6 12             	movzbl (%edx),%edx
  800c1e:	29 d0                	sub    %edx,%eax
}
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	53                   	push   %ebx
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2c:	89 c3                	mov    %eax,%ebx
  800c2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c31:	eb 06                	jmp    800c39 <strncmp+0x17>
		n--, p++, q++;
  800c33:	83 c0 01             	add    $0x1,%eax
  800c36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c39:	39 d8                	cmp    %ebx,%eax
  800c3b:	74 15                	je     800c52 <strncmp+0x30>
  800c3d:	0f b6 08             	movzbl (%eax),%ecx
  800c40:	84 c9                	test   %cl,%cl
  800c42:	74 04                	je     800c48 <strncmp+0x26>
  800c44:	3a 0a                	cmp    (%edx),%cl
  800c46:	74 eb                	je     800c33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c48:	0f b6 00             	movzbl (%eax),%eax
  800c4b:	0f b6 12             	movzbl (%edx),%edx
  800c4e:	29 d0                	sub    %edx,%eax
  800c50:	eb 05                	jmp    800c57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c64:	eb 07                	jmp    800c6d <strchr+0x13>
		if (*s == c)
  800c66:	38 ca                	cmp    %cl,%dl
  800c68:	74 0f                	je     800c79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	0f b6 10             	movzbl (%eax),%edx
  800c70:	84 d2                	test   %dl,%dl
  800c72:	75 f2                	jne    800c66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c85:	eb 07                	jmp    800c8e <strfind+0x13>
		if (*s == c)
  800c87:	38 ca                	cmp    %cl,%dl
  800c89:	74 0a                	je     800c95 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c8b:	83 c0 01             	add    $0x1,%eax
  800c8e:	0f b6 10             	movzbl (%eax),%edx
  800c91:	84 d2                	test   %dl,%dl
  800c93:	75 f2                	jne    800c87 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca3:	85 c9                	test   %ecx,%ecx
  800ca5:	74 36                	je     800cdd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cad:	75 28                	jne    800cd7 <memset+0x40>
  800caf:	f6 c1 03             	test   $0x3,%cl
  800cb2:	75 23                	jne    800cd7 <memset+0x40>
		c &= 0xFF;
  800cb4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	c1 e3 08             	shl    $0x8,%ebx
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	c1 e6 18             	shl    $0x18,%esi
  800cc2:	89 d0                	mov    %edx,%eax
  800cc4:	c1 e0 10             	shl    $0x10,%eax
  800cc7:	09 f0                	or     %esi,%eax
  800cc9:	09 c2                	or     %eax,%edx
  800ccb:	89 d0                	mov    %edx,%eax
  800ccd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ccf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cd2:	fc                   	cld    
  800cd3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cd5:	eb 06                	jmp    800cdd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cda:	fc                   	cld    
  800cdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cdd:	89 f8                	mov    %edi,%eax
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cf2:	39 c6                	cmp    %eax,%esi
  800cf4:	73 35                	jae    800d2b <memmove+0x47>
  800cf6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cf9:	39 d0                	cmp    %edx,%eax
  800cfb:	73 2e                	jae    800d2b <memmove+0x47>
		s += n;
		d += n;
  800cfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d0a:	75 13                	jne    800d1f <memmove+0x3b>
  800d0c:	f6 c1 03             	test   $0x3,%cl
  800d0f:	75 0e                	jne    800d1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d11:	83 ef 04             	sub    $0x4,%edi
  800d14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d1a:	fd                   	std    
  800d1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d1d:	eb 09                	jmp    800d28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d1f:	83 ef 01             	sub    $0x1,%edi
  800d22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d25:	fd                   	std    
  800d26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d28:	fc                   	cld    
  800d29:	eb 1d                	jmp    800d48 <memmove+0x64>
  800d2b:	89 f2                	mov    %esi,%edx
  800d2d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d2f:	f6 c2 03             	test   $0x3,%dl
  800d32:	75 0f                	jne    800d43 <memmove+0x5f>
  800d34:	f6 c1 03             	test   $0x3,%cl
  800d37:	75 0a                	jne    800d43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d39:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d3c:	89 c7                	mov    %eax,%edi
  800d3e:	fc                   	cld    
  800d3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d41:	eb 05                	jmp    800d48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d43:	89 c7                	mov    %eax,%edi
  800d45:	fc                   	cld    
  800d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d52:	8b 45 10             	mov    0x10(%ebp),%eax
  800d55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	89 04 24             	mov    %eax,(%esp)
  800d66:	e8 79 ff ff ff       	call   800ce4 <memmove>
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	89 d6                	mov    %edx,%esi
  800d7a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7d:	eb 1a                	jmp    800d99 <memcmp+0x2c>
		if (*s1 != *s2)
  800d7f:	0f b6 02             	movzbl (%edx),%eax
  800d82:	0f b6 19             	movzbl (%ecx),%ebx
  800d85:	38 d8                	cmp    %bl,%al
  800d87:	74 0a                	je     800d93 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d89:	0f b6 c0             	movzbl %al,%eax
  800d8c:	0f b6 db             	movzbl %bl,%ebx
  800d8f:	29 d8                	sub    %ebx,%eax
  800d91:	eb 0f                	jmp    800da2 <memcmp+0x35>
		s1++, s2++;
  800d93:	83 c2 01             	add    $0x1,%edx
  800d96:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d99:	39 f2                	cmp    %esi,%edx
  800d9b:	75 e2                	jne    800d7f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
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
  800dcc:	8b 45 10             	mov    0x10(%ebp),%eax
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
  800dd4:	0f b6 0a             	movzbl (%edx),%ecx
  800dd7:	80 f9 09             	cmp    $0x9,%cl
  800dda:	74 f5                	je     800dd1 <strtol+0xe>
  800ddc:	80 f9 20             	cmp    $0x20,%cl
  800ddf:	74 f0                	je     800dd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de1:	80 f9 2b             	cmp    $0x2b,%cl
  800de4:	75 0a                	jne    800df0 <strtol+0x2d>
		s++;
  800de6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800de9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dee:	eb 11                	jmp    800e01 <strtol+0x3e>
  800df0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800df5:	80 f9 2d             	cmp    $0x2d,%cl
  800df8:	75 07                	jne    800e01 <strtol+0x3e>
		s++, neg = 1;
  800dfa:	8d 52 01             	lea    0x1(%edx),%edx
  800dfd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e01:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800e06:	75 15                	jne    800e1d <strtol+0x5a>
  800e08:	80 3a 30             	cmpb   $0x30,(%edx)
  800e0b:	75 10                	jne    800e1d <strtol+0x5a>
  800e0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e11:	75 0a                	jne    800e1d <strtol+0x5a>
		s += 2, base = 16;
  800e13:	83 c2 02             	add    $0x2,%edx
  800e16:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1b:	eb 10                	jmp    800e2d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	75 0c                	jne    800e2d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e21:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e23:	80 3a 30             	cmpb   $0x30,(%edx)
  800e26:	75 05                	jne    800e2d <strtol+0x6a>
		s++, base = 8;
  800e28:	83 c2 01             	add    $0x1,%edx
  800e2b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e35:	0f b6 0a             	movzbl (%edx),%ecx
  800e38:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e3b:	89 f0                	mov    %esi,%eax
  800e3d:	3c 09                	cmp    $0x9,%al
  800e3f:	77 08                	ja     800e49 <strtol+0x86>
			dig = *s - '0';
  800e41:	0f be c9             	movsbl %cl,%ecx
  800e44:	83 e9 30             	sub    $0x30,%ecx
  800e47:	eb 20                	jmp    800e69 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e49:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	3c 19                	cmp    $0x19,%al
  800e50:	77 08                	ja     800e5a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e52:	0f be c9             	movsbl %cl,%ecx
  800e55:	83 e9 57             	sub    $0x57,%ecx
  800e58:	eb 0f                	jmp    800e69 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e5a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	3c 19                	cmp    $0x19,%al
  800e61:	77 16                	ja     800e79 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e63:	0f be c9             	movsbl %cl,%ecx
  800e66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e6c:	7d 0f                	jge    800e7d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e6e:	83 c2 01             	add    $0x1,%edx
  800e71:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e75:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e77:	eb bc                	jmp    800e35 <strtol+0x72>
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	eb 02                	jmp    800e7f <strtol+0xbc>
  800e7d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e83:	74 05                	je     800e8a <strtol+0xc7>
		*endptr = (char *) s;
  800e85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e88:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e8a:	f7 d8                	neg    %eax
  800e8c:	85 ff                	test   %edi,%edi
  800e8e:	0f 44 c3             	cmove  %ebx,%eax
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