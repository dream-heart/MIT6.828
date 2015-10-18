
obj/user/faultregs：     文件格式 elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 b1 17 80 	movl   $0x8017b1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 80 17 80 00 	movl   $0x801780,(%esp)
  80005b:	e8 97 06 00 00       	call   8006f7 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 90 17 80 	movl   $0x801790,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  80007b:	e8 77 06 00 00       	call   8006f7 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  80008d:	e8 65 06 00 00       	call   8006f7 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8000a0:	e8 52 06 00 00       	call   8006f7 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 b2 17 80 	movl   $0x8017b2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8000c7:	e8 2b 06 00 00       	call   8006f7 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8000db:	e8 17 06 00 00       	call   8006f7 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8000e9:	e8 09 06 00 00       	call   8006f7 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 b6 17 80 	movl   $0x8017b6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800110:	e8 e2 05 00 00       	call   8006f7 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800124:	e8 ce 05 00 00       	call   8006f7 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800132:	e8 c0 05 00 00       	call   8006f7 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 ba 17 80 	movl   $0x8017ba,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800159:	e8 99 05 00 00       	call   8006f7 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  80016d:	e8 85 05 00 00       	call   8006f7 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  80017b:	e8 77 05 00 00       	call   8006f7 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 be 17 80 	movl   $0x8017be,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001a2:	e8 50 05 00 00       	call   8006f7 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8001b6:	e8 3c 05 00 00       	call   8006f7 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8001c4:	e8 2e 05 00 00       	call   8006f7 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 c2 17 80 	movl   $0x8017c2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001eb:	e8 07 05 00 00       	call   8006f7 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8001ff:	e8 f3 04 00 00       	call   8006f7 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  80020d:	e8 e5 04 00 00       	call   8006f7 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 c6 17 80 	movl   $0x8017c6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800234:	e8 be 04 00 00       	call   8006f7 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800248:	e8 aa 04 00 00       	call   8006f7 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800256:	e8 9c 04 00 00       	call   8006f7 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 ca 17 80 	movl   $0x8017ca,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  80027d:	e8 75 04 00 00       	call   8006f7 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800291:	e8 61 04 00 00       	call   8006f7 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  80029f:	e8 53 04 00 00       	call   8006f7 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ce 17 80 	movl   $0x8017ce,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8002c6:	e8 2c 04 00 00       	call   8006f7 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8002da:	e8 18 04 00 00       	call   8006f7 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8002e8:	e8 0a 04 00 00       	call   8006f7 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 d5 17 80 	movl   $0x8017d5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  80030f:	e8 e3 03 00 00       	call   8006f7 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800323:	e8 cf 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 d9 17 80 00 	movl   $0x8017d9,(%esp)
  800336:	e8 bc 03 00 00       	call   8006f7 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800348:	e8 aa 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 d9 17 80 00 	movl   $0x8017d9,(%esp)
  80035b:	e8 97 03 00 00       	call   8006f7 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800369:	e8 89 03 00 00       	call   8006f7 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800377:	e8 7b 03 00 00       	call   8006f7 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 40 18 80 	movl   $0x801840,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 e7 17 80 00 	movl   $0x8017e7,(%esp)
  8003b9:	e8 3e 02 00 00       	call   8005fc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 a0 20 80 00    	mov    %edx,0x8020a0
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 a4 20 80 00    	mov    %edx,0x8020a4
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 a8 20 80 00    	mov    %edx,0x8020a8
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 ac 20 80 00    	mov    %edx,0x8020ac
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 b0 20 80 00    	mov    %edx,0x8020b0
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 b8 20 80 00    	mov    %edx,0x8020b8
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 bc 20 80 00    	mov    %edx,0x8020bc
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 c0 20 80 00    	mov    %edx,0x8020c0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 ff 17 80 	movl   $0x8017ff,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 0d 18 80 00 	movl   $0x80180d,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba f8 17 80 00       	mov    $0x8017f8,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 35 0d 00 00       	call   801194 <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 14 18 80 	movl   $0x801814,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 e7 17 80 00 	movl   $0x8017e7,(%esp)
  80047e:	e8 79 01 00 00       	call   8005fc <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 65 0f 00 00       	call   8013fc <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 44 20 80 00       	mov    %eax,0x802044
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 40 20 80 00       	mov    %eax,0x802040
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004b8:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004be:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c4:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004ca:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004db:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004f1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004f7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004fd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800503:	89 15 74 20 80 00    	mov    %edx,0x802074
  800509:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80050f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800514:	89 25 88 20 80 00    	mov    %esp,0x802088
  80051a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  800520:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800526:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80052c:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800532:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800538:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80053e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800543:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 84 20 80 00       	mov    %eax,0x802084
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 74 18 80 00 	movl   $0x801874,(%esp)
  800562:	e8 90 01 00 00       	call   8006f7 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 27 18 80 	movl   $0x801827,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 38 18 80 00 	movl   $0x801838,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba f8 17 80 00       	mov    $0x8017f8,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
  800596:	66 90                	xchg   %ax,%ax

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8005aa:	e8 85 0b 00 00       	call   801134 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 03                	mov    (%ebx),%eax
  8005c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 34 24             	mov    %esi,(%esp)
  8005d3:	e8 ad fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
  8005e7:	90                   	nop

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f5:	e8 dd 0a 00 00       	call   8010d7 <sys_env_destroy>
}
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800607:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80060d:	e8 22 0b 00 00       	call   801134 <sys_getenvid>
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
  800615:	89 54 24 10          	mov    %edx,0x10(%esp)
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 a0 18 80 00 	movl   $0x8018a0,(%esp)
  80062f:	e8 c3 00 00 00       	call   8006f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800634:	89 74 24 04          	mov    %esi,0x4(%esp)
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 53 00 00 00       	call   800696 <vcprintf>
	cprintf("\n");
  800643:	c7 04 24 b0 17 80 00 	movl   $0x8017b0,(%esp)
  80064a:	e8 a8 00 00 00       	call   8006f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064f:	cc                   	int3   
  800650:	eb fd                	jmp    80064f <_panic+0x53>
  800652:	66 90                	xchg   %ax,%ax

00800654 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	83 ec 14             	sub    $0x14,%esp
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065e:	8b 03                	mov    (%ebx),%eax
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800667:	83 c0 01             	add    $0x1,%eax
  80066a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80066c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800671:	75 19                	jne    80068c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800673:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80067a:	00 
  80067b:	8d 43 08             	lea    0x8(%ebx),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 f2 09 00 00       	call   801078 <sys_cputs>
		b->idx = 0;
  800686:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800690:	83 c4 14             	add    $0x14,%esp
  800693:	5b                   	pop    %ebx
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a6:	00 00 00 
	b.cnt = 0;
  8006a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 54 06 80 00 	movl   $0x800654,(%esp)
  8006d2:	e8 96 01 00 00       	call   80086d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 89 09 00 00       	call   801078 <sys_cputs>

	return b.cnt;
}
  8006ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 87 ff ff ff       	call   800696 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
  800711:	66 90                	xchg   %ax,%ax
  800713:	66 90                	xchg   %ax,%ax
  800715:	66 90                	xchg   %ax,%ax
  800717:	66 90                	xchg   %ax,%ax
  800719:	66 90                	xchg   %ax,%ax
  80071b:	66 90                	xchg   %ax,%ax
  80071d:	66 90                	xchg   %ax,%ax
  80071f:	90                   	nop

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 3c             	sub    $0x3c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d7                	mov    %edx,%edi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80073a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80073d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800740:	85 c0                	test   %eax,%eax
  800742:	75 08                	jne    80074c <printnum+0x2c>
  800744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800747:	39 45 10             	cmp    %eax,0x10(%ebp)
  80074a:	77 59                	ja     8007a5 <printnum+0x85>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80074c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800750:	83 eb 01             	sub    $0x1,%ebx
  800753:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800757:	8b 45 10             	mov    0x10(%ebp),%eax
  80075a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075e:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800762:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800766:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80076d:	00 
  80076e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	e8 60 0d 00 00       	call   8014e0 <__udivdi3>
  800780:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800784:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078f:	89 fa                	mov    %edi,%edx
  800791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800794:	e8 87 ff ff ff       	call   800720 <printnum>
  800799:	eb 11                	jmp    8007ac <printnum+0x8c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80079b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079f:	89 34 24             	mov    %esi,(%esp)
  8007a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007a5:	83 eb 01             	sub    $0x1,%ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f ef                	jg     80079b <printnum+0x7b>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007c2:	00 
  8007c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	e8 3b 0e 00 00       	call   801610 <__umoddi3>
  8007d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d9:	0f be 80 c3 18 80 00 	movsbl 0x8018c3(%eax),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007e6:	83 c4 3c             	add    $0x3c,%esp
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5f                   	pop    %edi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f1:	83 fa 01             	cmp    $0x1,%edx
  8007f4:	7e 0e                	jle    800804 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007f6:	8b 10                	mov    (%eax),%edx
  8007f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007fb:	89 08                	mov    %ecx,(%eax)
  8007fd:	8b 02                	mov    (%edx),%eax
  8007ff:	8b 52 04             	mov    0x4(%edx),%edx
  800802:	eb 22                	jmp    800826 <getuint+0x38>
	else if (lflag)
  800804:	85 d2                	test   %edx,%edx
  800806:	74 10                	je     800818 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80080d:	89 08                	mov    %ecx,(%eax)
  80080f:	8b 02                	mov    (%edx),%eax
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
  800816:	eb 0e                	jmp    800826 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081d:	89 08                	mov    %ecx,(%eax)
  80081f:	8b 02                	mov    (%edx),%eax
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800832:	8b 10                	mov    (%eax),%edx
  800834:	3b 50 04             	cmp    0x4(%eax),%edx
  800837:	73 0a                	jae    800843 <sprintputch+0x1b>
		*b->buf++ = ch;
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	88 0a                	mov    %cl,(%edx)
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	89 10                	mov    %edx,(%eax)
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800852:	8b 45 10             	mov    0x10(%ebp),%eax
  800855:	89 44 24 08          	mov    %eax,0x8(%esp)
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	e8 02 00 00 00       	call   80086d <vprintfmt>
	va_end(ap);
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	83 ec 4c             	sub    $0x4c,%esp
  800876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800879:	8b 75 10             	mov    0x10(%ebp),%esi
  80087c:	eb 12                	jmp    800890 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087e:	85 c0                	test   %eax,%eax
  800880:	0f 84 bf 03 00 00    	je     800c45 <vprintfmt+0x3d8>
				return;
			putch(ch, putdat);
  800886:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088a:	89 04 24             	mov    %eax,(%esp)
  80088d:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800890:	0f b6 06             	movzbl (%esi),%eax
  800893:	83 c6 01             	add    $0x1,%esi
  800896:	83 f8 25             	cmp    $0x25,%eax
  800899:	75 e3                	jne    80087e <vprintfmt+0x11>
  80089b:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80089f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8008a6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008ab:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008ba:	eb 2b                	jmp    8008e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008bf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008c3:	eb 22                	jmp    8008e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008cc:	eb 19                	jmp    8008e7 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8008d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008d8:	eb 0d                	jmp    8008e7 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e0:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e7:	0f b6 16             	movzbl (%esi),%edx
  8008ea:	0f b6 c2             	movzbl %dl,%eax
  8008ed:	8d 7e 01             	lea    0x1(%esi),%edi
  8008f0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008f3:	83 ea 23             	sub    $0x23,%edx
  8008f6:	80 fa 55             	cmp    $0x55,%dl
  8008f9:	0f 87 28 03 00 00    	ja     800c27 <vprintfmt+0x3ba>
  8008ff:	0f b6 d2             	movzbl %dl,%edx
  800902:	ff 24 95 80 19 80 00 	jmp    *0x801980(,%edx,4)
  800909:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80090c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800913:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800918:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80091b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80091f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800922:	8d 50 d0             	lea    -0x30(%eax),%edx
  800925:	83 fa 09             	cmp    $0x9,%edx
  800928:	77 2f                	ja     800959 <vprintfmt+0xec>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80092a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80092d:	eb e9                	jmp    800918 <vprintfmt+0xab>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8d 50 04             	lea    0x4(%eax),%edx
  800935:	89 55 14             	mov    %edx,0x14(%ebp)
  800938:	8b 00                	mov    (%eax),%eax
  80093a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800940:	eb 1a                	jmp    80095c <vprintfmt+0xef>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800942:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800945:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800949:	79 9c                	jns    8008e7 <vprintfmt+0x7a>
  80094b:	eb 81                	jmp    8008ce <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800950:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800957:	eb 8e                	jmp    8008e7 <vprintfmt+0x7a>
  800959:	89 7d d4             	mov    %edi,-0x2c(%ebp)

		process_precision:
			if (width < 0)
  80095c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800960:	79 85                	jns    8008e7 <vprintfmt+0x7a>
  800962:	e9 73 ff ff ff       	jmp    8008da <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800967:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80096d:	e9 75 ff ff ff       	jmp    8008e7 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097f:	8b 00                	mov    (%eax),%eax
  800981:	89 04 24             	mov    %eax,(%esp)
  800984:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800987:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80098a:	e9 01 ff ff ff       	jmp    800890 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	c1 fa 1f             	sar    $0x1f,%edx
  80099f:	31 d0                	xor    %edx,%eax
  8009a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009a3:	83 f8 09             	cmp    $0x9,%eax
  8009a6:	7f 0b                	jg     8009b3 <vprintfmt+0x146>
  8009a8:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  8009af:	85 d2                	test   %edx,%edx
  8009b1:	75 23                	jne    8009d6 <vprintfmt+0x169>
				printfmt(putch, putdat, "error %d", err);
  8009b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b7:	c7 44 24 08 db 18 80 	movl   $0x8018db,0x8(%esp)
  8009be:	00 
  8009bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	89 3c 24             	mov    %edi,(%esp)
  8009c9:	e8 77 fe ff ff       	call   800845 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009d1:	e9 ba fe ff ff       	jmp    800890 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8009d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009da:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  8009e1:	00 
  8009e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e9:	89 3c 24             	mov    %edi,(%esp)
  8009ec:	e8 54 fe ff ff       	call   800845 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009f4:	e9 97 fe ff ff       	jmp    800890 <vprintfmt+0x23>
  8009f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a02:	8b 45 14             	mov    0x14(%ebp),%eax
  800a05:	8d 50 04             	lea    0x4(%eax),%edx
  800a08:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800a0d:	85 f6                	test   %esi,%esi
  800a0f:	ba d4 18 80 00       	mov    $0x8018d4,%edx
  800a14:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  800a17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a1b:	0f 8e 8c 00 00 00    	jle    800aad <vprintfmt+0x240>
  800a21:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a25:	0f 84 82 00 00 00    	je     800aad <vprintfmt+0x240>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a2f:	89 34 24             	mov    %esi,(%esp)
  800a32:	e8 b1 02 00 00       	call   800ce8 <strnlen>
  800a37:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a3a:	29 c2                	sub    %eax,%edx
  800a3c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800a3f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a43:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800a46:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800a49:	89 de                	mov    %ebx,%esi
  800a4b:	89 d3                	mov    %edx,%ebx
  800a4d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4f:	eb 0d                	jmp    800a5e <vprintfmt+0x1f1>
					putch(padc, putdat);
  800a51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a55:	89 3c 24             	mov    %edi,(%esp)
  800a58:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5b:	83 eb 01             	sub    $0x1,%ebx
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	7f ef                	jg     800a51 <vprintfmt+0x1e4>
  800a62:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
  800a77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a7a:	29 c2                	sub    %eax,%edx
  800a7c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7f:	eb 2c                	jmp    800aad <vprintfmt+0x240>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a81:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a85:	74 18                	je     800a9f <vprintfmt+0x232>
  800a87:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a8a:	83 fa 5e             	cmp    $0x5e,%edx
  800a8d:	76 10                	jbe    800a9f <vprintfmt+0x232>
					putch('?', putdat);
  800a8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a93:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a9a:	ff 55 08             	call   *0x8(%ebp)
  800a9d:	eb 0a                	jmp    800aa9 <vprintfmt+0x23c>
				else
					putch(ch, putdat);
  800a9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800aad:	0f be 06             	movsbl (%esi),%eax
  800ab0:	83 c6 01             	add    $0x1,%esi
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	74 25                	je     800adc <vprintfmt+0x26f>
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	78 c6                	js     800a81 <vprintfmt+0x214>
  800abb:	83 ef 01             	sub    $0x1,%edi
  800abe:	79 c1                	jns    800a81 <vprintfmt+0x214>
  800ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac3:	89 de                	mov    %ebx,%esi
  800ac5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ac8:	eb 1a                	jmp    800ae4 <vprintfmt+0x277>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ace:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ad5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad7:	83 eb 01             	sub    $0x1,%ebx
  800ada:	eb 08                	jmp    800ae4 <vprintfmt+0x277>
  800adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adf:	89 de                	mov    %ebx,%esi
  800ae1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	7f e2                	jg     800aca <vprintfmt+0x25d>
  800ae8:	89 7d 08             	mov    %edi,0x8(%ebp)
  800aeb:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aed:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800af0:	e9 9b fd ff ff       	jmp    800890 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af5:	83 f9 01             	cmp    $0x1,%ecx
  800af8:	7e 10                	jle    800b0a <vprintfmt+0x29d>
		return va_arg(*ap, long long);
  800afa:	8b 45 14             	mov    0x14(%ebp),%eax
  800afd:	8d 50 08             	lea    0x8(%eax),%edx
  800b00:	89 55 14             	mov    %edx,0x14(%ebp)
  800b03:	8b 30                	mov    (%eax),%esi
  800b05:	8b 78 04             	mov    0x4(%eax),%edi
  800b08:	eb 26                	jmp    800b30 <vprintfmt+0x2c3>
	else if (lflag)
  800b0a:	85 c9                	test   %ecx,%ecx
  800b0c:	74 12                	je     800b20 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b11:	8d 50 04             	lea    0x4(%eax),%edx
  800b14:	89 55 14             	mov    %edx,0x14(%ebp)
  800b17:	8b 30                	mov    (%eax),%esi
  800b19:	89 f7                	mov    %esi,%edi
  800b1b:	c1 ff 1f             	sar    $0x1f,%edi
  800b1e:	eb 10                	jmp    800b30 <vprintfmt+0x2c3>
	else
		return va_arg(*ap, int);
  800b20:	8b 45 14             	mov    0x14(%ebp),%eax
  800b23:	8d 50 04             	lea    0x4(%eax),%edx
  800b26:	89 55 14             	mov    %edx,0x14(%ebp)
  800b29:	8b 30                	mov    (%eax),%esi
  800b2b:	89 f7                	mov    %esi,%edi
  800b2d:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b30:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b35:	85 ff                	test   %edi,%edi
  800b37:	0f 89 ac 00 00 00    	jns    800be9 <vprintfmt+0x37c>
				putch('-', putdat);
  800b3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b41:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b48:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b4b:	f7 de                	neg    %esi
  800b4d:	83 d7 00             	adc    $0x0,%edi
  800b50:	f7 df                	neg    %edi
			}
			base = 10;
  800b52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b57:	e9 8d 00 00 00       	jmp    800be9 <vprintfmt+0x37c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b5c:	89 ca                	mov    %ecx,%edx
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b61:	e8 88 fc ff ff       	call   8007ee <getuint>
  800b66:	89 c6                	mov    %eax,%esi
  800b68:	89 d7                	mov    %edx,%edi
			base = 10;
  800b6a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b6f:	eb 78                	jmp    800be9 <vprintfmt+0x37c>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b75:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b7c:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b83:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b8a:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b91:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b98:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9b:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b9e:	e9 ed fc ff ff       	jmp    800890 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800ba3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bae:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bbc:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc2:	8d 50 04             	lea    0x4(%eax),%edx
  800bc5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bc8:	8b 30                	mov    (%eax),%esi
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bcf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bd4:	eb 13                	jmp    800be9 <vprintfmt+0x37c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd6:	89 ca                	mov    %ecx,%edx
  800bd8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bdb:	e8 0e fc ff ff       	call   8007ee <getuint>
  800be0:	89 c6                	mov    %eax,%esi
  800be2:	89 d7                	mov    %edx,%edi
			base = 16;
  800be4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be9:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800bed:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bf1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bf4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfc:	89 34 24             	mov    %esi,(%esp)
  800bff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c03:	89 da                	mov    %ebx,%edx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	e8 13 fb ff ff       	call   800720 <printnum>
			break;
  800c0d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c10:	e9 7b fc ff ff       	jmp    800890 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c19:	89 04 24             	mov    %eax,(%esp)
  800c1c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c22:	e9 69 fc ff ff       	jmp    800890 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c2b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c32:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c35:	eb 03                	jmp    800c3a <vprintfmt+0x3cd>
  800c37:	83 ee 01             	sub    $0x1,%esi
  800c3a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c3e:	75 f7                	jne    800c37 <vprintfmt+0x3ca>
  800c40:	e9 4b fc ff ff       	jmp    800890 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800c45:	83 c4 4c             	add    $0x4c,%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 28             	sub    $0x28,%esp
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c60:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	74 30                	je     800c9e <vsnprintf+0x51>
  800c6e:	85 d2                	test   %edx,%edx
  800c70:	7e 2c                	jle    800c9e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c72:	8b 45 14             	mov    0x14(%ebp),%eax
  800c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c79:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c80:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c87:	c7 04 24 28 08 80 00 	movl   $0x800828,(%esp)
  800c8e:	e8 da fb ff ff       	call   80086d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c96:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9c:	eb 05                	jmp    800ca3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 04 24             	mov    %eax,(%esp)
  800cc6:	e8 82 ff ff ff       	call   800c4d <vsnprintf>
	va_end(ap);

	return rc;
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	eb 03                	jmp    800ce0 <strlen+0x10>
		n++;
  800cdd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce4:	75 f7                	jne    800cdd <strlen+0xd>
		n++;
	return n;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	eb 03                	jmp    800cfb <strnlen+0x13>
		n++;
  800cf8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfb:	39 d0                	cmp    %edx,%eax
  800cfd:	74 06                	je     800d05 <strnlen+0x1d>
  800cff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d03:	75 f3                	jne    800cf8 <strnlen+0x10>
		n++;
	return n;
}
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	53                   	push   %ebx
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d1a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d1d:	83 c2 01             	add    $0x1,%edx
  800d20:	84 c9                	test   %cl,%cl
  800d22:	75 f2                	jne    800d16 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d24:	5b                   	pop    %ebx
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 08             	sub    $0x8,%esp
  800d2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d31:	89 1c 24             	mov    %ebx,(%esp)
  800d34:	e8 97 ff ff ff       	call   800cd0 <strlen>
	strcpy(dst + len, src);
  800d39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d40:	01 d8                	add    %ebx,%eax
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	e8 bd ff ff ff       	call   800d07 <strcpy>
	return dst;
}
  800d4a:	89 d8                	mov    %ebx,%eax
  800d4c:	83 c4 08             	add    $0x8,%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d65:	eb 0f                	jmp    800d76 <strncpy+0x24>
		*dst++ = *src;
  800d67:	0f b6 1a             	movzbl (%edx),%ebx
  800d6a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d6d:	80 3a 01             	cmpb   $0x1,(%edx)
  800d70:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d73:	83 c1 01             	add    $0x1,%ecx
  800d76:	39 f1                	cmp    %esi,%ecx
  800d78:	75 ed                	jne    800d67 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	8b 75 08             	mov    0x8(%ebp),%esi
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d8c:	89 f0                	mov    %esi,%eax
  800d8e:	85 d2                	test   %edx,%edx
  800d90:	75 0a                	jne    800d9c <strlcpy+0x1e>
  800d92:	eb 1d                	jmp    800db1 <strlcpy+0x33>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d94:	88 18                	mov    %bl,(%eax)
  800d96:	83 c0 01             	add    $0x1,%eax
  800d99:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d9c:	83 ea 01             	sub    $0x1,%edx
  800d9f:	74 0b                	je     800dac <strlcpy+0x2e>
  800da1:	0f b6 19             	movzbl (%ecx),%ebx
  800da4:	84 db                	test   %bl,%bl
  800da6:	75 ec                	jne    800d94 <strlcpy+0x16>
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	eb 02                	jmp    800dae <strlcpy+0x30>
  800dac:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dae:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800db1:	29 f0                	sub    %esi,%eax
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800dc0:	eb 06                	jmp    800dc8 <strcmp+0x11>
		p++, q++;
  800dc2:	83 c1 01             	add    $0x1,%ecx
  800dc5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc8:	0f b6 01             	movzbl (%ecx),%eax
  800dcb:	84 c0                	test   %al,%al
  800dcd:	74 04                	je     800dd3 <strcmp+0x1c>
  800dcf:	3a 02                	cmp    (%edx),%al
  800dd1:	74 ef                	je     800dc2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd3:	0f b6 c0             	movzbl %al,%eax
  800dd6:	0f b6 12             	movzbl (%edx),%edx
  800dd9:	29 d0                	sub    %edx,%eax
}
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	53                   	push   %ebx
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800dea:	eb 09                	jmp    800df5 <strncmp+0x18>
		n--, p++, q++;
  800dec:	83 ea 01             	sub    $0x1,%edx
  800def:	83 c0 01             	add    $0x1,%eax
  800df2:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df5:	85 d2                	test   %edx,%edx
  800df7:	74 15                	je     800e0e <strncmp+0x31>
  800df9:	0f b6 18             	movzbl (%eax),%ebx
  800dfc:	84 db                	test   %bl,%bl
  800dfe:	74 04                	je     800e04 <strncmp+0x27>
  800e00:	3a 19                	cmp    (%ecx),%bl
  800e02:	74 e8                	je     800dec <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e04:	0f b6 00             	movzbl (%eax),%eax
  800e07:	0f b6 11             	movzbl (%ecx),%edx
  800e0a:	29 d0                	sub    %edx,%eax
  800e0c:	eb 05                	jmp    800e13 <strncmp+0x36>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e20:	eb 07                	jmp    800e29 <strchr+0x13>
		if (*s == c)
  800e22:	38 ca                	cmp    %cl,%dl
  800e24:	74 0f                	je     800e35 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e26:	83 c0 01             	add    $0x1,%eax
  800e29:	0f b6 10             	movzbl (%eax),%edx
  800e2c:	84 d2                	test   %dl,%dl
  800e2e:	75 f2                	jne    800e22 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e41:	eb 07                	jmp    800e4a <strfind+0x13>
		if (*s == c)
  800e43:	38 ca                	cmp    %cl,%dl
  800e45:	74 0a                	je     800e51 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e47:	83 c0 01             	add    $0x1,%eax
  800e4a:	0f b6 10             	movzbl (%eax),%edx
  800e4d:	84 d2                	test   %dl,%dl
  800e4f:	75 f2                	jne    800e43 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e62:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e6b:	85 c9                	test   %ecx,%ecx
  800e6d:	74 30                	je     800e9f <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e75:	75 25                	jne    800e9c <memset+0x49>
  800e77:	f6 c1 03             	test   $0x3,%cl
  800e7a:	75 20                	jne    800e9c <memset+0x49>
		c &= 0xFF;
  800e7c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e7f:	89 d3                	mov    %edx,%ebx
  800e81:	c1 e3 08             	shl    $0x8,%ebx
  800e84:	89 d6                	mov    %edx,%esi
  800e86:	c1 e6 18             	shl    $0x18,%esi
  800e89:	89 d0                	mov    %edx,%eax
  800e8b:	c1 e0 10             	shl    $0x10,%eax
  800e8e:	09 f0                	or     %esi,%eax
  800e90:	09 d0                	or     %edx,%eax
  800e92:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e94:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e97:	fc                   	cld    
  800e98:	f3 ab                	rep stos %eax,%es:(%edi)
  800e9a:	eb 03                	jmp    800e9f <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e9c:	fc                   	cld    
  800e9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e9f:	89 f8                	mov    %edi,%eax
  800ea1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eaa:	89 ec                	mov    %ebp,%esp
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ec0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec3:	39 c6                	cmp    %eax,%esi
  800ec5:	73 36                	jae    800efd <memmove+0x4f>
  800ec7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eca:	39 d0                	cmp    %edx,%eax
  800ecc:	73 2f                	jae    800efd <memmove+0x4f>
		s += n;
		d += n;
  800ece:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed1:	f6 c2 03             	test   $0x3,%dl
  800ed4:	75 1b                	jne    800ef1 <memmove+0x43>
  800ed6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800edc:	75 13                	jne    800ef1 <memmove+0x43>
  800ede:	f6 c1 03             	test   $0x3,%cl
  800ee1:	75 0e                	jne    800ef1 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee3:	83 ef 04             	sub    $0x4,%edi
  800ee6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eec:	fd                   	std    
  800eed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eef:	eb 09                	jmp    800efa <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ef1:	83 ef 01             	sub    $0x1,%edi
  800ef4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef7:	fd                   	std    
  800ef8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800efa:	fc                   	cld    
  800efb:	eb 20                	jmp    800f1d <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f03:	75 13                	jne    800f18 <memmove+0x6a>
  800f05:	a8 03                	test   $0x3,%al
  800f07:	75 0f                	jne    800f18 <memmove+0x6a>
  800f09:	f6 c1 03             	test   $0x3,%cl
  800f0c:	75 0a                	jne    800f18 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f0e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f11:	89 c7                	mov    %eax,%edi
  800f13:	fc                   	cld    
  800f14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f16:	eb 05                	jmp    800f1d <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f18:	89 c7                	mov    %eax,%edi
  800f1a:	fc                   	cld    
  800f1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f1d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f20:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f23:	89 ec                	mov    %ebp,%esp
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	89 04 24             	mov    %eax,(%esp)
  800f41:	e8 68 ff ff ff       	call   800eae <memmove>
}
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f57:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5c:	eb 1a                	jmp    800f78 <memcmp+0x30>
		if (*s1 != *s2)
  800f5e:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800f62:	83 c2 01             	add    $0x1,%edx
  800f65:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800f6a:	38 c8                	cmp    %cl,%al
  800f6c:	74 0a                	je     800f78 <memcmp+0x30>
			return (int) *s1 - (int) *s2;
  800f6e:	0f b6 c0             	movzbl %al,%eax
  800f71:	0f b6 c9             	movzbl %cl,%ecx
  800f74:	29 c8                	sub    %ecx,%eax
  800f76:	eb 09                	jmp    800f81 <memcmp+0x39>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f78:	39 da                	cmp    %ebx,%edx
  800f7a:	75 e2                	jne    800f5e <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f94:	eb 07                	jmp    800f9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f96:	38 08                	cmp    %cl,(%eax)
  800f98:	74 07                	je     800fa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f9a:	83 c0 01             	add    $0x1,%eax
  800f9d:	39 d0                	cmp    %edx,%eax
  800f9f:	72 f5                	jb     800f96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800faf:	eb 03                	jmp    800fb4 <strtol+0x11>
		s++;
  800fb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb4:	0f b6 02             	movzbl (%edx),%eax
  800fb7:	3c 20                	cmp    $0x20,%al
  800fb9:	74 f6                	je     800fb1 <strtol+0xe>
  800fbb:	3c 09                	cmp    $0x9,%al
  800fbd:	74 f2                	je     800fb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fbf:	3c 2b                	cmp    $0x2b,%al
  800fc1:	75 0a                	jne    800fcd <strtol+0x2a>
		s++;
  800fc3:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcb:	eb 10                	jmp    800fdd <strtol+0x3a>
  800fcd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fd2:	3c 2d                	cmp    $0x2d,%al
  800fd4:	75 07                	jne    800fdd <strtol+0x3a>
		s++, neg = 1;
  800fd6:	8d 52 01             	lea    0x1(%edx),%edx
  800fd9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fdd:	85 db                	test   %ebx,%ebx
  800fdf:	0f 94 c0             	sete   %al
  800fe2:	74 05                	je     800fe9 <strtol+0x46>
  800fe4:	83 fb 10             	cmp    $0x10,%ebx
  800fe7:	75 15                	jne    800ffe <strtol+0x5b>
  800fe9:	80 3a 30             	cmpb   $0x30,(%edx)
  800fec:	75 10                	jne    800ffe <strtol+0x5b>
  800fee:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ff2:	75 0a                	jne    800ffe <strtol+0x5b>
		s += 2, base = 16;
  800ff4:	83 c2 02             	add    $0x2,%edx
  800ff7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ffc:	eb 13                	jmp    801011 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ffe:	84 c0                	test   %al,%al
  801000:	74 0f                	je     801011 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801002:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801007:	80 3a 30             	cmpb   $0x30,(%edx)
  80100a:	75 05                	jne    801011 <strtol+0x6e>
		s++, base = 8;
  80100c:	83 c2 01             	add    $0x1,%edx
  80100f:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  801011:	b8 00 00 00 00       	mov    $0x0,%eax
  801016:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801018:	0f b6 0a             	movzbl (%edx),%ecx
  80101b:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80101e:	80 fb 09             	cmp    $0x9,%bl
  801021:	77 08                	ja     80102b <strtol+0x88>
			dig = *s - '0';
  801023:	0f be c9             	movsbl %cl,%ecx
  801026:	83 e9 30             	sub    $0x30,%ecx
  801029:	eb 1e                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  80102b:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80102e:	80 fb 19             	cmp    $0x19,%bl
  801031:	77 08                	ja     80103b <strtol+0x98>
			dig = *s - 'a' + 10;
  801033:	0f be c9             	movsbl %cl,%ecx
  801036:	83 e9 57             	sub    $0x57,%ecx
  801039:	eb 0e                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80103b:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80103e:	80 fb 19             	cmp    $0x19,%bl
  801041:	77 14                	ja     801057 <strtol+0xb4>
			dig = *s - 'A' + 10;
  801043:	0f be c9             	movsbl %cl,%ecx
  801046:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801049:	39 f1                	cmp    %esi,%ecx
  80104b:	7d 0e                	jge    80105b <strtol+0xb8>
			break;
		s++, val = (val * base) + dig;
  80104d:	83 c2 01             	add    $0x1,%edx
  801050:	0f af c6             	imul   %esi,%eax
  801053:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801055:	eb c1                	jmp    801018 <strtol+0x75>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801057:	89 c1                	mov    %eax,%ecx
  801059:	eb 02                	jmp    80105d <strtol+0xba>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80105b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80105d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801061:	74 05                	je     801068 <strtol+0xc5>
		*endptr = (char *) s;
  801063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801066:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801068:	89 ca                	mov    %ecx,%edx
  80106a:	f7 da                	neg    %edx
  80106c:	85 ff                	test   %edi,%edi
  80106e:	0f 45 c2             	cmovne %edx,%eax
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
  801076:	66 90                	xchg   %ax,%ax

00801078 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801081:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801084:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801087:	b8 00 00 00 00       	mov    $0x0,%eax
  80108c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108f:	8b 55 08             	mov    0x8(%ebp),%edx
  801092:	89 c3                	mov    %eax,%ebx
  801094:	89 c7                	mov    %eax,%edi
  801096:	89 c6                	mov    %eax,%esi
  801098:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80109a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80109d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010a3:	89 ec                	mov    %ebp,%esp
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c0:	89 d1                	mov    %edx,%ecx
  8010c2:	89 d3                	mov    %edx,%ebx
  8010c4:	89 d7                	mov    %edx,%edi
  8010c6:	89 d6                	mov    %edx,%esi
  8010c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010d3:	89 ec                	mov    %ebp,%esp
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 38             	sub    $0x38,%esp
  8010dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f3:	89 cb                	mov    %ecx,%ebx
  8010f5:	89 cf                	mov    %ecx,%edi
  8010f7:	89 ce                	mov    %ecx,%esi
  8010f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	7e 28                	jle    801127 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801103:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80110a:	00 
  80110b:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801122:	e8 d5 f4 ff ff       	call   8005fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801127:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80112a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80112d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801130:	89 ec                	mov    %ebp,%esp
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80113d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801140:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801143:	ba 00 00 00 00       	mov    $0x0,%edx
  801148:	b8 02 00 00 00       	mov    $0x2,%eax
  80114d:	89 d1                	mov    %edx,%ecx
  80114f:	89 d3                	mov    %edx,%ebx
  801151:	89 d7                	mov    %edx,%edi
  801153:	89 d6                	mov    %edx,%esi
  801155:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80115a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80115d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801160:	89 ec                	mov    %ebp,%esp
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sys_yield>:

void
sys_yield(void)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80116d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801170:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801173:	ba 00 00 00 00       	mov    $0x0,%edx
  801178:	b8 0a 00 00 00       	mov    $0xa,%eax
  80117d:	89 d1                	mov    %edx,%ecx
  80117f:	89 d3                	mov    %edx,%ebx
  801181:	89 d7                	mov    %edx,%edi
  801183:	89 d6                	mov    %edx,%esi
  801185:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801187:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80118a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80118d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801190:	89 ec                	mov    %ebp,%esp
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 38             	sub    $0x38,%esp
  80119a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80119d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a3:	be 00 00 00 00       	mov    $0x0,%esi
  8011a8:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 f7                	mov    %esi,%edi
  8011b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	7e 28                	jle    8011e6 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8011e1:	e8 16 f4 ff ff       	call   8005fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ef:	89 ec                	mov    %ebp,%esp
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 38             	sub    $0x38,%esp
  8011f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801202:	b8 05 00 00 00       	mov    $0x5,%eax
  801207:	8b 75 18             	mov    0x18(%ebp),%esi
  80120a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80120d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801213:	8b 55 08             	mov    0x8(%ebp),%edx
  801216:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801218:	85 c0                	test   %eax,%eax
  80121a:	7e 28                	jle    801244 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801220:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801227:	00 
  801228:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80122f:	00 
  801230:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801237:	00 
  801238:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80123f:	e8 b8 f3 ff ff       	call   8005fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801244:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801247:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80124a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80124d:	89 ec                	mov    %ebp,%esp
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 38             	sub    $0x38,%esp
  801257:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80125a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80125d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801260:	bb 00 00 00 00       	mov    $0x0,%ebx
  801265:	b8 06 00 00 00       	mov    $0x6,%eax
  80126a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126d:	8b 55 08             	mov    0x8(%ebp),%edx
  801270:	89 df                	mov    %ebx,%edi
  801272:	89 de                	mov    %ebx,%esi
  801274:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801276:	85 c0                	test   %eax,%eax
  801278:	7e 28                	jle    8012a2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80127a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80127e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801285:	00 
  801286:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  80128d:	00 
  80128e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801295:	00 
  801296:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80129d:	e8 5a f3 ff ff       	call   8005fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012a2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012a8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012ab:	89 ec                	mov    %ebp,%esp
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 38             	sub    $0x38,%esp
  8012b5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012b8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012bb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ce:	89 df                	mov    %ebx,%edi
  8012d0:	89 de                	mov    %ebx,%esi
  8012d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	7e 28                	jle    801300 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012dc:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012e3:	00 
  8012e4:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8012eb:	00 
  8012ec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012f3:	00 
  8012f4:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8012fb:	e8 fc f2 ff ff       	call   8005fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801300:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801303:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801306:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801309:	89 ec                	mov    %ebp,%esp
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 38             	sub    $0x38,%esp
  801313:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801316:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801319:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80131c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801321:	b8 09 00 00 00       	mov    $0x9,%eax
  801326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801329:	8b 55 08             	mov    0x8(%ebp),%edx
  80132c:	89 df                	mov    %ebx,%edi
  80132e:	89 de                	mov    %ebx,%esi
  801330:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801332:	85 c0                	test   %eax,%eax
  801334:	7e 28                	jle    80135e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801336:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801341:	00 
  801342:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  801349:	00 
  80134a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801351:	00 
  801352:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  801359:	e8 9e f2 ff ff       	call   8005fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80135e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801361:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801364:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801367:	89 ec                	mov    %ebp,%esp
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801374:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801377:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137a:	be 00 00 00 00       	mov    $0x0,%esi
  80137f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801384:	8b 7d 14             	mov    0x14(%ebp),%edi
  801387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138d:	8b 55 08             	mov    0x8(%ebp),%edx
  801390:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801392:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801395:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801398:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139b:	89 ec                	mov    %ebp,%esp
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 38             	sub    $0x38,%esp
  8013a5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013a8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013ab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bb:	89 cb                	mov    %ecx,%ebx
  8013bd:	89 cf                	mov    %ecx,%edi
  8013bf:	89 ce                	mov    %ecx,%esi
  8013c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	7e 28                	jle    8013ef <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013cb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8013d2:	00 
  8013d3:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8013ea:	e8 0d f2 ff ff       	call   8005fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013f8:	89 ec                	mov    %ebp,%esp
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801402:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801409:	75 44                	jne    80144f <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  80140b:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801410:	8b 40 48             	mov    0x48(%eax),%eax
  801413:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80141a:	00 
  80141b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801422:	ee 
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 69 fd ff ff       	call   801194 <sys_page_alloc>
		if( r < 0)
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 20                	jns    80144f <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  80142f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801433:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  80143a:	00 
  80143b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801442:	00 
  801443:	c7 04 24 90 1b 80 00 	movl   $0x801b90,(%esp)
  80144a:	e8 ad f1 ff ff       	call   8005fc <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	a3 d0 20 80 00       	mov    %eax,0x8020d0
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  801457:	e8 d8 fc ff ff       	call   801134 <sys_getenvid>
  80145c:	c7 44 24 04 94 14 80 	movl   $0x801494,0x4(%esp)
  801463:	00 
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 a1 fe ff ff       	call   80130d <sys_env_set_pgfault_upcall>
  80146c:	85 c0                	test   %eax,%eax
  80146e:	79 20                	jns    801490 <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  801470:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801474:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  80147b:	00 
  80147c:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801483:	00 
  801484:	c7 04 24 90 1b 80 00 	movl   $0x801b90,(%esp)
  80148b:	e8 6c f1 ff ff       	call   8005fc <_panic>


}
  801490:	c9                   	leave  
  801491:	c3                   	ret    
  801492:	66 90                	xchg   %ax,%ax

00801494 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801494:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801495:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80149a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80149c:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  80149f:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  8014a3:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  8014a7:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  8014ab:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  8014ae:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  8014b1:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  8014b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  8014b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  8014bc:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  8014c0:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  8014c4:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  8014c8:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
		leal 0x2c(%esp), %esp
  8014cc:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  8014d0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
		leave
  8014d1:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8014d2:	c3                   	ret    
  8014d3:	66 90                	xchg   %ax,%ax
  8014d5:	66 90                	xchg   %ax,%ax
  8014d7:	66 90                	xchg   %ax,%ax
  8014d9:	66 90                	xchg   %ax,%ax
  8014db:	66 90                	xchg   %ax,%ax
  8014dd:	66 90                	xchg   %ax,%ax
  8014df:	90                   	nop

008014e0 <__udivdi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8014ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8014f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014fc:	89 ea                	mov    %ebp,%edx
  8014fe:	89 0c 24             	mov    %ecx,(%esp)
  801501:	75 2d                	jne    801530 <__udivdi3+0x50>
  801503:	39 e9                	cmp    %ebp,%ecx
  801505:	77 61                	ja     801568 <__udivdi3+0x88>
  801507:	85 c9                	test   %ecx,%ecx
  801509:	89 ce                	mov    %ecx,%esi
  80150b:	75 0b                	jne    801518 <__udivdi3+0x38>
  80150d:	b8 01 00 00 00       	mov    $0x1,%eax
  801512:	31 d2                	xor    %edx,%edx
  801514:	f7 f1                	div    %ecx
  801516:	89 c6                	mov    %eax,%esi
  801518:	31 d2                	xor    %edx,%edx
  80151a:	89 e8                	mov    %ebp,%eax
  80151c:	f7 f6                	div    %esi
  80151e:	89 c5                	mov    %eax,%ebp
  801520:	89 f8                	mov    %edi,%eax
  801522:	f7 f6                	div    %esi
  801524:	89 ea                	mov    %ebp,%edx
  801526:	83 c4 0c             	add    $0xc,%esp
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    
  80152d:	8d 76 00             	lea    0x0(%esi),%esi
  801530:	39 e8                	cmp    %ebp,%eax
  801532:	77 24                	ja     801558 <__udivdi3+0x78>
  801534:	0f bd e8             	bsr    %eax,%ebp
  801537:	83 f5 1f             	xor    $0x1f,%ebp
  80153a:	75 3c                	jne    801578 <__udivdi3+0x98>
  80153c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801540:	39 34 24             	cmp    %esi,(%esp)
  801543:	0f 86 9f 00 00 00    	jbe    8015e8 <__udivdi3+0x108>
  801549:	39 d0                	cmp    %edx,%eax
  80154b:	0f 82 97 00 00 00    	jb     8015e8 <__udivdi3+0x108>
  801551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801558:	31 d2                	xor    %edx,%edx
  80155a:	31 c0                	xor    %eax,%eax
  80155c:	83 c4 0c             	add    $0xc,%esp
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
  801563:	90                   	nop
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	89 f8                	mov    %edi,%eax
  80156a:	f7 f1                	div    %ecx
  80156c:	31 d2                	xor    %edx,%edx
  80156e:	83 c4 0c             	add    $0xc,%esp
  801571:	5e                   	pop    %esi
  801572:	5f                   	pop    %edi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    
  801575:	8d 76 00             	lea    0x0(%esi),%esi
  801578:	89 e9                	mov    %ebp,%ecx
  80157a:	8b 3c 24             	mov    (%esp),%edi
  80157d:	d3 e0                	shl    %cl,%eax
  80157f:	89 c6                	mov    %eax,%esi
  801581:	b8 20 00 00 00       	mov    $0x20,%eax
  801586:	29 e8                	sub    %ebp,%eax
  801588:	89 c1                	mov    %eax,%ecx
  80158a:	d3 ef                	shr    %cl,%edi
  80158c:	89 e9                	mov    %ebp,%ecx
  80158e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801592:	8b 3c 24             	mov    (%esp),%edi
  801595:	09 74 24 08          	or     %esi,0x8(%esp)
  801599:	89 d6                	mov    %edx,%esi
  80159b:	d3 e7                	shl    %cl,%edi
  80159d:	89 c1                	mov    %eax,%ecx
  80159f:	89 3c 24             	mov    %edi,(%esp)
  8015a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a6:	d3 ee                	shr    %cl,%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	d3 e2                	shl    %cl,%edx
  8015ac:	89 c1                	mov    %eax,%ecx
  8015ae:	d3 ef                	shr    %cl,%edi
  8015b0:	09 d7                	or     %edx,%edi
  8015b2:	89 f2                	mov    %esi,%edx
  8015b4:	89 f8                	mov    %edi,%eax
  8015b6:	f7 74 24 08          	divl   0x8(%esp)
  8015ba:	89 d6                	mov    %edx,%esi
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	f7 24 24             	mull   (%esp)
  8015c1:	39 d6                	cmp    %edx,%esi
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	72 30                	jb     8015f8 <__udivdi3+0x118>
  8015c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015cc:	89 e9                	mov    %ebp,%ecx
  8015ce:	d3 e2                	shl    %cl,%edx
  8015d0:	39 c2                	cmp    %eax,%edx
  8015d2:	73 05                	jae    8015d9 <__udivdi3+0xf9>
  8015d4:	3b 34 24             	cmp    (%esp),%esi
  8015d7:	74 1f                	je     8015f8 <__udivdi3+0x118>
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	e9 7a ff ff ff       	jmp    80155c <__udivdi3+0x7c>
  8015e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015e8:	31 d2                	xor    %edx,%edx
  8015ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ef:	e9 68 ff ff ff       	jmp    80155c <__udivdi3+0x7c>
  8015f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015fb:	31 d2                	xor    %edx,%edx
  8015fd:	83 c4 0c             	add    $0xc,%esp
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    
  801604:	66 90                	xchg   %ax,%ax
  801606:	66 90                	xchg   %ax,%ax
  801608:	66 90                	xchg   %ax,%ax
  80160a:	66 90                	xchg   %ax,%ax
  80160c:	66 90                	xchg   %ax,%ax
  80160e:	66 90                	xchg   %ax,%ax

00801610 <__umoddi3>:
  801610:	55                   	push   %ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	83 ec 14             	sub    $0x14,%esp
  801616:	8b 44 24 28          	mov    0x28(%esp),%eax
  80161a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80161e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801622:	89 c7                	mov    %eax,%edi
  801624:	89 44 24 04          	mov    %eax,0x4(%esp)
  801628:	8b 44 24 30          	mov    0x30(%esp),%eax
  80162c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801630:	89 34 24             	mov    %esi,(%esp)
  801633:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801637:	85 c0                	test   %eax,%eax
  801639:	89 c2                	mov    %eax,%edx
  80163b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80163f:	75 17                	jne    801658 <__umoddi3+0x48>
  801641:	39 fe                	cmp    %edi,%esi
  801643:	76 4b                	jbe    801690 <__umoddi3+0x80>
  801645:	89 c8                	mov    %ecx,%eax
  801647:	89 fa                	mov    %edi,%edx
  801649:	f7 f6                	div    %esi
  80164b:	89 d0                	mov    %edx,%eax
  80164d:	31 d2                	xor    %edx,%edx
  80164f:	83 c4 14             	add    $0x14,%esp
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    
  801656:	66 90                	xchg   %ax,%ax
  801658:	39 f8                	cmp    %edi,%eax
  80165a:	77 54                	ja     8016b0 <__umoddi3+0xa0>
  80165c:	0f bd e8             	bsr    %eax,%ebp
  80165f:	83 f5 1f             	xor    $0x1f,%ebp
  801662:	75 5c                	jne    8016c0 <__umoddi3+0xb0>
  801664:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801668:	39 3c 24             	cmp    %edi,(%esp)
  80166b:	0f 87 e7 00 00 00    	ja     801758 <__umoddi3+0x148>
  801671:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801675:	29 f1                	sub    %esi,%ecx
  801677:	19 c7                	sbb    %eax,%edi
  801679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80167d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801681:	8b 44 24 08          	mov    0x8(%esp),%eax
  801685:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801689:	83 c4 14             	add    $0x14,%esp
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    
  801690:	85 f6                	test   %esi,%esi
  801692:	89 f5                	mov    %esi,%ebp
  801694:	75 0b                	jne    8016a1 <__umoddi3+0x91>
  801696:	b8 01 00 00 00       	mov    $0x1,%eax
  80169b:	31 d2                	xor    %edx,%edx
  80169d:	f7 f6                	div    %esi
  80169f:	89 c5                	mov    %eax,%ebp
  8016a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016a5:	31 d2                	xor    %edx,%edx
  8016a7:	f7 f5                	div    %ebp
  8016a9:	89 c8                	mov    %ecx,%eax
  8016ab:	f7 f5                	div    %ebp
  8016ad:	eb 9c                	jmp    80164b <__umoddi3+0x3b>
  8016af:	90                   	nop
  8016b0:	89 c8                	mov    %ecx,%eax
  8016b2:	89 fa                	mov    %edi,%edx
  8016b4:	83 c4 14             	add    $0x14,%esp
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
  8016bb:	90                   	nop
  8016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	8b 04 24             	mov    (%esp),%eax
  8016c3:	be 20 00 00 00       	mov    $0x20,%esi
  8016c8:	89 e9                	mov    %ebp,%ecx
  8016ca:	29 ee                	sub    %ebp,%esi
  8016cc:	d3 e2                	shl    %cl,%edx
  8016ce:	89 f1                	mov    %esi,%ecx
  8016d0:	d3 e8                	shr    %cl,%eax
  8016d2:	89 e9                	mov    %ebp,%ecx
  8016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d8:	8b 04 24             	mov    (%esp),%eax
  8016db:	09 54 24 04          	or     %edx,0x4(%esp)
  8016df:	89 fa                	mov    %edi,%edx
  8016e1:	d3 e0                	shl    %cl,%eax
  8016e3:	89 f1                	mov    %esi,%ecx
  8016e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016ed:	d3 ea                	shr    %cl,%edx
  8016ef:	89 e9                	mov    %ebp,%ecx
  8016f1:	d3 e7                	shl    %cl,%edi
  8016f3:	89 f1                	mov    %esi,%ecx
  8016f5:	d3 e8                	shr    %cl,%eax
  8016f7:	89 e9                	mov    %ebp,%ecx
  8016f9:	09 f8                	or     %edi,%eax
  8016fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8016ff:	f7 74 24 04          	divl   0x4(%esp)
  801703:	d3 e7                	shl    %cl,%edi
  801705:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801709:	89 d7                	mov    %edx,%edi
  80170b:	f7 64 24 08          	mull   0x8(%esp)
  80170f:	39 d7                	cmp    %edx,%edi
  801711:	89 c1                	mov    %eax,%ecx
  801713:	89 14 24             	mov    %edx,(%esp)
  801716:	72 2c                	jb     801744 <__umoddi3+0x134>
  801718:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80171c:	72 22                	jb     801740 <__umoddi3+0x130>
  80171e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801722:	29 c8                	sub    %ecx,%eax
  801724:	19 d7                	sbb    %edx,%edi
  801726:	89 e9                	mov    %ebp,%ecx
  801728:	89 fa                	mov    %edi,%edx
  80172a:	d3 e8                	shr    %cl,%eax
  80172c:	89 f1                	mov    %esi,%ecx
  80172e:	d3 e2                	shl    %cl,%edx
  801730:	89 e9                	mov    %ebp,%ecx
  801732:	d3 ef                	shr    %cl,%edi
  801734:	09 d0                	or     %edx,%eax
  801736:	89 fa                	mov    %edi,%edx
  801738:	83 c4 14             	add    $0x14,%esp
  80173b:	5e                   	pop    %esi
  80173c:	5f                   	pop    %edi
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    
  80173f:	90                   	nop
  801740:	39 d7                	cmp    %edx,%edi
  801742:	75 da                	jne    80171e <__umoddi3+0x10e>
  801744:	8b 14 24             	mov    (%esp),%edx
  801747:	89 c1                	mov    %eax,%ecx
  801749:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80174d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801751:	eb cb                	jmp    80171e <__umoddi3+0x10e>
  801753:	90                   	nop
  801754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801758:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80175c:	0f 82 0f ff ff ff    	jb     801671 <__umoddi3+0x61>
  801762:	e9 1a ff ff ff       	jmp    801681 <__umoddi3+0x71>
