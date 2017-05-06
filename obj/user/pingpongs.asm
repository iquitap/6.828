
obj/user/pingpongs：     文件格式 elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 c9 11 00 00       	call   80120b <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 5b 0b 00 00       	call   800baf <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 a0 16 80 00 	movl   $0x8016a0,(%esp)
  800063:	e8 e8 01 00 00       	call   800250 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 3f 0b 00 00       	call   800baf <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 ba 16 80 00 	movl   $0x8016ba,(%esp)
  80007f:	e8 cc 01 00 00       	call   800250 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 f0 11 00 00       	call   801297 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 6e 11 00 00       	call   801230 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 d3 0a 00 00       	call   800baf <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 d0 16 80 00 	movl   $0x8016d0,(%esp)
  8000fa:	e8 51 01 00 00       	call   800250 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 65 11 00 00       	call   801297 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800156:	e8 54 0a 00 00       	call   800baf <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 20 80 00       	mov    %eax,0x802008

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 af 09 00 00       	call   800b5d <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	40                   	inc    %eax
  8001c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	75 19                	jne    8001e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d4:	00 
  8001d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 40 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e6:	ff 43 04             	incl   0x4(%ebx)
}
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022b:	e8 82 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 d8 08 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800248:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 87 ff ff ff       	call   8001ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	85 c0                	test   %eax,%eax
  80028e:	75 08                	jne    800298 <printnum+0x2c>
  800290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800293:	39 45 10             	cmp    %eax,0x10(%ebp)
  800296:	77 57                	ja     8002ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029c:	4b                   	dec    %ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 86 11 00 00       	call   801450 <__udivdi3>
  8002ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 89 ff ff ff       	call   80026c <printnum>
  8002e3:	eb 0f                	jmp    8002f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	4b                   	dec    %ebx
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7f f1                	jg     8002e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030a:	00 
  80030b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	e8 53 12 00 00       	call   801570 <__umoddi3>
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	0f be 80 00 17 80 00 	movsbl 0x801700(%eax),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032e:	83 c4 3c             	add    $0x3c,%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800339:	83 fa 01             	cmp    $0x1,%edx
  80033c:	7e 0e                	jle    80034c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 08             	lea    0x8(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	8b 52 04             	mov    0x4(%edx),%edx
  80034a:	eb 22                	jmp    80036e <getuint+0x38>
	else if (lflag)
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 10                	je     800360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 0e                	jmp    80036e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800376:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 08                	jae    800388 <sprintputch+0x18>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	42                   	inc    %edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c1:	eb 12                	jmp    8003d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 84 6b 03 00 00    	je     800736 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	0f b6 06             	movzbl (%esi),%eax
  8003d8:	46                   	inc    %esi
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e5                	jne    8003c3 <vprintfmt+0x11>
  8003de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 26                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 1d                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 14                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 08                	jmp    800422 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80041d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	0f b6 06             	movzbl (%esi),%eax
  800425:	8d 56 01             	lea    0x1(%esi),%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	8a 16                	mov    (%esi),%dl
  80042d:	83 ea 23             	sub    $0x23,%edx
  800430:	80 fa 55             	cmp    $0x55,%dl
  800433:	0f 87 e1 02 00 00    	ja     80071a <vprintfmt+0x368>
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	ff 24 95 c0 17 80 00 	jmp    *0x8017c0(,%edx,4)
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800452:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800455:	8d 50 d0             	lea    -0x30(%eax),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 2a                	ja     800487 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb eb                	jmp    80044b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046e:	eb 17                	jmp    800487 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	78 98                	js     80040e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800479:	eb a7                	jmp    800422 <vprintfmt+0x70>
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800485:	eb 9b                	jmp    800422 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	79 95                	jns    800422 <vprintfmt+0x70>
  80048d:	eb 8b                	jmp    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	eb 8d                	jmp    800422 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ad:	e9 23 ff ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	79 02                	jns    8004c3 <vprintfmt+0x111>
  8004c1:	f7 d8                	neg    %eax
  8004c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 09             	cmp    $0x9,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x123>
  8004ca:	8b 04 85 20 19 80 00 	mov    0x801920(,%eax,4),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 23                	jne    8004f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d9:	c7 44 24 08 18 17 80 	movl   $0x801718,0x8(%esp)
  8004e0:	00 
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 9a fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 dd fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 21 17 80 	movl   $0x801721,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 14 24             	mov    %edx,(%esp)
  80050e:	e8 77 fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ba fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
  80051b:	89 f9                	mov    %edi,%ecx
  80051d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x185>
				p = "(null)";
  800532:	be 11 17 80 00       	mov    $0x801711,%esi
			if (width > 0 && padc != '-')
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	0f 8e 84 00 00 00    	jle    8005c5 <vprintfmt+0x213>
  800541:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800545:	74 7e                	je     8005c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	e8 8b 02 00 00       	call   8007de <strnlen>
  800553:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800556:	29 c2                	sub    %eax,%edx
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800562:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800565:	89 de                	mov    %ebx,%esi
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80056d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <vprintfmt+0x1bb>
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	89 f3                	mov    %esi,%ebx
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	79 05                	jns    800590 <vprintfmt+0x1de>
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800598:	eb 2b                	jmp    8005c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	74 18                	je     8005b8 <vprintfmt+0x206>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x206>
					putch('?', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	eb 0a                	jmp    8005c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	46                   	inc    %esi
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	74 21                	je     8005ee <vprintfmt+0x23c>
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	78 c9                	js     80059a <vprintfmt+0x1e8>
  8005d1:	4f                   	dec    %edi
  8005d2:	79 c6                	jns    80059a <vprintfmt+0x1e8>
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x244>
  8005ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f e4                	jg     8005de <vprintfmt+0x22c>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ce fd ff ff       	jmp    8003d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 10                	jle    80061c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 08             	lea    0x8(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	8b 78 04             	mov    0x4(%eax),%edi
  80061a:	eb 26                	jmp    800642 <vprintfmt+0x290>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 12                	je     800632 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
  800630:	eb 10                	jmp    800642 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	89 f7                	mov    %esi,%edi
  80063f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	85 ff                	test   %edi,%edi
  800644:	78 0a                	js     800650 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8c 00 00 00       	jmp    8006dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	f7 de                	neg    %esi
  800660:	83 d7 00             	adc    $0x0,%edi
  800663:	f7 df                	neg    %edi
			}
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 70                	jmp    8006dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	89 ca                	mov    %ecx,%edx
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 c0 fc ff ff       	call   800336 <getuint>
  800676:	89 c6                	mov    %eax,%esi
  800678:	89 d7                	mov    %edx,%edi
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067f:	eb 5b                	jmp    8006dc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 ab fc ff ff       	call   800336 <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
                        base = 8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  800694:	eb 46                	jmp    8006dc <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 63 fc ff ff       	call   800336 <getuint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ef:	89 34 24             	mov    %esi,(%esp)
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	e8 6c fb ff ff       	call   80026c <printnum>
			break;
  800700:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800703:	e9 cd fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800715:	e9 bb fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800725:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	eb 01                	jmp    80072b <vprintfmt+0x379>
  80072a:	4e                   	dec    %esi
  80072b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072f:	75 f9                	jne    80072a <vprintfmt+0x378>
  800731:	e9 9f fc ff ff       	jmp    8003d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800736:	83 c4 4c             	add    $0x4c,%esp
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5f                   	pop    %edi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 28             	sub    $0x28,%esp
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800751:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800754:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 30                	je     80078f <vsnprintf+0x51>
  80075f:	85 d2                	test   %edx,%edx
  800761:	7e 33                	jle    800796 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  80077f:	e8 2e fc ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	eb 0c                	jmp    80079b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb 05                	jmp    80079b <vsnprintf+0x5d>
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 7b ff ff ff       	call   80073e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    
  8007c5:	00 00                	add    %al,(%eax)
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f5                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	89 1c 24             	mov    %ebx,(%esp)
  800825:	e8 9e ff ff ff       	call   8007c8 <strlen>
	strcpy(dst + len, src);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c0 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	eb 0c                	jmp    800864 <strncpy+0x21>
		*dst++ = *src;
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 3a 01             	cmpb   $0x1,(%edx)
  800860:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	41                   	inc    %ecx
  800864:	39 f1                	cmp    %esi,%ecx
  800866:	75 f0                	jne    800858 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 0a                	jne    800888 <strlcpy+0x1c>
  80087e:	89 f0                	mov    %esi,%eax
  800880:	eb 1a                	jmp    80089c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 18                	mov    %bl,(%eax)
  800884:	40                   	inc    %eax
  800885:	41                   	inc    %ecx
  800886:	eb 02                	jmp    80088a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088a:	4a                   	dec    %edx
  80088b:	74 0a                	je     800897 <strlcpy+0x2b>
  80088d:	8a 19                	mov    (%ecx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strlcpy+0x16>
  800893:	89 c2                	mov    %eax,%edx
  800895:	eb 02                	jmp    800899 <strlcpy+0x2d>
  800897:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strcmp+0xd>
		p++, q++;
  8008ad:	41                   	inc    %ecx
  8008ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	8a 01                	mov    (%ecx),%al
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x17>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 f4                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 03                	jmp    8008d5 <strncmp+0x12>
		n--, p++, q++;
  8008d2:	4a                   	dec    %edx
  8008d3:	40                   	inc    %eax
  8008d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 14                	je     8008ed <strncmp+0x2a>
  8008d9:	8a 18                	mov    (%eax),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 04                	je     8008e3 <strncmp+0x20>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	74 ef                	je     8008d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	eb 05                	jmp    800905 <strchr+0x10>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0c                	je     800910 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091b:	eb 05                	jmp    800922 <strfind+0x10>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 07                	je     800928 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800921:	40                   	inc    %eax
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f5                	jne    80091d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 34                	jae    8009ba <memmove+0x46>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2d                	jae    8009ba <memmove+0x46>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 1b                	jne    8009b0 <memmove+0x3c>
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 13                	jne    8009b0 <memmove+0x3c>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0e                	jne    8009b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 07                	jmp    8009b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	4f                   	dec    %edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 20                	jmp    8009da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x61>
  8009c2:	a8 03                	test   $0x3,%al
  8009c4:	75 0f                	jne    8009d5 <memmove+0x61>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 77 ff ff ff       	call   800974 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	eb 16                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a18:	42                   	inc    %edx
  800a19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a1d:	38 c8                	cmp    %cl,%al
  800a1f:	74 0a                	je     800a2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 c9             	movzbl %cl,%ecx
  800a27:	29 c8                	sub    %ecx,%eax
  800a29:	eb 09                	jmp    800a34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 e6                	jne    800a15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 05                	jmp    800a4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 05                	je     800a52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f7                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 01                	jmp    800a63 <strtol+0xf>
		s++;
  800a62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f9                	je     800a62 <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f5                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 08                	jne    800a79 <strtol+0x25>
		s++;
  800a71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	eb 13                	jmp    800a8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x33>
		s++, neg = 1;
  800a7d:	8d 52 01             	lea    0x1(%edx),%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb 05                	jmp    800a8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 05                	je     800a95 <strtol+0x41>
  800a90:	83 fb 10             	cmp    $0x10,%ebx
  800a93:	75 28                	jne    800abd <strtol+0x69>
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 10                	jne    800aab <strtol+0x57>
  800a9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9f:	75 0a                	jne    800aab <strtol+0x57>
		s += 2, base = 16;
  800aa1:	83 c2 02             	add    $0x2,%edx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 12                	jmp    800abd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 0e                	jne    800abd <strtol+0x69>
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 05                	jne    800ab8 <strtol+0x64>
		s++, base = 8;
  800ab3:	42                   	inc    %edx
  800ab4:	b3 08                	mov    $0x8,%bl
  800ab6:	eb 05                	jmp    800abd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	8a 0a                	mov    (%edx),%cl
  800ac6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x82>
			dig = *s - '0';
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 30             	sub    $0x30,%ecx
  800ad4:	eb 1e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 57             	sub    $0x57,%ecx
  800ae4:	eb 0e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 12                	ja     800b00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af4:	39 f1                	cmp    %esi,%ecx
  800af6:	7d 0c                	jge    800b04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af8:	42                   	inc    %edx
  800af9:	0f af c6             	imul   %esi,%eax
  800afc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb c4                	jmp    800ac4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	eb 02                	jmp    800b06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xbd>
		*endptr = (char *) s;
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b11:	85 ff                	test   %edi,%edi
  800b13:	74 04                	je     800b19 <strtol+0xc5>
  800b15:	89 c8                	mov    %ecx,%eax
  800b17:	f7 d8                	neg    %eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 28                	jle    800ba7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800b92:	00 
  800b93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9a:	00 
  800b9b:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800ba2:	e8 9d 07 00 00       	call   801344 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	83 c4 2c             	add    $0x2c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 28                	jle    800c39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800c24:	00 
  800c25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2c:	00 
  800c2d:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800c34:	e8 0b 07 00 00       	call   801344 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	83 c4 2c             	add    $0x2c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 28                	jle    800c8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800c87:	e8 b8 06 00 00       	call   801344 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	83 c4 2c             	add    $0x2c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800cda:	e8 65 06 00 00       	call   801344 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800d2d:	e8 12 06 00 00       	call   801344 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800d80:	e8 bf 05 00 00       	call   801344 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	89 cb                	mov    %ecx,%ebx
  800dc8:	89 cf                	mov    %ecx,%edi
  800dca:	89 ce                	mov    %ecx,%esi
  800dcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7e 28                	jle    800dfa <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ddd:	00 
  800dde:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800de5:	00 
  800de6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ded:	00 
  800dee:	c7 04 24 65 19 80 00 	movl   $0x801965,(%esp)
  800df5:	e8 4a 05 00 00       	call   801344 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfa:	83 c4 2c             	add    $0x2c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
	...

00800e04 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 20             	sub    $0x20,%esp
	void *addr = (void *) utf->utf_fault_va;
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) == 0){
  800e11:	89 f0                	mov    %esi,%eax
  800e13:	c1 e8 0c             	shr    $0xc,%eax
  800e16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1d:	a9 02 08 00 00       	test   $0x802,%eax
  800e22:	75 1c                	jne    800e40 <pgfault+0x3c>
            panic("phfault fail at perm of faulting access!\n");
  800e24:	c7 44 24 08 74 19 80 	movl   $0x801974,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800e3b:	e8 04 05 00 00       	call   801344 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t env_id = sys_getenvid();
  800e40:	e8 6a fd ff ff       	call   800baf <sys_getenvid>
  800e45:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(env_id, (void *)PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  800e47:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e56:	00 
  800e57:	89 04 24             	mov    %eax,(%esp)
  800e5a:	e8 8e fd ff ff       	call   800bed <sys_page_alloc>
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 1c                	jns    800e7f <pgfault+0x7b>
            panic("pafault fail at page_alloc!\n");
  800e63:	c7 44 24 08 41 1a 80 	movl   $0x801a41,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800e7a:	e8 c5 04 00 00       	call   801344 <_panic>
        addr = ROUNDDOWN(addr, PGSIZE);
  800e7f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e8c:	00 
  800e8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e91:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e98:	e8 d7 fa ff ff       	call   800974 <memmove>
        if(sys_page_unmap(env_id, addr) < 0)
  800e9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea1:	89 1c 24             	mov    %ebx,(%esp)
  800ea4:	e8 eb fd ff ff       	call   800c94 <sys_page_unmap>
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 1c                	jns    800ec9 <pgfault+0xc5>
            panic("pafault fail at page_unmap addr!\n");
  800ead:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800ec4:	e8 7b 04 00 00       	call   801344 <_panic>
        if(sys_page_map(env_id, PFTEMP, env_id, addr, PTE_P|PTE_U|PTE_W) < 0)
  800ec9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ed0:	00 
  800ed1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ed5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ed9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ee0:	00 
  800ee1:	89 1c 24             	mov    %ebx,(%esp)
  800ee4:	e8 58 fd ff ff       	call   800c41 <sys_page_map>
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	79 1c                	jns    800f09 <pgfault+0x105>
            panic("page_map fail at page_map!\n");
  800eed:	c7 44 24 08 5e 1a 80 	movl   $0x801a5e,0x8(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800efc:	00 
  800efd:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800f04:	e8 3b 04 00 00       	call   801344 <_panic>
        if(sys_page_unmap(env_id, PFTEMP) < 0)
  800f09:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f10:	00 
  800f11:	89 1c 24             	mov    %ebx,(%esp)
  800f14:	e8 7b fd ff ff       	call   800c94 <sys_page_unmap>
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 1c                	jns    800f39 <pgfault+0x135>
            panic("pafault fail at page_unmap PFTEMP!\n");
  800f1d:	c7 44 24 08 c4 19 80 	movl   $0x8019c4,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800f34:	e8 0b 04 00 00       	call   801344 <_panic>
	//panic("pgfault not implemented");
}
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        set_pgfault_handler(pgfault);
  800f49:	c7 04 24 04 0e 80 00 	movl   $0x800e04,(%esp)
  800f50:	e8 47 04 00 00       	call   80139c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f55:	ba 07 00 00 00       	mov    $0x7,%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	cd 30                	int    $0x30
  800f5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f61:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 1c                	jns    800f84 <fork+0x44>
            panic("fork fail at sys_exofork!\n");
  800f68:	c7 44 24 08 7a 1a 80 	movl   $0x801a7a,0x8(%esp)
  800f6f:	00 
  800f70:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800f77:	00 
  800f78:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  800f7f:	e8 c0 03 00 00       	call   801344 <_panic>
        else if(env_id == 0){
  800f84:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800f88:	75 25                	jne    800faf <fork+0x6f>
            thisenv = &envs[ENVX(sys_getenvid())];
  800f8a:	e8 20 fc ff ff       	call   800baf <sys_getenvid>
  800f8f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f9b:	c1 e0 07             	shl    $0x7,%eax
  800f9e:	29 d0                	sub    %edx,%eax
  800fa0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa5:	a3 08 20 80 00       	mov    %eax,0x802008
            return 0;
  800faa:	e9 51 02 00 00       	jmp    801200 <fork+0x2c0>
        set_pgfault_handler(pgfault);
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
            panic("fork fail at sys_exofork!\n");
        else if(env_id == 0){
  800faf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
  800fb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800fb9:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  800fc0:	a8 01                	test   $0x1,%al
  800fc2:	0f 84 ea 00 00 00    	je     8010b2 <fork+0x172>
                    for(j = 0; j < NPTENTRIES; j++){
                        pn = PGNUM(PGADDR(i,j,0)); 
  800fc8:	c1 e2 16             	shl    $0x16,%edx
  800fcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fce:	be 00 00 00 00       	mov    $0x0,%esi
  800fd3:	89 f3                	mov    %esi,%ebx
  800fd5:	c1 e3 0c             	shl    $0xc,%ebx
  800fd8:	0b 5d e4             	or     -0x1c(%ebp),%ebx
  800fdb:	c1 eb 0c             	shr    $0xc,%ebx
                        if(pn == PGNUM(UTOP - PGSIZE))
  800fde:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800fe4:	0f 84 c8 00 00 00    	je     8010b2 <fork+0x172>
                            break;
                        if(uvpt[pn] & PTE_P)
  800fea:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ff1:	a8 01                	test   $0x1,%al
  800ff3:	0f 84 ac 00 00 00    	je     8010a5 <fork+0x165>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
  800ff9:	e8 b1 fb ff ff       	call   800baf <sys_getenvid>
  800ffe:	89 45 e0             	mov    %eax,-0x20(%ebp)
        pte_t pte = uvpt[pn];
  801001:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
        void *addr = (void *)(pn * PGSIZE);
  801008:	89 df                	mov    %ebx,%edi
  80100a:	c1 e7 0c             	shl    $0xc,%edi
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
  80100d:	25 02 08 00 00       	and    $0x802,%eax
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
        pte_t pte = uvpt[pn];
        void *addr = (void *)(pn * PGSIZE);
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
  801012:	83 f8 01             	cmp    $0x1,%eax
  801015:	19 db                	sbb    %ebx,%ebx
  801017:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  80101d:	81 c3 05 08 00 00    	add    $0x805,%ebx
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
            perm |= PTE_COW;
        if(sys_page_map(srcenv_id, addr, envid, addr, PTE_P|PTE_U|PTE_COW) < 0)
  801023:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80102a:	00 
  80102b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80102f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801032:	89 44 24 08          	mov    %eax,0x8(%esp)
  801036:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80103a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	e8 fc fb ff ff       	call   800c41 <sys_page_map>
  801045:	85 c0                	test   %eax,%eax
  801047:	79 1c                	jns    801065 <fork+0x125>
            panic("duppage fail at page map1!\n");
  801049:	c7 44 24 08 95 1a 80 	movl   $0x801a95,0x8(%esp)
  801050:	00 
  801051:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801058:	00 
  801059:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  801060:	e8 df 02 00 00       	call   801344 <_panic>
        if(perm & PTE_COW){
  801065:	f6 c7 08             	test   $0x8,%bh
  801068:	74 3b                	je     8010a5 <fork+0x165>
            if(sys_page_map(srcenv_id, addr, srcenv_id, addr, perm) < 0)
  80106a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80106e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801072:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801075:	89 44 24 08          	mov    %eax,0x8(%esp)
  801079:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 bc fb ff ff       	call   800c41 <sys_page_map>
  801085:	85 c0                	test   %eax,%eax
  801087:	79 1c                	jns    8010a5 <fork+0x165>
                panic("duppage fail at page map2!\n");
  801089:	c7 44 24 08 b1 1a 80 	movl   $0x801ab1,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  8010a0:	e8 9f 02 00 00       	call   801344 <_panic>
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
                    for(j = 0; j < NPTENTRIES; j++){
  8010a5:	46                   	inc    %esi
  8010a6:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  8010ac:	0f 85 21 ff ff ff    	jne    800fd3 <fork+0x93>
            thisenv = &envs[ENVX(sys_getenvid())];
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
  8010b2:	ff 45 dc             	incl   -0x24(%ebp)
  8010b5:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  8010bc:	0f 85 f4 fe ff ff    	jne    800fb6 <fork+0x76>
                        if(uvpt[pn] & PTE_P)
                            duppage(env_id, pn);
                    }
                }
            }
            if(sys_page_alloc(env_id,(void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8010c2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010d1:	ee 
  8010d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 10 fb ff ff       	call   800bed <sys_page_alloc>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 1c                	jns    8010fd <fork+0x1bd>
                panic("fork fail at sys_page_alloc!\n");
  8010e1:	c7 44 24 08 cd 1a 80 	movl   $0x801acd,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  8010f8:	e8 47 02 00 00       	call   801344 <_panic>
            if(sys_page_map(env_id, (void *)(UXSTACKTOP - PGSIZE), sys_getenvid(), PFTEMP, PTE_U|PTE_P|PTE_W) < 0)
  8010fd:	e8 ad fa ff ff       	call   800baf <sys_getenvid>
  801102:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801109:	00 
  80110a:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  801111:	00 
  801112:	89 44 24 08          	mov    %eax,0x8(%esp)
  801116:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80111d:	ee 
  80111e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801121:	89 04 24             	mov    %eax,(%esp)
  801124:	e8 18 fb ff ff       	call   800c41 <sys_page_map>
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 1c                	jns    801149 <fork+0x209>
                panic("fork fail at sys_page_map!\n");
  80112d:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  801144:	e8 fb 01 00 00       	call   801344 <_panic>
            memmove((void *)(UXSTACKTOP - PGSIZE),PFTEMP, PGSIZE);
  801149:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  801160:	e8 0f f8 ff ff       	call   800974 <memmove>
            if(sys_page_unmap(sys_getenvid(), PFTEMP) < 0)
  801165:	e8 45 fa ff ff       	call   800baf <sys_getenvid>
  80116a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801171:	00 
  801172:	89 04 24             	mov    %eax,(%esp)
  801175:	e8 1a fb ff ff       	call   800c94 <sys_page_unmap>
  80117a:	85 c0                	test   %eax,%eax
  80117c:	79 1c                	jns    80119a <fork+0x25a>
                panic("fork fail at sys_page_unmap!\n");
  80117e:	c7 44 24 08 07 1b 80 	movl   $0x801b07,0x8(%esp)
  801185:	00 
  801186:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80118d:	00 
  80118e:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  801195:	e8 aa 01 00 00       	call   801344 <_panic>
            
            extern void _pgfault_upcall(void);
            if(sys_env_set_pgfault_upcall(env_id, _pgfault_upcall) < 0)
  80119a:	c7 44 24 04 28 14 80 	movl   $0x801428,0x4(%esp)
  8011a1:	00 
  8011a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 8d fb ff ff       	call   800d3a <sys_env_set_pgfault_upcall>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	79 1c                	jns    8011cd <fork+0x28d>
                panic("fork fail at sys_env_set_pgfault_upcall!\n");
  8011b1:	c7 44 24 08 e8 19 80 	movl   $0x8019e8,0x8(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  8011c0:	00 
  8011c1:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  8011c8:	e8 77 01 00 00       	call   801344 <_panic>
            if(sys_env_set_status(env_id,ENV_RUNNABLE) < 0)
  8011cd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011d4:	00 
  8011d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d8:	89 04 24             	mov    %eax,(%esp)
  8011db:	e8 07 fb ff ff       	call   800ce7 <sys_env_set_status>
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 1c                	jns    801200 <fork+0x2c0>
                panic("fork fail at sys_env_set_status!\n");
  8011e4:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  8011f3:	00 
  8011f4:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  8011fb:	e8 44 01 00 00       	call   801344 <_panic>
            return env_id;
        }
}
  801200:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801203:	83 c4 4c             	add    $0x4c,%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <sfork>:

// Challenge!
int
sfork(void)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801211:	c7 44 24 08 25 1b 80 	movl   $0x801b25,0x8(%esp)
  801218:	00 
  801219:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  801220:	00 
  801221:	c7 04 24 36 1a 80 00 	movl   $0x801a36,(%esp)
  801228:	e8 17 01 00 00       	call   801344 <_panic>
  80122d:	00 00                	add    %al,(%eax)
	...

00801230 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 10             	sub    $0x10,%esp
  801238:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg)
  801241:	85 c0                	test   %eax,%eax
  801243:	75 05                	jne    80124a <ipc_recv+0x1a>
            pg = (void *)-1;
  801245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        int32_t ret;
        if((ret = (sys_ipc_recv(pg))) < 0){
  80124a:	89 04 24             	mov    %eax,(%esp)
  80124d:	e8 5e fb ff ff       	call   800db0 <sys_ipc_recv>
  801252:	85 c0                	test   %eax,%eax
  801254:	79 16                	jns    80126c <ipc_recv+0x3c>
            if(from_env_store)
  801256:	85 db                	test   %ebx,%ebx
  801258:	74 06                	je     801260 <ipc_recv+0x30>
                *from_env_store = 0;
  80125a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
            if(perm_store)
  801260:	85 f6                	test   %esi,%esi
  801262:	74 2c                	je     801290 <ipc_recv+0x60>
                *perm_store = 0;
  801264:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80126a:	eb 24                	jmp    801290 <ipc_recv+0x60>
            return ret;
        }
        if(from_env_store)
  80126c:	85 db                	test   %ebx,%ebx
  80126e:	74 0a                	je     80127a <ipc_recv+0x4a>
            *from_env_store = thisenv->env_ipc_from;
  801270:	a1 08 20 80 00       	mov    0x802008,%eax
  801275:	8b 40 74             	mov    0x74(%eax),%eax
  801278:	89 03                	mov    %eax,(%ebx)
        if(perm_store)
  80127a:	85 f6                	test   %esi,%esi
  80127c:	74 0a                	je     801288 <ipc_recv+0x58>
            *perm_store = thisenv->env_ipc_perm;
  80127e:	a1 08 20 80 00       	mov    0x802008,%eax
  801283:	8b 40 78             	mov    0x78(%eax),%eax
  801286:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801288:	a1 08 20 80 00       	mov    0x802008,%eax
  80128d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	57                   	push   %edi
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
  80129d:	83 ec 1c             	sub    $0x1c,%esp
  8012a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a6:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg)
  8012a9:	85 db                	test   %ebx,%ebx
  8012ab:	75 2d                	jne    8012da <ipc_send+0x43>
            pg = (void *)-1;
  8012ad:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8012b2:	eb 26                	jmp    8012da <ipc_send+0x43>
        int32_t ret;
        while((ret = sys_ipc_try_send(to_env, val, pg, perm)) != 0){
            if(ret != -E_IPC_NOT_RECV)
  8012b4:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8012b7:	74 1c                	je     8012d5 <ipc_send+0x3e>
                panic("ipc_send fail at sys_ipc_try_send!\n");
  8012b9:	c7 44 24 08 3c 1b 80 	movl   $0x801b3c,0x8(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8012c8:	00 
  8012c9:	c7 04 24 60 1b 80 00 	movl   $0x801b60,(%esp)
  8012d0:	e8 6f 00 00 00       	call   801344 <_panic>
            sys_yield();
  8012d5:	e8 f4 f8 ff ff       	call   800bce <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg)
            pg = (void *)-1;
        int32_t ret;
        while((ret = sys_ipc_try_send(to_env, val, pg, perm)) != 0){
  8012da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e9:	89 04 24             	mov    %eax,(%esp)
  8012ec:	e8 9c fa ff ff       	call   800d8d <sys_ipc_try_send>
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	75 bf                	jne    8012b4 <ipc_send+0x1d>
            if(ret != -E_IPC_NOT_RECV)
                panic("ipc_send fail at sys_ipc_try_send!\n");
            sys_yield();
        }
}
  8012f5:	83 c4 1c             	add    $0x1c,%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801304:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801309:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801310:	89 c2                	mov    %eax,%edx
  801312:	c1 e2 07             	shl    $0x7,%edx
  801315:	29 ca                	sub    %ecx,%edx
  801317:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80131d:	8b 52 50             	mov    0x50(%edx),%edx
  801320:	39 da                	cmp    %ebx,%edx
  801322:	75 0f                	jne    801333 <ipc_find_env+0x36>
			return envs[i].env_id;
  801324:	c1 e0 07             	shl    $0x7,%eax
  801327:	29 c8                	sub    %ecx,%eax
  801329:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80132e:	8b 40 40             	mov    0x40(%eax),%eax
  801331:	eb 0c                	jmp    80133f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801333:	40                   	inc    %eax
  801334:	3d 00 04 00 00       	cmp    $0x400,%eax
  801339:	75 ce                	jne    801309 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80133b:	66 b8 00 00          	mov    $0x0,%ax
}
  80133f:	5b                   	pop    %ebx
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
	...

00801344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80134c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80134f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801355:	e8 55 f8 ff ff       	call   800baf <sys_getenvid>
  80135a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801361:	8b 55 08             	mov    0x8(%ebp),%edx
  801364:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801368:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	c7 04 24 6c 1b 80 00 	movl   $0x801b6c,(%esp)
  801377:	e8 d4 ee ff ff       	call   800250 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80137c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801380:	8b 45 10             	mov    0x10(%ebp),%eax
  801383:	89 04 24             	mov    %eax,(%esp)
  801386:	e8 64 ee ff ff       	call   8001ef <vcprintf>
	cprintf("\n");
  80138b:	c7 04 24 af 1a 80 00 	movl   $0x801aaf,(%esp)
  801392:	e8 b9 ee ff ff       	call   800250 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801397:	cc                   	int3   
  801398:	eb fd                	jmp    801397 <_panic+0x53>
	...

0080139c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013a2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8013a9:	75 3d                	jne    8013e8 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  8013ab:	e8 ff f7 ff ff       	call   800baf <sys_getenvid>
  8013b0:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8013b7:	00 
  8013b8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013bf:	ee 
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 25 f8 ff ff       	call   800bed <sys_page_alloc>
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	79 1c                	jns    8013e8 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  8013cc:	c7 44 24 08 90 1b 80 	movl   $0x801b90,0x8(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8013db:	00 
  8013dc:	c7 04 24 e8 1b 80 00 	movl   $0x801be8,(%esp)
  8013e3:	e8 5c ff ff ff       	call   801344 <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013eb:	a3 0c 20 80 00       	mov    %eax,0x80200c
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  8013f0:	e8 ba f7 ff ff       	call   800baf <sys_getenvid>
  8013f5:	c7 44 24 04 28 14 80 	movl   $0x801428,0x4(%esp)
  8013fc:	00 
  8013fd:	89 04 24             	mov    %eax,(%esp)
  801400:	e8 35 f9 ff ff       	call   800d3a <sys_env_set_pgfault_upcall>
  801405:	85 c0                	test   %eax,%eax
  801407:	79 1c                	jns    801425 <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  801409:	c7 44 24 08 c0 1b 80 	movl   $0x801bc0,0x8(%esp)
  801410:	00 
  801411:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801418:	00 
  801419:	c7 04 24 e8 1b 80 00 	movl   $0x801be8,(%esp)
  801420:	e8 1f ff ff ff       	call   801344 <_panic>
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    
	...

00801428 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801428:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801429:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80142e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801430:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  801433:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  801435:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  801439:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  80143d:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  80143e:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  801440:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  801445:	58                   	pop    %eax
        popl %eax
  801446:	58                   	pop    %eax
        popal
  801447:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  801448:	83 c4 04             	add    $0x4,%esp
        popfl
  80144b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80144c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  80144d:	c3                   	ret    
	...

00801450 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801450:	55                   	push   %ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	83 ec 10             	sub    $0x10,%esp
  801456:	8b 74 24 20          	mov    0x20(%esp),%esi
  80145a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80145e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801462:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801466:	89 cd                	mov    %ecx,%ebp
  801468:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80146c:	85 c0                	test   %eax,%eax
  80146e:	75 2c                	jne    80149c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801470:	39 f9                	cmp    %edi,%ecx
  801472:	77 68                	ja     8014dc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801474:	85 c9                	test   %ecx,%ecx
  801476:	75 0b                	jne    801483 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801478:	b8 01 00 00 00       	mov    $0x1,%eax
  80147d:	31 d2                	xor    %edx,%edx
  80147f:	f7 f1                	div    %ecx
  801481:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801483:	31 d2                	xor    %edx,%edx
  801485:	89 f8                	mov    %edi,%eax
  801487:	f7 f1                	div    %ecx
  801489:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80148b:	89 f0                	mov    %esi,%eax
  80148d:	f7 f1                	div    %ecx
  80148f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801491:	89 f0                	mov    %esi,%eax
  801493:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	5e                   	pop    %esi
  801499:	5f                   	pop    %edi
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80149c:	39 f8                	cmp    %edi,%eax
  80149e:	77 2c                	ja     8014cc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014a0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8014a3:	83 f6 1f             	xor    $0x1f,%esi
  8014a6:	75 4c                	jne    8014f4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014a8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014aa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014af:	72 0a                	jb     8014bb <__udivdi3+0x6b>
  8014b1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014b5:	0f 87 ad 00 00 00    	ja     801568 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014bb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014c0:	89 f0                	mov    %esi,%eax
  8014c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    
  8014cb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014cc:	31 ff                	xor    %edi,%edi
  8014ce:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014d0:	89 f0                	mov    %esi,%eax
  8014d2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014dc:	89 fa                	mov    %edi,%edx
  8014de:	89 f0                	mov    %esi,%eax
  8014e0:	f7 f1                	div    %ecx
  8014e2:	89 c6                	mov    %eax,%esi
  8014e4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014e6:	89 f0                	mov    %esi,%eax
  8014e8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    
  8014f1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8014f4:	89 f1                	mov    %esi,%ecx
  8014f6:	d3 e0                	shl    %cl,%eax
  8014f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014fc:	b8 20 00 00 00       	mov    $0x20,%eax
  801501:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801503:	89 ea                	mov    %ebp,%edx
  801505:	88 c1                	mov    %al,%cl
  801507:	d3 ea                	shr    %cl,%edx
  801509:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80150d:	09 ca                	or     %ecx,%edx
  80150f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801513:	89 f1                	mov    %esi,%ecx
  801515:	d3 e5                	shl    %cl,%ebp
  801517:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80151b:	89 fd                	mov    %edi,%ebp
  80151d:	88 c1                	mov    %al,%cl
  80151f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801521:	89 fa                	mov    %edi,%edx
  801523:	89 f1                	mov    %esi,%ecx
  801525:	d3 e2                	shl    %cl,%edx
  801527:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80152b:	88 c1                	mov    %al,%cl
  80152d:	d3 ef                	shr    %cl,%edi
  80152f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801531:	89 f8                	mov    %edi,%eax
  801533:	89 ea                	mov    %ebp,%edx
  801535:	f7 74 24 08          	divl   0x8(%esp)
  801539:	89 d1                	mov    %edx,%ecx
  80153b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80153d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801541:	39 d1                	cmp    %edx,%ecx
  801543:	72 17                	jb     80155c <__udivdi3+0x10c>
  801545:	74 09                	je     801550 <__udivdi3+0x100>
  801547:	89 fe                	mov    %edi,%esi
  801549:	31 ff                	xor    %edi,%edi
  80154b:	e9 41 ff ff ff       	jmp    801491 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801550:	8b 54 24 04          	mov    0x4(%esp),%edx
  801554:	89 f1                	mov    %esi,%ecx
  801556:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801558:	39 c2                	cmp    %eax,%edx
  80155a:	73 eb                	jae    801547 <__udivdi3+0xf7>
		{
		  q0--;
  80155c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80155f:	31 ff                	xor    %edi,%edi
  801561:	e9 2b ff ff ff       	jmp    801491 <__udivdi3+0x41>
  801566:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801568:	31 f6                	xor    %esi,%esi
  80156a:	e9 22 ff ff ff       	jmp    801491 <__udivdi3+0x41>
	...

00801570 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801570:	55                   	push   %ebp
  801571:	57                   	push   %edi
  801572:	56                   	push   %esi
  801573:	83 ec 20             	sub    $0x20,%esp
  801576:	8b 44 24 30          	mov    0x30(%esp),%eax
  80157a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80157e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801582:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801586:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80158a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80158e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801590:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801592:	85 ed                	test   %ebp,%ebp
  801594:	75 16                	jne    8015ac <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801596:	39 f1                	cmp    %esi,%ecx
  801598:	0f 86 a6 00 00 00    	jbe    801644 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80159e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8015a0:	89 d0                	mov    %edx,%eax
  8015a2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015a4:	83 c4 20             	add    $0x20,%esp
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    
  8015ab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015ac:	39 f5                	cmp    %esi,%ebp
  8015ae:	0f 87 ac 00 00 00    	ja     801660 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8015b4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8015b7:	83 f0 1f             	xor    $0x1f,%eax
  8015ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015be:	0f 84 a8 00 00 00    	je     80166c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015c4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015c8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015ca:	bf 20 00 00 00       	mov    $0x20,%edi
  8015cf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8015d3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015d7:	89 f9                	mov    %edi,%ecx
  8015d9:	d3 e8                	shr    %cl,%eax
  8015db:	09 e8                	or     %ebp,%eax
  8015dd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8015e1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015e5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015e9:	d3 e0                	shl    %cl,%eax
  8015eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015ef:	89 f2                	mov    %esi,%edx
  8015f1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8015f3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015f7:	d3 e0                	shl    %cl,%eax
  8015f9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015fd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801601:	89 f9                	mov    %edi,%ecx
  801603:	d3 e8                	shr    %cl,%eax
  801605:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801607:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801609:	89 f2                	mov    %esi,%edx
  80160b:	f7 74 24 18          	divl   0x18(%esp)
  80160f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801611:	f7 64 24 0c          	mull   0xc(%esp)
  801615:	89 c5                	mov    %eax,%ebp
  801617:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801619:	39 d6                	cmp    %edx,%esi
  80161b:	72 67                	jb     801684 <__umoddi3+0x114>
  80161d:	74 75                	je     801694 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80161f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801623:	29 e8                	sub    %ebp,%eax
  801625:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801627:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80162b:	d3 e8                	shr    %cl,%eax
  80162d:	89 f2                	mov    %esi,%edx
  80162f:	89 f9                	mov    %edi,%ecx
  801631:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801633:	09 d0                	or     %edx,%eax
  801635:	89 f2                	mov    %esi,%edx
  801637:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80163b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801644:	85 c9                	test   %ecx,%ecx
  801646:	75 0b                	jne    801653 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801648:	b8 01 00 00 00       	mov    $0x1,%eax
  80164d:	31 d2                	xor    %edx,%edx
  80164f:	f7 f1                	div    %ecx
  801651:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801653:	89 f0                	mov    %esi,%eax
  801655:	31 d2                	xor    %edx,%edx
  801657:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801659:	89 f8                	mov    %edi,%eax
  80165b:	e9 3e ff ff ff       	jmp    80159e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801660:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801662:	83 c4 20             	add    $0x20,%esp
  801665:	5e                   	pop    %esi
  801666:	5f                   	pop    %edi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    
  801669:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80166c:	39 f5                	cmp    %esi,%ebp
  80166e:	72 04                	jb     801674 <__umoddi3+0x104>
  801670:	39 f9                	cmp    %edi,%ecx
  801672:	77 06                	ja     80167a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801674:	89 f2                	mov    %esi,%edx
  801676:	29 cf                	sub    %ecx,%edi
  801678:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80167a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80167c:	83 c4 20             	add    $0x20,%esp
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    
  801683:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801684:	89 d1                	mov    %edx,%ecx
  801686:	89 c5                	mov    %eax,%ebp
  801688:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80168c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801690:	eb 8d                	jmp    80161f <__umoddi3+0xaf>
  801692:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801694:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801698:	72 ea                	jb     801684 <__umoddi3+0x114>
  80169a:	89 f1                	mov    %esi,%ecx
  80169c:	eb 81                	jmp    80161f <__umoddi3+0xaf>
