
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
  80002c:	e8 2f 05 00 00       	call   800560 <libmain>
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
  80004c:	c7 44 24 04 b1 15 80 	movl   $0x8015b1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 80 15 80 00 	movl   $0x801580,(%esp)
  80005b:	e8 60 06 00 00       	call   8006c0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 90 15 80 	movl   $0x801590,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  80007b:	e8 40 06 00 00       	call   8006c0 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  80008d:	e8 2e 06 00 00       	call   8006c0 <cprintf>

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
  800099:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  8000a0:	e8 1b 06 00 00       	call   8006c0 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 b2 15 80 	movl   $0x8015b2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8000c7:	e8 f4 05 00 00       	call   8006c0 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  8000db:	e8 e0 05 00 00       	call   8006c0 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  8000e9:	e8 d2 05 00 00       	call   8006c0 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 b6 15 80 	movl   $0x8015b6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  800110:	e8 ab 05 00 00       	call   8006c0 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800124:	e8 97 05 00 00       	call   8006c0 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800132:	e8 89 05 00 00       	call   8006c0 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 ba 15 80 	movl   $0x8015ba,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  800159:	e8 62 05 00 00       	call   8006c0 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  80016d:	e8 4e 05 00 00       	call   8006c0 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  80017b:	e8 40 05 00 00       	call   8006c0 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 be 15 80 	movl   $0x8015be,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8001a2:	e8 19 05 00 00       	call   8006c0 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  8001b6:	e8 05 05 00 00       	call   8006c0 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  8001c4:	e8 f7 04 00 00       	call   8006c0 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 c2 15 80 	movl   $0x8015c2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8001eb:	e8 d0 04 00 00       	call   8006c0 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  8001ff:	e8 bc 04 00 00       	call   8006c0 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  80020d:	e8 ae 04 00 00       	call   8006c0 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 c6 15 80 	movl   $0x8015c6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  800234:	e8 87 04 00 00       	call   8006c0 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800248:	e8 73 04 00 00       	call   8006c0 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800256:	e8 65 04 00 00       	call   8006c0 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 ca 15 80 	movl   $0x8015ca,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  80027d:	e8 3e 04 00 00       	call   8006c0 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800291:	e8 2a 04 00 00       	call   8006c0 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  80029f:	e8 1c 04 00 00       	call   8006c0 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ce 15 80 	movl   $0x8015ce,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8002c6:	e8 f5 03 00 00       	call   8006c0 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  8002da:	e8 e1 03 00 00       	call   8006c0 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  8002e8:	e8 d3 03 00 00       	call   8006c0 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 d5 15 80 	movl   $0x8015d5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  80030f:	e8 ac 03 00 00       	call   8006c0 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800323:	e8 98 03 00 00       	call   8006c0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 d9 15 80 00 	movl   $0x8015d9,(%esp)
  800336:	e8 85 03 00 00       	call   8006c0 <cprintf>
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
  800341:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800348:	e8 73 03 00 00       	call   8006c0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 d9 15 80 00 	movl   $0x8015d9,(%esp)
  80035b:	e8 60 03 00 00       	call   8006c0 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800369:	e8 52 03 00 00       	call   8006c0 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800377:	e8 44 03 00 00       	call   8006c0 <cprintf>
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
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 40 16 80 	movl   $0x801640,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  8003bb:	e8 08 02 00 00       	call   8005c8 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf a0 20 80 00       	mov    $0x8020a0,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  8003dd:	8b 40 30             	mov    0x30(%eax),%eax
  8003e0:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003e5:	c7 44 24 04 ff 15 80 	movl   $0x8015ff,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 0d 16 80 00 	movl   $0x80160d,(%esp)
  8003f4:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003f9:	ba f8 15 80 00       	mov    $0x8015f8,%edx
  8003fe:	b8 20 20 80 00       	mov    $0x802020,%eax
  800403:	e8 2c fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800408:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80040f:	00 
  800410:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800417:	00 
  800418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80041f:	e8 39 0c 00 00       	call   80105d <sys_page_alloc>
  800424:	85 c0                	test   %eax,%eax
  800426:	79 20                	jns    800448 <pgfault+0xc4>
		panic("sys_page_alloc: %e", r);
  800428:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042c:	c7 44 24 08 14 16 80 	movl   $0x801614,0x8(%esp)
  800433:	00 
  800434:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80043b:	00 
  80043c:	c7 04 24 e7 15 80 00 	movl   $0x8015e7,(%esp)
  800443:	e8 80 01 00 00       	call   8005c8 <_panic>
}
  800448:	83 c4 20             	add    $0x20,%esp
  80044b:	5e                   	pop    %esi
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <umain>:

void
umain(int argc, char **argv)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800455:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  80045c:	e8 13 0e 00 00       	call   801274 <set_pgfault_handler>

	__asm __volatile(
  800461:	50                   	push   %eax
  800462:	9c                   	pushf  
  800463:	58                   	pop    %eax
  800464:	0d d5 08 00 00       	or     $0x8d5,%eax
  800469:	50                   	push   %eax
  80046a:	9d                   	popf   
  80046b:	a3 44 20 80 00       	mov    %eax,0x802044
  800470:	8d 05 ab 04 80 00    	lea    0x8004ab,%eax
  800476:	a3 40 20 80 00       	mov    %eax,0x802040
  80047b:	58                   	pop    %eax
  80047c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800482:	89 35 24 20 80 00    	mov    %esi,0x802024
  800488:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80048e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800494:	89 15 34 20 80 00    	mov    %edx,0x802034
  80049a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004a0:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004a5:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004ab:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b2:	00 00 00 
  8004b5:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004bb:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004c1:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004c7:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  8004cd:	89 15 74 20 80 00    	mov    %edx,0x802074
  8004d3:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  8004d9:	a3 7c 20 80 00       	mov    %eax,0x80207c
  8004de:	89 25 88 20 80 00    	mov    %esp,0x802088
  8004e4:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8004ea:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004f0:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004f6:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8004fc:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800502:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  800508:	a1 3c 20 80 00       	mov    0x80203c,%eax
  80050d:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800513:	50                   	push   %eax
  800514:	9c                   	pushf  
  800515:	58                   	pop    %eax
  800516:	a3 84 20 80 00       	mov    %eax,0x802084
  80051b:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80051c:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800523:	74 0c                	je     800531 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800525:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  80052c:	e8 8f 01 00 00       	call   8006c0 <cprintf>
	after.eip = before.eip;
  800531:	a1 40 20 80 00       	mov    0x802040,%eax
  800536:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  80053b:	c7 44 24 04 27 16 80 	movl   $0x801627,0x4(%esp)
  800542:	00 
  800543:	c7 04 24 38 16 80 00 	movl   $0x801638,(%esp)
  80054a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80054f:	ba f8 15 80 00       	mov    $0x8015f8,%edx
  800554:	b8 20 20 80 00       	mov    $0x802020,%eax
  800559:	e8 d6 fa ff ff       	call   800034 <check_regs>
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 10             	sub    $0x10,%esp
  800568:	8b 75 08             	mov    0x8(%ebp),%esi
  80056b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  80056e:	e8 ac 0a 00 00       	call   80101f <sys_getenvid>
  800573:	25 ff 03 00 00       	and    $0x3ff,%eax
  800578:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80057f:	c1 e0 07             	shl    $0x7,%eax
  800582:	29 d0                	sub    %edx,%eax
  800584:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800589:	a3 cc 20 80 00       	mov    %eax,0x8020cc

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80058e:	85 f6                	test   %esi,%esi
  800590:	7e 07                	jle    800599 <libmain+0x39>
		binaryname = argv[0];
  800592:	8b 03                	mov    (%ebx),%eax
  800594:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800599:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059d:	89 34 24             	mov    %esi,(%esp)
  8005a0:	e8 aa fe ff ff       	call   80044f <umain>

	// exit gracefully
	exit();
  8005a5:	e8 0a 00 00 00       	call   8005b4 <exit>
}
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	5b                   	pop    %ebx
  8005ae:	5e                   	pop    %esi
  8005af:	5d                   	pop    %ebp
  8005b0:	c3                   	ret    
  8005b1:	00 00                	add    %al,(%eax)
	...

008005b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005c1:	e8 07 0a 00 00       	call   800fcd <sys_env_destroy>
}
  8005c6:	c9                   	leave  
  8005c7:	c3                   	ret    

008005c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005d3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005d9:	e8 41 0a 00 00       	call   80101f <sys_getenvid>
  8005de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f4:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  8005fb:	e8 c0 00 00 00       	call   8006c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800600:	89 74 24 04          	mov    %esi,0x4(%esp)
  800604:	8b 45 10             	mov    0x10(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	e8 50 00 00 00       	call   80065f <vcprintf>
	cprintf("\n");
  80060f:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  800616:	e8 a5 00 00 00       	call   8006c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80061b:	cc                   	int3   
  80061c:	eb fd                	jmp    80061b <_panic+0x53>
	...

00800620 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800620:	55                   	push   %ebp
  800621:	89 e5                	mov    %esp,%ebp
  800623:	53                   	push   %ebx
  800624:	83 ec 14             	sub    $0x14,%esp
  800627:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80062a:	8b 03                	mov    (%ebx),%eax
  80062c:	8b 55 08             	mov    0x8(%ebp),%edx
  80062f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800633:	40                   	inc    %eax
  800634:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800636:	3d ff 00 00 00       	cmp    $0xff,%eax
  80063b:	75 19                	jne    800656 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80063d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800644:	00 
  800645:	8d 43 08             	lea    0x8(%ebx),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	e8 40 09 00 00       	call   800f90 <sys_cputs>
		b->idx = 0;
  800650:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800656:	ff 43 04             	incl   0x4(%ebx)
}
  800659:	83 c4 14             	add    $0x14,%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5d                   	pop    %ebp
  80065e:	c3                   	ret    

0080065f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800668:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80066f:	00 00 00 
	b.cnt = 0;
  800672:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800679:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80067c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	c7 04 24 20 06 80 00 	movl   $0x800620,(%esp)
  80069b:	e8 82 01 00 00       	call   800822 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 d8 08 00 00       	call   800f90 <sys_cputs>

	return b.cnt;
}
  8006b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	89 04 24             	mov    %eax,(%esp)
  8006d3:	e8 87 ff ff ff       	call   80065f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    
	...

008006dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	57                   	push   %edi
  8006e0:	56                   	push   %esi
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 3c             	sub    $0x3c,%esp
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e8:	89 d7                	mov    %edx,%edi
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	75 08                	jne    800708 <printnum+0x2c>
  800700:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800703:	39 45 10             	cmp    %eax,0x10(%ebp)
  800706:	77 57                	ja     80075f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800708:	89 74 24 10          	mov    %esi,0x10(%esp)
  80070c:	4b                   	dec    %ebx
  80070d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800711:	8b 45 10             	mov    0x10(%ebp),%eax
  800714:	89 44 24 08          	mov    %eax,0x8(%esp)
  800718:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80071c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800720:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800727:	00 
  800728:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	e8 ee 0b 00 00       	call   801328 <__udivdi3>
  80073a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80073e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800742:	89 04 24             	mov    %eax,(%esp)
  800745:	89 54 24 04          	mov    %edx,0x4(%esp)
  800749:	89 fa                	mov    %edi,%edx
  80074b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80074e:	e8 89 ff ff ff       	call   8006dc <printnum>
  800753:	eb 0f                	jmp    800764 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800755:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800759:	89 34 24             	mov    %esi,(%esp)
  80075c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075f:	4b                   	dec    %ebx
  800760:	85 db                	test   %ebx,%ebx
  800762:	7f f1                	jg     800755 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800764:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800768:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80076c:	8b 45 10             	mov    0x10(%ebp),%eax
  80076f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800773:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80077a:	00 
  80077b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	e8 bb 0c 00 00       	call   801448 <__umoddi3>
  80078d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800791:	0f be 80 c3 16 80 00 	movsbl 0x8016c3(%eax),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80079e:	83 c4 3c             	add    $0x3c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007a9:	83 fa 01             	cmp    $0x1,%edx
  8007ac:	7e 0e                	jle    8007bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007b3:	89 08                	mov    %ecx,(%eax)
  8007b5:	8b 02                	mov    (%edx),%eax
  8007b7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ba:	eb 22                	jmp    8007de <getuint+0x38>
	else if (lflag)
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 10                	je     8007d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c5:	89 08                	mov    %ecx,(%eax)
  8007c7:	8b 02                	mov    (%edx),%eax
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ce:	eb 0e                	jmp    8007de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ee:	73 08                	jae    8007f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8007f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f3:	88 0a                	mov    %cl,(%edx)
  8007f5:	42                   	inc    %edx
  8007f6:	89 10                	mov    %edx,(%eax)
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	e8 02 00 00 00       	call   800822 <vprintfmt>
	va_end(ap);
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	57                   	push   %edi
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	83 ec 4c             	sub    $0x4c,%esp
  80082b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082e:	8b 75 10             	mov    0x10(%ebp),%esi
  800831:	eb 12                	jmp    800845 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800833:	85 c0                	test   %eax,%eax
  800835:	0f 84 6b 03 00 00    	je     800ba6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80083b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800845:	0f b6 06             	movzbl (%esi),%eax
  800848:	46                   	inc    %esi
  800849:	83 f8 25             	cmp    $0x25,%eax
  80084c:	75 e5                	jne    800833 <vprintfmt+0x11>
  80084e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800852:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800859:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80085e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086a:	eb 26                	jmp    800892 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80086f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800873:	eb 1d                	jmp    800892 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800875:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800878:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80087c:	eb 14                	jmp    800892 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800881:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800888:	eb 08                	jmp    800892 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80088a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80088d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	0f b6 06             	movzbl (%esi),%eax
  800895:	8d 56 01             	lea    0x1(%esi),%edx
  800898:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80089b:	8a 16                	mov    (%esi),%dl
  80089d:	83 ea 23             	sub    $0x23,%edx
  8008a0:	80 fa 55             	cmp    $0x55,%dl
  8008a3:	0f 87 e1 02 00 00    	ja     800b8a <vprintfmt+0x368>
  8008a9:	0f b6 d2             	movzbl %dl,%edx
  8008ac:	ff 24 95 80 17 80 00 	jmp    *0x801780(,%edx,4)
  8008b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008c8:	83 fa 09             	cmp    $0x9,%edx
  8008cb:	77 2a                	ja     8008f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008ce:	eb eb                	jmp    8008bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8d 50 04             	lea    0x4(%eax),%edx
  8008d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008de:	eb 17                	jmp    8008f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e4:	78 98                	js     80087e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008e9:	eb a7                	jmp    800892 <vprintfmt+0x70>
  8008eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008f5:	eb 9b                	jmp    800892 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fb:	79 95                	jns    800892 <vprintfmt+0x70>
  8008fd:	eb 8b                	jmp    80088a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800903:	eb 8d                	jmp    800892 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 04             	lea    0x4(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	8b 00                	mov    (%eax),%eax
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091d:	e9 23 ff ff ff       	jmp    800845 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 00                	mov    (%eax),%eax
  80092d:	85 c0                	test   %eax,%eax
  80092f:	79 02                	jns    800933 <vprintfmt+0x111>
  800931:	f7 d8                	neg    %eax
  800933:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800935:	83 f8 09             	cmp    $0x9,%eax
  800938:	7f 0b                	jg     800945 <vprintfmt+0x123>
  80093a:	8b 04 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%eax
  800941:	85 c0                	test   %eax,%eax
  800943:	75 23                	jne    800968 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800945:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800949:	c7 44 24 08 db 16 80 	movl   $0x8016db,0x8(%esp)
  800950:	00 
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	e8 9a fe ff ff       	call   8007fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800963:	e9 dd fe ff ff       	jmp    800845 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800968:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096c:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800973:	00 
  800974:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
  80097b:	89 14 24             	mov    %edx,(%esp)
  80097e:	e8 77 fe ff ff       	call   8007fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800986:	e9 ba fe ff ff       	jmp    800845 <vprintfmt+0x23>
  80098b:	89 f9                	mov    %edi,%ecx
  80098d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800990:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8d 50 04             	lea    0x4(%eax),%edx
  800999:	89 55 14             	mov    %edx,0x14(%ebp)
  80099c:	8b 30                	mov    (%eax),%esi
  80099e:	85 f6                	test   %esi,%esi
  8009a0:	75 05                	jne    8009a7 <vprintfmt+0x185>
				p = "(null)";
  8009a2:	be d4 16 80 00       	mov    $0x8016d4,%esi
			if (width > 0 && padc != '-')
  8009a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009ab:	0f 8e 84 00 00 00    	jle    800a35 <vprintfmt+0x213>
  8009b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009b5:	74 7e                	je     800a35 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009bb:	89 34 24             	mov    %esi,(%esp)
  8009be:	e8 8b 02 00 00       	call   800c4e <strnlen>
  8009c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009c6:	29 c2                	sub    %eax,%edx
  8009c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009d5:	89 de                	mov    %ebx,%esi
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009db:	eb 0b                	jmp    8009e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e1:	89 3c 24             	mov    %edi,(%esp)
  8009e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e7:	4b                   	dec    %ebx
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	7f f1                	jg     8009dd <vprintfmt+0x1bb>
  8009ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	79 05                	jns    800a00 <vprintfmt+0x1de>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a03:	29 c2                	sub    %eax,%edx
  800a05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a08:	eb 2b                	jmp    800a35 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a0a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a0e:	74 18                	je     800a28 <vprintfmt+0x206>
  800a10:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a13:	83 fa 5e             	cmp    $0x5e,%edx
  800a16:	76 10                	jbe    800a28 <vprintfmt+0x206>
					putch('?', putdat);
  800a18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a23:	ff 55 08             	call   *0x8(%ebp)
  800a26:	eb 0a                	jmp    800a32 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2c:	89 04 24             	mov    %eax,(%esp)
  800a2f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a32:	ff 4d e4             	decl   -0x1c(%ebp)
  800a35:	0f be 06             	movsbl (%esi),%eax
  800a38:	46                   	inc    %esi
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	74 21                	je     800a5e <vprintfmt+0x23c>
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	78 c9                	js     800a0a <vprintfmt+0x1e8>
  800a41:	4f                   	dec    %edi
  800a42:	79 c6                	jns    800a0a <vprintfmt+0x1e8>
  800a44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a47:	89 de                	mov    %ebx,%esi
  800a49:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a4c:	eb 18                	jmp    800a66 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a52:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a59:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a5b:	4b                   	dec    %ebx
  800a5c:	eb 08                	jmp    800a66 <vprintfmt+0x244>
  800a5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a61:	89 de                	mov    %ebx,%esi
  800a63:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	7f e4                	jg     800a4e <vprintfmt+0x22c>
  800a6a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a6d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a72:	e9 ce fd ff ff       	jmp    800845 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a77:	83 f9 01             	cmp    $0x1,%ecx
  800a7a:	7e 10                	jle    800a8c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7f:	8d 50 08             	lea    0x8(%eax),%edx
  800a82:	89 55 14             	mov    %edx,0x14(%ebp)
  800a85:	8b 30                	mov    (%eax),%esi
  800a87:	8b 78 04             	mov    0x4(%eax),%edi
  800a8a:	eb 26                	jmp    800ab2 <vprintfmt+0x290>
	else if (lflag)
  800a8c:	85 c9                	test   %ecx,%ecx
  800a8e:	74 12                	je     800aa2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 04             	lea    0x4(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)
  800a99:	8b 30                	mov    (%eax),%esi
  800a9b:	89 f7                	mov    %esi,%edi
  800a9d:	c1 ff 1f             	sar    $0x1f,%edi
  800aa0:	eb 10                	jmp    800ab2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	8b 30                	mov    (%eax),%esi
  800aad:	89 f7                	mov    %esi,%edi
  800aaf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ab2:	85 ff                	test   %edi,%edi
  800ab4:	78 0a                	js     800ac0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ab6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800abb:	e9 8c 00 00 00       	jmp    800b4c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ac0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800acb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ace:	f7 de                	neg    %esi
  800ad0:	83 d7 00             	adc    $0x0,%edi
  800ad3:	f7 df                	neg    %edi
			}
			base = 10;
  800ad5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ada:	eb 70                	jmp    800b4c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800adc:	89 ca                	mov    %ecx,%edx
  800ade:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae1:	e8 c0 fc ff ff       	call   8007a6 <getuint>
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	89 d7                	mov    %edx,%edi
			base = 10;
  800aea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800aef:	eb 5b                	jmp    800b4c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  800af1:	89 ca                	mov    %ecx,%edx
  800af3:	8d 45 14             	lea    0x14(%ebp),%eax
  800af6:	e8 ab fc ff ff       	call   8007a6 <getuint>
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	89 d7                	mov    %edx,%edi
                        base = 8;
  800aff:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  800b04:	eb 46                	jmp    800b4c <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  800b06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b0a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b11:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b18:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b1f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8d 50 04             	lea    0x4(%eax),%edx
  800b28:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b2b:	8b 30                	mov    (%eax),%esi
  800b2d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b32:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b37:	eb 13                	jmp    800b4c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b39:	89 ca                	mov    %ecx,%edx
  800b3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3e:	e8 63 fc ff ff       	call   8007a6 <getuint>
  800b43:	89 c6                	mov    %eax,%esi
  800b45:	89 d7                	mov    %edx,%edi
			base = 16;
  800b47:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b4c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b50:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b57:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5f:	89 34 24             	mov    %esi,(%esp)
  800b62:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b66:	89 da                	mov    %ebx,%edx
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	e8 6c fb ff ff       	call   8006dc <printnum>
			break;
  800b70:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b73:	e9 cd fc ff ff       	jmp    800845 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b7c:	89 04 24             	mov    %eax,(%esp)
  800b7f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b82:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b85:	e9 bb fc ff ff       	jmp    800845 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b95:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b98:	eb 01                	jmp    800b9b <vprintfmt+0x379>
  800b9a:	4e                   	dec    %esi
  800b9b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b9f:	75 f9                	jne    800b9a <vprintfmt+0x378>
  800ba1:	e9 9f fc ff ff       	jmp    800845 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ba6:	83 c4 4c             	add    $0x4c,%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 28             	sub    $0x28,%esp
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	74 30                	je     800bff <vsnprintf+0x51>
  800bcf:	85 d2                	test   %edx,%edx
  800bd1:	7e 33                	jle    800c06 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bda:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be8:	c7 04 24 e0 07 80 00 	movl   $0x8007e0,(%esp)
  800bef:	e8 2e fc ff ff       	call   800822 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfd:	eb 0c                	jmp    800c0b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c04:	eb 05                	jmp    800c0b <vsnprintf+0x5d>
  800c06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c13:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c16:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	89 04 24             	mov    %eax,(%esp)
  800c2e:	e8 7b ff ff ff       	call   800bae <vsnprintf>
	va_end(ap);

	return rc;
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    
  800c35:	00 00                	add    %al,(%eax)
	...

00800c38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c43:	eb 01                	jmp    800c46 <strlen+0xe>
		n++;
  800c45:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c4a:	75 f9                	jne    800c45 <strlen+0xd>
		n++;
	return n;
}
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c54:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	eb 01                	jmp    800c5f <strnlen+0x11>
		n++;
  800c5e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5f:	39 d0                	cmp    %edx,%eax
  800c61:	74 06                	je     800c69 <strnlen+0x1b>
  800c63:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c67:	75 f5                	jne    800c5e <strnlen+0x10>
		n++;
	return n;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c80:	42                   	inc    %edx
  800c81:	84 c9                	test   %cl,%cl
  800c83:	75 f5                	jne    800c7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c85:	5b                   	pop    %ebx
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 08             	sub    $0x8,%esp
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c92:	89 1c 24             	mov    %ebx,(%esp)
  800c95:	e8 9e ff ff ff       	call   800c38 <strlen>
	strcpy(dst + len, src);
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca1:	01 d8                	add    %ebx,%eax
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	e8 c0 ff ff ff       	call   800c6b <strcpy>
	return dst;
}
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	83 c4 08             	add    $0x8,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc6:	eb 0c                	jmp    800cd4 <strncpy+0x21>
		*dst++ = *src;
  800cc8:	8a 1a                	mov    (%edx),%bl
  800cca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ccd:	80 3a 01             	cmpb   $0x1,(%edx)
  800cd0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd3:	41                   	inc    %ecx
  800cd4:	39 f1                	cmp    %esi,%ecx
  800cd6:	75 f0                	jne    800cc8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cea:	85 d2                	test   %edx,%edx
  800cec:	75 0a                	jne    800cf8 <strlcpy+0x1c>
  800cee:	89 f0                	mov    %esi,%eax
  800cf0:	eb 1a                	jmp    800d0c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cf2:	88 18                	mov    %bl,(%eax)
  800cf4:	40                   	inc    %eax
  800cf5:	41                   	inc    %ecx
  800cf6:	eb 02                	jmp    800cfa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cfa:	4a                   	dec    %edx
  800cfb:	74 0a                	je     800d07 <strlcpy+0x2b>
  800cfd:	8a 19                	mov    (%ecx),%bl
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 ef                	jne    800cf2 <strlcpy+0x16>
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	eb 02                	jmp    800d09 <strlcpy+0x2d>
  800d07:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d09:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d0c:	29 f0                	sub    %esi,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d18:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d1b:	eb 02                	jmp    800d1f <strcmp+0xd>
		p++, q++;
  800d1d:	41                   	inc    %ecx
  800d1e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d1f:	8a 01                	mov    (%ecx),%al
  800d21:	84 c0                	test   %al,%al
  800d23:	74 04                	je     800d29 <strcmp+0x17>
  800d25:	3a 02                	cmp    (%edx),%al
  800d27:	74 f4                	je     800d1d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d29:	0f b6 c0             	movzbl %al,%eax
  800d2c:	0f b6 12             	movzbl (%edx),%edx
  800d2f:	29 d0                	sub    %edx,%eax
}
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	53                   	push   %ebx
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d40:	eb 03                	jmp    800d45 <strncmp+0x12>
		n--, p++, q++;
  800d42:	4a                   	dec    %edx
  800d43:	40                   	inc    %eax
  800d44:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d45:	85 d2                	test   %edx,%edx
  800d47:	74 14                	je     800d5d <strncmp+0x2a>
  800d49:	8a 18                	mov    (%eax),%bl
  800d4b:	84 db                	test   %bl,%bl
  800d4d:	74 04                	je     800d53 <strncmp+0x20>
  800d4f:	3a 19                	cmp    (%ecx),%bl
  800d51:	74 ef                	je     800d42 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d53:	0f b6 00             	movzbl (%eax),%eax
  800d56:	0f b6 11             	movzbl (%ecx),%edx
  800d59:	29 d0                	sub    %edx,%eax
  800d5b:	eb 05                	jmp    800d62 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d62:	5b                   	pop    %ebx
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d6e:	eb 05                	jmp    800d75 <strchr+0x10>
		if (*s == c)
  800d70:	38 ca                	cmp    %cl,%dl
  800d72:	74 0c                	je     800d80 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d74:	40                   	inc    %eax
  800d75:	8a 10                	mov    (%eax),%dl
  800d77:	84 d2                	test   %dl,%dl
  800d79:	75 f5                	jne    800d70 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d8b:	eb 05                	jmp    800d92 <strfind+0x10>
		if (*s == c)
  800d8d:	38 ca                	cmp    %cl,%dl
  800d8f:	74 07                	je     800d98 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d91:	40                   	inc    %eax
  800d92:	8a 10                	mov    (%eax),%dl
  800d94:	84 d2                	test   %dl,%dl
  800d96:	75 f5                	jne    800d8d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da9:	85 c9                	test   %ecx,%ecx
  800dab:	74 30                	je     800ddd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db3:	75 25                	jne    800dda <memset+0x40>
  800db5:	f6 c1 03             	test   $0x3,%cl
  800db8:	75 20                	jne    800dda <memset+0x40>
		c &= 0xFF;
  800dba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dbd:	89 d3                	mov    %edx,%ebx
  800dbf:	c1 e3 08             	shl    $0x8,%ebx
  800dc2:	89 d6                	mov    %edx,%esi
  800dc4:	c1 e6 18             	shl    $0x18,%esi
  800dc7:	89 d0                	mov    %edx,%eax
  800dc9:	c1 e0 10             	shl    $0x10,%eax
  800dcc:	09 f0                	or     %esi,%eax
  800dce:	09 d0                	or     %edx,%eax
  800dd0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dd2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dd5:	fc                   	cld    
  800dd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd8:	eb 03                	jmp    800ddd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dda:	fc                   	cld    
  800ddb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ddd:	89 f8                	mov    %edi,%eax
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800def:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 34                	jae    800e2a <memmove+0x46>
  800df6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df9:	39 d0                	cmp    %edx,%eax
  800dfb:	73 2d                	jae    800e2a <memmove+0x46>
		s += n;
		d += n;
  800dfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e00:	f6 c2 03             	test   $0x3,%dl
  800e03:	75 1b                	jne    800e20 <memmove+0x3c>
  800e05:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e0b:	75 13                	jne    800e20 <memmove+0x3c>
  800e0d:	f6 c1 03             	test   $0x3,%cl
  800e10:	75 0e                	jne    800e20 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e12:	83 ef 04             	sub    $0x4,%edi
  800e15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e18:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e1b:	fd                   	std    
  800e1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1e:	eb 07                	jmp    800e27 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e20:	4f                   	dec    %edi
  800e21:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e24:	fd                   	std    
  800e25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e27:	fc                   	cld    
  800e28:	eb 20                	jmp    800e4a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e30:	75 13                	jne    800e45 <memmove+0x61>
  800e32:	a8 03                	test   $0x3,%al
  800e34:	75 0f                	jne    800e45 <memmove+0x61>
  800e36:	f6 c1 03             	test   $0x3,%cl
  800e39:	75 0a                	jne    800e45 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e3b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e3e:	89 c7                	mov    %eax,%edi
  800e40:	fc                   	cld    
  800e41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e43:	eb 05                	jmp    800e4a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e45:	89 c7                	mov    %eax,%edi
  800e47:	fc                   	cld    
  800e48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e54:	8b 45 10             	mov    0x10(%ebp),%eax
  800e57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	89 04 24             	mov    %eax,(%esp)
  800e68:	e8 77 ff ff ff       	call   800de4 <memmove>
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e83:	eb 16                	jmp    800e9b <memcmp+0x2c>
		if (*s1 != *s2)
  800e85:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e88:	42                   	inc    %edx
  800e89:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e8d:	38 c8                	cmp    %cl,%al
  800e8f:	74 0a                	je     800e9b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e91:	0f b6 c0             	movzbl %al,%eax
  800e94:	0f b6 c9             	movzbl %cl,%ecx
  800e97:	29 c8                	sub    %ecx,%eax
  800e99:	eb 09                	jmp    800ea4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e9b:	39 da                	cmp    %ebx,%edx
  800e9d:	75 e6                	jne    800e85 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800eb7:	eb 05                	jmp    800ebe <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb9:	38 08                	cmp    %cl,(%eax)
  800ebb:	74 05                	je     800ec2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ebd:	40                   	inc    %eax
  800ebe:	39 d0                	cmp    %edx,%eax
  800ec0:	72 f7                	jb     800eb9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed0:	eb 01                	jmp    800ed3 <strtol+0xf>
		s++;
  800ed2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed3:	8a 02                	mov    (%edx),%al
  800ed5:	3c 20                	cmp    $0x20,%al
  800ed7:	74 f9                	je     800ed2 <strtol+0xe>
  800ed9:	3c 09                	cmp    $0x9,%al
  800edb:	74 f5                	je     800ed2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800edd:	3c 2b                	cmp    $0x2b,%al
  800edf:	75 08                	jne    800ee9 <strtol+0x25>
		s++;
  800ee1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee7:	eb 13                	jmp    800efc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee9:	3c 2d                	cmp    $0x2d,%al
  800eeb:	75 0a                	jne    800ef7 <strtol+0x33>
		s++, neg = 1;
  800eed:	8d 52 01             	lea    0x1(%edx),%edx
  800ef0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ef5:	eb 05                	jmp    800efc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efc:	85 db                	test   %ebx,%ebx
  800efe:	74 05                	je     800f05 <strtol+0x41>
  800f00:	83 fb 10             	cmp    $0x10,%ebx
  800f03:	75 28                	jne    800f2d <strtol+0x69>
  800f05:	8a 02                	mov    (%edx),%al
  800f07:	3c 30                	cmp    $0x30,%al
  800f09:	75 10                	jne    800f1b <strtol+0x57>
  800f0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f0f:	75 0a                	jne    800f1b <strtol+0x57>
		s += 2, base = 16;
  800f11:	83 c2 02             	add    $0x2,%edx
  800f14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f19:	eb 12                	jmp    800f2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f1b:	85 db                	test   %ebx,%ebx
  800f1d:	75 0e                	jne    800f2d <strtol+0x69>
  800f1f:	3c 30                	cmp    $0x30,%al
  800f21:	75 05                	jne    800f28 <strtol+0x64>
		s++, base = 8;
  800f23:	42                   	inc    %edx
  800f24:	b3 08                	mov    $0x8,%bl
  800f26:	eb 05                	jmp    800f2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f34:	8a 0a                	mov    (%edx),%cl
  800f36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f39:	80 fb 09             	cmp    $0x9,%bl
  800f3c:	77 08                	ja     800f46 <strtol+0x82>
			dig = *s - '0';
  800f3e:	0f be c9             	movsbl %cl,%ecx
  800f41:	83 e9 30             	sub    $0x30,%ecx
  800f44:	eb 1e                	jmp    800f64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f49:	80 fb 19             	cmp    $0x19,%bl
  800f4c:	77 08                	ja     800f56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f4e:	0f be c9             	movsbl %cl,%ecx
  800f51:	83 e9 57             	sub    $0x57,%ecx
  800f54:	eb 0e                	jmp    800f64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f59:	80 fb 19             	cmp    $0x19,%bl
  800f5c:	77 12                	ja     800f70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f5e:	0f be c9             	movsbl %cl,%ecx
  800f61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f64:	39 f1                	cmp    %esi,%ecx
  800f66:	7d 0c                	jge    800f74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f68:	42                   	inc    %edx
  800f69:	0f af c6             	imul   %esi,%eax
  800f6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f6e:	eb c4                	jmp    800f34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f70:	89 c1                	mov    %eax,%ecx
  800f72:	eb 02                	jmp    800f76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f7a:	74 05                	je     800f81 <strtol+0xbd>
		*endptr = (char *) s;
  800f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f81:	85 ff                	test   %edi,%edi
  800f83:	74 04                	je     800f89 <strtol+0xc5>
  800f85:	89 c8                	mov    %ecx,%eax
  800f87:	f7 d8                	neg    %eax
}
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
	...

00800f90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	89 c7                	mov    %eax,%edi
  800fa5:	89 c6                	mov    %eax,%esi
  800fa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_cgetc>:

int
sys_cgetc(void)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbe:	89 d1                	mov    %edx,%ecx
  800fc0:	89 d3                	mov    %edx,%ebx
  800fc2:	89 d7                	mov    %edx,%edi
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 cb                	mov    %ecx,%ebx
  800fe5:	89 cf                	mov    %ecx,%edi
  800fe7:	89 ce                	mov    %ecx,%esi
  800fe9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 28                	jle    801017 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  801012:	e8 b1 f5 ff ff       	call   8005c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801017:	83 c4 2c             	add    $0x2c,%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801025:	ba 00 00 00 00       	mov    $0x0,%edx
  80102a:	b8 02 00 00 00       	mov    $0x2,%eax
  80102f:	89 d1                	mov    %edx,%ecx
  801031:	89 d3                	mov    %edx,%ebx
  801033:	89 d7                	mov    %edx,%edi
  801035:	89 d6                	mov    %edx,%esi
  801037:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5f                   	pop    %edi
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <sys_yield>:

void
sys_yield(void)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	ba 00 00 00 00       	mov    $0x0,%edx
  801049:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104e:	89 d1                	mov    %edx,%ecx
  801050:	89 d3                	mov    %edx,%ebx
  801052:	89 d7                	mov    %edx,%edi
  801054:	89 d6                	mov    %edx,%esi
  801056:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	be 00 00 00 00       	mov    $0x0,%esi
  80106b:	b8 04 00 00 00       	mov    $0x4,%eax
  801070:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801073:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	89 f7                	mov    %esi,%edi
  80107b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107d:	85 c0                	test   %eax,%eax
  80107f:	7e 28                	jle    8010a9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801081:	89 44 24 10          	mov    %eax,0x10(%esp)
  801085:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80108c:	00 
  80108d:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  801094:	00 
  801095:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109c:	00 
  80109d:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  8010a4:	e8 1f f5 ff ff       	call   8005c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010a9:	83 c4 2c             	add    $0x2c,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8010bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8010c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7e 28                	jle    8010fc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010df:	00 
  8010e0:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ef:	00 
  8010f0:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  8010f7:	e8 cc f4 ff ff       	call   8005c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010fc:	83 c4 2c             	add    $0x2c,%esp
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	b8 06 00 00 00       	mov    $0x6,%eax
  801117:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111a:	8b 55 08             	mov    0x8(%ebp),%edx
  80111d:	89 df                	mov    %ebx,%edi
  80111f:	89 de                	mov    %ebx,%esi
  801121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	7e 28                	jle    80114f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80112b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801132:	00 
  801133:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801142:	00 
  801143:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  80114a:	e8 79 f4 ff ff       	call   8005c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80114f:	83 c4 2c             	add    $0x2c,%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801160:	bb 00 00 00 00       	mov    $0x0,%ebx
  801165:	b8 08 00 00 00       	mov    $0x8,%eax
  80116a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116d:	8b 55 08             	mov    0x8(%ebp),%edx
  801170:	89 df                	mov    %ebx,%edi
  801172:	89 de                	mov    %ebx,%esi
  801174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	7e 28                	jle    8011a2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801185:	00 
  801186:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  80119d:	e8 26 f4 ff ff       	call   8005c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011a2:	83 c4 2c             	add    $0x2c,%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	57                   	push   %edi
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b8:	b8 09 00 00 00       	mov    $0x9,%eax
  8011bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c3:	89 df                	mov    %ebx,%edi
  8011c5:	89 de                	mov    %ebx,%esi
  8011c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	7e 28                	jle    8011f5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011d8:	00 
  8011d9:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  8011e0:	00 
  8011e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011e8:	00 
  8011e9:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  8011f0:	e8 d3 f3 ff ff       	call   8005c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f5:	83 c4 2c             	add    $0x2c,%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801203:	be 00 00 00 00       	mov    $0x0,%esi
  801208:	b8 0b 00 00 00       	mov    $0xb,%eax
  80120d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801216:	8b 55 08             	mov    0x8(%ebp),%edx
  801219:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80121b:	5b                   	pop    %ebx
  80121c:	5e                   	pop    %esi
  80121d:	5f                   	pop    %edi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801229:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801233:	8b 55 08             	mov    0x8(%ebp),%edx
  801236:	89 cb                	mov    %ecx,%ebx
  801238:	89 cf                	mov    %ecx,%edi
  80123a:	89 ce                	mov    %ecx,%esi
  80123c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123e:	85 c0                	test   %eax,%eax
  801240:	7e 28                	jle    80126a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801242:	89 44 24 10          	mov    %eax,0x10(%esp)
  801246:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80124d:	00 
  80124e:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  801255:	00 
  801256:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80125d:	00 
  80125e:	c7 04 24 25 19 80 00 	movl   $0x801925,(%esp)
  801265:	e8 5e f3 ff ff       	call   8005c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80126a:	83 c4 2c             	add    $0x2c,%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    
	...

00801274 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80127a:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801281:	75 3d                	jne    8012c0 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  801283:	e8 97 fd ff ff       	call   80101f <sys_getenvid>
  801288:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80128f:	00 
  801290:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801297:	ee 
  801298:	89 04 24             	mov    %eax,(%esp)
  80129b:	e8 bd fd ff ff       	call   80105d <sys_page_alloc>
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 1c                	jns    8012c0 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  8012a4:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  8012ab:	00 
  8012ac:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8012b3:	00 
  8012b4:	c7 04 24 8c 19 80 00 	movl   $0x80198c,(%esp)
  8012bb:	e8 08 f3 ff ff       	call   8005c8 <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	a3 d0 20 80 00       	mov    %eax,0x8020d0
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  8012c8:	e8 52 fd ff ff       	call   80101f <sys_getenvid>
  8012cd:	c7 44 24 04 00 13 80 	movl   $0x801300,0x4(%esp)
  8012d4:	00 
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 cd fe ff ff       	call   8011aa <sys_env_set_pgfault_upcall>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	79 1c                	jns    8012fd <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  8012e1:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  8012e8:	00 
  8012e9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012f0:	00 
  8012f1:	c7 04 24 8c 19 80 00 	movl   $0x80198c,(%esp)
  8012f8:	e8 cb f2 ff ff       	call   8005c8 <_panic>
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    
	...

00801300 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801300:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801301:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801306:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801308:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  80130b:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  80130d:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  801311:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  801315:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  801316:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  801318:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  80131d:	58                   	pop    %eax
        popl %eax
  80131e:	58                   	pop    %eax
        popal
  80131f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  801320:	83 c4 04             	add    $0x4,%esp
        popfl
  801323:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801324:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  801325:	c3                   	ret    
	...

00801328 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801328:	55                   	push   %ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	83 ec 10             	sub    $0x10,%esp
  80132e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801332:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80133a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80133e:	89 cd                	mov    %ecx,%ebp
  801340:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801344:	85 c0                	test   %eax,%eax
  801346:	75 2c                	jne    801374 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801348:	39 f9                	cmp    %edi,%ecx
  80134a:	77 68                	ja     8013b4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80134c:	85 c9                	test   %ecx,%ecx
  80134e:	75 0b                	jne    80135b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801350:	b8 01 00 00 00       	mov    $0x1,%eax
  801355:	31 d2                	xor    %edx,%edx
  801357:	f7 f1                	div    %ecx
  801359:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	89 f8                	mov    %edi,%eax
  80135f:	f7 f1                	div    %ecx
  801361:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801363:	89 f0                	mov    %esi,%eax
  801365:	f7 f1                	div    %ecx
  801367:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801369:	89 f0                	mov    %esi,%eax
  80136b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801374:	39 f8                	cmp    %edi,%eax
  801376:	77 2c                	ja     8013a4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801378:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80137b:	83 f6 1f             	xor    $0x1f,%esi
  80137e:	75 4c                	jne    8013cc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801380:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801382:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801387:	72 0a                	jb     801393 <__udivdi3+0x6b>
  801389:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80138d:	0f 87 ad 00 00 00    	ja     801440 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801393:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801398:	89 f0                	mov    %esi,%eax
  80139a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
  8013a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013a4:	31 ff                	xor    %edi,%edi
  8013a6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013a8:	89 f0                	mov    %esi,%eax
  8013aa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    
  8013b3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013b4:	89 fa                	mov    %edi,%edx
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	f7 f1                	div    %ecx
  8013ba:	89 c6                	mov    %eax,%esi
  8013bc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013be:	89 f0                	mov    %esi,%eax
  8013c0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	5e                   	pop    %esi
  8013c6:	5f                   	pop    %edi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    
  8013c9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013cc:	89 f1                	mov    %esi,%ecx
  8013ce:	d3 e0                	shl    %cl,%eax
  8013d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8013d9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8013db:	89 ea                	mov    %ebp,%edx
  8013dd:	88 c1                	mov    %al,%cl
  8013df:	d3 ea                	shr    %cl,%edx
  8013e1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013e5:	09 ca                	or     %ecx,%edx
  8013e7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8013eb:	89 f1                	mov    %esi,%ecx
  8013ed:	d3 e5                	shl    %cl,%ebp
  8013ef:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8013f3:	89 fd                	mov    %edi,%ebp
  8013f5:	88 c1                	mov    %al,%cl
  8013f7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8013f9:	89 fa                	mov    %edi,%edx
  8013fb:	89 f1                	mov    %esi,%ecx
  8013fd:	d3 e2                	shl    %cl,%edx
  8013ff:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801403:	88 c1                	mov    %al,%cl
  801405:	d3 ef                	shr    %cl,%edi
  801407:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801409:	89 f8                	mov    %edi,%eax
  80140b:	89 ea                	mov    %ebp,%edx
  80140d:	f7 74 24 08          	divl   0x8(%esp)
  801411:	89 d1                	mov    %edx,%ecx
  801413:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801415:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801419:	39 d1                	cmp    %edx,%ecx
  80141b:	72 17                	jb     801434 <__udivdi3+0x10c>
  80141d:	74 09                	je     801428 <__udivdi3+0x100>
  80141f:	89 fe                	mov    %edi,%esi
  801421:	31 ff                	xor    %edi,%edi
  801423:	e9 41 ff ff ff       	jmp    801369 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801428:	8b 54 24 04          	mov    0x4(%esp),%edx
  80142c:	89 f1                	mov    %esi,%ecx
  80142e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801430:	39 c2                	cmp    %eax,%edx
  801432:	73 eb                	jae    80141f <__udivdi3+0xf7>
		{
		  q0--;
  801434:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801437:	31 ff                	xor    %edi,%edi
  801439:	e9 2b ff ff ff       	jmp    801369 <__udivdi3+0x41>
  80143e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801440:	31 f6                	xor    %esi,%esi
  801442:	e9 22 ff ff ff       	jmp    801369 <__udivdi3+0x41>
	...

00801448 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801448:	55                   	push   %ebp
  801449:	57                   	push   %edi
  80144a:	56                   	push   %esi
  80144b:	83 ec 20             	sub    $0x20,%esp
  80144e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801452:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801456:	89 44 24 14          	mov    %eax,0x14(%esp)
  80145a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80145e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801462:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801466:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801468:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80146a:	85 ed                	test   %ebp,%ebp
  80146c:	75 16                	jne    801484 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80146e:	39 f1                	cmp    %esi,%ecx
  801470:	0f 86 a6 00 00 00    	jbe    80151c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801476:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801478:	89 d0                	mov    %edx,%eax
  80147a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80147c:	83 c4 20             	add    $0x20,%esp
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
  801483:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801484:	39 f5                	cmp    %esi,%ebp
  801486:	0f 87 ac 00 00 00    	ja     801538 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80148c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80148f:	83 f0 1f             	xor    $0x1f,%eax
  801492:	89 44 24 10          	mov    %eax,0x10(%esp)
  801496:	0f 84 a8 00 00 00    	je     801544 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80149c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014a0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014a2:	bf 20 00 00 00       	mov    $0x20,%edi
  8014a7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8014ab:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014af:	89 f9                	mov    %edi,%ecx
  8014b1:	d3 e8                	shr    %cl,%eax
  8014b3:	09 e8                	or     %ebp,%eax
  8014b5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8014b9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014bd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c1:	d3 e0                	shl    %cl,%eax
  8014c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014c7:	89 f2                	mov    %esi,%edx
  8014c9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8014cb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014cf:	d3 e0                	shl    %cl,%eax
  8014d1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014d5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014d9:	89 f9                	mov    %edi,%ecx
  8014db:	d3 e8                	shr    %cl,%eax
  8014dd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8014df:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014e1:	89 f2                	mov    %esi,%edx
  8014e3:	f7 74 24 18          	divl   0x18(%esp)
  8014e7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8014e9:	f7 64 24 0c          	mull   0xc(%esp)
  8014ed:	89 c5                	mov    %eax,%ebp
  8014ef:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014f1:	39 d6                	cmp    %edx,%esi
  8014f3:	72 67                	jb     80155c <__umoddi3+0x114>
  8014f5:	74 75                	je     80156c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8014f7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014fb:	29 e8                	sub    %ebp,%eax
  8014fd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8014ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801503:	d3 e8                	shr    %cl,%eax
  801505:	89 f2                	mov    %esi,%edx
  801507:	89 f9                	mov    %edi,%ecx
  801509:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80150b:	09 d0                	or     %edx,%eax
  80150d:	89 f2                	mov    %esi,%edx
  80150f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801513:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801515:	83 c4 20             	add    $0x20,%esp
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80151c:	85 c9                	test   %ecx,%ecx
  80151e:	75 0b                	jne    80152b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801520:	b8 01 00 00 00       	mov    $0x1,%eax
  801525:	31 d2                	xor    %edx,%edx
  801527:	f7 f1                	div    %ecx
  801529:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80152b:	89 f0                	mov    %esi,%eax
  80152d:	31 d2                	xor    %edx,%edx
  80152f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801531:	89 f8                	mov    %edi,%eax
  801533:	e9 3e ff ff ff       	jmp    801476 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801538:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80153a:	83 c4 20             	add    $0x20,%esp
  80153d:	5e                   	pop    %esi
  80153e:	5f                   	pop    %edi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    
  801541:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801544:	39 f5                	cmp    %esi,%ebp
  801546:	72 04                	jb     80154c <__umoddi3+0x104>
  801548:	39 f9                	cmp    %edi,%ecx
  80154a:	77 06                	ja     801552 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80154c:	89 f2                	mov    %esi,%edx
  80154e:	29 cf                	sub    %ecx,%edi
  801550:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801552:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801554:	83 c4 20             	add    $0x20,%esp
  801557:	5e                   	pop    %esi
  801558:	5f                   	pop    %edi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    
  80155b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80155c:	89 d1                	mov    %edx,%ecx
  80155e:	89 c5                	mov    %eax,%ebp
  801560:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801564:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801568:	eb 8d                	jmp    8014f7 <__umoddi3+0xaf>
  80156a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80156c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801570:	72 ea                	jb     80155c <__umoddi3+0x114>
  801572:	89 f1                	mov    %esi,%ecx
  801574:	eb 81                	jmp    8014f7 <__umoddi3+0xaf>
