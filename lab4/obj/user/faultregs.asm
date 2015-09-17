
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
  80002c:	e8 64 05 00 00       	call   800595 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 91 16 80 	movl   $0x801691,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 60 16 80 00 	movl   $0x801660,(%esp)
  80005a:	e8 78 06 00 00       	call   8006d7 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 70 16 80 	movl   $0x801670,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  80007a:	e8 58 06 00 00       	call   8006d7 <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  80008c:	e8 46 06 00 00       	call   8006d7 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  80009f:	e8 33 06 00 00       	call   8006d7 <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 92 16 80 	movl   $0x801692,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8000c6:	e8 0c 06 00 00       	call   8006d7 <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  8000da:	e8 f8 05 00 00       	call   8006d7 <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  8000e8:	e8 ea 05 00 00       	call   8006d7 <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 96 16 80 	movl   $0x801696,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  80010f:	e8 c3 05 00 00       	call   8006d7 <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800123:	e8 af 05 00 00       	call   8006d7 <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  800131:	e8 a1 05 00 00       	call   8006d7 <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 9a 16 80 	movl   $0x80169a,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  800158:	e8 7a 05 00 00       	call   8006d7 <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  80016c:	e8 66 05 00 00       	call   8006d7 <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  80017a:	e8 58 05 00 00       	call   8006d7 <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 9e 16 80 	movl   $0x80169e,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8001a1:	e8 31 05 00 00       	call   8006d7 <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  8001b5:	e8 1d 05 00 00       	call   8006d7 <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  8001c3:	e8 0f 05 00 00       	call   8006d7 <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 a2 16 80 	movl   $0x8016a2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8001ea:	e8 e8 04 00 00       	call   8006d7 <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  8001fe:	e8 d4 04 00 00       	call   8006d7 <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  80020c:	e8 c6 04 00 00       	call   8006d7 <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 a6 16 80 	movl   $0x8016a6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  800233:	e8 9f 04 00 00       	call   8006d7 <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800247:	e8 8b 04 00 00       	call   8006d7 <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  800255:	e8 7d 04 00 00       	call   8006d7 <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 aa 16 80 	movl   $0x8016aa,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  80027c:	e8 56 04 00 00       	call   8006d7 <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800290:	e8 42 04 00 00       	call   8006d7 <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  80029e:	e8 34 04 00 00       	call   8006d7 <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ae 16 80 	movl   $0x8016ae,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8002c5:	e8 0d 04 00 00       	call   8006d7 <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  8002d9:	e8 f9 03 00 00       	call   8006d7 <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  8002e7:	e8 eb 03 00 00       	call   8006d7 <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 b5 16 80 	movl   $0x8016b5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  80030e:	e8 c4 03 00 00       	call   8006d7 <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800322:	e8 b0 03 00 00       	call   8006d7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 b9 16 80 00 	movl   $0x8016b9,(%esp)
  800335:	e8 9d 03 00 00       	call   8006d7 <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800340:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  800347:	e8 8b 03 00 00       	call   8006d7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 b9 16 80 00 	movl   $0x8016b9,(%esp)
  80035a:	e8 78 03 00 00       	call   8006d7 <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800361:	c7 04 24 84 16 80 00 	movl   $0x801684,(%esp)
  800368:	e8 6a 03 00 00       	call   8006d7 <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  800376:	e8 5c 03 00 00       	call   8006d7 <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 20 17 80 	movl   $0x801720,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 c7 16 80 00 	movl   $0x8016c7,(%esp)
  8003b8:	e8 21 02 00 00       	call   8005de <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 74 20 80 00    	mov    %edx,0x802074
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 78 20 80 00    	mov    %edx,0x802078
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 df 16 80 	movl   $0x8016df,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 ed 16 80 00 	movl   $0x8016ed,(%esp)
  80042e:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800433:	ba d8 16 80 00       	mov    $0x8016d8,%edx
  800438:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80043d:	e8 f1 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 15 0d 00 00       	call   801173 <sys_page_alloc>
  80045e:	85 c0                	test   %eax,%eax
  800460:	79 20                	jns    800482 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 f4 16 80 	movl   $0x8016f4,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 c7 16 80 00 	movl   $0x8016c7,(%esp)
  80047d:	e8 5c 01 00 00       	call   8005de <_panic>
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <umain>:

void
umain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048a:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800491:	e8 f2 0e 00 00       	call   801388 <set_pgfault_handler>

	__asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004b7:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004bd:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004c3:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004c9:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004cf:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004d5:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004da:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004f0:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004f6:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004fc:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800502:	89 15 34 20 80 00    	mov    %edx,0x802034
  800508:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  80050e:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800513:	89 25 48 20 80 00    	mov    %esp,0x802048
  800519:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  80051f:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800525:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80052b:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800531:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800537:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80053d:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800542:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 44 20 80 00       	mov    %eax,0x802044
  800550:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  800561:	e8 71 01 00 00       	call   8006d7 <cprintf>
	after.eip = before.eip;
  800566:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80056b:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 07 17 80 	movl   $0x801707,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 18 17 80 00 	movl   $0x801718,(%esp)
  80057f:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800584:	ba d8 16 80 00       	mov    $0x8016d8,%edx
  800589:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80058e:	e8 a0 fa ff ff       	call   800033 <check_regs>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	83 ec 18             	sub    $0x18,%esp
  80059b:	8b 45 08             	mov    0x8(%ebp),%eax
  80059e:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005a1:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005a8:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	7e 08                	jle    8005b7 <libmain+0x22>
		binaryname = argv[0];
  8005af:	8b 0a                	mov    (%edx),%ecx
  8005b1:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8005b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 c1 fe ff ff       	call   800484 <umain>

	// exit gracefully
	exit();
  8005c3:	e8 02 00 00 00       	call   8005ca <exit>
}
  8005c8:	c9                   	leave  
  8005c9:	c3                   	ret    

008005ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005d7:	e8 07 0b 00 00       	call   8010e3 <sys_env_destroy>
}
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	56                   	push   %esi
  8005e2:	53                   	push   %ebx
  8005e3:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005ef:	e8 41 0b 00 00       	call   801135 <sys_getenvid>
  8005f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800602:	89 74 24 08          	mov    %esi,0x8(%esp)
  800606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060a:	c7 04 24 80 17 80 00 	movl   $0x801780,(%esp)
  800611:	e8 c1 00 00 00       	call   8006d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800616:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061a:	8b 45 10             	mov    0x10(%ebp),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	e8 51 00 00 00       	call   800676 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 90 16 80 00 	movl   $0x801690,(%esp)
  80062c:	e8 a6 00 00 00       	call   8006d7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800631:	cc                   	int3   
  800632:	eb fd                	jmp    800631 <_panic+0x53>

00800634 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	53                   	push   %ebx
  800638:	83 ec 14             	sub    $0x14,%esp
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063e:	8b 13                	mov    (%ebx),%edx
  800640:	8d 42 01             	lea    0x1(%edx),%eax
  800643:	89 03                	mov    %eax,(%ebx)
  800645:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800648:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800651:	75 19                	jne    80066c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800653:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80065a:	00 
  80065b:	8d 43 08             	lea    0x8(%ebx),%eax
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	e8 40 0a 00 00       	call   8010a6 <sys_cputs>
		b->idx = 0;
  800666:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80066c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800670:	83 c4 14             	add    $0x14,%esp
  800673:	5b                   	pop    %ebx
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80067f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800686:	00 00 00 
	b.cnt = 0;
  800689:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800690:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800693:	8b 45 0c             	mov    0xc(%ebp),%eax
  800696:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ab:	c7 04 24 34 06 80 00 	movl   $0x800634,(%esp)
  8006b2:	e8 7d 01 00 00       	call   800834 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	e8 d7 09 00 00       	call   8010a6 <sys_cputs>

	return b.cnt;
}
  8006cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 87 ff ff ff       	call   800676 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    
  8006f1:	66 90                	xchg   %ax,%ax
  8006f3:	66 90                	xchg   %ax,%ax
  8006f5:	66 90                	xchg   %ax,%ax
  8006f7:	66 90                	xchg   %ax,%ax
  8006f9:	66 90                	xchg   %ax,%ax
  8006fb:	66 90                	xchg   %ax,%ax
  8006fd:	66 90                	xchg   %ax,%ax
  8006ff:	90                   	nop

00800700 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 3c             	sub    $0x3c,%esp
  800709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070c:	89 d7                	mov    %edx,%edi
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800714:	8b 45 0c             	mov    0xc(%ebp),%eax
  800717:	89 c3                	mov    %eax,%ebx
  800719:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80071c:	8b 45 10             	mov    0x10(%ebp),%eax
  80071f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072d:	39 d9                	cmp    %ebx,%ecx
  80072f:	72 05                	jb     800736 <printnum+0x36>
  800731:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800734:	77 69                	ja     80079f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800736:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800739:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80073d:	83 ee 01             	sub    $0x1,%esi
  800740:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800744:	89 44 24 08          	mov    %eax,0x8(%esp)
  800748:	8b 44 24 08          	mov    0x8(%esp),%eax
  80074c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800750:	89 c3                	mov    %eax,%ebx
  800752:	89 d6                	mov    %edx,%esi
  800754:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800757:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80075a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80075e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800762:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	e8 4c 0c 00 00       	call   8013c0 <__udivdi3>
  800774:	89 d9                	mov    %ebx,%ecx
  800776:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	89 54 24 04          	mov    %edx,0x4(%esp)
  800785:	89 fa                	mov    %edi,%edx
  800787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80078a:	e8 71 ff ff ff       	call   800700 <printnum>
  80078f:	eb 1b                	jmp    8007ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800791:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800795:	8b 45 18             	mov    0x18(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff d3                	call   *%ebx
  80079d:	eb 03                	jmp    8007a2 <printnum+0xa2>
  80079f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007a2:	83 ee 01             	sub    $0x1,%esi
  8007a5:	85 f6                	test   %esi,%esi
  8007a7:	7f e8                	jg     800791 <printnum+0x91>
  8007a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c5:	89 04 24             	mov    %eax,(%esp)
  8007c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cf:	e8 1c 0d 00 00       	call   8014f0 <__umoddi3>
  8007d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d8:	0f be 80 a3 17 80 00 	movsbl 0x8017a3(%eax),%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007e5:	ff d0                	call   *%eax
}
  8007e7:	83 c4 3c             	add    $0x3c,%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007fe:	73 0a                	jae    80080a <sprintputch+0x1b>
		*b->buf++ = ch;
  800800:	8d 4a 01             	lea    0x1(%edx),%ecx
  800803:	89 08                	mov    %ecx,(%eax)
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	88 02                	mov    %al,(%edx)
}
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800815:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800819:	8b 45 10             	mov    0x10(%ebp),%eax
  80081c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800820:	8b 45 0c             	mov    0xc(%ebp),%eax
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	89 04 24             	mov    %eax,(%esp)
  80082d:	e8 02 00 00 00       	call   800834 <vprintfmt>
	va_end(ap);
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	57                   	push   %edi
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	83 ec 3c             	sub    $0x3c,%esp
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800843:	8b 7d 10             	mov    0x10(%ebp),%edi
  800846:	eb 11                	jmp    800859 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800848:	85 c0                	test   %eax,%eax
  80084a:	0f 84 48 04 00 00    	je     800c98 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800850:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800859:	83 c7 01             	add    $0x1,%edi
  80085c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800860:	83 f8 25             	cmp    $0x25,%eax
  800863:	75 e3                	jne    800848 <vprintfmt+0x14>
  800865:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800869:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800870:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800877:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80087e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800883:	eb 1f                	jmp    8008a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800888:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80088c:	eb 16                	jmp    8008a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800891:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800895:	eb 0d                	jmp    8008a4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800897:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80089a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80089d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8d 47 01             	lea    0x1(%edi),%eax
  8008a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008aa:	0f b6 17             	movzbl (%edi),%edx
  8008ad:	0f b6 c2             	movzbl %dl,%eax
  8008b0:	83 ea 23             	sub    $0x23,%edx
  8008b3:	80 fa 55             	cmp    $0x55,%dl
  8008b6:	0f 87 bf 03 00 00    	ja     800c7b <vprintfmt+0x447>
  8008bc:	0f b6 d2             	movzbl %dl,%edx
  8008bf:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
  8008c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008d1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008d4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008d8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8008db:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008de:	83 f9 09             	cmp    $0x9,%ecx
  8008e1:	77 3c                	ja     80091f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008e6:	eb e9                	jmp    8008d1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8b 00                	mov    (%eax),%eax
  8008ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	8d 40 04             	lea    0x4(%eax),%eax
  8008f6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008fc:	eb 27                	jmp    800925 <vprintfmt+0xf1>
  8008fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800901:	85 d2                	test   %edx,%edx
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	0f 49 c2             	cmovns %edx,%eax
  80090b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800911:	eb 91                	jmp    8008a4 <vprintfmt+0x70>
  800913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800916:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80091d:	eb 85                	jmp    8008a4 <vprintfmt+0x70>
  80091f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800922:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800925:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800929:	0f 89 75 ff ff ff    	jns    8008a4 <vprintfmt+0x70>
  80092f:	e9 63 ff ff ff       	jmp    800897 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800934:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800937:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80093a:	e9 65 ff ff ff       	jmp    8008a4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800942:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800946:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094a:	8b 00                	mov    (%eax),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800954:	e9 00 ff ff ff       	jmp    800859 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80095c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800960:	8b 00                	mov    (%eax),%eax
  800962:	99                   	cltd   
  800963:	31 d0                	xor    %edx,%eax
  800965:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800967:	83 f8 09             	cmp    $0x9,%eax
  80096a:	7f 0b                	jg     800977 <vprintfmt+0x143>
  80096c:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  800973:	85 d2                	test   %edx,%edx
  800975:	75 20                	jne    800997 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800977:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097b:	c7 44 24 08 bb 17 80 	movl   $0x8017bb,0x8(%esp)
  800982:	00 
  800983:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800987:	89 34 24             	mov    %esi,(%esp)
  80098a:	e8 7d fe ff ff       	call   80080c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800992:	e9 c2 fe ff ff       	jmp    800859 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800997:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80099b:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  8009a2:	00 
  8009a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a7:	89 34 24             	mov    %esi,(%esp)
  8009aa:	e8 5d fe ff ff       	call   80080c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009b2:	e9 a2 fe ff ff       	jmp    800859 <vprintfmt+0x25>
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009c3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8009c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009c9:	85 ff                	test   %edi,%edi
  8009cb:	b8 b4 17 80 00       	mov    $0x8017b4,%eax
  8009d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009d7:	0f 84 92 00 00 00    	je     800a6f <vprintfmt+0x23b>
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	0f 8e 98 00 00 00    	jle    800a7d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009e9:	89 3c 24             	mov    %edi,(%esp)
  8009ec:	e8 47 03 00 00       	call   800d38 <strnlen>
  8009f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009f4:	29 c1                	sub    %eax,%ecx
  8009f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8009f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a00:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a03:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a05:	eb 0f                	jmp    800a16 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800a07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a0e:	89 04 24             	mov    %eax,(%esp)
  800a11:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a13:	83 ef 01             	sub    $0x1,%edi
  800a16:	85 ff                	test   %edi,%edi
  800a18:	7f ed                	jg     800a07 <vprintfmt+0x1d3>
  800a1a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a1d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a20:	85 c9                	test   %ecx,%ecx
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	0f 49 c1             	cmovns %ecx,%eax
  800a2a:	29 c1                	sub    %eax,%ecx
  800a2c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a35:	89 cb                	mov    %ecx,%ebx
  800a37:	eb 50                	jmp    800a89 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a39:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a3d:	74 1e                	je     800a5d <vprintfmt+0x229>
  800a3f:	0f be d2             	movsbl %dl,%edx
  800a42:	83 ea 20             	sub    $0x20,%edx
  800a45:	83 fa 5e             	cmp    $0x5e,%edx
  800a48:	76 13                	jbe    800a5d <vprintfmt+0x229>
					putch('?', putdat);
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a51:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a58:	ff 55 08             	call   *0x8(%ebp)
  800a5b:	eb 0d                	jmp    800a6a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  800a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a64:	89 04 24             	mov    %eax,(%esp)
  800a67:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6a:	83 eb 01             	sub    $0x1,%ebx
  800a6d:	eb 1a                	jmp    800a89 <vprintfmt+0x255>
  800a6f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a72:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a78:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a7b:	eb 0c                	jmp    800a89 <vprintfmt+0x255>
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a89:	83 c7 01             	add    $0x1,%edi
  800a8c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a90:	0f be c2             	movsbl %dl,%eax
  800a93:	85 c0                	test   %eax,%eax
  800a95:	74 25                	je     800abc <vprintfmt+0x288>
  800a97:	85 f6                	test   %esi,%esi
  800a99:	78 9e                	js     800a39 <vprintfmt+0x205>
  800a9b:	83 ee 01             	sub    $0x1,%esi
  800a9e:	79 99                	jns    800a39 <vprintfmt+0x205>
  800aa0:	89 df                	mov    %ebx,%edi
  800aa2:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa8:	eb 1a                	jmp    800ac4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ab5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ab7:	83 ef 01             	sub    $0x1,%edi
  800aba:	eb 08                	jmp    800ac4 <vprintfmt+0x290>
  800abc:	89 df                	mov    %ebx,%edi
  800abe:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	7f e2                	jg     800aaa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800acb:	e9 89 fd ff ff       	jmp    800859 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad0:	83 f9 01             	cmp    $0x1,%ecx
  800ad3:	7e 19                	jle    800aee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800ad5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad8:	8b 50 04             	mov    0x4(%eax),%edx
  800adb:	8b 00                	mov    (%eax),%eax
  800add:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ae3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae6:	8d 40 08             	lea    0x8(%eax),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
  800aec:	eb 38                	jmp    800b26 <vprintfmt+0x2f2>
	else if (lflag)
  800aee:	85 c9                	test   %ecx,%ecx
  800af0:	74 1b                	je     800b0d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800af2:	8b 45 14             	mov    0x14(%ebp),%eax
  800af5:	8b 00                	mov    (%eax),%eax
  800af7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afa:	89 c1                	mov    %eax,%ecx
  800afc:	c1 f9 1f             	sar    $0x1f,%ecx
  800aff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 40 04             	lea    0x4(%eax),%eax
  800b08:	89 45 14             	mov    %eax,0x14(%ebp)
  800b0b:	eb 19                	jmp    800b26 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  800b0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b10:	8b 00                	mov    (%eax),%eax
  800b12:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b15:	89 c1                	mov    %eax,%ecx
  800b17:	c1 f9 1f             	sar    $0x1f,%ecx
  800b1a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b20:	8d 40 04             	lea    0x4(%eax),%eax
  800b23:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b26:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b29:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b2c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b31:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b35:	0f 89 04 01 00 00    	jns    800c3f <vprintfmt+0x40b>
				putch('-', putdat);
  800b3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b46:	ff d6                	call   *%esi
				num = -(long long) num;
  800b48:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b4b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b4e:	f7 da                	neg    %edx
  800b50:	83 d1 00             	adc    $0x0,%ecx
  800b53:	f7 d9                	neg    %ecx
  800b55:	e9 e5 00 00 00       	jmp    800c3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b5a:	83 f9 01             	cmp    $0x1,%ecx
  800b5d:	7e 10                	jle    800b6f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8b 10                	mov    (%eax),%edx
  800b64:	8b 48 04             	mov    0x4(%eax),%ecx
  800b67:	8d 40 08             	lea    0x8(%eax),%eax
  800b6a:	89 45 14             	mov    %eax,0x14(%ebp)
  800b6d:	eb 26                	jmp    800b95 <vprintfmt+0x361>
	else if (lflag)
  800b6f:	85 c9                	test   %ecx,%ecx
  800b71:	74 12                	je     800b85 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8b 10                	mov    (%eax),%edx
  800b78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7d:	8d 40 04             	lea    0x4(%eax),%eax
  800b80:	89 45 14             	mov    %eax,0x14(%ebp)
  800b83:	eb 10                	jmp    800b95 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800b85:	8b 45 14             	mov    0x14(%ebp),%eax
  800b88:	8b 10                	mov    (%eax),%edx
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	8d 40 04             	lea    0x4(%eax),%eax
  800b92:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b95:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800b9a:	e9 a0 00 00 00       	jmp    800c3f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800baa:	ff d6                	call   *%esi
			putch('X', putdat);
  800bac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bb7:	ff d6                	call   *%esi
			putch('X', putdat);
  800bb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bbd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bc4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800bc9:	e9 8b fc ff ff       	jmp    800859 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800bce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bd9:	ff d6                	call   *%esi
			putch('x', putdat);
  800bdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bdf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800be6:	ff d6                	call   *%esi
			num = (unsigned long long)
  800be8:	8b 45 14             	mov    0x14(%ebp),%eax
  800beb:	8b 10                	mov    (%eax),%edx
  800bed:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800bf2:	8d 40 04             	lea    0x4(%eax),%eax
  800bf5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800bfd:	eb 40                	jmp    800c3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800bff:	83 f9 01             	cmp    $0x1,%ecx
  800c02:	7e 10                	jle    800c14 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	8b 10                	mov    (%eax),%edx
  800c09:	8b 48 04             	mov    0x4(%eax),%ecx
  800c0c:	8d 40 08             	lea    0x8(%eax),%eax
  800c0f:	89 45 14             	mov    %eax,0x14(%ebp)
  800c12:	eb 26                	jmp    800c3a <vprintfmt+0x406>
	else if (lflag)
  800c14:	85 c9                	test   %ecx,%ecx
  800c16:	74 12                	je     800c2a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800c18:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1b:	8b 10                	mov    (%eax),%edx
  800c1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c22:	8d 40 04             	lea    0x4(%eax),%eax
  800c25:	89 45 14             	mov    %eax,0x14(%ebp)
  800c28:	eb 10                	jmp    800c3a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800c2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2d:	8b 10                	mov    (%eax),%edx
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	8d 40 04             	lea    0x4(%eax),%eax
  800c37:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c3a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c3f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c52:	89 14 24             	mov    %edx,(%esp)
  800c55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c59:	89 da                	mov    %ebx,%edx
  800c5b:	89 f0                	mov    %esi,%eax
  800c5d:	e8 9e fa ff ff       	call   800700 <printnum>
			break;
  800c62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c65:	e9 ef fb ff ff       	jmp    800859 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c6e:	89 04 24             	mov    %eax,(%esp)
  800c71:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c76:	e9 de fb ff ff       	jmp    800859 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c7f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c88:	eb 03                	jmp    800c8d <vprintfmt+0x459>
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c91:	75 f7                	jne    800c8a <vprintfmt+0x456>
  800c93:	e9 c1 fb ff ff       	jmp    800859 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800c98:	83 c4 3c             	add    $0x3c,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 28             	sub    $0x28,%esp
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800caf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cb3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	74 30                	je     800cf1 <vsnprintf+0x51>
  800cc1:	85 d2                	test   %edx,%edx
  800cc3:	7e 2c                	jle    800cf1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cda:	c7 04 24 ef 07 80 00 	movl   $0x8007ef,(%esp)
  800ce1:	e8 4e fb ff ff       	call   800834 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cef:	eb 05                	jmp    800cf6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cf1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cfe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d05:	8b 45 10             	mov    0x10(%ebp),%eax
  800d08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	e8 82 ff ff ff       	call   800ca0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2b:	eb 03                	jmp    800d30 <strlen+0x10>
		n++;
  800d2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d34:	75 f7                	jne    800d2d <strlen+0xd>
		n++;
	return n;
}
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	eb 03                	jmp    800d4b <strnlen+0x13>
		n++;
  800d48:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4b:	39 d0                	cmp    %edx,%eax
  800d4d:	74 06                	je     800d55 <strnlen+0x1d>
  800d4f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d53:	75 f3                	jne    800d48 <strnlen+0x10>
		n++;
	return n;
}
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	53                   	push   %ebx
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	83 c2 01             	add    $0x1,%edx
  800d66:	83 c1 01             	add    $0x1,%ecx
  800d69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d70:	84 db                	test   %bl,%bl
  800d72:	75 ef                	jne    800d63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d81:	89 1c 24             	mov    %ebx,(%esp)
  800d84:	e8 97 ff ff ff       	call   800d20 <strlen>
	strcpy(dst + len, src);
  800d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d90:	01 d8                	add    %ebx,%eax
  800d92:	89 04 24             	mov    %eax,(%esp)
  800d95:	e8 bd ff ff ff       	call   800d57 <strcpy>
	return dst;
}
  800d9a:	89 d8                	mov    %ebx,%eax
  800d9c:	83 c4 08             	add    $0x8,%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	8b 75 08             	mov    0x8(%ebp),%esi
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	89 f3                	mov    %esi,%ebx
  800daf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db2:	89 f2                	mov    %esi,%edx
  800db4:	eb 0f                	jmp    800dc5 <strncpy+0x23>
		*dst++ = *src;
  800db6:	83 c2 01             	add    $0x1,%edx
  800db9:	0f b6 01             	movzbl (%ecx),%eax
  800dbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dbf:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc5:	39 da                	cmp    %ebx,%edx
  800dc7:	75 ed                	jne    800db6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dda:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de3:	85 c9                	test   %ecx,%ecx
  800de5:	75 0b                	jne    800df2 <strlcpy+0x23>
  800de7:	eb 1d                	jmp    800e06 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800de9:	83 c0 01             	add    $0x1,%eax
  800dec:	83 c2 01             	add    $0x1,%edx
  800def:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df2:	39 d8                	cmp    %ebx,%eax
  800df4:	74 0b                	je     800e01 <strlcpy+0x32>
  800df6:	0f b6 0a             	movzbl (%edx),%ecx
  800df9:	84 c9                	test   %cl,%cl
  800dfb:	75 ec                	jne    800de9 <strlcpy+0x1a>
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	eb 02                	jmp    800e03 <strlcpy+0x34>
  800e01:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800e03:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800e06:	29 f0                	sub    %esi,%eax
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e15:	eb 06                	jmp    800e1d <strcmp+0x11>
		p++, q++;
  800e17:	83 c1 01             	add    $0x1,%ecx
  800e1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e1d:	0f b6 01             	movzbl (%ecx),%eax
  800e20:	84 c0                	test   %al,%al
  800e22:	74 04                	je     800e28 <strcmp+0x1c>
  800e24:	3a 02                	cmp    (%edx),%al
  800e26:	74 ef                	je     800e17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e28:	0f b6 c0             	movzbl %al,%eax
  800e2b:	0f b6 12             	movzbl (%edx),%edx
  800e2e:	29 d0                	sub    %edx,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	53                   	push   %ebx
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e41:	eb 06                	jmp    800e49 <strncmp+0x17>
		n--, p++, q++;
  800e43:	83 c0 01             	add    $0x1,%eax
  800e46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e49:	39 d8                	cmp    %ebx,%eax
  800e4b:	74 15                	je     800e62 <strncmp+0x30>
  800e4d:	0f b6 08             	movzbl (%eax),%ecx
  800e50:	84 c9                	test   %cl,%cl
  800e52:	74 04                	je     800e58 <strncmp+0x26>
  800e54:	3a 0a                	cmp    (%edx),%cl
  800e56:	74 eb                	je     800e43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e58:	0f b6 00             	movzbl (%eax),%eax
  800e5b:	0f b6 12             	movzbl (%edx),%edx
  800e5e:	29 d0                	sub    %edx,%eax
  800e60:	eb 05                	jmp    800e67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e74:	eb 07                	jmp    800e7d <strchr+0x13>
		if (*s == c)
  800e76:	38 ca                	cmp    %cl,%dl
  800e78:	74 0f                	je     800e89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7a:	83 c0 01             	add    $0x1,%eax
  800e7d:	0f b6 10             	movzbl (%eax),%edx
  800e80:	84 d2                	test   %dl,%dl
  800e82:	75 f2                	jne    800e76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e95:	eb 07                	jmp    800e9e <strfind+0x13>
		if (*s == c)
  800e97:	38 ca                	cmp    %cl,%dl
  800e99:	74 0a                	je     800ea5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9b:	83 c0 01             	add    $0x1,%eax
  800e9e:	0f b6 10             	movzbl (%eax),%edx
  800ea1:	84 d2                	test   %dl,%dl
  800ea3:	75 f2                	jne    800e97 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb3:	85 c9                	test   %ecx,%ecx
  800eb5:	74 36                	je     800eed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eb7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ebd:	75 28                	jne    800ee7 <memset+0x40>
  800ebf:	f6 c1 03             	test   $0x3,%cl
  800ec2:	75 23                	jne    800ee7 <memset+0x40>
		c &= 0xFF;
  800ec4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ec8:	89 d3                	mov    %edx,%ebx
  800eca:	c1 e3 08             	shl    $0x8,%ebx
  800ecd:	89 d6                	mov    %edx,%esi
  800ecf:	c1 e6 18             	shl    $0x18,%esi
  800ed2:	89 d0                	mov    %edx,%eax
  800ed4:	c1 e0 10             	shl    $0x10,%eax
  800ed7:	09 f0                	or     %esi,%eax
  800ed9:	09 c2                	or     %eax,%edx
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800edf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ee2:	fc                   	cld    
  800ee3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee5:	eb 06                	jmp    800eed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	fc                   	cld    
  800eeb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eed:	89 f8                	mov    %edi,%eax
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f02:	39 c6                	cmp    %eax,%esi
  800f04:	73 35                	jae    800f3b <memmove+0x47>
  800f06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f09:	39 d0                	cmp    %edx,%eax
  800f0b:	73 2e                	jae    800f3b <memmove+0x47>
		s += n;
		d += n;
  800f0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f10:	89 d6                	mov    %edx,%esi
  800f12:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1a:	75 13                	jne    800f2f <memmove+0x3b>
  800f1c:	f6 c1 03             	test   $0x3,%cl
  800f1f:	75 0e                	jne    800f2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f21:	83 ef 04             	sub    $0x4,%edi
  800f24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f2a:	fd                   	std    
  800f2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2d:	eb 09                	jmp    800f38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f2f:	83 ef 01             	sub    $0x1,%edi
  800f32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f35:	fd                   	std    
  800f36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f38:	fc                   	cld    
  800f39:	eb 1d                	jmp    800f58 <memmove+0x64>
  800f3b:	89 f2                	mov    %esi,%edx
  800f3d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3f:	f6 c2 03             	test   $0x3,%dl
  800f42:	75 0f                	jne    800f53 <memmove+0x5f>
  800f44:	f6 c1 03             	test   $0x3,%cl
  800f47:	75 0a                	jne    800f53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f49:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f4c:	89 c7                	mov    %eax,%edi
  800f4e:	fc                   	cld    
  800f4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f51:	eb 05                	jmp    800f58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f53:	89 c7                	mov    %eax,%edi
  800f55:	fc                   	cld    
  800f56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f62:	8b 45 10             	mov    0x10(%ebp),%eax
  800f65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	89 04 24             	mov    %eax,(%esp)
  800f76:	e8 79 ff ff ff       	call   800ef4 <memmove>
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	89 d6                	mov    %edx,%esi
  800f8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8d:	eb 1a                	jmp    800fa9 <memcmp+0x2c>
		if (*s1 != *s2)
  800f8f:	0f b6 02             	movzbl (%edx),%eax
  800f92:	0f b6 19             	movzbl (%ecx),%ebx
  800f95:	38 d8                	cmp    %bl,%al
  800f97:	74 0a                	je     800fa3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f99:	0f b6 c0             	movzbl %al,%eax
  800f9c:	0f b6 db             	movzbl %bl,%ebx
  800f9f:	29 d8                	sub    %ebx,%eax
  800fa1:	eb 0f                	jmp    800fb2 <memcmp+0x35>
		s1++, s2++;
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa9:	39 f2                	cmp    %esi,%edx
  800fab:	75 e2                	jne    800f8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fbf:	89 c2                	mov    %eax,%edx
  800fc1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fc4:	eb 07                	jmp    800fcd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc6:	38 08                	cmp    %cl,(%eax)
  800fc8:	74 07                	je     800fd1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fca:	83 c0 01             	add    $0x1,%eax
  800fcd:	39 d0                	cmp    %edx,%eax
  800fcf:	72 f5                	jb     800fc6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdf:	eb 03                	jmp    800fe4 <strtol+0x11>
		s++;
  800fe1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fe4:	0f b6 0a             	movzbl (%edx),%ecx
  800fe7:	80 f9 09             	cmp    $0x9,%cl
  800fea:	74 f5                	je     800fe1 <strtol+0xe>
  800fec:	80 f9 20             	cmp    $0x20,%cl
  800fef:	74 f0                	je     800fe1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ff1:	80 f9 2b             	cmp    $0x2b,%cl
  800ff4:	75 0a                	jne    801000 <strtol+0x2d>
		s++;
  800ff6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ffe:	eb 11                	jmp    801011 <strtol+0x3e>
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801005:	80 f9 2d             	cmp    $0x2d,%cl
  801008:	75 07                	jne    801011 <strtol+0x3e>
		s++, neg = 1;
  80100a:	8d 52 01             	lea    0x1(%edx),%edx
  80100d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801011:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801016:	75 15                	jne    80102d <strtol+0x5a>
  801018:	80 3a 30             	cmpb   $0x30,(%edx)
  80101b:	75 10                	jne    80102d <strtol+0x5a>
  80101d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801021:	75 0a                	jne    80102d <strtol+0x5a>
		s += 2, base = 16;
  801023:	83 c2 02             	add    $0x2,%edx
  801026:	b8 10 00 00 00       	mov    $0x10,%eax
  80102b:	eb 10                	jmp    80103d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80102d:	85 c0                	test   %eax,%eax
  80102f:	75 0c                	jne    80103d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801031:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801033:	80 3a 30             	cmpb   $0x30,(%edx)
  801036:	75 05                	jne    80103d <strtol+0x6a>
		s++, base = 8;
  801038:	83 c2 01             	add    $0x1,%edx
  80103b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801042:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801045:	0f b6 0a             	movzbl (%edx),%ecx
  801048:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	3c 09                	cmp    $0x9,%al
  80104f:	77 08                	ja     801059 <strtol+0x86>
			dig = *s - '0';
  801051:	0f be c9             	movsbl %cl,%ecx
  801054:	83 e9 30             	sub    $0x30,%ecx
  801057:	eb 20                	jmp    801079 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801059:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80105c:	89 f0                	mov    %esi,%eax
  80105e:	3c 19                	cmp    $0x19,%al
  801060:	77 08                	ja     80106a <strtol+0x97>
			dig = *s - 'a' + 10;
  801062:	0f be c9             	movsbl %cl,%ecx
  801065:	83 e9 57             	sub    $0x57,%ecx
  801068:	eb 0f                	jmp    801079 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80106a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80106d:	89 f0                	mov    %esi,%eax
  80106f:	3c 19                	cmp    $0x19,%al
  801071:	77 16                	ja     801089 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801073:	0f be c9             	movsbl %cl,%ecx
  801076:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801079:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80107c:	7d 0f                	jge    80108d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80107e:	83 c2 01             	add    $0x1,%edx
  801081:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801085:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801087:	eb bc                	jmp    801045 <strtol+0x72>
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	eb 02                	jmp    80108f <strtol+0xbc>
  80108d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80108f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801093:	74 05                	je     80109a <strtol+0xc7>
		*endptr = (char *) s;
  801095:	8b 75 0c             	mov    0xc(%ebp),%esi
  801098:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80109a:	f7 d8                	neg    %eax
  80109c:	85 ff                	test   %edi,%edi
  80109e:	0f 44 c3             	cmove  %ebx,%eax
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b7:	89 c3                	mov    %eax,%ebx
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	89 c6                	mov    %eax,%esi
  8010bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d4:	89 d1                	mov    %edx,%ecx
  8010d6:	89 d3                	mov    %edx,%ebx
  8010d8:	89 d7                	mov    %edx,%edi
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f9:	89 cb                	mov    %ecx,%ebx
  8010fb:	89 cf                	mov    %ecx,%edi
  8010fd:	89 ce                	mov    %ecx,%esi
  8010ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801101:	85 c0                	test   %eax,%eax
  801103:	7e 28                	jle    80112d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801105:	89 44 24 10          	mov    %eax,0x10(%esp)
  801109:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801110:	00 
  801111:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  801128:	e8 b1 f4 ff ff       	call   8005de <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80112d:	83 c4 2c             	add    $0x2c,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	b8 02 00 00 00       	mov    $0x2,%eax
  801145:	89 d1                	mov    %edx,%ecx
  801147:	89 d3                	mov    %edx,%ebx
  801149:	89 d7                	mov    %edx,%edi
  80114b:	89 d6                	mov    %edx,%esi
  80114d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <sys_yield>:

void
sys_yield(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115a:	ba 00 00 00 00       	mov    $0x0,%edx
  80115f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801164:	89 d1                	mov    %edx,%ecx
  801166:	89 d3                	mov    %edx,%ebx
  801168:	89 d7                	mov    %edx,%edi
  80116a:	89 d6                	mov    %edx,%esi
  80116c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117c:	be 00 00 00 00       	mov    $0x0,%esi
  801181:	b8 04 00 00 00       	mov    $0x4,%eax
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118f:	89 f7                	mov    %esi,%edi
  801191:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	7e 28                	jle    8011bf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801197:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  8011ba:	e8 1f f4 ff ff       	call   8005de <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011bf:	83 c4 2c             	add    $0x2c,%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	7e 28                	jle    801212 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  80120d:	e8 cc f3 ff ff       	call   8005de <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801212:	83 c4 2c             	add    $0x2c,%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801223:	bb 00 00 00 00       	mov    $0x0,%ebx
  801228:	b8 06 00 00 00       	mov    $0x6,%eax
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	8b 55 08             	mov    0x8(%ebp),%edx
  801233:	89 df                	mov    %ebx,%edi
  801235:	89 de                	mov    %ebx,%esi
  801237:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	7e 28                	jle    801265 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801241:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801248:	00 
  801249:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  801250:	00 
  801251:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801258:	00 
  801259:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  801260:	e8 79 f3 ff ff       	call   8005de <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801265:	83 c4 2c             	add    $0x2c,%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	57                   	push   %edi
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
  801273:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127b:	b8 08 00 00 00       	mov    $0x8,%eax
  801280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801283:	8b 55 08             	mov    0x8(%ebp),%edx
  801286:	89 df                	mov    %ebx,%edi
  801288:	89 de                	mov    %ebx,%esi
  80128a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80128c:	85 c0                	test   %eax,%eax
  80128e:	7e 28                	jle    8012b8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801290:	89 44 24 10          	mov    %eax,0x10(%esp)
  801294:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80129b:	00 
  80129c:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ab:	00 
  8012ac:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  8012b3:	e8 26 f3 ff ff       	call   8005de <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012b8:	83 c4 2c             	add    $0x2c,%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5f                   	pop    %edi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8012d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d9:	89 df                	mov    %ebx,%edi
  8012db:	89 de                	mov    %ebx,%esi
  8012dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	7e 28                	jle    80130b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012e7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  8012f6:	00 
  8012f7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012fe:	00 
  8012ff:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  801306:	e8 d3 f2 ff ff       	call   8005de <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80130b:	83 c4 2c             	add    $0x2c,%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	57                   	push   %edi
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801319:	be 00 00 00 00       	mov    $0x0,%esi
  80131e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801326:	8b 55 08             	mov    0x8(%ebp),%edx
  801329:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80132c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80132f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80133f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801344:	b8 0c 00 00 00       	mov    $0xc,%eax
  801349:	8b 55 08             	mov    0x8(%ebp),%edx
  80134c:	89 cb                	mov    %ecx,%ebx
  80134e:	89 cf                	mov    %ecx,%edi
  801350:	89 ce                	mov    %ecx,%esi
  801352:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801354:	85 c0                	test   %eax,%eax
  801356:	7e 28                	jle    801380 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801363:	00 
  801364:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  80136b:	00 
  80136c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801373:	00 
  801374:	c7 04 24 05 1a 80 00 	movl   $0x801a05,(%esp)
  80137b:	e8 5e f2 ff ff       	call   8005de <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801380:	83 c4 2c             	add    $0x2c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80138e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801395:	75 1c                	jne    8013b3 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801397:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  80139e:	00 
  80139f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8013a6:	00 
  8013a7:	c7 04 24 38 1a 80 00 	movl   $0x801a38,(%esp)
  8013ae:	e8 2b f2 ff ff       	call   8005de <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    
  8013bd:	66 90                	xchg   %ax,%ax
  8013bf:	90                   	nop

008013c0 <__udivdi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013dc:	89 ea                	mov    %ebp,%edx
  8013de:	89 0c 24             	mov    %ecx,(%esp)
  8013e1:	75 2d                	jne    801410 <__udivdi3+0x50>
  8013e3:	39 e9                	cmp    %ebp,%ecx
  8013e5:	77 61                	ja     801448 <__udivdi3+0x88>
  8013e7:	85 c9                	test   %ecx,%ecx
  8013e9:	89 ce                	mov    %ecx,%esi
  8013eb:	75 0b                	jne    8013f8 <__udivdi3+0x38>
  8013ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f2:	31 d2                	xor    %edx,%edx
  8013f4:	f7 f1                	div    %ecx
  8013f6:	89 c6                	mov    %eax,%esi
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	89 e8                	mov    %ebp,%eax
  8013fc:	f7 f6                	div    %esi
  8013fe:	89 c5                	mov    %eax,%ebp
  801400:	89 f8                	mov    %edi,%eax
  801402:	f7 f6                	div    %esi
  801404:	89 ea                	mov    %ebp,%edx
  801406:	83 c4 0c             	add    $0xc,%esp
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	39 e8                	cmp    %ebp,%eax
  801412:	77 24                	ja     801438 <__udivdi3+0x78>
  801414:	0f bd e8             	bsr    %eax,%ebp
  801417:	83 f5 1f             	xor    $0x1f,%ebp
  80141a:	75 3c                	jne    801458 <__udivdi3+0x98>
  80141c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801420:	39 34 24             	cmp    %esi,(%esp)
  801423:	0f 86 9f 00 00 00    	jbe    8014c8 <__udivdi3+0x108>
  801429:	39 d0                	cmp    %edx,%eax
  80142b:	0f 82 97 00 00 00    	jb     8014c8 <__udivdi3+0x108>
  801431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	31 c0                	xor    %eax,%eax
  80143c:	83 c4 0c             	add    $0xc,%esp
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
  801443:	90                   	nop
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	89 f8                	mov    %edi,%eax
  80144a:	f7 f1                	div    %ecx
  80144c:	31 d2                	xor    %edx,%edx
  80144e:	83 c4 0c             	add    $0xc,%esp
  801451:	5e                   	pop    %esi
  801452:	5f                   	pop    %edi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    
  801455:	8d 76 00             	lea    0x0(%esi),%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	8b 3c 24             	mov    (%esp),%edi
  80145d:	d3 e0                	shl    %cl,%eax
  80145f:	89 c6                	mov    %eax,%esi
  801461:	b8 20 00 00 00       	mov    $0x20,%eax
  801466:	29 e8                	sub    %ebp,%eax
  801468:	89 c1                	mov    %eax,%ecx
  80146a:	d3 ef                	shr    %cl,%edi
  80146c:	89 e9                	mov    %ebp,%ecx
  80146e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801472:	8b 3c 24             	mov    (%esp),%edi
  801475:	09 74 24 08          	or     %esi,0x8(%esp)
  801479:	89 d6                	mov    %edx,%esi
  80147b:	d3 e7                	shl    %cl,%edi
  80147d:	89 c1                	mov    %eax,%ecx
  80147f:	89 3c 24             	mov    %edi,(%esp)
  801482:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801486:	d3 ee                	shr    %cl,%esi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	d3 e2                	shl    %cl,%edx
  80148c:	89 c1                	mov    %eax,%ecx
  80148e:	d3 ef                	shr    %cl,%edi
  801490:	09 d7                	or     %edx,%edi
  801492:	89 f2                	mov    %esi,%edx
  801494:	89 f8                	mov    %edi,%eax
  801496:	f7 74 24 08          	divl   0x8(%esp)
  80149a:	89 d6                	mov    %edx,%esi
  80149c:	89 c7                	mov    %eax,%edi
  80149e:	f7 24 24             	mull   (%esp)
  8014a1:	39 d6                	cmp    %edx,%esi
  8014a3:	89 14 24             	mov    %edx,(%esp)
  8014a6:	72 30                	jb     8014d8 <__udivdi3+0x118>
  8014a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014ac:	89 e9                	mov    %ebp,%ecx
  8014ae:	d3 e2                	shl    %cl,%edx
  8014b0:	39 c2                	cmp    %eax,%edx
  8014b2:	73 05                	jae    8014b9 <__udivdi3+0xf9>
  8014b4:	3b 34 24             	cmp    (%esp),%esi
  8014b7:	74 1f                	je     8014d8 <__udivdi3+0x118>
  8014b9:	89 f8                	mov    %edi,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	e9 7a ff ff ff       	jmp    80143c <__udivdi3+0x7c>
  8014c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014c8:	31 d2                	xor    %edx,%edx
  8014ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cf:	e9 68 ff ff ff       	jmp    80143c <__udivdi3+0x7c>
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	83 c4 0c             	add    $0xc,%esp
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    
  8014e4:	66 90                	xchg   %ax,%ax
  8014e6:	66 90                	xchg   %ax,%ax
  8014e8:	66 90                	xchg   %ax,%ax
  8014ea:	66 90                	xchg   %ax,%ax
  8014ec:	66 90                	xchg   %ax,%ax
  8014ee:	66 90                	xchg   %ax,%ax

008014f0 <__umoddi3>:
  8014f0:	55                   	push   %ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	83 ec 14             	sub    $0x14,%esp
  8014f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801502:	89 c7                	mov    %eax,%edi
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	8b 44 24 30          	mov    0x30(%esp),%eax
  80150c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801510:	89 34 24             	mov    %esi,(%esp)
  801513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801517:	85 c0                	test   %eax,%eax
  801519:	89 c2                	mov    %eax,%edx
  80151b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80151f:	75 17                	jne    801538 <__umoddi3+0x48>
  801521:	39 fe                	cmp    %edi,%esi
  801523:	76 4b                	jbe    801570 <__umoddi3+0x80>
  801525:	89 c8                	mov    %ecx,%eax
  801527:	89 fa                	mov    %edi,%edx
  801529:	f7 f6                	div    %esi
  80152b:	89 d0                	mov    %edx,%eax
  80152d:	31 d2                	xor    %edx,%edx
  80152f:	83 c4 14             	add    $0x14,%esp
  801532:	5e                   	pop    %esi
  801533:	5f                   	pop    %edi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    
  801536:	66 90                	xchg   %ax,%ax
  801538:	39 f8                	cmp    %edi,%eax
  80153a:	77 54                	ja     801590 <__umoddi3+0xa0>
  80153c:	0f bd e8             	bsr    %eax,%ebp
  80153f:	83 f5 1f             	xor    $0x1f,%ebp
  801542:	75 5c                	jne    8015a0 <__umoddi3+0xb0>
  801544:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801548:	39 3c 24             	cmp    %edi,(%esp)
  80154b:	0f 87 e7 00 00 00    	ja     801638 <__umoddi3+0x148>
  801551:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801555:	29 f1                	sub    %esi,%ecx
  801557:	19 c7                	sbb    %eax,%edi
  801559:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801561:	8b 44 24 08          	mov    0x8(%esp),%eax
  801565:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801569:	83 c4 14             	add    $0x14,%esp
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    
  801570:	85 f6                	test   %esi,%esi
  801572:	89 f5                	mov    %esi,%ebp
  801574:	75 0b                	jne    801581 <__umoddi3+0x91>
  801576:	b8 01 00 00 00       	mov    $0x1,%eax
  80157b:	31 d2                	xor    %edx,%edx
  80157d:	f7 f6                	div    %esi
  80157f:	89 c5                	mov    %eax,%ebp
  801581:	8b 44 24 04          	mov    0x4(%esp),%eax
  801585:	31 d2                	xor    %edx,%edx
  801587:	f7 f5                	div    %ebp
  801589:	89 c8                	mov    %ecx,%eax
  80158b:	f7 f5                	div    %ebp
  80158d:	eb 9c                	jmp    80152b <__umoddi3+0x3b>
  80158f:	90                   	nop
  801590:	89 c8                	mov    %ecx,%eax
  801592:	89 fa                	mov    %edi,%edx
  801594:	83 c4 14             	add    $0x14,%esp
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
  80159b:	90                   	nop
  80159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	8b 04 24             	mov    (%esp),%eax
  8015a3:	be 20 00 00 00       	mov    $0x20,%esi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	29 ee                	sub    %ebp,%esi
  8015ac:	d3 e2                	shl    %cl,%edx
  8015ae:	89 f1                	mov    %esi,%ecx
  8015b0:	d3 e8                	shr    %cl,%eax
  8015b2:	89 e9                	mov    %ebp,%ecx
  8015b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b8:	8b 04 24             	mov    (%esp),%eax
  8015bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8015bf:	89 fa                	mov    %edi,%edx
  8015c1:	d3 e0                	shl    %cl,%eax
  8015c3:	89 f1                	mov    %esi,%ecx
  8015c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015cd:	d3 ea                	shr    %cl,%edx
  8015cf:	89 e9                	mov    %ebp,%ecx
  8015d1:	d3 e7                	shl    %cl,%edi
  8015d3:	89 f1                	mov    %esi,%ecx
  8015d5:	d3 e8                	shr    %cl,%eax
  8015d7:	89 e9                	mov    %ebp,%ecx
  8015d9:	09 f8                	or     %edi,%eax
  8015db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015df:	f7 74 24 04          	divl   0x4(%esp)
  8015e3:	d3 e7                	shl    %cl,%edi
  8015e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015e9:	89 d7                	mov    %edx,%edi
  8015eb:	f7 64 24 08          	mull   0x8(%esp)
  8015ef:	39 d7                	cmp    %edx,%edi
  8015f1:	89 c1                	mov    %eax,%ecx
  8015f3:	89 14 24             	mov    %edx,(%esp)
  8015f6:	72 2c                	jb     801624 <__umoddi3+0x134>
  8015f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015fc:	72 22                	jb     801620 <__umoddi3+0x130>
  8015fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801602:	29 c8                	sub    %ecx,%eax
  801604:	19 d7                	sbb    %edx,%edi
  801606:	89 e9                	mov    %ebp,%ecx
  801608:	89 fa                	mov    %edi,%edx
  80160a:	d3 e8                	shr    %cl,%eax
  80160c:	89 f1                	mov    %esi,%ecx
  80160e:	d3 e2                	shl    %cl,%edx
  801610:	89 e9                	mov    %ebp,%ecx
  801612:	d3 ef                	shr    %cl,%edi
  801614:	09 d0                	or     %edx,%eax
  801616:	89 fa                	mov    %edi,%edx
  801618:	83 c4 14             	add    $0x14,%esp
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    
  80161f:	90                   	nop
  801620:	39 d7                	cmp    %edx,%edi
  801622:	75 da                	jne    8015fe <__umoddi3+0x10e>
  801624:	8b 14 24             	mov    (%esp),%edx
  801627:	89 c1                	mov    %eax,%ecx
  801629:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80162d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801631:	eb cb                	jmp    8015fe <__umoddi3+0x10e>
  801633:	90                   	nop
  801634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801638:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80163c:	0f 82 0f ff ff ff    	jb     801551 <__umoddi3+0x61>
  801642:	e9 1a ff ff ff       	jmp    801561 <__umoddi3+0x71>
