
obj/user/stresssched：     文件格式 elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 86 0b 00 00       	call   800bc7 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 0b 0f 00 00       	call   800f58 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 83 0b 00 00       	call   800be6 <sys_yield>
		return;
  800063:	e9 97 00 00 00       	jmp    8000ff <umain+0xcb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 1a                	jmp    800086 <umain+0x52>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800079:	89 f2                	mov    %esi,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	8b 42 50             	mov    0x50(%edx),%eax
  800089:	85 c0                	test   %eax,%eax
  80008b:	75 db                	jne    800068 <umain+0x34>
  80008d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800092:	e8 4f 0b 00 00       	call   800be6 <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a9:	48                   	dec    %eax
  8000aa:	75 f0                	jne    80009c <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ac:	4b                   	dec    %ebx
  8000ad:	75 e3                	jne    800092 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000af:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 60 15 80 	movl   $0x801560,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  8000db:	e8 90 00 00 00       	call   800170 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e5:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e8:	8b 40 48             	mov    0x48(%eax),%eax
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 9b 15 80 00 	movl   $0x80159b,(%esp)
  8000fa:	e8 69 01 00 00       	call   800268 <cprintf>

}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
	...

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 10             	sub    $0x10,%esp
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800116:	e8 ac 0a 00 00       	call   800bc7 <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 08 20 80 00       	mov    %eax,0x802008

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 f6                	test   %esi,%esi
  800138:	7e 07                	jle    800141 <libmain+0x39>
		binaryname = argv[0];
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800145:	89 34 24             	mov    %esi,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014d:	e8 0a 00 00 00       	call   80015c <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800169:	e8 07 0a 00 00       	call   800b75 <sys_env_destroy>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800181:	e8 41 0a 00 00       	call   800bc7 <sys_getenvid>
  800186:	8b 55 0c             	mov    0xc(%ebp),%edx
  800189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800194:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 c4 15 80 00 	movl   $0x8015c4,(%esp)
  8001a3:	e8 c0 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 50 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001b7:	c7 04 24 8f 19 80 00 	movl   $0x80198f,(%esp)
  8001be:	e8 a5 00 00 00       	call   800268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x53>
	...

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 19                	jne    8001fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ec:	00 
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 40 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fe:	ff 43 04             	incl   0x4(%ebx)
}
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	5b                   	pop    %ebx
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800243:	e8 82 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 d8 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 87 ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	75 08                	jne    8002b0 <printnum+0x2c>
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 57                	ja     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b4:	4b                   	dec    %ebx
  8002b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 1a 10 00 00       	call   8012fc <__udivdi3>
  8002e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f6:	e8 89 ff ff ff       	call   800284 <printnum>
  8002fb:	eb 0f                	jmp    80030c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 34 24             	mov    %esi,(%esp)
  800304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	4b                   	dec    %ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f f1                	jg     8002fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 e7 10 00 00       	call   80141c <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 e7 15 80 00 	movsbl 0x8015e7(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 08                	jae    8003a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 0a                	mov    %cl,(%edx)
  80039d:	42                   	inc    %edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 4c             	sub    $0x4c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 6b 03 00 00    	je     80074e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e5                	jne    8003db <vprintfmt+0x11>
  8003f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 26                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041b:	eb 1d                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800424:	eb 14                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	eb 08                	jmp    80043a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 06             	movzbl (%esi),%eax
  80043d:	8d 56 01             	lea    0x1(%esi),%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	8a 16                	mov    (%esi),%dl
  800445:	83 ea 23             	sub    $0x23,%edx
  800448:	80 fa 55             	cmp    $0x55,%dl
  80044b:	0f 87 e1 02 00 00    	ja     800732 <vprintfmt+0x368>
  800451:	0f b6 d2             	movzbl %dl,%edx
  800454:	ff 24 95 a0 16 80 00 	jmp    *0x8016a0(,%edx,4)
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	77 2a                	ja     80049f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb eb                	jmp    800463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800486:	eb 17                	jmp    80049f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048c:	78 98                	js     800426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800491:	eb a7                	jmp    80043a <vprintfmt+0x70>
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049d:	eb 9b                	jmp    80043a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	79 95                	jns    80043a <vprintfmt+0x70>
  8004a5:	eb 8b                	jmp    800432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c5:	e9 23 ff ff ff       	jmp    8003ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <vprintfmt+0x111>
  8004d9:	f7 d8                	neg    %eax
  8004db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 09             	cmp    $0x9,%eax
  8004e0:	7f 0b                	jg     8004ed <vprintfmt+0x123>
  8004e2:	8b 04 85 00 18 80 00 	mov    0x801800(,%eax,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 23                	jne    800510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  8004f8:	00 
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 9a fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 dd fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 08 16 80 	movl   $0x801608,0x8(%esp)
  80051b:	00 
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 14 24             	mov    %edx,(%esp)
  800526:	e8 77 fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052e:	e9 ba fe ff ff       	jmp    8003ed <vprintfmt+0x23>
  800533:	89 f9                	mov    %edi,%ecx
  800535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	85 f6                	test   %esi,%esi
  800548:	75 05                	jne    80054f <vprintfmt+0x185>
				p = "(null)";
  80054a:	be f8 15 80 00       	mov    $0x8015f8,%esi
			if (width > 0 && padc != '-')
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	0f 8e 84 00 00 00    	jle    8005dd <vprintfmt+0x213>
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	74 7e                	je     8005dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 8b 02 00 00       	call   8007f6 <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057d:	89 de                	mov    %ebx,%esi
  80057f:	89 d3                	mov    %edx,%ebx
  800581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f f1                	jg     800585 <vprintfmt+0x1bb>
  800594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800597:	89 f3                	mov    %esi,%ebx
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	79 05                	jns    8005a8 <vprintfmt+0x1de>
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x206>
  8005b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bb:	83 fa 5e             	cmp    $0x5e,%edx
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x206>
					putch('?', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	eb 0a                	jmp    8005da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	ff 4d e4             	decl   -0x1c(%ebp)
  8005dd:	0f be 06             	movsbl (%esi),%eax
  8005e0:	46                   	inc    %esi
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	74 21                	je     800606 <vprintfmt+0x23c>
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	78 c9                	js     8005b2 <vprintfmt+0x1e8>
  8005e9:	4f                   	dec    %edi
  8005ea:	79 c6                	jns    8005b2 <vprintfmt+0x1e8>
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 de                	mov    %ebx,%esi
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	eb 18                	jmp    80060e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	eb 08                	jmp    80060e <vprintfmt+0x244>
  800606:	8b 7d 08             	mov    0x8(%ebp),%edi
  800609:	89 de                	mov    %ebx,%esi
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f e4                	jg     8005f6 <vprintfmt+0x22c>
  800612:	89 7d 08             	mov    %edi,0x8(%ebp)
  800615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	e9 ce fd ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 10                	jle    800634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	8b 78 04             	mov    0x4(%eax),%edi
  800632:	eb 26                	jmp    80065a <vprintfmt+0x290>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	74 12                	je     80064a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	89 f7                	mov    %esi,%edi
  800645:	c1 ff 1f             	sar    $0x1f,%edi
  800648:	eb 10                	jmp    80065a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 f7                	mov    %esi,%edi
  800657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065a:	85 ff                	test   %edi,%edi
  80065c:	78 0a                	js     800668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 8c 00 00 00       	jmp    8006f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800676:	f7 de                	neg    %esi
  800678:	83 d7 00             	adc    $0x0,%edi
  80067b:	f7 df                	neg    %edi
			}
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	eb 70                	jmp    8006f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 c0 fc ff ff       	call   80034e <getuint>
  80068e:	89 c6                	mov    %eax,%esi
  800690:	89 d7                	mov    %edx,%edi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 5b                	jmp    8006f4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 ab fc ff ff       	call   80034e <getuint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
                        base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8006ac:	eb 46                	jmp    8006f4 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	eb 13                	jmp    8006f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 63 fc ff ff       	call   80034e <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800703:	89 44 24 08          	mov    %eax,0x8(%esp)
  800707:	89 34 24             	mov    %esi,(%esp)
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	89 da                	mov    %ebx,%edx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	e8 6c fb ff ff       	call   800284 <printnum>
			break;
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071b:	e9 cd fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072d:	e9 bb fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	eb 01                	jmp    800743 <vprintfmt+0x379>
  800742:	4e                   	dec    %esi
  800743:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800747:	75 f9                	jne    800742 <vprintfmt+0x378>
  800749:	e9 9f fc ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074e:	83 c4 4c             	add    $0x4c,%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 28             	sub    $0x28,%esp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800769:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800773:	85 c0                	test   %eax,%eax
  800775:	74 30                	je     8007a7 <vsnprintf+0x51>
  800777:	85 d2                	test   %edx,%edx
  800779:	7e 33                	jle    8007ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800797:	e8 2e fc ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	eb 0c                	jmp    8007b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x5d>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 7b ff ff ff       	call   800756 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 01                	jmp    8007ee <strlen+0xe>
		n++;
  8007ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	75 f9                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	eb 01                	jmp    800807 <strnlen+0x11>
		n++;
  800806:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 d0                	cmp    %edx,%eax
  800809:	74 06                	je     800811 <strnlen+0x1b>
  80080b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080f:	75 f5                	jne    800806 <strnlen+0x10>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800825:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800828:	42                   	inc    %edx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f5                	jne    800822 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	89 1c 24             	mov    %ebx,(%esp)
  80083d:	e8 9e ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 54 24 04          	mov    %edx,0x4(%esp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 c0 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086e:	eb 0c                	jmp    80087c <strncpy+0x21>
		*dst++ = *src;
  800870:	8a 1a                	mov    (%edx),%bl
  800872:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 3a 01             	cmpb   $0x1,(%edx)
  800878:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	41                   	inc    %ecx
  80087c:	39 f1                	cmp    %esi,%ecx
  80087e:	75 f0                	jne    800870 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	75 0a                	jne    8008a0 <strlcpy+0x1c>
  800896:	89 f0                	mov    %esi,%eax
  800898:	eb 1a                	jmp    8008b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	88 18                	mov    %bl,(%eax)
  80089c:	40                   	inc    %eax
  80089d:	41                   	inc    %ecx
  80089e:	eb 02                	jmp    8008a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a2:	4a                   	dec    %edx
  8008a3:	74 0a                	je     8008af <strlcpy+0x2b>
  8008a5:	8a 19                	mov    (%ecx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	75 ef                	jne    80089a <strlcpy+0x16>
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	eb 02                	jmp    8008b1 <strlcpy+0x2d>
  8008af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 02                	jmp    8008c7 <strcmp+0xd>
		p++, q++;
  8008c5:	41                   	inc    %ecx
  8008c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c7:	8a 01                	mov    (%ecx),%al
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x17>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 f4                	je     8008c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 03                	jmp    8008ed <strncmp+0x12>
		n--, p++, q++;
  8008ea:	4a                   	dec    %edx
  8008eb:	40                   	inc    %eax
  8008ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 14                	je     800905 <strncmp+0x2a>
  8008f1:	8a 18                	mov    (%eax),%bl
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 04                	je     8008fb <strncmp+0x20>
  8008f7:	3a 19                	cmp    (%ecx),%bl
  8008f9:	74 ef                	je     8008ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 11             	movzbl (%ecx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb 05                	jmp    80090a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	eb 05                	jmp    80091d <strchr+0x10>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0c                	je     800928 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800933:	eb 05                	jmp    80093a <strfind+0x10>
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 07                	je     800940 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800939:	40                   	inc    %eax
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f5                	jne    800935 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 30                	je     800985 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 25                	jne    800982 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 20                	jne    800982 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 08             	shl    $0x8,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 18             	shl    $0x18,%esi
  80096f:	89 d0                	mov    %edx,%eax
  800971:	c1 e0 10             	shl    $0x10,%eax
  800974:	09 f0                	or     %esi,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb 03                	jmp    800985 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 34                	jae    8009d2 <memmove+0x46>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2d                	jae    8009d2 <memmove+0x46>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	75 1b                	jne    8009c8 <memmove+0x3c>
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3c>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 07                	jmp    8009cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c8:	4f                   	dec    %edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 20                	jmp    8009f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 13                	jne    8009ed <memmove+0x61>
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 0f                	jne    8009ed <memmove+0x61>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0a                	jne    8009ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 77 ff ff ff       	call   80098c <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	eb 16                	jmp    800a43 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a30:	42                   	inc    %edx
  800a31:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a35:	38 c8                	cmp    %cl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 c9             	movzbl %cl,%ecx
  800a3f:	29 c8                	sub    %ecx,%eax
  800a41:	eb 09                	jmp    800a4c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 e6                	jne    800a2d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	eb 05                	jmp    800a66 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 05                	je     800a6a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	40                   	inc    %eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	72 f7                	jb     800a61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 01                	jmp    800a7b <strtol+0xf>
		s++;
  800a7a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	8a 02                	mov    (%edx),%al
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f9                	je     800a7a <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f5                	je     800a7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 08                	jne    800a91 <strtol+0x25>
		s++;
  800a89:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 13                	jmp    800aa4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	75 0a                	jne    800a9f <strtol+0x33>
		s++, neg = 1;
  800a95:	8d 52 01             	lea    0x1(%edx),%edx
  800a98:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9d:	eb 05                	jmp    800aa4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	74 05                	je     800aad <strtol+0x41>
  800aa8:	83 fb 10             	cmp    $0x10,%ebx
  800aab:	75 28                	jne    800ad5 <strtol+0x69>
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 10                	jne    800ac3 <strtol+0x57>
  800ab3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab7:	75 0a                	jne    800ac3 <strtol+0x57>
		s += 2, base = 16;
  800ab9:	83 c2 02             	add    $0x2,%edx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb 12                	jmp    800ad5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 0e                	jne    800ad5 <strtol+0x69>
  800ac7:	3c 30                	cmp    $0x30,%al
  800ac9:	75 05                	jne    800ad0 <strtol+0x64>
		s++, base = 8;
  800acb:	42                   	inc    %edx
  800acc:	b3 08                	mov    $0x8,%bl
  800ace:	eb 05                	jmp    800ad5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	8a 0a                	mov    (%edx),%cl
  800ade:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x82>
			dig = *s - '0';
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 30             	sub    $0x30,%ecx
  800aec:	eb 1e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x92>
			dig = *s - 'a' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 57             	sub    $0x57,%ecx
  800afc:	eb 0e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 12                	ja     800b18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	7d 0c                	jge    800b1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b10:	42                   	inc    %edx
  800b11:	0f af c6             	imul   %esi,%eax
  800b14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb c4                	jmp    800adc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	eb 02                	jmp    800b1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 05                	je     800b29 <strtol+0xbd>
		*endptr = (char *) s;
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	74 04                	je     800b31 <strtol+0xc5>
  800b2d:	89 c8                	mov    %ecx,%eax
  800b2f:	f7 d8                	neg    %eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
	...

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 28                	jle    800bbf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800baa:	00 
  800bab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb2:	00 
  800bb3:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800bba:	e8 b1 f5 ff ff       	call   800170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbf:	83 c4 2c             	add    $0x2c,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	b8 04 00 00 00       	mov    $0x4,%eax
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 28                	jle    800c51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c34:	00 
  800c35:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c44:	00 
  800c45:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800c4c:	e8 1f f5 ff ff       	call   800170 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c51:	83 c4 2c             	add    $0x2c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 28                	jle    800ca4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c87:	00 
  800c88:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c97:	00 
  800c98:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800c9f:	e8 cc f4 ff ff       	call   800170 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca4:	83 c4 2c             	add    $0x2c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 28                	jle    800cf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cda:	00 
  800cdb:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cea:	00 
  800ceb:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800cf2:	e8 79 f4 ff ff       	call   800170 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	83 c4 2c             	add    $0x2c,%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 28                	jle    800d4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800d35:	00 
  800d36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3d:	00 
  800d3e:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800d45:	e8 26 f4 ff ff       	call   800170 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4a:	83 c4 2c             	add    $0x2c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d60:	b8 09 00 00 00       	mov    $0x9,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 df                	mov    %ebx,%edi
  800d6d:	89 de                	mov    %ebx,%esi
  800d6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 28                	jle    800d9d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d80:	00 
  800d81:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800d88:	00 
  800d89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d90:	00 
  800d91:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800d98:	e8 d3 f3 ff ff       	call   800170 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9d:	83 c4 2c             	add    $0x2c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 28                	jle    800e12 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dee:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df5:	00 
  800df6:	c7 44 24 08 28 18 80 	movl   $0x801828,0x8(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e05:	00 
  800e06:	c7 04 24 45 18 80 00 	movl   $0x801845,(%esp)
  800e0d:	e8 5e f3 ff ff       	call   800170 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e12:	83 c4 2c             	add    $0x2c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
	...

00800e1c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 20             	sub    $0x20,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) == 0){
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	c1 e8 0c             	shr    $0xc,%eax
  800e2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e35:	a9 02 08 00 00       	test   $0x802,%eax
  800e3a:	75 1c                	jne    800e58 <pgfault+0x3c>
            panic("phfault fail at perm of faulting access!\n");
  800e3c:	c7 44 24 08 54 18 80 	movl   $0x801854,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800e53:	e8 18 f3 ff ff       	call   800170 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t env_id = sys_getenvid();
  800e58:	e8 6a fd ff ff       	call   800bc7 <sys_getenvid>
  800e5d:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(env_id, (void *)PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  800e5f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e6e:	00 
  800e6f:	89 04 24             	mov    %eax,(%esp)
  800e72:	e8 8e fd ff ff       	call   800c05 <sys_page_alloc>
  800e77:	85 c0                	test   %eax,%eax
  800e79:	79 1c                	jns    800e97 <pgfault+0x7b>
            panic("pafault fail at page_alloc!\n");
  800e7b:	c7 44 24 08 21 19 80 	movl   $0x801921,0x8(%esp)
  800e82:	00 
  800e83:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800e8a:	00 
  800e8b:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800e92:	e8 d9 f2 ff ff       	call   800170 <_panic>
        addr = ROUNDDOWN(addr, PGSIZE);
  800e97:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e9d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ea4:	00 
  800ea5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800eb0:	e8 d7 fa ff ff       	call   80098c <memmove>
        if(sys_page_unmap(env_id, addr) < 0)
  800eb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eb9:	89 1c 24             	mov    %ebx,(%esp)
  800ebc:	e8 eb fd ff ff       	call   800cac <sys_page_unmap>
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 1c                	jns    800ee1 <pgfault+0xc5>
            panic("pafault fail at page_unmap addr!\n");
  800ec5:	c7 44 24 08 80 18 80 	movl   $0x801880,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800edc:	e8 8f f2 ff ff       	call   800170 <_panic>
        if(sys_page_map(env_id, PFTEMP, env_id, addr, PTE_P|PTE_U|PTE_W) < 0)
  800ee1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ee8:	00 
  800ee9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800eed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ef1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef8:	00 
  800ef9:	89 1c 24             	mov    %ebx,(%esp)
  800efc:	e8 58 fd ff ff       	call   800c59 <sys_page_map>
  800f01:	85 c0                	test   %eax,%eax
  800f03:	79 1c                	jns    800f21 <pgfault+0x105>
            panic("page_map fail at page_map!\n");
  800f05:	c7 44 24 08 3e 19 80 	movl   $0x80193e,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800f1c:	e8 4f f2 ff ff       	call   800170 <_panic>
        if(sys_page_unmap(env_id, PFTEMP) < 0)
  800f21:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f28:	00 
  800f29:	89 1c 24             	mov    %ebx,(%esp)
  800f2c:	e8 7b fd ff ff       	call   800cac <sys_page_unmap>
  800f31:	85 c0                	test   %eax,%eax
  800f33:	79 1c                	jns    800f51 <pgfault+0x135>
            panic("pafault fail at page_unmap PFTEMP!\n");
  800f35:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f44:	00 
  800f45:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800f4c:	e8 1f f2 ff ff       	call   800170 <_panic>
	//panic("pgfault not implemented");
}
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        set_pgfault_handler(pgfault);
  800f61:	c7 04 24 1c 0e 80 00 	movl   $0x800e1c,(%esp)
  800f68:	e8 db 02 00 00       	call   801248 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f6d:	ba 07 00 00 00       	mov    $0x7,%edx
  800f72:	89 d0                	mov    %edx,%eax
  800f74:	cd 30                	int    $0x30
  800f76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f79:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 1c                	jns    800f9c <fork+0x44>
            panic("fork fail at sys_exofork!\n");
  800f80:	c7 44 24 08 5a 19 80 	movl   $0x80195a,0x8(%esp)
  800f87:	00 
  800f88:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800f8f:	00 
  800f90:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  800f97:	e8 d4 f1 ff ff       	call   800170 <_panic>
        else if(env_id == 0){
  800f9c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800fa0:	75 25                	jne    800fc7 <fork+0x6f>
            thisenv = &envs[ENVX(sys_getenvid())];
  800fa2:	e8 20 fc ff ff       	call   800bc7 <sys_getenvid>
  800fa7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fb3:	c1 e0 07             	shl    $0x7,%eax
  800fb6:	29 d0                	sub    %edx,%eax
  800fb8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbd:	a3 08 20 80 00       	mov    %eax,0x802008
            return 0;
  800fc2:	e9 51 02 00 00       	jmp    801218 <fork+0x2c0>
        set_pgfault_handler(pgfault);
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
            panic("fork fail at sys_exofork!\n");
        else if(env_id == 0){
  800fc7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
  800fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800fd1:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  800fd8:	a8 01                	test   $0x1,%al
  800fda:	0f 84 ea 00 00 00    	je     8010ca <fork+0x172>
                    for(j = 0; j < NPTENTRIES; j++){
                        pn = PGNUM(PGADDR(i,j,0)); 
  800fe0:	c1 e2 16             	shl    $0x16,%edx
  800fe3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fe6:	be 00 00 00 00       	mov    $0x0,%esi
  800feb:	89 f3                	mov    %esi,%ebx
  800fed:	c1 e3 0c             	shl    $0xc,%ebx
  800ff0:	0b 5d e4             	or     -0x1c(%ebp),%ebx
  800ff3:	c1 eb 0c             	shr    $0xc,%ebx
                        if(pn == PGNUM(UTOP - PGSIZE))
  800ff6:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800ffc:	0f 84 c8 00 00 00    	je     8010ca <fork+0x172>
                            break;
                        if(uvpt[pn] & PTE_P)
  801002:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801009:	a8 01                	test   $0x1,%al
  80100b:	0f 84 ac 00 00 00    	je     8010bd <fork+0x165>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
  801011:	e8 b1 fb ff ff       	call   800bc7 <sys_getenvid>
  801016:	89 45 e0             	mov    %eax,-0x20(%ebp)
        pte_t pte = uvpt[pn];
  801019:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
        void *addr = (void *)(pn * PGSIZE);
  801020:	89 df                	mov    %ebx,%edi
  801022:	c1 e7 0c             	shl    $0xc,%edi
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
  801025:	25 02 08 00 00       	and    $0x802,%eax
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
        pte_t pte = uvpt[pn];
        void *addr = (void *)(pn * PGSIZE);
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
  80102a:	83 f8 01             	cmp    $0x1,%eax
  80102d:	19 db                	sbb    %ebx,%ebx
  80102f:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801035:	81 c3 05 08 00 00    	add    $0x805,%ebx
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
            perm |= PTE_COW;
        if(sys_page_map(srcenv_id, addr, envid, addr, PTE_P|PTE_U|PTE_COW) < 0)
  80103b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801042:	00 
  801043:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801047:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80104a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801052:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801055:	89 04 24             	mov    %eax,(%esp)
  801058:	e8 fc fb ff ff       	call   800c59 <sys_page_map>
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 1c                	jns    80107d <fork+0x125>
            panic("duppage fail at page map1!\n");
  801061:	c7 44 24 08 75 19 80 	movl   $0x801975,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  801078:	e8 f3 f0 ff ff       	call   800170 <_panic>
        if(perm & PTE_COW){
  80107d:	f6 c7 08             	test   $0x8,%bh
  801080:	74 3b                	je     8010bd <fork+0x165>
            if(sys_page_map(srcenv_id, addr, srcenv_id, addr, perm) < 0)
  801082:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801086:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80108a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80108d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801091:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801095:	89 04 24             	mov    %eax,(%esp)
  801098:	e8 bc fb ff ff       	call   800c59 <sys_page_map>
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 1c                	jns    8010bd <fork+0x165>
                panic("duppage fail at page map2!\n");
  8010a1:	c7 44 24 08 91 19 80 	movl   $0x801991,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  8010b8:	e8 b3 f0 ff ff       	call   800170 <_panic>
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
                    for(j = 0; j < NPTENTRIES; j++){
  8010bd:	46                   	inc    %esi
  8010be:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  8010c4:	0f 85 21 ff ff ff    	jne    800feb <fork+0x93>
            thisenv = &envs[ENVX(sys_getenvid())];
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
  8010ca:	ff 45 dc             	incl   -0x24(%ebp)
  8010cd:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  8010d4:	0f 85 f4 fe ff ff    	jne    800fce <fork+0x76>
                        if(uvpt[pn] & PTE_P)
                            duppage(env_id, pn);
                    }
                }
            }
            if(sys_page_alloc(env_id,(void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8010da:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010e9:	ee 
  8010ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010ed:	89 04 24             	mov    %eax,(%esp)
  8010f0:	e8 10 fb ff ff       	call   800c05 <sys_page_alloc>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	79 1c                	jns    801115 <fork+0x1bd>
                panic("fork fail at sys_page_alloc!\n");
  8010f9:	c7 44 24 08 ad 19 80 	movl   $0x8019ad,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  801110:	e8 5b f0 ff ff       	call   800170 <_panic>
            if(sys_page_map(env_id, (void *)(UXSTACKTOP - PGSIZE), sys_getenvid(), PFTEMP, PTE_U|PTE_P|PTE_W) < 0)
  801115:	e8 ad fa ff ff       	call   800bc7 <sys_getenvid>
  80111a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801121:	00 
  801122:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  801129:	00 
  80112a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801135:	ee 
  801136:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801139:	89 04 24             	mov    %eax,(%esp)
  80113c:	e8 18 fb ff ff       	call   800c59 <sys_page_map>
  801141:	85 c0                	test   %eax,%eax
  801143:	79 1c                	jns    801161 <fork+0x209>
                panic("fork fail at sys_page_map!\n");
  801145:	c7 44 24 08 cb 19 80 	movl   $0x8019cb,0x8(%esp)
  80114c:	00 
  80114d:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801154:	00 
  801155:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  80115c:	e8 0f f0 ff ff       	call   800170 <_panic>
            memmove((void *)(UXSTACKTOP - PGSIZE),PFTEMP, PGSIZE);
  801161:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801168:	00 
  801169:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  801178:	e8 0f f8 ff ff       	call   80098c <memmove>
            if(sys_page_unmap(sys_getenvid(), PFTEMP) < 0)
  80117d:	e8 45 fa ff ff       	call   800bc7 <sys_getenvid>
  801182:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801189:	00 
  80118a:	89 04 24             	mov    %eax,(%esp)
  80118d:	e8 1a fb ff ff       	call   800cac <sys_page_unmap>
  801192:	85 c0                	test   %eax,%eax
  801194:	79 1c                	jns    8011b2 <fork+0x25a>
                panic("fork fail at sys_page_unmap!\n");
  801196:	c7 44 24 08 e7 19 80 	movl   $0x8019e7,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  8011ad:	e8 be ef ff ff       	call   800170 <_panic>
            
            extern void _pgfault_upcall(void);
            if(sys_env_set_pgfault_upcall(env_id, _pgfault_upcall) < 0)
  8011b2:	c7 44 24 04 d4 12 80 	movl   $0x8012d4,0x4(%esp)
  8011b9:	00 
  8011ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011bd:	89 04 24             	mov    %eax,(%esp)
  8011c0:	e8 8d fb ff ff       	call   800d52 <sys_env_set_pgfault_upcall>
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	79 1c                	jns    8011e5 <fork+0x28d>
                panic("fork fail at sys_env_set_pgfault_upcall!\n");
  8011c9:	c7 44 24 08 c8 18 80 	movl   $0x8018c8,0x8(%esp)
  8011d0:	00 
  8011d1:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8011d8:	00 
  8011d9:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  8011e0:	e8 8b ef ff ff       	call   800170 <_panic>
            if(sys_env_set_status(env_id,ENV_RUNNABLE) < 0)
  8011e5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011ec:	00 
  8011ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	e8 07 fb ff ff       	call   800cff <sys_env_set_status>
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	79 1c                	jns    801218 <fork+0x2c0>
                panic("fork fail at sys_env_set_status!\n");
  8011fc:	c7 44 24 08 f4 18 80 	movl   $0x8018f4,0x8(%esp)
  801203:	00 
  801204:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  80120b:	00 
  80120c:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  801213:	e8 58 ef ff ff       	call   800170 <_panic>
            return env_id;
        }
}
  801218:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80121b:	83 c4 4c             	add    $0x4c,%esp
  80121e:	5b                   	pop    %ebx
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <sfork>:

// Challenge!
int
sfork(void)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801229:	c7 44 24 08 05 1a 80 	movl   $0x801a05,0x8(%esp)
  801230:	00 
  801231:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  801238:	00 
  801239:	c7 04 24 16 19 80 00 	movl   $0x801916,(%esp)
  801240:	e8 2b ef ff ff       	call   800170 <_panic>
  801245:	00 00                	add    %al,(%eax)
	...

00801248 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801255:	75 3d                	jne    801294 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  801257:	e8 6b f9 ff ff       	call   800bc7 <sys_getenvid>
  80125c:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126b:	ee 
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	e8 91 f9 ff ff       	call   800c05 <sys_page_alloc>
  801274:	85 c0                	test   %eax,%eax
  801276:	79 1c                	jns    801294 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  801278:	c7 44 24 08 1c 1a 80 	movl   $0x801a1c,0x8(%esp)
  80127f:	00 
  801280:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801287:	00 
  801288:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  80128f:	e8 dc ee ff ff       	call   800170 <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801294:	8b 45 08             	mov    0x8(%ebp),%eax
  801297:	a3 0c 20 80 00       	mov    %eax,0x80200c
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  80129c:	e8 26 f9 ff ff       	call   800bc7 <sys_getenvid>
  8012a1:	c7 44 24 04 d4 12 80 	movl   $0x8012d4,0x4(%esp)
  8012a8:	00 
  8012a9:	89 04 24             	mov    %eax,(%esp)
  8012ac:	e8 a1 fa ff ff       	call   800d52 <sys_env_set_pgfault_upcall>
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	79 1c                	jns    8012d1 <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  8012b5:	c7 44 24 08 4c 1a 80 	movl   $0x801a4c,0x8(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012c4:	00 
  8012c5:	c7 04 24 74 1a 80 00 	movl   $0x801a74,(%esp)
  8012cc:	e8 9f ee ff ff       	call   800170 <_panic>
}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    
	...

008012d4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012da:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012dc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  8012df:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  8012e1:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  8012e5:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  8012e9:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  8012ea:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  8012ec:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  8012f1:	58                   	pop    %eax
        popl %eax
  8012f2:	58                   	pop    %eax
        popal
  8012f3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  8012f4:	83 c4 04             	add    $0x4,%esp
        popfl
  8012f7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8012f8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  8012f9:	c3                   	ret    
	...

008012fc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8012fc:	55                   	push   %ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	83 ec 10             	sub    $0x10,%esp
  801302:	8b 74 24 20          	mov    0x20(%esp),%esi
  801306:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80130a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801312:	89 cd                	mov    %ecx,%ebp
  801314:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801318:	85 c0                	test   %eax,%eax
  80131a:	75 2c                	jne    801348 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80131c:	39 f9                	cmp    %edi,%ecx
  80131e:	77 68                	ja     801388 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801320:	85 c9                	test   %ecx,%ecx
  801322:	75 0b                	jne    80132f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801324:	b8 01 00 00 00       	mov    $0x1,%eax
  801329:	31 d2                	xor    %edx,%edx
  80132b:	f7 f1                	div    %ecx
  80132d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80132f:	31 d2                	xor    %edx,%edx
  801331:	89 f8                	mov    %edi,%eax
  801333:	f7 f1                	div    %ecx
  801335:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801337:	89 f0                	mov    %esi,%eax
  801339:	f7 f1                	div    %ecx
  80133b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80133d:	89 f0                	mov    %esi,%eax
  80133f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801348:	39 f8                	cmp    %edi,%eax
  80134a:	77 2c                	ja     801378 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80134c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80134f:	83 f6 1f             	xor    $0x1f,%esi
  801352:	75 4c                	jne    8013a0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801354:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801356:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80135b:	72 0a                	jb     801367 <__udivdi3+0x6b>
  80135d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801361:	0f 87 ad 00 00 00    	ja     801414 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801367:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80136c:	89 f0                	mov    %esi,%eax
  80136e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    
  801377:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801378:	31 ff                	xor    %edi,%edi
  80137a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80137c:	89 f0                	mov    %esi,%eax
  80137e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	5e                   	pop    %esi
  801384:	5f                   	pop    %edi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    
  801387:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801388:	89 fa                	mov    %edi,%edx
  80138a:	89 f0                	mov    %esi,%eax
  80138c:	f7 f1                	div    %ecx
  80138e:	89 c6                	mov    %eax,%esi
  801390:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801392:	89 f0                	mov    %esi,%eax
  801394:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013a0:	89 f1                	mov    %esi,%ecx
  8013a2:	d3 e0                	shl    %cl,%eax
  8013a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013a8:	b8 20 00 00 00       	mov    $0x20,%eax
  8013ad:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8013af:	89 ea                	mov    %ebp,%edx
  8013b1:	88 c1                	mov    %al,%cl
  8013b3:	d3 ea                	shr    %cl,%edx
  8013b5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013b9:	09 ca                	or     %ecx,%edx
  8013bb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8013bf:	89 f1                	mov    %esi,%ecx
  8013c1:	d3 e5                	shl    %cl,%ebp
  8013c3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8013c7:	89 fd                	mov    %edi,%ebp
  8013c9:	88 c1                	mov    %al,%cl
  8013cb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8013cd:	89 fa                	mov    %edi,%edx
  8013cf:	89 f1                	mov    %esi,%ecx
  8013d1:	d3 e2                	shl    %cl,%edx
  8013d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d7:	88 c1                	mov    %al,%cl
  8013d9:	d3 ef                	shr    %cl,%edi
  8013db:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013dd:	89 f8                	mov    %edi,%eax
  8013df:	89 ea                	mov    %ebp,%edx
  8013e1:	f7 74 24 08          	divl   0x8(%esp)
  8013e5:	89 d1                	mov    %edx,%ecx
  8013e7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8013e9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013ed:	39 d1                	cmp    %edx,%ecx
  8013ef:	72 17                	jb     801408 <__udivdi3+0x10c>
  8013f1:	74 09                	je     8013fc <__udivdi3+0x100>
  8013f3:	89 fe                	mov    %edi,%esi
  8013f5:	31 ff                	xor    %edi,%edi
  8013f7:	e9 41 ff ff ff       	jmp    80133d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8013fc:	8b 54 24 04          	mov    0x4(%esp),%edx
  801400:	89 f1                	mov    %esi,%ecx
  801402:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801404:	39 c2                	cmp    %eax,%edx
  801406:	73 eb                	jae    8013f3 <__udivdi3+0xf7>
		{
		  q0--;
  801408:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80140b:	31 ff                	xor    %edi,%edi
  80140d:	e9 2b ff ff ff       	jmp    80133d <__udivdi3+0x41>
  801412:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801414:	31 f6                	xor    %esi,%esi
  801416:	e9 22 ff ff ff       	jmp    80133d <__udivdi3+0x41>
	...

0080141c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80141c:	55                   	push   %ebp
  80141d:	57                   	push   %edi
  80141e:	56                   	push   %esi
  80141f:	83 ec 20             	sub    $0x20,%esp
  801422:	8b 44 24 30          	mov    0x30(%esp),%eax
  801426:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80142a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80142e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801432:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801436:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80143a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80143c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80143e:	85 ed                	test   %ebp,%ebp
  801440:	75 16                	jne    801458 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801442:	39 f1                	cmp    %esi,%ecx
  801444:	0f 86 a6 00 00 00    	jbe    8014f0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80144a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801450:	83 c4 20             	add    $0x20,%esp
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    
  801457:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801458:	39 f5                	cmp    %esi,%ebp
  80145a:	0f 87 ac 00 00 00    	ja     80150c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801460:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801463:	83 f0 1f             	xor    $0x1f,%eax
  801466:	89 44 24 10          	mov    %eax,0x10(%esp)
  80146a:	0f 84 a8 00 00 00    	je     801518 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801470:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801474:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801476:	bf 20 00 00 00       	mov    $0x20,%edi
  80147b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80147f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801483:	89 f9                	mov    %edi,%ecx
  801485:	d3 e8                	shr    %cl,%eax
  801487:	09 e8                	or     %ebp,%eax
  801489:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80148d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801491:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801495:	d3 e0                	shl    %cl,%eax
  801497:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80149b:	89 f2                	mov    %esi,%edx
  80149d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80149f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014a3:	d3 e0                	shl    %cl,%eax
  8014a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014a9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014ad:	89 f9                	mov    %edi,%ecx
  8014af:	d3 e8                	shr    %cl,%eax
  8014b1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8014b3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014b5:	89 f2                	mov    %esi,%edx
  8014b7:	f7 74 24 18          	divl   0x18(%esp)
  8014bb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8014bd:	f7 64 24 0c          	mull   0xc(%esp)
  8014c1:	89 c5                	mov    %eax,%ebp
  8014c3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014c5:	39 d6                	cmp    %edx,%esi
  8014c7:	72 67                	jb     801530 <__umoddi3+0x114>
  8014c9:	74 75                	je     801540 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8014cb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014cf:	29 e8                	sub    %ebp,%eax
  8014d1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8014d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d7:	d3 e8                	shr    %cl,%eax
  8014d9:	89 f2                	mov    %esi,%edx
  8014db:	89 f9                	mov    %edi,%ecx
  8014dd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8014df:	09 d0                	or     %edx,%eax
  8014e1:	89 f2                	mov    %esi,%edx
  8014e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014e9:	83 c4 20             	add    $0x20,%esp
  8014ec:	5e                   	pop    %esi
  8014ed:	5f                   	pop    %edi
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014f0:	85 c9                	test   %ecx,%ecx
  8014f2:	75 0b                	jne    8014ff <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	31 d2                	xor    %edx,%edx
  8014fb:	f7 f1                	div    %ecx
  8014fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014ff:	89 f0                	mov    %esi,%eax
  801501:	31 d2                	xor    %edx,%edx
  801503:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801505:	89 f8                	mov    %edi,%eax
  801507:	e9 3e ff ff ff       	jmp    80144a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80150c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80150e:	83 c4 20             	add    $0x20,%esp
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    
  801515:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801518:	39 f5                	cmp    %esi,%ebp
  80151a:	72 04                	jb     801520 <__umoddi3+0x104>
  80151c:	39 f9                	cmp    %edi,%ecx
  80151e:	77 06                	ja     801526 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801520:	89 f2                	mov    %esi,%edx
  801522:	29 cf                	sub    %ecx,%edi
  801524:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801526:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	5e                   	pop    %esi
  80152c:	5f                   	pop    %edi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    
  80152f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801530:	89 d1                	mov    %edx,%ecx
  801532:	89 c5                	mov    %eax,%ebp
  801534:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801538:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80153c:	eb 8d                	jmp    8014cb <__umoddi3+0xaf>
  80153e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801540:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801544:	72 ea                	jb     801530 <__umoddi3+0x114>
  801546:	89 f1                	mov    %esi,%ecx
  801548:	eb 81                	jmp    8014cb <__umoddi3+0xaf>
