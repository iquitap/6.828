
obj/user/faultdie：     文件格式 elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800054:	e8 37 01 00 00       	call   800190 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 91 0a 00 00       	call   800aef <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 37 0a 00 00       	call   800a9d <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 ca 0c 00 00       	call   800d44 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800096:	e8 54 0a 00 00       	call   800aef <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b6:	85 f6                	test   %esi,%esi
  8000b8:	7e 07                	jle    8000c1 <libmain+0x39>
		binaryname = argv[0];
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c5:	89 34 24             	mov    %esi,(%esp)
  8000c8:	e8 9b ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 0a 00 00 00       	call   8000dc <exit>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5d                   	pop    %ebp
  8000d8:	c3                   	ret    
  8000d9:	00 00                	add    %al,(%eax)
	...

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 af 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 14             	sub    $0x14,%esp
  8000f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fa:	8b 03                	mov    (%ebx),%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800103:	40                   	inc    %eax
  800104:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800106:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010b:	75 19                	jne    800126 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80010d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800114:	00 
  800115:	8d 43 08             	lea    0x8(%ebx),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 40 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800126:	ff 43 04             	incl   0x4(%ebx)
}
  800129:	83 c4 14             	add    $0x14,%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800138:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013f:	00 00 00 
	b.cnt = 0;
  800142:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800149:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800153:	8b 45 08             	mov    0x8(%ebp),%eax
  800156:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	c7 04 24 f0 00 80 00 	movl   $0x8000f0,(%esp)
  80016b:	e8 82 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 d8 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 87 ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    
	...

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 3c             	sub    $0x3c,%esp
  8001b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b8:	89 d7                	mov    %edx,%edi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	75 08                	jne    8001d8 <printnum+0x2c>
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 57                	ja     80022f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001dc:	4b                   	dec    %ebx
  8001dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f7:	00 
  8001f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	e8 46 0c 00 00       	call   800e50 <__udivdi3>
  80020a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80020e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 fa                	mov    %edi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 89 ff ff ff       	call   8001ac <printnum>
  800223:	eb 0f                	jmp    800234 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	89 34 24             	mov    %esi,(%esp)
  80022c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	4b                   	dec    %ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f f1                	jg     800225 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800238:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	e8 13 0d 00 00       	call   800f70 <__umoddi3>
  80025d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800261:	0f be 80 c6 10 80 00 	movsbl 0x8010c6(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 3c             	add    $0x3c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 08                	jae    8002c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c3:	88 0a                	mov    %cl,(%edx)
  8002c5:	42                   	inc    %edx
  8002c6:	89 10                	mov    %edx,(%eax)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 02 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 4c             	sub    $0x4c,%esp
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800301:	eb 12                	jmp    800315 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800303:	85 c0                	test   %eax,%eax
  800305:	0f 84 6b 03 00 00    	je     800676 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80030b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030f:	89 04 24             	mov    %eax,(%esp)
  800312:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800315:	0f b6 06             	movzbl (%esi),%eax
  800318:	46                   	inc    %esi
  800319:	83 f8 25             	cmp    $0x25,%eax
  80031c:	75 e5                	jne    800303 <vprintfmt+0x11>
  80031e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800329:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80032e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	eb 26                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800343:	eb 1d                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80034c:	eb 14                	jmp    800362 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800351:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800358:	eb 08                	jmp    800362 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80035d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	0f b6 06             	movzbl (%esi),%eax
  800365:	8d 56 01             	lea    0x1(%esi),%edx
  800368:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80036b:	8a 16                	mov    (%esi),%dl
  80036d:	83 ea 23             	sub    $0x23,%edx
  800370:	80 fa 55             	cmp    $0x55,%dl
  800373:	0f 87 e1 02 00 00    	ja     80065a <vprintfmt+0x368>
  800379:	0f b6 d2             	movzbl %dl,%edx
  80037c:	ff 24 95 80 11 80 00 	jmp    *0x801180(,%edx,4)
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800386:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80038e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800392:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800395:	8d 50 d0             	lea    -0x30(%eax),%edx
  800398:	83 fa 09             	cmp    $0x9,%edx
  80039b:	77 2a                	ja     8003c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80039e:	eb eb                	jmp    80038b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ae:	eb 17                	jmp    8003c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b4:	78 98                	js     80034e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b9:	eb a7                	jmp    800362 <vprintfmt+0x70>
  8003bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003c5:	eb 9b                	jmp    800362 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cb:	79 95                	jns    800362 <vprintfmt+0x70>
  8003cd:	eb 8b                	jmp    80035a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d3:	eb 8d                	jmp    800362 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 50 04             	lea    0x4(%eax),%edx
  8003db:	89 55 14             	mov    %edx,0x14(%ebp)
  8003de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ed:	e9 23 ff ff ff       	jmp    800315 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	79 02                	jns    800403 <vprintfmt+0x111>
  800401:	f7 d8                	neg    %eax
  800403:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800405:	83 f8 09             	cmp    $0x9,%eax
  800408:	7f 0b                	jg     800415 <vprintfmt+0x123>
  80040a:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	75 23                	jne    800438 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800415:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800419:	c7 44 24 08 de 10 80 	movl   $0x8010de,0x8(%esp)
  800420:	00 
  800421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 9a fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800433:	e9 dd fe ff ff       	jmp    800315 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800438:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043c:	c7 44 24 08 e7 10 80 	movl   $0x8010e7,0x8(%esp)
  800443:	00 
  800444:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800448:	8b 55 08             	mov    0x8(%ebp),%edx
  80044b:	89 14 24             	mov    %edx,(%esp)
  80044e:	e8 77 fe ff ff       	call   8002ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	e9 ba fe ff ff       	jmp    800315 <vprintfmt+0x23>
  80045b:	89 f9                	mov    %edi,%ecx
  80045d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800460:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 30                	mov    (%eax),%esi
  80046e:	85 f6                	test   %esi,%esi
  800470:	75 05                	jne    800477 <vprintfmt+0x185>
				p = "(null)";
  800472:	be d7 10 80 00       	mov    $0x8010d7,%esi
			if (width > 0 && padc != '-')
  800477:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047b:	0f 8e 84 00 00 00    	jle    800505 <vprintfmt+0x213>
  800481:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800485:	74 7e                	je     800505 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80048b:	89 34 24             	mov    %esi,(%esp)
  80048e:	e8 8b 02 00 00       	call   80071e <strnlen>
  800493:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800496:	29 c2                	sub    %eax,%edx
  800498:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80049b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80049f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004a5:	89 de                	mov    %ebx,%esi
  8004a7:	89 d3                	mov    %edx,%ebx
  8004a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	eb 0b                	jmp    8004b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b1:	89 3c 24             	mov    %edi,(%esp)
  8004b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	4b                   	dec    %ebx
  8004b8:	85 db                	test   %ebx,%ebx
  8004ba:	7f f1                	jg     8004ad <vprintfmt+0x1bb>
  8004bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004bf:	89 f3                	mov    %esi,%ebx
  8004c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	79 05                	jns    8004d0 <vprintfmt+0x1de>
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d8:	eb 2b                	jmp    800505 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004de:	74 18                	je     8004f8 <vprintfmt+0x206>
  8004e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e3:	83 fa 5e             	cmp    $0x5e,%edx
  8004e6:	76 10                	jbe    8004f8 <vprintfmt+0x206>
					putch('?', putdat);
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	eb 0a                	jmp    800502 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	ff 4d e4             	decl   -0x1c(%ebp)
  800505:	0f be 06             	movsbl (%esi),%eax
  800508:	46                   	inc    %esi
  800509:	85 c0                	test   %eax,%eax
  80050b:	74 21                	je     80052e <vprintfmt+0x23c>
  80050d:	85 ff                	test   %edi,%edi
  80050f:	78 c9                	js     8004da <vprintfmt+0x1e8>
  800511:	4f                   	dec    %edi
  800512:	79 c6                	jns    8004da <vprintfmt+0x1e8>
  800514:	8b 7d 08             	mov    0x8(%ebp),%edi
  800517:	89 de                	mov    %ebx,%esi
  800519:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051c:	eb 18                	jmp    800536 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800522:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800529:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	4b                   	dec    %ebx
  80052c:	eb 08                	jmp    800536 <vprintfmt+0x244>
  80052e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800531:	89 de                	mov    %ebx,%esi
  800533:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800536:	85 db                	test   %ebx,%ebx
  800538:	7f e4                	jg     80051e <vprintfmt+0x22c>
  80053a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80053d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800542:	e9 ce fd ff ff       	jmp    800315 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 10                	jle    80055c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 30                	mov    (%eax),%esi
  800557:	8b 78 04             	mov    0x4(%eax),%edi
  80055a:	eb 26                	jmp    800582 <vprintfmt+0x290>
	else if (lflag)
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	74 12                	je     800572 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 30                	mov    (%eax),%esi
  80056b:	89 f7                	mov    %esi,%edi
  80056d:	c1 ff 1f             	sar    $0x1f,%edi
  800570:	eb 10                	jmp    800582 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 30                	mov    (%eax),%esi
  80057d:	89 f7                	mov    %esi,%edi
  80057f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800582:	85 ff                	test   %edi,%edi
  800584:	78 0a                	js     800590 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 8c 00 00 00       	jmp    80061c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80059e:	f7 de                	neg    %esi
  8005a0:	83 d7 00             	adc    $0x0,%edi
  8005a3:	f7 df                	neg    %edi
			}
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	eb 70                	jmp    80061c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ac:	89 ca                	mov    %ecx,%edx
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 c0 fc ff ff       	call   800276 <getuint>
  8005b6:	89 c6                	mov    %eax,%esi
  8005b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005bf:	eb 5b                	jmp    80061c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8005c1:	89 ca                	mov    %ecx,%edx
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	e8 ab fc ff ff       	call   800276 <getuint>
  8005cb:	89 c6                	mov    %eax,%esi
  8005cd:	89 d7                	mov    %edx,%edi
                        base = 8;
  8005cf:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8005d4:	eb 46                	jmp    80061c <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fb:	8b 30                	mov    (%eax),%esi
  8005fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800602:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800607:	eb 13                	jmp    80061c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 63 fc ff ff       	call   800276 <getuint>
  800613:	89 c6                	mov    %eax,%esi
  800615:	89 d7                	mov    %edx,%edi
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800620:	89 54 24 10          	mov    %edx,0x10(%esp)
  800624:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800627:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062f:	89 34 24             	mov    %esi,(%esp)
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	89 da                	mov    %ebx,%edx
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	e8 6c fb ff ff       	call   8001ac <printnum>
			break;
  800640:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800643:	e9 cd fc ff ff       	jmp    800315 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800655:	e9 bb fc ff ff       	jmp    800315 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800665:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800668:	eb 01                	jmp    80066b <vprintfmt+0x379>
  80066a:	4e                   	dec    %esi
  80066b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066f:	75 f9                	jne    80066a <vprintfmt+0x378>
  800671:	e9 9f fc ff ff       	jmp    800315 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800676:	83 c4 4c             	add    $0x4c,%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 28             	sub    $0x28,%esp
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800691:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069b:	85 c0                	test   %eax,%eax
  80069d:	74 30                	je     8006cf <vsnprintf+0x51>
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	7e 33                	jle    8006d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  8006bf:	e8 2e fc ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	eb 0c                	jmp    8006db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb 05                	jmp    8006db <vsnprintf+0x5d>
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	89 04 24             	mov    %eax,(%esp)
  8006fe:	e8 7b ff ff ff       	call   80067e <vsnprintf>
	va_end(ap);

	return rc;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    
  800705:	00 00                	add    %al,(%eax)
	...

00800708 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	eb 01                	jmp    800716 <strlen+0xe>
		n++;
  800715:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071a:	75 f9                	jne    800715 <strlen+0xd>
		n++;
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
  80072c:	eb 01                	jmp    80072f <strnlen+0x11>
		n++;
  80072e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072f:	39 d0                	cmp    %edx,%eax
  800731:	74 06                	je     800739 <strnlen+0x1b>
  800733:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800737:	75 f5                	jne    80072e <strnlen+0x10>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80074d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800750:	42                   	inc    %edx
  800751:	84 c9                	test   %cl,%cl
  800753:	75 f5                	jne    80074a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800755:	5b                   	pop    %ebx
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	89 1c 24             	mov    %ebx,(%esp)
  800765:	e8 9e ff ff ff       	call   800708 <strlen>
	strcpy(dst + len, src);
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800771:	01 d8                	add    %ebx,%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 c0 ff ff ff       	call   80073b <strcpy>
	return dst;
}
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	83 c4 08             	add    $0x8,%esp
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	eb 0c                	jmp    8007a4 <strncpy+0x21>
		*dst++ = *src;
  800798:	8a 1a                	mov    (%edx),%bl
  80079a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079d:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	41                   	inc    %ecx
  8007a4:	39 f1                	cmp    %esi,%ecx
  8007a6:	75 f0                	jne    800798 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	75 0a                	jne    8007c8 <strlcpy+0x1c>
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	eb 1a                	jmp    8007dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	88 18                	mov    %bl,(%eax)
  8007c4:	40                   	inc    %eax
  8007c5:	41                   	inc    %ecx
  8007c6:	eb 02                	jmp    8007ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ca:	4a                   	dec    %edx
  8007cb:	74 0a                	je     8007d7 <strlcpy+0x2b>
  8007cd:	8a 19                	mov    (%ecx),%bl
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strlcpy+0x16>
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	eb 02                	jmp    8007d9 <strlcpy+0x2d>
  8007d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007dc:	29 f0                	sub    %esi,%eax
}
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007eb:	eb 02                	jmp    8007ef <strcmp+0xd>
		p++, q++;
  8007ed:	41                   	inc    %ecx
  8007ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ef:	8a 01                	mov    (%ecx),%al
  8007f1:	84 c0                	test   %al,%al
  8007f3:	74 04                	je     8007f9 <strcmp+0x17>
  8007f5:	3a 02                	cmp    (%edx),%al
  8007f7:	74 f4                	je     8007ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f9:	0f b6 c0             	movzbl %al,%eax
  8007fc:	0f b6 12             	movzbl (%edx),%edx
  8007ff:	29 d0                	sub    %edx,%eax
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800810:	eb 03                	jmp    800815 <strncmp+0x12>
		n--, p++, q++;
  800812:	4a                   	dec    %edx
  800813:	40                   	inc    %eax
  800814:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 14                	je     80082d <strncmp+0x2a>
  800819:	8a 18                	mov    (%eax),%bl
  80081b:	84 db                	test   %bl,%bl
  80081d:	74 04                	je     800823 <strncmp+0x20>
  80081f:	3a 19                	cmp    (%ecx),%bl
  800821:	74 ef                	je     800812 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 11             	movzbl (%ecx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083e:	eb 05                	jmp    800845 <strchr+0x10>
		if (*s == c)
  800840:	38 ca                	cmp    %cl,%dl
  800842:	74 0c                	je     800850 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800844:	40                   	inc    %eax
  800845:	8a 10                	mov    (%eax),%dl
  800847:	84 d2                	test   %dl,%dl
  800849:	75 f5                	jne    800840 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085b:	eb 05                	jmp    800862 <strfind+0x10>
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 07                	je     800868 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800861:	40                   	inc    %eax
  800862:	8a 10                	mov    (%eax),%dl
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f5                	jne    80085d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	8b 45 0c             	mov    0xc(%ebp),%eax
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 30                	je     8008ad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800883:	75 25                	jne    8008aa <memset+0x40>
  800885:	f6 c1 03             	test   $0x3,%cl
  800888:	75 20                	jne    8008aa <memset+0x40>
		c &= 0xFF;
  80088a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088d:	89 d3                	mov    %edx,%ebx
  80088f:	c1 e3 08             	shl    $0x8,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	c1 e6 18             	shl    $0x18,%esi
  800897:	89 d0                	mov    %edx,%eax
  800899:	c1 e0 10             	shl    $0x10,%eax
  80089c:	09 f0                	or     %esi,%eax
  80089e:	09 d0                	or     %edx,%eax
  8008a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008a5:	fc                   	cld    
  8008a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a8:	eb 03                	jmp    8008ad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 34                	jae    8008fa <memmove+0x46>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	73 2d                	jae    8008fa <memmove+0x46>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	f6 c2 03             	test   $0x3,%dl
  8008d3:	75 1b                	jne    8008f0 <memmove+0x3c>
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 13                	jne    8008f0 <memmove+0x3c>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0e                	jne    8008f0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e2:	83 ef 04             	sub    $0x4,%edi
  8008e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008eb:	fd                   	std    
  8008ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ee:	eb 07                	jmp    8008f7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f0:	4f                   	dec    %edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 20                	jmp    80091a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800900:	75 13                	jne    800915 <memmove+0x61>
  800902:	a8 03                	test   $0x3,%al
  800904:	75 0f                	jne    800915 <memmove+0x61>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	75 0a                	jne    800915 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80090b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80090e:	89 c7                	mov    %eax,%edi
  800910:	fc                   	cld    
  800911:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800913:	eb 05                	jmp    80091a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800915:	89 c7                	mov    %eax,%edi
  800917:	fc                   	cld    
  800918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
  800927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	e8 77 ff ff ff       	call   8008b4 <memmove>
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094e:	ba 00 00 00 00       	mov    $0x0,%edx
  800953:	eb 16                	jmp    80096b <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	8a 04 17             	mov    (%edi,%edx,1),%al
  800958:	42                   	inc    %edx
  800959:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80095d:	38 c8                	cmp    %cl,%al
  80095f:	74 0a                	je     80096b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800961:	0f b6 c0             	movzbl %al,%eax
  800964:	0f b6 c9             	movzbl %cl,%ecx
  800967:	29 c8                	sub    %ecx,%eax
  800969:	eb 09                	jmp    800974 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	39 da                	cmp    %ebx,%edx
  80096d:	75 e6                	jne    800955 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800982:	89 c2                	mov    %eax,%edx
  800984:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800987:	eb 05                	jmp    80098e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800989:	38 08                	cmp    %cl,(%eax)
  80098b:	74 05                	je     800992 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	40                   	inc    %eax
  80098e:	39 d0                	cmp    %edx,%eax
  800990:	72 f7                	jb     800989 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
  80099d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	eb 01                	jmp    8009a3 <strtol+0xf>
		s++;
  8009a2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	8a 02                	mov    (%edx),%al
  8009a5:	3c 20                	cmp    $0x20,%al
  8009a7:	74 f9                	je     8009a2 <strtol+0xe>
  8009a9:	3c 09                	cmp    $0x9,%al
  8009ab:	74 f5                	je     8009a2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ad:	3c 2b                	cmp    $0x2b,%al
  8009af:	75 08                	jne    8009b9 <strtol+0x25>
		s++;
  8009b1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 13                	jmp    8009cc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	75 0a                	jne    8009c7 <strtol+0x33>
		s++, neg = 1;
  8009bd:	8d 52 01             	lea    0x1(%edx),%edx
  8009c0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c5:	eb 05                	jmp    8009cc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	74 05                	je     8009d5 <strtol+0x41>
  8009d0:	83 fb 10             	cmp    $0x10,%ebx
  8009d3:	75 28                	jne    8009fd <strtol+0x69>
  8009d5:	8a 02                	mov    (%edx),%al
  8009d7:	3c 30                	cmp    $0x30,%al
  8009d9:	75 10                	jne    8009eb <strtol+0x57>
  8009db:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009df:	75 0a                	jne    8009eb <strtol+0x57>
		s += 2, base = 16;
  8009e1:	83 c2 02             	add    $0x2,%edx
  8009e4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e9:	eb 12                	jmp    8009fd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009eb:	85 db                	test   %ebx,%ebx
  8009ed:	75 0e                	jne    8009fd <strtol+0x69>
  8009ef:	3c 30                	cmp    $0x30,%al
  8009f1:	75 05                	jne    8009f8 <strtol+0x64>
		s++, base = 8;
  8009f3:	42                   	inc    %edx
  8009f4:	b3 08                	mov    $0x8,%bl
  8009f6:	eb 05                	jmp    8009fd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009f8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a04:	8a 0a                	mov    (%edx),%cl
  800a06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a09:	80 fb 09             	cmp    $0x9,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x82>
			dig = *s - '0';
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 30             	sub    $0x30,%ecx
  800a14:	eb 1e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a1e:	0f be c9             	movsbl %cl,%ecx
  800a21:	83 e9 57             	sub    $0x57,%ecx
  800a24:	eb 0e                	jmp    800a34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a29:	80 fb 19             	cmp    $0x19,%bl
  800a2c:	77 12                	ja     800a40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a2e:	0f be c9             	movsbl %cl,%ecx
  800a31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a34:	39 f1                	cmp    %esi,%ecx
  800a36:	7d 0c                	jge    800a44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a38:	42                   	inc    %edx
  800a39:	0f af c6             	imul   %esi,%eax
  800a3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb c4                	jmp    800a04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	89 c1                	mov    %eax,%ecx
  800a42:	eb 02                	jmp    800a46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4a:	74 05                	je     800a51 <strtol+0xbd>
		*endptr = (char *) s;
  800a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a51:	85 ff                	test   %edi,%edi
  800a53:	74 04                	je     800a59 <strtol+0xc5>
  800a55:	89 c8                	mov    %ecx,%eax
  800a57:	f7 d8                	neg    %eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
	...

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 28                	jle    800ae7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aca:	00 
  800acb:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800ad2:	00 
  800ad3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ada:	00 
  800adb:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800ae2:	e8 11 03 00 00       	call   800df8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae7:	83 c4 2c             	add    $0x2c,%esp
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	b8 02 00 00 00       	mov    $0x2,%eax
  800aff:	89 d1                	mov    %edx,%ecx
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	89 d7                	mov    %edx,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_yield>:

void
sys_yield(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	be 00 00 00 00       	mov    $0x0,%esi
  800b3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 f7                	mov    %esi,%edi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 28                	jle    800b79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b5c:	00 
  800b5d:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800b64:	00 
  800b65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b6c:	00 
  800b6d:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800b74:	e8 7f 02 00 00       	call   800df8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b79:	83 c4 2c             	add    $0x2c,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 28                	jle    800bcc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800baf:	00 
  800bb0:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800bb7:	00 
  800bb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbf:	00 
  800bc0:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800bc7:	e8 2c 02 00 00       	call   800df8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcc:	83 c4 2c             	add    $0x2c,%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	b8 06 00 00 00       	mov    $0x6,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 df                	mov    %ebx,%edi
  800bef:	89 de                	mov    %ebx,%esi
  800bf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 28                	jle    800c1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c1a:	e8 d9 01 00 00       	call   800df8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 28                	jle    800c72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c55:	00 
  800c56:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c5d:	00 
  800c5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c65:	00 
  800c66:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c6d:	e8 86 01 00 00       	call   800df8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c72:	83 c4 2c             	add    $0x2c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 28                	jle    800cc5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca8:	00 
  800ca9:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800cb0:	00 
  800cb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb8:	00 
  800cb9:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800cc0:	e8 33 01 00 00       	call   800df8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc5:	83 c4 2c             	add    $0x2c,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 cb                	mov    %ecx,%ebx
  800d08:	89 cf                	mov    %ecx,%edi
  800d0a:	89 ce                	mov    %ecx,%esi
  800d0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 28                	jle    800d3a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d16:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800d25:	00 
  800d26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2d:	00 
  800d2e:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800d35:	e8 be 00 00 00       	call   800df8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3a:	83 c4 2c             	add    $0x2c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
	...

00800d44 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d4a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d51:	75 3d                	jne    800d90 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  800d53:	e8 97 fd ff ff       	call   800aef <sys_getenvid>
  800d58:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800d5f:	00 
  800d60:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800d67:	ee 
  800d68:	89 04 24             	mov    %eax,(%esp)
  800d6b:	e8 bd fd ff ff       	call   800b2d <sys_page_alloc>
  800d70:	85 c0                	test   %eax,%eax
  800d72:	79 1c                	jns    800d90 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  800d74:	c7 44 24 08 34 13 80 	movl   $0x801334,0x8(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800d83:	00 
  800d84:	c7 04 24 89 13 80 00 	movl   $0x801389,(%esp)
  800d8b:	e8 68 00 00 00       	call   800df8 <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	a3 08 20 80 00       	mov    %eax,0x802008
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  800d98:	e8 52 fd ff ff       	call   800aef <sys_getenvid>
  800d9d:	c7 44 24 04 d0 0d 80 	movl   $0x800dd0,0x4(%esp)
  800da4:	00 
  800da5:	89 04 24             	mov    %eax,(%esp)
  800da8:	e8 cd fe ff ff       	call   800c7a <sys_env_set_pgfault_upcall>
  800dad:	85 c0                	test   %eax,%eax
  800daf:	79 1c                	jns    800dcd <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  800db1:	c7 44 24 08 64 13 80 	movl   $0x801364,0x8(%esp)
  800db8:	00 
  800db9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800dc0:	00 
  800dc1:	c7 04 24 89 13 80 00 	movl   $0x801389,(%esp)
  800dc8:	e8 2b 00 00 00       	call   800df8 <_panic>
}
  800dcd:	c9                   	leave  
  800dce:	c3                   	ret    
	...

00800dd0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dd0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dd1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dd6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dd8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  800ddb:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  800ddd:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  800de1:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  800de5:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  800de6:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  800de8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  800ded:	58                   	pop    %eax
        popl %eax
  800dee:	58                   	pop    %eax
        popal
  800def:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  800df0:	83 c4 04             	add    $0x4,%esp
        popfl
  800df3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800df4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  800df5:	c3                   	ret    
	...

00800df8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e00:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e03:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e09:	e8 e1 fc ff ff       	call   800aef <sys_getenvid>
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e1c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e24:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  800e2b:	e8 60 f3 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e30:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e34:	8b 45 10             	mov    0x10(%ebp),%eax
  800e37:	89 04 24             	mov    %eax,(%esp)
  800e3a:	e8 f0 f2 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  800e3f:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  800e46:	e8 45 f3 ff ff       	call   800190 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e4b:	cc                   	int3   
  800e4c:	eb fd                	jmp    800e4b <_panic+0x53>
	...

00800e50 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	83 ec 10             	sub    $0x10,%esp
  800e56:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e5a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e62:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e66:	89 cd                	mov    %ecx,%ebp
  800e68:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	75 2c                	jne    800e9c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e70:	39 f9                	cmp    %edi,%ecx
  800e72:	77 68                	ja     800edc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e74:	85 c9                	test   %ecx,%ecx
  800e76:	75 0b                	jne    800e83 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e78:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7d:	31 d2                	xor    %edx,%edx
  800e7f:	f7 f1                	div    %ecx
  800e81:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	89 f8                	mov    %edi,%eax
  800e87:	f7 f1                	div    %ecx
  800e89:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e8b:	89 f0                	mov    %esi,%eax
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e9c:	39 f8                	cmp    %edi,%eax
  800e9e:	77 2c                	ja     800ecc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ea0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800ea3:	83 f6 1f             	xor    $0x1f,%esi
  800ea6:	75 4c                	jne    800ef4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ea8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eaa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eaf:	72 0a                	jb     800ebb <__udivdi3+0x6b>
  800eb1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800eb5:	0f 87 ad 00 00 00    	ja     800f68 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ebb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ec0:	89 f0                	mov    %esi,%eax
  800ec2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
  800ecb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ecc:	31 ff                	xor    %edi,%edi
  800ece:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ed0:	89 f0                	mov    %esi,%eax
  800ed2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    
  800edb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800edc:	89 fa                	mov    %edi,%edx
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	f7 f1                	div    %ecx
  800ee2:	89 c6                	mov    %eax,%esi
  800ee4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee6:	89 f0                	mov    %esi,%eax
  800ee8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    
  800ef1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ef4:	89 f1                	mov    %esi,%ecx
  800ef6:	d3 e0                	shl    %cl,%eax
  800ef8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800efc:	b8 20 00 00 00       	mov    $0x20,%eax
  800f01:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f03:	89 ea                	mov    %ebp,%edx
  800f05:	88 c1                	mov    %al,%cl
  800f07:	d3 ea                	shr    %cl,%edx
  800f09:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f0d:	09 ca                	or     %ecx,%edx
  800f0f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f13:	89 f1                	mov    %esi,%ecx
  800f15:	d3 e5                	shl    %cl,%ebp
  800f17:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f1b:	89 fd                	mov    %edi,%ebp
  800f1d:	88 c1                	mov    %al,%cl
  800f1f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f21:	89 fa                	mov    %edi,%edx
  800f23:	89 f1                	mov    %esi,%ecx
  800f25:	d3 e2                	shl    %cl,%edx
  800f27:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f2b:	88 c1                	mov    %al,%cl
  800f2d:	d3 ef                	shr    %cl,%edi
  800f2f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f31:	89 f8                	mov    %edi,%eax
  800f33:	89 ea                	mov    %ebp,%edx
  800f35:	f7 74 24 08          	divl   0x8(%esp)
  800f39:	89 d1                	mov    %edx,%ecx
  800f3b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f3d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f41:	39 d1                	cmp    %edx,%ecx
  800f43:	72 17                	jb     800f5c <__udivdi3+0x10c>
  800f45:	74 09                	je     800f50 <__udivdi3+0x100>
  800f47:	89 fe                	mov    %edi,%esi
  800f49:	31 ff                	xor    %edi,%edi
  800f4b:	e9 41 ff ff ff       	jmp    800e91 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f50:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f54:	89 f1                	mov    %esi,%ecx
  800f56:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f58:	39 c2                	cmp    %eax,%edx
  800f5a:	73 eb                	jae    800f47 <__udivdi3+0xf7>
		{
		  q0--;
  800f5c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f5f:	31 ff                	xor    %edi,%edi
  800f61:	e9 2b ff ff ff       	jmp    800e91 <__udivdi3+0x41>
  800f66:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f68:	31 f6                	xor    %esi,%esi
  800f6a:	e9 22 ff ff ff       	jmp    800e91 <__udivdi3+0x41>
	...

00800f70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	83 ec 20             	sub    $0x20,%esp
  800f76:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f7a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f7e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f82:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f86:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f8a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f8e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f90:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f92:	85 ed                	test   %ebp,%ebp
  800f94:	75 16                	jne    800fac <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f96:	39 f1                	cmp    %esi,%ecx
  800f98:	0f 86 a6 00 00 00    	jbe    801044 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f9e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fa0:	89 d0                	mov    %edx,%eax
  800fa2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fac:	39 f5                	cmp    %esi,%ebp
  800fae:	0f 87 ac 00 00 00    	ja     801060 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fb4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fb7:	83 f0 1f             	xor    $0x1f,%eax
  800fba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbe:	0f 84 a8 00 00 00    	je     80106c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fc4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fc8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fca:	bf 20 00 00 00       	mov    $0x20,%edi
  800fcf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fd3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fd7:	89 f9                	mov    %edi,%ecx
  800fd9:	d3 e8                	shr    %cl,%eax
  800fdb:	09 e8                	or     %ebp,%eax
  800fdd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fe1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fe5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fe9:	d3 e0                	shl    %cl,%eax
  800feb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fef:	89 f2                	mov    %esi,%edx
  800ff1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ff3:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ff7:	d3 e0                	shl    %cl,%eax
  800ff9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ffd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801001:	89 f9                	mov    %edi,%ecx
  801003:	d3 e8                	shr    %cl,%eax
  801005:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801007:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801009:	89 f2                	mov    %esi,%edx
  80100b:	f7 74 24 18          	divl   0x18(%esp)
  80100f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801011:	f7 64 24 0c          	mull   0xc(%esp)
  801015:	89 c5                	mov    %eax,%ebp
  801017:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801019:	39 d6                	cmp    %edx,%esi
  80101b:	72 67                	jb     801084 <__umoddi3+0x114>
  80101d:	74 75                	je     801094 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80101f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801023:	29 e8                	sub    %ebp,%eax
  801025:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801027:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	89 f9                	mov    %edi,%ecx
  801031:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801033:	09 d0                	or     %edx,%eax
  801035:	89 f2                	mov    %esi,%edx
  801037:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80103b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80103d:	83 c4 20             	add    $0x20,%esp
  801040:	5e                   	pop    %esi
  801041:	5f                   	pop    %edi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801044:	85 c9                	test   %ecx,%ecx
  801046:	75 0b                	jne    801053 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801048:	b8 01 00 00 00       	mov    $0x1,%eax
  80104d:	31 d2                	xor    %edx,%edx
  80104f:	f7 f1                	div    %ecx
  801051:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801053:	89 f0                	mov    %esi,%eax
  801055:	31 d2                	xor    %edx,%edx
  801057:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801059:	89 f8                	mov    %edi,%eax
  80105b:	e9 3e ff ff ff       	jmp    800f9e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801060:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801062:	83 c4 20             	add    $0x20,%esp
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
  801069:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80106c:	39 f5                	cmp    %esi,%ebp
  80106e:	72 04                	jb     801074 <__umoddi3+0x104>
  801070:	39 f9                	cmp    %edi,%ecx
  801072:	77 06                	ja     80107a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801074:	89 f2                	mov    %esi,%edx
  801076:	29 cf                	sub    %ecx,%edi
  801078:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80107a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    
  801083:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801084:	89 d1                	mov    %edx,%ecx
  801086:	89 c5                	mov    %eax,%ebp
  801088:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80108c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801090:	eb 8d                	jmp    80101f <__umoddi3+0xaf>
  801092:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801094:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801098:	72 ea                	jb     801084 <__umoddi3+0x114>
  80109a:	89 f1                	mov    %esi,%ecx
  80109c:	eb 81                	jmp    80101f <__umoddi3+0xaf>
