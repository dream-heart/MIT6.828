
obj/user/softint.debug：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 10             	sub    $0x10,%esp
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800048:	e8 d8 00 00 00       	call   800125 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006e:	89 1c 24             	mov    %ebx,(%esp)
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 07 00 00 00       	call   800082 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 3f 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 28                	jle    80011d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800100:	00 
  800101:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800108:	00 
  800109:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800110:	00 
  800111:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800118:	e8 ae 02 00 00       	call   8003cb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	83 c4 2c             	add    $0x2c,%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
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
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 28                	jle    8001af <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800192:	00 
  800193:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  80019a:	00 
  80019b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a2:	00 
  8001a3:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001aa:	e8 1c 02 00 00       	call   8003cb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001af:	83 c4 2c             	add    $0x2c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7e 28                	jle    800202 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001de:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f5:	00 
  8001f6:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8001fd:	e8 c9 01 00 00       	call   8003cb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800202:	83 c4 2c             	add    $0x2c,%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	53                   	push   %ebx
  800210:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800213:	bb 00 00 00 00       	mov    $0x0,%ebx
  800218:	b8 06 00 00 00       	mov    $0x6,%eax
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	8b 55 08             	mov    0x8(%ebp),%edx
  800223:	89 df                	mov    %ebx,%edi
  800225:	89 de                	mov    %ebx,%esi
  800227:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800229:	85 c0                	test   %eax,%eax
  80022b:	7e 28                	jle    800255 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800231:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800238:	00 
  800239:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800240:	00 
  800241:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800248:	00 
  800249:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800250:	e8 76 01 00 00       	call   8003cb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800255:	83 c4 2c             	add    $0x2c,%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	b8 08 00 00 00       	mov    $0x8,%eax
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	89 df                	mov    %ebx,%edi
  800278:	89 de                	mov    %ebx,%esi
  80027a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 28                	jle    8002a8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	89 44 24 10          	mov    %eax,0x10(%esp)
  800284:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028b:	00 
  80028c:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002a3:	e8 23 01 00 00       	call   8003cb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a8:	83 c4 2c             	add    $0x2c,%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002be:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	89 df                	mov    %ebx,%edi
  8002cb:	89 de                	mov    %ebx,%esi
  8002cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	7e 28                	jle    8002fb <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002de:	00 
  8002df:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ee:	00 
  8002ef:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8002f6:	e8 d0 00 00 00       	call   8003cb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002fb:	83 c4 2c             	add    $0x2c,%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800311:	b8 0a 00 00 00       	mov    $0xa,%eax
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 df                	mov    %ebx,%edi
  80031e:	89 de                	mov    %ebx,%esi
  800320:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7e 28                	jle    80034e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800331:	00 
  800332:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  800339:	00 
  80033a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800341:	00 
  800342:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  800349:	e8 7d 00 00 00       	call   8003cb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80034e:	83 c4 2c             	add    $0x2c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035c:	be 00 00 00 00       	mov    $0x0,%esi
  800361:	b8 0c 00 00 00       	mov    $0xc,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800372:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800374:	5b                   	pop    %ebx
  800375:	5e                   	pop    %esi
  800376:	5f                   	pop    %edi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	b8 0d 00 00 00       	mov    $0xd,%eax
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 cb                	mov    %ecx,%ebx
  800391:	89 cf                	mov    %ecx,%edi
  800393:	89 ce                	mov    %ecx,%esi
  800395:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800397:	85 c0                	test   %eax,%eax
  800399:	7e 28                	jle    8003c3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003a6:	00 
  8003a7:	c7 44 24 08 2a 11 80 	movl   $0x80112a,0x8(%esp)
  8003ae:	00 
  8003af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b6:	00 
  8003b7:	c7 04 24 47 11 80 00 	movl   $0x801147,(%esp)
  8003be:	e8 08 00 00 00       	call   8003cb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c3:	83 c4 2c             	add    $0x2c,%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003dc:	e8 44 fd ff ff       	call   800125 <sys_getenvid>
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ef:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f7:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  8003fe:	e8 c1 00 00 00       	call   8004c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800407:	8b 45 10             	mov    0x10(%ebp),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 51 00 00 00       	call   800463 <vcprintf>
	cprintf("\n");
  800412:	c7 04 24 7b 11 80 00 	movl   $0x80117b,(%esp)
  800419:	e8 a6 00 00 00       	call   8004c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041e:	cc                   	int3   
  80041f:	eb fd                	jmp    80041e <_panic+0x53>

00800421 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	53                   	push   %ebx
  800425:	83 ec 14             	sub    $0x14,%esp
  800428:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042b:	8b 13                	mov    (%ebx),%edx
  80042d:	8d 42 01             	lea    0x1(%edx),%eax
  800430:	89 03                	mov    %eax,(%ebx)
  800432:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800435:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800439:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043e:	75 19                	jne    800459 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800440:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800447:	00 
  800448:	8d 43 08             	lea    0x8(%ebx),%eax
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	e8 43 fc ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800453:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800459:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80045d:	83 c4 14             	add    $0x14,%esp
  800460:	5b                   	pop    %ebx
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80046c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800473:	00 00 00 
	b.cnt = 0;
  800476:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80047d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800494:	89 44 24 04          	mov    %eax,0x4(%esp)
  800498:	c7 04 24 21 04 80 00 	movl   $0x800421,(%esp)
  80049f:	e8 70 01 00 00       	call   800614 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	e8 da fb ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8004bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 87 ff ff ff       	call   800463 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
  8004de:	66 90                	xchg   %ax,%ax

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800502:	b9 00 00 00 00       	mov    $0x0,%ecx
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80050d:	39 d9                	cmp    %ebx,%ecx
  80050f:	72 05                	jb     800516 <printnum+0x36>
  800511:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800514:	77 69                	ja     80057f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800516:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800519:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80051d:	83 ee 01             	sub    $0x1,%esi
  800520:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800524:	89 44 24 08          	mov    %eax,0x8(%esp)
  800528:	8b 44 24 08          	mov    0x8(%esp),%eax
  80052c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800530:	89 c3                	mov    %eax,%ebx
  800532:	89 d6                	mov    %edx,%esi
  800534:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800537:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80053e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800542:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	e8 3c 09 00 00       	call   800e90 <__udivdi3>
  800554:	89 d9                	mov    %ebx,%ecx
  800556:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80055a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	89 54 24 04          	mov    %edx,0x4(%esp)
  800565:	89 fa                	mov    %edi,%edx
  800567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056a:	e8 71 ff ff ff       	call   8004e0 <printnum>
  80056f:	eb 1b                	jmp    80058c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800571:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800575:	8b 45 18             	mov    0x18(%ebp),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff d3                	call   *%ebx
  80057d:	eb 03                	jmp    800582 <printnum+0xa2>
  80057f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800582:	83 ee 01             	sub    $0x1,%esi
  800585:	85 f6                	test   %esi,%esi
  800587:	7f e8                	jg     800571 <printnum+0x91>
  800589:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	e8 0c 0a 00 00       	call   800fc0 <__umoddi3>
  8005b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b8:	0f be 80 7d 11 80 00 	movsbl 0x80117d(%eax),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c5:	ff d0                	call   *%eax
}
  8005c7:	83 c4 3c             	add    $0x3c,%esp
  8005ca:	5b                   	pop    %ebx
  8005cb:	5e                   	pop    %esi
  8005cc:	5f                   	pop    %edi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	3b 50 04             	cmp    0x4(%eax),%edx
  8005de:	73 0a                	jae    8005ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e3:	89 08                	mov    %ecx,(%eax)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	88 02                	mov    %al,(%edx)
}
  8005ea:	5d                   	pop    %ebp
  8005eb:	c3                   	ret    

008005ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800600:	8b 45 0c             	mov    0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 02 00 00 00       	call   800614 <vprintfmt>
	va_end(ap);
}
  800612:	c9                   	leave  
  800613:	c3                   	ret    

00800614 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800614:	55                   	push   %ebp
  800615:	89 e5                	mov    %esp,%ebp
  800617:	57                   	push   %edi
  800618:	56                   	push   %esi
  800619:	53                   	push   %ebx
  80061a:	83 ec 3c             	sub    $0x3c,%esp
  80061d:	8b 75 08             	mov    0x8(%ebp),%esi
  800620:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800623:	8b 7d 10             	mov    0x10(%ebp),%edi
  800626:	eb 11                	jmp    800639 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800628:	85 c0                	test   %eax,%eax
  80062a:	0f 84 48 04 00 00    	je     800a78 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	83 f8 25             	cmp    $0x25,%eax
  800643:	75 e3                	jne    800628 <vprintfmt+0x14>
  800645:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800649:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800650:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800657:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	eb 1f                	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800668:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80066c:	eb 16                	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800671:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800675:	eb 0d                	jmp    800684 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800677:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8d 47 01             	lea    0x1(%edi),%eax
  800687:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80068a:	0f b6 17             	movzbl (%edi),%edx
  80068d:	0f b6 c2             	movzbl %dl,%eax
  800690:	83 ea 23             	sub    $0x23,%edx
  800693:	80 fa 55             	cmp    $0x55,%dl
  800696:	0f 87 bf 03 00 00    	ja     800a5b <vprintfmt+0x447>
  80069c:	0f b6 d2             	movzbl %dl,%edx
  80069f:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006b4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006b8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8006bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006be:	83 f9 09             	cmp    $0x9,%ecx
  8006c1:	77 3c                	ja     8006ff <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006c6:	eb e9                	jmp    8006b1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006dc:	eb 27                	jmp    800705 <vprintfmt+0xf1>
  8006de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	0f 49 c2             	cmovns %edx,%eax
  8006eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f1:	eb 91                	jmp    800684 <vprintfmt+0x70>
  8006f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006fd:	eb 85                	jmp    800684 <vprintfmt+0x70>
  8006ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800702:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800709:	0f 89 75 ff ff ff    	jns    800684 <vprintfmt+0x70>
  80070f:	e9 63 ff ff ff       	jmp    800677 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800714:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071a:	e9 65 ff ff ff       	jmp    800684 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800722:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800734:	e9 00 ff ff ff       	jmp    800639 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800740:	8b 00                	mov    (%eax),%eax
  800742:	99                   	cltd   
  800743:	31 d0                	xor    %edx,%eax
  800745:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800747:	83 f8 0f             	cmp    $0xf,%eax
  80074a:	7f 0b                	jg     800757 <vprintfmt+0x143>
  80074c:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	75 20                	jne    800777 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800757:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075b:	c7 44 24 08 95 11 80 	movl   $0x801195,0x8(%esp)
  800762:	00 
  800763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800767:	89 34 24             	mov    %esi,(%esp)
  80076a:	e8 7d fe ff ff       	call   8005ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800772:	e9 c2 fe ff ff       	jmp    800639 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800777:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80077b:	c7 44 24 08 9e 11 80 	movl   $0x80119e,0x8(%esp)
  800782:	00 
  800783:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800787:	89 34 24             	mov    %esi,(%esp)
  80078a:	e8 5d fe ff ff       	call   8005ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800792:	e9 a2 fe ff ff       	jmp    800639 <vprintfmt+0x25>
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80079d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8007a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8007a9:	85 ff                	test   %edi,%edi
  8007ab:	b8 8e 11 80 00       	mov    $0x80118e,%eax
  8007b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8007b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007b7:	0f 84 92 00 00 00    	je     80084f <vprintfmt+0x23b>
  8007bd:	85 c9                	test   %ecx,%ecx
  8007bf:	0f 8e 98 00 00 00    	jle    80085d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c9:	89 3c 24             	mov    %edi,(%esp)
  8007cc:	e8 47 03 00 00       	call   800b18 <strnlen>
  8007d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007d4:	29 c1                	sub    %eax,%ecx
  8007d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8007d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e5:	eb 0f                	jmp    8007f6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8007e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ee:	89 04 24             	mov    %eax,(%esp)
  8007f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f3:	83 ef 01             	sub    $0x1,%edi
  8007f6:	85 ff                	test   %edi,%edi
  8007f8:	7f ed                	jg     8007e7 <vprintfmt+0x1d3>
  8007fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007fd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800800:	85 c9                	test   %ecx,%ecx
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	0f 49 c1             	cmovns %ecx,%eax
  80080a:	29 c1                	sub    %eax,%ecx
  80080c:	89 75 08             	mov    %esi,0x8(%ebp)
  80080f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800812:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800815:	89 cb                	mov    %ecx,%ebx
  800817:	eb 50                	jmp    800869 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800819:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80081d:	74 1e                	je     80083d <vprintfmt+0x229>
  80081f:	0f be d2             	movsbl %dl,%edx
  800822:	83 ea 20             	sub    $0x20,%edx
  800825:	83 fa 5e             	cmp    $0x5e,%edx
  800828:	76 13                	jbe    80083d <vprintfmt+0x229>
					putch('?', putdat);
  80082a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800838:	ff 55 08             	call   *0x8(%ebp)
  80083b:	eb 0d                	jmp    80084a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800840:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800844:	89 04 24             	mov    %eax,(%esp)
  800847:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80084a:	83 eb 01             	sub    $0x1,%ebx
  80084d:	eb 1a                	jmp    800869 <vprintfmt+0x255>
  80084f:	89 75 08             	mov    %esi,0x8(%ebp)
  800852:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800855:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800858:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80085b:	eb 0c                	jmp    800869 <vprintfmt+0x255>
  80085d:	89 75 08             	mov    %esi,0x8(%ebp)
  800860:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800863:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800866:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800869:	83 c7 01             	add    $0x1,%edi
  80086c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800870:	0f be c2             	movsbl %dl,%eax
  800873:	85 c0                	test   %eax,%eax
  800875:	74 25                	je     80089c <vprintfmt+0x288>
  800877:	85 f6                	test   %esi,%esi
  800879:	78 9e                	js     800819 <vprintfmt+0x205>
  80087b:	83 ee 01             	sub    $0x1,%esi
  80087e:	79 99                	jns    800819 <vprintfmt+0x205>
  800880:	89 df                	mov    %ebx,%edi
  800882:	8b 75 08             	mov    0x8(%ebp),%esi
  800885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800888:	eb 1a                	jmp    8008a4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80088a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800895:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800897:	83 ef 01             	sub    $0x1,%edi
  80089a:	eb 08                	jmp    8008a4 <vprintfmt+0x290>
  80089c:	89 df                	mov    %ebx,%edi
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a4:	85 ff                	test   %edi,%edi
  8008a6:	7f e2                	jg     80088a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ab:	e9 89 fd ff ff       	jmp    800639 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008b0:	83 f9 01             	cmp    $0x1,%ecx
  8008b3:	7e 19                	jle    8008ce <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8b 50 04             	mov    0x4(%eax),%edx
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 40 08             	lea    0x8(%eax),%eax
  8008c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008cc:	eb 38                	jmp    800906 <vprintfmt+0x2f2>
	else if (lflag)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 1b                	je     8008ed <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 00                	mov    (%eax),%eax
  8008d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008da:	89 c1                	mov    %eax,%ecx
  8008dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8008df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 40 04             	lea    0x4(%eax),%eax
  8008e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008eb:	eb 19                	jmp    800906 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8b 00                	mov    (%eax),%eax
  8008f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008f5:	89 c1                	mov    %eax,%ecx
  8008f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8d 40 04             	lea    0x4(%eax),%eax
  800903:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800906:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800909:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80090c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800911:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800915:	0f 89 04 01 00 00    	jns    800a1f <vprintfmt+0x40b>
				putch('-', putdat);
  80091b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800926:	ff d6                	call   *%esi
				num = -(long long) num;
  800928:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80092b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80092e:	f7 da                	neg    %edx
  800930:	83 d1 00             	adc    $0x0,%ecx
  800933:	f7 d9                	neg    %ecx
  800935:	e9 e5 00 00 00       	jmp    800a1f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80093a:	83 f9 01             	cmp    $0x1,%ecx
  80093d:	7e 10                	jle    80094f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8b 10                	mov    (%eax),%edx
  800944:	8b 48 04             	mov    0x4(%eax),%ecx
  800947:	8d 40 08             	lea    0x8(%eax),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
  80094d:	eb 26                	jmp    800975 <vprintfmt+0x361>
	else if (lflag)
  80094f:	85 c9                	test   %ecx,%ecx
  800951:	74 12                	je     800965 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8b 10                	mov    (%eax),%edx
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095d:	8d 40 04             	lea    0x4(%eax),%eax
  800960:	89 45 14             	mov    %eax,0x14(%ebp)
  800963:	eb 10                	jmp    800975 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800965:	8b 45 14             	mov    0x14(%ebp),%eax
  800968:	8b 10                	mov    (%eax),%edx
  80096a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096f:	8d 40 04             	lea    0x4(%eax),%eax
  800972:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800975:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80097a:	e9 a0 00 00 00       	jmp    800a1f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80097f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800983:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80098a:	ff d6                	call   *%esi
			putch('X', putdat);
  80098c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800990:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800997:	ff d6                	call   *%esi
			putch('X', putdat);
  800999:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8009a4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8009a9:	e9 8b fc ff ff       	jmp    800639 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  8009ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009c6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8009c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009cb:	8b 10                	mov    (%eax),%edx
  8009cd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  8009d2:	8d 40 04             	lea    0x4(%eax),%eax
  8009d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009d8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8009dd:	eb 40                	jmp    800a1f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009df:	83 f9 01             	cmp    $0x1,%ecx
  8009e2:	7e 10                	jle    8009f4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  8009e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e7:	8b 10                	mov    (%eax),%edx
  8009e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ec:	8d 40 08             	lea    0x8(%eax),%eax
  8009ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8009f2:	eb 26                	jmp    800a1a <vprintfmt+0x406>
	else if (lflag)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 12                	je     800a0a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8b 10                	mov    (%eax),%edx
  8009fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a02:	8d 40 04             	lea    0x4(%eax),%eax
  800a05:	89 45 14             	mov    %eax,0x14(%ebp)
  800a08:	eb 10                	jmp    800a1a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8b 10                	mov    (%eax),%edx
  800a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a14:	8d 40 04             	lea    0x4(%eax),%eax
  800a17:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a1a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a1f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a27:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a32:	89 14 24             	mov    %edx,(%esp)
  800a35:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a39:	89 da                	mov    %ebx,%edx
  800a3b:	89 f0                	mov    %esi,%eax
  800a3d:	e8 9e fa ff ff       	call   8004e0 <printnum>
			break;
  800a42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a45:	e9 ef fb ff ff       	jmp    800639 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a56:	e9 de fb ff ff       	jmp    800639 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a66:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a68:	eb 03                	jmp    800a6d <vprintfmt+0x459>
  800a6a:	83 ef 01             	sub    $0x1,%edi
  800a6d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a71:	75 f7                	jne    800a6a <vprintfmt+0x456>
  800a73:	e9 c1 fb ff ff       	jmp    800639 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a78:	83 c4 3c             	add    $0x3c,%esp
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 28             	sub    $0x28,%esp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a8f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a93:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	74 30                	je     800ad1 <vsnprintf+0x51>
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	7e 2c                	jle    800ad1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aba:	c7 04 24 cf 05 80 00 	movl   $0x8005cf,(%esp)
  800ac1:	e8 4e fb ff ff       	call   800614 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acf:	eb 05                	jmp    800ad6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ad1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ade:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ae1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	89 04 24             	mov    %eax,(%esp)
  800af9:	e8 82 ff ff ff       	call   800a80 <vsnprintf>
	va_end(ap);

	return rc;
}
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	eb 03                	jmp    800b10 <strlen+0x10>
		n++;
  800b0d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b14:	75 f7                	jne    800b0d <strlen+0xd>
		n++;
	return n;
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	eb 03                	jmp    800b2b <strnlen+0x13>
		n++;
  800b28:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	74 06                	je     800b35 <strnlen+0x1d>
  800b2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b33:	75 f3                	jne    800b28 <strnlen+0x10>
		n++;
	return n;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b4d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b50:	84 db                	test   %bl,%bl
  800b52:	75 ef                	jne    800b43 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b54:	5b                   	pop    %ebx
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b61:	89 1c 24             	mov    %ebx,(%esp)
  800b64:	e8 97 ff ff ff       	call   800b00 <strlen>
	strcpy(dst + len, src);
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b70:	01 d8                	add    %ebx,%eax
  800b72:	89 04 24             	mov    %eax,(%esp)
  800b75:	e8 bd ff ff ff       	call   800b37 <strcpy>
	return dst;
}
  800b7a:	89 d8                	mov    %ebx,%eax
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b92:	89 f2                	mov    %esi,%edx
  800b94:	eb 0f                	jmp    800ba5 <strncpy+0x23>
		*dst++ = *src;
  800b96:	83 c2 01             	add    $0x1,%edx
  800b99:	0f b6 01             	movzbl (%ecx),%eax
  800b9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9f:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba5:	39 da                	cmp    %ebx,%edx
  800ba7:	75 ed                	jne    800b96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ba9:	89 f0                	mov    %esi,%eax
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc3:	85 c9                	test   %ecx,%ecx
  800bc5:	75 0b                	jne    800bd2 <strlcpy+0x23>
  800bc7:	eb 1d                	jmp    800be6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd2:	39 d8                	cmp    %ebx,%eax
  800bd4:	74 0b                	je     800be1 <strlcpy+0x32>
  800bd6:	0f b6 0a             	movzbl (%edx),%ecx
  800bd9:	84 c9                	test   %cl,%cl
  800bdb:	75 ec                	jne    800bc9 <strlcpy+0x1a>
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	eb 02                	jmp    800be3 <strlcpy+0x34>
  800be1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 07                	jmp    800c7e <strfind+0x13>
		if (*s == c)
  800c77:	38 ca                	cmp    %cl,%dl
  800c79:	74 0a                	je     800c85 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c7b:	83 c0 01             	add    $0x1,%eax
  800c7e:	0f b6 10             	movzbl (%eax),%edx
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
  800cbb:	89 d0                	mov    %edx,%eax
  800cbd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d29:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d42:	8b 45 10             	mov    0x10(%ebp),%eax
  800d45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	89 04 24             	mov    %eax,(%esp)
  800d56:	e8 79 ff ff ff       	call   800cd4 <memmove>
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	89 d6                	mov    %edx,%esi
  800d6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6d:	eb 1a                	jmp    800d89 <memcmp+0x2c>
		if (*s1 != *s2)
  800d6f:	0f b6 02             	movzbl (%edx),%eax
  800d72:	0f b6 19             	movzbl (%ecx),%ebx
  800d75:	38 d8                	cmp    %bl,%al
  800d77:	74 0a                	je     800d83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d79:	0f b6 c0             	movzbl %al,%eax
  800d7c:	0f b6 db             	movzbl %bl,%ebx
  800d7f:	29 d8                	sub    %ebx,%eax
  800d81:	eb 0f                	jmp    800d92 <memcmp+0x35>
		s1++, s2++;
  800d83:	83 c2 01             	add    $0x1,%edx
  800d86:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d89:	39 f2                	cmp    %esi,%edx
  800d8b:	75 e2                	jne    800d6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800da4:	eb 07                	jmp    800dad <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800da6:	38 08                	cmp    %cl,(%eax)
  800da8:	74 07                	je     800db1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800daa:	83 c0 01             	add    $0x1,%eax
  800dad:	39 d0                	cmp    %edx,%eax
  800daf:	72 f5                	jb     800da6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbf:	eb 03                	jmp    800dc4 <strtol+0x11>
		s++;
  800dc1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc4:	0f b6 0a             	movzbl (%edx),%ecx
  800dc7:	80 f9 09             	cmp    $0x9,%cl
  800dca:	74 f5                	je     800dc1 <strtol+0xe>
  800dcc:	80 f9 20             	cmp    $0x20,%cl
  800dcf:	74 f0                	je     800dc1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dd1:	80 f9 2b             	cmp    $0x2b,%cl
  800dd4:	75 0a                	jne    800de0 <strtol+0x2d>
		s++;
  800dd6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dd9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dde:	eb 11                	jmp    800df1 <strtol+0x3e>
  800de0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800de5:	80 f9 2d             	cmp    $0x2d,%cl
  800de8:	75 07                	jne    800df1 <strtol+0x3e>
		s++, neg = 1;
  800dea:	8d 52 01             	lea    0x1(%edx),%edx
  800ded:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800df1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800df6:	75 15                	jne    800e0d <strtol+0x5a>
  800df8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dfb:	75 10                	jne    800e0d <strtol+0x5a>
  800dfd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e01:	75 0a                	jne    800e0d <strtol+0x5a>
		s += 2, base = 16;
  800e03:	83 c2 02             	add    $0x2,%edx
  800e06:	b8 10 00 00 00       	mov    $0x10,%eax
  800e0b:	eb 10                	jmp    800e1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	75 0c                	jne    800e1d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e11:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e13:	80 3a 30             	cmpb   $0x30,(%edx)
  800e16:	75 05                	jne    800e1d <strtol+0x6a>
		s++, base = 8;
  800e18:	83 c2 01             	add    $0x1,%edx
  800e1b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e25:	0f b6 0a             	movzbl (%edx),%ecx
  800e28:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800e2b:	89 f0                	mov    %esi,%eax
  800e2d:	3c 09                	cmp    $0x9,%al
  800e2f:	77 08                	ja     800e39 <strtol+0x86>
			dig = *s - '0';
  800e31:	0f be c9             	movsbl %cl,%ecx
  800e34:	83 e9 30             	sub    $0x30,%ecx
  800e37:	eb 20                	jmp    800e59 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e39:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	3c 19                	cmp    $0x19,%al
  800e40:	77 08                	ja     800e4a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e42:	0f be c9             	movsbl %cl,%ecx
  800e45:	83 e9 57             	sub    $0x57,%ecx
  800e48:	eb 0f                	jmp    800e59 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e4a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e4d:	89 f0                	mov    %esi,%eax
  800e4f:	3c 19                	cmp    $0x19,%al
  800e51:	77 16                	ja     800e69 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e53:	0f be c9             	movsbl %cl,%ecx
  800e56:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e59:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e5c:	7d 0f                	jge    800e6d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e5e:	83 c2 01             	add    $0x1,%edx
  800e61:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e65:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e67:	eb bc                	jmp    800e25 <strtol+0x72>
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	eb 02                	jmp    800e6f <strtol+0xbc>
  800e6d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e73:	74 05                	je     800e7a <strtol+0xc7>
		*endptr = (char *) s;
  800e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e78:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e7a:	f7 d8                	neg    %eax
  800e7c:	85 ff                	test   %edi,%edi
  800e7e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

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