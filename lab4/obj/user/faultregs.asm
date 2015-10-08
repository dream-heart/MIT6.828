
obj/user/faultregs:     file format elf32-i386


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
	...

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
  80004c:	c7 44 24 04 b1 16 80 	movl   $0x8016b1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 80 16 80 00 	movl   $0x801680,(%esp)
  80005b:	e8 94 06 00 00       	call   8006f4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 90 16 80 	movl   $0x801690,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  80007b:	e8 74 06 00 00       	call   8006f4 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  80008d:	e8 62 06 00 00       	call   8006f4 <cprintf>

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
  800099:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8000a0:	e8 4f 06 00 00       	call   8006f4 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 b2 16 80 	movl   $0x8016b2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8000c7:	e8 28 06 00 00       	call   8006f4 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8000db:	e8 14 06 00 00       	call   8006f4 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8000e9:	e8 06 06 00 00       	call   8006f4 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 b6 16 80 	movl   $0x8016b6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  800110:	e8 df 05 00 00       	call   8006f4 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  800124:	e8 cb 05 00 00       	call   8006f4 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  800132:	e8 bd 05 00 00       	call   8006f4 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 ba 16 80 	movl   $0x8016ba,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  800159:	e8 96 05 00 00       	call   8006f4 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  80016d:	e8 82 05 00 00       	call   8006f4 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80017b:	e8 74 05 00 00       	call   8006f4 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 be 16 80 	movl   $0x8016be,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8001a2:	e8 4d 05 00 00       	call   8006f4 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8001b6:	e8 39 05 00 00       	call   8006f4 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8001c4:	e8 2b 05 00 00       	call   8006f4 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 c2 16 80 	movl   $0x8016c2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8001eb:	e8 04 05 00 00       	call   8006f4 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8001ff:	e8 f0 04 00 00       	call   8006f4 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80020d:	e8 e2 04 00 00       	call   8006f4 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 c6 16 80 	movl   $0x8016c6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  800234:	e8 bb 04 00 00       	call   8006f4 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  800248:	e8 a7 04 00 00       	call   8006f4 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  800256:	e8 99 04 00 00       	call   8006f4 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 ca 16 80 	movl   $0x8016ca,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  80027d:	e8 72 04 00 00       	call   8006f4 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  800291:	e8 5e 04 00 00       	call   8006f4 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  80029f:	e8 50 04 00 00       	call   8006f4 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ce 16 80 	movl   $0x8016ce,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8002c6:	e8 29 04 00 00       	call   8006f4 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8002da:	e8 15 04 00 00       	call   8006f4 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  8002e8:	e8 07 04 00 00       	call   8006f4 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 d5 16 80 	movl   $0x8016d5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  80030f:	e8 e0 03 00 00       	call   8006f4 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  800323:	e8 cc 03 00 00       	call   8006f4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 d9 16 80 00 	movl   $0x8016d9,(%esp)
  800336:	e8 b9 03 00 00       	call   8006f4 <cprintf>
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
  800341:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  800348:	e8 a7 03 00 00       	call   8006f4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 d9 16 80 00 	movl   $0x8016d9,(%esp)
  80035b:	e8 94 03 00 00       	call   8006f4 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  800369:	e8 86 03 00 00       	call   8006f4 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 a8 16 80 00 	movl   $0x8016a8,(%esp)
  800377:	e8 78 03 00 00       	call   8006f4 <cprintf>
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
  8003a2:	c7 44 24 08 40 17 80 	movl   $0x801740,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 e7 16 80 00 	movl   $0x8016e7,(%esp)
  8003b9:	e8 3d 02 00 00       	call   8005fb <_panic>
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
  800420:	c7 44 24 04 ff 16 80 	movl   $0x8016ff,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 0d 17 80 00 	movl   $0x80170d,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 24 0d 00 00       	call   801183 <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 14 17 80 	movl   $0x801714,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 e7 16 80 00 	movl   $0x8016e7,(%esp)
  80047e:	e8 78 01 00 00       	call   8005fb <_panic>
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
  800492:	e8 01 0f 00 00       	call   801398 <set_pgfault_handler>

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
  80055b:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  800562:	e8 8d 01 00 00       	call   8006f4 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 27 17 80 	movl   $0x801727,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 38 17 80 00 	movl   $0x801738,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
	...

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
  8005aa:	e8 96 0b 00 00       	call   801145 <sys_getenvid>
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
  8005d8:	e8 0a 00 00 00       	call   8005e7 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f4:	e8 fa 0a 00 00       	call   8010f3 <sys_env_destroy>
}
  8005f9:	c9                   	leave  
  8005fa:	c3                   	ret    

008005fb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	56                   	push   %esi
  8005ff:	53                   	push   %ebx
  800600:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800603:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800606:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80060c:	e8 34 0b 00 00       	call   801145 <sys_getenvid>
  800611:	8b 55 0c             	mov    0xc(%ebp),%edx
  800614:	89 54 24 10          	mov    %edx,0x10(%esp)
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	89 74 24 08          	mov    %esi,0x8(%esp)
  800623:	89 44 24 04          	mov    %eax,0x4(%esp)
  800627:	c7 04 24 a0 17 80 00 	movl   $0x8017a0,(%esp)
  80062e:	e8 c1 00 00 00       	call   8006f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800637:	8b 45 10             	mov    0x10(%ebp),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	e8 51 00 00 00       	call   800693 <vcprintf>
	cprintf("\n");
  800642:	c7 04 24 b0 16 80 00 	movl   $0x8016b0,(%esp)
  800649:	e8 a6 00 00 00       	call   8006f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064e:	cc                   	int3   
  80064f:	eb fd                	jmp    80064e <_panic+0x53>

00800651 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800651:	55                   	push   %ebp
  800652:	89 e5                	mov    %esp,%ebp
  800654:	53                   	push   %ebx
  800655:	83 ec 14             	sub    $0x14,%esp
  800658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065b:	8b 13                	mov    (%ebx),%edx
  80065d:	8d 42 01             	lea    0x1(%edx),%eax
  800660:	89 03                	mov    %eax,(%ebx)
  800662:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800665:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800669:	3d ff 00 00 00       	cmp    $0xff,%eax
  80066e:	75 19                	jne    800689 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800670:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800677:	00 
  800678:	8d 43 08             	lea    0x8(%ebx),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 33 0a 00 00       	call   8010b6 <sys_cputs>
		b->idx = 0;
  800683:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800689:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80068d:	83 c4 14             	add    $0x14,%esp
  800690:	5b                   	pop    %ebx
  800691:	5d                   	pop    %ebp
  800692:	c3                   	ret    

00800693 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a3:	00 00 00 
	b.cnt = 0;
  8006a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c8:	c7 04 24 51 06 80 00 	movl   $0x800651,(%esp)
  8006cf:	e8 70 01 00 00       	call   800844 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 ca 09 00 00       	call   8010b6 <sys_cputs>

	return b.cnt;
}
  8006ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 87 ff ff ff       	call   800693 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    
	...

00800710 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 3c             	sub    $0x3c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d7                	mov    %edx,%edi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 c3                	mov    %eax,%ebx
  800729:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072c:	8b 45 10             	mov    0x10(%ebp),%eax
  80072f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80073d:	39 d9                	cmp    %ebx,%ecx
  80073f:	72 05                	jb     800746 <printnum+0x36>
  800741:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800744:	77 69                	ja     8007af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800746:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800749:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80074d:	83 ee 01             	sub    $0x1,%esi
  800750:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8b 44 24 08          	mov    0x8(%esp),%eax
  80075c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800760:	89 c3                	mov    %eax,%ebx
  800762:	89 d6                	mov    %edx,%esi
  800764:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800767:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80076e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80077b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077f:	e8 4c 0c 00 00       	call   8013d0 <__udivdi3>
  800784:	89 d9                	mov    %ebx,%ecx
  800786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	89 54 24 04          	mov    %edx,0x4(%esp)
  800795:	89 fa                	mov    %edi,%edx
  800797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079a:	e8 71 ff ff ff       	call   800710 <printnum>
  80079f:	eb 1b                	jmp    8007bc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff d3                	call   *%ebx
  8007ad:	eb 03                	jmp    8007b2 <printnum+0xa2>
  8007af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007b2:	83 ee 01             	sub    $0x1,%esi
  8007b5:	85 f6                	test   %esi,%esi
  8007b7:	7f e8                	jg     8007a1 <printnum+0x91>
  8007b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	e8 1c 0d 00 00       	call   801500 <__umoddi3>
  8007e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e8:	0f be 80 c3 17 80 00 	movsbl 0x8017c3(%eax),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f5:	ff d0                	call   *%eax
}
  8007f7:	83 c4 3c             	add    $0x3c,%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800805:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	3b 50 04             	cmp    0x4(%eax),%edx
  80080e:	73 0a                	jae    80081a <sprintputch+0x1b>
		*b->buf++ = ch;
  800810:	8d 4a 01             	lea    0x1(%edx),%ecx
  800813:	89 08                	mov    %ecx,(%eax)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	88 02                	mov    %al,(%edx)
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800822:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800825:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800829:	8b 45 10             	mov    0x10(%ebp),%eax
  80082c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800830:	8b 45 0c             	mov    0xc(%ebp),%eax
  800833:	89 44 24 04          	mov    %eax,0x4(%esp)
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	e8 02 00 00 00       	call   800844 <vprintfmt>
	va_end(ap);
}
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	57                   	push   %edi
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	83 ec 3c             	sub    $0x3c,%esp
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800853:	8b 7d 10             	mov    0x10(%ebp),%edi
  800856:	eb 11                	jmp    800869 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800858:	85 c0                	test   %eax,%eax
  80085a:	0f 84 48 04 00 00    	je     800ca8 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800869:	83 c7 01             	add    $0x1,%edi
  80086c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800870:	83 f8 25             	cmp    $0x25,%eax
  800873:	75 e3                	jne    800858 <vprintfmt+0x14>
  800875:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800879:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800880:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800887:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80088e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800893:	eb 1f                	jmp    8008b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800898:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80089c:	eb 16                	jmp    8008b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008a5:	eb 0d                	jmp    8008b4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8d 47 01             	lea    0x1(%edi),%eax
  8008b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ba:	0f b6 17             	movzbl (%edi),%edx
  8008bd:	0f b6 c2             	movzbl %dl,%eax
  8008c0:	83 ea 23             	sub    $0x23,%edx
  8008c3:	80 fa 55             	cmp    $0x55,%dl
  8008c6:	0f 87 bf 03 00 00    	ja     800c8b <vprintfmt+0x447>
  8008cc:	0f b6 d2             	movzbl %dl,%edx
  8008cf:	ff 24 95 80 18 80 00 	jmp    *0x801880(,%edx,4)
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008e1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008e4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008e8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8008eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008ee:	83 f9 09             	cmp    $0x9,%ecx
  8008f1:	77 3c                	ja     80092f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008f6:	eb e9                	jmp    8008e1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8d 40 04             	lea    0x4(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80090c:	eb 27                	jmp    800935 <vprintfmt+0xf1>
  80090e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800911:	85 d2                	test   %edx,%edx
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	0f 49 c2             	cmovns %edx,%eax
  80091b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800921:	eb 91                	jmp    8008b4 <vprintfmt+0x70>
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800926:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80092d:	eb 85                	jmp    8008b4 <vprintfmt+0x70>
  80092f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800932:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800935:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800939:	0f 89 75 ff ff ff    	jns    8008b4 <vprintfmt+0x70>
  80093f:	e9 63 ff ff ff       	jmp    8008a7 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800944:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800947:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80094a:	e9 65 ff ff ff       	jmp    8008b4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800952:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800956:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095a:	8b 00                	mov    (%eax),%eax
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800961:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800964:	e9 00 ff ff ff       	jmp    800869 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80096c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800970:	8b 00                	mov    (%eax),%eax
  800972:	99                   	cltd   
  800973:	31 d0                	xor    %edx,%eax
  800975:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800977:	83 f8 09             	cmp    $0x9,%eax
  80097a:	7f 0b                	jg     800987 <vprintfmt+0x143>
  80097c:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800983:	85 d2                	test   %edx,%edx
  800985:	75 20                	jne    8009a7 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800987:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098b:	c7 44 24 08 db 17 80 	movl   $0x8017db,0x8(%esp)
  800992:	00 
  800993:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 7d fe ff ff       	call   80081c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009a2:	e9 c2 fe ff ff       	jmp    800869 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8009a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ab:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  8009b2:	00 
  8009b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b7:	89 34 24             	mov    %esi,(%esp)
  8009ba:	e8 5d fe ff ff       	call   80081c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009c2:	e9 a2 fe ff ff       	jmp    800869 <vprintfmt+0x25>
  8009c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8009d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009d9:	85 ff                	test   %edi,%edi
  8009db:	b8 d4 17 80 00       	mov    $0x8017d4,%eax
  8009e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009e7:	0f 84 92 00 00 00    	je     800a7f <vprintfmt+0x23b>
  8009ed:	85 c9                	test   %ecx,%ecx
  8009ef:	0f 8e 98 00 00 00    	jle    800a8d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f9:	89 3c 24             	mov    %edi,(%esp)
  8009fc:	e8 47 03 00 00       	call   800d48 <strnlen>
  800a01:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a04:	29 c1                	sub    %eax,%ecx
  800a06:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800a09:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a10:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a13:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a15:	eb 0f                	jmp    800a26 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800a17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a23:	83 ef 01             	sub    $0x1,%edi
  800a26:	85 ff                	test   %edi,%edi
  800a28:	7f ed                	jg     800a17 <vprintfmt+0x1d3>
  800a2a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a2d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a30:	85 c9                	test   %ecx,%ecx
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	0f 49 c1             	cmovns %ecx,%eax
  800a3a:	29 c1                	sub    %eax,%ecx
  800a3c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a42:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a45:	89 cb                	mov    %ecx,%ebx
  800a47:	eb 50                	jmp    800a99 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a49:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a4d:	74 1e                	je     800a6d <vprintfmt+0x229>
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 20             	sub    $0x20,%edx
  800a55:	83 fa 5e             	cmp    $0x5e,%edx
  800a58:	76 13                	jbe    800a6d <vprintfmt+0x229>
					putch('?', putdat);
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a61:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a68:	ff 55 08             	call   *0x8(%ebp)
  800a6b:	eb 0d                	jmp    800a7a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  800a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a70:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a74:	89 04 24             	mov    %eax,(%esp)
  800a77:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7a:	83 eb 01             	sub    $0x1,%ebx
  800a7d:	eb 1a                	jmp    800a99 <vprintfmt+0x255>
  800a7f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a82:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a85:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a88:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a8b:	eb 0c                	jmp    800a99 <vprintfmt+0x255>
  800a8d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a90:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a93:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a96:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a99:	83 c7 01             	add    $0x1,%edi
  800a9c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800aa0:	0f be c2             	movsbl %dl,%eax
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	74 25                	je     800acc <vprintfmt+0x288>
  800aa7:	85 f6                	test   %esi,%esi
  800aa9:	78 9e                	js     800a49 <vprintfmt+0x205>
  800aab:	83 ee 01             	sub    $0x1,%esi
  800aae:	79 99                	jns    800a49 <vprintfmt+0x205>
  800ab0:	89 df                	mov    %ebx,%edi
  800ab2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab8:	eb 1a                	jmp    800ad4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800abe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ac5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ac7:	83 ef 01             	sub    $0x1,%edi
  800aca:	eb 08                	jmp    800ad4 <vprintfmt+0x290>
  800acc:	89 df                	mov    %ebx,%edi
  800ace:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	7f e2                	jg     800aba <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800adb:	e9 89 fd ff ff       	jmp    800869 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ae0:	83 f9 01             	cmp    $0x1,%ecx
  800ae3:	7e 19                	jle    800afe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8b 50 04             	mov    0x4(%eax),%edx
  800aeb:	8b 00                	mov    (%eax),%eax
  800aed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	8d 40 08             	lea    0x8(%eax),%eax
  800af9:	89 45 14             	mov    %eax,0x14(%ebp)
  800afc:	eb 38                	jmp    800b36 <vprintfmt+0x2f2>
	else if (lflag)
  800afe:	85 c9                	test   %ecx,%ecx
  800b00:	74 1b                	je     800b1d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8b 00                	mov    (%eax),%eax
  800b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b0a:	89 c1                	mov    %eax,%ecx
  800b0c:	c1 f9 1f             	sar    $0x1f,%ecx
  800b0f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b12:	8b 45 14             	mov    0x14(%ebp),%eax
  800b15:	8d 40 04             	lea    0x4(%eax),%eax
  800b18:	89 45 14             	mov    %eax,0x14(%ebp)
  800b1b:	eb 19                	jmp    800b36 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  800b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b20:	8b 00                	mov    (%eax),%eax
  800b22:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b25:	89 c1                	mov    %eax,%ecx
  800b27:	c1 f9 1f             	sar    $0x1f,%ecx
  800b2a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b30:	8d 40 04             	lea    0x4(%eax),%eax
  800b33:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b36:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b39:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b3c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b41:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b45:	0f 89 04 01 00 00    	jns    800c4f <vprintfmt+0x40b>
				putch('-', putdat);
  800b4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b4f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b56:	ff d6                	call   *%esi
				num = -(long long) num;
  800b58:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b5b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b5e:	f7 da                	neg    %edx
  800b60:	83 d1 00             	adc    $0x0,%ecx
  800b63:	f7 d9                	neg    %ecx
  800b65:	e9 e5 00 00 00       	jmp    800c4f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b6a:	83 f9 01             	cmp    $0x1,%ecx
  800b6d:	7e 10                	jle    800b7f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  800b6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b72:	8b 10                	mov    (%eax),%edx
  800b74:	8b 48 04             	mov    0x4(%eax),%ecx
  800b77:	8d 40 08             	lea    0x8(%eax),%eax
  800b7a:	89 45 14             	mov    %eax,0x14(%ebp)
  800b7d:	eb 26                	jmp    800ba5 <vprintfmt+0x361>
	else if (lflag)
  800b7f:	85 c9                	test   %ecx,%ecx
  800b81:	74 12                	je     800b95 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800b83:	8b 45 14             	mov    0x14(%ebp),%eax
  800b86:	8b 10                	mov    (%eax),%edx
  800b88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8d:	8d 40 04             	lea    0x4(%eax),%eax
  800b90:	89 45 14             	mov    %eax,0x14(%ebp)
  800b93:	eb 10                	jmp    800ba5 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	8b 10                	mov    (%eax),%edx
  800b9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9f:	8d 40 04             	lea    0x4(%eax),%eax
  800ba2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800ba5:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800baa:	e9 a0 00 00 00       	jmp    800c4f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800baf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bba:	ff d6                	call   *%esi
			putch('X', putdat);
  800bbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bc7:	ff d6                	call   *%esi
			putch('X', putdat);
  800bc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bcd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bd4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800bd9:	e9 8b fc ff ff       	jmp    800869 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800bde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800be2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800be9:	ff d6                	call   *%esi
			putch('x', putdat);
  800beb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bf6:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bf8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfb:	8b 10                	mov    (%eax),%edx
  800bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800c02:	8d 40 04             	lea    0x4(%eax),%eax
  800c05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c08:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800c0d:	eb 40                	jmp    800c4f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c0f:	83 f9 01             	cmp    $0x1,%ecx
  800c12:	7e 10                	jle    800c24 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800c14:	8b 45 14             	mov    0x14(%ebp),%eax
  800c17:	8b 10                	mov    (%eax),%edx
  800c19:	8b 48 04             	mov    0x4(%eax),%ecx
  800c1c:	8d 40 08             	lea    0x8(%eax),%eax
  800c1f:	89 45 14             	mov    %eax,0x14(%ebp)
  800c22:	eb 26                	jmp    800c4a <vprintfmt+0x406>
	else if (lflag)
  800c24:	85 c9                	test   %ecx,%ecx
  800c26:	74 12                	je     800c3a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c32:	8d 40 04             	lea    0x4(%eax),%eax
  800c35:	89 45 14             	mov    %eax,0x14(%ebp)
  800c38:	eb 10                	jmp    800c4a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800c3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3d:	8b 10                	mov    (%eax),%edx
  800c3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c44:	8d 40 04             	lea    0x4(%eax),%eax
  800c47:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c4a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c4f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c62:	89 14 24             	mov    %edx,(%esp)
  800c65:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c69:	89 da                	mov    %ebx,%edx
  800c6b:	89 f0                	mov    %esi,%eax
  800c6d:	e8 9e fa ff ff       	call   800710 <printnum>
			break;
  800c72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c75:	e9 ef fb ff ff       	jmp    800869 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c7e:	89 04 24             	mov    %eax,(%esp)
  800c81:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c86:	e9 de fb ff ff       	jmp    800869 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c8f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c96:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c98:	eb 03                	jmp    800c9d <vprintfmt+0x459>
  800c9a:	83 ef 01             	sub    $0x1,%edi
  800c9d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ca1:	75 f7                	jne    800c9a <vprintfmt+0x456>
  800ca3:	e9 c1 fb ff ff       	jmp    800869 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800ca8:	83 c4 3c             	add    $0x3c,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 28             	sub    $0x28,%esp
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cc3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	74 30                	je     800d01 <vsnprintf+0x51>
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	7e 2c                	jle    800d01 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cea:	c7 04 24 ff 07 80 00 	movl   $0x8007ff,(%esp)
  800cf1:	e8 4e fb ff ff       	call   800844 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cff:	eb 05                	jmp    800d06 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d0e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d15:	8b 45 10             	mov    0x10(%ebp),%eax
  800d18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	e8 82 ff ff ff       	call   800cb0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3b:	eb 03                	jmp    800d40 <strlen+0x10>
		n++;
  800d3d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d44:	75 f7                	jne    800d3d <strlen+0xd>
		n++;
	return n;
}
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	eb 03                	jmp    800d5b <strnlen+0x13>
		n++;
  800d58:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5b:	39 d0                	cmp    %edx,%eax
  800d5d:	74 06                	je     800d65 <strnlen+0x1d>
  800d5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d63:	75 f3                	jne    800d58 <strnlen+0x10>
		n++;
	return n;
}
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	83 c2 01             	add    $0x1,%edx
  800d76:	83 c1 01             	add    $0x1,%ecx
  800d79:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d7d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d80:	84 db                	test   %bl,%bl
  800d82:	75 ef                	jne    800d73 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d84:	5b                   	pop    %ebx
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 08             	sub    $0x8,%esp
  800d8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d91:	89 1c 24             	mov    %ebx,(%esp)
  800d94:	e8 97 ff ff ff       	call   800d30 <strlen>
	strcpy(dst + len, src);
  800d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800da0:	01 d8                	add    %ebx,%eax
  800da2:	89 04 24             	mov    %eax,(%esp)
  800da5:	e8 bd ff ff ff       	call   800d67 <strcpy>
	return dst;
}
  800daa:	89 d8                	mov    %ebx,%eax
  800dac:	83 c4 08             	add    $0x8,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	89 f3                	mov    %esi,%ebx
  800dbf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc2:	89 f2                	mov    %esi,%edx
  800dc4:	eb 0f                	jmp    800dd5 <strncpy+0x23>
		*dst++ = *src;
  800dc6:	83 c2 01             	add    $0x1,%edx
  800dc9:	0f b6 01             	movzbl (%ecx),%eax
  800dcc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dcf:	80 39 01             	cmpb   $0x1,(%ecx)
  800dd2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd5:	39 da                	cmp    %ebx,%edx
  800dd7:	75 ed                	jne    800dc6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	8b 75 08             	mov    0x8(%ebp),%esi
  800de7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ded:	89 f0                	mov    %esi,%eax
  800def:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df3:	85 c9                	test   %ecx,%ecx
  800df5:	75 0b                	jne    800e02 <strlcpy+0x23>
  800df7:	eb 1d                	jmp    800e16 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800df9:	83 c0 01             	add    $0x1,%eax
  800dfc:	83 c2 01             	add    $0x1,%edx
  800dff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e02:	39 d8                	cmp    %ebx,%eax
  800e04:	74 0b                	je     800e11 <strlcpy+0x32>
  800e06:	0f b6 0a             	movzbl (%edx),%ecx
  800e09:	84 c9                	test   %cl,%cl
  800e0b:	75 ec                	jne    800df9 <strlcpy+0x1a>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	eb 02                	jmp    800e13 <strlcpy+0x34>
  800e11:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e13:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e16:	29 f0                	sub    %esi,%eax
}
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e25:	eb 06                	jmp    800e2d <strcmp+0x11>
		p++, q++;
  800e27:	83 c1 01             	add    $0x1,%ecx
  800e2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e2d:	0f b6 01             	movzbl (%ecx),%eax
  800e30:	84 c0                	test   %al,%al
  800e32:	74 04                	je     800e38 <strcmp+0x1c>
  800e34:	3a 02                	cmp    (%edx),%al
  800e36:	74 ef                	je     800e27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e38:	0f b6 c0             	movzbl %al,%eax
  800e3b:	0f b6 12             	movzbl (%edx),%edx
  800e3e:	29 d0                	sub    %edx,%eax
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	53                   	push   %ebx
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4c:	89 c3                	mov    %eax,%ebx
  800e4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e51:	eb 06                	jmp    800e59 <strncmp+0x17>
		n--, p++, q++;
  800e53:	83 c0 01             	add    $0x1,%eax
  800e56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e59:	39 d8                	cmp    %ebx,%eax
  800e5b:	74 15                	je     800e72 <strncmp+0x30>
  800e5d:	0f b6 08             	movzbl (%eax),%ecx
  800e60:	84 c9                	test   %cl,%cl
  800e62:	74 04                	je     800e68 <strncmp+0x26>
  800e64:	3a 0a                	cmp    (%edx),%cl
  800e66:	74 eb                	je     800e53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e68:	0f b6 00             	movzbl (%eax),%eax
  800e6b:	0f b6 12             	movzbl (%edx),%edx
  800e6e:	29 d0                	sub    %edx,%eax
  800e70:	eb 05                	jmp    800e77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e77:	5b                   	pop    %ebx
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e84:	eb 07                	jmp    800e8d <strchr+0x13>
		if (*s == c)
  800e86:	38 ca                	cmp    %cl,%dl
  800e88:	74 0f                	je     800e99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e8a:	83 c0 01             	add    $0x1,%eax
  800e8d:	0f b6 10             	movzbl (%eax),%edx
  800e90:	84 d2                	test   %dl,%dl
  800e92:	75 f2                	jne    800e86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ea5:	eb 07                	jmp    800eae <strfind+0x13>
		if (*s == c)
  800ea7:	38 ca                	cmp    %cl,%dl
  800ea9:	74 0a                	je     800eb5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eab:	83 c0 01             	add    $0x1,%eax
  800eae:	0f b6 10             	movzbl (%eax),%edx
  800eb1:	84 d2                	test   %dl,%dl
  800eb3:	75 f2                	jne    800ea7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ec0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ec3:	85 c9                	test   %ecx,%ecx
  800ec5:	74 36                	je     800efd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ecd:	75 28                	jne    800ef7 <memset+0x40>
  800ecf:	f6 c1 03             	test   $0x3,%cl
  800ed2:	75 23                	jne    800ef7 <memset+0x40>
		c &= 0xFF;
  800ed4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed8:	89 d3                	mov    %edx,%ebx
  800eda:	c1 e3 08             	shl    $0x8,%ebx
  800edd:	89 d6                	mov    %edx,%esi
  800edf:	c1 e6 18             	shl    $0x18,%esi
  800ee2:	89 d0                	mov    %edx,%eax
  800ee4:	c1 e0 10             	shl    $0x10,%eax
  800ee7:	09 f0                	or     %esi,%eax
  800ee9:	09 c2                	or     %eax,%edx
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ef2:	fc                   	cld    
  800ef3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ef5:	eb 06                	jmp    800efd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	fc                   	cld    
  800efb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800efd:	89 f8                	mov    %edi,%eax
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 35                	jae    800f4b <memmove+0x47>
  800f16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f19:	39 d0                	cmp    %edx,%eax
  800f1b:	73 2e                	jae    800f4b <memmove+0x47>
		s += n;
		d += n;
  800f1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f20:	89 d6                	mov    %edx,%esi
  800f22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f2a:	75 13                	jne    800f3f <memmove+0x3b>
  800f2c:	f6 c1 03             	test   $0x3,%cl
  800f2f:	75 0e                	jne    800f3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f31:	83 ef 04             	sub    $0x4,%edi
  800f34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f3a:	fd                   	std    
  800f3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f3d:	eb 09                	jmp    800f48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f3f:	83 ef 01             	sub    $0x1,%edi
  800f42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f45:	fd                   	std    
  800f46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f48:	fc                   	cld    
  800f49:	eb 1d                	jmp    800f68 <memmove+0x64>
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4f:	f6 c2 03             	test   $0x3,%dl
  800f52:	75 0f                	jne    800f63 <memmove+0x5f>
  800f54:	f6 c1 03             	test   $0x3,%cl
  800f57:	75 0a                	jne    800f63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f5c:	89 c7                	mov    %eax,%edi
  800f5e:	fc                   	cld    
  800f5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f61:	eb 05                	jmp    800f68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f63:	89 c7                	mov    %eax,%edi
  800f65:	fc                   	cld    
  800f66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f72:	8b 45 10             	mov    0x10(%ebp),%eax
  800f75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	89 04 24             	mov    %eax,(%esp)
  800f86:	e8 79 ff ff ff       	call   800f04 <memmove>
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9d:	eb 1a                	jmp    800fb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800f9f:	0f b6 02             	movzbl (%edx),%eax
  800fa2:	0f b6 19             	movzbl (%ecx),%ebx
  800fa5:	38 d8                	cmp    %bl,%al
  800fa7:	74 0a                	je     800fb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800fa9:	0f b6 c0             	movzbl %al,%eax
  800fac:	0f b6 db             	movzbl %bl,%ebx
  800faf:	29 d8                	sub    %ebx,%eax
  800fb1:	eb 0f                	jmp    800fc2 <memcmp+0x35>
		s1++, s2++;
  800fb3:	83 c2 01             	add    $0x1,%edx
  800fb6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb9:	39 f2                	cmp    %esi,%edx
  800fbb:	75 e2                	jne    800f9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fd4:	eb 07                	jmp    800fdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd6:	38 08                	cmp    %cl,(%eax)
  800fd8:	74 07                	je     800fe1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fda:	83 c0 01             	add    $0x1,%eax
  800fdd:	39 d0                	cmp    %edx,%eax
  800fdf:	72 f5                	jb     800fd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fef:	eb 03                	jmp    800ff4 <strtol+0x11>
		s++;
  800ff1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ff4:	0f b6 0a             	movzbl (%edx),%ecx
  800ff7:	80 f9 09             	cmp    $0x9,%cl
  800ffa:	74 f5                	je     800ff1 <strtol+0xe>
  800ffc:	80 f9 20             	cmp    $0x20,%cl
  800fff:	74 f0                	je     800ff1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801001:	80 f9 2b             	cmp    $0x2b,%cl
  801004:	75 0a                	jne    801010 <strtol+0x2d>
		s++;
  801006:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801009:	bf 00 00 00 00       	mov    $0x0,%edi
  80100e:	eb 11                	jmp    801021 <strtol+0x3e>
  801010:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801015:	80 f9 2d             	cmp    $0x2d,%cl
  801018:	75 07                	jne    801021 <strtol+0x3e>
		s++, neg = 1;
  80101a:	8d 52 01             	lea    0x1(%edx),%edx
  80101d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801021:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801026:	75 15                	jne    80103d <strtol+0x5a>
  801028:	80 3a 30             	cmpb   $0x30,(%edx)
  80102b:	75 10                	jne    80103d <strtol+0x5a>
  80102d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801031:	75 0a                	jne    80103d <strtol+0x5a>
		s += 2, base = 16;
  801033:	83 c2 02             	add    $0x2,%edx
  801036:	b8 10 00 00 00       	mov    $0x10,%eax
  80103b:	eb 10                	jmp    80104d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 0c                	jne    80104d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801041:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801043:	80 3a 30             	cmpb   $0x30,(%edx)
  801046:	75 05                	jne    80104d <strtol+0x6a>
		s++, base = 8;
  801048:	83 c2 01             	add    $0x1,%edx
  80104b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80104d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801052:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801055:	0f b6 0a             	movzbl (%edx),%ecx
  801058:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	3c 09                	cmp    $0x9,%al
  80105f:	77 08                	ja     801069 <strtol+0x86>
			dig = *s - '0';
  801061:	0f be c9             	movsbl %cl,%ecx
  801064:	83 e9 30             	sub    $0x30,%ecx
  801067:	eb 20                	jmp    801089 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801069:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80106c:	89 f0                	mov    %esi,%eax
  80106e:	3c 19                	cmp    $0x19,%al
  801070:	77 08                	ja     80107a <strtol+0x97>
			dig = *s - 'a' + 10;
  801072:	0f be c9             	movsbl %cl,%ecx
  801075:	83 e9 57             	sub    $0x57,%ecx
  801078:	eb 0f                	jmp    801089 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80107a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80107d:	89 f0                	mov    %esi,%eax
  80107f:	3c 19                	cmp    $0x19,%al
  801081:	77 16                	ja     801099 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801083:	0f be c9             	movsbl %cl,%ecx
  801086:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801089:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80108c:	7d 0f                	jge    80109d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80108e:	83 c2 01             	add    $0x1,%edx
  801091:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801095:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801097:	eb bc                	jmp    801055 <strtol+0x72>
  801099:	89 d8                	mov    %ebx,%eax
  80109b:	eb 02                	jmp    80109f <strtol+0xbc>
  80109d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80109f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a3:	74 05                	je     8010aa <strtol+0xc7>
		*endptr = (char *) s;
  8010a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8010aa:	f7 d8                	neg    %eax
  8010ac:	85 ff                	test   %edi,%edi
  8010ae:	0f 44 c3             	cmove  %ebx,%eax
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	89 c7                	mov    %eax,%edi
  8010cb:	89 c6                	mov    %eax,%esi
  8010cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010da:	ba 00 00 00 00       	mov    $0x0,%edx
  8010df:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e4:	89 d1                	mov    %edx,%ecx
  8010e6:	89 d3                	mov    %edx,%ebx
  8010e8:	89 d7                	mov    %edx,%edi
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    

008010f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	57                   	push   %edi
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801101:	b8 03 00 00 00       	mov    $0x3,%eax
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 cb                	mov    %ecx,%ebx
  80110b:	89 cf                	mov    %ecx,%edi
  80110d:	89 ce                	mov    %ecx,%esi
  80110f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	7e 28                	jle    80113d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801115:	89 44 24 10          	mov    %eax,0x10(%esp)
  801119:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801120:	00 
  801121:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801138:	e8 be f4 ff ff       	call   8005fb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80113d:	83 c4 2c             	add    $0x2c,%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114b:	ba 00 00 00 00       	mov    $0x0,%edx
  801150:	b8 02 00 00 00       	mov    $0x2,%eax
  801155:	89 d1                	mov    %edx,%ecx
  801157:	89 d3                	mov    %edx,%ebx
  801159:	89 d7                	mov    %edx,%edi
  80115b:	89 d6                	mov    %edx,%esi
  80115d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <sys_yield>:

void
sys_yield(void)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116a:	ba 00 00 00 00       	mov    $0x0,%edx
  80116f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801174:	89 d1                	mov    %edx,%ecx
  801176:	89 d3                	mov    %edx,%ebx
  801178:	89 d7                	mov    %edx,%edi
  80117a:	89 d6                	mov    %edx,%esi
  80117c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	53                   	push   %ebx
  801189:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118c:	be 00 00 00 00       	mov    $0x0,%esi
  801191:	b8 04 00 00 00       	mov    $0x4,%eax
  801196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801199:	8b 55 08             	mov    0x8(%ebp),%edx
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119f:	89 f7                	mov    %esi,%edi
  8011a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 28                	jle    8011cf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ab:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8011ca:	e8 2c f4 ff ff       	call   8005fb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011cf:	83 c4 2c             	add    $0x2c,%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	7e 28                	jle    801222 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011fe:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801205:	00 
  801206:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80121d:	e8 d9 f3 ff ff       	call   8005fb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801222:	83 c4 2c             	add    $0x2c,%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
  801238:	b8 06 00 00 00       	mov    $0x6,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 df                	mov    %ebx,%edi
  801245:	89 de                	mov    %ebx,%esi
  801247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	7e 28                	jle    801275 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801251:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801258:	00 
  801259:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801260:	00 
  801261:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801268:	00 
  801269:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801270:	e8 86 f3 ff ff       	call   8005fb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801275:	83 c4 2c             	add    $0x2c,%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
  801283:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	b8 08 00 00 00       	mov    $0x8,%eax
  801290:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801293:	8b 55 08             	mov    0x8(%ebp),%edx
  801296:	89 df                	mov    %ebx,%edi
  801298:	89 de                	mov    %ebx,%esi
  80129a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80129c:	85 c0                	test   %eax,%eax
  80129e:	7e 28                	jle    8012c8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  8012b3:	00 
  8012b4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012bb:	00 
  8012bc:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  8012c3:	e8 33 f3 ff ff       	call   8005fb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012c8:	83 c4 2c             	add    $0x2c,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	57                   	push   %edi
  8012d4:	56                   	push   %esi
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012de:	b8 09 00 00 00       	mov    $0x9,%eax
  8012e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	89 df                	mov    %ebx,%edi
  8012eb:	89 de                	mov    %ebx,%esi
  8012ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	7e 28                	jle    80131b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  801316:	e8 e0 f2 ff ff       	call   8005fb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80131b:	83 c4 2c             	add    $0x2c,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801329:	be 00 00 00 00       	mov    $0x0,%esi
  80132e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801336:	8b 55 08             	mov    0x8(%ebp),%edx
  801339:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80133f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80134f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801354:	b8 0c 00 00 00       	mov    $0xc,%eax
  801359:	8b 55 08             	mov    0x8(%ebp),%edx
  80135c:	89 cb                	mov    %ecx,%ebx
  80135e:	89 cf                	mov    %ecx,%edi
  801360:	89 ce                	mov    %ecx,%esi
  801362:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	7e 28                	jle    801390 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801368:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801373:	00 
  801374:	c7 44 24 08 08 1a 80 	movl   $0x801a08,0x8(%esp)
  80137b:	00 
  80137c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801383:	00 
  801384:	c7 04 24 25 1a 80 00 	movl   $0x801a25,(%esp)
  80138b:	e8 6b f2 ff ff       	call   8005fb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801390:	83 c4 2c             	add    $0x2c,%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80139e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8013a5:	75 1c                	jne    8013c3 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8013a7:	c7 44 24 08 34 1a 80 	movl   $0x801a34,0x8(%esp)
  8013ae:	00 
  8013af:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8013b6:	00 
  8013b7:	c7 04 24 58 1a 80 00 	movl   $0x801a58,(%esp)
  8013be:	e8 38 f2 ff ff       	call   8005fb <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    
  8013cd:	00 00                	add    %al,(%eax)
	...

008013d0 <__udivdi3>:
  8013d0:	83 ec 1c             	sub    $0x1c,%esp
  8013d3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8013d7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8013db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8013df:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8013e3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8013eb:	85 ff                	test   %edi,%edi
  8013ed:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8013f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f5:	89 cd                	mov    %ecx,%ebp
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	75 33                	jne    801430 <__udivdi3+0x60>
  8013fd:	39 f1                	cmp    %esi,%ecx
  8013ff:	77 57                	ja     801458 <__udivdi3+0x88>
  801401:	85 c9                	test   %ecx,%ecx
  801403:	75 0b                	jne    801410 <__udivdi3+0x40>
  801405:	b8 01 00 00 00       	mov    $0x1,%eax
  80140a:	31 d2                	xor    %edx,%edx
  80140c:	f7 f1                	div    %ecx
  80140e:	89 c1                	mov    %eax,%ecx
  801410:	89 f0                	mov    %esi,%eax
  801412:	31 d2                	xor    %edx,%edx
  801414:	f7 f1                	div    %ecx
  801416:	89 c6                	mov    %eax,%esi
  801418:	8b 44 24 04          	mov    0x4(%esp),%eax
  80141c:	f7 f1                	div    %ecx
  80141e:	89 f2                	mov    %esi,%edx
  801420:	8b 74 24 10          	mov    0x10(%esp),%esi
  801424:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801428:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80142c:	83 c4 1c             	add    $0x1c,%esp
  80142f:	c3                   	ret    
  801430:	31 d2                	xor    %edx,%edx
  801432:	31 c0                	xor    %eax,%eax
  801434:	39 f7                	cmp    %esi,%edi
  801436:	77 e8                	ja     801420 <__udivdi3+0x50>
  801438:	0f bd cf             	bsr    %edi,%ecx
  80143b:	83 f1 1f             	xor    $0x1f,%ecx
  80143e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801442:	75 2c                	jne    801470 <__udivdi3+0xa0>
  801444:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801448:	76 04                	jbe    80144e <__udivdi3+0x7e>
  80144a:	39 f7                	cmp    %esi,%edi
  80144c:	73 d2                	jae    801420 <__udivdi3+0x50>
  80144e:	31 d2                	xor    %edx,%edx
  801450:	b8 01 00 00 00       	mov    $0x1,%eax
  801455:	eb c9                	jmp    801420 <__udivdi3+0x50>
  801457:	90                   	nop
  801458:	89 f2                	mov    %esi,%edx
  80145a:	f7 f1                	div    %ecx
  80145c:	31 d2                	xor    %edx,%edx
  80145e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801462:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801466:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80146a:	83 c4 1c             	add    $0x1c,%esp
  80146d:	c3                   	ret    
  80146e:	66 90                	xchg   %ax,%ax
  801470:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801475:	b8 20 00 00 00       	mov    $0x20,%eax
  80147a:	89 ea                	mov    %ebp,%edx
  80147c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801480:	d3 e7                	shl    %cl,%edi
  801482:	89 c1                	mov    %eax,%ecx
  801484:	d3 ea                	shr    %cl,%edx
  801486:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80148b:	09 fa                	or     %edi,%edx
  80148d:	89 f7                	mov    %esi,%edi
  80148f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801493:	89 f2                	mov    %esi,%edx
  801495:	8b 74 24 08          	mov    0x8(%esp),%esi
  801499:	d3 e5                	shl    %cl,%ebp
  80149b:	89 c1                	mov    %eax,%ecx
  80149d:	d3 ef                	shr    %cl,%edi
  80149f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014a4:	d3 e2                	shl    %cl,%edx
  8014a6:	89 c1                	mov    %eax,%ecx
  8014a8:	d3 ee                	shr    %cl,%esi
  8014aa:	09 d6                	or     %edx,%esi
  8014ac:	89 fa                	mov    %edi,%edx
  8014ae:	89 f0                	mov    %esi,%eax
  8014b0:	f7 74 24 0c          	divl   0xc(%esp)
  8014b4:	89 d7                	mov    %edx,%edi
  8014b6:	89 c6                	mov    %eax,%esi
  8014b8:	f7 e5                	mul    %ebp
  8014ba:	39 d7                	cmp    %edx,%edi
  8014bc:	72 22                	jb     8014e0 <__udivdi3+0x110>
  8014be:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8014c2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014c7:	d3 e5                	shl    %cl,%ebp
  8014c9:	39 c5                	cmp    %eax,%ebp
  8014cb:	73 04                	jae    8014d1 <__udivdi3+0x101>
  8014cd:	39 d7                	cmp    %edx,%edi
  8014cf:	74 0f                	je     8014e0 <__udivdi3+0x110>
  8014d1:	89 f0                	mov    %esi,%eax
  8014d3:	31 d2                	xor    %edx,%edx
  8014d5:	e9 46 ff ff ff       	jmp    801420 <__udivdi3+0x50>
  8014da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014e0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8014e3:	31 d2                	xor    %edx,%edx
  8014e5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8014e9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8014ed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8014f1:	83 c4 1c             	add    $0x1c,%esp
  8014f4:	c3                   	ret    
	...

00801500 <__umoddi3>:
  801500:	83 ec 1c             	sub    $0x1c,%esp
  801503:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801507:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80150b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80150f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801513:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801517:	8b 74 24 24          	mov    0x24(%esp),%esi
  80151b:	85 ed                	test   %ebp,%ebp
  80151d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801521:	89 44 24 08          	mov    %eax,0x8(%esp)
  801525:	89 cf                	mov    %ecx,%edi
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	89 f2                	mov    %esi,%edx
  80152c:	75 1a                	jne    801548 <__umoddi3+0x48>
  80152e:	39 f1                	cmp    %esi,%ecx
  801530:	76 4e                	jbe    801580 <__umoddi3+0x80>
  801532:	f7 f1                	div    %ecx
  801534:	89 d0                	mov    %edx,%eax
  801536:	31 d2                	xor    %edx,%edx
  801538:	8b 74 24 10          	mov    0x10(%esp),%esi
  80153c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801540:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801544:	83 c4 1c             	add    $0x1c,%esp
  801547:	c3                   	ret    
  801548:	39 f5                	cmp    %esi,%ebp
  80154a:	77 54                	ja     8015a0 <__umoddi3+0xa0>
  80154c:	0f bd c5             	bsr    %ebp,%eax
  80154f:	83 f0 1f             	xor    $0x1f,%eax
  801552:	89 44 24 04          	mov    %eax,0x4(%esp)
  801556:	75 60                	jne    8015b8 <__umoddi3+0xb8>
  801558:	3b 0c 24             	cmp    (%esp),%ecx
  80155b:	0f 87 07 01 00 00    	ja     801668 <__umoddi3+0x168>
  801561:	89 f2                	mov    %esi,%edx
  801563:	8b 34 24             	mov    (%esp),%esi
  801566:	29 ce                	sub    %ecx,%esi
  801568:	19 ea                	sbb    %ebp,%edx
  80156a:	89 34 24             	mov    %esi,(%esp)
  80156d:	8b 04 24             	mov    (%esp),%eax
  801570:	8b 74 24 10          	mov    0x10(%esp),%esi
  801574:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801578:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80157c:	83 c4 1c             	add    $0x1c,%esp
  80157f:	c3                   	ret    
  801580:	85 c9                	test   %ecx,%ecx
  801582:	75 0b                	jne    80158f <__umoddi3+0x8f>
  801584:	b8 01 00 00 00       	mov    $0x1,%eax
  801589:	31 d2                	xor    %edx,%edx
  80158b:	f7 f1                	div    %ecx
  80158d:	89 c1                	mov    %eax,%ecx
  80158f:	89 f0                	mov    %esi,%eax
  801591:	31 d2                	xor    %edx,%edx
  801593:	f7 f1                	div    %ecx
  801595:	8b 04 24             	mov    (%esp),%eax
  801598:	f7 f1                	div    %ecx
  80159a:	eb 98                	jmp    801534 <__umoddi3+0x34>
  80159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	89 f2                	mov    %esi,%edx
  8015a2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8015a6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8015aa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8015ae:	83 c4 1c             	add    $0x1c,%esp
  8015b1:	c3                   	ret    
  8015b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015b8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015bd:	89 e8                	mov    %ebp,%eax
  8015bf:	bd 20 00 00 00       	mov    $0x20,%ebp
  8015c4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8015c8:	89 fa                	mov    %edi,%edx
  8015ca:	d3 e0                	shl    %cl,%eax
  8015cc:	89 e9                	mov    %ebp,%ecx
  8015ce:	d3 ea                	shr    %cl,%edx
  8015d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015d5:	09 c2                	or     %eax,%edx
  8015d7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015db:	89 14 24             	mov    %edx,(%esp)
  8015de:	89 f2                	mov    %esi,%edx
  8015e0:	d3 e7                	shl    %cl,%edi
  8015e2:	89 e9                	mov    %ebp,%ecx
  8015e4:	d3 ea                	shr    %cl,%edx
  8015e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015ef:	d3 e6                	shl    %cl,%esi
  8015f1:	89 e9                	mov    %ebp,%ecx
  8015f3:	d3 e8                	shr    %cl,%eax
  8015f5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015fa:	09 f0                	or     %esi,%eax
  8015fc:	8b 74 24 08          	mov    0x8(%esp),%esi
  801600:	f7 34 24             	divl   (%esp)
  801603:	d3 e6                	shl    %cl,%esi
  801605:	89 74 24 08          	mov    %esi,0x8(%esp)
  801609:	89 d6                	mov    %edx,%esi
  80160b:	f7 e7                	mul    %edi
  80160d:	39 d6                	cmp    %edx,%esi
  80160f:	89 c1                	mov    %eax,%ecx
  801611:	89 d7                	mov    %edx,%edi
  801613:	72 3f                	jb     801654 <__umoddi3+0x154>
  801615:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801619:	72 35                	jb     801650 <__umoddi3+0x150>
  80161b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80161f:	29 c8                	sub    %ecx,%eax
  801621:	19 fe                	sbb    %edi,%esi
  801623:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801628:	89 f2                	mov    %esi,%edx
  80162a:	d3 e8                	shr    %cl,%eax
  80162c:	89 e9                	mov    %ebp,%ecx
  80162e:	d3 e2                	shl    %cl,%edx
  801630:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801635:	09 d0                	or     %edx,%eax
  801637:	89 f2                	mov    %esi,%edx
  801639:	d3 ea                	shr    %cl,%edx
  80163b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80163f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801643:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801647:	83 c4 1c             	add    $0x1c,%esp
  80164a:	c3                   	ret    
  80164b:	90                   	nop
  80164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801650:	39 d6                	cmp    %edx,%esi
  801652:	75 c7                	jne    80161b <__umoddi3+0x11b>
  801654:	89 d7                	mov    %edx,%edi
  801656:	89 c1                	mov    %eax,%ecx
  801658:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80165c:	1b 3c 24             	sbb    (%esp),%edi
  80165f:	eb ba                	jmp    80161b <__umoddi3+0x11b>
  801661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801668:	39 f5                	cmp    %esi,%ebp
  80166a:	0f 82 f1 fe ff ff    	jb     801561 <__umoddi3+0x61>
  801670:	e9 f8 fe ff ff       	jmp    80156d <__umoddi3+0x6d>
