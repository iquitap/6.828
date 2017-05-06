
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  800041:	e8 22 01 00 00       	call   800168 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ee 0f 80 00 	movl   $0x800fee,(%esp)
  800059:	e8 0a 01 00 00       	call   800168 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  80006e:	e8 54 0a 00 00       	call   800ac7 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007f:	c1 e0 07             	shl    $0x7,%eax
  800082:	29 d0                	sub    %edx,%eax
  800084:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800089:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 f6                	test   %esi,%esi
  800090:	7e 07                	jle    800099 <libmain+0x39>
		binaryname = argv[0];
  800092:	8b 03                	mov    (%ebx),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800099:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 af 09 00 00       	call   800a75 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 40 09 00 00       	call   800a38 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	ff 43 04             	incl   0x4(%ebx)
}
  800101:	83 c4 14             	add    $0x14,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013c:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800143:	e8 82 01 00 00       	call   8002ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 d8 08 00 00       	call   800a38 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 87 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	75 08                	jne    8001b0 <printnum+0x2c>
  8001a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ae:	77 57                	ja     800207 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b4:	4b                   	dec    %ebx
  8001b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cf:	00 
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	e8 92 0b 00 00       	call   800d74 <__udivdi3>
  8001e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f1:	89 fa                	mov    %edi,%edx
  8001f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f6:	e8 89 ff ff ff       	call   800184 <printnum>
  8001fb:	eb 0f                	jmp    80020c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800201:	89 34 24             	mov    %esi,(%esp)
  800204:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800207:	4b                   	dec    %ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f f1                	jg     8001fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800222:	00 
  800223:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	e8 5f 0c 00 00       	call   800e94 <__umoddi3>
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	0f be 80 0f 10 80 00 	movsbl 0x80100f(%eax),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800246:	83 c4 3c             	add    $0x3c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x38>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800291:	8b 10                	mov    (%eax),%edx
  800293:	3b 50 04             	cmp    0x4(%eax),%edx
  800296:	73 08                	jae    8002a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	88 0a                	mov    %cl,(%edx)
  80029d:	42                   	inc    %edx
  80029e:	89 10                	mov    %edx,(%eax)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 02 00 00 00       	call   8002ca <vprintfmt>
	va_end(ap);
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 4c             	sub    $0x4c,%esp
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d9:	eb 12                	jmp    8002ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	0f 84 6b 03 00 00    	je     80064e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ed:	0f b6 06             	movzbl (%esi),%eax
  8002f0:	46                   	inc    %esi
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e5                	jne    8002db <vprintfmt+0x11>
  8002f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800301:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800306:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	eb 26                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800317:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80031b:	eb 1d                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800320:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800324:	eb 14                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	eb 08                	jmp    80033a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800332:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 06             	movzbl (%esi),%eax
  80033d:	8d 56 01             	lea    0x1(%esi),%edx
  800340:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800343:	8a 16                	mov    (%esi),%dl
  800345:	83 ea 23             	sub    $0x23,%edx
  800348:	80 fa 55             	cmp    $0x55,%dl
  80034b:	0f 87 e1 02 00 00    	ja     800632 <vprintfmt+0x368>
  800351:	0f b6 d2             	movzbl %dl,%edx
  800354:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  80035b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800363:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800366:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80036a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800370:	83 fa 09             	cmp    $0x9,%edx
  800373:	77 2a                	ja     80039f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800375:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800376:	eb eb                	jmp    800363 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 50 04             	lea    0x4(%eax),%edx
  80037e:	89 55 14             	mov    %edx,0x14(%ebp)
  800381:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800386:	eb 17                	jmp    80039f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800388:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038c:	78 98                	js     800326 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800391:	eb a7                	jmp    80033a <vprintfmt+0x70>
  800393:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80039d:	eb 9b                	jmp    80033a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a3:	79 95                	jns    80033a <vprintfmt+0x70>
  8003a5:	eb 8b                	jmp    800332 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	eb 8d                	jmp    80033a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c5:	e9 23 ff ff ff       	jmp    8002ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	79 02                	jns    8003db <vprintfmt+0x111>
  8003d9:	f7 d8                	neg    %eax
  8003db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 09             	cmp    $0x9,%eax
  8003e0:	7f 0b                	jg     8003ed <vprintfmt+0x123>
  8003e2:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	75 23                	jne    800410 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f1:	c7 44 24 08 27 10 80 	movl   $0x801027,0x8(%esp)
  8003f8:	00 
  8003f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 9a fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040b:	e9 dd fe ff ff       	jmp    8002ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800414:	c7 44 24 08 30 10 80 	movl   $0x801030,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	8b 55 08             	mov    0x8(%ebp),%edx
  800423:	89 14 24             	mov    %edx,(%esp)
  800426:	e8 77 fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042e:	e9 ba fe ff ff       	jmp    8002ed <vprintfmt+0x23>
  800433:	89 f9                	mov    %edi,%ecx
  800435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800438:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 30                	mov    (%eax),%esi
  800446:	85 f6                	test   %esi,%esi
  800448:	75 05                	jne    80044f <vprintfmt+0x185>
				p = "(null)";
  80044a:	be 20 10 80 00       	mov    $0x801020,%esi
			if (width > 0 && padc != '-')
  80044f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800453:	0f 8e 84 00 00 00    	jle    8004dd <vprintfmt+0x213>
  800459:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80045d:	74 7e                	je     8004dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800463:	89 34 24             	mov    %esi,(%esp)
  800466:	e8 8b 02 00 00       	call   8006f6 <strnlen>
  80046b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046e:	29 c2                	sub    %eax,%edx
  800470:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800473:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800477:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80047a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80047d:	89 de                	mov    %ebx,%esi
  80047f:	89 d3                	mov    %edx,%ebx
  800481:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0b                	jmp    800490 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800485:	89 74 24 04          	mov    %esi,0x4(%esp)
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	4b                   	dec    %ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f f1                	jg     800485 <vprintfmt+0x1bb>
  800494:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800497:	89 f3                	mov    %esi,%ebx
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80049c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 05                	jns    8004a8 <vprintfmt+0x1de>
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ab:	29 c2                	sub    %eax,%edx
  8004ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b0:	eb 2b                	jmp    8004dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b6:	74 18                	je     8004d0 <vprintfmt+0x206>
  8004b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bb:	83 fa 5e             	cmp    $0x5e,%edx
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x206>
					putch('?', putdat);
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	eb 0a                	jmp    8004da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	ff 4d e4             	decl   -0x1c(%ebp)
  8004dd:	0f be 06             	movsbl (%esi),%eax
  8004e0:	46                   	inc    %esi
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	74 21                	je     800506 <vprintfmt+0x23c>
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	78 c9                	js     8004b2 <vprintfmt+0x1e8>
  8004e9:	4f                   	dec    %edi
  8004ea:	79 c6                	jns    8004b2 <vprintfmt+0x1e8>
  8004ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ef:	89 de                	mov    %ebx,%esi
  8004f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800501:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800503:	4b                   	dec    %ebx
  800504:	eb 08                	jmp    80050e <vprintfmt+0x244>
  800506:	8b 7d 08             	mov    0x8(%ebp),%edi
  800509:	89 de                	mov    %ebx,%esi
  80050b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050e:	85 db                	test   %ebx,%ebx
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x22c>
  800512:	89 7d 08             	mov    %edi,0x8(%ebp)
  800515:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 ce fd ff ff       	jmp    8002ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051f:	83 f9 01             	cmp    $0x1,%ecx
  800522:	7e 10                	jle    800534 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 30                	mov    (%eax),%esi
  80052f:	8b 78 04             	mov    0x4(%eax),%edi
  800532:	eb 26                	jmp    80055a <vprintfmt+0x290>
	else if (lflag)
  800534:	85 c9                	test   %ecx,%ecx
  800536:	74 12                	je     80054a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 30                	mov    (%eax),%esi
  800543:	89 f7                	mov    %esi,%edi
  800545:	c1 ff 1f             	sar    $0x1f,%edi
  800548:	eb 10                	jmp    80055a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 30                	mov    (%eax),%esi
  800555:	89 f7                	mov    %esi,%edi
  800557:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	85 ff                	test   %edi,%edi
  80055c:	78 0a                	js     800568 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 8c 00 00 00       	jmp    8005f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800576:	f7 de                	neg    %esi
  800578:	83 d7 00             	adc    $0x0,%edi
  80057b:	f7 df                	neg    %edi
			}
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800582:	eb 70                	jmp    8005f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	89 ca                	mov    %ecx,%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 c0 fc ff ff       	call   80024e <getuint>
  80058e:	89 c6                	mov    %eax,%esi
  800590:	89 d7                	mov    %edx,%edi
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800597:	eb 5b                	jmp    8005f4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  800599:	89 ca                	mov    %ecx,%edx
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
  80059e:	e8 ab fc ff ff       	call   80024e <getuint>
  8005a3:	89 c6                	mov    %eax,%esi
  8005a5:	89 d7                	mov    %edx,%edi
                        base = 8;
  8005a7:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8005ac:	eb 46                	jmp    8005f4 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8005ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d3:	8b 30                	mov    (%eax),%esi
  8005d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005df:	eb 13                	jmp    8005f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	89 ca                	mov    %ecx,%edx
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 63 fc ff ff       	call   80024e <getuint>
  8005eb:	89 c6                	mov    %eax,%esi
  8005ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800603:	89 44 24 08          	mov    %eax,0x8(%esp)
  800607:	89 34 24             	mov    %esi,(%esp)
  80060a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060e:	89 da                	mov    %ebx,%edx
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	e8 6c fb ff ff       	call   800184 <printnum>
			break;
  800618:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061b:	e9 cd fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062d:	e9 bb fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800632:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800636:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80063d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800640:	eb 01                	jmp    800643 <vprintfmt+0x379>
  800642:	4e                   	dec    %esi
  800643:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800647:	75 f9                	jne    800642 <vprintfmt+0x378>
  800649:	e9 9f fc ff ff       	jmp    8002ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80064e:	83 c4 4c             	add    $0x4c,%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	83 ec 28             	sub    $0x28,%esp
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800662:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800665:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800669:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800673:	85 c0                	test   %eax,%eax
  800675:	74 30                	je     8006a7 <vsnprintf+0x51>
  800677:	85 d2                	test   %edx,%edx
  800679:	7e 33                	jle    8006ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800682:	8b 45 10             	mov    0x10(%ebp),%eax
  800685:	89 44 24 08          	mov    %eax,0x8(%esp)
  800689:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800697:	e8 2e fc ff ff       	call   8002ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a5:	eb 0c                	jmp    8006b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb 05                	jmp    8006b3 <vsnprintf+0x5d>
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    

008006b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	89 04 24             	mov    %eax,(%esp)
  8006d6:	e8 7b ff ff ff       	call   800656 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    
  8006dd:	00 00                	add    %al,(%eax)
	...

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 01                	jmp    8006ee <strlen+0xe>
		n++;
  8006ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f2:	75 f9                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 01                	jmp    800707 <strnlen+0x11>
		n++;
  800706:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	39 d0                	cmp    %edx,%eax
  800709:	74 06                	je     800711 <strnlen+0x1b>
  80070b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070f:	75 f5                	jne    800706 <strnlen+0x10>
		n++;
	return n;
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800725:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800728:	42                   	inc    %edx
  800729:	84 c9                	test   %cl,%cl
  80072b:	75 f5                	jne    800722 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072d:	5b                   	pop    %ebx
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073a:	89 1c 24             	mov    %ebx,(%esp)
  80073d:	e8 9e ff ff ff       	call   8006e0 <strlen>
	strcpy(dst + len, src);
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
  800745:	89 54 24 04          	mov    %edx,0x4(%esp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 c0 ff ff ff       	call   800713 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	83 c4 08             	add    $0x8,%esp
  800758:	5b                   	pop    %ebx
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	eb 0c                	jmp    80077c <strncpy+0x21>
		*dst++ = *src;
  800770:	8a 1a                	mov    (%edx),%bl
  800772:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 3a 01             	cmpb   $0x1,(%edx)
  800778:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	41                   	inc    %ecx
  80077c:	39 f1                	cmp    %esi,%ecx
  80077e:	75 f0                	jne    800770 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	75 0a                	jne    8007a0 <strlcpy+0x1c>
  800796:	89 f0                	mov    %esi,%eax
  800798:	eb 1a                	jmp    8007b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079a:	88 18                	mov    %bl,(%eax)
  80079c:	40                   	inc    %eax
  80079d:	41                   	inc    %ecx
  80079e:	eb 02                	jmp    8007a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007a2:	4a                   	dec    %edx
  8007a3:	74 0a                	je     8007af <strlcpy+0x2b>
  8007a5:	8a 19                	mov    (%ecx),%bl
  8007a7:	84 db                	test   %bl,%bl
  8007a9:	75 ef                	jne    80079a <strlcpy+0x16>
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	eb 02                	jmp    8007b1 <strlcpy+0x2d>
  8007af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c3:	eb 02                	jmp    8007c7 <strcmp+0xd>
		p++, q++;
  8007c5:	41                   	inc    %ecx
  8007c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c7:	8a 01                	mov    (%ecx),%al
  8007c9:	84 c0                	test   %al,%al
  8007cb:	74 04                	je     8007d1 <strcmp+0x17>
  8007cd:	3a 02                	cmp    (%edx),%al
  8007cf:	74 f4                	je     8007c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d1:	0f b6 c0             	movzbl %al,%eax
  8007d4:	0f b6 12             	movzbl (%edx),%edx
  8007d7:	29 d0                	sub    %edx,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e8:	eb 03                	jmp    8007ed <strncmp+0x12>
		n--, p++, q++;
  8007ea:	4a                   	dec    %edx
  8007eb:	40                   	inc    %eax
  8007ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 14                	je     800805 <strncmp+0x2a>
  8007f1:	8a 18                	mov    (%eax),%bl
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	74 04                	je     8007fb <strncmp+0x20>
  8007f7:	3a 19                	cmp    (%ecx),%bl
  8007f9:	74 ef                	je     8007ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 00             	movzbl (%eax),%eax
  8007fe:	0f b6 11             	movzbl (%ecx),%edx
  800801:	29 d0                	sub    %edx,%eax
  800803:	eb 05                	jmp    80080a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080a:	5b                   	pop    %ebx
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800816:	eb 05                	jmp    80081d <strchr+0x10>
		if (*s == c)
  800818:	38 ca                	cmp    %cl,%dl
  80081a:	74 0c                	je     800828 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081c:	40                   	inc    %eax
  80081d:	8a 10                	mov    (%eax),%dl
  80081f:	84 d2                	test   %dl,%dl
  800821:	75 f5                	jne    800818 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800833:	eb 05                	jmp    80083a <strfind+0x10>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 07                	je     800840 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800839:	40                   	inc    %eax
  80083a:	8a 10                	mov    (%eax),%dl
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f5                	jne    800835 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800851:	85 c9                	test   %ecx,%ecx
  800853:	74 30                	je     800885 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800855:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085b:	75 25                	jne    800882 <memset+0x40>
  80085d:	f6 c1 03             	test   $0x3,%cl
  800860:	75 20                	jne    800882 <memset+0x40>
		c &= 0xFF;
  800862:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800865:	89 d3                	mov    %edx,%ebx
  800867:	c1 e3 08             	shl    $0x8,%ebx
  80086a:	89 d6                	mov    %edx,%esi
  80086c:	c1 e6 18             	shl    $0x18,%esi
  80086f:	89 d0                	mov    %edx,%eax
  800871:	c1 e0 10             	shl    $0x10,%eax
  800874:	09 f0                	or     %esi,%eax
  800876:	09 d0                	or     %edx,%eax
  800878:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80087a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80087d:	fc                   	cld    
  80087e:	f3 ab                	rep stos %eax,%es:(%edi)
  800880:	eb 03                	jmp    800885 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800882:	fc                   	cld    
  800883:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 34                	jae    8008d2 <memmove+0x46>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	73 2d                	jae    8008d2 <memmove+0x46>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	f6 c2 03             	test   $0x3,%dl
  8008ab:	75 1b                	jne    8008c8 <memmove+0x3c>
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 13                	jne    8008c8 <memmove+0x3c>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0e                	jne    8008c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ba:	83 ef 04             	sub    $0x4,%edi
  8008bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c3:	fd                   	std    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 07                	jmp    8008cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c8:	4f                   	dec    %edi
  8008c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cc:	fd                   	std    
  8008cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cf:	fc                   	cld    
  8008d0:	eb 20                	jmp    8008f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d8:	75 13                	jne    8008ed <memmove+0x61>
  8008da:	a8 03                	test   $0x3,%al
  8008dc:	75 0f                	jne    8008ed <memmove+0x61>
  8008de:	f6 c1 03             	test   $0x3,%cl
  8008e1:	75 0a                	jne    8008ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e6:	89 c7                	mov    %eax,%edi
  8008e8:	fc                   	cld    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 05                	jmp    8008f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	fc                   	cld    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f2:	5e                   	pop    %esi
  8008f3:	5f                   	pop    %edi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 77 ff ff ff       	call   80088c <memmove>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 75 0c             	mov    0xc(%ebp),%esi
  800923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	eb 16                	jmp    800943 <memcmp+0x2c>
		if (*s1 != *s2)
  80092d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800930:	42                   	inc    %edx
  800931:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800935:	38 c8                	cmp    %cl,%al
  800937:	74 0a                	je     800943 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800939:	0f b6 c0             	movzbl %al,%eax
  80093c:	0f b6 c9             	movzbl %cl,%ecx
  80093f:	29 c8                	sub    %ecx,%eax
  800941:	eb 09                	jmp    80094c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	39 da                	cmp    %ebx,%edx
  800945:	75 e6                	jne    80092d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095a:	89 c2                	mov    %eax,%edx
  80095c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095f:	eb 05                	jmp    800966 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800961:	38 08                	cmp    %cl,(%eax)
  800963:	74 05                	je     80096a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800965:	40                   	inc    %eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	72 f7                	jb     800961 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 55 08             	mov    0x8(%ebp),%edx
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800978:	eb 01                	jmp    80097b <strtol+0xf>
		s++;
  80097a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097b:	8a 02                	mov    (%edx),%al
  80097d:	3c 20                	cmp    $0x20,%al
  80097f:	74 f9                	je     80097a <strtol+0xe>
  800981:	3c 09                	cmp    $0x9,%al
  800983:	74 f5                	je     80097a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800985:	3c 2b                	cmp    $0x2b,%al
  800987:	75 08                	jne    800991 <strtol+0x25>
		s++;
  800989:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098a:	bf 00 00 00 00       	mov    $0x0,%edi
  80098f:	eb 13                	jmp    8009a4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800991:	3c 2d                	cmp    $0x2d,%al
  800993:	75 0a                	jne    80099f <strtol+0x33>
		s++, neg = 1;
  800995:	8d 52 01             	lea    0x1(%edx),%edx
  800998:	bf 01 00 00 00       	mov    $0x1,%edi
  80099d:	eb 05                	jmp    8009a4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a4:	85 db                	test   %ebx,%ebx
  8009a6:	74 05                	je     8009ad <strtol+0x41>
  8009a8:	83 fb 10             	cmp    $0x10,%ebx
  8009ab:	75 28                	jne    8009d5 <strtol+0x69>
  8009ad:	8a 02                	mov    (%edx),%al
  8009af:	3c 30                	cmp    $0x30,%al
  8009b1:	75 10                	jne    8009c3 <strtol+0x57>
  8009b3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b7:	75 0a                	jne    8009c3 <strtol+0x57>
		s += 2, base = 16;
  8009b9:	83 c2 02             	add    $0x2,%edx
  8009bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c1:	eb 12                	jmp    8009d5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 0e                	jne    8009d5 <strtol+0x69>
  8009c7:	3c 30                	cmp    $0x30,%al
  8009c9:	75 05                	jne    8009d0 <strtol+0x64>
		s++, base = 8;
  8009cb:	42                   	inc    %edx
  8009cc:	b3 08                	mov    $0x8,%bl
  8009ce:	eb 05                	jmp    8009d5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009dc:	8a 0a                	mov    (%edx),%cl
  8009de:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e1:	80 fb 09             	cmp    $0x9,%bl
  8009e4:	77 08                	ja     8009ee <strtol+0x82>
			dig = *s - '0';
  8009e6:	0f be c9             	movsbl %cl,%ecx
  8009e9:	83 e9 30             	sub    $0x30,%ecx
  8009ec:	eb 1e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f6:	0f be c9             	movsbl %cl,%ecx
  8009f9:	83 e9 57             	sub    $0x57,%ecx
  8009fc:	eb 0e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 12                	ja     800a18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a06:	0f be c9             	movsbl %cl,%ecx
  800a09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	7d 0c                	jge    800a1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a10:	42                   	inc    %edx
  800a11:	0f af c6             	imul   %esi,%eax
  800a14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a16:	eb c4                	jmp    8009dc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	89 c1                	mov    %eax,%ecx
  800a1a:	eb 02                	jmp    800a1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 05                	je     800a29 <strtol+0xbd>
		*endptr = (char *) s;
  800a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	74 04                	je     800a31 <strtol+0xc5>
  800a2d:	89 c8                	mov    %ecx,%eax
  800a2f:	f7 d8                	neg    %eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    
	...

00800a38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 01 00 00 00       	mov    $0x1,%eax
  800a66:	89 d1                	mov    %edx,%ecx
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	89 d7                	mov    %edx,%edi
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	89 cb                	mov    %ecx,%ebx
  800a8d:	89 cf                	mov    %ecx,%edi
  800a8f:	89 ce                	mov    %ecx,%esi
  800a91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a93:	85 c0                	test   %eax,%eax
  800a95:	7e 28                	jle    800abf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aa2:	00 
  800aa3:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800aaa:	00 
  800aab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ab2:	00 
  800ab3:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800aba:	e8 5d 02 00 00       	call   800d1c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	83 c4 2c             	add    $0x2c,%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_yield>:

void
sys_yield(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	be 00 00 00 00       	mov    $0x0,%esi
  800b13:	b8 04 00 00 00       	mov    $0x4,%eax
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 f7                	mov    %esi,%edi
  800b23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 28                	jle    800b51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b34:	00 
  800b35:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b44:	00 
  800b45:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800b4c:	e8 cb 01 00 00       	call   800d1c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b51:	83 c4 2c             	add    $0x2c,%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 05 00 00 00       	mov    $0x5,%eax
  800b67:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 28                	jle    800ba4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b87:	00 
  800b88:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800b8f:	00 
  800b90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b97:	00 
  800b98:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800b9f:	e8 78 01 00 00       	call   800d1c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba4:	83 c4 2c             	add    $0x2c,%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 df                	mov    %ebx,%edi
  800bc7:	89 de                	mov    %ebx,%esi
  800bc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 28                	jle    800bf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bda:	00 
  800bdb:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800be2:	00 
  800be3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bea:	00 
  800beb:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800bf2:	e8 25 01 00 00       	call   800d1c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf7:	83 c4 2c             	add    $0x2c,%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 28                	jle    800c4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800c35:	00 
  800c36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3d:	00 
  800c3e:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800c45:	e8 d2 00 00 00       	call   800d1c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4a:	83 c4 2c             	add    $0x2c,%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 09 00 00 00       	mov    $0x9,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800c98:	e8 7f 00 00 00       	call   800d1c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	be 00 00 00 00       	mov    $0x0,%esi
  800cb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 cb                	mov    %ecx,%ebx
  800ce0:	89 cf                	mov    %ecx,%edi
  800ce2:	89 ce                	mov    %ecx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 28                	jle    800d12 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cee:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 08 68 12 80 	movl   $0x801268,0x8(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d05:	00 
  800d06:	c7 04 24 85 12 80 00 	movl   $0x801285,(%esp)
  800d0d:	e8 0a 00 00 00       	call   800d1c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d12:	83 c4 2c             	add    $0x2c,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
	...

00800d1c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d24:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d27:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d2d:	e8 95 fd ff ff       	call   800ac7 <sys_getenvid>
  800d32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d35:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d48:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800d4f:	e8 14 f4 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d58:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5b:	89 04 24             	mov    %eax,(%esp)
  800d5e:	e8 a4 f3 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800d63:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d6a:	e8 f9 f3 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d6f:	cc                   	int3   
  800d70:	eb fd                	jmp    800d6f <_panic+0x53>
	...

00800d74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d74:	55                   	push   %ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	83 ec 10             	sub    $0x10,%esp
  800d7a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d7e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d82:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d86:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d8a:	89 cd                	mov    %ecx,%ebp
  800d8c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	75 2c                	jne    800dc0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d94:	39 f9                	cmp    %edi,%ecx
  800d96:	77 68                	ja     800e00 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d98:	85 c9                	test   %ecx,%ecx
  800d9a:	75 0b                	jne    800da7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	f7 f1                	div    %ecx
  800da5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800da7:	31 d2                	xor    %edx,%edx
  800da9:	89 f8                	mov    %edi,%eax
  800dab:	f7 f1                	div    %ecx
  800dad:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800daf:	89 f0                	mov    %esi,%eax
  800db1:	f7 f1                	div    %ecx
  800db3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dc0:	39 f8                	cmp    %edi,%eax
  800dc2:	77 2c                	ja     800df0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dc4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dc7:	83 f6 1f             	xor    $0x1f,%esi
  800dca:	75 4c                	jne    800e18 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dcc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd3:	72 0a                	jb     800ddf <__udivdi3+0x6b>
  800dd5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dd9:	0f 87 ad 00 00 00    	ja     800e8c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ddf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de4:	89 f0                	mov    %esi,%eax
  800de6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df0:	31 ff                	xor    %edi,%edi
  800df2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df4:	89 f0                	mov    %esi,%eax
  800df6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    
  800dff:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e00:	89 fa                	mov    %edi,%edx
  800e02:	89 f0                	mov    %esi,%eax
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0a:	89 f0                	mov    %esi,%eax
  800e0c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e18:	89 f1                	mov    %esi,%ecx
  800e1a:	d3 e0                	shl    %cl,%eax
  800e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e20:	b8 20 00 00 00       	mov    $0x20,%eax
  800e25:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e27:	89 ea                	mov    %ebp,%edx
  800e29:	88 c1                	mov    %al,%cl
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e31:	09 ca                	or     %ecx,%edx
  800e33:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e37:	89 f1                	mov    %esi,%ecx
  800e39:	d3 e5                	shl    %cl,%ebp
  800e3b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e3f:	89 fd                	mov    %edi,%ebp
  800e41:	88 c1                	mov    %al,%cl
  800e43:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e45:	89 fa                	mov    %edi,%edx
  800e47:	89 f1                	mov    %esi,%ecx
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e4f:	88 c1                	mov    %al,%cl
  800e51:	d3 ef                	shr    %cl,%edi
  800e53:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e55:	89 f8                	mov    %edi,%eax
  800e57:	89 ea                	mov    %ebp,%edx
  800e59:	f7 74 24 08          	divl   0x8(%esp)
  800e5d:	89 d1                	mov    %edx,%ecx
  800e5f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e61:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e65:	39 d1                	cmp    %edx,%ecx
  800e67:	72 17                	jb     800e80 <__udivdi3+0x10c>
  800e69:	74 09                	je     800e74 <__udivdi3+0x100>
  800e6b:	89 fe                	mov    %edi,%esi
  800e6d:	31 ff                	xor    %edi,%edi
  800e6f:	e9 41 ff ff ff       	jmp    800db5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e74:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e78:	89 f1                	mov    %esi,%ecx
  800e7a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e7c:	39 c2                	cmp    %eax,%edx
  800e7e:	73 eb                	jae    800e6b <__udivdi3+0xf7>
		{
		  q0--;
  800e80:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e83:	31 ff                	xor    %edi,%edi
  800e85:	e9 2b ff ff ff       	jmp    800db5 <__udivdi3+0x41>
  800e8a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e8c:	31 f6                	xor    %esi,%esi
  800e8e:	e9 22 ff ff ff       	jmp    800db5 <__udivdi3+0x41>
	...

00800e94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	83 ec 20             	sub    $0x20,%esp
  800e9a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e9e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ea2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ea6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800eaa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eae:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eb2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800eb4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eb6:	85 ed                	test   %ebp,%ebp
  800eb8:	75 16                	jne    800ed0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eba:	39 f1                	cmp    %esi,%ecx
  800ebc:	0f 86 a6 00 00 00    	jbe    800f68 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ec4:	89 d0                	mov    %edx,%eax
  800ec6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec8:	83 c4 20             	add    $0x20,%esp
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    
  800ecf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed0:	39 f5                	cmp    %esi,%ebp
  800ed2:	0f 87 ac 00 00 00    	ja     800f84 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ed8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800edb:	83 f0 1f             	xor    $0x1f,%eax
  800ede:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee2:	0f 84 a8 00 00 00    	je     800f90 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ee8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eec:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eee:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ef7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e8                	shr    %cl,%eax
  800eff:	09 e8                	or     %ebp,%eax
  800f01:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f05:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f09:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f0d:	d3 e0                	shl    %cl,%eax
  800f0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f17:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1b:	d3 e0                	shl    %cl,%eax
  800f1d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f21:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f2b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	f7 74 24 18          	divl   0x18(%esp)
  800f33:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f35:	f7 64 24 0c          	mull   0xc(%esp)
  800f39:	89 c5                	mov    %eax,%ebp
  800f3b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f3d:	39 d6                	cmp    %edx,%esi
  800f3f:	72 67                	jb     800fa8 <__umoddi3+0x114>
  800f41:	74 75                	je     800fb8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f43:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f47:	29 e8                	sub    %ebp,%eax
  800f49:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f4b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4f:	d3 e8                	shr    %cl,%eax
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f57:	09 d0                	or     %edx,%eax
  800f59:	89 f2                	mov    %esi,%edx
  800f5b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f5f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f68:	85 c9                	test   %ecx,%ecx
  800f6a:	75 0b                	jne    800f77 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f71:	31 d2                	xor    %edx,%edx
  800f73:	f7 f1                	div    %ecx
  800f75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f7d:	89 f8                	mov    %edi,%eax
  800f7f:	e9 3e ff ff ff       	jmp    800ec2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f84:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f90:	39 f5                	cmp    %esi,%ebp
  800f92:	72 04                	jb     800f98 <__umoddi3+0x104>
  800f94:	39 f9                	cmp    %edi,%ecx
  800f96:	77 06                	ja     800f9e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	29 cf                	sub    %ecx,%edi
  800f9c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f9e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 c5                	mov    %eax,%ebp
  800fac:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb4:	eb 8d                	jmp    800f43 <__umoddi3+0xaf>
  800fb6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fb8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fbc:	72 ea                	jb     800fa8 <__umoddi3+0x114>
  800fbe:	89 f1                	mov    %esi,%ecx
  800fc0:	eb 81                	jmp    800f43 <__umoddi3+0xaf>
