
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800048:	e8 4b 00 00 00       	call   800098 <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	83 ec 18             	sub    $0x18,%esp
  800055:	8b 45 08             	mov    0x8(%ebp),%eax
  800058:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800062:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 c0                	test   %eax,%eax
  800067:	7e 08                	jle    800071 <libmain+0x22>
		binaryname = argv[0];
  800069:	8b 0a                	mov    (%edx),%ecx
  80006b:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800071:	89 54 24 04          	mov    %edx,0x4(%esp)
  800075:	89 04 24             	mov    %eax,(%esp)
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 02 00 00 00       	call   800084 <exit>
}
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800091:	e8 3f 00 00 00       	call   8000d5 <sys_env_destroy>
}
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	89 c3                	mov    %eax,%ebx
  8000ab:	89 c7                	mov    %eax,%edi
  8000ad:	89 c6                	mov    %eax,%esi
  8000af:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5f                   	pop    %edi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c6:	89 d1                	mov    %edx,%ecx
  8000c8:	89 d3                	mov    %edx,%ebx
  8000ca:	89 d7                	mov    %edx,%edi
  8000cc:	89 d6                	mov    %edx,%esi
  8000ce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 cb                	mov    %ecx,%ebx
  8000ed:	89 cf                	mov    %ecx,%edi
  8000ef:	89 ce                	mov    %ecx,%esi
  8000f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7e 28                	jle    80011f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  80011a:	e8 5b 02 00 00       	call   80037a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	83 c4 2c             	add    $0x2c,%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 0a 00 00 00       	mov    $0xa,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	be 00 00 00 00       	mov    $0x0,%esi
  800173:	b8 04 00 00 00       	mov    $0x4,%eax
  800178:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800181:	89 f7                	mov    %esi,%edi
  800183:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800185:	85 c0                	test   %eax,%eax
  800187:	7e 28                	jle    8001b1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800189:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800194:	00 
  800195:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001ac:	e8 c9 01 00 00       	call   80037a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b1:	83 c4 2c             	add    $0x2c,%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5e                   	pop    %esi
  8001b6:	5f                   	pop    %edi
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	7e 28                	jle    800204 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8001ef:	00 
  8001f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f7:	00 
  8001f8:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001ff:	e8 76 01 00 00       	call   80037a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800204:	83 c4 2c             	add    $0x2c,%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 28                	jle    800257 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800233:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023a:	00 
  80023b:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800242:	00 
  800243:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024a:	00 
  80024b:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800252:	e8 23 01 00 00       	call   80037a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800257:	83 c4 2c             	add    $0x2c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 08 00 00 00       	mov    $0x8,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 28                	jle    8002aa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	89 44 24 10          	mov    %eax,0x10(%esp)
  800286:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028d:	00 
  80028e:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800295:	00 
  800296:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029d:	00 
  80029e:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002a5:	e8 d0 00 00 00       	call   80037a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002aa:	83 c4 2c             	add    $0x2c,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cb:	89 df                	mov    %ebx,%edi
  8002cd:	89 de                	mov    %ebx,%esi
  8002cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	7e 28                	jle    8002fd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f0:	00 
  8002f1:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002f8:	e8 7d 00 00 00       	call   80037a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fd:	83 c4 2c             	add    $0x2c,%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030b:	be 00 00 00 00       	mov    $0x0,%esi
  800310:	b8 0b 00 00 00       	mov    $0xb,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800321:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800331:	b9 00 00 00 00       	mov    $0x0,%ecx
  800336:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 cb                	mov    %ecx,%ebx
  800340:	89 cf                	mov    %ecx,%edi
  800342:	89 ce                	mov    %ecx,%esi
  800344:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 28                	jle    800372 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80034e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800355:	00 
  800356:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80035d:	00 
  80035e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800365:	00 
  800366:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  80036d:	e8 08 00 00 00       	call   80037a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800372:	83 c4 2c             	add    $0x2c,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800382:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800385:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038b:	e8 97 fd ff ff       	call   800127 <sys_getenvid>
  800390:	8b 55 0c             	mov    0xc(%ebp),%edx
  800393:	89 54 24 10          	mov    %edx,0x10(%esp)
  800397:	8b 55 08             	mov    0x8(%ebp),%edx
  80039a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80039e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a6:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8003ad:	e8 c1 00 00 00       	call   800473 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b9:	89 04 24             	mov    %eax,(%esp)
  8003bc:	e8 51 00 00 00       	call   800412 <vcprintf>
	cprintf("\n");
  8003c1:	c7 04 24 3c 11 80 00 	movl   $0x80113c,(%esp)
  8003c8:	e8 a6 00 00 00       	call   800473 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003cd:	cc                   	int3   
  8003ce:	eb fd                	jmp    8003cd <_panic+0x53>

008003d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 14             	sub    $0x14,%esp
  8003d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003da:	8b 13                	mov    (%ebx),%edx
  8003dc:	8d 42 01             	lea    0x1(%edx),%eax
  8003df:	89 03                	mov    %eax,(%ebx)
  8003e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ed:	75 19                	jne    800408 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f6:	00 
  8003f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	e8 96 fc ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  800402:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800408:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80040c:	83 c4 14             	add    $0x14,%esp
  80040f:	5b                   	pop    %ebx
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80041b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800422:	00 00 00 
	b.cnt = 0;
  800425:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800443:	89 44 24 04          	mov    %eax,0x4(%esp)
  800447:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  80044e:	e8 71 01 00 00       	call   8005c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800453:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 2d fc ff ff       	call   800098 <sys_cputs>

	return b.cnt;
}
  80046b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800479:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	89 04 24             	mov    %eax,(%esp)
  800486:	e8 87 ff ff ff       	call   800412 <vcprintf>
	va_end(ap);

	return cnt;
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    
  80048d:	66 90                	xchg   %ax,%ax
  80048f:	90                   	nop

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 3c             	sub    $0x3c,%esp
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004bd:	39 d9                	cmp    %ebx,%ecx
  8004bf:	72 05                	jb     8004c6 <printnum+0x36>
  8004c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004c4:	77 69                	ja     80052f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8004dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	89 d6                	mov    %edx,%esi
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8004ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 04 24             	mov    %eax,(%esp)
  8004f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	e8 3c 09 00 00       	call   800e40 <__udivdi3>
  800504:	89 d9                	mov    %ebx,%ecx
  800506:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 71 ff ff ff       	call   800490 <printnum>
  80051f:	eb 1b                	jmp    80053c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	8b 45 18             	mov    0x18(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d3                	call   *%ebx
  80052d:	eb 03                	jmp    800532 <printnum+0xa2>
  80052f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	85 f6                	test   %esi,%esi
  800537:	7f e8                	jg     800521 <printnum+0x91>
  800539:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80054a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 0c 0a 00 00       	call   800f70 <__umoddi3>
  800564:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800568:	0f be 80 3e 11 80 00 	movsbl 0x80113e(%eax),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800575:	ff d0                	call   *%eax
}
  800577:	83 c4 3c             	add    $0x3c,%esp
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800585:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	3b 50 04             	cmp    0x4(%eax),%edx
  80058e:	73 0a                	jae    80059a <sprintputch+0x1b>
		*b->buf++ = ch;
  800590:	8d 4a 01             	lea    0x1(%edx),%ecx
  800593:	89 08                	mov    %ecx,(%eax)
  800595:	8b 45 08             	mov    0x8(%ebp),%eax
  800598:	88 02                	mov    %al,(%edx)
}
  80059a:	5d                   	pop    %ebp
  80059b:	c3                   	ret    

0080059c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	e8 02 00 00 00       	call   8005c4 <vprintfmt>
	va_end(ap);
}
  8005c2:	c9                   	leave  
  8005c3:	c3                   	ret    

008005c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	57                   	push   %edi
  8005c8:	56                   	push   %esi
  8005c9:	53                   	push   %ebx
  8005ca:	83 ec 3c             	sub    $0x3c,%esp
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005d6:	eb 11                	jmp    8005e9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	0f 84 48 04 00 00    	je     800a28 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005e9:	83 c7 01             	add    $0x1,%edi
  8005ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f0:	83 f8 25             	cmp    $0x25,%eax
  8005f3:	75 e3                	jne    8005d8 <vprintfmt+0x14>
  8005f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800600:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800607:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	eb 1f                	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800618:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80061c:	eb 16                	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800621:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800625:	eb 0d                	jmp    800634 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800627:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8d 47 01             	lea    0x1(%edi),%eax
  800637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063a:	0f b6 17             	movzbl (%edi),%edx
  80063d:	0f b6 c2             	movzbl %dl,%eax
  800640:	83 ea 23             	sub    $0x23,%edx
  800643:	80 fa 55             	cmp    $0x55,%dl
  800646:	0f 87 bf 03 00 00    	ja     800a0b <vprintfmt+0x447>
  80064c:	0f b6 d2             	movzbl %dl,%edx
  80064f:	ff 24 95 00 12 80 00 	jmp    *0x801200(,%edx,4)
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800659:	ba 00 00 00 00       	mov    $0x0,%edx
  80065e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800661:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800664:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800668:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80066b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80066e:	83 f9 09             	cmp    $0x9,%ecx
  800671:	77 3c                	ja     8006af <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800673:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800676:	eb e9                	jmp    800661 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068c:	eb 27                	jmp    8006b5 <vprintfmt+0xf1>
  80068e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	0f 49 c2             	cmovns %edx,%eax
  80069b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	eb 91                	jmp    800634 <vprintfmt+0x70>
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006ad:	eb 85                	jmp    800634 <vprintfmt+0x70>
  8006af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b9:	0f 89 75 ff ff ff    	jns    800634 <vprintfmt+0x70>
  8006bf:	e9 63 ff ff ff       	jmp    800627 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ca:	e9 65 ff ff ff       	jmp    800634 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e4:	e9 00 ff ff ff       	jmp    8005e9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ec:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	99                   	cltd   
  8006f3:	31 d0                	xor    %edx,%eax
  8006f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f7:	83 f8 09             	cmp    $0x9,%eax
  8006fa:	7f 0b                	jg     800707 <vprintfmt+0x143>
  8006fc:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800703:	85 d2                	test   %edx,%edx
  800705:	75 20                	jne    800727 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800707:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070b:	c7 44 24 08 56 11 80 	movl   $0x801156,0x8(%esp)
  800712:	00 
  800713:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800717:	89 34 24             	mov    %esi,(%esp)
  80071a:	e8 7d fe ff ff       	call   80059c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800722:	e9 c2 fe ff ff       	jmp    8005e9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800727:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80072b:	c7 44 24 08 5f 11 80 	movl   $0x80115f,0x8(%esp)
  800732:	00 
  800733:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800737:	89 34 24             	mov    %esi,(%esp)
  80073a:	e8 5d fe ff ff       	call   80059c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	e9 a2 fe ff ff       	jmp    8005e9 <vprintfmt+0x25>
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80074d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800757:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800759:	85 ff                	test   %edi,%edi
  80075b:	b8 4f 11 80 00       	mov    $0x80114f,%eax
  800760:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800763:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800767:	0f 84 92 00 00 00    	je     8007ff <vprintfmt+0x23b>
  80076d:	85 c9                	test   %ecx,%ecx
  80076f:	0f 8e 98 00 00 00    	jle    80080d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800775:	89 54 24 04          	mov    %edx,0x4(%esp)
  800779:	89 3c 24             	mov    %edi,(%esp)
  80077c:	e8 47 03 00 00       	call   800ac8 <strnlen>
  800781:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800784:	29 c1                	sub    %eax,%ecx
  800786:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800789:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800790:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800793:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800795:	eb 0f                	jmp    8007a6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	85 ff                	test   %edi,%edi
  8007a8:	7f ed                	jg     800797 <vprintfmt+0x1d3>
  8007aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007b0:	85 c9                	test   %ecx,%ecx
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	0f 49 c1             	cmovns %ecx,%eax
  8007ba:	29 c1                	sub    %eax,%ecx
  8007bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c5:	89 cb                	mov    %ecx,%ebx
  8007c7:	eb 50                	jmp    800819 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007cd:	74 1e                	je     8007ed <vprintfmt+0x229>
  8007cf:	0f be d2             	movsbl %dl,%edx
  8007d2:	83 ea 20             	sub    $0x20,%edx
  8007d5:	83 fa 5e             	cmp    $0x5e,%edx
  8007d8:	76 13                	jbe    8007ed <vprintfmt+0x229>
					putch('?', putdat);
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
  8007eb:	eb 0d                	jmp    8007fa <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fa:	83 eb 01             	sub    $0x1,%ebx
  8007fd:	eb 1a                	jmp    800819 <vprintfmt+0x255>
  8007ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800802:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800805:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800808:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80080b:	eb 0c                	jmp    800819 <vprintfmt+0x255>
  80080d:	89 75 08             	mov    %esi,0x8(%ebp)
  800810:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800813:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800816:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800819:	83 c7 01             	add    $0x1,%edi
  80081c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800820:	0f be c2             	movsbl %dl,%eax
  800823:	85 c0                	test   %eax,%eax
  800825:	74 25                	je     80084c <vprintfmt+0x288>
  800827:	85 f6                	test   %esi,%esi
  800829:	78 9e                	js     8007c9 <vprintfmt+0x205>
  80082b:	83 ee 01             	sub    $0x1,%esi
  80082e:	79 99                	jns    8007c9 <vprintfmt+0x205>
  800830:	89 df                	mov    %ebx,%edi
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800838:	eb 1a                	jmp    800854 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80083a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800845:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800847:	83 ef 01             	sub    $0x1,%edi
  80084a:	eb 08                	jmp    800854 <vprintfmt+0x290>
  80084c:	89 df                	mov    %ebx,%edi
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800854:	85 ff                	test   %edi,%edi
  800856:	7f e2                	jg     80083a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80085b:	e9 89 fd ff ff       	jmp    8005e9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800860:	83 f9 01             	cmp    $0x1,%ecx
  800863:	7e 19                	jle    80087e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 50 04             	mov    0x4(%eax),%edx
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800870:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
  80087c:	eb 38                	jmp    8008b6 <vprintfmt+0x2f2>
	else if (lflag)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 1b                	je     80089d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8b 00                	mov    (%eax),%eax
  800887:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088a:	89 c1                	mov    %eax,%ecx
  80088c:	c1 f9 1f             	sar    $0x1f,%ecx
  80088f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	8d 40 04             	lea    0x4(%eax),%eax
  800898:	89 45 14             	mov    %eax,0x14(%ebp)
  80089b:	eb 19                	jmp    8008b6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 00                	mov    (%eax),%eax
  8008a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a5:	89 c1                	mov    %eax,%ecx
  8008a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8008aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008bc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c5:	0f 89 04 01 00 00    	jns    8009cf <vprintfmt+0x40b>
				putch('-', putdat);
  8008cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008db:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008de:	f7 da                	neg    %edx
  8008e0:	83 d1 00             	adc    $0x0,%ecx
  8008e3:	f7 d9                	neg    %ecx
  8008e5:	e9 e5 00 00 00       	jmp    8009cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ea:	83 f9 01             	cmp    $0x1,%ecx
  8008ed:	7e 10                	jle    8008ff <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f7:	8d 40 08             	lea    0x8(%eax),%eax
  8008fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8008fd:	eb 26                	jmp    800925 <vprintfmt+0x361>
	else if (lflag)
  8008ff:	85 c9                	test   %ecx,%ecx
  800901:	74 12                	je     800915 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 10                	mov    (%eax),%edx
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090d:	8d 40 04             	lea    0x4(%eax),%eax
  800910:	89 45 14             	mov    %eax,0x14(%ebp)
  800913:	eb 10                	jmp    800925 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 10                	mov    (%eax),%edx
  80091a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091f:	8d 40 04             	lea    0x4(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800925:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80092a:	e9 a0 00 00 00       	jmp    8009cf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80092f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800933:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80093a:	ff d6                	call   *%esi
			putch('X', putdat);
  80093c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800940:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800947:	ff d6                	call   *%esi
			putch('X', putdat);
  800949:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800954:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800959:	e9 8b fc ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  80095e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800962:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800969:	ff d6                	call   *%esi
			putch('x', putdat);
  80096b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800976:	ff d6                	call   *%esi
			num = (unsigned long long)
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80098d:	eb 40                	jmp    8009cf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80098f:	83 f9 01             	cmp    $0x1,%ecx
  800992:	7e 10                	jle    8009a4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8b 10                	mov    (%eax),%edx
  800999:	8b 48 04             	mov    0x4(%eax),%ecx
  80099c:	8d 40 08             	lea    0x8(%eax),%eax
  80099f:	89 45 14             	mov    %eax,0x14(%ebp)
  8009a2:	eb 26                	jmp    8009ca <vprintfmt+0x406>
	else if (lflag)
  8009a4:	85 c9                	test   %ecx,%ecx
  8009a6:	74 12                	je     8009ba <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009b2:	8d 40 04             	lea    0x4(%eax),%eax
  8009b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8009b8:	eb 10                	jmp    8009ca <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8b 10                	mov    (%eax),%edx
  8009bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009c4:	8d 40 04             	lea    0x4(%eax),%eax
  8009c7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8009ca:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e2:	89 14 24             	mov    %edx,(%esp)
  8009e5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e9:	89 da                	mov    %ebx,%edx
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	e8 9e fa ff ff       	call   800490 <printnum>
			break;
  8009f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009f5:	e9 ef fb ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fe:	89 04 24             	mov    %eax,(%esp)
  800a01:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a06:	e9 de fb ff ff       	jmp    8005e9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a16:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a18:	eb 03                	jmp    800a1d <vprintfmt+0x459>
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a21:	75 f7                	jne    800a1a <vprintfmt+0x456>
  800a23:	e9 c1 fb ff ff       	jmp    8005e9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800a28:	83 c4 3c             	add    $0x3c,%esp
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 28             	sub    $0x28,%esp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a3f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a43:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 30                	je     800a81 <vsnprintf+0x51>
  800a51:	85 d2                	test   %edx,%edx
  800a53:	7e 2c                	jle    800a81 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a55:	8b 45 14             	mov    0x14(%ebp),%eax
  800a58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a63:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	c7 04 24 7f 05 80 00 	movl   $0x80057f,(%esp)
  800a71:	e8 4e fb ff ff       	call   8005c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a79:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a7f:	eb 05                	jmp    800a86 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a95:	8b 45 10             	mov    0x10(%ebp),%eax
  800a98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 82 ff ff ff       	call   800a30 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 03                	jmp    800ac0 <strlen+0x10>
		n++;
  800abd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac4:	75 f7                	jne    800abd <strlen+0xd>
		n++;
	return n;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	eb 03                	jmp    800adb <strnlen+0x13>
		n++;
  800ad8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adb:	39 d0                	cmp    %edx,%eax
  800add:	74 06                	je     800ae5 <strnlen+0x1d>
  800adf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ae3:	75 f3                	jne    800ad8 <strnlen+0x10>
		n++;
	return n;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800afd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b00:	84 db                	test   %bl,%bl
  800b02:	75 ef                	jne    800af3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b11:	89 1c 24             	mov    %ebx,(%esp)
  800b14:	e8 97 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b20:	01 d8                	add    %ebx,%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 bd ff ff ff       	call   800ae7 <strcpy>
	return dst;
}
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	83 c4 08             	add    $0x8,%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b42:	89 f2                	mov    %esi,%edx
  800b44:	eb 0f                	jmp    800b55 <strncpy+0x23>
		*dst++ = *src;
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b55:	39 da                	cmp    %ebx,%edx
  800b57:	75 ed                	jne    800b46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b59:	89 f0                	mov    %esi,%eax
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 75 08             	mov    0x8(%ebp),%esi
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	75 0b                	jne    800b82 <strlcpy+0x23>
  800b77:	eb 1d                	jmp    800b96 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b79:	83 c0 01             	add    $0x1,%eax
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b82:	39 d8                	cmp    %ebx,%eax
  800b84:	74 0b                	je     800b91 <strlcpy+0x32>
  800b86:	0f b6 0a             	movzbl (%edx),%ecx
  800b89:	84 c9                	test   %cl,%cl
  800b8b:	75 ec                	jne    800b79 <strlcpy+0x1a>
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	eb 02                	jmp    800b93 <strlcpy+0x34>
  800b91:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b93:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b96:	29 f0                	sub    %esi,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba5:	eb 06                	jmp    800bad <strcmp+0x11>
		p++, q++;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bad:	0f b6 01             	movzbl (%ecx),%eax
  800bb0:	84 c0                	test   %al,%al
  800bb2:	74 04                	je     800bb8 <strcmp+0x1c>
  800bb4:	3a 02                	cmp    (%edx),%al
  800bb6:	74 ef                	je     800ba7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb8:	0f b6 c0             	movzbl %al,%eax
  800bbb:	0f b6 12             	movzbl (%edx),%edx
  800bbe:	29 d0                	sub    %edx,%eax
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bd1:	eb 06                	jmp    800bd9 <strncmp+0x17>
		n--, p++, q++;
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd9:	39 d8                	cmp    %ebx,%eax
  800bdb:	74 15                	je     800bf2 <strncmp+0x30>
  800bdd:	0f b6 08             	movzbl (%eax),%ecx
  800be0:	84 c9                	test   %cl,%cl
  800be2:	74 04                	je     800be8 <strncmp+0x26>
  800be4:	3a 0a                	cmp    (%edx),%cl
  800be6:	74 eb                	je     800bd3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 00             	movzbl (%eax),%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
  800bf0:	eb 05                	jmp    800bf7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c04:	eb 07                	jmp    800c0d <strchr+0x13>
		if (*s == c)
  800c06:	38 ca                	cmp    %cl,%dl
  800c08:	74 0f                	je     800c19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 f2                	jne    800c06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	eb 07                	jmp    800c2e <strfind+0x13>
		if (*s == c)
  800c27:	38 ca                	cmp    %cl,%dl
  800c29:	74 0a                	je     800c35 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	0f b6 10             	movzbl (%eax),%edx
  800c31:	84 d2                	test   %dl,%dl
  800c33:	75 f2                	jne    800c27 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c43:	85 c9                	test   %ecx,%ecx
  800c45:	74 36                	je     800c7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4d:	75 28                	jne    800c77 <memset+0x40>
  800c4f:	f6 c1 03             	test   $0x3,%cl
  800c52:	75 23                	jne    800c77 <memset+0x40>
		c &= 0xFF;
  800c54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	c1 e3 08             	shl    $0x8,%ebx
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	c1 e6 18             	shl    $0x18,%esi
  800c62:	89 d0                	mov    %edx,%eax
  800c64:	c1 e0 10             	shl    $0x10,%eax
  800c67:	09 f0                	or     %esi,%eax
  800c69:	09 c2                	or     %eax,%edx
  800c6b:	89 d0                	mov    %edx,%eax
  800c6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c6f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c72:	fc                   	cld    
  800c73:	f3 ab                	rep stos %eax,%es:(%edi)
  800c75:	eb 06                	jmp    800c7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	fc                   	cld    
  800c7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c92:	39 c6                	cmp    %eax,%esi
  800c94:	73 35                	jae    800ccb <memmove+0x47>
  800c96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 2e                	jae    800ccb <memmove+0x47>
		s += n;
		d += n;
  800c9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800caa:	75 13                	jne    800cbf <memmove+0x3b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 0e                	jne    800cbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cb1:	83 ef 04             	sub    $0x4,%edi
  800cb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800cba:	fd                   	std    
  800cbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbd:	eb 09                	jmp    800cc8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cbf:	83 ef 01             	sub    $0x1,%edi
  800cc2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cc5:	fd                   	std    
  800cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc8:	fc                   	cld    
  800cc9:	eb 1d                	jmp    800ce8 <memmove+0x64>
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ccf:	f6 c2 03             	test   $0x3,%dl
  800cd2:	75 0f                	jne    800ce3 <memmove+0x5f>
  800cd4:	f6 c1 03             	test   $0x3,%cl
  800cd7:	75 0a                	jne    800ce3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	fc                   	cld    
  800cdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce1:	eb 05                	jmp    800ce8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce3:	89 c7                	mov    %eax,%edi
  800ce5:	fc                   	cld    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	89 04 24             	mov    %eax,(%esp)
  800d06:	e8 79 ff ff ff       	call   800c84 <memmove>
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1d:	eb 1a                	jmp    800d39 <memcmp+0x2c>
		if (*s1 != *s2)
  800d1f:	0f b6 02             	movzbl (%edx),%eax
  800d22:	0f b6 19             	movzbl (%ecx),%ebx
  800d25:	38 d8                	cmp    %bl,%al
  800d27:	74 0a                	je     800d33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d29:	0f b6 c0             	movzbl %al,%eax
  800d2c:	0f b6 db             	movzbl %bl,%ebx
  800d2f:	29 d8                	sub    %ebx,%eax
  800d31:	eb 0f                	jmp    800d42 <memcmp+0x35>
		s1++, s2++;
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d39:	39 f2                	cmp    %esi,%edx
  800d3b:	75 e2                	jne    800d1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d54:	eb 07                	jmp    800d5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	38 08                	cmp    %cl,(%eax)
  800d58:	74 07                	je     800d61 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	39 d0                	cmp    %edx,%eax
  800d5f:	72 f5                	jb     800d56 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6f:	eb 03                	jmp    800d74 <strtol+0x11>
		s++;
  800d71:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d74:	0f b6 0a             	movzbl (%edx),%ecx
  800d77:	80 f9 09             	cmp    $0x9,%cl
  800d7a:	74 f5                	je     800d71 <strtol+0xe>
  800d7c:	80 f9 20             	cmp    $0x20,%cl
  800d7f:	74 f0                	je     800d71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d81:	80 f9 2b             	cmp    $0x2b,%cl
  800d84:	75 0a                	jne    800d90 <strtol+0x2d>
		s++;
  800d86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d89:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8e:	eb 11                	jmp    800da1 <strtol+0x3e>
  800d90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d95:	80 f9 2d             	cmp    $0x2d,%cl
  800d98:	75 07                	jne    800da1 <strtol+0x3e>
		s++, neg = 1;
  800d9a:	8d 52 01             	lea    0x1(%edx),%edx
  800d9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800da6:	75 15                	jne    800dbd <strtol+0x5a>
  800da8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dab:	75 10                	jne    800dbd <strtol+0x5a>
  800dad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800db1:	75 0a                	jne    800dbd <strtol+0x5a>
		s += 2, base = 16;
  800db3:	83 c2 02             	add    $0x2,%edx
  800db6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dbb:	eb 10                	jmp    800dcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 0c                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc6:	75 05                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
  800dc8:	83 c2 01             	add    $0x1,%edx
  800dcb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd5:	0f b6 0a             	movzbl (%edx),%ecx
  800dd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	3c 09                	cmp    $0x9,%al
  800ddf:	77 08                	ja     800de9 <strtol+0x86>
			dig = *s - '0';
  800de1:	0f be c9             	movsbl %cl,%ecx
  800de4:	83 e9 30             	sub    $0x30,%ecx
  800de7:	eb 20                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800de9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	3c 19                	cmp    $0x19,%al
  800df0:	77 08                	ja     800dfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800df2:	0f be c9             	movsbl %cl,%ecx
  800df5:	83 e9 57             	sub    $0x57,%ecx
  800df8:	eb 0f                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	3c 19                	cmp    $0x19,%al
  800e01:	77 16                	ja     800e19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e03:	0f be c9             	movsbl %cl,%ecx
  800e06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e0c:	7d 0f                	jge    800e1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e0e:	83 c2 01             	add    $0x1,%edx
  800e11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e17:	eb bc                	jmp    800dd5 <strtol+0x72>
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	eb 02                	jmp    800e1f <strtol+0xbc>
  800e1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e23:	74 05                	je     800e2a <strtol+0xc7>
		*endptr = (char *) s;
  800e25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e2a:	f7 d8                	neg    %eax
  800e2c:	85 ff                	test   %edi,%edi
  800e2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__udivdi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e56:	85 c0                	test   %eax,%eax
  800e58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e5c:	89 ea                	mov    %ebp,%edx
  800e5e:	89 0c 24             	mov    %ecx,(%esp)
  800e61:	75 2d                	jne    800e90 <__udivdi3+0x50>
  800e63:	39 e9                	cmp    %ebp,%ecx
  800e65:	77 61                	ja     800ec8 <__udivdi3+0x88>
  800e67:	85 c9                	test   %ecx,%ecx
  800e69:	89 ce                	mov    %ecx,%esi
  800e6b:	75 0b                	jne    800e78 <__udivdi3+0x38>
  800e6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e72:	31 d2                	xor    %edx,%edx
  800e74:	f7 f1                	div    %ecx
  800e76:	89 c6                	mov    %eax,%esi
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	89 e8                	mov    %ebp,%eax
  800e7c:	f7 f6                	div    %esi
  800e7e:	89 c5                	mov    %eax,%ebp
  800e80:	89 f8                	mov    %edi,%eax
  800e82:	f7 f6                	div    %esi
  800e84:	89 ea                	mov    %ebp,%edx
  800e86:	83 c4 0c             	add    $0xc,%esp
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	39 e8                	cmp    %ebp,%eax
  800e92:	77 24                	ja     800eb8 <__udivdi3+0x78>
  800e94:	0f bd e8             	bsr    %eax,%ebp
  800e97:	83 f5 1f             	xor    $0x1f,%ebp
  800e9a:	75 3c                	jne    800ed8 <__udivdi3+0x98>
  800e9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea0:	39 34 24             	cmp    %esi,(%esp)
  800ea3:	0f 86 9f 00 00 00    	jbe    800f48 <__udivdi3+0x108>
  800ea9:	39 d0                	cmp    %edx,%eax
  800eab:	0f 82 97 00 00 00    	jb     800f48 <__udivdi3+0x108>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	31 d2                	xor    %edx,%edx
  800eba:	31 c0                	xor    %eax,%eax
  800ebc:	83 c4 0c             	add    $0xc,%esp
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	89 f8                	mov    %edi,%eax
  800eca:	f7 f1                	div    %ecx
  800ecc:	31 d2                	xor    %edx,%edx
  800ece:	83 c4 0c             	add    $0xc,%esp
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	8b 3c 24             	mov    (%esp),%edi
  800edd:	d3 e0                	shl    %cl,%eax
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee6:	29 e8                	sub    %ebp,%eax
  800ee8:	89 c1                	mov    %eax,%ecx
  800eea:	d3 ef                	shr    %cl,%edi
  800eec:	89 e9                	mov    %ebp,%ecx
  800eee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef2:	8b 3c 24             	mov    (%esp),%edi
  800ef5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ef9:	89 d6                	mov    %edx,%esi
  800efb:	d3 e7                	shl    %cl,%edi
  800efd:	89 c1                	mov    %eax,%ecx
  800eff:	89 3c 24             	mov    %edi,(%esp)
  800f02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f06:	d3 ee                	shr    %cl,%esi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	d3 e2                	shl    %cl,%edx
  800f0c:	89 c1                	mov    %eax,%ecx
  800f0e:	d3 ef                	shr    %cl,%edi
  800f10:	09 d7                	or     %edx,%edi
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	89 f8                	mov    %edi,%eax
  800f16:	f7 74 24 08          	divl   0x8(%esp)
  800f1a:	89 d6                	mov    %edx,%esi
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	f7 24 24             	mull   (%esp)
  800f21:	39 d6                	cmp    %edx,%esi
  800f23:	89 14 24             	mov    %edx,(%esp)
  800f26:	72 30                	jb     800f58 <__udivdi3+0x118>
  800f28:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f2c:	89 e9                	mov    %ebp,%ecx
  800f2e:	d3 e2                	shl    %cl,%edx
  800f30:	39 c2                	cmp    %eax,%edx
  800f32:	73 05                	jae    800f39 <__udivdi3+0xf9>
  800f34:	3b 34 24             	cmp    (%esp),%esi
  800f37:	74 1f                	je     800f58 <__udivdi3+0x118>
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	e9 7a ff ff ff       	jmp    800ebc <__udivdi3+0x7c>
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4f:	e9 68 ff ff ff       	jmp    800ebc <__udivdi3+0x7c>
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 0c             	add    $0xc,%esp
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
  800f64:	66 90                	xchg   %ax,%ax
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	83 ec 14             	sub    $0x14,%esp
  800f76:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f88:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f90:	89 34 24             	mov    %esi,(%esp)
  800f93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f9f:	75 17                	jne    800fb8 <__umoddi3+0x48>
  800fa1:	39 fe                	cmp    %edi,%esi
  800fa3:	76 4b                	jbe    800ff0 <__umoddi3+0x80>
  800fa5:	89 c8                	mov    %ecx,%eax
  800fa7:	89 fa                	mov    %edi,%edx
  800fa9:	f7 f6                	div    %esi
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	83 c4 14             	add    $0x14,%esp
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	39 f8                	cmp    %edi,%eax
  800fba:	77 54                	ja     801010 <__umoddi3+0xa0>
  800fbc:	0f bd e8             	bsr    %eax,%ebp
  800fbf:	83 f5 1f             	xor    $0x1f,%ebp
  800fc2:	75 5c                	jne    801020 <__umoddi3+0xb0>
  800fc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fc8:	39 3c 24             	cmp    %edi,(%esp)
  800fcb:	0f 87 e7 00 00 00    	ja     8010b8 <__umoddi3+0x148>
  800fd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd5:	29 f1                	sub    %esi,%ecx
  800fd7:	19 c7                	sbb    %eax,%edi
  800fd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fe1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fe5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fe9:	83 c4 14             	add    $0x14,%esp
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    
  800ff0:	85 f6                	test   %esi,%esi
  800ff2:	89 f5                	mov    %esi,%ebp
  800ff4:	75 0b                	jne    801001 <__umoddi3+0x91>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f6                	div    %esi
  800fff:	89 c5                	mov    %eax,%ebp
  801001:	8b 44 24 04          	mov    0x4(%esp),%eax
  801005:	31 d2                	xor    %edx,%edx
  801007:	f7 f5                	div    %ebp
  801009:	89 c8                	mov    %ecx,%eax
  80100b:	f7 f5                	div    %ebp
  80100d:	eb 9c                	jmp    800fab <__umoddi3+0x3b>
  80100f:	90                   	nop
  801010:	89 c8                	mov    %ecx,%eax
  801012:	89 fa                	mov    %edi,%edx
  801014:	83 c4 14             	add    $0x14,%esp
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
  80101b:	90                   	nop
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	8b 04 24             	mov    (%esp),%eax
  801023:	be 20 00 00 00       	mov    $0x20,%esi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	29 ee                	sub    %ebp,%esi
  80102c:	d3 e2                	shl    %cl,%edx
  80102e:	89 f1                	mov    %esi,%ecx
  801030:	d3 e8                	shr    %cl,%eax
  801032:	89 e9                	mov    %ebp,%ecx
  801034:	89 44 24 04          	mov    %eax,0x4(%esp)
  801038:	8b 04 24             	mov    (%esp),%eax
  80103b:	09 54 24 04          	or     %edx,0x4(%esp)
  80103f:	89 fa                	mov    %edi,%edx
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 f1                	mov    %esi,%ecx
  801045:	89 44 24 08          	mov    %eax,0x8(%esp)
  801049:	8b 44 24 10          	mov    0x10(%esp),%eax
  80104d:	d3 ea                	shr    %cl,%edx
  80104f:	89 e9                	mov    %ebp,%ecx
  801051:	d3 e7                	shl    %cl,%edi
  801053:	89 f1                	mov    %esi,%ecx
  801055:	d3 e8                	shr    %cl,%eax
  801057:	89 e9                	mov    %ebp,%ecx
  801059:	09 f8                	or     %edi,%eax
  80105b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80105f:	f7 74 24 04          	divl   0x4(%esp)
  801063:	d3 e7                	shl    %cl,%edi
  801065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801069:	89 d7                	mov    %edx,%edi
  80106b:	f7 64 24 08          	mull   0x8(%esp)
  80106f:	39 d7                	cmp    %edx,%edi
  801071:	89 c1                	mov    %eax,%ecx
  801073:	89 14 24             	mov    %edx,(%esp)
  801076:	72 2c                	jb     8010a4 <__umoddi3+0x134>
  801078:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80107c:	72 22                	jb     8010a0 <__umoddi3+0x130>
  80107e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801082:	29 c8                	sub    %ecx,%eax
  801084:	19 d7                	sbb    %edx,%edi
  801086:	89 e9                	mov    %ebp,%ecx
  801088:	89 fa                	mov    %edi,%edx
  80108a:	d3 e8                	shr    %cl,%eax
  80108c:	89 f1                	mov    %esi,%ecx
  80108e:	d3 e2                	shl    %cl,%edx
  801090:	89 e9                	mov    %ebp,%ecx
  801092:	d3 ef                	shr    %cl,%edi
  801094:	09 d0                	or     %edx,%eax
  801096:	89 fa                	mov    %edi,%edx
  801098:	83 c4 14             	add    $0x14,%esp
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    
  80109f:	90                   	nop
  8010a0:	39 d7                	cmp    %edx,%edi
  8010a2:	75 da                	jne    80107e <__umoddi3+0x10e>
  8010a4:	8b 14 24             	mov    (%esp),%edx
  8010a7:	89 c1                	mov    %eax,%ecx
  8010a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010b1:	eb cb                	jmp    80107e <__umoddi3+0x10e>
  8010b3:	90                   	nop
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010bc:	0f 82 0f ff ff ff    	jb     800fd1 <__umoddi3+0x61>
  8010c2:	e9 1a ff ff ff       	jmp    800fe1 <__umoddi3+0x71>
