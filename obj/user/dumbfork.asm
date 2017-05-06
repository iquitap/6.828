
obj/user/dumbfork：     文件格式 elf32-i386


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
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 ef 0c 00 00       	call   800d45 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  800075:	e8 36 02 00 00       	call   8002b0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 fb 0c 00 00       	call   800d99 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
            panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 e3 11 80 	movl   $0x8011e3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  8000bd:	e8 ee 01 00 00       	call   8002b0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 f2 09 00 00       	call   800acc <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 fe 0c 00 00       	call   800dec <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 f4 11 80 	movl   $0x8011f4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  80010d:	e8 9e 01 00 00       	call   8002b0 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 07 12 80 	movl   $0x801207,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  80014d:	e8 5e 01 00 00       	call   8002b0 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 22                	jne    800178 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 ac 0b 00 00       	call   800d07 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800176:	eb 6e                	jmp    8001e6 <dumbfork+0xcd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800178:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80017f:	eb 13                	jmp    800194 <dumbfork+0x7b>
		duppage(envid, addr);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	89 1c 24             	mov    %ebx,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	3d 08 20 80 00       	cmp    $0x802008,%eax
  80019c:	72 e3                	jb     800181 <dumbfork+0x68>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80019e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	89 34 24             	mov    %esi,(%esp)
  8001ad:	e8 82 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b9:	00 
  8001ba:	89 34 24             	mov    %esi,(%esp)
  8001bd:	e8 7d 0c 00 00       	call   800e3f <sys_env_set_status>
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	79 20                	jns    8001e6 <dumbfork+0xcd>
		panic("sys_env_set_status: %e", r);
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	c7 44 24 08 17 12 80 	movl   $0x801217,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 d3 11 80 00 	movl   $0x8011d3,(%esp)
  8001e1:	e8 ca 00 00 00       	call   8002b0 <_panic>

	return envid;
}
  8001e6:	89 f0                	mov    %esi,%eax
  8001e8:	83 c4 20             	add    $0x20,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001f7:	e8 1d ff ff ff       	call   800119 <dumbfork>
  8001fc:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fe:	be 00 00 00 00       	mov    $0x0,%esi
  800203:	eb 2a                	jmp    80022f <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800205:	85 db                	test   %ebx,%ebx
  800207:	74 07                	je     800210 <umain+0x21>
  800209:	b8 2e 12 80 00       	mov    $0x80122e,%eax
  80020e:	eb 05                	jmp    800215 <umain+0x26>
  800210:	b8 35 12 80 00       	mov    $0x801235,%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021d:	c7 04 24 3b 12 80 00 	movl   $0x80123b,(%esp)
  800224:	e8 7f 01 00 00       	call   8003a8 <cprintf>
		sys_yield();
  800229:	e8 f8 0a 00 00       	call   800d26 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022e:	46                   	inc    %esi
  80022f:	83 fb 01             	cmp    $0x1,%ebx
  800232:	19 c0                	sbb    %eax,%eax
  800234:	83 e0 0a             	and    $0xa,%eax
  800237:	83 c0 0a             	add    $0xa,%eax
  80023a:	39 c6                	cmp    %eax,%esi
  80023c:	7c c7                	jl     800205 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
  800245:	00 00                	add    %al,(%eax)
	...

00800248 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800256:	e8 ac 0a 00 00       	call   800d07 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800276:	85 f6                	test   %esi,%esi
  800278:	7e 07                	jle    800281 <libmain+0x39>
		binaryname = argv[0];
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800281:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800285:	89 34 24             	mov    %esi,(%esp)
  800288:	e8 62 ff ff ff       	call   8001ef <umain>

	// exit gracefully
	exit();
  80028d:	e8 0a 00 00 00       	call   80029c <exit>
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a9:	e8 07 0a 00 00       	call   800cb5 <sys_env_destroy>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002c1:	e8 41 0a 00 00       	call   800d07 <sys_getenvid>
  8002c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	c7 04 24 58 12 80 00 	movl   $0x801258,(%esp)
  8002e3:	e8 c0 00 00 00       	call   8003a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 50 00 00 00       	call   800347 <vcprintf>
	cprintf("\n");
  8002f7:	c7 04 24 4b 12 80 00 	movl   $0x80124b,(%esp)
  8002fe:	e8 a5 00 00 00       	call   8003a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800303:	cc                   	int3   
  800304:	eb fd                	jmp    800303 <_panic+0x53>
	...

00800308 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	53                   	push   %ebx
  80030c:	83 ec 14             	sub    $0x14,%esp
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800312:	8b 03                	mov    (%ebx),%eax
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80031b:	40                   	inc    %eax
  80031c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80031e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800323:	75 19                	jne    80033e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800325:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80032c:	00 
  80032d:	8d 43 08             	lea    0x8(%ebx),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 40 09 00 00       	call   800c78 <sys_cputs>
		b->idx = 0;
  800338:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80033e:	ff 43 04             	incl   0x4(%ebx)
}
  800341:	83 c4 14             	add    $0x14,%esp
  800344:	5b                   	pop    %ebx
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800350:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800357:	00 00 00 
	b.cnt = 0;
  80035a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800361:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800372:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037c:	c7 04 24 08 03 80 00 	movl   $0x800308,(%esp)
  800383:	e8 82 01 00 00       	call   80050a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 d8 08 00 00       	call   800c78 <sys_cputs>

	return b.cnt;
}
  8003a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 87 ff ff ff       	call   800347 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    
	...

008003c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 3c             	sub    $0x3c,%esp
  8003cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d0:	89 d7                	mov    %edx,%edi
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003de:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	75 08                	jne    8003f0 <printnum+0x2c>
  8003e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ee:	77 57                	ja     800447 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003f4:	4b                   	dec    %ebx
  8003f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800404:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800408:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040f:	00 
  800410:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800413:	89 04 24             	mov    %eax,(%esp)
  800416:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041d:	e8 3a 0b 00 00       	call   800f5c <__udivdi3>
  800422:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800426:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800431:	89 fa                	mov    %edi,%edx
  800433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800436:	e8 89 ff ff ff       	call   8003c4 <printnum>
  80043b:	eb 0f                	jmp    80044c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800441:	89 34 24             	mov    %esi,(%esp)
  800444:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800447:	4b                   	dec    %ebx
  800448:	85 db                	test   %ebx,%ebx
  80044a:	7f f1                	jg     80043d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800450:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800454:	8b 45 10             	mov    0x10(%ebp),%eax
  800457:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800462:	00 
  800463:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800470:	e8 07 0c 00 00       	call   80107c <__umoddi3>
  800475:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800479:	0f be 80 7c 12 80 00 	movsbl 0x80127c(%eax),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800486:	83 c4 3c             	add    $0x3c,%esp
  800489:	5b                   	pop    %ebx
  80048a:	5e                   	pop    %esi
  80048b:	5f                   	pop    %edi
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    

0080048e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800491:	83 fa 01             	cmp    $0x1,%edx
  800494:	7e 0e                	jle    8004a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	8b 52 04             	mov    0x4(%edx),%edx
  8004a2:	eb 22                	jmp    8004c6 <getuint+0x38>
	else if (lflag)
  8004a4:	85 d2                	test   %edx,%edx
  8004a6:	74 10                	je     8004b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 02                	mov    (%edx),%eax
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b6:	eb 0e                	jmp    8004c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ce:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d6:	73 08                	jae    8004e0 <sprintputch+0x18>
		*b->buf++ = ch;
  8004d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004db:	88 0a                	mov    %cl,(%edx)
  8004dd:	42                   	inc    %edx
  8004de:	89 10                	mov    %edx,(%eax)
}
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 02 00 00 00       	call   80050a <vprintfmt>
	va_end(ap);
}
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	53                   	push   %ebx
  800510:	83 ec 4c             	sub    $0x4c,%esp
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800516:	8b 75 10             	mov    0x10(%ebp),%esi
  800519:	eb 12                	jmp    80052d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051b:	85 c0                	test   %eax,%eax
  80051d:	0f 84 6b 03 00 00    	je     80088e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800523:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052d:	0f b6 06             	movzbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	83 f8 25             	cmp    $0x25,%eax
  800534:	75 e5                	jne    80051b <vprintfmt+0x11>
  800536:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80053a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800541:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800546:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800552:	eb 26                	jmp    80057a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800557:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80055b:	eb 1d                	jmp    80057a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800560:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800564:	eb 14                	jmp    80057a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800569:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800570:	eb 08                	jmp    80057a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800572:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800575:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	0f b6 06             	movzbl (%esi),%eax
  80057d:	8d 56 01             	lea    0x1(%esi),%edx
  800580:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800583:	8a 16                	mov    (%esi),%dl
  800585:	83 ea 23             	sub    $0x23,%edx
  800588:	80 fa 55             	cmp    $0x55,%dl
  80058b:	0f 87 e1 02 00 00    	ja     800872 <vprintfmt+0x368>
  800591:	0f b6 d2             	movzbl %dl,%edx
  800594:	ff 24 95 40 13 80 00 	jmp    *0x801340(,%edx,4)
  80059b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005a6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005aa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005ad:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005b0:	83 fa 09             	cmp    $0x9,%edx
  8005b3:	77 2a                	ja     8005df <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b6:	eb eb                	jmp    8005a3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c6:	eb 17                	jmp    8005df <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cc:	78 98                	js     800566 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d1:	eb a7                	jmp    80057a <vprintfmt+0x70>
  8005d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005dd:	eb 9b                	jmp    80057a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e3:	79 95                	jns    80057a <vprintfmt+0x70>
  8005e5:	eb 8b                	jmp    800572 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005eb:	eb 8d                	jmp    80057a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800605:	e9 23 ff ff ff       	jmp    80052d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 04             	lea    0x4(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 00                	mov    (%eax),%eax
  800615:	85 c0                	test   %eax,%eax
  800617:	79 02                	jns    80061b <vprintfmt+0x111>
  800619:	f7 d8                	neg    %eax
  80061b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 09             	cmp    $0x9,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x123>
  800622:	8b 04 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%eax
  800629:	85 c0                	test   %eax,%eax
  80062b:	75 23                	jne    800650 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80062d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800631:	c7 44 24 08 94 12 80 	movl   $0x801294,0x8(%esp)
  800638:	00 
  800639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	e8 9a fe ff ff       	call   8004e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80064b:	e9 dd fe ff ff       	jmp    80052d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800650:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800654:	c7 44 24 08 9d 12 80 	movl   $0x80129d,0x8(%esp)
  80065b:	00 
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	89 14 24             	mov    %edx,(%esp)
  800666:	e8 77 fe ff ff       	call   8004e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066e:	e9 ba fe ff ff       	jmp    80052d <vprintfmt+0x23>
  800673:	89 f9                	mov    %edi,%ecx
  800675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800678:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	8b 30                	mov    (%eax),%esi
  800686:	85 f6                	test   %esi,%esi
  800688:	75 05                	jne    80068f <vprintfmt+0x185>
				p = "(null)";
  80068a:	be 8d 12 80 00       	mov    $0x80128d,%esi
			if (width > 0 && padc != '-')
  80068f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800693:	0f 8e 84 00 00 00    	jle    80071d <vprintfmt+0x213>
  800699:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80069d:	74 7e                	je     80071d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	e8 8b 02 00 00       	call   800936 <strnlen>
  8006ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ae:	29 c2                	sub    %eax,%edx
  8006b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006b3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006b7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006bd:	89 de                	mov    %ebx,%esi
  8006bf:	89 d3                	mov    %edx,%ebx
  8006c1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	eb 0b                	jmp    8006d0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c9:	89 3c 24             	mov    %edi,(%esp)
  8006cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	4b                   	dec    %ebx
  8006d0:	85 db                	test   %ebx,%ebx
  8006d2:	7f f1                	jg     8006c5 <vprintfmt+0x1bb>
  8006d4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006d7:	89 f3                	mov    %esi,%ebx
  8006d9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	79 05                	jns    8006e8 <vprintfmt+0x1de>
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	29 c2                	sub    %eax,%edx
  8006ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f0:	eb 2b                	jmp    80071d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f6:	74 18                	je     800710 <vprintfmt+0x206>
  8006f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006fb:	83 fa 5e             	cmp    $0x5e,%edx
  8006fe:	76 10                	jbe    800710 <vprintfmt+0x206>
					putch('?', putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
  80070e:	eb 0a                	jmp    80071a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	ff 4d e4             	decl   -0x1c(%ebp)
  80071d:	0f be 06             	movsbl (%esi),%eax
  800720:	46                   	inc    %esi
  800721:	85 c0                	test   %eax,%eax
  800723:	74 21                	je     800746 <vprintfmt+0x23c>
  800725:	85 ff                	test   %edi,%edi
  800727:	78 c9                	js     8006f2 <vprintfmt+0x1e8>
  800729:	4f                   	dec    %edi
  80072a:	79 c6                	jns    8006f2 <vprintfmt+0x1e8>
  80072c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072f:	89 de                	mov    %ebx,%esi
  800731:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800734:	eb 18                	jmp    80074e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800736:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800741:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800743:	4b                   	dec    %ebx
  800744:	eb 08                	jmp    80074e <vprintfmt+0x244>
  800746:	8b 7d 08             	mov    0x8(%ebp),%edi
  800749:	89 de                	mov    %ebx,%esi
  80074b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80074e:	85 db                	test   %ebx,%ebx
  800750:	7f e4                	jg     800736 <vprintfmt+0x22c>
  800752:	89 7d 08             	mov    %edi,0x8(%ebp)
  800755:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075a:	e9 ce fd ff ff       	jmp    80052d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075f:	83 f9 01             	cmp    $0x1,%ecx
  800762:	7e 10                	jle    800774 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 08             	lea    0x8(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)
  80076d:	8b 30                	mov    (%eax),%esi
  80076f:	8b 78 04             	mov    0x4(%eax),%edi
  800772:	eb 26                	jmp    80079a <vprintfmt+0x290>
	else if (lflag)
  800774:	85 c9                	test   %ecx,%ecx
  800776:	74 12                	je     80078a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 50 04             	lea    0x4(%eax),%edx
  80077e:	89 55 14             	mov    %edx,0x14(%ebp)
  800781:	8b 30                	mov    (%eax),%esi
  800783:	89 f7                	mov    %esi,%edi
  800785:	c1 ff 1f             	sar    $0x1f,%edi
  800788:	eb 10                	jmp    80079a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	89 f7                	mov    %esi,%edi
  800797:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80079a:	85 ff                	test   %edi,%edi
  80079c:	78 0a                	js     8007a8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80079e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a3:	e9 8c 00 00 00       	jmp    800834 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ac:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007b3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007b6:	f7 de                	neg    %esi
  8007b8:	83 d7 00             	adc    $0x0,%edi
  8007bb:	f7 df                	neg    %edi
			}
			base = 10;
  8007bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c2:	eb 70                	jmp    800834 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 c0 fc ff ff       	call   80048e <getuint>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	89 d7                	mov    %edx,%edi
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d7:	eb 5b                	jmp    800834 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 ab fc ff ff       	call   80048e <getuint>
  8007e3:	89 c6                	mov    %eax,%esi
  8007e5:	89 d7                	mov    %edx,%edi
                        base = 8;
  8007e7:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8007ec:	eb 46                	jmp    800834 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8007ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8d 50 04             	lea    0x4(%eax),%edx
  800810:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800813:	8b 30                	mov    (%eax),%esi
  800815:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80081f:	eb 13                	jmp    800834 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800821:	89 ca                	mov    %ecx,%edx
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 63 fc ff ff       	call   80048e <getuint>
  80082b:	89 c6                	mov    %eax,%esi
  80082d:	89 d7                	mov    %edx,%edi
			base = 16;
  80082f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800834:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800838:	89 54 24 10          	mov    %edx,0x10(%esp)
  80083c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80083f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800843:	89 44 24 08          	mov    %eax,0x8(%esp)
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80084e:	89 da                	mov    %ebx,%edx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	e8 6c fb ff ff       	call   8003c4 <printnum>
			break;
  800858:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80085b:	e9 cd fc ff ff       	jmp    80052d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800860:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80086d:	e9 bb fc ff ff       	jmp    80052d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800876:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80087d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800880:	eb 01                	jmp    800883 <vprintfmt+0x379>
  800882:	4e                   	dec    %esi
  800883:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800887:	75 f9                	jne    800882 <vprintfmt+0x378>
  800889:	e9 9f fc ff ff       	jmp    80052d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80088e:	83 c4 4c             	add    $0x4c,%esp
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5f                   	pop    %edi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 28             	sub    $0x28,%esp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	74 30                	je     8008e7 <vsnprintf+0x51>
  8008b7:	85 d2                	test   %edx,%edx
  8008b9:	7e 33                	jle    8008ee <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d0:	c7 04 24 c8 04 80 00 	movl   $0x8004c8,(%esp)
  8008d7:	e8 2e fc ff ff       	call   80050a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e5:	eb 0c                	jmp    8008f3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ec:	eb 05                	jmp    8008f3 <vsnprintf+0x5d>
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800902:	8b 45 10             	mov    0x10(%ebp),%eax
  800905:	89 44 24 08          	mov    %eax,0x8(%esp)
  800909:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	89 04 24             	mov    %eax,(%esp)
  800916:	e8 7b ff ff ff       	call   800896 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    
  80091d:	00 00                	add    %al,(%eax)
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 01                	jmp    80092e <strlen+0xe>
		n++;
  80092d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800932:	75 f9                	jne    80092d <strlen+0xd>
		n++;
	return n;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb 01                	jmp    800947 <strnlen+0x11>
		n++;
  800946:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	39 d0                	cmp    %edx,%eax
  800949:	74 06                	je     800951 <strnlen+0x1b>
  80094b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80094f:	75 f5                	jne    800946 <strnlen+0x10>
		n++;
	return n;
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800965:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800968:	42                   	inc    %edx
  800969:	84 c9                	test   %cl,%cl
  80096b:	75 f5                	jne    800962 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097a:	89 1c 24             	mov    %ebx,(%esp)
  80097d:	e8 9e ff ff ff       	call   800920 <strlen>
	strcpy(dst + len, src);
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 54 24 04          	mov    %edx,0x4(%esp)
  800989:	01 d8                	add    %ebx,%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 c0 ff ff ff       	call   800953 <strcpy>
	return dst;
}
  800993:	89 d8                	mov    %ebx,%eax
  800995:	83 c4 08             	add    $0x8,%esp
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ae:	eb 0c                	jmp    8009bc <strncpy+0x21>
		*dst++ = *src;
  8009b0:	8a 1a                	mov    (%edx),%bl
  8009b2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bb:	41                   	inc    %ecx
  8009bc:	39 f1                	cmp    %esi,%ecx
  8009be:	75 f0                	jne    8009b0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d2:	85 d2                	test   %edx,%edx
  8009d4:	75 0a                	jne    8009e0 <strlcpy+0x1c>
  8009d6:	89 f0                	mov    %esi,%eax
  8009d8:	eb 1a                	jmp    8009f4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009da:	88 18                	mov    %bl,(%eax)
  8009dc:	40                   	inc    %eax
  8009dd:	41                   	inc    %ecx
  8009de:	eb 02                	jmp    8009e2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009e2:	4a                   	dec    %edx
  8009e3:	74 0a                	je     8009ef <strlcpy+0x2b>
  8009e5:	8a 19                	mov    (%ecx),%bl
  8009e7:	84 db                	test   %bl,%bl
  8009e9:	75 ef                	jne    8009da <strlcpy+0x16>
  8009eb:	89 c2                	mov    %eax,%edx
  8009ed:	eb 02                	jmp    8009f1 <strlcpy+0x2d>
  8009ef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009f1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009f4:	29 f0                	sub    %esi,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a03:	eb 02                	jmp    800a07 <strcmp+0xd>
		p++, q++;
  800a05:	41                   	inc    %ecx
  800a06:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a07:	8a 01                	mov    (%ecx),%al
  800a09:	84 c0                	test   %al,%al
  800a0b:	74 04                	je     800a11 <strcmp+0x17>
  800a0d:	3a 02                	cmp    (%edx),%al
  800a0f:	74 f4                	je     800a05 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a11:	0f b6 c0             	movzbl %al,%eax
  800a14:	0f b6 12             	movzbl (%edx),%edx
  800a17:	29 d0                	sub    %edx,%eax
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a25:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a28:	eb 03                	jmp    800a2d <strncmp+0x12>
		n--, p++, q++;
  800a2a:	4a                   	dec    %edx
  800a2b:	40                   	inc    %eax
  800a2c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2d:	85 d2                	test   %edx,%edx
  800a2f:	74 14                	je     800a45 <strncmp+0x2a>
  800a31:	8a 18                	mov    (%eax),%bl
  800a33:	84 db                	test   %bl,%bl
  800a35:	74 04                	je     800a3b <strncmp+0x20>
  800a37:	3a 19                	cmp    (%ecx),%bl
  800a39:	74 ef                	je     800a2a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3b:	0f b6 00             	movzbl (%eax),%eax
  800a3e:	0f b6 11             	movzbl (%ecx),%edx
  800a41:	29 d0                	sub    %edx,%eax
  800a43:	eb 05                	jmp    800a4a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a56:	eb 05                	jmp    800a5d <strchr+0x10>
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	74 0c                	je     800a68 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5c:	40                   	inc    %eax
  800a5d:	8a 10                	mov    (%eax),%dl
  800a5f:	84 d2                	test   %dl,%dl
  800a61:	75 f5                	jne    800a58 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a73:	eb 05                	jmp    800a7a <strfind+0x10>
		if (*s == c)
  800a75:	38 ca                	cmp    %cl,%dl
  800a77:	74 07                	je     800a80 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a79:	40                   	inc    %eax
  800a7a:	8a 10                	mov    (%eax),%dl
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	75 f5                	jne    800a75 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 30                	je     800ac5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9b:	75 25                	jne    800ac2 <memset+0x40>
  800a9d:	f6 c1 03             	test   $0x3,%cl
  800aa0:	75 20                	jne    800ac2 <memset+0x40>
		c &= 0xFF;
  800aa2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	c1 e3 08             	shl    $0x8,%ebx
  800aaa:	89 d6                	mov    %edx,%esi
  800aac:	c1 e6 18             	shl    $0x18,%esi
  800aaf:	89 d0                	mov    %edx,%eax
  800ab1:	c1 e0 10             	shl    $0x10,%eax
  800ab4:	09 f0                	or     %esi,%eax
  800ab6:	09 d0                	or     %edx,%eax
  800ab8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800abd:	fc                   	cld    
  800abe:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac0:	eb 03                	jmp    800ac5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac2:	fc                   	cld    
  800ac3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac5:	89 f8                	mov    %edi,%eax
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ada:	39 c6                	cmp    %eax,%esi
  800adc:	73 34                	jae    800b12 <memmove+0x46>
  800ade:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae1:	39 d0                	cmp    %edx,%eax
  800ae3:	73 2d                	jae    800b12 <memmove+0x46>
		s += n;
		d += n;
  800ae5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c2 03             	test   $0x3,%dl
  800aeb:	75 1b                	jne    800b08 <memmove+0x3c>
  800aed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af3:	75 13                	jne    800b08 <memmove+0x3c>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 0e                	jne    800b08 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800afa:	83 ef 04             	sub    $0x4,%edi
  800afd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b03:	fd                   	std    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 07                	jmp    800b0f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b08:	4f                   	dec    %edi
  800b09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0c:	fd                   	std    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0f:	fc                   	cld    
  800b10:	eb 20                	jmp    800b32 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b18:	75 13                	jne    800b2d <memmove+0x61>
  800b1a:	a8 03                	test   $0x3,%al
  800b1c:	75 0f                	jne    800b2d <memmove+0x61>
  800b1e:	f6 c1 03             	test   $0x3,%cl
  800b21:	75 0a                	jne    800b2d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b26:	89 c7                	mov    %eax,%edi
  800b28:	fc                   	cld    
  800b29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2b:	eb 05                	jmp    800b32 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	fc                   	cld    
  800b30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	89 04 24             	mov    %eax,(%esp)
  800b50:	e8 77 ff ff ff       	call   800acc <memmove>
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	eb 16                	jmp    800b83 <memcmp+0x2c>
		if (*s1 != *s2)
  800b6d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b70:	42                   	inc    %edx
  800b71:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b75:	38 c8                	cmp    %cl,%al
  800b77:	74 0a                	je     800b83 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c0             	movzbl %al,%eax
  800b7c:	0f b6 c9             	movzbl %cl,%ecx
  800b7f:	29 c8                	sub    %ecx,%eax
  800b81:	eb 09                	jmp    800b8c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b83:	39 da                	cmp    %ebx,%edx
  800b85:	75 e6                	jne    800b6d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9a:	89 c2                	mov    %eax,%edx
  800b9c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9f:	eb 05                	jmp    800ba6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba1:	38 08                	cmp    %cl,(%eax)
  800ba3:	74 05                	je     800baa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba5:	40                   	inc    %eax
  800ba6:	39 d0                	cmp    %edx,%eax
  800ba8:	72 f7                	jb     800ba1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	eb 01                	jmp    800bbb <strtol+0xf>
		s++;
  800bba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbb:	8a 02                	mov    (%edx),%al
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f9                	je     800bba <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f5                	je     800bba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	75 08                	jne    800bd1 <strtol+0x25>
		s++;
  800bc9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcf:	eb 13                	jmp    800be4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd1:	3c 2d                	cmp    $0x2d,%al
  800bd3:	75 0a                	jne    800bdf <strtol+0x33>
		s++, neg = 1;
  800bd5:	8d 52 01             	lea    0x1(%edx),%edx
  800bd8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bdd:	eb 05                	jmp    800be4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be4:	85 db                	test   %ebx,%ebx
  800be6:	74 05                	je     800bed <strtol+0x41>
  800be8:	83 fb 10             	cmp    $0x10,%ebx
  800beb:	75 28                	jne    800c15 <strtol+0x69>
  800bed:	8a 02                	mov    (%edx),%al
  800bef:	3c 30                	cmp    $0x30,%al
  800bf1:	75 10                	jne    800c03 <strtol+0x57>
  800bf3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bf7:	75 0a                	jne    800c03 <strtol+0x57>
		s += 2, base = 16;
  800bf9:	83 c2 02             	add    $0x2,%edx
  800bfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c01:	eb 12                	jmp    800c15 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	75 0e                	jne    800c15 <strtol+0x69>
  800c07:	3c 30                	cmp    $0x30,%al
  800c09:	75 05                	jne    800c10 <strtol+0x64>
		s++, base = 8;
  800c0b:	42                   	inc    %edx
  800c0c:	b3 08                	mov    $0x8,%bl
  800c0e:	eb 05                	jmp    800c15 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c10:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1c:	8a 0a                	mov    (%edx),%cl
  800c1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c21:	80 fb 09             	cmp    $0x9,%bl
  800c24:	77 08                	ja     800c2e <strtol+0x82>
			dig = *s - '0';
  800c26:	0f be c9             	movsbl %cl,%ecx
  800c29:	83 e9 30             	sub    $0x30,%ecx
  800c2c:	eb 1e                	jmp    800c4c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c31:	80 fb 19             	cmp    $0x19,%bl
  800c34:	77 08                	ja     800c3e <strtol+0x92>
			dig = *s - 'a' + 10;
  800c36:	0f be c9             	movsbl %cl,%ecx
  800c39:	83 e9 57             	sub    $0x57,%ecx
  800c3c:	eb 0e                	jmp    800c4c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 12                	ja     800c58 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c46:	0f be c9             	movsbl %cl,%ecx
  800c49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c4c:	39 f1                	cmp    %esi,%ecx
  800c4e:	7d 0c                	jge    800c5c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c50:	42                   	inc    %edx
  800c51:	0f af c6             	imul   %esi,%eax
  800c54:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c56:	eb c4                	jmp    800c1c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c58:	89 c1                	mov    %eax,%ecx
  800c5a:	eb 02                	jmp    800c5e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c5c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c62:	74 05                	je     800c69 <strtol+0xbd>
		*endptr = (char *) s;
  800c64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c67:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c69:	85 ff                	test   %edi,%edi
  800c6b:	74 04                	je     800c71 <strtol+0xc5>
  800c6d:	89 c8                	mov    %ecx,%eax
  800c6f:	f7 d8                	neg    %eax
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
	...

00800c78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 c3                	mov    %eax,%ebx
  800c8b:	89 c7                	mov    %eax,%edi
  800c8d:	89 c6                	mov    %eax,%esi
  800c8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	89 d7                	mov    %edx,%edi
  800cac:	89 d6                	mov    %edx,%esi
  800cae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 cb                	mov    %ecx,%ebx
  800ccd:	89 cf                	mov    %ecx,%edi
  800ccf:	89 ce                	mov    %ecx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800cfa:	e8 b1 f5 ff ff       	call   8002b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 02 00 00 00       	mov    $0x2,%eax
  800d17:	89 d1                	mov    %edx,%ecx
  800d19:	89 d3                	mov    %edx,%ebx
  800d1b:	89 d7                	mov    %edx,%edi
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_yield>:

void
sys_yield(void)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d36:	89 d1                	mov    %edx,%ecx
  800d38:	89 d3                	mov    %edx,%ebx
  800d3a:	89 d7                	mov    %edx,%edi
  800d3c:	89 d6                	mov    %edx,%esi
  800d3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 04 00 00 00       	mov    $0x4,%eax
  800d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 f7                	mov    %esi,%edi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 28                	jle    800d91 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d74:	00 
  800d75:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d84:	00 
  800d85:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800d8c:	e8 1f f5 ff ff       	call   8002b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d91:	83 c4 2c             	add    $0x2c,%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	b8 05 00 00 00       	mov    $0x5,%eax
  800da7:	8b 75 18             	mov    0x18(%ebp),%esi
  800daa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7e 28                	jle    800de4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dc7:	00 
  800dc8:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd7:	00 
  800dd8:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800ddf:	e8 cc f4 ff ff       	call   8002b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de4:	83 c4 2c             	add    $0x2c,%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 28                	jle    800e37 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800e22:	00 
  800e23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2a:	00 
  800e2b:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800e32:	e8 79 f4 ff ff       	call   8002b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e37:	83 c4 2c             	add    $0x2c,%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 28                	jle    800e8a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e66:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800e75:	00 
  800e76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7d:	00 
  800e7e:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800e85:	e8 26 f4 ff ff       	call   8002b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8a:	83 c4 2c             	add    $0x2c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	89 df                	mov    %ebx,%edi
  800ead:	89 de                	mov    %ebx,%esi
  800eaf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	7e 28                	jle    800edd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800ed8:	e8 d3 f3 ff ff       	call   8002b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800edd:	83 c4 2c             	add    $0x2c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
  800ef0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 cb                	mov    %ecx,%ebx
  800f20:	89 cf                	mov    %ecx,%edi
  800f22:	89 ce                	mov    %ecx,%esi
  800f24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 28                	jle    800f52 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800f35:	00 
  800f36:	c7 44 24 08 c8 14 80 	movl   $0x8014c8,0x8(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f45:	00 
  800f46:	c7 04 24 e5 14 80 00 	movl   $0x8014e5,(%esp)
  800f4d:	e8 5e f3 ff ff       	call   8002b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f52:	83 c4 2c             	add    $0x2c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
	...

00800f5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800f5c:	55                   	push   %ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	83 ec 10             	sub    $0x10,%esp
  800f62:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f66:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800f72:	89 cd                	mov    %ecx,%ebp
  800f74:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	75 2c                	jne    800fa8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800f7c:	39 f9                	cmp    %edi,%ecx
  800f7e:	77 68                	ja     800fe8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f8f:	31 d2                	xor    %edx,%edx
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	f7 f1                	div    %ecx
  800f95:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f1                	div    %ecx
  800f9b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f9d:	89 f0                	mov    %esi,%eax
  800f9f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fa8:	39 f8                	cmp    %edi,%eax
  800faa:	77 2c                	ja     800fd8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fac:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800faf:	83 f6 1f             	xor    $0x1f,%esi
  800fb2:	75 4c                	jne    801000 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fb6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fbb:	72 0a                	jb     800fc7 <__udivdi3+0x6b>
  800fbd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800fc1:	0f 87 ad 00 00 00    	ja     801074 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fc7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fcc:	89 f0                	mov    %esi,%eax
  800fce:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    
  800fd7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fd8:	31 ff                	xor    %edi,%edi
  800fda:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800fdc:	89 f0                	mov    %esi,%eax
  800fde:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    
  800fe7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fe8:	89 fa                	mov    %edi,%edx
  800fea:	89 f0                	mov    %esi,%eax
  800fec:	f7 f1                	div    %ecx
  800fee:	89 c6                	mov    %eax,%esi
  800ff0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ff2:	89 f0                	mov    %esi,%eax
  800ff4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801000:	89 f1                	mov    %esi,%ecx
  801002:	d3 e0                	shl    %cl,%eax
  801004:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801008:	b8 20 00 00 00       	mov    $0x20,%eax
  80100d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80100f:	89 ea                	mov    %ebp,%edx
  801011:	88 c1                	mov    %al,%cl
  801013:	d3 ea                	shr    %cl,%edx
  801015:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801019:	09 ca                	or     %ecx,%edx
  80101b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80101f:	89 f1                	mov    %esi,%ecx
  801021:	d3 e5                	shl    %cl,%ebp
  801023:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801027:	89 fd                	mov    %edi,%ebp
  801029:	88 c1                	mov    %al,%cl
  80102b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80102d:	89 fa                	mov    %edi,%edx
  80102f:	89 f1                	mov    %esi,%ecx
  801031:	d3 e2                	shl    %cl,%edx
  801033:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801037:	88 c1                	mov    %al,%cl
  801039:	d3 ef                	shr    %cl,%edi
  80103b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80103d:	89 f8                	mov    %edi,%eax
  80103f:	89 ea                	mov    %ebp,%edx
  801041:	f7 74 24 08          	divl   0x8(%esp)
  801045:	89 d1                	mov    %edx,%ecx
  801047:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801049:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80104d:	39 d1                	cmp    %edx,%ecx
  80104f:	72 17                	jb     801068 <__udivdi3+0x10c>
  801051:	74 09                	je     80105c <__udivdi3+0x100>
  801053:	89 fe                	mov    %edi,%esi
  801055:	31 ff                	xor    %edi,%edi
  801057:	e9 41 ff ff ff       	jmp    800f9d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80105c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801060:	89 f1                	mov    %esi,%ecx
  801062:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801064:	39 c2                	cmp    %eax,%edx
  801066:	73 eb                	jae    801053 <__udivdi3+0xf7>
		{
		  q0--;
  801068:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80106b:	31 ff                	xor    %edi,%edi
  80106d:	e9 2b ff ff ff       	jmp    800f9d <__udivdi3+0x41>
  801072:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801074:	31 f6                	xor    %esi,%esi
  801076:	e9 22 ff ff ff       	jmp    800f9d <__udivdi3+0x41>
	...

0080107c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80107c:	55                   	push   %ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	83 ec 20             	sub    $0x20,%esp
  801082:	8b 44 24 30          	mov    0x30(%esp),%eax
  801086:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80108a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80108e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801092:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801096:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80109a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80109c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80109e:	85 ed                	test   %ebp,%ebp
  8010a0:	75 16                	jne    8010b8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8010a2:	39 f1                	cmp    %esi,%ecx
  8010a4:	0f 86 a6 00 00 00    	jbe    801150 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010aa:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8010ac:	89 d0                	mov    %edx,%eax
  8010ae:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010b0:	83 c4 20             	add    $0x20,%esp
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    
  8010b7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010b8:	39 f5                	cmp    %esi,%ebp
  8010ba:	0f 87 ac 00 00 00    	ja     80116c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010c0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8010c3:	83 f0 1f             	xor    $0x1f,%eax
  8010c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ca:	0f 84 a8 00 00 00    	je     801178 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010d0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010d4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8010d6:	bf 20 00 00 00       	mov    $0x20,%edi
  8010db:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8010df:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010e3:	89 f9                	mov    %edi,%ecx
  8010e5:	d3 e8                	shr    %cl,%eax
  8010e7:	09 e8                	or     %ebp,%eax
  8010e9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8010ed:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010f1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010f5:	d3 e0                	shl    %cl,%eax
  8010f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010fb:	89 f2                	mov    %esi,%edx
  8010fd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8010ff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801103:	d3 e0                	shl    %cl,%eax
  801105:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801109:	8b 44 24 14          	mov    0x14(%esp),%eax
  80110d:	89 f9                	mov    %edi,%ecx
  80110f:	d3 e8                	shr    %cl,%eax
  801111:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801113:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801115:	89 f2                	mov    %esi,%edx
  801117:	f7 74 24 18          	divl   0x18(%esp)
  80111b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80111d:	f7 64 24 0c          	mull   0xc(%esp)
  801121:	89 c5                	mov    %eax,%ebp
  801123:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801125:	39 d6                	cmp    %edx,%esi
  801127:	72 67                	jb     801190 <__umoddi3+0x114>
  801129:	74 75                	je     8011a0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80112b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80112f:	29 e8                	sub    %ebp,%eax
  801131:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801133:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 f2                	mov    %esi,%edx
  80113b:	89 f9                	mov    %edi,%ecx
  80113d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80113f:	09 d0                	or     %edx,%eax
  801141:	89 f2                	mov    %esi,%edx
  801143:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801147:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801150:	85 c9                	test   %ecx,%ecx
  801152:	75 0b                	jne    80115f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f1                	div    %ecx
  80115d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801165:	89 f8                	mov    %edi,%eax
  801167:	e9 3e ff ff ff       	jmp    8010aa <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80116c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80116e:	83 c4 20             	add    $0x20,%esp
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    
  801175:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801178:	39 f5                	cmp    %esi,%ebp
  80117a:	72 04                	jb     801180 <__umoddi3+0x104>
  80117c:	39 f9                	cmp    %edi,%ecx
  80117e:	77 06                	ja     801186 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801180:	89 f2                	mov    %esi,%edx
  801182:	29 cf                	sub    %ecx,%edi
  801184:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801186:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    
  80118f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801190:	89 d1                	mov    %edx,%ecx
  801192:	89 c5                	mov    %eax,%ebp
  801194:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801198:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80119c:	eb 8d                	jmp    80112b <__umoddi3+0xaf>
  80119e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011a0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8011a4:	72 ea                	jb     801190 <__umoddi3+0x114>
  8011a6:	89 f1                	mov    %esi,%ecx
  8011a8:	eb 81                	jmp    80112b <__umoddi3+0xaf>
